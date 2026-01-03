-- SIMPLE CAR DUPE CLIENT
print("Car Dupe Client Started")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Get event
local DupeEvent = ReplicatedStorage:WaitForChild("CarDupeEvent")

-- Simple UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CarDupeUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 180, 0, 45)
button.Position = UDim2.new(1, -190, 0, 100)
button.Text = "🚗 DUPE CAR"
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.TextColor3 = Color3.new(1, 1, 1)
button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
button.BorderSizePixel = 0
button.Parent = screenGui

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 180, 0, 60)
status.Position = UDim2.new(1, -190, 0, 155)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1, 1, 1)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextWrapped = true
status.Text = "Sit in a car\nClick button"
status.Parent = screenGui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

-- Track current seat
local currentSeat = nil
local currentCarName = ""

-- Update status
game:GetService("RunService").Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local seat = humanoid.SeatPart
    
    if seat and seat:IsA("VehicleSeat") then
        currentSeat = seat
        
        -- Try to get car name
        local body = seat.Parent
        local carModel = nil
        
        if body and body.Name == "Body" then
            carModel = body.Parent
        else
            carModel = seat.Parent
        end
        
        if carModel and carModel:IsA("Model") then
            currentCarName = carModel.Name
        else
            currentCarName = "Unknown Car"
        end
        
        button.Text = "DUPE: " .. currentCarName
        button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        status.Text = "✅ In: " .. currentCarName .. "\nClick to duplicate"
    else
        if currentSeat then
            currentSeat = nil
            currentCarName = ""
            button.Text = "🚗 DUPE CAR"
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            status.Text = "❌ Not in car\nSit in vehicle first"
        end
    end
end)

-- Button click
button.MouseButton1Click:Connect(function()
    if not currentSeat then
        status.Text = "❌ Sit in car first!"
        button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        task.wait(1)
        button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        status.Text = "❌ Not in car\nSit in vehicle first"
        return
    end
    
    -- Send request
    print("Sending dupe request...")
    status.Text = "🔄 Duplicating..."
    button.Text = "PROCESSING..."
    button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    
    local success = DupeEvent:FireServer(currentSeat)
    
    if success then
        print("Success!")
        status.Text = "✅ Car duplicated!\nCheck: ServerStorage/DuplicatedCars/"
        button.Text = "SUCCESS!"
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        print("Failed")
        status.Text = "❌ Failed\nCheck output window"
        button.Text = "FAILED"
        button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    -- Reset after 3 seconds
    task.delay(3, function()
        if currentSeat then
            button.Text = "DUPE: " .. currentCarName
            button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            status.Text = "✅ In: " .. currentCarName .. "\nClick to duplicate"
        else
            button.Text = "🚗 DUPE CAR"
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            status.Text = "❌ Not in car\nSit in vehicle first"
        end
    end)
end)

print("Client ready! Button in top-right")
