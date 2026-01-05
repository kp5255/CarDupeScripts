-- 🚀 ADVANCED CAR DUPLICATION SYSTEM
-- Based on actual car data structure
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🚀 ADVANCED CAR DUPLICATION SYSTEM")
print("=" .. string.rep("=", 60))

-- ===== GET ACTUAL CAR DATA =====
local function getActualCars()
    print("\n🔍 Getting your actual cars...")
    
    local success, result = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(result) == "table" then
        print("✅ Successfully loaded " .. #result .. " cars")
        return result
    else
        print("❌ Failed to load cars")
        return {}
    end
end

-- ===== FIND ALL CAR REMOTES =====
local function findCarRemotes()
    print("\n🔍 Finding all car-related RemoteEvents...")
    
    local carRemotes = {}
    local allRemotes = {}
    
    -- Get all RemoteEvents
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(allRemotes, {
                Object = obj,
                Name = obj.Name,
                Path = obj:GetFullName()
            })
        end
    end
    
    print("Found " .. #allRemotes .. " total RemoteEvents")
    
    -- Categorize by likely function
    for _, remote in pairs(allRemotes) do
        local nameLower = remote.Name:lower()
        
        -- High confidence car remotes
        if nameLower:find("claim") or nameLower:find("redeem") or 
           nameLower:find("duplicate") or nameLower:find("copy") or
           nameLower:find("spawn") or nameLower:find("purchase") or
           nameLower:find("buy") then
            table.insert(carRemotes, {
                Object = remote.Object,
                Name = remote.Name,
                Path = remote.Path,
                Priority = "HIGH",
                Reason = "Contains car/duplication keywords"
            })
        
        -- Medium confidence
        elseif nameLower:find("car") or nameLower:find("vehicle") or
               nameLower:find("garage") or nameLower:find("inventory") then
            table.insert(carRemotes, {
                Object = remote.Object,
                Name = remote.Name,
                Path = remote.Path,
                Priority = "MEDIUM",
                Reason = "Contains car/vehicle terms"
            })
        
        -- Low confidence but worth checking
        elseif nameLower:find("add") or nameLower:find("get") or
               nameLower:find("select") or nameLower:find("choose") then
            table.insert(carRemotes, {
                Object = remote.Object,
                Name = remote.Name,
                Path = remote.Path,
                Priority = "LOW",
                Reason = "General item management"
            })
        end
    end
    
    -- Also check ReplicatedStorage.Remotes
    local remoteFolders = {
        ReplicatedStorage.Remotes,
        ReplicatedStorage.Services,
        game:GetService("ServerStorage")
    }
    
    for _, folder in pairs(remoteFolders) do
        if folder then
            for _, obj in pairs(folder:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    local found = false
                    for _, r in pairs(carRemotes) do
                        if r.Object == obj then found = true break end
                    end
                    
                    if not found then
                        table.insert(carRemotes, {
                            Object = obj,
                            Name = obj.Name,
                            Path = obj:GetFullName(),
                            Priority = "CHECK",
                            Reason = "From Remotes folder"
                        })
                    end
                end
            end
        end
    end
    
    print("Identified " .. #carRemotes .. " potential car remotes")
    return carRemotes
end

-- ===== TEST REMOTES WITH ACTUAL CAR DATA =====
local function testRemotesWithCarData(remotes, carData)
    print("\n🔬 Testing remotes with actual car data...")
    
    if #carData == 0 then
        print("❌ No car data to test with")
        return {}
    end
    
    local workingCombinations = {}
    local testCar = carData[1]  -- Use first car for testing
    
    print("Using car data: " .. tostring(testCar.Name or "Unknown"))
    
    -- Try different data formats
    local testFormats = {
        -- Format 1: Raw car table
        testCar,
        
        -- Format 2: Car table in array
        {testCar},
        
        -- Format 3: Just car name/ID
        testCar.Name or testCar.name or testCar.Id or testCar.id,
        
        -- Format 4: With player
        {player, testCar},
        {player.UserId, testCar},
        
        -- Format 5: Key-value pairs
        {Car = testCar, Player = player},
        {Vehicle = testCar, Owner = player.UserId},
        
        -- Format 6: Common CDT formats
        {testCar, 1},  -- Car + quantity
        {testCar.Name, player.UserId},
        {testCar.Id, testCar.Name, player.Name}
    }
    
    -- Test HIGH priority remotes first
    for _, remote in pairs(remotes) do
        if remote.Priority == "HIGH" then
            print("\n🎯 Testing HIGH priority: " .. remote.Name)
            
            for i, format in ipairs(testFormats) do
                local success, result = pcall(function()
                    remote.Object:FireServer(format)
                    return true
                end)
                
                if success then
                    print("   ✅ Format " .. i .. " ACCEPTED!")
                    table.insert(workingCombinations, {
                        Remote = remote,
                        Format = format,
                        FormatIndex = i,
                        Car = testCar
                    })
                    
                    -- Test rapid fire
                    print("   ⚡ Testing rapid fire (5 requests)...")
                    local fireCount = 0
                    for j = 1, 5 do
                        if pcall(function() remote.Object:FireServer(format) end) then
                            fireCount = fireCount + 1
                        end
                        task.wait(0.05)
                    end
                    print("   🔥 Successfully sent " .. fireCount .. " rapid requests")
                    break
                end
            end
        end
    end
    
    -- If no HIGH worked, try MEDIUM
    if #workingCombinations == 0 then
        print("\n🔍 No HIGH priority worked, trying MEDIUM...")
        
        for _, remote in pairs(remotes) do
            if remote.Priority == "MEDIUM" then
                print("   Testing: " .. remote.Name)
                
                -- Try just basic formats
                local basicFormats = {
                    testCar,
                    testCar.Name or testCar.name,
                    {testCar}
                }
                
                for _, format in ipairs(basicFormats) do
                    local success = pcall(function()
                        remote.Object:FireServer(format)
                        return true
                    end)
                    
                    if success then
                        print("   ✅ " .. remote.Name .. " accepts format")
                        table.insert(workingCombinations, {
                            Remote = remote,
                            Format = format,
                            Car = testCar
                        })
                        break
                    end
                end
                
                if #workingCombinations > 2 then break end
            end
        end
    end
    
    return workingCombinations
end

-- ===== BULK DUPLICATION =====
local function bulkDuplication(workingCombo, carData)
    print("\n🚀 STARTING BULK DUPLICATION")
    print("=" .. string.rep("=", 50))
    
    if not workingCombo then
        print("❌ No working combination found")
        return
    end
    
    print("🎯 Using: " .. workingCombo.Remote.Name)
    print("🚗 Car: " .. tostring(workingCombo.Car.Name or "Unknown"))
    print("📦 Format: " .. tostring(workingCombo.FormatIndex or "Custom"))
    
    -- Phase 1: Initial rapid fire
    print("\n⚡ PHASE 1: Initial Rapid Fire (25 requests)")
    local phase1Count = 0
    local phase1Start = tick()
    
    for i = 1, 25 do
        if pcall(function() workingCombo.Remote.Object:FireServer(workingCombo.Format) end) then
            phase1Count = phase1Count + 1
        end
        task.wait(0.03)  -- 30ms delay
    end
    
    local phase1Time = tick() - phase1Start
    print("   Sent: " .. phase1Count .. " requests")
    print("   Time: " .. string.format("%.2f", phase1Time) .. " seconds")
    
    -- Wait for server to process
    print("\n⏳ Waiting 3 seconds for server processing...")
    task.wait(3)
    
    -- Phase 2: Second wave
    print("⚡ PHASE 2: Second Wave (15 requests)")
    local phase2Count = 0
    
    for i = 1, 15 do
        if pcall(function() workingCombo.Remote.Object:FireServer(workingCombo.Format) end) then
            phase2Count = phase2Count + 1
        end
        task.wait(0.05)
    end
    
    print("   Sent: " .. phase2Count .. " additional requests")
    
    -- Phase 3: Try different cars from your list
    if #carData > 1 then
        print("\n🎯 PHASE 3: Testing other cars")
        
        for i = 2, math.min(5, #carData) do
            local otherCar = carData[i]
            print("   Testing: " .. tostring(otherCar.Name or "Car " .. i))
            
            -- Try same format with different car
            local testFormat = otherCar  -- Try raw car data
            
            local success = pcall(function()
                workingCombo.Remote.Object:FireServer(testFormat)
                return true
            end)
            
            if success then
                print("   ✅ Remote accepts this car too!")
                -- Rapid fire this car
                for j = 1, 10 do
                    workingCombo.Remote.Object:FireServer(testFormat)
                    task.wait(0.04)
                end
                print("   🔥 Sent 10 rapid requests")
            end
        end
    end
    
    local totalSent = phase1Count + phase2Count
    print("\n📊 DUPLICATION COMPLETE")
    print("   Total requests sent: " .. totalSent)
    print("\n💡 Check your inventory/garage now!")
    print("🔄 Wait 10 seconds and check again")
    print("🎯 Try the process again if needed")
end

-- ===== MAIN EXECUTION =====
local function main()
    print("\n🎯 STARTING DUPLICATION PROCESS")
    
    -- Step 1: Get actual car data
    local myCars = getActualCars()
    if #myCars == 0 then
        print("❌ Cannot proceed without car data")
        return
    end
    
    -- Show car info
    print("\n🚗 YOUR CARS:")
    for i, car in ipairs(myCars) do
        local carName = car.Name or car.name or "Unknown"
        local carId = car.Id or car.id or car.UUID or "No ID"
        print(i .. ". " .. carName .. " (" .. type(carId) .. ": " .. tostring(carId) .. ")")
        if i >= 5 then
            print("   ... and " .. (#myCars - 5) .. " more cars")
            break
        end
    end
    
    -- Step 2: Find car remotes
    local carRemotes = findCarRemotes()
    
    -- Step 3: Test remotes with car data
    local workingCombos = testRemotesWithCarData(carRemotes, myCars)
    
    -- Step 4: Perform duplication
    if #workingCombos > 0 then
        print("\n✅ FOUND " .. #workingCombos .. " WORKING COMBINATIONS!")
        
        -- Use the first working combo for bulk duplication
        bulkDuplication(workingCombos[1], myCars)
        
        -- If multiple combos found, offer to try others
        if #workingCombos > 1 then
            print("\n🎯 ADDITIONAL WORKING COMBOS FOUND:")
            for i, combo in ipairs(workingCombos) do
                if i > 1 then
                    print(i .. ". " .. combo.Remote.Name .. " (Format " .. tostring(combo.FormatIndex or "?") .. ")")
                end
            end
            
            print("\n💡 Run the script again to try other combinations")
        end
    else
        print("\n❌ NO WORKING COMBINATIONS FOUND")
        print("\n💡 MANUAL TESTING RECOMMENDED:")
        print("1. Open Developer Console (F9)")
        print("2. Try these common CDT remotes:")
        print("   - ReplicatedStorage.Remotes.ClaimCar")
        print("   - ReplicatedStorage.Remotes.DuplicateCar")
        print("   - ReplicatedStorage.Remotes.PurchaseCar")
        print("3. Use your car table as argument")
    end
end

-- ===== CREATE QUICK UI =====
local function createQuickUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarDupeQuick"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 350, 0, 250)
    main.Position = UDim2.new(0.5, -175, 0.5, -125)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🎯 CAR DUPE QUICK"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    local status = Instance.new("TextLabel")
    status.Text = "Ready to duplicate cars"
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🔍 SCAN & TEST"
    scanBtn.Size = UDim2.new(1, -20, 0, 40)
    scanBtn.Position = UDim2.new(0, 10, 0, 140)
    scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 14
    scanBtn.Parent = main
    
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "⚡ START DUPLICATION"
    dupeBtn.Size = UDim2.new(1, -20, 0, 40)
    dupeBtn.Position = UDim2.new(0, 10, 0, 190)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.GothamBold
    dupeBtn.TextSize = 16
    dupeBtn.Parent = main
    
    -- Add corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    for _, obj in pairs({main, title, status, scanBtn, dupeBtn}) do
        addCorner(obj)
    end
    
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "SCANNING..."
        status.Text = "🔍 Scanning for car data and remotes..."
        
        task.spawn(function()
            local cars = getActualCars()
            local remotes = findCarRemotes()
            
            status.Text = "Found:\n" ..
                         "Cars: " .. #cars .. "\n" ..
                         "Remotes: " .. #remotes .. "\n\n" ..
                         "Click START DUPLICATION"
            scanBtn.Text = "✅ SCAN COMPLETE"
            scanBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        end)
    end)
    
    dupeBtn.MouseButton1Click:Connect(function()
        dupeBtn.Text = "DUPLICATING..."
        status.Text = "⚡ Starting duplication process...\nPlease wait"
        
        task.spawn(function()
            main()
            
            dupeBtn.Text = "⚡ DUPE COMPLETE"
            dupeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            status.Text = "✅ Process complete!\nCheck your inventory\nWait 10s and try again"
        end)
    end)
    
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
    addCorner(closeBtn)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== START =====
print("\n🚀 Creating interface...")
createQuickUI()

print("\n🎯 READY TO DUPLICATE")
print("=" .. string.rep("=", 60))
print("\n💡 INSTRUCTIONS:")
print("1. Click SCAN & TEST")
print("2. Wait for scan to complete")
print("3. Click START DUPLICATION")
print("4. Check your inventory!")
print("5. Wait and repeat if needed")
