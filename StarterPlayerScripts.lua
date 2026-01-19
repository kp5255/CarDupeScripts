-- Trade Session Reverse Engineer
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== TRADE SESSION REVERSE ENGINEER ===")

-- Get trading service
local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes

-- Try to understand the session flow
local function AnalyzeSessionFlow()
    print("\n🔄 ANALYZING SESSION FLOW...")
    
    -- List all session-related remotes
    print("\n📋 SESSION REMOTES:")
    local sessionRemotes = {}
    for _, remote in pairs(tradingService:GetChildren()) do
        local name = remote.Name
        if name:find("Session") or name:find("Invite") then
            local remoteType = remote.ClassName
            print("  " .. name .. " (" .. remoteType .. ")")
            table.insert(sessionRemotes, {
                name = name,
                type = remoteType,
                remote = remote
            })
        end
    end
    
    -- Try to understand the flow
    print("\n🎯 POSSIBLE SESSION FLOW:")
    print("1. Player A invites Player B (Invite remote)")
    print("2. Player B accepts (InviteAccept remote)")
    print("3. Session is created on server (SessionStarted event)")
    print("4. Session ID is generated server-side")
    print("5. Clients use the session ID without seeing it")
    
    return sessionRemotes
end

-- Try to get current session through remotes
local function TryToGetSessionThroughRemotes()
    print("\n🔍 TRYING TO GET SESSION THROUGH REMOTES...")
    
    -- Try Invite remote to see if it returns session info
    local Invite = tradingService:FindFirstChild("Invite")
    if Invite and Invite:IsA("RemoteFunction") then
        print("Testing Invite remote...")
        
        -- Try to get info about current session
        local success, result = pcall(function()
            -- Try different parameters
            return Invite:InvokeServer("get_session", Player)
        end)
        
        if success then
            print("✅ Invite returned: " .. tostring(result))
        else
            print("❌ Invite failed: " .. tostring(result))
        end
    end
    
    -- Try OnSessionStarted event listener
    local OnSessionStarted = tradingService:FindFirstChild("OnSessionStarted")
    if OnSessionStarted and OnSessionStarted:IsA("RemoteEvent") then
        print("\nOnSessionStarted event exists")
        print("This fires when a session starts")
        
        -- Hook into it to see what data it sends
        local connection = OnSessionStarted.OnClientEvent:Connect(function(...)
            local args = {...}
            print("\n🎯 OnSessionStarted FIRED!")
            print("Args: " .. #args)
            for i, arg in ipairs(args) do
                print("  [" .. i .. "] " .. type(arg) .. ": " .. tostring(arg))
            end
        end)
        
        print("✅ Hooked into OnSessionStarted")
    end
end

-- Check what's in the trade UI right now
local function InspectTradeUI()
    print("\n🔍 INSPECTING TRADE UI STATE...")
    
    if not Player.PlayerGui then return end
    
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then return end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then return end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then return end
    
    -- Check Top bar
    local top = peerToPeer:FindFirstChild("Top")
    if top then
        print("\n📊 TOP BAR:")
        for _, child in pairs(top:GetChildren()) do
            print("  " .. child.Name .. " (" .. child.ClassName .. ")")
            if child:IsA("TextLabel") then
                print("    Text: \"" .. child.Text .. "\"")
            end
        end
    end
    
    -- Check Main
    local main = peerToPeer:FindFirstChild("Main")
    if main then
        print("\n📊 MAIN CONTAINER:")
        
        -- Check LocalPlayer
        local localPlayer = main:FindFirstChild("LocalPlayer")
        if localPlayer then
            print("  LocalPlayer frame exists")
            
            -- Check for any data in LocalPlayer
            for _, child in pairs(localPlayer:GetChildren()) do
                if child:IsA("StringValue") or child:IsA("IntValue") then
                    print("    Value: " .. child.Name .. " = " .. tostring(child.Value))
                end
            end
        end
        
        -- Check if there's another player frame
        for _, child in pairs(main:GetChildren()) do
            if child.Name ~= "LocalPlayer" and child.Name ~= "Inventory" then
                print("  Other player frame: " .. child.Name)
            end
        end
    end
end

-- Try a different approach: Maybe session ID is the other player's UserId
local function TryPlayerIdAsSession()
    print("\n🎯 TRYING PLAYER ID AS SESSION...")
    
    -- Get the other player from the trade UI
    local otherPlayerName = nil
    
    if Player.PlayerGui then
        pcall(function()
            local menu = Player.PlayerGui.Menu
            local trading = menu.Trading
            local peerToPeer = trading.PeerToPeer
            local top = peerToPeer.Top
            
            -- Extract name from "Trading with @KahanGamerYT"
            for _, child in pairs(top:GetChildren()) do
                if child:IsA("TextLabel") and child.Text:find("Trading with") then
                    otherPlayerName = child.Text:match("@(%w+)")
                    break
                end
            end
        end)
    end
    
    if otherPlayerName then
        print("Other player: @" .. otherPlayerName)
        
        -- Try to find this player
        local otherPlayer = nil
        for _, player in pairs(Players:GetPlayers()) do
            if player.Name == otherPlayerName then
                otherPlayer = player
                break
            end
        end
        
        if otherPlayer then
            print("Found player: " .. otherPlayer.Name)
            print("UserID: " .. otherPlayer.UserId)
            
            -- Try these as session IDs
            local possibleSessionIds = {
                tostring(otherPlayer.UserId),
                Player.UserId .. "_" .. otherPlayer.UserId,
                "session_" .. otherPlayer.UserId,
                otherPlayer.UserId .. "_trade"
            }
            
            return possibleSessionIds, otherPlayer
        end
    end
    
    print("❌ Could not identify other player")
    return nil, nil
end

-- Test with possible session IDs
local function TestSessionIds(possibleIds)
    print("\n🧪 TESTING POSSIBLE SESSION IDs...")
    
    if not possibleIds or #possibleIds == 0 then
        print("❌ No session IDs to test")
        return false
    end
    
    local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
    local SessionAddItem = tradingService.SessionAddItem
    
    -- Get car ID
    local carId = nil
    pcall(function()
        local carList = carService.GetOwnedCars:InvokeServer()
        for _, carData in ipairs(carList) do
            if type(carData) == "table" and carData.Name == "AstonMartin8" then
                carId = carData.Id
                break
            end
        end
    end)
    
    if not carId then
        print("❌ Could not get car ID")
        return false
    end
    
    print("Car ID: " .. carId:sub(1, 8) + "...")
    
    local successCount = 0
    
    for i, sessionId in ipairs(possibleIds) do
        print("\nTest " .. i .. ": " .. sessionId)
        
        local success, result = pcall(function()
            return SessionAddItem:InvokeServer(sessionId, carId)
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
                    SessionAddItem:InvokeServer(sessionId, carId)
                    print("   Repeated " .. j)
                end)
            end
            
            return true  -- Stop if successful
        else
            print("❌ Failed: " .. tostring(result))
        end
        
        wait(0.3)
    end
    
    print("\n📊 Results: " .. successCount .. "/" .. #possibleIds .. " successful")
    return successCount > 0
end

-- Alternative: Maybe we don't need session ID at all
local function TryWithoutSessionId()
    print("\n🎯 TRYING WITHOUT SESSION ID...")
    
    local SessionAddItem = tradingService.SessionAddItem
    local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
    
    -- Get car ID
    local carId = nil
    pcall(function()
        local carList = carService.GetOwnedCars:InvokeServer()
        for _, carData in ipairs(carList) do
            if type(carData) == "table" and carData.Name == "AstonMartin8" then
                carId = carData.Id
                break
            end
        end
    end)
    
    if not carId then
        print("❌ Could not get car ID")
        return false
    end
    
    print("Car ID: " .. carId:sub(1, 8) + "...")
    
    -- Try different parameter formats WITHOUT session ID
    local testCases = {
        {name = "Just car ID", params = {carId}},
        {name = "Car ID as table", params = {{id = carId}}},
        {name = "Player + car", params = {Player, carId}},
        {name = "Just player", params = {Player}},
    }
    
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
            return true
        else
            print("❌ Failed: " .. tostring(result))
        end
        
        wait(0.3)
    end
    
    return false
end

-- Main function
local function RunAllTests()
    print("\n🚀 RUNNING ALL TESTS...")
    
    -- Analyze session flow
    AnalyzeSessionFlow()
    
    -- Try to get session through remotes
    wait(1)
    TryToGetSessionThroughRemotes()
    
    -- Inspect UI
    wait(1)
    InspectTradeUI()
    
    -- Try player ID as session
    wait(1)
    local possibleIds, otherPlayer = TryPlayerIdAsSession()
    
    -- Test with possible session IDs
    if possibleIds then
        wait(1)
        TestSessionIds(possibleIds)
    end
    
    -- Try without session ID
    wait(1)
    TryWithoutSessionId()
    
    print("\n" .. string.rep("=", 60))
    print("TESTING COMPLETE")
    print("=" .. string.rep("=", 60))
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SessionReverseEngineer"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 200)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "SESSION REVERSE ENGINEER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    local status = Instance.new("TextLabel")
    status.Text = "Trying different approaches\nto find session ID"
    status.Size = UDim2.new(1, -20, 0, 110)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 230, 255)
    status.TextWrapped = true
    
    local testBtn = Instance.new("TextButton")
    testBtn.Text = "🚀 RUN ALL TESTS"
    testBtn.Size = UDim2.new(1, -20, 0, 40)
    testBtn.Position = UDim2.new(0, 10, 0, 170)
    testBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    testBtn.MouseButton1Click:Connect(function()
        status.Text = "Running all tests...\nThis may take a minute"
        testBtn.Text = "TESTING..."
        
        spawn(function()
            RunAllTests()
            
            status.Text = "✅ Tests complete!\nCheck output window"
            
            wait(2)
            testBtn.Text = "🚀 RUN ALL TESTS"
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
print("\n=== SESSION REVERSE ENGINEER ===")
print("Session ID is NOT in UI - trying different approaches")
print("\n📋 TESTING STRATEGIES:")
print("1. Analyze session flow from remotes")
print("2. Try to get session through remotes")
print("3. Use other player's ID as session")
print("4. Try without session ID")
print("\n🔍 Click 'RUN ALL TESTS' to start!")

-- Auto-run tests after delay
spawn(function()
    wait(10)
    print("\n🔍 Auto-running tests in 10 seconds...")
    print("Make sure you're in a trade!")
    
    wait(10)
    print("\n🔍 Starting tests...")
    RunAllTests()
end)
