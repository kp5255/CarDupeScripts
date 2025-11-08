-- ServerCarDupe.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- Setup RemoteEvent & folders automatically
local function setup()
    local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not remoteFolder then
        remoteFolder = Instance.new("Folder")
        remoteFolder.Name = "RemoteEvents"
        remoteFolder.Parent = ReplicatedStorage
        print("[Setup] Created RemoteEvents folder")
    end

    local dupeEvent = remoteFolder:FindFirstChild("RequestDupeCar")
    if not dupeEvent then
        dupeEvent = Instance.new("RemoteEvent")
        dupeEvent.Name = "RequestDupeCar"
        dupeEvent.Parent = remoteFolder
        print("[Setup] Created RequestDupeCar RemoteEvent")
    end

    local invFolder = ServerStorage:FindFirstChild("PlayerInventory")
    if not invFolder then
        invFolder = Instance.new("Folder")
        invFolder.Name = "PlayerInventory"
        invFolder.Parent = ServerStorage
        print("[Setup] Created PlayerInventory folder in ServerStorage")
    end

    local publicCarsFolder = Workspace:FindFirstChild("PublicCars")
    if not publicCarsFolder then
        publicCarsFolder = Instance.new("Folder")
        publicCarsFolder.Name = "PublicCars"
        publicCarsFolder.Parent = Workspace
        print("[Setup] Created PublicCars folder in Workspace")
    end

    return dupeEvent, invFolder, publicCarsFolder
end

local dupeEvent, playerInventoryFolder, publicCarsFolder = setup()

-- Scan for car templates
local function scanForCars()
    local cars = {}
    local function scan(folder)
        for _, obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("Model") then
                local lname = obj.Name:lower()
                if lname:find("car") or lname:find("vehicle") then
                    cars[obj.Name] = obj
                end
            end
        end
    end
    scan(ReplicatedStorage)
    scan(ServerStorage)
    return cars
end

-- Get or create player's inventory folder
local function getPlayerInventory(player)
    local folder = playerInventoryFolder:FindFirstChild(player.Name)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = player.Name
        folder.Parent = playerInventoryFolder
    end
    return folder
end

-- When a player requests duplication
dupeEvent.OnServerEvent:Connect(function(player, carName)
    local carTemplates = scanForCars()
    local template = carTemplates[carName]

    if not template then
        warn("[Dupe] Car template not found:", carName)
        return
    end

    local playerInv = getPlayerInventory(player)

    -- Clone car to inventory
    local carClone = template:Clone()
    carClone.Name = template.Name .. "_Dupe_" .. player.Name
    carClone.Parent = playerInv

    -- Also clone another copy into the public world folder
    local publicClone = template:Clone()
    publicClone.Name = template.Name .. "_PublicDupe_" .. player.Name
    publicClone.Parent = publicCarsFolder

    -- Position the public clone
    local basePosition = Vector3.new(0, 5, 0)
    local offset = Vector3.new((player.UserId % 10) * 30, 0, math.floor(player.UserId / 10) * 30)
    if publicClone.PrimaryPart then
        publicClone:SetPrimaryPartCFrame(CFrame.new(basePosition + offset))
    else
        publicClone.PrimaryPart = publicClone:FindFirstChildWhichIsA("BasePart")
        if publicClone.PrimaryPart then
            publicClone:SetPrimaryPartCFrame(CFrame.new(basePosition + offset))
        end
    end

    print("[Dupe] Player", player.Name, "duplicated", carClone.Name, "and spawned public car", publicClone.Name)
end)
