-- Dealership Car Duplication System - Server
print("🏢 Dealership Car Duplication System - Server Loaded")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

-- Create remote events
local VehicleDupeEvent = Instance.new("RemoteEvent")
VehicleDupeEvent.Name = "VehicleDupeEvent"
VehicleDupeEvent.Parent = ReplicatedStorage

local VehicleDupeResponse = Instance.new("RemoteEvent")
VehicleDupeResponse.Name = "VehicleDupeResponse"
VehicleDupeResponse.Parent = ReplicatedStorage

-- Configuration
local CONFIG = {
    MaxDuplicatesPerDay = 5,  -- Limit to prevent abuse
    DuplicateCooldown = 60,   -- Seconds between duplicates
    SellPercentage = 0.7,      -- 70% of original price if selling
    AllowTrading = true,       -- Allow duplicated cars to be traded
    AllowSelling = true        -- Allow selling duplicated cars
}

-- Player cooldown tracking
local playerCooldowns = {}
local playerDailyCount = {}

-- Function to validate vehicle
local function isValidVehicle(vehicle)
    if not vehicle or not vehicle:IsA("Model") then
        return false, "Invalid vehicle"
    end
    
    -- Check if it has required components
    local hasSeat = vehicle:FindFirstChild("DriveSeat") or 
                    vehicle:FindFirstChild("Seat") or
                    vehicle:FindFirstChildWhichIsA("VehicleSeat")
    
    if not hasSeat then
        return false, "Not a valid vehicle"
    end
    
    return true, "Valid"
end

-- Function to get vehicle data from your game's system
local function getVehicleData(vehicleName)
    -- Try to find in your game's vehicle database
    local vehicleDatabase = {
        -- Example structure - you'll need to adapt this to your game
        ["SportsCar"] = {
            Name = "SportsCar",
            DisplayName = "Sports Car",
            Class = 2,
            Price = 75000,
            Speed = 140,
            Acceleration = 8.5,
            Handling = 8,
            Customizable = true,
            Tradable = true,
            Sellable = true
        },
        ["Truck"] = {
            Name = "Truck",
            DisplayName = "Pickup Truck",
            Class = 1,
            Price = 45000,
            Speed = 100,
            Acceleration = 6,
            Handling = 6,
            Customizable = true,
            Tradable = true,
            Sellable = true
        }
        -- Add all your game's vehicles here
    }
    
    -- Check if vehicle exists in database
    if vehicleDatabase[vehicleName] then
        return vehicleDatabase[vehicleName]
    end
    
    -- Fallback: Create generic data
    return {
        Name = vehicleName,
        DisplayName = vehicleName,
        Class = 1,
        Price = 50000,
        Speed = 120,
        Acceleration = 7,
        Handling = 6,
        Customizable = true,
        Tradable = CONFIG.AllowTrading,
        Sellable = CONFIG.AllowSelling,
        IsDuplicated = true,
        DuplicatedDate = os.time()
    }
end

-- Function to add vehicle to player's garage
local function addToPlayerGarage(player, vehicleData)
    local playerId = player.UserId
    local playerName = player.Name
    
    -- Get or create DataStore
    local garageStore = DataStoreService:GetDataStore("PlayerGarage_" .. playerId)
    
    local success, garage = pcall(function()
        return garageStore:GetAsync("vehicles") or {}
    end)
    
    if not success then
        return false, "DataStore error"
    end
    
    -- Generate unique ID for the vehicle
    vehicleData.ID = HttpService:GenerateGUID(false)
    vehicleData.OwnerId = playerId
    vehicleData.OwnerName = playerName
    vehicleData.AcquiredDate = os.time()
    vehicleData.IsDuplicated = true
    
    -- Check if player already has this vehicle
    for _, existingVehicle in ipairs(garage) do
        if existingVehicle.Name == vehicleData.Name and existingVehicle.OwnerId == playerId then
            return false, "Already own this vehicle"
        end
    end
    
    -- Add to garage
    table.insert(garage, vehicleData)
    
    -- Save to DataStore
    local saveSuccess, saveError = pcall(function()
        garageStore:SetAsync("vehicles", garage)
    end)
    
    if not saveSuccess then
        warn("⚠️ Failed to save vehicle for " .. playerName .. ": " .. saveError)
        return false, "Save failed"
    end
    
    -- Log the duplication
    print(string.format("✅ %s duplicated: %s (Value: $%d)", 
        playerName, vehicleData.DisplayName, vehicleData.Price))
    
    -- Trigger garage update (if your game has this)
    task.spawn(function()
        wait(1)
        local updateEvent = ReplicatedStorage:FindFirstChild("UpdateGarage")
        if updateEvent then
            updateEvent:FireClient(player)
        end
    end)
    
    return true, "Successfully added to garage!"
end

