-- SIMPLE CAR DUPE CLIENT
print("=== Car Duplication Client ===")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Get event
local VehicleSystem = ReplicatedStorage:WaitForChild("VehicleSystem")

-- Create clean UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CarDupeUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 160)
frame.Position = UDim2.new(1, -260, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "🚗 CAR DUPLICATOR"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local button = Instance.new("TextButton")
button.Text = "ADD TO GARAGE"
button.Size = UDim2.new(1, -40, 0, 45)
button.Position = UDim2.new(0, 20, 0, 100)
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.TextColor3 = Color3.new(1, 1, 1)
button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
button.BorderSizePixel = 0
button.Parent = frame

local status = Instance.new("TextLabel")
status.Text = "Sit in any car\nto duplicate it"
status.Size = UDim2.new(1, -20, 0, 60)
status.Position = UDim2.new(0, 10, 0, 35)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1, 1, 1)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextWrapped = true
status.Parent = frame

-- Styling
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = button

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 150, 255)
stroke.Thickness = 2
stroke.Parent = frame

-- Track current car
local currentSeat = nil
local currentCar = ""

-- Update car status
game:GetService("RunService").Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local seat = humanoid.SeatPart
    
    if seat and seat:IsA("VehicleSeat") then
        if currentSeat ~= seat then
            currentSeat = seat
            
            -- Get car name (handles Body structure)
            local body = seat.Parent
            if body and body.Name == "Body" then
                currentCar = body.Parent.Name
            else
                currentCar = seat.Parent.Name
            end
            
            status.Text = "✅ IN: " .. currentCar .. "\nReady to duplicate"
            button.Text = "ADD " .. currentCar
            button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        end
    else
        if currentSeat ~= nil then
            currentSeat = nil
            currentCar = ""
            status.Text = "❌ NOT IN CAR\nSit in a vehicle first"
            button.Text = "ADD TO GARAGE"
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        end
    end
end)

-- Button click
button.MouseButton1Click:Connect(function()
    if not currentSeat then
        status.Text = "❌ SIT IN CAR FIRST!"
        button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        task.wait(1)
        if not currentSeat then
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            status.Text = "❌ NOT IN CAR\nSit in a vehicle first"
        end
        return
    end
    
    -- Start duplication
    print("🔄 Adding " .. currentCar .. " to garage...")
    
    status.Text = "🔄 ADDING TO GARAGE..."
    button.Text = "PROCESSING..."
    button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    
    -- Send to server
    local success = VehicleSystem:FireServer("DuplicateVehicle", {
        Seat = currentSeat,
        CarName = currentCar,
        Time = os.time()
    })
    
    if success then
        print("✅ Car added to garage!")
        status.Text = "✅ ADDED TO GARAGE!\nCheck your inventory"
        button.Text = "SUCCESS!"
        button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        print("❌ Failed to add car")
        status.Text = "❌ FAILED\nTry again"
        button.Text = "FAILED"
        button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    -- Reset
    task.delay(3, function()
        if currentSeat then
            button.Text = "ADD " .. currentCar
            button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            status.Text = "✅ IN: " .. currentCar .. "\nReady to duplicate"
        else
            button.Text = "ADD TO GARAGE"
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            status.Text = "❌ NOT IN CAR\nSit in a vehicle first"
        end
    end)
end)

-- Toggle UI with G key
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.G then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

print("\n" .. string.rep("=", 60))
print("🚗 CAR DUPLICATION CLIENT READY")
print("=":rep(60))
print("• UI appears in top-right")
print("• Press G to show/hide")
print("• Sit in any car and click button")
print("• Car appears in your normal garage")
print("=":rep(60))
