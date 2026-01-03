-- 💰 PERSISTENT MONEY HACK
-- Game ID: ffad7ea30d080c4aa1d7bf4b2f5f4381

print("💰 PERSISTENT MONEY EXPLOIT")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()

-- ===== PERSISTENT MONEY SOLUTION =====
local function getPersistentMoney()
    print("\n💰 Starting PERSISTENT money hack...")
    
    -- Find money stat
    local moneyStat = nil
    if player:FindFirstChild("leaderstats") then
        for _, stat in pairs(player.leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                local name = stat.Name:lower()
                if name:find("money") or name:find("cash") or name:find("dollar") then
                    moneyStat = stat
                    print("Money stat found: " .. stat.Name)
                    break
                end
            end
        end
    end
    
    if not moneyStat then
        print("❌ No money stat found!")
        return false
    end
    
    local originalMoney = moneyStat.Value
    print("Original money: $" .. originalMoney)
    
    -- STRATEGY 1: Constant money setting (persistent)
    print("\n[STRATEGY 1] Constant money setting loop...")
    
    local targetMoney = 9999999
    local setLoop = true
    
    -- Create a loop that CONSTANTLY sets money
    task.spawn(function()
        while setLoop do
            pcall(function()
                moneyStat.Value = targetMoney
            end)
            task.wait(0.1) -- Set every 0.1 seconds
        end
    end)
    
    -- Check if money stays
    task.wait(3)
    
    local currentMoney = moneyStat.Value
    if currentMoney >= targetMoney then
        print("✅ MONEY PERSISTS! Current: $" .. currentMoney)
        setLoop = false
        return true
    end
    
    -- STRATEGY 2: Event spam with different amounts
    print("\n[STRATEGY 2] Event spamming...")
    
    local moneyEvents = {"AddMoney", "SetMoney", "GiveMoney", "Money"}
    local successCount = 0
    
    -- Try rapid event spamming
    for _, eventName in pairs(moneyEvents) do
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if event then
            print("Spamming event: " .. eventName)
            
            -- Spam 10 times rapidly
            for i = 1, 10 do
                local amount = math.random(100000, 1000000)
                local success = pcall(function()
                    if event:IsA("RemoteEvent") then
                        event:FireServer(amount)
                    else
                        event:InvokeServer(amount)
                    end
                end)
                
                if success then
                    successCount = successCount + 1
                end
                task.wait(0.05) -- Very fast
            end
        end
    end
    
    task.wait(1)
    currentMoney = moneyStat.Value
    
    if currentMoney > originalMoney then
        print("✅ Money increased to: $" .. currentMoney)
        
        -- STRATEGY 3: Immediately spend money before it can be reverted
        print("\n[STRATEGY 3] Immediate spending...")
        
        -- Try to buy something expensive immediately
        local buyEvents = {"BuyCar", "PurchaseCar", "BuyDealership"}
        
        for _, eventName in pairs(buyEvents) do
            local event = ReplicatedStorage:FindFirstChild(eventName)
            if event then
                -- Try to buy the most expensive car
                pcall(function()
                    if event:IsA("RemoteEvent") then
                        event:FireServer("Lamborghini", currentMoney)
                    else
                        event:InvokeServer("Lamborghini", currentMoney)
                    end
                    print("✅ Attempted to purchase expensive item")
                end)
            end
        end
        
        return true
    end
    
    -- STRATEGY 4: Find and intercept the sync event
    print("\n[STRATEGY 4] Looking for sync events...")
    
    -- Monitor for what changes the money back
    moneyStat:GetPropertyChangedSignal("Value"):Connect(function()
        if moneyStat.Value < targetMoney then
            print("⚠️ Money was reverted! New value: $" .. moneyStat.Value)
            -- Try to set it back immediately
            task.wait(0.05)
            moneyStat.Value = targetMoney
        end
    end)
    
    -- Keep trying
    local attempts = 0
    while attempts < 20 do
        moneyStat.Value = targetMoney
        attempts = attempts + 1
        task.wait(0.2)
        
        if moneyStat.Value >= targetMoney then
            print("✅ Money stabilized at: $" .. moneyStat.Value)
            return true
        end
    end
    
    print("❌ Money keeps being reverted by server")
    setLoop = false
    return false
end

-- MAIN EXECUTION
task.wait(2)
getPersistentMoney()

print("\n" .. string.rep("=", 50))
print("If money disappears after 1-2 seconds,")
print("the server has STRONG validation.")
print("Try buying something IMMEDIATELY when money appears!")
print(string.rep("=", 50))
