-- Trade Parameter Capturer & Duplicator
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

wait(2)

print("=== TRADE PARAMETER CAPTURER ===")

-- Get remotes
local TradingServiceRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local SessionAddItem = TradingServiceRemotes:WaitForChild("SessionAddItem")

-- Store original function to capture calls
local originalInvoke = SessionAddItem.InvokeServer
local capturedCalls = {}

-- Hook the InvokeServer to capture successful calls
SessionAddItem.InvokeServer = function(self, ...)
    local args = {...}
    
    print("\n🎯 CAPTURED SessionAddItem CALL!")
    print("Number of arguments: " .. #args)
    
    -- Record the call
    table.insert(capturedCalls, {
        timestamp = os.time(),
        args = args,
        argCount = #args
    })
    
    -- Show details of each argument
    for i, arg in ipairs(args) do
        local argType = type(arg)
        print("  Arg " .. i .. ": Type = " .. argType)
        
        if argType == "string" then
            print("       Value = \"" .. arg .. "\"")
        elseif argType == "number" then
            print("       Value = " .. arg)
        elseif argType == "boolean" then
            print("       Value = " .. tostring(arg))
        elseif argType == "table" then
            print("       Table contents:")
            for k, v in pairs(arg) do
                print("         " .. tostring(k) .. " = " .. tostring(v))
            end
        elseif argType == "userdata" then
            if typeof(arg) == "Instance" then
                print("       Instance: " .. arg:GetFullName())
            else
                print("       Userdata: " .. typeof(arg))
            end
        else
            print("       Value = " .. tostring(arg))
        end
    end
    
    -- Try to call original
    local success, result = pcall(function()
        return originalInvoke(self, ...)
    end)
    
    if success then
        print("✅ Original call successful!")
        if result then
            print("   Result: " .. tostring(result))
        end
    else
        print("❌ Original call failed: " .. result)
    end
    
    return result
end

print("✅ Hooked SessionAddItem to capture parameters")

-- Function to manually test the remote
local function TestManualAdd()
    print("\n🧪 MANUAL TESTING SessionAddItem...")
    
    -- First, let's see what happens when you normally add a car
    print("1. Try adding a car NORMALLY through the game UI")
    print("2. Watch the CAPTURED output above")
    print("3. We'll see what parameters the game uses")
    
    -- Wait for user to add a car
    print("\n⏳ Waiting for you to add a car to trade...")
    print("(Click a car button in the trade window)")
    
    local initialCalls = #capturedCalls
    
    -- Wait for a call to be captured
    for i = 1, 30 do  -- Wait up to 30 seconds
        wait(1)
        if #capturedCalls > initialCalls then
            print("✅ Got it! Captured a successful call")
            break
        end
        if i % 5 == 0 then
            print("Still waiting... (" .. i .. "/30)")
        end
    end
    
    if #capturedCalls > initialCalls then
        local lastCall = capturedCalls[#capturedCalls]
        print("\n📋 CAPTURED PARAMETERS:")
        print("Argument count: " .. lastCall.argCount)
        
        -- Now try to duplicate using the same parameters
        print("\n🔄 ATTEMPTING TO DUPLICATE...")
        
        for i = 1, 5 do
            print("\nDuplicate attempt " .. i .. "...")
            local success, result = pcall(function()
                return SessionAddItem:InvokeServer(unpack(lastCall.args))
            end)
            
            if success then
                print("✅ Duplication successful!")
                if result then
                    print("   Result: " .. tostring(result))
                end
                return true
            else
                print("❌ Failed: " .. tostring(result))
            end
            
            wait(0.5)
        end
    else
        print("❌ No calls captured")
        print("Try adding a car to the trade window")
    end
    
    return false
end

-- Alternative: Try to find the correct parameters by brute force
local function BruteForceParameters()
    print("\n🔍 BRUTE FORCING PARAMETERS...")
    
    local carName = "Car-AstonMartin8"
    local playerId = Player.UserId
    
    -- Common parameter combinations to try
    local testCombinations = {
        -- Single argument
        {carName},
        {tostring(playerId)},
        {"trade"},
        
        -- Two arguments
        {"session_1", carName},
        {playerId, carName},
        {carName, 1},  -- Item + quantity
        {carName, "add"},
        
        -- Three arguments  
        {"session_1", carName, 1},
        {playerId, carName, 1},
        {carName, 1, true},
        
        -- Player as argument
        {Player, carName},
        {"session_1", Player, carName},
        
        -- Table formats
        {{item = carName}},
        {{item = carName, quantity = 1}},
        {"session_1", {item = carName}},
        {Player, {item = carName}}
    }
    
    local successCount = 0
    
    for i, params in ipairs(testCombinations) do
        print("\nTest " .. i .. ": " .. #params .. " params")
        
        -- Show params
        for j, param in ipairs(params) do
            local paramType = type(param)
            if paramType == "string" then
                print("  [" .. j .. "] String: \"" .. param .. "\"")
            elseif paramType == "table" then
                print("  [" .. j .. "] Table")
            else
                print("  [" .. j .. "] " .. tostring(param) .. " (" .. paramType .. ")")
            end
        end
        
        -- Try the call
        local success, result = pcall(function()
            return SessionAddItem:InvokeServer(unpack(params))
        end)
        
        if success then
            print("✅ SUCCESS!")
            if result then
                print("   Result: " .. tostring(result))
            end
            successCount = successCount + 1
            
            -- Try a few more times with same params
            for repeatCount = 1, 3 do
                wait(0.2)
                pcall(function()
                    SessionAddItem:InvokeServer(unpack(params))
                    print("   Repeated successfully")
                end)
            end
            
            break  -- Stop if we found working params
        else
            print("❌ Failed")
        end
        
        wait(0.3)
    end
    
    print("\n📊 Brute force results: " .. successCount .. " successful combinations")
    return successCount > 0
end

-- Get session ID from captured calls
local function GetSessionFromCaptured()
    if #capturedCalls == 0 then
        return nil
    end
    
    print("\n🔍 ANALYZING CAPTURED CALLS...")
    
    for i, call in ipairs(capturedCalls) do
        print("\nCall " .. i .. " (" .. call.argCount .. " args):")
        
        -- Look for session ID in arguments
        for j, arg in ipairs(call.args) do
            if type(arg) == "string" then
                if arg:find("session") or arg:find("trade_") then
                    print("  Potential session ID at arg " .. j .. ": " .. arg)
                    return arg
                end
            end
        end
    end
    
    return nil
end

-- Create monitoring UI
local function CreateMonitorUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeMonitor"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "TRADE PARAMETER CAPTURER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(50, 70, 90)
    title.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    local status = Instance.new("TextLabel")
    status.Text = "Monitoring SessionAddItem calls..."
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 230, 255)
    status.TextWrapped = true
    
    local callsLabel = Instance.new("TextLabel")
    callsLabel.Text = "Calls captured: 0"
    callsLabel.Size = UDim2.new(1, -20, 0, 30)
    callsLabel.Position = UDim2.new(0, 10, 0, 140)
    callsLabel.BackgroundTransparency = 1
    callsLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    
    -- Buttons
    local buttons = {
        {text = "📝 MANUAL TEST", func = TestManualAdd, pos = UDim2.new(0.025, 0, 0, 180)},
        {text = "🔍 BRUTE FORCE", func = BruteForceParameters, pos = UDim2.new(0.525, 0, 0, 180)},
        {text = "🔄 ANALYZE", func = GetSessionFromCaptured, pos = UDim2.new(0.025, 0, 0, 215)},
        {text = "📊 SHOW CALLS", func = function()
            print("\n📋 ALL CAPTURED CALLS (" .. #capturedCalls .. "):")
            for i, call in ipairs(capturedCalls) do
                print("\nCall " .. i .. " (" .. call.argCount .. " args):")
                for j, arg in ipairs(call.args) do
                    print("  [" .. j .. "] " .. type(arg) .. ": " .. tostring(arg))
                end
            end
        end, pos = UDim2.new(0.525, 0, 0, 215)}
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
                callsLabel.Text = "Calls captured: " .. #capturedCalls
            end)
        end)
        
        btn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    callsLabel.Parent = frame
    frame.Parent = gui
    
    -- Update calls count periodically
    spawn(function()
        while true do
            wait(1)
            callsLabel.Text = "Calls captured: " .. #capturedCalls
        end
    end)
    
    return status
end

-- Initialize
CreateMonitorUI()

-- Instructions
wait(3)
print("\n=== TRADE PARAMETER CAPTURER ACTIVE ===")
print("🎯 This script HOOKS SessionAddItem remote")
print("It captures parameters when you add items to trade")
print("\n📋 HOW TO USE:")
print("1. Start a trade with another player")
print("2. Add a car to trade NORMALLY (click it)")
print("3. Watch the CAPTURED output above")
print("4. Click 'ANALYZE' or 'SHOW CALLS' to see parameters")
print("5. Click 'MANUAL TEST' to try duplication")
print("\n⚠️ The key is capturing CORRECT parameters!")

-- Auto-update instructions
spawn(function()
    while true do
        wait(10)
        if #capturedCalls > 0 then
            print("\n🔔 TIP: Found " .. #capturedCalls .. " captured calls!")
            print("Click 'ANALYZE' to see session parameters")
            print("Click 'MANUAL TEST' to try duplication")
        end
    end
end)

-- Keybinds
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.M then
        print("\n🎮 M KEY - MANUAL TEST")
        TestManualAdd()
    elseif input.KeyCode == Enum.KeyCode.B then
        print("\n🎮 B KEY - BRUTE FORCE")
        BruteForceParameters()
    end
end)

print("\n🔑 QUICK KEYS:")
print("M = Manual test (capture & duplicate)")
print("B = Brute force parameters")
