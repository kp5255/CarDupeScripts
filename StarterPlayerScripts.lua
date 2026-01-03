-- Car Duplication Client for Dealership Tycoon
print("🚗 Car Duplication System - Client Loaded")

-- Wait for game to fully load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Wait for player
repeat wait() until player.Character

-- Find or create events
local VehicleDupeEvent
local VehicleDupeResponse

repeat
    VehicleDupeEvent = ReplicatedStorage:FindFirstChild("VehicleDupeEvent")
    VehicleDupeResponse = ReplicatedStorage:FindFirstChild("VehicleDupeResponse")
    if not VehicleDupeEvent or not VehicleDupeResponse then
        wait(1)
        print("⏳ Waiting for server events...")
    end
until VehicleDupeEvent and VehicleDupeResponse

print("✅ Events found!")

-- Create clean UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DealershipDupeUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(1, -320, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Text = "🚗 DEALERSHIP DUPLICATOR"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

-- Status box
local statusBox = Instance.new("Frame")
statusBox.Size = UDim2.new(1, -20, 0, 80)
statusBox.Position = UDim2.new(0, 10, 0, 50)
statusBox.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
statusBox.BorderSizePixel = 0
statusBox.Parent = mainFrame

local statusText = Instance.new("TextLabel")
statusText.Text = "Sit in any car to\nstart duplication"
statusText.Size = UDim2.new(1, 0, 1, 0)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.new(1, 1, 1)
statusText.Font = Enum.Font.Gotham
statusText.TextSize = 14
statusText.TextWrapped = true
statusText.Parent = statusBox

-- Duplicate button
local dupeButton = Instance.new("TextButton")
dupeButton.Text = "DUPLICATE CAR"
dupeButton.Size = UDim2.new(1, -20, 0, 50)
dupeButton.Position = UDim2.new(0, 10, 0, 140)
dupeButton.Font = Enum.Font.GothamBold
dupeButton.TextSize = 16
dupeButton.TextColor3 = Color3.new(1, 1, 1)
dupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
dupeButton.AutoButtonColor = true
dupeButton.Parent = mainFrame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Text = "✕"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
closeButton.Parent = title

-- UI Styling
local function applyCorner(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

local function applyStroke(obj, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Parent = obj
end

applyCorner(mainFrame, 10)
applyCorner(title, 10)
applyCorner(statusBox, 8)
applyCorner(dupeButton, 8)
applyCorner(closeButton, 15)

applyStroke(mainFrame, Color3.fromRGB(0, 150, 255), 2)
applyStroke(statusBox, Color3.fromRGB(100, 100, 100), 1)

-- Variables
local currentVehicle = nil
local currentVehicleName = ""
local isProcessing = false

-- Vehicle detection
RunService.Heartbeat:Connect(function()
    if isProcessing then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local seat = humanoid.SeatPart
    
    if seat and seat:IsA("VehicleSeat") then
        local vehicleModel = seat.Parent
        -- Check if it's the main vehicle (not just a seat)
        if vehicleModel:FindFirstChild("DriveSeat") or vehicleModel:FindFirstChild("Body") then
            -- Get actual car model (handles different vehicle structures)
            local actualVehicle = vehicleModel
            if vehicleModel:FindFirstChild("Body") then
                actualVehicle = vehicleModel.Parent or vehicleModel
            end
            
            if currentVehicle ~= actualVehicle then
                currentVehicle = actualVehicle
                currentVehicleName = actualVehicle.Name
                
                -- Update UI
                statusText.Text = string.format("✅ IN VEHICLE:\n%s\n\nReady to duplicate!", currentVehicleName)
                dupeButton.Text = "DUPLICATE " .. string.sub(currentVehicleName, 1, 12)
                dupeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            end
        end
    else
        if currentVehicle then
            currentVehicle = nil
            currentVehicleName = ""
            statusText.Text = "❌ NOT IN VEHICLE\n\nSit in any car to\nduplicate it"
            dupeButton.Text = "DUPLICATE CAR"
            dupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        end
    end
end)

-- Listen for server responses
VehicleDupeResponse.OnClientEvent:Connect(function(success, message, carData)
    isProcessing = false
    
    if success then
        statusText.Text = "✅ SUCCESS!\n\n" .. message .. "\n\nCheck your garage!"
        dupeButton.Text = "DUPLICATED!"
        dupeButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        
        -- Optional: Show car details
        if carData then
            print(string.format("🎉 Car Duplicated!\nName: %s\nClass: %d\nValue: $%d", 
                carData.Name, carData.Class or 1, carData.Price or 0))
        end
    else
        statusText.Text = "❌ FAILED\n\n" .. (message or "Unknown error")
        dupeButton.Text = "FAILED"
        dupeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    end
    
    -- Reset after 3 seconds
    task.delay(3, function()
        if currentVehicle then
            statusText.Text = string.format("✅ IN VEHICLE:\n%s\n\nReady to duplicate!", currentVehicleName)
            dupeButton.Text = "DUPLICATE " .. string.sub(currentVehicleName, 1, 12)
            dupeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        else
            statusText.Text = "❌ NOT IN VEHICLE\n\nSit in any car to\nduplicate it"
            dupeButton.Text = "DUPLICATE CAR"
            dupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        end
    end)
end)

-- Duplicate button click
dupeButton.MouseButton1Click:Connect(function()
    if isProcessing then return end
    
    if not currentVehicle then
        statusText.Text = "❌ NOT IN VEHICLE!\n\nPlease sit in a car first"
        dupeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        task.wait(1)
        if currentVehicle then
            statusText.Text = string.format("✅ IN VEHICLE:\n%s\n\nReady to duplicate!", currentVehicleName)
            dupeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        end
        return
    end
    
    -- Start duplication process
    isProcessing = true
    statusText.Text = "🔄 PROCESSING...\n\nDuplicating " .. currentVehicleName .. "\nPlease wait..."
    dupeButton.Text = "PROCESSING"
    dupeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    
    -- Send request to server
    VehicleDupeEvent:FireServer("DuplicateVehicle", {
        Vehicle = currentVehicle,
        VehicleName = currentVehicleName,
        Player = player,
        Timestamp = os.time()
    })
    
    print("🔄 Request sent to duplicate: " .. currentVehicleName)
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    print("📱 Duplication UI closed")
end)

-- Toggle with G key
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.G then
        mainFrame.Visible = not mainFrame.Visible
        print("📱 UI toggled: " .. tostring(mainFrame.Visible))
    end
end)

print("\n" .. string.rep("=", 60))
print("🚗 DEALERSHIP DUPLICATION CLIENT READY")
print("=":rep(60))
print("• UI appears on right side")
print("• Press G to show/hide")
print("• Sit in any car and click DUPLICATE")
print("• Car will be added to your garage")
print("=":rep(60))
