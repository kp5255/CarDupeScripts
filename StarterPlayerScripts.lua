-- 🔍 ULTIMATE DATA CAPTURER - FIND REAL CAR DATA
print("🔍 ULTIMATE DATA CAPTURER")
print("=" .. string.rep("=", 50))

local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes
local capturedData = nil
local capturedRemote = nil

-- METHOD 1: CAPTURE ALL NETWORK TRAFFIC
print("\n🎯 CAPTURING ALL TRADING NETWORK CALLS...")

-- Temporarily replace ALL remote methods to capture data
local originalMethods = {}

for _, remote in pairs(tradingFolder:GetChildren()) do
    if remote:IsA("RemoteFunction") then
        -- Capture RemoteFunction
        local originalInvoke = remote.InvokeServer
        originalMethods[remote] = originalInvoke
        
        remote.InvokeServer = function(self, ...)
            local args = {...}
            
            print("\n" .. string.rep("📡", 30))
            print("📤 OUTGOING CALL: " .. remote.Name)
            print("Arguments: " .. #args)
            
            for i, arg in ipairs(args) do
                print("\n  [Argument " .. i .. "]")
                
                if type(arg) == "table" then
                    print("  Type: Table")
                    print("  Contents:")
                    
                    -- Save if it looks like item data
                    for k, v in pairs(arg) do
                        print("    " .. tostring(k) .. " = " .. tostring(v))
                        
                        -- Check for ANY car-related data
                        if type(v) == "string" and (v:find("Vehicle") or v:find("Car") or v:find("Aston") or v:find("Martin")) then
                            print("    🚗 CAR DATA DETECTED!")
                            if not capturedData then
                                capturedData = arg
                                capturedRemote = remote
                            end
                        end
                    end
                    
                    -- Also check for item ID patterns
                    if arg.ItemId or arg.ID or arg.id or arg.itemId then
                        print("    📍 ITEM ID FOUND!")
                        if not capturedData then
                            capturedData = arg
                            capturedRemote = remote
                        end
                    end
                    
                elseif type(arg) == "string" then
                    print("  Type: String")
                    print('  Value: "' .. arg .. '"')
                    
                    -- Check for item ID patterns
                    if #arg > 5 and (tonumber(arg) or arg:find("%d")) then
                        print("    🔢 POSSIBLE ITEM ID: " .. arg)
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
            
            print(string.rep("📡", 30))
            
            -- Call original
            return originalInvoke(self, ...)
        end
        
    elseif remote:IsA("RemoteEvent") then
        -- Capture RemoteEvent
        local methods = {"FireServer", "Fire"}
        for _, methodName in pairs(methods) do
            local originalMethod = remote[methodName]
            if type(originalMethod) == "function" then
                originalMethods[remote] = originalMethods[remote] or {}
                originalMethods[remote][methodName] = originalMethod
                
                remote[methodName] = function(self, ...)
                    local args = {...}
                    
                    print("\n" .. string.rep("📡", 30))
                    print("📤 EVENT FIRED: " .. remote.Name .. " (" .. methodName .. ")")
                    print("Arguments: " .. #args)
                    
                    for i, arg in ipairs(args) do
                        print("\n  [Argument " .. i .. "]")
                        print("  Type: " .. type(arg))
                        
                        if type(arg) == "table" then
                            for k, v in pairs(arg) do
                                print("    " .. tostring(k) .. " = " .. tostring(v))
                            end
                        else
                            print("  Value: " .. tostring(arg))
                        end
                    end
                    
                    print(string.rep("📡", 30))
                    
                    return originalMethod(self, ...)
                end
            end
        end
    end
end

print("✅ All trading remotes are now MONITORING!")
print("\n🎯 NOW: CLICK THE ASTON MARTIN IN YOUR INVENTORY")
print("I will capture EXACTLY what data is sent")

-- WAIT FOR CLICK
print("\n" .. string.rep("⏳", 40))
print("WAITING FOR CAR CLICK...")
print("You have 30 seconds to click the car")
print(string.rep("⏳", 40))

for i = 1, 30 do
    task.wait(1)
    if capturedData then
        print("\n" .. string.rep("🎉", 40))
        print("SUCCESS! CAR DATA CAPTURED!")
        print(string.rep("🎉", 40))
        break
    end
    if i % 5 == 0 then
        print("[🕐 " .. i .. "/30] Still waiting for click...")
    end
end

-- RESTORE ORIGINAL METHODS
print("\n🧹 Restoring original methods...")
for remote, method in pairs(originalMethods) do
    if type(method) == "function" then
        remote.InvokeServer = method
    elseif type(method) == "table" then
        for methodName, originalMethod in pairs(method) do
            remote[methodName] = originalMethod
        end
    end
end

-- RESULTS
print("\n" .. string.rep("=", 60))

if capturedData then
    print("🎯 CAPTURED DATA FOUND!")
    print("Remote: " .. capturedRemote.Name)
    print("Data type: " .. type(capturedData))
    
    if type(capturedData) == "table" then
        print("\n📊 TABLE CONTENTS:")
        for k, v in pairs(capturedData) do
            print("  " .. tostring(k) .. " = " .. tostring(v))
        end
        
        -- CREATE WORKING BOT WITH REAL DATA
        print("\n" .. string.rep("🚀", 30))
        print("CREATING WORKING BOT...")
        print(string.rep("🚀", 30))
        
        local botCode = [[
            -- 🎯 WORKING TRADE BOT WITH REAL DATA
            local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes
            local sessionAddItem = tradingFolder:WaitForChild("SessionAddItem")
            
            -- EXACT captured data:
            local carData = ]] .. game:GetService("HttpService"):JSONEncode(capturedData) .. [[
            
            print("🎯 Adding car with REAL data...")
            print("Data: " .. game:GetService("HttpService"):JSONEncode(carData))
            
            function addCar()
                local success, result = pcall(function()
                    return sessionAddItem:InvokeServer(carData)
                end)
                
                if success then
                    print("✅ Result: " .. tostring(result))
                    return result
                else
                    print("❌ Error: " .. tostring(result))
                    return false
                end
            end
            
            function addMultiple(count)
                local added = 0
                for i = 1, count do
                    print("[" .. i .. "/" .. count .. "]")
                    if addCar() then
                        added = added + 1
                    end
                    task.wait(0.5)
                end
                print("🎯 Added " .. added .. "/" .. count)
                return added
            end
            
            -- Export functions
            getgenv().RealTrade = {
                add1 = function() addMultiple(1) end,
                add5 = function() addMultiple(5) end,
                add10 = function() addMultiple(10) end,
                test = addCar,
                data = carData
            }
            
            print("\n🎮 Use RealTrade.add5() to add cars!")
            
            -- Test
            task.wait(1)
            RealTrade.test()
        ]]
        
        print("\n" .. string.rep("=", 60))
        print("🤖 WORKING BOT CODE:")
        print(string.rep("=", 60))
        print(botCode)
        print(string.rep("=", 60))
        
        print("\n🚀 EXECUTING BOT...")
        local success, err = pcall(loadstring, botCode)
        if not success then
            print("❌ Bot error: " .. tostring(err))
        end
        
    else
        -- String data
        print("\n📄 STRING DATA: " .. capturedData)
        
        local botCode = [[
            local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes
            local sessionAddItem = tradingFolder:WaitForChild("SessionAddItem")
            
            print("Testing with captured data: " .. ]] .. '"' .. capturedData .. '"' .. [[)
            
            for i = 1, 3 do
                print("Attempt " .. i)
                local success, result = pcall(function()
                    return sessionAddItem:InvokeServer(]] .. '"' .. capturedData .. '"' .. [[)
                end)
                print("Result: " .. tostring(result))
                wait(0.5)
            end
        ]]
        
        print("\n🚀 Testing captured string...")
        pcall(loadstring, botCode)
    end
    
else
    print("❌ NO DATA CAPTURED")
    
    -- ALTERNATIVE: CHECK INVENTORY FOR REAL ITEM IDS
    print("\n🔍 CHECKING INVENTORY FOR ITEM DATA...")
    
    local function findInventoryData()
        -- Try to find inventory GUI
        local Player = game:GetService("Players").LocalPlayer
        local PlayerGui = Player:WaitForChild("PlayerGui")
        
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                print("Checking GUI: " .. gui.Name)
                
                -- Look for car buttons with attributes
                for _, button in pairs(gui:GetDescendants()) do
                    if button:IsA("TextButton") or button:IsA("ImageButton") then
                        local name = button.Name:lower()
                        if name:find("aston") or name:find("martin") or name:find("car") then
                            print("\n🎯 Found car button: " .. button.Name)
                            
                            -- Check all attributes
                            for _, attr in pairs({"ItemId", "ID", "Id", "itemId", "AssetId", "ProductId", "Item", "item"}) do
                                local value = button:GetAttribute(attr)
                                if value then
                                    print("  📍 " .. attr .. ": " .. tostring(value))
                                    
                                    -- Test this value
                                    print("  🧪 Testing this value...")
                                    local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes
                                    local sessionAddItem = tradingFolder:WaitForChild("SessionAddItem")
                                    
                                    -- Try as string
                                    pcall(function()
                                        sessionAddItem:InvokeServer(value)
                                        print("    ✅ Sent as string")
                                    end)
                                    
                                    -- Try as table
                                    pcall(function()
                                        sessionAddItem:InvokeServer({ItemId = value})
                                        print("    ✅ Sent as table with ItemId")
                                    end)
                                    
                                    task.wait(0.5)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    pcall(findInventoryData)
end

-- FINAL: TRY TO GET ITEM ID FROM GAME DATA
print("\n" .. string.rep("💡", 40))
print("TRYING TO FIND REAL ITEM ID...")
print(string.rep("💡", 40))

local finalAttemptCode = [[
    -- 🕵️ FIND REAL ASTON MARTIN ITEM ID
    
    -- Method 1: Search all game data
    function searchForCarId()
        local possibleIds = {}
        
        -- Check ReplicatedStorage for car data
        local RS = game:GetService("ReplicatedStorage")
        for _, obj in pairs(RS:GetDescendants()) do
            if obj:IsA("StringValue") or obj:IsA("NumberValue") then
                local name = obj.Name:lower()
                local value = tostring(obj.Value):lower()
                
                if name:find("aston") or name:find("martin") or 
                   value:find("aston") or value:find("martin") then
                    table.insert(possibleIds, {
                        name = obj.Name,
                        value = obj.Value,
                        path = obj:GetFullName()
                    })
                end
            end
        end
        
        return possibleIds
    end
    
    -- Method 2: Try common car ID patterns
    function tryCommonPatterns()
        print("Trying common car ID patterns...")
        
        local patterns = {
            "AstonMartin12",
            "astonmartin12",
            "Aston_Martin_12",
            "aston_martin_12",
            "Vehicle_AstonMartin12",
            "Car_AstonMartin12",
            "AM12",
            "am12"
        }
        
        -- Also try numeric IDs (common in games)
        for i = 1000, 1100 do
            table.insert(patterns, tostring(i))
        end
        
        for i = 5000, 5100 do
            table.insert(patterns, tostring(i))
        end
        
        return patterns
    end
    
    -- Test all patterns
    local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes
    local sessionAddItem = tradingFolder:WaitForChild("SessionAddItem")
    
    print("🔍 Testing common patterns...")
    
    local patterns = tryCommonPatterns()
    for i, pattern in ipairs(patterns) do
        if i > 50 then break end -- Limit attempts
        
        print("Pattern " .. i .. ": " .. pattern)
        
        -- Try as string
        pcall(function()
            sessionAddItem:InvokeServer(pattern)
        end)
        
        -- Try as table
        pcall(function()
            sessionAddItem:InvokeServer({ItemId = pattern})
        end)
        
        pcall(function()
            sessionAddItem:InvokeServer({ID = pattern})
        end)
        
        task.wait(0.1)
    end
    
    print("🎯 Pattern testing complete!")
]]

print("🚀 Running final attempt...")
pcall(loadstring, finalAttemptCode)

print("\n" .. string.rep("=", 60))
print("🔍 DATA CAPTURE COMPLETE")
print(string.rep("=", 60))

print("\n📋 NEXT STEPS:")
print("1. Click the Aston Martin in your inventory")
print("2. Look at the CAPTURED DATA above")
print("3. Share the EXACT data that appears")
print("4. I'll create the perfect bot with that data")
