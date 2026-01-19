-- 🔍 TRADE FORMAT DETECTOR
-- Finds the EXACT format the server wants

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

print("=== TRADE FORMAT DETECTOR ===")

-- Get the remote
local tradingRemote = RS.Remotes.Services.TradingServiceRemotes.SessionAddItem
print("✅ Remote found:", tradingRemote.Name)

-- ===== TEST DIFFERENT FORMATS =====
local function TestFormat(formatName, data)
    print("\n🧪 Testing:", formatName)
    print("Data:", data)
    
    local success, result = pcall(function()
        return tradingRemote:InvokeServer(data)
    end)
    
    if success then
        print("✅ SUCCESS!")
        print("Result:", result)
        return true, result
    else
        print("❌ Error:", result)
        return false, result
    end
end

-- ===== ALL POSSIBLE FORMATS =====
local testFormats = {
    -- Format 1: Simple string (what we tried)
    {"Simple String", "AstonMartin12"},
    
    -- Format 2: Table with ItemId
    {"Table with ItemId", {ItemId = "AstonMartin12"}},
    
    -- Format 3: Table with id
    {"Table with id", {id = "AstonMartin12"}},
    
    -- Format 4: Table with Name
    {"Table with Name", {Name = "AstonMartin12"}},
    
    -- Format 5: Table with item
    {"Table with item", {item = "AstonMartin12"}},
    
    -- Format 6: Table with itemId (lowercase i)
    {"Table with itemId", {itemId = "AstonMartin12"}},
    
    -- Format 7: Table with type
    {"Table with ItemId + Type", {ItemId = "AstonMartin12", Type = "Car"}},
    
    -- Format 8: Table with itemType
    {"Table with ItemId + itemType", {ItemId = "AstonMartin12", itemType = "Car"}},
    
    -- Format 9: Table with ItemType
    {"Table with ItemId + ItemType", {ItemId = "AstonMartin12", ItemType = "Car"}},
    
    -- Format 10: Table with category
    {"Table with ItemId + Category", {ItemId = "AstonMartin12", Category = "Vehicle"}},
    
    -- Format 11: Table with multiple properties
    {"Table with multiple", {ItemId = "AstonMartin12", Type = "Car", Category = "Vehicle"}},
    
    -- Format 12: Number instead of string
    {"Table with numeric ID", {ItemId = 123}}, -- Some games use numeric IDs
    
    -- Format 13: With player ID
    {"Table with PlayerId", {ItemId = "AstonMartin12", PlayerId = Player.UserId}},
    
    -- Format 14: With timestamp
    {"Table with timestamp", {ItemId = "AstonMartin12", Time = os.time()}},
    
    -- Format 15: Try Car- prefix
    {"Car-AstonMartin12", "Car-AstonMartin12"},
    
    -- Format 16: Table with Car- prefix
    {"Table with Car- prefix", {ItemId = "Car-AstonMartin12"}},
    
    -- Format 17: Try vehicle type
    {"Table with vehicle type", {ItemId = "AstonMartin12", Type = "Vehicle"}},
    
    -- Format 18: Try automotive type
    {"Table with automotive type", {ItemId = "AstonMartin12", Type = "Automotive"}},
}

-- ===== FIND THE CORRECT TYPE =====
local function FindItemType()
    print("\n🔍 FINDING CORRECT ITEM TYPE...")
    
    -- Common item types in car games
    local itemTypes = {
        "Car", "Vehicle", "Automobile", "Automotive",
        "Ride", "Drive", "Motor", "Engine",
        "Body", "Chassis", "Frame"
    }
    
    for _, itemType in ipairs(itemTypes) do
        print("\nTesting type:", itemType)
        
        local data = {ItemId = "AstonMartin12", Type = itemType}
        local success, result = TestFormat("Type: " .. itemType, data)
        
        if success then
            print("🎉 FOUND CORRECT TYPE:", itemType)
            return itemType
        end
    end
    
    return nil
end

