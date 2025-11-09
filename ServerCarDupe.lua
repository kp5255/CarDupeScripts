--[[ 
  AutoCarDupeSystem.server.lua
  One-drop, self-configuring car duplication + inventory persistence for CDT-style games.

  ✅ Auto-discovers likely folders (templates, dealerships, player data, inventories)
  ✅ Creates its own safe fallbacks if nothing is found
  ✅ Server-authoritative dupe (press R by default) — protected against client spoofing
  ✅ Adds duped car to actual inventory and saves via DataStore
  ✅ Optional immediate spawn of cloned car near player
  ✅ Verbose DeepScan logs to understand what it latched onto
--]]

--============================= CONFIG =============================--
local CONFIG = {
    INPUT_KEY = Enum.KeyCode.R,       -- client key to request dupe
    COOLDOWN_SEC = 5,                 -- per-player dupe cooldown
    SPAWN_ON_DUPE = true,             -- also spawn the new dupe in Workspace
    MAX_PER_SESSION = 100,            -- safety cap per session
    DATASTORE_NAME = "AutoCDT_Inventory_v1",
    LOG_PREFIX = "[AutoCDT]",
    ENABLE_DEEPSCAN_LOGS = true
}
--=================================================================--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

-- Utilities
local function log(...) print(CONFIG.LOG_PREFIX, ...) end
local function warnlog(...) warn(CONFIG.LOG_PREFIX, ...) end
local function safeWaitFor(obj, name)
    local ok, res = pcall(function() return obj:WaitForChild(name, 10) end)
    return ok and res or nil
end

local function path(instance: Instance)
    if not instance then return "<nil>" end
    local segs = {}
    local cur = instance
    while cur and cur ~= game do
        table.insert(segs, 1, cur.Name)
        cur = cur.Parent
    end
    return table.concat(segs, ".")
end

-- Keyword-based discovery helpers
local function nameHasAny(inst: Instance, words: {string})
    local n = string.lower(inst.Name)
    for _, w in ipairs(words) do
        if string.find(n, string.lower(w), 1, true) then return true end
    end
    return false
end

local function findFoldersRecursively(root: Instance, words: {string}, maxCount: number?)
    local found = {}
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("Folder") or d:IsA("Model") then
            if nameHasAny(d, words) then
                table.insert(found, d)
                if maxCount and #found >= maxCount then
                    break
                end
            end
        end
    end
    return found
end

local function firstExistingFolder(roots: {Instance}, words: {string})
    for _, r in ipairs(roots) do
        for _, d in ipairs(r:GetChildren()) do
            if (d:IsA("Folder") or d:IsA("Model")) and nameHasAny(d, words) then
                return d
            end
        end
    end
    return nil
end

--===================== BOOTSTRAP: REMOTES & CLIENT =====================--
-- RemoteEvents container
local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteFolder then
    remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "RemoteEvents"
    remoteFolder.Parent = ReplicatedStorage
end

local dupeEvent = remoteFolder:FindFirstChild("RequestDupeCar")
if not dupeEvent then
    dupeEvent = Instance.new("RemoteEvent")
    dupeEvent.Name = "RequestDupeCar"
    dupeEvent.Parent = remoteFolder
end

-- Auto-install a LocalScript for input (R key) into StarterPlayerScripts
local playerScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts") or StarterPlayer
local existingClient = playerScripts:FindFirstChild("LocalCarDupe_Auto")
if not existingClient then
    local localScript = Instance.new("LocalScript")
    localScript.Name = "LocalCarDupe_Auto"
    localScript.Source = string.format([[
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local UIS = game:GetService("UserInputService")
        local Players = game:GetService("Players")

        local player = Players.LocalPlayer
        local dupeEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestDupeCar")

        local COOLDOWN = 0.15
        local last = 0

        local function getSeatedCarModel()
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return nil end
            local seat = humanoid.SeatPart
            if not seat then return nil end
            local model = seat:FindFirstAncestorOfClass("Model")
            return model
        end

        UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == %s then
                if (time() - last) < COOLDOWN then return end
                last = time()
                local carModel = getSeatedCarModel()
                if carModel then
                    -- We send both the model name and an optional attribute CarId if present.
                    local carId = carModel:GetAttribute("CarId")
                    dupeEvent:FireServer(carModel.Name, carId)
                else
                    warn("[CLIENT] Not seated in a car.")
                end
            end
        end)
    ]], tostring(CONFIG.INPUT_KEY))
    localScript.Parent = playerScripts
    log("Installed LocalCarDupe_Auto into StarterPlayerScripts.")
end

