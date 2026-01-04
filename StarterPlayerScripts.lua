-- 🎯 SIMPLE CAR STORAGE FINDER
local Players = game:GetService("Players")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 FIND YOUR 54 CARS")
print("=" .. string.rep("=", 50))

-- ===== SIMPLE SCAN =====
local function simpleScan()
    print("\n🔍 Simple scan starting...")
    
    -- Check all player children
    for _, child in pairs(player:GetChildren()) do
        print("📁 " .. child.Name .. " (" .. child.ClassName .. ")")
        
        if child:IsA("Folder") then
            print("   Contains " .. #child:GetChildren() .. " items")
            
            -- Check contents
            local stringValues = 0
            for _, item in pairs(child:GetChildren()) do
                if item:IsA("StringValue") or item:IsA("IntValue") then
                    stringValues = stringValues + 1
                end
            end
            
            if stringValues > 0 then
                print("   🚗 Found " .. stringValues .. " value objects (possible cars)")
            end
        end
    end
end

-- ===== CHECK VALUES =====
local function checkValues()
    print("\n📊 Checking value objects...")
    
    local valuesFound = {}
    
    for _, obj in pairs(player:GetDescendants()) do
        if obj:IsA("StringValue") or obj:IsA("IntValue") then
            local success, value = pcall(function()
                return obj.Value
            end)
            
            if success then
                table.insert(valuesFound, {
                    Path = obj:GetFullName(),
                    Type = obj.ClassName,
                    Value = tostring(value)
                })
            end
        end
    end
    
    print("Found " .. #valuesFound .. " value objects")
    
    -- Show interesting ones
    local interesting = {}
    for _, v in pairs(valuesFound) do
        if #v.Value > 10 then
            table.insert(interesting, v)
        end
    end
    
    if #interesting > 0 then
        print("\n🎯 INTERESTING VALUES (long data):")
        for i, v in ipairs(interesting) do
            if i <= 5 then
                print(i .. ". " .. v.Path)
                print("   Type: " .. v.Type)
                print("   Value: " .. v.Value:sub(1, 50) .. (#v.Value > 50 and "..." or ""))
            end
        end
    end
    
    return valuesFound
end

-- ===== FIND GARAGE =====
local function findGarage()
    print("\n🏠 Looking for garage...")
    
    -- Check PlayerGui
    local gui = player:FindFirstChild("PlayerGui")
    if gui then
        for _, screenGui in pairs(gui:GetChildren()) do
            local nameLower = screenGui.Name:lower()
            if nameLower:find("garage") or nameLower:find("inventory") or 
               nameLower:find("car") or nameLower:find("vehicle") then
                print("✅ Found: " .. screenGui.Name)
                
                -- Count frames
                local frames = 0
                for _ in pairs(screenGui:GetDescendants()) do
                    frames = frames + 1
                end
                print("   Contains " .. frames .. " objects")
            end
        end
    end
    
    -- Check for leaderstats
    if player:FindFirstChild("leaderstats") then
        print("\n💰 Leaderstats found:")
        for _, stat in pairs(player.leaderstats:GetChildren()) do
            print("   " .. stat.Name .. ": " .. tostring(stat.Value))
        end
    end
end

-- ===== MANUAL CHECK =====
local function manualCheck()
    print("\n👤 MANUAL CHECK COMMANDS:")
    print("Copy and paste these in F9 console:")
    print("")
    print("-- Check all player children")
    print('for i,v in pairs(game.Players.LocalPlayer:GetChildren()) do print(v.Name, v.ClassName) end')
    print("")
    print("-- Check StringValues")
    print('for i,v in pairs(game.Players.LocalPlayer:GetDescendants()) do if v:IsA("StringValue") then print(v:GetFullName(), v.Value) end end')
    print("")
    print("-- Check IntValues")
    print('for i,v in pairs(game.Players.LocalPlayer:GetDescendants()) do if v:IsA("IntValue") then print(v:GetFullName(), v.Value) end end')
    print("")
    print("-- Check for folders with many items")
    print('for i,v in pairs(game.Players.LocalPlayer:GetChildren()) do if v:IsA("Folder") and #v:GetChildren() > 10 then print("FOLDER:", v.Name, "ITEMS:", #v:GetChildren()) end end')
end

-- ===== SIMPLE UI =====
local function createSimpleUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarFinder"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 300)
    main.Position = UDim2.new(0.5, -150, 0.5, -150)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎯 FIND 54 CARS"
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
    status.Text = "You have 54 cars. Let's find them!"
    status.Size = UDim2.new(1, -20, 0, 40)
    status.Position = UDim2.new(0, 10, 0, 10)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = content
    
    -- Results
    local results = Instance.new("ScrollingFrame")
    results.Size = UDim2.new(1, -20, 0, 150)
    results.Position = UDim2.new(0, 10, 1, -170)
    results.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    results.BorderSizePixel = 0
    results.ScrollBarThickness = 6
    results.Parent = content
    
    -- Buttons
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🔍 SCAN"
    scanBtn.Size = UDim2.new(0.5, -7, 0, 35)
    scanBtn.Position = UDim2.new(0, 10, 0, 60)
    scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 14
    scanBtn.Parent = content
    
    local valueBtn = Instance.new("TextButton")
    valueBtn.Text = "📊 VALUES"
    valueBtn.Size = UDim2.new(0.5, -7, 0, 35)
    valueBtn.Position = UDim2.new(0.5, 2, 0, 60)
    valueBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    valueBtn.TextColor3 = Color3.new(1, 1, 1)
    valueBtn.Font = Enum.Font.GothamBold
    valueBtn.TextSize = 14
    valueBtn.Parent = content
    
    local garageBtn = Instance.new("TextButton")
    garageBtn.Text = "🏠 GARAGE"
    garageBtn.Size = UDim2.new(0.5, -7, 0, 35)
    garageBtn.Position = UDim2.new(0, 10, 0, 105)
    garageBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    garageBtn.TextColor3 = Color3.new(1, 1, 1)
    garageBtn.Font = Enum.Font.GothamBold
    garageBtn.TextSize = 14
    garageBtn.Parent = content
    
    local manualBtn = Instance.new("TextButton")
    manualBtn.Text = "👤 MANUAL"
    manualBtn.Size = UDim2.new(0.5, -7, 0, 35)
    manualBtn.Position = UDim2.new(0.5, 2, 0, 105)
    manualBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    manualBtn.TextColor3 = Color3.new(1, 1, 1)
    manualBtn.Font = Enum.Font.GothamBold
    manualBtn.TextSize = 14
    manualBtn.Parent = content
    
    -- Add corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    addCorner(main)
    addCorner(title)
    addCorner(status)
    addCorner(results)
    addCorner(scanBtn)
    addCorner(valueBtn)
    addCorner(garageBtn)
    addCorner(manualBtn)
    
    -- Functions
    local function updateResults(text)
        results:ClearAllChildren()
        
        local label = Instance.new("TextLabel")
        label.Text = text
        label.Size = UDim2.new(1, -10, 1, -10)
        label.Position = UDim2.new(0, 5, 0, 5)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.Code
        label.TextSize = 10
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Parent = results
    end
    
    -- Button actions
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "..."
        scanBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Scanning player data..."
        
        task.spawn(function()
            simpleScan()
            status.Text = "Scan complete! Check console."
            updateResults("Scan complete.\nCheck ROBLOX console for results.")
            
            scanBtn.Text = "🔍 SCAN"
            scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        end)
    end)
    
    valueBtn.MouseButton1Click:Connect(function()
        valueBtn.Text = "..."
        valueBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Checking value objects..."
        
        task.spawn(function()
            local values = checkValues()
            
            if #values > 0 then
                status.Text = "Found " .. #values .. " value objects"
                updateResults("Found " .. #values .. " value objects.\nCheck console for details.")
            else
                status.Text = "No value objects found"
                updateResults("No value objects found")
            end
            
            valueBtn.Text = "📊 VALUES"
            valueBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end)
    end)
    
    garageBtn.MouseButton1Click:Connect(function()
        garageBtn.Text = "..."
        garageBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Looking for garage..."
        
        task.spawn(function()
            findGarage()
            status.Text = "Garage search complete"
            updateResults("Garage search complete.\nCheck console.")
            
            garageBtn.Text = "🏠 GARAGE"
            garageBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        end)
    end)
    
    manualBtn.MouseButton1Click:Connect(function()
        manualBtn.Text = "COPIED"
        manualBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        status.Text = "Commands copied to console"
        updateResults("Commands ready in console.\nOpen F9 and paste them.")
        
        manualCheck()
        
        task.wait(2)
        manualBtn.Text = "👤 MANUAL"
        manualBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    end)
    
    -- Initial
    updateResults("Click buttons to find where\nyour 54 cars are stored.")
    
    return gui
end

-- ===== RUN =====
print("\n🚀 Starting car finder...")

-- Create UI
local ui = createSimpleUI()

print("\n✅ UI Created!")
print("\n💡 Click these buttons IN ORDER:")
print("1. SCAN - Find folders and structures")
print("2. VALUES - Check String/Int values")
print("3. GARAGE - Look for garage UI")
print("4. MANUAL - Get console commands")

print("\n🎯 After scanning, tell me:")
print("• Any folders found")
print("• Number of value objects")
print("• Any interesting data found")
