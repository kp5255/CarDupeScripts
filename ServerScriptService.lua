-- 🎯 TARGETED DUPLICATION SYSTEM
-- Using your exact car structure
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 TARGETED DUPLICATION SYSTEM")
print("=" .. string.rep("=", 50))
print("Using car structure: Id, Data, Name")

-- ===== GET CAR DATA =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

local function getCars()
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(cars) == "table" then
        return cars
    end
    return {}
end

-- ===== EXTRACT CAR ID AND NAME =====
local function extractCarInfo(car)
    if not car then return nil end
    
    return {
        Id = car.Id,
        Name = car.Name,
        FullTable = car,
        Data = car.Data
    }
end

-- ===== FIND AND TEST REMOTES =====
local function findWorkingRemotes()
    print("\n🔍 FINDING WORKING REMOTES")
    print("=" .. string.rep("=", 50))
    
    local cars = getCars()
    if #cars == 0 then
        print("❌ No cars found")
        return {}
    end
    
    local car = cars[1]
    local carInfo = extractCarInfo(car)
    
    print("🚗 Using car:")
    print("   Name: " .. (carInfo.Name or "Unknown"))
    print("   ID: " .. (carInfo.Id or "Unknown"))
    
    -- Common CDT remote locations
    local remoteLocations = {
        ReplicatedStorage.Remotes,
        ReplicatedStorage.Services,
        game:GetService("ServerStorage"),
        workspace
    }
    
    local workingRemotes = {}
    
    -- Test specific remote names (based on CDT)
    local remoteNamesToTest = {
        -- Purchase/Buy remotes
        "PurchaseCar",
        "BuyCar",
        "PurchaseVehicle",
        "BuyVehicle",
        
        -- Get/Claim remotes
        "GetCar",
        "ClaimCar",
        "RedeemCar",
        "ReceiveCar",
        "CollectCar",
        "UnlockCar",
        
        -- Trade/Transfer remotes
        "TradeCar",
        "TransferCar",
        "ExchangeCar",
        "GiveCar",
        "AddCar",
        
        -- Duplication remotes (if they exist)
        "DuplicateCar",
        "CopyCar",
        "CloneCar",
        "DuplicateVehicle",
        
        -- Update/Modify remotes
        "UpdateCar",
        "ModifyCar",
        "UpgradeCar",
        "EnhanceCar",
        
        -- Garage/Inventory remotes
        "GarageAddCar",
        "InventoryAddCar",
        "SpawnCar",
        "CreateCar"
    }
    
    -- Search for and test each remote
    for _, remoteName in ipairs(remoteNamesToTest) do
        for _, location in ipairs(remoteLocations) do
            if location then
                local remote = location:FindFirstChild(remoteName)
                if remote and remote:IsA("RemoteEvent") then
                    print("\n🎯 Found: " .. remoteName .. " in " .. location.Name)
                    
                    -- Test different data formats
                    local formats = {
                        -- Format 1: Full car table
                        carInfo.FullTable,
                        
                        -- Format 2: Just car ID
                        carInfo.Id,
                        
                        -- Format 3: Just car name
                        carInfo.Name,
                        
                        -- Format 4: Array with car
                        {carInfo.FullTable},
                        
                        -- Format 5: With player
                        {player, carInfo.FullTable},
                        {player.UserId, carInfo.FullTable},
                        
                        -- Format 6: Key-value format
                        {Car = carInfo.FullTable, Player = player},
                        {Vehicle = carInfo.FullTable, Owner = player.UserId},
                        
                        -- Format 7: Car ID + Name
                        {carInfo.Id, carInfo.Name},
                        
                        -- Format 8: Data table only
                        carInfo.Data
                    }
                    
                    for i, format in ipairs(formats) do
                        if format ~= nil then
                            local success = pcall(function()
                                remote:FireServer(format)
                                return true
                            end)
                            
                            if success then
                                print("   ✅ Format " .. i .. " WORKS!")
                                
                                -- Test rapid fire with this format
                                print("   ⚡ Testing rapid fire...")
                                local sentCount = 0
                                for j = 1, 5 do
                                    if pcall(function() remote:FireServer(format) end) then
                                        sentCount = sentCount + 1
                                    end
                                    task.wait(0.1)
                                end
                                print("   🔥 Sent " .. sentCount .. " rapid requests")
                                
                                -- Save working combination
                                table.insert(workingRemotes, {
                                    Remote = remote,
                                    Name = remoteName,
                                    Format = i,
                                    Data = format
                                })
                                
                                break  -- Move to next remote
                            end
                        end
                    end
                end
            end
        end
    end
    
    return workingRemotes
end

-- ===== BULK DUPLICATION =====
local function bulkDuplication(workingRemote)
    print("\n🚀 BULK DUPLICATION ATTEMPT")
    print("=" .. string.rep("=", 50))
    
    if not workingRemote then
        print("❌ No working remote found")
        return
    end
    
    print("🎯 Using remote: " .. workingRemote.Name)
    print("📦 Using format: " .. workingRemote.Format)
    
    local cars = getCars()
    if #cars == 0 then return end
    
    -- Phase 1: Initial requests
    print("\n📡 PHASE 1: Initial requests")
    for i = 1, 10 do
        pcall(function()
            workingRemote.Remote:FireServer(workingRemote.Data)
        end)
        print("   Sent request " .. i)
        task.wait(0.2)
    end
    
    -- Wait for server processing
    print("\n⏳ Waiting 3 seconds...")
    task.wait(3)
    
    -- Phase 2: Second wave
    print("📡 PHASE 2: Second wave")
    for i = 1, 5 do
        pcall(function()
            workingRemote.Remote:FireServer(workingRemote.Data)
        end)
        print("   Sent follow-up " .. i)
        task.wait(0.3)
    end
    
    print("\n✅ Bulk duplication complete!")
    print("💡 Check your garage NOW")
