-- FIXED: SessionSetConfirmation is RemoteFunction
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get trading remotes
local TradingRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")

-- CORRECT: SessionSetConfirmation is RemoteFunction
local SessionSetConfirmation = TradingRemotes:WaitForChild("SessionSetConfirmation")
local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")
local OnSessionCountdownUpdated = TradingRemotes:WaitForChild("OnSessionCountdownUpdated")
local SessionCancel = TradingRemotes:WaitForChild("SessionCancel")

print("✅ Remotes found:")
print("SessionSetConfirmation type:", SessionSetConfirmation.ClassName)
print("SessionCancel type:", SessionCancel and SessionCancel.ClassName or "nil")

-- Variables
local ItemToDupe = nil
local CountdownTime = 0

-- Track items
OnSessionItemsUpdated.OnClientEvent:Connect(function(data)
    if data and data.Player == LocalPlayer then
        if data.Items and #data.Items > 0 then
            ItemToDupe = data.Items[1].Id
            print("✅ Car ID:", ItemToDupe)
        end
    end
end)

-- Track countdown
OnSessionCountdownUpdated.OnClientEvent:Connect(function(timeData)
    if timeData and timeData.Time then
        CountdownTime = timeData.Time
        if CountdownTime > 0 then
            print("⏰ Countdown:", CountdownTime .. "s")
        end
    end
end)

-- WORKING METHOD: REMOTEFUNCTION HOOK
local function remoteFunctionHook()
    if not ItemToDupe then
        print("❌ Add car first")
        return
    end
    
    print("🚀 REMOTEFUNCTION HOOK METHOD")
    
    -- Accept trade normally
    print("Step 1: Accepting trade...")
    local success, result = pcall(function()
        return SessionSetConfirmation:InvokeServer(true)
    end)
    
    if not success then
        print("❌ Failed to accept:", result)
        return
    end
    
    -- Wait for countdown
    print("Step 2: Waiting for countdown...")
    local waited = 0
    while CountdownTime == 0 and waited < 50 do
        wait(0.1)
        waited = waited + 1
    end
    
    if CountdownTime == 0 then
        print("❌ Countdown didn't start")
        print("Make sure other player accepts!")
        return
    end
    
    print("Countdown started: " .. CountdownTime .. "s")
    
    -- Hook the RemoteFunction
    print("Step 3: Hooking RemoteFunction...")
    
    local originalInvoke = SessionSetConfirmation.InvokeServer
    
    -- Replace InvokeServer method
    SessionSetConfirmation.InvokeServer = function(...)
        local args = {...}
        print("[HOOK] RemoteFunction called with:", args[1])
        
        -- If accepting, also send cancel
        if args[1] == true then
            print("[HOOK] Accept detected - sending cancel too!")
            
            -- Send original accept
            local acceptResult = originalInvoke(SessionSetConfirmation, true)
            
            -- Immediately send cancel (race condition)
            spawn(function()
                wait(0.001)
                print("[HOOK] Sending cancel...")
                pcall(function()
                    originalInvoke(SessionSetConfirmation, false)
                end)
                
                -- Send more cancels
                for i = 1, 3 do
                    wait(0.001)
                    pcall(function()
                        originalInvoke(SessionSetConfirmation, false)
                    end)
                end
            end)
            
            return acceptResult
        end
        
        -- Normal call
        return originalInvoke(SessionSetConfirmation, ...)
    end
    
    print("✅ RemoteFunction hooked!")
    
    -- Wait for optimal timing
    print("Step 4: Waiting for right moment...")
    while CountdownTime > 0.2 do
        wait(0.1)
    end
    
    -- Trigger the hook by "accepting" again
    print("🚨 Triggering hook at " .. CountdownTime .. "s...")
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    print("✅ Hook triggered!")
    print("Check if car duplicated!")
end

