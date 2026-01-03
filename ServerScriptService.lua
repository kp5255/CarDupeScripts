-- 🏢 Advanced Car Duplication System - Makes EXACT Duplicates
print("🏢 Advanced Car Duplication System - Server Loaded")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Create events
local CarDupeEvent = Instance.new("RemoteEvent")
CarDupeEvent.Name = "CarDupeEvent"
CarDupeEvent.Parent = ReplicatedStorage

local CarDupeResponse = Instance.new("RemoteEvent")
CarDupeResponse.Name = "CarDupeResponse"
CarDupeResponse.Parent = ReplicatedStorage

-- Configuration
local CONFIG = {
    MaxDuplicatesPerDay = 10,
    DuplicateCooldown = 30,
    AllowTrading = true,
    AllowSelling = true,
    MaxInventorySize = 50,
    EnableVehicleCloning = true, -- Actually clones the 3D model
    SaveToPlayerData = true
}

-- Data structures
local playerCooldowns = {}
local playerDailyCount = {}
local vehicleCache = {} -- Cache vehicle data for performance

-- Function to get EXACT vehicle data from model
local function extractExactVehicleData(vehicleModel)
    local data = {
        Name = vehicleModel.Name,
        DisplayName = vehicleModel.Name,
        ModelId = tostring(vehicleModel:GetAttribute("AssetId") or 0),
        Class = vehicleModel:GetAttribute("Class") or 1,
        Price = vehicleModel:GetAttribute("Price") or 50000,
        Speed = vehicleModel:GetAttribute("Speed") or 100,
        Acceleration = vehicleModel:GetAttribute("Acceleration") or 7,
        Handling = vehicleModel:GetAttribute("Handling") or 6,
        Braking = vehicleModel:GetAttribute("Braking") or 6,
        Customizable = true,
        Tradable = CONFIG.AllowTrading,
        Sellable = CONFIG.AllowSelling,
        Created = os.time(),
        IsOriginal = false,
        DuplicateOf = vehicleModel.Name
    }
    
    -- Extract all attributes
    for _, attrName in ipairs(vehicleModel:GetAttributes()) do
        data[attrName] = vehicleModel:GetAttribute(attrName)
    end
    
    -- Try to find vehicle in game database
    local gameVehicles = ReplicatedStorage:FindFirstChild("Vehicles") or ServerStorage:FindFirstChild("Vehicles")
    if gameVehicles then
        local originalVehicle = gameVehicles:FindFirstChild(vehicleModel.Name)
        if originalVehicle then
            -- Copy configuration from original
            local config = originalVehicle:FindFirstChild("Configuration")
            if config then
                for _, child in ipairs(config:GetChildren()) do
                    if child:IsA("StringValue") then
                        data[child.Name] = child.Value
                    elseif child:IsA("NumberValue") then
                        data[child.Name] = child.Value
                    elseif child:IsA("BoolValue") then
                        data[child.Name] = child.Value
                    end
                end
            end
        end
    end
    
    return data
end

-- Function to CLONE the actual vehicle model (optional)
local function cloneVehicleModel(originalModel, player)
    if not CONFIG.EnableVehicleCloning then return nil end
    
    local clone = originalModel:Clone()
    clone.Name = originalModel.Name .. "_DUP_" .. HttpService:GenerateGUID(false):sub(1, 8)
    
    -- Add duplication marker (hidden)
    local marker = Instance.new("StringValue")
    marker.Name = "DuplicationData"
    marker.Value = HttpService:JSONEncode({
        OriginalVehicle = originalModel.Name,
        DuplicatedBy = player.Name,
        DuplicatedDate = os.date("%Y-%m-%d %H:%M:%S"),
        DuplicateId = HttpService:GenerateGUID(false)
    })
    marker.Parent = clone
    
    -- Store in ServerStorage for later spawning
    local playerFolder = ServerStorage:FindFirstChild("DuplicatedVehicles") or Instance.new("Folder", ServerStorage)
    playerFolder.Name = "DuplicatedVehicles"
    
    local playerVehicles = playerFolder:FindFirstChild(player.UserId) or Instance.new("Folder", playerFolder)
    playerVehicles.Name = player.UserId
    
    clone.Parent = playerVehicles
    
    return clone
end

