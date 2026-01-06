-- 🔍 COSMETIC ID FINDER & UNLOCKER
-- Finds all cosmetic IDs and lets you unlock them

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== SCAN FOR COSMETIC IDs =====
local function ScanForCosmeticIDs()
    print("🔍 Scanning for cosmetic IDs...")
    
    local foundIDs = {}
    local categories = {
        Wraps = {},
        Kits = {},
        Wheels = {},
        Neons = {},
        Other = {}
    }
    
    -- Function to add ID with category
    local function AddID(id, category, source)
        if not id or id == "" then return end
        
        if not foundIDs[id] then
            foundIDs[id] = {
                id = id,
                category = category,
                source = source
            }
            table.insert(categories[category], id)
        end
    end
    
    -- Scan ReplicatedStorage
    print("📦 Scanning ReplicatedStorage...")
    for _, obj in pairs(RS:GetDescendants()) do
        -- Look for cosmetic items
        local name = obj.Name:lower()
        
        -- Check by name patterns
        if name:find("wrap") or name:find("paint") or name:find("color") then
            AddID(obj.Name, "Wraps", "RS: " .. obj:GetFullName())
        elseif name:find("kit") or name:find("spoiler") or name:find("body") then
            AddID(obj.Name, "Kits", "RS: " .. obj:GetFullName())
        elseif name:find("wheel") or name:find("rim") or name:find("tire") then
            AddID(obj.Name, "Wheels", "RS: " .. obj:GetFullName())
        elseif name:find("neon") or name:find("light") or name:find("glow") then
            AddID(obj.Name, "Neons", "RS: " .. obj:GetFullName())
        elseif name:find("exhaust") or name:find("hood") or name:find("window") then
            AddID(obj.Name, "Other", "RS: " .. obj:GetFullName())
        end
        
        -- Check for StringValues with IDs
        if obj:IsA("StringValue") then
            local value = obj.Value:lower()
            if value:find("wrap") or value:find("paint") or value:find("color") then
                AddID(obj.Value, "Wraps", "RS Value: " .. obj:GetFullName())
            end
        end
        
        -- Check for folders that might contain cosmetics
        if obj:IsA("Folder") then
            local folderName = obj.Name:lower()
            if folderName:find("wrap") or folderName:find("paint") 
               or folderName:find("kit") or folderName:find("wheel") then
                -- Add the folder itself as an ID
                AddID(obj.Name, "Other", "RS Folder: " .. obj:GetFullName())
                
                -- Add all children
                for _, child in pairs(obj:GetChildren()) do
                    AddID(child.Name, "Other", "RS Child: " .. child:GetFullName())
                end
            end
        end
    end
    
    -- Scan ServerStorage
    print("📦 Scanning ServerStorage...")
    for _, obj in pairs(SS:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("wrap") or name:find("paint") then
            AddID(obj.Name, "Wraps", "SS: " .. obj:GetFullName())
        elseif name:find("kit") or name:find("body") then
            AddID(obj.Name, "Kits", "SS: " .. obj:GetFullName())
        end
    end
    
    -- Scan shop UI for IDs (when shop is open)
    local function ScanShopUI()
        local PlayerGui = Player:WaitForChild("PlayerGui")
        
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                -- Check for ItemId attribute
                local itemId = gui:GetAttribute("ItemId") 
                              or gui:GetAttribute("ID")
                              or gui:GetAttribute("CosmeticId")
                
                if itemId then
                    local name = gui.Name:lower()
                    local category = "Other"
                    
                    if name:find("wrap") or itemId:lower():find("wrap") then
                        category = "Wraps"
                    elseif name:find("kit") or itemId:lower():find("kit") then
                        category = "Kits"
                    elseif name:find("wheel") or itemId:lower():find("wheel") then
                        category = "Wheels"
                    elseif name:find("neon") or itemId:lower():find("neon") then
                        category = "Neons"
                    end
                    
                    AddID(itemId, category, "Shop UI: " .. gui:GetFullName())
                end
            end
        end
    end
    
    task.spawn(ScanShopUI)
    
    -- Wait a bit for UI to load if shop is open
    task.wait(2)
    ScanShopUI()
    
    -- Display results
    print("\n" .. string.rep("=", 50))
    print("📊 FOUND COSMETIC IDs:")
    print(string.rep("=", 50))
    
    local total = 0
    for category, ids in pairs(categories) do
        if #ids > 0 then
            print("\n🎨 " .. category .. " (" .. #ids .. " items):")
            for i, id in ipairs(ids) do
                print("  " .. i .. ". " .. id)
                total = total + 1
            end
        end
    end
    
    print("\n" .. string.rep("=", 50))
    print("✅ Found " .. total .. " total cosmetic IDs")
    print(string.rep("=", 50))
    
    return foundIDs, categories
end

-- ===== EXTRACT IDs FROM SHOP =====
local function ExtractIDsFromCurrentShop()
    print("🛒 Extracting IDs from currently open shop...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local extracted = {}
    
    -- Look for shop containers
    for _, container in pairs(PlayerGui:GetDescendants()) do
        if container:IsA("ScrollingFrame") or container:IsA("Frame") then
            local containerName = container.Name:lower()
            
            -- Check if this looks like a shop container
            if containerName:find("shop") or containerName:find("store") 
               or containerName:find("custom") or containerName:find("selection") then
                
                print("📋 Found shop container: " .. container.Name)
                
                -- Extract IDs from all buttons
                for _, item in pairs(container:GetDescendants()) do
                    if item:IsA("TextButton") or item:IsA("ImageButton") then
                        -- Try to get item name from various sources
                        local itemName = item.Name
                        local displayText = ""
                        
                        -- Get text from child labels
                        for _, child in pairs(item:GetDescendants()) do
                            if child:IsA("TextLabel") then
                                displayText = child.Text
                                break
                            end
                        end
                        
                        -- Check if this looks like a cosmetic item
                        local nameLower = itemName:lower()
                        local textLower = displayText:lower()
                        
                        if nameLower:find("wrap") or textLower:find("wrap") 
                           or nameLower:find("paint") or textLower:find("paint")
                           or nameLower:find("kit") or textLower:find("kit")
                           or nameLower:find("wheel") or textLower:find("wheel")
                           or nameLower:find("neon") or textLower:find("neon") then
                            
                            -- Use display text if available, otherwise use button name
                            local id = displayText ~= "" and displayText or itemName
                            
                            if not extracted[id] then
                                extracted[id] = {
                                    id = id,
                                    button = item,
                                    container = container.Name
                                }
                                print("  • Found: " .. id)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- If nothing found, look for any button with cosmetic-like text
    if next(extracted) == nil then
        print("🔍 Doing deep search for cosmetic items...")
        
        for _, item in pairs(PlayerGui:GetDescendants()) do
            if item:IsA("TextButton") then
                local text = item.Text:lower()
                if text:find("wrap") or text:find("paint") 
                   or text:find("kit") or text:find("wheel") 
                   or text:find("neon") or text:find("color") then
                    
                    extracted[item.Text] = {
                        id = item.Text,
                        button = item,
                        container = "Unknown"
                    }
                    print("  • Found via text: " .. item.Text)
                end
            end
        end
    end
    
    return extracted
end

-- ===== HOVER DETECTOR =====
local function CreateHoverDetector()
    print("🖱️ Creating hover detector...")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "HoverDetectorUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    local DetectorFrame = Instance.new("Frame")
    DetectorFrame.Size = UDim2.new(0, 300, 0, 100)
    DetectorFrame.Position = UDim2.new(0.5, -150, 0, 20)
    DetectorFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    DetectorFrame.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = DetectorFrame
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🖱️ HOVER DETECTOR"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Text = "Hover over shop items to see IDs"
    InfoLabel.Size = UDim2.new(1, -20, 1, -40)
    InfoLabel.Position = UDim2.new(0, 10, 0, 40)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextSize = 12
    InfoLabel.TextWrapped = true
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "✕"
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Position = UDim2.new(1, -30, 0, 2)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    -- Parent everything
    Title.Parent = DetectorFrame
    InfoLabel.Parent = DetectorFrame
    CloseBtn.Parent = Title
    DetectorFrame.Parent = ScreenGui
    
    -- Monitor hover events
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local lastHovered = ""
    
    game:GetService("RunService").RenderStepped:Connect(function()
        local mouse = Player:GetMouse()
        local target = mouse.Target
        
        if target and target:IsDescendantOf(PlayerGui) then
            if target ~= lastHovered then
                lastHovered = target
                
                -- Extract info from hovered element
                local info = "Hovering: " .. target.Name .. "\n"
                info = info .. "Class: " .. target.ClassName .. "\n"
                
                -- Get text if available
                if target:IsA("TextButton") or target:IsA("TextLabel") then
                    info = info .. "Text: " .. target.Text .. "\n"
                end
                
                -- Get attributes
                local attributes = {}
                for _, attr in pairs({"ItemId", "ID", "CosmeticId", "ProductId"}) do
                    local value = target:GetAttribute(attr)
                    if value then
                        table.insert(attributes, attr .. ": " .. tostring(value))
                    end
                end
                
                if #attributes > 0 then
                    info = info .. "Attributes:\n" .. table.concat(attributes, "\n")
                end
                
                InfoLabel.Text = info
            end
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    print("✅ Hover detector active! Hover over shop items to see their IDs.")
    
    return ScreenGui
end

-- ===== BULK UNLOCKER UI =====
local function CreateBulkUnlocker(allIDs)
    print("🚀 Creating bulk unlocker...")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BulkUnlockerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    MainFrame.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🎮 COSMETIC ID UNLOCKER"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 15)
    TitleCorner.Parent = Title
    
    -- Scrolling frame for IDs
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 0, 400)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 60)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 8
    
    local ScrollCorner = Instance.new("UICorner")
    ScrollCorner.CornerRadius = UDim.new(0, 10)
    ScrollCorner.Parent = ScrollFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = ScrollFrame
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "Select IDs to unlock"
    Status.Size = UDim2.new(1, -20, 0, 80)
    Status.Position = UDim2.new(0, 10, 1, -140)
    Status.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.TextWrapped = true
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 10)
    StatusCorner.Parent = Status
    
    -- Buttons
    local UnlockSelectedBtn = Instance.new("TextButton")
    UnlockSelectedBtn.Text = "🔓 UNLOCK SELECTED"
    UnlockSelectedBtn.Size = UDim2.new(1, -20, 0, 40)
    UnlockSelectedBtn.Position = UDim2.new(0, 10, 1, -90)
    UnlockSelectedBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    UnlockSelectedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnlockSelectedBtn.Font = Enum.Font.GothamBold
    UnlockSelectedBtn.TextSize = 14
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = UnlockSelectedBtn
    
    local UnlockAllBtn = Instance.new("TextButton")
    UnlockAllBtn.Text = "🎯 UNLOCK ALL"
    UnlockAllBtn.Size = UDim2.new(1, -20, 0, 40)
    UnlockAllBtn.Position = UDim2.new(0, 10, 1, -40)
    UnlockAllBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    UnlockAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnlockAllBtn.Font = Enum.Font.GothamBold
    UnlockAllBtn.TextSize = 14
    
    local AllBtnCorner = Instance.new("UICorner")
    AllBtnCorner.CornerRadius = UDim.new(0, 10)
    AllBtnCorner.Parent = UnlockAllBtn
    
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
    ScrollFrame.Parent = MainFrame
    Status.Parent = MainFrame
    UnlockSelectedBtn.Parent = MainFrame
    UnlockAllBtn.Parent = MainFrame
    CloseBtn.Parent = Title
    MainFrame.Parent = ScreenGui
    
    -- Create checkboxes for each ID
    local selectedIDs = {}
    local checkboxes = {}
    
    local function AddCheckbox(id, category)
        local checkboxFrame = Instance.new("Frame")
        checkboxFrame.Size = UDim2.new(1, -10, 0, 30)
        checkboxFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        checkboxFrame.BackgroundTransparency = 0.5
        
        local checkboxCorner = Instance.new("UICorner")
        checkboxCorner.CornerRadius = UDim.new(0, 6)
        checkboxCorner.Parent = checkboxFrame
        
        local checkbox = Instance.new("TextButton")
        checkbox.Text = "☐ " .. id
        checkbox.Size = UDim2.new(1, -30, 1, 0)
        checkbox.Position = UDim2.new(0, 30, 0, 0)
        checkbox.BackgroundTransparency = 1
        checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkbox.Font = Enum.Font.Gotham
        checkbox.TextSize = 12
        checkbox.TextXAlignment = Enum.TextXAlignment.Left
        
        local checkIcon = Instance.new("TextLabel")
        checkIcon.Text = "☐"
        checkIcon.Size = UDim2.new(0, 20, 0, 20)
        checkIcon.Position = UDim2.new(0, 5, 0, 5)
        checkIcon.BackgroundTransparency = 1
        checkIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
        checkIcon.Font = Enum.Font.Gotham
        checkIcon.TextSize = 14
        
        local categoryLabel = Instance.new("TextLabel")
        categoryLabel.Text = "[" .. category .. "]"
        categoryLabel.Size = UDim2.new(0, 70, 0, 20)
        categoryLabel.Position = UDim2.new(1, -75, 0, 5)
        categoryLabel.BackgroundTransparency = 1
        categoryLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
        categoryLabel.Font = Enum.Font.Gotham
        categoryLabel.TextSize = 10
        
        -- Checkbox click
        checkbox.MouseButton1Click:Connect(function()
            if selectedIDs[id] then
                selectedIDs[id] = nil
                checkIcon.Text = "☐"
                checkbox.Text = "☐ " .. id
            else
                selectedIDs[id] = true
                checkIcon.Text = "✓"
                checkbox.Text = "✓ " .. id
            end
            Status.Text = "Selected: " .. table.count(selectedIDs) .. " IDs"
        end)
        
        checkIcon.Parent = checkboxFrame
        checkbox.Parent = checkboxFrame
        categoryLabel.Parent = checkboxFrame
        checkboxFrame.Parent = ScrollFrame
        
        checkboxes[id] = {
            frame = checkboxFrame,
            checkIcon = checkIcon,
            checkbox = checkbox
        }
    end
    
    -- Add all IDs to the list
    local idCount = 0
    for id, info in pairs(allIDs) do
        AddCheckbox(id, info.category)
        idCount = idCount + 1
    end
    
    -- Update scroll frame size
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
    
    -- Unlock function
    local function PurchaseItem(itemId)
        -- Find purchase remote
        local purchaseRemote = RS:FindFirstChild("PurchaseShopItem", true)
                             or RS:FindFirstChild("Purchase", true)
        
        if purchaseRemote and purchaseRemote:IsA("RemoteFunction") then
            -- Try different formats
            local formats = {
                itemId,
                {ItemId = itemId},
                {id = itemId},
                {Name = itemId}
            }
            
            for _, data in ipairs(formats) do
                local success, result = pcall(function()
                    return purchaseRemote:InvokeServer(data)
                end)
                
                if success then
                    return true, result
                end
            end
        end
        
        return false, "No purchase remote found"
    end
    
    -- Unlock selected
    UnlockSelectedBtn.MouseButton1Click:Connect(function()
        local toUnlock = {}
        for id, _ in pairs(selectedIDs) do
            table.insert(toUnlock, id)
        end
        
        if #toUnlock == 0 then
            Status.Text = "Select IDs first!"
            return
        end
        
        UnlockSelectedBtn.Text = "UNLOCKING..."
        UnlockSelectedBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        Status.Text = "Unlocking " .. #toUnlock .. " items..."
        
        task.spawn(function()
            local unlocked = 0
            
            for _, id in ipairs(toUnlock) do
                local success, result = PurchaseItem(id)
                if success then
                    unlocked = unlocked + 1
                    Status.Text = "Unlocked " .. unlocked .. "/" .. #toUnlock .. "\nLast: " .. id
                end
                
                task.wait(0.1)
            end
            
            UnlockSelectedBtn.Text = "🔓 UNLOCK SELECTED"
            UnlockSelectedBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            Status.Text = "✅ Unlocked " .. unlocked .. "/" .. #toUnlock .. " items!"
        end)
    end)
    
    -- Unlock all
    UnlockAllBtn.MouseButton1Click:Connect(function()
        local total = idCount
        
        UnlockAllBtn.Text = "UNLOCKING ALL..."
        UnlockAllBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        Status.Text = "Unlocking all " .. total .. " items..."
        
        task.spawn(function()
            local unlocked = 0
            local current = 0
            
            for id, _ in pairs(allIDs) do
                current = current + 1
                local success, _ = PurchaseItem(id)
                if success then
                    unlocked = unlocked + 1
                end
                
                Status.Text = "Progress: " .. current .. "/" .. total .. "\nUnlocked: " .. unlocked
                task.wait(0.05)
            end
            
            UnlockAllBtn.Text = "🎯 UNLOCK ALL"
            UnlockAllBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            Status.Text = "✅ Finished!\nUnlocked " .. unlocked .. "/" .. total .. " items"
        end)
    end)
    
    -- Close
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    Status.Text = "Loaded " .. idCount .. " cosmetic IDs\nSelect items to unlock"
    
    return ScreenGui
end

-- ===== MAIN EXECUTION =====
print("=" .. string.rep("=", 60))
print("🔍 COSMETIC ID FINDER & UNLOCKER")
print("=" .. string.rep("=", 60))
print("This script will:")
print("1. Scan game for cosmetic IDs")
print("2. Create hover detector to find IDs")
print("3. Show all found IDs in a list")
print("4. Let you unlock selected IDs")
print("=" .. string.rep("=", 60))

-- Wait for game
task.wait(2)

-- Start scanning
local allIDs, categories = ScanForCosmeticIDs()

-- Create hover detector (helps find IDs in shop)
task.wait(1)
CreateHoverDetector()

-- Extract IDs from current shop if open
task.wait(2)
local shopIDs = ExtractIDsFromCurrentShop()
if next(shopIDs) ~= nil then
    print("🛒 Found", table.count(shopIDs), "IDs in current shop")
    
    -- Add shop IDs to allIDs
    for id, info in pairs(shopIDs) do
        if not allIDs[id] then
            allIDs[id] = {
                id = id,
                category = "Shop",
                source = info.container
            }
        end
    end
end

-- Create bulk unlocker with all found IDs
task.wait(3)
if next(allIDs) ~= nil then
    CreateBulkUnlocker(allIDs)
    print("\n✅ Bulk unlocker created!")
    print("🎯 Found", table.count(allIDs), "total cosmetic IDs")
    print("📝 Open the UI to see and unlock them!")
else
    print("\n⚠️ No cosmetic IDs found!")
    print("💡 Try opening the car customization shop first,")
    print("   then run the script again.")
end

-- Instructions
print("\n" .. string.rep("=", 60))
print("📖 HOW TO FIND COSMETIC IDs:")
print(string.rep("=", 60))
print("1. OPEN the car customization shop in-game")
print("2. HOVER over items with the hover detector")
print("3. LOOK for IDs in the displayed info")
print("4. CHECK the list in the unlocker UI")
print("5. SELECT and UNLOCK items you want")
print(string.rep("=", 60))
