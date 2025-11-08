-- ServerCarDupe.lua
-- Put this in ServerScriptService

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Create RemoteEvents folder automatically
local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteFolder then
    remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "RemoteEvents"
    remoteFolder.Parent = ReplicatedStorage
end

-- Create duplication RemoteEvent automatically
local dupeEvent = remoteFolder:FindFirstChild("RequestDupeCar")
if not dupeEvent then
    dupeEvent = Instance.new("RemoteEvent")
    dupeEvent.Name = "RequestDupeCar"
    dupeEvent.Parent = remoteFolder
end

-- Create inventory folder automatically
local inventoryFolder = ServerStorage:FindFirstChild("PlayerInventory")
if not inventoryFolder then
    inventoryFolder = Instance.new("Folder")
    inventoryFolder.Name = "PlayerInventory"
    inventoryFolder.Parent = ServerStorage
end

-- Handle duplication requests
dupeEvent.OnServerEvent:Connect(function(player, carName)
    if type(carName) ~= "string" then
        warn("[Server] Invalid car name from", player.Name)
        return
    end

    -- Find car model in workspace
    local carModel = workspace:FindFirstChild(carName)
    if not carModel then
        warn("[Server] Could not find car model:", carName)
        return
    end

    -- Ensure player inventory folder exists
    local playerFolder = inventoryFolder:FindFirstChild(player.Name)
    if not playerFolder then
        playerFolder = Instance.new("Folder")
        playerFolder.Name = player.Name
        playerFolder.Parent = inventoryFolder
    end

    -- Clone car into inventory
    local carClone = carModel:Clone()
    carClone.Name = carModel.Name .. "_Inventory"
    carClone.Parent = playerFolder

    print("[Server] Car duplicated for", player.Name, "in inventory")
end)
