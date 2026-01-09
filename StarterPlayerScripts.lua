-- FIXED: Items are tables, need to extract IDs
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Get remotes
local TradingRemotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local SessionSetConfirmation = TradingRemotes:WaitForChild("SessionSetConfirmation")
local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")
local OnSessionCountdownUpdated = TradingRemotes:WaitForChild("OnSessionCountdownUpdated")

-- Variables
local ItemToDupe = nil
local CountdownTime = 0

-- Function to extract item ID from table
local function extractItemId(itemTable)
    if type(itemTable) == "string" or type(itemTable) == "number" then
        return tostring(itemTable)
    elseif type(itemTable) == "table" then
        -- Try common property names
        local possibleIds = {
            itemTable.Id,
            itemTable.ID,
            itemTable.id,
            itemTable.ItemId,
            itemTable.itemId,
            itemTable.Name,
            itemTable.name,
            itemTable.AssetId,
            itemTable.assetId
        }
        
        for _, id in ipairs(possibleIds) do
            if id then
                return tostring(id)
            end
        end
        
        -- Try to find any string/number in the table
        for key, value in pairs(itemTable) do
            if type(value) == "string" or type(value) == "number" then
                if tostring(key):lower():find("id") or 
                   tostring(key):lower():find("name") or
                   tostring(value):lower():find("car") then
                    return tostring(value)
                end
            end
        end
        
        -- Last resort: return table address
        return tostring(itemTable):match("table: (%x+)") or "unknown"
    end
    
    return tostring(itemTable)
end

-- DEBUG: Print table contents
local function debugTable(t, indent)
    indent = indent or ""
    for key, value in pairs(t) do
        if type(value) == "table" then
            print(indent .. tostring(key) .. ": table")
            debugTable(value, indent .. "  ")
        else
            print(indent .. tostring(key) .. ": " .. tostring(value) .. " (" .. type(value) .. ")")
        end
    end
end

-- Track items
OnSessionItemsUpdated.OnClientEvent:Connect(function(data)
    print("\n🔍 ITEM UPDATE RECEIVED")
    
    if type(data) == "table" then
        print("Full data structure:")
        debugTable(data)
        
        -- The data structure seems to be:
        -- data.Player = player object
        -- data.Items = table of items
        -- data.Id = ???
        
        if data.Items and type(data.Items) == "table" then
            print("\n📦 Items in trade:")
            for i, itemTable in ipairs(data.Items) do
                local itemId = extractItemId(itemTable)
                print("  Item " .. i .. ": " .. itemId)
                
                -- Check if this is our player's items
                if data.Player and data.Player == LocalPlayer then
                    ItemToDupe = itemId
                    print("✅ THIS IS YOUR CAR! ID: " .. itemId)
                end
            end
        end
        
        -- Alternative structure: might be data[player] = items
        for key, value in pairs(data) do
            if type(key) == "number" or type(key) == "string" then
                local playerId = tonumber(key)
                if playerId == LocalPlayer.UserId and type(value) == "table" then
                    print("\n🎯 Found items for you (method 2):")
                    for i, itemTable in ipairs(value) do
                        local itemId = extractItemId(itemTable)
                        ItemToDupe = itemId
                        print("  Your car " .. i .. ": " .. itemId)
                    end
                end
            end
        end
        
        if not ItemToDupe then
            print("❌ Could not identify your car in the data")
            print("Trying to auto-select first car...")
            
            -- Try to get first item from any structure
            if data.Items and #data.Items > 0 then
                ItemToDupe = extractItemId(data.Items[1])
                print("⚠️ Auto-selected: " .. ItemToDupe)
            end
        end
    end
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
    print("\n🚀 Starting dupe...")
    print("Using item ID:", ItemToDupe)
    
    if not ItemToDupe then
        print("❌ No item selected!")
        print("Please add a car to trade first")
        return
    end
    
    print("Step 1: Accepting trade...")
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    print("Waiting for countdown...")
    
    -- Wait for countdown
    local waited = 0
    while CountdownTime == 0 and waited < 50 do
        wait(0.1)
        waited = waited + 1
    end
    
    if CountdownTime == 0 then
        print("❌ Countdown didn't start")
        print("Other player needs to accept!")
        return
    end
    
    print("Countdown: " .. CountdownTime .. "s")
    
    -- Wait for last 0.3 seconds
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
    print("Check your inventory!")
end

-- SIMPLE UI
local gui = Instance.new("ScreenGui")
gui.Name = "CarDupe"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 100)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(0, 0.7, 1)
frame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Text = "≡ CAR DUPE (Drag)"
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

-- Status
local status = Instance.new("TextLabel")
status.Text = "Add car to trade"
status.Size = UDim2.new(1, 0, 0, 25)
status.Position = UDim2.new(0, 0, 0.2, 0)
status.TextColor3 = Color3.new(1, 1, 0)
status.TextSize = 12
status.Parent = frame

-- Item ID display
local itemDisplay = Instance.new("TextLabel")
itemDisplay.Text = "ID: none"
itemDisplay.Size = UDim2.new(1, 0, 0, 15)
itemDisplay.Position = UDim2.new(0, 0, 0.45, 0)
itemDisplay.TextColor3 = Color3.new(1, 1, 1)
itemDisplay.TextSize = 10
itemDisplay.Parent = frame

-- Dupe button
local btn = Instance.new("TextButton")
btn.Text = "START DUPE"
btn.Size = UDim2.new(0.9, 0, 0.3, 0)
btn.Position = UDim2.new(0.05, 0, 0.65, 0)
btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Parent = frame

btn.MouseButton1Click:Connect(startDupe)

-- Close button
local close = Instance.new("TextButton")
close.Text = "X"
close.Size = UDim2.new(0, 20, 0, 20)
close.Position = UDim2.new(1, -20, 0, 0)
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.TextColor3 = Color3.new(1, 1, 1)
close.Parent = frame

close.MouseButton1Click:Connect(function()
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

-- Update UI
game:GetService("RunService").Heartbeat:Connect(function()
    if ItemToDupe then
        status.Text = "✅ READY TO DUPE"
        status.TextColor3 = Color3.new(0, 1, 0)
        itemDisplay.Text = "ID: " .. tostring(ItemToDupe):sub(1, 10) .. "..."
    else
        status.Text = "Add car to trade"
        status.TextColor3 = Color3.new(1, 1, 0)
        itemDisplay.Text = "ID: none"
    end
    
    if CountdownTime > 0 then
        status.Text = status.Text .. " " .. CountdownTime .. "s"
    end
end)

print("\n" .. string.rep("=", 50))
print("CAR TABLE DUPE SCRIPT LOADED")
print(string.rep("=", 50))
print("ITEMS ARE TABLES, NOT STRINGS!")
print("Now extracting IDs from tables...")
print("\nINSTRUCTIONS:")
print("1. Start trade")
print("2. Add car(s) to trade")
print("3. Look for 'THIS IS YOUR CAR!' message")
print("4. Click START DUPE")
print(string.rep("=", 50))

-- Make ItemToDupe global for manual setting
_G.ItemToDupe = ItemToDupe
_G.setCarId = function(id)
    ItemToDupe = id
    print("✅ Manually set car ID to:", id)
end
