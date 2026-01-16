-- CLIENT-SIDE CUSTOMIZATION UNLOCKER
-- Makes all items APPEAR unlocked on YOUR screen only

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🎨 CUSTOMIZATION UNLOCKER")
print("Makes all items APPEAR unlocked (client-side only)")

-- Find the customization UI
local customizationUI = LocalPlayer.PlayerGui:FindFirstChild("Customization")
if customizationUI then
    print("✅ Found Customization UI!")
else
    print("❌ Customization UI not found in PlayerGui")
    -- Try to find it elsewhere
    customizationUI = LocalPlayer.PlayerGui:WaitForChild("Customization", 5)
end

-- Get customization databases
local CarCustomization
local Icons
pcall(function()
    CarCustomization = require(ReplicatedStorage.Databases.CarCustomization)
    Icons = require(ReplicatedStorage.Databases.Icons)
    print("✅ Found customization databases")
end)

-- Store all customization categories
local allCategories = {
    "BodyKit", "Spoiler", "FrontBumper", "RearBumper", "Skirt",
    "Hood", "Exhaust", "Grille", "Headlights", "Taillights",
    "WindowTint", "LicensePlate", "Neon", "Underglow", "Wrap",
    "Rims", "Tires", "WindowSticker", "Horn", "EngineSound"
}

-- Function to unlock ALL items visually
local function unlockAllVisuals()
    print("\n🔓 UNLOCKING ALL ITEMS VISUALLY...")
    
    if not customizationUI then
        print("❌ No customization UI found")
        return
    end
    
    -- Find the items container
    local itemsContainer = customizationUI:FindFirstChild("Bottom")
    if itemsContainer then
        itemsContainer = itemsContainer:FindFirstChild("Customization")
        if itemsContainer then
            itemsContainer = itemsContainer:FindFirstChild("Items")
        end
    end
    
    -- Also check Pages > List
    local listContainer = customizationUI:FindFirstChild("Pages")
    if listContainer then
        listContainer = listContainer:FindFirstChild("List")
    end
    
    print("Searching for locked items to unlock visually...")
    
    local unlockedCount = 0
    
    -- Method 1: Direct UI manipulation
    if itemsContainer then
        for _, itemFrame in pairs(itemsContainer:GetDescendants()) do
            if itemFrame:IsA("Frame") or itemFrame:IsA("ImageButton") then
                -- Look for lock icons or disabled states
                for _, child in pairs(itemFrame:GetDescendants()) do
                    -- Remove lock icons
                    if child:IsA("ImageLabel") and (child.Name:find("Lock") or child.Image:find("Lock")) then
                        child.Visible = false
                        unlockedCount = unlockedCount + 1
                    end
                    
                    -- Enable buttons
                    if child:IsA("TextButton") or child:IsA("ImageButton") then
                        child.Active = true
                        child.AutoButtonColor = true
                        child.BackgroundTransparency = 0
                    end
                    
                    -- Change "Locked" text to "Unlocked"
                    if child:IsA("TextLabel") and child.Text:find("Locked") then
                        child.Text = "Unlocked"
                        child.TextColor3 = Color3.new(0, 1, 0)
                    end
                end
            end
        end
    end
    
    -- Method 2: Create fake unlocked items
    if listContainer then
        print("Creating fake unlocked items in list...")
        
        -- Clear existing (optional)
        for _, child in pairs(listContainer:GetChildren()) do
            if child.Name ~= "UIListLayout" then
                child:Destroy()
            end
        end
        
        -- Create fake unlocked items for each category
        for _, category in pairs(allCategories) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Name = category .. "_UNLOCKED"
            itemFrame.Size = UDim2.new(1, 0, 0, 50)
            itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            itemFrame.BorderSizePixel = 1
            
            local itemName = Instance.new("TextLabel")
            itemName.Text = category .. " - UNLOCKED"
            itemName.Size = UDim2.new(0.7, 0, 1, 0)
            itemName.TextColor3 = Color3.new(0, 1, 0)
            itemName.Font = Enum.Font.SourceSansBold
            itemName.Parent = itemFrame
            
            local equipButton = Instance.new("TextButton")
            equipButton.Text = "EQUIP"
            equipButton.Size = UDim2.new(0.3, 0, 1, 0)
            equipButton.Position = UDim2.new(0.7, 0, 0, 0)
            equipButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            equipButton.TextColor3 = Color3.new(1, 1, 1)
            equipButton.Parent = itemFrame
            
            itemFrame.Parent = listContainer
            unlockedCount = unlockedCount + 1
        end
    end
    
    print("✅ Visually unlocked " .. unlockedCount .. " items")
    print("⚠️ Note: This is CLIENT-SIDE only!")
    print("Other players won't see your unlocked items")
end