-- Function to save duplicate to player's permanent inventory
local function saveToPlayerInventory(player, vehicleData, clonedModel)
    local playerId = player.UserId
    local playerName = player.Name
    
    -- Get DataStore
    local inventoryStore = DataStoreService:GetDataStore("PlayerInventory_" .. playerId)
    local garageStore = DataStoreService:GetDataStore("PlayerGarage_" .. playerId)
    
    -- Generate unique ID for this vehicle
    local vehicleId = HttpService:GenerateGUID(false)
    vehicleData.ID = vehicleId
    vehicleData.OwnerId = playerId
    vehicleData.OwnerName = playerName
    vehicleData.AcquiredDate = os.time()
    vehicleData.IsDuplicated = true
    vehicleData.CloneId = clonedModel and clonedModel.Name or nil
    vehicleData.CanRace = true
    vehicleData.CanCustomize = true
    vehicleData.CanUpgrade = true
    
    -- Save to inventory DataStore
    local success, inventory = pcall(function()
        return inventoryStore:GetAsync("vehicles") or {}
    end)
    
    if success then
        -- Check inventory limit
        if #inventory >= CONFIG.MaxInventorySize then
            return false, "Inventory full! Max " .. CONFIG.MaxInventorySize .. " vehicles"
        end
        
        -- Add to inventory
        table.insert(inventory, vehicleData)
        
        -- Save
        local saveSuccess = pcall(function()
            inventoryStore:SetAsync("vehicles", inventory)
        end)
        
        if not saveSuccess then
            return false, "Failed to save to inventory"
        end
    else
        return false, "Inventory DataStore error"
    end
    
    -- Also save to garage (for spawning)
    if CONFIG.SaveToPlayerData then
        local garageSuccess, garage = pcall(function()
            return garageStore:GetAsync("owned_vehicles") or {}
        end)
        
        if garageSuccess then
            local garageVehicle = {
                Name = vehicleData.Name,
                DisplayName = vehicleData.DisplayName,
                ID = vehicleId,
                Class = vehicleData.Class,
                Spawnable = true,
                Data = vehicleData
            }
            
            table.insert(garage, garageVehicle)
            
            pcall(function()
                garageStore:SetAsync("owned_vehicles", garage)
            end)
        end
    end
    
    -- Fire garage update event
    task.spawn(function()
        wait(0.5)
        local updateEvent = ReplicatedStorage:FindFirstChild("UpdateGarage") or Instance.new("RemoteEvent", ReplicatedStorage)
        updateEvent.Name = "UpdateGarage"
        updateEvent:FireClient(player, "vehicle_added", vehicleData)
    end)
    
    -- Log
    print(string.format("💾 Saved to %s's inventory: %s (ID: %s)", 
        playerName, vehicleData.Name, vehicleId:sub(1, 8)))
    
    return true, "Vehicle added to your permanent inventory!", vehicleData
end

-- Function to check if vehicle can be duplicated
local function canDuplicateVehicle(player, vehicleModel)
    local playerId = player.UserId
    
    -- Cooldown check
    if playerCooldowns[playerId] then
        local timeSince = os.time() - playerCooldowns[playerId]
        if timeSince < CONFIG.DuplicateCooldown then
            return false, string.format("Please wait %d seconds", CONFIG.DuplicateCooldown - timeSince)
        end
    end
    
    -- Daily limit check
    local today = os.date("%Y-%m-%d")
    if not playerDailyCount[playerId] then
        playerDailyCount[playerId] = {date = today, count = 0}
    end
    
    if playerDailyCount[playerId].date ~= today then
        playerDailyCount[playerId] = {date = today, count = 0}
    end
    
    if playerDailyCount[playerId].count >= CONFIG.MaxDuplicatesPerDay then
        return false, string.format("Daily limit reached (%d/%d)", 
            playerDailyCount[playerId].count, CONFIG.MaxDuplicatesPerDay)
    end
    
    -- Check if vehicle is valid
    if not vehicleModel or not vehicleModel:IsA("Model") then
        return false, "Invalid vehicle"
    end
    
    -- Check if vehicle has required parts
    local hasSeat = vehicleModel:FindFirstChild("DriveSeat") or 
                   vehicleModel:FindFirstChildOfClass("VehicleSeat")
    
    if not hasSeat then
        return false, "Not a valid drivable vehicle"
    end
    
    return true, "Can duplicate"
end

