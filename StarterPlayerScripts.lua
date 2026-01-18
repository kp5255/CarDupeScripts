-- Item ID Finder & Trade Duplicator
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== ITEM ID FINDER ===")

-- Get remotes
local TradingServiceRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local SessionAddItem = TradingServiceRemotes:WaitForChild("SessionAddItem")

-- Get trade container
local function GetTradeContainer()
    if not Player.PlayerGui then return nil end
    return Player.PlayerGui:WaitForChild("Menu"):WaitForChild("Trading"):WaitForChild("PeerToPeer"):WaitForChild("Main"):WaitForChild("LocalPlayer"):WaitForChild("Content"):WaitForChild("ScrollingFrame")
end

-- Find ALL data in car button
local function GetCarItemData()
    print("\n🔍 EXTRACTING CAR ITEM DATA...")
    
    local container = GetTradeContainer()
    if not container then
        print("❌ No trade container")
        return nil
    end
    
    -- Find car button
    local carButton = nil
    for _, item in pairs(container:GetChildren()) do
        if item:IsA("ImageButton") and item.Name:sub(1, 4) == "Car-" then
            carButton = item
            break
        end
    end
    
    if not carButton then
        print("❌ No car button found")
        return nil
    end
    
    print("Found car button: " .. carButton.Name)
    
    -- Extract ALL data from the button and its children
    local itemData = {
        buttonName = carButton.Name,
        children = {}
    }
    
    -- Get all children values
    for _, child in pairs(carButton:GetDescendants()) do
        if child:IsA("StringValue") then
            itemData.children[child.Name] = child.Value
            print("StringValue: " .. child.Name .. " = \"" .. child.Value .. "\"")
        elseif child:IsA("IntValue") then
            itemData.children[child.Name] = child.Value
            print("IntValue: " .. child.Name .. " = " .. child.Value)
        elseif child:IsA("NumberValue") then
            itemData.children[child.Name] = child.Value
            print("NumberValue: " .. child.Name .. " = " .. child.Value)
        elseif child:IsA("BoolValue") then
            itemData.children[child.Name] = child.Value
            print("BoolValue: " .. child.Name .. " = " .. tostring(child.Value))
        elseif child:IsA("ObjectValue") then
            if child.Value then
                itemData.children[child.Name] = child.Value:GetFullName()
                print("ObjectValue: " .. child.Name .. " = " .. child.Value:GetFullName())
            end
        end
    end
    
    -- Also check for TextLabels with important info
    for _, child in pairs(carButton:GetChildren()) do
        if child:IsA("TextLabel") then
            print("TextLabel: " .. child.Name .. " = \"" .. child.Text .. "\"")
        end
    end
    
    return itemData
end

-- Try to find what item ID the server expects
local function FindCorrectItemId()
    print("\n🔑 FINDING CORRECT ITEM ID...")
    
    local itemData = GetCarItemData()
    if not itemData then return nil end
    
    -- Common item ID patterns to check for
    local possibleIds = {}
    
    -- Check children for likely IDs
    for name, value in pairs(itemData.children) do
        local nameLower = name:lower()
        
        -- Look for ID-related names
        if nameLower:find("id") or 
           nameLower:find("item") or 
           nameLower:find("asset") or
           nameLower:find("product") then
            
            table.insert(possibleIds, {
                source = name,
                value = value,
                type = type(value)
            })
        end
    end
    
    -- Also check the button name for numeric ID
    local numericId = itemData.buttonName:match("%d+")
    if numericId then
        table.insert(possibleIds, {
            source = "button name",
            value = tonumber(numericId),
            type = "number"
        })
    end
    
    print("\n📋 Possible item IDs found:")
    for i, idInfo in ipairs(possibleIds) do
        print(i .. ". " .. idInfo.source .. " = " .. tostring(idInfo.value) .. " (" .. idInfo.type .. ")")
    end
    
    return possibleIds
end

-- Test different item IDs
local function TestItemIds()
    print("\n🧪 TESTING ITEM IDs...")
    
    local possibleIds = FindCorrectItemId()
    if not possibleIds or #possibleIds == 0 then
        print("❌ No possible IDs found")
        return false
    end
    
    local successCount = 0
    
    for i, idInfo in ipairs(possibleIds) do
        print("\n--- Test " .. i .. " ---")
        print("Using ID: " .. tostring(idInfo.value) .. " (from " .. idInfo.source .. ")")
        
        -- Try different formats with this ID
        local testFormats = {
            {name = "Number ID", value = tonumber(idInfo.value) or idInfo.value},
            {name = "String ID", value = tostring(idInfo.value)},
            {name = "ID with prefix", value = "Car_" .. tostring(idInfo.value)},
            {name = "ID as table", value = {id = idInfo.value}},
            {name = "ID with type", value = {id = idInfo.value, type = "car"}},
        }
        
        for _, format in ipairs(testFormats) do
            print("  Format: " .. format.name)
            
            -- Try to add item
            local success, result = pcall(function()
                return SessionAddItem:InvokeServer("trade_session", format.value)
            end)
            
            if success then
                print("    ✅ SUCCESS!")
                if result then
                    print("    Result: " .. tostring(result))
                end
                successCount = successCount + 1
                
                -- Try a few more times
                for j = 1, 3 do
                    wait(0.2)
                    pcall(function()
                        SessionAddItem:InvokeServer("trade_session", format.value)
                        print("    Repeated " .. j)
                    end)
                end
                
                break  -- Stop if this format works
            else
                print("    ❌ Failed: " .. tostring(result))
            end
            
            wait(0.3)
        end
    end
    
    print("\n📊 Results: " .. successCount .. " successful ID tests")
    return successCount > 0
