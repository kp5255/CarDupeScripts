-- WRAP UNLOCKER FOR SELECTED CAR
-- Targets exact UI structure: PlayerGui.Customization.Bottom.Customization.Items.Pages.List.Wrap

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

print("🎯 WRAP UNLOCKER FOR SELECTED CAR")
print("Targeting: PlayerGui.Customization.Bottom.Customization.Items.Pages.List.Wrap")

-- Find the exact UI structure
local function findWrapUI()
    print("\n🔍 FINDING WRAP UI...")
    
    local customizationUI = LocalPlayer.PlayerGui:FindFirstChild("Customization")
    if not customizationUI then
        print("❌ Customization UI not found")
        return nil
    end
    
    local bottom = customizationUI:FindFirstChild("Bottom")
    if not bottom then
        print("❌ Bottom not found")
        return nil
    end
    
    local customization = bottom:FindFirstChild("Customization")
    if not customization then
        print("❌ Customization not found")
        return nil
    end
    
    local items = customization:FindFirstChild("Items")
    if not items then
        print("❌ Items not found")
        return nil
    end
    
    local pages = items:FindFirstChild("Pages")
    if not pages then
        print("❌ Pages not found")
        return nil
    end
    
    local list = pages:FindFirstChild("List")
    if not list then
        print("❌ List not found")
        return nil
    end
    
    local wrap = list:FindFirstChild("Wrap")
    if not wrap then
        print("❌ Wrap category not found in List")
        -- Try to find Wrap elsewhere
        for _, child in pairs(list:GetChildren()) do
            if child.Name:find("Wrap") then
                print("Found similar:", child.Name)
                return child
            end
        end
        return nil
    end
    
    print("✅ Found Wrap UI at:", wrap:GetFullName())
    return wrap
end

-- Get currently selected car
local function getSelectedCar()
    print("\n🚗 FINDING SELECTED CAR...")
    
    -- Method 1: Check garage UI
    local garageUI = LocalPlayer.PlayerGui:FindFirstChild("Garage")
    if garageUI then
        for _, element in pairs(garageUI:GetDescendants()) do
            if element:IsA("TextLabel") and element.Text:find("Selected:") then
                local carName = element.Text:gsub("Selected: ", "")
                print("✅ Selected car from Garage:", carName)
                return carName
            end
        end
    end
    
    -- Method 2: Check current vehicle
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("Model") and (part.Name:find("Car") or part.Name:find("Vehicle")) then
                print("✅ Current vehicle:", part.Name)
                return part.Name
            end
        end
    end
    
    -- Method 3: Check customization UI for car reference
    local customizationUI = LocalPlayer.PlayerGui:FindFirstChild("Customization")
    if customizationUI then
        for _, element in pairs(customizationUI:GetDescendants()) do
            if element:IsA("TextLabel") and (element.Text:find("Car:") or element.Text:find("Vehicle:")) then
                local carName = element.Text:gsub("Car: ", ""):gsub("Vehicle: ", "")
                print("✅ Car from Customization UI:", carName)
                return carName
            end
        end
    end
    
    print("❌ Could not detect selected car")
    print("Please select a car in garage first!")
    return nil
end

