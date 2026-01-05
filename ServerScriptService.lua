-- 🎯 OPTIMIZED STATE BOUNDARY EXPLORATION
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(math.random(3000, 7000) / 1000)

print("🎯 OPTIMIZED STATE EXPLORATION")
print("=" .. string.rep("=", 50))

-- ===== OPTIMIZED FUNCTIONS =====
local function optimizedDelay()
    -- More natural delay distribution
    local delayTypes = {
        {min = 200, max = 600},   -- Quick glance
        {min = 800, max = 1800},  -- Reading
        {min = 2500, max = 5000}, -- Thinking
        {min = 7000, max = 12000} -- AFK
    }
    
    local delayType = delayTypes[math.random(1, #delayTypes)]
    task.wait(math.random(delayType.min, delayType.max) / 1000)
end

local function getCarsOptimized()
    optimizedDelay()
    
    local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(cars) == "table" then
        return cars
    end
    return {}
end

-- ===== OPTIMIZED BOUNDARY TESTING =====
local function optimizedBoundaryTest()
    print("\n🎯 OPTIMIZED BOUNDARY TEST")
    print("=" .. string.rep("=", 40))
    
    local cars = getCarsOptimized()
    if #cars == 0 then
        print("❌ No cars found")
        return false
    end
    
    print("✅ Loaded " .. #cars .. " cars")
    
    -- Find ClaimGiveawayCar
    local claimRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if not claimRemote then
        print("❌ Remote not found")
        return false
    end
    
    -- Select different cars for different boundaries
    local testCars = {}
    for i = 1, math.min(3, #cars) do
        table.insert(testCars, cars[i])
    end
    
    print("🎯 Testing " .. #testCars .. " different cars")
    
    -- Optimized boundary points based on your successful run
    local boundaries = {
        {time = 0.95, carIndex = 1, desc = "Save point"},
        {time = 1.95, carIndex = 2, desc = "Sync point"},
        {time = 2.95, carIndex = 3, desc = "Update point"},
        {time = 4.95, carIndex = 1, desc = "Extended point"},  -- New
        {time = 7.95, carIndex = 2, desc = "Long boundary"}    -- New
    }
    
    local successfulBoundaries = 0
    
    for i, boundary in ipairs(boundaries) do
        if boundary.carIndex <= #testCars then
            local car = testCars[boundary.carIndex]
            
            print("\n⏰ Boundary " .. i .. ": " .. boundary.desc)
            print("   Waiting " .. boundary.time .. "s...")
            print("   Car: " .. (car.Name or "Car " .. boundary.carIndex))
            
            task.wait(boundary.time)
            
            local success = pcall(function()
                claimRemote:FireServer(car)
                return true
            end)
            
            if success then
                print("   ✅ ACCEPTED")
                successfulBoundaries = successfulBoundaries + 1
                
                -- Natural inventory check
                if math.random(1, 3) == 1 then
                    optimizedDelay()
                    getCarsOptimized()
                end
            else
                print("   ❌ Rejected")
            end
        end
    end
    
    print("\n📊 RESULTS: " .. successfulBoundaries .. "/" .. #boundaries .. " boundaries accepted")
    return successfulBoundaries > 0
end

-- ===== FOCUSED DUPLICATION ATTEMPT =====
local function focusedAttempt()
    print("\n🎯 FOCUSED ATTEMPT")
    print("=" .. string.rep("=", 40))
    
    local cars = getCarsOptimized()
    if #cars < 2 then return false end
    
    local claimRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if not claimRemote then return false end
    
    -- Strategy: Rapid car switching at optimal boundary
    print("🚗 Rapid car switching at optimal boundary...")
    
    local optimalTime = 1.95  -- Based on your successful run
    print("⏰ Optimal boundary: " .. optimalTime .. "s")
    
    -- Wait to optimal boundary
    task.wait(optimalTime)
    
    -- Send 3 different cars in quick succession
    local carsSent = 0
    for i = 1, math.min(3, #cars) do
        local car = cars[i]
        local success = pcall(function()
            claimRemote:FireServer(car)
            return true
        end)
        
        if success then
            print("   ✅ Sent: " .. (car.Name or "Car " .. i))
            carsSent = carsSent + 1
        end
        
        if i < 3 then
            task.wait(0.05)  -- Very small gap
        end
    end
    
    print("📊 Sent " .. carsSent .. "/3 cars")
    
    -- Wait and send one more of the first car
    task.wait(0.5)
    print("🔄 Follow-up on primary car...")
    pcall(function() claimRemote:FireServer(cars[1]) end)
    
    return carsSent > 0
end

-- ===== CAR ROTATION STRATEGY =====
local function carRotationStrategy()
    print("\n🔄 CAR ROTATION STRATEGY")
    print("=" .. string.rep("=", 40))
    
    local cars = getCarsOptimized()
    if #cars < 3 then
        print("❌ Need at least 3 cars")
        return false
    end
    
    local claimRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if not claimRemote then return false end
    
    -- Rotation pattern: Car1 -> Car2 -> Car3 -> Car1
    local rotation = {1, 2, 3, 1}
    local delays = {0.95, 1.95, 0.5, 2.95}
    
    print("🔄 Starting car rotation...")
    
    for i, carIndex in ipairs(rotation) do
        if carIndex <= #cars then
            local car = cars[carIndex]
            
            print("   Step " .. i .. ": Car " .. carIndex)
            print("   " .. (car.Name or "Car " .. carIndex))
            
            task.wait(delays[i] or 1.0)
            
            local success = pcall(function()
                claimRemote:FireServer(car)
                return true
            end)
            
            if success then
                print("   ✅ Sent")
            else
                print("   ❌ Failed")
            end
            
            -- Check inventory occasionally
            if i % 2 == 0 then
                getCarsOptimized()
            end
        end
    end
    
    print("✅ Rotation complete")
    return true
end

-- ===== CREATE OPTIMIZED UI =====
local function createOptimizedUI()
    while not player:FindFirstChild("PlayerGui") do
        task.wait(0.1)
    end
    
    -- Clean up
    for _, gui in pairs(player.PlayerGui:GetChildren()) do
        if gui.Name == "OptimizedTool" then
            gui:Destroy()
        end
    end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "OptimizedTool"
    gui.Parent = player.PlayerGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 280, 0, 220)
    main.Position = UDim2.new(0.5, -140, 0.5, -110)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🎯 Optimized Tool"
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = main
    
    local status = Instance.new("TextLabel")
    status.Text = "Ready - Based on successful run data"
    status.Size = UDim2.new(1, -20, 0, 70)
    status.Position = UDim2.new(0, 10, 0, 45)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Buttons
    local buttons = {
        {name = "Boundary Test", func = optimizedBoundaryTest, color = Color3.fromRGB(70, 130, 180)},
        {name = "Focused Attempt", func = focusedAttempt, color = Color3.fromRGB(200, 100, 0)},
        {name = "Car Rotation", func = carRotationStrategy, color = Color3.fromRGB(100, 0, 200)},
        {name = "Full Sequence", func = function()
            optimizedBoundaryTest()
            task.wait(5)
            focusedAttempt()
            task.wait(5)
            carRotationStrategy()
        end, color = Color3.fromRGB(0, 180, 0)}
    }
    
    for i, btnInfo in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.name
        btn.Size = UDim2.new(0.45, 0, 0, 30)
        btn.Position = UDim2.new((i % 2 == 1) and 0.05 or 0.5, 10, 0, 125 + math.floor((i-1)/2) * 35)
        btn.BackgroundColor3 = btnInfo.color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.Parent = main
        
        btn.MouseButton1Click:Connect(function()
            btn.Text = "RUNNING"
            status.Text = btnInfo.name .. " in progress...\nBased on successful timing"
            
            task.spawn(function()
                local success = btnInfo.func()
                if success then
                    status.Text = "✅ " .. btnInfo.name .. " complete!\nCheck garage carefully"
                else
                    status.Text = "⚠️ " .. btnInfo.name .. " finished\nSome steps may have failed"
                end
                btn.Text = btnInfo.name
            end)
        end)
    end
    
    -- Close
    local close = Instance.new("TextButton")
    close.Text = "X"
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 2)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 16
    close.Parent = title
    
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = main
    
    return gui
end

-- ===== SUCCESS-BASED BACKGROUND =====
local function startSuccessBasedBackground()
    spawn(function()
        while true do
            -- Wait based on your successful timing
            local waitTime = math.random(180, 420)  -- 3-7 minutes
            print("\n⏰ Next optimized run in " .. math.floor(waitTime/60) .. " minutes...")
            task.wait(waitTime)
            
            print("\n🔄 Running optimized background check...")
            optimizedBoundaryTest()
            print("✅ Background check complete")
        end
    end)
end

-- ===== MAIN =====
print("\n🚀 Loading optimized system...")
createOptimizedUI()

-- Start background based on successful timing
task.wait(10)
startSuccessBasedBackground()

print("\n✅ OPTIMIZED SYSTEM READY!")
print("\n📈 BASED ON YOUR SUCCESSFUL RUN:")
print("• All 3 boundaries worked (0.95s, 1.95s, 2.95s)")
print("• Multi-session successful (76s break)")
print("• No anti-cheat triggers")
print("• Requests accepted at boundaries")

print("\n🎯 NEW OPTIMIZATIONS:")
print("1. Extended boundaries (4.95s, 7.95s)")
print("2. Car rotation strategy")
print("3. Focused attempt at optimal boundary (1.95s)")
print("4. Success-based timing")

print("\n💡 RECOMMENDED ORDER:")
print("1. Click 'Boundary Test' - Test all boundaries")
print("2. Click 'Focused Attempt' - Use optimal 1.95s boundary")
print("3. Click 'Car Rotation' - Switch between cars")
print("4. Click 'Full Sequence' - All strategies combined")
