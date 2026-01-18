-- Fixed Trade Duplicator with Better UI Detection
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

wait(2)

print("=== FIXED TRADE DUPLICATOR ===")

-- First, let's verify the exact UI path
local function DebugUITree()
    print("\n🔍 DEBUGGING UI TREE...")
    
    if not Player.PlayerGui then
        print("❌ No PlayerGui")
        return nil
    end
    
    print("✅ PlayerGui exists")
    
    -- Check Menu
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then
        print("❌ No Menu in PlayerGui")
        -- List what's actually in PlayerGui
        print("Contents of PlayerGui:")
        for _, child in pairs(Player.PlayerGui:GetChildren()) do
            print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
        return nil
    end
    
    print("✅ Found Menu")
    
    -- Check Trading
    local trading = menu:FindFirstChild("Trading")
    if not trading then
        print("❌ No Trading in Menu")
        print("Contents of Menu:")
        for _, child in pairs(menu:GetChildren()) do
            print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
        return nil
    end
    
    print("✅ Found Trading")
    
    -- Check PeerToPeer
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then
        print("❌ No PeerToPeer in Trading")
        return nil
    end
    
    print("✅ Found PeerToPeer")
    
    -- Check Main
    local main = peerToPeer:FindFirstChild("Main")
    if not main then
        print("❌ No Main in PeerToPeer")
        return nil
    end
    
    print("✅ Found Main")
    
    -- Check LocalPlayer
    local localPlayer = main:FindFirstChild("LocalPlayer")
    if not localPlayer then
        print("❌ No LocalPlayer in Main")
        print("Contents of Main:")
        for _, child in pairs(main:GetChildren()) do
            print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
        return nil
    end
    
    print("✅ Found LocalPlayer")
    
    -- Check Content
    local content = localPlayer:FindFirstChild("Content")
    if not content then
        print("❌ No Content in LocalPlayer")
        return nil
    end
    
    print("✅ Found Content")
    
    -- Check ScrollingFrame
    local scrollingFrame = content:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then
        print("❌ No ScrollingFrame in Content")
        print("Contents of Content:")
        for _, child in pairs(content:GetChildren()) do
            print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
        return nil
    end
    
    print("✅ Found ScrollingFrame")
    print("🎯 Full path verified!")
    print("Path: PlayerGui.Menu.Trading.PeerToPeer.Main.LocalPlayer.Content.ScrollingFrame")
    
    return scrollingFrame
end

