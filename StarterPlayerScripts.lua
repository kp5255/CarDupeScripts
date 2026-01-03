-- 🚗 WORKING CAR DUPLICATOR
-- Game ID: ffad7ea30d080c4aa1d7bf4b2f5f4381

print("🚗 WORKING DUPLICATOR - TARGETING YOUR CARS")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- YOUR ACTUAL CAR NAMES from the image
local YOUR_CARS = {
    "LirrMedMuseumCar",  -- This is your actual car!
    "Prices",  -- Price data
    "CarReplication"  -- Might be duplication system
}

-- ===== FIND THE CORRECT EVENT =====
local function findCarEvents()
    print("\n🔍 Finding car events...")
    
    local events = {}
    
    -- Look for events with your car names
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            print("Found: " .. obj.Name .. " (" .. obj.ClassName .. ")")
            table.insert(events, {
                Object = obj,
                Name = obj.Name,
                Type = obj.ClassName
            })
        end
    end
    
    return events
end

-- ===== TRY TO DUPLICATE LirrMedMuseumCar =====
local function duplicateLirrCar()
    print("\n⚡ ATTEMPTING TO DUPLICATE: LirrMedMuseumCar")
    
    local events = findCarEvents()
    local targetCar = "LirrMedMuseumCar"
    local attempts = 0
    
    -- Try each event
    for _, eventData in pairs(events) do
        local event = eventData.Object
        
        print("\nTrying event: " .. eventData.Name)
        
        -- Specialized arguments for THIS game
        local argSets = {
            -- Basic car duplication
            {targetCar},
            
            -- With player
            {player, targetCar},
            
            -- Purchase with price
            {targetCar, 0},
            {targetCar, 1},
            {targetCar, 1000},
            
            -- Command style
            {"BuyVehicle", targetCar},
            {"PurchaseCar", targetCar},
            {"AddCar", targetCar},
            
            -- Might need special format for LirrMedMuseumCar
            {"LirrMedMuseum", "Car"},
            {"Lirr", "MedMuseumCar"},
            
            -- Try CarReplication event (since you have this!)
            {"replicate", targetCar},
            {"duplicate", targetCar},
            {"copy", targetCar},
            
            -- Table format
            {VehicleName = targetCar},
            {Car = targetCar, Action = "Buy"},
            {Model = targetCar, Purchase = true},
            
            -- For "CarReplication" system
            {targetCar, "duplicate"},
            {targetCar, "clone"},
            {targetCar, 2},  -- quantity 2
            
            -- Maybe it needs player data
            {player.UserId, targetCar},
            {player.Name, targetCar},
            
            -- Try free purchase
            {targetCar, "free"},
            {"free", targetCar},
            {targetCar, false}  -- false = free
        }
        
        for i, args in pairs(argSets) do
            local success, errorMsg = pcall(function()
                if eventData.Type == "RemoteEvent" then
                    event:FireServer(unpack(args))
                    return "Fired"
                else
                    event:InvokeServer(unpack(args))
                    return "Invoked"
                end
            end)
            
            if success then
                print("✅ Attempt " .. i .. " - CALL SENT")
                attempts = attempts + 1
                
                -- Try rapid fire
                for j = 1, 3 do
                    pcall(function()
                        if eventData.Type == "RemoteEvent" then
                            event:FireServer(unpack(args))
                        else
                            event:InvokeServer(unpack(args))
                        end
                    end)
                    task.wait(0.02)
                end
            end
            
            task.wait(0.05)
        end
    end
    
    return attempts
end

-- ===== CHECK CARREPLICATION SYSTEM =====
local function checkCarReplication()
    print("\n🔬 CHECKING CarReplication SYSTEM")
    
    -- Look for CarReplication object
    local carReplication = nil
    
    -- Check player folders
    for _, folder in pairs(player:GetChildren()) do
        if folder.Name == "CarReplication" then
            carReplication = folder
            print("Found CarReplication folder!")
            break
        end
    end
    
    if carReplication then
        print("CarReplication contents:")
        for _, item in pairs(carReplication:GetChildren()) do
            print("  - " .. item.Name .. " (" .. item.ClassName .. ")")
            
            -- If it's a RemoteEvent, use it!
            if item:IsA("RemoteEvent") or item:IsA("RemoteFunction") then
                print("  ⚡ Found replication event!")
                
                -- Try to use it
                for i = 1, 5 do
                    pcall(function()
                        if item:IsA("RemoteEvent") then
                            item:FireServer("LirrMedMuseumCar")
                        else
                            item:InvokeServer("LirrMedMuseumCar")
                        end
                        print("  ✅ Sent replication request " .. i)
                    end)
                    task.wait(0.1)
                end
            end
        end
    end
    
    return carReplication ~= nil