--===================== DEEPSCAN: DISCOVER STRUCTURE =====================--
local function dprint(...)
    if CONFIG.ENABLE_DEEPSCAN_LOGS then
        print("[DeepScan]", ...)
    end
end

-- Find likely car template containers
local TEMPLATE_KEYWORDS = {"car", "vehicle", "template", "prefab", "garage"}
local CANDIDATE_SERVICES = {ReplicatedStorage, ServerStorage, workspace}

local CarTemplates = firstExistingFolder(CANDIDATE_SERVICES, {"CarTemplates"})
if not CarTemplates then
    -- broader search
    for _, service in ipairs(CANDIDATE_SERVICES) do
        local candidates = findFoldersRecursively(service, TEMPLATE_KEYWORDS, 1)
        if #candidates > 0 then
            CarTemplates = candidates[1]
            dprint("🚗 Found templates-like folder:", path(CarTemplates))
            break
        end
    end
end
if not CarTemplates then
    CarTemplates = Instance.new("Folder")
    CarTemplates.Name = "CarTemplates"
    CarTemplates.Parent = ReplicatedStorage
    dprint("🆕 Created CarTemplates at", path(CarTemplates))
end

-- Find likely player data / inventory root
local INVENTORY_PARENT_KEYWORDS = {"playerdata", "players", "profiles", "data", "datastore", "save"}
local InventoryRoot = firstExistingFolder({ReplicatedStorage, ServerStorage}, INVENTORY_PARENT_KEYWORDS)
if not InventoryRoot then
    local autoRoot = ReplicatedStorage:FindFirstChild("AutoCDT") or Instance.new("Folder")
    autoRoot.Name = "AutoCDT"
    autoRoot.Parent = ReplicatedStorage
    InventoryRoot = autoRoot:FindFirstChild("PlayerInventories")
    if not InventoryRoot then
        InventoryRoot = Instance.new("Folder")
        InventoryRoot.Name = "PlayerInventories"
        InventoryRoot.Parent = autoRoot
    end
    dprint("🆕 Created inventory root at", path(InventoryRoot))
else
    dprint("📦 Using inventory root:", path(InventoryRoot))
end

-- (Optional) dealership-like models — just logged for visibility like your screenshot
for _, service in ipairs({workspace}) do
    local dealerships = findFoldersRecursively(service, {"dealership","shop","garage","custom"}, nil)
    for i, m in ipairs(dealerships) do
        dprint(("🏬 #%d Found dealership-like model: %s"):format(i, path(m)))
    end
end

--===================== PERSISTENCE LAYER =====================--
local store = DataStoreService:GetDataStore(CONFIG.DATASTORE_NAME)
local sessionCount = {}

local function getPlayerInvFolder(player: Player)
    local folder = InventoryRoot:FindFirstChild(tostring(player.UserId))
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = tostring(player.UserId)
        folder.Parent = InventoryRoot
    end
    local carsFolder = folder:FindFirstChild("Cars")
    if not carsFolder then
        carsFolder = Instance.new("Folder")
        carsFolder.Name = "Cars"
        carsFolder.Parent = folder
    end
    return carsFolder
end

local function loadInventory(player: Player)
    local carsFolder = getPlayerInvFolder(player)
    local key = "inv_" .. player.UserId
    local data
    local ok, err = pcall(function()
        data = store:GetAsync(key)
    end)
    if not ok then
        warnlog("DataStore GetAsync failed:", err)
        return
    end
    if type(data) == "table" then
        for carId, count in pairs(data) do
            local item = carsFolder:FindFirstChild(carId) or Instance.new("IntValue")
            item.Name = carId
            item.Value = tonumber(count) or 1
            item.Parent = carsFolder
        end
    end
end

local function saveInventory(player: Player)
    local carsFolder = getPlayerInvFolder(player)
    local key = "inv_" .. player.UserId
    local blob = {}
    for _, v in ipairs(carsFolder:GetChildren()) do
        if v:IsA("IntValue") then
            blob[v.Name] = v.Value
        end
    end
    pcall(function()
        store:SetAsync(key, blob)
    end)
end

Players.PlayerAdded:Connect(function(player)
    sessionCount[player] = 0
    loadInventory(player)
end)

Players.PlayerRemoving:Connect(function(player)
    saveInventory(player)
    sessionCount[player] = nil
end)

game:BindToClose(function()
    if RunService:IsStudio() then return end
    for _, player in ipairs(Players:GetPlayers()) do
        saveInventory(player)
    end
end)

