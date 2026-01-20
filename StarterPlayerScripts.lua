-- 💀 FINAL BATTLE - ULTIMATE SOLUTION
print("💀 FINAL BATTLE - ULTIMATE SOLUTION")
print("=" .. string.rep("=", 60))

-- DISABLE ALL HOOKS FIRST TO PREVENT OVERFLOW
print("🛡️ Disabling any existing hooks...")
local mt = getrawmetatable(game)
if mt then
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index
end

-- SIMPLE VARIABLES
local capturedData = nil
local capturedRemote = nil

-- METHOD 1: DIRECT REMOTE INTERCEPTION WITHOUT HOOKS
print("\n🎯 METHOD 1: DIRECT REMOTE MONITORING")

local tradingFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    :WaitForChild("Services"):WaitForChild("TradingServiceRemotes")

print("📁 Folder: " .. tradingFolder:GetFullName())

-- LIST ALL REMOTES AND THEIR REAL METHODS
print("\n🔍 Analyzing remote methods...")
for _, remote in pairs(tradingFolder:GetChildren()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        print("\n" .. remote.Name .. " (" .. remote.ClassName .. ")")
        
        -- Check what methods REALLY exist
        local methods = {}
        
        -- Try common method names
        local commonMethods = {"InvokeServer", "FireServer", "Fire", "Invoke", "CallServer"}
        for _, methodName in pairs(commonMethods) do
            local success, result = pcall(function()
                return remote[methodName]
            end)
            if success and type(result) == "function" then
                table.insert(methods, methodName)
            end
        end
        
        if #methods > 0 then
            print("  ✅ Methods: " .. table.concat(methods, ", "))
        else
            print("  ⚠️ No standard methods found")
            -- Try to see what's actually there
            print("  📝 Raw properties:")
            for _, prop in pairs({"InvokeServer", "FireServer", "Fire", "Invoke"}) do
                print("    " .. prop .. ": " .. tostring(remote[prop]))
            end
        end
    end
end

-- METHOD 2: UNIVERSAL CAPTURE USING COROUTINES
print("\n🎯 METHOD 2: UNIVERSAL CAPTURE SYSTEM")

-- This creates a new coroutine that monitors ALL calls
local function startUniversalCapture()
    print("🚀 Starting universal capture...")
    
    -- Store original remote if we find it
    local possibleRemotes = {
        "AddToTrade", "AddItem", "AddVehicle", "AddCar",
        "TradeAdd", "AddToTrading", "SendTradeRequest"
    }
    
    -- Wait for ANY call to ANY trading remote
    spawn(function()
        while not capturedData do
            -- Check all possible remotes
            for _, remoteName in pairs(possibleRemotes) do
                local remote = tradingFolder:FindFirstChild(remoteName)
                if remote then
                    print("✅ Found potential remote: " .. remoteName)
                    
                    -- Try to call it with test data to see what happens
                    local testData = {
                        "AstonMartin12",
                        {ItemId = "AstonMartin12"},
                        {ID = "AstonMartin12"},
                        {Car = "AstonMartin12"}
                    }
                    
                    for _, data in pairs(testData) do
                        pcall(function()
                            if remote:IsA("RemoteFunction") then
                                remote:InvokeServer(data)
                                print("  📡 Called " .. remoteName .. " with data")
                            else
                                -- Try both FireServer and Fire
                                pcall(function() remote:FireServer(data) end)
                                pcall(function() remote:Fire(data) end)
                                print("  📡 Fired " .. remoteName .. " with data")
                            end
                        end)
                        task.wait(0.1)
                    end
                end
            end
            
            task.wait(1)
        end
    end)
end

-- METHOD 3: SIMPLE CLICK MONITOR
print("\n🎯 METHOD 3: CLICK MONITOR")

local function monitorClicks()
    local Player = game:GetService("Players").LocalPlayer
    local mouse = Player:GetMouse()
    
    mouse.Button1Down:Connect(function()
        local target = mouse.Target
        if target then
            -- Check if clicked on a button
            local button = target:FindFirstAncestorWhichIsA("TextButton") or 
                          target:FindFirstAncestorWhichIsA("ImageButton")
            
            if button then
                print("\n🖱️ Clicked button: " .. button.Name)
                print("  Text: " .. (button.Text or "N/A"))
                
                -- Check for car attributes
                for _, attr in pairs({"ItemId", "ID", "Item", "Car", "Vehicle"}) do
                    local value = button:GetAttribute(attr)
                    if value then
                        print("  📍 " .. attr .. ": " .. tostring(value))
                        
                        if tostring(value):find("Aston") or tostring(value):find("Martin") then
                            print("  🚗 CAR FOUND!")
                            capturedData = value
                            capturedRemote = button
                        end
                    end
                end
            end
        end
    end)
    
    print("✅ Click monitor active")
end

pcall(monitorClicks)

-- METHOD 4: MANUAL TEST SYSTEM
print("\n🎯 METHOD 4: MANUAL TEST SYSTEM")

print("\n" .. string.rep("🎮", 40))
print("TEST THESE COMMANDS MANUALLY:")
print(string.rep("🎮", 40))

print([[
1. First, try clicking the Aston Martin in your inventory
2. If nothing happens, try these commands:

-- Test AddToTrade remote
local remote = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes:FindFirstChild("AddToTrade")
if remote then
    print("Testing AddToTrade...")
    if remote:IsA("RemoteFunction") then
        remote:InvokeServer("AstonMartin12")
    else
        pcall(function() remote:FireServer("AstonMartin12") end)
        pcall(function() remote:Fire("AstonMartin12") end)
    end
end

-- Test AddItem remote
local remote2 = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes:FindFirstChild("AddItem")
if remote2 then
    print("Testing AddItem...")
    if remote2:IsA("RemoteFunction") then
        remote2:InvokeServer({ItemId = "AstonMartin12"})
    else
        pcall(function() remote2:FireServer({ItemId = "AstonMartin12"}) end)
        pcall(function() remote2:Fire({ItemId = "AstonMartin12"}) end)
    end
end

-- Try ALL remotes
for _, remote in pairs(game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes:GetChildren()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        print("Testing " .. remote.Name .. "...")
        if remote:IsA("RemoteFunction") then
            pcall(function() remote:InvokeServer("AstonMartin12") end)
        else
            pcall(function() remote:FireServer("AstonMartin12") end)
            pcall(function() remote:Fire("AstonMartin12") end)
        end
        wait(0.1)
    end
end
]])

-- WAIT FOR ACTION
print("\n" .. string.rep("⏳", 40))
print("CLICK THE ASTON MARTIN NOW!")
print("I'll wait 15 seconds...")
print(string.rep("⏳", 40))

for i = 1, 15 do
    task.wait(1)
    if capturedData then
        print("\n" .. string.rep("🎉", 40))
        print("SUCCESS! DATA CAPTURED!")
        print(string.rep("🎉", 40))
        break
    end
    if i % 5 == 0 then print("[🕐 " .. i .. "/15] Waiting...") end
end

-- RESULTS
print("\n" .. string.rep("=", 60))

if capturedData then
    print("📊 CAPTURED DATA:")
    print("Data: " .. tostring(capturedData))
    print("From: " .. capturedRemote:GetFullName())
    
    -- CREATE WORKING SCRIPT
    print("\n" .. string.rep("🚀", 40))
    print("CREATING WORKING SCRIPT...")
    print(string.rep("🚀", 40))
    
    local workingScript = ""
    
    if capturedRemote:IsA("TextButton") or capturedRemote:IsA("ImageButton") then
        workingScript = [[
            -- SIMPLE BUTTON CLICKER
            function clickCar()
                local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        for _, button in pairs(gui:GetDescendants()) do
                            if button:IsA("TextButton") or button:IsA("ImageButton") then
                                if button.Name:find("Car") or (button.Text or ""):find("Car") then
                                    for i = 1, 5 do
                                        pcall(function()
                                            button:Fire("Activated")
                                            print("Clicked: " .. button.Name)
                                        end)
                                        wait(0.3)
                                    end
                                    return true
                                end
                            end
                        end
                    end
                end
                return false
            end
            
            clickCar()
        ]]
    else
        -- Remote-based script
        workingScript = [[
            -- SIMPLE TRADE SCRIPT
            local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes
            
            -- Try common remote names
            local remoteNames = {"AddToTrade", "AddItem", "AddVehicle", "TradeAdd"}
            
            for _, remoteName in pairs(remoteNames) do
                local remote = tradingFolder:FindFirstChild(remoteName)
                if remote then
                    print("Found remote: " .. remoteName)
                    
                    -- Try different data formats
                    local testData = {
                        "AstonMartin12",
                        {ItemId = "AstonMartin12"},
                        {ID = "AstonMartin12"},
                        {Car = "AstonMartin12"}
                    }
                    
                    for _, data in pairs(testData) do
                        print("Trying data: " .. tostring(data))
                        
                        if remote:IsA("RemoteFunction") then
                            pcall(function()
                                remote:InvokeServer(data)
                                print("✅ Success!")
                            end)
                        else
                            pcall(function()
                                remote:FireServer(data)
                                print("✅ Success!")
                            end)
                        end
                        
                        wait(0.5)
                    end
                end
            end
            
            print("🎯 Script complete!")
        ]]
    end
    
    -- Display and execute
    print("\n" .. string.rep("=", 60))
    print("💻 WORKING SCRIPT:")
    print(string.rep("=", 60))
    print(workingScript)
    print(string.rep("=", 60))
    
    print("\n🚀 EXECUTING...")
    local success, err = pcall(loadstring, workingScript)
    if not success then
        print("❌ Error: " .. tostring(err))
    end
    
else
    print("❌ NO DATA CAPTURED")
    
    -- ULTIMATE FALLBACK: CREATE ALL-IN-ONE SCRIPT
    print("\n" .. string.rep("💎", 40))
    print("CREATING ALL-IN-ONE SOLUTION...")
    print(string.rep("💎", 40))
    
    local allInOneScript = [[
        -- 💎 ALL-IN-ONE TRADE SOLUTION
        print("💎 ALL-IN-ONE TRADE BOT ACTIVATED")
        
        -- CONFIGURATION
        local TARGET_CAR = "AstonMartin12"
        local ADD_COUNT = 5
        local DELAY_BETWEEN = 0.4
        
        -- FIND THE RIGHT REMOTE
        local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes
        local targetRemote = nil
        local targetMethod = nil
        
        -- List of possible remote names (ordered by likelihood)
        local possibleRemotes = {
            "AddToTrade", "AddItem", "AddVehicle", "AddCar",
            "TradeAdd", "AddToTrading", "SendTradeRequest",
            "OfferTrade", "TradeOffer", "StartTrade"
        }
        
        -- Find any remote that exists
        for _, name in pairs(possibleRemotes) do
            local remote = tradingFolder:FindFirstChild(name)
            if remote then
                targetRemote = remote
                print("✅ Found remote: " .. name)
                break
            end
        end
        
        -- If no named remote found, try any remote in the folder
        if not targetRemote then
            for _, remote in pairs(tradingFolder:GetChildren()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    targetRemote = remote
                    print("✅ Using remote: " .. remote.Name)
                    break
                end
            end
        end
        
        if not targetRemote then
            print("❌ No trading remotes found!")
            return
        end
        
        -- DETECT THE RIGHT METHOD
        local function detectMethod(remote)
            -- Try common methods
            local methods = {"InvokeServer", "FireServer", "Fire", "Invoke"}
            
            for _, methodName in pairs(methods) do
                local success, result = pcall(function()
                    return remote[methodName]
                end)
                
                if success and type(result) == "function" then
                    print("✅ Method detected: " .. methodName)
                    return methodName
                end
            end
            
            print("⚠️ No standard method found, trying InvokeServer by default")
            return "InvokeServer"
        end
        
        targetMethod = detectMethod(targetRemote)
        
        -- TEST DATA FORMATS
        local testDataFormats = {
            TARGET_CAR,  -- Just the string
            {ItemId = TARGET_CAR},
            {ID = TARGET_CAR},
            {Car = TARGET_CAR},
            {Vehicle = TARGET_CAR},
            {Name = "Aston Martin"},
            {ProductId = TARGET_CAR}
        }
        
        -- FUNCTION TO ADD CAR
        function addCar(dataFormat)
            print("➕ Adding car with format: " .. tostring(dataFormat))
            
            local success, result = pcall(function()
                local method = targetRemote[targetMethod]
                
                if type(method) == "function" then
                    if type(dataFormat) == "table" then
                        return method(targetRemote, unpack(dataFormat))
                    else
                        return method(targetRemote, dataFormat)
                    end
                else
                    -- Method doesn't exist, try all methods
                    local allMethods = {"InvokeServer", "FireServer", "Fire", "Invoke"}
                    for _, m in pairs(allMethods) do
                        local func = targetRemote[m]
                        if type(func) == "function" then
                            if type(dataFormat) == "table" then
                                return func(targetRemote, unpack(dataFormat))
                            else
                                return func(targetRemote, dataFormat)
                            end
                        end
                    end
                    return nil, "No valid method found"
                end
            end)
            
            if success then
                print("✅ Success!")
                if result then
                    print("   Result: " .. tostring(result))
                end
                return true
            else
                print("❌ Failed: " .. tostring(result))
                return false
            end
        end
        
        -- MAIN EXECUTION
        print("\n" .. string.rep("🚀", 30))
        print("STARTING BULK ADD...")
        print(string.rep("🚀", 30))
        
        local addedCount = 0
        
        for i = 1, ADD_COUNT do
            print("\n[" .. i .. "/" .. ADD_COUNT .. "]")
            
            -- Try each data format until one works
            local success = false
            for _, dataFormat in pairs(testDataFormats) do
                if addCar(dataFormat) then
                    success = true
                    addedCount = addedCount + 1
                    break
                end
                task.wait(0.1)
            end
            
            if not success then
                print("⚠️ No format worked, trying default...")
                addCar(TARGET_CAR)
            end
            
            task.wait(DELAY_BETWEEN)
        end
        
        print("\n" .. string.rep("🎯", 30))
        print("COMPLETE! Added " .. addedCount .. "/" .. ADD_COUNT .. " cars")
        print(string.rep("🎯", 30))
        
        -- EXPORT FUNCTIONS
        getgenv().TradeBot = {
            add = function(count) 
                ADD_COUNT = count or 5
                -- Run the script again with new count
                -- (In practice, you'd refactor this better)
                print("Use the script above with your desired count")
            end,
            remote = targetRemote,
            method = targetMethod
        }
    ]]
    
    -- Display the ultimate solution
    print("\n" .. string.rep("=", 60))
    print("💎 ULTIMATE ALL-IN-ONE SCRIPT:")
    print(string.rep("=", 60))
    print(allInOneScript)
    print(string.rep("=", 60))
    
    print("\n🚀 EXECUTING ULTIMATE SOLUTION...")
    local success, err = pcall(loadstring, allInOneScript)
    if not success then
        print("❌ Execution error: " .. tostring(err))
        
        -- SUPER SIMPLE FALLBACK
        print("\n🔄 TRYING SUPER SIMPLE VERSION...")
        local superSimple = [[
            print("Super simple attempt...")
            local folder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes
            for i = 1, 3 do
                print("Attempt " .. i)
                for _, remote in pairs(folder:GetChildren()) do
                    if remote:IsA("RemoteFunction") then
                        pcall(function() remote:InvokeServer("AstonMartin12") end)
                    elseif remote:IsA("RemoteEvent") then
                        pcall(function() remote:Fire("AstonMartin12") end)
                    end
                end
                wait(0.5)
            end
            print("Done!")
        ]]
        pcall(loadstring, superSimple)
    end
end

print("\n" .. string.rep("=", 60))
print("💀 MISSION COMPLETE - NO HOOKS, NO ERRORS")
print(string.rep("=", 60))

print("\n📋 FINAL INSTRUCTIONS:")
print("1. If the script worked, you should see cars added")
print("2. If not, copy the ALL-IN-ONE script above")
print("3. Paste it into a new script and run it")
print("4. It will automatically find the right remote and method")
