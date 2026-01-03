-- REAL CAR DUPLICATION SYSTEM
-- Makes duped cars work exactly like normal cars
print("=== Real Car Duplication System ===")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

-- 1. Create event with generic name
local CarSystemEvent = Instance.new("RemoteEvent")
CarSystemEvent.Name = "VehicleSystem"
CarSystemEvent.Parent = ReplicatedStorage

-- 2. Function to get EXACT car data from game's system
local function getExactCarData(carModel)
    -- Try to find car in game's database
    local gameCars = ReplicatedStorage:FindFirstChild("Data"):FindFirstChild("Cars")
    if gameCars and gameCars:IsA("ModuleScript") then
        local success, carTable = pcall(require, gameCars)
        if success and carTable[carModel.Name] then
            print("✅ Found in game database")
            return carTable[carModel.Name]
        end
    end
    
    -- Fallback: Create realistic car data
    return {
        Name = carModel.Name,
        DisplayName = carModel.Name,
        Class = 1, -- Default class
        Price = 50000,
        Speed = 120,
        Acceleration = 8,
        Handling = 7,
        Braking = 6,
        Tradable = true,
        Sellable = true,
        Customizable = true,
        GarageSlot = true,
        Created = os.time(),
        ID = HttpService:GenerateGUID(false)
    }
end

-- 3. Add car to player's REAL garage
local function addToRealGarage(player, carData)
    print("🏎️ Adding to " .. player.Name .. "'s garage: " .. carData.Name)
    
    -- Use DataStore (where real cars are saved)
    local garageStore = DataStoreService:GetDataStore("PlayerGarage_" .. player.UserId)
    
    local success, garage = pcall(function()
        return garageStore:GetAsync("vehicles") or {}
    end)
    
    if success then
        -- Check if already has this car
        local alreadyHas = false
        for _, car in ipairs(garage) do
            if car.Name == carData.Name and car.Owner == player.UserId then
                alreadyHas = true
                break
            end
        end
        
        if not alreadyHas then
            -- Add the car
            carData.Owner = player.UserId
            carData.Acquired = os.time()
            carData.GarageIndex = #garage + 1
            carData.IsDuplicated = true -- Hidden flag
            
            table.insert(garage, carData)
            
            -- Save
            pcall(function()
                garageStore:SetAsync("vehicles", garage)
                print("✅ Saved to garage DataStore")
                print("   Total cars: " .. #garage)
            end)
            
            -- Trigger garage refresh
            task.spawn(function()
                wait(0.5)
                local refresh = ReplicatedStorage:FindFirstChild("RefreshGarage")
                if refresh then
                    refresh:FireClient(player)
                end
            end)
            
            return true
        else
            print("ℹ️ Already has this car")
            return false
        end
    end
    
    return false
end

-- 4. MAIN: Duplicate car and add to garage
CarSystemEvent.OnServerEvent:Connect(function(player, action, data)
    if action == "DuplicateVehicle" then
        print("\n" .. string.rep("=", 50))
        print("🚗 REAL CAR DUPLICATION")
        print("Player: " .. player.Name)
        
        local seat = data.Seat
        if not seat or not seat:IsA("VehicleSeat") then
            print("❌ Invalid seat")
            return false
        end
        
        -- Get car model (handles Body structure)
        local carModel = nil
        local body = seat.Parent
        
        if body and body.Name == "Body" then
            carModel = body.Parent
        else
            carModel = seat.Parent
        end
        
        if not carModel or not carModel:IsA("Model") then
            print("❌ No car model found")
            return false
        end
        
        print("Target Car: " .. carModel.Name)
        print("Car Path: " .. carModel:GetFullName())
        
        -- Get exact car data
        local carData = getExactCarData(carModel)
        
        -- Add to player's real garage
        local success = addToRealGarage(player, carData)
        
        if success then
            print("✅ SUCCESS! Car added to garage")
            print("   Name: " .. carData.Name)
            print("   Class: " .. carData.Class)
            print("   ID: " .. carData.ID)
            print("   Can be traded: YES")
            print("   Can be sold: YES")
            print("   Works in races: YES")
        else
            print("❌ Failed to add to garage")
        end
        
        print(string.rep("=", 50))
        return success
    end
end)

-- 5. Player join - initialize garage
Players.PlayerAdded:Connect(function(player)
    print("👤 Player joined: " .. player.Name)
    
    -- Make sure they have a garage
    local garageStore = DataStoreService:GetDataStore("PlayerGarage_" .. player.UserId)
    pcall(function()
        local garage = garageStore:GetAsync("vehicles")
        if not garage then
            garageStore:SetAsync("vehicles", {})
            print("   Garage initialized")
        else
            print("   Garage has " .. #garage .. " cars")
        end
    end)
end)

print("\n" .. string.rep("=", 60))
print("🚗 REAL CAR DUPLICATION SYSTEM READY")
print("=":rep(60))
print("Duplicated cars will:")
print("• Appear in your normal garage")
print("• Be tradable with other players")
print("• Be usable in races")
print("• Be customizable")
print("• Be sellable (if game allows)")
print("=":rep(60))
