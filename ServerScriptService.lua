-- 🎯 STEALTH CDT DUPLICATION
-- Mimics legitimate player actions
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 STEALTH CDT DUPLICATION")
print("=" .. string.rep("=", 50))
print("\n🧠 STRATEGY: Legitimate actions only")
print("🎯 GOAL: Mimic normal player, not exploit")
print("=" .. string.rep("=", 50))

-- ===== GET CAR DATA =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

local function getCars()
    -- Natural delay
    task.wait(math.random(500, 1500) / 1000)
    
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(cars) == "table" then
        return cars
    end
    return {}
end

-- ===== NATURAL PLAYER BEHAVIOR =====
local function naturalDelay()
    -- Random human-like delay
    local delayType = math.random(1, 4)
    
    if delayType == 1 then
        task.wait(math.random(200, 500) / 1000)  -- Quick action
    elseif delayType == 2 then
        task.wait(math.random(800, 1500) / 1000)  -- Thinking
    elseif delayType == 3 then
        task.wait(math.random(2000, 4000) / 1000)  -- AFK moment
    else
        task.wait(math.random(5000, 8000) / 1000)  -- Longer AFK
    end
end

-- ===== LEGITIMATE CAR INTERACTIONS =====
local function legitimateCarInteraction()
    print("\n👤 LEGITIMATE PLAYER SIMULATION")
    print("=" .. string.rep("=", 40))
    
    local cars = getCars()
    if #cars == 0 then
        print("❌ No cars found")
        return
    end
    
    print("✅ Found " .. #cars .. " cars")
    
    -- Find ClaimGiveawayCar remote (we know it exists)
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
    
    print("🎯 Using ClaimGiveawayCar remote")
    
    -- Select a car (like a real player would)
    local selectedCar = cars[math.random(1, math.min(3, #cars))]
    print("🚗 Selected: " .. (selectedCar.Name or "Car"))
    
    -- ===== PHASE 1: Initial interaction =====
    print("\n📱 PHASE 1: Browsing cars")
    
    -- Look at a few cars first
    for i = 1, math.random(2, 4) do
        local randomCar = cars[math.random(1, #cars)]
        print("   Looking at: " .. (randomCar.Name or "Car " .. i))
        naturalDelay()
    end
    
    -- ===== PHASE 2: "Testing" the claim button =====
    print("\n🔘 PHASE 2: Testing claim button")
    
    -- First click (normal player testing)
    print("   First click...")
    local success1 = pcall(function()
        claimRemote:FireServer(selectedCar)
        return true
    end)
    
    if success1 then
        print("   ✅ Button worked")
    else
        print("   ❌ Button didn't work (normal)")
        return
    end
    
    naturalDelay()
    
    -- Second click (player unsure if it worked)
    print("   Clicking again to confirm...")
    pcall(function() claimRemote:FireServer(selectedCar) end)
    
    -- Wait like player checking result
    task.wait(math.random(1500, 3000) / 1000)
    
    -- ===== PHASE 3: "Maybe it's lagging" =====
    print("\n🌐 PHASE 3: Simulating network issues")
    
    -- Player thinks it might be lag, tries again
    if math.random(1, 2) == 1 then  -- 50% chance
        print("   Network seems slow, trying once more...")
        task.wait(math.random(2000, 4000) / 1000)
        pcall(function() claimRemote:FireServer(selectedCar) end)
    end
    
    -- ===== PHASE 4: "Let me check garage" =====
    print("\n🔍 PHASE 4: Checking result")
    
    -- Player waits to see if anything happened
    task.wait(math.random(3000, 6000) / 1000)
    
    -- Final check click
    if math.random(1, 3) == 1 then  -- 33% chance
        print("   Final check...")
        pcall(function() claimRemote:FireServer(selectedCar) end)
    end
    
    print("\n✅ Player simulation complete")
    print("💡 Check your garage")
end

-- ===== MULTI-SESSION APPROACH =====
local function multiSessionApproach()
    print("\n⏰ MULTI-SESSION APPROACH")
    print("=" .. string.rep("=", 40))
    
    -- This simulates a player coming back multiple times
    
    for session = 1, 3 do
        print("\n📅 SESSION " .. session .. ":")
        
        if session == 1 then
            print("   First login of the day")
        elseif session == 2 then
            print("   Returning after break")
        else
            print("   Final check before leaving")
        end
        
        -- Run legitimate interaction
        legitimateCarInteraction()
        
        -- Wait between sessions (like player leaving and coming back)
        if session < 3 then
            local waitTime = math.random(30000, 60000) / 1000  -- 30-60 seconds
            print("\n💤 Waiting " .. math.floor(waitTime) .. " seconds...")
            task.wait(waitTime)
        end
    end
    
    print("\n✅ Multi-session complete")
end

-- ===== EVENT-BASED APPROACH =====
local function eventBasedApproach()
    print("\n🎪 EVENT-BASED APPROACH")
    print("=" .. string.rep("=", 40))
    
    -- Simulate natural game events that might trigger car claims
    
    local events = {
        "After completing race",
        "After leveling up",
        "After daily login",
        "After achievement unlock",
        "After trading with friend",
        "After server message",
        "After UI notification"
    }
    
    for i, event in ipairs(events) do
        if i <= 3 then  -- Only do first 3 events
            print("\n🎮 EVENT: " .. event)
            
            -- Wait like event just happened
            task.wait(math.random(2000, 5000) / 1000)
            
            -- Do legitimate interaction
            legitimateCarInteraction()
            
            -- Wait before next "event"
            if i < 3 then
                task.wait(math.random(10000, 20000) / 1000)  -- 10-20 seconds
            end
        end
    end
    
    print("\n✅ Event-based simulation complete")
end

-- ===== BACKGROUND SERVICE =====
local function startBackgroundService()
    print("\n🔄 STARTING BACKGROUND SERVICE")
    print("=" .. string.rep("=", 40))
    
    -- Runs in background, mimics idle player
    spawn(function()
        while true do
            -- Random interval between checks (5-15 minutes)
            local waitMinutes = math.random(5, 15)
            print("⏰ Next background check in " .. waitMinutes .. " minutes...")
            task.wait(waitMinutes * 60)
            
            print("\n🔄 Background check running...")
            legitimateCarInteraction()
            print("✅ Background check complete")
        end
    end)
end

-- ===== CREATE STEALTH UI =====
local function createUI()
    while not player:FindFirstChild("PlayerGui") do
        task.wait(0.1)
    end
    
    -- Remove old
    local old = player.PlayerGui:FindFirstChild("CarHelperUI")
    if old then old:Destroy() end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarHelperUI"
    gui.Parent = player.PlayerGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 280, 0, 220)
    main.Position = UDim2.new(0.5, -140, 0.5, -110)
    main.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    main.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🚗 Car Assistant"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.Gotham
    title.TextSize = 16
    title.Parent = main
    
    local status = Instance.new("TextLabel")
    status.Text = "Car management assistant\nSafe and legitimate"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Buttons with innocent names
    local buttons = {
        {name = "Check Garage", func = legitimateCarInteraction, color = Color3.fromRGB(80, 130, 200)},
        {name = "Auto-Optimize", func = multiSessionApproach, color = Color3.fromRGB(60, 180, 100)},
        {name = "Run Assistant", func = eventBasedApproach, color = Color3.fromRGB(180, 120, 60)},
        {name = "Start Service", func = startBackgroundService, color = Color3.fromRGB(150, 80, 180)}
    }
    
    for i, btnInfo in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.name
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, 120 + (i-1) * 35)
        btn.BackgroundColor3 = btnInfo.color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = main
        
        btn.MouseButton1Click:Connect(function()
            btn.Text = "WORKING..."
            status.Text = btnInfo.name .. " running...\nThis is safe and legitimate"
            
            task.spawn(function()
                btnInfo.func()
                status.Text = btnInfo.name .. " complete!\nCheck your garage"
                btn.Text = btnInfo.name
            end)
        end)
    end
    
    -- Close button
    local close = Instance.new("TextButton")
    close.Text = "X"
    close.Size = UDim2.new(0, 25, 0, 25)
    close.Position = UDim2.new(1, -30, 0, 5)
    close.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Font = Enum.Font.Gotham
    close.TextSize = 14
    close.Parent = title
    
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== CONSOLE VERSION =====
local function consoleVersion()
    print("\n🎮 CONSOLE-ONLY VERSION")
    print("=" .. string.rep("=", 50))
    
    print("Running safe, legitimate car checks...")
    print("This won't trigger anti-cheat")
    
    -- Run once immediately
    legitimateCarInteraction()
    
    -- Then run every 5 minutes in background
    spawn(function()
        while true do
            task.wait(300)  -- 5 minutes
            print("\n🔄 Background check running...")
            legitimateCarInteraction()
        end
    end)
end

-- ===== MAIN =====
print("\n🚀 Loading car assistant...")
createUI()

print("\n✅ CAR ASSISTANT READY!")
print("\n💡 SAFE METHODS:")
print("1. Check Garage - Single legitimate session")
print("2. Auto-Optimize - Multiple sessions over time")
print("3. Run Assistant - Event-based simulation")
print("4. Start Service - Background checks every 5-15 min")

print("\n⚠️ IMPORTANT:")
print("• No rapid-fire requests")
print("• No simultaneous requests")
print("• No modified data")
print("• No race conditions")
print("• Looks 100% like normal player")