-- ===== FIND THE CORRECT KEY NAMES =====
local function FindCorrectKeys()
    print("\n🔑 FINDING CORRECT KEY NAMES...")
    
    -- Different key name combinations
    local keyCombinations = {
        {"ItemId", "Type"},
        {"id", "type"},
        {"Name", "Category"},
        {"itemId", "itemType"},
        {"Item", "Kind"},
        {"productId", "productType"}
    }
    
    for _, keys in ipairs(keyCombinations) do
        local idKey, typeKey = keys[1], keys[2]
        
        print("\nTesting keys:", idKey, "and", typeKey)
        
        local data = {}
        data[idKey] = "AstonMartin12"
        data[typeKey] = "Car"
        
        local success, result = TestFormat("Keys: " .. idKey .. "/" .. typeKey, data)
        
        if success then
            print("🎉 FOUND CORRECT KEYS!")
            return idKey, typeKey
        end
    end
    
    return nil, nil
end

-- ===== AUTO-DETECT FROM MANUAL CLICK =====
local function CaptureManualFormat()
    print("\n👀 CAPTURE MANUAL CLICK FORMAT")
    print("===============================")
    print("1. I will hook the remote")
    print("2. YOU click AstonMartin12 in inventory")
    print("3. I will capture the EXACT format")
    print("===============================")
    
    -- Store original function
    local originalInvoke = tradingRemote.InvokeServer
    local capturedData = nil
    
    -- Create hook
    tradingRemote.InvokeServer = function(self, ...)
        local args = {...}
        capturedData = args[1]
        
        print("\n🎯 CAPTURED MANUAL CLICK!")
        print("Data type:", type(capturedData))
        
        if type(capturedData) == "table" then
            print("Table contents:")
            for k, v in pairs(capturedData) do
                print("  " .. tostring(k) .. " = " .. tostring(v))
            end
        else
            print("Value:", capturedData)
        end
        
        -- Call original
        return originalInvoke(self, ...)
    end
    
    print("\n✅ Hook installed!")
    print("Now click AstonMartin12 in your inventory...")
    
    -- Wait for click
    for i = 1, 30 do
        task.wait(1)
        if capturedData then
            print("\n✅ Format captured successfully!")
            return capturedData
        end
        if i % 5 == 0 then
            print("Waiting... (" .. i .. "/30 seconds)")
        end
    end
    
    print("\n❌ No click captured")
    return nil
end

-- ===== BULK ADD WITH CORRECT FORMAT =====
local function BulkAddWithFormat(itemData, count)
    if not itemData then
        print("❌ No format data provided")
        return false
    end
    
    print("\n📦 BULK ADDING WITH CORRECT FORMAT")
    print("Format:", itemData)
    
    local successCount = 0
    
    for i = 1, count do
        print("\nAdding", i, "/", count)
        
        local success, result = pcall(function()
            return tradingRemote:InvokeServer(itemData)
        end)
        
        if success then
            print("✅ Added successfully!")
            successCount = successCount + 1
        else
            print("❌ Failed:", result)
        end
        
        -- Random delay
        task.wait(math.random(50, 200) / 1000)
    end
    
    print("\n📊 RESULTS:")
    print("Success:", successCount, "/", count)
    print("Failed:", count - successCount)
    
    return successCount > 0
end

-- ===== MAIN TEST SEQUENCE =====
print("\n🚀 STARTING FORMAT DETECTION...")

-- Step 1: Try all basic formats
print("\n" .. string.rep("=", 50))
print("STEP 1: Testing all basic formats")
print(string.rep("=", 50))

local foundFormat = nil
for i, formatInfo in ipairs(testFormats) do
    local formatName, data = formatInfo[1], formatInfo[2]
    local success, result = TestFormat(formatName, data)
    
    if success then
        print("\n🎉 FOUND WORKING FORMAT!")
        print("Format:", formatName)
        print("Data:", data)
        foundFormat = data
        break
    end
end

-- Step 2: If no format found, find correct item type
if not foundFormat then
    print("\n" .. string.rep("=", 50))
    print("STEP 2: Finding correct item type")
    print(string.rep("=", 50))
    
    local itemType = FindItemType()
    if itemType then
        foundFormat = {ItemId = "AstonMartin12", Type = itemType}
    end
