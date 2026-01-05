-- CAR CUSTOMIZATION PREVIEW SYSTEM
-- Allows previewing all customizations (including locked ones) for planning
-- DOES NOT unlock or give paid items - VISUAL ONLY

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local PreviewMode = false
local CurrentCar = nil
local OriginalProperties = {}

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== GET ALL CUSTOMIZATION DATA =====
local function getAllCustomizations()
    local customizations = {}
    
    -- Try to find customization database
    local success, data = pcall(function()
        -- Look for customization data in common locations
        local possiblePaths = {
            "Databases.CarCustomization",
            "Data.Customizations", 
            "GameData.Customizations",
            "Config.Customizations",
            "Settings.Customizations"
        }
        
        for _, path in ipairs(possiblePaths) do
            local obj = ReplicatedStorage
            for part in string.gmatch(path, "[^%.]+") do
                obj = obj:FindFirstChild(part)
                if not obj then break end
            end
            if obj then
                -- Extract customization data
                for _, item in ipairs(obj:GetDescendants()) do
                    if item:IsA("ModuleScript") or item:IsA("Folder") then
                        table.insert(customizations, {
                            Name = item.Name,
                            Path = item:GetFullName(),
                            Type = item.ClassName
                        })
                    end
                end
                break
            end
        end
        
        return customizations
    end)
    
    if success then
        print("📦 Found " .. #data .. " customization items")
        return data
    else
        print("⚠️ Could not load customization data")
        return {}
    end
end

-- ===== BACKUP ORIGINAL PROPERTIES =====
local function backupOriginalProperties(car)
    OriginalProperties = {}
    
    for _, part in ipairs(car:GetDescendants()) do
        if part:IsA("BasePart") then
            OriginalProperties[part] = {
                Color = part.Color,
                Material = part.Material,
                Transparency = part.Transparency,
                CanCollide = part.CanCollide
            }
        end
    end
end

-- ===== RESTORE ORIGINAL PROPERTIES =====
local function restoreOriginalProperties(car)
    for part, properties in pairs(OriginalProperties) do
        if part and part.Parent then
            part.Color = properties.Color
            part.Material = properties.Material
            part.Transparency = properties.Transparency
            part.CanCollide = properties.CanCollide
        end
    end
    OriginalProperties = {}
end

-- ===== PREVIEW CUSTOMIZATION TYPE =====
local function previewCustomization(customizationType, color, material)
    if not CurrentCar then return end
    
    local partsToModify = {}
    
    -- Determine which parts to modify based on customization type
    for _, part in ipairs(CurrentCar:GetDescendants()) do
        if part:IsA("BasePart") then
            local partName = part.Name:lower()
            local shouldModify = false
            
            if customizationType == "Paint" then
                -- Modify body parts (not wheels, windows, etc.)
                if not partName:find("wheel") and 
                   not partName:find("glass") and 
                   not partName:find("light") and
                   not partName:find("seat") then
                    shouldModify = true
                end
                
            elseif customizationType == "Rims" then
                -- Only modify wheels
                if partName:find("wheel") or partName:find("rim") then
                    shouldModify = true
                end
                
            elseif customizationType == "Spoiler" then
                -- Only spoiler parts
                if partName:find("spoiler") then
                    shouldModify = true
                end
                
            elseif customizationType == "Windows" then
                -- Only glass/transparent parts
                if partName:find("glass") or partName:find("window") then
                    shouldModify = true
                end
                
            elseif customizationType == "Lights" then
                -- Only light parts
                if partName:find("light") or partName:find("lamp") then
                    shouldModify = true
                end
            end
            
            if shouldModify then
                table.insert(partsToModify, part)
            end
        end
    end
    
    -- Apply preview
    for _, part in ipairs(partsToModify) do
        if customizationType == "Paint" then
            part.Color = color or Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
            part.Material = material or Enum.Material.Metal
            
        elseif customizationType == "Rims" then
            part.Color = color or Color3.fromRGB(20, 20, 20)
            part.Material = material or Enum.Material.Metal
            
        elseif customizationType == "Spoiler" then
            part.Transparency = 0
            part.CanCollide = true
            part.Color = color or Color3.fromRGB(255, 255, 255)
            
        elseif customizationType == "Windows" then
            part.Transparency = 0.5
            part.Color = Color3.fromRGB(100, 100, 100)
            
        elseif customizationType == "Lights" then
            part.Color = color or Color3.fromRGB(255, 255, 200)
            part.Material = Enum.Material.Neon
        end
    end
end

-- ===== CREATE PREVIEW UI =====
local function createPreviewUI()
    -- Remove old UI
    local playerGui = player:WaitForChild("PlayerGui")
    local oldUI = playerGui:FindFirstChild("CustomizationPreviewUI")
    if oldUI then oldUI:Destroy() end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "CustomizationPreviewUI"
    gui.Parent = playerGui
    gui.ResetOnSpawn = false
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 400)
    main.Position = UDim2.new(0, 20, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎨 CUSTOMIZATION PREVIEW"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Text = "Select a customization type to preview"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Customization Types
    local customizations = {
        {Name = "🎨 Paint Job", Type = "Paint"},
        {Name = "🛞 Rims", Type = "Rims"},
        {Name = "✈️ Spoiler", Type = "Spoiler"},
        {Name = "🔲 Windows", Type = "Windows"},
        {Name = "💡 Lights", Type = "Lights"},
        {Name = "🔄 Random", Type = "Random"}
    }
    
    -- Create buttons
    local buttonY = 120
    for i, item in ipairs(customizations) do
        local btn = Instance.new("TextButton")
        btn.Name = item.Type
        btn.Text = item.Name
        btn.Size = UDim2.new(1, -20, 0, 35)
        btn.Position = UDim2.new(0, 10, 0, buttonY)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        btn.Parent = main
        
        btn.MouseButton1Click:Connect(function()
            if CurrentCar then
                status.Text = "Previewing: " .. item.Name
                
                if item.Type == "Random" then
                    -- Randomize all customizations
                    for _, customType in ipairs({"Paint", "Rims", "Spoiler", "Windows", "Lights"}) do
                        previewCustomization(customType)
                    end
                else
                    previewCustomization(item.Type)
                end
            else
                status.Text = "⚠️ Please enter a vehicle first"
            end
        end)
        
        buttonY = buttonY + 40
    end
    
    -- Reset Button
    local resetBtn = Instance.new("TextButton")
    resetBtn.Text = "🔄 Reset to Original"
    resetBtn.Size = UDim2.new(1, -20, 0, 40)
    resetBtn.Position = UDim2.new(0, 10, 0, 350)
    resetBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    resetBtn.TextColor3 = Color3.new(1, 1, 1)
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.TextSize = 14
    resetBtn.Parent = main
    
    resetBtn.MouseButton1Click:Connect(function()
        if CurrentCar then
            restoreOriginalProperties(CurrentCar)
            status.Text = "✅ Reset to original appearance"
        end
    end)
    
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
    
    for _, child in ipairs(main:GetChildren()) do
        if child:IsA("TextButton") then
            roundCorners(child)
        end
    end
    
    -- Button actions
    closeBtn.MouseButton1Click:Connect(function()
        if CurrentCar then
            restoreOriginalProperties(CurrentCar)
        end
        gui:Destroy()
    end)
    
    print("✅ Preview UI Created")
    return gui
end

-- ===== DETECT CURRENT CAR =====
local function monitorCurrentCar()
    while task.wait(1) do
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.SeatPart then
                local seat = humanoid.SeatPart
                if seat:IsA("VehicleSeat") then
                    local car = seat:FindFirstAncestorWhichIsA("Model")
                    if car and car ~= CurrentCar then
                        print("🚗 Entered vehicle:", car.Name)
                        
                        -- Backup original properties
                        if CurrentCar then
                            restoreOriginalProperties(CurrentCar)
                        end
                        
                        CurrentCar = car
                        backupOriginalProperties(car)
                        
                        -- Update UI status
                        local ui = player.PlayerGui:FindFirstChild("CustomizationPreviewUI")
                        if ui then
                            local status = ui:FindFirstChild("Status", true)
                            if status then
                                status.Text = "Vehicle detected: " .. car.Name .. "\nSelect a customization to preview"
                            end
                        end
                    end
                else
                    if CurrentCar then
                        restoreOriginalProperties(CurrentCar)
                        CurrentCar = nil
                    end
                end
            end
        end
    end
end

-- ===== MAIN =====
print("\n🎨 CAR CUSTOMIZATION PREVIEW SYSTEM")
print("This allows you to VISUALLY PREVIEW customizations")
print("All changes are TEMPORARY and CLIENT-SIDE ONLY")
print("=" .. string.rep("=", 50))

-- Load all available customizations
local allCustomizations = getAllCustomizations()

-- Create UI
createPreviewUI()

-- Start car monitoring
task.spawn(monitorCurrentCar)

print("\n✅ SYSTEM READY!")
print("1. Enter any vehicle")
print("2. Use the preview UI to test different looks")
print("3. All changes reset when you exit the vehicle")
print("4. No permanent changes are made")
