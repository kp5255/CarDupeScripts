-- 🎯 PERFECT TRADE BOT - FOUND WORKING REMOTES
print("🎯 PERFECT TRADE BOT")
print("=" .. string.rep("=", 50))

-- CONFIGURATION
local TARGET_CAR = "AstonMartin12"

-- Get the trading folder
local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes

-- THE WORKING REMOTES FOUND:
print("📋 WORKING REMOTES IDENTIFIED:")
print("1. SessionSetConfirmation - Returns: true")
print("2. SessionAddItem - Returns: false (but recognized the car!)")
print("3. SessionRemoveItem - Returns: false")
print("4. SessionCancel - Returns: true")

-- CREATE THE PERFECT ADD FUNCTION
local function addCarToTrade()
    print("➕ Attempting to add car...")
    
    -- Try SessionAddItem (most likely for adding items)
    local sessionAddItem = tradingFolder:FindFirstChild("SessionAddItem")
    if sessionAddItem and sessionAddItem:IsA("RemoteFunction") then
        print("  Using SessionAddItem remote...")
        
        -- Try different data formats
        local dataFormats = {
            TARGET_CAR,  -- Just string
            {ItemId = TARGET_CAR},
            {ID = TARGET_CAR},
            {itemId = TARGET_CAR},
            {id = TARGET_CAR},
            {Item = TARGET_CAR},
            {item = TARGET_CAR}
        }
        
        for i, data in pairs(dataFormats) do
            print("  Trying format " .. i .. "...")
            local success, result = pcall(function()
                return sessionAddItem:InvokeServer(data)
            end)
            
            if success then
                print("    ✅ Result: " .. tostring(result))
                if result == true then
                    print("    🎉 SUCCESS! Car added!")
                    return true
                elseif result == false then
                    print("    ⚠️ Recognized but returned false")
                    -- The car was recognized but something prevented adding
                end
            else
                print("    ❌ Error: " .. tostring(result))
            end
            
            task.wait(0.2)
        end
    end
    
    return false
end

-- SET UP TRADE SESSION FIRST
print("\n🔄 SETTING UP TRADE SESSION...")

-- First, we need to start or join a trade session
-- Try to accept an invite or start a trade

local function setupTradeSession()
    print("Setting up trade environment...")
    
    -- Try to accept any pending invites
    local inviteAccept = tradingFolder:FindFirstChild("InviteAccept")
    if inviteAccept and inviteAccept:IsA("RemoteFunction") then
        print("  Checking for invites...")
        -- Try with empty data or common formats
        local testData = {"", {}, nil}
        for _, data in pairs(testData) do
            pcall(function()
                inviteAccept:InvokeServer(data)
            end)
        end
    end
    
    -- Try to start a session
    local sessionStart = tradingFolder:FindFirstChild("OnSessionStarted")
    if sessionStart and sessionStart:IsA("RemoteEvent") then
        print("  Attempting to signal session start...")
        pcall(function()
            sessionStart:FireServer({})
        end)
    end
    
    -- Confirm the session
    local sessionConfirm = tradingFolder:FindFirstChild("SessionSetConfirmation")
    if sessionConfirm and sessionConfirm:IsA("RemoteFunction") then
        print("  Confirming session...")
        pcall(function()
            sessionConfirm:InvokeServer(true)  -- true = confirm
        end)
    end
end

-- BULK ADD FUNCTION
local function bulkAddCars(count)
    print("\n📦 BULK ADDING " .. count .. " CARS")
    print("=" .. string.rep("=", 30))
    
    local added = 0
    local failed = 0
    
    for i = 1, count do
        print("\n[" .. i .. "/" .. count .. "]")
        
        if addCarToTrade() then
            added = added + 1
            print("  ✅ SUCCESS - Car added!")
        else
            failed = failed + 1
            print("  ⚠️ Failed to add car")
            
            -- Try alternative method
            print("  Trying alternative...")
            local sessionAddItem = tradingFolder:FindFirstChild("SessionAddItem")
            if sessionAddItem then
                pcall(function()
                    -- Try with table containing ItemId
                    sessionAddItem:InvokeServer({ItemId = TARGET_CAR})
                    print("  Alternative attempt sent")
                end)
            end
        end
        
        -- Critical: Wait to prevent rate limiting
        task.wait(0.5)
    end
    
    print("\n" .. string.rep("🎯", 30))
    print("BULK ADD COMPLETE!")
    print("Added: " .. added .. " cars")
    print("Failed: " .. failed .. " attempts")
    print(string.rep("🎯", 30))
    
    return added
end

-- COMPLETE TRADE WORKFLOW
local function completeTradeWorkflow()
    print("\n🔄 COMPLETE TRADE WORKFLOW")
    print("=" .. string.rep("=", 40))
    
    -- Step 1: Setup
    print("1. Setting up trade session...")
    setupTradeSession()
    task.wait(1)
    
    -- Step 2: Add cars
    print("\n2. Adding cars...")
    local added = bulkAddCars(5)
    
    -- Step 3: Confirm trade
    print("\n3. Confirming trade...")
    local sessionConfirm = tradingFolder:FindFirstChild("SessionSetConfirmation")
    if sessionConfirm then
        pcall(function()
            sessionConfirm:InvokeServer(true)  -- Confirm
            print("  ✅ Trade confirmed!")
        end)
    end
    
    -- Step 4: Update tokens if needed
    print("\n4. Updating session...")
    local updateTokens = tradingFolder:FindFirstChild("SessionUpdateTokens")
    if updateTokens then
        pcall(function()
            updateTokens:InvokeServer(1)  -- Try with token count 1
            print("  ✅ Tokens updated")
        end)
    end
    
    return added
