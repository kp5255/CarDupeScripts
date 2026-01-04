-- 🏎️ ACTIVE CAR DUPLICATION WHILE DRIVING
-- Place ID: 1554960397 - NY SALE! Car Dealership Tycoon

print("🏎️ ACTIVE CAR DUPLICATION SYSTEM")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== STEP 1: FIND YOUR CURRENT DRIVING CAR =====
local function findCurrentDrivingCar()
    print("\n🔍 FINDING CURRENT DRIVING CAR...")
    
    local currentCar = nil
    
    -- Method 1: Look for car with player as driver
    if Workspace:FindFirstChild("Vehicles") then
        for _, vehicle in pairs(Workspace.Vehicles:GetChildren()) do
            if vehicle:IsA("Model") then
                -- Check for driver seat
                local driverSeat = vehicle:FindFirstChild("DriverSeat") or vehicle:FindFirstChild("Seat")
                if driverSeat and driverSeat:FindFirstChild("Occupant") then
                    local occupant = driverSeat.Occupant
                    if occupant and occupant.Parent == player.Character then
                        currentCar = vehicle
                        print("✅ Found driving car: " .. vehicle.Name)
                        break
                    end
                end
            end
        end
    end
    
    -- Method 2: Look for cars near player
    if not currentCar and player.Character then
        local charPos = player.Character:GetPivot().Position
        
        for _, vehicle in pairs(Workspace:GetChildren()) do
            if vehicle:IsA("Model") and vehicle:GetAttribute("IsVehicle") then
                local vehiclePos = vehicle:GetPivot().Position
                local distance = (charPos - vehiclePos).Magnitude
                
                if distance < 20 then  -- Within 20 studs
                    currentCar = vehicle
                    print("✅ Found nearby car: " .. vehicle.Name)
                    break
                end
            end
        end
    end
    
    -- Method 3: Look for spawned player vehicles
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local owner = obj:GetAttribute("Owner") or obj:FindFirstChild("Owner")
            if owner and (owner.Value == player or owner.Value == player.Name or owner.Value == player.UserId) then
                currentCar = obj
                print("✅ Found owned car: " .. obj.Name)
                break
            end
        end
    end
    
    if currentCar then
        print("Car details:")
        print("- Name: " .. currentCar.Name)
        print("- Class: " .. currentCar.ClassName)
        
        -- Get car model type
        for _, child in pairs(currentCar:GetChildren()) do
            if child:IsA("StringValue") and child.Name == "CarType" then
                print("- Type: " .. child.Value)
            end
        end
    else
        print("❌ No car found! Get in a car first!")
    end
    
    return currentCar
end

