-- 🚗 CAR-SPECIFIC COSMETIC UNLOCKER
-- Scans current car in shop and unlocks all its cosmetics

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== CAR SCANNING SYSTEM =====
local function GetCurrentCarInShop()
    print("🔍 Finding current car in shop...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local foundCar = nil
    local carName = ""
    
    -- Look for car display in shop
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("Model") or gui:IsA("BasePart") then
            -- Check if it's a car model in the shop
            if gui.Name:find("Car") or gui.Name:find("Vehicle") 
               or gui.Parent and gui.Parent.Name:find("Car") then
                
                -- Check if it's in a shop container
                local parent = gui
                local isInShop = false
                
                while parent do
                    if parent:IsA("ScreenGui") or parent:IsA("Frame") then
                        local name = parent.Name:lower()
                        if name:find("shop") or name:find("custom") 
                           or name:find("showroom") or name:find("display") then
                            isInShop = true
                            break
                        end
                    end
                    parent = parent.Parent
                end
                
                if isInShop then
                    foundCar = gui
                    carName = gui.Name
                    print("🚗 Found car in shop: " .. carName)
                    break
                end
            end
        end
    end
    
    -- If no 3D model found, look for car name in UI
    if not foundCar then
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") then
                local text = gui.Text:lower()
                if text:find("car") or text:find("vehicle") then
                    -- Check if this is in shop UI
                    local parent = gui
                    while parent do
                        if parent:IsA("ScreenGui") then
                            local parentName = parent.Name:lower()
                            if parentName:find("shop") or parentName:find("custom") then
                                carName = gui.Text
                                print("📝 Found car name in UI: " .. carName)
                                break
                            end
                        end
                        parent = parent.Parent
                    end
                    if carName ~= "" then break end
                end
            end
        end
    end
    
    return foundCar, carName
end

local function ScanCarForCosmetics(carModel)
    print("🎨 Scanning car for available cosmetics...")
    
    local cosmetics = {
        Wraps = {},
        Kits = {},
        Wheels = {},
        Neons = {},
        Other = {}
    }
    
    if carModel then
        -- Check car model for cosmetic slots
        for _, child in pairs(carModel:GetDescendants()) do
            local name = child.Name:lower()
            
            -- Look for wrap/paint slots
            if name:find("wrap") or name:find("paint") or name:find("color") then
                table.insert(cosmetics.Wraps, {
                    name = child.Name,
                    object = child,
                    type = "Wrap"
                })
            end
            
            -- Look for body kit slots
            if name:find("kit") or name:find("body") or name:find("spoiler") 
               or name:find("bumper") or name:find("wing") then
                table.insert(cosmetics.Kits, {
                    name = child.Name,
                    object = child,
                    type = "BodyKit"
                })
            end
            
            -- Look for wheel slots
            if name:find("wheel") or name:find("rim") or name:find("tire") then
                table.insert(cosmetics.Wheels, {
                    name = child.Name,
                    object = child,
                    type = "Wheel"
                })
            end
            
            -- Look for neon slots
            if name:find("neon") or name:find("light") or name:find("glow") then
                table.insert(cosmetics.Neons, {
                    name = child.Name,
                    object = child,
                    type = "Neon"
                })
            end
        end
    end
    
    -- Also scan shop UI for this car's cosmetics
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    for _, container in pairs(PlayerGui:GetDescendants()) do
        if container:IsA("ScrollingFrame") or container:IsA("Frame") then
            local containerName = container.Name:lower()
            
            if containerName:find("custom") or containerName:find("shop") 
               or containerName:find("wrap") or containerName:find("kit") then
                
                -- Look for cosmetic buttons
                for _, item in pairs(container:GetDescendants()) do
                    if item:IsA("TextButton") then
                        local itemText = item.Text:lower()
                        
                        -- Categorize based on text
                        if itemText:find("wrap") or itemText:find("paint") 
                           or itemText:find("color") then
                            table.insert(cosmetics.Wraps, {
                                name = item.Text,
                                object = item,
                                type = "Wrap",
                                fromUI = true
                            })
                        elseif itemText:find("kit") or itemText:find("body") 
                               or itemText:find("spoiler") then
                            table.insert(cosmetics.Kits, {
                                name = item.Text,
                                object = item,
                                type = "BodyKit",
                                fromUI = true
                            })
                        elseif itemText:find("wheel") or itemText:find("rim") then
                            table.insert(cosmetics.Wheels, {
                                name = item.Text,
                                object = item,
                                type = "Wheel",
                                fromUI = true
                            })
                        elseif itemText:find("neon") or itemText:find("light") then
                            table.insert(cosmetics.Neons, {
                                name = item.Text,
                                object = item,
                                type = "Neon",
                                fromUI = true
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Display found cosmetics
    print("\n📊 FOUND COSMETICS FOR THIS CAR:")
    for category, items in pairs(cosmetics) do
        if #items > 0 then
            print("🎨 " .. category .. " (" .. #items .. " items):")
            for i, item in ipairs(items) do
                print("   " .. i .. ". " .. item.name)
            end
        end
    end
    
    return cosmetics
end

-- ===== UNLOCK SYSTEM =====
local function FindCarSpecificRemotes(carName)
    print("🔍 Finding remotes for car: " .. carName)
    
    local remotes = {}
    
    -- Search for car-specific remotes
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteFunction") then
            local remoteName = obj.Name:lower()
            local objName = obj.Name
            
            -- Check if remote is for this car or general cosmetics
            if remoteName:find("purchase") or remoteName:find("buy") 
               or remoteName:find("unlock") or remoteName:find("equip") then
                
                table.insert(remotes, {
                    object = obj,
                    name = objName,
                    type = "Purchase"
                })
            end
        end
    end
    
    -- Also look in Network folder
    local network = RS:FindFirstChild("Network")
    if network then
        for _, obj in pairs(network:GetDescendants()) do
            if obj:IsA("RemoteFunction") then
                table.insert(remotes, {
                    object = obj,
                    name = obj.Name,
                    type = "Network"
                })
            end
        end
    end
    
    print("📡 Found " .. #remotes .. " potential remotes")
    return remotes
end

local function UnlockCarCosmetics(carName, cosmetics)
    print("🔓 Unlocking cosmetics for: " .. carName)
    
    local results = {
        total = 0,
        unlocked = 0,
        failed = 0,
        details = {}
    }
    
    -- Find remotes
    local remotes = FindCarSpecificRemotes(carName)
    if #remotes == 0 then
        print("❌ No remotes found for this car")
        return results
    end
    
    -- Combine all cosmetics into one list
    local allCosmetics = {}
    for category, items in pairs(cosmetics) do
        for _, item in ipairs(items) do
            table.insert(allCosmetics, {
                name = item.name,
                type = item.type,
                category = category
            })
            results.total = results.total + 1
        end
    end
    
    if results.total == 0 then
        print("⚠️ No cosmetics found for this car")
        return results
    end
    
    print("🎯 Attempting to unlock " .. results.total .. " cosmetics...")
    
    -- Try each remote for each cosmetic
    for _, remote in ipairs(remotes) do
        for _, cosmetic in ipairs(allCosmetics) do
            print("🔄 Trying: " .. cosmetic.name .. " via " .. remote.name)
            
            -- Try different data formats
            local formats = {
                cosmetic.name,
                {ItemId = cosmetic.name, Car = carName},
                {id = cosmetic.name, type = cosmetic.type},
                {Name = cosmetic.name, Category = cosmetic.category}
            }
            
            for _, data in ipairs(formats) do
                local success, result = pcall(function()
                    return remote.object:InvokeServer(data)
                end)
                
                if success then
                    results.unlocked = results.unlocked + 1
                    results.details[cosmetic.name] = "✅ Unlocked"
                    print("✅ Success: " .. cosmetic.name)
                    break
                else
                    results.details[cosmetic.name] = "❌ Failed"
                    results.failed = results.failed + 1
                end
            end
            
            task.wait(0.05) -- Small delay
        end
    end
    
    print("\n" .. string.rep("=", 50))
    print("📊 UNLOCK RESULTS FOR " .. carName .. ":")
    print(string.rep("=", 50))
    print("✅ Unlocked: " .. results.unlocked)
    print("❌ Failed: " .. results.failed)
    print("📁 Total cosmetics: " .. results.total)
    print(string.rep("=", 50))
    
    return results
end

-- ===== MAKE COSMETICS FREE IN SHOP =====
local function MakeShopCosmeticsFree(cosmetics)
    print("💵 Making cosmetics free in shop...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local modified = 0
    
    for category, items in pairs(cosmetics) do
        for _, item in ipairs(items) do
            if item.fromUI and item.object then
                -- This is a shop UI button
                local button = item.object
                
                -- Change price to FREE
                for _, child in pairs(button:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        local text = child.Text:lower()
                        if text:find("$") or text:find("locked") 
                           or text:find("buy") or text:find("purchase") then
                            child.Text = "FREE"
                            child.TextColor3 = Color3.fromRGB(0, 255, 0)
                            modified = modified + 1
                        end
                    end
                    
                    -- Remove lock icons
                    if child:IsA("ImageLabel") then
                        if child.Name:lower():find("lock") then
                            child.Visible = false
                            modified = modified + 1
                        end
                    end
                end
                
                -- Make button green
                if button:IsA("TextButton") then
                    button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                    button.Text = "EQUIP"
                    modified = modified + 1
                end
            end
        end
    end
    
    print("🛍️ Modified " .. modified .. " shop elements to show FREE")
    return modified
end

-- ===== MAIN FUNCTION =====
local function ScanAndUnlockCurrentCar()
    print("🚀 Starting car-specific cosmetic unlock...")
    
    -- Step 1: Find current car in shop
    local carModel, carName = GetCurrentCarInShop()
    
    if carName == "" then
        print("❌ No car found in shop!")
        print("💡 Please open the car customization shop first.")
        return nil
    end
    
    -- Step 2: Scan for available cosmetics
    local cosmetics = ScanCarForCosmetics(carModel)
    
    -- Step 3: Unlock the cosmetics
    local unlockResults = UnlockCarCosmetics(carName, cosmetics)
    
    -- Step 4: Make them free in shop
    local freeResults = MakeShopCosmeticsFree(cosmetics)
    
    -- Return combined results
    return {
        carName = carName,
        cosmeticsFound = unlockResults.total,
        cosmeticsUnlocked = unlockResults.unlocked,
        shopModified = freeResults,
        details = unlockResults.details
    }
end

-- ===== AUTO-SCANNING UI =====
local function CreateAutoScannerUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CarScannerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Floating Scanner Button
    local ScannerButton = Instance.new("TextButton")
    ScannerButton.Text = "🔍 SCAN CAR"
    ScannerButton.Size = UDim2.new(0, 140, 0, 45)
    ScannerButton.Position = UDim2.new(1, -150, 0, 20)
    ScannerButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    ScannerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScannerButton.Font = Enum.Font.GothamBold
    ScannerButton.TextSize = 14
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = ScannerButton
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    ButtonStroke.Thickness = 2
    ButtonStroke.Parent = ScannerButton
    
    -- Results Panel
    local ResultsPanel = Instance.new("Frame")
    ResultsPanel.Size = UDim2.new(0, 300, 0, 350)
    ResultsPanel.Position = UDim2.new(1, -320, 0, 80)
    ResultsPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    ResultsPanel.Visible = false
    
    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 12)
    PanelCorner.Parent = ResultsPanel
    
    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color = Color3.fromRGB(0, 150, 255)
    PanelStroke.Thickness = 2
    PanelStroke.Parent = ResultsPanel
    
    -- Title
    local PanelTitle = Instance.new("TextLabel")
    PanelTitle.Text = "CAR SCANNER RESULTS"
    PanelTitle.Size = UDim2.new(1, 0, 0, 40)
    PanelTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    PanelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PanelTitle.Font = Enum.Font.GothamBold
    PanelTitle.TextSize = 14
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = PanelTitle
    
    -- Content
    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Size = UDim2.new(1, -20, 1, -100)
    ContentScroll.Position = UDim2.new(0, 10, 0, 50)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.ScrollBarThickness = 8
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 5)
    ContentLayout.Parent = ContentScroll
    
    -- Status
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Text = "Ready to scan"
    StatusLabel.Size = UDim2.new(1, -20, 0, 40)
    StatusLabel.Position = UDim2.new(0, 10, 1, -50)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 11
    StatusLabel.TextWrapped = true
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "✕"
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    -- Parent everything
    PanelTitle.Parent = ResultsPanel
    ContentScroll.Parent = ResultsPanel
    StatusLabel.Parent = ResultsPanel
    CloseBtn.Parent = PanelTitle
    ResultsPanel.Parent = ScreenGui
    ScannerButton.Parent = ScreenGui
    
    -- Function to add result item
    local function AddResultItem(text, color)
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, 0, 0, 30)
        itemFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        itemFrame.BackgroundTransparency = 0.5
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 6)
        itemCorner.Parent = itemFrame
        
        local itemLabel = Instance.new("TextLabel")
        itemLabel.Text = text
        itemLabel.Size = UDim2.new(1, -10, 1, 0)
        itemLabel.Position = UDim2.new(0, 5, 0, 0)
        itemLabel.BackgroundTransparency = 1
        itemLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        itemLabel.Font = Enum.Font.Gotham
        itemLabel.TextSize = 11
        itemLabel.TextXAlignment = Enum.TextXAlignment.Left
        itemLabel.Parent = itemFrame
        
        itemFrame.Parent = ContentScroll
    end
    
    -- Clear results
    local function ClearResults()
        for _, child in pairs(ContentScroll:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
    
    -- Scan function
    local function PerformScan()
        ScannerButton.Text = "SCANNING..."
        ScannerButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        ResultsPanel.Visible = true
        StatusLabel.Text = "Finding car in shop..."
        
        ClearResults()
        AddResultItem("🔍 Scanning current car...", Color3.fromRGB(255, 200, 0))
        
        task.spawn(function()
            -- Wait a moment for UI to update
            task.wait(1)
            
            -- Perform scan
            local results = ScanAndUnlockCurrentCar()
            
            if results then
                -- Display results
                ClearResults()
                
                AddResultItem("🚗 Car: " .. results.carName, Color3.fromRGB(0, 200, 255))
                AddResultItem("📊 Cosmetics found: " .. results.cosmeticsFound, Color3.fromRGB(255, 255, 255))
                AddResultItem("✅ Unlocked: " .. results.cosmeticsUnlocked, Color3.fromRGB(0, 255, 0))
                AddResultItem("🛍️ Shop modified: " .. results.shopModified, Color3.fromRGB(255, 200, 0))
                
                -- Add details
                AddResultItem("", Color3.fromRGB(255, 255, 255))
                AddResultItem("📝 COSMETICS DETAILS:", Color3.fromRGB(200, 220, 255))
                
                for name, status in pairs(results.details) do
                    local color = status:find("✅") and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
                    AddResultItem("  • " .. name .. " - " .. status, color)
                end
                
                ScannerButton.Text = "✅ SCANNED"
                ScannerButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                StatusLabel.Text = "Scan complete! Cosmetics should be free in shop."
                
                -- Success sound
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://4590662766"
                sound.Volume = 0.2
                sound.Parent = ResultsPanel
                sound:Play()
                game:GetService("Debris"):AddItem(sound, 3)
            else
                AddResultItem("❌ No car found in shop!", Color3.fromRGB(255, 100, 100))
                AddResultItem("💡 Open car customization shop first", Color3.fromRGB(255, 200, 100))
                
                ScannerButton.Text = "🔍 SCAN CAR"
                ScannerButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                StatusLabel.Text = "Failed - Open car shop and try again"
            end
        end)
    end
    
    -- Button events
    ScannerButton.MouseButton1Click:Connect(PerformScan)
    
    CloseBtn.MouseButton1Click:Connect(function()
        ResultsPanel.Visible = false
    end)
    
    -- Toggle panel on hover
    ScannerButton.MouseEnter:Connect(function()
        ResultsPanel.Visible = true
    end)
    
    ResultsPanel.MouseEnter:Connect(function()
        ResultsPanel.Visible = true
    end)
    
    ResultsPanel.MouseLeave:Connect(function()
        if ScannerButton.Text ~= "SCANNING..." then
            ResultsPanel.Visible = false
        end
    end)
    
    -- Make draggable
    local dragging = false
    local dragStart, startPos
    
    ScannerButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = ScannerButton.Position
            
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
            ScannerButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            
            -- Move panel with button
            ResultsPanel.Position = UDim2.new(
                1, -320,
                0, ScannerButton.Position.Y.Offset + 60
            )
        end
    end)
    
    return ScreenGui
end

-- ===== AUTO-START =====
print("=" .. string.rep("=", 60))
print("🚗 CAR-SPECIFIC COSMETIC UNLOCKER")
print("=" .. string.rep("=", 60))
print("HOW IT WORKS:")
print("1. Scans current car in customization shop")
print("2. Finds all available cosmetics for that car")
print("3. Makes them free and obtainable")
print("=" .. string.rep("=", 60))

-- Wait for game
task.wait(2)

-- Create UI
CreateAutoScannerUI()

-- Instructions
task.wait(3)
print("\n[System] Click the '🔍 SCAN CAR' button in top-right!")
print("[System] Make sure you're viewing a car in the shop.")
print("[System] The script will find and unlock all its cosmetics.")

-- Try auto-scan after delay (optional)
task.wait(10)
print("\n[Tip] If button doesn't work, make sure:")
print("1. Car customization shop is OPEN")
print("2. You're LOOKING at a specific car")
print("3. Then click SCAN CAR button")
