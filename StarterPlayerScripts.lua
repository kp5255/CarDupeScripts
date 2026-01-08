-- SIMPLE BUT EFFECTIVE TRADE DUPE
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local TradingRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")

-- Get the key remotes
local SessionAddItem = TradingRemotes:WaitForChild("SessionAddItem")
local SessionRemoveItem = TradingRemotes:WaitForChild("SessionRemoveItem")
local SessionSetConfirmation = TradingRemotes:WaitForChild("SessionSetConfirmation")
local SessionCancel = TradingRemotes:WaitForChild("SessionCancel")

if not (SessionAddItem and SessionSetConfirmation) then
    warn("Required remotes not found!")
    return
end

print("=== SIMPLE TRADE DUPE SCRIPT ===")

-- Track what we're trying to dupe
local itemToDupe = nil
local dupeAttempts = 0

-- Function to execute the dupe
local function executeSimpleDupe()
    if not itemToDupe then
        print("ERROR: No item selected to dupe!")
        print("Add a car to trade first, then run this function")
        return
    end
    
    print("Starting dupe sequence for item:", itemToDupe)
    dupeAttempts = dupeAttempts + 1
    
    -- SEQUENCE 1: Add item and immediately accept
    print("Step 1: Adding item to trade...")
    pcall(function()
        SessionAddItem:InvokeServer(itemToDupe)
    end)
    
    wait(0.5) -- Wait for server to register
    
    -- SEQUENCE 2: Rapid accept/cancel spam
    print("Step 2: Rapid accept/cancel sequence...")
    for i = 1, 10 do
        spawn(function()
            pcall(function()
                SessionSetConfirmation:InvokeServer(true) -- Accept
            end)
        end)
        
        spawn(function()
            wait(0.03) -- Tiny offset
            pcall(function()
                SessionSetConfirmation:InvokeServer(false) -- Cancel
            end)
        end)
        
        wait(0.1)
    end
    
    -- SEQUENCE 3: Try to remove item while trade is "processing"
    print("Step 3: Attempting to remove item during processing...")
    for i = 1, 5 do
        pcall(function()
            SessionRemoveItem:InvokeServer(itemToDupe)
        end)
        wait(0.1)
    end
    
    -- SEQUENCE 4: Cancel entire trade
    print("Step 4: Cancelling trade...")
    pcall(function()
        SessionCancel:InvokeServer()
    end)
    
    print("Dupe sequence #" .. dupeAttempts .. " complete!")
    print("Check if you still have the car AND if the other player got it too.")
end

-- Function to set item to dupe (run AFTER adding car to trade)
local function setItemToDupe()
    -- Listen for item updates to auto-detect
    local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")
    
    OnSessionItemsUpdated.OnClientEvent:Connect(function(itemsData)
        if itemsData and itemsData[LocalPlayer.UserId] then
            local myItems = itemsData[LocalPlayer.UserId]
            if #myItems > 0 then
                itemToDupe = myItems[1] -- Get first item
                print("Auto-detected item to dupe:", itemToDupe)
            end
        end
    end)
end

-- Create control GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "Trade Duplicator v3"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

-- Auto-detect button
local detectBtn = Instance.new("TextButton")
detectBtn.Text = "1. Auto-Detect Item"
detectBtn.Size = UDim2.new(0.9, 0, 0, 35)
detectBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
detectBtn.Parent = frame
detectBtn.MouseButton1Click:Connect(function()
    setItemToDupe()
    print("Auto-detection enabled. Add a car to trade.")
end)

-- Execute dupe button
local dupeBtn = Instance.new("TextButton")
dupeBtn.Text = "2. EXECUTE DUPE"
dupeBtn.Size = UDim2.new(0.9, 0, 0, 35)
dupeBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
dupeBtn.Parent = frame
dupeBtn.MouseButton1Click:Connect(executeSimpleDupe)

-- Instructions
print("\n=== INSTRUCTIONS ===")
print("1. Start a trade with someone (alt account best)")
print("2. Click 'Auto-Detect Item' button")
print("3. Add your car to the trade")
print("4. Click 'EXECUTE DUPE' button")
print("5. Check if car duplicated!")
print("\nTIP: Try multiple times if it doesn't work first time!")
