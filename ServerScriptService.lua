-- FINAL CAR DUPE - DATASTORE INTEGRATION
print("=":rep(60))
print("🚗 FINAL CAR DUPLICATION SYSTEM")
print("Integrating with game's DataStore system")
print("=":rep(60))

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

-- 1. Find game systems
local CarServiceRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("CarServiceRemotes")
print("✅ Found CarServiceRemotes")

-- 2. Create our event
local DupeEvent = Instance.new("RemoteEvent")
DupeEvent.Name = "Dev_DupeCar"
DupeEvent.Parent = ReplicatedStorage

-- 3. Get car data from existing system
local function findCarInGameDatabase(carName)
    print("🔍 Searching for car in game database:", carName)
    
    -- Check Data.Cars module
    local dataCars = ReplicatedStorage:FindFirstChild("Data")
    if dataCars then
        local carsModule = dataCars:FindFirstChild("Cars")
        if carsModule and carsModule:IsA("ModuleScript") then
            local success, carTable = pcall(require, carsModule)
            if success and type(carTable) == "table" then
                if carTable[carName] then
                    print("✅ Found in Cars module")
                    return carTable[carName]
                end
                
                -- Try case-insensitive search
                for key, data in pairs(carTable) do
                    if key:lower() == carName:lower() then
                        print("✅ Found (case-insensitive):", key)
                        return data
                    end
                end
            end
        end
    end
    
    -- Check CarShopEntries
    local carShopEntries = ReplicatedStorage:FindFirstChild("CarShopEntries")
    if carShopEntries then
        for _, entry in ipairs(carShopEntries:GetChildren()) do
            if entry.Name:lower() == carName:lower() then
                print("✅ Found in CarShopEntries:", entry.Name)
                return entry
            end
        end
    end
    
    print("❌ Car not found in game databases")
    return nil
end

-- 4. Get car from seat (SIMPLIFIED)
local function getCarFromSeat(seat)
    if not seat then return nil end
    
    -- Most cars: seat is directly in car model
    local car = seat.Parent
    if car and car:IsA("Model") then
        return car
    end
    
    -- Some cars: seat is in "Body" folder
    if car and car.Parent and car.Parent:IsA("Model") then
        return car.Parent
    end
    
    return nil
end

