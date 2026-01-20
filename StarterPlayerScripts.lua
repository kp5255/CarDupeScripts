-- 🚀 MAXIMUM STATE - PERFECT SCRIPT
print("🚀 MAXIMUM STATE ACTIVATED")
print("=" .. string.rep("=", 50))

-- SAFE FUNCTION WRAPPERS
local function safeCall(func, ...)
    local args = {...}
    return pcall(function()
        return func(unpack(args))
    end)
end

local function safeGetProperty(obj, prop)
    local success, value = pcall(function()
        return obj[prop]
    end)
    return success, value
end

-- GET TRADING FOLDER
local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes

-- FIND SESSIONADDITEM REMOTE
local sessionAddItem = tradingFolder:WaitForChild("SessionAddItem")
print("✅ Target Remote: SessionAddItem")

-- DISCOVER THE REAL ITEM DATA
print("\n🔍 DISCOVERING REAL ITEM DATA...")

-- Method 1: Find car in inventory via UI
local function findCarInInventory()
    local Player = game:GetService("Players").LocalPlayer
    local success, PlayerGui = safeCall(function() return Player:WaitForChild("PlayerGui") end)
    
    if success and PlayerGui then
        -- Search all ScreenGuis
        for _, gui in pairs(PlayerGui:GetChildren()) do
            local guiSuccess, isScreenGui = safeCall(function() return gui:IsA("ScreenGui") end)
            
            if guiSuccess and isScreenGui then
                local enabledSuccess, isEnabled = safeCall(function() return gui.Enabled end)
                
                if enabledSuccess and isEnabled then
                    -- Search for car elements
                    for _, descendant in pairs(gui:GetDescendants()) do
                        -- Check if it's a button
                        local isButtonSuccess, isButton = safeCall(function() 
                            return descendant:IsA("TextButton") or descendant:IsA("ImageButton") 
                        end)
                        
                        if isButtonSuccess and isButton then
                            -- Check name without causing errors
                            local nameSuccess, name = safeCall(function() return descendant.Name end)
                            local nameLower = nameSuccess and name:lower() or ""
                            
                            -- Check for car indicators
                            if nameLower:find("aston") or nameLower:find("martin") or 
                               nameLower:find("vehicle") or nameLower:find("car") then
                                
                                print("\n🎯 FOUND CAR BUTTON: " .. name)
                                
                                -- Get all attributes safely
                                local attributes = {"ItemId", "ID", "Id", "itemId", "AssetId", "ProductId", "Item"}
                                for _, attr in pairs(attributes) do
                                    local attrSuccess, value = safeCall(function() 
                                        return descendant:GetAttribute(attr) 
                                    end)
                                    
                                    if attrSuccess and value then
                                        print("  📍 " .. attr .. ": " .. tostring(value))
                                        
                                        -- TEST THIS VALUE IMMEDIATELY
                                        print("  🧪 Testing value: " .. tostring(value))
                                        
                                        -- Test as string
                                        local test1Success, test1Result = safeCall(function()
                                            return sessionAddItem:InvokeServer(value)
                                        end)
                                        if test1Success then print("    String result: " .. tostring(test1Result)) end
                                        
                                        -- Test as table
                                        local test2Success, test2Result = safeCall(function()
                                            return sessionAddItem:InvokeServer({ItemId = value})
                                        end)
                                        if test2Success then print("    Table result: " .. tostring(test2Result)) end
                                        
                                        task.wait(0.2)
                                    end
                                end
                                
                                -- Try to click the button
                                for click = 1, 3 do
                                    safeCall(function()
                                        descendant:Fire("Activated")
                                        print("  ✅ Clicked " .. click .. " times")
                                    end)
                                    task.wait(0.3)
                                end
                                
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    
    return false
end

