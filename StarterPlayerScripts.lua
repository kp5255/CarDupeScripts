-- MOBILE TRADE DUPE SCRIPT (For Delta Android)
-- Optimized for touch controls and mobile performance

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Find trading remotes
local TradingRemotes = ReplicatedStorage:WaitForChild("Remotes", 10)
if TradingRemotes then
    TradingRemotes = TradingRemotes:WaitForChild("Services", 10)
    if TradingRemotes then
        TradingRemotes = TradingRemotes:WaitForChild("TradingServiceRemotes", 10)
    end
end

if not TradingRemotes then
    warn("❌ Trading system not found!")
    return
end

print("✅ Trading system found!")

-- Get remotes with mobile-safe checks
local function safeGetRemote(name)
    local remote = TradingRemotes:FindFirstChild(name)
    if remote then
        print("📱 Found:", name)
        return remote
    end
    return nil
end

-- Essential remotes
local SessionSetConfirmation = safeGetRemote("SessionSetConfirmation")
local OnSessionItemsUpdated = safeGetRemote("OnSessionItemsUpdated")
local OnSessionCountdownUpdated = safeGetRemote("OnSessionCountdownUpdated")

if not SessionSetConfirmation then
    warn("❌ Cannot find SessionSetConfirmation!")
    return
end

print("\n📱 MOBILE TRADE DUPE LOADED")

-- Variables for mobile
local ItemToDupe = nil
local CountdownTime = 0
local DupeAttempts = 0

-- Track items (MOBILE OPTIMIZED - less frequent updates)
if OnSessionItemsUpdated then
    OnSessionItemsUpdated.OnClientEvent:Connect(function(itemsData)
        if type(itemsData) == "table" then
            for playerId, items in pairs(itemsData) do
                if playerId == LocalPlayer.UserId and #items > 0 then
                    ItemToDupe = items[1]
                    print("✅ Car detected!")
                end
            end
        end
    end)
end

-- Track countdown
if OnSessionCountdownUpdated then
    OnSessionCountdownUpdated.OnClientEvent:Connect(function(timeLeft)
        if timeLeft then
            CountdownTime = timeLeft
            if timeLeft > 0 then
                print("⏰ " .. timeLeft .. "s")
            end
        end
    end)
end

-- SIMPLE MOBILE DUPE (Most reliable)
local function mobileSimpleDupe()
    if not ItemToDupe then
        print("❌ Add car to trade first!")
        return
    end
    
    DupeAttempts = DupeAttempts + 1
    print("\n🚀 Attempt #" .. DupeAttempts .. " starting...")
    
    -- Step 1: Accept trade
    print("1️⃣ Accepting trade...")
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    -- Step 2: Wait for countdown
    print("2️⃣ Waiting for countdown...")
    local waited = 0
    while CountdownTime == 0 and waited < 5 do
        wait(1)
        waited = waited + 1
        print("   Waiting... " .. waited .. "s")
    end
    
    if CountdownTime == 0 then
        print("❌ Countdown didn't start!")
        print("   Make sure other player accepts!")
        return
    end
    
    -- Step 3: Wait for last moment (MOBILE TIMING - slower)
    print("3️⃣ Waiting for right moment...")
    while CountdownTime > 1.0 do  -- Mobile needs more time
        wait(0.5)
    end
    
    -- Step 4: Cancel at last second
    print("4️⃣ 🚨 CANCELLING NOW! 🚨")
    
    -- Mobile: Send cancel 3 times (network can be slower)
    for i = 1, 3 do
        pcall(function()
            SessionSetConfirmation:InvokeServer(false)
        end)
        wait(0.2)  -- Mobile-friendly delay
    end
    
    print("\n✅ Attempt complete!")
    print("📱 Check your inventory!")
end

-- AUTOMATIC DUPE (One-click for mobile)
local function autoDupe()
    print("\n🤖 AUTOMATIC DUPE MODE")
    print("Will try 3 times automatically")
    
    for attempt = 1, 3 do
        print("\n--- Attempt " .. attempt .. " ---")
        mobileSimpleDupe()
        wait(2)  -- Wait between attempts
    end
    
    print("\n🎯 All attempts complete!")
end

-- Create MOBILE-FRIENDLY GUI (Big buttons for touch)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileDupeGUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0.8, 0, 0.6, 0)  -- Big for mobile
mainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
mainFrame.Parent = screenGui

