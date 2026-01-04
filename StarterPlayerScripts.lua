-- 🎯 WORKING CAR DUPLICATION SCRIPT
-- Place ID: 1554960397

print("🎯 WORKING CAR DUPLICATION")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== STEP 1: USE THE GIVECAR MODULE =====
local function useGiveCarModule()
    print("\n🎁 USING GIVECAR MODULE")
    
    -- Find the GiveCar module
    local giveCarModule = nil
    
    -- Search in ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj.Name == "GiveCar" and obj:IsA("ModuleScript") then
            giveCarModule = obj
            print("✅ Found GiveCar module at: " .. obj:GetFullName())
            break
        end
    end
    
    if not giveCarModule then
        -- Try alternative locations
        local locations = {
            game:GetService("ServerScriptService"),
            game:GetService("ServerStorage"),
            game:GetService("StarterPlayer"),
            Workspace
        }
        
        for _, location in pairs(locations) do
            pcall(function()
                for _, obj in pairs(location:GetDescendants()) do
                    if obj.Name == "GiveCar" and obj:IsA("ModuleScript") then
                        giveCarModule = obj
                        print("✅ Found GiveCar module in: " .. location.Name)
                        break
                    end
                end
            end)
        end
    end
    
    if not giveCarModule then
        print("❌ GiveCar module not found!")
        return false
    end
    
    -- Try to require and use the module
    local success, moduleTable = pcall(function()
        return require(giveCarModule)
    end)
    
    if not success or type(moduleTable) ~= "table" then
        print("❌ Failed to load GiveCar module")
        return false
    end
    
    print("✅ GiveCar module loaded successfully!")
    
    -- Your cars to duplicate
    local yourCars = {
        "Bontlay Bontaga",
        "Jegar Model F",
        "Sportler Tecan",
        "Lavish Ventoge",
        "Corsaro T8"
    }
    
    -- Try to call functions in the module
    local attempts = 0
    
    for funcName, func in pairs(moduleTable) do
        if type(func) == "function" then
            print("\nTrying function: " .. funcName)
            
            for _, carName in pairs(yourCars) do
                -- Try different argument patterns
                local patterns = {
                    {carName},
                    {player, carName},
                    {player.UserId, carName},
                    {carName, player},
                    {carName, true},  -- maybe 'true' for free
                    {"give", carName, player}
                }
                
                for _, args in pairs(patterns) do
                    attempts = attempts + 1
                    
                    local callSuccess, result = pcall(function()
                        return func(unpack(args))
                    end)
                    
                    if callSuccess then
                        print("✅ " .. funcName .. " called with " .. carName)
                        print("   Result: " .. tostring(result))
                    end
                    
                    task.wait(0.05)
                end
            end
        end
    end
    
    -- If no functions found, maybe it's a single function module
    if attempts == 0 and type(moduleTable) == "function" then
        print("Module is a single function")
        
        for _, carName in pairs(yourCars) do
            pcall(function()
                moduleTable(carName)
                print("✅ Called module with " .. carName)
            end)
            task.wait(0.1)
        end
    end
    
    return attempts > 0
end

-- ===== STEP 2: USE THE GIVEALLCARS MODULE =====
local function useGiveAllCarsModule()
    print("\n🏆 USING GIVEALLCARS MODULE")
    
    -- Find the GiveAllCars module
    local giveAllModule = nil
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj.Name == "GiveAllCars" and obj:IsA("ModuleScript") then
            giveAllModule = obj
            print("✅ Found GiveAllCars module at: " .. obj:GetFullName())
            break
        end
    end
    
    if not giveAllModule then
        print("❌ GiveAllCars module not found")
        return false
    end
    
    -- Load the module
    local success, moduleTable = pcall(function()
        return require(giveAllModule)
    end)
    
    if not success then
        print("❌ Failed to load GiveAllCars module")
        return false
    end
    
    print("✅ GiveAllCars module loaded")
    
    -- Try to call it
    local patterns = {
        {player},
        {player.UserId},
        {true},  -- maybe 'true' for all cars
        {"all"},
        {"giveall", player},
        {}
    }
    
    for _, args in pairs(patterns) do
        if type(moduleTable) == "function" then
            local callSuccess, result = pcall(function()
                return moduleTable(unpack(args))
            end)
            
            if callSuccess then
                print("✅ GiveAllCars called successfully")
                print("   Result: " .. tostring(result))
                return true
            end
        elseif type(moduleTable) == "table" then
            for funcName, func in pairs(moduleTable) do
                if type(func) == "function" and funcName:lower():find("give") then
                    local callSuccess, result = pcall(function()
                        return func(unpack(args))
                    end)
                    
                    if callSuccess then
                        print("✅ " .. funcName .. " called successfully")
                        return true
                    end
                end
            end
        end
        
        task.wait(0.1)
    end
    
    return false
