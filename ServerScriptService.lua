-- 🎨 COMPLETE CAR CUSTOMIZATION VIEWER & PREVIEW SYSTEM
-- Shows ALL your owned customizations and lets you preview them

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🎨 CAR CUSTOMIZATION VIEWER")
print("=" .. string.rep("=", 60))

-- ===== GET ALL CARS WITH CUSTOMIZATIONS =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
local function getCarsWithCustomizations()
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(cars) == "table" then
        print("✅ Loaded " .. #cars .. " cars")
        return cars
    end
    return {}
end

-- ===== GET CAR'S CUSTOMIZATION DATA =====
local function getCarCustomizations(car)
    if not car or not car.Data then return {} end
    
    local customizations = {}
    
    -- Extract all customization categories from car.Data
    for category, data in pairs(car.Data) do
        if type(data) == "table" then
            -- Get the actual value (usually in a field like 'Current', 'Value', or 'Level')
            local value = data.Current or data.Value or data.Level or data.Selected or data
            
            customizations[category] = {
                Value = value,
                RawData = data,
                Category = category
            }
        end
    end
    
    return customizations
end

-- ===== GET ALL AVAILABLE UPGRADES FROM DATABASE =====
local function getAllAvailableUpgrades()
    local upgrades = {}
    
    -- Search for upgrade databases
    local dataFolder = ReplicatedStorage:FindFirstChild("Data")
    if not dataFolder then return upgrades end
    
    -- Find all upgrade categories
    for _, category in ipairs(dataFolder:GetChildren()) do
        if category:IsA("Folder") then
            upgrades[category.Name] = {}
            
            -- Get all upgrades in this category
            for _, upgrade in ipairs(category:GetChildren()) do
                if upgrade:IsA("ModuleScript") then
                    table.insert(upgrades[category.Name], upgrade.Name)
                end
            end
        end
    end
    
    return upgrades
end

-- ===== DISPLAY CAR CUSTOMIZATIONS =====
local function displayCarCustomizations(carIndex)
    local cars = getCarsWithCustomizations()
    if #cars == 0 then return end
    
    local carIndex = carIndex or 1
    local car = cars[carIndex]
    
    if not car then return end
    
    print("\n🚗 CAR: " .. (car.Name or "Unknown"))
    print("📋 ID: " .. (car.Id or "N/A"))
    print(string.rep("-", 60))
    
    -- Get current customizations
    local customizations = getCarCustomizations(car)
    
    if next(customizations) == nil then
        print("❌ No customizations found for this car")
        return
    end
    
    -- Display all customizations
    print("🎨 CURRENT CUSTOMIZATIONS:")
    for category, data in pairs(customizations) do
        local valueStr = tostring(data.Value)
        if type(data.Value) == "table" then
            valueStr = "[TABLE]"
            for k, v in pairs(data.Value) do
                valueStr = valueStr .. "\n      " .. k .. " = " .. tostring(v)
            end
        end
        
        print(string.format("  %-20s = %s", category, valueStr))
    end
    
    return car, customizations
end

-- ===== CREATE CUSTOMIZATION PREVIEW UI =====
local function createCustomizationUI()
    -- Remove old UI
    local playerGui = player:WaitForChild("PlayerGui")
    local oldUI = playerGui:FindFirstChild("CustomizationViewer")
    if oldUI then oldUI:Destroy() end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "CustomizationViewer"
    gui.Parent = playerGui
    gui.ResetOnSpawn = false
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 450, 0, 500)
    main.Position = UDim2.new(0.5, -225, 0.5, -250)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎨 CAR CUSTOMIZATION VIEWER"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    -- Car Selector
    local carSelector = Instance.new("Frame")
    carSelector.Size = UDim2.new(1, -20, 0, 40)
    carSelector.Position = UDim2.new(0, 10, 0, 60)
    carSelector.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    carSelector.Parent = main
    
    local carLabel = Instance.new("TextLabel")
    carLabel.Text = "Select Car:"
    carLabel.Size = UDim2.new(0, 80, 1, 0)
    carLabel.Position = UDim2.new(0, 10, 0, 0)
    carLabel.BackgroundTransparency = 1
    carLabel.TextColor3 = Color3.new(1, 1, 1)
    carLabel.Font = Enum.Font.Gotham
    carLabel.TextSize = 14
    carLabel.TextXAlignment = Enum.TextXAlignment.Left
    carLabel.Parent = carSelector
    
    local carDropdown = Instance.new("TextButton")
    carDropdown.Name = "CarDropdown"
    carDropdown.Text = "Loading cars..."
    carDropdown.Size = UDim2.new(0, 300, 0.8, 0)
    carDropdown.Position = UDim2.new(0, 100, 0.1, 0)
    carDropdown.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    carDropdown.TextColor3 = Color3.new(1, 1, 1)
    carDropdown.Font = Enum.Font.Gotham
    carDropdown.TextSize = 14
    carDropdown.Parent = carSelector
    
    -- Customization List
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Name = "CustomizationList"
    listFrame.Size = UDim2.new(1, -20, 0, 350)
    listFrame.Position = UDim2.new(0, 10, 0, 110)
    listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    listFrame.BorderSizePixel = 0
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollBarThickness = 6
    listFrame.Parent = main
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = listFrame
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Text = "Select a car to view its customizations"
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 470)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
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
    
    -- Round corners function
    local function roundCorners(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    roundCorners(main)
    roundCorners(title)
    roundCorners(carSelector)
    roundCorners(listFrame)
    roundCorners(carDropdown)
    roundCorners(status)
    roundCorners(closeBtn)
    
    -- Load cars for dropdown
    local function loadCarsIntoUI()
        local cars = getCarsWithCustomizations()
        if #cars == 0 then
            carDropdown.Text = "No cars found"
            return {}
        end
        
        -- Create dropdown menu
        local dropdownMenu = Instance.new("Frame")
        dropdownMenu.Name = "DropdownMenu"
        dropdownMenu.Size = UDim2.new(1, 0, 0, math.min(#cars * 30, 150))
        dropdownMenu.Position = UDim2.new(0, 0, 1, 5)
        dropdownMenu.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        dropdownMenu.Visible = false
        dropdownMenu.Parent = carDropdown
        
        local dropdownLayout = Instance.new("UIListLayout")
        dropdownLayout.Parent = dropdownMenu
        
        -- Add car options
        for i, car in ipairs(cars) do
            local carBtn = Instance.new("TextButton")
            carBtn.Text = (car.Name or "Car " .. i) .. " (ID: " .. string.sub(tostring(car.Id or i), 1, 8) .. "...)"
            carBtn.Size = UDim2.new(1, 0, 0, 30)
            carBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            carBtn.TextColor3 = Color3.new(1, 1, 1)
            carBtn.Font = Enum.Font.Gotham
            carBtn.TextSize = 12
            carBtn.Parent = dropdownMenu
            
            carBtn.MouseButton1Click:Connect(function()
                carDropdown.Text = car.Name or "Car " .. i
                dropdownMenu.Visible = false
                displayCarInUI(car, i)
            end)
            
            roundCorners(carBtn)
        end
        
        -- Set first car as default
        carDropdown.Text = cars[1].Name or "Car 1"
        displayCarInUI(cars[1], 1)
        
        return cars
    end
    
    -- Display car customizations in UI
    local function displayCarInUI(car, index)
        status.Text = "Loading customizations for " .. (car.Name or "car") .. "..."
        
        -- Clear previous list
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Get customizations
        local customizations = getCarCustomizations(car)
        
        if next(customizations) == nil then
            local noData = Instance.new("TextLabel")
            noData.Text = "No customizations found for this car"
            noData.Size = UDim2.new(1, 0, 0, 30)
            noData.BackgroundTransparency = 1
            noData.TextColor3 = Color3.new(1, 1, 1)
            noData.Font = Enum.Font.Gotham
            noData.TextSize = 14
            noData.Parent = listFrame
            status.Text = "❌ No customizations found"
            return
        end
        
        -- Display each customization
        local itemCount = 0
        for category, data in pairs(customizations) do
            itemCount = itemCount + 1
            
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, 0, 0, 40)
            itemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            itemFrame.Parent = listFrame
            
            local categoryLabel = Instance.new("TextLabel")
            categoryLabel.Text = category
            categoryLabel.Size = UDim2.new(0.4, -10, 1, 0)
            categoryLabel.Position = UDim2.new(0, 10, 0, 0)
            categoryLabel.BackgroundTransparency = 1
            categoryLabel.TextColor3 = Color3.new(1, 1, 1)
            categoryLabel.Font = Enum.Font.GothamBold
            categoryLabel.TextSize = 14
            categoryLabel.TextXAlignment = Enum.TextXAlignment.Left
            categoryLabel.Parent = itemFrame
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Text = tostring(data.Value)
            valueLabel.Size = UDim2.new(0.6, -10, 1, 0)
            valueLabel.Position = UDim2.new(0.4, 0, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.TextSize = 13
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = itemFrame
            
            roundCorners(itemFrame)
        end
        
        -- Update canvas size
        listFrame.CanvasSize = UDim2.new(0, 0, 0, itemCount * 45)
        
        status.Text = "✅ Loaded " .. itemCount .. " customizations for " .. (car.Name or "car")
    end
    
    -- Toggle dropdown
    carDropdown.MouseButton1Click:Connect(function()
        local dropdown = carDropdown:FindFirstChild("DropdownMenu")
        if dropdown then
            dropdown.Visible = not dropdown.Visible
        end
    end)
    
    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Load cars
    task.spawn(function()
        loadCarsIntoUI()
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
    
    print("✅ Customization UI created")
    return gui
end

-- ===== MAIN =====
print("\nLoading your car customizations...")
displayCarCustomizations(1)  -- Show first car's customizations in console

-- Get all available upgrades from database
local allUpgrades = getAllAvailableUpgrades()
if next(allUpgrades) ~= nil then
    print("\n📁 AVAILABLE UPGRADE CATEGORIES IN DATABASE:")
    for category, upgrades in pairs(allUpgrades) do
        print("  " .. category .. " (" .. #upgrades .. " upgrades)")
    end
end

-- Create UI
task.wait(1)
createCustomizationUI()

print("\n" .. string.rep("=", 60))
print("✅ SYSTEM READY!")
print("The UI shows all your car customizations:")
print("• Rims, Engine, Turbo, BrakeColor, etc.")
print("• Current values for each customization")
print("• Select different cars from the dropdown")
