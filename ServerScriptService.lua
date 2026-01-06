-- 🎨 CAR CUSTOMIZATION UNLOCKER
-- Unlocks wraps, bodykits, underglows, wheels, etc.

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== CONFIGURATION =====
local TARGET_ITEMS = {
    "wrap", "paint", "color", "skin", "vinyl",
    "bodykit", "kit", "bumper", "spoiler", "wing",
    "wheel", "rim", "tire", "brake",
    "underglow", "neon", "light", "led",
    "exhaust", "engine", "hood",
    "window", "tint", "sticker", "decals"
}

local IGNORE_ITEMS = {
    "car", "vehicle", "buy", "purchase", "shop", "store", 
    "back", "close", "exit", "menu", "tab", "button"
}

-- ===== CORE UNLOCK FUNCTIONS =====
local function IsCarCosmetic(item)
    if not item then return false end
    
    local name = item.Name:lower()
    local text = ""
    
    -- Get text if available
    if item:IsA("TextButton") or item:IsA("TextLabel") then
        text = item.Text:lower()
    elseif item:FindFirstChildWhichIsA("TextLabel") then
        text = item:FindFirstChildWhichIsA("TextLabel").Text:lower()
    end
    
    -- Check if this is a cosmetic item
    for _, target in ipairs(TARGET_ITEMS) do
        if name:find(target) or text:find(target) then
            -- Make sure it's not in ignore list
            local shouldIgnore = false
            for _, ignore in ipairs(IGNORE_ITEMS) do
                if name == ignore or text == ignore then
                    shouldIgnore = true
                    break
                end
            end
            
            if not shouldIgnore then
                return true
            end
        end
    end
    
    return false
end

local function UnlockSingleItem(item)
    if not item or not item:IsDescendantOf(game) then return false end
    
    local changesMade = 0
    
    -- 1. Remove all lock visuals
    for _, child in pairs(item:GetDescendants()) do
        -- Remove lock images
        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            local imgName = child.Name:lower()
            local imgId = tostring(child.Image):lower()
            
            if imgName:find("lock") or imgId:find("lock") 
               or imgName:find("price") or imgId:find("price") then
                child.Visible = false
                changesMade = changesMade + 1
            end
        end
        
        -- Change locked text
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            local text = child.Text:lower()
            if text:find("locked") or text:find("lock") 
               or text:find("purchase") or text:find("buy") 
               or text:find("$") or text:match("%d+%s*[ckm]") then
                
                if text:find("locked") then
                    child.Text = "UNLOCKED"
                elseif text:find("purchase") or text:find("buy") then
                    child.Text = "EQUIP"
                elseif text:find("$") or text:match("%d+%s*[ckm]") then
                    child.Text = "FREE"
                end
                
                child.TextColor3 = Color3.fromRGB(0, 255, 0)
                changesMade = changesMade + 1
            end
        end
    end
    
    -- 2. Add green border to show it's unlocked
    if not item:FindFirstChild("UnlockedBorder") then
        local border = Instance.new("UIStroke")
        border.Name = "UnlockedBorder"
        border.Color = Color3.fromRGB(0, 255, 0)
        border.Thickness = 2
        border.Parent = item
        changesMade = changesMade + 1
    end
    
    -- 3. Add "OWNED" text
    if not item:FindFirstChild("OwnedLabel") then
        local ownedLabel = Instance.new("TextLabel")
        ownedLabel.Name = "OwnedLabel"
        ownedLabel.Text = "✓ OWNED"
        ownedLabel.Size = UDim2.new(1, 0, 0, 20)
        ownedLabel.Position = UDim2.new(0, 0, 1, -20)
        ownedLabel.BackgroundTransparency = 1
        ownedLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        ownedLabel.Font = Enum.Font.GothamBold
        ownedLabel.TextSize = 12
        ownedLabel.Parent = item
        changesMade = changesMade + 1
    end
    
    -- 4. Enable the button if it's disabled
    if item:IsA("TextButton") or item:IsA("ImageButton") then
        item.AutoButtonColor = true
        item.Active = true
        
        -- Change button color to green
        if item:IsA("TextButton") then
            item.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end
        
        changesMade = changesMade + 1
    end
    
    return changesMade > 0
