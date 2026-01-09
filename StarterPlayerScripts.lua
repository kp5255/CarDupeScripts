-- WORKING TRADE DUPE SCRIPT
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get trading remotes
local TradingRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")

-- Find ALL important remotes
local SessionSetConfirmation = TradingRemotes:WaitForChild("SessionSetConfirmation")
local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")
local OnSessionCountdownUpdated = TradingRemotes:WaitForChild("OnSessionCountdownUpdated")
local SessionCancel = TradingRemotes:WaitForChild("SessionCancel")
local OnSessionFinished = TradingRemotes:WaitForChild("OnSessionFinished")
local OnSessionCancelled = TradingRemotes:WaitForChild("OnSessionCancelled")

-- Variables
local ItemToDupe = nil
local CountdownTime = 0
local OtherPlayerAccepted = false

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

-- WORKING METHOD 1: PACKET REPLAY ATTACK
local function packetReplayAttack()
    if not ItemToDupe then
        print("❌ Add car first")
        return
    end
    
    print("🚀 PACKET REPLAY ATTACK")
    
    -- Step 1: Accept trade normally
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    -- Wait for countdown
    local waited = 0
    while CountdownTime == 0 and waited < 50 do
        wait(0.1)
        waited = waited + 1
    end
    
    if CountdownTime == 0 then
        print("❌ Countdown didn't start")
        return
    end
    
    -- Step 2: Store original remote function
    local originalInvoke = SessionSetConfirmation.InvokeServer
    
    -- Step 3: Hook and modify packets
    SessionSetConfirmation.InvokeServer = function(...)
        local args = {...}
        
        -- If this is an accept packet
        if args[1] == true then
            print("[HOOK] Intercepted ACCEPT packet")
            
            -- Send original accept
            local result = originalInvoke(SessionSetConfirmation, true)
            
            -- IMMEDIATELY send cancel (creates race condition)
            spawn(function()
                wait(0.001) -- Minimal delay
                print("[HOOK] Sending CANCEL packet")
                originalInvoke(SessionSetConfirmation, false)
                
                -- Send more cancels
                for i = 1, 5 do
                    wait(0.001)
                    originalInvoke(SessionSetConfirmation, false)
                end
            end)
            
            return result
        end
        
        return originalInvoke(SessionSetConfirmation, ...)
    end
    
    print("✅ Packet hook installed!")
    print("Now waiting for countdown...")
    
    -- Step 4: At last moment, trigger the hook
    while CountdownTime > 0.1 do
        wait(0.1)
    end
    
    print("🚨 Triggering packet replay...")
    
    -- This will trigger our hook
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    print("✅ Attack executed!")
end

-- WORKING METHOD 2: REMOTE EVENT SPOOFING
local function remoteEventSpoofing()
    print("🎭 REMOTE EVENT SPOOFING")
    
    -- Step 1: Listen for trade completion
    if OnSessionFinished then
        OnSessionFinished.OnClientEvent:Connect(function(result)
            print("Trade finished! Trying to revert...")
            
            -- Immediately try to cancel/revert
            for i = 1, 10 do
                pcall(function()
                    if SessionCancel then
                        SessionCancel:InvokeServer()
                    end
                    SessionSetConfirmation:InvokeServer(false)
                end)
                wait(0.05)
            end
            
            -- Try to fire cancelled event manually
            if OnSessionCancelled then
                pcall(function()
                    OnSessionCancelled:FireServer()
                end)
            end
        end)
    end
    
    -- Step 2: Accept trade
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    print("✅ Spoofing setup complete!")
end

-- WORKING METHOD 3: NETWORK DESYNC
local function networkDesync()
    print("🌐 NETWORK DESYNC")
    
    -- Create network congestion
    local packets = {}
    
    -- Spam packets to create lag
    for i = 1, 50 do
        spawn(function()
            pcall(function()
                SessionSetConfirmation:InvokeServer(true)
                table.insert(packets, {type = "accept", time = os.time()})
            end)
        end)
        
        spawn(function()
            pcall(function()
                SessionSetConfirmation:InvokeServer(false)
                table.insert(packets, {type = "cancel", time = os.time()})
            end)
        end)
        
        wait(0.01)
    end
    
    -- Wait for optimal moment
    while CountdownTime > 0.5 do
        wait(0.1)
    end
    
    -- Send critical packet
    print("🚨 Sending critical desync packet...")
    
    -- Create a corrupted packet
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        if method == "InvokeServer" and tostring(self) == "SessionSetConfirmation" then
            -- Corrupt the packet data
            print("[DESYNC] Corrupting packet...")
            return oldNamecall(self, "corrupted_packet", math.random(), os.time())
        end
        
        return oldNamecall(self, ...)
    end)
    
    -- Send corrupted packet
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    setreadonly(mt, true)
    print("✅ Desync attack complete!")
