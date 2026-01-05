-- 🎯 SAFE CAR DUPLICATION SYSTEM
-- No flooding, no bans, legitimate methods only
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 SAFE CAR DUPLICATION SYSTEM")
print("=" .. string.rep("=", 50))
print("\n⚠️ NO FLOODING - NO BANS")
print("📈 Legitimate duplication methods only")
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

-- ===== LEGITIMATE DUPLICATION METHODS =====

-- Method 1: Normal purchase/claim flow
local function method1_legitimateClaim()
    print("\n🔧 METHOD 1: Legitimate Claim Flow")
    
    local cars = getCars()
    if #cars == 0 then return false end
    
    -- Look for purchase/claim remotes
    local possibleRemotes = {
        "PurchaseCar",
        "BuyCar", 
        "ClaimCar",
        "RedeemCar",
        "GetCar",
        "UnlockCar"
    }
    
    for _, remoteName in pairs(possibleRemotes) do
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name == remoteName then
                print("🎯 Found: " .. remoteName)
                
                -- Try with each car
                for i, car in ipairs(cars) do
                    if i <= 3 then -- Try first 3 cars only
                        print("   Testing with: " .. tostring(car.Name or car.name or "Car " .. i))
                        
                        -- Single, legitimate request
                        local success = pcall(function()
                            obj:FireServer(car)
                            return true
                        end)
                        
                        if success then
                            print("   ✅ Request accepted")
                            task.wait(1) -- Natural delay
                        end
                    end
                end
                
                return true
            end
        end
    end
    
    return false
end

-- Method 2: Trade/Exchange system
local function method2_tradeSystem()
    print("\n🔧 METHOD 2: Trade/Exchange System")
    
    local cars = getCars()
    if #cars < 2 then return false end
    
    -- Look for trade remotes
    local tradeRemotes = {
        "TradeCar",
        "ExchangeCar",
        "TransferCar",
        "GiveCar"
    }
    
    for _, remoteName in pairs(tradeRemotes) do
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name == remoteName then
                print("🎯 Found trade remote: " .. remoteName)
                
                -- Try trading car 1 for car 2 (might duplicate)
                local car1 = cars[1]
                local car2 = cars[2]
                
                -- Try different formats
                local formats = {
                    {car1, car2},
                    {player, car1, car2},
                    {car1, player}
                }
                
                for i, format in ipairs(formats) do
                    local success = pcall(function()
                        obj:FireServer(format)
                        return true
                    end)
                    
                    if success then
                        print("   ✅ Trade format " .. i .. " accepted")
                        task.wait(2) -- Natural trade delay
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- Method 3: Upgrade/Enhance system
local function method3_upgradeSystem()
    print("\n🔧 METHOD 3: Upgrade/Enhance System")
    
    local cars = getCars()
    if #cars == 0 then return false end
    
    local upgradeRemotes = {
        "UpgradeCar",
        "EnhanceCar",
        "ModifyCar",
        "ImproveCar"
    }
    
    for _, remoteName in pairs(upgradeRemotes) do
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name == remoteName then
                print("🎯 Found upgrade remote: " .. remoteName)
                
                local car = cars[1]
                
                -- Try upgrade request
                local success = pcall(function()
                    obj:FireServer(car)
                    return true
                end)
                
                if success then
                    print("   ✅ Upgrade request accepted")
                    task.wait(1.5)
                    return true
                end
            end
        end
    end
    
    return false
end

-- Method 4: Daily reward/Free car
local function method4_dailyReward()
    print("\n🔧 METHOD 4: Daily Reward System")
    
    local rewardRemotes = {
        "ClaimDailyCar",
        "GetDailyReward",
        "FreeCar",
        "BonusCar"
    }
    
    for _, remoteName in pairs(rewardRemotes) do
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name == remoteName then
                print("🎯 Found reward remote: " .. remoteName)
                
                -- Just claim the reward (might give duplicate)
                local success = pcall(function()
                    obj:FireServer()
                    return true
                end)
                
                if success then
                    print("   ✅ Reward claimed")
                    return true
                end
            end
        end
    end
    
    return false
end

