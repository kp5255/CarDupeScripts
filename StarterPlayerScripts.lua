-- 🚗 ADVANCED CAR DUPLICATOR
-- Game ID: ffad7ea30d080c4aa1d7bf4b2f5f4381
-- FULLY AUTOMATIC - NO MANUAL SETUP NEEDED

print("🚗 ADVANCED CAR DUPLICATOR LOADING...")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

-- Global variables
local originalCars = {}
local duplicationMethod = nil
local isDuplicating = false

-- ===== STEP 1: INTELLIGENT CAR DETECTION =====
local function findAllOwnedCars()
    print("\n🔍 Scanning for your cars...")
    
    local foundCars = {}
    local scannedFolders = {}
    
    -- Deep scan player data
    local function deepScanFolder(folder, path)
        if not folder then return end
        if scannedFolders[folder] then return end
        scannedFolders[folder] = true
        
        for _, child in pairs(folder:GetChildren()) do
            -- Check if it's a car object
            if child:IsA("Folder") or child:IsA("Model") or child:IsA("ValueBase") then
                local name = child.Name:lower()
                
                -- Car indicators
                local isCar = false
                if name:find("car") or name:find("vehicle") or 
                   name:find("_car") or name:find("_vehicle") or
                   name:find("model") or child:GetAttribute("IsVehicle") then
                    isCar = true
                end
                
                -- Check children for car indicators
                if not isCar then
                    for _, sub in pairs(child:GetChildren()) do
                        if sub.Name:find("Car") or sub.Name:find("Vehicle") then
                            isCar = true
                            break
                        end
                    end
                end
                
                if isCar then
                    if not table.find(foundCars, child.Name) then
                        table.insert(foundCars, {
                            Name = child.Name,
                            Object = child,
                            Path = path .. " → " .. child.Name
                        })
                        print("✅ Found: " .. child.Name .. " in " .. path)
                    end
                end
                
                -- Recursive scan
                if child:IsA("Folder") then
                    deepScanFolder(child, path .. " → " .. child.Name)
                end
            end
        end
    end
    
    -- Scan all player folders
    for _, folder in pairs(player:GetChildren()) do
        deepScanFolder(folder, "Player")
    end
    
    -- Scan Workspace for player's spawned cars
    if Workspace:FindFirstChild("Vehicles") then
        for _, vehicle in pairs(Workspace.Vehicles:GetChildren()) do
            if vehicle:IsA("Model") then
                -- Check if this vehicle belongs to the player
                local owner = vehicle:FindFirstChild("Owner") or vehicle:GetAttribute("Owner")
                if owner == player.Name or owner == player.UserId then
                    if not table.find(foundCars, vehicle.Name) then
                        table.insert(foundCars, {
                            Name = vehicle.Name,
                            Object = vehicle,
                            Path = "Workspace → Vehicles"
                        })
                        print("✅ Found spawned: " .. vehicle.Name)
                    end
                end
            end
        end
    end
    
    -- Fallback: Look for any saved data
    if #foundCars == 0 then
        print("No cars found in folders, checking leaderstats...")
        
        -- Check leaderstats for car counts
        if player:FindFirstChild("leaderstats") then
            for _, stat in pairs(player.leaderstats:GetChildren()) do
                local name = stat.Name:lower()
                if name:find("car") or name:find("vehicle") then
                    if stat.Value > 0 then
                        local carName = "Car_" .. stat.Name
                        table.insert(foundCars, {
                            Name = carName,
                            Object = stat,
                            Path = "leaderstats"
                        })
                        print("✅ Found car stat: " .. carName .. " (Count: " .. stat.Value .. ")")
                    end
                end
            end
        end
    end
    
    -- Save original list
    originalCars = {}
    for _, car in pairs(foundCars) do
        table.insert(originalCars, car.Name)
    end
    
    print("\n📊 Found " .. #foundCars .. " total cars")
    return foundCars
end

-- ===== STEP 2: INTELLIGENT EVENT DISCOVERY =====
local function discoverDuplicationMethods()
    print("\n🔧 Discovering duplication methods...")
    
    local methods = {}
    
    -- Phase 1: Direct event scanning
    local allRemotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            local fullPath = obj:GetFullName()
            
            -- Rate events by relevance
            local score = 0
            if name:find("car") or name:find("vehicle") then score = score + 3 end
            if name:find("duplicate") or name:find("copy") then score = score + 5 end
            if name:find("add") or name:find("spawn") then score = score + 2 end
            if name:find("buy") or name:find("purchase") then score = score + 2 end
            if name:find("save") or name:find("load") then score = score + 1 end
            
            if score > 0 then
                table.insert(methods, {
                    Object = obj,
                    Name = obj.Name,
                    Type = obj.ClassName,
                    Path = fullPath,
                    Score = score,
                    Tested = false,
                    Works = false
                })
            end
        end
    end
    
    -- Sort by relevance score
    table.sort(methods, function(a, b)
        return a.Score > b.Score
    end)
    
    -- Phase 2: Look for server scripts to understand the API
    local function analyzeServerScripts()
        print("Analyzing server scripts for API patterns...")
        
        local serverScripts = game:GetService("ServerScriptService"):GetDescendants()
        local clientScripts = game:GetService("StarterPlayer"):GetDescendants()
        
        local allScripts = {}
        for _, script in pairs(serverScripts) do
            table.insert(allScripts, script)
        end
        for _, script in pairs(clientScripts) do
            table.insert(allScripts, script)
        end
        
        -- Look for remote event handlers
        for _, script in pairs(allScripts) do
            if script:IsA("Script") or script:IsA("LocalScript") then
                local source = ""
                pcall(function()
                    source = script.Source
                end)
                
                if #source > 0 then
                    -- Look for car-related patterns
                    for line in source:gmatch("[^\r\n]+") do
                        local cleanLine = line:lower()
                        
                        -- Look for function signatures
                        if cleanLine:find("onevent") or cleanLine:find("onserver") then
                            -- Extract event name
                            for eventName in line:gmatch("%w+") do
                                if eventName:lower():find("car") or eventName:lower():find("vehicle") then
                                    print("📝 Found potential event in script: " .. eventName)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    pcall(analyzeServerScripts)
    
    print("📋 Found " .. #methods .. " potential methods")
    for i, method in ipairs(methods) do
        if i <= 10 then  -- Show top 10
            print(string.format("%d. %s (%s) - Score: %d", i, method.Name, method.Type, method.Score))
        end
    end
    
    return methods
end

-- ===== STEP 3: SMART DUPLICATION TESTER =====
local function testDuplicationMethod(method, carName)
    local event = method.Object
    
    -- Generate test ID for tracking
    local testId = HttpService:GenerateGUID(false):sub(1, 8)
    
    -- Smart argument generation based on event name
    local eventName = method.Name:lower()
    local argSets = {}
    
    -- Basic arguments
    table.insert(argSets, {carName})
    table.insert(argSets, {player, carName})
    table.insert(argSets, {player.UserId, carName})
    
    -- Event-specific arguments
    if eventName:find("buy") or eventName:find("purchase") then
        table.insert(argSets, {carName, 0})
        table.insert(argSets, {carName, 1})
        table.insert(argSets, {"buy", carName})
    end
    
    if eventName:find("add") or eventName:find("spawn") then
        table.insert(argSets, {"add", carName})
        table.insert(argSets, {"spawn", carName})
        table.insert(argSets, {carName, true})
    end
    
    if eventName:find("duplicate") or eventName:find("copy") then
        table.insert(argSets, {"duplicate", carName})
        table.insert(argSets, {"copy", carName})
        table.insert(argSets, {carName, 2}) -- Quantity 2
    end
    
    -- Table format
    table.insert(argSets, {
        Vehicle = carName,
        Action = "Add"
    })
    
    -- Test all argument sets
    local anySuccess = false
    local bestResult = nil
    
    for i, args in pairs(argSets) do
        local success, result = pcall(function()
            if method.Type == "RemoteEvent" then
                return {event:FireServer(unpack(args)), "FireServer"}
            else
                return {event:InvokeServer(unpack(args)), "InvokeServer"}
            end
        end)
        
        if success then
            print("   [" .. testId .. "] Test " .. i .. ": CALL SENT")
            anySuccess = true
            bestResult = {
                Args = args,
                Type = result[2]
            }
        else
            -- Extract meaningful error
            local err = tostring(result)
            if not err:find("Not connected") and not err:find("attempt to yield") then
                print("   [" .. testId .. "] Test " .. i .. ": " .. err:sub(1, 50))
            end
        end
        
        task.wait(0.05)
    end
    
    return anySuccess, bestResult
end

-- ===== STEP 4: AUTO-DUPLICATION ENGINE =====
local function duplicateAllCars()
    if isDuplicating then return end
    isDuplicating = true
    
    print("\n" .. string.rep("=", 60))
    print("🚀 STARTING AUTO-DUPLICATION PROCESS")
    print(string.rep("=", 60))
    
    -- Step 1: Find cars
    local cars = findAllOwnedCars()
    
    if #cars == 0 then
        print("\n❌ CRITICAL: No cars found!")
        print("Please buy at least one car from the store first.")
        print("The game needs car data to work with.")
        isDuplicating = false
        return false
    end
    
    -- Step 2: Discover methods
    local methods = discoverDuplicationMethods()
    
    if #methods == 0 then
        print("\n❌ CRITICAL: No methods found!")
        print("Game may have strong protection or different architecture.")
        isDuplicating = false
        return false
    end
    
    -- Step 3: Test methods on first car
    print("\n🧪 Testing methods on first car...")
    local firstCar = cars[1].Name
    local workingMethod = nil
    local workingArgs = nil
    
    for _, method in pairs(methods) do
        if not workingMethod then
            print("Testing: " .. method.Name .. "...")
            local success, result = testDuplicationMethod(method, firstCar)
            
            if success then
                print("✅ " .. method.Name .. " appears to work!")
                workingMethod = method
                workingArgs = result
                break
            end
        end
    end
    
    if not workingMethod then
        print("\n⚠️ No method accepted the call.")
        print("Trying fallback brute force...")
        
        -- Brute force all remotes
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and not workingMethod then
                pcall(function()
                    obj:FireServer(firstCar)
                    print("Brute force tried: " .. obj.Name)
                end)
                task.wait(0.03)
            end
        end
    end
    
    -- Step 4: Apply to all cars
    if workingMethod then
        print("\n🔄 Duplicating all cars using " .. workingMethod.Name .. "...")
        
        local dupeAttempts = 0
        for _, car in pairs(cars) do
            print("Duplicating: " .. car.Name)
            
            if workingArgs then
                -- Use working arguments
                local args = workingArgs.Args
                pcall(function()
                    if workingMethod.Type == "RemoteEvent" then
                        workingMethod.Object:FireServer(unpack(args))
                    else
                        workingMethod.Object:InvokeServer(unpack(args))
                    end
                    dupeAttempts = dupeAttempts + 1
                    print("   ✅ Request sent for " .. car.Name)
                end)
            else
                -- Try multiple patterns
                local patterns = {
                    {car.Name},
                    {player, car.Name},
                    {car.Name, 0}
                }
                
                for _, args in pairs(patterns) do
                    pcall(function()
                        if workingMethod.Type == "RemoteEvent" then
                            workingMethod.Object:FireServer(unpack(args))
                        else
                            workingMethod.Object:InvokeServer(unpack(args))
                        end
                        dupeAttempts = dupeAttempts + 1
                    end)
                    task.wait(0.05)
                end
            end
            
            task.wait(0.1) -- Avoid rate limits
        end
        
        print("\n📊 Sent " .. dupeAttempts .. " duplication requests")
    end
    
    -- Step 5: Verify results
    print("\n⏳ Waiting for server processing...")
    task.wait(3)
    
    print("\n🔍 Verifying duplication...")
    local newCars = findAllOwnedCars()
    local newCarNames = {}
    for _, car in pairs(newCars) do
        table.insert(newCarNames, car.Name)
    end
    
    -- Find new cars
    local addedCars = 0
    for _, newCar in pairs(newCarNames) do
        if not table.find(originalCars, newCar) then
            addedCars = addedCars + 1
            print("➕ NEW: " .. newCar)
        end
    end
    
    -- Final report
    print("\n" .. string.rep("=", 60))
    print("DUPLICATION REPORT")
    print(string.rep("=", 60))
    print("Original cars: " .. #originalCars)
    print("Current cars: " .. #newCarNames)
    print("New cars detected: " .. addedCars)
    
    if addedCars > 0 then
        print("\n🎉 SUCCESS! " .. addedCars .. " new cars added!")
        print("Check your garage/inventory!")
    else
        print("\n⚠️ No new cars detected.")
        print("Possible reasons:")
        print("1. Server validation is rejecting requests")
        print("2. Need to wait longer for sync")
        print("3. Cars might be in different location")
        print("4. Game requires specific arguments")
    end
    
    isDuplicating = false
    return addedCars > 0
end

-- ===== STEP 5: SMART UI =====
local function createSmartUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CarDuplicatorUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 ADVANCED CAR DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = mainFrame
    
    -- Status display
    local status = Instance.new("TextLabel")
    status.Text = "Ready to scan your cars..."
    status.Size = UDim2.new(1, -20, 0, 200)
    status.Position = UDim2.new(0, 10, 0, 60)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextYAlignment = Enum.TextYAlignment.Top
    status.Parent = mainFrame
    
    -- Buttons
    local buttons = {
        {
            Text = "🔍 SCAN CARS",
            Position = UDim2.new(0, 20, 0, 270),
            Color = Color3.fromRGB(50, 150, 255),
            Action = function()
                status.Text = "Scanning for your cars..."
                task.spawn(function()
                    local cars = findAllOwnedCars()
                    if #cars > 0 then
                        local carList = "Found " .. #cars .. " cars:\n\n"
                        for i, car in ipairs(cars) do
                            if i <= 8 then  -- Show first 8
                                carList = carList .. "• " .. car.Name .. "\n"
                            end
                        end
                        if #cars > 8 then
                            carList = carList .. "... and " .. (#cars - 8) .. " more\n"
                        end
                        status.Text = carList
                    else
                        status.Text = "❌ No cars found!\n\nBuy at least one car\nfrom the store first."
                    end
                end)
            end
        },
        {
            Text = "🚀 AUTO-DUPLICATE",
            Position = UDim2.new(0, 20, 0, 320),
            Color = Color3.fromRGB(0, 200, 100),
            Action = function()
                if isDuplicating then
                    status.Text = "Already duplicating...\nPlease wait."
                    return
                end
                
                status.Text = "🚀 Starting auto-duplication...\n\nThis may take 10-15 seconds.\nPlease wait..."
                
                task.spawn(function()
                    local success = duplicateAllCars()
                    if success then
                        status.Text = "✅ DUPLICATION SUCCESS!\n\nCheck your garage/inventory\nfor new cars!"
                    else
                        status.Text = "⚠️ Duplication attempted.\n\nIf no new cars appear:\n1. Buy cars first\n2. Try again\n3. Check garage"
                    end
                end)
            end
        },
        {
            Text = "🔄 QUICK DUPE",
            Position = UDim2.new(0, 20, 0, 370),
            Color = Color3.fromRGB(255, 150, 0),
            Action = function()
                status.Text = "Quick duplication in progress..."
                task.spawn(function()
                    -- Quick single car duplication
                    local cars = findAllOwnedCars()
                    if #cars > 0 then
                        local carName = cars[1].Name
                        status.Text = "Duplicating: " .. carName
                        
                        -- Try common events
                        local events = {"BuyCar", "AddCar", "SpawnCar", "DuplicateCar"}
                        for _, eventName in pairs(events) do
                            local event = ReplicatedStorage:FindFirstChild(eventName)
                            if event then
                                pcall(function()
                                    event:FireServer(carName)
                                    print("Quick dupe: " .. eventName)
                                end)
                            end
                        end
                        
                        task.wait(1)
                        status.Text = "✅ Quick dupe attempted!\nCheck for new " .. carName
                    else
                        status.Text = "No cars to duplicate!"
                    end
                end)
            end
        }
    }
    
    for _, btn in pairs(buttons) do
        local button = Instance.new("TextButton")
        button.Text = btn.Text
        button.Size = UDim2.new(1, -40, 0, 40)
        button.Position = btn.Position
        button.BackgroundColor3 = btn.Color
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.Parent = mainFrame
        
        button.MouseButton1Click:Connect(btn.Action)
        
        -- Add corner
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button
    end
    
    -- Add corner to main frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    return screenGui, status
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 60))
print("🚗 ADVANCED CAR DUPLICATOR READY")
print(string.rep("=", 60))

-- Create UI
task.wait(1)
local ui, statusText = createSmartUI()

-- Auto-scan after 3 seconds
task.wait(3)
statusText.Text = "Auto-scanning for cars..."
task.wait(1)

local cars = findAllOwnedCars()
if #cars > 0 then
    statusText.Text = "✅ Ready!\n\nFound " .. #cars .. " cars.\nClick 'AUTO-DUPLICATE' to begin."
else
    statusText.Text = "⚠️ No cars detected.\n\nPlease buy at least one car\nfrom the store first.\nThen click 'SCAN CARS'."
end

print("\n📱 UI created! Use the buttons to:")
print("1. Scan for your current cars")
print("2. Auto-duplicate all cars")
print("3. Quick duplication")
print("\n" .. string.rep("=", 60))
