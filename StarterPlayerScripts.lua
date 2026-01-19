-- Trade Session Test - Focused on OtherPlayer
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== TRADE SESSION TEST - FOCUSED ===")

-- Get services
local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

-- Get the SessionAddItem remote
local SessionAddItem = tradingService:WaitForChild("SessionAddItem")

-- Critical discovery: OtherPlayer frame exists!
local function ExamineOtherPlayerFrame()
    print("\n🔍 EXAMINING OTHERPLAYER FRAME...")
    
    if not Player.PlayerGui then return nil end
    
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then return nil end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then return nil end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then return nil end
    
    local main = peerToPeer:FindFirstChild("Main")
    if not main then return nil end
    
    -- Find OtherPlayer frame
    local otherPlayerFrame = main:FindFirstChild("OtherPlayer")
    if otherPlayerFrame then
        print("✅ Found OtherPlayer frame!")
        print("Class: " .. otherPlayerFrame.ClassName)
        print("Visible: " .. tostring(otherPlayerFrame.Visible))
        
        -- Check its children
        print("\n📁 OtherPlayer frame children:")
        for _, child in pairs(otherPlayerFrame:GetChildren()) do
            print("  " .. child.Name .. " (" .. child.ClassName .. ")")
            
            -- Look for Content and ScrollingFrame
            if child.Name == "Content" then
                local scrollingFrame = child:FindFirstChild("ScrollingFrame")
                if scrollingFrame then
                    print("    Found ScrollingFrame!")
                    print("    Items: " .. #scrollingFrame:GetChildren())
                    
                    -- List items in other player's trade window
                    print("\n    Items in OtherPlayer's trade:")
                    for _, item in pairs(scrollingFrame:GetChildren()) do
                        if item:IsA("ImageButton") then
                            print("      - " .. item.Name)
                        end
                    end
                end
            end
        end
        
        return otherPlayerFrame
    else
        print("❌ OtherPlayer frame not found")
        return nil
    end
end

-- Get car ID safely
local function GetCarIdSafely()
    print("\n🔑 GETTING CAR ID...")
    
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
            local carId = carData.Id
            print("✅ Found Aston Martin 8")
            print("Car ID: " .. carId)
            return carId
        end
    end
    
    print("❌ Aston Martin 8 not found")
    return nil
end

-- Test: Maybe session ID is simply "OtherPlayer" or related to it
local function TestOtherPlayerAsSession()
    print("\n🎯 TESTING OTHERPLAYER AS SESSION CONTEXT...")
    
    local carId = GetCarIdSafely()
    if not carId then return false end
    
    -- Possible session IDs based on OtherPlayer discovery
    local testCases = {
        -- Simple session IDs
        {name = "otherplayer", id = "otherplayer"},
        {name = "OtherPlayer", id = "OtherPlayer"},
        {name = "session_other", id = "session_other"},
        
        -- Player-based IDs
        {name = "player_" .. Player.UserId, id = "player_" .. Player.UserId},
        
        -- Trade-specific IDs
        {name = "trade_session", id = "trade_session"},
        {name = "current_trade", id = "current_trade"},
        {name = "active_session", id = "active_session"},
        
        -- Maybe no session ID needed
        {name = "NO_SESSION_ID", id = nil},
    }
    
    -- Get other player's ID from the frame name
    local otherPlayerFrame = ExamineOtherPlayerFrame()
    if otherPlayerFrame then
        -- The frame might contain the actual session ID
        for _, child in pairs(otherPlayerFrame:GetDescendants()) do
            if child:IsA("StringValue") then
                local value = tostring(child.Value)
                if #value > 5 and #value < 50 then  -- Reasonable length for ID
                    table.insert(testCases, {
                        name = "From StringValue: " .. child.Name,
                        id = value
                    })
                end
            end
        end
    end
    
    print("\n🧪 TESTING " .. #testCases .. " SESSION IDS:")
    
    local successCount = 0
    
    for i, testCase in ipairs(testCases) do
        print("\nTest " .. i .. ": " .. testCase.name)
        print("ID: " .. tostring(testCase.id or "nil"))
        
        local params = testCase.id and {testCase.id, carId} or {carId}
        
        local success, result = pcall(function()
            return SessionAddItem:InvokeServer(unpack(params))
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
                    SessionAddItem:InvokeServer(unpack(params))
                    print("   Repeated " .. j)
                end)
            end
            
            return true, testCase.id
        else
            print("❌ Failed: " .. tostring(result))
            
            -- Analyze error
            local errorMsg = tostring(result)
            if errorMsg:find("Invalid item") then
                print("   ⚠️ Wrong item format")
            elseif errorMsg:find("session") then
                print("   ⚠️ Session issue")
            elseif errorMsg:find("not in trade") then
                print("   ⚠️ Not in correct trade state")
            end
        end
        
        wait(0.3)
    end
    
    print("\n📊 Results: " .. successCount .. "/" .. #testCases .. " successful")
    return successCount > 0, nil
end

-- Alternative: Maybe we need to use the SessionSetConfirmation remote
local function TestSessionConfirmation()
    print("\n🤝 TESTING SESSION CONFIRMATION...")
    
    local SessionSetConfirmation = tradingService:FindFirstChild("SessionSetConfirmation")
    if not SessionSetConfirmation then
        print("❌ SessionSetConfirmation not found")
        return false
    end
    
    print("Found SessionSetConfirmation remote")
    
    -- Try to set confirmation (accept trade)
    local testIds = {
        "otherplayer",
        "trade_session", 
        Player.UserId .. "_trade",
        nil
    }
    
    for i, sessionId in ipairs(testIds) do
        print("\nTest " .. i .. ": " .. tostring(sessionId))
        
        local params = sessionId and {sessionId, true} or {true}
        
        local success, result = pcall(function()
            return SessionSetConfirmation:InvokeServer(unpack(params))
        end)
        
        if success then
            print("✅ Success!")
            if result then
                print("   Result: " .. tostring(result))
            end
            return true
        else
            print("❌ Failed: " .. tostring(result))
        end
    end
    
    return false
end

-- Monitor what happens when you normally add a car
local function MonitorNormalAdd()
    print("\n👀 MONITORING NORMAL CAR ADDITION...")
    
    -- First, let's see what cars are in the inventory
    local inventoryFrame = nil
    pcall(function()
        local main = Player.PlayerGui.Menu.Trading.PeerToPeer.Main
        inventoryFrame = main:FindFirstChild("Inventory")
    end)
    
    if inventoryFrame then
        print("📦 INVENTORY FOUND")
        local scrollingFrame = inventoryFrame:FindFirstChild("List"):FindFirstChild("ScrollingFrame")
        if scrollingFrame then
            print("Cars in inventory: " .. #scrollingFrame:GetChildren())
            
            -- Find Aston Martin 8 in inventory
            for _, item in pairs(scrollingFrame:GetChildren()) do
                if item.Name == "Car-AstonMartin8" then
                    print("✅ Found Car-AstonMartin8 in inventory")
                    print("  Class: " .. item.ClassName)
                    
                    -- Click it to see what happens
                    print("\n🖱️ Try clicking Car-AstonMartin8 in inventory")
                    print("Then check if it appears in your trade window")
                    print("And check OtherPlayer's trade window too")
                    
                    return item
                end
            end
        end
    end
    
    return nil
end

-- Check trade state
local function CheckTradeState()
    print("\n🔍 CHECKING TRADE STATE...")
    
    local inTrade = false
    
    pcall(function()
        local peerToPeer = Player.PlayerGui.Menu.Trading.PeerToPeer
        if peerToPeer and peerToPeer.Visible then
            inTrade = true
            print("✅ In PeerToPeer trade")
            
            -- Check if both players are ready
            local main = peerToPeer.Main
            if main then
                local localPlayer = main:FindFirstChild("LocalPlayer")
                local otherPlayer = main:FindFirstChild("OtherPlayer")
                
                if localPlayer and otherPlayer then
                    print("✅ Both players in trade")
                    print("  LocalPlayer: " .. tostring(localPlayer.Visible))
                    print("  OtherPlayer: " .. tostring(otherPlayer.Visible))
                end
            end
        else
            print("❌ Not in PeerToPeer trade")
        end
    end)
    
    return inTrade
end

-- Main test function
local function RunFocusedTests()
    print("\n🎯 RUNNING FOCUSED TESTS...")
    
    -- Check trade state first
    if not CheckTradeState() then
        print("❌ Start a trade first!")
        return false
    end
    
    -- Examine OtherPlayer frame (critical!)
    wait(1)
    ExamineOtherPlayerFrame()
    
    -- Monitor normal addition
    wait(1)
    MonitorNormalAdd()
    
    -- Test session IDs
    wait(1)
    local success, sessionId = TestOtherPlayerAsSession()
    
    if success then
        print("\n🎉 FOUND WORKING SESSION ID: " .. tostring(sessionId))
        return true
    end
    
    -- Try session confirmation
    wait(1)
    TestSessionConfirmation()
    
    print("\n" .. string.rep("=", 60))
    print("TEST COMPLETE")
    print("Key finding: OtherPlayer frame exists!")
    print("Session ID might be 'otherplayer' or related")
    print(string.rep("=", 60))
    
    return false
end

-- Create simple UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "FocusedTester"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "FOCUSED TRADE TESTER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    local status = Instance.new("TextLabel")
    status.Text = "Found OtherPlayer frame!\nTesting session IDs..."
    status.Size = UDim2.new(1, -20, 0, 110)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 230, 255)
    status.TextWrapped = true
    
    local testBtn = Instance.new("TextButton")
    testBtn.Text = "🚀 RUN FOCUSED TESTS"
    testBtn.Size = UDim2.new(1, -20, 0, 40)
    testBtn.Position = UDim2.new(0, 10, 0, 170)
    testBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    testBtn.MouseButton1Click:Connect(function()
        status.Text = "Running focused tests...\nCheck output!"
        testBtn.Text = "TESTING..."
        
        spawn(function()
            local success = RunFocusedTests()
            
            if success then
                status.Text = "✅ Found working session ID!\nCheck output"
                testBtn.Text = "🎉 SUCCESS"
                testBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            else
                status.Text = "❌ Need more testing\nSee output for details"
                testBtn.Text = "🚀 TRY AGAIN"
            end
            
            wait(2)
            testBtn.Text = "🚀 RUN FOCUSED TESTS"
            testBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
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
print("\n=== FOCUSED TRADE TESTER ===")
print("CRITICAL DISCOVERY: OtherPlayer frame exists!")
print("\n📋 WHAT THIS MEANS:")
print("1. The trade has LocalPlayer and OtherPlayer frames")
print("2. Session ID might be 'otherplayer' or related")
print("3. We're testing this hypothesis")
print("\n🔍 Click 'RUN FOCUSED TESTS' to test!")

-- Auto-run
spawn(function()
    wait(5)
    print("\n🔍 Auto-checking trade state...")
    CheckTradeState()
    
    wait(3)
    print("\n🔍 Examining OtherPlayer frame...")
    ExamineOtherPlayerFrame()
end)
