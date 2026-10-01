-- CDT DUPLICATION OBSERVER
-- Client-side / Delta
-- Observation only: does NOT fire trade remotes

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UID_NAMES = {
    "CarUID",
    "CarUid",
    "VehicleUID",
    "VehicleUid",
    "UniqueID",
    "UniqueId",
    "UID",
    "Uid"
}

local function getUID(obj)
    for _, name in ipairs(UID_NAMES) do
        local ok, value = pcall(function()
            return obj:GetAttribute(name)
        end)

        if ok and value ~= nil then
            return tostring(value), name
        end
    end

    return nil
end

local function scan()
    local cars = {}
    local count = 0

    for _, obj in ipairs(LocalPlayer:GetDescendants()) do
        local uid, attr = getUID(obj)

        if uid then
            count += 1

            cars[uid] = cars[uid] or {}
            table.insert(cars[uid], {
                object = obj:GetFullName(),
                attribute = attr
            })
        end
    end

    print("========== DUPLICATION TEST ==========")
    print("UID-bearing objects:", count)

    local duplicates = 0

    for uid, list in pairs(cars) do
        if #list > 1 then
            duplicates += 1

            warn("!!! POSSIBLE DUPLICATE !!!")
            warn("UID:", uid)

            for i, item in ipairs(list) do
                warn(
                    "[" .. i .. "]",
                    item.object,
                    "| attribute:",
                    item.attribute
                )
            end
        end
    end

    if duplicates > 0 then
        warn(">>> DUPLICATE OBSERVED CLIENT-SIDE:", duplicates)
    else
        print(">>> NO DUPLICATE UID OBSERVED")
    end

    print("======================================")
end

print("[CDT-DUP-TEST] Observer started")

scan()

while task.wait(3) do
    scan()
end
