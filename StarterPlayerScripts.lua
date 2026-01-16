-- REAL TRADE EXPLOIT BASED ON DECOMPILED SCRIPT
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TradingServiceRemotes = require(ReplicatedStorage.Remotes.Services.TradingServiceRemotes)

print("🎯 REAL TRADE EXPLOIT FROM DECOMPILED CODE")
print("Found trading system structure!")

-- From decompiled code analysis:
-- SessionUpdateTokens:InvokeServer(tokens) - Updates token offer
-- SessionAddItem:InvokeServer(item) - Adds item to trade
-- SessionRemoveItem:InvokeServer(item) - Removes item from trade
-- SessionSetConfirmation:InvokeServer(bool) - Accept/cancel trade
-- SessionCancel:InvokeServer() - Cancels entire trade

-- KEY DISCOVERY: Items have structure:
-- Car item: {Type = "Car", Name = "Subaru3", Id = "uuid"}
-- Customization item: {Type = "Customization", Category = "Category", Name = "ItemName"}

-- EXPLOIT 1: ITEM INJECTION
local function injectFakeItem()
    print("\n💉 INJECTING FAKE ITEM INTO TRADE...")
    
    -- Create a fake car item
    local fakeCar = {
        Type = "Car",
        Name = "Subaru3",
        Id = "FAKE_CAR_" .. math.random(10000, 99999)
    }
    
    print("Fake car created:", fakeCar)
    
    -- Try to add it to trade
    local success, result = pcall(function()
        return TradingServiceRemotes.SessionAddItem:InvokeServer(fakeCar)
    end)
    
    if success then
        print("✅ Fake car injected!")
        print("Result:", result)
    else
        print("❌ Failed:", result)
    end
end

-- EXPLOIT 2: TOKEN MANIPULATION
local function manipulateTokens()
    print("\n💰 MANIPULATING TRADE TOKENS...")
    
    -- Try different token amounts
    local tokenAmounts = {
        999999,
        1000000,
        5000000,
        -1,  -- Negative (might cause bug)
        0,
        1
    }
    
    for _, amount in pairs(tokenAmounts) do
        pcall(function()
            TradingServiceRemotes.SessionUpdateTokens:InvokeServer(amount)
            print("Set tokens to:", amount)
        end)
        wait(0.1)
    end
end

-- EXPLOIT 3: SESSION HIJACK
local function hijackSession()
    print("\n🎭 HIJACKING TRADE SESSION...")
    
    -- Try to create fake session data
    local fakeSession = {
        Id = "HACKED_SESSION_" .. math.random(10000, 99999),
        OtherPlayer = {
            Name = "HACKED_PLAYER",
            UserId = 999999
        }
    }
    
    -- Try to trigger OnSessionStarted manually
    pcall(function()
        -- This might trigger the UI to think we're in a trade
        TradingServiceRemotes.OnSessionStarted:Fire(fakeSession)
        print("✅ Fake session started!")
    end)
end

-- EXPLOIT 4: PACKET REPLAY WITH MODIFIED DATA
local function packetReplayExploit()
    print("\n📡 PACKET REPLAY EXPLOIT")
    
    -- Store original functions
    local originalUpdateTokens = TradingServiceRemotes.SessionUpdateTokens.InvokeServer
    local originalAddItem = TradingServiceRemotes.SessionAddItem.InvokeServer
    local originalSetConfirmation = TradingServiceRemotes.SessionSetConfirmation.InvokeServer
    
    -- Hook the functions
    TradingServiceRemotes.SessionUpdateTokens.InvokeServer = function(...)
        local args = {...}
        print("[HOOK] SessionUpdateTokens called with:", args[1])
        
        -- Modify token amount
        if type(args[1]) == "number" then
            local modifiedAmount = args[1] * 10  -- 10x the tokens!
            print("[HOOK] Modifying tokens from", args[1], "to", modifiedAmount)
            return originalUpdateTokens(TradingServiceRemotes.SessionUpdateTokens, modifiedAmount)
        end
        
        return originalUpdateTokens(TradingServiceRemotes.SessionUpdateTokens, ...)
    end
    
    TradingServiceRemotes.SessionAddItem.InvokeServer = function(...)
        local args = {...}
        print("[HOOK] SessionAddItem called with item:", args[1])
        
        -- Duplicate the item
        spawn(function()
            wait(0.01)
            print("[HOOK] Sending duplicate item...")
            pcall(function()
                originalAddItem(TradingServiceRemotes.SessionAddItem, args[1])
            end)
        end)
        
        return originalAddItem(TradingServiceRemotes.SessionAddItem, ...)
    end
    
    print("✅ Packet hooks installed!")
    print("Now when you trade, tokens will be 10x and items will duplicate!")
end

