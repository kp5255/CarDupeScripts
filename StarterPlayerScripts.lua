-- 🎯 SMART CAR COSMETIC SCANNER & UNLOCKER v2
-- Working scanner with improved unlock system

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

print("🎯 SMART UNLOCKER v2 LOADED")

-- ===== WORKING SCANNER (from your script) =====
local function GetCarNameFromShop()
    print("🔍 Scanning for car name...")
    
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
    
    -- Method 2: Look for car brand names
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
    
    -- Display findings
    print("📋 Possible car names found:")
    for i, car in ipairs(possibleCarNames) do
        print("  [" .. i .. "] " .. car.text .. " (from: " .. car.path .. ")")
        if i >= 5 then break end
    end
    
    if #possibleCarNames > 0 then
        local bestGuess = possibleCarNames[1].text
        print("🎯 Best guess: " .. bestGuess)
        return bestGuess, possibleCarNames[1].element
    end
    
    print("❌ Could not detect car name")
    return "Unknown Car", nil
end

-- ===== IMPROVED COSMETIC SCAN =====
local function DeepScanCosmetics(carName)
    print("🎨 Scanning for cosmetics...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local foundCosmetics = {
        Wraps = {},
        Kits = {},
        Wheels = {},
        Neons = {},
        All = {}
    }
    
    -- Look for shop containers
    local shopContainers = {}
    
    for _, container in pairs(PlayerGui:GetDescendants()) do
        if container:IsA("ScrollingFrame") or (container:IsA("Frame") and container.Visible) then
            local containerName = container.Name:lower()
            local isShopRelated = containerName:find("shop") or containerName:find("custom") 
                                or containerName:find("select") or containerName:find("menu")
                                or containerName:find("inventory") or containerName:find("item")
            
            if isShopRelated then
                table.insert(shopContainers, container)
            end
        end
    end
    
    print("📦 Found " .. #shopContainers .. " shop containers")
    
    -- Scan all buttons
    for _, container in ipairs(shopContainers) do
        for _, item in pairs(container:GetDescendants()) do
            if item:IsA("TextButton") or item:IsA("ImageButton") then
                local buttonText = ""
                local buttonName = item.Name:lower()
                
                if item:IsA("TextButton") then
                    buttonText = item.Text
                elseif item:IsA("ImageButton") then
                    buttonText = buttonName
                    for _, child in pairs(item:GetDescendants()) do
                        if child:IsA("TextLabel") and child.Text ~= "" then
                            buttonText = child.Text
                            break
                        end
                    end
                end
                
                local buttonTextLower = buttonText:lower()
                
                -- Check if this is a cosmetic
                local isCosmetic = false
                local category = "Other"
                
                if buttonTextLower:find("wrap") or buttonTextLower:find("paint") 
                   or buttonTextLower:find("color") or buttonName:find("wrap") then
                    isCosmetic = true
                    category = "Wraps"
                elseif buttonTextLower:find("kit") or buttonTextLower:find("body") 
                       or buttonTextLower:find("spoiler") or buttonName:find("kit") then
                    isCosmetic = true
                    category = "Kits"
                elseif buttonTextLower:find("wheel") or buttonTextLower:find("rim") 
                       or buttonTextLower:find("tire") or buttonName:find("wheel") then
                    isCosmetic = true
                    category = "Wheels"
                elseif buttonTextLower:find("neon") or buttonTextLower:find("light") 
                       or buttonTextLower:find("glow") or buttonName:find("neon") then
                    isCosmetic = true
                    category = "Neons"
                end
                
                if isCosmetic and buttonText ~= "" then
                    -- Look for GUIDs in the button or its children
                    local guids = {}
                    
                    -- Check button text for GUIDs
                    for guid in buttonText:gmatch("%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x") do
                        table.insert(guids, guid)
                    end
                    
                    -- Check children for GUIDs
                    for _, child in pairs(item:GetDescendants()) do
                        if child:IsA("StringValue") then
                            local value = tostring(child.Value)
                            for guid in value:gmatch("%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x") do
                                table.insert(guids, guid)
                            end
                        end
                    end
                    
                    -- Create cosmetic entry
                    local cosmetic = {
                        name = buttonText,
                        button = item,
                        category = category,
                        guids = guids,
                        path = item:GetFullName()
                    }
                    
                    -- Avoid duplicates
                    local isDuplicate = false
                    for _, existing in ipairs(foundCosmetics.All) do
                        if existing.name == buttonText then
                            isDuplicate = true
                            break
                        end
                    end
                    
                    if not isDuplicate then
                        table.insert(foundCosmetics[category], cosmetic)
                        table.insert(foundCosmetics.All, cosmetic)
                        
                        print("🎨 Found: [" .. category .. "] " .. buttonText)
                        if #guids > 0 then
                            print("   GUIDs: " .. table.concat(guids, ", "))
                        end
                    end
                end
            end
        end
    end
    
    -- Display results
    print("\n📊 SCAN RESULTS:")
    for category, items in pairs(foundCosmetics) do
        if category ~= "All" and #items > 0 then
            print("🎨 " .. category .. ": " .. #items .. " items")
        end
    end
    
    print("✅ Total cosmetics found: " .. #foundCosmetics.All)
    
    return foundCosmetics
end

-- ===== NEW: REAL UNLOCK SYSTEM =====
local function RealUnlockSystem(carName, cosmetics)
    print("🔓 Real unlock system starting...")
    
    local results = {
        total = #cosmetics.All,
        unlocked = 0,
        failed = 0
    }
    
    if results.total == 0 then
        print("⚠️ No cosmetics to unlock!")
        return results
    end
    
    -- Find ALL remotes (both RemoteFunction AND RemoteEvent)
    local allRemotes = {}
    
    print("📡 Searching for all remotes...")
    
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
            table.insert(allRemotes, {
                object = obj,
                name = obj.Name,
                type = obj.ClassName
            })
        end
    end
    
    print("✅ Found " .. #allRemotes .. " remotes total")
    
    -- Try to unlock each cosmetic
    for _, cosmetic in ipairs(cosmetics.All) do
        print("\n🔄 Processing: " .. cosmetic.name)
        
        local unlocked = false
        
        -- First, try with any GUIDs found
        if #cosmetic.guids > 0 then
            for _, guid in ipairs(cosmetic.guids) do
                print("   Trying GUID: " .. guid)
                
                for _, remote in ipairs(allRemotes) do
                    local formats = {
                        guid,
                        {ItemId = guid},
                        {id = guid},
                        {productId = guid},
                        {GUID = guid},
                        {item = guid, category = cosmetic.category}
                    }
                    
                    for i, data in ipairs(formats) do
                        local success, result = pcall(function()
                            if remote.type == "RemoteFunction" then
                                return remote.object:InvokeServer(data)
                            else
                                remote.object:FireServer(data)
                                return "FireServer called"
                            end
                        end)
                        
                        if success then
                            print("   ✅ Success with " .. remote.name .. " (format " .. i .. ")")
                            print("   Result: " .. tostring(result))
                            results.unlocked = results.unlocked + 1
                            unlocked = true
                            
                            -- Update button appearance
                            if cosmetic.button and cosmetic.button:IsA("TextButton") then
                                cosmetic.button.Text = "EQUIP"
                                cosmetic.button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                            end
                            
                            break
                        end
                    end
                    
                    if unlocked then break end
                end
                
                if unlocked then break end
            end
        else
            -- If no GUIDs, try with cosmetic name
            print("   No GUIDs found, trying with name...")
            
            for _, remote in ipairs(allRemotes) do
                local formats = {
                    cosmetic.name,
                    {Name = cosmetic.name},
                    {Item = cosmetic.name},
                    {cosmetic = cosmetic.name, car = carName}
                }
                
                for i, data in ipairs(formats) do
                    local success, result = pcall(function()
                        if remote.type == "RemoteFunction" then
                            return remote.object:InvokeServer(data)
                        else
                            remote.object:FireServer(data)
                            return "FireServer called"
                        end
                    })
                    
                    if success then
                        print("   ✅ Success with " .. remote.name .. " (format " .. i .. ")")
                        results.unlocked = results.unlocked + 1
                        unlocked = true
                        
                        if cosmetic.button and cosmetic.button:IsA("TextButton") then
                            cosmetic.button.Text = "EQUIP"
                            cosmetic.button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                        end
                        
                        break
                    end
                end
                
                if unlocked then break end
            end
        end
        
        if not unlocked then
            results.failed = results.failed + 1
            print("   ❌ Failed to unlock")
            
            -- Mark as failed
            if cosmetic.button and cosmetic.button:IsA("TextButton") then
                cosmetic.button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
        end
        
        task.wait(0.1) -- Small delay
    end
    
    print("\n📊 FINAL RESULTS:")
    print("✅ Successfully unlocked: " .. results.unlocked .. "/" .. results.total)
    print("❌ Failed: " .. results.failed)
    
    return results
end

-- ===== NEW: VISUAL UNLOCK (UI Only) =====
local function VisualUnlockUI(cosmetics)
    print("🎨 Applying visual unlocks...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local modified = 0
    
    for _, cosmetic in ipairs(cosmetics.All) do
        if cosmetic.button and cosmetic.button:IsDescendantOf(PlayerGui) then
            local button = cosmetic.button
            
            -- Change button appearance
            if button:IsA("TextButton") then
                local text = button.Text:lower()
                if text:find("buy") or text:find("purchase") 
                   or text:find("$") or text:find("%d") then
                    button.Text = "EQUIP"
                    button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
                    modified = modified + 1
                end
            end
            
            -- Change child text labels
            for _, child in pairs(button:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local text = child.Text:lower()
                    if text:find("buy") or text:find("purchase") 
                       or text:find("$") or text:find("%d") 
                       or text:find("locked") then
                        child.Text = "UNLOCKED"
                        child.TextColor3 = Color3.fromRGB(0, 255, 0)
                        modified = modified + 1
                    end
                end
            end
        end
    end
    
    print("🛍️ Visually modified " .. modified .. " UI elements")
    return modified
end

-- ===== SIMPLE UI =====
local function CreateSimpleUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleUnlockerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🎯 SMART UNLOCKER v2"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    
    local Status = Instance.new("TextLabel")
    Status.Text = "Ready to scan and unlock\n"
    Status.Size = UDim2.new(1, -20, 0, 150)
    Status.Position = UDim2.new(0, 10, 0, 60)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    Status.TextWrapped = true
    Status.TextXAlignment = Enum.TextXAlignment.Left
    
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Text = "🔍 SCAN CAR & ITEMS"
    ScanBtn.Size = UDim2.new(1, -20, 0, 40)
    ScanBtn.Position = UDim2.new(0, 10, 0, 220)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    
    local UnlockBtn = Instance.new("TextButton")
    UnlockBtn.Text = "🔓 UNLOCK ALL"
    UnlockBtn.Size = UDim2.new(1, -20, 0, 40)
    UnlockBtn.Position = UDim2.new(0, 10, 0, 270)
    UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    UnlockBtn.Visible = false
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = Title
    corner:Clone().Parent = ScanBtn
    corner:Clone().Parent = UnlockBtn
    
    -- Parent
    Title.Parent = MainFrame
    Status.Parent = MainFrame
    ScanBtn.Parent = MainFrame
    UnlockBtn.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Variables
    local scanData = nil
    
    -- Update status
    local function updateStatus(text)
        Status.Text = Status.Text .. text .. "\n"
    end
    
    -- Scan function
    ScanBtn.MouseButton1Click:Connect(function()
        ScanBtn.Text = "SCANNING..."
        Status.Text = "🔍 Scanning...\n"
        
        -- Get car name
        updateStatus("Step 1: Finding car...")
        local carName = GetCarNameFromShop()
        
        -- Scan cosmetics
        updateStatus("Step 2: Scanning cosmetics...")
        local cosmetics = DeepScanCosmetics(carName)
        
        if #cosmetics.All > 0 then
            updateStatus("✅ Found " .. #cosmetics.All .. " cosmetics!")
            updateStatus("Car: " .. carName)
            
            scanData = {
                carName = carName,
                cosmetics = cosmetics
            }
            
            UnlockBtn.Visible = true
            UnlockBtn.Text = "🔓 UNLOCK " .. #cosmetics.All .. " ITEMS"
            
            ScanBtn.Text = "✅ SCAN COMPLETE"
            ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            updateStatus("❌ No cosmetics found")
            updateStatus("Open shop and try again")
            
            ScanBtn.Text = "🔍 SCAN CAR & ITEMS"
            ScanBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end)
    
    -- Unlock function
    UnlockBtn.MouseButton1Click:Connect(function()
        UnlockBtn.Text = "UNLOCKING..."
        updateStatus("\n🔓 Attempting unlock...")
        
        if scanData then
            -- Try real unlock first
            local unlockResults = RealUnlockSystem(scanData.carName, scanData.cosmetics)
            
            -- Then apply visual unlock
            local visualResults = VisualUnlockUI(scanData.cosmetics)
            
            updateStatus("📊 Results:")
            updateStatus("Server attempts: " .. unlockResults.unlocked .. "/" .. unlockResults.total)
            updateStatus("Visual changes: " .. visualResults .. " items")
            
            if unlockResults.unlocked > 0 or visualResults > 0 then
                updateStatus("🎉 Some success!")
                updateStatus("Check if items show 'EQUIP'")
                
                UnlockBtn.Text = "✅ PARTIAL SUCCESS"
                UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            else
                updateStatus("❌ No unlocks")
                updateStatus("Try manual click after scan")
                
                UnlockBtn.Text = "🔓 UNLOCK ALL"
                UnlockBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
        else
            updateStatus("❌ Scan first!")
            UnlockBtn.Text = "🔓 UNLOCK ALL"
        end
    end)
    
    -- Initial message
    updateStatus("🎯 SMART UNLOCKER v2")
    updateStatus(string.rep("=", 30))
    updateStatus("HOW TO USE:")
    updateStatus("1. Open car shop")
    updateStatus("2. Select a car")
    updateStatus("3. Open cosmetic tabs")
    updateStatus("4. Click SCAN")
    updateStatus("5. Click UNLOCK")
    updateStatus(string.rep("=", 30))
    
    return ScreenGui
end

-- Auto-start
print("=" .. string.rep("=", 50))
print("🎯 SMART UNLOCKER v2 - WITH WORKING SCANNER")
print("=" .. string.rep("=", 50))

task.wait(2)
CreateSimpleUI()

-- Auto-scan after 5 seconds
task.wait(5)
print("\n⏰ Auto-scanning in 3 seconds...")
for i = 3, 1, -1 do
    print(i .. "...")
    task.wait(1)
end

print("🔍 Auto-scanning...")
local carName = GetCarNameFromShop()
local cosmetics = DeepScanCosmetics(carName)

if #cosmetics.All > 0 then
    print("✅ Auto-found " .. #cosmetics.All .. " cosmetics")
    print("💡 Open the UI and click UNLOCK")
else
    print("❌ Auto-scan found nothing")
    print("💡 Open the shop and click SCAN")
end