-- Function to check if player already owns this vehicle
local function playerOwnsVehicle(player, vehicleName)
    local inventoryStore = DataStoreService:GetDataStore("PlayerInventory_" .. player.UserId)
    
    local success, inventory = pcall(function()
        return inventoryStore:GetAsync("vehicles") or {}
    end)
    
    if success then
        for _, vehicle in ipairs(inventory) do
            if vehicle.Name == vehicleName and vehicle.OwnerId == player.UserId then
                return true, vehicle
            end
        end
    end
    
    return false, nil
end

-- Main duplication handler
CarDupeEvent.OnServerEvent:Connect(function(player, action, data)
    if action == "DuplicateVehicle" then
        print("\n" .. string.rep("=", 60))
        print("🚗 EXACT CAR DUPLICATION PROCESS")
        print("Player: " .. player.Name)
        print("Request Time: " .. os.date("%H:%M:%S"))
        
        -- Security check
        if not player or not player:IsDescendantOf(Players) then
            CarDupeResponse:FireClient(player, false, "Invalid player")
            return
        end
        
        local vehicleModel = data.VehicleModel
        local vehicleData = data.VehicleData
        
        -- Validation
        local canDup, reason = canDuplicateVehicle(player, vehicleModel)
        if not canDup then
            CarDupeResponse:FireClient(player, false, reason)
            print("❌ Denied: " .. reason)
            print(string.rep("=", 60))
            return
        end
        
        -- Check if already owns
        local owns, existingVehicle = playerOwnsVehicle(player, vehicleModel.Name)
        if owns then
            CarDupeResponse:FireClient(player, false, 
                "You already own this vehicle!\nCheck your garage.")
            print("ℹ️ Already owns: " .. vehicleModel.Name)
            print(string.rep("=", 60))
            return
        end
        
        print("✅ Vehicle: " .. vehicleModel.Name)
        print("✅ Model Path: " .. vehicleModel:GetFullName())
        
        -- Extract exact vehicle data
        local exactData = extractExactVehicleData(vehicleModel)
        
        -- Clone the 3D model if enabled
        local clonedModel = nil
        if CONFIG.EnableVehicleCloning then
            print("🔄 Cloning 3D model...")
            clonedModel = cloneVehicleModel(vehicleModel, player)
            if clonedModel then
                print("✅ Model cloned: " .. clonedModel.Name)
                exactData.CloneReference = clonedModel:GetFullName()
            end
        end
        
        -- Save to player's permanent inventory
        local success, message, savedData = saveToPlayerInventory(player, exactData, clonedModel)
        
        if success then
            -- Update player stats
            playerCooldowns[player.UserId] = os.time()
            playerDailyCount[player.UserId].count = (playerDailyCount[player.UserId].count or 0) + 1
            
            -- Send success response
            CarDupeResponse:FireClient(player, true, message, savedData)
            
            -- Log success
            print("🎉 DUPLICATION SUCCESSFUL!")
            print("   Vehicle: " .. savedData.Name)
            print("   Value: $" .. savedData.Price)
            print("   Class: " .. savedData.Class)
            print("   ID: " .. savedData.ID:sub(1, 8))
            print("   Daily Count: " .. playerDailyCount[player.UserId].count .. "/" .. CONFIG.MaxDuplicatesPerDay)
            print("   Permanent: YES")
            print("   Full Functionality: YES")
        else
            CarDupeResponse:FireClient(player, false, message)
            print("❌ Failed: " .. message)
        end
        
        print(string.rep("=", 60))
    end
end)