-- Method 2: Search game for car data
local function searchGameForCarData()
    print("\n🔍 SEARCHING GAME DATA...")
    
    -- Check common locations for car data
    local locations = {
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedStorage"):FindFirstChild("Assets"),
        game:GetService("ReplicatedStorage"):FindFirstChild("Items"),
        game:GetService("ReplicatedStorage"):FindFirstChild("Vehicles"),
        game:GetService("ReplicatedStorage"):FindFirstChild("Cars"),
        game:GetService("ReplicatedStorage"):FindFirstChild("Data")
    }
    
    for _, location in pairs(locations) do
        if location then
            for _, item in pairs(location:GetDescendants()) do
                local nameSuccess, name = safeCall(function() return item.Name end)
                local nameLower = nameSuccess and name:lower() or ""
                
                if nameLower:find("aston") or nameLower:find("martin") then
                    print("🎯 Found car reference: " .. item:GetFullName())
                    
                    -- Check if it has a Value property
                    local valueSuccess, value = safeCall(function() return item.Value end)
                    if valueSuccess and value then
                        print("  Value: " .. tostring(value))
                        
                        -- Test this value
                        safeCall(function()
                            sessionAddItem:InvokeServer(value)
                            print("  ✅ Tested value")
                        end)
                        
                        safeCall(function()
                            sessionAddItem:InvokeServer({ItemId = value})
                            print("  ✅ Tested as ItemId")
                        end)
                    end
                end
            end
        end
    end
end

-- Method 3: Intelligent pattern testing
local function intelligentPatternTest()
    print("\n🤖 INTELLIGENT PATTERN TESTING...")
    
    -- Common item ID patterns in games
    local patterns = {}
    
    -- Pattern 1: Vehicle ID patterns
    for i = 1000, 1100 do
        table.insert(patterns, tostring(i))  -- Just number
        table.insert(patterns, "Vehicle_" .. i)
        table.insert(patterns, "Car_" .. i)
        table.insert(patterns, "V" .. i)
    end
    
    -- Pattern 2: Aston Martin specific
    local astonPatterns = {
        "AstonMartin12", "AM12", "Aston_Martin_12", "AstonMartin",
        "Aston", "Martin", "Aston12", "Martin12"
    }
    
    for _, pattern in pairs(astonPatterns) do
        table.insert(patterns, pattern)
        table.insert(patterns, pattern:lower())
        table.insert(patterns, pattern:upper())
    end
    
    -- Pattern 3: Try common item IDs from other games
    local commonIds = {"1001", "1002", "1003", "1010", "1020", "1030", "1100", "1200", "1300"}
    for _, id in pairs(commonIds) do
        table.insert(patterns, id)
    end
    
    -- Test all patterns
    local tested = 0
    for _, pattern in pairs(patterns) do
        if tested >= 50 then break end  -- Limit tests
        
        print("Testing: " .. pattern)
        
        -- Test as string
        local success1, result1 = safeCall(function()
            return sessionAddItem:InvokeServer(pattern)
        end)
        if success1 then print("  String: " .. tostring(result1)) end
        
        -- Test as table with ItemId
        local success2, result2 = safeCall(function()
            return sessionAddItem:InvokeServer({ItemId = pattern})
        end)
        if success2 then print("  Table: " .. tostring(result2)) end
        
        -- Test as table with ID
        local success3, result3 = safeCall(function()
            return sessionAddItem:InvokeServer({ID = pattern})
        end)
        if success3 then print("  ID: " .. tostring(result3)) end
        
        tested = tested + 1
        task.wait(0.05)  -- Fast but safe
    end
    
    print("\n✅ Tested " .. tested .. " patterns")
end

-- EXECUTE ALL METHODS
print("\n" .. string.rep("⚡", 40))
print("EXECUTING MAXIMUM STATE SCAN...")
print(string.rep("⚡", 40))

-- Run method 1: Find in inventory
print("\n🔍 METHOD 1: Inventory Scan...")
findCarInInventory()

-- Run method 2: Game data scan
print("\n🔍 METHOD 2: Game Data Scan...")
searchGameForCarData()

-- Run method 3: Pattern testing
print("\n🔍 METHOD 3: Pattern Testing...")
intelligentPatternTest()

