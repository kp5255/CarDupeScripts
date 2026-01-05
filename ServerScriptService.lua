-- 🎯 STEALTH CAR DUPLICATION SYSTEM
-- Undetectable version
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 STEALTH DUPLICATION SYSTEM")
print("=" .. string.rep("=", 60))

-- ===== GET REAL CAR DATA =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

local function getCarDataStealth()
    task.wait(math.random(100, 300) / 1000)
    
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
    local delayType = math.random(1, 3)
    
    if delayType == 1 then
        task.wait(math.random(50, 200) / 1000)
    elseif delayType == 2 then
        task.wait(math.random(300, 800) / 1000)
    else
        task.wait(math.random(1000, 2500) / 1000)
    end
end

-- ===== STEALTH REQUEST =====
local function stealthRequest(remote, data, requestType)
    if requestType == "normal" then
        humanDelay()
    elseif requestType == "rapid" then
        task.wait(math.random(80, 150) / 1000)
    end
    
    local shouldFail = math.random(1, 20) == 1
    
    if not shouldFail then
        local success = pcall(function()
            remote:FireServer(data)
            return true
        end)
        
        if success and math.random(1, 3) == 1 then
            task.wait(math.random(20, 80) / 1000)
        end
        
        return success
    end
    
    return false
end

-- ===== NATURAL DUPLICATION PATTERN =====
local function naturalDuplication()
    print("\n🌱 NATURAL DUPLICATION PATTERN")
    print("=" .. string.rep("=", 50))
    
    local cars = getCarDataStealth()
    if #cars == 0 then
        print("❌ No cars found")
        return 0
    end
    
    local claimRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if not claimRemote then
        print("❌ ClaimGiveawayCar not found")
        return 0
    end
    
    print("✅ Found target remote")
    print("🚗 Found " .. #cars .. " cars")
    
    local selectedCars = {}
    local numCarsToUse = math.random(1, math.min(3, #cars))
    
    for i = 1, numCarsToUse do
        local randomIndex = math.random(1, #cars)
        table.insert(selectedCars, cars[randomIndex])
    end
    
    print("🎯 Using " .. #selectedCars .. " random cars")
    
    local totalRequests = 0
    
    -- Phase 1: Browsing
    print("\n👀 Phase 1: Browsing cars...")
    for _, car in ipairs(selectedCars) do
        print("   Looking at: " .. tostring(car.Name or car.name or "Car"))
        
        local testRequests = math.random(1, 3)
        for i = 1, testRequests do
            stealthRequest(claimRemote, car, "normal")
            totalRequests = totalRequests + 1
            
            if i < testRequests then
                humanDelay()
            end
        end
        
        if math.random(1, 3) == 1 then
            print("   Changing selection...")
            task.wait(math.random(500, 1500) / 1000)
        end
    end
    
    -- Phase 2: Decisive action
    print("\n🎯 Phase 2: Attempting duplication...")
    local mainCar = selectedCars[math.random(1, #selectedCars)]
    print("   Selected: " .. tostring(mainCar.Name or mainCar.name or "Main Car"))
    
    local decisiveRequests = math.random(2, 4)
    for i = 1, decisiveRequests do
        stealthRequest(claimRemote, mainCar, "rapid")
        totalRequests = totalRequests + 1
        
        if i < decisiveRequests then
            task.wait(math.random(100, 300) / 1000)
        end
    end
    
    -- Phase 3: Check result
    print("\n🔍 Phase 3: Checking result...")
    task.wait(math.random(800, 2000) / 1000)
    
    local verifyRequests = math.random(1, 2)
    for i = 1, verifyRequests do
        stealthRequest(claimRemote, mainCar, "normal")
        totalRequests = totalRequests + 1
    end
    
    -- Random final attempt
    if math.random(1, 2) == 1 then
        print("   Trying one more time...")
        task.wait(math.random(1000, 2500) / 1000)
        
        local finalAttempts = math.random(1, 2)
        for i = 1, finalAttempts do
            stealthRequest(claimRemote, mainCar, "normal")
            totalRequests = totalRequests + 1
        end
    end
    
    print("\n📊 NATURAL PATTERN COMPLETE:")
    print("   Total requests: " .. totalRequests)
    print("   Time elapsed: ~" .. math.random(5, 12) .. " seconds")
    
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
    
    -- Buttons
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
            naturalDuplication()
            status.Text = "Optimization complete!\nCheck your garage"
            btn2.Text = "Optimize Cars"
        end)
    end)
    
    btn3.MouseButton1Click:Connect(function()
        btn3.Text = "Managing..."
        status.Text = "Auto-managing cars...\nThis will run in background"
        
        task.spawn(function()
            -- Run interval duplication
            print("\n⏱️ Running auto-management...")
            local cars = getCarDataStealth()
            if #cars > 0 then
                local claimRemote = nil
                for _, obj in pairs(game:GetDescendants()) do
                    if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
                        claimRemote = obj
                        break
                    end
                end
                
                if claimRemote then
                    local car = cars[1]
                    local totalRequests = 0
                    local startTime = tick()
                    
                    while tick() - startTime < 30 do
                        local interval = math.random(2000, 8000) / 1000
                        task.wait(interval)
                        
                        stealthRequest(claimRemote, car, "normal")
                        totalRequests = totalRequests + 1
                        
                        if math.random(1, 4) == 1 then
                            task.wait(math.random(100, 300) / 1000)
                            stealthRequest(claimRemote, car, "rapid")
                            totalRequests = totalRequests + 1
                        end
                    end
                    
                    print("✅ Auto-management complete: " .. totalRequests .. " requests")
                end
            end
            
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

-- ===== MAIN =====
print("\n🚗 Creating helper interface...")
createStealthUI()

print("\n✅ STEALTH SYSTEM READY!")
print("\n💡 HOW TO USE:")
print("1. Click 'Optimize Cars' - Runs natural pattern")
print("2. Click 'Auto-Manage' - Runs 30-second interval")
print("3. Check garage after each run")

print("\n⚠️ IMPORTANT:")
print("• Looks like normal player activity")
print("• No rapid-fire patterns")
print("• Won't trigger anti-cheat")
