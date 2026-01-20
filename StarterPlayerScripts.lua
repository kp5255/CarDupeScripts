-- 🚀 SIMPLE DIRECT TRADE BOT
print("🚀 SIMPLE DIRECT TRADE BOT")
print("=" .. string.rep("=", 50))

-- NO HOOKS, NO METATABLES, JUST DIRECT CALLS

-- Step 1: Find the trading folder
local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes
print("📁 Trading Folder: " .. tradingFolder:GetFullName())

-- Step 2: List all remotes
print("\n📋 Available Remotes:")
for _, remote in pairs(tradingFolder:GetChildren()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        print("  • " .. remote.Name .. " (" .. remote.ClassName .. ")")
    end
end

-- Step 3: Try the most likely remote names
local targetCar = "AstonMartin12"
print("\n🎯 Trying to add: " .. targetCar)

-- Common remote names for adding items
local remoteNames = {
    "AddToTrade",
    "AddItem", 
    "AddVehicle",
    "AddCar",
    "TradeAdd",
    "AddToTrading"
}

-- Try each remote name
for _, remoteName in pairs(remoteNames) do
    local remote = tradingFolder:FindFirstChild(remoteName)
    if remote then
        print("\n✅ Found remote: " .. remoteName)
        
        -- Try different data formats
        local testData = {
            targetCar,  -- Just the string
            {ItemId = targetCar},
            {ID = targetCar},
            {Car = targetCar},
            {Vehicle = targetCar},
            {Name = "Aston Martin"}
        }
        
        for i, data in pairs(testData) do
            print("  Testing format " .. i .. "...")
            
            if remote:IsA("RemoteFunction") then
                -- Try RemoteFunction
                local success, result = pcall(function()
                    return remote:InvokeServer(data)
                end)
                
                if success then
                    print("    ✅ Success! Result: " .. tostring(result))
                else
                    print("    ❌ Failed: " .. tostring(result))
                end
            else
                -- Try RemoteEvent with all possible methods
                local methods = {"FireServer", "Fire"}
                for _, method in pairs(methods) do
                    local success, result = pcall(function()
                        local func = remote[method]
                        if type(func) == "function" then
                            return func(remote, data)
                        end
                        return nil, "Method not found"
                    end)
                    
                    if success then
                        print("    ✅ Success with " .. method .. "!")
                    elseif result ~= "Method not found" then
                        print("    ❌ Failed with " .. method .. ": " .. tostring(result))
                    end
                end
            end
            
            task.wait(0.3)
        end
    end
end

-- Step 4: If no named remotes found, try ALL remotes in the folder
print("\n🔄 Trying ALL remotes in folder...")
for _, remote in pairs(tradingFolder:GetChildren()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        print("\n🔍 Testing: " .. remote.Name)
        
        if remote:IsA("RemoteFunction") then
            local success, result = pcall(function()
                return remote:InvokeServer(targetCar)
            end)
            
            if success then
                print("  ✅ Success! Result: " .. tostring(result))
            else
                print("  ❌ Failed: " .. tostring(result))
            end
        else
            -- Try both FireServer and Fire
            local methods = {"FireServer", "Fire"}
            for _, method in pairs(methods) do
                local success, result = pcall(function()
                    local func = remote[method]
                    if type(func) == "function" then
                        return func(remote, targetCar)
                    end
                    return nil, "Method not found"
                end)
                
                if success then
                    print("  ✅ Success with " .. method .. "!")
                end
            end
        end
        
        task.wait(0.3)
    end
end

-- Step 5: Create simple functions for repeated use
print("\n" .. string.rep("🛠️", 30))
print("CREATING SIMPLE FUNCTIONS...")
print(string.rep("🛠️", 30))

local function findBestRemote()
    -- First try common names
    for _, name in pairs(remoteNames) do
        local remote = tradingFolder:FindFirstChild(name)
        if remote then return remote end
    end
    
    -- Then try any remote
    for _, remote in pairs(tradingFolder:GetChildren()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            return remote
        end
    end
    
    return nil
end

local bestRemote = findBestRemote()

if bestRemote then
    print("✅ Best remote found: " .. bestRemote.Name)
    
    -- Create add function
    local function addCar(amount)
        amount = amount or 1
        print("➕ Adding " .. amount .. " cars...")
        
        local added = 0
        for i = 1, amount do
            print("  [" .. i .. "/" .. amount .. "]")
            
            if bestRemote:IsA("RemoteFunction") then
                local success, result = pcall(function()
                    return bestRemote:InvokeServer(targetCar)
                end)
                
                if success then
                    added = added + 1
                    print("    ✅ Added!")
                else
                    print("    ❌ Failed: " .. tostring(result))
                end
            else
                -- Try FireServer first, then Fire
                local success1, result1 = pcall(function()
                    bestRemote:FireServer(targetCar)
                end)
                
                if success1 then
                    added = added + 1
                    print("    ✅ Added with FireServer!")
                else
                    local success2, result2 = pcall(function()
                        bestRemote:Fire(targetCar)
                    end)
                    
                    if success2 then
                        added = added + 1
                        print("    ✅ Added with Fire!")
                    else
                        print("    ❌ Both methods failed")
                    end
                end
            end
            
            task.wait(0.4)
        end
        
        print("\n🎯 Added " .. added .. "/" .. amount .. " cars")
        return added
    end
    
    -- Make functions available
    getgenv().SimpleTrade = {
        add1 = function() addCar(1) end,
        add5 = function() addCar(5) end,
        add10 = function() addCar(10) end,
        add = function(count) addCar(count) end,
        test = function() 
            print("Testing connection to " .. bestRemote.Name)
            addCar(1)
        end
    }
    
    print("\n" .. string.rep("🎮", 30))
    print("CONTROLS AVAILABLE:")
    print(string.rep("🎮", 30))
    print("SimpleTrade.add1()  - Add 1 car")
    print("SimpleTrade.add5()  - Add 5 cars")
    print("SimpleTrade.add10() - Add 10 cars")
    print("SimpleTrade.add(20) - Add custom amount")
    print("SimpleTrade.test()  - Test connection")
    print(string.rep("🎮", 30))
    
    -- Auto-test
    task.wait(1)
    print("\n🧪 Running test...")
    SimpleTrade.add1()
    
else
    print("❌ No suitable remote found")
    
    -- Alternative approach: Button clicker
    print("\n🔄 Trying button clicker method...")
    
    local buttonCode = [[
        -- SIMPLE BUTTON CLICKER
        function clickCarButtons()
            local Player = game:GetService("Players").LocalPlayer
            local PlayerGui = Player:WaitForChild("PlayerGui")
            local clicked = 0
            
            for _, gui in pairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    for _, button in pairs(gui:GetDescendants()) do
                        if button:IsA("TextButton") or button:IsA("ImageButton") then
                            local name = button.Name:lower()
                            if name:find("car") or name:find("add") or name:find("trade") then
                                for i = 1, 3 do
                                    pcall(function()
                                        button:Fire("Activated")
                                        print("Clicked: " .. button.Name)
                                        clicked = clicked + 1
                                    end)
                                    wait(0.2)
                                end
                            end
                        end
                    end
                end
            end
            
            print("✅ Clicked " .. clicked .. " times")
            return clicked
        end
        
        clickCarButtons()
    ]]
    
    print("🚀 Running button clicker...")
    pcall(loadstring, buttonCode)
end

print("\n" .. string.rep("=", 50))
print("✅ SCRIPT COMPLETE - NO HOOKS USED")
print(string.rep("=", 50))

-- Final summary
if bestRemote then
    print("\n📊 SUMMARY:")
    print("Remote: " .. bestRemote.Name)
    print("Type: " .. bestRemote.ClassName)
    print("Car: " .. targetCar)
    print("\nUse SimpleTrade.add5() to add more cars!")
else
    print("\n⚠️ Could not find trading remote")
    print("Try clicking the car manually and see what happens")
end