-- CREATE FINAL SOLUTION
print("\n" .. string.rep("🚀", 40))
print("CREATING FINAL SOLUTION...")
print(string.rep("🚀", 40))

-- Universal add function that works with any data
local function universalAdd(itemData, count)
    count = count or 1
    
    if not itemData then
        -- If no data provided, use discovered data
        print("⚠️ No item data provided")
        print("Trying default patterns...")
        
        local defaultTests = {
            "AstonMartin12",
            {ItemId = "AstonMartin12"},
            "1001", {ItemId = "1001"},
            "1010", {ItemId = "1010"}
        }
        
        for _, testData in pairs(defaultTests) do
            print("Testing: " .. tostring(testData))
            local success, result = safeCall(function()
                return sessionAddItem:InvokeServer(testData)
            end)
            
            if success then
                print("Result: " .. tostring(result))
                if result == true then
                    itemData = testData
                    break
                end
            end
            task.wait(0.1)
        end
    end
    
    if itemData then
        print("\n📦 Adding " .. count .. " items...")
        local added = 0
        
        for i = 1, count do
            print("[" .. i .. "/" .. count .. "]")
            
            local success, result = safeCall(function()
                return sessionAddItem:InvokeServer(itemData)
            end)
            
            if success then
                print("  Result: " .. tostring(result))
                if result == true then
                    added = added + 1
                end
            else
                print("  Error: " .. tostring(result))
            end
            
            task.wait(0.3)
        end
        
        print("\n✅ Added " .. added .. "/" .. count .. " items")
        return added
    else
        print("❌ No valid item data found")
        return 0
    end
end

-- Export to global environment
getgenv().MaximumTrade = {
    -- Basic functions
    add1 = function() return universalAdd(nil, 1) end,
    add5 = function() return universalAdd(nil, 5) end,
    add10 = function() return universalAdd(nil, 10) end,
    
    -- Advanced functions
    add = function(count, data) 
        if type(count) == "table" then
            -- If first arg is data
            return universalAdd(count, data or 5)
        else
            return universalAdd(data, count or 5)
        end
    end,
    
    -- Discovery functions
    findCar = findCarInInventory,
    scanGame = searchGameForCarData,
    testPatterns = intelligentPatternTest,
    
    -- Direct call
    test = function(data)
        print("Testing data: " .. tostring(data))
        local success, result = safeCall(function()
            return sessionAddItem:InvokeServer(data)
        end)
        print("Success: " .. tostring(success))
        print("Result: " .. tostring(result))
        return success, result
    end
}

-- Display controls
print("\n" .. string.rep("🎮", 40))
print("MAXIMUM STATE CONTROLS:")
print(string.rep("🎮", 40))
print("MaximumTrade.add1()       - Add 1 item")
print("MaximumTrade.add5()       - Add 5 items")
print("MaximumTrade.add10()      - Add 10 items")
print("MaximumTrade.add(20)      - Add 20 items")
print("MaximumTrade.findCar()    - Find car in inventory")
print("MaximumTrade.scanGame()   - Scan game for car data")
print("MaximumTrade.test(data)   - Test specific data")
print(string.rep("🎮", 40))

-- Auto-run
print("\n🧪 AUTO-RUNNING TESTS...")
task.wait(1)
MaximumTrade.add1()

-- FINAL MESSAGE
print("\n" .. string.rep("=", 60))
print("🚀 MAXIMUM STATE COMPLETE")
print(string.rep("=", 60))

print("\n📊 DIAGNOSIS:")
print("The error 'Invalid item type' means:")
print("1. We need the EXACT item ID/data")
print("2. 'AstonMartin12' is NOT the correct format")
print("3. The real data is likely a NUMBER or specific TABLE")

print("\n🎯 NEXT STEP:")
print("1. Open your inventory")
print("2. Click the Aston Martin")
print("3. Tell me EXACTLY what happens")
print("4. OR check the button for ItemId attribute")
print("\nExample: If you see 'ItemId: 1001' on the button,")
print("use: MaximumTrade.test(1001)")
print("or: MaximumTrade.test({ItemId = 1001})")