-- Player join - setup inventory
Players.PlayerAdded:Connect(function(player)
    print("👤 Player joined: " .. player.Name)
    
    -- Initialize inventory
    task.spawn(function()
        local inventoryStore = DataStoreService:GetDataStore("PlayerInventory_" .. player.UserId)
        local garageStore = DataStoreService:GetDataStore("PlayerGarage_" .. player.UserId)
        
        pcall(function()
            local inventory = inventoryStore:GetAsync("vehicles")
            if not inventory then
                inventoryStore:SetAsync("vehicles", {})
                print("   Inventory initialized")
            else
                print("   Inventory: " .. #inventory .. " vehicles")
            end
            
            local garage = garageStore:GetAsync("owned_vehicles")
            if not garage then
                garageStore:SetAsync("owned_vehicles", {})
            end
        end)
    end)
    
    -- Send welcome message
    task.delay(3, function()
        if player and player:IsDescendantOf(Players) then
            CarDupeResponse:FireClient(player, true, 
                "Welcome to Car Duplication!\n\n" ..
                "Press G to open the duplicator.\n" ..
                "Sit in ANY car and click DUPLICATE.\n" ..
                "The car will be added to your PERMANENT inventory.")
        end
    end)
end)

-- Player leave cleanup
Players.PlayerRemoving:Connect(function(player)
    playerCooldowns[player.UserId] = nil
    playerDailyCount[player.UserId] = nil
end)

-- Function to spawn duplicated vehicle for player
local function spawnDuplicatedVehicle(player, vehicleId)
    -- Find vehicle in inventory
    local inventoryStore = DataStoreService:GetDataStore("PlayerInventory_" .. player.UserId)
    
    local success, inventory = pcall(function()
        return inventoryStore:GetAsync("vehicles") or {}
    end)
    
    if success then
        for _, vehicle in ipairs(inventory) do
            if vehicle.ID == vehicleId then
                -- Find cloned model
                local dupeFolder = ServerStorage:FindFirstChild("DuplicatedVehicles")
                if dupeFolder then
                    local playerFolder = dupeFolder:FindFirstChild(tostring(player.UserId))
                    if playerFolder then
                        for _, model in ipairs(playerFolder:GetChildren()) do
                            if model.Name:find(vehicle.Name) then
                                -- Clone and spawn
                                local spawn = model:Clone()
                                spawn.Name = vehicle.Name
                                spawn.Parent = workspace
                                
                                -- Position near player
                                local char = player.Character
                                if char and char:FindFirstChild("HumanoidRootPart") then
                                    spawn:SetPrimaryPartCFrame(
                                        char.HumanoidRootPart.CFrame * CFrame.new(0, 0, 10)
                                    )
                                end
                                
                                print("🚗 Spawned duplicated vehicle: " .. vehicle.Name)
                                return spawn
                            end
                        end
                    end
                end
                
                -- If no clone, spawn original from game vehicles
                local gameVehicles = ReplicatedStorage:FindFirstChild("Vehicles")
                if gameVehicles then
                    local original = gameVehicles:FindFirstChild(vehicle.Name)
                    if original then
                        local spawn = original:Clone()
                        spawn.Parent = workspace
                        
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            spawn:SetPrimaryPartCFrame(
                                char.HumanoidRootPart.CFrame * CFrame.new(0, 0, 10)
                            )
                        end
                        
                        return spawn
                    end
                end
            end
        end
    end
    
    return nil
end

-- Expose spawn function to other scripts
ReplicatedStorage:WaitForChild("CarDupeEvent").OnServerEvent:Connect(function(player, action, data)
    if action == "SpawnVehicle" then
        local vehicle = spawnDuplicatedVehicle(player, data.VehicleId)
        if vehicle then
            CarDupeResponse:FireClient(player, true, "Vehicle spawned!")
        else
            CarDupeResponse:FireClient(player, false, "Failed to spawn vehicle")
        end
    end
end)

-- Daily reset
task.spawn(function()
    while true do
        local now = os.time()
        local nextMidnight = os.time({
            year = os.date("%Y"),
            month = os.date("%m"),
            day = os.date("%d") + 1,
            hour = 0,
            min = 0,
            sec = 0
        })
        
        local waitTime = nextMidnight - now
        if waitTime > 0 then
            wait(waitTime)
        end
        
        -- Reset daily counts
        playerDailyCount = {}
        print("🔄 Daily duplication limits reset at midnight")
    end
end)

print("\n" .. string.rep("=", 70))
print("🏢 ADVANCED CAR DUPLICATION SYSTEM READY")
print("=":rep(70))
print("FEATURES:")
print("• Auto-detects ANY vehicle you sit in")
print("• Creates EXACT duplicates with all original attributes")
print("• Saves to PERMANENT inventory (DataStore)")
print("• Full functionality: Race, Customize, Upgrade, Trade, Sell")
print("• Optional 3D model cloning for exact replicas")
print("• Anti-abuse: Cooldowns & daily limits")
print("• Integration with existing garage systems")
print("=":rep(70))
print("CONFIGURATION:")
print("• Max per day: " .. CONFIG.MaxDuplicatesPerDay)
print("• Cooldown: " .. CONFIG.DuplicateCooldown .. "s")
print("• Trading: " .. (CONFIG.AllowTrading and "ENABLED" : "DISABLED"))
print("• Selling: " .. (CONFIG.AllowSelling and "ENABLED" : "DISABLED"))
print("• Model Cloning: " ..