-- ===== STEP 2: DUPLICATE WHILE DRIVING =====
local function duplicateWhileDriving(carModel)
    print("\n⚡ DUPLICATING WHILE DRIVING...")
    
    if not carModel then
        print("❌ No car to duplicate!")
        return false
    end
    
    local carName = carModel.Name
    print("Target car: " .. carName)
    
    -- Strategy: Use driving/racing events since you're actively driving
    
    -- Look for driving/race events
    local drivingEvents = {}
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("drive") or name:find("race") or name:find("vehicle") or 
               name:find("spawn") or name:find("savecar") then
                table.insert(drivingEvents, obj)
                print("Found driving event: " .. obj.Name)
            end
        end
    end
    
    -- Also check for generic car events
    local carEvents = {}
    for _, obj in pairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") then
            table.insert(carEvents, obj)
        end
    end
    
    print("Total events to try: " .. (#drivingEvents + #carEvents))
    
    -- Try to duplicate using driving context
    local attempts = 0
    
    -- Method A: Try to save/spawn duplicate while driving
    for _, event in pairs(drivingEvents) do
        -- Different argument patterns for driving context
        local patterns = {
            {carName, "duplicate"},
            {player, carName, "save"},
            {carName, player.UserId},
            {Vehicle = carName, Action = "Clone"},
            {"savevehicle", carName},
            {"spawn", carName, player}
        }
        
        for _, args in pairs(patterns) do
            attempts = attempts + 1
            local success = pcall(function()
                if event:IsA("RemoteEvent") then
                    event:FireServer(unpack(args))
                else
                    event:InvokeServer(unpack(args))
                end
            end)
            
            if success then
                print("✅ Driving attempt " .. attempts .. " via " .. event.Name)
                
                -- Rapid fire while success
                for i = 1, 3 do
                    pcall(function()
                        if event:IsA("RemoteEvent") then
                            event:FireServer(unpack(args))
                        end
                    end)
                    task.wait(0.02)
                end
            end
            
            task.wait(0.05)
        end
    end
    
    -- Method B: Try to trigger garage save from driving
    print("\n🔄 Attempting garage save while driving...")
    
    -- Look for save/garage events
    local saveEvents = {"SaveCar", "StoreVehicle", "ParkCar", "GarageSave"}
    
    for _, eventName in pairs(saveEvents) do
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if event then
            for i = 1, 5 do
                pcall(function()
                    if event:IsA("RemoteEvent") then
                        event:FireServer(carName, player, i)  -- Try multiple saves
                        print("✅ Save attempt " .. i .. " via " .. eventName)
                    end
                end)
                task.wait(0.1)
            end
        end
    end
    
    -- Method C: Try to exploit the "No boost launch" system
    print("\n🚀 Exploiting boost system...")
    
    -- Since we see "No boost launch" messages, there's a boost system
    local boostEvents = {"Boost", "Nitrous", "SpeedBoost", "LaunchCar"}
    
    for _, eventName in pairs(boostEvents) do
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if event then
            -- Try to trigger boost with car duplication
            pcall(function()
                event:FireServer(carName, "DUPLICATE", 999)  -- High value might trigger bug
                print("✅ Boost exploit via " .. eventName)
            end)
        end
    end
    
    return attempts
end

-- ===== STEP 3: QUICK INVENTORY CHECK =====
local function quickInventoryCheck()
    print("\n📦 QUICK INVENTORY CHECK...")
    
    local inventory = player:FindFirstChild("Inventory") or 
                     player:FindFirstChild("Garage") or
                     player:FindFirstChild("Cars")
    
    if inventory then
        print("Inventory items (" .. #inventory:GetChildren() .. "):")
        for _, item in pairs(inventory:GetChildren()) do
            print("  - " .. item.Name .. " (" .. item.ClassName .. ")")
        end
    else
        print("❌ No inventory found!")
    end
    
    -- Also check player data
    if player:FindFirstChild("PlayerData") then
        local data = player.PlayerData
        for _, value in pairs(data:GetChildren()) do
            if value:IsA("StringValue") and value.Value:find("Car") then
                print("Data: " .. value.Name .. " = " .. value.Value)
            end
        end
    end
end

-- ===== STEP 4: CONTINUOUS DRIVING EXPLOIT =====
local function continuousDrivingExploit()
    print("\n🏎️ STARTING CONTINUOUS DRIVING EXPLOIT")
    
    -- This runs continuously while you drive
    local lastCar = nil
    local duplicateCount = 0
    
    while true do
        task.wait(3)  -- Check every 3 seconds
        
        -- Find current car
        local currentCar = findCurrentDrivingCar()
        
        if currentCar and currentCar ~= lastCar then
            print("\n🔄 NEW CAR DETECTED: " .. currentCar.Name)
            lastCar = currentCar
            
            -- Try to duplicate it
            local attempts = duplicateWhileDriving(currentCar)
            duplicateCount = duplicateCount + 1
            
            print("Duplication cycle: " .. duplicateCount)
            
            -- Quick inventory check
            quickInventoryCheck()
            
            -- If we've tried many times, wait longer
            if duplicateCount > 5 then
                print("⏳ Waiting 10 seconds before next attempt...")
                task.wait(10)
            end
        elseif not currentCar then
            print("⚠️ Not in a car. Get in a vehicle to continue.")
        end
    end
end

-- ===== STEP 5: CREATE DRIVING UI =====
local function createDrivingUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.Position = UDim2.new(0.8, 0, 0.1, 0)  -- Top right corner
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🏎️ DRIVING DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "Get in a car to start!\n\nDrive around while this runs.\n\nCheck console for updates."
    status.Size = UDim2.new(1, -20, 0, 120)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    -- Buttons
    local buttons = {
        {
            Text = "🔍 FIND CURRENT CAR",
            Y = 180,
            Action = function()
                local car = findCurrentDrivingCar()
                if car then
                    status.Text = "Found: " .. car.Name .. "\n\nAttempting duplication..."
                    task.wait(1)
                    duplicateWhileDriving(car)
                    task.wait(2)
                    quickInventoryCheck()
                    status.Text = "Duplication attempted!\nCheck inventory/garage."
                else
                    status.Text = "No car found!\nGet in a vehicle first."
                end
            end
        },
        {
            Text = "⚡ QUICK DUPLICATE",
            Y = 220,
            Action = function()
                local car = findCurrentDrivingCar()
                if car then
                    status.Text = "Quick dupe: " .. car.Name
                    for i = 1, 10 do
                        task.spawn(function()
                            local event = ReplicatedStorage:FindFirstChild("SaveCar")
                            if event then
                                pcall(function()
                                    event:FireServer(car.Name)
                                end)
                            end
                        end)
                    end
                    task.wait(1)
                    status.Text = "10 rapid attempts sent!\nCheck if car duplicated."
                end
            end
        }
    }
    
    for _, btn in pairs(buttons) do
        local button = Instance.new("TextButton")
        button.Text = btn.Text
        button.Size = UDim2.new(1, -40, 0, 35)
        button.Position = UDim2.new(0, 20, 0, btn.Y)
        button.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.Parent = frame
        
        button.MouseButton1Click:Connect(btn.Action)
    end
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return gui, status
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 70))
print("🏎️ ACTIVE DRIVING DUPLICATION SYSTEM")
print(string.rep("=", 70))
print("\nIMPORTANT: You must be DRIVING a car!")
print("The console shows you're in driving mode.")
print("\nThis script will:")
print("1. Detect your current car")
print("2. Attempt duplication WHILE you drive")
print("3. Run continuously")

-- Create UI
task.wait(1)
local gui, status = createDrivingUI()

-- Initial car check
task.wait(2)
local currentCar = findCurrentDrivingCar()

if currentCar then
    status.Text = "Found car: " .. currentCar.Name .. "\n\nStarting continuous exploit..."
    
    -- Start continuous exploit in background
    task.spawn(function()
        task.wait(2)
        continuousDrivingExploit()
    end)
    
    -- Initial duplication attempt
    task.wait(1)
    duplicateWhileDriving(currentCar)
    
else
    status.Text = "❌ NO CAR DETECTED!\n\nGet in a vehicle first!\n\nDrive around, then check back."
    print("\n❌ ERROR: You're not in a car!")
    print("Get in a vehicle, then the script will work.")
end

-- Final instructions
print("\n" .. string.rep("=", 70))
print("📋 INSTRUCTIONS:")
print(string.rep("=", 70))
print("\n1. DRIVE AROUND in your car")
print("2. The script runs CONTINUOUSLY")
print("3. Try DIFFERENT CARS")
print("4. Check garage BETWEEN drives")
print("5. Use the UI buttons for manual control")
print("\nThe script exploits the DRIVING STATE")
print("which might have weaker validation!")
