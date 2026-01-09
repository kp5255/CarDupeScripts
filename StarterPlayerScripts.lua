-- FINAL WORKING TRADE DUPE SCRIPT
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

-- Track items (FIXED: Using exact structure from debug)
OnSessionItemsUpdated.OnClientEvent:Connect(function(data)
    print("\n📦 ITEM UPDATE")
    
    if type(data) == "table" then
        -- Check if this is our player's data
        if data.Player and data.Player == LocalPlayer then
            if data.Items and #data.Items > 0 then
                -- Get first car's ID
                local firstCar = data.Items[1]
                if firstCar and firstCar.Id then
                    ItemToDupe = firstCar.Id
                    print("✅ CAR DETECTED!")
                    print("Name: " .. (firstCar.Name or "Unknown"))
                    print("Type: " .. (firstCar.Type or "Unknown"))
                    print("ID: " .. ItemToDupe)
                end
            end
        else
            print("⚠️ Data not for current player")
            -- Try to auto-detect anyway
            if data.Items and #data.Items > 0 then
                local firstCar = data.Items[1]
                if firstCar and firstCar.Id then
                    ItemToDupe = firstCar.Id
                    print("⚠️ Auto-selected car:")
                    print("ID: " .. ItemToDupe)
                end
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

-- Dupe function
local function startDupe()
    if not ItemToDupe then
        print("❌ No car detected!")
        print("Add car to trade first")
        return
    end
    
    print("\n🚀 STARTING DUPE...")
    print("Car ID: " .. ItemToDupe)
    
    -- Accept trade
    print("Step 1: Accepting trade...")
    local success, error = pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    if not success then
        print("❌ Failed to accept:", error)
        return
    end
    
    -- Wait for countdown
    print("Step 2: Waiting for countdown...")
    local waited = 0
    while CountdownTime == 0 and waited < 50 do
        wait(0.1)
        waited = waited + 1
    end
    
    if CountdownTime == 0 then
        print("❌ Countdown didn't start!")
        print("Make sure other player accepts!")
        return
    end
    
    print("Step 3: Countdown started: " .. CountdownTime .. "s")
    
    -- Wait for last 0.3 seconds
    while CountdownTime > 0.3 do
        wait(0.1)
    end
    
    -- Cancel at last moment
    print("Step 4: 🚨 CANCELLING AT " .. CountdownTime .. "s!")
    
    for i = 1, 3 do
        pcall(function()
            SessionSetConfirmation:InvokeServer(false)
        end)
        wait(0.05)
    end
    
    print("\n✅ DUPE COMPLETE!")
    print("Check if you still have the car!")
end

-- SIMPLE UI
local gui = Instance.new("ScreenGui")
gui.Name = "DupeGUI"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 80)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(0, 0.7, 1)
frame.Parent = gui

-- Drag title
local title = Instance.new("TextLabel")
title.Text = "≡ DUPE"
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

-- Status
local status = Instance.new("TextLabel")
status.Text = "Add car"
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0.25, 0)
status.TextColor3 = Color3.new(1, 1, 0)
status.TextSize = 12
status.Parent = frame

-- Button
local btn = Instance.new("TextButton")
btn.Text = "START"
btn.Size = UDim2.new(0.8, 0, 0.3, 0)
btn.Position = UDim2.new(0.1, 0, 0.6, 0)
btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Parent = frame

btn.MouseButton1Click:Connect(startDupe)

-- Close
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
print("🎯 FINAL DUPE SCRIPT LOADED!")
print(string.rep("=", 50))
print("CAR STRUCTURE FOUND:")
print("- Id: UUID string")
print("- Name: Car name")
print("- Type: 'Car'")
print(string.rep("=", 50))
print("INSTRUCTIONS:")
print("1. Start trade")
print("2. Add car to trade")
print("3. Wait for 'CAR DETECTED!'")
print("4. Click START")
print("5. Other player MUST accept")
print("6. Script cancels at 0.3s")
print("7. Check inventory!")
print(string.rep("=", 50))

-- Manual override if needed
_G.forceCarId = function(id)
    ItemToDupe = id
    print("✅ Manually set car ID to:", id)
end

-- Show current car
_G.showCar = function()
    print("Current car ID:", ItemToDupe)
end
