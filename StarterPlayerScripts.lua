-- Car Format Tester - Found Working Session ID!
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== CAR FORMAT TESTER ===")
print("✅ Found working session ID: 'otherplayer'")

-- Get services
local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

local SessionAddItem = tradingService:WaitForChild("SessionAddItem")
local workingSessionId = "otherplayer"  -- PROVEN TO WORK!

-- Get car data to test different formats
local function GetCarData()
    print("\n📊 GETTING CAR DATA FOR FORMAT TESTING...")
    
    local success, carList = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if not success or not carList then
        print("❌ Failed to get car list")
        return nil
    end
    
    -- Find Aston Martin 8
    for _, carData in ipairs(carList) do
        if type(carData) == "table" and carData.Name == "AstonMartin8" then
            print("✅ Found Aston Martin 8 data")
            
            -- Show all fields
            print("\n📋 CAR DATA FIELDS:")
            for fieldName, fieldValue in pairs(carData) do
                local valueType = type(fieldValue)
                local displayValue = tostring(fieldValue)
                
                if valueType == "table" then
                    print("  " .. fieldName .. " = [TABLE]")
                    -- Show table contents
                    for k, v in pairs(fieldValue) do
                        print("    " .. tostring(k) .. " = " .. tostring(v))
                    end
                else
                    if #displayValue > 50 then
                        displayValue = displayValue:sub(1, 50) .. "..."
                    end
                    print("  " .. fieldName .. " = " .. displayValue .. " (" .. valueType .. ")")
                end
            end
            
            return carData
        end
    end
    
    print("❌ Aston Martin 8 not found")
    return nil
end