-- EXPLOIT 5: DIRECT UI MANIPULATION
local function manipulateTradeUI()
    print("\n🎨 MANIPULATING TRADE UI...")
    
    -- Find the trading UI component
    local tradingUI = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:GetAttribute("Tag") == "UI_Menus_Trading_PeerToPeer" then
            tradingUI = obj
            print("Found trading UI:", obj:GetFullName())
            break
        end
    end
    
    if tradingUI then
        -- Try to modify UI values
        for _, descendant in pairs(tradingUI:GetDescendants()) do
            if descendant:IsA("TextLabel") then
                -- Look for token display
                if descendant.Text and descendant.Text:find("Tokens") then
                    print("Found token display:", descendant:GetFullName())
                    descendant.Text = "Tokens: 999,999"
                end
                
                -- Look for item counts
                if descendant.Name:find("Item") or descendant.Text:find("Item") then
                    descendant.Text = "Items: 10"
                end
            end
            
            -- Look for buttons and make them do different things
            if descendant:IsA("TextButton") then
                local originalClick = descendant.MouseButton1Click
                descendant.MouseButton1Click = function()
                    print("[UI HOOK] Button clicked:", descendant.Name)
                    -- Call original
                    if originalClick then
                        originalClick()
                    end
                    -- Add our exploit
                    injectFakeItem()
                end
            end
        end
    else
        print("❌ Trading UI not found")
    end
end

-- EXPLOIT 6: TRADE COMPLETION HIJACK
local function tradeCompletionHijack()
    print("\n✅ TRADE COMPLETION HIJACK")
    
    -- Listen for trade completion
    TradingServiceRemotes.OnSessionFinished.OnClientEvent:Connect(function(result)
        print("[COMPLETION HOOK] Trade finished!")
        print("Result:", result)
        
        -- Try to add items after trade completes
        spawn(function()
            wait(0.5)
            print("[COMPLETION HOOK] Adding bonus items...")
            injectFakeItem()
        end)
    end)
    
    -- Also listen for cancellations
    TradingServiceRemotes.OnSessionCancelled.OnClientEvent:Connect(function(reason)
        print("[CANCELLATION HOOK] Trade cancelled:", reason)
        
        -- Try to keep items anyway
        spawn(function()
            wait(0.5)
            print("[CANCELLATION HOOK] Attempting to keep items...")
        end)
    end)
    
    print("✅ Trade completion hooks installed!")
end

-- CREATE EXPLOIT CONTROL PANEL
local exploitGUI = Instance.new("ScreenGui")
exploitGUI.Name = "TradeExploitPanel"
exploitGUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 350)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.new(0, 1, 0)
mainFrame.Parent = exploitGUI

local title = Instance.new("TextLabel")
title.Text = "🎯 TRADE EXPLOITS"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Exploit buttons
local exploits = {
    {"💉 Inject Fake Item", injectFakeItem},
    {"💰 Manipulate Tokens", manipulateTokens},
    {"🎭 Hijack Session", hijackSession},
    {"📡 Packet Replay", packetReplayExploit},
    {"🎨 Manipulate UI", manipulateTradeUI},
    {"✅ Completion Hijack", tradeCompletionHijack}
}

for i, exploit in ipairs(exploits) do
    local btn = Instance.new("TextButton")
    btn.Text = exploit[1]
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0.1 + (i * 0.14), 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(exploit[2])
end

print("\n" .. string.rep("=", 60))
print("🎯 REAL TRADE EXPLOITS FROM DECOMPILED CODE")
print(string.rep("=", 60))
print("ANALYSIS OF DECOMPILED TRADING SCRIPT:")
print("1. Items have structure: {Type, Name, Id}")
print("2. Cars: Type='Car', Name='CarName', Id='uuid'")
print("3. Customizations: Type='Customization', Category, Name")
print("4. SessionUpdateTokens: Updates token amount")
print("5. SessionAddItem/RemoveItem: Add/remove items")
print("6. SessionSetConfirmation: Accept/cancel trade")
print(string.rep("=", 60))
print("EXPLOIT METHODS:")
print("1. Inject Fake Item - Add non-existent items")
print("2. Manipulate Tokens - Change token amounts")
print("3. Hijack Session - Create fake trade sessions")
print("4. Packet Replay - Modify packets in transit")
print("5. Manipulate UI - Change displayed values")
print("6. Completion Hijack - Intercept trade completion")
print(string.rep("=", 60))

-- Make functions global
_G.inject = injectFakeItem
_G.tokens = manipulateTokens
_G.hijack = hijackSession
_G.packet = packetReplayExploit
_G.ui = manipulateTradeUI
_G.complete = tradeCompletionHijack

-- DIRECT ACCESS TO TRADING FUNCTIONS
_G.addCar = function(carName)
    local carItem = {
        Type = "Car",
        Name = carName,
        Id = "EXPLOIT_" .. carName .. "_" .. math.random(10000, 99999)
    }
    
    pcall(function()
        TradingServiceRemotes.SessionAddItem:InvokeServer(carItem)
        print("Added car:", carName)
    end)
end

_G.setTokens = function(amount)
    pcall(function()
        TradingServiceRemotes.SessionUpdateTokens:InvokeServer(amount)
        print("Set tokens to:", amount)
    end)
end

print("\nConsole commands:")
print("_G.inject() - Inject fake item")
print("_G.tokens() - Manipulate tokens")
print("_G.hijack() - Hijack session")
print("_G.addCar('Subaru3') - Add car to trade")
print("_G.setTokens(999999) - Set token amount")