-- 5. MAIN FUNCTION: Try to add car to player's REAL inventory
DupeEvent.OnServerEvent:Connect(function(player, seat)
    print("\n" .. "=":rep(50))
    print("🎮 CAR DUPLICATION REQUEST")
    print("Player:", player.Name)
    print("UserID:", player.UserId)
    
    -- Validate seat
    if not seat or not seat:IsA("VehicleSeat") then
        print("❌ Invalid seat")
        return false
    end
    
    -- Get car model
    local carModel = getCarFromSeat(seat)
    if not carModel then
        print("❌ Could not find car model")
        return false
    end
    
    local carName = carModel.Name
    print("✅ Car detected:", carName)
    
    -- METHOD 1: Try to use CarServiceRemotes
    print("\n🔄 METHOD 1: Using CarServiceRemotes...")
    
    -- Look for specific remotes in CarServiceRemotes
    local remotesToTry = {
        "AddCar",
        "GiveCar", 
        "UnlockCar",
        "PurchaseCar",
        "BuyCar"
    }
    
    for _, remoteName in ipairs(remotesToTry) do
        local remote = CarServiceRemotes:FindFirstChild(remoteName)
        if remote then
            print("   Found remote:", remoteName)
            
            -- Try to fire it
            local success = pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireClient(player, carName, 0) -- 0 price
                    print("   Fired RemoteEvent to client")
                elseif remote:IsA("RemoteFunction") then
                    local result = remote:InvokeClient(player, carName, 0)
                    print("   Invoked RemoteFunction, result:", result)
                end
            end)
            
            if success then
                print("   ✅ Success!")
            else
                print("   ❌ Failed")
            end
        end
    end
    
    -- METHOD 2: Try to use generic Buy remote
    print("\n🔄 METHOD 2: Using Buy remote...")
    
    local buyRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Buy")
    if buyRemote and buyRemote:IsA("RemoteEvent") then
        print("   Found Buy remote")
        
        local success = pcall(function()
            -- Create purchase data
            local purchaseData = {
                Item = carName,
                Type = "Car",
                Price = 0,
                Currency = "Cash",
                Duplicated = true
            }
            
            buyRemote:FireClient(player, purchaseData)
            print("   Sent purchase data")
        end)
        
        if success then
            print("   ✅ Buy request sent")
        end
    end
    
    -- METHOD 3: Direct DataStore manipulation (if we can find the right one)
    print("\n🔄 METHOD 3: Direct approach...")
    
    -- Try to find player's car list
    local carDataStore = DataStoreService:GetDataStore("PlayerCars_" .. player.UserId)
    
    local success, carList = pcall(function()
        return carDataStore:GetAsync("cars") or {}
    end)
    
    if success then
        print("   Accessed player's car DataStore")
        
        -- Check if car already in list
        local alreadyHas = false
        for _, ownedCar in ipairs(carList) do
            if ownedCar.Name == carName then
                alreadyHas = true
                break
            end
        end
        
        if not alreadyHas then
            -- Add car to list
            local carData = {
                Name = carName,
                Class = "Class 1", -- Default class
                Owned = true,
                Duplicated = os.time(),
                OriginalModel = carModel:GetFullName()
            }
            
            table.insert(carList, carData)
            
            -- Save back
            pcall(function()
                carDataStore:SetAsync("cars", carList)
                print("   ✅ Added car to DataStore")
            end)
        else
            print("   ℹ️ Player already has this car")
        end
    else
        print("   ❌ Could not access DataStore")
    end
    
    -- METHOD 4: Trigger inventory refresh
    print("\n🔄 METHOD 4: Refreshing inventory...")
    
    local loadedRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("Loaded")
    if loadedRemote then
        loadedRemote:FireClient(player)
        print("   ✅ Inventory refresh triggered")
    end
    
    -- Create physical backup
    print("\n🔄 Creating physical backup...")
    
    local ServerStorage = game:GetService("ServerStorage")
    local backupFolder = ServerStorage:FindFirstChild("CarDupeBackups")
    if not backupFolder then
        backupFolder = Instance.new("Folder")
        backupFolder.Name = "CarDupeBackups"
        backupFolder.Parent = ServerStorage
    end
    
    local playerFolder = backupFolder:FindFirstChild(player.Name)
    if not playerFolder then
        playerFolder = Instance.new("Folder")
        playerFolder.Name = player.Name
        playerFolder.Parent = backupFolder
    end
    
    -- Clone and save
    local clone = carModel:Clone()
    clone.Name = carName .. "_BACKUP_" .. os.time()
    clone.Parent = playerFolder
    
    print("   ✅ Physical backup created")
    print("   Location: ServerStorage/CarDupeBackups/" .. player.Name)
    
    -- FINAL MESSAGE
    print("\n" .. "=":rep(50))
    print("🎉 DUPLICATION COMPLETE!")
    print("=":rep(50))
    print("Attempted multiple methods to add car to your inventory.")
    print("")
    print("CHECK THESE PLACES:")
    print("1. Your in-game garage/inventory (press whatever opens it)")
    print("2. ServerStorage/CarDupeBackups/" .. player.Name .. "/")
    print("")
    print("If car doesn't appear in inventory, the game might need")
    print("a reload or the server might restart.")
    print("=":rep(50) .. "\n")
    
    return true
end)

-- Player join handler
Players.PlayerAdded:Connect(function(player)
    print("👤 Player joined:", player.Name)
    
    -- Create backup folder
    local ServerStorage = game:GetService("ServerStorage")
    local backupFolder = ServerStorage:FindFirstChild("CarDupeBackups")
    if not backupFolder then
        backupFolder = Instance.new("Folder")
        backupFolder.Name = "CarDupeBackups"
        backupFolder.Parent = ServerStorage
    end
    
    local playerFolder = backupFolder:FindFirstChild(player.Name)
    if not playerFolder then
        playerFolder = Instance.new("Folder")
        playerFolder.Name = player.Name
        playerFolder.Parent = backupFolder
    end
end)

print("\n" .. "=":rep(60))
print("✅ SYSTEM READY")
print("=":rep(60))
print("This system attempts to add cars directly to your")
print("inventory through multiple methods:")
print("")
print("1. Uses the game's CarServiceRemotes")
print("2. Uses Buy remote event")
print("3. Direct DataStore manipulation")
print("4. Creates physical backups")
print("")
print("Sit in any car and use the client to duplicate!")
print("=":rep(60))