-- Function to show ALL cars in UI
local function showAllCars()
    print("\n🚗 SHOWING ALL CARS VISUALLY...")
    
    -- Try to find car selection UI
    local carUI = LocalPlayer.PlayerGui:FindFirstChild("Garage") or 
                  LocalPlayer.PlayerGui:FindFirstChild("Cars") or
                  LocalPlayer.PlayerGui:FindFirstChild("Showroom")
    
    if carUI then
        print("Found car UI:", carUI.Name)
        
        -- Look for car containers
        for _, container in pairs(carUI:GetDescendants()) do
            if container:IsA("ScrollingFrame") or container:IsA("Frame") then
                if container.Name:find("Car") or container.Name:find("List") then
                    print("Found car container:", container:GetFullName())
                    
                    -- Create fake car entries
                    local fakeCars = {
                        "Subaru3", "Bugatti", "Ferrari", "Lamborghini",
                        "Porsche", "McLaren", "Audi", "BMW", "Mercedes",
                        "Tesla", "Ford", "Chevrolet", "Toyota", "Honda"
                    }
                    
                    for i, carName in pairs(fakeCars) do
                        local carFrame = Instance.new("Frame")
                        carFrame.Name = carName .. "_FAKE"
                        carFrame.Size = UDim2.new(0, 100, 0, 120)
                        carFrame.Position = UDim2.new(0, ((i-1) % 5) * 110, 0, math.floor((i-1)/5) * 130)
                        carFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                        carFrame.BorderSizePixel = 2
                        carFrame.BorderColor3 = Color3.new(0, 0.7, 1)
                        
                        local carIcon = Instance.new("TextLabel")
                        carIcon.Text = "🚗 " .. carName
                        carIcon.Size = UDim2.new(1, 0, 0.7, 0)
                        carIcon.TextColor3 = Color3.new(1, 1, 1)
                        carIcon.Font = Enum.Font.SourceSansBold
                        carIcon.Parent = carFrame
                        
                        local selectButton = Instance.new("TextButton")
                        selectButton.Text = "SELECT"
                        selectButton.Size = UDim2.new(1, 0, 0.3, 0)
                        selectButton.Position = UDim2.new(0, 0, 0.7, 0)
                        selectButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                        selectButton.TextColor3 = Color3.new(1, 1, 1)
                        selectButton.Parent = carFrame
                        
                        carFrame.Parent = container
                    end
                end
            end
        end
    else
        print("❌ Car UI not found")
    end
    
    print("✅ Added fake cars to UI (visual only)")
end

