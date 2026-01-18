-- Car Data Analyzer & Trade ID Finder
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== CAR DATA ANALYZER & TRADE ID FINDER ===")

-- Get car service and trading service
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes
local SessionAddItem = tradingService.SessionAddItem

-- Get all owned cars
local function GetOwnedCars()
    print("\n📊 GETTING OWNED CARS...")
    
    local success, carList = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if not success or not carList then
        print("❌ Failed to get car list")
        return {}
    end
    
    print("✅ Found " .. #carList .. " owned cars")
    return carList
end

-- Find AstonMartin8 in the car list
local function FindAstonMartin8(carList)
    print("\n🔍 LOOKING FOR ASTON MARTIN 8...")
    
    for i, carData in ipairs(carList) do
        if type(carData) == "table" then
            -- Check for Aston Martin identification
            local isAstonMartin = false
            local carName = nil
            local carId = nil
            
            -- Look for name/displayName fields
            for fieldName, fieldValue in pairs(carData) do
                if type(fieldValue) == "string" then
                    if fieldValue:find("Aston") or fieldValue:find("Martin") or fieldValue:find("Lavish 077 Ultra") then
                        isAstonMartin = true
                        carName = fieldValue
                    end
                end
                
                -- Look for ID fields (most important!)
                if fieldName:lower():find("id") or fieldName:lower():find("asset") then
                    print("  Found ID field: " .. fieldName .. " = " .. tostring(fieldValue))
                    carId = fieldValue
                end
            end
            
            if isAstonMartin then
                print("\n🎯 FOUND ASTON MARTIN 8!")
                print("Car index: " .. i)
                print("Car name: " .. (carName or "Unknown"))
                print("Car ID: " .. tostring(carId or "Unknown"))
                
                -- Show all fields of this car
                print("\n📋 ALL FIELDS FOR THIS CAR:")
                for fieldName, fieldValue in pairs(carData) do
                    local valueType = type(fieldValue)
                    local displayValue = tostring(fieldValue)
                    
                    if valueType == "string" and #displayValue > 50 then
                        displayValue = displayValue:sub(1, 50) .. "..."
                    end
                    
                    print("  " .. fieldName .. " = " .. displayValue .. " (" .. valueType .. ")")
                end
                
                return carData, carId
            end
        end
    end
    
    print("❌ Aston Martin 8 not found in car list")
    return nil, nil
end

-- Try to trade using the car data
local function TryTradeWithCarData(carData, carId)
    print("\n🔄 ATTEMPTING TO TRADE WITH CAR DATA...")
    
    if not carId then
        print("❌ No car ID found")
        return false
    end
    
    print("Car ID to use: " .. tostring(carId))
    print("Car ID type: " .. type(carId))
    
    -- Try different parameter combinations
    local testCases = {
        -- Direct ID approaches
        {name = "Just car ID", params = {carId}},
        {name = "Car ID as string", params = {tostring(carId)}},
        {name = "Car ID with session", params = {"trade_session", carId}},
        
        -- Table approaches
        {name = "Table with id field", params = {{id = carId}}},
        {name = "Table with carData", params = {carData}},
        {name = "Session + table", params = {"trade_session", {id = carId}}},
        
        -- Special cases
        {name = "CarData as JSON", params = {game:GetService("HttpService"):JSONEncode(carData)}},
    }
    
    -- If carId is a number, also try number formats
    if type(carId) == "number" then
        table.insert(testCases, {name = "Number ID", params = {carId}})
        table.insert(testCases, {name = "Number with quantity", params = {carId, 1}})
    end
    
    local successCount = 0
    
    for i, testCase in ipairs(testCases) do
        print("\nTest " .. i .. ": " .. testCase.name)
        
        local success, result = pcall(function()
            return SessionAddItem:InvokeServer(unpack(testCase.params))
        end)
        
        if success then
            print("✅ SUCCESS!")
            if result then
                print("   Result: " .. tostring(result))
            end
            successCount = successCount + 1
            
            -- Try a few more times
            for j = 1, 3 do
                wait(0.2)
                pcall(function()
                    SessionAddItem:InvokeServer(unpack(testCase.params))
                    print("   Repeated " .. j)
                end)
            end
            
            return true
        else
            print("❌ Failed: " .. tostring(result))
            
            -- Check for specific error patterns
            local errorMsg = tostring(result)
            if errorMsg:find("Invalid item") then
                print("   ⚠️ Wrong item format")
            elseif errorMsg:find("not in inventory") then
                print("   ⚠️ Item not in inventory (wrong ID?)")
            elseif errorMsg:find("session") then
                print("   ⚠️ Session issue")
            end
        end
        
        wait(0.3)
    end
    
    print("\n📊 Results: " .. successCount .. "/" .. #testCases .. " successful")
    return successCount > 0
end

-- Alternative: Find what field is used for trading
local function AnalyzeCarFieldsForTrading(carList)
    print("\n🔬 ANALYZING CAR FIELDS FOR TRADING...")
    
    -- Look at all cars and find common ID fields
    local idFields = {}
    local allFields = {}
    
    for i, carData in ipairs(carList) do
        if type(carData) == "table" then
            for fieldName, fieldValue in pairs(carData) do
                -- Count field occurrences
                allFields[fieldName] = (allFields[fieldName] or 0) + 1
                
                -- Track ID-like fields
                local nameLower = fieldName:lower()
                if nameLower:find("id") or nameLower:find("asset") or nameLower:find("key") then
                    idFields[fieldName] = (idFields[fieldName] or 0) + 1
                end
            end
        end
    end
    
    print("📋 MOST COMMON FIELDS:")
    local sortedFields = {}
    for fieldName, count in pairs(allFields) do
        table.insert(sortedFields, {name = fieldName, count = count})
    end
    
    table.sort(sortedFields, function(a, b) return a.count > b.count end)
    
    for i = 1, math.min(10, #sortedFields) do
        local field = sortedFields[i]
        print(i .. ". " .. field.name .. " (in " .. field.count .. "/" .. #carList .. " cars)")
    end
    
    print("\n🔑 ID-LIKE FIELDS:")
    for fieldName, count in pairs(idFields) do
        print("  " .. fieldName .. " (in " .. count .. " cars)")
    end
    
    return sortedFields, idFields
end

-- Main function
local function FindAndTestTradeId()
    print("\n🚀 FINDING AND TESTING TRADE ID...")
    
    -- Step 1: Get owned cars
    local carList = GetOwnedCars()
    if #carList == 0 then
        print("❌ No cars found")
        return false
    end
    
    -- Step 2: Analyze fields
    wait(1)
    AnalyzeCarFieldsForTrading(carList)
    
    -- Step 3: Find Aston Martin 8
    wait(1)
    local astonData, astonId = FindAstonMartin8(carList)
    
    if not astonData then
        print("\n⚠️ Could not find Aston Martin, trying first car...")
        astonData = carList[1]
        
        -- Find ID in first car
        for fieldName, fieldValue in pairs(astonData) do
            if fieldName:lower():find("id") then
                astonId = fieldValue
                print("Using ID from first car: " .. fieldName .. " = " .. tostring(fieldValue))
                break
            end
        end
    end
    
    -- Step 4: Try to trade
    wait(1)
    if astonData then
        return TryTradeWithCarData(astonData, astonId)
    end
    
    return false
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarTradeFinder"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 200)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "CAR TRADE ID FINDER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    local status = Instance.new("TextLabel")
    status.Text = "Analyzing car data to find trade ID"
    status.Size = UDim2.new(1, -20, 0, 110)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 220, 255)
    status.TextWrapped = true
    
    local button = Instance.new("TextButton")
    button.Text = "🚀 FIND & TEST TRADE ID"
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 170)
    button.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    button.MouseButton1Click:Connect(function()
        status.Text = "Finding car data...\nThis may take a moment"
        button.Text = "ANALYZING..."
        
        spawn(function()
            local success = FindAndTestTradeId()
            
            if success then
                status.Text = "✅ Success!\nCheck other player's screen"
                button.Text = "🎉 DONE"
                button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            else
                status.Text = "❌ Need to see car data output\nShare the output with me"
                button.Text = "🚀 TRY AGAIN"
            end
            
            wait(2)
            button.Text = "🚀 FIND & TEST TRADE ID"
            button.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
        end)
    end)
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    button.Parent = frame
    frame.Parent = gui
    
    return status
end

-- Initialize
CreateUI()

-- Auto-run analysis
wait(3)
print("\n=== CAR TRADE ID FINDER ===")
print("This analyzes your car data to find the correct trade ID")
print("\n📋 WHAT THIS DOES:")
print("1. Gets your owned cars list")
print("2. Finds Aston Martin 8 in your inventory")
print("3. Extracts the REAL item ID")
print("4. Tests it with SessionAddItem")
print("\n🔍 Click 'FIND & TEST TRADE ID' to start!")

spawn(function()
    wait(5)
    print("\n🔍 Starting car analysis...")
    FindAndTestTradeId()
end)