end

-- Step 3: If still no format, find correct keys
if not foundFormat then
    print("\n" .. string.rep("=", 50))
    print("STEP 3: Finding correct key names")
    print(string.rep("=", 50))
    
    local idKey, typeKey = FindCorrectKeys()
    if idKey and typeKey then
        foundFormat = {}
        foundFormat[idKey] = "AstonMartin12"
        foundFormat[typeKey] = "Car"
    end
end

-- Step 4: If all else fails, capture manual click
if not foundFormat then
    print("\n" .. string.rep("=", 50))
    print("STEP 4: Capturing manual click format")
    print(string.rep("=", 50))
    
    foundFormat = CaptureManualFormat()
end

-- Step 5: Use the found format for bulk add
if foundFormat then
    print("\n" .. string.rep("=", 50))
    print("STEP 5: Bulk adding with correct format")
    print(string.rep("=", 50))
    
    -- Ask how many to add
    print("\nHow many AstonMartin12 to add?")
    print("Enter number (10, 50, 100, etc):")
    
    -- In a real script, you'd get user input
    -- For now, let's add 10
    BulkAddWithFormat(foundFormat, 10)
else
    print("\n❌ Could not find correct format")
    print("Try clicking manually and checking error messages")
end

-- ===== CREATE SIMPLE UI =====
local function CreateFormatUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "FormatDetector"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    
    local title = Instance.new("TextLabel")
    title.Text = "🔍 FORMAT DETECTOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local log = Instance.new("ScrollingFrame")
    log.Size = UDim2.new(1, -20, 0, 300)
    log.Position = UDim2.new(0, 10, 0, 50)
    log.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    log.ScrollBarThickness = 8
    
    local logText = Instance.new("TextLabel")
    logText.Size = UDim2.new(1, -10, 0, 500)
    logText.Position = UDim2.new(0, 5, 0, 5)
    logText.BackgroundTransparency = 1
    logText.TextColor3 = Color3.fromRGB(220, 220, 255)
    logText.TextWrapped = true
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.TextYAlignment = Enum.TextYAlignment.Top
    
    local function AddLog(text)
        logText.Text = logText.Text .. text .. "\n"
    end
    
    -- Test buttons
    local testBtn = Instance.new("TextButton")
    testBtn.Text = "🧪 Test Formats"
    testBtn.Size = UDim2.new(1, -20, 0, 35)
    testBtn.Position = UDim2.new(0, 10, 1, -80)
    testBtn.BackgroundColor3 = Color3.fromRGB(70, 120, 180)
    testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    testBtn.MouseButton1Click:Connect(function()
        AddLog("\n=== Testing formats ===")
        for i, formatInfo in ipairs(testFormats) do
            local formatName, data = formatInfo[1], formatInfo[2]
            local success, result = TestFormat(formatName, data)
            
            if success then
                AddLog("✅ " .. formatName .. ": SUCCESS")
            else
                AddLog("❌ " .. formatName .. ": " .. tostring(result))
            end
        end
    end)
    
    local captureBtn = Instance.new("TextButton")
    captureBtn.Text = "👀 Capture Manual Click"
    captureBtn.Size = UDim2.new(1, -20, 0, 35)
    captureBtn.Position = UDim2.new(0, 10, 1, -40)
    captureBtn.BackgroundColor3 = Color3.fromRGB(70, 180, 120)
    captureBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    captureBtn.MouseButton1Click:Connect(function()
        AddLog("\n=== Capturing manual click ===")
        local captured = CaptureManualFormat()
        if captured then
            AddLog("✅ Captured: " .. tostring(captured))
        else
            AddLog("❌ No click captured")
        end
    end)
    
    -- Parent everything
    logText.Parent = log
    title.Parent = frame
    log.Parent = frame
    testBtn.Parent = frame
    captureBtn.Parent = frame
    frame.Parent = gui
    
    AddLog("Format Detector Ready")
    AddLog("Click 'Test Formats' to begin")
    
    return gui
end

-- Start UI after tests
task.wait(2)
CreateFormatUI()
