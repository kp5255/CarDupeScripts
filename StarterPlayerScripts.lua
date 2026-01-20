-- 🔍 FIND EXACT ITEM TYPE
-- Tests ALL possible item types to find the right one

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

print("=== FINDING EXACT ITEM TYPE ===")

-- Get the remote
local tradingRemote = RS.Remotes.Services.TradingServiceRemotes.SessionAddItem
print("✅ Remote: SessionAddItem")

-- ===== TEST ALL POSSIBLE ITEM TYPES =====
local function TestItemType(itemType)
    local testData = {
        ItemId = "AstonMartin12",
        itemType = itemType
    }
    
    print("\n🧪 Testing itemType: '" .. itemType .. "'")
    
    local success, result = pcall(function()
        return tradingRemote:InvokeServer(testData)
    end)
    
    if success then
        print("✅ SUCCESS! Result:", result)
        return true, result, testData
    else
        print("❌ Failed:", result)
        return false, result
    end
end

-- ===== ALL POSSIBLE ITEM TYPES =====
local itemTypesToTest = {
    -- Common car/vehicle types
    "Car", "Vehicle", "Automobile", "Automotive",
    "Ride", "Drive", "Motor", "Engine",
    
    -- Try with different capitalization
    "car", "vehicle", "automobile",
    "CAR", "VEHICLE", "AUTOMOBILE",
    
    -- Game-specific types
    "Rideable", "Driveable", "Movable",
    "Transport", "Transportation",
    
    -- Try numeric types
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
    
    -- Try type IDs
    "Type1", "Type2", "Type3", "TypeCar", "TypeVehicle",
    
    -- Try category names
    "CategoryCar", "CategoryVehicle", "Category1",
    
    -- Try nothing/null
    "", nil,
    
    -- Try boolean
    true, false,
    
    -- Try with spaces
    "Car Type", "Vehicle Type", "Auto Mobile",
    
    -- Try abbreviations
    "Veh", "Auto", "Ride", "Mov",
    
    -- Try plural
    "Cars", "Vehicles", "Automobiles",
    
    -- Try with underscore
    "Car_Type", "Vehicle_Type", "Auto_Vehicle",
    
    -- Try with hyphen
    "Car-Type", "Vehicle-Type",
    
    -- Try property names
    "PropertyCar", "PropertyVehicle",
    
    -- Try class names
    "ClassCar", "ClassVehicle",
    
    -- Try other common game item types
    "Part", "Model", "Tool", "Weapon", "Item", "Product", "Asset"
}

-- ===== TEST DIFFERENT KEY NAMES =====
local function TestKeyCombinations()
    print("\n🔑 TESTING DIFFERENT KEY NAMES...")
    
    local keyCombinations = {
        -- Original
        {idKey = "ItemId", typeKey = "itemType"},
        
        -- Different capitalizations
        {idKey = "itemId", typeKey = "itemType"},
        {idKey = "itemid", typeKey = "itemtype"},
        {idKey = "ItemID", typeKey = "ItemType"},
        
        -- Different key names
        {idKey = "id", typeKey = "type"},
        {idKey = "Id", typeKey = "Type"},
        {idKey = "ID", typeKey = "TYPE"},
        
        {idKey = "name", typeKey = "category"},
        {idKey = "Name", typeKey = "Category"},
        
        {idKey = "item", typeKey = "kind"},
        {idKey = "Item", typeKey = "Kind"},
        
        {idKey = "productId", typeKey = "productType"},
        {idKey = "ProductId", typeKey = "ProductType"},
        
        {idKey = "assetId", typeKey = "assetType"},
        {idKey = "AssetId", typeKey = "AssetType"}
    }
    
    -- Common type values to test with each key combo
    local typeValues = {"Car", "Vehicle", "1", "car", "vehicle"}
    
    for _, keys in ipairs(keyCombinations) do
        for _, typeValue in ipairs(typeValues) do
            local testData = {}
            testData[keys.idKey] = "AstonMartin12"
            testData[keys.typeKey] = typeValue
            
            print("\n🔧 Testing: " .. keys.idKey .. " + " .. keys.typeKey .. " = '" .. typeValue .. "'")
            
            local success, result = pcall(function()
                return tradingRemote:InvokeServer(testData)
            end)
            
            if success then
                print("✅ SUCCESS! Format found!")
                print("Data:", testData)
                return true, testData
            end
        end
    end
    
    return false, nil