-- Get all available wraps for a specific car
local function getWrapsForCar(carName)
    print("\n🎨 FINDING WRAPS FOR CAR:", carName)
    
    local wraps = {}
    
    -- Check ReplicatedStorage for wrap data
    local customizationFolder = ReplicatedStorage:FindFirstChild("Customization")
    if customizationFolder then
        -- Look for Wrap category
        local wrapFolder = customizationFolder:FindFirstChild("Wrap")
        if wrapFolder then
            print("Found Wrap folder with items:")
            for _, wrapItem in pairs(wrapFolder:GetChildren()) do
                if wrapItem:IsA("Model") or wrapItem:IsA("Part") then
                    table.insert(wraps, wrapItem.Name)
                    print("  • " .. wrapItem.Name)
                end
            end
        end
        
        -- Check for car-specific wraps
        local wrapsPerCar = customizationFolder:FindFirstChild("WrapsPerCar")
        if wrapsPerCar then
            local carWraps = wrapsPerCar:FindFirstChild(carName)
            if carWraps then
                print("\nFound car-specific wraps for", carName)
                for _, wrapItem in pairs(carWraps:GetChildren()) do
                    table.insert(wraps, carName .. "/" .. wrapItem.Name)
                    print("  • " .. wrapItem.Name .. " (car-specific)")
                end
            end
        end
    end
    
    -- Also check databases
    pcall(function()
        local CarCustomization = require(ReplicatedStorage.Databases.CarCustomization)
        local wrapData = CarCustomization.Wrap
        if wrapData and wrapData.GetAllItems then
            local allWraps = wrapData.GetAllItems()
            print("\nFound wraps in database:")
            for wrapName, wrapInfo in pairs(allWraps) do
                if not table.find(wraps, wrapName) then
                    table.insert(wraps, wrapName)
                    print("  • " .. wrapName .. " (" .. (wrapInfo.Rarity or "Common") .. ")")
                end
            end
        end
    end)
    
    print("✅ Total wraps found:", #wraps)
    return wraps
end

-- Unlock wraps in UI for selected car
local function unlockWrapsInUI()
    print("\n🔓 UNLOCKING WRAPS IN UI...")
    
    local wrapUI = findWrapUI()
    if not wrapUI then
        print("❌ Could not find Wrap UI")
        return
    end
    
    local selectedCar = getSelectedCar()
    if not selectedCar then
        print("❌ No car selected")
        return
    end
    
    local wraps = getWrapsForCar(selectedCar)
    if #wraps == 0 then
        print("❌ No wraps found for this car")
        return
    end
    
    -- Clear existing wrap items (optional)
    for _, child in pairs(wrapUI:GetChildren()) do
        if child.Name ~= "UIListLayout" then
            child:Destroy()
        end
    end
    
    -- Add all wraps as unlocked
    local unlockedCount = 0
    
    for i, wrapName in pairs(wraps) do
        -- Create wrap item frame
        local wrapFrame = Instance.new("Frame")
        wrapFrame.Name = "Wrap_" .. wrapName
        wrapFrame.Size = UDim2.new(1, -10, 0, 60)
        wrapFrame.Position = UDim2.new(0, 5, 0, (i-1) * 65)
        wrapFrame.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(60, 60, 80)
        wrapFrame.BorderSizePixel = 1
        
        -- Wrap name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = "✅ " .. wrapName
        nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
        nameLabel.TextColor3 = Color3.new(0, 1, 0)
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.PaddingLeft = UDim.new(0, 10)
        nameLabel.Parent = wrapFrame
        
        -- For car-specific wraps
        if wrapName:find("/") then
            local carSpecific = Instance.new("TextLabel")
            carSpecific.Text = "For: " .. selectedCar
            carSpecific.Size = UDim2.new(0.7, 0, 0, 15)
            carSpecific.Position = UDim2.new(0, 10, 0.7, 0)
            carSpecific.TextColor3 = Color3.new(1, 1, 0)
            carSpecific.TextSize = 12
            carSpecific.Parent = wrapFrame
        end
        
        -- Equip button
        local equipBtn = Instance.new("TextButton")
        equipBtn.Text = "EQUIP"
        equipBtn.Size = UDim2.new(0.2, 0, 0.6, 0)
        equipBtn.Position = UDim2.new(0.75, 0, 0.2, 0)
        equipBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        equipBtn.TextColor3 = Color3.new(1, 1, 1)
        equipBtn.Font = Enum.Font.SourceSansBold
        equipBtn.Parent = wrapFrame
        
        equipBtn.MouseButton1Click:Connect(function()
            print("Equipping wrap:", wrapName, "on car:", selectedCar)
            equipWrapOnCar(wrapName, selectedCar)
        end)
        
        -- Preview button
        local previewBtn = Instance.new("TextButton")
        previewBtn.Text = "PREVIEW"
        previewBtn.Size = UDim2.new(0.2, 0, 0.6, 0)
        previewBtn.Position = UDim2.new(0.55, 0, 0.2, 0)
        previewBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        previewBtn.TextColor3 = Color3.new(1, 1, 1)
        previewBtn.Parent = wrapFrame
        
        previewBtn.MouseButton1Click:Connect(function()
            previewWrapOnCar(wrapName, selectedCar)
        end)
        
        wrapFrame.Parent = wrapUI
        unlockedCount = unlockedCount + 1
    end
    
    print("✅ Added " .. unlockedCount .. " wraps to UI")
    print("⚠️ UI only - for client-side display")
end

-- Actually equip a wrap on the car (client-side)
local function equipWrapOnCar(wrapName, carName)
    print("\n🔧 EQUIPPING WRAP:", wrapName, "on", carName)
    
    -- Generate fake item data
    local fakeWrapItem = {
        Id = HttpService:GenerateGUID(false),
        Type = "Customization",
        Category = "Wrap",
        Name = wrapName,
        CarName = carName,
        ObtainedAt = os.time(),
        Rarity = "Legendary"
    }
    
    -- Try to use the game's customization system
    pcall(function()
        local CustomizationItemsRemotes = require(ReplicatedStorage.Remotes.Services.CustomizationItemsRemotes)
        if CustomizationItemsRemotes and CustomizationItemsRemotes.EquipItem then
            CustomizationItemsRemotes.EquipItem:InvokeServer("Wrap", wrapName, carName)
            print("✅ Equipped via game system")
        end
    end)
    
    -- Also try direct remote events
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            if remote.Name:find("Wrap") or remote.Name:find("Customization") then
                pcall(function()
                    if remote:IsA("RemoteFunction") then
                        remote:InvokeServer("Wrap", wrapName, carName)
                    else
                        remote:FireServer("Wrap", wrapName, carName)
                    end
                    print("Sent to remote:", remote.Name)
                end)
            end
        end
    end
    
    -- Apply visual wrap to current car
    applyWrapVisual(wrapName, carName)
    
    print("✅ Wrap equipped (client-side)")
    print("Visible to you, may not persist")
end

-- Apply wrap visual to car (client-side only)
local function applyWrapVisual(wrapName, carName)
    print("🎨 APPLYING WRAP VISUAL...")
    
    -- Find the car in workspace
    local targetCar = nil
    
    -- Check player's current vehicle
    local character = LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("Model") and part.Name == carName then
                targetCar = part
                break
            end
        end
    end
    
    -- If not found, search workspace
    if not targetCar then
        targetCar = workspace:FindFirstChild(carName)
    end
    
    if targetCar then
        print("Found car to apply wrap:", targetCar.Name)
        
        -- Remove existing wrap materials
        for _, part in pairs(targetCar:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Try to apply a special material/color
                part.BrickColor = BrickColor.new("Bright blue") -- Visual indicator
                part.Material = EnumMaterial.Neon
                
                -- Add a decal if possible
                local decal = Instance.new("Decal")
                decal.Name = "Wrap_" .. wrapName
                decal.Texture = "rbxassetid://276934160" -- Some texture
                decal.Face = Enum.NormalId.Top
                decal.Parent = part
            end
        end
        
        print("✅ Applied wrap visual to car")
    else
        print("❌ Could not find car to apply wrap")
    end
end

-- Preview wrap on car
local function previewWrapOnCar(wrapName, carName)
    print("\n👁️ PREVIEWING WRAP:", wrapName)
    
    -- Create preview window
    local previewUI = Instance.new("ScreenGui")
    previewUI.Name = "WrapPreview"
    previewUI.DisplayOrder = 999
    previewUI.Parent = LocalPlayer.PlayerGui
    
    local previewFrame = Instance.new("Frame")
    previewFrame.Size = UDim2.new(0, 400, 0, 300)
    previewFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    previewFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    previewFrame.BorderSizePixel = 3
    previewFrame.BorderColor3 = Color3.new(0, 1, 0)
    previewFrame.Parent = previewUI
    
    local title = Instance.new("TextLabel")
    title.Text = "👁️ WRAP PREVIEW"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.Parent = previewFrame
    
    local wrapInfo = Instance.new("TextLabel")
    wrapInfo.Text = "Wrap: " .. wrapName .. "\nCar: " .. carName
    wrapInfo.Size = UDim2.new(1, 0, 0, 60)
    wrapInfo.Position = UDim2.new(0, 0, 0.15, 0)
    wrapInfo.TextColor3 = Color3.new(1, 1, 1)
    wrapInfo.TextSize = 18
    wrapInfo.Parent = previewFrame
    
    local previewText = Instance.new("TextLabel")
    previewText.Text = "This wrap would be applied to your " .. carName
    previewText.Size = UDim2.new(1, 0, 0, 40)
    previewText.Position = UDim2.new(0, 0, 0.4, 0)
    previewText.TextColor3 = Color3.new(1, 1, 0)
    previewText.Parent = previewFrame
    
    local equipBtn = Instance.new("TextButton")
    equipBtn.Text = "EQUIP THIS WRAP"
    equipBtn.Size = UDim2.new(0.6, 0, 0, 50)
    equipBtn.Position = UDim2.new(0.2, 0, 0.7, 0)
    equipBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    equipBtn.TextColor3 = Color3.new(1, 1, 1)
    equipBtn.Font = Enum.Font.SourceSansBold
    equipBtn.Parent = previewFrame
    
    equipBtn.MouseButton1Click:Connect(function()
        equipWrapOnCar(wrapName, carName)
        previewUI:Destroy()
    end)
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "CLOSE"
    closeBtn.Size = UDim2.new(0.3, 0, 0, 30)
    closeBtn.Position = UDim2.new(0.7, 0, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Parent = previewFrame
    
    closeBtn.MouseButton1Click:Connect(function()
        previewUI:Destroy()
    end)
    
    print("✅ Preview window created")
end

-- CREATE CONTROL UI
local controlUI = Instance.new("ScreenGui")
controlUI.Name = "WrapUnlockerUI"
controlUI.Parent = LocalPlayer.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 250)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.new(0, 0.7, 1)
mainFrame.Parent = controlUI

local title = Instance.new("TextLabel")
title.Text = "🎨 WRAP UNLOCKER"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

local subtitle = Instance.new("TextLabel")
subtitle.Text = "For selected car only"
subtitle.Size = UDim2.new(1, 0, 0, 20)
subtitle.Position = UDim2.new(0, 0, 0.12, 0)
subtitle.TextColor3 = Color3.new(1, 1, 0)
subtitle.Parent = mainFrame

-- Car display
local carDisplay = Instance.new("TextLabel")
carDisplay.Name = "CarDisplay"
carDisplay.Text = "Car: Not selected"
carDisplay.Size = UDim2.new(1, 0, 0, 25)
carDisplay.Position = UDim2.new(0, 0, 0.25, 0)
carDisplay.TextColor3 = Color3.new(1, 1, 1)
carDisplay.Parent = mainFrame

-- Buttons
local buttons = {
    {"🔍 Detect Car", function()
        local car = getSelectedCar()
        if car then
            carDisplay.Text = "Car: " .. car
            carDisplay.TextColor3 = Color3.new(0, 1, 0)
        end
    end},
    {"🎨 Unlock All Wraps", unlockWrapsInUI},
    {"✨ Unlock & Equip Best", function()
        local car = getSelectedCar()
        if car then
            equipWrapOnCar(car .. "/LegendaryWrap", car)
        end
    end},
    {"👁️ Preview Wraps", function()
        local car = getSelectedCar()
        if car then
            previewWrapOnCar(car .. "/PreviewWrap", car)
        end
    end},
    {"🔄 Refresh UI", function()
        unlockWrapsInUI()
    end}
}

for i, btnData in ipairs(buttons) do
    local btn = Instance.new("TextButton")
    btn.Text = btnData[1]
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0.35 + (i * 0.13), 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(btnData[2])
end

print("\n" .. string.rep("=", 60))
print("🎯 WRAP UNLOCKER FOR SELECTED CAR")
print(string.rep("=", 60))
print("TARGETING EXACT UI PATH:")
print("PlayerGui.Customization.Bottom.Customization.Items.Pages.List.Wrap")
print(string.rep("=", 60))
print("HOW TO USE:")
print("1. Select a car in Garage first")
print("2. Click '🔍 Detect Car' to confirm")
print("3. Click '🎨 Unlock All Wraps'")
print("4. All wraps will appear in Wrap category")
print("5. Click EQUIP on any wrap")
print(string.rep("=", 60))
print("FEATURES:")
print("• Unlocks wraps FOR SELECTED CAR ONLY")
print("• Shows in exact UI location")
print("• Preview before equipping")
print("• Client-side (disappears on relog)")
print(string.rep("=", 60))

-- Make global
_G.detectcar = getSelectedCar
_G.unlockwraps = unlockWrapsInUI
_G.equipwrap = equipWrapOnCar

print("\nConsole commands:")
print("_G.detectcar() - Detect selected car")
print("_G.unlockwraps() - Unlock all wraps for current car")
print("_G.equipwrap('WrapName', 'CarName') - Equip specific wrap")