-- Test different car ID/formats with working session ID
local function TestCarFormats(carData)
    print("\n🧪 TESTING DIFFERENT CAR FORMATS...")
    print("Using PROVEN session ID: 'otherplayer'")
    
    if not carData then
        print("❌ No car data")
        return false
    end
    
    local carId = carData.Id  -- The UUID
    local carName = carData.Name  -- "AstonMartin8"
    
    print("Car UUID: " .. carId)
    print("Car Name: " .. carName)
    
    -- Different formats to test
    local testFormats = {
        -- Direct UUID formats (what we tried)
        {name = "UUID as string", value = carId},
        {name = "UUID without dashes", value = carId:gsub("-", "")},
        
        -- Name-based formats
        {name = "Just car name", value = carName},
        {name = "Car- prefix", value = "Car-" .. carName},
        {name = "Lowercase name", value = carName:lower()},
        
        -- Number extraction (AstonMartin8 → 8)
        {name = "Extracted number", value = carName:match("%d+")},
        {name = "Number as string", value = tostring(carName:match("%d+"))},
        
        -- Table formats
        {name = "Table with id", value = {id = carId}},
        {name = "Table with name", value = {name = carName}},
        {name = "Full car data table", value = carData},
        {name = "Data field from car", value = carData.Data},
        
        -- Combination formats
        {name = "Table with id+name", value = {id = carId, name = carName}},
        {name = "Table with id+type", value = {id = carId, type = "car"}},
        
        -- Maybe it needs a quantity
        {name = "UUID + quantity", value = carId, quantity = 1},
        {name = "Name + quantity", value = carName, quantity = 1},
    }
    
    local successCount = 0
    
    for i, format in ipairs(testFormats) do
        print("\nTest " .. i .. ": " .. format.name)
        print("  Format: " .. type(format.value))
        
        local params = nil
        
        if format.quantity then
            -- Format with quantity
            params = {workingSessionId, format.value, format.quantity}
            print("  Params: session, " .. type(format.value) .. ", quantity=" .. format.quantity)
        else
            -- Format without quantity
            params = {workingSessionId, format.value}
            print("  Params: session, " .. type(format.value))
        end
        
        local success, result = pcall(function()
            return SessionAddItem:InvokeServer(unpack(params))
        end)
        
        if success then
            print("  ✅ SUCCESS!")
            if result then
                print("  Result: " .. tostring(result))
            end
            successCount = successCount + 1
            
            -- Try a few more times
            for j = 1, 3 do
                wait(0.2)
                pcall(function()
                    SessionAddItem:InvokeServer(unpack(params))
                    print("  Repeated " .. j)
                end)
            end
            
            return true, format
        else
            print("  ❌ Failed: " .. tostring(result))
            
            -- Analyze error
            local errorMsg = tostring(result)
            if errorMsg:find("Invalid item") then
                print("  ⚠️ Wrong item format")
            elseif errorMsg:find("not in inventory") then
                print("  ⚠️ Item not in inventory")
            elseif errorMsg:find("already in trade") then
                print("  ⚠️ Item already in trade")
            end
        end
        
        wait(0.3)
    end
    
    print("\n📊 Results: " .. successCount .. "/" .. #testFormats .. " successful")
    return successCount > 0
end

-- Check what's in the trade windows
local function CheckTradeWindows()
    print("\n🔍 CHECKING TRADE WINDOWS...")
    
    pcall(function()
        local main = Player.PlayerGui.Menu.Trading.PeerToPeer.Main
        
        -- LocalPlayer window
        local localPlayer = main.LocalPlayer
        local localContent = localPlayer.Content
        local localScrolling = localContent.ScrollingFrame
        
        print("📦 YOUR TRADE WINDOW:")
        local yourItems = {}
        for _, item in pairs(localScrolling:GetChildren()) do
            if item:IsA("ImageButton") then
                table.insert(yourItems, item.Name)
            end
        end
        
        if #yourItems > 0 then
            for _, itemName in ipairs(yourItems) do
                print("  - " .. itemName)
            end
        else
            print("  (empty)")
        end
        
        -- OtherPlayer window
        local otherPlayer = main.OtherPlayer
        local otherContent = otherPlayer.Content
        local otherScrolling = otherContent.ScrollingFrame
        
        print("\n📦 OTHER PLAYER'S WINDOW (on YOUR screen):")
        local theirItems = {}
        for _, item in pairs(otherScrolling:GetChildren()) do
            if item:IsA("ImageButton") then
                table.insert(theirItems, item.Name)
            end
        end
        
        if #theirItems > 0 then
            for _, itemName in ipairs(theirItems) do
                print("  - " .. itemName)
            end
        else
            print("  (empty)")
        end
    end)
end

-- Try to add car normally first
local function AddCarNormallyForReference()
    print("\n🖱️ TRYING TO ADD CAR NORMALLY FIRST...")
    
    -- Find Car-AstonMartin8 in inventory
    local carButton = nil
    
    pcall(function()
        local inventory = Player.PlayerGui.Menu.Trading.PeerToPeer.Main.Inventory
        local scrolling = inventory.List.ScrollingFrame
        
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name == "Car-AstonMartin8" then
                carButton = item
                break
            end
        end
    end)
    
    if carButton then
        print("✅ Found Car-AstonMartin8 in inventory")
        print("Try clicking it normally to see what happens")
        print("Then we can compare with script results")
        
        -- Optional: Click it programmatically to see
        print("\n🔄 Clicking programmatically to observe...")
        for i = 1, 3 do
            pcall(function()
                carButton:Fire("Activated")
                print("  Click " .. i)
            end)
            wait(0.2)
        end
        
        return carButton
    else
        print("❌ Car-AstonMartin8 not in inventory")
        return nil
    end
end

-- Main test
local function RunFormatTests()
    print("\n🎯 RUNNING FORMAT TESTS...")
    
    -- Check current trade state
    CheckTradeWindows()
    
    -- Try normal addition first
    wait(1)
    AddCarNormallyForReference()
    
    -- Get car data
    wait(1)
    local carData = GetCarData()
    
    -- Test different formats
    if carData then
        wait(1)
        local success, format = TestCarFormats(carData)
        
        if success then
            print("\n" .. string.rep("=", 60))
            print("🎉 FOUND WORKING FORMAT!")
            print("Session ID: 'otherplayer'")
            print("Car Format: " .. format.name)
            print(string.rep("=", 60))
            
            -- Check trade windows again
            wait(1)
            CheckTradeWindows()
            
            return true
        end
    end
    
    print("\n" .. string.rep("=", 60))
    print("❌ No working format found")
    print("But we KNOW 'otherplayer' is correct session ID!")
    print("The car format must be different than we expect")
    print(string.rep("=", 60))
    
    return false
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "FormatTester"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 200)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "CAR FORMAT TESTER 🎉"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 255, 100)
    
    local status = Instance.new("TextLabel")
    status.Text = "Found working session ID: 'otherplayer'\nTesting car formats..."
    status.Size = UDim2.new(1, -20, 0, 110)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 255, 200)
    status.TextWrapped = true
    
    local testBtn = Instance.new("TextButton")
    testBtn.Text = "🧪 TEST CAR FORMATS"
    testBtn.Size = UDim2.new(1, -20, 0, 40)
    testBtn.Position = UDim2.new(0, 10, 0, 170)
    testBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    testBtn.MouseButton1Click:Connect(function()
        status.Text = "Testing car formats...\nSession ID: 'otherplayer'"
        testBtn.Text = "TESTING..."
        
        spawn(function()
            local success = RunFormatTests()
            
            if success then
                status.Text = "✅ Found working format!\nCheck output"
                testBtn.Text = "🎉 SUCCESS"
                testBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            else
                status.Text = "❌ Need different format\nSee output"
                testBtn.Text = "🧪 TRY AGAIN"
            end
            
            wait(2)
            testBtn.Text = "🧪 TEST CAR FORMATS"
        end)
    end)
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    testBtn.Parent = frame
    frame.Parent = gui
    
    return status
end

-- Initialize
CreateUI()

-- Instructions
wait(3)
print("\n=== CAR FORMAT TESTER ===")
print("✅ PROVEN: Session ID = 'otherplayer'")
print("❌ PROBLEM: Car UUID format wrong for SessionAddItem")
print("\n📋 TESTING STRATEGY:")
print("1. Try different car ID formats with 'otherplayer'")
print("2. Check car Data field (might be correct format)")
print("3. Try name/number instead of UUID")
print("4. Try table formats")
print("\n🔍 Click 'TEST CAR FORMATS' to find correct format!")
