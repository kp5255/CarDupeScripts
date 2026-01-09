-- PERFECT COUNTDOWN DUPE SCRIPT
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
local TradeActive = false

-- Track item
OnSessionItemsUpdated.OnClientEvent:Connect(function(data)
    if data and data[LocalPlayer.UserId] then
        if #data[LocalPlayer.UserId] > 0 then
            ItemToDupe = data[LocalPlayer.UserId][1]
            print("✅ Car detected!")
        end
    end
end)

-- Track countdown (FIXED: Use Time with capital T)
OnSessionCountdownUpdated.OnClientEvent:Connect(function(timeData)
    if type(timeData) == "table" and timeData.Time then
        CountdownTime = timeData.Time
        TradeActive = CountdownTime > 0
        
        if TradeActive then
            print("⏰ " .. CountdownTime .. "s")
        end
    end
end)

-- Simple dupe function
local function startDupe()
    if not ItemToDupe then
        print("❌ Add car to trade first!")
        return
    end
    
    print("🚀 Starting dupe...")
    
    -- Step 1: Accept trade
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    print("Waiting for countdown...")
    
    -- Wait for countdown to start
    local waitTime = 0
    while CountdownTime == 0 and waitTime < 5 do
        wait(1)
        waitTime = waitTime + 1
    end
    
    if CountdownTime == 0 then
        print("❌ Countdown didn't start!")
        print("Make sure other player accepts!")
        return
    end
    
    -- Step 2: Wait for last 0.3 seconds
    print("Countdown: " .. CountdownTime .. "s")
    
    while CountdownTime > 0.3 do
        wait(0.1)
    end
    
    -- Step 3: Cancel at last moment
    print("🚨 CANCELLING AT " .. CountdownTime .. "s!")
    
    -- Send cancel multiple times
    for i = 1, 3 do
        pcall(function()
            SessionSetConfirmation:InvokeServer(false)
        end)
        wait(0.05)
    end
    
    print("✅ Dupe complete!")
    print("Check if car duplicated!")
end

-- ULTRA SIMPLE UI
local gui = Instance.new("ScreenGui")
gui.Name = "SimpleDupe"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 140, 0, 70)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(0, 0.7, 1)
frame.Parent = gui

-- Drag bar
local drag = Instance.new("TextLabel")
drag.Text = "≡ Drag"
drag.Size = UDim2.new(1, 0, 0, 15)
drag.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
drag.TextColor3 = Color3.new(1, 1, 1)
drag.TextSize = 12
drag.Parent = frame

-- Status
local status = Instance.new("TextLabel")
status.Text = "Add car"
status.Size = UDim2.new(1, 0, 0, 15)
status.Position = UDim2.new(0, 0, 0.25, 0)
status.TextColor3 = Color3.new(1, 1, 0)
status.TextSize = 11
status.Parent = frame

-- Button
local btn = Instance.new("TextButton")
btn.Text = "DUPE"
btn.Size = UDim2.new(0.7, 0, 0.4, 0)
btn.Position = UDim2.new(0.15, 0, 0.5, 0)
btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Parent = frame

btn.MouseButton1Click:Connect(startDupe)

-- Draggable
local dragging = false
local dragStart, frameStart

drag.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        frameStart = frame.Position
    end
end)

drag.InputEnded:Connect(function()
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

print("\n" .. string.rep("=", 40))
print("PERFECT DUPE SCRIPT LOADED!")
print(string.rep("=", 40))
print("COUNTDOWN DATA: Uses Time = X (number)")
print("INSTRUCTIONS:")
print("1. Start trade")
print("2. Add car")
print("3. Wait for ✅ READY")
print("4. Click DUPE button")
print("5. Other player MUST accept")
print("6. Script cancels at 0.3s")
print("7. Check inventory!")
print(string.rep("=", 40))
