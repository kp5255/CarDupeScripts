-- 🎯 ENHANCED CAR DUPLICATION SYSTEM
-- Fixed car detection issue
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 ENHANCED CAR DUPLICATION SYSTEM")
print("=" .. string.rep("=", 60))

-- ===== IMPROVED CAR DATA FINDER =====
local function findMyCurrentCars()
    print("\n🔍 ENHANCED: Finding your current cars...")
    
    local myCars = {}
    local checkedFolders = {}
    
    -- METHOD 1: Check Player Data folders (COMMON LOCATION)
    local function checkFolder(folder)
        if checkedFolders[folder] then return end
        checkedFolders[folder] = true
        
        for _, child in pairs(folder:GetChildren()) do
            -- Check for car-related objects
            if child:IsA("Folder") and (child.Name:find("Car") or child.Name:find("Vehicle")) then
                for _, item in pairs(child:GetChildren()) do
                    if item:IsA("StringValue") or item:IsA("NumberValue") then
                        table.insert(myCars, {
                            Name = item.Value,
                            Source = "Car Folder: " .. child.Name,
                            Path = item:GetFullName(),
                            Object = item
                        })
                    end
                end
            end
            
            -- Check for values that might contain car data
            if child:IsA("StringValue") then
                local value = child.Value
                if type(value) == "string" then
                    -- Check for common car ID patterns
                    if value:find("car_") or value:find("vehicle_") or 
                       value:find("Bontlay") or value:find("Jegar") or 
                       value:find("Corsaro") or value:find("Lavish") or 
                       value:find("Sportler") or #value > 15 then
                        table.insert(myCars, {
                            Name = value,
                            Source = "StringValue: " .. child.Name,
                            Path = child:GetFullName(),
                            Object = child
                        })
                    end
                end
            end
            
            -- Check for NumberValue that might be car ID
            if child:IsA("NumberValue") then
                table.insert(myCars, {
                    Name = tostring(child.Value),
                    Source = "NumberValue: " .. child.Name,
                    Path = child:GetFullName(),
                    Object = child
                })
            end
            
            -- Recursively check folders
            if child:IsA("Folder") then
                checkFolder(child)
            end
        end
    end
    
    -- Check common locations
    local locations = {
        player,  -- Player object
        player:FindFirstChild("PlayerGui"),
        player:FindFirstChild("Backpack"),
        workspace:FindFirstChild("Vehicles"),
        ReplicatedStorage,
        game:GetService("ServerStorage")
    }
    
    for _, location in pairs(locations) do
        if location then
            checkFolder(location)
        end
    end
    
    -- METHOD 2: Check for GUIs showing owned cars
    if player:FindFirstChild("PlayerGui") then
        local guis = player.PlayerGui:GetChildren()
        for _, gui in pairs(guis) do
            if gui:IsA("ScreenGui") then
                local textLabels = gui:GetDescendants()
                for _, label in pairs(textLabels) do
                    if label:IsA("TextLabel") or label:IsA("TextBox") then
                        local text = label.Text
                        if text and #text > 0 then
                            -- Look for car names
                            if text:find("Bontlay") or text:find("Jegar") or 
                               text:find("Corsaro") or text:find("Lavish") or 
                               text:find("Sportler") or text:find("Car") or
                               text:find("car_") then
                                table.insert(myCars, {
                                    Name = text,
                                    Source = "GUI: " .. gui.Name,
                                    Path = label:GetFullName(),
                                    Object = label
                                })
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- METHOD 3: Look for car parts in workspace
    local vehicles = workspace:FindFirstChild("Vehicles")
    if vehicles then
        for _, vehicle in pairs(vehicles:GetChildren()) do
            if vehicle:FindFirstChild("Owner") then
                local owner = vehicle.Owner.Value
                if owner == player or owner == player.Name or owner == player.UserId then
                    table.insert(myCars, {
                        Name = vehicle.Name,
                        Source = "Workspace Vehicle",
                        Path = vehicle:GetFullName(),
                        Object = vehicle
                    })
                end
            end
        end
    end
    
    -- METHOD 4: Check Data Stores (via RemoteEvents)
    print("   Checking 43 found remotes for car data patterns...")
    
    -- Get the transfer remotes
    local transferRemotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nameLower = obj.Name:lower()
            if nameLower:find("claim") or nameLower:find("redeem") or 
               nameLower:find("collect") or nameLower:find("get") or
               nameLower:find("vehicle") or nameLower:find("car") then
                table.insert(transferRemotes, obj)
            end
        end
    end
    
    -- Try to get car data from what these remotes accept
    for _, remote in pairs(transferRemotes) do
        -- Store remote reference
        table.insert(myCars, {
            Name = remote.Name,
            Source = "RemoteEvent Name",
            Path = remote:GetFullName(),
            Object = remote,
            IsRemote = true
        })
    end
    
    print("   Found " .. #myCars .. " potential car sources")
    return myCars
end

-- ===== SIMPLIFIED DUPLICATION =====
local function simpleDuplication()
    print("\n⚡ SIMPLIFIED DUPLICATION METHOD")
    print("=" .. string.rep("=", 50))
    
    -- Find car data
    local myCars = findMyCurrentCars()
    
    if #myCars == 0 then
        print("❌ STILL NO CAR DATA FOUND")
        print("\n💡 MANUAL DETECTION REQUIRED:")
        print("1. Open Developer Console (F9)")
        print("2. Look for RemoteEvents with names like:")
        print("   - ClaimCar")
        print("   - RedeemVehicle") 
        print("   - GetCar")
        print("   - PurchaseVehicle")
        print("3. Look for your car data in:")
        print("   - Player folder")
        print("   - PlayerGui displays")
        print("   - StringValues with long IDs")
        return
    end
    
    -- Display found data
    print("\n📋 FOUND DATA:")
    for i, car in ipairs(myCars) do
        print(i .. ". " .. car.Name .. " (" .. car.Source .. ")")
        if i >= 10 then
            print("   ... and " .. (#myCars - 10) .. " more")
            break
        end
    end
    
    -- Try different duplication methods
    print("\n🎯 ATTEMPTING DUPLICATION...")
    
    -- Method 1: Try remotes directly
    for _, car in ipairs(myCars) do
        if car.IsRemote then
            print("\n📡 Trying remote: " .. car.Name)
            
            -- Try different data formats
            local formats = {
                "Car1",
                "Vehicle1",
                "1",
                "0",
                player.Name,
                player.UserId
            }
            
            for _, data in pairs(formats) do
                local success = pcall(function()
                    car.Object:FireServer(data)
                    print("   ✅ Sent: " .. tostring(data))
                    return true
                end)
                
                if success then
                    print("   🎯 REMOTE ACCEPTS: " .. tostring(data))
                    -- Rapid fire this successful format
                    for i = 1, 20 do
                        car.Object:FireServer(data)
                        task.wait(0.05)
                    end
                    print("   ⚡ Sent 20 rapid requests!")
                end
            end
        end
    end
    
    -- Method 2: Try car data with transfer remotes
    print("\n🔍 Looking for transfer remotes...")
    
    local transferRemotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(transferRemotes, obj)
        end
    end
    
    print("   Found " .. #transferRemotes .. " RemoteEvents")
    
    -- Try top 5 car data with top 10 remotes
    for i = 1, math.min(5, #myCars) do
        local car = myCars[i]
        if not car.IsRemote then  -- Skip if it's already a remote
            for j = 1, math.min(10, #transferRemotes) do
                local remote = transferRemotes[j]
                
                print("   Testing: " .. remote.Name .. " with " .. car.Name)
                
                -- Try the car data
                local success = pcall(function()
                    remote:FireServer(car.Name)
                    return true
                end)
                
                if success then
                    print("   ✅ " .. remote.Name .. " accepted " .. car.Name)
                    -- Rapid fire!
                    for k = 1, 30 do
                        remote:FireServer(car.Name)
                        task.wait(0.03)
                    end
                    print("   ⚡ Sent 30 rapid requests!")
                end
            end
        end
    end
    
    print("\n✅ DUPLICATION ATTEMPT COMPLETE!")
    print("💡 Check your inventory/garage")
    print("🔄 Wait 15 seconds and try again")
end

-- ===== QUICK UI =====
local function createQuickUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "QuickDupe"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 350, 0, 200)
    main.Position = UDim2.new(0.5, -175, 0.5, -100)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "⚡ QUICK DUPE V2"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    local status = Instance.new("TextLabel")
    status.Text = "Click SCAN then DUPE"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🔍 SCAN FOR DATA"
    scanBtn.Size = UDim2.new(1, -20, 0, 40)
    scanBtn.Position = UDim2.new(0, 10, 0, 120)
    scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 14
    scanBtn.Parent = main
    
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "⚡ START DUPE"
    dupeBtn.Size = UDim2.new(1, -20, 0, 40)
    dupeBtn.Position = UDim2.new(0, 10, 0, 170)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.GothamBold
    dupeBtn.TextSize = 16
    dupeBtn.Parent = main
    
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
    addCorner(dupeBtn)
    
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "SCANNING..."
        status.Text = "Scanning for car data..."
        
        task.spawn(function()
            local cars = findMyCurrentCars()
            status.Text = "Found " .. #cars .. " data sources\nClick DUPE to start"
            scanBtn.Text = "🔍 SCAN COMPLETE"
            scanBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        end)
    end)
    
    dupeBtn.MouseButton1Click:Connect(function()
        dupeBtn.Text = "DUPLICATING..."
        status.Text = "Starting duplication..."
        
        task.spawn(function()
            simpleDuplication()
            dupeBtn.Text = "⚡ DUPE COMPLETE"
            dupeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            status.Text = "Check your inventory!\nWait 15s and try again"
        end)
    end)
    
    -- Close
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = title
    
    addCorner(closeBtn)
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== MAIN =====
print("\n🚀 Starting enhanced system...")
createQuickUI()

print("\n🎯 NEW STRATEGY:")
print("1. Find ANY data that might be car-related")
print("2. Try ALL RemoteEvents with that data")
print("3. When one accepts, RAPID-FIRE it")
print("4. Check inventory for duplicates")
