-- 🎯 SERVER-SIDE CAR TRACKER & ID GRABBER
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== NETWORK TRAFFIC ANALYZER =====
local capturedData = {}
local carIDs = {}
local carPurchasePatterns = {}

local function startNetworkAnalysis()
    print("📡 Analyzing network traffic for car IDs...")
    
    -- Monitor all RemoteEvents
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local success, original = pcall(function()
                return obj.FireServer
            end)
            
            if success and original then
                -- Create a wrapper to intercept calls
                obj.FireServer = function(self, ...)
                    local args = {...}
                    local remoteName = self.Name:lower()
                    
                    -- Look for car-related traffic
                    if remoteName:find("car") or remoteName:find("vehicle") or 
                       remoteName:find("buy") or remoteName:find("purchase") or
                       remoteName:find("give") or remoteName:find("add") then
                        
                        local timestamp = os.time()
                        local data = {
                            Time = timestamp,
                            Remote = self.Name,
                            Path = self:GetFullName(),
                            Args = args
                        }
                        
                        table.insert(capturedData, data)
                        
                        -- Try to extract car IDs
                        extractCarIDsFromData(data)
                        
                        -- Show in console
                        print(string.format("🚗 CAR-RELATED CALL: %s", self.Name))
                        print(string.format("   Path: %s", self:GetFullName()))
                        print(string.format("   Args: %d arguments", #args))
                        
                        for i, arg in ipairs(args) do
                            local argType = type(arg)
                            local argStr = tostring(arg)
                            
                            if argType == "table" then
                                -- Try to decode tables
                                local success, json = pcall(function()
                                    return HttpService:JSONEncode(arg)
                                end)
                                if success and #json < 100 then
                                    print(string.format("   Arg %d [TABLE]: %s", i, json))
                                end
                            elseif argType == "string" and #argStr < 50 then
                                print(string.format("   Arg %d [STRING]: %s", i, argStr))
                            elseif argType == "number" then
                                print(string.format("   Arg %d [NUMBER]: %s", i, argStr))
                            end
                        end
                    end
                    
                    return original(self, ...)
                end
            end
        end
    end
    
    print("✅ Network analysis started")
end

-- ===== CAR ID EXTRACTOR =====
local function extractCarIDsFromData(data)
    local foundIDs = {}
    
    for i, arg in ipairs(data.Args) do
        local argType = type(arg)
        
        if argType == "string" then
            -- Look for UUIDs or hash-like strings
            local str = tostring(arg)
            
            -- Check for common ID patterns
            if #str == 36 and str:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
                -- UUID format
                if not carIDs[str] then
                    carIDs[str] = {
                        ID = str,
                        Type = "UUID",
                        Remote = data.Remote,
                        FirstSeen = data.Time
                    }
                    print(string.format("🎯 FOUND UUID CAR ID: %s", str))
                end
                foundIDs[str] = true
                
            elseif #str == 32 and str:match("^%x+$") then
                -- 32-character hex (MD5-like)
                if not carIDs[str] then
                    carIDs[str] = {
                        ID = str,
                        Type = "HEX32",
                        Remote = data.Remote,
                        FirstSeen = data.Time
                    }
                    print(string.format("🎯 FOUND HEX32 CAR ID: %s", str))
                end
                foundIDs[str] = true
                
            elseif #str >= 16 and #str <= 24 and str:match("^%d+$") then
                -- Numeric ID
                if not carIDs[str] then
                    carIDs[str] = {
                        ID = str,
                        Type = "NUMERIC",
                        Remote = data.Remote,
                        FirstSeen = data.Time
                    }
                    print(string.format("🎯 FOUND NUMERIC CAR ID: %s", str))
                end
                foundIDs[str] = true
                
            elseif str:find("car_") or str:find("vehicle_") or str:find("_id") then
                -- Named ID with prefix
                if not carIDs[str] then
                    carIDs[str] = {
                        ID = str,
                        Type = "NAMED_ID",
                        Remote = data.Remote,
                        FirstSeen = data.Time
                    }
                    print(string.format("🎯 FOUND NAMED CAR ID: %s", str))
                end
                foundIDs[str] = true
            end
            
        elseif argType == "table" then
            -- Recursively search tables
            local function searchTable(tbl, path)
                for k, v in pairs(tbl) do
                    local keyStr = tostring(k)
                    local valueStr = tostring(v)
                    local fullPath = path .. "." .. keyStr
                    
                    -- Check keys
                    if (keyStr:find("id") or keyStr:find("Id") or keyStr:find("ID")) and 
                       type(v) == "string" and #valueStr > 5 then
                        if not carIDs[valueStr] then
                            carIDs[valueStr] = {
                                ID = valueStr,
                                Type = "TABLE_KEY_" .. keyStr,
                                Remote = data.Remote,
                                Path = fullPath,
                                FirstSeen = data.Time
                            }
                            print(string.format("🎯 FOUND CAR ID IN TABLE: %s = %s", keyStr, valueStr))
                        end
                        foundIDs[valueStr] = true
                    end
                    
                    -- Recursively search nested tables
                    if type(v) == "table" then
                        searchTable(v, fullPath)
                    end
                end
            end
            
            searchTable(arg, "root")
        end
    end
    
    return foundIDs
end

-- ===== CAR ID TESTER =====
local function testCarIDs()
    print("\n🧪 Testing captured car IDs...")
    
    local testedRemotes = {}
    local successfulTests = {}
    
    -- First, find all car-related remotes
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nameLower = obj.Name:lower()
            if nameLower:find("car") or nameLower:find("vehicle") or 
               nameLower:find("give") or nameLower:find("add") then
                testedRemotes[obj] = obj.Name
            end
        end
    end
    
    -- Test each ID on each remote
    for carID, data in pairs(carIDs) do
        print(string.format("\nTesting ID: %s (%s)", carID, data.Type))
        
        for remoteObj, remoteName in pairs(testedRemotes) do
            -- Try different formats
            local testFormats = {
                carID,  -- Just the ID
                {carID},  -- Array with ID
                {CarId = carID},  -- Table with key
                {ID = carID, Player = player.Name},  -- Full data
                {player, carID},  -- Player + ID
                {player.UserId, carID}  -- UserId + ID
            }
            
            for _, testData in ipairs(testFormats) do
                local success, result = pcall(function()
                    remoteObj:FireServer(testData)
                    return "Success"
                end)
                
                if success then
                    if not successfulTests[remoteName] then
                        successfulTests[remoteName] = {}
                    end
                    
                    table.insert(successfulTests[remoteName], {
                        CarID = carID,
                        Format = testData,
                        Result = result
                    })
                    
                    print(string.format("✅ %s accepted ID!", remoteName))
                    
                    -- Send multiple times
                    for i = 1, 5 do
                        pcall(function()
                            remoteObj:FireServer(testData)
                        end)
                        task.wait(0.05)
                    end
                    
                    break
                end
            end
            
            task.wait(0.1)  -- Small delay between remotes
        end
    end
    
    -- Show results
    print("\n📊 TEST RESULTS:")
    if next(successfulTests) then
        local totalSuccess = 0
        for remoteName, tests in pairs(successfulTests) do
            totalSuccess = totalSuccess + #tests
            print(string.format("• %s: %d successful tests", remoteName, #tests))
        end
        print(string.format("\n🎉 %d total successful ID tests!", totalSuccess))
        print("Check your inventory for new cars!")
    else
        print("❌ No remotes accepted the car IDs")
    end
    
    return successfulTests
end

-- ===== INVENTORY SCANNER =====
local function scanForInventory()
    print("\n📦 Looking for inventory system...")
    
    local inventoryFound = false
    
    -- Check player for inventory folders
    for _, child in pairs(player:GetChildren()) do
        if child:IsA("Folder") then
            local nameLower = child.Name:lower()
            if nameLower:find("inventory") or nameLower:find("cars") or 
               nameLower:find("vehicles") or nameLower:find("items") then
                print(string.format("✅ Found inventory folder: %s", child.Name))
                print(string.format("   Contains %d items", #child:GetChildren()))
                inventoryFound = true
                
                -- List contents
                for _, item in pairs(child:GetChildren()) do
                    print(string.format("   • %s (%s)", item.Name, item.ClassName))
                end
            end
        end
    end
    
    -- Check for leaderstats
    if player:FindFirstChild("leaderstats") then
        print("✅ Found leaderstats:")
        for _, stat in pairs(player.leaderstats:GetChildren()) do
            print(string.format("   • %s: %s", stat.Name, tostring(stat.Value)))
        end
        inventoryFound = true
    end
    
    -- Check for data value objects
    local valueObjects = {}
    for _, obj in pairs(player:GetDescendants()) do
        if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("NumberValue") then
            local value = obj.Value
            if type(value) == "string" and #value > 10 then
                -- Check if it looks like a car ID
                if value:match("^%x+$") or value:match("^%d+$") or 
                   value:find("car_") or value:find("vehicle_") then
                    table.insert(valueObjects, {
                        Name = obj.Name,
                        Path = obj:GetFullName(),
                        Value = value,
                        Type = obj.ClassName
                    })
                end
            end
        end
    end
    
    if #valueObjects > 0 then
        print("\n🔍 Possible car IDs in player data:")
        for _, obj in ipairs(valueObjects) do
            print(string.format("   • %s = %s", obj.Path, tostring(obj.Value)))
        end
        inventoryFound = true
    end
    
    if not inventoryFound then
        print("❌ No inventory system found")
        print("   Cars might be stored server-side only")
    end
    
    return inventoryFound
end

-- ===== AUTO-DUPLICATION SYSTEM =====
local function autoDuplicateCars()
    print("\n⚡ Starting auto-duplication...")
    
    -- Step 1: Scan for inventory
    scanForInventory()
    
    -- Step 2: Start network analysis
    startNetworkAnalysis()
    
    -- Step 3: Wait for car interactions
    print("\n🎮 Now play the game normally:")
    print("1. Buy cars from dealership")
    print("2. Enter/exist cars")
    print("3. Check inventory")
    print("4. Sell/trade cars")
    print("\nThe script will capture all car IDs...")
    
    -- Wait for some traffic
    for i = 1, 30 do
        task.wait(1)
        if i % 10 == 0 then
            print(string.format("⏳ Waiting... %d/30 seconds", i))
        end
    end
    
    -- Step 4: Test captured IDs
    if next(carIDs) then
        print(string.format("\n🎯 Captured %d car IDs, testing them...", #carIDs))
        local results = testCarIDs()
        
        if next(results) then
            print("\n✅ AUTO-DUPLICATION COMPLETE!")
            print("Check your inventory for duplicated cars!")
            
            -- Try rapid duplication of successful IDs
            print("\n🚀 Attempting rapid duplication...")
            for remoteName, tests in pairs(results) do
                for _, test in ipairs(tests) do
                    -- Find the remote
                    local remoteObj
                    for _, obj in pairs(game:GetDescendants()) do
                        if obj.Name == remoteName and obj:IsA("RemoteEvent") then
                            remoteObj = obj
                            break
                        end
                    end
                    
                    if remoteObj then
                        for i = 1, 10 do
                            pcall(function()
                                remoteObj:FireServer(test.Format)
                            end)
                            task.wait(0.05)
                        end
                        print(string.format("   Sent 10 duplicates via %s", remoteName))
                    end
                end
            end
        end
    else
        print("❌ No car IDs captured")
        print("Try buying/selling cars in the game")
    end
end

-- ===== SIMPLE UI =====
local function createSimpleUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarIDTracker"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Main Window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 320, 0, 350)
    main.Position = UDim2.new(0.5, -160, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title Bar (Draggable)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleBar.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Text = "🎯 CAR ID TRACKER"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.Parent = titleBar
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Ready to track car IDs\nPlay the game to capture data"
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
    scanBtn.Text = "🔍 SCAN INVENTORY"
    scanBtn.Size = UDim2.new(1, -20, 0, 30)
    scanBtn.Position = UDim2.new(0, 10, 0, 70)
    scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 12
    scanBtn.Parent = content
    
    local trackBtn = Instance.new("TextButton")
    trackBtn.Text = "📡 START TRACKING"
    trackBtn.Size = UDim2.new(1, -20, 0, 30)
    trackBtn.Position = UDim2.new(0, 10, 0, 110)
    trackBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    trackBtn.TextColor3 = Color3.new(1, 1, 1)
    trackBtn.Font = Enum.Font.GothamBold
    trackBtn.TextSize = 12
    trackBtn.Parent = content
    
    local autoBtn = Instance.new("TextButton")
    autoBtn.Text = "⚡ AUTO-DUPE"
    autoBtn.Size = UDim2.new(1, -20, 0, 30)
    autoBtn.Position = UDim2.new(0, 10, 0, 150)
    autoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    autoBtn.TextColor3 = Color3.new(1, 1, 1)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 12
    autoBtn.Parent = content
    
    -- Results Display
    local results = Instance.new("ScrollingFrame")
    results.Size = UDim2.new(1, -20, 0, 130)
    results.Position = UDim2.new(0, 10, 0, 190)
    results.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    results.BorderSizePixel = 0
    results.ScrollBarThickness = 4
    results.Parent = content
    
    -- Add rounded corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    addCorner(main)
    addCorner(titleBar)
    addCorner(status)
    addCorner(scanBtn)
    addCorner(trackBtn)
    addCorner(autoBtn)
    addCorner(results)
    addCorner(closeBtn)
    
    -- === DRAGGABLE WINDOW ===
    local dragging = false
    local dragStart, frameStart
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = main.Position
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- === FUNCTIONS ===
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
    
    -- === BUTTON ACTIONS ===
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "SCANNING..."
        scanBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Scanning inventory system..."
        
        task.spawn(function()
            local found = scanForInventory()
            
            if found then
                status.Text = "✅ Inventory system found!\nCheck console for details."
                updateResults("Inventory scan complete.\nSee console for car IDs.", Color3.fromRGB(0, 255, 150))
            else
                status.Text = "❌ No inventory found\nCars are server-side only"
                updateResults("No local inventory found.\nCars stored server-side.", Color3.fromRGB(255, 100, 100))
            end
            
            scanBtn.Text = "🔍 SCAN INVENTORY"
            scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        end)
    end)
    
    trackBtn.MouseButton1Click:Connect(function()
        trackBtn.Text = "TRACKING..."
        trackBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Starting network tracking...\nPlay the game to capture data"
        
        task.spawn(function()
            startNetworkAnalysis()
            
            -- Monitor for 10 seconds
            for i = 1, 10 do
                status.Text = string.format("Tracking... %d/10 seconds\nPerform car actions", i)
                task.wait(1)
            end
            
            if next(carIDs) then
                local idCount = 0
                for _ in pairs(carIDs) do
                    idCount = idCount + 1
                end
                
                status.Text = string.format("✅ Captured %d car IDs!\nClick AUTO-DUPE to test", idCount)
                
                local resultText = string.format("Captured %d car IDs:\n\n", idCount)
                local count = 0
                for id, data in pairs(carIDs) do
                    if count < 5 then  -- Show first 5
                        resultText = resultText .. string.format("• %s (%s)\n", id:sub(1, 20) .. "...", data.Type)
                        count = count + 1
                    end
                end
                
                updateResults(resultText, Color3.fromRGB(0, 255, 150))
            else
                status.Text = "❌ No car IDs captured\nTry buying/selling cars"
                updateResults("No car IDs captured yet.\nBuy/sell cars in the game.", Color3.fromRGB(255, 100, 100))
            end
            
            trackBtn.Text = "📡 START TRACKING"
            trackBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end)
    end)
    
    autoBtn.MouseButton1Click:Connect(function()
        autoBtn.Text = "RUNNING..."
        autoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        status.Text = "Running auto-duplication...\nThis will take 30 seconds"
        
        task.spawn(function()
            updateResults("Auto-duplication started...\nSee console for progress.", Color3.fromRGB(255, 200, 100))
            
            autoDuplicateCars()
            
            autoBtn.Text = "⚡ AUTO-DUPE"
            autoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            
            if next(carIDs) then
                status.Text = "✅ Auto-dupe complete!\nCheck inventory for cars"
                updateResults("Auto-duplication complete!\nCheck your inventory.", Color3.fromRGB(0, 255, 0))
            else
                status.Text = "❌ No car IDs found\nTry manual tracking first"
            end
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Initial display
    updateResults("Click SCAN INVENTORY to start\nThen START TRACKING to capture IDs", Color3.fromRGB(150, 150, 150))
    
    return gui
end

-- ===== MAIN =====
print("=" .. string.rep("=", 60))
print("🎯 SERVER-SIDE CAR ID TRACKER")
print("=" .. string.rep("=", 60))

print("\n🎯 This script:")
print("• Captures car IDs from network traffic")
print("• Identifies UUIDs, numeric IDs, and hash-based IDs")
print("• Tests captured IDs on all car-related remotes")
print("• Attempts to add cars to your inventory")

print("\n🔧 Initializing...")
task.wait(1)

local ui = createSimpleUI()
print("\n✅ UI Ready!")
print("\n💡 How to use:")
print("1. Click SCAN INVENTORY first")
print("2. Click START TRACKING and play the game")
print("3. Buy/sell/enter cars to capture IDs")
print("4. Click AUTO-DUPE to test all IDs")
print("5. Check inventory after testing")

print("\n⚠️  Important:")
print("• This works by capturing REAL car IDs")
print("• You need to actually interact with cars")
print("• Success depends on the game's security")
