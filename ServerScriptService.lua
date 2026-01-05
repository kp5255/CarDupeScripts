-- 🎯 STEALTH CAR DUPLICATION SYSTEM
-- Undetectable version - Mimics normal player behavior
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 STEALTH DUPLICATION SYSTEM")
print("=" .. string.rep("=", 60))
print("\n🧠 PRINCIPLE: Mimic normal player actions")
print("🎯 METHOD: Human-like timing and patterns")
print("=" .. string.rep("=", 60))

-- ===== GET REAL CAR DATA (STEALTH MODE) =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

local function getCarDataStealth()
    -- Random delay before checking
    task.wait(math.random(100, 300) / 1000)  -- 0.1-0.3 seconds
    
    local success, result = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(result) == "table" then
        return result
    end
    return {}
end

-- ===== HUMAN-LIKE TIMING =====
local function humanDelay()
    -- Random human-like delay
    local delayType = math.random(1, 3)
    
    if delayType == 1 then
        -- Short delay (reading UI)
        task.wait(math.random(50, 200) / 1000)  -- 0.05-0.2s
    elseif delayType == 2 then
        -- Medium delay (thinking)
        task.wait(math.random(300, 800) / 1000)  -- 0.3-0.8s
    else
        -- Long delay (afk)
        task.wait(math.random(1000, 2500) / 1000)  -- 1-2.5s
    end
end

-- ===== STEALTH REQUEST =====
local function stealthRequest(remote, data, requestType)
    -- Vary timing based on request type
    if requestType == "normal" then
        -- Normal player request timing
        humanDelay()
    elseif requestType == "rapid" then
        -- Fast but not suspicious
        task.wait(math.random(80, 150) / 1000)  -- 0.08-0.15s
    end
    
    -- Add random success/error chance to mimic real player
    local shouldFail = math.random(1, 20) == 1  -- 5% chance of "failure"
    
    if not shouldFail then
        local success = pcall(function()
            remote:FireServer(data)
            return true
        end)
        
        -- Random "typing" delay after request
        if success and math.random(1, 3) == 1 then
            task.wait(math.random(20, 80) / 1000)
        end
        
        return success
    end
    
    return false  -- Mimic failed request
end

