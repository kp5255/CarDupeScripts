-- 🎨 ADVANCED CAR CUSTOMIZATION VIEWER
-- Shows ALL customizations for each car, including missing ones

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🎨 ADVANCED CAR CUSTOMIZATION VIEWER")
print("=" .. string.rep("=", 60))

-- ===== GET ALL CARS =====
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

-- ===== ALL POSSIBLE CUSTOMIZATION TYPES =====
local ALL_CUSTOMIZATION_TYPES = {
    "Rims", "Wheels", "RimColor",
    "Engine", "Turbo", "Transmission",
    "Brakes", "BrakeColor",
    "Drivetrain", "Suspension", "Springs",
    "Bodykit", "BodyKit", "Kit",
    "Spoiler", "Wing",
    "Wrap", "Paint", "Color", "PrimaryColor", "SecondaryColor",
    "Underglow", "UnderglowColor", "Neon",
    "TireSmoke", "TireSmokeColor", "TireSmokeTexture",
    "Interior", "InteriorColor", "InteriorColor2",
    "WindowTint", "Windows",
    "Horn", "Exhaust",
    "CamberHeightFront", "CamberHeightRear",
    "CamberAngleFront", "CamberAngleRear",
    "CamberOffsetRear",
    "Reflectance", "Material",
    "Headlights", "Taillights",
    "LicensePlate", "Plate",
    "Sticker", "Decal",
    "Battery", "NOS", "Nitrous"
}

-- ===== GET CAR CUSTOMIZATION WITH DETAILS =====
local function getCarCustomizationsDetailed(car)
    if not car or type(car) ~= "table" then
        return {}, "Invalid car data"
    end
    
    local customizations = {}
    local hasCustomizations = false
    local carName = car.Name or "Unknown"
    
    -- Check if car has Data table
    if car.Data and type(car.Data) == "table" then
        hasCustomizations = true
        
        -- Check for each possible customization type
        for _, custType in ipairs(ALL_CUSTOMIZATION_TYPES) do
            local data = car.Data[custType]
            
            if data ~= nil then
                -- Extract value safely
                local value, valueType, rawData
                
                if type(data) == "table" then
                    rawData = data
                    -- Try different value fields
                    value = data.Current or data.Value or data.Level or 
                            data.Selected or data.Name or data.Id or 
                            data.Color or "[Table]"
                    valueType = "table"
                else
                    value = data
                    valueType = type(data)
                end
                
                customizations[custType] = {
                    Value = value,
                    Type = valueType,
                    RawData = rawData,
                    Exists = true
                }
            else
                -- Mark as not existing for this car
                customizations[custType] = {
                    Value = "❌ NOT FOUND",
                    Type = "missing",
                    Exists = false
                }
            end
        end
        
        -- Also check for any other customizations not in our list
        for key, data in pairs(car.Data) do
            if not customizations[key] then
                local value, valueType
                
                if type(data) == "table" then
                    value = data.Current or data.Value or data.Level or "[Table]"
                    valueType = "table"
                else
                    value = data
                    valueType = type(data)
                end
                
                customizations[key] = {
                    Value = value,
                    Type = valueType,
                    Exists = true,
                    IsUnknown = true  -- Not in our predefined list
                }
            end
        end
    else
        -- Car has no Data table at all
        for _, custType in ipairs(ALL_CUSTOMIZATION_TYPES) do
            customizations[custType] = {
                Value = "❌ NO DATA TABLE",
                Type = "missing",
                Exists = false
            }
        end
    end
    
    return customizations, hasCustomizations and "Has customizations" or "No customizations found"
end

