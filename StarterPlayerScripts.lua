-- 🎯 SMART CAR COSMETIC SCANNER & UNLOCKER
-- Reads car name from shop UI and unlocks all its cosmetics

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== SMART CAR DETECTION =====
local function GetCarNameFromShop()
    print("🔍 Smart scanning for car name in shop...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local possibleCarNames = {}
    
    -- Method 1: Look for large text that might be car name
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            local text = gui.Text
            local textLower = text:lower()
            
            -- Skip common UI text
            if text ~= "" and not textLower:find("shop") 
               and not textLower:find("custom") and not textLower:find("back")
               and not textLower:find("exit") and not textLower:find("close")
               and not textLower:find("buy") and not textLower:find("purchase") then
                
                -- Check text characteristics (car names are usually 1-3 words)
                local wordCount = #text:split(" ")
                if wordCount <= 3 and #text > 3 then
                    -- Check if it's likely a car name
                    if not text:find("%$") and not text:find("%d") then
                        -- Check font size (car names often larger)
                        if gui.TextSize >= 14 or gui:FindFirstAncestorWhichIsA("Frame") then
                            table.insert(possibleCarNames, {
                                text = text,
                                element = gui,
                                size = gui.TextSize,
                                path = gui:GetFullName()
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Method 2: Look for car brand names (common in games)
    local carBrands = {
        "Pagani", "Bugatti", "Lamborghini", "Ferrari", "Porsche",
        "McLaren", "Koenigsegg", "Audi", "BMW", "Mercedes",
        "Ford", "Chevrolet", "Dodge", "Nissan", "Toyota",
        "Mazda", "Subaru", "Honda", "Tesla", "Lexus"
    }
    
    for _, brand in ipairs(carBrands) do
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text:find(brand) then
                table.insert(possibleCarNames, {
                    text = gui.Text,
                    element = gui,
                    isBrand = true,
                    path = gui:GetFullName()
                })
            end
        end
    end
    
    -- Method 3: Look for price displays (next to car name)
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and (gui.Text:find("%$") or gui.Text:find("%d")) then
            -- Look for sibling text that might be car name
            local parent = gui.Parent
            if parent then
                for _, sibling in pairs(parent:GetChildren()) do
                    if sibling:IsA("TextLabel") and sibling ~= gui then
                        local text = sibling.Text
                        if text ~= "" and not text:find("%$") and not text:find("%d") then
                            table.insert(possibleCarNames, {
                                text = text,
                                element = sibling,
                                nearPrice = true,
                                path = sibling:GetFullName()
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- Sort by likelihood
    table.sort(possibleCarNames, function(a, b)
        local scoreA = 0
        local scoreB = 0
        
        if a.isBrand then scoreA = scoreA + 3 end
        if a.nearPrice then scoreA = scoreA + 2 end
        if a.size and a.size >= 18 then scoreA = scoreA + 1 end
        
        if b.isBrand then scoreB = scoreB + 3 end
        if b.nearPrice then scoreB = scoreB + 2 end
        if b.size and b.size >= 18 then scoreB = scoreB + 1 end
        
        return scoreA > scoreB
    end)
    
    -- Display findings
    print("📋 Possible car names found:")
    for i, car in ipairs(possibleCarNames) do
        print("  [" .. i .. "] " .. car.text .. " (from: " .. car.path .. ")")
        if i >= 10 then break end -- Limit display
    end
    
    if #possibleCarNames > 0 then
        local bestGuess = possibleCarNames[1].text
        print("🎯 Best guess for car name: " .. bestGuess)
        return bestGuess, possibleCarNames[1].element
    end
    
    print("❌ Could not detect car name")
    return nil, nil
end

-- ===== DEEP COSMETIC SCAN =====
local function DeepScanCosmetics(carName)
    print("🎨 Deep scanning for cosmetics...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local foundCosmetics = {
        Wraps = {},
        Kits = {},
        Wheels = {},
        Neons = {},
        All = {}
    }
    
    -- Method 1: Scan all shop containers
    local shopContainers = {}
    
    for _, container in pairs(PlayerGui:GetDescendants()) do
        if container:IsA("ScrollingFrame") or (container:IsA("Frame") and container.Visible) then
            local containerName = container.Name:lower()
            local isShopRelated = containerName:find("shop") or containerName:find("custom") 
                                or containerName:find("select") or containerName:find("menu")
            
            if isShopRelated then
                table.insert(shopContainers, container)
            end
        end
    end
    
    print("📦 Found " .. #shopContainers .. " shop containers")
    
    -- Method 2: Scan all buttons in shop containers
    for _, container in ipairs(shopContainers) do
        for _, item in pairs(container:GetDescendants()) do
            if item:IsA("TextButton") or item:IsA("ImageButton") then
                local buttonText = item.Text or ""
                local buttonName = item.Name:lower()
                
                -- Check if this is a cosmetic button
                local isCosmetic = false
                local category = "Other"
                
                -- Check by text content
                if buttonText:lower():find("wrap") or buttonText:lower():find("paint") 
                   or buttonText:lower():find("color") then
                    isCosmetic = true
                    category = "Wraps"
                elseif buttonText:lower():find("kit") or buttonText:lower():find("body") 
                       or buttonText:lower():find("spoiler") then
                    isCosmetic = true
                    category = "Kits"
                elseif buttonText:lower():find("wheel") or buttonText:lower():find("rim") 
                       or buttonText:lower():find("tire") then
                    isCosmetic = true
                    category = "Wheels"
                elseif buttonText:lower():find("neon") or buttonText:lower():find("light") 
                       or buttonText:lower():find("glow") then
                    isCosmetic = true
                    category = "Neons"
                end
                
                -- Check by name if text is empty
                if not isCosmetic and buttonText == "" then
                    if buttonName:find("wrap") or buttonName:find("paint") then
                        isCosmetic = true
                        category = "Wraps"
                    elseif buttonName:find("kit") or buttonName:find("body") then
                        isCosmetic = true
                        category = "Kits"
                    end
                end
                
                if isCosmetic and buttonText ~= "" then
                    -- Avoid duplicates
                    local isDuplicate = false
                    for _, existing in ipairs(foundCosmetics.All) do
                        if existing.name == buttonText then
                            isDuplicate = true
                            break
                        end
                    end
                    
                    if not isDuplicate then
                        local cosmetic = {
                            name = buttonText,
                            button = item,
                            category = category,
                            container = container.Name
                        }
                        
                        table.insert(foundCosmetics[category], cosmetic)
                        table.insert(foundCosmetics.All, cosmetic)
                        
                        print("🎨 Found cosmetic: [" .. category .. "] " .. buttonText)
                    end
                end
            end
        end
    end
    
    -- Method 3: Look for cosmetic tabs/categories
    for _, container in ipairs(shopContainers) do
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("TextButton") then
                local text = child.Text:lower()
                if text == "wraps" or text == "paints" or text == "colors" then
                    print("📁 Found Wraps category tab")
                elseif text == "kits" or text == "body kits" then
                    print("📁 Found Kits category tab")
                elseif text == "wheels" or text == "rims" then
                    print("📁 Found Wheels category tab")
                elseif text == "neons" or text == "lights" then
                    print("📁 Found Neons category tab")
                end
            end
        end
    end
    
    -- Display results
    print("\n📊 DEEP SCAN RESULTS:")
    for category, items in pairs(foundCosmetics) do
        if category ~= "All" and #items > 0 then
            print("🎨 " .. category .. ": " .. #items .. " items")
            for i, item in ipairs(items) do
                print("   " .. i .. ". " .. item.name)
            end
        end
    end
    
    print("✅ Total cosmetics found: " .. #foundCosmetics.All)
    
    return foundCosmetics
end

-- ===== ENHANCED UNLOCK SYSTEM =====
local function EnhancedUnlockCosmetics(carName, cosmetics)
    print("🔓 Enhanced unlocking for: " .. (carName or "Unknown Car"))
    
    local results = {
        total = #cosmetics.All,
        unlocked = 0,
        failed = 0,
        details = {}
    }
    
    if results.total == 0 then
        print("⚠️ No cosmetics to unlock!")
        return results
    end
    
    -- Find ALL purchase remotes
    local purchaseRemotes = {}
    
    print("📡 Searching for purchase remotes...")
    
    -- Look in common locations
    local locationsToCheck = {
        RS,
        RS:FindFirstChild("Network"),
        RS:FindFirstChild("Remotes"),
        RS:FindFirstChild("Events"),
        RS:FindFirstChild("Functions")
    }
    
    for _, location in pairs(locationsToCheck) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    if name:find("purchase") or name:find("buy") 
                       or name:find("unlock") or name:find("equip") then
                        
                        table.insert(purchaseRemotes, {
                            object = obj,
                            name = obj.Name,
                            path = obj:GetFullName()
                        })
                    end
                end
            end
        end
    end
    
    print("✅ Found " .. #purchaseRemotes .. " purchase remotes")
    
    -- Try to unlock each cosmetic with each remote
    for _, cosmetic in ipairs(cosmetics.All) do
        print("🔄 Unlocking: " .. cosmetic.name)
        local unlocked = false
        
        for _, remote in ipairs(purchaseRemotes) do
            -- Try different data formats for this cosmetic
            local formats = {
                cosmetic.name,  -- Just the name
                {ItemId = cosmetic.name},  -- With ItemId
                {id = cosmetic.name, type = cosmetic.category},  -- With type
                {Name = cosmetic.name, Category = cosmetic.category},  -- With Category
                {cosmetic = cosmetic.name, car = carName}  -- With car name
            }
            
            for i, data in ipairs(formats) do
                local success, result = pcall(function()
                    return remote.object:InvokeServer(data)
                end)
                
                if success then
                    print("   ✅ Via " .. remote.name .. " (format " .. i .. ")")
                    results.unlocked = results.unlocked + 1
                    results.details[cosmetic.name] = "✅ Unlocked via " .. remote.name
                    unlocked = true
                    break
                end
            end
            
            if unlocked then break end
        end
        
        if not unlocked then
            results.failed = results.failed + 1
            results.details[cosmetic.name] = "❌ Failed to unlock"
            print("   ❌ Failed")
        end
        
        task.wait(0.05) -- Small delay
    end
    
    return results
end

-- ===== FORCE SHOP UNLOCK =====
local function ForceUnlockShopUI(cosmetics)
    print("💵 Force unlocking shop UI...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local modified = 0
    
    -- Modify each cosmetic button
    for _, cosmetic in ipairs(cosmetics.All) do
        if cosmetic.button and cosmetic.button:IsDescendantOf(PlayerGui) then
            local button = cosmetic.button
            
            -- Change all text labels to FREE
            for _, child in pairs(button:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local text = child.Text:lower()
                    if text:find("%$") or text:find("%d") 
                       or text:find("buy") or text:find("purchase") 
                       or text:find("locked") then
                        child.Text = "FREE"
                        child.TextColor3 = Color3.fromRGB(0, 255, 0)
                        modified = modified + 1
                    end
                end
                
                -- Hide lock icons
                if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    if child.Name:lower():find("lock") 
                       or tostring(child.Image):lower():find("lock") then
                        child.Visible = false
                        modified = modified + 1
                    end
                end
            end
            
            -- Make the button itself green
            if button:IsA("TextButton") then
                button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                if button.Text:lower():find("buy") or button.Text:lower():find("purchase") then
                    button.Text = "EQUIP"
                end
                modified = modified + 1
            end
        end
    end
    
    print("🛍️ Force modified " .. modified .. " shop elements")
    
    -- Also try to unlock categories/tabs
    for _, container in pairs(PlayerGui:GetDescendants()) do
        if container:IsA("Frame") then
            local name = container.Name:lower()
            if name:find("wrap") or name:find("kit") 
               or name:find("wheel") or name:find("neon") then
                
                -- Make entire category appear unlocked
                for _, child in pairs(container:GetDescendants()) do
                    if child:IsA("TextLabel") and child.Text:lower():find("locked") then
                        child.Text = "UNLOCKED"
                        child.TextColor3 = Color3.fromRGB(0, 255, 0)
                        modified = modified + 1
                    end
                end
            end
        end
    end
    
    return modified
end

-- ===== SMART UNLOCKER UI =====
local function CreateSmartUnlockerUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SmartUnlockerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Control Panel
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    MainFrame.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 150, 255)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🎯 SMART CAR UNLOCKER"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 15)
    TitleCorner.Parent = Title
    
    -- Status Display
    local StatusFrame = Instance.new("ScrollingFrame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 250)
    StatusFrame.Position = UDim2.new(0, 10, 0, 60)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    StatusFrame.ScrollBarThickness = 8
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 10)
    StatusCorner.Parent = StatusFrame
    
    local StatusLayout = Instance.new("UIListLayout")
    StatusLayout.Padding = UDim.new(0, 5)
    StatusLayout.Parent = StatusFrame
    
    -- Progress
    local ProgressFrame = Instance.new("Frame")
    ProgressFrame.Size = UDim2.new(1, -20, 0, 30)
    ProgressFrame.Position = UDim2.new(0, 10, 0, 320)
    ProgressFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 10)
    ProgressCorner.Parent = ProgressFrame
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    ProgressBar.BorderSizePixel = 0
    
    local ProgressBarCorner = Instance.new("UICorner")
    ProgressBarCorner.CornerRadius = UDim.new(0, 10)
    ProgressBarCorner.Parent = ProgressBar
    
    local ProgressText = Instance.new("TextLabel")
    ProgressText.Text = "Ready"
    ProgressText.Size = UDim2.new(1, 0, 1, 0)
    ProgressText.BackgroundTransparency = 1
    ProgressText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ProgressText.Font = Enum.Font.Gotham
    ProgressText.TextSize = 12
    ProgressText.Parent = ProgressFrame
    
    ProgressBar.Parent = ProgressFrame
    
    -- Buttons
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Text = "🔍 SCAN CAR & COSMETICS"
    ScanBtn.Size = UDim2.new(1, -20, 0, 45)
    ScanBtn.Position = UDim2.new(0, 10, 0, 360)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.GothamBold
    ScanBtn.TextSize = 14
    
    local ScanCorner = Instance.new("UICorner")
    ScanCorner.CornerRadius = UDim.new(0, 10)
    ScanCorner.Parent = ScanBtn
    
    local UnlockBtn = Instance.new("TextButton")
    UnlockBtn.Text = "🔓 UNLOCK ALL COSMETICS"
    UnlockBtn.Size = UDim2.new(1, -20, 0, 45)
    UnlockBtn.Position = UDim2.new(0, 10, 0, 415)
    UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnlockBtn.Font = Enum.Font.GothamBold
    UnlockBtn.TextSize = 14
    UnlockBtn.Visible = false
    
    local UnlockCorner = Instance.new("UICorner")
    UnlockCorner.CornerRadius = UDim.new(0, 10)
    UnlockCorner.Parent = UnlockBtn
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "✕"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    -- Parent everything
    Title.Parent = MainFrame
    StatusFrame.Parent = MainFrame
    ProgressFrame.Parent = MainFrame
    ScanBtn.Parent = MainFrame
    UnlockBtn.Parent = MainFrame
    CloseBtn.Parent = Title
    MainFrame.Parent = ScreenGui
    
    -- Variables
    local scanData = nil
    local isScanning = false
    
    -- Function to add status message
    local function AddStatus(text, color)
        local messageFrame = Instance.new("Frame")
        messageFrame.Size = UDim2.new(1, 0, 0, 30)
        messageFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        messageFrame.BackgroundTransparency = 0.5
        
        local messageCorner = Instance.new("UICorner")
        messageCorner.CornerRadius = UDim.new(0, 6)
        messageCorner.Parent = messageFrame
        
        local messageLabel = Instance.new("TextLabel")
        messageLabel.Text = text
        messageLabel.Size = UDim2.new(1, -10, 1, 0)
        messageLabel.Position = UDim2.new(0, 5, 0, 0)
        messageLabel.BackgroundTransparency = 1
        messageLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        messageLabel.Font = Enum.Font.Gotham
        messageLabel.TextSize = 11
        messageLabel.TextXAlignment = Enum.TextXAlignment.Left
        messageLabel.Parent = messageFrame
        
        messageFrame.Parent = StatusFrame
        StatusFrame.CanvasSize = UDim2.new(0, 0, 0, StatusLayout.AbsoluteContentSize.Y)
        StatusFrame.CanvasPosition = Vector2.new(0, StatusLayout.AbsoluteContentSize.Y)
    end
    
    -- Clear status
    local function ClearStatus()
        for _, child in pairs(StatusFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
    
    -- Scan function
    local function PerformSmartScan()
        if isScanning then return end
        isScanning = true
        
        ScanBtn.Text = "SCANNING..."
        ScanBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        ClearStatus()
        AddStatus("🔍 Starting smart scan...", Color3.fromRGB(255, 200, 0))
        
        task.spawn(function()
            -- Step 1: Get car name
            AddStatus("Step 1: Finding car name in shop...", Color3.fromRGB(255, 255, 255))
            local carName, carElement = GetCarNameFromShop()
            
            if carName then
                AddStatus("✅ Found car: " .. carName, Color3.fromRGB(0, 255, 0))
            else
                AddStatus("⚠️ Could not detect car name", Color3.fromRGB(255, 200, 0))
                carName = "Current Car"
            end
            
            -- Step 2: Deep scan cosmetics
            AddStatus("Step 2: Scanning for cosmetics...", Color3.fromRGB(255, 255, 255))
            local cosmetics = DeepScanCosmetics(carName)
            
            if #cosmetics.All > 0 then
                AddStatus("✅ Found " .. #cosmetics.All .. " cosmetics!", Color3.fromRGB(0, 255, 0))
                
                -- Display found cosmetics
                for category, items in pairs(cosmetics) do
                    if category ~= "All" and #items > 0 then
                        AddStatus("🎨 " .. category .. " (" .. #items .. "):", Color3.fromRGB(200, 220, 255))
                        for _, item in ipairs(items) do
                            AddStatus("   • " .. item.name, Color3.fromRGB(255, 255, 200))
                        end
                    end
                end
                
                -- Save scan data
                scanData = {
                    carName = carName,
                    cosmetics = cosmetics,
                    element = carElement
                }
                
                -- Show unlock button
                UnlockBtn.Visible = true
                UnlockBtn.Text = "🔓 UNLOCK " .. #cosmetics.All .. " COSMETICS"
                
                ScanBtn.Text = "✅ SCAN COMPLETE"
                ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                AddStatus("📊 Ready to unlock " .. #cosmetics.All .. " cosmetics!", Color3.fromRGB(0, 255, 0))
            else
                AddStatus("❌ No cosmetics found!", Color3.fromRGB(255, 100, 100))
                AddStatus("💡 Make sure:", Color3.fromRGB(255, 200, 100))
                AddStatus("   • Shop is fully loaded", Color3.fromRGB(255, 255, 200))
                AddStatus("   • You're viewing a car", Color3.fromRGB(255, 255, 200))
                AddStatus("   • Cosmetic tabs are open", Color3.fromRGB(255, 255, 200))
                
                ScanBtn.Text = "🔍 SCAN CAR & COSMETICS"
                ScanBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
            
            isScanning = false
        end)
    end
    
    -- Unlock function
    local function PerformUnlock()
        if not scanData or isScanning then return end
        isScanning = true
        
        UnlockBtn.Text = "UNLOCKING..."
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        ClearStatus()
        AddStatus("🔓 Starting unlock process...", Color3.fromRGB(255, 200, 0))
        
        task.spawn(function()
            -- Update progress
            local total = #scanData.cosmetics.All
            ProgressText.Text = "0/" .. total
            
            -- Step 1: Enhanced unlock
            AddStatus("Step 1: Unlocking cosmetics...", Color3.fromRGB(255, 255, 255))
            local unlockResults = EnhancedUnlockCosmetics(scanData.carName, scanData.cosmetics)
            
            -- Update progress bar
            ProgressBar:TweenSize(
                UDim2.new(1, 0, 1, 0),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.5,
                true
            )
            
            ProgressText.Text = total .. "/" .. total
            
            -- Step 2: Force shop unlock
            AddStatus("Step 2: Unlocking shop UI...", Color3.fromRGB(255, 255, 255))
            local shopResults = ForceUnlockShopUI(scanData.cosmetics)
            
            -- Display results
            AddStatus("📊 UNLOCK RESULTS:", Color3.fromRGB(200, 220, 255))
            AddStatus("✅ Unlocked: " .. unlockResults.unlocked .. "/" .. total, Color3.fromRGB(0, 255, 0))
            AddStatus("❌ Failed: " .. unlockResults.failed, Color3.fromRGB(255, 100, 100))
            AddStatus("🛍️ Shop modified: " .. shopResults .. " elements", Color3.fromRGB(255, 200, 0))
            
            if unlockResults.unlocked > 0 then
                AddStatus("🎉 Success! Cosmetics should now work!", Color3.fromRGB(0, 255, 0))
                
                -- Success sound
                local sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://4590662766"
                sound.Volume = 0.2
                sound.Parent = MainFrame
                sound:Play()
                game:GetService("Debris"):AddItem(sound, 3)
                
                UnlockBtn.Text = "✅ UNLOCKED!"
                UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            else
                AddStatus("⚠️ Limited success - Try manual unlock", Color3.fromRGB(255, 200, 0))
                UnlockBtn.Text = "🔓 UNLOCK COSMETICS"
                UnlockBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
            
            isScanning = false
        end)
    end
    
    -- Connect events
    ScanBtn.MouseButton1Click:Connect(PerformSmartScan)
    UnlockBtn.MouseButton1Click:Connect(PerformUnlock)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Initial message
    AddStatus("🎯 SMART CAR UNLOCKER READY", Color3.fromRGB(0, 200, 255))
    AddStatus("", Color3.fromRGB(255, 255, 255))
    AddStatus("HOW TO USE:", Color3.fromRGB(200, 220, 255))
    AddStatus("1. Open car customization shop", Color3.fromRGB(255, 255, 200))
    AddStatus("2. Select/view a specific car", Color3.fromRGB(255, 255, 200))
    AddStatus("3. Open cosmetic tabs (wraps/kits/etc)", Color3.fromRGB(255, 255, 200))
    AddStatus("4. Click SCAN button", Color3.fromRGB(255, 255, 200))
    AddStatus("5. Click UNLOCK when ready", Color3.fromRGB(255, 255, 200))
    
    return ScreenGui
end

-- ===== AUTO-START =====
print("=" .. string.rep("=", 60))
print("🎯 SMART CAR COSMETIC UNLOCKER")
print("=" .. string.rep("=", 60))
print("FEATURES:")
print("• Smart car name detection")
print("• Deep cosmetic scanning")
print("• Enhanced unlock system")
print("• Force shop UI modification")
print("=" .. string.rep("=", 60))

-- Wait for game
task.wait(2)

-- Create UI
CreateSmartUnlockerUI()

-- Instructions
task.wait(3)
print("\n[System] UI created! Center of screen.")
print("[System] Follow these steps:")
print("1. OPEN car customization shop")
print("2. SELECT a specific car")
print("3. OPEN wraps/kits/wheels/neons tabs")
print("4. CLICK 'SCAN CAR & COSMETICS'")
print("5. CLICK 'UNLOCK ALL COSMETICS'")