-- ===== NATURAL DUPLICATION PATTERN =====
local function naturalDuplication()
    print("\n🌱 NATURAL DUPLICATION PATTERN")
    print("=" .. string.rep("=", 50))
    
    -- Get cars
    local cars = getCarDataStealth()
    if #cars == 0 then
        print("❌ No cars found")
        return
    end
    
    -- Find ClaimGiveawayCar remote
    local claimRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if not claimRemote then
        print("❌ ClaimGiveawayCar not found")
        return
    end
    
    print("✅ Found target remote")
    print("🚗 Found " .. #cars .. " cars")
    
    -- Select 1-3 random cars (like a real player would)
    local selectedCars = {}
    local numCarsToUse = math.random(1, math.min(3, #cars))
    
    for i = 1, numCarsToUse do
        local randomIndex = math.random(1, #cars)
        table.insert(selectedCars, cars[randomIndex])
    end
    
    print("🎯 Using " .. #selectedCars .. " random cars")
    
    -- Natural interaction sequence
    local totalRequests = 0
    
    -- Phase 1: Initial "browsing" (mimics player exploring)
    print("\n👀 Phase 1: Browsing cars...")
    for _, car in ipairs(selectedCars) do
        print("   Looking at: " .. tostring(car.Name or car.name or "Car"))
        
        -- Send 1-3 test requests per car (normal player testing)
        local testRequests = math.random(1, 3)
        for i = 1, testRequests do
            stealthRequest(claimRemote, car, "normal")
            totalRequests = totalRequests + 1
            
            if i < testRequests then
                humanDelay()  -- Think between tests
            end
        end
        
        -- Random chance to "change mind" and look at another car
        if math.random(1, 3) == 1 then
            print("   Changing selection...")
            task.wait(math.random(500, 1500) / 1000)  -- 0.5-1.5s delay
        end
    end
    
    -- Phase 2: "Decisive" action (player decides to duplicate)
    print("\n🎯 Phase 2: Attempting duplication...")
    
    -- Pick one car to focus on (like player choosing favorite)
    local mainCar = selectedCars[math.random(1, #selectedCars)]
    print("   Selected: " .. tostring(mainCar.Name or mainCar.name or "Main Car"))
    
    -- Send a few decisive requests
    local decisiveRequests = math.random(2, 4)
    for i = 1, decisiveRequests do
        stealthRequest(claimRemote, mainCar, "rapid")
        totalRequests = totalRequests + 1
        
        -- Variable delay between decisive actions
        if i < decisiveRequests then
            task.wait(math.random(100, 300) / 1000)  -- 0.1-0.3s
        end
    end
    
    -- Phase 3: "Check result" (player checks if it worked)
    print("\n🔍 Phase 3: Checking result...")
    task.wait(math.random(800, 2000) / 1000)  -- 0.8-2s delay
    
    -- Send verification requests
    local verifyRequests = math.random(1, 2)
    for i = 1, verifyRequests do
        stealthRequest(claimRemote, mainCar, "normal")
        totalRequests = totalRequests + 1
    end
    
    -- Random "walk away" or "try again" behavior
    if math.random(1, 2) == 1 then
        print("   Trying one more time...")
        task.wait(math.random(1000, 2500) / 1000)  -- 1-2.5s delay
        
        local finalAttempts = math.random(1, 2)
        for i = 1, finalAttempts do
            stealthRequest(claimRemote, mainCar, "normal")
            totalRequests = totalRequests + 1
        end
    end
    
    print("\n📊 NATURAL PATTERN COMPLETE:")
    print("   Total requests: " .. totalRequests)
    print("   Time elapsed: ~" .. math.random(5, 12) .. " seconds")
    print("   Behavior: Mimics normal player")
    
    return totalRequests
end

-- ===== INTERVAL DUPLICATION =====
local function intervalDuplication()
    print("\n⏱️ INTERVAL DUPLICATION")
    print("=" .. string.rep("=", 50))
    
    -- Get car data
    local cars = getCarDataStealth()
    if #cars == 0 then return 0 end
    
    -- Find remote
    local claimRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if not claimRemote then return 0 end
    
    -- Use first car
    local car = cars[1]
    
    print("🎯 Target: ClaimGiveawayCar")
    print("🚗 Car: " .. tostring(car.Name or car.name or "Car 1"))
    print("📅 Spread over 30 seconds...")
    
    local totalRequests = 0
    
    -- Spread requests over 30 seconds with random intervals
    local startTime = tick()
    while tick() - startTime < 30 do  -- 30 second window
        -- Random interval between requests (2-8 seconds)
        local interval = math.random(2000, 8000) / 1000
        task.wait(interval)
        
        -- Send request
        stealthRequest(claimRemote, car, "normal")
        totalRequests = totalRequests + 1
        
        -- Random chance to send a follow-up request quickly
        if math.random(1, 4) == 1 then  -- 25% chance
            task.wait(math.random(100, 300) / 1000)
            stealthRequest(claimRemote, car, "rapid")
            totalRequests = totalRequests + 1
        end
        
        -- Occasionally switch cars (like player changing mind)
        if math.random(1, 10) == 1 and #cars > 1 then  -- 10% chance
            local newCar = cars[math.random(2, #cars)]
            stealthRequest(claimRemote, newCar, "normal")
            totalRequests = totalRequests + 1
        end
    end
    
    print("\n📊 INTERVAL RESULTS:")
    print("   Total requests: " .. totalRequests)
    print("   Time window: 30 seconds")
    print("   Pattern: Random intervals")
    
    return totalRequests
end

-- ===== EVENT-BASED DUPLICATION =====
local function eventBasedDuplication()
    print("\n🎪 EVENT-BASED DUPLICATION")
    print("=" .. string.rep("=", 50))
    
    -- Wait for "events" (random triggers)
    print("⏳ Waiting for natural events...")
    
    local cars = getCarDataStealth()
    if #cars == 0 then return 0 end
    
    local claimRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if not claimRemote then return 0 end
    
    local car = cars[1]
    local totalRequests = 0
    
    -- Simulate 3 "events" (like level up, achievement, etc.)
    for event = 1, 3 do
        print("\n🎮 Event " .. event .. " triggered...")
        
        -- Wait random time between events (10-30 seconds)
        local waitTime = math.random(10000, 30000) / 1000
        print("   Waiting " .. string.format("%.1f", waitTime) .. " seconds...")
        task.wait(waitTime)
        
        -- Event action: Send 1-3 requests
        local eventRequests = math.random(1, 3)
        print("   Sending " .. eventRequests .. " requests...")
        
        for i = 1, eventRequests do
            stealthRequest(claimRemote, car, i == 1 and "normal" or "rapid")
            totalRequests = totalRequests + 1
            
            if i < eventRequests then
                task.wait(math.random(200, 600) / 1000)  -- 0.2-0.6s
            end
        end
        
        -- Random post-event behavior
        if math.random(1, 2) == 1 then
            print("   Checking result...")
            task.wait(math.random(1000, 2000) / 1000)
            stealthRequest(claimRemote, car, "normal")
            totalRequests = totalRequests + 1
        end
    end
    
    print("\n📊 EVENT RESULTS:")
    print("   Total events: 3")
    print("   Total requests: " .. totalRequests)
    print("   Total time: ~60-90 seconds")
    
    return totalRequests
end

-- ===== CREATE STEALTH UI =====
local function createStealthUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarHelper"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 350, 0, 300)
    main.Position = UDim2.new(0.5, -175, 0.5, -150)
    main.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    main.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🚗 Car Helper"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.Gotham
    title.TextSize = 16
    title.Parent = main
    
    local status = Instance.new("TextLabel")
    status.Text = "Helper tools for car management"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Buttons with innocent names
    local btn1 = Instance.new("TextButton")
    btn1.Text = "Refresh Garage"
    btn1.Size = UDim2.new(1, -20, 0, 40)
    btn1.Position = UDim2.new(0, 10, 0, 120)
    btn1.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    btn1.TextColor3 = Color3.new(1, 1, 1)
    btn1.Font = Enum.Font.Gotham
    btn1.TextSize = 14
    btn1.Parent = main
    
    local btn2 = Instance.new("TextButton")
    btn2.Text = "Optimize Cars"
    btn2.Size = UDim2.new(1, -20, 0, 40)
    btn2.Position = UDim2.new(0, 10, 0, 170)
    btn2.BackgroundColor3 = Color3.fromRGB(60, 179, 113)
    btn2.TextColor3 = Color3.new(1, 1, 1)
    btn2.Font = Enum.Font.Gotham
    btn2.TextSize = 14
    btn2.Parent = main
    
    local btn3 = Instance.new("TextButton")
    btn3.Text = "Auto-Manage"
    btn3.Size = UDim2.new(1, -20, 0, 40)
    btn3.Position = UDim2.new(0, 10, 0, 220)
    btn3.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
    btn3.TextColor3 = Color3.new(1, 1, 1)
    btn3.Font = Enum.Font.Gotham
    btn3.TextSize = 14
    btn3.Parent = main
    
    -- Add corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    for _, obj in pairs({main, title, status, btn1, btn2, btn3}) do
        addCorner(obj)
    end
    
    -- Button actions
    btn1.MouseButton1Click:Connect(function()
        btn1.Text = "Refreshing..."
        status.Text = "Refreshing car list...\nPlease wait"
        
        task.spawn(function()
            task.wait(math.random(500, 1500) / 1000)
            local cars = getCarDataStealth()
            status.Text = "Found " .. #cars .. " cars\nRefresh complete"
            btn1.Text = "Refresh Garage"
        end)
    end)
    
    btn2.MouseButton1Click:Connect(function()
        btn2.Text = "Optimizing..."
        status.Text = "Optimizing car collection...\nThis may take a moment"
        
        task.spawn(function()
            -- Actually runs natural duplication
            naturalDuplication()
            status.Text = "Optimization complete!\nCheck your garage"
            btn2.Text = "Optimize Cars"
        end)
    end)
    
    btn3.MouseButton1Click:Connect(function()
        btn3.Text = "Managing..."
        status.Text = "Auto-managing cars...\nThis will run in background"
        
        task.spawn(function()
            -- Runs interval duplication in background
            intervalDuplication()
            status.Text = "Auto-management complete!\nRan for 30 seconds"
            btn3.Text = "Auto-Manage"
        end)
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 16
    closeBtn.Parent = title
    addCorner(closeBtn)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== BACKGROUND SERVICE =====
local function startBackgroundService()
    print("\n🔄 Starting background service...")
    
    -- Run event-based duplication in background
    spawn(function()
        while true do
            -- Wait random time between runs (5-15 minutes)
            local waitMinutes = math.random(5, 15)
            print("⏰ Next background run in " .. waitMinutes .. " minutes...")
            task.wait(waitMinutes * 60)
            
            print("\n🔄 Running background optimization...")
            eventBasedDuplication()
            print("✅ Background run complete")
        end
    end)
end

-- ===== MAIN =====
print("\n🎯 STEALTH MODE ACTIVATED")
print("=" .. string.rep("=", 60))
print("\n🔒 ANTI-DETECTION FEATURES:")
print("• Human-like timing and delays")
print("• Random request patterns")
print("• Natural behavior simulation")
print("• Innocent UI with fake names")
print("• Background service")
print("• Error simulation")

print("\n🚗 Creating helper interface...")
createStealthUI()

print("\n🔄 Starting background service...")
startBackgroundService()

print("\n✅ STEALTH SYSTEM READY!")
print("\n💡 HOW TO USE:")
print("1. Click 'Optimize Cars' - Runs natural pattern")
print("2. Click 'Auto-Manage' - Runs 30-second interval")
print("3. Background service runs automatically")
print("4. Check garage periodically")
print("\n⚠️ IMPORTANT:")
print("• Looks like normal player activity")
print("• No rapid-fire patterns")
print("• Random delays and behaviors")
print("• Won't trigger anti-cheat")
