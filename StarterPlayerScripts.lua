-- FIXED: Countdown is a table error

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Find trading remotes
local TradingRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")

if not TradingRemotes then
    print("❌ No trading found")
    return
end

-- Get remotes
local SessionSetConfirmation = TradingRemotes:WaitForChild("SessionSetConfirmation")
local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")
local OnSessionCountdownUpdated = TradingRemotes:WaitForChild("OnSessionCountdownUpdated")

-- Variables
local ItemToDupe = nil
local Countdown = 0

-- Track item
if OnSessionItemsUpdated then
    OnSessionItemsUpdated.OnClientEvent:Connect(function(data)
        if data and type(data) == "table" then
            if data[LocalPlayer.UserId] then
                if #data[LocalPlayer.UserId] > 0 then
                    ItemToDupe = data[LocalPlayer.UserId][1]
                    print("✅ Item ready")
                end
            end
        end
    end)
end

-- Track countdown (FIXED: Handle table data)
if OnSessionCountdownUpdated then
    OnSessionCountdownUpdated.OnClientEvent:Connect(function(timeData)
        -- timeData might be a table, not a number
        if type(timeData) == "number" then
            -- It's a number directly
            Countdown = timeData
        elseif type(timeData) == "table" then
            -- It's a table, extract the time
            if timeData.timeLeft then
                Countdown = timeData.timeLeft
            elseif timeData.TimeLeft then
                Countdown = timeData.TimeLeft
            elseif timeData.seconds then
                Countdown = timeData.seconds
            elseif timeData.Seconds then
                Countdown = timeData.Seconds
            elseif timeData[1] then
                Countdown = timeData[1]
            else
                -- Try to find any number in the table
                for _, value in pairs(timeData) do
                    if type(value) == "number" then
                        Countdown = value
                        break
                    end
                end
            end
        end
        
        -- Debug: Print what we received
        if Countdown > 0 then
            print("⏰ Countdown:", Countdown, "seconds")
            print("Data received:", timeData)
        end
    end)
end

-- Simple dupe function (FIXED: Safe number comparison)
local function startDupe()
    if not ItemToDupe then
        print("❌ Add car first")
        return
    end
    
    print("🚀 Starting...")
    
    -- Accept
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    -- Wait for countdown to start
    print("Waiting for countdown...")
    local waited = 0
    while Countdown == 0 and waited < 50 do  -- 5 seconds max
        wait(0.1)
        waited = waited + 1
    end
    
    if Countdown == 0 then
        print("❌ No countdown started")
        print("Make sure other player accepts!")
        return
    end
    
    -- Wait for last moment (SAFE: Ensure Countdown is number)
    print("Countdown active:", Countdown, "seconds")
    
    local startTime = Countdown
    while true do
        -- SAFE CHECK: Make sure Countdown is a number
        if type(Countdown) ~= "number" then
            print("⚠️ Countdown is not a number:", Countdown)
            break
        end
        
        if Countdown <= 0.5 then
            break
        end
        
        wait(0.1)
    end
    
    -- Cancel at last moment
    print("🚨 CANCELLING NOW!")
    
    -- Multiple cancels for safety
    for i = 1, 3 do
        pcall(function()
            SessionSetConfirmation:InvokeServer(false)
        end)
        wait(0.1)
    end
    
    print("✅ Dupe attempt complete!")
    print("Check your inventory!")
end

-- TINY DRAGGABLE UI
local gui = Instance.new("ScreenGui")
gui.Name = "MiniDupe"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 80)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(0.2, 0.6, 1)
frame.Parent = gui

-- Title bar (for dragging)
local title = Instance.new("TextLabel")
title.Text = "DUPE v2"
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

-- Start button
local btn = Instance.new("TextButton")
btn.Text = "START"
btn.Size = UDim2.new(0.8, 0, 0, 30)
btn.Position = UDim2.new(0.1, 0, 0.6, 0)
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

-- Make draggable
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
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
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

-- Update status (SAFE: Check if Countdown is number)
game:GetService("RunService").Heartbeat:Connect(function()
    if ItemToDupe then
        status.Text = "✅ READY"
        status.TextColor3 = Color3.new(0, 1, 0)
    else
        status.Text = "Add car"
        status.TextColor3 = Color3.new(1, 1, 0)
    end
    
    -- SAFE: Only show if it's a number
    if type(Countdown) == "number" and Countdown > 0 then
        status.Text = status.Text .. " " .. Countdown .. "s"
    end
end)

print("📱 Fixed dupe loaded!")
print("Drag the blue bar to move")

-- DEBUG: Print what the countdown remote sends
print("\n🔍 DEBUG MODE ON")
print("Starting countdown listener...")

-- Also hook to see raw data
if OnSessionCountdownUpdated then
    local originalEvent = OnSessionCountdownUpdated.OnClientEvent
    OnSessionCountdownUpdated.OnClientEvent:Connect(function(data)
        print("\n📊 COUNTDOWN DATA RECEIVED:")
        print("Type:", type(data))
        
        if type(data) == "table" then
            print("Table contents:")
            for key, value in pairs(data) do
                print("  " .. tostring(key) .. " = " .. tostring(value) .. " (" .. type(value) .. ")")
            end
        else
            print("Value:", data)
        end
    end)
end
