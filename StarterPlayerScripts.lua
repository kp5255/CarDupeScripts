-- Trade Duplicator with Real Session ID
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== TRADE DUPLICATOR WITH REAL SESSION ID ===")

-- Get services
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes
local SessionAddItem = tradingService.SessionAddItem

-- Get the Aston Martin 8 car ID
local function GetAstonMartinId()
    print("\n🔑 GETTING ASTON MARTIN ID...")
    
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

-- Find the REAL session ID from the trade UI
local function FindRealSessionId()
    print("\n🔍 FINDING REAL SESSION ID...")
    
    if not Player.PlayerGui then
        print("❌ No PlayerGui")
        return nil
    end
    
    -- Try to find session ID in the trade UI
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then
        print("❌ No Menu")
        return nil
    end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then
        print("❌ No Trading")
        return nil
    end
    
    -- Look through the entire trade UI for session info
    print("Searching for session information...")
    
    local foundSessionIds = {}
    
    -- Check all text in the trade UI
    for _, obj in pairs(trading:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local text = obj.Text
            if text and text ~= "" then
                -- Look for session-like patterns
                if text:find("Session") or text:find("session") or text:find("Trade ID") then
                    print("Found session text: \"" .. text .. "\"")
                    
                    -- Try to extract session ID
                    local patterns = {
                        "Session:?%s*([%w%-]+)",
                        "session:?%s*([%w%-]+)", 
                        "ID:?%s*([%w%-]+)",
                        "Trade:?%s*([%w%-]+)",
                        "([%w%-]+%-[%w%-]+%-[%w%-]+%-[%w%-]+%-[%w%-]+)", -- UUID pattern
                    }
                    
                    for _, pattern in ipairs(patterns) do
                        local sessionId = text:match(pattern)
                        if sessionId and sessionId ~= "Session" and sessionId ~= "session" then
                            print("✅ Extracted session ID: " .. sessionId)
                            table.insert(foundSessionIds, sessionId)
                        end
                    end
                end
            end
        end
    end
    
    -- Also check for any StringValue/IntValue that might be session ID
    for _, obj in pairs(trading:GetDescendants()) do
        if obj:IsA("StringValue") or obj:IsA("IntValue") then
            if obj.Name:lower():find("session") or obj.Name:lower():find("trade") then
                print("Found session value: " .. obj.Name .. " = " .. tostring(obj.Value))
                table.insert(foundSessionIds, tostring(obj.Value))
            end
        end
    end
    
    if #foundSessionIds > 0 then
        print("\n📋 Found " .. #foundSessionIds .. " potential session IDs:")
        for i, id in ipairs(foundSessionIds) do
            print(i .. ". " .. id)
        end
        
        -- Return the first one (most likely)
        return foundSessionIds[1]
    else
        print("❌ No session ID found in UI")
        return nil
    end
end

-- Try different session ID strategies
local function TryMultipleSessionIds(carId)
    print("\n🎯 TRYING MULTIPLE SESSION ID STRATEGIES...")
    
    -- Get car ID if not provided
    if not carId then
        carId = GetAstonMartinId()
        if not carId then return false end
    end
    
    print("Using car ID: " .. carId:sub(1, 8) .. "...")
    
    -- Different session ID strategies to try
    local sessionStrategies = {
        -- Strategy 1: Find in UI
        {name = "UI Search", func = FindRealSessionId},
        
        -- Strategy 2: Try common patterns
        {name = "Common Pattern 1", id = Player.UserId .. "-session"},
        {name = "Common Pattern 2", id = "trade-session-" .. Player.UserId},
        {name = "Common Pattern 3", id = "session-" .. os.time()},
        {name = "Common Pattern 4", id = "trade-" .. Player.UserId},
        
        -- Strategy 3: Try UUID format (like car ID)
        {name = "UUID Format", id = "00000000-0000-0000-0000-000000000000"},
        
        -- Strategy 4: Try empty/null session
        {name = "No Session", id = nil},
    }
    
    local successCount = 0
    
    for _, strategy in ipairs(sessionStrategies) do
        print("\n--- Strategy: " .. strategy.name .. " ---")
        
        local sessionId = nil
        
        if strategy.func then
            sessionId = strategy.func()
        else
            sessionId = strategy.id
        end
        
        if sessionId then
            print("Session ID: " .. sessionId)
            
            -- Try to add car
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
                for i = 1, 3 do
                    wait(0.2)
                    pcall(function()
                        SessionAddItem:InvokeServer(sessionId, carId)
                        print("   Repeated " .. i)
                    end)
                end
                
                return sessionId, true  -- Return successful session ID
            else
                print("❌ Failed: " .. tostring(result))
            end
        else
            print("No session ID from this strategy")
        end
        
        wait(0.3)
    end
    
    print("\n📊 Results: " .. successCount .. " successful strategies")
    return nil, successCount > 0
end

-- Check if we're in a trade
local function CheckIfInTrade()
    print("\n🔍 CHECKING IF IN TRADE...")
    
    if not Player.PlayerGui then
        print("❌ No PlayerGui")
        return false
    end
    
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then
        print("❌ No Menu")
        return false
    end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then
        print("❌ Trading not open")
        return false
    end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer or not peerToPeer.Visible then
        print("❌ Not in PeerToPeer trade")
        return false
    end
    
    print("✅ In a trade!")
    
    -- Check if there's another player in the trade
    local main = peerToPeer:FindFirstChild("Main")
    if main then
        local playerCount = 0
        for _, child in pairs(main:GetChildren()) do
            if child.Name ~= "LocalPlayer" then
                playerCount = playerCount + 1
            end
        end
        print("Other players in trade: " .. playerCount)
    end
    
    return true
end

-- Main duplication function
local function SmartDuplicate()
    print("\n🧠 SMART DUPLICATION...")
    
    -- Step 1: Check if we're in a trade
    if not CheckIfInTrade() then
        print("❌ Start a trade with another player first!")
        return false
    end
    
    -- Step 2: Get car ID
    local carId = GetAstonMartinId()
    if not carId then
        print("❌ Could not get car ID")
        return false
    end
    
    -- Step 3: Try to find working session ID
    wait(1)
    local sessionId, success = TryMultipleSessionIds(carId)
    
    if success and sessionId then
        print("\n🎉 FOUND WORKING SESSION ID: " .. sessionId)
        
        -- Add multiple copies
        print("\n📦 ADDING MULTIPLE COPIES...")
        for i = 1, 5 do
            pcall(function()
                SessionAddItem:InvokeServer(sessionId, carId)
                print("✅ Added copy " .. i)
            end)
            wait(0.2)
        end
        
        print("\n✅ Duplication complete!")
        print("Check if other player sees multiple cars")
        return true
    else
        print("\n❌ Could not find working session ID")
        print("The trade might not be fully set up")
        return false
    end
end

-- Alternative: Maybe we need to use a different remote
local function TryDifferentRemotes(carId)
    print("\n🔍 TRYING DIFFERENT TRADING REMOTES...")
    
    local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes
    
    -- List all remotes in trading service
    print("Available trading remotes:")
    local remotes = {}
    for _, remote in pairs(tradingService:GetChildren()) do
        print("  - " .. remote.Name .. " (" .. remote.ClassName .. ")")
        if remote:IsA("RemoteFunction") or remote:IsA("RemoteEvent") then
            table.insert(remotes, remote)
        end
    end
    
    -- Try different remotes with car ID
    for _, remote in ipairs(remotes) do
        print("\nTesting remote: " .. remote.Name)
        
        -- Try different parameter combinations
        local testParams = {
            {carId},
            {"session_1", carId},
            {Player.UserId, carId},
            {{item = carId}}
        }
        
        for _, params in ipairs(testParams) do
            print("  Params: " .. #params)
            
            local success, result = pcall(function()
                if remote:IsA("RemoteFunction") then
                    return remote:InvokeServer(unpack(params))
                else
                    return remote:FireServer(unpack(params))
                end
            end)
            
            if success then
                print("    ✅ Success!")
                if result then
                    print("    Result: " .. tostring(result))
                end
                return remote.Name, params
            else
                print("    ❌ Failed")
            end
            
            wait(0.2)
        end
    end
    
    return nil, nil
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SmartDuplicator"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "SMART DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    local status = Instance.new("TextLabel")
    status.Text = "Finding real session ID\nStart a trade first!"
    status.Size = UDim2.new(1, -20, 0, 110)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 230, 255)
    status.TextWrapped = true
    
    -- Buttons
    local buttons = {
        {text = "🔍 FIND SESSION ID", func = FindRealSessionId, pos = UDim2.new(0.025, 0, 0, 170)},
        {text = "🧠 SMART DUPLICATE", func = SmartDuplicate, pos = UDim2.new(0.525, 0, 0, 170)},
        {text = "🎯 TRY SESSION IDS", func = function()
            local carId = GetAstonMartinId()
            if carId then TryMultipleSessionIds(carId) end
        end, pos = UDim2.new(0.025, 0, 0, 210)},
        {text = "🔍 TRY REMOTES", func = function()
            local carId = GetAstonMartinId()
            if carId then TryDifferentRemotes(carId) end
        end, pos = UDim2.new(0.525, 0, 0, 210)}
    }
    
    for _, btnInfo in pairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.text
        btn.Size = UDim2.new(0.45, 0, 0, 30)
        btn.Position = btnInfo.pos
        btn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        btn.MouseButton1Click:Connect(function()
            status.Text = "Running: " .. btnInfo.text
            spawn(function()
                btnInfo.func()
                wait(0.5)
                status.Text = "Completed"
            end)
        end)
        
        btn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    frame.Parent = gui
    
    return status
end

-- Initialize
CreateUI()

-- Instructions
wait(3)
print("\n=== SMART DUPLICATOR READY ===")
print("We have the correct car ID but need the session ID")
print("\n📋 HOW TO USE:")
print("1. Start a trade with another player")
print("2. Wait for trade to fully load")
print("3. Click 'FIND SESSION ID' to search UI")
print("4. Click 'SMART DUPLICATE' to try all strategies")
print("5. Share the output with me!")

-- Auto-check
spawn(function()
    wait(5)
    print("\n🔍 Auto-checking trade status...")
    CheckIfInTrade()
end)
