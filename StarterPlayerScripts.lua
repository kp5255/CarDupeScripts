-- SIMPLE TEST CLIENT FOR CAR DUPE
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Get event
local DupeEvent = ReplicatedStorage:WaitForChild("Dev_DupeCar")

-- Simple button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(1, -210, 0, 150)
button.Text = "🚗 DUPE CAR"
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.TextColor3 = Color3.new(1, 1, 1)
button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
button.Parent = player:WaitForChild("PlayerGui")

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

-- Status text
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 200, 0, 60)
status.Position = UDim2.new(1, -210, 0, 210)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1, 1, 1)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextWrapped = true
status.Text = "Sit in a car\nClick button"
status.Parent = button.Parent

-- Track seat
local currentSeat = nil

-- Check seat
game:GetService("RunService").Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local seat = humanoid.SeatPart
    
    if seat and seat:IsA("VehicleSeat") then
        if currentSeat ~= seat then
            currentSeat = seat
            local carName = seat.Parent and seat.Parent.Name or "Car"
            button.Text = "DUPE: " .. carName
            button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            status.Text = "✅ IN: " .. carName .. "\nClick to duplicate"
        end
    else
        if currentSeat ~= nil then
            currentSeat = nil
            button.Text = "🚗 DUPE CAR"
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            status.Text = "❌ NOT IN CAR\nSit in vehicle first"
        end
    end
end)

-- Button click
button.MouseButton1Click:Connect(function()
    if not currentSeat then
        status.Text = "❌ SIT IN CAR FIRST!"
        button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        -- Flash
        for i = 1, 3 do
            button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(0.1)
            button.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            task.wait(0.1)
        end
        
        task.wait(1)
        button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        button.Text = "🚗 DUPE CAR"
        status.Text = "❌ NOT IN CAR\nSit in vehicle first"
        return
    end
    
    -- Send request
    print("🔄 Duplicating car...")
    
    status.Text = "🔄 PROCESSING..."
    button.Text = "WORKING..."
    button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    
    local success = DupeEvent:FireServer(currentSeat)
    
    if success then
        print("✅ Request sent to server")
        status.Text = "✅ REQUEST SENT!\nCheck inventory"
        button.Text = "SUCCESS!"
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        print("❌ Request failed")
        status.Text = "❌ FAILED\nCheck output"
        button.Text = "FAILED"
        button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    -- Reset
    task.delay(3, function()
        if currentSeat then
            local carName = currentSeat.Parent and currentSeat.Parent.Name or "Car"
            button.Text = "DUPE: " .. carName
            button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            status.Text = "✅ IN: " .. carName .. "\nClick to duplicate"
        else
            button.Text = "🚗 DUPE CAR"
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            status.Text = "❌ NOT IN CAR\nSit in vehicle first"
        end
    end)
end)

print("🚗 Car Dupe Test Client Ready!")
print("Button in top-right corner")
print("Sit in any car and click!")