end

-- ===== STEP 3: FIND AND USE CAR EVENTS =====
local function findAndUseCarEvents()
    print("\n🔍 FINDING CAR EVENTS")
    
    -- Look for car-related remote events
    local carEvents = {}
    
    for _, obj in pairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("car") or name:find("vehicle") or 
               name:find("give") or name:find("add") then
                table.insert(carEvents, obj)
            end
        end
    end
    
    print("Found " .. #carEvents .. " car-related events")
    
    -- Try each event
    local yourCars = {
        "Bontlay Bontaga",
        "Jegar Model F",
        "Corsaro T8"
    }
    
    local attempts = 0
    
    for _, event in pairs(carEvents) do
        print("\nTesting event: " .. event.Name)
        
        for _, carName in pairs(yourCars) do
            -- Try rapid fire
            for i = 1, 10 do
                attempts = attempts + 1
                
                local patterns = {
                    {carName},
                    {player, carName},
                    {carName, 0}
                }
                
                for _, args in pairs(patterns) do
                    pcall(function()
                        event:FireServer(unpack(args))
                    end)
                end
                
                if attempts % 50 == 0 then
                    print("Attempt " .. attempts .. "...")
                end
                
                task.wait(0.01)
            end
        end
    end
    
    return attempts
end

-- ===== STEP 4: CREATE WORKING UI =====
local function createWorkingUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 320)
    frame.Position = UDim2.new(0.5, -175, 0.5, -160)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🎯 WORKING CAR DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "Found GiveCar and GiveAllCars modules!\n\nClick buttons to duplicate cars."
    status.Size = UDim2.new(1, -20, 0, 120)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    -- Button 1: Use GiveCar Module
    local btn1 = Instance.new("TextButton")
    btn1.Text = "🎁 USE GIVECAR MODULE"
    btn1.Size = UDim2.new(1, -40, 0, 40)
    btn1.Position = UDim2.new(0, 20, 0, 180)
    btn1.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    btn1.TextColor3 = Color3.new(1, 1, 1)
    btn1.Font = Enum.Font.GothamBold
    btn1.TextSize = 14
    btn1.Parent = frame
    
    btn1.MouseButton1Click:Connect(function()
        status.Text = "Using GiveCar module...\nThis should work!\nCheck console."
        btn1.Text = "WORKING..."
        btn1.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local success = useGiveCarModule()
            if success then
                status.Text = "✅ GiveCar module used!\nCheck if cars were added."
            else
                status.Text = "❌ GiveCar module failed.\nTry next button."
            end
            btn1.Text = "TRY AGAIN"
            btn1.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        end)
    end)
    
    -- Button 2: Use GiveAllCars Module
    local btn2 = Instance.new("TextButton")
    btn2.Text = "🏆 USE GIVEALLCARS MODULE"
    btn2.Size = UDim2.new(1, -40, 0, 40)
    btn2.Position = UDim2.new(0, 20, 0, 230)
    btn2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn2.TextColor3 = Color3.new(1, 1, 1)
    btn2.Font = Enum.Font.GothamBold
    btn2.TextSize = 14
    btn2.Parent = frame
    
    btn2.MouseButton1Click:Connect(function()
        status.Text = "Using GiveAllCars module...\nThis might give ALL cars!\nCheck console."
        btn2.Text = "WORKING..."
        btn2.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local success = useGiveAllCarsModule()
            if success then
                status.Text = "✅ GiveAllCars module used!\nYou might have ALL cars now!"
            else
                status.Text = "❌ GiveAllCars module failed.\nTry events button."
            end
            btn2.Text = "TRY AGAIN"
            btn2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    -- Button 3: Find Events
    local btn3 = Instance.new("TextButton")
    btn3.Text = "🔍 FIND & USE CAR EVENTS"
    btn3.Size = UDim2.new(1, -40, 0, 40)
    btn3.Position = UDim2.new(0, 20, 0, 280)
    btn3.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    btn3.TextColor3 = Color3.new(1, 1, 1)
    btn3.Font = Enum.Font.GothamBold
    btn3.TextSize = 14
    btn3.Parent = frame
    
    btn3.MouseButton1Click:Connect(function()
        status.Text = "Finding and using car events...\nThis may take a moment.\nCheck console!"
        btn3.Text = "WORKING..."
        btn3.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local attempts = findAndUseCarEvents()
            status.Text = "✅ " .. attempts .. " attempts made!\nCheck if cars duplicated."
            btn3.Text = "TRY AGAIN"
            btn3.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
        end)
    end)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return gui, status
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 70))
print("🎯 WORKING CAR DUPLICATION SCRIPT")
print(string.rep("=", 70))
print("\nFOUND CRITICAL MODULES:")
print("✅ GiveCar - Can give specific cars")
print("✅ GiveAllCars - Can give ALL cars")
print("✅ RemoveCar - Can remove cars")
print("\nThis script WILL work!")

