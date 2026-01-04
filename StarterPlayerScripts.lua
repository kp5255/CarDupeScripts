-- 🔍 REAL CAR ID DISCOVERY SCRIPT
-- Place ID: 1554960397

print("🔍 REAL CAR ID DISCOVERY")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== FIND ALL CAR DATA IN GAME =====
local function discoverRealCarIds()
    print("\n🔍 DISCOVERING REAL CAR IDs")
    
    -- Look for car databases, catalogs, shops
    local carDataFound = {}
    
    -- 1. Check ReplicatedStorage for car catalogs
    print("\n📦 Checking ReplicatedStorage...")
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Folder") and obj.Name:lower():find("car") then
            print("Found car folder: " .. obj.Name)
            for _, item in pairs(obj:GetChildren()) do
                print("  - " .. item.Name .. " (" .. item.ClassName .. ")")
                if item:IsA("Configuration") or item:IsA("ModuleScript") then
                    table.insert(carDataFound, {
                        Path = obj:GetFullName(),
                        Name = item.Name,
                        Type = "Catalog"
                    })
                end
            end
        end
    end
    
    -- 2. Check for car shop data
    print("\n🏪 Checking car shop data...")
    local shopModules = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local name = obj.Name:lower()
            if name:find("shop") or name:find("store") or name:find("catalog") then
                table.insert(shopModules, obj)
                print("Found shop module: " .. obj.Name)
            end
        end
    end
    
    -- Try to load shop modules
    for _, module in pairs(shopModules) do
        local success, moduleTable = pcall(function()
            return require(module)
        end)
        
        if success and type(moduleTable) == "table" then
            print("\n✅ Loaded shop module: " .. module.Name)
            
            -- Look for car lists
            for key, value in pairs(moduleTable) do
                if type(value) == "table" then
                    -- Check if it's a car list
                    if key:lower():find("car") or key:lower():find("vehicle") then
                        print("Found car table: " .. key)
                        
                        -- Display first few cars
                        local count = 0
                        for carKey, carData in pairs(value) do
                            if count < 10 then
                                print("  Car: " .. tostring(carKey))
                                if type(carData) == "table" then
                                    print("    Data: " .. tostring(carData))
                                end
                                count = count + 1
                            end
                        end
                    end
                elseif type(value) == "string" and value:find("Car") then
                    print("Car string: " .. key .. " = " .. value)
                end
            end
        end
    end
    
    -- 3. Look for car spawner/garage data
    print("\n🏢 Checking garage/spawner data...")
    if Workspace:FindFirstChild("Cars") then
        print("Found Cars in Workspace")
        for _, car in pairs(Workspace.Cars:GetChildren()) do
            if car:IsA("Model") then
                print("  Model: " .. car.Name)
                
                -- Check for car ID
                local carId = car:GetAttribute("CarId") or 
                             car:FindFirstChild("CarId") or
                             car:FindFirstChild("ID")
                
                if carId then
                    print("    ID: " .. tostring(carId.Value or carId))
                end
            end
        end
    end
    
    return carDataFound
end

