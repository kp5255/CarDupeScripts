print("🎯 INTELLIGENT CAR DUPLICATION SYSTEM")
print("=" .. string.rep("=", 60))

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local CarDuplicator = {
    CurrentCar = nil,
    CarService = ReplicatedStorage.Remotes.Services.CarServiceRemotes,
    DetectedCalls = {},
    VulnerabilitiesFound = 0
}

-- Step 1: Detect current car
function CarDuplicator:DetectCurrentCar()
    print("🔍 Detecting current car...")
    
    -- Method 1: Check Workspace for player's vehicle
    local character = player.Character or player.CharacterAdded:Wait()
    
    if character then
        -- Check if sitting in vehicle seat
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            local seat = humanoid.SeatPart
            if seat then
                -- Trace up to find car model
                local vehicle = seat.Parent
                while vehicle and not vehicle:FindFirstChild("VehicleSeat") do
                    vehicle = vehicle.Parent
                end
                
                if vehicle then
                    print("✅ Found vehicle: " .. vehicle.Name)
                    self.CurrentCar = vehicle
                    return vehicle
                end
            end
        end
    end
    
    -- Method 2: Check CarReplication in PlayerGui
    local carReplication = player.PlayerGui:FindFirstChild("CarReplication")
    if carReplication then
        print("📊 CarReplication folder found: " .. #carReplication:GetChildren() .. " cars")
        
        -- Get the most recent car (likely current)
        local newestCar = nil
        local newestTime = 0
        
        for _, carFrame in pairs(carReplication:GetChildren()) do
            if carFrame:IsA("Frame") then
                local stats = carFrame:FindFirstChild("Stats")
                if stats then
                    -- Check if this car is active
                    if carFrame.Visible then
                        self.CurrentCar = carFrame
                        print("✅ Active car in CarReplication: " .. carFrame.Name)
                        return carFrame
                    end
                end
            end
        end
    end
    
    print("❌ No car detected")
    return nil
end

-- Step 2: Monitor car data access
function CarDuplicator:MonitorDataAccess()
    print("\n📡 Monitoring car data access...")
    
    -- Hook GetOwnedCars to see when it's called
    local getOwnedCars = self.CarService:FindFirstChild("GetOwnedCars")
    if getOwnedCars then
        local original = getOwnedCars.InvokeServer
        
        getOwnedCars.InvokeServer = function(...)
            local args = {...}
            print("📞 GetOwnedCars called!")
            print("   Args: " .. #args .. " arguments")
            
            -- Record the call
            table.insert(self.DetectedCalls, {
                time = os.time(),
                function = "GetOwnedCars",
                args = args
            })
            
            return original(...)
        end
        print("✅ Hooked GetOwnedCars")
    end
    
    -- Monitor other car-related remotes
    for _, remote in pairs(self.CarService:GetChildren()) do
        if remote:IsA("RemoteFunction") then
            print("📞 Monitoring: " .. remote.Name)
        end
    end
end

-- Step 3: Find vulnerabilities in car access
function CarDuplicator:FindVulnerabilities()
    print("\n🔓 Searching for vulnerabilities...")
    
    -- Check for OnCarsAdded remote (server event)
    local onCarsAdded = self.CarService:FindFirstChild("OnCarsAdded")
    if onCarsAdded then
        print("✅ Found OnCarsAdded RemoteEvent")
        print("   This might accept car data from client")
        self.VulnerabilitiesFound = self.VulnerabilitiesFound + 1
    end
    
    -- Check for UpdateCarPack remote
    local updateCarPack = ReplicatedStorage.Remotes:FindFirstChild("UpdateCarPack")
    if updateCarPack then
        print("✅ Found UpdateCarPack RemoteEvent")
        print("   Might accept car data updates")
        self.VulnerabilitiesFound = self.VulnerabilitiesFound + 1
    end
    
    -- Check for SetCarFavorite
    local setFavorite = ReplicatedStorage.Remotes:FindFirstChild("SetCarFavorite")
    if setFavorite then
        print("✅ Found SetCarFavorite RemoteEvent")
        print("   Might be used to manipulate car ownership")
        self.VulnerabilitiesFound = self.VulnerabilitiesFound + 1
    end
    
    -- Check CarReplication for editable values
    local carReplication = player.PlayerGui:FindFirstChild("CarReplication")
    if carReplication then
        print("✅ Found CarReplication UI")
        print("   Contains: " .. #carReplication:GetChildren() .. " car frames")
        
        -- Check if values can be modified
        for _, carFrame in pairs(carReplication:GetChildren()) do
            local stats = carFrame:FindFirstChild("Stats")
            if stats then
                for _, value in pairs(stats:GetChildren()) do
                    if value:IsA("StringValue") or value:IsA("IntValue") then
                        print("   Car " .. carFrame.Name .. " has value: " .. value.Name)
                    end
                end
            end
        end
    end
    
    print("\n📊 Vulnerabilities found: " .. self.VulnerabilitiesFound)
end

-- Step 4: Extract car data from current car
function CarDuplicator:ExtractCarData()
    if not self.CurrentCar then
        print("❌ No current car to extract data from")
        return nil
    end
    
    print("\n🔍 Extracting data from current car...")
    
    local carData = {
        extractedAt = os.time(),
        source = self.CurrentCar:GetFullName()
    }
    
    -- Extract from Vehicle model (if in Workspace)
    if self.CurrentCar:IsA("Model") then
        carData.type = "Model"
        carData.Name = self.CurrentCar.Name
        
        -- Try to get configuration
        local configuration = self.CurrentCar:FindFirstChild("Configuration")
        if configuration then
            for _, attribute in pairs(configuration:GetAttributes()) do
                carData[attribute] = configuration:GetAttribute(attribute)
            end
        end
        
        -- Check for VehicleSeat properties
        local vehicleSeat = self.CurrentCar:FindFirstChild("VehicleSeat")
        if vehicleSeat then
            carData.SeatType = vehicleSeat.ClassName
        end
        
        print("✅ Extracted from Model: " .. self.CurrentCar.Name)
        
    -- Extract from CarReplication frame
    elseif self.CurrentCar:IsA("Frame") then
        carData.type = "UIFrame"
        carData.Name = self.CurrentCar.Name
        
        -- Extract from Stats folder
        local stats = self.CurrentCar:FindFirstChild("Stats")
        if stats then
            for _, value in pairs(stats:GetChildren()) do
                if value:IsA("StringValue") or value:IsA("IntValue") then
                    carData[value.Name] = value.Value
                end
            end
        end
        
        print("✅ Extracted from UI Frame: " .. self.CurrentCar.Name)
        print("   Stats: " .. tostring(#stats:GetChildren()))
    end
    
    -- Display extracted data
    print("\n📋 EXTRACTED CAR DATA:")
    for key, value in pairs(carData) do
        if type(value) == "string" or type(value) == "number" then
            print("  " .. key .. ": " .. tostring(value))
        end
    end
    
    return carData
end

-- Step 5: Attempt duplication via found vulnerabilities
function CarDuplicator:AttemptDuplication(extractedData)
    print("\n🎯 ATTEMPTING DUPLICATION...")
    
    if not extractedData then
        print("❌ No data to duplicate")
        return false
    end
    
    local successCount = 0
    
    -- Method 1: Try OnCarsAdded
    print("\n🔄 Method 1: OnCarsAdded")
    local onCarsAdded = self.CarService:FindFirstChild("OnCarsAdded")
    if onCarsAdded then
        -- Create duplicate car data
        local duplicateData = {}
        for k, v in pairs(extractedData) do
            duplicateData[k] = v
        end
        
        -- Modify to make unique
        duplicateData.Id = "dup-" .. os.time() .. "-" .. math.random(1000, 9999)
        duplicateData.Name = duplicateData.Name .. " (DUPLICATE)"
        duplicateData.Duplicated = true
        duplicateData.DuplicateTime = os.time()
        
        -- Attempt to send
        local success, result = pcall(function()
            onCarsAdded:FireServer({duplicateData})
            return "Fired"
        end)
        
        if success then
            print("✅ OnCarsAdded fired successfully")
            successCount = successCount + 1
        else
            print("❌ Error: " .. tostring(result))
        end
    end
    
    -- Method 2: Try UpdateCarPack
    print("\n🔄 Method 2: UpdateCarPack")
    local updateCarPack = ReplicatedStorage.Remotes:FindFirstChild("UpdateCarPack")
    if updateCarPack then
        local duplicateData = {
            Id = "pack-dup-" .. os.time(),
            Name = extractedData.Name or "Duplicated Car",
            Action = "add",
            Player = player
        }
        
        local success, result = pcall(function()
            updateCarPack:FireServer(duplicateData)
            return "Fired"
        end)
        
        if success then
            print("✅ UpdateCarPack fired")
            successCount = successCount + 1
        end
    end
    
    -- Method 3: Try SetCarFavorite (might trigger ownership)
    print("\n🔄 Method 3: SetCarFavorite")
    local setFavorite = ReplicatedStorage.Remotes:FindFirstChild("SetCarFavorite")
    if setFavorite then
        -- Try to mark car as favorite (might give ownership)
        local carId = extractedData.Id or "car-" .. os.time()
        
        local success, result = pcall(function()
            setFavorite:FireServer(carId, true)  -- true = favorite
            return "Fired"
        end)
        
        if success then
            print("✅ SetCarFavorite fired for ID: " .. carId)
            successCount = successCount + 1
        end
    end
    
    -- Method 4: Direct CarReplication manipulation
    print("\n🔄 Method 4: CarReplication manipulation")
    local carReplication = player.PlayerGui:FindFirstChild("CarReplication")
    if carReplication then
        -- Create duplicate car frame
        local duplicateFrame = Instance.new("Frame")
        duplicateFrame.Name = "dup-" .. os.time()
        duplicateFrame.Size = UDim2.new(0, 200, 0, 100)
        duplicateFrame.Position = UDim2.new(0, 0, 0, 0)
        duplicateFrame.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        duplicateFrame.Visible = true
        duplicateFrame.Parent = carReplication
        
        -- Add stats folder
        local stats = Instance.new("Folder")
        stats.Name = "Stats"
        stats.Parent = duplicateFrame
        
        -- Add values
        local nameValue = Instance.new("StringValue")
        nameValue.Name = "Name"
        nameValue.Value = extractedData.Name .. " [DUP]"
        nameValue.Parent = stats
        
        local classValue = Instance.new("IntValue")
        classValue.Name = "Class"
        classValue.Value = extractedData.Class or 1
        classValue.Parent = stats
        
        local ownerValue = Instance.new("StringValue")
        ownerValue.Name = "Owner"
        ownerValue.Value = player.Name
        ownerValue.Parent = stats
        
        print("✅ Created duplicate in CarReplication")
        successCount = successCount + 1
    end
    
    print("\n📊 DUPLICATION RESULTS:")
    print("Methods attempted: 4")
    print("Methods successful: " .. successCount)
    
    return successCount > 0
end

-- Step 6: Monitor inventory access
function CarDuplicator:MonitorInventory()
    print("\n📊 Monitoring inventory access...")
    
    -- Track when inventory is opened
    local inventoryOpened = false
    local lastInventoryAccess = 0
    
    RunService.Heartbeat:Connect(function()
        -- Check if inventory GUI is visible
        local inventory = player.PlayerGui.Menu:FindFirstChild("Inventory")
        if inventory and inventory.Visible then
            if not inventoryOpened then
                inventoryOpened = true
                lastInventoryAccess = os.time()
                print("📂 INVENTORY OPENED at " .. os.date("%H:%M:%S"))
                
                -- Log what happens when inventory opens
                self:LogInventoryActivity()
            end
        else
            inventoryOpened = false
        end
    end)
    
    print("✅ Inventory monitor active")
end

function CarDuplicator:LogInventoryActivity()
    print("🔍 Recording inventory activity...")
    
    -- Check what remotes are called when inventory opens
    task.wait(1)  -- Wait for inventory to load
    
    -- Get current car count
    local carList = self.CarService.GetOwnedCars:InvokeServer()
    print("📦 Cars in inventory: " .. #carList)
    
    -- Check CarReplication
    local carReplication = player.PlayerGui:FindFirstChild("CarReplication")
    if carReplication then
        print("🔄 CarReplication updated, cars: " .. #carReplication:GetChildren())
    end
end

-- Step 7: Run the complete system
function CarDuplicator:Run()
    print("🚀 Starting Intelligent Car Duplication System...")
    
    -- Detect current car
    local currentCar = self:DetectCurrentCar()
    if not currentCar then
        print("⚠️ Please enter/sit in a car first!")
        print("Then run the script again")
        return
    end
    
    -- Setup monitoring
    self:MonitorDataAccess()
    self:MonitorInventory()
    
    -- Find vulnerabilities
    self:FindVulnerabilities()
    
    -- Extract car data
    local extractedData = self:ExtractCarData()
    
    if extractedData then
        -- Ask user if they want to duplicate
        print("\n" .. string.rep("=", 60))
        print("🎮 DUPLICATION READY!")
        print("Current car: " .. tostring(extractedData.Name))
        print("Vulnerabilities found: " .. self.VulnerabilitiesFound)
        print("\n💡 Do you want to attempt duplication?")
        print("Type: duplicate() to start")
        
        -- Make function available
        _G.duplicate = function()
            return self:AttemptDuplication(extractedData)
        end
        
        print("\n✅ System ready! Type 'duplicate()' in console to duplicate")
    end
    
    -- Auto-monitor for 5 minutes
    delay(300, function()
        print("\n🛑 Auto-monitoring ended")
        print("Total calls detected: " .. #self.DetectedCalls)
    end)
end

-- Start the system
CarDuplicator:Run()