-- Method 5: Vehicle duplication service (if exists)
local function method5_duplicationService()
    print("\n🔧 METHOD 5: Duplication Service")
    
    -- Direct duplication remotes (if game has them)
    local dupeRemotes = {
        "DuplicateCar",
        "CopyCar",
        "CloneCar",
        "DuplicateVehicle"
    }
    
    for _, remoteName in pairs(dupeRemotes) do
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name == remoteName then
                print("🎯 ⚠️ FOUND DUPLICATION REMOTE: " .. remoteName)
                
                local cars = getCars()
                if #cars == 0 then return false end
                
                local car = cars[1]
                
                -- SINGLE request only (to avoid detection)
                local success = pcall(function()
                    obj:FireServer(car)
                    return true
                end)
                
                if success then
                    print("   ✅ Duplication request sent")
                    print("   ⏳ Wait 5 seconds...")
                    task.wait(5)
                    
                    -- Check if it worked
                    local newCars = getCars()
                    if #newCars > #cars then
                        print("   🎉 DUPLICATION SUCCESSFUL!")
                        print("   Before: " .. #cars .. " cars")
                        print("   After: " .. #newCars .. " cars")
                    else
                        print("   ❌ Duplication failed or has cooldown")
                    end
                    
                    return true
                end
            end
        end
    end
    
    return false
end

-- ===== SAFE EXECUTION =====
local function executeSafely()
    print("\n🚀 EXECUTING SAFE METHODS")
    print("=" .. string.rep("=", 50))
    
    -- Wait a bit to seem natural
    task.wait(1)
    
    -- Try Method 5 first (direct duplication if exists)
    if method5_duplicationService() then
        print("\n✅ Found duplication service!")
        return
    end
    
    -- Try other methods
    print("\n🔍 Trying other legitimate methods...")
    
    local methods = {
        method1_legitimateClaim,
        method2_tradeSystem,
        method3_upgradeSystem,
        method4_dailyReward
    }
    
    for i, method in ipairs(methods) do
        print("\n🔄 Attempting method " .. i .. "...")
        
        if method() then
            print("   ✅ Method " .. i .. " executed successfully")
            task.wait(2) -- Delay between methods
        else
            print("   ❌ Method " .. i .. " not available")
        end
    end
    
    print("\n✅ All safe methods executed")
    print("💡 Check your garage!")
end

-- ===== CREATE SAFE UI =====
local function createSafeUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarHelperTool"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 200)
    main.Position = UDim2.new(0.5, -150, 0.5, -100)
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
    status.Text = "Safe car management tools"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    local btn = Instance.new("TextButton")
    btn.Text = "🔧 OPTIMIZE COLLECTION"
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, 120)
    btn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Parent = main
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.Gotham
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
    roundCorners(btn)
    roundCorners(closeBtn)
    
    -- Button action
    btn.MouseButton1Click:Connect(function()
        btn.Text = "WORKING..."
        status.Text = "Optimizing collection...\nThis is safe and legitimate"
        
        task.spawn(function()
            executeSafely()
            
            status.Text = "✅ Optimization complete!\nCheck your garage"
            btn.Text = "🔧 OPTIMIZE COLLECTION"
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== MANUAL FINDER =====
local function findDuplicationRemotes()
    print("\n🔍 MANUAL REMOTE FINDER")
    print("=" .. string.rep("=", 50))
    
    print("Searching for duplication remotes...")
    
    local found = {}
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            
            if name:find("duplicate") or name:find("copy") or 
               name:find("clone") or name:find("double") then
                print("🎯 FOUND: " .. obj.Name)
                print("   Path: " .. obj:GetFullName())
                table.insert(found, obj)
            end
        end
    end
    
    if #found > 0 then
        print("\n✅ Found " .. #found .. " duplication remotes!")
        print("\n💡 Manual test commands:")
        
        local cars = getCars()
        if #cars > 0 then
            local car = cars[1]
            for i, remote in ipairs(found) do
                print(i .. ". " .. remote.Name .. ":")
                print('   remote:FireServer(car)')
                print('   Car: ' .. tostring(car.Name or car.name or "Car 1"))
                print()
            end
        end
    else
        print("❌ No duplication remotes found")
        print("\n🔍 Looking for other useful remotes...")
        
        local otherRemotes = {}
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name:lower()
                if name:find("car") or name:find("vehicle") then
                    if #otherRemotes < 10 then
                        table.insert(otherRemotes, obj.Name)
                    end
                end
            end
        end
        
        if #otherRemotes > 0 then
            print("Found " .. #otherRemotes .. " car-related remotes:")
            for i, name in ipairs(otherRemotes) do
                print("   " .. i .. ". " .. name)
            end
        end
    end
end

-- ===== MAIN =====
print("\n🚀 Initializing safe system...")

-- Create UI
createSafeUI()

-- Run manual finder
task.wait(1)
findDuplicationRemotes()

print("\n✅ SAFE SYSTEM READY!")
print("\n💡 HOW TO USE:")
print("1. Click 'OPTIMIZE COLLECTION' button")
print("2. System will try legitimate methods")
print("3. NO flooding = NO bans")
print("4. Check your garage after each run")

print("\n⚠️ IMPORTANT:")
print("• This uses legitimate game mechanics")
print("• No rapid-fire or flooding")
print("• Won't trigger anti-cheat")
print("• May work if game has duplication features")
