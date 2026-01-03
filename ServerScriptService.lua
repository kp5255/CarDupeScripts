-- SIMPLE CAR DUPE CLIENT
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- WAIT FOR SERVER EVENT
local DupeEvent = ReplicatedStorage:WaitForChild("Dev_DupeCar")
print("✅ Connected to server event")

-- SIMPLE GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleCarDupeGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 120)
frame.Position = UDim2.new(1, -260, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "🚗 CAR DUPLICATOR"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local status = Instance.new("TextLabel")
status.Text = "Sit in a car, then click below"
status.Size = UDim2.new(1, -20, 0, 40)
status.Position = UDim2.new(0, 10, 0, 35)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1, 1, 1)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextWrapped = true
status.Parent = frame

local button = Instance.new("TextButton")
button.Text = "DUPLICATE CAR"
button.Size = UDim2.new(1, -40, 0, 40)
button.Position = UDim2.new(0, 20, 0, 80)
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.TextColor3 = Color3.new(1, 1, 1)
button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
button.BorderSizePixel = 0
button.Parent = frame

-- TRACK CURRENT SEAT
local currentSeat = nil

-- CHECK FOR SEAT
local function checkSeat()
    local character = player.Character
    if not character then return nil end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return nil end
    
    return humanoid.SeatPart
end

-- UPDATE STATUS
game:GetService("RunService").Heartbeat:Connect(function()
    local seat = checkSeat()
    
    if seat and seat:IsA("VehicleSeat") then
        currentSeat = seat
        status.Text = "✅ In car: " .. seat.Parent.Name
        button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        button.Text = "DUPLICATE CAR"
    else
        currentSeat = nil
        status.Text = "❌ Not in a car\nSit in a vehicle first"
        button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        button.Text = "NEED TO SIT IN CAR"
    end
end)

-- BUTTON ACTION
button.MouseButton1Click:Connect(function()
    if not currentSeat then
        status.Text = "❌ You must sit in a car first!"
        button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(1)
        return
    end
    
    -- Send request
    status.Text = "🔄 Duplicating..."
    button.Text = "PROCESSING..."
    button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    
    local success = DupeEvent:FireServer(currentSeat)
    
    if success then
        status.Text = "✅ Car duplicated!\nCheck ServerStorage"
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        button.Text = "SUCCESS!"
    else
        status.Text = "❌ Failed to duplicate"
        button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        button.Text = "FAILED - TRY AGAIN"
    end
    
    -- Reset after 3 seconds
    task.delay(3, function()
        if currentSeat then
            button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            button.Text = "DUPLICATE CAR"
            status.Text = "✅ In car: " .. currentSeat.Parent.Name
        else
            button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            button.Text = "NEED TO SIT IN CAR"
            status.Text = "❌ Not in a car"
        end
    end)
end)

-- KEYBIND TOGGLE
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        screenGui.Enabled = not screenGui.Enabled
        print("GUI toggled:", screenGui.Enabled)
    end
end)

print("🚗 Car Duplication Client READY!")
print("Press F to show/hide GUI")
print("Sit in a car and click the button!")