end

-- ===== TEST WITHOUT ITEM TYPE =====
local function TestWithoutItemType()
    print("\n🎯 TESTING WITHOUT ITEM TYPE...")
    
    -- Try just ItemId
    print("1. Just ItemId string...")
    local success1, result1 = pcall(function()
        return tradingRemote:InvokeServer("AstonMartin12")
    end)
    
    if success1 then
        print("✅ Success with just string!")
        return true, "AstonMartin12"
    end
    
    -- Try table with only ItemId
    print("2. Table with only ItemId...")
    local testData2 = {ItemId = "AstonMartin12"}
    local success2, result2 = pcall(function()
        return tradingRemote:InvokeServer(testData2)
    end)
    
    if success2 then
        print("✅ Success with table!")
        return true, testData2
    end
    
    return false, nil
end

-- ===== TEST WITH DIFFERENT ITEM ID FORMATS =====
local function TestDifferentItemIdFormats()
    print("\n🔍 TESTING DIFFERENT ITEM ID FORMATS...")
    
    local itemIdFormats = {
        "AstonMartin12",
        "Car-AstonMartin12",
        "astonmartin12",
        "ASTONMARTIN12",
        "Aston Martin 12",
        "aston_martin_12",
        "aston-martin-12",
        
        -- Try numeric
        "123456", "1001", "999",
        
        -- Try with prefix
        "item_astonmartin12", "product_astonmartin12",
        
        -- Try from your original success
        "Car-AstonMartin12"  -- From earlier script
    }
    
    for _, itemId in ipairs(itemIdFormats) do
        print("\n🔄 Testing ItemId: '" .. itemId .. "'")
        
        -- Try with itemType = "Car"
        local testData1 = {ItemId = itemId, itemType = "Car"}
        local success1 = pcall(function()
            return tradingRemote:InvokeServer(testData1)
        end)
        
        if success1 then
            print("✅ Success with itemType='Car'!")
            return true, testData1
        end
        
        -- Try with itemType = "Vehicle"
        local testData2 = {ItemId = itemId, itemType = "Vehicle"}
        local success2 = pcall(function()
            return tradingRemote:InvokeServer(testData2)
        end)
        
        if success2 then
            print("✅ Success with itemType='Vehicle'!")
            return true, testData2
        end
    end
    
    return false, nil
end

-- ===== CAPTURE MANUAL CLICK =====
local function CaptureManualClick()
    print("\n👀 CAPTURE MANUAL CLICK")
    print("========================")
    print("1. I will hook the remote")
    print("2. YOU click AstonMartin12 in your inventory")
    print("3. I will capture EXACT format")
    print("========================")
    
    local originalInvoke = tradingRemote.InvokeServer
    local capturedData = nil
    
    tradingRemote.InvokeServer = function(self, ...)
        local args = {...}
        capturedData = args[1]
        
        print("\n🎯 MANUAL CLICK CAPTURED!")
        print("Data type:", type(capturedData))
        
        if type(capturedData) == "table" then
            print("📋 Table contents:")
            for k, v in pairs(capturedData) do
                print("  " .. tostring(k) .. " = " .. tostring(v))
            end
        else
            print("Value:", capturedData)
        end
        
        return originalInvoke(self, ...)
    end
    
    print("\n✅ Hook installed!")
    print("Now click AstonMartin12 in your inventory...")
    print("(Wait for 'CAPTURED' message)")
    
    -- Wait for click
    for i = 1, 30 do
        task.wait(1)
        if capturedData then
            print("\n✅ Format captured successfully!")
            return capturedData
        end
        if i % 5 == 0 then
            print("Waiting... (" .. i .. "/30)")
        end
    end
    
    print("\n❌ No click captured")
    return nil