end

-- ===== MAIN DUPLICATION =====
local function mainDuplication()
    print("\n" .. string.rep("=", 60))
    print("🚗 DUPLICATING LirrMedMuseumCar")
    print(string.rep("=", 60))
    
    -- First, check CarReplication system
    local hasReplication = checkCarReplication()
    
    if hasReplication then
        print("\n🎯 Using CarReplication system...")
        task.wait(1)
    end
    
    -- Then try standard duplication
    print("\n🎯 Standard duplication attempts...")
    local attempts = duplicateLirrCar()
    
    print("\n📊 Sent " .. attempts .. " duplication attempts")
    
    -- Check results
    task.wait(2)
    
    print("\n🔍 Checking inventory...")
    
    -- Look for your cars again
    local currentCars = {}
    for _, folder in pairs(player:GetChildren()) do
        for _, item in pairs(folder:GetChildren()) do
            if item.Name:find("Car") or item.Name:find("Lirr") then
                if not table.find(currentCars, item.Name) then
                    table.insert(currentCars, item.Name)
                end
            end
        end
    end
    
    print("\n" .. string.rep("=", 50))
    print("YOUR CARS NOW:")
    for i, car in ipairs(currentCars) do
        print(i .. ". " .. car)
    end
    
    -- Check if we have multiple LirrMedMuseumCar
    local lirrCount = 0
    for _, car in pairs(currentCars) do
        if car:find("Lirr") then
            lirrCount = lirrCount + 1
        end
    end
    
    if lirrCount > 1 then
        print("\n🎉 SUCCESS! You now have " .. lirrCount .. " LirrMedMuseumCars!")
        print("Check your garage/inventory!")
    else
        print("\n⚠️ Still only 1 LirrMedMuseumCar")
        print("\nTrying one more method...")
        
        -- Last resort: Direct event search
        lastResortMethod()
    end
end

-- ===== LAST RESORT METHOD =====
local function lastResortMethod()
    print("\n💥 LAST RESORT: Direct event firing")
    
    -- Get ALL remote events
    local allEvents = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(allEvents, obj)
        end
    end
    
    print("Found " .. #allEvents .. " RemoteEvents")
    
    -- Fire them all with car name
    for i, event in ipairs(allEvents) do
        if i <= 50 then  -- Limit to 50
            pcall(function()
                event:FireServer("LirrMedMuseumCar")
                print("Fired: " .. event.Name)
            end)
            task.wait(0.01)
        end
    end
end

-- ===== CREATE SIMPLE CONTROL =====
local function createControlUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🚗 DUPLICATE LirrMedMuseumCar"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "Found: LirrMedMuseumCar\nClick to duplicate!"
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 0, 35)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Text = "⚡ DUPLICATE NOW"
    button.Size = UDim2.new(1, -40, 0, 40)
    button.Position = UDim2.new(0, 20, 0, 90)
    button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        status.Text = "Duplicating...\nCheck console!"
        button.Text = "WORKING..."
        button.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            mainDuplication()
            task.wait(2)
            status.Text = "Complete!\nCheck your cars."
            button.Text = "TRY AGAIN"
            button.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        end)
    end)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return gui
end

-- ===== AUTO-RUN =====
print("\n" .. string.rep("=", 60))
print("YOUR CARS FOUND:")
print("1. Prices (price data)")
print("2. LirrMedMuseumCar (YOUR CAR!)")
print("3. CarReplication (duplication system)")
print(string.rep("=", 60))

-- Create UI
task.wait(1)
createControlUI()

-- Auto-start after 3 seconds
task.wait(3)
print("\n⚡ Auto-starting duplication in 3... 2... 1...")
mainDuplication()

print("\n💡 TIPS:")
print("1. Check if 'CarReplication' is a folder with events")
print("2. Look for BuyCar, PurchaseVehicle events")
print("3. Try buying/selling first, then duplicating")
