-- DELTA TRADE DUPE SCRIPT (Optimized for Delta Executor)
-- Works with 5-second countdown trade system

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Find trading remotes
local TradingRemotes = ReplicatedStorage:FindFirstChild("Remotes")
if TradingRemotes then
    TradingRemotes = TradingRemotes:FindFirstChild("Services")
    if TradingRemotes then
        TradingRemotes = TradingRemotes:FindFirstChild("TradingServiceRemotes")
    end
end

if not TradingRemotes then
    warn("❌ Trading remotes not found!")
    return
end

print("✅ Trading remotes found!")

-- Get specific remotes (with safe checking)
local function getRemote(name)
    local remote = TradingRemotes:FindFirstChild(name)
    if remote then
        print("✅ Found remote:", name)
        return remote
    else
        print("⚠️ Missing remote:", name)
        return nil
    end
end

local SessionAddItem = getRemote("SessionAddItem")
local SessionRemoveItem = getRemote("SessionRemoveItem")
local SessionSetConfirmation = getRemote("SessionSetConfirmation")
local SessionCancel = getRemote("SessionCancel")
local OnSessionItemsUpdated = getRemote("OnSessionItemsUpdated")
local OnSessionCountdownUpdated = getRemote("OnSessionCountdownUpdated")

if not SessionSetConfirmation then
    warn("❌ Critical remote (SessionSetConfirmation) not found!")
    return
end

print("\n" .. string.rep("=", 50))
print("DELTA TRADE DUPE SCRIPT LOADED!")
print(string.rep("=", 50))

-- Variables
local ItemToDupe = nil
local CountdownActive = false
local CountdownTime = 0

-- Track items in trade
if OnSessionItemsUpdated then
    OnSessionItemsUpdated.OnClientEvent:Connect(function(itemsData)
        if itemsData and type(itemsData) == "table" then
            for playerId, items in pairs(itemsData) do
                if playerId == LocalPlayer.UserId then
                    if #items > 0 then
                        ItemToDupe = items[1]
                        print("✅ Item detected for duping:", ItemToDupe)
                    end
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
            CountdownActive = timeLeft > 0
            if CountdownActive then
                print("⏰ Countdown: " .. timeLeft .. "s")
            end
        end
    end)
end

-- SIMPLE DUPE METHOD (Most reliable for Delta)
local function simpleDupe()
    if not ItemToDupe then
        print("❌ No item detected!")
        print("Please add a car to trade first")
        return
    end
    
    print("\n🚀 Starting SIMPLE DUPE method...")
    print("Item:", ItemToDupe)
    
    -- Step 1: Accept trade to start countdown
    print("\n[1/4] Accepting trade...")
    local success = pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    if not success then
        print("❌ Failed to accept trade")
        return
    end
    
    -- Step 2: Wait for countdown to start
    print("[2/4] Waiting for countdown...")
    for i = 1, 30 do  -- Wait up to 3 seconds
        if CountdownActive then break end
        wait(0.1)
    end
    
    if not CountdownActive then
        print("❌ Countdown didn't start!")
        print("Make sure other player also accepted")
        return
    end
    
    -- Step 3: Wait until 0.5 seconds left
    print("[3/4] Waiting for right moment...")
    while CountdownTime > 0.5 do
        wait(0.1)
    end
    
    -- Step 4: Cancel at last moment
    print("[4/4] Cancelling at last second!")
    
    -- Try multiple cancels for better chance
    for i = 1, 3 do
        pcall(function()
            SessionSetConfirmation:InvokeServer(false) -- Cancel
        end)
        wait(0.05)
    end
    
    -- Try to remove item
    wait(0.1)
    if SessionRemoveItem then
        pcall(function()
            SessionRemoveItem:InvokeServer(ItemToDupe)
        end)
    end
    
    print("\n✅ Dupe attempt complete!")
    print("Check if you still have the car!")
end

-- RAPID CANCEL METHOD
local function rapidCancelDupe()
    if not ItemToDupe then
        print("❌ No item detected!")
        return
    end
    
    print("\n⚡ Starting RAPID CANCEL dupe...")
    
    -- Accept trade
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    wait(0.5)
    
    -- Rapid cancel spam
    print("Spamming cancel...")
    for i = 1, 15 do
        pcall(function()
            SessionSetConfirmation:InvokeServer(false)
        end)
        wait(0.1)
    end
    
    print("✅ Rapid cancel complete!")
end

-- CREATE SIMPLE GUI (Delta compatible)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaDupeGUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 180)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
mainFrame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Text = "DELTA TRADE DUPE"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

-- Status
local status = Instance.new("TextLabel")
status.Name = "Status"
status.Text = "Status: Waiting for item..."
status.Size = UDim2.new(0.9, 0, 0, 30)
status.Position = UDim2.new(0.05, 0, 0.25, 0)
status.TextColor3 = Color3.new(1, 1, 0)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = mainFrame

-- Simple Dupe Button
local btn1 = Instance.new("TextButton")
btn1.Text = "🚀 SIMPLE DUPE"
btn1.Size = UDim2.new(0.9, 0, 0, 35)
btn1.Position = UDim2.new(0.05, 0, 0.45, 0)
btn1.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btn1.TextColor3 = Color3.new(1, 1, 1)
btn1.Font = Enum.Font.SourceSansBold
btn1.Parent = mainFrame

btn1.MouseButton1Click:Connect(function()
    simpleDupe()
end)

-- Rapid Cancel Button
local btn2 = Instance.new("TextButton")
btn2.Text = "⚡ RAPID CANCEL"
btn2.Size = UDim2.new(0.9, 0, 0, 35)
btn2.Position = UDim2.new(0.05, 0, 0.7, 0)
btn2.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
btn2.TextColor3 = Color3.new(1, 1, 1)
btn2.Parent = mainFrame

btn2.MouseButton1Click:Connect(function()
    rapidCancelDupe()
end)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Draggable GUI
local dragToggle = nil
local dragInput = nil
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragToggle = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
        updateInput(input)
    end
end)

-- Update status
game:GetService("RunService").Heartbeat:Connect(function()
    if ItemToDupe then
        status.Text = "✅ READY: Item detected"
        status.TextColor3 = Color3.new(0, 1, 0)
    else
        status.Text = "❌ WAITING: Add car to trade"
        status.TextColor3 = Color3.new(1, 0.5, 0)
    end
    
    if CountdownActive then
        status.Text = status.Text .. " | ⏰ " .. CountdownTime .. "s"
    end
end)

print("\n📋 INSTRUCTIONS:")
print("1. Start a trade with someone")
print("2. Add your car to the trade")
print("3. Wait for 'READY: Item detected'")
print("4. Click 'SIMPLE DUPE' button")
print("5. Other player must ALSO accept trade")
print("6. Script will cancel at last second")
print("\n💡 TIP: Use an alt account for best results!")
print("💡 TIP: Try multiple times if it fails!")

-- Keybind to toggle GUI
local UserInputService = game:GetService("UserInputService")
local guiVisible = true

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed then
        if input.KeyCode == Enum.KeyCode.RightControl then
            guiVisible = not guiVisible
            screenGui.Enabled = guiVisible
            if guiVisible then
                print("GUI shown (RightControl to hide)")
            else
                print("GUI hidden (RightControl to show)")
            end
        end
    end
end)

print("\n🎮 CONTROLS:")
print("• RightControl: Hide/Show GUI")
print("• Drag title bar: Move GUI")
print("• X button: Close GUI")
