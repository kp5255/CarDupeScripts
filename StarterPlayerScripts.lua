-- Trade Item Analyzer & Duplicator
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== TRADE ITEM ANALYZER ===")
print("Found Car-AstonMartin12 in trade window!")

-- Get services
local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

local SessionAddItem = tradingService:WaitForChild("SessionAddItem")
local workingSessionId = "otherplayer"  -- Proven to work!

-- Get the car that's ALREADY in the trade
local function GetCarInTrade()
    print("\n🔍 EXAMINING CAR IN TRADE WINDOW...")
    
    local tradeCar = nil
    local tradeCarData = nil
    
    pcall(function()
        local main = Player.PlayerGui.Menu.Trading.PeerToPeer.Main
        local localPlayer = main.LocalPlayer
        local scrolling = localPlayer.Content.ScrollingFrame
        
        -- Find Car-AstonMartin12 in trade
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name == "Car-AstonMartin12" then
                tradeCar = item
                print("✅ Found in trade: " .. item.Name)
                
                -- Look for car data in the button
                for _, child in pairs(item:GetDescendants()) do
                    if child:IsA("StringValue") then
                        print("  StringValue: " .. child.Name .. " = " .. child.Value)
                        if child.Name:lower():find("id") then
                            tradeCarData = {id = child.Value, name = item.Name}
                        end
                    end
                end
                break
            end
        end
    end)
    
    if tradeCar then
        -- Get full car data from inventory
        print("\n📊 GETTING FULL CAR DATA...")
        local success, carList = pcall(function()
            return carService.GetOwnedCars:InvokeServer()
        end)
        
        if success and carList then
            -- Find AstonMartin12 in inventory
            for _, carData in ipairs(carList) do
                if type(carData) == "table" and carData.Name == "AstonMartin12" then
                    print("✅ Found AstonMartin12 in inventory")
                    print("Car ID: " .. carData.Id)
                    
                    -- Show key fields
                    print("\n📋 KEY CAR DATA:")
                    for fieldName, fieldValue in pairs(carData) do
                        if fieldName == "Id" or fieldName == "Name" or fieldName == "Created" then
                            print("  " .. fieldName .. " = " .. tostring(fieldValue))
                        end
                    end
                    
                    return carData
                end
            end
        end
    else
        print("❌ No car found in trade window")
    end
    
    return nil
end

-- Test: Maybe SessionAddItem needs the car that's ALREADY in trade
local function TestWithTradeCar(carData)
    print("\n🧪 TESTING WITH TRADE CAR...")
    
    if not carData then
        print("❌ No car data")
        return false
    end
    
    print("Car Name: " .. carData.Name)
    print("Car ID: " .. carData.Id)
    
    -- The car is ALREADY in trade, so maybe SessionAddItem works differently
    print("\n⚠️ IMPORTANT: Car is ALREADY in trade window")
    print("SessionAddItem might work differently in this case")
    
    -- Maybe we need to remove and re-add? Or duplicate existing?
    local SessionRemoveItem = tradingService:FindFirstChild("SessionRemoveItem")
    
    if SessionRemoveItem then
        print("\n🔄 TESTING REMOVE/ADD CYCLE...")
        
        -- Try to remove the car first
        print("1. Attempting to remove car...")
        local removeSuccess, removeResult = pcall(function()
            return SessionRemoveItem:InvokeServer(workingSessionId, carData.Id)
        end)
        
        if removeSuccess then
            print("✅ Remove successful: " .. tostring(removeResult))
            
            -- Wait a bit
            wait(1)
            
            -- Try to add it back
            print("\n2. Attempting to add car back...")
            local addSuccess, addResult = pcall(function()
                return SessionAddItem:InvokeServer(workingSessionId, carData.Id)
            end)
            
            if addSuccess then
                print("✅ Add successful: " .. tostring(addResult))
                
                -- Try to add multiple times
                print("\n3. Attempting to add multiple times...")
                for i = 1, 5 do
                    wait(0.2)
                    pcall(function()
                        SessionAddItem:InvokeServer(workingSessionId, carData.Id)
                        print("  Added copy " .. i)
                    end)
                end
                
                return true
            else
                print("❌ Add failed: " .. tostring(addResult))
            end
        else
            print("❌ Remove failed: " .. tostring(removeResult))
        end
    end
    
    return false