-- METHOD 2: DIRECT PACKET MANIPULATION
local function directPacketManipulation()
    print("💉 DIRECT PACKET MANIPULATION")
    
    -- Hook at the metatable level
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Target our trading RemoteFunction
        if method == "InvokeServer" and tostring(self) == "SessionSetConfirmation" then
            print("[METATABLE HOOK] Intercepted trade packet:", args[1])
            
            -- If this is an accept (true)
            if args[1] == true then
                -- Send the accept normally
                local result = oldNamecall(self, ...)
                
                -- But also queue a cancel
                spawn(function()
                    wait(0.001)  -- Tiny delay
                    print("[METATABLE HOOK] Queueing cancel...")
                    for i = 1, 5 do
                        pcall(function()
                            oldNamecall(self, false)
                        end)
                        wait(0.001)
                    end
                end)
                
                return result
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
    
    print("✅ Metatable hook installed!")
    print("Now accept the trade normally...")
end

-- METHOD 3: SIMULTANEOUS INVOKE
local function simultaneousInvoke()
    print("⚡ SIMULTANEOUS INVOKE")
    
    -- Create race condition by calling both at "same" time
    local function createRace()
        -- Call accept and cancel in rapid succession
        for i = 1, 20 do
            spawn(function()
                pcall(function()
                    SessionSetConfirmation:InvokeServer(true)
                end)
            end)
            
            spawn(function()
                pcall(function()
                    SessionSetConfirmation:InvokeServer(false)
                end)
            end)
            
            wait(0.001)
        end
    end
    
    -- Start trade
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    -- Wait for countdown
    while CountdownTime == 0 do
        wait(0.1)
    end
    
    print("Countdown: " .. CountdownTime .. "s")
    
    -- Create race at different timings
    local timings = {4.5, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0, 0.5, 0.3, 0.2, 0.1}
    
    for _, timing in ipairs(timings) do
        while CountdownTime > timing do
            wait(0.1)
        end
        
        print("🚨 Race condition at " .. CountdownTime .. "s")
        createRace()
        wait(0.5)
    end
    
    print("✅ Race conditions created!")
end

-- METHOD 4: SESSION CANCELLATION SPAM
local function sessionCancellationSpam()
    print("🔁 SESSION CANCELLATION SPAM")
    
    -- Start trade
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    -- Wait for countdown
    while CountdownTime == 0 do
        wait(0.1)
    end
    
    print("Countdown: " .. CountdownTime .. "s")
    
    -- Spam SessionCancel if it exists
    if SessionCancel then
        print("Found SessionCancel remote!")
        
        -- Wait for last second
        while CountdownTime > 1 do
            wait(0.1)
        end
        
        print("🚨 Spamming SessionCancel...")
        
        -- Spam cancellation
        for i = 1, 50 do
            spawn(function()
                pcall(function()
                    SessionCancel:InvokeServer()
                end)
            end)
            wait(0.01)
        end
        
        -- Also spam SetConfirmation false
        for i = 1, 50 do
            spawn(function()
                pcall(function()
                    SessionSetConfirmation:InvokeServer(false)
                end)
            end)
            wait(0.01)
        end
    else
        print("❌ SessionCancel not found")
    end
    
    print("✅ Cancellation spam complete!")
end

-- SIMPLE UI
local gui = Instance.new("ScreenGui")
gui.Name = "RemoteFunctionDupe"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 180)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(0, 1, 0)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "✅ REMOTEFUNCTION DUPE"
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Methods
local methods = {
    {"🚀 RemoteFunction Hook", remoteFunctionHook},
    {"💉 Direct Packet Manip", directPacketManipulation},
    {"⚡ Simultaneous Invoke", simultaneousInvoke},
    {"🔁 Session Cancel Spam", sessionCancellationSpam}
}

for i, method in ipairs(methods) do
    local btn = Instance.new("TextButton")
    btn.Text = method[1]
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0.15 + (i * 0.2), 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = frame
    btn.MouseButton1Click:Connect(method[2])
end

print("\n" .. string.rep("=", 60))
print("✅ FIXED: SessionSetConfirmation is REMOTEFUNCTION")
print(string.rep("=", 60))
print("RemoteFunctions use: :InvokeServer(args)")
print("RemoteEvents use: :FireServer(args)")
print(string.rep("=", 60))
print("BEST METHOD: RemoteFunction Hook")
print("It intercepts and modifies packets in real-time")
print(string.rep("=", 60))

-- Make functions global
_G.dupe = remoteFunctionHook
_G.hook = directPacketManipulation
_G.race = simultaneousInvoke

print("\nCommands available:")
print("_G.dupe() - Run main dupe method")
print("_G.hook() - Install packet hook")
print("_G.race() - Create race conditions")