-- ===== DISPLAY CAR SUMMARY =====
local function displayCarSummary(car, index)
    local carName = car.Name or "Car " .. index
    local carId = car.Id and string.sub(tostring(car.Id), 1, 8) .. "..." or "N/A"
    
    print("\n🚗 [" .. index .. "] " .. carName)
    print("   ID: " .. carId)
    
    local customizations, status = getCarCustomizationsDetailed(car)
    
    -- Count customizations
    local totalFound = 0
    local hasBodykit = false
    local hasWrap = false
    local hasSpoiler = false
    local hasUnderglow = false
    
    for custType, data in pairs(customizations) do
        if data.Exists and data.Value ~= "❌ NOT FOUND" and data.Value ~= "❌ NO DATA TABLE" then
            totalFound = totalFound + 1
            
            -- Check for specific customizations
            local lowerType = custType:lower()
            if lowerType:find("bodykit") or lowerType:find("kit") then
                hasBodykit = true
            elseif lowerType:find("wrap") or lowerType:find("paint") or lowerType:find("color") then
                hasWrap = true
            elseif lowerType:find("spoiler") or lowerType:find("wing") then
                hasSpoiler = true
            elseif lowerType:find("underglow") or lowerType:find("neon") then
                hasUnderglow = true
            end
        end
    end
    
    print("   📊 Customizations: " .. totalFound)
    
    -- Show what this car has
    local features = {}
    if hasBodykit then table.insert(features, "🚗 Bodykit") end
    if hasWrap then table.insert(features, "🎨 Wrap/Paint") end
    if hasSpoiler then table.insert(features, "✈️ Spoiler") end
    if hasUnderglow then table.insert(features, "💡 Underglow") end
    
    if #features > 0 then
        print("   ✅ Has: " .. table.concat(features, ", "))
    else
        print("   ⚠️ No major customizations found")
    end
    
    return customizations, totalFound
end