end

-- ===== MAIN TEST SEQUENCE =====
print("\n🚀 STARTING COMPREHENSIVE TEST...")

local foundFormat = nil

-- Step 1: Test without item type
print("\n" .. string.rep("=", 50))
print("STEP 1: Testing without itemType")
print(string.rep("=", 50))

local success1, format1 = TestWithoutItemType()
if success1 then
    foundFormat = format1
    print("🎉 Found working format (no itemType)!")
end

-- Step 2: Test different ItemId formats
if not foundFormat then
    print("\n" .. string.rep("=", 50))
    print("STEP 2: Testing different ItemId formats")
    print(string.rep("=", 50))
    
    local success2, format2 = TestDifferentItemIdFormats()
    if success2 then
        foundFormat = format2
        print("🎉 Found working ItemId format!")
    end
end

-- Step 3: Test all item types
if not foundFormat then
    print("\n" .. string.rep("=", 50))
    print("STEP 3: Testing ALL item types")
    print(string.rep("=", 50))
    
    for i, itemType in ipairs(itemTypesToTest) do
        local success, result, data = TestItemType(itemType)
        if success then
            foundFormat = data
            print("\n🎉 FOUND WORKING ITEM TYPE!")
            print("itemType = '" .. tostring(itemType) .. "'")
            break
        end
        
        -- Pause every 5 tests
        if i % 5 == 0 then
            task.wait(0.5)
        end
    end
end

-- Step 4: Test key combinations
if not foundFormat then
    print("\n" .. string.rep("=", 50))
    print("STEP 4: Testing different key names")
    print(string.rep("=", 50))
    
    local success4, format4 = TestKeyCombinations()
    if success4 then
        foundFormat = format4
        print("🎉 Found working key combination!")
    end
end

-- Step 5: Capture manual click
if not foundFormat then
    print("\n" .. string.rep("=", 50))
    print("STEP 5: Capturing manual click")
    print(string.rep("=", 50))
    
    foundFormat = CaptureManualClick()
end

-- ===== FINAL RESULT =====
print("\n" .. string.rep("=", 60))
print("📊 TEST RESULTS")
print(string.rep("=", 60))

if foundFormat then
    print("✅ SUCCESS! Found working format!")
    print("🎯 Use this exact format:")
    
    if type(foundFormat) == "table" then
        print("{")
        for k, v in pairs(foundFormat) do
            print("  " .. tostring(k) .. " = " .. tostring(v))
        end
        print("}")
    else
        print('"' .. tostring(foundFormat) .. '"')
    end
    
    -- Create simple bot with found format
    print("\n🚀 CREATING WORKING BOT...")
    
    local function CreateWorkingBot(correctData)
        return function(quantity)
            print("\n📦 Adding " .. quantity .. " items...")
            
            local successCount = 0
            for i = 1, quantity do
                print("[" .. i .. "/" .. quantity .. "] Adding...")
                
                local success = pcall(function()
                    if type(correctData) == "table" then
                        return tradingRemote:InvokeServer(correctData)
                    else
                        return tradingRemote:InvokeServer(correctData)
                    end
                end)
                
                if success then
                    successCount = successCount + 1
                    print("✅ Success!")
                else
                    print("❌ Failed")
                end
                
                task.wait(0.1)
            end
            
            print("\n✅ Added " .. successCount .. "/" .. quantity .. " successfully!")
        end
    end
    
    local bot = CreateWorkingBot(foundFormat)
    
    -- Test with 5 items
    print("\n🧪 Testing with 5 items...")
    bot(5)
    
else
    print("❌ Could not find working format")
    print("💡 Suggestions:")
    print("1. Make sure you're in a trading session")
    print("2. Make sure AstonMartin12 is in your inventory")
    print("3. Try clicking it manually first")
    print("4. Check the exact name in inventory")
end

print(string.rep("=", 60))
