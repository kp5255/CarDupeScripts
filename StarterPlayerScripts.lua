-- FIXED: Item detection problem
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Get remotes
local TradingRemotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local SessionSetConfirmation = TradingRemotes:WaitForChild("SessionSetConfirmation")
local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")
local OnSessionCountdownUpdated = TradingRemotes:WaitForChild("OnSessionCountdownUpdated")

-- DEBUG: Print to confirm we found remotes
print("✅ Remotes found:")
print("- SessionSetConfirmation:", SessionSetConfirmation ~= nil)
print("- OnSessionItemsUpdated:", OnSessionItemsUpdated ~= nil)
print("- OnSessionCountdownUpdated:", OnSessionCountdownUpdated ~= nil)

-- Variables
local ItemToDupe = nil
local CountdownTime = 0

-- DEBUG function to print item data
local function debugItems(data)
    print("\n🔍 DEBUG ITEM DATA:")
    print("Type:", type(data))
    
    if type(data) == "table" then
        print("Table keys:")
        for key, value in pairs(data) do
            print("  " .. tostring(key) .. " = " .. tostring(type(value)))
            
            if type(value) == "table" then
                print("    Items for player " .. key .. ":")
                for i, item in ipairs(value) do
                    print("      Item " .. i .. ": " .. tostring(item))
                end
            end
        end
    end
end

-- Track item (FIXED: Better detection)
OnSessionItemsUpdated.OnClientEvent:Connect(function(data)
    debugItems(data) -- Show what data looks like
    
    if type(data) == "table" then
        -- Try different ways to find our items
        local myUserId = tostring(LocalPlayer.UserId)
        
        -- Method 1: Direct user ID key
        if data[LocalPlayer.UserId] then
            local items = data[LocalPlayer.UserId]
            if #items > 0 then
                ItemToDupe = items[1]
                print("✅ Method 1: Car detected! ID:", ItemToDupe)
                return
            end
        end
        
        -- Method 2: User ID as string
        if data[myUserId] then
            local items = data[myUserId]
            if #items > 0 then
                ItemToDupe = items[1]
                print("✅ Method 2: Car detected! ID:", ItemToDupe)
                return
            end
        end
        
        -- Method 3: Find any user ID that matches
        for playerId, items in pairs(data) do
            if type(items) == "table" then
                local playerIdNum = tonumber(playerId)
                if playerIdNum == LocalPlayer.UserId then
                    if #items > 0 then
                        ItemToDupe = items[1]
                        print("✅ Method 3: Car detected! ID:", ItemToDupe)
                        return
                    end
                end
            end
        end
    end
    
    print("❌ No car detected in trade")
    ItemToDupe = nil
end)

-- Track countdown
OnSessionCountdownUpdated.OnClientEvent:Connect(function(timeData)
    if type(timeData) == "table" and timeData.Time then
        CountdownTime = timeData.Time
        
        if CountdownTime > 0 then
            print("⏰ " .. CountdownTime .. "s")
        end
    end
end)

-- Simple dupe function
local function startDupe()
    print("\n🚀 Attempting dupe...")
    print("ItemToDupe:", ItemToDupe)
    print("Type:", type(ItemToDupe))
    
    if not ItemToDupe then
        print("❌ ERROR: ItemToDupe is nil!")
        print("Please make sure:")
        print("1. Trade is started")
        print("2. Car is added to trade")
        print("3. Wait for 'Car detected!' message")
        return
    end
    
    if type(ItemToDupe) ~= "string" and type(ItemToDupe) ~= "number" then
        print("❌ ERROR: ItemToDupe is not string/number!")
        print("It's a:", type(ItemToDupe))
        return
    end
    
    print("Step 1: Accepting trade...")
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    print("Waiting for countdown...")
    
    -- Wait for countdown
    local waitTime = 0
    while CountdownTime == 0 and waitTime < 30 do
        wait(0.1)
        waitTime = waitTime + 1
    end
    
    if CountdownTime == 0 then
        print("❌ Countdown never started")
        print("Other player needs to accept!")
        return
    end
    
    print("Countdown active: " .. CountdownTime .. "s")
    
    -- Wait for last moment
    while CountdownTime > 0.3 do
        wait(0.1)
    end
    
    print("🚨 Cancelling at " .. CountdownTime .. "s!")
    
    -- Send cancel
    for i = 1, 3 do
        pcall(function()
            SessionSetConfirmation:InvokeServer(false)
        end)
        wait(0.05)
    end
    
    print("✅ Dupe attempt complete!")