-- ===== CREATE ADVANCED UI =====
local function createAdvancedUI()
    local playerGui = player:WaitForChild("PlayerGui")
    local oldUI = playerGui:FindFirstChild("AdvancedCustomizationViewer")
    if oldUI then oldUI:Destroy() end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "AdvancedCustomizationViewer"
    gui.Parent = playerGui
    gui.ResetOnSpawn = false
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 500, 0, 550)
    main.Position = UDim2.new(0.5, -250, 0.5, -275)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 ADVANCED CUSTOMIZATION VIEWER"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    -- Car Info Display
    local carInfoFrame = Instance.new("Frame")
    carInfoFrame.Size = UDim2.new(1, -20, 0, 80)
    carInfoFrame.Position = UDim2.new(0, 10, 0, 60)
    carInfoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    carInfoFrame.Parent = main
    
    local carNameLabel = Instance.new("TextLabel")
    carNameLabel.Name = "CarName"
    carNameLabel.Text = "Select a car"
    carNameLabel.Size = UDim2.new(1, -20, 0, 25)
    carNameLabel.Position = UDim2.new(0, 10, 0, 10)
    carNameLabel.BackgroundTransparency = 1
    carNameLabel.TextColor3 = Color3.new(1, 1, 1)
    carNameLabel.Font = Enum.Font.GothamBold
    carNameLabel.TextSize = 16
    carNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    carInfoFrame.Parent = carInfoFrame
    
    local carStatsLabel = Instance.new("TextLabel")
    carStatsLabel.Name = "CarStats"
    carStatsLabel.Text = "Customizations: --"
    carStatsLabel.Size = UDim2.new(1, -20, 0, 40)
    carStatsLabel.Position = UDim2.new(0, 10, 0, 35)
    carStatsLabel.BackgroundTransparency = 1
    carStatsLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    carStatsLabel.Font = Enum.Font.Gotham
    carStatsLabel.TextSize = 12
    carStatsLabel.TextXAlignment = Enum.TextXAlignment.Left
    carStatsLabel.TextWrapped = true
    carInfoFrame.Parent = carStatsLabel
    
    -- Filter Buttons
    local filterFrame = Instance.new("Frame")
    filterFrame.Size = UDim2.new(1, -20, 0, 40)
    filterFrame.Position = UDim2.new(0, 10, 0, 150)
    filterFrame.BackgroundTransparency = 1
    filterFrame.Parent = main
    
    local filterButtons = {
        {Name = "All", Color = Color3.fromRGB(100, 100, 150)},
        {Name = "✅ Has", Color = Color3.fromRGB(0, 150, 0)},
        {Name = "❌ Missing", Color = Color3.fromRGB(150, 0, 0)},
        {Name = "🎨 Visual", Color = Color3.fromRGB(200, 100, 0)}
    }
    
    local buttonX = 0
    for i, filter in ipairs(filterButtons) do
        local btn = Instance.new("TextButton")
        btn.Text = filter.Name
        btn.Size = UDim2.new(0.22, -5, 1, 0)
        btn.Position = UDim2.new(buttonX, 0, 0, 0)
        btn.BackgroundColor3 = filter.Color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Name = "Filter" .. filter.Name
        filterFrame.Parent = btn
        
        buttonX = buttonX + 0.23
    end
    
    -- Customization List
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Name = "CustomizationList"
    listFrame.Size = UDim2.new(1, -20, 0, 320)
    listFrame.Position = UDim2.new(0, 10, 0, 200)
    listFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    listFrame.BorderSizePixel = 0
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollBarThickness = 8
    listFrame.Parent = main
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 3)
    listLayout.Parent = listFrame
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Text = "Select a car from the console first"
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 530)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
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
    
    -- Round corners
    local function roundCorners(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    roundCorners(main)
    roundCorners(title)
    roundCorners(carInfoFrame)
    roundCorners(listFrame)
    roundCorners(status)
    
    for _, child in ipairs(filterFrame:GetChildren()) do
        if child:IsA("TextButton") then
            roundCorners(child)
        end
    end
    
    -- Data storage
    local currentCarIndex = 1
    local currentCarData = nil
    local currentCustomizations = {}
    local allCars = {}
    
    -- Display customizations in list
    local function displayCustomizations(filterType)
        -- Clear list
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        if not currentCustomizations or next(currentCustomizations) == nil then
            local noData = Instance.new("TextLabel")
            noData.Text = "No customizations to display"
            noData.Size = UDim2.new(1, 0, 0, 30)
            noData.BackgroundTransparency = 1
            noData.TextColor3 = Color3.new(1, 1, 1)
            noData.Font = Enum.Font.Gotham
            noData.TextSize = 14
            noData.Parent = listFrame
            return
        end
        
        local itemCount = 0
        
        for custType, data in pairs(currentCustomizations) do
            -- Apply filter
            local showItem = true
            
            if filterType == "Has" then
                showItem = data.Exists and data.Value ~= "❌ NOT FOUND" and data.Value ~= "❌ NO DATA TABLE"
            elseif filterType == "Missing" then
                showItem = not data.Exists or data.Value == "❌ NOT FOUND" or data.Value == "❌ NO DATA TABLE"
            elseif filterType == "Visual" then
                local lowerType = custType:lower()
                showItem = lowerType:find("color") or lowerType:find("paint") or 
                          lowerType:find("wrap") or lowerType:find("kit") or 
                          lowerType:find("spoiler") or lowerType:find("underglow") or
                          lowerType:find("rim") or lowerType:find("wheel")
            end
            
            if showItem then
                itemCount = itemCount + 1
                
                local itemFrame = Instance.new("Frame")
                itemFrame.Size = UDim2.new(1, 0, 0, 30)
                itemFrame.BackgroundColor3 = data.Exists and 
                    (data.Value == "❌ NOT FOUND" and Color3.fromRGB(60, 30, 30) or 
                     data.Value == "❌ NO DATA TABLE" and Color3.fromRGB(60, 30, 30) or 
                     Color3.fromRGB(40, 40, 60)) or 
                    Color3.fromRGB(50, 30, 30)
                itemFrame.Parent = listFrame
                
                local typeLabel = Instance.new("TextLabel")
                typeLabel.Text = custType
                typeLabel.Size = UDim2.new(0.5, -10, 1, 0)
                typeLabel.Position = UDim2.new(0, 10, 0, 0)
                typeLabel.BackgroundTransparency = 1
                typeLabel.TextColor3 = data.Exists and Color3.new(1, 1, 1) or Color3.fromRGB(200, 150, 150)
                typeLabel.Font = Enum.Font.Gotham
                typeLabel.TextSize = 12
                typeLabel.TextXAlignment = Enum.TextXAlignment.Left
                itemFrame.Parent = typeLabel
                
                local valueLabel = Instance.new("TextLabel")
                valueLabel.Text = tostring(data.Value)
                valueLabel.Size = UDim2.new(0.5, -10, 1, 0)
                valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
                valueLabel.BackgroundTransparency = 1
                valueLabel.TextColor3 = data.Exists and 
                    (data.Value == "❌ NOT FOUND" and Color3.fromRGB(255, 100, 100) or 
                     data.Value == "❌ NO DATA TABLE" and Color3.fromRGB(255, 100, 100) or 
                     Color3.fromRGB(150, 200, 255)) or 
                    Color3.fromRGB(255, 150, 150)
                valueLabel.Font = Enum.Font.Gotham
                valueLabel.TextSize = 11
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                itemFrame.Parent = valueLabel
                
                roundCorners(itemFrame)
            end
        end
        
        -- Update canvas size
        listFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(itemCount * 33, 100))
        
        status.Text = "Showing " .. itemCount .. " customizations" .. 
                     (filterType ~= "All" and " (Filter: " .. filterType .. ")" or "")
    end
    
    -- Load a specific car
    local function loadCarIntoUI(car, index)
        if not car then return end
        
        currentCarIndex = index
        currentCarData = car
        
        local carName = car.Name or "Car " .. index
        local shortId = car.Id and string.sub(tostring(car.Id), 1, 8) .. "..." or "N/A"
        
        -- Update car info
        carNameLabel.Text = "🚗 " .. carName
        carStatsLabel.Text = "ID: " .. shortId .. "\nLoading customizations..."
        
        -- Get customizations
        currentCustomizations = getCarCustomizationsDetailed(car)
        
        -- Count stats
        local totalFound = 0
        local hasBodykit = false
        local hasWrap = false
        
        for _, data in pairs(currentCustomizations) do
            if data.Exists and data.Value ~= "❌ NOT FOUND" and data.Value ~= "❌ NO DATA TABLE" then
                totalFound = totalFound + 1
                
                local lowerType = data.Category and data.Category:lower() or ""
                if lowerType:find("bodykit") or lowerType:find("kit") then
                    hasBodykit = true
                elseif lowerType:find("wrap") or lowerType:find("paint") then
                    hasWrap = true
                end
            end
        end
        
        -- Update stats
        local features = {}
        if hasBodykit then table.insert(features, "Bodykit") end
        if hasWrap then table.insert(features, "Wrap") end
        
        carStatsLabel.Text = "Customizations: " .. totalFound
        if #features > 0 then
            carStatsLabel.Text = carStatsLabel.Text .. "\nHas: " .. table.concat(features, ", ")
        end
        
        -- Display all customizations
        displayCustomizations("All")
        
        status.Text = "✅ Loaded " .. totalFound .. " customizations for " .. carName
    end
    
    -- Load all cars from console
    local function loadCarsFromConsole()
        allCars = getCars()
        
        if #allCars == 0 then
            status.Text = "❌ No cars found"
            return
        end
        
        -- Display summary in console
        print("\n📊 CAR CUSTOMIZATION SUMMARY:")
        print("=" .. string.rep("=", 50))
        
        for i, car in ipairs(allCars) do
            local customizations, totalFound = displayCarSummary(car, i)
            
            -- Store first car's data
            if i == 1 then
                loadCarIntoUI(car, 1)
            end
        end
        
        print("\n" .. string.rep("=", 50))
        print("💡 TIP: Cars with ❌ means they don't have that customization")
        print("       Cars with ✅ means they have it installed")
        
        status.Text = "✅ Loaded " .. #allCars .. " cars. Showing first car."
    end
    
    -- Filter button actions
    for _, btn in ipairs(filterFrame:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.MouseButton1Click:Connect(function()
                local filterName = btn.Text
                displayCustomizations(filterName)
            end)
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
    
    -- Initialize
    task.spawn(function()
        loadCarsFromConsole()
    end)
    
    return gui
end

-- ===== MAIN =====
print("\n🔍 Analyzing ALL your cars...")
task.wait(1)

-- Create the advanced UI
createAdvancedUI()

print("\n" .. string.rep("=", 60))
print("✅ ADVANCED VIEWER READY!")
print("\n📱 FEATURES:")
print("• Shows ALL customizations for each car")
print("• Clearly marks ❌ missing customizations")
print("• Filters: All / Has / Missing / Visual")
print("• Summary shows which cars have bodykits/wraps")
print("\n📊 Check console for complete car-by-car analysis!")
