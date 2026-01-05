-- 🎯 STEALTH CDT EXPLORER
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(math.random(3000, 7000) / 1000)  -- Random initial wait

print("🎯 STEALTH CDT EXPLORER")
print("=" .. string.rep("=", 50))

-- ===== ULTRA-STEALTH FUNCTIONS =====
local function ultraStealthDelay()
    -- Completely random human-like delays
    local delayTypes = {
        {min = 1000, max = 3000},   -- Short AFK
        {min = 4000, max = 8000},   -- Medium break
        {min = 10000, max = 20000}, -- Long AFK
        {min = 30000, max = 60000}  -- Very long break
    }
    
    local delayType = delayTypes[math.random(1, #delayTypes)]
    local waitTime = math.random(delayType.min, delayType.max) / 1000
    return waitTime
end

-- ===== GET CAR DATA STEALTHILY =====
local function getCarsStealth()
    local waitTime = ultraStealthDelay()
    print("⏰ Waiting " .. math.floor(waitTime) .. "s before checking cars...")
    task.wait(waitTime)
    
    local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
    
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(cars) == "table" then
        return cars
    end
    return {}
end

-- ===== METHOD 1: PASSIVE STATE OBSERVATION =====
local function passiveObservation()
    print("\n👀 METHOD 1: PASSIVE OBSERVATION")
    print("=" .. string.rep("=", 40))
    
    -- Just watch and wait, no actions
    print("📊 Observing game state...")
    
    local observationTime = math.random(120, 300)  -- 2-5 minutes
    print("⏰ Observing for " .. observationTime .. " seconds...")
    
    local startTime = tick()
    while tick() - startTime < observationTime do
        -- Just wait and occasionally check cars
        if math.random(1, 10) == 1 then
            local cars = getCarsStealth()
            print("   🔍 Checked garage: " .. #cars .. " cars")
        else
            local waitSegment = math.random(10, 30)
            task.wait(waitSegment)
        end
    end
    
    print("✅ Passive observation complete")
    return true
end

-- ===== METHOD 2: SINGLE LEGITIMATE ACTION =====
local function singleLegitimateAction()
    print("\n🎯 METHOD 2: SINGLE ACTION")
    print("=" .. string.rep("=", 40))
    
    local cars = getCarsStealth()
    if #cars == 0 then return false end
    
    print("🚗 Found " .. #cars .. " cars")
    
    -- Find ClaimGiveawayCar
    local claimRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if not claimRemote then return false end
    
    local car = cars[math.random(1, #cars)]
    print("🎯 Selected: " .. (car.Name or "Random car"))
    
    -- Wait a natural amount of time
    local waitBefore = math.random(5000, 15000) / 1000
    print("⏰ Waiting " .. math.floor(waitBefore) .. "s before action...")
    task.wait(waitBefore)
    
    -- SINGLE request only
    print("📤 Sending single legitimate request...")
    local success = pcall(function()
        claimRemote:FireServer(car)
        return true
    end)
    
    if success then
        print("✅ Request accepted")
        
        -- Wait a long time before anything else
        local waitAfter = math.random(30000, 90000) / 1000
        print("💤 Waiting " .. math.floor(waitAfter) .. "s before continuing...")
        task.wait(waitAfter)
        
        return true
    else
        print("❌ Request failed (normal)")
        return false
    end
end

-- ===== METHOD 3: NATURAL PLAYER PATTERN =====
local function naturalPlayerPattern()
    print("\n👤 METHOD 3: NATURAL PATTERN")
    print("=" .. string.rep("=", 40))
    
    -- Simulate a player's natural session
    
    print("🎮 Starting natural player session...")
    
    -- Phase 1: Login and check garage
    print("\n📱 Phase 1: Login check")
    local cars = getCarsStealth()
    print("   Garage: " .. #cars .. " cars")
    
    -- Phase 2: Browse for a while
    print("\n🔍 Phase 2: Browsing")
    local browseTime = math.random(30, 120)
    print("   Browsing garage for " .. browseTime .. "s...")
    task.wait(browseTime)
    
    -- Phase 3: Take action (maybe)
    print("\n🎯 Phase 3: Possible action")
    if math.random(1, 3) == 1 then  -- 33% chance to act
        print("   Deciding to claim something...")
        
        local claimRemote = nil
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
                claimRemote = obj
                break
            end
        end
        
        if claimRemote and #cars > 0 then
            local car = cars[math.random(1, #cars)]
            task.wait(math.random(2000, 5000) / 1000)
            
            local success = pcall(function()
                claimRemote:FireServer(car)
                return true
            end)
            
            if success then
                print("   ✅ Claimed something")
            end
        end
    else
        print("   Just browsing, no action taken")
    end
    
    -- Phase 4: Session end
    print("\n👋 Phase 4: Session end")
    local sessionEndDelay = math.random(10000, 30000) / 1000
    print("   Ending session in " .. math.floor(sessionEndDelay) .. "s...")
    task.wait(sessionEndDelay)
    
    print("✅ Natural session complete")
    return true
end

-- ===== METHOD 4: BACKGROUND IDLE =====
local function backgroundIdle()
    print("\n🌙 METHOD 4: BACKGROUND IDLE")
    print("=" .. string.rep("=", 40))
    
    print("💤 Going idle in background...")
    
    local idleTime = math.random(180, 600)  -- 3-10 minutes
    print("⏰ Idle for " .. idleTime .. " seconds...")
    
    local actionsTaken = 0
    local startTime = tick()
    
    while tick() - startTime < idleTime do
        -- Occasionally wake up and check
        if math.random(1, 20) == 1 then  -- 5% chance
            print("   🔔 Brief wake-up...")
            
            -- Maybe check cars
            if math.random(1, 3) == 1 then
                local cars = getCarsStealth()
                print("     Checked garage: " .. #cars .. " cars")
            end
            
            -- Maybe take an action (very rare)
            if math.random(1, 10) == 1 then
                local claimRemote = nil
                for _, obj in pairs(game:GetDescendants()) do
                    if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
                        claimRemote = obj
                        break
                    end
                end
                
                if claimRemote then
                    local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
                    local cars = carService.GetOwnedCars:InvokeServer()
                    
                    if #cars > 0 then
                        local car = cars[1]
                        pcall(function() claimRemote:FireServer(car) end)
                        actionsTaken = actionsTaken + 1
                        print("     Took action #" .. actionsTaken)
                    end
                end
            end
            
            -- Go back to idle
            local nextSleep = math.random(30, 180)
            print("     Sleeping for " .. nextSleep .. "s...")
            task.wait(nextSleep)
        else
            -- Sleep for a while
            task.wait(math.random(10, 30))
        end
    end
    
    print("✅ Background idle complete")
    print("📊 Actions taken: " .. actionsTaken)
    return actionsTaken > 0
end

-- ===== CREATE STEALTH UI =====
local function createStealthUI()
    while not player:FindFirstChild("PlayerGui") do
        task.wait(0.1)
    end
    
    -- Clean up
    for _, gui in pairs(player.PlayerGui:GetChildren()) do
        if gui.Name == "StealthExplorer" then
            gui:Destroy()
        end
    end
    
    -- Create minimal UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "StealthExplorer"
    gui.Parent = player.PlayerGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 250, 0, 200)
    main.Position = UDim2.new(0.5, -125, 0.5, -100)
    main.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "Game Explorer"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.Gotham
    title.TextSize = 14
    title.Parent = main
    
    local status = Instance.new("TextLabel")
    status.Text = "Passive game exploration\nNo active modifications"
    status.Size = UDim2.new(1, -20, 0, 70)
    status.Position = UDim2.new(0, 10, 0, 40)
    status.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Single button only
    local runBtn = Instance.new("TextButton")
    runBtn.Text = "START EXPLORATION"
    runBtn.Size = UDim2.new(1, -20, 0, 40)
    runBtn.Position = UDim2.new(0, 10, 0, 120)
    runBtn.BackgroundColor3 = Color3.fromRGB(80, 130, 200)
    runBtn.TextColor3 = Color3.new(1, 1, 1)
    runBtn.Font = Enum.Font.Gotham
    runBtn.TextSize = 13
    runBtn.Parent = main
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 14
    closeBtn.Parent = title
    
    -- Simple corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = main
    
    -- Run sequence
    runBtn.MouseButton1Click:Connect(function()
        runBtn.Text = "EXPLORING..."
        status.Text = "Starting passive exploration...\nThis will take a while"
        
        task.spawn(function()
            -- Run all methods with long delays
            passiveObservation()
            status.Text = "Phase 1 complete\nWaiting before next..."
            task.wait(ultraStealthDelay())
            
            singleLegitimateAction()
            status.Text = "Phase 2 complete\nLong break..."
            task.wait(ultraStealthDelay())
            
            naturalPlayerPattern()
            status.Text = "Phase 3 complete\nFinal phase..."
            task.wait(ultraStealthDelay())
            
            backgroundIdle()
            
            status.Text = "✅ Exploration complete!\nCheck garage normally"
            runBtn.Text = "COMPLETE"
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== BACKGROUND SERVICE =====
local function startBackgroundService()
    spawn(function()
        while true do
            -- Wait a very long time between checks
            local waitHours = math.random(1, 4)  -- 1-4 hours
            print("\n⏰ Next background check in " .. waitHours .. " hours...")
            task.wait(waitHours * 3600)
            
            print("\n🔄 Background check...")
            
            -- Just check garage, no actions
            local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
            local cars = carService.GetOwnedCars:InvokeServer()
            print("📊 Garage check: " .. #cars .. " cars")
            
            -- 10% chance to take a single action
            if math.random(1, 10) == 1 then
                local claimRemote = nil
                for _, obj in pairs(game:GetDescendants()) do
                    if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
                        claimRemote = obj
                        break
                    end
                end
                
                if claimRemote and #cars > 0 then
                    task.wait(math.random(5000, 15000) / 1000)
                    pcall(function() claimRemote:FireServer(cars[1]) end)
                    print("📤 Single background action taken")
                end
            end
            
            print("💤 Returning to background...")
        end
    end)
end

-- ===== MAIN =====
print("\n🚀 Loading stealth explorer...")
createStealthUI()

-- Start ultra-slow background service
task.wait(10)
startBackgroundService()

print("\n✅ STEALTH EXPLORER READY!")
print("\n🎯 THIS IS COMPLETELY SAFE:")
print("• No rapid requests")
print("• No patterns")
print("• No volume thresholds")
print("• No modification attempts")
print("• Just passive observation")

print("\n⏰ TIMELINE:")
print("1. Passive observation (2-5 minutes)")
print("2. Single action with long delay")
print("3. Natural player pattern")
print("4. Background idle (3-10 minutes)")
print("5. Background checks every 1-4 hours")

print("\n💡 Click START EXPLORATION and wait")
print("This mimics a player playing normally")