-- Function to create fake customization menu
local function createFakeCustomizationMenu()
    print("\n🎨 CREATING FAKE CUSTOMIZATION MENU...")
    
    -- Remove old fake menu if exists
    local oldMenu = LocalPlayer.PlayerGui:FindFirstChild("FakeCustomization")
    if oldMenu then
        oldMenu:Destroy()
    end
    
    -- Create new fake menu
    local fakeMenu = Instance.new("ScreenGui")
    fakeMenu.Name = "FakeCustomization"
    fakeMenu.DisplayOrder = 999
    fakeMenu.Parent = LocalPlayer.PlayerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 3
    mainFrame.BorderColor3 = Color3.new(0, 1, 0)
    mainFrame.Parent = fakeMenu
    
    local title = Instance.new("TextLabel")
    title.Text = "🎨 ALL CUSTOMIZATIONS UNLOCKED 🎨"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Text = "(Client-side visual only - for screenshots)"
    subtitle.Size = UDim2.new(1, 0, 0, 20)
    subtitle.Position = UDim2.new(0, 0, 0.1, 0)
    subtitle.TextColor3 = Color3.new(1, 0, 0)
    subtitle.Parent = mainFrame
    
    -- Create scrolling frame for items
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 0.7, 0)
    scrollFrame.Position = UDim2.new(0, 10, 0.2, 0)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #allCategories * 60)
    scrollFrame.Parent = mainFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollFrame
    
    -- Add all categories as "unlocked"
    for i, category in pairs(allCategories) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, 0, 0, 50)
        itemFrame.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(60, 60, 80)
        
        local itemName = Instance.new("TextLabel")
        itemName.Text = "✅ " .. category .. " - ALL ITEMS UNLOCKED"
        itemName.Size = UDim2.new(0.7, 0, 1, 0)
        itemName.TextColor3 = Color3.new(0, 1, 0)
        itemName.Font = Enum.Font.SourceSansBold
        itemName.TextXAlignment = Enum.TextXAlignment.Left
        itemName.PaddingLeft = UDim.new(0, 10)
        itemName.Parent = itemFrame
        
        local equipButton = Instance.new("TextButton")
        equipButton.Text = "EQUIP RANDOM"
        equipButton.Size = UDim2.new(0.3, 0, 0.7, 0)
        equipButton.Position = UDim2.new(0.7, 0, 0.15, 0)
        equipButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        equipButton.TextColor3 = Color3.new(1, 1, 1)
        equipButton.Parent = itemFrame
        
        equipButton.MouseButton1Click:Connect(function()
            print("Equipping random " .. category .. " (visual only)")
            -- Just show a message since it's visual only
            local notification = Instance.new("TextLabel")
            notification.Text = "Equipped random " .. category .. " (visual)"
            notification.Size = UDim2.new(1, 0, 0, 30)
            notification.Position = UDim2.new(0, 0, 0.9, 0)
            notification.TextColor3 = Color3.new(0, 1, 0)
            notification.BackgroundTransparency = 1
            notification.Parent = mainFrame
            
            wait(2)
            notification:Destroy()
        end)
        
        itemFrame.Parent = scrollFrame
    end
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "CLOSE MENU"
    closeButton.Size = UDim2.new(0.3, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0.35, 0, 0.92, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = mainFrame
    
    closeButton.MouseButton1Click:Connect(function()
        fakeMenu:Destroy()
    end)
    
    print("✅ Fake customization menu created!")
    print("Perfect for screenshots/videos!")
end

-- Function to create screenshot mode
local function screenshotMode()
    print("\n📸 SCREENSHOT MODE ACTIVATED")
    
    -- Hide all other GUIs except our fake ones
    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        if gui.Name ~= "FakeCustomization" and gui.Name ~= "CustomizationExploitUI" then
            gui.Enabled = false
        end
    end
    
    -- Create epic background
    local background = Instance.new("ScreenGui")
    background.Name = "ScreenshotBackground"
    background.DisplayOrder = -1
    background.Parent = LocalPlayer.PlayerGui
    
    local bgFrame = Instance.new("Frame")
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    bgFrame.BackgroundTransparency = 0.3
    bgFrame.Parent = background
    
    -- Add some effects
    for i = 1, 20 do
        local star = Instance.new("Frame")
        star.Size = UDim2.new(0, math.random(2, 5), 0, math.random(2, 5))
        star.Position = UDim2.new(0, math.random(0, 1000), 0, math.random(0, 600))
        star.BackgroundColor3 = Color3.new(1, 1, 1)
        star.BorderSizePixel = 0
        star.Parent = bgFrame
        
        -- Sparkle animation
        spawn(function()
            while star and star.Parent do
                star.BackgroundTransparency = math.random(0, 50) / 100
                wait(math.random(10, 30) / 100)
            end
        end)
    end
    
    print("✅ Screenshot mode ready!")
    print("All other GUIs hidden")
    print("Take screenshots now!")
    
    -- Auto-revert after 30 seconds
    wait(30)
    background:Destroy()
    for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
        gui.Enabled = true
    end
    print("Screenshot mode ended")
end

-- CREATE CONTROL UI
local controlUI = Instance.new("ScreenGui")
controlUI.Name = "CustomizationExploitUI"
controlUI.Parent = LocalPlayer.PlayerGui

local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(0, 250, 0, 300)
controlFrame.Position = UDim2.new(0, 20, 0, 100)
controlFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
controlFrame.BorderSizePixel = 3
controlFrame.BorderColor3 = Color3.new(0, 0.7, 1)
controlFrame.Parent = controlUI

local controlTitle = Instance.new("TextLabel")
controlTitle.Text = "🎨 VISUAL UNLOCKER"
controlTitle.Size = UDim2.new(1, 0, 0, 30)
controlTitle.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
controlTitle.TextColor3 = Color3.new(1, 1, 1)
controlTitle.Font = Enum.Font.SourceSansBold
controlTitle.Parent = controlFrame

-- Buttons
local buttons = {
    {"🔓 Unlock All Visuals", unlockAllVisuals},
    {"🚗 Show All Cars", showAllCars},
    {"🎨 Fake Menu", createFakeCustomizationMenu},
    {"📸 Screenshot Mode", screenshotMode},
    {"⚠️ Reset GUI", function()
        for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if gui.Name:find("Fake") or gui.Name == "ScreenshotBackground" then
                gui:Destroy()
            end
        end
        print("✅ Removed fake GUIs")
    end}
}

for i, btnData in ipairs(buttons) do
    local btn = Instance.new("TextButton")
    btn.Text = btnData[1]
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0.1 + (i * 0.16), 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = controlFrame
    btn.MouseButton1Click:Connect(btnData[2])
end

print("\n" .. string.rep("=", 60))
print("🎨 CLIENT-SIDE CUSTOMIZATION UNLOCKER")
print(string.rep("=", 60))
print("WHAT THIS DOES:")
print("• Makes items APPEAR unlocked on YOUR screen")
print("• Creates fake menus for screenshots")
print("• Shows all cars visually")
print("• PERFECT for content creation!")
print(string.rep("=", 60))
print("⚠️ IMPORTANT:")
print("• This is VISUAL ONLY")
print("• Other players won't see your unlocks")
print("• Items aren't actually unlocked on server")
print("• Use for screenshots/videos only")
print(string.rep("=", 60))

-- Make global
_G.unlockvisual = unlockAllVisuals
_G.fakemenu = createFakeCustomizationMenu
_G.screenshot = screenshotMode
_G.showcars = showAllCars

print("\nConsole commands:")
print("_G.unlockvisual() - Unlock items visually")
print("_G.fakemenu() - Create fake customization menu")
print("_G.screenshot() - Enter screenshot mode")
print("_G.showcars() - Show all cars")
