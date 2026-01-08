-- FIXED Trade Dupe Script
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

print("=== TRADE DUPE SCRIPT (FIXED) ===")

-- GLOBAL variable to store item
_G.ItemToDupe = nil
local dupeAttempts = 0

-- Listen for item updates
local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")

OnSessionItemsUpdated.OnClientEvent:Connect(function(itemsData)
    if itemsData and itemsData[LocalPlayer.UserId] then
        local myItems = itemsData[LocalPlayer.UserId]
        if #myItems > 0 then
            _G.ItemToDupe = myItems[1] -- Get first item
            print("✅ Auto-detected item:", _G.ItemToDupe)
        end
    end
end)

-- Function to execute the dupe
local function executeDupe()
    if not _G.ItemToDupe then
        print("❌ ERROR: No item detected!")
        print("Please: 1) Start a trade 2) Add a car 3) Wait for 'Auto-detected item' message")
        return
    end
    
    print("🚀 Starting dupe sequence for item:", _G.ItemToDupe)
    dupeAttempts = dupeAttempts + 1
    
    -- STEP 1: Make sure item is in trade
    print("Step 1: Verifying item in trade...")
    pcall(function()
        SessionAddItem:InvokeServer(_G.ItemToDupe)
    end)
    
    wait(0.5)
    
    -- STEP 2: Rapid accept/cancel
    print("Step 2: Rapid accept/cancel (10 attempts)...")
    for i = 1, 10 do
        -- Accept
        spawn(function()
            pcall(function()
                SessionSetConfirmation:InvokeServer(true)
                print("  ✓ Accept sent #" .. i)
            end)
        end)
        
        -- Cancel (with tiny delay)
        spawn(function()
            wait(0.02)
            pcall(function()
                SessionSetConfirmation:InvokeServer(false)
                print("  ✗ Cancel sent #" .. i)
            end)
        end)
        
        wait(0.08) -- Wait between cycles
    end
    
    -- STEP 3: Try to remove during confusion
    print("Step 3: Attempting to remove item...")
    for i = 1, 3 do
        pcall(function()
            SessionRemoveItem:InvokeServer(_G.ItemToDupe)
            print("  ↻ Remove attempt #" .. i)
        end)
        wait(0.2)
    end
    
    -- STEP 4: Cancel trade
    print("Step 4: Cancelling trade...")
    pcall(function()
        SessionCancel:InvokeServer()
        print("  ⛔ Trade cancelled")
    end)
    
    print("\n✅ Dupe sequence #" .. dupeAttempts .. " complete!")
    print("📋 Check your inventory AND the other player's inventory!")
    print("🔄 Try again if it didn't work!")
end

-- Function to manually set item (for debugging)
local function manualSetItem()
    print("Manual mode: Please enter item ID (check output when you add car):")
    -- This would normally be a textbox, but for simplicity:
    _G.ItemToDupe = "CAR_ITEM_ID_HERE" -- You need to replace this
    print("Manually set item to:", _G.ItemToDupe)
end

-- Create control GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "TRADE DUPLICATOR"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Text = "Status: Waiting for item..."
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0.2, 0)
statusLabel.TextColor3 = Color3.new(1, 1, 0)
statusLabel.Parent = frame

-- Update status function
local function updateStatus()
    if _G.ItemToDupe then
        statusLabel.Text = "✅ Item ready: " .. tostring(_G.ItemToDupe)
        statusLabel.TextColor3 = Color3.new(0, 1, 0)
    else
        statusLabel.Text = "❌ No item detected"
        statusLabel.TextColor3 = Color3.new(1, 0, 0)
    end
end

-- Auto-detect is now automatic, no button needed

-- Execute dupe button
local dupeBtn = Instance.new("TextButton")
dupeBtn.Text = "🚀 EXECUTE DUPE"
dupeBtn.Size = UDim2.new(0.9, 0, 0, 40)
dupeBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
dupeBtn.TextColor3 = Color3.new(1, 1, 1)
dupeBtn.Font = Enum.Font.SourceSansBold
dupeBtn.Parent = frame
dupeBtn.MouseButton1Click:Connect(function()
    updateStatus()
    executeDupe()
end)

-- Manual mode button (for debugging)
local manualBtn = Instance.new("TextButton")
manualBtn.Text = "🔧 Debug: Print Item ID"
manualBtn.Size = UDim2.new(0.9, 0, 0, 30)
manualBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
manualBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
manualBtn.Parent = frame
manualBtn.MouseButton1Click:Connect(function()
    -- Listen for next item update and print details
    local connection
    connection = OnSessionItemsUpdated.OnClientEvent:Connect(function(itemsData)
        print("\n=== DEBUG INFO ===")
        print("Full itemsData:", itemsData)
        if itemsData then
            for playerId, items in pairs(itemsData) do
                print("Player " .. playerId .. " has " .. #items .. " items:")
                for i, item in ipairs(items) do
                    print("  Item " .. i .. ": " .. tostring(item))
                    print("  Type: " .. typeof(item))
                end
            end
        end
        print("=================\n")
        connection:Disconnect()
    end)
    print("Debug mode: Add a car to trade and check output!")
end)

-- Instructions label
local instructions = Instance.new("TextLabel")
instructions.Text = "HOW TO USE:\n1. Start trade\n2. Add car\n3. Click DUPE"
instructions.Size = UDim2.new(1, 0, 0, 40)
instructions.Position = UDim2.new(0, 0, 0.85, 0)
instructions.TextColor3 = Color3.new(1, 1, 1)
instructions.TextYAlignment = Enum.TextYAlignment.Top
instructions.Parent = frame

-- Auto-update status
game:GetService("RunService").RenderStepped:Connect(updateStatus)

print("\n" .. string.rep("=", 50))
print("TRADE DUPE SCRIPT LOADED!")
print("1. Start a trade with someone")
print("2. Add a car to the trade")
print("3. Wait for 'Auto-detected item' message")
print("4. Click 'EXECUTE DUPE' button")
print("5. Check if car duplicated!")
print(string.rep("=", 50))
