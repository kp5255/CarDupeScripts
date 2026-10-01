--[[
    BLACK-BOX ROBLOX SECURITY RECON
    =================================
    Authorized/private testing only.

    Goal:
      Start with ZERO knowledge of the game's implementation.

    It:
      • inventories RemoteEvents/RemoteFunctions
      • categorizes likely game systems
      • detects newly-created/removed remotes
      • records object metadata
      • creates a searchable report
      • periodically rescans

    It does NOT automatically invoke arbitrary remotes.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    SCAN_INTERVAL = 5,
    VERBOSE = true,
    SHOW_ALL = true,
    MAX_RESULTS = 2000,
}

local State = {
    started = os.clock(),
    scanCount = 0,

    remotes = {},
    previous = {},

    categories = {
        vehicle = {},
        trade = {},
        inventory = {},
        purchase = {},
        reward = {},
        currency = {},
        player = {},
        unknown = {},
    },

    changes = {},
}

--==================================================
-- LOGGING
--==================================================

local function log(...)
    if CONFIG.VERBOSE then
        print("[BLACKBOX]", ...)
    end
end

local function warnLog(...)
    warn("[BLACKBOX]", ...)
end

--==================================================
-- CLASSIFICATION
--==================================================

local CATEGORY_WORDS = {
    vehicle = {
        "vehicle",
        "car",
        "garage",
        "spawn",
        "drive",
        "dealership",
        "dealer",
    },

    trade = {
        "trade",
        "exchange",
        "offer",
        "accept",
        "decline",
    },

    inventory = {
        "inventory",
        "item",
        "owned",
        "storage",
        "collection",
    },

    purchase = {
        "buy",
        "purchase",
        "checkout",
        "shop",
        "price",
    },

    reward = {
        "reward",
        "claim",
        "gift",
        "daily",
        "bonus",
        "crate",
    },

    currency = {
        "cash",
        "money",
        "coin",
        "currency",
        "token",
        "diamond",
    },

    player = {
        "player",
        "character",
        "profile",
        "data",
        "save",
        "load",
    },
}

local function classify(name, path)

    local text =
        (name .. " " .. path):lower()

    for category, words in pairs(CATEGORY_WORDS) do

        for _, word in ipairs(words) do

            if text:find(word, 1, true) then
                return category
            end

        end

    end

    return "unknown"
end

--==================================================
-- REMOTE DESCRIPTION
--==================================================

local function describe(instance)

    local className = instance.ClassName
    local path = instance:GetFullName()

    return {
        name = instance.Name,
        class = className,
        path = path,

        category =
            classify(
                instance.Name,
                path
            ),

        parent =
            instance.Parent
                and instance.Parent:GetFullName()
                or "nil",
    }
end

--==================================================
-- SNAPSHOT
--==================================================

local function makeSnapshot()

    local snapshot = {}

    local descendants =
        ReplicatedStorage:GetDescendants()

    local count = 0

    for _, object in ipairs(descendants) do

        if object:IsA("RemoteEvent")
            or object:IsA("RemoteFunction")
        then

            if count >= CONFIG.MAX_RESULTS then
                break
            end

            local info =
                describe(object)

            snapshot[info.path] = info

            count += 1
        end

    end

    return snapshot
end

--==================================================
-- CHANGE DETECTION
--==================================================

local function compareSnapshots(old, new)

    if not old then
        return
    end

    for path, info in pairs(new) do

        if not old[path] then

            table.insert(
                State.changes,
                {
                    type = "ADDED",
                    time = os.clock(),
                    remote = info,
                }
            )

            log(
                "NEW REMOTE:",
                info.class,
                info.path
            )

        end

    end

    for path, info in pairs(old) do

        if not new[path] then

            table.insert(
                State.changes,
                {
                    type = "REMOVED",
                    time = os.clock(),
                    remote = info,
                }
            )

            log(
                "REMOVED REMOTE:",
                info.class,
                info.path
            )

        end

    end
end

--==================================================
-- REBUILD CATEGORIES
--==================================================

local function rebuildCategories()

    for category in pairs(State.categories) do
        table.clear(
            State.categories[category]
        )
    end

    for _, remote in pairs(State.remotes) do

        local category =
            remote.category

        if not State.categories[category] then
            category = "unknown"
        end

        table.insert(
            State.categories[category],
            remote
        )

    end
end

--==================================================
-- SCAN
--==================================================

local function scan()

    State.scanCount += 1

    local snapshot =
        makeSnapshot()

    compareSnapshots(
        State.previous,
        snapshot
    )

    State.remotes =
        snapshot

    State.previous =
        snapshot

    rebuildCategories()

    log(
        string.format(
            "Scan #%d | %d remotes",
            State.scanCount,
            #(
                (function()
                    local n = 0
                    for _ in pairs(snapshot) do
                        n += 1
                    end
                    return {n}
                end)()
            )
        )
    )
end

--==================================================
-- REPORT
--==================================================

local function printCategory(category)

    local list =
        State.categories[category]

    if not list or #list == 0 then
        return
    end

    print("")
    print(
        "------ "
        .. category:upper()
        .. " ------"
    )

    for i, remote in ipairs(list) do

        print(
            string.format(
                "[%d] %s | %s",
                i,
                remote.class,
                remote.path
            )
        )

    end
end

local function report()

    local counts = {}

    for category, list in pairs(
        State.categories
    ) do

        counts[category] =
            #list

    end

    print("")
    print("==========================================")
    print("       BLACK-BOX SECURITY REPORT")
    print("==========================================")

    print(
        "Player:",
        LocalPlayer
            and LocalPlayer.Name
            or "unknown"
    )

    print(
        "Scans:",
        State.scanCount
    )

    print("")
    print("CATEGORY COUNTS")

    for category, count in pairs(counts) do

        print(
            string.format(
                "  %-12s %d",
                category,
                count
            )
        )

    end

    if CONFIG.SHOW_ALL then

        printCategory("vehicle")
        printCategory("trade")
        printCategory("inventory")
        printCategory("purchase")
        printCategory("reward")
        printCategory("currency")
        printCategory("player")
        printCategory("unknown")

    end

    print("")
    print(
        "Detected tree changes:",
        #State.changes
    )

    print("==========================================")
end

--==================================================
-- PUBLIC API
--==================================================

_G.__BlackBoxRecon = {

    Scan = function()
        scan()
    end,

    Report = function()
        report()
    end,

    GetRemotes = function()
        return State.remotes
    end,

    GetCategory = function(category)
        return State.categories[category]
    end,

    GetChanges = function()
        return State.changes
    end,

    Find = function(term)

        term =
            tostring(term):lower()

        local results = {}

        for _, remote in pairs(
            State.remotes
        ) do

            if remote.name:lower():find(
                term,
                1,
                true
            )
            or remote.path:lower():find(
                term,
                1,
                true
            )
            then

                table.insert(
                    results,
                    remote
                )

            end

        end

        return results
    end,
}

--==================================================
-- START
--==================================================

log("Starting black-box reconnaissance...")

scan()

report()

task.spawn(function()

    while true do

        task.wait(
            CONFIG.SCAN_INTERVAL
        )

        scan()

    end

end)

log("Recon active.")