end

-- Alternative: Look for item data in other places
local function SearchForItemDatabase()
    print("\n🗄️ SEARCHING FOR ITEM DATABASE...")
    
    -- Look in ReplicatedStorage for item data
    local foundItems = {}
    
    local function SearchFolder(folder, path)
        for _, item in pairs(folder:GetChildren()) do
            if item:IsA("Folder") and (item.Name:lower():find("car") or item.Name:lower():find("item") or item.Name:lower():find("vehicle")) then
                print("Found item folder: " .. path .. item.Name)
                
                -- Check for item data in folder
                for _, data in pairs(item:GetChildren()) do
                    if data:IsA("StringValue") or data:IsA("IntValue") then
                        print("  " .. data.Name .. " = " .. tostring(data.Value))
                        table.insert(foundItems, {
                            name = item.Name,
                            dataName = data.Name,
                            value = data.Value,
                            path = path .. item.Name
                        })
                    end
                end
            end
            
            -- Recursive search
            if item:IsA("Folder") then
                SearchFolder(item, path .. item.Name .. "/")
            end
        end
    end
    
    -- Search common locations
    local locations = {
        {name = "ReplicatedStorage", folder = ReplicatedStorage},
        {name = "ServerStorage", folder = game:GetService("ServerStorage")},
        {name = "ServerScriptService", folder = game:GetService("ServerScriptService")},
    }
    
    for _, location in pairs(locations) do
        print("\nSearching " .. location.name .. "...")
        pcall(function()
            SearchFolder(location.folder, location.name .. "/")
        end)
    end
    
    print("\n📋 Found " .. #foundItems .. " potential item data entries")
    return foundItems
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ItemIdFinder"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "ITEM ID FINDER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    local status = Instance.new("TextLabel")
    status.Text = "Find the REAL item ID\nnot just display name"
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 230, 255)
    status.TextWrapped = true
    
    -- Buttons
    local buttons = {
        {text = "🔍 GET CAR DATA", func = GetCarItemData, pos = UDim2.new(0.025, 0, 0, 140)},
        {text = "🔑 FIND ITEM ID", func = FindCorrectItemId, pos = UDim2.new(0.525, 0, 0, 140)},
        {text = "🧪 TEST IDs", func = TestItemIds, pos = UDim2.new(0.025, 0, 0, 175)},
        {text = "🗄️ SEARCH DB", func = SearchForItemDatabase, pos = UDim2.new(0.525, 0, 0, 175)},
        {text = "🚀 QUICK TEST", func = function()
            print("\n⚡ QUICK TEST...")
            local itemData = GetCarItemData()
            if itemData then
                -- Try the most likely ID formats
                local tests = {
                    {name = "First child value", value = next(itemData.children)},
                    {name = "Numeric from name", value = itemData.buttonName:match("%d+")},
                    {name = "AssetId if exists", value = itemData.children["AssetId"]}
                }
                
                for _, test in ipairs(tests) do
                    if test.value then
                        print("Testing: " .. test.name .. " = " .. test.value)
                        pcall(function()
                            SessionAddItem:InvokeServer("trade_session", test.value)
                            print("✅ Sent!")
                        end)
                        wait(0.3)
                    end
                end
            end
        end, pos = UDim2.new(0.025, 0, 0, 210)}
    }
    
    for _, btnInfo in pairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.text
        btn.Size = UDim2.new(0.45, 0, 0, 30)
        btn.Position = btnInfo.pos
        btn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        btn.MouseButton1Click:Connect(function()
            status.Text = "Running: " .. btnInfo.text
            spawn(function()
                btnInfo.func()
                wait(0.5)
                status.Text = "Completed"
            end)
        end)
        
        btn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    frame.Parent = gui
    
    return status
end

-- Initialize
CreateUI()

-- Instructions
wait(2)
print("\n=== ITEM ID FINDER ===")
print("The error 'Invalid item type' means we're sending the wrong ID")
print("\n📋 WHAT TO DO:")
print("1. Click 'GET CAR DATA' - shows all data in car button")
print("2. Look for ID values (StringValue, IntValue)")
print("3. Click 'TEST IDs' - tries different ID formats")
print("4. Share the OUTPUT with me!")

-- Auto-run first scan
spawn(function()
    wait(3)
    print("\n🔍 Auto-scanning car data...")
    GetCarItemData()
end)