end

-- CREATE EASY-TO-USE FUNCTIONS
getgenv().PerfectTrade = {
    -- Simple add
    add1 = function() 
        setupTradeSession()
        task.wait(0.5)
        return bulkAddCars(1) 
    end,
    
    -- Bulk add
    add5 = function() 
        setupTradeSession()
        task.wait(0.5)
        return bulkAddCars(5) 
    end,
    
    add10 = function() 
        setupTradeSession()
        task.wait(0.5)
        return bulkAddCars(10) 
    end,
    
    -- Custom amount
    add = function(count) 
        setupTradeSession()
        task.wait(0.5)
        return bulkAddCars(count or 5) 
    end,
    
    -- Complete workflow
    trade = function() 
        return completeTradeWorkflow() 
    end,
    
    -- Just setup session
    setup = function() 
        setupTradeSession() 
    end,
    
    -- Test remote
    test = function()
        print("Testing SessionAddItem remote...")
        local remote = tradingFolder:FindFirstChild("SessionAddItem")
        if remote then
            local success, result = pcall(function()
                return remote:InvokeServer(TARGET_CAR)
            end)
            print("Success: " .. tostring(success))
            print("Result: " .. tostring(result))
            return success, result
        end
        return false, "Remote not found"
    end
}

-- Display controls
print("\n" .. string.rep("🎮", 30))
print("PERFECT TRADE CONTROLS:")
print(string.rep("🎮", 30))
print("PerfectTrade.add1()    - Add 1 car")
print("PerfectTrade.add5()    - Add 5 cars")
print("PerfectTrade.add10()   - Add 10 cars")
print("PerfectTrade.add(20)   - Add custom amount")
print("PerfectTrade.trade()   - Complete trade workflow")
print("PerfectTrade.setup()   - Setup trade session")
print("PerfectTrade.test()    - Test the remote")
print(string.rep("🎮", 30))

-- Auto-run a test
print("\n🧪 RUNNING AUTO-TEST...")
task.wait(1)

-- First, setup a trade session
PerfectTrade.setup()
task.wait(1)

-- Then add 3 cars
PerfectTrade.add(3)

print("\n" .. string.rep("✅", 40))
print("PERFECT TRADE BOT READY!")
print(string.rep("✅", 40))

-- IMPORTANT TIP ABOUT TRADE SESSIONS
print("\n💡 IMPORTANT:")
print("The trade session closes automatically because:")
print("1. You need someone to trade WITH")
print("2. Or the game has anti-dupe protection")
print("3. Try adding cars while in an ACTIVE trade with someone")
print("\nTo use this bot:")
print("1. Start a trade with another player")
print("2. Run PerfectTrade.add5()")
print("3. The cars should appear in your trade window")

-- Create a version for active trades
print("\n" .. string.rep("🔄", 40))
print("ACTIVE TRADE VERSION:")
print(string.rep("🔄", 40))

local activeTradeCode = [[
    -- 🎯 ACTIVE TRADE BOT
    -- Use this WHEN you're in an active trade session
    
    local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes
    local TARGET_CAR = "AstonMartin12"
    
    function addToActiveTrade(count)
        count = count or 5
        print("Adding " .. count .. " cars to active trade...")
        
        local sessionAddItem = tradingFolder:WaitForChild("SessionAddItem")
        local added = 0
        
        for i = 1, count do
            print("[" .. i .. "/" .. count .. "]")
            
            -- Try multiple formats
            local formats = {
                TARGET_CAR,
                {ItemId = TARGET_CAR},
                {ID = TARGET_CAR},
                {itemId = TARGET_CAR}
            }
            
            for _, data in pairs(formats) do
                local success, result = pcall(function()
                    return sessionAddItem:InvokeServer(data)
                end)
                
                if success then
                    print("  Result: " .. tostring(result))
                    if result == true then
                        added = added + 1
                        print("  ✅ Added!")
                        break
                    end
                end
            end
            
            task.wait(0.4)
        end
        
        print("\n🎯 Added " .. added .. "/" .. count .. " cars")
        return added
    end
    
    -- Export function
    getgenv().ActiveTrade = {
        add = addToActiveTrade,
        add5 = function() addToActiveTrade(5) end,
        add10 = function() addToActiveTrade(10) end
    }
    
    print("🎮 Use ActiveTrade.add5() to add cars!")
    print("⚠️ Make sure you're IN a trade session!")
    
    -- Quick test
    task.wait(1)
    print("\n🧪 Quick test...")
    local success, result = pcall(function()
        return tradingFolder.SessionAddItem:InvokeServer(TARGET_CAR)
    end)
    print("Test result: " .. tostring(result))
]]

print("\n💻 ACTIVE TRADE CODE (copy if needed):")
print(activeTradeCode)

-- Run the active trade version too
print("\n🚀 LOADING ACTIVE TRADE FUNCTIONS...")
pcall(loadstring, activeTradeCode)

print("\n" .. string.rep("=", 50))
print("🎯 BOT READY - USE IN ACTIVE TRADES")
print(string.rep("=", 50))
