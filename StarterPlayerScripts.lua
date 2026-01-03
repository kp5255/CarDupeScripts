-- 🚗 Auto Car Duplication Client for Dealership Tycoon
print("🚗 Auto Car Duplication System - Client Loaded")

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

-- Find events
local CarDupeEvent = ReplicatedStorage:WaitForChild("CarDupeEvent")
local CarDupeResponse = ReplicatedStorage:WaitForChild("CarDupeResponse")

print("✅ Events ready!")

-- Create sleek UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoCarDupeUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 240)
mainFrame.Position = UDim2.new(1, -370, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Title with gradient
local title = Instance.new("TextLabel")
title.Text = "🏎️ AUTO CAR DUPLICATOR"
title.Size = UDim2.new(1, 0, 0, 50)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

-- Vehicle info display
local vehicleInfo = Instance.new("Frame")
vehicleInfo.Size = UDim2.new(1, -20, 0, 100)
vehicleInfo.Position = UDim2.new(0, 10, 0, 60)
vehicleInfo.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
vehicleInfo.BorderSizePixel = 0
vehicleInfo.Parent = mainFrame

local vehicleIcon = Instance.new("TextLabel")
vehicleIcon.Text = "🚗"
vehicleIcon.Size = UDim2.new(0, 60, 1, 0)
vehicleIcon.Position = UDim2.new(0, 10, 0, 0)
vehicleIcon.BackgroundTransparency = 1
vehicleIcon.TextColor3 = Color3.new(1, 1, 1)
vehicleIcon.Font = Enum.Font.GothamBold
vehicleIcon.TextSize = 40
vehicleIcon.TextXAlignment = Enum.TextXAlignment.Left
vehicleIcon.Parent = vehicleInfo

local vehicleName = Instance.new("TextLabel")
vehicleName.Text = "No Vehicle Detected"
vehicleName.Size = UDim2.new(0.7, 0, 0.5, 0)
vehicleName.Position = UDim2.new(0, 70, 0, 5)
vehicleName.BackgroundTransparency = 1
vehicleName.TextColor3 = Color3.new(1, 1, 1)
vehicleName.Font = Enum.Font.GothamBold
vehicleName.TextSize = 18
vehicleName.TextXAlignment = Enum.TextXAlignment.Left
vehicleName.Parent = vehicleInfo

local vehicleStatus = Instance.new("TextLabel")
vehicleStatus.Text = "Sit in any vehicle to begin"
vehicleStatus.Size = UDim2.new(0.7, 0, 0.5, 0)
vehicleStatus.Position = UDim2.new(0, 70, 0, 35)
vehicleStatus.BackgroundTransparency = 1
vehicleStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
vehicleStatus.Font = Enum.Font.Gotham
vehicleStatus.TextSize = 14
vehicleStatus.TextXAlignment = Enum.TextXAlignment.Left
vehicleStatus.Parent = vehicleInfo

-- Duplicate button
local dupeButton = Instance.new("TextButton")
dupeButton.Text = "DUPLICATE VEHICLE"
dupeButton.Size = UDim2.new(1, -20, 0, 50)
dupeButton.Position = UDim2.new(0, 10, 0, 170)
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
closeButton.Position = UDim2.new(1, -35, 0, 10)
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

applyCorner(mainFrame, 12)
applyCorner(title, 12)
applyCorner(vehicleInfo, 10)
applyCorner(dupeButton, 8)
applyCorner(closeButton, 15)

applyStroke(mainFrame, Color3.fromRGB(0, 170, 255), 2)
applyStroke(vehicleInfo, Color3.fromRGB(80, 100, 150), 1)

-- Variables
local currentVehicle = nil
local currentVehicleData = {}
local isProcessing = false
local autoDetectionEnabled = true

-- Function to get the root vehicle model from a seat
local function getVehicleFromSeat(seat)
    if not seat then return nil end
    
    local model = seat:FindFirstAncestorOfClass("Model")
    if not model then return nil end
    
    -- Check if this is a valid vehicle model
    -- Look for common vehicle indicators
    local hasVehicleParts = 
        model:FindFirstChild("DriveSeat") or
        model:FindFirstChild("VehicleSeat") or
        model:FindFirstChild("Body") or
        model:FindFirstChild("Chassis") or
        model:FindFirstChild("VehicleStats") or
        model:FindFirstChild("EngineSound")
    
    if hasVehicleParts then
        return model
    end
    
    -- Check if parent might be the actual vehicle
    if model.Parent and model.Parent:IsA("Model") then
        local parentHasParts = 
            model.Parent:FindFirstChild("DriveSeat") or
            model.Parent:FindFirstChild("Body")
        
        if parentHasParts then
            return model.Parent
        end
    end
    
    return model
end

-- Function to extract vehicle data
local function getVehicleData(vehicleModel)
    local data = {
        Name = vehicleModel.Name,
        ModelPath = vehicleModel:GetFullName(),
        PartsCount = #vehicleModel:GetChildren(),
        IsValidVehicle = false
    }
    
    -- Check for vehicle configuration
    local config = vehicleModel:FindFirstChild("Configuration") or vehicleModel:FindFirstChild("Settings")
    if config then
        for _, child in ipairs(config:GetChildren()) do
            if child:IsA("StringValue") or child:IsA("NumberValue") or child:IsA("BoolValue") then
                data[child.Name] = child.Value
            end
        end
    end
    
    -- Check if it has essential vehicle parts
    data.HasDriveSeat = vehicleModel:FindFirstChild("DriveSeat") ~= nil
    data.HasWheels = vehicleModel:FindFirstChild("Wheels") ~= nil or #vehicleModel:GetChildrenOfClass("Part"):Filter(function(p) return p.Name:find("Wheel") end) > 0
    data.HasEngine = vehicleModel:FindFirstChild("Engine") ~= nil
    data.HasBody = vehicleModel:FindFirstChild("Body") ~= nil
    
    data.IsValidVehicle = data.HasDriveSeat and data.HasWheels
    
    return data
end

-- Automatic vehicle detection
RunService.Heartbeat:Connect(function()
    if not autoDetectionEnabled or isProcessing then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local seat = humanoid.SeatPart
    
    if seat and seat:IsA("VehicleSeat") then
        local vehicle = getVehicleFromSeat(seat)
        
        if vehicle and vehicle ~= currentVehicle then
            currentVehicle = vehicle
            local vehicleData = getVehicleData(vehicle)
            
            if vehicleData.IsValidVehicle then
                currentVehicleData = vehicleData
                
                -- Update UI with vehicle info
                vehicleName.Text = vehicleData.Name
                vehicleStatus.Text = "✅ Vehicle detected\nReady to duplicate"
                vehicleStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
                vehicleIcon.Text = "🚗"
                
                dupeButton.Text = "DUPLICATE " .. string.upper(string.sub(vehicleData.Name, 1, 10))
                dupeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
                dupeButton.Visible = true
                
                print("🚗 Detected vehicle: " .. vehicleData.Name)
            else
                -- Not a valid vehicle
                vehicleName.Text = "Invalid Vehicle"
                vehicleStatus.Text = "Not a valid car model"
                vehicleStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
                vehicleIcon.Text = "⚠️"
                
                dupeButton.Visible = false
                currentVehicle = nil
                currentVehicleData = {}
            end
        end
    else
        if currentVehicle then
            -- Player left vehicle
            currentVehicle = nil
            currentVehicleData = {}
            
            vehicleName.Text = "No Vehicle Detected"
            vehicleStatus.Text = "Sit in any vehicle to begin"
            vehicleStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
            vehicleIcon.Text = "🚗"
            
            dupeButton.Text = "DUPLICATE VEHICLE"
            dupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
            dupeButton.Visible = true
        end
    end
end)

-- Listen for server responses
CarDupeResponse.OnClientEvent:Connect(function(success, message, duplicateData)
    isProcessing = false
    
    if success then
        -- Success response
        vehicleName.Text = "✅ DUPLICATION SUCCESS!"
        vehicleStatus.Text = message .. "\nCheck your garage!"
        vehicleStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
        vehicleIcon.Text = "🎉"
        
        dupeButton.Text = "DUPLICATED!"
        dupeButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        
        -- Show duplicate details
        if duplicateData then
            print(string.format("\n🎉 CAR DUPLICATION SUCCESS!"))
            print(string.format("   Vehicle: %s", duplicateData.DisplayName or duplicateData.Name))
            print(string.format("   Value: $%d", duplicateData.Price or 0))
            print(string.format("   Class: %d", duplicateData.Class or 1))
            print(string.format("   ID: %s", duplicateData.ID or "N/A"))
            print(string.format("   Tradable: %s", duplicateData.Tradable and "YES" or "NO"))
            print(string.format("   Sellable: %s", duplicateData.Sellable and "YES" or "NO"))
        end
        
        -- Play success sound (optional)
        if game:GetService("SoundService"):FindFirstChild("SuccessSound") then
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://3570576787" -- Success sound
            sound.Volume = 0.5
            sound.Parent = player.Character or player:FindFirstChild("Head")
            sound:Play()
            game:Debris:AddItem(sound, 3)
        end
    else
        -- Failure response
        vehicleName.Text = "❌ DUPLICATION FAILED"
        vehicleStatus.Text = message or "Unknown error occurred"
        vehicleStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        vehicleIcon.Text = "❌"
        
        dupeButton.Text = "FAILED - TRY AGAIN"
        dupeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    end
    
    -- Reset UI after delay
    task.delay(4, function()
        if currentVehicle and currentVehicleData.IsValidVehicle then
            vehicleName.Text = currentVehicleData.Name
            vehicleStatus.Text = "✅ Vehicle detected\nReady to duplicate"
            vehicleStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
            vehicleIcon.Text = "🚗"
            
            dupeButton.Text = "DUPLICATE " .. string.upper(string.sub(currentVehicleData.Name, 1, 10))
            dupeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        else
            vehicleName.Text = "No Vehicle Detected"
            vehicleStatus.Text = "Sit in any vehicle to begin"
            vehicleStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
            vehicleIcon.Text = "🚗"
            
            dupeButton.Text = "DUPLICATE VEHICLE"
            dupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        end
    end)
end)

-- Duplicate button click
dupeButton.MouseButton1Click:Connect(function()
    if isProcessing then return end
    
    if not currentVehicle or not currentVehicleData.IsValidVehicle then
        vehicleName.Text = "NO VEHICLE DETECTED"
        vehicleStatus.Text = "Please sit in a valid vehicle first"
        vehicleStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        vehicleIcon.Text = "⚠️"
        
        task.wait(1.5)
        return
    end
    
    -- Start duplication process
    isProcessing = true
    autoDetectionEnabled = false
    
    vehicleName.Text = "PROCESSING..."
    vehicleStatus.Text = "Duplicating " .. currentVehicleData.Name .. "\nPlease wait..."
    vehicleStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
    vehicleIcon.Text = "🔄"
    
    dupeButton.Text = "DUPLICATING..."
    dupeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    
    -- Send vehicle data to server
    CarDupeEvent:FireServer("DuplicateVehicle", {
        VehicleModel = currentVehicle,
        VehicleData = currentVehicleData,
        Timestamp = os.time(),
        Player = player
    })
    
    print("🔄 Sending duplication request for: " .. currentVehicleData.Name)
    
    -- Re-enable auto detection after 2 seconds
    task.delay(2, function()
        autoDetectionEnabled = true
    end)
end)

-- Close button
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    print("📱 Duplication UI closed")
end)

-- Toggle UI with G key
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.G then
        mainFrame.Visible = not mainFrame.Visible
        print("📱 Auto Duplication UI: " .. (mainFrame.Visible and "SHOWN" or "HIDDEN"))
    end
end)

-- Auto-show UI when player enters a vehicle
local function showUIOnVehicleEnter()
    while true do
        if currentVehicle and currentVehicleData.IsValidVehicle and not mainFrame.Visible then
            mainFrame.Visible = true
        end
        wait(5)
    end
end

task.spawn(showUIOnVehicleEnter)

print("\n" .. string.rep("=", 60))
print("🚗 AUTO CAR DETECTION & DUPLICATION READY")
print("=":rep(60))
print("• Automatically detects ANY vehicle you sit in")
print("• Press G to toggle UI")
print("• Duplicated cars work EXACTLY like originals")
print("• Cars saved permanently to your inventory")
print("=":rep(60))
