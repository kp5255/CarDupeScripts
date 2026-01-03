-- 🏢 Car Duplication Server - SIMPLE WORKING VERSION
-- Place in ServerScriptService

-- Wait for game to load
wait(1)
print("🏢 Loading Car Duplication Server...")

-- Get services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

-- Create events
local CarDupeEvent = Instance.new("RemoteEvent")
CarDupeEvent.Name = "CarDupeEvent"
CarDupeEvent.Parent = ReplicatedStorage

local CarDupeResponse = Instance.new("RemoteEvent")
CarDupeResponse.Name = "CarDupeResponse"
CarDupeResponse.Parent = ReplicatedStorage

print("✅ Events created")

-- Configuration
local CONFIG = {
    MaxPerDay = 10,
    Cooldown = 30
}

local playerCooldowns = {}
local playerDailyCount = {}

-- Main handler
CarDupeEvent.OnServerEvent:Connect(function(player, action, data)
    if action == "DuplicateVehicle" then
        print("🚗 Duplication request from: " .. player.Name)
        
        -- Check cooldown
        local playerId = player.UserId
        local now = os.time()
        
        if playerCooldowns[playerId] then
            local timeSince = now - playerCooldowns[playerId]
            if timeSince < CONFIG.Cooldown then
                CarDupeResponse:FireClient(player, false, 
                    "Wait " .. (CONFIG.Cooldown - timeSince) .. " seconds")
                return
            end
        end
        
        -- Check daily limit
        local today = os.date("%Y-%m-%d")
        if not playerDailyCount[playerId] then
            playerDailyCount[playerId] = {date = today, count = 0}
        end
        
        if playerDailyCount[playerId].date ~= today then
            playerDailyCount[playerId] = {date = today, count = 0}
        end
        
        if playerDailyCount[playerId].count >= CONFIG.MaxPerDay then
            CarDupeResponse:FireClient(player, false, 
                "Daily limit reached (" .. CONFIG.MaxPerDay .. "/day)")
            return
        end
        
        -- Validate vehicle
        local vehicle = data.Vehicle
        if not vehicle or not vehicle:IsA("Model") then
            CarDupeResponse:FireClient(player, false, "Invalid vehicle")
            return
        end
        
        -- Create vehicle data
        local vehicleData = {
            Name = vehicle.Name,
            DisplayName = vehicle.Name,
            Price = 50000,
            Class = 1,
            ID = HttpService:GenerateGUID(false),
            OwnerId = player.UserId,
            AcquiredDate = os.time(),
            IsDuplicated = true
        }
        
        -- Save to player's garage
        local success, message = saveToPlayerGarage(player, vehicleData)
        
        if success then
            -- Update counters
            playerCooldowns[playerId] = now
            playerDailyCount[playerId].count = playerDailyCount[playerId].count + 1
            
            CarDupeResponse:FireClient(player, true, 
                vehicleData.Name .. " added to garage! (" .. 
                playerDailyCount[playerId].count .. "/" .. CONFIG.MaxPerDay .. ")")
            
            print("✅ " .. player.Name .. " duplicated: " .. vehicleData.Name)
        else
            CarDupeResponse:FireClient(player, false, message)
        end
    end
end)

-- Save function
local function saveToPlayerGarage(player, vehicleData)
    local success, errorMsg = pcall(function()
        local garageStore = DataStoreService:GetDataStore("PlayerGarage_" .. player.UserId)
        
        -- Get current garage
        local garage = garageStore:GetAsync("vehicles") or {}
        
        -- Check if already has this vehicle
        for _, v in ipairs(garage) do
            if v.Name == vehicleData.Name and v.OwnerId == player.UserId then
                return false, "Already own this vehicle"
            end
        end
        
        -- Add to garage
        table.insert(garage, vehicleData)
        
        -- Save
        garageStore:SetAsync("vehicles", garage)
        
        return true, "Saved"
    end)
    
    if success then
        return true, "Success"
    else
        return false, "Save error: " .. tostring(errorMsg)
    end
end

-- Player join
Players.PlayerAdded:Connect(function(player)
    print("👤 Player joined: " .. player.Name)
    
    -- Initialize garage
    pcall(function()
        local garageStore = DataStoreService:GetDataStore("PlayerGarage_" .. player.UserId)
        local garage = garageStore:GetAsync("vehicles")
        if not garage then
            garageStore:SetAsync("vehicles", {})
            print("   Garage initialized")
        end
    end)
    
    -- Welcome message
    task.wait(3)
    if player and player:IsDescendantOf(Players) then
        CarDupeResponse:FireClient(player, true, 
            "Press G to open Car Duplicator!\nSit in any car and click DUPLICATE")
    end
end)

print("🏢 Car Duplication Server READY")
print("• Max per day: " .. CONFIG.MaxPerDay)
print("• Cooldown: " .. CONFIG.Cooldown .. "s")
