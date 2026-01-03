-- 🚗 Auto Car Duplication Client - FIXED VERSION
-- Place in StarterPlayerScripts or StarterGui

-- SAFE INITIALIZATION FUNCTION
local function initializeDuplicationSystem()
    print("🚗 Initializing Car Duplication System...")
    
    -- Wait for essential services
    repeat
        wait(0.5)
    until game:IsLoaded()
    
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Wait for player
    local player = Players.LocalPlayer
    while not player do
        wait(0.5)
        player = Players.LocalPlayer
    end
    
    print("✅ Player found: " .. player.Name)
    
    -- Wait for PlayerGui
    local playerGui
    repeat
        playerGui = player:WaitForChild("PlayerGui", 5)
        if not playerGui then
            print("⏳ Waiting for PlayerGui...")
            wait(1)
        end
    until playerGui
    
    print("✅ PlayerGui ready")
    
    -- Wait for remote events (with timeout)
    local CarDupeEvent, CarDupeResponse
    local attempts = 0
    local maxAttempts = 30
    
    repeat
        CarDupeEvent = ReplicatedStorage:FindFirstChild("CarDupeEvent")
        CarDupeResponse = ReplicatedStorage:FindFirstChild("CarDupeResponse")
        
        if not CarDupeEvent or not CarDupeResponse then
            attempts = attempts + 1
            print("⏳ Waiting for server events... (" .. attempts .. "/" .. maxAttempts .. ")")
            wait(1)
        end
    until (CarDupeEvent and CarDupeResponse) or attempts >= maxAttempts
    
    if not CarDupeEvent or not CarDupeResponse then
        warn("❌ Server events not found after " .. maxAttempts .. " attempts")
        return
    end
    
    print("✅ Remote events ready!")
    
    -- Now create the UI and setup the system
    setupDuplicationUI(player, playerGui, CarDupeEvent, CarDupeResponse)
end