-- ===== TEST WITH DIFFERENT CAR FORMATS =====
local function testAllCarFormats()
    print("\n🧪 TESTING ALL CAR FORMATS")
    
    -- Get GiveCar module
    local giveCarModule = ReplicatedStorage:FindFirstChild("CmdrClient")
    if giveCarModule then
        giveCarModule = giveCarModule:FindFirstChild("Commands")
        if giveCarModule then
            giveCarModule = giveCarModule:FindFirstChild("GiveCar")
        end
    end
    
    if not giveCarModule then
        print("❌ GiveCar module not found")
        return
    end
    
    -- Load module
    local success, moduleFunc = pcall(function()
        return require(giveCarModule)
    end)
    
    if not success then
        print("❌ Failed to load module")
        return
    end
    
    print("✅ GiveCar module loaded")
    
    -- Test MANY different car ID formats
    local testFormats = {
        -- Basic formats
        "bontlay_bontaga",
        "bontlaybontaga",
        "BontlayBontaga",
        "Bontlay_Bontaga",
        
        -- ID formats
        "car_1",
        "car1",
        "car_001",
        "vehicle_1",
        
        -- Short codes
        "bb",
        "bb1",
        "bontlay",
        "bontaga",
        
        -- Number formats
        "1",
        "100",
        "1000",
        "1001",
        
        -- Shop formats
        "Car_Bontlay_Bontaga",
        "Vehicle_Bontlay_Bontaga",
        "BontlayBontagaCar",
        "BontlayBontagaVehicle",
        
        -- Database formats
        "car_bontlay_bontaga_01",
        "vehicle_bontlay_bontaga_v1",
        "bontlay_bontaga_v1",
        "bb_v1",
        
        -- Try common car IDs
        "lamborghini",
        "ferrari",
        "bugatti",
        "mclaren",
        "porsche",
        "audi",
        "bmw",
        "mercedes",
        
        -- Game-specific
        "hypercar",
        "supercar",
        "sportscar",
        "driftcar",
        
        -- Try your other cars
        "jegar_modelf",
        "jegar_model_f",
        "JegarModelF",
        "jegar",
        
        "corsaro_t8",
        "corsarot8",
        "CorsaroT8",
        "corsaro",
        
        "lavish_ventoge",
        "lavishventoge",
        "LavishVentoge",
        "lavish",
        
        "sportler_tecan",
        "sportlertecan",
        "SportlerTecan",
        "sportler"
    }
    
    print("Testing " .. #testFormats .. " car ID formats...")
    
    local successfulCalls = 0
    
    for _, carId in pairs(testFormats) do
        -- Try to execute
        local callSuccess = pcall(function()
            if type(moduleFunc) == "function" then
                moduleFunc(player, carId)
                return true
            elseif type(moduleFunc) == "table" then
                -- Look for execute function
                for key, func in pairs(moduleFunc) do
                    if type(func) == "function" and key:lower():find("exec") then
                        func(player, carId)
                        return true
                    end
                end
            end
            return false
        end)
        
        if callSuccess then
            print("✅ Called with: " .. carId)
            successfulCalls = successfulCalls + 1
            
            -- Wait a bit between successful calls
            task.wait(0.1)
        end
        
        -- Small delay to avoid rate limits
        task.wait(0.05)
    end
    
    print("\n📊 RESULTS: " .. successfulCalls .. " successful calls out of " .. #testFormats .. " attempts")
    
    if successfulCalls == 0 then
        print("\n❌ NO car IDs worked!")
        print("The module might need specific server-side IDs.")
    end
end

-- ===== FIND CAR DATABASE =====
local function findCarDatabase()
    print("\n🗄️ FINDING CAR DATABASE")
    
    -- Look for DataStore or database modules
    local dataModules = {}
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local name = obj.Name:lower()
            if name:find("data") or name:find("database") or name:find("store") then
                table.insert(dataModules, obj)
            end
        end
    end
    
    print("Found " .. #dataModules .. " data modules")
    
    -- Try to find car IDs in data
    for _, module in pairs(dataModules) do
        local success, moduleTable = pcall(function()
            return require(module)
        end)
        
        if success and type(moduleTable) == "table" then
            -- Look for car definitions
            for key, value in pairs(moduleTable) do
                if type(value) == "table" then
                    -- Check if it contains car data
                    if value.Name and (value.Name:find("Car") or value.Name:find("Vehicle")) then
                        print("Found car definition:")
                        print("  Key: " .. key)
                        for k, v in pairs(value) do
                            print("  " .. k .. ": " .. tostring(v))
                        }
                    end
                    
                    -- Check for car IDs
                    if value.CarId or value.VehicleId or value.ID then
                        print("Found car ID in " .. key .. ": " .. tostring(value.CarId or value.VehicleId or value.ID))
                    end
                end
            end
        end
    end
end

-- ===== BRUTE FORCE NUMERIC IDs =====
local function bruteForceNumericIds()
    print("\n🔢 BRUTE FORCING NUMERIC IDs")
    
    local giveCarModule = ReplicatedStorage:FindFirstChild("CmdrClient")
    if giveCarModule then
        giveCarModule = giveCarModule:FindFirstChild("Commands")
        if giveCarModule then
            giveCarModule = giveCarModule:FindFirstChild("GiveCar")
        end
    end
    
    if not giveCarModule then return end
    
    local success, moduleFunc = pcall(function()
        return require(giveCarModule)
    end)
    
    if not success then return end
    
    print("Testing numeric IDs 1-1000...")
    
    local foundIds = {}
    
    -- Test IDs 1-1000
    for id = 1, 1000 do
        if id % 100 == 0 then
            print("Testing ID " .. id .. "...")
        end
        
        local callSuccess = pcall(function()
            if type(moduleFunc) == "function" then
                moduleFunc(player, tostring(id))
                return true
            elseif type(moduleFunc) == "table" then
                for key, func in pairs(moduleFunc) do
                    if type(func) == "function" and key:lower():find("exec") then
                        func(player, tostring(id))
                        return true
                    end
                end
            end
            return false
        end)
        
        if callSuccess then
            table.insert(foundIds, id)
            print("✅ ID " .. id .. " accepted!")
        end
        
        task.wait(0.01) -- Fast but not too fast
    end
    
    print("\n📊 NUMERIC ID RESULTS:")
    if #foundIds > 0 then
        print("Found " .. #foundIds .. " working IDs:")
        for _, id in pairs(foundIds) do
            print("  ID: " .. id)
        end
    else
        print("❌ No numeric IDs worked")
    end
end

-- ===== CREATE DISCOVERY UI =====
local function createDiscoveryUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 400)
    frame.Position = UDim2.new(0.5, -200, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🔍 REAL CAR ID DISCOVERY"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local status = Instance.new("ScrollingFrame")
    status.Size = UDim2.new(1, -20, 0, 200)
    status.Position = UDim2.new(0, 10, 0, 60)
    status.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    status.BorderSizePixel = 0
    status.ScrollBarThickness = 5
    status.Parent = frame
    
    local statusText = Instance.new("TextLabel")
    statusText.Text = "We need to find the REAL car IDs\nthat the server actually uses.\n\n'Bontlay Bontaga' might be just a display name!"
    statusText.Size = UDim2.new(1, 0, 0, 300)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.new(1, 1, 1)
    statusText.Font = Enum.Font.Code
    statusText.TextSize = 14
    statusText.TextWrapped = true
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextYAlignment = Enum.TextYAlignment.Top
    statusText.Parent = status
    
    -- Buttons
    local buttons = {
        {
            Text = "🔍 DISCOVER CAR DATA",
            Y = 270,
            Action = function()
                statusText.Text = "Discovering car data...\nCheck F9 console!"
                task.spawn(function()
                    discoverRealCarIds()
                    statusText.Text = statusText.Text .. "\n\n✅ Discovery complete!\nCheck F9 for found data."
                end)
            end
        },
        {
            Text = "🧪 TEST ALL FORMATS",
            Y = 320,
            Action = function()
                statusText.Text = "Testing all car ID formats...\nThis may take 10 seconds.\nCheck F9!"
                task.spawn(function()
                    testAllCarFormats()
                    statusText.Text = statusText.Text .. "\n\n✅ Format testing complete!"
                end)
            end
        },
        {
            Text = "🔢 BRUTE FORCE IDs",
            Y = 370,
            Action = function()
                statusText.Text = "Brute forcing numeric IDs 1-1000...\nThis will take 15-20 seconds.\nCheck F9!"
                task.spawn(function()
                    bruteForceNumericIds()
                    statusText.Text = statusText.Text .. "\n\n✅ Brute force complete!"
                end)
            end
        }
    }
    
    for _, btn in pairs(buttons) do
        local button = Instance.new("TextButton")
        button.Text = btn.Text
        button.Size = UDim2.new(1, -40, 0, 40)
        button.Position = UDim2.new(0, 20, 0, btn.Y)
        button.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.Parent = frame
        
        button.MouseButton1Click:Connect(btn.Action)
    end
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 5)
    statusCorner.Parent = status
    
    return gui, statusText
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 70))
print("🔍 REAL CAR ID DISCOVERY")
print(string.rep("=", 70))
print("\nCRITICAL INSIGHT:")
print("'Bontlay Bontaga' might be DISPLAY NAME only!")
print("The server uses DIFFERENT internal IDs.")
print("\nThis script will find REAL car IDs.")

-- Create UI
task.wait(1)
local gui, statusText = createDiscoveryUI()

-- Auto-start discovery
task.wait(3)
statusText.Text = "Auto-starting car ID discovery...\nCheck F9 console!"

print("\n🚀 AUTO-DISCOVERING REAL CAR IDs...")

-- Step 1: Discover car data
discoverRealCarIds()

-- Step 2: Test all formats
task.wait(2)
testAllCarFormats()

-- Step 3: Find database
task.wait(2)
findCarDatabase()

-- Step 4: Brute force
task.wait(2)
print("\n🚀 STARTING BRUTE FORCE...")
bruteForceNumericIds()

-- Final analysis
task.wait(3)
print("\n" .. string.rep("=", 70))
print("📊 DISCOVERY COMPLETE")
print(string.rep("=", 70))

statusText.Text = "✅ Discovery complete!\n\nIf no car IDs were found:\n1. Server uses complex IDs\n2. IDs might be in ServerStorage\n3. Need to decompile game\n\nCheck F9 for any found IDs!"

print("\n💡 NEXT STEPS:")
print("1. Check F9 for ANY successful calls")
print("2. Look for patterns in successful IDs")
print("3. Try IDs that the game ACCEPTED")
print("4. If none worked, IDs are server-side only")