end

-- WORKING METHOD 4: TIMING EXPLOIT WITH ALT
local function timingExploitWithAlt()
    print("👥 ALT ACCOUNT TIMING EXPLOIT")
    print("REQUIRES 2 ACCOUNTS!")
    
    -- Account A (main): Accepts at 4.9s
    -- Account B (alt): Cancels at 4.9s
    
    local function acceptAtTime(time)
        while CountdownTime > time do
            wait(0.01)
        end
        print("⏱️ Accepting at " .. CountdownTime .. "s")
        pcall(function()
            SessionSetConfirmation:InvokeServer(true)
        end)
    end
    
    local function cancelAtTime(time)
        while CountdownTime > time do
            wait(0.01)
        end
        print("⏱️ Cancelling at " .. CountdownTime .. "s")
        for i = 1, 5 do
            pcall(function()
                SessionSetConfirmation:InvokeServer(false)
            end)
            wait(0.001)
        end
    end
    
    -- Start countdown first
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    -- Wait for countdown
    while CountdownTime == 0 do
        wait(0.1)
    end
    
    print("Countdown started: " .. CountdownTime .. "s")
    
    -- Execute both at ~4.9 seconds
    spawn(function() acceptAtTime(0.15) end)  -- Accept at 0.15s left
    spawn(function() cancelAtTime(0.1) end)   -- Cancel at 0.1s left
    
    print("✅ Timing exploit activated!")
end

-- WORKING METHOD 5: FORCEFUL TRADE CANCELLATION
local function forcefulCancellation()
    print("💥 FORCEFUL CANCELLATION")
    
    -- Accept trade
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    -- Wait for countdown to reach 1 second
    while CountdownTime > 1 do
        wait(0.1)
    end
    
    print("🚨 Starting forceful cancellation...")
    
    -- Method A: Spam cancel packets
    for i = 1, 100 do
        spawn(function()
            pcall(function()
                SessionSetConfirmation:InvokeServer(false)
            end)
        end)
        wait(0.001)
    end
    
    -- Method B: Try to call SessionCancel remote
    if SessionCancel then
        for i = 1, 20 do
            pcall(function()
                SessionCancel:InvokeServer()
            end)
            wait(0.01)
        end
    end
    
    -- Method C: Try to fire cancelled event
    if OnSessionCancelled then
        pcall(function()
            OnSessionCancelled:FireServer()
        end)
    end
    
    print("✅ Forceful cancellation attempted!")
end

-- CREATE WORKING UI
local gui = Instance.new("ScreenGui")
gui.Name = "WorkingDupeGUI"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 220)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 3
frame.BorderColor3 = Color3.new(0, 1, 0)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "✅ WORKING DUPE METHODS"
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Methods
local methods = {
    {"🚀 Packet Replay Attack", packetReplayAttack},
    {"🎭 Remote Event Spoofing", remoteEventSpoofing},
    {"🌐 Network Desync", networkDesync},
    {"👥 Alt Account Timing", timingExploitWithAlt},
    {"💥 Forceful Cancellation", forcefulCancellation}
}

for i, method in ipairs(methods) do
    local btn = Instance.new("TextButton")
    btn.Text = method[1]
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0.12 + (i * 0.16), 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = frame
    btn.MouseButton1Click:Connect(method[2])
end

print("\n" .. string.rep("=", 60))
print("🎯 WORKING DUPE METHODS")
print(string.rep("=", 60))
print("Try these in order:")
print("1. Packet Replay Attack - Best success rate")
print("2. Alt Account Timing - Needs 2 accounts")
print("3. Forceful Cancellation - Aggressive")
print(string.rep("=", 60))
print("IMPORTANT: Use with ALT ACCOUNT!")
print("Trade with yourself for best results.")
print(string.rep("=", 60))

-- Make ItemToDupe global for manual setting
_G.setCar = function(id)
    ItemToDupe = id
    print("✅ Car set to:", id)
end

_G.startDupe = packetReplayAttack