--===================== TEMPLATE RESOLUTION =====================--
local function resolveCarIdAndTemplate(fromModel: Model?)
    -- Strategy:
    -- 1) Prefer Attribute "CarId" on model
    -- 2) Fall back to model.Name as id
    -- 3) Find template by exact name/id under CarTemplates (or nested)
    local carId
    local template

    if fromModel then
        carId = fromModel:GetAttribute("CarId")
        if not carId or carId == "" then
            carId = fromModel.Name
        end
    end

    local function findTemplateById(id: string)
        if not id or id == "" then return nil end
        -- direct child
        local t = CarTemplates:FindFirstChild(id)
        if t then return t end
        -- deep search
        for _, d in ipairs(CarTemplates:GetDescendants()) do
            if d:IsA("Model") or d:IsA("Folder") then
                if d.Name == id then
                    return d
                end
            end
        end
        return nil
    end

    template = findTemplateById(carId or "")
    return carId, template
end

local function snapshotTemplateFromLiveModel(model: Model): Instance
    -- If there is no template, we create one by cloning the seated model.
    -- Light cleanup only; we keep structure intact so it works with your systems.
    local snap = model:Clone()
    -- Prefer an explicit CarId so future lookups are stable
    if not snap:GetAttribute("CarId") then
        snap:SetAttribute("CarId", model:GetAttribute("CarId") or model.Name)
    end
    snap.Parent = CarTemplates
    dprint("🆕 Snapshotted live model as template:", path(snap))
    return snap
end

--===================== SERVER DUPE LOGIC =====================--
local cooldowns: {[Player]: number} = {}

local function isPlayerSeatedInModel(player: Player, modelName: string?): Model?
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local seat = hum.SeatPart
    if not seat then return nil end
    local m = seat:FindFirstAncestorOfClass("Model")
    if not m then return nil end
    if modelName and m.Name ~= modelName then
        -- Name mismatch; still allow if CarId attribute matches
        local id = m:GetAttribute("CarId")
        if not id or id ~= modelName then
            return nil
        end
    end
    return m
end

local function incrementInventory(player: Player, carId: string)
    local carsFolder = getPlayerInvFolder(player)
    local val = carsFolder:FindFirstChild(carId)
    if not val then
        val = Instance.new("IntValue")
        val.Name = carId
        val.Value = 0
        val.Parent = carsFolder
    end
    val.Value += 1
end

local function spawnCloneNearPlayer(player: Player, template: Instance)
    local char = player.Character
    if not char or not char.PrimaryPart then return end

    local clone = template:Clone()
    clone.Name = (template.Name or "Car") .. "_Copy_" .. math.random(1000, 9999)
    clone.Parent = workspace

    -- Try to move model
    local primary = (clone:IsA("Model") and clone.PrimaryPart) or clone:FindFirstChildWhichIsA("BasePart", true)
    local targetPos = char.PrimaryPart.Position + Vector3.new(0, 4, 0)
    if primary then
        if clone:IsA("Model") then
            clone:MoveTo(targetPos)
        else
            primary.CFrame = CFrame.new(targetPos)
        end
    end
    return clone
end

dupeEvent.OnServerEvent:Connect(function(player: Player, clientModelName: string?, clientCarId: string?)
    local now = os.clock()
    if cooldowns[player] and now - cooldowns[player] < CONFIG.COOLDOWN_SEC then
        return
    end
    cooldowns[player] = now

    sessionCount[player] = (sessionCount[player] or 0) + 1
    if sessionCount[player] > CONFIG.MAX_PER_SESSION then
        warnlog(player.Name .. " reached session dupe cap.")
        return
    end

    -- Validate seated state on server
    local seatedModel = isPlayerSeatedInModel(player, clientModelName)
    if not seatedModel then
        warnlog(player.Name, "is not seated in a valid car model. Rejected.")
        return
    end

    -- Resolve ID + template
    local id, template = resolveCarIdAndTemplate(seatedModel)
    if (not id or id == "") and (clientCarId and clientCarId ~= "") then
        id = clientCarId
    end
    if not id or id == "" then
        id = seatedModel.Name
    end

    if not template then
        template = snapshotTemplateFromLiveModel(seatedModel)
    end

    -- Add to inventory and save async-ish
    incrementInventory(player, id)
    task.spawn(function()
        saveInventory(player)
    end)

    -- Optional spawn
    if CONFIG.SPAWN_ON_DUPE then
        spawnCloneNearPlayer(player, template)
    end

    log(("[Dupe] %s duplicated '%s' (template: %s)"):format(
        player.Name,
        tostring(id),
        path(template)
    ))
end)

log("Ready! Press " .. tostring(CONFIG.INPUT_KEY) .. " in-game while seated to duplicate the car and add it to your inventory.")
