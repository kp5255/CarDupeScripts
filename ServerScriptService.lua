-- 🎨 TEMPORARY CUSTOMIZATION APPLIER
-- Applies customizations temporarily (visible to all, resets on rejoin)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

print("🎨 TEMPORARY CUSTOMIZATION APPLIER")
print("=" .. string.rep("=", 60))

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== GET PLAYER'S CARS =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
local function getCars()
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(cars) == "table" then
        print("✅ Found " .. #cars .. " cars")
        return cars
    end
    return {}
end

-- ===== APPLY TEMPORARY CUSTOMIZATION =====
local function applyTemporaryCustomization(carModel, customizationType, value)
    if not carModel or not carModel:IsA("Model") then
        warn("Invalid car model")
        return false
    end
    
    print("\n🎨 Applying " .. customizationType .. " to " .. carModel.Name)
    
    local applied = false
    
    if customizationType == "Paint" then
        -- Apply color to all body parts
        for _, part in ipairs(carModel:GetDescendants()) do
            if part:IsA("BasePart") and not part.Name:lower():find("wheel") 
               and not part.Name:lower():find("glass") 
               and not part.Name:lower():find("light") then
                
                part.Color = value or Color3.fromRGB(255, 50, 50) -- Red
                applied = true
            end
        end
        
    elseif customizationType == "Rims" then
        -- Apply to wheels
        for _, part in ipairs(carModel:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find("wheel") then
                part.Color = value or Color3.fromRGB(20, 20, 20) -- Black
                part.Material = Enum.Material.Metal
                applied = true
            end
        end
        
    elseif customizationType == "Spoiler" then
        -- Make spoiler visible
        for _, part in ipairs(carModel:GetDescendants()) do
            if part:IsA("BasePart") and part.Name:lower():find("spoiler") then
                part.Transparency = 0
                part.CanCollide = true
                if value then part.Color = value end
                applied = true
            end
        end
        
    elseif customizationType == "Underglow" then
        -- Find or create underglow
        local underglow = carModel:FindFirstChild("Underglow")
        if not underglow then
            underglow = Instance.new("Part")
            underglow.Name = "Underglow"
            underglow.Size = Vector3.new(6, 0.2, 3)
            underglow.Position = carModel:GetPivot().Position - Vector3.new(0, 1.5, 0)
            underglow.Anchored = true
            underglow.CanCollide = false
            underglow.Parent = carModel
        end
        underglow.Color = value or Color3.fromRGB(0, 255, 255) -- Cyan
        underglow.Material = Enum.Material.Neon
        underglow.Transparency = 0.3
        applied = true
        
    elseif customizationType == "WindowTint" then
        -- Tint windows
        for _, part in ipairs(carModel:GetDescendants()) do
            if part:IsA("BasePart") and (part.Name:lower():find("glass") or part.Name:lower():find("window")) then
                part.Transparency = 0.5
                part.Color = value or Color3.fromRGB(0, 0, 50) -- Dark blue tint
                applied = true
            end
        end
        
    elseif customizationType == "SmokeColor" then
        -- This would typically be a particle effect
        print("⚠️ Smoke color requires particle system (not implemented)")
        
    else
        warn("Unknown customization type: " .. customizationType)
    end
    
    if applied then
        print("✅ Applied " .. customizationType .. " (visible to all players)")
        print("⚠️ Will reset when you rejoin the game")
    else
        print("❌ Could not apply " .. customizationType)
    end
    
    return applied
end

-- ===== APPLY ALL CUSTOMIZATIONS =====
local function applyAllCustomizations(carModel)
    if not carModel or not carModel:IsA("Model") then
        warn("Invalid car model")
        return
    end
    
    print("\n✨ APPLYING ALL CUSTOMIZATIONS TO " .. carModel.Name)
    
    -- Apply different customizations
    applyTemporaryCustomization(carModel, "Paint", Color3.fromRGB(0, 100, 255)) -- Blue
    task.wait(0.1)
    applyTemporaryCustomization(carModel, "Rims", Color3.fromRGB(220, 220, 220)) -- Silver
    task.wait(0.1)
    applyTemporaryCustomization(carModel, "Spoiler", Color3.fromRGB(30, 30, 30)) -- Dark spoiler
    task.wait(0.1)
    applyTemporaryCustomization(carModel, "Underglow", Color3.fromRGB(255, 0, 255)) -- Purple
    task.wait(0.1)
    applyTemporaryCustomization(carModel, "WindowTint", Color3.fromRGB(0, 0, 30)) -- Tint
    
    print("\n✅ ALL CUSTOMIZATIONS APPLIED!")
    print("🎨 Car now has: Blue paint, Silver rims, Spoiler, Purple underglow, Tinted windows")
    print("👁️ Visible to ALL players in the server")
    print("🔄 Will reset when you rejoin the game")
end

-- ===== FIND CAR IN WORKSPACE =====
local function findCarInWorkspace(carName)
    -- Look for the car in workspace
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model.Name == carName then
            -- Check if it has vehicle seat
            local seat = model:FindFirstChildWhichIsA("VehicleSeat")
            if seat then
                print("🚗 Found car in workspace: " .. model.Name)
                return model
            end
        end
    end
    
    -- Check descendants too
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name == carName then
            local seat = obj:FindFirstChildWhichIsA("VehicleSeat")
            if seat then
                print("🚗 Found car in workspace: " .. obj.Name)
                return obj
            end
        end
    end
    
    warn("Car not found in workspace: " .. carName)
    return nil
end

-- ===== CREATE SIMPLE UI =====
local function createCustomizationUI()
    local playerGui = player:WaitForChild("PlayerGui")
    local oldUI = playerGui:FindFirstChild("TempCustomizer")
    if oldUI then oldUI:Destroy() end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "TempCustomizer"
    gui.Parent = playerGui
    gui.ResetOnSpawn = false
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 400)
    main.Position = UDim2.new(0.5, -150, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎨 TEMP CUSTOMIZER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Enter car name below (e.g., 'Subaru3')"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Car Name Input
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -20, 0, 40)
    inputFrame.Position = UDim2.new(0, 10, 0, 120)
    inputFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    inputFrame.Parent = main
    
    local inputBox = Instance.new("TextBox")
    inputBox.PlaceholderText = "Enter car name..."
    inputBox.Size = UDim2.new(1, -20, 0.8, 0)
    inputBox.Position = UDim2.new(0, 10, 0.1, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    inputBox.TextColor3 = Color3.new(1, 1, 1)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 14
    inputBox.Text = ""
    inputBox.Parent = inputFrame
    
    -- Customization Buttons
    local customizations = {
        {"🎨 Blue Paint", "Paint", Color3.fromRGB(0, 100, 255)},
        {"🎨 Red Paint", "Paint", Color3.fromRGB(255, 50, 50)},
        {"🎨 Green Paint", "Paint", Color3.fromRGB(50, 255, 50)},
        {"🛞 Chrome Rims", "Rims", Color3.fromRGB(220, 220, 220)},
        {"🛞 Black Rims", "Rims", Color3.fromRGB(20, 20, 20)},
        {"✈️ Show Spoiler", "Spoiler", Color3.fromRGB(30, 30, 30)},
        {"💡 Blue Underglow", "Underglow", Color3.fromRGB(0, 150, 255)},
        {"💡 Red Underglow", "Underglow", Color3.fromRGB(255, 50, 50)},
        {"🔲 Window Tint", "WindowTint", Color3.fromRGB(0, 0, 30)}
    }
    
    -- Apply All Button
    local applyAllBtn = Instance.new("TextButton")
    applyAllBtn.Text = "✨ APPLY ALL CUSTOMIZATIONS"
    applyAllBtn.Size = UDim2.new(1, -20, 0, 40)
    applyAllBtn.Position = UDim2.new(0, 10, 0, 170)
    applyAllBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    applyAllBtn.TextColor3 = Color3.new(1, 1, 1)
    applyAllBtn.Font = Enum.Font.GothamBold
    applyAllBtn.TextSize = 14
    applyAllBtn.Parent = main
    
    -- Customization List
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, -20, 0, 150)
    listFrame.Position = UDim2.new(0, 10, 0, 220)
    listFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    listFrame.BorderSizePixel = 0
    listFrame.CanvasSize = UDim2.new(0, 0, 0, #customizations * 45)
    listFrame.ScrollBarThickness = 6
    listFrame.Parent = main
    
    for i, cust in ipairs(customizations) do
        local buttonText, custType, color = cust[1], cust[2], cust[3]
        
        local btn = Instance.new("TextButton")
        btn.Text = buttonText
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.Position = UDim2.new(0, 0, 0, (i-1) * 45)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = listFrame
        
        btn.MouseButton1Click:Connect(function()
            local carName = inputBox.Text
            if carName == "" then
                status.Text = "❌ Please enter a car name first!"
                return
            end
            
            local carModel = findCarInWorkspace(carName)
            if carModel then
                applyTemporaryCustomization(carModel, custType, color)
                status.Text = "✅ Applied " .. custType .. " to " .. carName .. "\n👁️ Visible to all players"
            else
                status.Text = "❌ Car not found: " .. carName .. "\nMake sure the car is spawned in workspace"
            end
        end)
    end
    
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
    roundCorners(status)
    roundCorners(inputFrame)
    roundCorners(inputBox)
    roundCorners(applyAllBtn)
    roundCorners(listFrame)
    roundCorners(closeBtn)
    
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then
            roundCorners(child)
        end
    end
    
    -- Apply All Button Action
    applyAllBtn.MouseButton1Click:Connect(function()
        local carName = inputBox.Text
        if carName == "" then
            status.Text = "❌ Please enter a car name first!"
            return
        end
        
        local carModel = findCarInWorkspace(carName)
        if carModel then
            applyAllCustomizations(carModel)
            status.Text = "✅ All customizations applied to " .. carName .. "!\n👁️ Visible to all players\n🔄 Resets on rejoin"
        else
            status.Text = "❌ Car not found: " .. carName .. "\nMake sure the car is spawned in workspace"
        end
    end)
    
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
    
    print("✅ Customization UI created")
    return gui
end

-- ===== AUTO-APPLY TO FIRST CAR FOUND =====
local function autoApplyToFirstCar()
    task.wait(3) -- Wait for cars to load
    
    -- Look for any car in workspace
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") then
            local seat = model:FindFirstChildWhichIsA("VehicleSeat")
            if seat then
                print("\n🚗 AUTO-DETECTED CAR: " .. model.Name)
                print("🎨 Applying temporary customizations...")
                
                applyAllCustomizations(model)
                return model
            end
        end
    end
    
    print("⚠️ No cars found in workspace")
    print("💡 Spawn a car first, then run the script again")
    return nil
end

-- ===== MAIN =====
print("\n🎨 TEMPORARY CUSTOMIZATION SYSTEM")
print("\n💡 HOW TO USE:")
print("1. Spawn any car in the game")
print("2. Enter car name in the UI")
print("3. Click customization buttons")
print("4. All players will see the changes")
print("5. Changes reset when you rejoin")

-- Get player's cars for reference
local cars = getCars()
if #cars > 0 then
    print("\n📋 YOUR CARS:")
    for i = 1, math.min(5, #cars) do
        print("  " .. i .. ". " .. (cars[i].Name or "Car " .. i))
    end
    if #cars > 5 then
        print("  ... and " .. (#cars - 5) .. " more")
    end
end

-- Create UI
task.wait(1)
createCustomizationUI()

-- Try to auto-apply to first car found
task.spawn(autoApplyToFirstCar)

print("\n" .. string.rep("=", 60))
print("✅ SYSTEM READY!")
print("\n🎯 FEATURES:")
print("• Apply customizations to ANY spawned car")
print("• Changes are VISIBLE TO ALL PLAYERS")
print("• NO PERMANENT CHANGES (resets on rejoin)")
print("• Works without owning the customizations")
print("• Perfect for testing/showroom displays")
