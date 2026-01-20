-- 💀 FINAL BATTLE - ULTIMATE FIXED VERSION
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Safe print with JSON encoding for tables
function safePrint(...)
    local args = {...}
    for i, arg in ipairs(args) do
        if type(arg) == "table" then
            local success, json = pcall(HttpService.JSONEncode, HttpService, arg)
            if success then
                print("📦 TABLE (JSON): " .. json)
            else
                print("📦 TABLE: " .. tostring(arg))
            end
        else
            print(tostring(arg))
        end
    end
end

print("💀 FINAL BATTLE - ULTIMATE VERSION")
print("=" .. string.rep("=", 60))

-- Get ALL trading remotes
local tradingFolder = RS.Remotes.Services.TradingServiceRemotes
local capturedData = nil
local capturedRemote = nil
local capturedRemoteType = nil

print("🎯 MONITORING ALL TRADING REMOTES:")
for _, remote in pairs(tradingFolder:GetChildren()) do
    print("  • " .. remote.Name .. " (" .. remote.ClassName .. ")")
    
    if remote.ClassName == "RemoteFunction" then
        capturedRemoteType = "RemoteFunction"
        -- Hook RemoteFunction with maximum protection
        local originalInvoke = remote.InvokeServer
        if originalInvoke then
            remote.InvokeServer = function(self, ...)
                local args = {...}
                
                print("\n🔥 CAPTURED CALL TO: " .. remote.Name)
                print("📊 Arguments:", #args)
                
                -- Deep inspect all arguments
                for i, arg in ipairs(args) do
                    print("\n  Argument " .. i .. ":")
                    
                    if type(arg) == "table" then
                        print("  Type: Table")
                        print("  Contents:")
                        
                        -- Deep table inspection
                        local function deepInspect(tbl, indent)
                            indent = indent or "    "
                            for k, v in pairs(tbl) do
                                local keyStr = tostring(k)
                                local valueType = type(v)
                                
                                if valueType == "table" then
                                    print(indent .. keyStr .. " = [TABLE]")
                                    deepInspect(v, indent .. "  ")
                                elseif valueType == "string" then
                                    print(indent .. keyStr .. ' = "' .. tostring(v) .. '"')
                                    -- Check for car references
                                    local lowerV = tostring(v):lower()
                                    if lowerV:find("aston") or lowerV:find("martin") or 
                                       lowerV:find("vehicle") or lowerV:find("car") then
                                        print(indent .. "🎯 CAR IDENTIFIED!")
                                        if not capturedData then
                                            capturedData = tbl
                                            capturedRemote = remote
                                        end
                                    end
                                else
                                    print(indent .. keyStr .. " = " .. tostring(v))
                                end
                            end
                        end
                        
                        deepInspect(arg)
                        
                        -- Also check for ID fields
                        local function checkForCarId(tbl)
                            for k, v in pairs(tbl) do
                                local keyStr = tostring(k):lower()
                                local valueStr = tostring(v):lower()
                                
                                if (keyStr:find("id") or keyStr:find("item")) and 
                                   (valueStr:find("aston") or valueStr:find("martin") or 
                                    valueStr:find("vehicle") or valueStr:find("car")) then
                                    return true, tbl
                                end
                            end
                            return false, nil
                        end
                        
                        local isCar, carData = checkForCarId(arg)
                        if isCar and not capturedData then
                            capturedData = carData
                            capturedRemote = remote
                            print("🎯 CAR DATA CAPTURED VIA ID CHECK!")
                        end
                        
                    elseif type(arg) == "string" then
                        print("  Type: String")
                        print('  Value: "' .. arg .. '"')
                        
                        local lowerArg = arg:lower()
                        if lowerArg:find("aston") or lowerArg:find("martin") or 
                           lowerArg:find("vehicle") or lowerArg:find("car") then
                            print("🎯 CAR STRING IDENTIFIED!")
                            if not capturedData then
                                capturedData = arg
                                capturedRemote = remote
                            end
                        end
                        
                    else
                        print("  Type: " .. type(arg))
                        print("  Value: " .. tostring(arg))
                    end
                end
                
                -- Also capture the result
                local result = nil
                local success, err = pcall(function()
                    result = originalInvoke(self, ...)
                    return result
                end)
                
                if success then
                    print("✅ Original call succeeded")
                    if result then
                        print("📤 Return value: " .. tostring(result))
                    end
                else
                    print("❌ Original call failed: " .. tostring(err))
                end
                
                return result
            end
        end
        
    elseif remote.ClassName == "RemoteEvent" then
        capturedRemoteType = "RemoteEvent"
        -- Hook RemoteEvent - TEST ALL POSSIBLE METHODS
        
        -- Method 1: Try FireServer (older Roblox)
        if remote.FireServer then
            print("  ✓ Using FireServer method")
            local originalFire = remote.FireServer
            remote.FireServer = function(self, ...)
                local args = {...}
                
                print("\n🔥 CAPTURED EVENT (FireServer): " .. remote.Name)
                print("📊 Arguments:", #args)
                
                -- Same deep inspection as above
                for i, arg in ipairs(args) do
                    print("\n  Argument " .. i .. ":")
                    
                    if type(arg) == "table" then
                        print("  Type: Table")
                        print("  Contents:")
                        
                        local function deepInspect(tbl, indent)
                            indent = indent or "    "
                            for k, v in pairs(tbl) do
                                local keyStr = tostring(k)
                                local valueType = type(v)
                                
                                if valueType == "table" then
                                    print(indent .. keyStr .. " = [TABLE]")
                                    deepInspect(v, indent .. "  ")
                                elseif valueType == "string" then
                                    print(indent .. keyStr .. ' = "' .. tostring(v) .. '"')
                                    local lowerV = tostring(v):lower()
                                    if lowerV:find("aston") or lowerV:find("martin") then
                                        print(indent .. "🎯 CAR IDENTIFIED!")
                                        if not capturedData then
                                            capturedData = tbl
                                            capturedRemote = remote
                                        end
                                    end
                                else
                                    print(indent .. keyStr .. " = " .. tostring(v))
                                end
                            end
                        end
                        
                        deepInspect(arg)
                        
                    elseif type(arg) == "string" then
                        print("  Type: String")
                        print('  Value: "' .. arg .. '"')
                        
                        if arg:lower():find("aston") or arg:lower():find("martin") then
                            print("🎯 CAR STRING IDENTIFIED!")
                            if not capturedData then
                                capturedData = arg
                                capturedRemote = remote
                            end
                        end
                    else
                        print("  Type: " .. type(arg))
                        print("  Value: " .. tostring(arg))
                    end
                end
                
                return originalFire(self, ...)
            end
            
        -- Method 2: Try Fire (newer Roblox)
        elseif remote.Fire then
            print("  ✓ Using Fire method")
            local originalFire = remote.Fire
            remote.Fire = function(self, ...)
                local args = {...}
                
                print("\n🔥 CAPTURED EVENT (Fire): " .. remote.Name)
                print("📊 Arguments:", #args)
                
                -- Same inspection logic...
                for i, arg in ipairs(args) do
                    print("\n  Argument " .. i .. ":")
                    safePrint(arg)
                    
                    if type(arg) == "string" and arg:lower():find("aston") or arg:lower():find("martin") then
                        print("🎯 CAR STRING IDENTIFIED!")
                        if not capturedData then
                            capturedData = arg
                            capturedRemote = remote
                        end
                    end
                end
                
                return originalFire(self, ...)
            end
            
        -- Method 3: Try __index metatable approach
        else
            print("  ⚠️ Trying metatable hook...")
            
            local mt = getrawmetatable(remote)
            if mt then
                local oldIndex = mt.__index
                mt.__index = function(self, key)
                    if key == "FireServer" or key == "Fire" then
                        return function(...)
                            print("\n🔥 CAPTURED VIA METATABLE: " .. remote.Name)
                            print("Method used: " .. key)
                            -- This would need more complex handling
                        end
                    end
                    return oldIndex(self, key)
                end
            end
        end
    end
end

print("\n✅ ALL TRADING REMOTES HOOKED!")
print("NOW: Click AstonMartin12 in your inventory ONCE")
print("Waiting 45 seconds for click...")

-- Enhanced waiting with visual feedback
local dots = {"", ".", "..", "..."}
local dotIndex = 1

for i = 1, 45 do
    task.wait(1)
    
    -- Animated waiting indicator
    dotIndex = dotIndex + 1
    if dotIndex > 4 then dotIndex = 1 end
    
    if capturedData then
        print("\n" .. string.rep("🎉", 30))
        print("🔥 SUCCESS! CAR CLICK CAPTURED! 🔥")
        print(string.rep("🎉", 30))
        break
    end
    
    if i % 5 == 0 then 
        print("[🕐 " .. i .. "/45] Still waiting for click" .. dots[dotIndex])
        
        -- Check if inventory is open
        pcall(function()
            local playerGui = Player:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in pairs(playerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and (gui.Name:lower():find("invent") or gui.Name:lower():find("trade")) then
                        print("📦 Inventory/Trade GUI detected: " .. gui.Name)
                    end
                end
            end
        end)
    end
end

-- ULTIMATE DATA CAPTURE ANALYSIS
if capturedData and capturedRemote then
    print("\n" .. string.rep("📊", 30))
    print("ULTIMATE CAPTURE RESULTS:")
    print(string.rep("📊", 30))
    
    print("Remote used: " .. capturedRemote.Name)
    print("Remote type: " .. capturedRemote.ClassName)
    print("Data type: " .. type(capturedData))
    
    -- DEEP ANALYSIS OF CAPTURED DATA
    print("\n🔍 DEEP DATA ANALYSIS:")
    
    local function analyzeData(data, path)
        path = path or "root"
        
        if type(data) == "table" then
            print("\n📁 " .. path .. " (Table):")
            for k, v in pairs(data) do
                local keyPath = path .. "." .. tostring(k)
                local valueType = type(v)
                
                if valueType == "table" then
                    analyzeData(v, keyPath)
                elseif valueType == "string" then
                    print("  📍 " .. tostring(k) .. ": \"" .. tostring(v) .. "\"")
                    -- Highlight important fields
                    local lowerK = tostring(k):lower()
                    local lowerV = tostring(v):lower()
                    
                    if lowerK:find("id") or lowerK:find("item") or lowerK:find("name") then
                        print("    ⭐ IMPORTANT FIELD DETECTED!")
                        if lowerV:find("aston") or lowerV:find("martin") then
                            print("    🚗 CAR SPECIFIC DATA!")
                        end
                    end
                else
                    print("  📍 " .. tostring(k) .. ": " .. tostring(v))
                end
            end
        else
            print("📄 " .. path .. ": " .. tostring(data))
        end
    end
    
    analyzeData(capturedData)
    
    -- CREATE ULTIMATE BOT
    print("\n" .. string.rep("🤖", 30))
    print("CREATING ULTIMATE BOT...")
    print(string.rep("🤖", 30))
    
    -- Generate bot code based on captured data type
    local botCode = ""
    
    if type(capturedData) == "table" then
        -- Convert table to Lua code
        local function tableToCode(tbl, indent)
            indent = indent or ""
            local parts = {}
            
            for k, v in pairs(tbl) do
                local keyStr = tostring(k)
                local valueStr = ""
                
                if type(v) == "string" then
                    valueStr = '"' .. v .. '"'
                elseif type(v) == "number" then
                    valueStr = tostring(v)
                elseif type(v) == "boolean" then
                    valueStr = tostring(v)
                elseif type(v) == "table" then
                    valueStr = tableToCode(v, indent .. "  ")
                else
                    valueStr = '"' .. tostring(v) .. '"'
                end
                
                -- Handle numeric vs string keys
                if tonumber(keyStr) then
                    table.insert(parts, indent .. "[" .. keyStr .. "] = " .. valueStr)
                else
                    table.insert(parts, indent .. keyStr .. " = " .. valueStr)
                end
            end
            
            return "{\n" .. table.concat(parts, ",\n") .. "\n" .. string.sub(indent, 1, #indent-2) .. "}"
        end
        
        botCode = [[
            -- 🤖 ULTIMATE TRADE BOT
            
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local remote = ReplicatedStorage.Remotes.Services.TradingServiceRemotes.]] .. capturedRemote.Name .. [[
            
            local carData = ]] .. tableToCode(capturedData) .. [[
            
            print("🤖 ULTIMATE BOT ACTIVATED")
            print("Using remote: " .. remote.Name)
            print("Remote type: " .. remote.ClassName)
            
            -- SMART SENDING FUNCTION
            function sendTradeRequest(data, attempt)
                attempt = attempt or 1
                print("\n📤 Attempt " .. attempt .. ": Sending trade request...")
                
                local success, result = pcall(function()
                    if remote.ClassName == "RemoteFunction" then
                        return remote:InvokeServer(data)
                    else
                        -- Try both methods for RemoteEvent
                        local success1, result1 = pcall(function()
                            return remote:FireServer(data)
                        end)
                        
                        if success1 then
                            return result1
                        else
                            return remote:Fire(data)
                        end
                    end
                end)
                
                if success then
                    print("✅ Success!")
                    if result then
                        print("📥 Response: " .. tostring(result))
                    end
                    return true, result
                else
                    print("❌ Failed: " .. tostring(result))
                    
                    -- Retry logic
                    if attempt < 3 then
                        task.wait(1)
                        return sendTradeRequest(data, attempt + 1)
                    end
                    return false, result
                end
            end
            
            -- BATCH OPERATIONS
            function addMultiple(count, delay)
                delay = delay or 0.5
                print("\n📦 Starting batch of " .. count .. " items...")
                
                local successes = 0
                for i = 1, count do
                    print("[" .. i .. "/" .. count .. "] Processing...")
                    
                    local success = sendTradeRequest(carData)
                    if success then
                        successes = successes + 1
                    end
                    
                    -- Dynamic delay based on success rate
                    local currentDelay = delay
                    if successes / i < 0.5 then  -- Less than 50% success rate
                        currentDelay = currentDelay * 2  -- Slow down
                        print("⚠️ Slowing down due to errors...")
                    end
                    
                    task.wait(currentDelay)
                end
                
                print("\n🎯 Batch complete!")
                print("Successes: " .. successes .. "/" .. count)
                return successes
            end
            
            -- EXPORT FUNCTIONS TO GLOBAL
            getgenv().UltimateBot = {
                test = function() return sendTradeRequest(carData) end,
                add1 = function() addMultiple(1) end,
                add5 = function() addMultiple(5) end,
                add10 = function() addMultiple(10) end,
                addCustom = function(count, delay) addMultiple(count or 1, delay or 0.5) end,
                data = carData,
                remote = remote
            }
            
            print("\n" .. string.rep("✅", 30))
            print("ULTIMATE BOT READY!")
            print(string.rep("✅", 30))
            print("\nAvailable commands:")
            print("  UltimateBot.test()  - Test once")
            print("  UltimateBot.add1()  - Add 1 car")
            print("  UltimateBot.add5()  - Add 5 cars")
            print("  UltimateBot.add10() - Add 10 cars")
            print("  UltimateBot.addCustom(20, 0.3) - Custom amount/delay")
            print("\nData stored in: UltimateBot.data")
            print("Remote stored in: UltimateBot.remote")
            
            -- Auto-test
            task.wait(2)
            print("\n🧪 Running auto-test...")
            UltimateBot.test()
        ]]
        
    else
        -- Simple data (string/number)
        botCode = [[
            local remote = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes.]] .. capturedRemote.Name .. [[
            local data = ]] .. 
            (type(capturedData) == "string" and '"' .. capturedData .. '"' or tostring(capturedData)) .. [[
            
            print("Simple bot activated")
            
            -- Try to add 3 immediately
            for i = 1, 3 do
                print("Adding " .. i .. "...")
                pcall(function()
                    if remote.ClassName == "RemoteFunction" then
                        remote:InvokeServer(data)
                    else
                        pcall(function() remote:FireServer(data) end)
                        pcall(function() remote:Fire(data) end)
                    end
                end)
                task.wait(0.7)
            end
            print("✅ Done!")
        ]]
    end
    
    print("\n" .. string.rep("=", 60))
    print("🤖 ULTIMATE BOT CODE GENERATED")
    print(string.rep("=", 60))
    
    -- Save bot code to clipboard (if possible)
    pcall(function()
        setclipboard(botCode)
        print("📋 Bot code copied to clipboard!")
    end)
    
    print("\n" .. string.rep("🚀", 30))
    print("EXECUTING ULTIMATE BOT...")
    print(string.rep("🚀", 30))
    
    -- Execute with maximum protection
    local success, err = pcall(function()
        local func, loadErr = loadstring(botCode)
        if func then
            func()
        else
            error("Loadstring failed: " .. tostring(loadErr))
        end
    end)
    
    if not success then
        print("❌ Bot execution failed: " .. tostring(err))
        
        -- Try alternative execution method
        print("\n🔄 Trying alternative execution...")
        pcall(loadstring, [[
            print("Alternative execution attempt...")
            local remote = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes.]] .. capturedRemote.Name .. [[
            print("Remote: " .. remote.Name)
            print("Click the car again while I watch...")
        ]])
    end
    
else
    -- ULTIMATE FALLBACK PLAN
    print("\n" .. string.rep("⚠️", 30))
    print("NO CLICK CAPTURED - ACTIVATING FALLBACK PLAN")
    print(string.rep("⚠️", 30))
    
    -- METHOD 1: Find and simulate all possible buttons
    print("\n🔍 METHOD 1: Button discovery...")
    
    local function findAndClickCarButtons()
        local foundButtons = {}
        
        -- Search in PlayerGui
        pcall(function()
            local PlayerGui = Player:WaitForChild("PlayerGui")
            for _, gui in pairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    for _, obj in pairs(gui:GetDescendants()) do
                        if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Visible then
                            local name = obj.Name:lower()
                            local text = (obj.Text or ""):lower()
                            
                            -- Check for car indicators
                            if name:find("aston") or name:find("martin") or 
                               text:find("aston") or text:find("martin") or
                               name:find("vehicle") or name:find("car") or
                               name:find("add") or name:find("trade") then
                                
                                table.insert(foundButtons, {
                                    object = obj,
                                    name = obj.Name,
                                    text = obj.Text or ""
                                })
                            end
                        end
                    end
                end
            end
        end)
        
        return foundButtons
    end
    
    local buttons = findAndClickCarButtons()
    print("Found " .. #buttons .. " potential buttons")
    
    if #buttons > 0 then
        print("\n🎯 Simulating clicks on all found buttons...")
        for i, buttonInfo in ipairs(buttons) do
            print("[" .. i .. "] " .. buttonInfo.name .. " - " .. buttonInfo.text)
            
            -- Try to click
            pcall(function()
                local btn = buttonInfo.object
                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                    -- Try multiple click methods
                    pcall(function() btn:Fire("Activated") end)
                    pcall(function() 
                        local activated = btn.Activated
                        if activated then
                            activated:Fire()
                        end
                    end)
                    pcall(function() 
                        btn:Fire("MouseButton1Click") 
                    end)
                    
                    print("✅ Click simulated")
                    
                    -- Check for attributes that might hold item data
                    for _, attr in pairs({
                        "ItemId", "ID", "Id", "ItemID", 
                        "ProductId", "AssetId", "Data",
                        "Item", "Car", "Vehicle"
                    }) do
                        local value = btn:GetAttribute(attr)
                        if value then
                            print("  📍 Attribute " .. attr .. ": " .. tostring(value))
                        end
                    end
                end
            end)
            
            task.wait(0.5)
        end
    end
    
    -- METHOD 2: Direct remote guessing
    print("\n🔍 METHOD 2: Direct remote guessing...")
    
    -- Common trade remote names
    local commonRemoteNames = {
        "AddToTrade", "AddItem", "AddVehicle", "AddCar",
        "TradeAdd", "AddToTrading", "SendTradeRequest",
        "StartTrade", "OfferTrade", "TradeOffer"
    }
    
    for _, remoteName in pairs(commonRemoteNames) do
        local remote = tradingFolder:FindFirstChild(remoteName)
        if remote then
            print("Found remote: " .. remoteName .. " (" .. remote.ClassName .. ")")
            
            -- Try to use it with dummy data
            local dummyData = {
                ItemId = "AstonMartin12",
                ID = "AstonMartin12",
                Name = "Aston Martin",
                Car = "AstonMartin12",
                Vehicle = "AstonMartin12"
            }
            
            pcall(function()
                if remote.ClassName == "RemoteFunction" then
                    remote:InvokeServer(dummyData)
                    print("  ✅ Called with dummy data")
                elseif remote.ClassName == "RemoteEvent" then
                    pcall(function() remote:FireServer(dummyData) end)
                    pcall(function() remote:Fire(dummyData) end)
                    print("  ✅ Fired with dummy data")
                end
            end)
        end
    end
    
    -- METHOD 3: Memory scanning approach (conceptual)
    print("\n🔍 METHOD 3: Advanced analysis...")
    
    -- Check for any recent network activity
    print("Monitoring last 5 seconds of activity...")
    
    -- Create a new hook for any future clicks
    print("\n🔄 Setting up live monitoring...")
    
    -- Hook all UI events
    pcall(function()
        local UIS = game:GetService("UserInputService")
        UIS.InputBegan:Connect(function(input, processed)
            if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
                print("🖱️ Mouse click detected - check inventory now!")
            end
        end)
    end)
end

print("\n" .. string.rep("=", 60))
print("🎯 FINAL STATUS: " .. (capturedData and "DATA CAPTURED - BOT DEPLOYED" or "NEEDS MANUAL INVESTIGATION"))
print(string.rep("=", 60))

-- Provide next steps
if not capturedData then
    print("\n📋 MANUAL INVESTIGATION STEPS:")
    print("1. Open your inventory")
    print("2. Find the Aston Martin car")
    print("3. Click it ONCE")
    print("4. Check the output above for captured data")
    print("5. If nothing appears, the remote might be elsewhere")
    print("\n🔍 Check these locations:")
    print("  • game.ReplicatedStorage.Remotes.*")
    print("  • game.ReplicatedStorage:FindFirstChild('Remote', true)")
    print("  • game:GetService('ReplicatedStorage'):GetDescendants()")
end

print("\n💀 MISSION " .. (capturedData and "ACCOMPLISHED" or "REQUIRES FURTHER ACTION"))
