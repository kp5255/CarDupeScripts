-- 🏢 IMPROVED CAR DEALERSHIP TYCOON SCRIPT
-- Game ID: ffad7ea30d080c4aa1d7bf4b2f5f4381

print("==========================================")
print("CAR DEALERSHIP TYCOON - FIXED VERSION")
print("==========================================")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
print("Game loaded: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)

-- ===== FIXED FUNCTIONS =====

-- FIX 1: Track REAL changes, not just successful pcall()
local function getFreeMoney()
    print("\n💰 Getting FREE MONEY...")
    
    -- Store ORIGINAL money BEFORE trying anything
    local originalMoney = 0
    local moneyStatName = nil
    
    if player:FindFirstChild("leaderstats") then
        for _, stat in pairs(player.leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                local nameLower = stat.Name:lower()
                if nameLower:find("money") or nameLower:find("cash") or nameLower:find("dollar") then
                    originalMoney = stat.Value
                    moneyStatName = stat.Name
                    print("Found money stat: " .. stat.Name .. " = $" .. originalMoney)
                end
            end
        end
    end
    
    -- Now try the events
    local moneyAmounts = {999999, 1000000 }
    local events = {"AddMoney", "SetMoney", "GiveMoney", "Money", "Cash"}
    
    for _, eventName in pairs(events) do
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if event then
            print("Trying event: " .. eventName .. " (" .. event.ClassName .. ")")
            
            for _, amount in pairs(moneyAmounts) do
                local attempts = {
                    {amount},
                    {player, amount},
                    {player.UserId, amount}
                }
                
                for _, args in pairs(attempts) do
                    local success, errorMsg = pcall(function()
                        if event:IsA("RemoteEvent") then
                            event:FireServer(unpack(args))
                        else
                            event:InvokeServer(unpack(args))
                        end
                    end)
                    
                    if success then
                        print("✅ Event fired: " .. eventName .. " with $" .. amount)
                        -- WAIT and CHECK if money actually changed
                        task.wait(0.5)
                        if moneyStatName then
                            local newMoney = player.leaderstats[moneyStatName].Value
                            if newMoney ~= originalMoney then
                                print("🎉 REAL CHANGE! Money: $" .. originalMoney .. " → $" .. newMoney)
                                return true
                            end
                        end
                    else
                        print("❌ Event failed: " .. errorMsg)
                    end
                end
            end
        end
    end
    
    -- FIX 2: If direct events don't work, try to find money-related modules
    print("\n🔍 Searching for money modules...")
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") and obj.Name:lower():find("money") then
            print("Found money module: " .. obj.Name)
            -- Try to require and call it
            local success, module = pcall(function() return require(obj) end)
            if success then
                if type(module) == "table" then
                    for funcName, func in pairs(module) do
                        if type(func) == "function" and (funcName:lower():find("add") or funcName:lower():find("set")) then
                            local success2 = pcall(function()
                                func(9999999)
                            end)
                            if success2 then
                                print("✅ Called money function: " .. funcName)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Final check
    if moneyStatName then
        local finalMoney = player.leaderstats[moneyStatName].Value
        if finalMoney > originalMoney then
            print("🎉 SUCCESS! Money increased by: $" .. (finalMoney - originalMoney))
            return true
        end
    end
    
    print("❌ No money changes detected")
    return false
end

-- FIX 3: Better car detection and duplication
local function duplicateDealershipCars()
    print("\n🚗 Duplicating dealership cars...")
    
    -- FIRST: Check if player actually owns any cars
    local ownedCars = {}
    
    -- Check player data folder
    if player:FindFirstChild("Data") then
        for _, data in pairs(player.Data:GetChildren()) do
            if data.Name:find("Car") or data.Name:find("Vehicle") then
                table.insert(ownedCars, data.Name)
                print("Found owned car: " .. data.Name)
            end
        end
    end
    
    -- Check inventory
    if player:FindFirstChild("Inventory") then
        for _, item in pairs(player.Inventory:GetChildren()) do
            if item.Name:find("Car") or item.Name:find("Vehicle") then
                table.insert(ownedCars, item.Name)
                print("Found inventory car: " .. item.Name)
            end
        end
    end
    
    if #ownedCars == 0 then
        print("⚠️ No owned cars found! Buy a car first!")
        return false
    end
    
    -- Now try to duplicate owned cars
    local events = {"BuyCar", "PurchaseCar", "AddCar", "UnlockCar"}
    local successCount = 0
    
    for _, carName in pairs(ownedCars) do
        print("\nTrying to duplicate: " .. carName)
        
        for _, eventName in pairs(events) do
            local event = ReplicatedStorage:FindFirstChild(eventName)
            if event then
                -- Try different purchase formats
                local attempts = {
                    {carName},
                    {player, carName},
                    {carName, 0},
                    {"free", carName}
                }
                
                for _, args in pairs(attempts) do
                    local success, errorMsg = pcall(function()
                        if event:IsA("RemoteEvent") then
                            event:FireServer(unpack(args))
                        else
                            event:InvokeServer(unpack(args))
                        end
                    end)
                    
                    if success then
                        print("✅ Event fired: " .. eventName)
                        successCount = successCount + 1
                        -- Wait a bit to avoid rate limiting
                        task.wait(0.2)
                    else
                        if errorMsg:find("rate") or errorMsg:find("spam") then
                            print("⚠️ Rate limited, waiting...")
                            task.wait(1)
                        end
                    end
                end
            end
        end
    end
    
    -- Check if any new cars were added
    if player:FindFirstChild("Data") then
        task.wait(1)
        local newCarCount = 0
        for _, data in pairs(player.Data:GetChildren()) do
            if data.Name:find("Car") or data.Name:find("Vehicle") then
                if not table.find(ownedCars, data.Name) then
                    newCarCount = newCarCount + 1
                end
            end
        end
        
        if newCarCount > 0 then
            print("🎉 ADDED " .. newCarCount .. " NEW CARS!")
            return true
        end
    end
    
    print("Duplicated " .. successCount .. " times (check inventory)")
    return successCount > 0
end

-- FIX 4: Unlock with better detection
local function unlockEverything()
    print("\n🔓 Unlocking all dealership features...")
    
    local events = {"UpgradeDealership", "UnlockDealership", "BuyDealership"}
    local anySuccess = false
    
    -- First check current dealership level
    local currentLevel = 1
    if player:FindFirstChild("DealershipLevel") then
        currentLevel = player.DealershipLevel.Value
        print("Current dealership level: " .. currentLevel)
    end
    
    for _, eventName in pairs(events) do
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if event then
            print("Trying event: " .. eventName)
            
            -- Try to unlock max levels
            for level = 1, 10 do
                local success, errorMsg = pcall(function()
                    if event:IsA("RemoteEvent") then
                        event:FireServer(level)
                    else
                        event:InvokeServer(level)
                    end
                end)
                
                if success then
                    print("✅ Sent level " .. level .. " to " .. eventName)
                    anySuccess = true
                    task.wait(0.1)
                else
                    if not errorMsg:find("Not connected") then
                        print("❌ Failed: " .. errorMsg)
                    end
                end
            end
        end
    end
    
    -- Check if level changed
    task.wait(1)
    if player:FindFirstChild("DealershipLevel") then
        local newLevel = player.DealershipLevel.Value
        if newLevel > currentLevel then
            print("🎉 Dealership level increased: " .. currentLevel .. " → " .. newLevel)
            return true
        end
    end
    
    return anySuccess
end

-- MAIN EXECUTION
task.wait(2)
print("\n🚀 STARTING EXECUTION...")

-- Run in sequence
local moneySuccess = getFreeMoney()

if moneySuccess then
    print("\n💰 MONEY SUCCESSFUL! Proceeding to car duplication...")
    task.wait(2)
    duplicateDealershipCars()
else
    print("\n⚠️ Money failed, trying cars anyway...")
    task.wait(1)
    duplicateDealershipCars()
end

task.wait(2)
unlockEverything()

print("\n" .. string.rep("=", 50))
print("✅ SCRIPT COMPLETED!")
print(string.rep("=", 50))