end

-- ===== CREATE SIMPLE UI =====
local function createUI()
    -- Wait for PlayerGui
    while not player:FindFirstChild("PlayerGui") do
        task.wait(0.1)
    end
    
    -- Remove old UI
    local oldUI = player.PlayerGui:FindFirstChild("CarToolsUI")
    if oldUI then oldUI:Destroy() end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarToolsUI"
    gui.Parent = player.PlayerGui
    gui.ResetOnSpawn = false
    
    -- Main frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 200)
    main.Position = UDim2.new(0.5, -150, 0.5, -100)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 Car Tools"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Text = "Ready to find duplication remotes"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Buttons
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🔍 SCAN REMOTES"
    scanBtn.Size = UDim2.new(1, -20, 0, 40)
    scanBtn.Position = UDim2.new(0, 10, 0, 120)
    scanBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 14
    scanBtn.Parent = main
    
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "⚡ START DUPE"
    dupeBtn.Size = UDim2.new(1, -20, 0, 40)
    dupeBtn.Position = UDim2.new(0, 10, 0, 170)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.GothamBold
    dupeBtn.TextSize = 14
    dupeBtn.Parent = main
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = title
    
    -- Round corners
    local function roundCorners(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    roundCorners(main)
    roundCorners(title)
    roundCorners(status)
    roundCorners(scanBtn)
    roundCorners(dupeBtn)
    roundCorners(closeBtn)
    
    -- Variables
    local workingRemote = nil
    
    -- Button actions
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "SCANNING..."
        status.Text = "Scanning for duplication remotes...\nThis may take a moment"
        
        task.spawn(function()
            local remotes = findWorkingRemotes()
            
            if #remotes > 0 then
                workingRemote = remotes[1]  -- Use first working remote
                status.Text = "✅ Found " .. #remotes .. " working remotes!\nUsing: " .. workingRemote.Name
            else
                status.Text = "❌ No working remotes found\nCheck console for details"
            end
            
            scanBtn.Text = "🔍 SCAN REMOTES"
        end)
    end)
    
    dupeBtn.MouseButton1Click:Connect(function()
        if not workingRemote then
            status.Text = "❌ Scan for remotes first!"
            return
        end
        
        dupeBtn.Text = "DUPLICATING..."
        status.Text = "Starting duplication...\nPlease wait"
        
        task.spawn(function()
            bulkDuplication(workingRemote)
            status.Text = "✅ Duplication complete!\nCheck your garage"
            dupeBtn.Text = "⚡ START DUPE"
        end)
    end)
    
    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Make draggable
    local dragging = false
    local dragStart, frameStart
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = main.Position
        end
    end)
    
    title.InputEnded:Connect(function()
        dragging = false
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    return gui
end

-- ===== MANUAL TEST =====
local function manualTest()
    print("\n🔧 MANUAL TEST - DIRECT TO CONSOLE")
    print("=" .. string.rep("=", 50))
    
    local cars = getCars()
    if #cars == 0 then
        print("❌ No cars found")
        return
    end
    
    local car = cars[1]
    print("🚗 Car: " .. (car.Name or "Unknown"))
    print("🔑 ID: " .. (car.Id or "Unknown"))
    
    -- Try PurchaseCar remote (common in CDT)
    local purchaseRemote = ReplicatedStorage:FindFirstChild("PurchaseCar")
    if not purchaseRemote then
        purchaseRemote = ReplicatedStorage.Remotes:FindFirstChild("PurchaseCar")
    end
    if not purchaseRemote then
        purchaseRemote = ReplicatedStorage.Services:FindFirstChild("PurchaseCar")
    end
    
    if purchaseRemote and purchaseRemote:IsA("RemoteEvent") then
        print("\n🎯 Found PurchaseCar remote!")
        
        -- Try different formats
        print("📦 Testing formats...")
        
        local formats = {
            car,
            car.Id,
            car.Name,
            {car},
            {player, car}
        }
        
        for i, format in ipairs(formats) do
            local success = pcall(function()
                purchaseRemote:FireServer(format)
                return true
            end)
            
            if success then
                print("   ✅ Format " .. i .. " ACCEPTED!")
                
                -- Rapid fire
                print("   ⚡ Sending 10 rapid requests...")
                for j = 1, 10 do
                    pcall(function() purchaseRemote:FireServer(format) end)
                    task.wait(0.1)
                end
                
                print("   🔥 Rapid fire complete!")
                return
            end
        end
    else
        print("❌ PurchaseCar remote not found")
    end
    
    print("\n💡 Check console for other remotes from previous scan")
end

-- ===== MAIN =====
print("\n🚀 Starting system...")
createUI()

print("\n✅ SYSTEM READY!")
print("\n💡 HOW TO USE:")
print("1. Click SCAN REMOTES - Finds working duplication remotes")
print("2. Click START DUPE - Uses found remote for duplication")
print("3. Check console for results")

print("\n🎯 Testing PurchaseCar remote directly...")
task.wait(2)
manualTest()