-- Check cooldown and limits
local function canDuplicate(player)
    local playerId = player.UserId
    local now = os.time()
    
    -- Check cooldown
    if playerCooldowns[playerId] then
        local timeSinceLast = now - playerCooldowns[playerId]
        if timeSinceLast < CONFIG.DuplicateCooldown then
            local remaining = CONFIG.DuplicateCooldown - timeSinceLast
            return false, string.format("Cooldown: %d seconds remaining", remaining)
        end
    end
    
    -- Check daily limit (optional - resets daily)
    local today = os.date("%Y-%m-%d")
    if not playerDailyCount[playerId] then
        playerDailyCount[playerId] = {}
    end
    
    if not playerDailyCount[playerId].date or playerDailyCount[playerId].date ~= today then
        playerDailyCount[playerId] = {date = today, count = 0}
    end
    
    if playerDailyCount[playerId].count >= CONFIG.MaxDuplicatesPerDay then
        return false, "Daily limit reached (" .. CONFIG.MaxDuplicatesPerDay .. "/day)"
    end
    
    return true, "Can duplicate"
end

-- Main event handler
VehicleDupeEvent.OnServerEvent:Connect(function(player, action, data)
    if action == "DuplicateVehicle" then
        print("\n" .. string.rep("=", 50))
        print("🚗 DUPLICATION REQUEST")
        print("Player: " .. player.Name)
        
        -- Check if player can duplicate
        local canDup, reason = canDuplicate(player)
        if not canDup then
            VehicleDupeResponse:FireClient(player, false, reason)
            print("❌ Denied: " .. reason)
            print(string.rep("=", 50))
            return
        end
        
        -- Validate vehicle
        local vehicle = data.Vehicle
        local isValid, validReason = isValidVehicle(vehicle)
        
        if not isValid then
            VehicleDupeResponse:FireClient(player, false, validReason)
            print("❌ Invalid vehicle: " .. validReason)
            print(string.rep("=", 50))
            return
        end
        
        local vehicleName = data.VehicleName or vehicle.Name
        print("Vehicle: " .. vehicleName)
        
        -- Get vehicle data
        local vehicleData = getVehicleData(vehicleName)
        
        -- Add to player's garage
        local success, message = addToPlayerGarage(player, vehicleData)
        
        if success then
            -- Update cooldown and counters
            playerCooldowns[player.UserId] = os.time()
            playerDailyCount[player.UserId].count = (playerDailyCount[player.UserId].count or 0) + 1
            
            -- Send success response
            VehicleDupeResponse:FireClient(player, true, message, vehicleData)
            print("✅ Success: " .. message)
            print("   Class: " .. (vehicleData.Class or "N/A"))
            print("   Value: $" .. (vehicleData.Price or 0))
            print("   Daily count: " .. playerDailyCount[player.UserId].count .. "/" .. CONFIG.MaxDuplicatesPerDay)
        else
            VehicleDupeResponse:FireClient(player, false, message)
            print("❌ Failed: " .. message)
        end
        
        print(string.rep("=", 50))
    end
end)

-- Player join handling
Players.PlayerAdded:Connect(function(player)
    print("👤 Player joined: " .. player.Name)
    
    -- Initialize DataStore if needed
    task.spawn(function()
        local garageStore = DataStoreService:GetDataStore("PlayerGarage_" .. player.UserId)
        pcall(function()
            local garage = garageStore:GetAsync("vehicles")
            if not garage then
                garageStore:SetAsync("vehicles", {})
                print("   Garage initialized for " .. player.Name)
            end
        end)
    end)
    
    -- Welcome message with instructions
    task.delay(5, function()
        if player and player:IsDescendantOf(Players) then
            VehicleDupeResponse:FireClient(player, true, 
                "Welcome! Press G to open\nthe car duplicator UI.\nSit in any car and click\nthe duplicate button!")
        end
    end)
end)

-- Player leave cleanup
Players.PlayerRemoving:Connect(function(player)
    playerCooldowns[player.UserId] = nil
    playerDailyCount[player.UserId] = nil
end)

-- Daily reset function (optional)
local function resetDailyCounts()
    while true do
        local now = os.time()
        local nextReset = os.time({year=os.date("%Y"), month=os.date("%m"), day=os.date("%d")+1, hour=0})
        local waitTime = nextReset - now
        
        if waitTime > 0 then
            wait(waitTime)
        end
        
        -- Reset all daily counts
        playerDailyCount = {}
        print("🔄 Daily duplication counts reset")
    end
end

-- Start daily reset in background
task.spawn(resetDailyCounts)

print("\n" .. string.rep("=", 60))
print("🏢 DEALERSHIP DUPLICATION SYSTEM READY")
print("=":rep(60))
print("Features:")
print("• Limits: " .. CONFIG.MaxDuplicatesPerDay .. "/day per player")
print("• Cooldown: " .. CONFIG.DuplicateCooldown .. " seconds")
print("• Trading: " .. (CONFIG.AllowTrading and "ENABLED" or "DISABLED"))
print("• Selling: " .. (CONFIG.AllowSelling and "ENABLED" or "DISABLED"))
print("• DataStore integration for persistence")
print("• Anti-abuse protection")
print("=":rep(60))