end

-- Check the actual error more carefully
local function AnalyzeError()
    print("\n🔍 ANALYZING ERROR PATTERN...")
    
    -- The error is ALWAYS: "ServerScriptService.Services.TradingService:650: Invalid item type"
    print("Error pattern: 'Invalid item type'")
    print("Line 650 in TradingService")
    
    print("\n🎯 WHAT THIS MEANS:")
    print("1. The REMOTE CALL IS WORKING (reaching server)")
    print("2. Session ID 'otherplayer' IS CORRECT")
    print("3. But the ITEM DATA FORMAT is wrong")
    
    print("\n📋 POSSIBLE SOLUTIONS:")
    print("A. Maybe need to use DIFFERENT REMOTE for adding to trade")
    print("B. Maybe car needs to be in different state")
    print("C. Maybe trade session needs different setup")
    
    -- Check other remotes
    print("\n🔍 CHECKING OTHER TRADING REMOTES:")
    for _, remote in pairs(tradingService:GetChildren()) do
        if remote:IsA("RemoteFunction") and remote.Name ~= "SessionAddItem" then
            print("  " .. remote.Name)
        end
    end
end

-- Maybe we need to click the inventory button to see what happens
local function MonitorInventoryClick()
    print("\n🖱️ MONITORING INVENTORY CLICK...")
    
    -- Find Car-AstonMartin12 in inventory
    local inventoryButton = nil
    
    pcall(function()
        local inventory = Player.PlayerGui.Menu.Trading.PeerToPeer.Main.Inventory
        local scrolling = inventory.List.ScrollingFrame
        
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name == "Car-AstonMartin12" then
                inventoryButton = item
                break
            end
        end
    end)
    
    if inventoryButton then
        print("✅ Found Car-AstonMartin12 in inventory")
        print("Class: " .. inventoryButton.ClassName)
        
        -- Look for data in the button
        print("\n🔍 INVENTORY BUTTON DATA:")
        for _, child in pairs(inventoryButton:GetDescendants()) do
            if child:IsA("StringValue") or child:IsA("IntValue") then
                print("  " .. child.Name .. " = " .. tostring(child.Value))
            end
        end
        
        -- Try clicking it and see what remote gets called
        print("\n🔄 Clicking inventory button 3 times...")
        for i = 1, 3 do
            pcall(function()
                inventoryButton:Fire("Activated")
                inventoryButton:Fire("MouseButton1Click")
                print("  Click " .. i)
            end)
            wait(0.5)
        end
        
        print("\n⏳ Check if car appears in trade window...")
        wait(2)
        
        -- Check trade window again
        pcall(function()
            local main = Player.PlayerGui.Menu.Trading.PeerToPeer.Main
            local localPlayer = main.LocalPlayer
            local scrolling = localPlayer.Content.ScrollingFrame
            
            local carCount = 0
            for _, item in pairs(scrolling:GetChildren()) do
                if item.Name:sub(1, 4) == "Car-" then
                    carCount = carCount + 1
                end
            end
            
            print("Cars in trade window now: " .. carCount)
        end)
        
        return inventoryButton
    else
        print("❌ Car-AstonMartin12 not in inventory")
        return nil
    end
end