-- Title (Big for mobile)
local title = Instance.new("TextLabel")
title.Text = "📱 MOBILE DUPE"
title.Size = UDim2.new(1, 0, 0.15, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24  -- Big text
title.Parent = mainFrame

-- Status (Big text)
local status = Instance.new("TextLabel")
status.Name = "Status"
status.Text = "Waiting for car..."
status.Size = UDim2.new(0.9, 0, 0.15, 0)
status.Position = UDim2.new(0.05, 0, 0.2, 0)
status.TextColor3 = Color3.new(1, 1, 0)
status.TextSize = 18
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = mainFrame

-- Big button for simple dupe (Easy to tap)
local btnDupe = Instance.new("TextButton")
btnDupe.Text = "🚀 START DUPE"
btnDupe.Size = UDim2.new(0.9, 0, 0.2, 0)  -- Big button
btnDupe.Position = UDim2.new(0.05, 0, 0.4, 0)
btnDupe.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
btnDupe.TextColor3 = Color3.new(1, 1, 1)
btnDupe.Font = Enum.Font.SourceSansBold
btnDupe.TextSize = 22
btnDupe.Parent = mainFrame

btnDupe.MouseButton1Click:Connect(function()
    mobileSimpleDupe()
end)

-- Auto dupe button
local btnAuto = Instance.new("TextButton")
btnAuto.Text = "🤖 AUTO DUPE (3x)"
btnAuto.Size = UDim2.new(0.9, 0, 0.2, 0)
btnAuto.Position = UDim2.new(0.05, 0, 0.65, 0)
btnAuto.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
btnAuto.TextColor3 = Color3.new(1, 1, 1)
btnAuto.Font = Enum.Font.SourceSansBold
btnAuto.TextSize = 20
btnAuto.Parent = mainFrame

btnAuto.MouseButton1Click:Connect(function()
    autoDupe()
end)

-- Close button (Big X)
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✖️ CLOSE"
closeBtn.Size = UDim2.new(0.4, 0, 0.1, 0)
closeBtn.Position = UDim2.new(0.3, 0, 0.88, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    print("GUI closed!")
end)

-- Update status for mobile
game:GetService("RunService").Heartbeat:Connect(function()
    if ItemToDupe then
        status.Text = "✅ READY: Tap START DUPE"
        status.TextColor3 = Color3.new(0, 1, 0)
    else
        status.Text = "❌ Add car to trade..."
        status.TextColor3 = Color3.new(1, 0.5, 0)
    end
    
    if CountdownTime > 0 then
        status.Text = status.Text .. "\n⏰ " .. CountdownTime .. "s"
    end
end)

-- Make GUI draggable for mobile (touch-friendly)
local dragging = false
local dragStart = nil
local startPos = nil

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

print("\n" .. string.rep("=", 40))
print("📱 MOBILE DUPE INSTRUCTIONS:")
print(string.rep("=", 40))
print("1. Start trade with someone")
print("2. Add your car to trade")
print("3. Wait for ✅ READY message")
print("4. Tap 🚀 START DUPE button")
print("5. Other player MUST accept")
print("6. Wait for countdown")
print("7. Script cancels automatically")
print("8. Check if car duplicated!")
print(string.rep("=", 40))
print("\n💡 TIPS FOR MOBILE:")
print("• Use GOOD INTERNET (WiFi recommended)")
print("• Keep screen ON during process")
print("• Try multiple times if fails")
print("• Drag title to move GUI")
print("• Tap ✖️ CLOSE to remove GUI")

-- Mobile notification system
local function mobileNotify(message)
    print("📢 " .. message)
    
    -- Try to create a popup (mobile-friendly)
    local notify = Instance.new("TextLabel")
    notify.Text = message
    notify.Size = UDim2.new(0.8, 0, 0.1, 0)
    notify.Position = UDim2.new(0.1, 0, 0.05, 0)
    notify.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notify.TextColor3 = Color3.new(1, 1, 1)
    notify.TextSize = 16
    notify.ZIndex = 100
    notify.Parent = screenGui
    
    -- Auto-remove after 3 seconds
    delay(3, function()
        if notify then
            notify:Destroy()
        end
    end)
end

-- Auto-start detection
mobileNotify("Mobile Dupe Script Loaded!")
mobileNotify("Add car to trade to begin")

-- Add help text at bottom
local helpText = Instance.new("TextLabel")
helpText.Text = "Need help? Make sure:\n1. Trade is active\n2. Car added to trade\n3. Other player accepts"
helpText.Size = UDim2.new(1, 0, 0.2, 0)
helpText.Position = UDim2.new(0, 0, 0.9, 0)
helpText.TextColor3 = Color3.new(1, 1, 1)
helpText.TextSize = 14
helpText.TextYAlignment = Enum.TextYAlignment.Top
helpText.BackgroundTransparency = 1
helpText.Parent = mainFrame
