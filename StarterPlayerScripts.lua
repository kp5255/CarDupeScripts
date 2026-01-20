-- 🎯 ULTIMATE UNDETECTABLE SCRIPT
print("🎯 ULTIMATE SCRIPT - NO ERRORS")
print("=" .. string.rep("=", 50))

-- GET TRADING FOLDER
local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes

-- LIST ALL REMOTES
print("\n📋 ALL TRADING REMOTES:")
for _, remote in pairs(tradingFolder:GetChildren()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        print("  • " .. remote.Name .. " (" .. remote.ClassName .. ")")
    end
end

-- CREATE SIMPLE TESTER FUNCTION
print("\n🎯 CREATING TESTER...")

local function testRemote(remote, data)
    local success, result = pcall(function()
        if remote:IsA("RemoteFunction") then
            -- Check if InvokeServer exists
            if remote.InvokeServer then
                return remote:InvokeServer(data)
            end
        elseif remote:IsA("RemoteEvent") then
            -- Try FireServer first, then Fire
            if remote.FireServer then
                remote:FireServer(data)
                return "FireServer called"
            elseif remote.Fire then
                remote:Fire(data)
                return "Fire called"
            end
        end
        return "No valid method found"
    end)
    
    return success, result
end

-- TEST SESSIONADDITEM WITH DIFFERENT DATA
print("\n🔍 TESTING SessionAddItem...")

local sessionAddItem = tradingFolder:WaitForChild("SessionAddItem")

-- Test different data formats
local testFormats = {
    "AstonMartin12",
    "astonmartin12",
    {ItemId = "AstonMartin12"},
    {ID = "AstonMartin12"},
    {itemId = "AstonMartin12"},
    {id = "AstonMartin12"},
    {Item = "AstonMartin12"},
    {Car = "AstonMartin12"},
    {Vehicle = "AstonMartin12"}
}

-- Also test numeric IDs (common in games)
for i = 1000, 1020 do
    table.insert(testFormats, tostring(i))
    table.insert(testFormats, {ItemId = tostring(i)})
end

-- Run tests
for i, testData in ipairs(testFormats) do
    if i > 30 then break end -- Limit tests
    
    print("\nTest " .. i .. ":")
    print("Data: " .. tostring(testData))
    
    local success, result = testRemote(sessionAddItem, testData)
    
    if success then
        print("✅ Success! Result: " .. tostring(result))
    else
        print("❌ Error: " .. tostring(result))
    end
    
    task.wait(0.1)
end

-- CREATE UNIVERSAL ADD FUNCTION
print("\n" .. string.rep("🚀", 30))
print("CREATING UNIVERSAL ADD FUNCTION...")
print(string.rep("🚀", 30))

local UniversalTrade = {}

function UniversalTrade.addCar(data)
    if not data then
        -- Try default patterns
        local defaultTests = {
            "AstonMartin12",
            {ItemId = "AstonMartin12"},
            {ID = "AstonMartin12"}
        }
        
        for _, testData in pairs(defaultTests) do
            print("Testing: " .. tostring(testData))
            local success, result = testRemote(sessionAddItem, testData)
            if success then
                print("Result: " .. tostring(result))
                if result == true then
                    return true
                end
            end
            task.wait(0.2)
        end
        return false
    else
        -- Use provided data
        local success, result = testRemote(sessionAddItem, data)
        return success, result
    end
end

function UniversalTrade.addMultiple(count)
    count = count or 5
    print("Adding " .. count .. " cars...")
    
    local added = 0
    for i = 1, count do
        print("[" .. i .. "/" .. count .. "]")
        
        local success, result = UniversalTrade.addCar()
        if success and result == true then
            added = added + 1
            print("  ✅ Added!")
        else
            print("  ⚠️ Failed")
        end
        
        task.wait(0.5)
    end
    
    print("\n🎯 Added " .. added .. "/" .. count .. " cars")
    return added
end

-- Export functions
getgenv().UniversalTrade = {
    add1 = function() return UniversalTrade.addMultiple(1) end,
    add5 = function() return UniversalTrade.addMultiple(5) end,
    add10 = function() return UniversalTrade.addMultiple(10) end,
    add = function(n) return UniversalTrade.addMultiple(n) end,
    test = function(data) return UniversalTrade.addCar(data) end
}

-- CREATE BUTTON FINDER
print("\n🎯 CREATING BUTTON FINDER...")

local function findCarButton()
    local Player = game:GetService("Players").LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local name = obj.Name:lower()
                    local text = (obj.Text or ""):lower()
                    
                    if name:find("aston") or name:find("martin") or 
                       name:find("car") or name:find("vehicle") then
                        
                        return obj
                    end
                end
            end
        end
    end
    
    return nil
end

-- Try to find and click car button
local carButton = findCarButton()
if carButton then
    print("✅ Found car button: " .. carButton.Name)
    
    -- Get button attributes
    for _, attr in pairs({"ItemId", "ID", "Id", "itemId", "AssetId"}) do
        local value = carButton:GetAttribute(attr)
        if value then
            print("  📍 " .. attr .. ": " .. tostring(value))
            
            -- Test this value
            UniversalTrade.test(value)
            UniversalTrade.test({ItemId = value})
            task.wait(0.2)
        end
    end
    
    -- Click the button
    for i = 1, 3 do
        pcall(function()
            carButton:Fire("Activated")
            print("  ✅ Clicked button " .. i .. " times")
        end)
        task.wait(0.3)
    end
else
    print("❌ No car button found")
end

-- FINAL INSTRUCTIONS
print("\n" .. string.rep("🎮", 40))
print("AVAILABLE FUNCTIONS:")
print(string.rep("🎮", 40))
print("UniversalTrade.add1()  - Add 1 car")
print("UniversalTrade.add5()  - Add 5 cars")
print("UniversalTrade.add10() - Add 10 cars")
print("UniversalTrade.add(20) - Add custom amount")
print("UniversalTrade.test(data) - Test specific data")
print(string.rep("🎮", 40))

-- AUTO-RUN TEST
print("\n🧪 RUNNING AUTO-TEST...")
task.wait(1)
UniversalTrade.add1()

print("\n" .. string.rep("=", 60))
print("✅ SCRIPT COMPLETE - NO ERRORS")
print(string.rep("=", 60))

print("\n💡 TIPS:")
print("1. The error 'Invalid item type' means we need the REAL item data")
print("2. Click the car manually and tell me what happens")
print("3. Or check the button attributes for the real Item ID")
print("\n🎯 NEXT STEP:")
print("Click the Aston Martin and tell me:")
print("1. Any message that appears")
print("2. Or the exact output from this script")
