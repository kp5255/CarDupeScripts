-- Car Duplication Script
-- Using exact remote names from your game

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Get trading remotes
local TradingRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")

print("=== TRADE DUPLICATION SCRIPT ===")
print("Ready for car duplication!")

-- IMPORTANT REMOTES:
-- SessionAddItem (RemoteFunction) - Add item to trade
-- SessionRemoveItem (RemoteFunction) - Remove item from trade
-- SessionSetConfirmation (RemoteFunction) - Accept/cancel trade
-- SessionCancel (RemoteFunction) - Cancel entire trade
-- OnSessionItemsUpdated (RemoteEvent) - When items change
-- OnSessionConfirmationUpdated (RemoteEvent) - When confirmations change

-- Get the key remotes
local SessionAddItem = TradingRemotes:WaitForChild("SessionAddItem")
local SessionRemoveItem = TradingRemotes:WaitForChild("SessionRemoveItem")
local SessionSetConfirmation = TradingRemotes:WaitForChild("SessionSetConfirmation")
local SessionCancel = TradingRemotes:WaitForChild("SessionCancel")
local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")

if not SessionAddItem or not SessionSetConfirmation then
    warn("Critical remotes not found!")
    return
end

-- Track trade state
local tradeSessionId = nil
local myItemsInTrade = {}
local otherPlayerId = nil
local isTradeConfirmed = false

-- Listen for trade updates
OnSessionItemsUpdated.OnClientEvent:Connect(function(itemsData)
    print("[TRADE] Items updated")
    if itemsData then
        for playerId, items in pairs(itemsData) do
            if playerId == LocalPlayer.UserId then
                myItemsInTrade = items
                print("Your items in trade:", #items)
            else
                otherPlayerId = playerId
            end
        end
    end
end)

-- Method 1: Classic Trade Dupe
local function classicTradeDupe()
    if #myItemsInTrade == 0 then
        warn("[DUPE] No items in trade!")
        return
    end
    
    print("[DUPE] Starting classic dupe...")
    
    -- Add a small delay and spam accept
    spawn(function()
        for i = 1, 5 do
            pcall(function()
                SessionSetConfirmation:InvokeServer(true) -- Accept
            end)
            wait(0.05)
        end
    end)
    
    -- Try to cancel simultaneously
    spawn(function()
        wait(0.03)
        pcall(function()
            SessionSetConfirmation:InvokeServer(false) -- Cancel
        end)
    end)
    
    print("[DUPE] Classic dupe attempt complete!")
end

-- Method 2: Add/Remove Rapid Dupe
local function addRemoveDupe()
    print("[DUPE] Starting Add/Remove dupe...")
    
    -- Get first item from trade (assuming you already added a car)
    if #myItemsInTrade == 0 then
        warn("Add a car to trade first!")
        return
    end
    
    local itemId = myItemsInTrade[1]
    
    -- Rapidly add and remove item while accepting
    spawn(function()
        for i = 1, 10 do
            pcall(function()
                -- Add item
                SessionAddItem:InvokeServer(itemId)
                wait(0.01)
                -- Remove item
                SessionRemoveItem:InvokeServer(itemId)
                wait(0.01)
                -- Accept trade
                SessionSetConfirmation:InvokeServer(true)
            end)
            wait(0.05)
        end
    end)
    
    print("[DUPE] Add/Remove dupe attempt complete!")
end

-- Method 3: Timing Exploit Dupe (Best for 2 accounts)
local function timingExploitDupe()
    print("[DUPE] Starting timing exploit...")
    
    -- This works best with 2 accounts you control
    -- Both accounts need to accept at EXACTLY the same time
    
    local acceptCount = 0
    local function spamAccept()
        while acceptCount < 50 do
            pcall(function()
                SessionSetConfirmation:InvokeServer(true)
                acceptCount = acceptCount + 1
            end)
            wait(0.01)
        end
    end
    
    -- Start spamming accept on both sides (you need 2 accounts)
    spawn(spamAccept)
    
    -- Also try to cancel while spamming accept
    spawn(function()
        wait(0.5)
        pcall(function()
            SessionCancel:InvokeServer()
        end)
    end)
    
    print("[DUPE] Timing exploit running! Use alt account to spam accept too.")
end

-- Method 4: Fake Confirmation Dupe
local function fakeConfirmationDupe()
    print("[DUPE] Starting fake confirmation dupe...")
    
    -- Step 1: Send fake confirmation update to yourself
    local OnSessionConfirmationUpdated = TradingRemotes:WaitForChild("OnSessionConfirmationUpdated")
    if OnSessionConfirmationUpdated then
        -- Try to trigger client-side that trade was accepted
        spawn(function()
            for i = 1, 3 do
                -- Fake that other player accepted
                OnSessionConfirmationUpdated:Fire({[otherPlayerId] = true})
                wait(0.1)
            end
        end)
    end
    
    -- Step 2: Accept trade normally
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    -- Step 3: Immediately try to remove item
    wait(0.1)
    if #myItemsInTrade > 0 then
        pcall(function()
            SessionRemoveItem:InvokeServer(myItemsInTrade[1])
        end)
    end
    
    print("[DUPE] Fake confirmation dupe complete!")
end

-- Create GUI for easy access
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 250)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "Trade Duplicator v2.0"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

-- Buttons for each method
local methods = {
    {"Classic Trade Dupe", classicTradeDupe},
    {"Add/Remove Rapid Dupe", addRemoveDupe},
    {"Timing Exploit (2 accounts)", timingExploitDupe},
    {"Fake Confirmation Dupe", fakeConfirmationDupe}
}

for i, method in ipairs(methods) do
    local button = Instance.new("TextButton")
    button.Text = method[1]
    button.Size = UDim2.new(0.9, 0, 0, 40)
    button.Position = UDim2.new(0.05, 0, 0.2 + (i * 0.18), 0)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Parent = Frame
    
    button.MouseButton1Click:Connect(method[2])
end

-- Status label
local Status = Instance.new("TextLabel")
Status.Text = "Status: Ready - Add car to trade first"
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0.9, 0)
Status.TextColor3 = Color3.new(0, 1, 0)
Status.Parent = Frame

print("GUI Created! Use buttons to try different dupe methods.")

-- INSTRUCTIONS
print("\n=== HOW TO DUPE ===")
print("1. Start a trade with someone")
print("2. Add your car to the trade")
print("3. Click a dupe method button")
print("4. Try different methods if one doesn't work")
print("\nTIP: Use an alt account for best results!")
print("TIP: Try methods multiple times!")