-- Try a completely different approach
local function TryAlternativeApproach()
    print("\n🎯 TRYING ALTERNATIVE APPROACH...")
    
    -- Maybe the issue is we're in the wrong trade state
    print("1. Checking trade state...")
    
    local inCorrectState = false
    pcall(function()
        local peerToPeer = Player.PlayerGui.Menu.Trading.PeerToPeer
        if peerToPeer and peerToPeer.Visible then
            local top = peerToPeer.Top
            for _, child in pairs(top:GetChildren()) do
                if child:IsA("TextLabel") and child.Text:find("Trading with") then
                    print("✅ Trading with: " .. child.Text)
                    inCorrectState = true
                end
            end
        end
    end)
    
    if not inCorrectState then
        print("❌ Not in correct trade state")
        return false
    end
    
    -- Maybe we need to use a different parameter order
    print("\n2. Testing different parameter orders...")
    
    local carData = GetCarInTrade()
    if not carData then return false end
    
    local testCases = {
        {name = "Session, CarId", params = {workingSessionId, carData.Id}},
        {name = "CarId, Session", params = {carData.Id, workingSessionId}},
        {name = "Just CarId", params = {carData.Id}},
        {name = "Player, Session, CarId", params = {Player, workingSessionId, carData.Id}},
    }
    
    for i, testCase in ipairs(testCases) do
        print("\nTest " .. i .. ": " .. testCase.name)
        
        local success, result = pcall(function()
            return SessionAddItem:InvokeServer(unpack(testCase.params))
        end)
        
        if success then
            print("✅ SUCCESS!")
            if result then
                print("Result: " .. tostring(result))
            end
            return true
        else
            print("❌ Failed: " .. tostring(result))
        end
    end
    
    return false
end

-- Main function
local function RunAnalysis()
    print("\n🔍 RUNNING COMPLETE ANALYSIS...")
    
    -- Get the car that's in trade
    local tradeCarData = GetCarInTrade()
    
    -- Monitor inventory click
    wait(1)
    MonitorInventoryClick()
    
    -- Try with trade car
    if tradeCarData then
        wait(1)
        TestWithTradeCar(tradeCarData)
    end
    
    -- Analyze error pattern
    wait(1)
    AnalyzeError()
    
    -- Try alternative approach
    wait(1)
    TryAlternativeApproach()
    
    print("\n" .. string.rep("=", 60))
    print("ANALYSIS COMPLETE")
    print("Key finding: Car-AstonMartin12 is IN trade window")
    print("We need to understand how it got there")
    print(string.rep("=", 60))
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeAnalyzer"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 200)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "TRADE ITEM ANALYZER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    local status = Instance.new("TextLabel")
    status.Text = "Found Car-AstonMartin12 in trade!\nAnalyzing how it got there..."
    status.Size = UDim2.new(1, -20, 0, 110)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 230, 255)
    status.TextWrapped = true
    
    local analyzeBtn = Instance.new("TextButton")
    analyzeBtn.Text = "🔍 ANALYZE TRADE ITEM"
    analyzeBtn.Size = UDim2.new(1, -20, 0, 40)
    analyzeBtn.Position = UDim2.new(0, 10, 0, 170)
    analyzeBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    analyzeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    analyzeBtn.MouseButton1Click:Connect(function()
        status.Text = "Analyzing trade item...\nCheck output!"
        analyzeBtn.Text = "ANALYZING..."
        
        spawn(function()
            RunAnalysis()
            
            status.Text = "✅ Analysis complete!\nSee output for details"
            
            wait(2)
            analyzeBtn.Text = "🔍 ANALYZE TRADE ITEM"
        end)
    end)
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    analyzeBtn.Parent = frame
    frame.Parent = gui
    
    return status
end

-- Initialize
CreateUI()

-- Instructions
wait(3)
print("\n=== TRADE ITEM ANALYZER ===")
print("CRITICAL DISCOVERY: Car-AstonMartin12 is IN trade window")
print("\n📋 KEY QUESTIONS:")
print("1. How did Car-AstonMartin12 get into the trade?")
print("2. What data format was used to add it?")
print("3. Can we duplicate it using the same method?")
print("\n🔍 Click 'ANALYZE TRADE ITEM' to investigate!")
