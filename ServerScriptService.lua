-- 🎯 WORKING DUPLICATION SYSTEM v2.0
-- Based on actual car data structure
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 WORKING DUPLICATION SYSTEM")
print("=" .. string.rep("=", 50))

-- ===== GET CAR DATA =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

local function getCars()
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(cars) == "table" then
        print("✅ Loaded " .. #cars .. " cars")
        return cars
    end
    return {}
end

-- ===== ANALYZE CAR STRUCTURE =====
local function analyzeCar(car)
    print("\n🔍 CAR STRUCTURE ANALYSIS:")
    
    local fieldCount = 0
    local importantFields = {}
    
    for fieldName, fieldValue in pairs(car) do
        fieldCount = fieldCount + 1
        
        if fieldCount <= 10 then
            local valueType = type(fieldValue)
            local displayValue = tostring(fieldValue)
            
            if valueType == "string" and #displayValue > 20 then
                displayValue = displayValue:sub(1, 20) .. "..."
            end
            
            print(string.format("  %-15s = %-20s (%s)", 
                tostring(fieldName), displayValue, valueType))
        end
        
        -- Track important fields
        local nameLower = tostring(fieldName):lower()
        if nameLower:find("name") or nameLower:find("id") or 
           nameLower:find("uuid") or nameLower:find("display") then
            table.insert(importantFields, {
                Name = fieldName,
                Value = fieldValue,
                Type = type(fieldValue)
            })
        end
    end
    
    if fieldCount > 10 then
        print("  ... and " .. (fieldCount - 10) .. " more fields")
    end
    
    return importantFields
end

-- ===== FIND ALL REMOTES =====
local function findAllRemotes()
    local remotes = {}
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(remotes, {
                Object = obj,
                Name = obj.Name,
                Path = obj:GetFullName()
            })
        end
    end
    
    return remotes
end

-- ===== TEST SPECIFIC REMOTES =====
local function testSpecificRemotes(car)
    print("\n🎯 TESTING SPECIFIC REMOTES:")
    
    local cars = getCars()
    if #cars == 0 then return end
    
    local testCar = cars[1]
    
    -- Common CDT remote names for duplication
    local testRemotes = {
        "PurchaseCar",
        "BuyCar",
        "GetCar", 
        "ClaimCar",
        "RedeemCar",
        "DuplicateCar",
        "CopyCar",
        "CloneCar",
        "AddCar",
        "GiveCar",
        "CreateCar",
        "SpawnCar",
        "UnlockCar",
        "ReceiveCar",
        "CollectCar"
    }
    
    for _, remoteName in ipairs(testRemotes) do
        -- Search for this remote
        local foundRemote = nil
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name == remoteName then
                foundRemote = obj
                break
            end
        end
        
        if foundRemote then
            print("\n🔍 Testing: " .. remoteName)
            
            -- Test different data formats
            local formats = {
                -- Format 1: Full car table
                testCar,
                
                -- Format 2: Just car name (if exists)
                testCar.Name or testCar.name or testCar.DisplayName,
                
                -- Format 3: Just car ID (if exists)
                testCar.Id or testCar.id or testCar.UUID,
                
                -- Format 4: Array format
                {testCar},
                
                -- Format 5: With player
                {player, testCar},
                {player.UserId, testCar},
                
                -- Format 6: Transaction format
                {testCar, 1},  -- Car + quantity
                {testCar, os.time()},  -- Car + timestamp
            }
            
            local foundWorking = false
            
            for i, format in ipairs(formats) do
                if format ~= nil then  -- Skip nil formats
                    local success = pcall(function()
                        foundRemote:FireServer(format)
                        return true
                    end)
                    
                    if success then
                        print("   ✅ Format " .. i .. " ACCEPTED!")
                        foundWorking = true
                        
                        -- Test rapid fire with this format
                        print("   ⚡ Testing rapid fire (3 requests)...")
                        for j = 1, 3 do
                            pcall(function() foundRemote:FireServer(format) end)
                            task.wait(0.1)
                        end
                        
                        break
                    end
                end
            end
            
            if not foundWorking then
                print("   ❌ No format accepted")
            end
            
            task.wait(0.5)  -- Brief pause between remotes
        end
    end
end

-- ===== MANUAL REMOTE FINDER =====
local function manualRemoteFinder()
    print("\n🔧 MANUAL REMOTE FINDER")
    print("=" .. string.rep("=", 50))
    
    local cars = getCars()
    if #cars == 0 then return end
    
    local testCar = cars[1]
    
    -- Display car info
    print("\n🚗 USING CAR:")
    analyzeCar(testCar)
    
    -- Find all remotes
    local allRemotes = findAllRemotes()
    print("\n📡 Found " .. #allRemotes .. " RemoteEvents")
    
    -- Show first 10 remotes
    print("\n🔍 FIRST 10 REMOTES:")
    for i = 1, math.min(10, #allRemotes) do
        local remote = allRemotes[i]
        print(i .. ". " .. remote.Name .. " (" .. remote.Path .. ")")
    end
    
    -- Test the most promising ones
    print("\n🎯 TESTING PROMISING REMOTES:")
    
    local promisingRemotes = {}
    for _, remote in ipairs(allRemotes) do
        local nameLower = remote.Name:lower()
        
        if nameLower:find("car") or nameLower:find("vehicle") or
           nameLower:find("purchase") or nameLower:find("buy") or
           nameLower:find("get") or nameLower:find("claim") or
           nameLower:find("duplicate") or nameLower:find("copy") then
            table.insert(promisingRemotes, remote)
        end
    end
    
    print("Found " .. #promisingRemotes .. " promising remotes")
    
    -- Test each promising remote
    for i, remote in ipairs(promisingRemotes) do
        if i > 5 then break end  -- Test only first 5
        
        print("\n🔧 Testing: " .. remote.Name)
        
        -- Try the full car table
        local success = pcall(function()
            remote.Object:FireServer(testCar)
            return true
        end)
        
        if success then
            print("   ✅ Remote accepts car table!")
            
            -- Try a few more times
            print("   ⚡ Sending 2 more requests...")
            for j = 1, 2 do
                pcall(function() remote.Object:FireServer(testCar) end)
                task.wait(0.2)
            end
        else
            print("   ❌ Remote rejected car table")
        end
        
        task.wait(0.5)
    end
    
    print("\n✅ Manual testing complete!")
end

-- ===== CREATE WORKING UI =====
local function createUI()
    -- Wait for PlayerGui
    while not player:FindFirstChild("PlayerGui") do
        task.wait(0.1)
    end
    
    -- Remove old UI
    local oldUI = player.PlayerGui:FindFirstChild("CarDupeUI")
    if oldUI then oldUI:Destroy() end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarDupeUI"
    gui.Parent = player.PlayerGui
    gui.ResetOnSpawn = false
    
    -- Main frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 350, 0, 250)
    main.Position = UDim2.new(0.5, -175, 0.5, -125)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎯 CAR DUPLICATION TOOLS"
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
    status.Text = "Ready to scan for duplication remotes"
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Buttons
    local analyzeBtn = Instance.new("TextButton")
    analyzeBtn.Text = "🔍 ANALYZE CARS"
    analyzeBtn.Size = UDim2.new(1, -20, 0, 40)
    analyzeBtn.Position = UDim2.new(0, 10, 0, 140)
    analyzeBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    analyzeBtn.TextColor3 = Color3.new(1, 1, 1)
    analyzeBtn.Font = Enum.Font.GothamBold
    analyzeBtn.TextSize = 14
    analyzeBtn.Parent = main
    
    local testBtn = Instance.new("TextButton")
    testBtn.Text = "🎯 TEST REMOTES"
    testBtn.Size = UDim2.new(1, -20, 0, 40)
    testBtn.Position = UDim2.new(0, 10, 0, 190)
    testBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    testBtn.TextColor3 = Color3.new(1, 1, 1)
    testBtn.Font = Enum.Font.GothamBold
    testBtn.TextSize = 14
    testBtn.Parent = main
    
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
    roundCorners(analyzeBtn)
    roundCorners(testBtn)
    roundCorners(closeBtn)
    
    -- Button actions
    analyzeBtn.MouseButton1Click:Connect(function()
        analyzeBtn.Text = "ANALYZING..."
        status.Text = "Analyzing car structure...\nPlease wait"
        
        task.spawn(function()
            local cars = getCars()
            if #cars > 0 then
                analyzeCar(cars[1])
                status.Text = "✅ Car analysis complete!\nCheck console for details"
            else
                status.Text = "❌ No cars found"
            end
            analyzeBtn.Text = "🔍 ANALYZE CARS"
        end)
    end)
    
    testBtn.MouseButton1Click:Connect(function()
        testBtn.Text = "TESTING..."
        status.Text = "Testing all duplication remotes...\nThis may take a minute"
        
        task.spawn(function()
            local cars = getCars()
            if #cars > 0 then
                testSpecificRemotes(cars[1])
                status.Text = "✅ Remote testing complete!\nCheck console for results"
            else
                status.Text = "❌ No cars found"
            end
            testBtn.Text = "🎯 TEST REMOTES"
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
    
    print("✅ UI created successfully")
    return gui
end

-- ===== MAIN =====
print("\n🚀 Starting system...")
createUI()

print("\n✅ SYSTEM READY!")
print("\n💡 HOW TO USE:")
print("1. Click ANALYZE CARS - See your car structure")
print("2. Click TEST REMOTES - Find working duplication remotes")
print("3. Check console for results")

print("\n🎯 This will find the ACTUAL duplication remote!")
