-- 🎮 PLAYER CUSTOMIZATION UNLOCK SIMULATOR
-- Simulates the normal player process for unlocking customizations

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🎮 PLAYER CUSTOMIZATION UNLOCK PROCESS SIMULATOR")
print("=" .. string.rep("=", 60))

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== GET PLAYER'S CARS =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
local function getPlayerCars()
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(cars) == "table" then
        print("✅ Found " .. #cars .. " cars")
        return cars
    end
    return {}
end

-- ===== GET AVAILABLE CUSTOMIZATIONS =====
local function getAvailableCustomizations(car)
    print("\n🔍 Finding available customizations for: " .. (car.Name or "Unknown"))
    
    -- This simulates what a player would see in the customization menu
    local availableCustomizations = {
        -- Performance Upgrades
        {Category = "Engine", Name = "Engine Level 1", Price = 1000, RequiredLevel = 5},
        {Category = "Engine", Name = "Engine Level 2", Price = 2500, RequiredLevel = 10},
        {Category = "Engine", Name = "Engine Level 3", Price = 5000, RequiredLevel = 15},
        {Category = "Turbo", Name = "Basic Turbo", Price = 1500, RequiredLevel = 8},
        {Category = "Turbo", Name = "Advanced Turbo", Price = 3500, RequiredLevel = 12},
        {Category = "Brakes", Name = "Sport Brakes", Price = 800, RequiredLevel = 3},
        {Category = "Brakes", Name = "Race Brakes", Price = 2000, RequiredLevel = 7},
        
        -- Visual Upgrades
        {Category = "Rims", Name = "Sport Rims", Price = 1200, RequiredLevel = 4},
        {Category = "Rims", Name = "Chrome Rims", Price = 3000, RequiredLevel = 9},
        {Category = "Bodykit", Name = "Basic Bodykit", Price = 5000, RequiredLevel = 10},
        {Category = "Bodykit", Name = "Widebody Kit", Price = 10000, RequiredLevel = 15},
        {Category = "Spoiler", Name = "Small Spoiler", Price = 800, RequiredLevel = 3},
        {Category = "Spoiler", Name = "Large Wing", Price = 2500, RequiredLevel = 8},
        
        -- Paint & Wraps
        {Category = "Wrap", Name = "Racing Stripe", Price = 500, RequiredLevel = 2},
        {Category = "Wrap", Name = "Carbon Fiber", Price = 3000, RequiredLevel = 10},
        {Category = "Wrap", Name = "Chrome Wrap", Price = 5000, RequiredLevel = 12},
        {Category = "Color", Name = "Metallic Red", Price = 800, RequiredLevel = 3},
        {Category = "Color", Name = "Pearl White", Price = 1200, RequiredLevel = 5},
        
        -- Effects
        {Category = "Underglow", Name = "Blue Neon", Price = 1500, RequiredLevel = 6},
        {Category = "Underglow", Name = "RGB Neon", Price = 3000, RequiredLevel = 10},
        {Category = "TireSmoke", Name = "Blue Smoke", Price = 1000, RequiredLevel = 5},
        {Category = "TireSmoke", Name = "Rainbow Smoke", Price = 2500, RequiredLevel = 8}
    }
    
    return availableCustomizations
end

-- ===== SIMULATE PLAYER PROGRESSION =====
local function simulatePlayerStats()
    -- Simulate player stats (what a normal player would have)
    return {
        Level = 10,
        Cash = 15000,
        Reputation = 2500,
        PlayTime = "25 hours",
        CarsOwned = 3
    }
end

-- ===== DISPLAY PLAYER PROGRESS =====
local function displayPlayerProgress()
    local stats = simulatePlayerStats()
    
    print("\n👤 PLAYER STATISTICS:")
    print("   Level: " .. stats.Level)
    print("   Cash: $" .. stats.Cash)
    print("   Reputation: " .. stats.Reputation)
    print("   Play Time: " .. stats.PlayTime)
    print("   Cars Owned: " .. stats.CarsOwned)
    
    return stats
end

-- ===== SIMULATE UNLOCK PROCESS =====
local function simulateUnlockProcess(car, customization)
    print("\n🔄 SIMULATING UNLOCK PROCESS...")
    print("   Car: " .. (car.Name or "Unknown"))
    print("   Customization: " .. customization.Name)
    print("   Category: " .. customization.Category)
    print("   Price: $" .. customization.Price)
    print("   Required Level: " .. customization.RequiredLevel)
    
    local playerStats = simulatePlayerStats()
    
    -- Check if player meets requirements
    if playerStats.Level < customization.RequiredLevel then
        print("   ❌ FAILED: Player level too low!")
        print("      Need level " .. customization.RequiredLevel .. ", have level " .. playerStats.Level)
        return false
    end
    
    if playerStats.Cash < customization.Price then
        print("   ❌ FAILED: Not enough cash!")
        print("      Need $" .. customization.Price .. ", have $" .. playerStats.Cash)
        return false
    end
    
    -- Simulate purchase
    print("   ✅ REQUIREMENTS MET!")
    print("   💰 Deducting $" .. customization.Price .. " from cash...")
    print("   🔧 Installing " .. customization.Name .. "...")
    
    -- Simulate installation time
    for i = 1, 3 do
        task.wait(0.5)
        print("   Installing" .. string.rep(".", i))
    end
    
    print("   🎉 SUCCESS! " .. customization.Name .. " unlocked and equipped!")
    print("   💵 Remaining cash: $" .. (playerStats.Cash - customization.Price))
    
    return true
end

-- ===== CREATE UNLOCK SIMULATION UI =====
local function createUnlockSimulationUI()
    local playerGui = player:WaitForChild("PlayerGui")
    local oldUI = playerGui:FindFirstChild("UnlockSimulator")
    if oldUI then oldUI:Destroy() end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "UnlockSimulator"
    gui.Parent = playerGui
    gui.ResetOnSpawn = false
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 500)
    main.Position = UDim2.new(0.5, -200, 0.5, -250)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎮 UNLOCK PROCESS SIMULATOR"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = main
    
    -- Player Stats Display
    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, -20, 0, 100)
    statsFrame.Position = UDim2.new(0, 10, 0, 60)
    statsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    statsFrame.Parent = main
    
    local statsTitle = Instance.new("TextLabel")
    statsTitle.Text = "👤 SIMULATED PLAYER STATS"
    statsTitle.Size = UDim2.new(1, 0, 0, 25)
    statsTitle.Position = UDim2.new(0, 0, 0, 5)
    statsTitle.BackgroundTransparency = 1
    statsTitle.TextColor3 = Color3.new(1, 1, 1)
    statsTitle.Font = Enum.Font.GothamBold
    statsTitle.TextSize = 14
    statsTitle.Parent = statsFrame
    
    local statsText = Instance.new("TextLabel")
    statsText.Name = "StatsText"
    statsText.Text = "Level: 10\nCash: $15,000\nCars: 3"
    statsText.Size = UDim2.new(1, -20, 0, 70)
    statsText.Position = UDim2.new(0, 10, 0, 25)
    statsText.BackgroundTransparency = 1
    statsText.TextColor3 = Color3.fromRGB(200, 200, 255)
    statsText.Font = Enum.Font.Gotham
    statsText.TextSize = 12
    statsText.TextXAlignment = Enum.TextXAlignment.Left
    statsText.TextWrapped = true
    statsText.Parent = statsFrame
    
    -- Car Selector
    local carFrame = Instance.new("Frame")
    carFrame.Size = UDim2.new(1, -20, 0, 60)
    carFrame.Position = UDim2.new(0, 10, 0, 170)
    carFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    carFrame.Parent = main
    
    local carLabel = Instance.new("TextLabel")
    carLabel.Text = "🚗 SELECT CAR TO UPGRADE:"
    carLabel.Size = UDim2.new(1, 0, 0, 25)
    carLabel.Position = UDim2.new(0, 0, 0, 5)
    carLabel.BackgroundTransparency = 1
    carLabel.TextColor3 = Color3.new(1, 1, 1)
    carLabel.Font = Enum.Font.Gotham
    carLabel.TextSize = 14
    carLabel.Parent = carFrame
    
    local carList = Instance.new("ScrollingFrame")
    carList.Name = "CarList"
    carList.Size = UDim2.new(1, -20, 0, 30)
    carList.Position = UDim2.new(0, 10, 0, 30)
    carList.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    carList.BorderSizePixel = 0
    carList.CanvasSize = UDim2.new(2, 0, 0, 0)
    carList.ScrollBarThickness = 6
    carList.Parent = carFrame
    
    local carLayout = Instance.new("UIListLayout")
    carLayout.FillDirection = Enum.FillDirection.Horizontal
    carLayout.Padding = UDim.new(0, 5)
    carLayout.Parent = carList
    
    -- Customization Categories
    local categories = {
        {Name = "🚀 Performance", Color = Color3.fromRGB(220, 80, 80)},
        {Name = "🎨 Visual", Color = Color3.fromRGB(80, 160, 220)},
        {Name = "✨ Effects", Color = Color3.fromRGB(160, 80, 220)},
        {Name = "💎 Premium", Color = Color3.fromRGB(220, 180, 80)}
    }
    
    local categoryFrame = Instance.new("Frame")
    categoryFrame.Size = UDim2.new(1, -20, 0, 40)
    categoryFrame.Position = UDim2.new(0, 10, 0, 240)
    categoryFrame.BackgroundTransparency = 1
    categoryFrame.Parent = main
    
    local catX = 0
    for i, category in ipairs(categories) do
        local catBtn = Instance.new("TextButton")
        catBtn.Text = category.Name
        catBtn.Size = UDim2.new(0.23, 0, 1, 0)
        catBtn.Position = UDim2.new(catX, 0, 0, 0)
        catBtn.BackgroundColor3 = category.Color
        catBtn.TextColor3 = Color3.new(1, 1, 1)
        catBtn.Font = Enum.Font.Gotham
        catBtn.TextSize = 11
        catBtn.Parent = categoryFrame
        
        catX = catX + 0.24
    end
    
    -- Customization List
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Name = "CustomizationList"
    listFrame.Size = UDim2.new(1, -20, 0, 150)
    listFrame.Position = UDim2.new(0, 10, 0, 290)
    listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    listFrame.BorderSizePixel = 0
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollBarThickness = 8
    listFrame.Parent = main
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = listFrame
    
    -- Status/Log
    local logFrame = Instance.new("ScrollingFrame")
    logFrame.Name = "LogFrame"
    logFrame.Size = UDim2.new(1, -20, 0, 80)
    logFrame.Position = UDim2.new(0, 10, 0, 450)
    logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    logFrame.BorderSizePixel = 0
    logFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    logFrame.ScrollBarThickness = 6
    logFrame.Parent = main
    
    local logLayout = Instance.new("UIListLayout")
    logLayout.Parent = logFrame
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
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
    roundCorners(carFrame)
    roundCorners(carList)
    roundCorners(listFrame)
    roundCorners(logFrame)
    
    for _, child in ipairs(categoryFrame:GetChildren()) do
        if child:IsA("TextButton") then
            roundCorners(child)
        end
    end
    
    -- Data
    local allCars = {}
    local currentCar = nil
    local playerStats = simulatePlayerStats()
    
    -- Update stats display
    statsText.Text = string.format(
        "Level: %d\nCash: $%s\nReputation: %d\nCars: %d",
        playerStats.Level,
        tostring(playerStats.Cash),
        playerStats.Reputation,
        playerStats.CarsOwned
    )
    
    -- Load cars
    local function loadCars()
        allCars = getPlayerCars()
        carList:ClearAllChildren()
        
        if #allCars == 0 then
            local noCars = Instance.new("TextLabel")
            noCars.Text = "No cars found"
            noCars.Size = UDim2.new(1, 0, 1, 0)
            noCars.BackgroundTransparency = 1
            noCars.TextColor3 = Color3.new(1, 1, 1)
            noCars.Font = Enum.Font.Gotham
            noCars.TextSize = 12
            noCars.Parent = carList
            return
        end
        
        for i, car in ipairs(allCars) do
            local carBtn = Instance.new("TextButton")
            carBtn.Text = car.Name or "Car " .. i
            carBtn.Size = UDim2.new(0, 100, 0, 25)
            carBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
            carBtn.TextColor3 = Color3.new(1, 1, 1)
            carBtn.Font = Enum.Font.Gotham
            carBtn.TextSize = 11
            carBtn.Parent = carList
            
            carBtn.MouseButton1Click:Connect(function()
                currentCar = car
                loadCustomizations(car)
                addLog("Selected: " .. (car.Name or "Car " .. i))
            end)
            
            roundCorners(carBtn)
            
            -- Select first car by default
            if i == 1 then
                currentCar = car
                loadCustomizations(car)
            end
        end
        
        carList.CanvasSize = UDim2.new(0, (#allCars * 105), 0, 0)
    end
    
    -- Load customizations for selected car
    local function loadCustomizations(car)
        listFrame:ClearAllChildren()
        
        local customizations = getAvailableCustomizations(car)
        
        for i, cust in ipairs(customizations) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, 0, 0, 35)
            itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            itemFrame.Parent = listFrame
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Text = cust.Name
            nameLabel.Size = UDim2.new(0.6, -10, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = itemFrame
            
            local priceLabel = Instance.new("TextLabel")
            priceLabel.Text = "$" .. cust.Price
            priceLabel.Size = UDim2.new(0.2, -10, 1, 0)
            priceLabel.Position = UDim2.new(0.6, 0, 0, 0)
            priceLabel.BackgroundTransparency = 1
            priceLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            priceLabel.Font = Enum.Font.Gotham
            priceLabel.TextSize = 11
            priceLabel.Parent = itemFrame
            
            local buyBtn = Instance.new("TextButton")
            buyBtn.Text = "BUY"
            buyBtn.Size = UDim2.new(0.2, -10, 0.7, 0)
            buyBtn.Position = UDim2.new(0.8, 0, 0.15, 0)
            buyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            buyBtn.TextColor3 = Color3.new(1, 1, 1)
            buyBtn.Font = Enum.Font.GothamBold
            buyBtn.TextSize = 10
            buyBtn.Parent = itemFrame
            
            buyBtn.MouseButton1Click:Connect(function()
                if currentCar then
                    simulateUnlockProcess(currentCar, cust)
                    addLog("Attempted to buy: " .. cust.Name .. " for $" .. cust.Price)
                end
            end)
            
            roundCorners(itemFrame)
            roundCorners(buyBtn)
        end
        
        listFrame.CanvasSize = UDim2.new(0, 0, 0, #customizations * 40)
    end
    
    -- Add log message
    local function addLog(message)
        local logEntry = Instance.new("TextLabel")
        logEntry.Text = "> " .. message
        logEntry.Size = UDim2.new(1, 0, 0, 20)
        logEntry.BackgroundTransparency = 1
        logEntry.TextColor3 = Color3.fromRGB(200, 200, 200)
        logEntry.Font = Enum.Font.Gotham
        logEntry.TextSize = 10
        logEntry.TextXAlignment = Enum.TextXAlignment.Left
        logEntry.Parent = logFrame
        
        logFrame.CanvasSize = UDim2.new(0, 0, 0, #logFrame:GetChildren() * 22)
        logFrame.CanvasPosition = Vector2.new(0, logFrame.CanvasSize.Y.Offset)
    end
    
    -- Category button actions
    for _, btn in ipairs(categoryFrame:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.MouseButton1Click:Connect(function()
                addLog("Filtered by: " .. btn.Text)
            end)
        end
    end
    
    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Initialize
    task.spawn(function()
        loadCars()
        addLog("Unlock Simulator started")
        addLog("Select a car and try buying customizations")
    end)
    
    return gui
end

-- ===== MAIN =====
print("\n🎮 Simulating normal player unlock process...")

-- Show player stats
local playerStats = displayPlayerProgress()

-- Get player's cars
local cars = getPlayerCars()

if #cars > 0 then
    print("\n🚗 PLAYER'S CARS:")
    for i, car in ipairs(cars) do
        print("  " .. i .. ". " .. (car.Name or "Car " .. i))
        local customizations = getAvailableCustomizations(car)
        print("     Available upgrades: " .. #customizations)
    end
    
    -- Show example unlock process
    print("\n📋 EXAMPLE UNLOCK PROCESS:")
    simulateUnlockProcess(cars[1], {
        Name = "Sport Rims",
        Category = "Rims",
        Price = 1200,
        RequiredLevel = 4
    })
    
    -- Create UI
    task.wait(1)
    createUnlockSimulationUI()
    
else
    print("❌ No cars found for simulation")
end

print("\n" .. string.rep("=", 60))
print("✅ UNLOCK SIMULATOR READY!")
print("\n🎯 This simulates the NORMAL player experience:")
print("1. Player earns cash through gameplay")
print("2. Player reaches required level")
print("3. Player selects car to customize")
print("4. Player purchases customization")
print("5. Customization is installed")
print("\n💡 Use this to test your game's economy and progression!")
