-- 🎯 SERVER-SIDE CAR DUPLICATION ATTEMPT
-- Place ID: 1554960397

print("🎯 SERVER-SIDE CAR DUPLICATION")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== STEP 1: CHECK FOR MODULE-BASED STORAGE =====
local function checkModuleStorage()
    print("\n📦 CHECKING MODULE-BASED STORAGE")
    
    -- Look for car-related modules
    local carModules = {}
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local name = obj.Name:lower()
            if name:find("car") or name:find("vehicle") or 
               name:find("garage") or name:find("inventory") or
               name:find("data") or name:find("save") then
                table.insert(carModules, obj)
            end
        end
    end
    
    print("Found " .. #carModules .. " car-related modules")
    
    -- Try to require and check them
    for _, module in pairs(carModules) do
        local success, moduleTable = pcall(function()
            return require(module)
        end)
        
        if success and type(moduleTable) == "table" then
            print("\nModule: " .. module.Name)
            
            -- Look for car data functions
            for key, value in pairs(moduleTable) do
                if type(value) == "function" then
                    -- Try to call with player
                    pcall(function()
                        local result = value(player)
                        if result and (type(result) == "table" or type(result) == "string") then
                            print("  Function " .. key .. " returned data")
                        end
                    end)
                elseif type(value) == "table" then
                    -- Check if it contains car data
                    for k, v in pairs(value) do
                        if type(v) == "string" and (v:find("Bontlay") or v:find("Corsaro")) then
                            print("  Found car in table: " .. v)
                        end
                    end
                end
            end
        end
    end
end

-- ===== STEP 2: ATTEMPT SERVER-SIDE DUPLICATION =====
local function attemptServerSideDuplication()
    print("\n⚡ ATTEMPTING SERVER-SIDE DUPLICATION")
    
    -- Since cars aren't client-side, we need to trigger server actions
    
    -- Method 1: Achievement/Challenge completion
    print("\n[Method 1] Achievement triggers...")
    local achievementEvents = {
        "CompleteChallenge",
        "UnlockAchievement",
        "EarnReward",
        "GetPrize"
    }
    
    for _, eventName in pairs(achievementEvents) do
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if event then
            for i = 1, 3 do
                pcall(function()
                    event:FireServer("CarDuplication", "Bontlay Bontaga")
                    print("✅ Triggered " .. eventName .. " attempt " .. i)
                end)
                task.wait(0.1)
            end
        end
    end
    
    -- Method 2: Data save/load manipulation
    print("\n[Method 2] Data manipulation...")
    local dataEvents = {
        "SaveGame",
        "LoadGame", 
        "UpdateData",
        "SetPlayerData"
    }
    
    for _, eventName in pairs(dataEvents) do
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if event then
            -- Try to send fake save data with extra cars
            local fakeData = {
                Cars = {"Bontlay Bontaga", "Jegar Model F", "Corsaro T8"},
                ExtraCars = {"Bontlay Bontaga", "Bontlay Bontaga", "Bontlay Bontaga"}
            }
            
            pcall(function()
                event:FireServer(fakeData)
                print("✅ Sent fake data to " .. eventName)
            end)
        end
    end
    
    -- Method 3: Direct purchase events (most likely to work)
    print("\n[Method 3] Direct purchase events...")
    
    -- Get ALL remote events
    local allRemotes = {}
    for _, obj in pairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") then
            table.insert(allRemotes, obj)
        end
    end
    
    -- Also check for RemoteFunctions
    for _, obj in pairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteFunction") then
            table.insert(allRemotes, obj)
        end
    end
    
    print("Testing " .. #allRemotes .. " remote objects")
    
    local testCars = {
        "Bontlay Bontaga",
        "Jegar Model F",
        "Corsaro T8",
        "Lavish Ventoge",
        "Sportler Tecan"
    }
    
    local attempts = 0
    local successfulEvents = {}
    
    for _, remote in pairs(allRemotes) do
        for _, carName in pairs(testCars) do
            -- Try different argument patterns
            local patterns = {
                {carName},
                {carName, 0},
                {player, carName},
                {"buy", carName},
                {Vehicle = carName, Price = 0}
            }
            
            for _, args in pairs(patterns) do
                attempts = attempts + 1
                
                local success, errorMsg = pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(unpack(args))
                    else
                        remote:InvokeServer(unpack(args))
                    end
                end)
                
                if success then
                    if not successfulEvents[remote.Name] then
                        successfulEvents[remote.Name] = 0
                    end
                    successfulEvents[remote.Name] = successfulEvents[remote.Name] + 1
                    
                    if attempts % 20 == 0 then
                        print("Attempt " .. attempts .. " - " .. remote.Name .. " accepted")
                    end
                end
                
                task.wait(0.02)
            end
        end
    end
    
    print("\n📊 RESULTS:")
    print("Total attempts: " .. attempts)
    print("Successful events: " .. #(successfulEvents))
    
    if next(successfulEvents) then
        print("\nEvents that accepted calls:")
        for eventName, count in pairs(successfulEvents) do
            print("  " .. eventName .. " (" .. count .. " calls)")
        end
    end
    
    return attempts
end

-- ===== STEP 3: CHECK FOR VISIBLE CHANGES =====
local function checkForChanges()
    print("\n🔍 CHECKING FOR VISIBLE CHANGES")
    
    -- Check money (might change if purchases happen)
    if player:FindFirstChild("leaderstats") then
        local moneyStat = player.leaderstats:FindFirstChild("Money")
        if moneyStat then
            print("Current money: $" .. moneyStat.Value)
        end
    end
    
    -- Check if any new UI appears
    if player:FindFirstChild("PlayerGui") then
        local screenGuis = 0
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                screenGuis = screenGuis + 1
            end
        end
        print("ScreenGuis in PlayerGui: " .. screenGuis)
    end
    
    -- Listen for any server messages
    for _, remote in pairs(ReplicatedStorage:GetChildren()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote.OnClientEvent:Connect(function(...)
                    local args = {...}
                    local argsStr = ""
                    for i, arg in ipairs(args) do
                        if type(arg) == "string" and (arg:find("Car") or arg:find("Success") or arg:find("Bought")) then
                            argsStr = argsStr .. tostring(arg) .. " "
                        end
                    end
                    if #argsStr > 0 then
                        print("\n📨 Server message from " .. remote.Name .. ": " .. argsStr)
                    end
                end)
                print("Listening to " .. remote.Name)
            end)
        end
    end
end

-- ===== STEP 4: CREATE SIMPLE TEST UI =====
local function createTestUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 280)
    frame.Position = UDim2.new(0.5, -160, 0.5, -140)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🎯 SERVER-SIDE DUPLICATION"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "Cars are stored SERVER-SIDE.\nWe need to trigger server actions.\n\nClick buttons below to try."
    status.Size = UDim2.new(1, -20, 0, 100)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    -- Button 1: Check Modules
    local btn1 = Instance.new("TextButton")
    btn1.Text = "📦 CHECK MODULES"
    btn1.Size = UDim2.new(1, -40, 0, 35)
    btn1.Position = UDim2.new(0, 20, 0, 160)
    btn1.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    btn1.TextColor3 = Color3.new(1, 1, 1)
    btn1.Font = Enum.Font.GothamBold
    btn1.TextSize = 14
    btn1.Parent = frame
    
    btn1.MouseButton1Click:Connect(function()
        status.Text = "Checking module storage...\nCheck F9 console."
        task.spawn(function()
            checkModuleStorage()
            status.Text = "Module check complete.\nCheck F9 for results."
        end)
    end)
    
    -- Button 2: Attempt Duplication
    local btn2 = Instance.new("TextButton")
    btn2.Text = "⚡ TRY DUPLICATION"
    btn2.Size = UDim2.new(1, -40, 0, 35)
    btn2.Position = UDim2.new(0, 20, 0, 205)
    btn2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn2.TextColor3 = Color3.new(1, 1, 1)
    btn2.Font = Enum.Font.GothamBold
    btn2.TextSize = 14
    btn2.Parent = frame
    
    btn2.MouseButton1Click:Connect(function()
        status.Text = "Attempting duplication...\nThis may take 10-15 seconds.\nCheck F9 console!"
        btn2.Text = "WORKING..."
        btn2.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local attempts = attemptServerSideDuplication()
            task.wait(2)
            checkForChanges()
            
            status.Text = "Complete!\n\nAttempts: " .. attempts .. "\nCheck if cars duplicated."
            btn2.Text = "TRY AGAIN"
            btn2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    -- Button 3: Monitor
    local btn3 = Instance.new("TextButton")
    btn3.Text = "👂 MONITOR CHANGES"
    btn3.Size = UDim2.new(1, -40, 0, 35)
    btn3.Position = UDim2.new(0, 20, 0, 250)
    btn3.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    btn3.TextColor3 = Color3.new(1, 1, 1)
    btn3.Font = Enum.Font.GothamBold
    btn3.TextSize = 14
    btn3.Parent = frame
    
    btn3.MouseButton1Click:Connect(function()
        status.Text = "Monitoring for changes...\nWill alert in F9 console."
        task.spawn(function()
            checkForChanges()
            status.Text = "Monitoring active!\nCheck F9 for any server messages."
        end)
    end)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return gui, status
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 70))
print("🎯 SERVER-SIDE CAR DUPLICATION ATTEMPT")
print(string.rep("=", 70))
print("\nKEY FINDING: Cars are NOT stored client-side!")
print("They are stored SERVER-SIDE.")
print("\nThis means we need to:")
print("1. Trigger server actions")
print("2. Manipulate server data")
print("3. Exploit server validation")

-- Create UI
task.wait(1)
local gui, status = createTestUI()

-- Auto-run
task.wait(3)
status.Text = "Auto-starting duplication attempt...\nCheck F9 console!"

print("\n🚀 AUTO-STARTING DUPLICATION ATTEMPT...")
local attempts = attemptServerSideDuplication()

task.wait(2)
checkForChanges()

-- Final analysis
print("\n" .. string.rep("=", 70))
print("📊 FINAL ANALYSIS")
print(string.rep("=", 70))
print("\nAttempts made: " .. attempts)
print("\nIf no cars duplicated:")
print("1. Server has strong validation")
print("2. All requests are being rejected")
print("3. Game is properly secured")
print("\n💡 Last resorts:")
print("• Try buying a NEW car, then immediately run script")
print("• Try different game servers")
print("• Look for game updates/patches")