end

-- MANUAL MODE: Force set item
local function manualSetItem()
    print("\n🔧 MANUAL MODE")
    print("Current ItemToDupe:", ItemToDupe)
    print("Enter item ID from debug output:")
    
    -- This would normally be a textbox, but for now:
    print("Check debug output above for item ID")
    print("Then type in console: _G.ItemToDupe = 'ITEM_ID_HERE'")
end

-- SIMPLE UI
local gui = Instance.new("ScreenGui")
gui.Name = "DupeGUI"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 90)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(0, 0.7, 1)
frame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Text = "≡ DUPE (Drag)"
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

-- Status
local status = Instance.new("TextLabel")
status.Name = "Status"
status.Text = "Add car to trade"
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0.25, 0)
status.TextColor3 = Color3.new(1, 1, 0)
status.TextSize = 12
status.Parent = frame

-- Dupe button
local btnDupe = Instance.new("TextButton")
btnDupe.Text = "START DUPE"
btnDupe.Size = UDim2.new(0.9, 0, 0.3, 0)
btnDupe.Position = UDim2.new(0.05, 0, 0.5, 0)
btnDupe.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnDupe.TextColor3 = Color3.new(1, 1, 1)
btnDupe.Parent = frame

btnDupe.MouseButton1Click:Connect(startDupe)

-- Manual button
local btnManual = Instance.new("TextButton")
btnManual.Text = "DEBUG"
btnManual.Size = UDim2.new(0.4, 0, 0.2, 0)
btnManual.Position = UDim2.new(0.55, 0, 0.8, 0)
btnManual.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btnManual.TextColor3 = Color3.new(1, 1, 1)
btnManual.TextSize = 10
btnManual.Parent = frame

btnManual.MouseButton1Click:Connect(manualSetItem)

-- Close button
local btnClose = Instance.new("TextButton")
btnClose.Text = "X"
btnClose.Size = UDim2.new(0.2, 0, 0.2, 0)
btnClose.Position = UDim2.new(0.8, 0, 0, 0)
btnClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnClose.TextColor3 = Color3.new(1, 1, 1)
btnClose.Parent = frame

btnClose.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Draggable
local dragging = false
local dragStart, frameStart

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        frameStart = frame.Position
    end
end)

title.InputEnded:Connect(function(input)
    dragging = false
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            frameStart.X.Scale,
            frameStart.X.Offset + delta.X,
            frameStart.Y.Scale,
            frameStart.Y.Offset + delta.Y
        )
    end
end)

-- Update status
game:GetService("RunService").Heartbeat:Connect(function()
    if ItemToDupe then
        status.Text = "✅ READY"
        status.TextColor3 = Color3.new(0, 1, 0)
    else
        status.Text = "Add car"
        status.TextColor3 = Color3.new(1, 1, 0)
    end
    
    if CountdownTime > 0 then
        status.Text = status.Text .. " " .. CountdownTime .. "s"
    end
end)

print("\n" .. string.rep("=", 50))
print("DEBUG MODE ENABLED")
print(string.rep("=", 50))
print("INSTRUCTIONS:")
print("1. Start trade with someone")
print("2. Add car to trade")
print("3. Look at DEBUG output above")
print("4. Wait for 'Car detected!' message")
print("5. Click START DUPE")
print(string.rep("=", 50))
print("\nIf 'Car detected!' doesn't appear:")
print("1. Click DEBUG button")
print("2. Check console for item ID")
print("3. Manually set with: _G.ItemToDupe = 'ID'")