-- UI AND SYSTEM SETUP FUNCTION
local function setupDuplicationUI(player, playerGui, CarDupeEvent, CarDupeResponse)
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    -- Create UI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoCarDupeUI"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 200)
    mainFrame.Position = UDim2.new(1, -340, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🏎️ CAR DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = mainFrame
    
    -- Vehicle status
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(1, -20, 0, 90)
    statusFrame.Position = UDim2.new(0, 10, 0, 50)
    statusFrame.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = mainFrame
    
    local vehicleIcon = Instance.new("TextLabel")
    vehicleIcon.Text = "🚗"
    vehicleIcon.Size = UDim2.new(0, 50, 1, 0)
    vehicleIcon.Position = UDim2.new(0, 5, 0, 0)
    vehicleIcon.BackgroundTransparency = 1
    vehicleIcon.TextColor3 = Color3.new(1, 1, 1)
    vehicleIcon.Font = Enum.Font.GothamBold
    vehicleIcon.TextSize = 36
    vehicleIcon.Parent = statusFrame
    
    local vehicleName = Instance.new("TextLabel")
    vehicleName.Text = "No vehicle detected"
    vehicleName.Size = UDim2.new(0.7, 0, 0.4, 0)
    vehicleName.Position = UDim2.new(0, 60, 0, 5)
    vehicleName.BackgroundTransparency = 1
    vehicleName.TextColor3 = Color3.new(1, 1, 1)
    vehicleName.Font = Enum.Font.GothamBold
    vehicleName.TextSize = 16
    vehicleName.TextXAlignment = Enum.TextXAlignment.Left
    vehicleName.Parent = statusFrame
    
    local vehicleStatus = Instance.new("TextLabel")
    vehicleStatus.Text = "Sit in a car to begin"
    vehicleStatus.Size = UDim2.new(0.7, 0, 0.4, 0)
    vehicleStatus.Position = UDim2.new(0, 60, 0, 40)
    vehicleStatus.BackgroundTransparency = 1
    vehicleStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
    vehicleStatus.Font = Enum.Font.Gotham
    vehicleStatus.TextSize = 14
    vehicleStatus.TextXAlignment = Enum.TextXAlignment.Left
    vehicleStatus.Parent = statusFrame
    
    -- Duplicate button
    local dupeButton = Instance.new("TextButton")
    dupeButton.Text = "DUPLICATE CAR"
    dupeButton.Size = UDim2.new(1, -20, 0, 40)
    dupeButton.Position = UDim2.new(0, 10, 0, 150)
    dupeButton.Font = Enum.Font.GothamBold
    dupeButton.TextSize = 16
    dupeButton.TextColor3 = Color3.new(1, 1, 1)
    dupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    dupeButton.AutoButtonColor = true
    dupeButton.Parent = mainFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "X"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeButton.Parent = title
    
    -- Simple styling
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = obj
        return corner
    end
    
    addCorner(mainFrame)
    addCorner(title)
    addCorner(statusFrame)
    addCorner(dupeButton)
    addCorner(closeButton)
    
    -- Variables
    local currentVehicle = nil
    local isProcessing = false
    
    -- Vehicle detection function
    local function getVehicleFromSeat(seat)
        if not seat then return nil end
        
        local vehicle = seat:FindFirstAncestorOfClass("Model")
        if not vehicle then return nil end
        
        -- Check if it's a vehicle by looking for common parts
        if vehicle:FindFirstChild("DriveSeat") or 
           vehicle:FindFirstChild("VehicleSeat") or
           vehicle:FindFirstChild("Body") or
           vehicle:FindFirstChild("Chassis") then
            return vehicle
        end
        
        return nil
    end
    
    -- Auto vehicle detection
    RunService.Heartbeat:Connect(function()
        if isProcessing then return end
        
        local character = player.Character
        if not character then return end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        local seat = humanoid.SeatPart
        
        if seat and seat:IsA("VehicleSeat") then
            local vehicle = getVehicleFromSeat(seat)
            
            if vehicle and vehicle ~= currentVehicle then
                currentVehicle = vehicle
                
                vehicleName.Text = vehicle.Name
                vehicleStatus.Text = "✅ Ready to duplicate"
                vehicleStatus.TextColor3 = Color3.fromRGB(0, 200, 0)
                vehicleIcon.Text = "🚗"
                
                dupeButton.Text = "DUPLICATE " .. string.sub(vehicle.Name, 1, 12)
                dupeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            end
        else
            if currentVehicle then
                currentVehicle = nil
                
                vehicleName.Text = "No vehicle detected"
                vehicleStatus.Text = "Sit in a car to begin"
                vehicleStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
                vehicleIcon.Text = "🚗"
                
                dupeButton.Text = "DUPLICATE CAR"
                dupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
            end
        end
    end)
    
    -- Listen for server responses
    CarDupeResponse.OnClientEvent:Connect(function(success, message)
        isProcessing = false
        
        if success then
            vehicleStatus.Text = "✅ " .. message
            vehicleStatus.TextColor3 = Color3.fromRGB(0, 200, 0)
            dupeButton.Text = "SUCCESS!"
            dupeButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            vehicleStatus.Text = "❌ " .. message
            vehicleStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
            dupeButton.Text = "FAILED"
            dupeButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
        end
        
        -- Reset after 3 seconds
        task.delay(3, function()
            if currentVehicle then
                vehicleStatus.Text = "✅ Ready to duplicate"
                vehicleStatus.TextColor3 = Color3.fromRGB(0, 200, 0)
                dupeButton.Text = "DUPLICATE " .. string.sub(currentVehicle.Name, 1, 12)
                dupeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            else
                vehicleStatus.Text = "Sit in a car to begin"
                vehicleStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
                dupeButton.Text = "DUPLICATE CAR"
                dupeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
            end
        end)
    end)
    
    -- Duplicate button click
    dupeButton.MouseButton1Click:Connect(function()
        if isProcessing then return end
        
        if not currentVehicle then
            vehicleStatus.Text = "❌ Sit in a car first!"
            vehicleStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
            
            task.wait(1.5)
            if not currentVehicle then
                vehicleStatus.Text = "Sit in a car to begin"
                vehicleStatus.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            return
        end
        
        -- Start duplication
        isProcessing = true
        vehicleStatus.Text = "🔄 Processing..."
        vehicleStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
        dupeButton.Text = "PROCESSING"
        dupeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        
        -- Send to server
        CarDupeEvent:FireServer("DuplicateVehicle", {
            Vehicle = currentVehicle,
            VehicleName = currentVehicle.Name,
            Timestamp = os.time()
        })
        
        print("🔄 Request sent: " .. currentVehicle.Name)
    end)
    
    -- Close button
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        print("📱 Duplication UI closed")
    end)
    
    -- Toggle UI with G key
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.G then
            mainFrame.Visible = not mainFrame.Visible
            print("📱 UI toggled: " .. tostring(mainFrame.Visible))
        end
    end)
    
    print("🚗 Car Duplication System READY!")
    print("• Press G to show/hide")
    print("• Sit in any car and click DUPLICATE")
    
    -- Show welcome message
    task.wait(2)
    vehicleStatus.Text = "System Ready!\nPress G to toggle UI"
    vehicleStatus.TextColor3 = Color3.fromRGB(100, 200, 255)
end

-- START THE SYSTEM WITH ERROR HANDLING
local success, errorMessage = pcall(function()
    initializeDuplicationSystem()
end)

if not success then
    warn("❌ Failed to initialize Car Duplication System: " .. tostring(errorMessage))
    print("Stack trace:", debug.traceback())
end
