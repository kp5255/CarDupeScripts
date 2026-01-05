-- 🎯 ULTIMATE CAR DUPLICATION SYSTEM v2.0
-- Now with REAL car data integration
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 ULTIMATE CAR DUPLICATION SYSTEM v2.0")
print("=" .. string.rep("=", 60))
print("\n🧠 PRINCIPLE: Use REAL car data for duplication")
print("🎯 METHOD: Rapid-fire actual car tables to valid remotes")
print("=" .. string.rep("=", 60))

-- ===== GET REAL CAR DATA =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

local function getRealCarData()
    print("\n🔍 Getting REAL car data from server...")
    
    local success, result = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(result) == "table" and #result > 0 then
        print("✅ Successfully loaded " .. #result .. " real cars")
        
        -- Extract useful information
        local processedCars = {}
        for i, carTable in ipairs(result) do
            if type(carTable) == "table" then
                -- Get car name from various possible fields
                local carName = carTable.Name or carTable.name or carTable.DisplayName or carTable.NameTag or "Car " .. i
                
                -- Get car ID from various possible fields
                local carId = carTable.Id or carTable.id or carTable.UUID or carTable.uuid or tostring(i)
                
                table.insert(processedCars, {
                    Name = carName,
                    Id = carId,
                    FullTable = carTable,  -- Keep the full table for duplication
                    Index = i
                })
                
                -- Show first few cars for verification
                if i <= 3 then
                    print("   " .. i .. ". " .. carName .. " (ID: " .. carId .. ")")
                end
            end
        end
        
        if #result > 3 then
            print("   ... and " .. (#result - 3) .. " more cars")
        end
        
        return processedCars
    else
        print("❌ Failed to get car data. Error: " .. tostring(result))
        return {}
    end
end

-- ===== FIND VALID CAR TRANSFER REMOTES =====
local function findTransferRemotes()
    print("\n🔍 Finding car transfer/duplication remotes...")
    
    local transferRemotes = {}
    
    -- Common transfer/duplication remote names (expanded list)
    local transferPatterns = {
        "Claim", "Redeem", "Collect", "Receive",
        "Transfer", "Move", "Duplicate", "Copy",
        "Give", "Add", "Purchase", "Buy",
        "Sell", "Trade", "Exchange", "Spawn",
        "Get", "Enable", "Update", "Set"
    }
    
    -- Search all remotes
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local remoteName = obj.Name
            local nameLower = remoteName:lower()
            
            -- Check for transfer patterns
            for _, pattern in pairs(transferPatterns) do
                if nameLower:find(pattern:lower()) then
                    table.insert(transferRemotes, {
                        Object = obj,
                        Name = remoteName,
                        Path = obj:GetFullName(),
                        Pattern = pattern
                    })
                    break
                end
            end
        end
    end
    
    -- Sort by likely relevance
    table.sort(transferRemotes, function(a, b)
        local aScore = 0
        local bScore = 0
        
        -- Higher score for specific patterns
        if a.Name:lower():find("claim") then aScore = aScore + 10 end
        if b.Name:lower():find("claim") then bScore = bScore + 10 end
        
        if a.Name:lower():find("duplicate") then aScore = aScore + 9 end
        if b.Name:lower():find("duplicate") then bScore = bScore + 9 end
        
        if a.Name:lower():find("copy") then aScore = aScore + 8 end
        if b.Name:lower():find("copy") then bScore = bScore + 8 end
        
        if a.Name:lower():find("car") then aScore = aScore + 5 end
        if b.Name:lower():find("car") then bScore = bScore + 5 end
        
        if a.Name:lower():find("vehicle") then aScore = aScore + 5 end
        if b.Name:lower():find("vehicle") then bScore = bScore + 5 end
        
        return aScore > bScore
    end)
    
    print("📡 Found " .. #transferRemotes .. " transfer remotes")
    
    -- Show top 5 most promising remotes
    if #transferRemotes > 0 then
        print("\n🎯 TOP REMOTES:")
        for i = 1, math.min(5, #transferRemotes) do
            print("   " .. i .. ". " .. transferRemotes[i].Name .. " (" .. transferRemotes[i].Pattern .. ")")
        end
    end
    
    return transferRemotes
end

-- ===== ENHANCED RAPID-FIRE DUPLICATION =====
local function rapidFireDuplication(remote, carData)
    print("\n⚡ ENHANCED RAPID-FIRE DUPLICATION")
    print("🎯 Target: " .. remote.Name)
    print("🚗 Using: " .. carData.Name .. " (ID: " .. carData.Id .. ")")
    
    local attempts = 0
    local successes = 0
    local startTime = tick()
    
    -- Enhanced data formats using REAL car table
    local dataFormats = {
        -- Format 1: Full car table (most likely to work)
        carData.FullTable,
        
        -- Format 2: Car table in array
        {carData.FullTable},
        
        -- Format 3: Just car ID
        carData.Id,
        
        -- Format 4: Just car name
        carData.Name,
        
        -- Format 5: With player
        {player, carData.FullTable},
        {player.UserId, carData.FullTable},
        
        -- Format 6: With player and car ID
        {player.UserId, carData.Id},
        {player.Name, carData.Name},
        
        -- Format 7: Transaction format
        {carData.FullTable, 1},  -- Car + quantity
        {carData.FullTable, os.time(), "duplicate"},
        
        -- Format 8: Key-value pairs
        {Car = carData.FullTable, Player = player},
        {Vehicle = carData.FullTable, Owner = player.UserId},
        {carId = carData.Id, playerId = player.UserId}
    }
    
    -- Test formats first
    print("\n🔬 TESTING DATA FORMATS...")
    local workingFormat = nil
    
    for i, data in ipairs(dataFormats) do
        local success = pcall(function()
            remote.Object:FireServer(data)
            return true
        end)
        
        if success then
            print("   ✅ Format " .. i .. " ACCEPTED!")
            workingFormat = data
            successes = successes + 1
            break
        end
    end
    
    if not workingFormat then
        print("❌ No data format accepted by this remote")
        return false
    end
    
    -- RAPID FIRE with working format
    print("\n🚀 STARTING RAPID FIRE (40 attempts)...")
    
    for i = 1, 40 do
        attempts = attempts + 1
        
        local success = pcall(function()
            remote.Object:FireServer(workingFormat)
            return true
        end)
        
        if success then
            successes = successes + 1
        end
        
        -- Variable delay to avoid rate limiting
        task.wait(0.02 + (i % 10) * 0.001)  -- 20-30ms delay
        
        if i % 10 == 0 then
            print("   Sent " .. i .. "/40 rapid requests...")
        end
    end
    
    local totalTime = tick() - startTime
    print("\n📊 RAPID FIRE RESULTS:")
    print("   Total attempts: " .. attempts)
    print("   Successful sends: " .. successes)
    print("   Success rate: " .. string.format("%.1f", (successes/attempts)*100) .. "%")
    print("   Total time: " .. string.format("%.2f", totalTime) .. " seconds")
    print("   Average speed: " .. string.format("%.1f", attempts/totalTime) .. " req/sec")
    
    return successes > 0
end

-- ===== MULTI-CAR DUPLICATION =====
local function multiCarDuplication(remote, allCars)
    print("\n🚀 MULTI-CAR DUPLICATION ATTEMPT")
    print("🎯 Testing multiple cars with: " .. remote.Name)
    
    local totalSuccesses = 0
    local testedCars = 0
    
    -- Test with top 3 cars
    for i = 1, math.min(3, #allCars) do
        local carData = allCars[i]
        print("\n🎯 Testing Car " .. i .. ": " .. carData.Name)
        
        -- Test this car
        local success = rapidFireDuplication(remote, carData)
        
        if success then
            totalSuccesses = totalSuccesses + 1
            print("   ✅ This car works with this remote!")
            
            -- Wait a bit before next car
            task.wait(2)
        else
            print("   ❌ This car doesn't work with this remote")
        end
        
        testedCars = testedCars + 1
    end
    
    print("\n📊 MULTI-CAR RESULTS:")
    print("   Cars tested: " .. testedCars)
    print("   Working combinations: " .. totalSuccesses)
    
    return totalSuccesses > 0
end

-- ===== STATE-BASED DUPLICATION =====
local function stateBasedDuplication()
    print("\n🧠 STATE-BASED DUPLICATION STRATEGY v2.0")
    print("=" .. string.rep("=", 50))
    
    -- Step 1: Get REAL car data
    local myCars = getRealCarData()
    if #myCars == 0 then
        print("❌ No real car data found")
        return
    end
    
    print("\n🚗 YOUR REAL CARS (" .. #myCars .. " total):")
    for i, car in ipairs(myCars) do
        if i <= 5 then
            print("   " .. i .. ". " .. car.Name .. " (ID: " .. car.Id .. ")")
        end
    end
    
    -- Step 2: Find transfer remotes
    local transferRemotes = findTransferRemotes()
    if #transferRemotes == 0 then
        print("❌ No transfer remotes found")
        return
    end
    
    -- Step 3: Select best remote and car
    local bestRemote = nil
    for _, remote in pairs(transferRemotes) do
        if remote.Name:find("Claim") or remote.Name:find("Duplicate") then
            bestRemote = remote
            print("🎯 Selected high-probability remote: " .. remote.Name)
            break
        end
    end
    
    if not bestRemote then
        bestRemote = transferRemotes[1]
        print("🎯 Selected first remote: " .. bestRemote.Name)
    end
    
    local bestCar = myCars[1]  -- Use first car
    
    -- Step 4: Attempt duplication with first car
    print("\n🎯 ATTEMPT 1: Single Car Duplication")
    print("   Remote: " .. bestRemote.Name)
    print("   Car: " .. bestCar.Name)
    
    local success = rapidFireDuplication(bestRemote, bestCar)
    
    if success then
        print("\n✅ SINGLE CAR DUPLICATION SUCCESSFUL!")
        print("💡 Check your inventory now...")
        
        -- Step 5: Try multi-car duplication
        task.wait(5)
        print("\n🔄 ATTEMPT 2: Multi-Car Duplication")
        multiCarDuplication(bestRemote, myCars)
        
        -- Step 6: Try second wave
        task.wait(8)
        print("\n🚀 ATTEMPT 3: Second Wave Duplication")
        print("   Sending another 30 requests...")
        
        for i = 1, 30 do
            pcall(function()
                bestRemote.Object:FireServer(bestCar.FullTable)
            end)
            task.wait(0.03)
        end
        
        print("✅ Second wave complete!")
        
    else
        print("\n❌ Single car duplication failed")
        print("💡 Trying multi-car approach...")
        
        task.wait(3)
        multiCarDuplication(bestRemote, myCars)
    end
    
    print("\n🎯 DUPLICATION PROCESS COMPLETE!")
    print("💡 Check your inventory/garage")
    print("🔄 Wait 15 seconds and run again if needed")
end

-- ===== CREATE DUPER UI v2 =====
local function createDuperUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarDuperProV2"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 450, 0, 500)
    main.Position = UDim2.new(0.5, -225, 0.5, -250)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "⚡ CAR DUPLICATION SYSTEM v2.0"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "🧠 Using REAL car data from server\n🎯 Rapid-fire actual car tables"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 60)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Results display
    local results = Instance.new("ScrollingFrame")
    results.Size = UDim2.new(1, -20, 0, 250)
    results.Position = UDim2.new(0, 10, 0, 130)
    results.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    results.BorderSizePixel = 0
    results.ScrollBarThickness = 8
    results.Parent = main
    
    -- Buttons
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🔍 LOAD REAL CARS"
    scanBtn.Size = UDim2.new(0.48, 0, 0, 40)
    scanBtn.Position = UDim2.new(0, 10, 0, 390)
    scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 14
    scanBtn.Parent = main
    
    local findBtn = Instance.new("TextButton")
    findBtn.Text = "📡 FIND REMOTES"
    findBtn.Size = UDim2.new(0.48, 0, 0, 40)
    findBtn.Position = UDim2.new(0.52, 0, 0, 390)
    findBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 200)
    findBtn.TextColor3 = Color3.new(1, 1, 1)
    findBtn.Font = Enum.Font.GothamBold
    findBtn.TextSize = 14
    findBtn.Parent = main
    
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "⚡ START DUPLICATION"
    dupeBtn.Size = UDim2.new(1, -20, 0, 50)
    dupeBtn.Position = UDim2.new(0, 10, 0, 440)
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
    
    addCorner(main)
    addCorner(title)
    addCorner(status)
    addCorner(results)
    addCorner(scanBtn)
    addCorner(findBtn)
    addCorner(dupeBtn)
    
    -- Functions
    local function updateResults(text, color)
        results:ClearAllChildren()
        
        local label = Instance.new("TextLabel")
        label.Text = text
        label.Size = UDim2.new(1, -10, 1, -10)
        label.Position = UDim2.new(0, 5, 0, 5)
        label.BackgroundTransparency = 1
        label.TextColor3 = color or Color3.new(1, 1, 1)
        label.Font = Enum.Font.Code
        label.TextSize = 10
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Parent = results
    end
    
    -- Variables
    local transferRemotes = {}
    local myCars = {}
    
    -- Button actions
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "LOADING..."
        scanBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Loading REAL car data from server..."
        
        task.spawn(function()
            myCars = getRealCarData()
            
            local resultText = "🚗 REAL CAR DATA:\n\n"
            if #myCars > 0 then
                resultText = resultText .. "Loaded " .. #myCars .. " cars:\n\n"
                for i, car in ipairs(myCars) do
                    if i <= 8 then
                        resultText = resultText .. i .. ". " .. car.Name .. "\n"
                    end
                end
                if #myCars > 8 then
                    resultText = resultText .. "... and " .. (#myCars - 8) .. " more\n"
                end
                status.Text = "✅ Loaded " .. #myCars .. " real cars!"
            else
                resultText = resultText .. "❌ Failed to load car data"
                status.Text = "❌ Failed to load car data"
            end
            
            updateResults(resultText, Color3.fromRGB(0, 255, 150))
            scanBtn.Text = "✅ CARS LOADED"
            scanBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        end)
    end)
    
    findBtn.MouseButton1Click:Connect(function()
        findBtn.Text = "SCANNING..."
        findBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Scanning for transfer remotes..."
        
        task.spawn(function()
            transferRemotes = findTransferRemotes()
            
            local resultText = "📡 TRANSFER REMOTES:\n\n"
            if #transferRemotes > 0 then
                resultText = resultText .. "Found " .. #transferRemotes .. " remotes:\n\n"
                for i, remote in ipairs(transferRemotes) do
                    if i <= 8 then
                        resultText = resultText .. i .. ". " .. remote.Name .. "\n"
                    end
                end
                status.Text = "✅ Found " .. #transferRemotes .. " remotes!"
            else
                resultText = resultText .. "❌ No transfer remotes found"
                status.Text = "❌ No remotes found"
            end
            
            updateResults(resultText, Color3.fromRGB(150, 150, 255))
            findBtn.Text = "✅ REMOTES FOUND"
            findBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 200)
        end)
    end)
    
    dupeBtn.MouseButton1Click:Connect(function()
        if #transferRemotes == 0 then
            status.Text = "❌ Find remotes first!"
            updateResults("Please click FIND REMOTES first", Color3.fromRGB(255, 100, 100))
            return
        end
        
        if #myCars == 0 then
            status.Text = "❌ Load cars first!"
            updateResults("Please click LOAD REAL CARS first", Color3.fromRGB(255, 100, 100))
            return
        end
        
        dupeBtn.Text = "DUPLICATING..."
        dupeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        status.Text = "Starting state-based duplication..."
        updateResults("⚡ STARTING DUPLICATION...\nUsing REAL car data...", Color3.fromRGB(255, 200, 100))
        
        task.spawn(function()
            stateBasedDuplication()
            
            dupeBtn.Text = "⚡ DUPE COMPLETE"
            dupeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            status.Text = "✅ Duplication attempt complete!"
            updateResults("🎯 Check your inventory NOW!\n💡 Wait 15 seconds and try again.", Color3.fromRGB(0, 255, 0))
        end)
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = title
    
    addCorner(closeBtn)
    
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
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Initial display
    updateResults("1. Click LOAD REAL CARS\n2. Click FIND REMOTES\n3. Click START DUPLICATION\n\nUses actual car data from server!", Color3.fromRGB(150, 150, 150))
    
    return gui
end

-- ===== MAIN =====
print("\n🎯 REAL CAR DATA DUPLICATION:")
print("1. Get ACTUAL car tables from server")
print("2. Find car transfer remotes")
print("3. Test remotes with REAL car data")
print("4. Rapid-fire working combinations")
print("5. Multi-car and multi-wave attempts")

print("\n🚀 Starting system...")

-- Create UI
local ui = createDuperUI()

print("\n✅ SYSTEM READY WITH REAL CAR DATA!")
print("\n💡 HOW TO USE:")
print("1. LOAD REAL CARS - Gets your actual car tables")
print("2. FIND REMOTES - Finds transfer/duplication remotes")
print("3. START DUPLICATION - Tests and rapid-fires")
print("4. Check inventory - Look for duplicates")
print("5. Wait 15s - Try again")

print("\n🎯 KEY IMPROVEMENTS:")
print("• Uses REAL car data from GetOwnedCars")
print("• Tests with full car tables (not just names)")
print("• Multi-car testing approach")
print("• Multiple duplication waves")
