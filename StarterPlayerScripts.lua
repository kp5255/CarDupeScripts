-- 🎯 FIND CAR STORAGE LOCATION
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CAR STORAGE FINDER")
print("=" .. string.rep("=", 50))
print("\n📊 You have 54 cars - Let's find where they're stored!")

-- ===== DEEP PLAYER DATA SCAN =====
local function deepScanPlayerData()
    print("\n🔍 Scanning ALL player data...")
    
    local foundData = {}
    
    -- Check all Value objects
    for _, obj in pairs(player:GetDescendants()) do
        if obj:IsA("ValueBase") then  -- StringValue, IntValue, NumberValue, BoolValue
            local success, value = pcall(function()
                return obj.Value
            end)
            
            if success then
                local valueStr = tostring(value)
                
                -- Look for patterns that might indicate car storage
                if #valueStr > 10 then
                    -- Check for JSON or data structures
                    if valueStr:find("{") or valueStr:find("[") then
                        table.insert(foundData, {
                            Type = obj.ClassName,
                            Path = obj:GetFullName(),
                            Value = valueStr:sub(1, 100) .. (#valueStr > 100 and "..." or "")
                        })
                    -- Check for numeric IDs or hashes
                    elseif valueStr:match("^%d+$") and #valueStr > 5 then
                        table.insert(foundData, {
                            Type = obj.ClassName,
                            Path = obj:GetFullName(),
                            Value = "NUMERIC_ID: " .. valueStr
                        })
                    -- Check for UUIDs or hashes
                    elseif valueStr:match("^%x+$") and #valueStr > 20 then
                        table.insert(foundData, {
                            Type = obj.ClassName,
                            Path = obj:GetFullName(),
                            Value = "HASH: " .. valueStr:sub(1, 20) .. "..."
                        })
                    end
                end
            end
        end
    end
    
    -- Check Folders
    for _, folder in pairs(player:GetChildren()) do
        if folder:IsA("Folder") then
            print("📁 Found folder: " .. folder.Name .. " (" .. #folder:GetChildren() .. " items)")
            
            -- Check folder contents
            local carCount = 0
            for _, item in pairs(folder:GetChildren()) do
                if item:IsA("StringValue") or item:IsA("IntValue") then
                    carCount = carCount + 1
                end
            end
            
            if carCount > 0 then
                print("   🚗 Potential car storage: " .. carCount .. " value objects")
            end
        end
    end
    
    return foundData
end

-- ===== MONITOR DATA CHANGES =====
local function monitorForNewCars()
    print("\n👁️ Monitoring for new car additions...")
    print("💡 Buy or receive a NEW car while this runs...")
    
    -- Take snapshot of current data
    local snapshot = {}
    for _, obj in pairs(player:GetDescendants()) do
        if obj:IsA("ValueBase") then
            local success, value = pcall(function()
                return obj.Value
            end)
            if success then
                snapshot[obj:GetFullName()] = {
                    Value = value,
                    Type = obj.ClassName
                }
            end
        end
    end
    
    print("📸 Snapshot taken (" .. #snapshot .. " values)")
    print("⏳ Waiting 30 seconds...")
    
    for i = 1, 30 do
        if i % 10 == 0 then
            print("   " .. i .. " seconds elapsed...")
        end
        task.wait(1)
    end
    
    -- Check for changes
    print("\n🔍 Comparing for changes...")
    local changes = {}
    
    for _, obj in pairs(player:GetDescendants()) do
        if obj:IsA("ValueBase") then
            local path = obj:GetFullName()
            local success, newValue = pcall(function()
                return obj.Value
            end)
            
            if success then
                local oldData = snapshot[path]
                
                if not oldData then
                    -- NEW value added
                    table.insert(changes, {
                        Type = "NEW",
                        Path = path,
                        Value = newValue
                    })
                elseif tostring(oldData.Value) ~= tostring(newValue) then
                    -- Value CHANGED
                    table.insert(changes, {
                        Type = "CHANGED",
                        Path = path,
                        OldValue = oldData.Value,
                        NewValue = newValue
                    })
                end
            end
        end
    end
    
    -- Check for deleted values
    for path, oldData in pairs(snapshot) do
        local found = false
        for _, obj in pairs(player:GetDescendants()) do
            if obj:GetFullName() == path then
                found = true
                break
            end
        end
        
        if not found then
            table.insert(changes, {
                Type = "DELETED",
                Path = path,
                OldValue = oldData.Value
            })
        end
    end
    
    if #changes > 0 then
        print("\n🎯 CHANGES DETECTED:")
        for _, change in pairs(changes) do
            if change.Type == "NEW" then
                print("➕ NEW: " .. change.Path)
                print("   Value: " .. tostring(change.Value):sub(1, 50))
            elseif change.Type == "CHANGED" then
                print("📝 CHANGED: " .. change.Path)
                print("   Old: " .. tostring(change.OldValue):sub(1, 30))
                print("   New: " .. tostring(change.NewValue):sub(1, 30))
            end
        end
    else
        print("❌ No changes detected")
    end
    
    return changes
end

-- ===== ATTEMPT TO READ CAR DATA =====
local function attemptToReadCarData()
    print("\n📖 Attempting to read car data...")
    
    -- Look for JSON or serialized data
    local potentialData = {}
    
    for _, obj in pairs(player:GetDescendants()) do
        if obj:IsA("StringValue") then
            local success, value = pcall(function()
                return obj.Value
            end)
            
            if success and type(value) == "string" and #value > 100 then
                -- Check if it looks like JSON
                if value:find("{") and value:find("}") then
                    table.insert(potentialData, {
                        Path = obj:GetFullName(),
                        Value = value:sub(1, 200) .. "...",
                        Length = #value
                    })
                end
            end
        end
    end
    
    if #potentialData > 0 then
        print("\n🎯 POTENTIAL CAR DATA FOUND:")
        for i, data in ipairs(potentialData) do
            print(i .. ". " .. data.Path)
            print("   Length: " .. data.Length .. " characters")
            print("   Preview: " .. data.Value)
        end
    else
        print("❌ No JSON-like data found")
    end
    
    return potentialData
end

-- ===== SEARCH FOR GARAGE UI =====
local function findGarageUI()
    print("\n🏠 Looking for garage UI...")
    
    local guiFound = false
    
    -- Check PlayerGui
    if player:FindFirstChild("PlayerGui") then
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            local guiName = gui.Name:lower()
            if guiName:find("garage") or guiName:find("inventory") or 
               guiName:find("cars") or guiName:find("vehicle") then
                print("✅ Found garage UI: " .. gui.Name)
                guiFound = true
                
                -- Look for car list
                for _, obj in pairs(gui:GetDescendants()) do
                    if obj:IsA("ScrollingFrame") or obj:IsA("Frame") then
                        if #obj:GetChildren() > 5 then
                            print("   📊 Potential car list: " .. obj:GetFullName())
                        end
                    end
                end
            end
        end
    end
    
    if not guiFound then
        print("❌ No obvious garage UI found")
    end
    
    return guiFound
end

-- ===== CREATE DISCOVERY UI =====
local function createDiscoveryUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarDiscovery"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 350, 0, 400)
    main.Position = UDim2.new(0.5, -175, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎯 FIND YOUR 54 CARS"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = main
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -40)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "You have 54 cars. Let's find where they're stored!"
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 0, 10)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = content
    
    -- Buttons
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🔍 SCAN DATA"
    scanBtn.Size = UDim2.new(1, -20, 0, 35)
    scanBtn.Position = UDim2.new(0, 10, 0, 70)
    scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 14
    scanBtn.Parent = content
    
    local monitorBtn = Instance.new("TextButton")
    monitorBtn.Text = "👁️ MONITOR CHANGES"
    monitorBtn.Size = UDim2.new(1, -20, 0, 35)
    monitorBtn.Position = UDim2.new(0, 10, 0, 115)
    monitorBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    monitorBtn.TextColor3 = Color3.new(1, 1, 1)
    monitorBtn.Font = Enum.Font.GothamBold
    monitorBtn.TextSize = 14
    monitorBtn.Parent = content
    
    local readBtn = Instance.new("TextButton")
    readBtn.Text = "📖 READ CAR DATA"
    readBtn.Size = UDim2.new(1, -20, 0, 35)
    readBtn.Position = UDim2.new(0, 10, 0, 160)
    readBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    readBtn.TextColor3 = Color3.new(1, 1, 1)
    readBtn.Font = Enum.Font.GothamBold
    readBtn.TextSize = 14
    readBtn.Parent = content
    
    local garageBtn = Instance.new("TextButton")
    garageBtn.Text = "🏠 FIND GARAGE"
    garageBtn.Size = UDim2.new(1, -20, 0, 35)
    garageBtn.Position = UDim2.new(0, 10, 0, 205)
    garageBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    garageBtn.TextColor3 = Color3.new(1, 1, 1)
    garageBtn.Font = Enum.Font.GothamBold
    garageBtn.TextSize = 14
    garageBtn.Parent = content
    
    -- Results display
    local results = Instance.new("ScrollingFrame")
    results.Size = UDim2.new(1, -20, 0, 120)
    results.Position = UDim2.new(0, 10, 1, -140)
    results.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    results.BorderSizePixel = 0
    results.ScrollBarThickness = 6
    results.Parent = content
    
    -- Add corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    addCorner(main)
    addCorner(title)
    addCorner(status)
    addCorner(scanBtn)
    addCorner(monitorBtn)
    addCorner(readBtn)
    addCorner(garageBtn)
    addCorner(results)
    
    -- Functions
    local function updateResults(text, color)
        results:ClearAllChildren()
        
        local label = Instance.new("TextLabel")
        label.Text = text
        label.Size = UDim2.new(1, -10, 1, -10)
        label.Position = UDim2.new(0, 5, 0, 5)
        label.BackgroundTransparency = 1
        label.TextColor3 = color or Color3.new(1, 1, 1)
        label.Font = Enum.Font.Code
        label.TextSize = 10
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Parent = results
    end
    
    -- Button actions
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "SCANNING..."
        scanBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Scanning player data for car storage..."
        
        task.spawn(function()
            local data = deepScanPlayerData()
            
            if #data > 0 then
                local resultText = "📊 FOUND " .. #data .. " POTENTIAL CAR DATA LOCATIONS:\n\n"
                
                for i, item in ipairs(data) do
                    if i <= 10 then  -- Limit display
                        resultText = resultText .. i .. ". " .. item.Path .. "\n"
                        resultText = resultText .. "   " .. item.Value .. "\n\n"
                    end
                end
                
                updateResults(resultText, Color3.fromRGB(0, 255, 150))
                status.Text = "✅ Found " .. #data .. " potential data locations"
            else
                updateResults("❌ No structured data found\nCars might be in simple StringValues", Color3.fromRGB(255, 100, 100))
                status.Text = "❌ No structured data found"
            end
            
            scanBtn.Text = "🔍 SCAN DATA"
            scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        end)
    end)
    
    monitorBtn.MouseButton1Click:Connect(function()
        monitorBtn.Text = "MONITORING..."
        monitorBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Monitoring for 30 seconds...\nBuy/Get a NEW car now!"
        updateResults("Monitoring started...\nPerform car actions in game", Color3.fromRGB(255, 200, 100))
        
        task.spawn(function()
            local changes = monitorForNewCars()
            
            if #changes > 0 then
                local resultText = "🎯 " .. #changes .. " CHANGES DETECTED:\n\n"
                
                for i, change in ipairs(changes) do
                    if i <= 5 then
                        resultText = resultText .. change.Type .. ": " .. change.Path .. "\n"
                    end
                end
                
                updateResults(resultText, Color3.fromRGB(0, 255, 0))
                status.Text = "✅ Found changes! Check console for details"
            else
                updateResults("❌ No changes detected\nTry buying/selling cars", Color3.fromRGB(255, 100, 100))
                status.Text = "❌ No changes detected"
            end
            
            monitorBtn.Text = "👁️ MONITOR CHANGES"
            monitorBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end)
    end)
    
    readBtn.MouseButton1Click:Connect(function()
        readBtn.Text = "READING..."
        readBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Looking for car data in StringValues..."
        
        task.spawn(function()
            local data = attemptToReadCarData()
            
            if #data > 0 then
                local resultText = "📖 FOUND " .. #data .. " DATA STRINGS:\n\n"
                
                for i, item in ipairs(data) do
                    resultText = resultText .. i .. ". " .. item.Path .. "\n"
                    resultText = resultText .. "   Size: " .. item.Length .. " chars\n"
                end
                
                updateResults(resultText, Color3.fromRGB(200, 150, 255))
                status.Text = "✅ Found potential car data"
            else
                updateResults("❌ No readable data found\nData might be encrypted", Color3.fromRGB(255, 100, 100))
                status.Text = "❌ No readable data found"
            end
            
            readBtn.Text = "📖 READ CAR DATA"
            readBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
        end)
    end)
    
    garageBtn.MouseButton1Click:Connect(function()
        garageBtn.Text = "SEARCHING..."
        garageBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Looking for garage UI..."
        
        task.spawn(function()
            local found = findGarageUI()
            
            if found then
                updateResults("✅ Garage UI found!\nCheck console for location", Color3.fromRGB(0, 255, 0))
                status.Text = "✅ Garage UI found"
            else
                updateResults("❌ No garage UI found\nCheck for hidden GUIs", Color3.fromRGB(255, 100, 100))
                status.Text = "❌ No garage UI found"
            end
            
            garageBtn.Text = "🏠 FIND GARAGE"
            garageBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        end)
    end)
    
    -- Initial display
    updateResults("Click buttons to find where your 54 cars are stored", Color3.fromRGB(150, 150, 150))
    
    return gui
end

-- ===== AUTO-RUN =====
print("\n🚀 Starting discovery process...")

-- Create UI first
local ui = createDiscoveryUI()

print("\n📱 UI Created!")
print("\n💡 HOW TO FIND YOUR 54 CARS:")
print("1. Click SCAN DATA - Find where data is stored")
print("2. Click MONITOR CHANGES - Buy a NEW car while this runs")
print("3. Click READ CAR DATA - Look for JSON/encrypted data")
print("4. Click FIND GARAGE - Locate the garage UI")

print("\n🎯 The GOAL is to find:")
print("• WHERE your 54 cars are stored locally")
print("• HOW the game tracks your inventory")
print("• WHAT format it uses (IDs, names, JSON, etc.)")

print("\n🔍 Once we find the storage location,")
print("we can figure out how to add more cars!")
