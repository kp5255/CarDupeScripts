-- FINAL FIXED TRADE DUPE
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get trading remotes
local TradingRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local SessionSetConfirmation = TradingRemotes:WaitForChild("SessionSetConfirmation")
local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")
local OnSessionCountdownUpdated = TradingRemotes:WaitForChild("OnSessionCountdownUpdated")

-- Variables
local ItemToDupe = nil
local CountdownTime = 0
local HookInstalled = false

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

-- INSTALL METATABLE HOOK (DO THIS FIRST)
local function installMetatableHook()
    if HookInstalled then
        print("✅ Hook already installed")
        return
    end
    
    print("🔧 Installing metatable hook...")
    
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Target SessionSetConfirmation RemoteFunction
        if method == "InvokeServer" and self == SessionSetConfirmation then
            print("[METATABLE HOOK] Intercepted:", args[1])
            
            -- If this is an accept (true)
            if args[1] == true then
                -- Send original accept
                local result = oldNamecall(self, ...)
                
                -- Queue automatic cancel
                spawn(function()
                    wait(0.001)
                    print("[METATABLE HOOK] Auto-cancelling...")
                    for i = 1, 3 do
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
    HookInstalled = true
    print("✅ Metatable hook installed!")
end

-- SIMPLE DUPE FUNCTION
local function simpleDupe()
    if not ItemToDupe then
        print("❌ Add car first")
        return
    end
    
    print("🚀 Starting dupe...")
    print("Car:", ItemToDupe)
    
    -- Install hook if not already
    if not HookInstalled then
        installMetatableHook()
    end
    
    -- Accept trade (hook will auto-cancel)
    print("Accepting trade...")
    local success, result = pcall(function()
        return SessionSetConfirmation:InvokeServer(true)
    end)
    
    if not success then
        print("❌ Failed:", result)
        return
    end
    
    -- Wait for countdown
    print("Waiting for countdown...")
    local waited = 0
    while CountdownTime == 0 and waited < 50 do
        wait(0.1)
        waited = waited + 1
    end
    
    if CountdownTime == 0 then
        print("❌ No countdown - other player needs to accept")
        return
    end
    
    print("Countdown active:", CountdownTime .. "s")
    
    -- Wait for optimal timing
    while CountdownTime > 0.3 do
        wait(0.1)
    end
    
    -- Send another accept to trigger hook again
    print("🚨 Sending final accept at " .. CountdownTime .. "s")
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    print("✅ Dupe attempt complete!")
end

-- MANUAL TRIGGER FUNCTION
local function manualTrigger()
    print("🎮 MANUAL TRIGGER")
    
    if not HookInstalled then
        installMetatableHook()
    end
    
    -- Just send an accept to trigger the hook
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    print("✅ Trigger sent!")
end

-- COUNTDOWN TRIGGER (for precise timing)
local function countdownTrigger()
    print("⏱️ COUNTDOWN TRIGGER")
    
    if not HookInstalled then
        installMetatableHook()
    end
    
    -- Wait for specific countdown times
    local triggerTimes = {4.5, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0, 0.5, 0.4, 0.3, 0.2, 0.1}
    
    for _, triggerTime in pairs(triggerTimes) do
        while CountdownTime > triggerTime do
            wait(0.1)
        end
        
        print("🚨 Triggering at " .. CountdownTime .. "s")
        pcall(function()
            SessionSetConfirmation:InvokeServer(true)
        end)
        
        wait(0.3) -- Wait between triggers
    end
    
    print("✅ All triggers sent!")
end

-- CREATE SIMPLE UI
local gui = Instance.new("ScreenGui")
gui.Name = "FinalDupe"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 120)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(0, 1, 0)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "≡ FINAL DUPE"
title.Size = UDim2.new(1, 0, 0, 20)
title.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

-- Status
local status = Instance.new("TextLabel")
status.Text = "Add car"
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0.2, 0)
status.TextColor3 = Color3.new(1, 1, 0)
status.TextSize = 12
status.Parent = frame

-- Install Hook button
local btnHook = Instance.new("TextButton")
btnHook.Text = "🔧 INSTALL HOOK"
btnHook.Size = UDim2.new(0.9, 0, 0, 25)
btnHook.Position = UDim2.new(0.05, 0, 0.4, 0)
btnHook.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
btnHook.TextColor3 = Color3.new(1, 1, 1)
btnHook.Parent = frame
btnHook.MouseButton1Click:Connect(installMetatableHook)

-- Start Dupe button
local btnDupe = Instance.new("TextButton")
btnDupe.Text = "🚀 START DUPE"
btnDupe.Size = UDim2.new(0.9, 0, 0, 25)
btnDupe.Position = UDim2.new(0.05, 0, 0.7, 0)
btnDupe.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnDupe.TextColor3 = Color3.new(1, 1, 1)
btnDupe.Parent = frame
btnDupe.MouseButton1Click:Connect(simpleDupe)

-- Close
local btnClose = Instance.new("TextButton")
btnClose.Text = "X"
btnClose.Size = UDim2.new(0, 20, 0, 20)
btnClose.Position = UDim2.new(1, -20, 0, 0)
btnClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnClose.TextColor3 = Color3.new(1, 1, 1)
btnClose.Parent = frame
btnClose.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Update status
game:GetService("RunService").Heartbeat:Connect(function()
    if ItemToDupe then
        status.Text = "✅ READY"
        status.TextColor3 = Color3.new(0, 1, 0)
    else
        status.Text = "Add car"
        status.TextColor3 = Color3.new(1, 1, 0)
    end
    
    if CountdownTime > 0 then
        status.Text = status.Text .. " " .. CountdownTime .. "s"
    end
    
    if HookInstalled then
        btnHook.Text = "✅ HOOK INSTALLED"
        btnHook.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end)

print("\n" .. string.rep("=", 60))
print("🎯 FINAL DUPE SCRIPT - FIXED")
print(string.rep("=", 60))
print("HOW TO USE:")
print("1. Click '🔧 INSTALL HOOK' button")
print("2. Start trade with alt account")
print("3. Add car to trade")
print("4. Wait for '✅ READY' message")
print("5. Click '🚀 START DUPE' button")
print("6. Other player MUST accept")
print("7. Hook will auto-cancel for you")
print(string.rep("=", 60))
print("The hook intercepts ALL trade packets")
print("and automatically sends cancels!")
print(string.rep("=", 60))

-- Make functions global
_G.install = installMetatableHook
_G.start = simpleDupe
_G.trigger = manualTrigger
_G.timed = countdownTrigger

print("\nConsole commands:")
print("_G.install() - Install metatable hook")
print("_G.start()   - Start dupe sequence")
print("_G.trigger() - Manually trigger hook")
print("_G.timed()   - Trigger at all timings")