end

local function FindAndUnlockAllCosmetics()
    print("🎯 Searching for car customization items...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local unlockedCount = 0
    local scannedItems = 0
    
    -- Look in all UI containers
    local containers = {}
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("ScrollingFrame") or gui:IsA("Frame") then
            table.insert(containers, gui)
        end
    end
    
    print("📦 Scanning", #containers, "UI containers...")
    
    for _, container in pairs(containers) do
        -- Find all potential cosmetic items
        for _, item in pairs(container:GetDescendants()) do
            scannedItems = scannedItems + 1
            
            -- Check if this is a cosmetic item
            if IsCarCosmetic(item) then
                print("🔓 Found cosmetic: " .. item.Name)
                
                -- Unlock it
                if UnlockSingleItem(item) then
                    unlockedCount = unlockedCount + 1
                    
                    -- Also check parent items
                    local parent = item.Parent
                    if parent and IsCarCosmetic(parent) then
                        UnlockSingleItem(parent)
                    end
                end
            end
        end
    end
    
    -- If we didn't find many, do a deeper search
    if unlockedCount < 5 then
        print("🔍 Doing deep search for customization items...")
        
        -- Look for any button with cosmetic-like names
        for _, item in pairs(PlayerGui:GetDescendants()) do
            if item:IsA("TextButton") or item:IsA("ImageButton") then
                local name = item.Name:lower()
                
                for _, target in ipairs(TARGET_ITEMS) do
                    if name:find(target) then
                        if UnlockSingleItem(item) then
                            unlockedCount = unlockedCount + 1
                        end
                        break
                    end
                end
            end
        end
    end
    
    print("✅ Scanned", scannedItems, "items")
    print("✨ Unlocked", unlockedCount, "car cosmetics")
    
    return unlockedCount
end

-- ===== SHOP DETECTION =====
local function WaitForShopToOpen()
    print("🕐 Waiting for shop to open...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local maxAttempts = 50
    local attempts = 0
    
    while attempts < maxAttempts do
        -- Look for shop indicators
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") then
                local text = gui.Text:lower()
                if text:find("shop") or text:find("store") 
                   or text:find("custom") or text:find("cosmetic") then
                    print("🏪 Shop detected!")
                    return true
                end
            end
        end
        
        attempts = attempts + 1
        task.wait(0.5)
    end
    
    print("⚠️ Shop not detected, trying anyway...")
    return false
end

-- ===== AUTO-UNLOCK SYSTEM =====
local function SetupAutoUnlock()
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Monitor for new UI elements
    PlayerGui.DescendantAdded:Connect(function(item)
        task.wait(0.1) -- Let it load
        
        if IsCarCosmetic(item) then
            UnlockSingleItem(item)
        end
    end)
    
    -- Also monitor property changes (for when items become visible)
    for _, item in pairs(PlayerGui:GetDescendants()) do
        if item:IsA("GuiObject") then
            item:GetPropertyChangedSignal("Visible"):Connect(function()
                if item.Visible and IsCarCosmetic(item) then
                    task.wait(0.2)
                    UnlockSingleItem(item)
                end
            end)
        end
    end
end

-- ===== SIMPLE CONTROL UI =====
local function CreateControlUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CarCustomUnlocker"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Control Panel
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.Position = UDim2.new(1, -320, 0.5, -100)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    MainFrame.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 150, 255)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🚗 CAR CUSTOMIZATION UNLOCKER"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "Open car customization shop\nand click UNLOCK"
    Status.Size = UDim2.new(1, -20, 0, 60)
    Status.Position = UDim2.new(0, 10, 0, 50)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(200, 200, 220)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.TextWrapped = true
    
    -- Unlock Button
    local UnlockBtn = Instance.new("TextButton")
    UnlockBtn.Text = "🔓 UNLOCK ALL ITEMS"
    UnlockBtn.Size = UDim2.new(1, -40, 0, 40)
    UnlockBtn.Position = UDim2.new(0, 20, 1, -100)
    UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnlockBtn.Font = Enum.Font.GothamBold
    UnlockBtn.TextSize = 14
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = UnlockBtn
    
    -- Auto Button
    local AutoBtn = Instance.new("TextButton")
    AutoBtn.Text = "⏰ AUTO: OFF"
    AutoBtn.Size = UDim2.new(1, -40, 0, 30)
    AutoBtn.Position = UDim2.new(0, 20, 1, -60)
    AutoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    AutoBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    AutoBtn.Font = Enum.Font.Gotham
    AutoBtn.TextSize = 12
    
    local AutoCorner = Instance.new("UICorner")
    AutoCorner.CornerRadius = UDim.new(0, 6)
    AutoCorner.Parent = AutoBtn
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "✕"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    -- Parent everything
    Title.Parent = MainFrame
    Status.Parent = MainFrame
    UnlockBtn.Parent = MainFrame
    AutoBtn.Parent = MainFrame
    CloseBtn.Parent = Title
    MainFrame.Parent = ScreenGui
    
    -- Variables
    local autoEnabled = false
    
    -- Unlock function
    local function PerformUnlock()
        UnlockBtn.Text = "UNLOCKING..."
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        Status.Text = "Searching for customization items..."
        
        task.spawn(function()
            -- Wait a moment for UI to load
            task.wait(0.5)
            
            -- Unlock everything
            local unlocked = FindAndUnlockAllCosmetics()
            
            if unlocked > 0 then
                UnlockBtn.Text = "✅ UNLOCKED!"
                UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
                Status.Text = "Unlocked " .. unlocked .. " items!\nAll wraps, kits, wheels, etc. are now FREE."
                
                -- Success sound
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://4590662766"
                sound.Volume = 0.2
                sound.Parent = ScreenGui
                sound:Play()
                game:GetService("Debris"):AddItem(sound, 3)
            else
                UnlockBtn.Text = "🔓 UNLOCK ALL ITEMS"
                UnlockBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                Status.Text = "No items found!\nMake sure:\n1. Shop is open\n2. On customization tab\n3. Try scrolling"
            end
        end)
    end
    
    -- Auto-toggle function
    local function ToggleAuto()
        autoEnabled = not autoEnabled
        
        if autoEnabled then
            AutoBtn.Text = "⏰ AUTO: ON"
            AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
            Status.Text = "Auto-unlock enabled!\nItems will unlock automatically."
            
            -- Setup auto-unlock
            SetupAutoUnlock()
            
            -- Unlock once now
            task.wait(1)
            PerformUnlock()
        else
            AutoBtn.Text = "⏰ AUTO: OFF"
            AutoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            Status.Text = "Auto-unlock disabled"
        end
    end
    
    -- Connect events
    UnlockBtn.MouseButton1Click:Connect(PerformUnlock)
    AutoBtn.MouseButton1Click:Connect(ToggleAuto)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Make draggable
    local dragging = false
    local dragStart, startPos
    
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return ScreenGui
end

-- ===== MAIN EXECUTION =====
print("=" .. string.rep("=", 50))
print("🎨 CAR CUSTOMIZATION UNLOCKER")
print("=" .. string.rep("=", 50))
print("TARGET ITEMS:")
print("• Wraps / Paints / Colors")
print("• Body Kits / Spoilers")
print("• Wheels / Rims")
print("• Underglows / Neons")
print("• Exhausts / Hoods")
print("• Window Tints / Stickers")
print("=" .. string.rep("=", 50))

-- Wait for game to fully load
task.wait(2)

-- Create UI
CreateControlUI()

-- Try to detect and unlock if shop is already open
task.wait(3)
print("[System] UI ready! Open car customization and click UNLOCK.")

-- Auto-attempt after 10 seconds
task.wait(10)
print("[Tip] If shop is open, click the UNLOCK button in the top-right panel!")
