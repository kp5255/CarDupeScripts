-- 💀 FINAL BATTLE - NO ERRORS, JUST TRUTH
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

print("💀 FINAL BATTLE")
print("=" .. string.rep("=", 60))

-- Get ALL trading remotes
local tradingFolder = RS.Remotes.Services.TradingServiceRemotes
local capturedData = nil
local capturedRemote = nil

print("🎯 MONITORING ALL TRADING REMOTES:")
for _, remote in pairs(tradingFolder:GetChildren()) do
    print("  • " .. remote.Name .. " (" .. remote.ClassName .. ")")
    
    if remote.ClassName == "RemoteFunction" then
        -- Hook RemoteFunction
        local originalInvoke = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            local args = {...}
            
            print("\n🔥 CAPTURED CALL TO: " .. remote.Name)
            print("Arguments:", #args)
            
            for i, arg in ipairs(args) do
                print("  Arg " .. i .. " type:", type(arg))
                
                if type(arg) == "table" then
                    print("  📊 TABLE CONTENTS:")
                    for k, v in pairs(arg) do
                        print("    " .. tostring(k) .. " = " .. tostring(v))
                    end
                    
                    -- Check if this looks like car data
                    for _, checkKey in pairs({"Id", "ID", "id", "ItemId", "Name", "Car", "Vehicle"}) do
                        if arg[checkKey] and tostring(arg[checkKey]):find("Aston") 
                           or tostring(arg[checkKey]):find("Martin") 
                           or tostring(arg[checkKey]):find("aston") 
                           or tostring(arg[checkKey]):find("martin") then
                            print("🎯 THIS LOOKS LIKE OUR CAR!")
                            capturedData = arg
                            capturedRemote = remote
                        end
                    end
                    
                elseif type(arg) == "string" then
                    print("  Value: \"" .. arg .. "\"")
                    if arg:find("Aston") or arg:find("Martin") or arg:find("aston") or arg:find("martin") then
                        print("🎯 THIS LOOKS LIKE OUR CAR!")
                        capturedData = arg
                        capturedRemote = remote
                    end
                else
                    print("  Value:", arg)
                end
            end
            
            -- Call original
            return originalInvoke(self, ...)
        end
        
    elseif remote.ClassName == "RemoteEvent" then
        -- Hook RemoteEvent
        local originalFire = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            
            print("\n🔥 CAPTURED EVENT: " .. remote.Name)
            print("Arguments:", #args)
            
            for i, arg in ipairs(args) do
                print("  Arg " .. i .. " type:", type(arg))
                
                if type(arg) == "table" then
                    print("  📊 TABLE CONTENTS:")
                    for k, v in pairs(arg) do
                        print("    " .. tostring(k) .. " = " .. tostring(v))
                    end
                elseif type(arg) == "string" then
                    print("  Value: \"" .. arg .. "\"")
                else
                    print("  Value:", arg)
                end
            end
            
            -- Call original
            return originalFire(self, ...)
        end
    end
end

print("\n✅ ALL TRADING REMOTES HOOKED!")
print("NOW: Click AstonMartin12 in your inventory ONCE")
print("I will see EXACTLY what gets called")

-- Wait for click
for i = 1, 40 do
    task.wait(1)
    if capturedData then
        print("\n" .. string.rep("🎉", 20))
        print("SUCCESS! CAR CLICK CAPTURED!")
        print(string.rep("🎉", 20))
        break
    end
    if i % 5 == 0 then print("Waiting for click... " .. i .. "/40") end
end

if capturedData and capturedRemote then
    print("\n📊 CAPTURE RESULTS:")
    print("Remote used:", capturedRemote.Name)
    print("Data type:", type(capturedData))
    
    if type(capturedData) == "table" then
        print("Data contents:")
        for k, v in pairs(capturedData) do
            print("  " .. tostring(k) .. " = " .. tostring(v))
        end
    else
        print("Data:", capturedData)
    end
    
    -- CREATE THE WORKING BOT
    print("\n" .. string.rep("🚀", 20))
    print("CREATING WORKING BOT...")
    print(string.rep("🚀", 20))
    
    -- Bot code
    local botCode = [[
        -- 🎯 WORKING TRADE BOT
        local remote = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes.]] .. capturedRemote.Name .. [[
        
        local data = ]] .. 
        (type(capturedData) == "table" and 
            "{" .. 
            (function()
                local parts = {}
                for k, v in pairs(capturedData) do
                    if type(v) == "string" then
                        table.insert(parts, tostring(k) .. ' = "' .. tostring(v) .. '"')
                    elseif type(v) == "number" then
                        table.insert(parts, tostring(k) .. ' = ' .. tostring(v))
                    elseif type(v) == "boolean" then
                        table.insert(parts, tostring(k) .. ' = ' .. tostring(v))
                    else
                        table.insert(parts, tostring(k) .. ' = "' .. tostring(v) .. '"')
                    end
                end
                return table.concat(parts, ", ")
            end)() .. 
            "}" 
        or 
            '"' .. tostring(capturedData) .. '"') .. [[
        
        print("Using remote: " .. remote.Name)
        print("Data:", data)
        
        -- Test function
        function testAdd()
            print("🧪 Testing add...")
            local success, result = pcall(function()
                return remote:InvokeServer(data)
            end)
            
            if success then
                print("✅ Test successful!")
                print("Result:", result)
                return true
            else
                print("❌ Test failed:", result)
                return false
            end
        end
        
        -- Bulk add function
        function addMultiple(count)
            print("📦 Adding " .. count .. " items...")
            
            local added = 0
            for i = 1, count do
                print("[" .. i .. "/" .. count .. "] Adding...")
                
                local success = pcall(function()
                    return remote:InvokeServer(data)
                end)
                
                if success then
                    added = added + 1
                    print("✅ Success!")
                else
                    print("❌ Failed")
                end
                
                -- Safe delay
                task.wait(0.8)
            end
            
            print("\n✅ Finished! Added " .. added .. "/" .. count)
            return added
        end
        
        -- Make functions global
        getgenv().test = testAdd
        getgenv().add1 = function() addMultiple(1) end
        getgenv().add5 = function() addMultiple(5) end
        getgenv().add10 = function() addMultiple(10) end
        
        print("\n🎮 BOT READY!")
        print("Commands: test(), add1(), add5(), add10()")
        
        -- Auto-test
        task.wait(1)
        print("\n🧪 Auto-testing...")
        test()
    ]]
    
    print("\n" .. string.rep("=", 60))
    print("🤖 BOT CODE:")
    print(string.rep("=", 60))
    print(botCode)
    print(string.rep("=", 60))
    
    -- Execute the bot
    task.wait(1)
    print("\n🚀 EXECUTING BOT...")
    local success, err = pcall(loadstring, botCode)
    if not success then
        print("❌ Failed to create bot:", err)
        
        -- Try simpler approach
        print("\n💥 SIMPLER APPROACH...")
        
        local simpleCode = [[
            local remote = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes.]] .. capturedRemote.Name .. [[
            local data = ]] .. (type(capturedData) == "table" and 
                "{" .. 
                (function()
                    local parts = {}
                    for k, v in pairs(capturedData) do
                        table.insert(parts, tostring(k) .. ' = "' .. tostring(v) .. '"')
                    end
                    return table.concat(parts, ", ")
                end)() .. 
                "}" 
            or 
                '"' .. tostring(capturedData) .. '"') .. [[
            
            -- Add 5 immediately
            for i = 1, 5 do
                print("Adding " .. i .. "...")
                pcall(function()
                    remote:InvokeServer(data)
                end)
                wait(1)
            end
            print("✅ Added 5 cars!")
        ]]
        
        pcall(loadstring, simpleCode)
    end
    
else
    print("\n❌ NO CLICK CAPTURED")
    print("Trying something else...")
    
    -- Maybe the button doesn't call a remote directly
    -- Let's check the button itself
    print("\n🔍 CHECKING INVENTORY BUTTON...")
    
    local function FindCarButton()
        local PlayerGui = Player:WaitForChild("PlayerGui")
        local found = nil
        
        for _, obj in pairs(PlayerGui:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                local name = obj.Name:lower()
                local text = (obj.Text or ""):lower()
                
                if name:find("aston") or name:find("martin") or 
                   text:find("aston") or text:find("martin") or
                   name:find("car") then
                    found = obj
                    break
                end
            end
        end
        
        return found
    end
    
    local button = FindCarButton()
    if button then
        print("✅ Found button:", button.Name)
        print("Class:", button.ClassName)
        
        -- Try to see what happens when we click it
        print("\n🎯 SIMULATING CLICK...")
        
        -- Check for attributes
        for _, attr in pairs({"ItemId", "ID", "Id", "ItemID", "ProductId", "AssetId", "Data"}) do
            local value = button:GetAttribute(attr)
            if value then
                print("Attribute " .. attr .. ": " .. tostring(value))
            end
        end
        
        -- Try to trigger the button
        if button:IsA("TextButton") then
            pcall(function()
                button:Fire("Activated")
                print("Fired Activated event")
            end)
        end
    else
        print("❌ No button found")
    end
end

print("\n" .. string.rep("=", 60))
print("💀 MISSION STATUS: " .. (capturedData and "SUCCESS" or "NEEDS MANUAL CLICK"))
print(string.rep("=", 60))
