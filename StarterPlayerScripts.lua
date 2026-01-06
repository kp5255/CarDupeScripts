-- 🏎️ ULTIMATE CAR COSMETIC UNLOCKER
-- Complete solution for Car Dealership Tycoon

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Player = Players.LocalPlayer

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
task.wait(3)

print("=" .. string.rep("=", 70))
print("🏎️ ULTIMATE CAR COSMETIC UNLOCKER v3.0")
print("=" .. string.rep("=", 70))

-- ===== ADVANCED VALUE FINDER =====
local function AdvancedValueFinder()
    print("🔍 Starting advanced value scan...")
    
    local foundValues = {
        guids = {},
        numericIDs = {},
        lockValues = {},
        priceValues = {},
        allValues = {}
    }
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Scan entire PlayerGui
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        local className = obj.ClassName
        local name = obj.Name
        local value = nil
        
        -- Get value based on class
        if className == "StringValue" then
            value = tostring(obj.Value)
        elseif className == "IntValue" or className == "NumberValue" then
            value = tonumber(obj.Value)
        elseif className == "BoolValue" then
            value = obj.Value
        end
        
        if value ~= nil then
            local entry = {
                object = obj,
                name = name,
                className = className,
                value = value,
                path = obj:GetFullName()
            }
            
            table.insert(foundValues.allValues, entry)
            
            -- Categorize
            if className == "StringValue" then
                -- Check for GUID pattern
                if tostring(value):match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
                    table.insert(foundValues.guids, entry)
                    print("🎯 Found GUID: " .. value .. " in " .. name)
                end
                
                -- Check for numeric ID
                if tostring(value):match("^%d+$") and #tostring(value) >= 4 then
                    table.insert(foundValues.numericIDs, entry)
                end
            end
            
            -- Check for lock-related values
            local nameLower = name:lower()
            if nameLower:find("lock") or nameLower:find("owned") 
               or nameLower:find("purchased") or nameLower:find("unlocked") then
                table.insert(foundValues.lockValues, entry)
                print("🔐 Found lock value: " .. name .. " = " .. tostring(value))
            end
            
            -- Check for price-related values
            if nameLower:find("price") or nameLower:find("cost") 
               or nameLower:find("value") then
                table.insert(foundValues.priceValues, entry)
            end
        end
    end
    
    print("\n📊 SCAN RESULTS:")
    print("Total values found: " .. #foundValues.allValues)
    print("GUIDs found: " .. #foundValues.guids)
    print("Lock values found: " .. #foundValues.lockValues)
    print("Price values found: " .. #foundValues.priceValues)
    print("Numeric IDs found: " .. #foundValues.numericIDs)
    
    return foundValues
end

-- ===== REMOTE FUNCTION DETECTOR =====
local function FindAllRemotes()
    print("📡 Scanning for remote functions/events...")
    
    local remotes = {
        functions = {},
        events = {},
        all = {}
    }
    
    -- Check ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteFunction") then
            table.insert(remotes.functions, obj)
            table.insert(remotes.all, obj)
        elseif obj:IsA("RemoteEvent") then
            table.insert(remotes.events, obj)
            table.insert(remotes.all, obj)
        end
    end
    
    -- Check Workspace
    for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("RemoteFunction") then
            table.insert(remotes.functions, obj)
            table.insert(remotes.all, obj)
        elseif obj:IsA("RemoteEvent") then
            table.insert(remotes.events, obj)
            table.insert(remotes.all, obj)
        end
    end
    
    -- Check ServerScriptService
    local success, sss = pcall(function() return game:GetService("ServerScriptService") end)
    if success and sss then
        for _, obj in pairs(sss:GetDescendants()) do
            if obj:IsA("RemoteFunction") then
                table.insert(remotes.functions, obj)
                table.insert(remotes.all, obj)
            elseif obj:IsA("RemoteEvent") then
                table.insert(remotes.events, obj)
                table.insert(remotes.all, obj)
            end
        end
    end
    
    print("\n📊 REMOTE SCAN RESULTS:")
    print("RemoteFunctions found: " .. #remotes.functions)
    print("RemoteEvents found: " .. #remotes.events)
    print("Total remotes: " .. #remotes.all)
    
    -- Show remote names
    print("\n🎯 REMOTE NAMES:")
    for i, remote in ipairs(remotes.all) do
        if i <= 20 then  -- Limit to first 20
            print("  " .. i .. ". " .. remote.Name .. " (" .. remote.ClassName .. ")")
        end
    end
    
    if #remotes.all > 20 then
        print("  ... and " .. (#remotes.all - 20) .. " more")
    end
    
    return remotes
end

-- ===== UI ELEMENT DETECTOR =====
local function FindShopUI()
    print("🛍️ Looking for shop UI elements...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local uiElements = {
        buttons = {},
        labels = {},
        frames = {},
        containers = {}
    }
    
    -- Find all UI elements
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        local className = obj.ClassName
        local name = obj.Name:lower()
        local text = ""
        
        if className == "TextButton" then
            text = obj.Text:lower()
            table.insert(uiElements.buttons, {
                object = obj,
                name = obj.Name,
                text = obj.Text,
                path = obj:GetFullName()
            })
        elseif className == "TextLabel" then
            text = obj.Text:lower()
            table.insert(uiElements.labels, {
                object = obj,
                name = obj.Name,
                text = obj.Text,
                path = obj:GetFullName()
            })
        elseif className == "Frame" or className == "ScrollingFrame" then
            table.insert(uiElements.frames, {
                object = obj,
                name = obj.Name,
                className = className,
                path = obj:GetFullName()
            })
        end
        
        -- Check for shop/customization containers
        if name:find("shop") or name:find("custom") 
           or name:find("inventory") or name:find("menu")
           or name:find("wrap") or name:find("kit")
           or name:find("wheel") or name:find("neon")
           or text:find("buy") or text:find("purchase")
           or text:find("equip") then
            
            table.insert(uiElements.containers, {
                object = obj,
                name = obj.Name,
                className = className,
                text = text,
                path = obj:GetFullName()
            })
        end
    end
    
    print("\n📊 UI SCAN RESULTS:")
    print("Buttons: " .. #uiElements.buttons)
    print("Labels: " .. #uiElements.labels)
    print("Frames: " .. #uiElements.frames)
    print("Shop containers: " .. #uiElements.containers)
    
    -- Show interesting containers
    print("\n🎯 INTERESTING CONTAINERS:")
    for i, container in ipairs(uiElements.containers) do
        if i <= 10 then
            print("  " .. i .. ". " .. container.name .. " (" .. container.className .. ")")
            if container.text ~= "" then
                print("     Text: " .. container.text)
            end
        end
    end
    
    return uiElements
end

-- ===== ADVANCED UNLOCK ATTEMPT =====
local function AttemptAdvancedUnlock(values, remotes)
    print("🔓 Starting advanced unlock attempt...")
    
    local results = {
        attempts = 0,
        successes = 0,
        failures = 0,
        details = {}
    }
    
    -- Create test data from found values
    local testData = {}
    
    -- Add GUIDs
    for _, guidEntry in ipairs(values.guids) do
        table.insert(testData, {
            type = "GUID",
            value = guidEntry.value,
            source = guidEntry.name
        })
    end
    
    -- Add numeric IDs
    for _, idEntry in ipairs(values.numericIDs) do
        table.insert(testData, {
            type = "NumericID",
            value = idEntry.value,
            source = idEntry.name
        })
    end
    
    -- Add lock values that are 0 (locked)
    for _, lockEntry in ipairs(values.lockValues) do
        if lockEntry.value == 0 or lockEntry.value == false then
            table.insert(testData, {
                type = "LockValue",
                value = lockEntry.value,
                source = lockEntry.name
            })
        end
    end
    
    print("\n🎯 TEST DATA PREPARED:")
    print("Items to test: " .. #testData)
    
    -- Try each piece of data with each remote
    for _, data in ipairs(testData) do
        print("\n🔄 Testing: " .. data.type .. " = " .. tostring(data.value))
        
        for _, remote in ipairs(remotes.all) do
            -- Skip if we've already had success with this remote
            if results.details[remote.Name] and results.details[remote.Name].success then
                -- Already succeeded with this remote, skip to save time
                -- Remove this line if you want to test everything
            else
                -- Try different formats
                local formats = {}
                
                if data.type == "GUID" then
                    formats = {
                        data.value,
                        {ItemId = data.value},
                        {id = data.value},
                        {GUID = data.value},
                        {UUID = data.value},
                        {productId = data.value},
                        {item = data.value},
                        {Item = data.value, Player = Player}
                    }
                elseif data.type == "NumericID" then
                    formats = {
                        data.value,
                        {ItemId = data.value},
                        {id = data.value},
                        {productId = data.value},
                        {itemId = data.value}
                    }
                elseif data.type == "LockValue" then
                    formats = {
                        {unlock = true},
                        {purchase = true},
                        {buy = true},
                        {item = data.source, unlock = true}
                    }
                end
                
                for formatIndex, formatData in ipairs(formats) do
                    results.attempts = results.attempts + 1
                    
                    local success, result = pcall(function()
                        if remote:IsA("RemoteFunction") then
                            return remote:InvokeServer(formatData)
                        else
                            remote:FireServer(formatData)
                            return "FireServer called (no return value)"
                        end
                    end)
                    
                    if success then
                        print("   ✅ SUCCESS with " .. remote.Name .. " (format " .. formatIndex .. ")")
                        print("   Result: " .. tostring(result))
                        
                        results.successes = results.successes + 1
                        
                        if not results.details[remote.Name] then
                            results.details[remote.Name] = {
                                success = true,
                                dataUsed = data.value,
                                format = formatIndex,
                                result = result
                            }
                        end
                        
                        -- Found a working remote, try to use it more
                        break
                    else
                        -- Don't print every failure to avoid spam
                        if formatIndex == 1 then
                            -- print("   ❌ Failed with " .. remote.Name)
                        end
                    end
                    
                    task.wait(0.01) -- Small delay between attempts
                end
            end
            
            -- Small delay between remotes
            task.wait(0.05)
        end
    end
    
    print("\n📊 ADVANCED UNLOCK RESULTS:")
    print("Total attempts: " .. results.attempts)
    print("Successes: " .. results.successes)
    print("Failures: " .. results.failures)
    
    if results.successes > 0 then
        print("\n🎉 SUCCESSFUL REMOTES:")
        for remoteName, info in pairs(results.details) do
            if info.success then
                print("  ✅ " .. remoteName)
                print("     Used data: " .. tostring(info.dataUsed))
                print("     Format: " .. tostring(info.format))
                print("     Result: " .. tostring(info.result))
            end
        end
    else
        print("\n❌ No successful unlocks")
        print("💡 Try opening the shop and browsing cosmetics first")
    end
    
    return results
end

-- ===== VISUAL UI MODIFIER =====
local function ModifyShopUI()
    print("🎨 Modifying shop UI visually...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local modified = 0
    
    -- Find and modify all buy buttons
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("TextButton") then
            local text = obj.Text:lower()
            
            if text:find("buy") or text:find("purchase") 
               or text:find("$") or text:find("%d%d%d") then
                
                -- Change to EQUIP
                obj.Text = "EQUIP"
                obj.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
                
                -- Make text white for better visibility
                obj.TextColor3 = Color3.fromRGB(255, 255, 255)
                
                modified = modified + 1
            end
        elseif obj:IsA("TextLabel") then
            local text = obj.Text:lower()
            
            if text:find("locked") or text:find("not owned") 
               or text:find("purchase") then
                
                -- Change to UNLOCKED
                obj.Text = "UNLOCKED"
                obj.TextColor3 = Color3.fromRGB(0, 255, 0)
                
                modified = modified + 1
            end
        elseif obj:IsA("IntValue") or obj:IsA("NumberValue") then
            -- Try to unlock numeric lock values
            if obj.Name:lower():find("lock") then
                if obj.Value == 0 then
                    obj.Value = 1
                    print("🔓 Changed " .. obj.Name .. " from 0 to 1")
                    modified = modified + 1
                end
            end
        elseif obj:IsA("BoolValue") then
            -- Try to unlock boolean lock values
            if obj.Name:lower():find("lock") or obj.Name:lower():find("owned") then
                if obj.Value == false then
                    obj.Value = true
                    print("🔓 Changed " .. obj.Name .. " from false to true")
                    modified = modified + 1
                end
            end
        end
    end
    
    print("\n🛍️ VISUAL MODIFICATION RESULTS:")
    print("Modified elements: " .. modified)
    
    if modified > 0 then
        print("✅ Shop should now show items as unlocked!")
        print("💡 Items should show 'EQUIP' instead of 'BUY'")
    else
        print("❌ No elements modified")
        print("💡 Open the shop first, then try again")
    end
    
    return modified
end

-- ===== CREATE ADVANCED UI =====
local function CreateAdvancedUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UltimateUnlockerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(0, 150, 255)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🏎️ ULTIMATE CAR UNLOCKER"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title
    
    -- Status Display
    local StatusFrame = Instance.new("ScrollingFrame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 350)
    StatusFrame.Position = UDim2.new(0, 10, 0, 60)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    StatusFrame.ScrollBarThickness = 8
    StatusFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Text = "ULTIMATE UNLOCKER READY\n" .. string.rep("=", 50) .. "\n"
    StatusLabel.Size = UDim2.new(1, -10, 0, 0)
    StatusLabel.Position = UDim2.new(0, 5, 0, 5)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.Font = Enum.Font.Code
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatusLabel.TextWrapped = true
    StatusLabel.AutomaticSize = Enum.AutomaticSize.Y
    
    -- Buttons Frame
    local ButtonsFrame = Instance.new("Frame")
    ButtonsFrame.Size = UDim2.new(1, -20, 0, 160)
    ButtonsFrame.Position = UDim2.new(0, 10, 0, 420)
    ButtonsFrame.BackgroundTransparency = 1
    
    -- Scan Button
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Text = "🔍 SCAN EVERYTHING"
    ScanBtn.Size = UDim2.new(1, 0, 0, 35)
    ScanBtn.Position = UDim2.new(0, 0, 0, 0)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.GothamBold
    ScanBtn.TextSize = 14
    
    local ScanCorner = Instance.new("UICorner")
    ScanCorner.CornerRadius = UDim.new(0, 8)
    ScanCorner.Parent = ScanBtn
    
    -- Unlock Button
    local UnlockBtn = Instance.new("TextButton")
    UnlockBtn.Text = "🔓 ADVANCED UNLOCK"
    UnlockBtn.Size = UDim2.new(1, 0, 0, 35)
    UnlockBtn.Position = UDim2.new(0, 0, 0, 45)
    UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnlockBtn.Font = Enum.Font.GothamBold
    UnlockBtn.TextSize = 14
    
    local UnlockCorner = Instance.new("UICorner")
    UnlockCorner.CornerRadius = UDim.new(0, 8)
    UnlockCorner.Parent = UnlockBtn
    
    -- Visual Modify Button
    local VisualBtn = Instance.new("TextButton")
    VisualBtn.Text = "🎨 VISUAL UNLOCK"
    VisualBtn.Size = UDim2.new(1, 0, 0, 35)
    VisualBtn.Position = UDim2.new(0, 0, 0, 90)
    VisualBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    VisualBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    VisualBtn.Font = Enum.Font.GothamBold
    VisualBtn.TextSize = 14
    
    local VisualCorner = Instance.new("UICorner")
    VisualCorner.CornerRadius = UDim.new(0, 8)
    VisualCorner.Parent = VisualBtn
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "✕ CLOSE"
    CloseBtn.Size = UDim2.new(1, 0, 0, 35)
    CloseBtn.Position = UDim2.new(0, 0, 0, 135)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn
    
    -- Progress Bar
    local ProgressFrame = Instance.new("Frame")
    ProgressFrame.Size = UDim2.new(1, -20, 0, 20)
    ProgressFrame.Position = UDim2.new(0, 10, 0, 590)
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
    
    -- Parent everything
    StatusLabel.Parent = StatusFrame
    ProgressBar.Parent = ProgressFrame
    
    Title.Parent = MainFrame
    StatusFrame.Parent = MainFrame
    ButtonsFrame.Parent = MainFrame
    ProgressFrame.Parent = MainFrame
    
    ScanBtn.Parent = ButtonsFrame
    UnlockBtn.Parent = ButtonsFrame
    VisualBtn.Parent = ButtonsFrame
    CloseBtn.Parent = ButtonsFrame
    
    MainFrame.Parent = ScreenGui
    
    -- Variables
    local scanData = {}
    local isProcessing = false
    
    -- Update status function
    local function updateStatus(text, color)
        color = color or Color3.fromRGB(255, 255, 255)
        StatusLabel.Text = StatusLabel.Text .. text .. "\n"
        StatusLabel.TextColor3 = color
        
        -- Auto-scroll
        StatusFrame.CanvasSize = UDim2.new(0, 0, 0, StatusLabel.TextBounds.Y + 20)
        StatusFrame.CanvasPosition = Vector2.new(0, StatusLabel.TextBounds.Y)
    end
    
    local function clearStatus()
        StatusLabel.Text = ""
    end
    
    -- Scan function
    ScanBtn.MouseButton1Click:Connect(function()
        if isProcessing then return end
        isProcessing = true
        
        ScanBtn.Text = "SCANNING..."
        clearStatus()
        updateStatus("🔍 STARTING COMPREHENSIVE SCAN...", Color3.fromRGB(255, 200, 0))
        
        task.spawn(function()
            -- Scan values
            updateStatus("\n📊 SCANNING FOR VALUES...", Color3.fromRGB(255, 255, 200))
            scanData.values = AdvancedValueFinder()
            
            updateStatus("✅ Found " .. #scanData.values.allValues .. " total values", Color3.fromRGB(0, 255, 0))
            updateStatus("✅ Found " .. #scanData.values.guids .. " GUIDs", Color3.fromRGB(0, 255, 0))
            updateStatus("✅ Found " .. #scanData.values.lockValues .. " lock values", Color3.fromRGB(0, 255, 0))
            
            -- Scan remotes
            updateStatus("\n📡 SCANNING FOR REMOTES...", Color3.fromRGB(255, 255, 200))
            scanData.remotes = FindAllRemotes()
            
            updateStatus("✅ Found " .. #scanData.remotes.all .. " total remotes", Color3.fromRGB(0, 255, 0))
            
            -- Scan UI
            updateStatus("\n🛍️ SCANNING FOR UI ELEMENTS...", Color3.fromRGB(255, 255, 200))
            scanData.ui = FindShopUI()
            
            updateStatus("✅ Found " .. #scanData.ui.containers .. " shop containers", Color3.fromRGB(0, 255, 0))
            
            -- Summary
            updateStatus("\n🎯 SCAN COMPLETE!", Color3.fromRGB(0, 255, 0))
            updateStatus("Ready for unlocking attempts.", Color3.fromRGB(200, 200, 255))
            
            ScanBtn.Text = "✅ SCAN COMPLETE"
            ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            isProcessing = false
        end)
    end)
    
    -- Unlock function
    UnlockBtn.MouseButton1Click:Connect(function()
        if isProcessing then return end
        if not scanData.values or not scanData.remotes then
            updateStatus("❌ Scan first!", Color3.fromRGB(255, 100, 100))
            return
        end
        
        isProcessing = true
        UnlockBtn.Text = "UNLOCKING..."
        updateStatus("\n🔓 STARTING ADVANCED UNLOCK...", Color3.fromRGB(255, 200, 0))
        
        task.spawn(function()
            local results = AttemptAdvancedUnlock(scanData.values, scanData.remotes)
            
            updateStatus("\n📊 UNLOCK RESULTS:", Color3.fromRGB(200, 220, 255))
            updateStatus("Attempts: " .. results.attempts, Color3.fromRGB(255, 255, 200))
            updateStatus("Successes: " .. results.successes, Color3.fromRGB(0, 255, 0))
            
            if results.successes > 0 then
                updateStatus("🎉 Some items may be unlocked!", Color3.fromRGB(0, 255, 0))
                updateStatus("💡 Check the shop for 'EQUIP' buttons", Color3.fromRGB(200, 255, 200))
                
                UnlockBtn.Text = "✅ PARTIAL SUCCESS"
                UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            else
                updateStatus("❌ No server-side unlocks", Color3.fromRGB(255, 100, 100))
                updateStatus("💡 Try visual unlock or open shop first", Color3.fromRGB(255, 200, 100))
                
                UnlockBtn.Text = "🔓 ADVANCED UNLOCK"
            end
            
            isProcessing = false
        end)
    end)
    
    -- Visual unlock function
    VisualBtn.MouseButton1Click:Connect(function()
        if isProcessing then return end
        isProcessing = true
        
        VisualBtn.Text = "MODIFYING..."
        updateStatus("\n🎨 APPLYING VISUAL UNLOCKS...", Color3.fromRGB(255, 200, 0))
        
        task.spawn(function()
            local modified = ModifyShopUI()
            
            updateStatus("\n🛍️ VISUAL RESULTS:", Color3.fromRGB(200, 220, 255))
            updateStatus("Modified elements: " .. modified, Color3.fromRGB(255, 255, 200))
            
            if modified > 0 then
                updateStatus("✅ Shop UI should show items as unlocked!", Color3.fromRGB(0, 255, 0))
                updateStatus("💡 Look for 'EQUIP' buttons in the shop", Color3.fromRGB(200, 255, 200))
                
                VisualBtn.Text = "✅ VISUAL DONE"
                VisualBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            else
                updateStatus("❌ No visual changes made", Color3.fromRGB(255, 100, 100))
                updateStatus("💡 Open the shop first, then try again", Color3.fromRGB(255, 200, 100))
                
                VisualBtn.Text = "🎨 VISUAL UNLOCK"
            end
            
            isProcessing = false
        end)
    end)
    
    -- Close button
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Initial message
    clearStatus()
    updateStatus("🏎️ ULTIMATE CAR UNLOCKER v3.0", Color3.fromRGB(0, 200, 255))
    updateStatus(string.rep("=", 50), Color3.fromRGB(100, 100, 100))
    updateStatus("COMPLETE UNLOCKING SOLUTION", Color3.fromRGB(200, 220, 255))
    updateStatus(string.rep("=", 50), Color3.fromRGB(100, 100, 100))
    updateStatus("INSTRUCTIONS:", Color3.fromRGB(255, 255, 200))
    updateStatus("1. Open car customization shop", Color3.fromRGB(255, 255, 200))
    updateStatus("2. Select a car and browse cosmetics", Color3.fromRGB(255, 255, 200))
    updateStatus("3. Click SCAN EVERYTHING", Color3.fromRGB(255, 255, 200))
    updateStatus("4. Click ADVANCED UNLOCK", Color3.fromRGB(255, 255, 200))
    updateStatus("5. Click VISUAL UNLOCK for UI changes", Color3.fromRGB(255, 255, 200))
    updateStatus(string.rep("=", 50), Color3.fromRGB(100, 100, 100))
    
    return ScreenGui
end

-- ===== MAIN EXECUTION =====
print("\n🎯 INITIALIZING ULTIMATE UNLOCKER...")
task.wait(2)

-- Create UI
CreateAdvancedUI()

-- Auto-scan after 5 seconds
task.wait(5)
print("\n⏰ Auto-scanning in 3 seconds...")
for i = 3, 1, -1 do
    print(i .. "...")
    task.wait(1)
end

print("🔍 Performing initial scan...")
local initialValues = AdvancedValueFinder()
local initialRemotes = FindAllRemotes()

if #initialValues.guids > 0 or #initialRemotes.all > 0 then
    print("✅ Initial scan successful!")
    print("💡 Open the UI and click ADVANCED UNLOCK")
else
    print("❌ Initial scan found nothing")
    print("💡 Open the car shop first, then scan from UI")
end

print("\n" .. string.rep("=", 70))
print("✅ ULTIMATE UNLOCKER READY")
print("📍 Look for the UI window in-game")
print("🎯 Use the buttons to scan and unlock")
print(string.rep("=", 70))