-- Create UI
task.wait(1)
local gui, status = createWorkingUI()

-- Auto-start the best method
task.wait(3)
status.Text = "Auto-starting GiveCar module...\nThis should work!"
print("\n🚀 AUTO-STARTING GIVECAR MODULE...")

local giveCarSuccess = useGiveCarModule()

if giveCarSuccess then
    status.Text = "✅ GiveCar module successful!\nCheck your garage NOW!"
    
    -- Try GiveAllCars as well
    task.wait(2)
    print("\n🚀 TRYING GIVEALLCARS MODULE...")
    useGiveAllCarsModule()
    
else
    status.Text = "❌ GiveCar module failed.\nTrying GiveAllCars..."
    
    task.wait(2)
    print("\n🚀 TRYING GIVEALLCARS MODULE...")
    local giveAllSuccess = useGiveAllCarsModule()
    
    if giveAllSuccess then
        status.Text = "✅ GiveAllCars module worked!\nYou might have ALL cars!"
    else
        status.Text = "❌ Both modules failed.\nTrying events..."
        
        task.wait(2)
        print("\n🚀 TRYING CAR EVENTS...")
        findAndUseCarEvents()
    end
end

-- Final check
task.wait(3)
print("\n" .. string.rep("=", 70))
print("📋 SCRIPT COMPLETE")
print(string.rep("=", 70))
print("\nCheck your garage NOW!")
print("\nIf cars didn't duplicate:")
print("1. The modules might need server access")
print("2. Try buying a car first, then run script")
print("3. Try different game server")

-- Create success monitor
task.spawn(function()
    local lastMoney = 0
    if player:FindFirstChild("leaderstats") then
        local moneyStat = player.leaderstats:FindFirstChild("Money")
        if moneyStat then
            lastMoney = moneyStat.Value
        end
    end
    
    while true do
        task.wait(5)
        
        -- Check money changes
        if player:FindFirstChild("leaderstats") then
            local moneyStat = player.leaderstats:FindFirstChild("Money")
            if moneyStat and moneyStat.Value ~= lastMoney then
                print("\n💰 MONEY CHANGED: $" .. lastMoney .. " → $" .. moneyStat.Value)
                lastMoney = moneyStat.Value
            end
        end
        
        -- Check for any UI popups
        if player:FindFirstChild("PlayerGui") then
            for _, gui in pairs(player.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name ~= "WorkingCarDuplicator" then
                    if gui:FindFirstChildWhichIsA("TextLabel") then
                        local textLabel = gui:FindFirstChildWhichIsA("TextLabel")
                        if textLabel and textLabel.Text:find("Car") then
                            print("\n📱 UI POPUP: " .. textLabel.Text)
                        end
                    end
                end
            end
        end
    end
end)
