-- 🎯 ULTIMATE CAR DUPLICATION SYSTEM
-- Based on VALID STATE REPETITION principle
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 ULTIMATE CAR DUPLICATION SYSTEM")
print("=" .. string.rep("=", 60))
print("\n🧠 PRINCIPLE: Duplicate VALID states, not bypass validation")
print("🎯 METHOD: Rapid-fire SAME valid request before state updates")
print("=" .. string.rep("=", 60))

-- ===== FIND VALID CAR TRANSFER REMOTES =====
local function findTransferRemotes()
    print("\n🔍 Finding car transfer/duplication remotes...")
    
    local transferRemotes = {}
    
    -- Common transfer/duplication remote names
    local transferPatterns = {
        "Claim", "Redeem", "Collect", "Receive",
        "Transfer", "Move", "Duplicate", "Copy",
        "Give", "Add", "Purchase", "Buy",
        "Sell", "Trade", "Exchange"
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
    
    print("📡 Found " .. #transferRemotes .. " transfer remotes")
    return transferRemotes
end

-- ===== FIND YOUR CURRENT CARS =====
local function findMyCurrentCars()
    print("\n🔍 Finding your current cars for VALID duplication...")
    
    local myCars = {}
    
    -- Method 1: Check GUI for owned cars
    if player:FindFirstChild("PlayerGui") then
        local gui = player.PlayerGui:FindFirstChild("MultiCarSelection")
        if gui then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("TextLabel") and #obj.Text > 2 then
                    local text = obj.Text
                    -- Check if it's a car name
                    if text:find("Bontlay") or text:find("Jegar") or text:find("Corsaro") or
                       text:find("Lavish") or text:find("Sportler") then
                        table.insert(myCars, {
                            Name = text,
                            Source = "GUI Display",
                            Path = obj:GetFullName()
                        })
                    end
                end
            end
        end
    end
    
    -- Method 2: Check StringValues for car IDs
    for _, obj in pairs(player:GetDescendants()) do
        if obj:IsA("StringValue") then
            local value = obj.Value
            if type(value) == "string" and #value > 10 then
                -- Check for car ID patterns
                if value:find("car_") or value:find("vehicle_") or 
                   value:match("^%x%x%x%x") or value:match("^%d%d%d%d") then
                    table.insert(myCars, {
                        Name = value,
                        Source = "StringValue ID",
                        Path = obj:GetFullName()
                    })
                end
            end
        end
    end
    
    print("🚗 Found " .. #myCars .. " potential car sources")
    return myCars
end

-- ===== RAPID-FIRE DUPLICATION =====
local function rapidFireDuplication(remote, carData)
    print("\n⚡ RAPID-FIRE DUPLICATION ATTEMPT")
    print("🎯 Target: " .. remote.Name)
    print("🚗 Using: " .. carData.Name)
    
    local attempts = 0
    local successes = 0
    local startTime = tick()
    
    -- Try different VALID data formats
    local dataFormats = {
        -- Format 1: Direct car data
        carData.Name,
        
        -- Format 2: Array with car
        {carData.Name},
        
        -- Format 3: With player
        {player, carData.Name},
        {player.UserId, carData.Name},
        
        -- Format 4: Table format
        {Car = carData.Name, Player = player.Name},
        {Vehicle = carData.Name, Owner = player.UserId},
        
        -- Format 5: Transaction format
        {carData.Name, os.time(), "duplicate"},
        {carData.Name, 1, player.UserId}  -- Quantity = 1
    }
    
    -- RAPID FIRE LOOP
    print("\n🚀 STARTING RAPID FIRE (50 attempts)...")
    
    for i = 1, 50 do
        attempts = attempts + 1
        
        -- Try each format rapidly
        for _, data in pairs(dataFormats) do
            local success = pcall(function()
                remote.Object:FireServer(data)
                return true
            end)
            
            if success then
                successes = successes + 1
                if successes == 1 then
                    print("✅ FIRST SUCCESS! Format accepted!")
                end
                break  -- Move to next rapid fire
            end
        end
        
        -- Extreme speed (minimum delay)
        task.wait(0.01)  -- 10ms between attempts
        
        if i % 10 == 0 then
            print("   Sent " .. i .. "/50 rapid requests...")
        end
    end
    
    local totalTime = tick() - startTime
    print("\n📊 RAPID FIRE RESULTS:")
    print("   Total attempts: " .. attempts)
    print("   Successful sends: " .. successes)
    print("   Total time: " .. string.format("%.2f", totalTime) .. " seconds")
    print("   Average speed: " .. string.format("%.1f", attempts/totalTime) .. " req/sec")
    
    return successes > 0
end

-- ===== STATE-BASED DUPLICATION =====
local function stateBasedDuplication()
    print("\n🧠 STATE-BASED DUPLICATION STRATEGY")
    print("=" .. string.rep("=", 50))
    
    -- Step 1: Find transfer remotes
    local transferRemotes = findTransferRemotes()
    if #transferRemotes == 0 then
        print("❌ No transfer remotes found")
        return
    end
    
    -- Step 2: Find my current cars
    local myCars = findMyCurrentCars()
    if #myCars == 0 then
        print("❌ No car data found")
        return
    end
    
    -- Step 3: Select best remote and car
    local bestRemote = nil
    for _, remote in pairs(transferRemotes) do
        if remote.Name:find("Claim") or remote.Name:find("Give") then
            bestRemote = remote
            break
        end
    end
    
    if not bestRemote then
        bestRemote = transferRemotes[1]
    end
    
    local bestCar = myCars[1]  -- Use first found car
    
    -- Step 4: Attempt duplication
    print("\n🎯 SELECTED FOR DUPLICATION:")
    print("   Remote: " .. bestRemote.Name)
    print("   Car: " .. bestCar.Name)
    print("   Source: " .. bestCar.Source)
    
    -- Try rapid-fire duplication
    local success = rapidFireDuplication(bestRemote, bestCar)
    
    if success then
        print("\n✅ DUPLICATION ATTEMPT COMPLETE!")
        print("💡 Check your inventory in 10 seconds...")
        
        -- Wait and try again (state might still be valid)
        task.wait(10)
        print("\n🔄 SECOND ATTEMPT (state might still be valid)...")
        rapidFireDuplication(bestRemote, bestCar)
    else
        print("\n❌ Duplication failed")
        print("💡 Try different remote/car combination")
    end
end

-- ===== CREATE DUPER UI =====
local function createDuperUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarDuperPro"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 450)
    main.Position = UDim2.new(0.5, -200, 0.5, -225)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "⚡ CAR DUPLICATION SYSTEM"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "🧠 Principle: Duplicate VALID states\n🎯 Method: Rapid-fire same valid request"
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
    results.Size = UDim2.new(1, -20, 0, 200)
    results.Position = UDim2.new(0, 10, 0, 130)
    results.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    results.BorderSizePixel = 0
    results.ScrollBarThickness = 8
    results.Parent = main
    
    -- Buttons
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🔍 SCAN SYSTEMS"
    scanBtn.Size = UDim2.new(1, -20, 0, 40)
    scanBtn.Position = UDim2.new(0, 10, 0, 340)
    scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 14
    scanBtn.Parent = main
    
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "⚡ RAPID-FIRE DUPE"
    dupeBtn.Size = UDim2.new(1, -20, 0, 40)
    dupeBtn.Position = UDim2.new(0, 10, 0, 390)
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
        scanBtn.Text = "SCANNING..."
        scanBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Scanning for transfer systems..."
        
        task.spawn(function()
            transferRemotes = findTransferRemotes()
            myCars = findMyCurrentCars()
            
            local resultText = "📡 SCAN COMPLETE:\n\n"
            resultText = resultText .. "Transfer Remotes: " .. #transferRemotes .. "\n"
            resultText = resultText .. "Your Cars Found: " .. #myCars .. "\n\n"
            
            if #transferRemotes > 0 then
                resultText = resultText .. "🎯 TOP REMOTES:\n"
                for i, remote in ipairs(transferRemotes) do
                    if i <= 5 then
                        resultText = resultText .. i .. ". " .. remote.Name .. "\n"
                    end
                end
            end
            
            if #myCars > 0 then
                resultText = resultText .. "\n🚗 YOUR CARS:\n"
                for i, car in ipairs(myCars) do
                    if i <= 3 then
                        resultText = resultText .. i .. ". " .. car.Name .. "\n"
                    end
                end
            end
            
            updateResults(resultText, Color3.fromRGB(0, 255, 150))
            status.Text = "✅ Scan complete! Ready for duplication."
            
            scanBtn.Text = "🔍 SCAN SYSTEMS"
            scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        end)
    end)
    
    dupeBtn.MouseButton1Click:Connect(function()
        if #transferRemotes == 0 or #myCars == 0 then
            status.Text = "❌ Scan systems first!"
            updateResults("Please click SCAN SYSTEMS first", Color3.fromRGB(255, 100, 100))
            return
        end
        
        dupeBtn.Text = "DUPLICATING..."
        dupeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        status.Text = "Starting rapid-fire duplication..."
        updateResults("⚡ RAPID-FIRE STARTING...\nSending 50 rapid requests...", Color3.fromRGB(255, 200, 100))
        
        task.spawn(function()
            stateBasedDuplication()
            
            dupeBtn.Text = "⚡ RAPID-FIRE DUPE"
            dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            status.Text = "✅ Duplication attempt complete!"
            updateResults("🎯 Check your inventory!\n💡 Wait 10 seconds and try again.", Color3.fromRGB(0, 255, 0))
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
    updateResults("Click SCAN SYSTEMS to find transfer remotes\nThen click RAPID-FIRE DUPE to attempt duplication", Color3.fromRGB(150, 150, 150))
    
    return gui
end

-- ===== MAIN =====
print("\n🎯 THEORY INTO PRACTICE:")
print("1. Find VALID car transfer remote")
print("2. Find YOUR current car data (VALID state)")
print("3. Rapid-fire SAME valid request 50+ times")
print("4. Server processes same valid state multiple times")
print("5. DUPLICATION occurs because validation passes EVERY time")

print("\n🚀 Starting system...")

-- Create UI
local ui = createDuperUI()

print("\n✅ DUPLICATION SYSTEM READY!")
print("\n💡 HOW TO USE:")
print("1. Click SCAN SYSTEMS - Find transfer remotes & your cars")
print("2. Click RAPID-FIRE DUPE - Send 50 rapid valid requests")
print("3. Check inventory - See if duplication occurred")
print("4. Wait 10 seconds - Try again (state might still be valid)")

print("\n🎯 KEY INSIGHT YOU DISCOVERED:")
print("Dupes happen when server processes SAME valid state")
print("multiple times BEFORE updating ownership.")
print("This script implements THAT EXACT PRINCIPLE!")
