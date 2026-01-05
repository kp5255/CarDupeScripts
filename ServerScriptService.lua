-- 🎮 FIXED PLAYER CUSTOMIZATION UNLOCK SIMULATOR
-- With proper error handling

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🎮 PLAYER CUSTOMIZATION UNLOCK PROCESS SIMULATOR")
print("=" .. string.rep("=", 60))

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== GET PLAYER'S CARS (WITH ERROR HANDLING) =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
local function getPlayerCars()
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(cars) == "table" then
        print("✅ Found " .. #cars .. " cars")
        return cars
    else
        print("⚠️ Could not load cars: " .. tostring(cars))
        return {}
    end
end

-- ===== SIMULATE PLAYER STATS =====
local function simulatePlayerStats()
    return {
        Level = 15,
        Cash = 25000,
        Reputation = 5000,
        PlayTime = "40 hours",
        CarsOwned = 52
    }
end

-- ===== SIMPLE CONSOLE VERSION =====
local function simpleConsoleSimulator()
    print("\n🎮 SIMPLE CONSOLE SIMULATOR")
    print("=" .. string.rep("=", 50))
    
    -- Get player stats
    local stats = simulatePlayerStats()
    print("\n👤 PLAYER STATS:")
    print("   Level: " .. stats.Level)
    print("   Cash: $" .. stats.Cash)
    print("   Reputation: " .. stats.Reputation)
    print("   Cars Owned: " .. stats.CarsOwned)
    
    -- Get cars
    local cars = getPlayerCars()
    
    if #cars == 0 then
        print("\n❌ No cars found for simulation")
        return
    end
    
    print("\n🚗 SELECT A CAR TO CUSTOMIZE:")
    for i = 1, math.min(10, #cars) do
        local car = cars[i]
        local carName = car.Name or "Car " .. i
        local customizationCount = 0
        
        if car.Data and type(car.Data) == "table" then
            for _ in pairs(car.Data) do
                customizationCount = customizationCount + 1
            end
        end
        
        print(string.format("%2d. %-20s (Customizations: %d)", i, carName, customizationCount))
    end
    
    if #cars > 10 then
        print("   ... and " .. (#cars - 10) .. " more cars")
    end
    
    -- Available customizations
    print("\n🎨 AVAILABLE CUSTOMIZATIONS TO UNLOCK:")
    
    local customizations = {
        {"Engine Upgrade", "Performance", 5000, 10},
        {"Turbo Charger", "Performance", 8000, 12},
        {"Sport Brakes", "Performance", 3000, 8},
        {"Racing Rims", "Visual", 4000, 9},
        {"Body Kit", "Visual", 12000, 15},
        {"Custom Paint", "Visual", 6000, 11},
        {"Neon Underglow", "Effects", 3500, 7},
        {"Tire Smoke", "Effects", 2500, 6},
        {"Spoiler", "Visual", 4500, 8},
        {"Window Tint", "Visual", 2000, 5}
    }
    
    for i, cust in ipairs(customizations) do
        local name, category, price, reqLevel = cust[1], cust[2], cust[3], cust[4]
        print(string.format("%2d. %-20s | %-12s | $%6d | Level %2d", 
            i, name, category, price, reqLevel))
    end
    
    -- Simulate unlock process
    print("\n🔄 EXAMPLE UNLOCK PROCESS:")
    print("1. Player selects 'Subaru3'")
    print("2. Chooses 'Body Kit' ($12,000, Level 15)")
    print("3. Checks requirements:")
    print("   - Level: " .. stats.Level .. "/15 ✓")
    print("   - Cash: $" .. stats.Cash .. "/$12,000 ✓")
    print("4. Processes purchase...")
    print("5. Body Kit successfully installed!")
    print("6. Remaining cash: $" .. (stats.Cash - 12000))
    
    print("\n" .. string.rep("=", 50))
    print("💡 This simulates how a normal player would:")
    print("   • Earn cash through races/events")
    print("   • Level up by playing")
    print("   • Save up for desired customizations")
    print("   • Purchase and install upgrades")
    
    return true
end

-- ===== SIMPLE UI VERSION =====
local function createSimpleUI()
    local playerGui = player:WaitForChild("PlayerGui")
    local oldUI = playerGui:FindFirstChild("SimpleUnlockSim")
    if oldUI then oldUI:Destroy() end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "SimpleUnlockSim"
    gui.Parent = playerGui
    gui.ResetOnSpawn = false
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 350, 0, 400)
    main.Position = UDim2.new(0.5, -175, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎮 UNLOCK SIMULATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    -- Stats Display
    local stats = simulatePlayerStats()
    
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, -20, 0, 80)
    statsFrame.Position = UDim2.new(0, 10, 0, 50)
    statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    statsFrame.Parent = main
    
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Text = "👤 PLAYER STATISTICS"
    statsLabel.Size = UDim2.new(1, 0, 0, 25)
    statsLabel.Position = UDim2.new(0, 0, 0, 5)
    statsLabel.BackgroundTransparency = 1
    statsLabel.TextColor3 = Color3.new(1, 1, 1)
    statsLabel.Font = Enum.Font.GothamBold
    statsLabel.TextSize = 14
    statsLabel.Parent = statsFrame
    
    local statsText = Instance.new("TextLabel")
    statsText.Text = string.format(
        "Level: %d\nCash: $%s\nCars: %d\nPlay Time: %s",
        stats.Level,
        tostring(stats.Cash),
        stats.CarsOwned,
        stats.PlayTime
    )
    statsText.Size = UDim2.new(1, -20, 0, 50)
    statsText.Position = UDim2.new(0, 10, 0, 25)
    statsText.BackgroundTransparency = 1
    statsText.TextColor3 = Color3.fromRGB(200, 220, 255)
    statsText.Font = Enum.Font.Gotham
    statsText.TextSize = 12
    statsText.TextXAlignment = Enum.TextXAlignment.Left
    statsText.TextWrapped = true
    statsText.Parent = statsFrame
    
    -- Customization Options
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(1, -20, 0, 200)
    optionsFrame.Position = UDim2.new(0, 10, 0, 140)
    optionsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    optionsFrame.Parent = main
    
    local optionsLabel = Instance.new("TextLabel")
    optionsLabel.Text = "🔧 AVAILABLE UPGRADES"
    optionsLabel.Size = UDim2.new(1, 0, 0, 25)
    optionsLabel.Position = UDim2.new(0, 0, 0, 5)
    optionsLabel.BackgroundTransparency = 1
    optionsLabel.TextColor3 = Color3.new(1, 1, 1)
    optionsLabel.Font = Enum.Font.GothamBold
    optionsLabel.TextSize = 14
    optionsLabel.Parent = optionsFrame
    
    -- Customization list
    local customizations = {
        {"Engine Lvl 2", "Performance", 5000, 10},
        {"Turbo Lvl 2", "Performance", 8000, 12},
        {"Sport Rims", "Visual", 4000, 9},
        {"Body Kit", "Visual", 12000, 15},
        {"Custom Paint", "Visual", 6000, 11},
        {"Neon Lights", "Effects", 3500, 7}
    }
    
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, -20, 0, 160)
    listFrame.Position = UDim2.new(0, 10, 0, 30)
    listFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    listFrame.BorderSizePixel = 0
    listFrame.CanvasSize = UDim2.new(0, 0, 0, #customizations * 35)
    listFrame.ScrollBarThickness = 6
    listFrame.Parent = optionsFrame
    
    for i, cust in ipairs(customizations) do
        local name, category, price, reqLevel = cust[1], cust[2], cust[3], cust[4]
        
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, 0, 0, 30)
        itemFrame.Position = UDim2.new(0, 0, 0, (i-1) * 35)
        itemFrame.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(40, 40, 60) or Color3.fromRGB(45, 45, 65)
        itemFrame.Parent = listFrame
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = name
        nameLabel.Size = UDim2.new(0.5, -10, 1, 0)
        nameLabel.Position = UDim2.new(0, 5, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = itemFrame
        
        local priceLabel = Instance.new("TextLabel")
        priceLabel.Text = "$" .. price
        priceLabel.Size = UDim2.new(0.3, -10, 1, 0)
        priceLabel.Position = UDim2.new(0.5, 0, 0, 0)
        priceLabel.BackgroundTransparency = 1
        priceLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        priceLabel.Font = Enum.Font.Gotham
        priceLabel.TextSize = 11
        priceLabel.Parent = itemFrame
        
        local buyBtn = Instance.new("TextButton")
        buyBtn.Text = "SIMULATE"
        buyBtn.Size = UDim2.new(0.2, -5, 0.7, 0)
        buyBtn.Position = UDim2.new(0.8, 0, 0.15, 0)
        buyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        buyBtn.TextColor3 = Color3.new(1, 1, 1)
        buyBtn.Font = Enum.Font.GothamBold
        buyBtn.TextSize = 10
        buyBtn.Parent = itemFrame
        
        buyBtn.MouseButton1Click:Connect(function()
            print("\n🔄 SIMULATING PURCHASE:")
            print("   Item: " .. name)
            print("   Price: $" .. price)
            print("   Required Level: " .. reqLevel)
            print("   Player Level: " .. stats.Level)
            print("   Player Cash: $" .. stats.Cash)
            
            if stats.Level >= reqLevel then
                print("   ✅ Level requirement met!")
            else
                print("   ❌ Need level " .. reqLevel .. " (have " .. stats.Level .. ")")
            end
            
            if stats.Cash >= price then
                print("   ✅ Cash requirement met!")
                print("   💰 New balance: $" .. (stats.Cash - price))
            else
                print("   ❌ Need $" .. price .. " (have $" .. stats.Cash .. ")")
            end
            
            print("   🎉 Purchase simulation complete!")
        end)
    end
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Click SIMULATE to test purchase process"
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 350)
    status.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Close Button
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
    roundCorners(statsFrame)
    roundCorners(optionsFrame)
    roundCorners(listFrame)
    roundCorners(status)
    roundCorners(closeBtn)
    
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") then
            roundCorners(child)
        end
        if child:IsA("TextButton") then
            roundCorners(child)
        end
    end
    
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
    
    title.InputEnded:Connect(function(input)
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
    
    print("✅ Simple UI created successfully")
    return gui
end

-- ===== MAIN =====
print("\n🎮 Starting Unlock Process Simulator...")

-- Try to create UI
local success, err = pcall(function()
    -- First show console version
    simpleConsoleSimulator()
    
    -- Then create UI
    task.wait(1)
    createSimpleUI()
    
    print("\n✅ SIMULATOR READY!")
end)

if not success then
    print("\n⚠️ UI Creation Failed: " .. tostring(err))
    print("📟 Using console-only mode...")
    simpleConsoleSimulator()
end

print("\n" .. string.rep("=", 60))
print("🎯 WHAT THIS SIMULATES:")
print("1. Player earns cash/levels through gameplay")
print("2. Player browses available customizations")
print("3. Player checks requirements (level, cash)")
print("4. Player purchases if requirements met")
print("5. Customization is installed")
print("\n💡 Use this to understand player progression flow!")
