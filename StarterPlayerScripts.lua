-- 🚗 ULTIMATE CAR FINDER & ANALYZER
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== COMPREHENSIVE CAR DETECTOR =====
local function findAllCars()
    print("🚗 ULTIMATE CAR SCAN INITIATED...")
    
    local allCars = {}
    local carPatterns = {
        -- Brand names
        "Bontlay", "Jegar", "Corsaro", "Lavish", "Sportler",
        -- Model names
        "Bontaga", "Cental", "Model", "Tecan", "Ventoge", "Roni", 
        "Pursane", "T8", "G08", "GT", "RS", "SVR", "Turbo",
        -- General car terms
        "Car", "Vehicle", "Auto", "Motor", "Wheel", "Engine",
        -- Luxury brands (common in tycoons)
        "Bugatti", "Ferrari", "Lamborghini", "Porsche", "McLaren",
        "Aston", "Mercedes", "BMW", "Audi", "Lexus", "Tesla"
    }
    
    -- Function to check if something looks like a car
    local function isLikelyCar(name, obj)
        if not name or #name < 2 then return false end
        
        local lowerName = name:lower()
        
        -- Skip obvious non-cars
        local skipPatterns = {
            "gui", "ui", "button", "frame", "label", "textbox",
            "script", "localscript", "modulescript", "folder",
            "part", "mesh", "sound", "audio", "camera", "light",
            "spawn", "dealer", "shop", "store", "tycoon", "game",
            "player", "humanoid", "animation", "remote", "event"
        }
        
        for _, pattern in ipairs(skipPatterns) do
            if lowerName:find(pattern) then
                return false
            end
        end
        
        -- Check for car patterns
        for _, pattern in ipairs(carPatterns) do
            if name:find(pattern) then
                return true
            end
        end
        
        -- Check if it has car-like children
        if obj and obj:IsA("Model") then
            local hasWheels = false
            local hasSeats = false
            
            for _, child in ipairs(obj:GetChildren()) do
                local childLower = child.Name:lower()
                if childLower:find("wheel") or childLower:find("tire") then
                    hasWheels = true
                end
                if childLower:find("seat") or child:IsA("VehicleSeat") then
                    hasSeats = true
                end
                if child:IsA("BasePart") and child.Name:lower():find("chassis") then
                    return true
                end
            end
            
            if hasWheels and hasSeats then
                return true
            end
        end
        
        return false
    end
    
    -- ===== PHASE 1: Scan Game Structure =====
    print("\n📂 PHASE 1: Scanning Game Structure...")
    
    local locations = {
        ReplicatedStorage,
        Workspace,
        game:GetService("Lighting"),
        game:GetService("StarterPack"),
        game:GetService("StarterGui"),
        game:GetService("StarterPlayer")
    }
    
    -- Try to access ServerStorage
    local success, ServerStorage = pcall(function()
        return game:GetService("ServerStorage")
    end)
    if success then
        table.insert(locations, ServerStorage)
    end
    
    for _, location in ipairs(locations) do
        pcall(function()
            for _, obj in ipairs(location:GetDescendants()) do
                if isLikelyCar(obj.Name, obj) then
                    if not allCars[obj.Name] then
                        allCars[obj.Name] = {
                            Name = obj.Name,
                            Path = obj:GetFullName(),
                            Class = obj.ClassName,
                            Location = location.Name,
                            Children = #obj:GetChildren(),
                            IsModel = obj:IsA("Model")
                        }
                    end
                end
            end
        end)
    end
    
    -- ===== PHASE 2: Analyze Remote Events =====
    print("📡 PHASE 2: Analyzing Remote Events...")
    
    local remotesFound = {}
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local remoteName = obj.Name:lower()
            if remoteName:find("car") or remoteName:find("vehicle") or 
               remoteName:find("buy") or remoteName:find("purchase") or
               remoteName:find("give") or remoteName:find("add") then
                
                table.insert(remotesFound, {
                    Name = obj.Name,
                    Type = obj.ClassName,
                    Path = obj:GetFullName()
                })
                
                -- Add as potential car source
                if not allCars["REMOTE_" .. obj.Name] then
                    allCars["REMOTE_" .. obj.Name] = {
                        Name = "Remote: " .. obj.Name,
                        Path = obj:GetFullName(),
                        Class = obj.ClassName,
                        Location = "Remote Event",
                        IsRemote = true
                    }
                end
            end
        end
    end
    
    -- ===== PHASE 3: Scan Module Scripts =====
    print("📦 PHASE 3: Scanning Module Scripts...")
    
    local modulesScanned = 0
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            modulesScanned = modulesScanned + 1
            
            local success, source = pcall(function()
                return obj.Source
            end)
            
            if success and source then
                -- Look for car names in module source
                for _, pattern in ipairs(carPatterns) do
                    if source:find(pattern) then
                        -- Extract potential car names
                        for line in source:gmatch("[^\r\n]+") do
                            if line:find('"') then
                                for quoted in line:gmatch('"([^"]+)"') do
                                    if isLikelyCar(quoted, nil) then
                                        if not allCars["MODULE_" .. quoted] then
                                            allCars["MODULE_" .. quoted] = {
                                                Name = quoted,
                                                Path = "Module: " .. obj.Name,
                                                Class = "String",
                                                Location = "ModuleScript",
                                                FromModule = true
                                            }
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- ===== PHASE 4: Check Player Data =====
    print("👤 PHASE 4: Checking Player Data...")
    
    local playerCars = {}
    pcall(function()
        for _, obj in ipairs(player:GetDescendants()) do
            if obj:IsA("StringValue") or obj:IsA("Folder") then
                local value = ""
                if obj:IsA("StringValue") then
                    value = obj.Value
                end
                
                if isLikelyCar(obj.Name, obj) or isLikelyCar(value, obj) then
                    local carName = obj.Name
                    if value and value ~= "" then
                        carName = value
                    end
                    
                    if not allCars["PLAYER_" .. carName] then
                        allCars["PLAYER_" .. carName] = {
                            Name = carName,
                            Path = obj:GetFullName(),
                            Class = obj.ClassName,
                            Location = "PlayerData",
                            Value = value ~= "" and value or nil
                        }
                    end
                end
            end
        end
    end)
    
    -- ===== PHASE 5: Check Workspace Vehicles =====
    print("🏎️ PHASE 5: Checking Workspace Vehicles...")
    
    local workspaceCars = 0
    pcall(function()
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") then
                -- Check for vehicle parts
                local vehicleParts = 0
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local nameLower = part.Name:lower()
                        if nameLower:find("chassis") or nameLower:find("body") or 
                           nameLower:find("wheel") or nameLower:find("seat") then
                            vehicleParts = vehicleParts + 1
                        end
                    end
                end
                
                if vehicleParts >= 2 and isLikelyCar(obj.Name, obj) then
                    workspaceCars = workspaceCars + 1
                    if not allCars["WORKSPACE_" .. obj.Name] then
                        allCars["WORKSPACE_" .. obj.Name] = {
                            Name = obj.Name,
                            Path = obj:GetFullName(),
                            Class = "Model",
                            Location = "Workspace",
                            Parts = vehicleParts,
                            IsPhysical = true
                        }
                    end
                end
            end
        end
    end)
    
    -- ===== COMPILE RESULTS =====
    print("\n📊 SCAN COMPLETE!")
    print("=" .. string.rep("=", 50))
    
    local carList = {}
    for _, carData in pairs(allCars) do
        table.insert(carList, carData)
    end
    
    -- Sort alphabetically
    table.sort(carList, function(a, b)
        return a.Name < b.Name
    end)
    
    -- Statistics
    print("\n📈 STATISTICS:")
    print("Total car references found: " .. #carList)
    print("Remote events found: " .. #remotesFound)
    print("Modules scanned: " .. modulesScanned)
    print("Workspace vehicles: " .. workspaceCars)
    
    -- Show remotes
    if #remotesFound > 0 then
        print("\n🎯 KEY REMOTE EVENTS:")
        for i, remote in ipairs(remotesFound) do
            if i <= 10 then  -- Show top 10
                print(string.format("  %d. %s (%s)", i, remote.Name, remote.Type))
            end
        end
    end
    
    return carList, remotesFound
end

-- ===== CREATE ADVANCED UI =====
local function createCarHunterUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarHunterUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Main Window
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 500, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = gui
    
    -- Title Bar (Draggable)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "🚗 CAR HUNTER v3.0"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar
    
    -- Content Area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -40)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame
    
    -- Controls Frame
    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(1, -20, 0, 100)
    controls.Position = UDim2.new(0, 10, 0, 10)
    controls.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    controls.Parent = content
    
    -- Scan Button
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🔍 DEEP SCAN"
    scanBtn.Size = UDim2.new(1, -20, 0, 40)
    scanBtn.Position = UDim2.new(0, 10, 0, 10)
    scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 16
    scanBtn.Parent = controls
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Ready to scan. Click DEEP SCAN to find all cars."
    status.Size = UDim2.new(1, -20, 0, 40)
    status.Position = UDim2.new(0, 10, 0, 60)
    status.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = controls
    
    -- Results Frame
    local results = Instance.new("ScrollingFrame")
    results.Name = "Results"
    results.Size = UDim2.new(1, -20, 0, 400)
    results.Position = UDim2.new(0, 10, 0, 120)
    results.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    results.BorderSizePixel = 0
    results.ScrollBarThickness = 8
    results.Visible = false
    results.Parent = content
    
    -- Stats Frame
    local stats = Instance.new("Frame")
    stats.Size = UDim2.new(1, -20, 0, 80)
    stats.Position = UDim2.new(0, 10, 0, 530)
    stats.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    stats.Visible = false
    stats.Parent = content
    
    -- Add rounded corners
    local function addCorners(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    addCorners(mainFrame)
    addCorners(controls)
    addCorners(results)
    addCorners(stats)
    addCorners(scanBtn)
    addCorners(status)
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeBtn
    
    -- Draggable window
    local dragging = false
    local dragStart, frameStart
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Variables
    local carData = {}
    local remotes = {}
    
    -- Function to display results
    local function displayResults()
        results:ClearAllChildren()
        results.Visible = true
        stats.Visible = true
        
        local yPos = 5
        
        for i, car in ipairs(carData) do
            -- Create entry
            local entry = Instance.new("Frame")
            entry.Size = UDim2.new(1, -10, 0, 60)
            entry.Position = UDim2.new(0, 5, 0, yPos)
            entry.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(35, 35, 45) or Color3.fromRGB(30, 30, 40)
            entry.Parent = results
            
            addCorners(entry)
            
            -- Car name
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Text = car.Name
            nameLabel.Size = UDim2.new(0.7, -10, 0, 25)
            nameLabel.Position = UDim2.new(0, 5, 0, 5)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = entry
            
            -- Location
            local locLabel = Instance.new("TextLabel")
            locLabel.Text = "📍 " .. car.Location
            locLabel.Size = UDim2.new(0.3, -5, 0, 20)
            locLabel.Position = UDim2.new(0.7, 0, 0, 5)
            locLabel.BackgroundTransparency = 1
            locLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            locLabel.Font = Enum.Font.Gotham
            locLabel.TextSize = 10
            locLabel.TextXAlignment = Enum.TextXAlignment.Right
            locLabel.Parent = entry
            
            -- Path
            local pathLabel = Instance.new("TextLabel")
            pathLabel.Text = "📁 " .. car.Path
            pathLabel.Size = UDim2.new(1, -10, 0, 25)
            pathLabel.Position = UDim2.new(0, 5, 0, 30)
            pathLabel.BackgroundTransparency = 1
            pathLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            pathLabel.Font = Enum.Font.Gotham
            pathLabel.TextSize = 10
            pathLabel.TextXAlignment = Enum.TextXAlignment.Left
            pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
            pathLabel.Parent = entry
            
            yPos = yPos + 65
        end
        
        results.CanvasSize = UDim2.new(0, 0, 0, yPos)
        
        -- Update stats
        stats:ClearAllChildren()
        
        local stat1 = Instance.new("TextLabel")
        stat1.Text = "📊 Cars Found: " .. #carData
        stat1.Size = UDim2.new(0.5, -5, 0.5, -5)
        stat1.Position = UDim2.new(0, 5, 0, 5)
        stat1.BackgroundTransparency = 1
        stat1.TextColor3 = Color3.new(1, 1, 1)
        stat1.Font = Enum.Font.GothamBold
        stat1.TextSize = 14
        stat1.Parent = stats
        
        local stat2 = Instance.new("TextLabel")
        stat2.Text = "📡 Remotes: " .. #remotes
        stat2.Size = UDim2.new(0.5, -5, 0.5, -5)
        stat2.Position = UDim2.new(0.5, 0, 0, 5)
        stat2.BackgroundTransparency = 1
        stat2.TextColor3 = Color3.new(1, 1, 1)
        stat2.Font = Enum.Font.GothamBold
        stat2.TextSize = 14
        stat2.Parent = stats
        
        local info = Instance.new("TextLabel")
        info.Text = "💡 Use remotes for car duplication"
        info.Size = UDim2.new(1, -10, 0.5, -5)
        info.Position = UDim2.new(0, 5, 0.5, 0)
        info.BackgroundTransparency = 1
        info.TextColor3 = Color3.fromRGB(255, 200, 100)
        info.Font = Enum.Font.Gotham
        info.TextSize = 12
        info.Parent = stats
    end
    
    -- Scan functionality
    scanBtn.MouseButton1Click:Connect(function()
        status.Text = "🔍 Scanning game... This may take a moment."
        scanBtn.Text = "SCANNING..."
        scanBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            carData, remotes = findAllCars()
            
            if #carData > 0 then
                status.Text = "✅ Found " .. #carData .. " car references!"
                displayResults()
                
                -- Show key remotes
                if #remotes > 0 then
                    status.Text = status.Text .. "\n🎯 " .. #remotes .. " remote events found!"
                    
                    -- Try to use Cmdr if available
                    local cmdr = ReplicatedStorage:FindFirstChild("CmdrClient")
                    if cmdr then
                        status.Text = status.Text .. "\n✅ Cmdr system detected!"
                    end
                end
            else
                status.Text = "❌ No cars found. Game might use server-only storage."
            end
            
            scanBtn.Text = "🔍 DEEP SCAN"
            scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        end)
    end)
    
    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== MAIN =====
print("🚗 ULTIMATE CAR HUNTER")
print("Initializing...")
task.wait(1)

createCarHunterUI()
print("✅ UI Ready!")
print("\n🔥 HOW TO USE:")
print("1. Click 'DEEP SCAN' to find ALL cars")
print("2. Look for car names and remote events")
print("3. Cars are shown with their locations")
print("4. Use remote events for duplication attempts")
print("\n⚠️  IMPORTANT:")
print("• Server-side cars cannot be directly accessed")
print("• This shows all cars VISIBLE to client")
print("• Duplication depends on game security")
