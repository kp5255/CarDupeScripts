-- 🔍 PROPER CAR STORAGE ANALYSIS (Fixed)
-- Place ID: 1554960397

print("🔍 PROPER CAR STORAGE ANALYSIS")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== SAFE DATA SCAN =====
local function safePlayerScan()
    print("\n🔬 SAFE PLAYER DATA SCAN")
    
    print("Scanning player: " .. player.Name)
    print("Player has " .. #player:GetChildren() .. " direct children")
    
    -- List all player folders
    local folders = {}
    local values = {}
    
    for _, child in pairs(player:GetChildren()) do
        print("\n📁 " .. child.Name .. " (" .. child.ClassName .. ")")
        
        if child:IsA("Folder") then
            table.insert(folders, child.Name)
            print("  Contains " .. #child:GetChildren() .. " items:")
            
            for _, item in pairs(child:GetChildren()) do
                local safeValue = "N/A"
                pcall(function()
                    if item:IsA("ValueBase") then
                        safeValue = tostring(item.Value)
                    end
                end)
                
                print("    - " .. item.Name .. " (" .. item.ClassName .. ") = " .. safeValue)
                
                -- Check for car names
                if safeValue:find("Bontlay") or safeValue:find("Jegar") or 
                   safeValue:find("Sportler") or safeValue:find("Lavish") or 
                   safeValue:find("Corsaro") then
                    print("      ⚡ CAR FOUND: " .. safeValue)
                end
            end
        elseif child:IsA("ValueBase") then
            table.insert(values, child.Name)
            local safeValue = "N/A"
            pcall(function()
                safeValue = tostring(child.Value)
            end)
            print("  Value: " .. safeValue)
        end
    end
    
    -- Deep scan for StringValues with car names
    print("\n🔍 DEEP SCAN FOR CAR DATA:")
    
    local carDataFound = false
    for _, descendant in pairs(player:GetDescendants()) do
        if descendant:IsA("StringValue") then
            local value = ""
            pcall(function()
                value = descendant.Value
            end)
            
            if value and (value:find("Bontlay") or value:find("Jegar") or 
                          value:find("Sportler") or value:find("Lavish") or 
                          value:find("Corsaro") or value:find("T8") or 
                          value:find("Model")) then
                
                print("✅ CAR DATA FOUND:")
                print("   Path: " .. descendant:GetFullName())
                print("   Value: " .. value)
                carDataFound = true
            end
        end
    end
    
    if not carDataFound then
        print("❌ No car data found in StringValues")
    end
    
    return {Folders = folders, Values = values, FoundCarData = carDataFound}
end

-- ===== SIMPLE REMOTE TEST =====
local function simpleRemoteTest()
    print("\n💰 SIMPLE REMOTE TEST")
    
    -- Just test a few key remotes
    local testRemotes = {
        "BuyCar",
        "PurchaseCar", 
        "AddCar",
        "GiveCar",
        "SaveCar",
        "LoadCar",
        "DuplicateCar",
        "CopyCar"
    }
    
    local testCars = {
        "Bontlay Bontaga",
        "Jegar Model F",
        "Corsaro T8"
    }
    
    for _, remoteName in pairs(testRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if remote then
            print("\nTesting: " .. remoteName .. " (" .. remote.ClassName .. ")")
            
            for _, carName in pairs(testCars) do
                -- Try simple calls
                local attempts = {
                    {carName},
                    {carName, 0},
                    {player, carName}
                }
                
                for i, args in pairs(attempts) do
                    local success, errorMsg = pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(unpack(args))
                        else
                            remote:InvokeServer(unpack(args))
                        end
                    end)
                    
                    if success then
                        print("  ✅ " .. carName .. " - Attempt " .. i)
                    else
                        if errorMsg and not errorMsg:find("Not connected") then
                            print("  ❌ Error: " .. errorMsg:sub(1, 50))
                        end
                    end
                    
                    task.wait(0.1)
                end
            end
        end
    end
end

-- ===== CHECK INVENTORY LOCATIONS =====
local function checkInventoryLocations()
    print("\n📦 CHECKING COMMON INVENTORY LOCATIONS")
    
    local commonLocations = {
        "Inventory",
        "Garage", 
        "Cars",
        "Vehicles",
        "OwnedCars",
        "PlayerData",
        "Data",
        "SaveData",
        "CarStorage"
    }
    
    for _, locationName in pairs(commonLocations) do
        local location = player:FindFirstChild(locationName)
        if location then
            print("\n✅ FOUND: " .. locationName)
            print("   Type: " .. location.ClassName)
            print("   Items: " .. #location:GetChildren())
            
            -- Show first few items
            for i = 1, math.min(5, #location:GetChildren()) do
                local item = location:GetChildren()[i]
                local valueInfo = ""
                
                if item:IsA("ValueBase") then
                    pcall(function()
                        valueInfo = " = " .. tostring(item.Value)
                    end)
                end
                
                print("   " .. i .. ". " .. item.Name .. " (" .. item.ClassName .. ")" .. valueInfo)
            end
        end
    end
end

-- ===== CREATE SIMPLE UI FOR CONTROL =====
local function createControlUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 250)
    frame.Position = UDim2.new(0.5, -150, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🔍 CAR STORAGE ANALYZER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "Click buttons to analyze\nwhere your cars are stored."
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    -- Button 1: Scan Player
    local btn1 = Instance.new("TextButton")
    btn1.Text = "🔍 SCAN PLAYER DATA"
    btn1.Size = UDim2.new(1, -40, 0, 35)
    btn1.Position = UDim2.new(0, 20, 0, 140)
    btn1.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    btn1.TextColor3 = Color3.new(1, 1, 1)
    btn1.Font = Enum.Font.GothamBold
    btn1.TextSize = 14
    btn1.Parent = frame
    
    btn1.MouseButton1Click:Connect(function()
        status.Text = "Scanning player data...\nCheck console (F9) for results."
        task.spawn(function()
            safePlayerScan()
            status.Text = "Scan complete!\nCheck F9 console for details."
        end)
    end)
    
    -- Button 2: Check Inventory
    local btn2 = Instance.new("TextButton")
    btn2.Text = "📦 CHECK INVENTORY"
    btn2.Size = UDim2.new(1, -40, 0, 35)
    btn2.Position = UDim2.new(0, 20, 0, 185)
    btn2.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    btn2.TextColor3 = Color3.new(1, 1, 1)
    btn2.Font = Enum.Font.GothamBold
    btn2.TextSize = 14
    btn2.Parent = frame
    
    btn2.MouseButton1Click:Connect(function()
        status.Text = "Checking inventory locations..."
        task.spawn(function()
            checkInventoryLocations()
            status.Text = "Inventory check complete!\nCheck F9 console."
        end)
    end)
    
    -- Button 3: Test Remotes
    local btn3 = Instance.new("TextButton")
    btn3.Text = "💰 TEST REMOTES"
    btn3.Size = UDim2.new(1, -40, 0, 35)
    btn3.Position = UDim2.new(0, 20, 0, 230)
    btn3.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn3.TextColor3 = Color3.new(1, 1, 1)
    btn3.Font = Enum.Font.GothamBold
    btn3.TextSize = 14
    btn3.Parent = frame
    
    btn3.MouseButton1Click:Connect(function()
        status.Text = "Testing remote events...\nThis may take a moment."
        task.spawn(function()
            simpleRemoteTest()
            status.Text = "Remote test complete!\nCheck F9 console for results."
        end)
    end)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return gui, status
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 60))
print("🔍 PROPER CAR STORAGE ANALYSIS")
print(string.rep("=", 60))
print("\nThis script will help us find:")
print("1. WHERE your cars are stored")
print("2. WHICH remote events work")
print("3. WHAT format the game uses")

-- Create UI
task.wait(1)
local gui, status = createControlUI()

-- Auto-run initial scan
task.wait(3)
status.Text = "Auto-running initial scan...\nCheck F9 console!"

print("\n🚀 AUTO-RUNNING INITIAL SCAN...")
local scanResults = safePlayerScan()

task.wait(2)
checkInventoryLocations()

task.wait(2)
simpleRemoteTest()

-- Final summary
task.wait(2)
print("\n" .. string.rep("=", 60))
print("📋 ANALYSIS COMPLETE")
print(string.rep("=", 60))

if scanResults.FoundCarData then
    print("\n✅ CAR DATA WAS FOUND!")
    print("Now we know WHERE cars are stored.")
    status.Text = "✅ Car data found!\nCheck F9 console for location."
else
    print("\n❌ NO CAR DATA FOUND IN STRINGVALUES")
    print("\nCars might be stored in:")
    print("1. Folder structure (not values)")
    print("2. Remote server (not client)")
    print("3. Custom data format")
    status.Text = "⚠️ No car data found.\nCars might be server-side only."
end

print("\n💡 NEXT STEPS:")
print("1. Use the UI buttons to investigate more")
print("2. Check F9 console for detailed output")
print("3. Look for where NEW cars appear when bought")

-- Monitor for new data
task.spawn(function()
    local lastItemCount = #player:GetChildren()
    
    while true do
        task.wait(5)
        local currentCount = #player:GetChildren()
        
        if currentCount > lastItemCount then
            print("\n🔔 NEW ITEMS ADDED TO PLAYER!")
            print("Count: " .. lastItemCount .. " → " .. currentCount)
            print("New items might be car data!")
            lastItemCount = currentCount
            
            -- Quick scan for new StringValues
            for _, child in pairs(player:GetDescendants()) do
                if child:IsA("StringValue") and child:GetFullName():find("Car") then
                    pcall(function()
                        print("New car value: " .. child.Name .. " = " .. child.Value)
                    end)
                end
            end
        end
    end
end)