-- Get trade container with better error handling
local function GetTradeContainer()
    local container = DebugUITree()
    
    if container then
        print("✅ Trade container found!")
        print("Container visible: " .. tostring(container.Visible))
        print("Container children: " .. #container:GetChildren())
        return container
    else
        print("⚠️ Trade container not found. Are you in a trade?")
        return nil
    end
end

-- Get remotes
local TradingServiceRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local SessionAddItem = TradingServiceRemotes:WaitForChild("SessionAddItem")
local SessionSetConfirmation = TradingServiceRemotes:WaitForChild("SessionSetConfirmation")
local OnSessionItemsUpdated = TradingServiceRemotes:WaitForChild("OnSessionItemsUpdated")

print("✅ Loaded TradingServiceRemotes")

-- Get car ID directly from any button in trade
local function GetCarIdFromTrade()
    print("\n🔍 GETTING CAR ID FROM TRADE...")
    
    local container = GetTradeContainer()
    if not container then
        print("❌ Cannot get container. Start a trade first!")
        return nil
    end
    
    -- List ALL items in container
    print("Items in trade window:")
    local items = {}
    
    for _, item in pairs(container:GetChildren()) do
        local itemName = item.Name
        local itemClass = item.ClassName
        
        print("  - " .. itemName .. " (" .. itemClass .. ")")
        
        if item:IsA("TextButton") or item:IsA("ImageButton") or item:IsA("Frame") then
            table.insert(items, item)
            
            -- If it's a button, show text
            if item:IsA("TextButton") then
                print("    Text: \"" .. item.Text .. "\"")
            end
            
            -- Show children
            for _, child in pairs(item:GetChildren()) do
                print("    └─ " .. child.Name .. " (" .. child.ClassName .. ")")
                if child:IsA("TextLabel") then
                    print("      Text: \"" .. child.Text .. "\"")
                elseif child:IsA("StringValue") or child:IsA("IntValue") then
                    print("      Value: " .. tostring(child.Value))
                end
            end
        end
    end
    
    if #items == 0 then
        print("❌ No items found in trade window")
        return nil
    end
    
    -- Try to find a car
    for _, item in pairs(items) do
        local itemName = item.Name:lower()
        local itemText = item:IsA("TextButton") and item.Text:lower() or ""
        
        if itemName:find("car") or itemText:find("car") or itemName:find("vehicle") then
            print("🚗 Found potential car item: " .. item.Name)
            
            -- Return the first likely car ID
            return item.Name  -- Use button name as ID
        end
    end
    
    -- If no car found, use first item
    print("⚠️ No car identified, using first item: " .. items[1].Name)
    return items[1].Name
end

-- Get session ID (simplified)
local function GetSessionId()
    print("\n🆔 GETTING SESSION ID...")
    
    -- Try a few common session ID formats
    local possibleIds = {
        "trade_session",
        "session_1",
        "current_session",
        Player.UserId .. "_trade",
        os.time()  -- Current timestamp
    }
    
    -- Just return the first one for testing
    local sessionId = possibleIds[1]
    print("Using session ID: " .. sessionId)
    return sessionId
end

-- Main duplication function
local function DuplicateItem()
    print("\n🔄 ATTEMPTING DUPLICATION...")
    
    local sessionId = GetSessionId()
    local itemId = GetCarIdFromTrade()
    
    if not itemId then
        print("❌ Cannot get item ID")
        return false
    end
    
    print("Session ID: " .. sessionId)
    print("Item ID: " .. itemId)
    
    local successCount = 0
    
    -- Try different parameter formats
    local attempts = {
        {name = "Just item ID", func = function() return SessionAddItem:InvokeServer(sessionId, itemId) end},
        {name = "Item ID + quantity", func = function() return SessionAddItem:InvokeServer(sessionId, itemId, 1) end},
        {name = "Item ID + quantity + extra", func = function() return SessionAddItem:InvokeServer(sessionId, itemId, 1, "duplicate") end},
        {name = "Table format", func = function() 
            return SessionAddItem:InvokeServer(sessionId, {
                id = itemId,
                name = itemId .. "_duplicate",
                type = "item"
            }) 
        end}
    }
    
    for i, attempt in ipairs(attempts) do
        print("\nAttempt " .. i .. ": " .. attempt.name)
        
        local success, result = pcall(attempt.func)
        
        if success then
            print("✅ Success!")
            if result then
                print("   Server returned: " .. tostring(result))
            end
            successCount = successCount + 1
        else
            print("❌ Failed")
        end
        
        wait(0.5)  -- Wait between attempts
    end
    
    print("\n📊 Results: " .. successCount .. "/" .. #attempts .. " successful")
    
    -- Force update if any succeeded
    if successCount > 0 then
        print("\n🔄 Forcing session update...")
        pcall(function()
            OnSessionItemsUpdated:FireServer(sessionId, {updated = true})
        end)
        
        wait(1)
        
        -- Check if items changed
        local container = GetTradeContainer()
        if container then
            local itemCount = 0
            for _ in pairs(container:GetChildren()) do
                itemCount = itemCount + 1
            end
            print("Current item count: " .. itemCount)
        end
    end
    
    return successCount > 0
end

-- Create simple UI
local function CreateSimpleUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeDuplicatorFixed"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "TRADE DUPLICATOR FIXED"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(255, 150, 100)
    
    local output = Instance.new("TextLabel")
    output.Text = "Ready\nStart a trade first!"
    output.Size = UDim2.new(1, -20, 0, 110)
    output.Position = UDim2.new(0, 10, 0, 50)
    output.BackgroundTransparency = 1
    output.TextColor3 = Color3.fromRGB(200, 220, 255)
    output.TextWrapped = true
    output.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Buttons
    local debugBtn = Instance.new("TextButton")
    debugBtn.Text = "🔍 DEBUG UI"
    debugBtn.Size = UDim2.new(0.48, 0, 0, 30)
    debugBtn.Position = UDim2.new(0.01, 0, 0, 170)
    debugBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
    
    local dupBtn = Instance.new("TextButton")
    dupBtn.Text = "🔄 DUPLICATE"
    dupBtn.Size = UDim2.new(0.48, 0, 0, 30)
    dupBtn.Position = UDim2.new(0.51, 0, 0, 170)
    dupBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    
    -- Update output
    local function updateOutput(text)
        output.Text = text
        print(text)
    end
    
    debugBtn.MouseButton1Click:Connect(function()
        updateOutput("Debugging UI...")
        spawn(function()
            DebugUITree()
            updateOutput("Debug complete!\nCheck output window.")
        end)
    end)
    
    dupBtn.MouseButton1Click:Connect(function()
        updateOutput("Attempting duplication...")
        spawn(function()
            local success = DuplicateItem()
            if success then
                updateOutput("✅ Duplication attempted!\nCheck other player.")
            else
                updateOutput("❌ Duplication failed\nStart a trade first!")
            end
        end)
    end)
    
    -- Parent everything
    title.Parent = frame
    output.Parent = frame
    debugBtn.Parent = frame
    dupBtn.Parent = frame
    frame.Parent = gui
    
    return updateOutput
end

-- Initialize
local updateOutput = CreateSimpleUI()

-- Auto-debug on start
wait(3)
print("\n=== TRADE DUPLICATOR FIXED ===")
print("This version fixes the container error")

-- Run initial debug
spawn(function()
    wait(2)
    print("\n🔍 Running initial UI check...")
    DebugUITree()
    updateOutput("UI check complete.\nStart a trade to begin.")
end)

-- Keybinds
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.D then
        print("\n🎮 D KEY - DEBUGGING UI")
        DebugUITree()
        updateOutput("Debugging UI...")
    elseif input.KeyCode == Enum.KeyCode.F then
        print("\n🎮 F KEY - DUPLICATING")
        DuplicateItem()
        updateOutput("Duplicating...")
    end
end)

print("\n🔑 CONTROLS:")
print("D = Debug UI")
print("F = Duplicate item")
print("\n📋 INSTRUCTIONS:")
print("1. Start a trade with another player")
print("2. Add an item to the trade")
print("3. Click DEBUG UI to verify path")
print("4. Click DUPLICATE to attempt duplication")
print("5. Check if other player sees the duplicate")
