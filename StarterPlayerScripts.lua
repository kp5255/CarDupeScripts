-- 🚗 STATIC CAR DUPLICATOR (NO MOVEMENT)
-- Place ID: 1554960397 - NY SALE! Car Dealership Tycoon

print("🚗 STATIC DUPLICATOR - NO MOVEMENT")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- Prevent any character movement
local function disableMovement()
    print("\n🛑 DISABLING CHARACTER MOVEMENT")
    
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            -- Disable movement but keep script running
            pcall(function()
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
                print("✅ Movement disabled")
            end)
        end
    end
end

-- ===== STEP 1: CHECK INVENTORY WITHOUT MOVING =====
local function checkInventoryStatic()
    print("\n📦 CHECKING INVENTORY (STATIC)...")
    
    local carCount = 0
    local carNames = {}
    
    -- Check all player folders without moving
    for _, folder in pairs(player:GetChildren()) do
        if folder:IsA("Folder") then
            for _, item in pairs(folder:GetChildren()) do
                if item.Name:find("Car") or item.Name:find("Vehicle") then
                    carCount = carCount + 1
                    table.insert(carNames, item.Name)
                end
            end
        end
    end
    
    -- Check leaderstats
    if player:FindFirstChild("leaderstats") then
        for _, stat in pairs(player.leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                if stat.Name:lower():find("car") then
                    print("Car stat: " .. stat.Name .. " = " .. stat.Value)
                end
            end
        end
    end
    
    print("Found " .. carCount .. " cars in inventory")
    if carCount > 0 then
        print("Car names:")
        for i, name in ipairs(carNames) do
            print("  " .. i .. ". " .. name)
        end
    end
    
    return carNames
end

-- ===== STEP 2: STATIC DUPLICATION ATTEMPTS =====
local function staticDuplicateCars(carNames)
    print("\n⚡ STATIC DUPLICATION ATTEMPTS")
    
    if #carNames == 0 then
        print("❌ No cars to duplicate!")
        return false
    end
    
    -- Find events WITHOUT moving character
    local events = {}
    
    for _, obj in pairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(events, {
                Object = obj,
                Name = obj.Name,
                Type = obj.ClassName
            })
        end
    end
    
    print("Found " .. #events .. " events")
    
    -- Try duplication with each car
    local attempts = 0
    
    for _, carName in pairs(carNames) do
        print("\nTrying: " .. carName)
        
        for _, eventData in pairs(events) do
            local event = eventData.Object
            
            -- Simple argument patterns (no player movement)
            local patterns = {
                {carName},
                {carName, 0},
                {carName, 1},
                {"buy", carName},
                {"add", carName},
                {"duplicate", carName}
            }
            
            for i, args in pairs(patterns) do
                attempts = attempts + 1
                
                local success, errorMsg = pcall(function()
                    if eventData.Type == "RemoteEvent" then
                        event:FireServer(unpack(args))
                        return true
                    else
                        event:InvokeServer(unpack(args))
                        return true
                    end
                end)
                
                if success then
                    print("✅ Attempt " .. attempts .. " via " .. eventData.Name)
                    
                    -- Rapid fire a few times
                    for j = 1, 3 do
                        pcall(function()
                            if eventData.Type == "RemoteEvent" then
                                event:FireServer(unpack(args))
                            end
                        end)
                        task.wait(0.01)
                    end
                end
                
                task.wait(0.05)
            end
        end
    end
    
    print("\n📊 Total attempts: " .. attempts)
    return attempts > 0
end

-- ===== STEP 3: SIMPLE UI (NO MOVEMENT) =====
local function createStaticUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "StaticDuplicator"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.8, -100)  -- Bottom center
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🚗 STATIC DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "Ready. Will NOT move your character.\n\nClick buttons below."
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    -- Button 1: Check Cars
    local btn1 = Instance.new("TextButton")
    btn1.Text = "🔍 CHECK CARS"
    btn1.Size = UDim2.new(1, -40, 0, 35)
    btn1.Position = UDim2.new(0, 20, 0, 140)
    btn1.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    btn1.TextColor3 = Color3.new(1, 1, 1)
    btn1.Font = Enum.Font.GothamBold
    btn1.TextSize = 14
    btn1.Parent = frame
    
    btn1.MouseButton1Click:Connect(function()
        local cars = checkInventoryStatic()
        if #cars > 0 then
            local text = "Found " .. #cars .. " cars:\n"
            for i = 1, math.min(3, #cars) do
                text = text .. "• " .. cars[i] .. "\n"
            end
            if #cars > 3 then
                text = text .. "... and " .. (#cars - 3) .. " more\n"
            end
            status.Text = text
        else
            status.Text = "No cars found!\nBuy some cars first."
        end
    end)
    
    -- Button 2: Duplicate
    local btn2 = Instance.new("TextButton")
    btn2.Text = "⚡ DUPLICATE"
    btn2.Size = UDim2.new(1, -40, 0, 35)
    btn2.Position = UDim2.new(0, 20, 0, 185)
    btn2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn2.TextColor3 = Color3.new(1, 1, 1)
    btn2.Font = Enum.Font.GothamBold
    btn2.TextSize = 14
    btn2.Parent = frame
    
    btn2.MouseButton1Click:Connect(function()
        status.Text = "Duplicating...\nStay still!\n\nCheck console."
        btn2.Text = "WORKING..."
        btn2.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local cars = checkInventoryStatic()
            staticDuplicateCars(cars)
            
            task.wait(2)
            
            -- Check results
            local newCars = checkInventoryStatic()
            status.Text = "Complete!\n\nCars before: " .. #cars .. "\nCars after: " .. #newCars
            
            btn2.Text = "DUPLICATE"
            btn2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return gui, status
end

-- ===== STEP 4: SAFE AUTOMATIC DUPLICATION =====
local function safeAutoDuplicate()
    print("\n🤖 SAFE AUTOMATIC DUPLICATION")
    
    -- Step 1: Check current cars
    local currentCars = checkInventoryStatic()
    
    if #currentCars == 0 then
        print("❌ No cars found! Buy cars first.")
        return false
    end
    
    print("Starting with " .. #currentCars .. " cars")
    
    -- Step 2: Try duplication
    local success = staticDuplicateCars(currentCars)
    
    -- Step 3: Check results
    task.wait(3)
    local newCars = checkInventoryStatic()
    
    print("\n" .. string.rep("=", 50))
    print("RESULTS:")
    print("Before: " .. #currentCars .. " cars")
    print("After: " .. #newCars .. " cars")
    
    if #newCars > #currentCars then
        print("🎉 SUCCESS! Gained " .. (#newCars - #currentCars) .. " cars!")
        return true
    else
        print("⚠️ No new cars gained")
        print("Server is rejecting requests.")
        return false
    end
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 70))
print("🚗 STATIC CAR DUPLICATOR")
print(string.rep("=", 70))
print("\n⚠️ IMPORTANT: This script will NOT move your character!")
print("It works from your current position.")

-- Disable movement first
disableMovement()

-- Create UI
task.wait(1)
local gui, status = createStaticUI()

-- Auto-start after 3 seconds
task.wait(3)
status.Text = "Auto-starting in 3... 2... 1..."
task.wait(1)

status.Text = "Running safe duplication...\n\nCheck console for details."
safeAutoDuplicate()

-- Final status
task.wait(2)
status.Text = "Script complete!\n\nCheck your inventory.\nIf no new cars, server has protection."

print("\n" .. string.rep("=", 70))
print("📋 STATIC METHOD COMPLETE")
print(string.rep("=", 70))
print("\nThis script:")
print("1. Does NOT move your character")
print("2. Works from current position")
print("3. Only sends network requests")
print("4. Cannot force movement or teleport")
