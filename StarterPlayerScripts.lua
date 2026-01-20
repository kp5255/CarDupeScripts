-- 💀 FINAL BATTLE - GOD MODE VERSION
print("💀 FINAL BATTLE - GOD MODE ACTIVATED")
print("=" .. string.rep("=", 60))

-- SUPER SAFE WRAPPERS
local function superCall(func, ...)
    local success, result = pcall(func, ...)
    return success, result
end

local function getMethodNames(obj)
    local methods = {}
    if obj and typeof(obj) == "Instance" then
        local mt = getrawmetatable(obj)
        if mt and mt.__index then
            if type(mt.__index) == "function" then
                -- Try to get methods via __index
                for _, name in pairs({"InvokeServer", "FireServer", "Fire", "Invoke", "CallServer"}) do
                    local success, result = pcall(function()
                        return mt.__index(obj, name)
                    end)
                    if success and type(result) == "function" then
                        table.insert(methods, name)
                    end
                end
            elseif type(mt.__index) == "table" then
                -- Check table for methods
                for name, value in pairs(mt.__index) do
                    if type(value) == "function" and (name:find("Fire") or name:find("Invoke") or name:find("Call")) then
                        table.insert(methods, name)
                    end
                end
            end
        end
        
        -- Also try direct check
        for _, name in pairs({"InvokeServer", "FireServer", "Fire", "Invoke", "CallServer"}) do
            local value = obj[name]
            if type(value) == "function" then
                table.insert(methods, name)
            end
        end
    end
    return methods
end

-- CAPTURE SYSTEM
local capturedData = nil
local capturedRemote = nil
local capturedMethod = nil
local capturedArgs = {}

-- STEP 1: DIRECT METHOD INTERCEPTION
print("\n🎯 ULTIMATE INTERCEPTION SYSTEM")

-- Get trading folder
local tradingFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes", true)
    and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Services", true)
    and game:GetService("ReplicatedStorage").Remotes.Services:FindFirstChild("TradingServiceRemotes", true)

if tradingFolder then
    print("✅ Trading folder found: " .. tradingFolder:GetFullName())
    
    -- List all remotes
    print("\n📋 Available remotes:")
    for _, remote in pairs(tradingFolder:GetChildren()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            print("  • " .. remote.Name .. " (" .. remote.ClassName .. ")")
            
            -- Get available methods
            local methods = getMethodNames(remote)
            if #methods > 0 then
                print("    Available methods: " .. table.concat(methods, ", "))
            else
                print("    ⚠️ No standard methods found!")
            end
        end
    end
    
    -- INTERCEPT ALL REMOTES USING METATABLE
    print("\n⚡ INTERCEPTING ALL COMMUNICATION...")
    
    for _, remote in pairs(tradingFolder:GetChildren()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            -- Get the metatable
            local success, mt = pcall(getrawmetatable, remote)
            if success and mt then
                -- Save original __index
                local originalIndex = mt.__index
                
                -- Override __index to intercept calls
                mt.__index = function(self, key)
                    -- First get the original method
                    local method = originalIndex(self, key)
                    
                    -- If it's a callable method, wrap it
                    if type(method) == "function" and 
                       (key == "InvokeServer" or key == "FireServer" or key == "Fire" or key == "Invoke") then
                        
                        return function(...)
                            local args = {...}
                            
                            print("\n" .. string.rep("🔥", 40))
                            print("⚡ INTERCEPTED CALL!")
                            print("Remote: " .. remote:GetFullName())
                            print("Method: " .. key)
                            print("Args: " .. #args)
                            
                            -- Deep inspect arguments
                            for i, arg in ipairs(args) do
                                print("\n  [Argument " .. i .. "]")
                                if type(arg) == "table" then
                                    print("  Type: Table")
                                    print("  Contents:")
                                    for k, v in pairs(arg) do
                                        print("    " .. tostring(k) .. " = " .. tostring(v))
                                        
                                        -- Check for car data
                                        if type(v) == "string" and (v:find("Aston") or v:find("Martin") or v:find("aston") or v:find("martin")) then
                                            print("    🚗 CAR DATA DETECTED!")
                                            capturedData = arg
                                            capturedRemote = remote
                                            capturedMethod = key
                                            capturedArgs = args
                                        end
                                    end
                                elseif type(arg) == "string" then
                                    print("  Type: String")
                                    print("  Value: \"" .. arg .. "\"")
                                    if arg:find("Aston") or arg:find("Martin") or arg:find("aston") or arg:find("martin") then
                                        print("    🚗 CAR STRING DETECTED!")
                                        capturedData = arg
                                        capturedRemote = remote
                                        capturedMethod = key
                                        capturedArgs = args
                                    end
                                else
                                    print("  Type: " .. type(arg))
                                    print("  Value: " .. tostring(arg))
                                end
                            end
                            
                            print(string.rep("🔥", 40) .. "\n")
                            
                            -- Call original method
                            return method(...)
                        end
                    end
                    
                    return method
                end
                
                print("✅ Intercepted: " .. remote.Name)
            end
        end
    end
end

-- STEP 2: UNIVERSAL NETWORK INTERCEPTOR
print("\n🌐 ACTIVATING UNIVERSAL NETWORK INTERCEPTOR")

-- This intercepts ALL network traffic
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Check if this is a remote call
    if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) and 
       (method == "InvokeServer" or method == "FireServer" or method == "Fire") then
        
        -- Check if it's from trading folder
        local isTradingRemote = false
        local current = self
        while current do
            if current.Name == "TradingServiceRemotes" then
                isTradingRemote = true
                break
            end
            current = current.Parent
        end
        
        if isTradingRemote then
            print("\n" .. string.rep("📡", 40))
            print("🌐 NETWORK INTERCEPT!")
            print("Remote: " .. self:GetFullName())
            print("Method: " .. method)
            
            -- Analyze arguments
            for i, arg in ipairs(args) do
                print("\n  Arg " .. i .. ":")
                
                -- Deep search for car data
                local function deepSearch(val, path)
                    path = path or "root"
                    
                    if type(val) == "table" then
                        for k, v in pairs(val) do
                            local newPath = path .. "." .. tostring(k)
                            deepSearch(v, newPath)
                        end
                    elseif type(val) == "string" then
                        print("    " .. path .. " = \"" .. val .. "\"")
                        
                        -- Check for car mentions
                        local lowerVal = val:lower()
                        if lowerVal:find("aston") or lowerVal:find("martin") or 
                           lowerVal:find("vehicle") or lowerVal:find("car") then
                            print("      🚗 CAR IDENTIFIED IN STRING!")
                            if not capturedData then
                                capturedData = args[1] or args
                                capturedRemote = self
                                capturedMethod = method
                                capturedArgs = args
                            end
                        end
                    elseif type(val) == "number" then
                        -- Could be an item ID
                        if tostring(val):find("12") or (val > 1000 and val < 99999) then
                            print("    " .. path .. " = " .. val .. " (Possible Item ID)")
                        end
                    end
                end
                
                deepSearch(arg, "arg" .. i)
            end
            
            print(string.rep("📡", 40))
        end
    end
    
    return oldNamecall(self, ...)
end)

print("✅ Universal network interceptor activated!")

-- STEP 3: UI ELEMENT INTERCEPTOR
print("\n🖱️ ACTIVATING UI INTERCEPTOR")

-- Hook all button clicks
local function hookAllUI()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local PlayerGui = player:WaitForChild("PlayerGui", 2)
    
    if PlayerGui then
        -- Hook existing buttons
        local function hookButton(button)
            if button:IsA("TextButton") or button:IsA("ImageButton") then
                local connection
                connection = button.Activated:Connect(function()
                    print("\n🖱️ BUTTON CLICKED: " .. button:GetFullName())
                    
                    -- Check button properties
                    print("  Name: " .. button.Name)
                    print("  Text: " .. (button.Text or "N/A"))
                    
                    -- Check attributes for car data
                    for _, attr in pairs({"ItemId", "ID", "Item", "Car", "Vehicle", "AssetId", "ProductId"}) do
                        local value = button:GetAttribute(attr)
                        if value then
                            print("  📍 " .. attr .. ": " .. tostring(value))
                            
                            if tostring(value):find("Aston") or tostring(value):find("Martin") or 
                               tostring(value):find("aston") or tostring(value):find("martin") then
                                print("    🚗 CAR ATTRIBUTE FOUND!")
                                capturedData = {[attr] = value}
                                capturedRemote = button
                                capturedMethod = "Activated"
                            end
                        end
                    end
                end)
            end
        end
        
        -- Hook all existing buttons
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, button in pairs(gui:GetDescendants()) do
                    hookButton(button)
                end
            end
        end
        
        -- Hook new buttons
        PlayerGui.DescendantAdded:Connect(function(descendant)
            hookButton(descendant)
        end)
        
        print("✅ UI interceptor activated!")
    end
end

pcall(hookAllUI)

-- STEP 4: WAIT FOR ACTION
print("\n" .. string.rep("⏳", 40))
print("WAITING FOR CAR CLICK...")
print("Click the Aston Martin in your inventory!")
print(string.rep("⏳", 40))

local waited = 0
local maxWait = 45

while waited < maxWait and not capturedData do
    task.wait(1)
    waited = waited + 1
    
    if waited % 5 == 0 then
        print("[🕐 " .. waited .. "/" .. maxWait .. "] Still waiting...")
        
        -- Try to find car button automatically
        if waited == 10 or waited == 25 then
            print("\n🔍 Auto-scanning for car button...")
            pcall(function()
                local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled then
                        for _, button in pairs(gui:GetDescendants()) do
                            if button:IsA("TextButton") or button:IsA("ImageButton") then
                                local name = button.Name:lower()
                                local text = (button.Text or ""):lower()
                                
                                if name:find("aston") or name:find("martin") or 
                                   text:find("aston") or text:find("martin") then
                                    print("  🎯 Found potential car button: " .. button.Name)
                                    
                                    -- Try to click it
                                    pcall(function()
                                        button:Fire("Activated")
                                        print("  ✅ Simulated click!")
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end

-- STEP 5: RESULTS AND CODE GENERATION
print("\n" .. string.rep("=", 60))

if capturedData then
    print("🎉 SUCCESS! DATA CAPTURED!")
    print(string.rep("🎉", 30))
    
    print("\n📊 CAPTURE DETAILS:")
    print("Source: " .. capturedRemote:GetFullName())
    print("Method: " .. tostring(capturedMethod))
    print("Data type: " .. type(capturedData))
    
    -- Display captured data
    if type(capturedData) == "table" then
        print("\n📦 CAPTURED TABLE:")
        for k, v in pairs(capturedData) do
            print("  " .. tostring(k) .. " = " .. tostring(v))
        end
    else
        print("\n📄 CAPTURED DATA: " .. tostring(capturedData))
    end
    
    -- Display all arguments
    if #capturedArgs > 0 then
        print("\n🎯 ALL ARGUMENTS:")
        for i, arg in ipairs(capturedArgs) do
            print("  Arg " .. i .. ": " .. tostring(arg))
        end
    end
    
    -- GENERATE GOD MODE BOT
    print("\n" .. string.rep("🤖", 30))
    print("CREATING GOD MODE BOT...")
    print(string.rep("🤖", 30))
    
    local botCode = ""
    
    if capturedRemote:IsA("RemoteEvent") or capturedRemote:IsA("RemoteFunction") then
        -- Remote-based bot
        local remotePath = capturedRemote:GetFullName()
        local dataStr = ""
        
        if type(capturedData) == "table" then
            -- Convert table to code
            local parts = {}
            for k, v in pairs(capturedData) do
                if type(v) == "string" then
                    table.insert(parts, tostring(k) .. ' = "' .. v .. '"')
                else
                    table.insert(parts, tostring(k) .. ' = ' .. tostring(v))
                end
            end
            dataStr = "{" .. table.concat(parts, ", ") .. "}"
        else
            dataStr = type(capturedData) == "string" and '"' .. capturedData .. '"' or tostring(capturedData)
        end
        
        botCode = [[
            -- 🤖 GOD MODE TRADE BOT
            print("GOD MODE BOT ACTIVATED")
            
            local remote = ]] .. remotePath .. [[
            local data = ]] .. dataStr .. [[
            
            print("Using remote: " .. remote.Name)
            print("Data: ", data)
            
            -- Try all possible calling methods
            function callRemote()
                local methods = {"InvokeServer", "FireServer", "Fire", "Invoke"}
                
                for _, method in pairs(methods) do
                    local func = remote[method]
                    if type(func) == "function" then
                        print("Trying method: " .. method)
                        
                        local success, result = pcall(function()
                            return func(remote, data)
                        end)
                        
                        if success then
                            print("✅ Success with " .. method .. "!")
                            if result then
                                print("Result: " .. tostring(result))
                            end
                            return true
                        else
                            print("❌ Failed: " .. tostring(result))
                        end
                    end
                end
                return false
            end
            
            -- Bulk add function
            function addMultiple(times, delay)
                delay = delay or 0.3
                print("Adding " .. times .. " cars...")
                
                local added = 0
                for i = 1, times do
                    print("[" .. i .. "/" .. times .. "]")
                    
                    if callRemote() then
                        added = added + 1
                    end
                    
                    task.wait(delay)
                end
                
                print("✅ Added " .. added .. "/" .. times .. " cars!")
                return added
            end
            
            -- Export functions
            getgenv().GodBot = {
                test = function() return callRemote() end,
                add1 = function() addMultiple(1) end,
                add5 = function() addMultiple(5) end,
                add10 = function() addMultiple(10) end,
                add = function(count, delay) addMultiple(count or 1, delay or 0.3) end
            }
            
            print("\n🎮 BOT READY!")
            print("Commands: GodBot.test(), GodBot.add1(), GodBot.add5(), GodBot.add10()")
            print("Or: GodBot.add(20, 0.2) for custom")
            
            -- Auto-test
            task.wait(1)
            print("\n🧪 Auto-testing...")
            GodBot.test()
        ]]
    else
        -- Button-based bot
        botCode = [[
            -- 🖱️ BUTTON CLICKER BOT
            print("BUTTON BOT ACTIVATED")
            
            function findAndClickCar()
                local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                local buttons = {}
                
                -- Find all car buttons
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        for _, obj in pairs(gui:GetDescendants()) do
                            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                                local name = obj.Name:lower()
                                local text = (obj.Text or ""):lower()
                                
                                if name:find("aston") or name:find("martin") or 
                                   name:find("car") or name:find("vehicle") or
                                   text:find("aston") or text:find("martin") then
                                    table.insert(buttons, obj)
                                end
                            end
                        end
                    end
                end
                
                return buttons
            end
            
            -- Click function
            function clickButtons(times, delay)
                delay = delay or 0.4
                local buttons = findAndClickCar()
                
                if #buttons == 0 then
                    print("❌ No car buttons found!")
                    return 0
                end
                
                print("Found " .. #buttons .. " buttons")
                
                local clicked = 0
                for i = 1, times do
                    for _, button in pairs(buttons) do
                        pcall(function()
                            button:Fire("Activated")
                            clicked = clicked + 1
                            print("✅ Clicked: " .. button.Name)
                        end)
                        task.wait(delay / #buttons)
                    end
                end
                
                print("🎯 Total clicks: " .. clicked)
                return clicked
            end
            
            -- Export
            getgenv().ClickBot = {
                click1 = function() clickButtons(1) end,
                click5 = function() clickButtons(5) end,
                click10 = function() clickButtons(10) end
            }
            
            -- Auto-click 3 times
            task.wait(1)
            clickButtons(3, 0.3)
        ]]
    end
    
    -- Display and execute
    print("\n" .. string.rep("=", 60))
    print("🤖 BOT CODE GENERATED")
    print(string.rep("=", 60))
    print(botCode)
    print(string.rep("=", 60))
    
    print("\n🚀 EXECUTING BOT...")
    local success, err = pcall(loadstring, botCode)
    if not success then
        print("❌ Bot execution failed: " .. tostring(err))
        
        -- Fallback to simple execution
        print("\n🔄 FALLBACK: Simple execution...")
        if capturedRemote:IsA("RemoteEvent") or capturedRemote:IsA("RemoteFunction") then
            local simple = "local r = " .. capturedRemote:GetFullName() .. 
                         " for i=1,5 do pcall(function() r:InvokeServer(" .. 
                         (type(capturedData) == "string" and '"' .. capturedData .. '"' or 
                          type(capturedData) == "table" and "{}" or tostring(capturedData)) .. 
                         ") end) wait(0.5) end print('✅ Done!')"
            pcall(loadstring, simple)
        end
    end
    
else
    print("❌ NO DATA CAPTURED")
    
    -- FINAL RESORT: BRUTE FORCE
    print("\n" .. string.rep("💥", 30))
    print("ACTIVATING BRUTE FORCE MODE")
    print(string.rep("💥", 30))
    
    local bruteCode = [[
        -- 💥 BRUTE FORCE TRADER
        print("BRUTE FORCE ACTIVATED")
        
        -- Find all trading remotes
        local tradingRemotes = {}
        for _, remote in pairs(game:GetDescendants()) do
            if (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) and 
               (remote.Name:find("Trade") or remote.Name:find("Add") or 
                remote.Name:find("Offer") or remote.Name:find("Item")) then
                table.insert(tradingRemotes, remote)
            end
        end
        
        print("Found " .. #tradingRemotes .. " potential remotes")
        
        -- Test data (Aston Martin)
        local testData = {
            "AstonMartin12",
            "Aston Martin",
            "astonmartin12",
            {ItemId = "AstonMartin12"},
            {ID = "AstonMartin12"},
            {Car = "AstonMartin12"},
            {Vehicle = "AstonMartin12"},
            {Name = "Aston Martin"}
        }
        
        -- Try all combinations
        local attempts = 0
        local maxAttempts = 50
        
        for _, remote in pairs(tradingRemotes) do
            for _, data in pairs(testData) do
                if attempts >= maxAttempts then break end
                
                print("\n🎯 Testing: " .. remote:GetFullName())
                print("Data: " .. tostring(data))
                
                -- Try all calling methods
                local methods = {"InvokeServer", "FireServer", "Fire", "Invoke"}
                for _, method in pairs(methods) do
                    local func = remote[method]
                    if type(func) == "function" then
                        pcall(function()
                            func(remote, data)
                            print("✅ Called with " .. method)
                        end)
                        task.wait(0.1)
                    end
                end
                
                attempts = attempts + 1
                task.wait(0.2)
            end
        end
        
        print("\n🎯 Brute force complete!")
        print("Attempted " .. attempts .. " combinations")
    ]]
    
    print("\n🚀 EXECUTING BRUTE FORCE...")
    pcall(loadstring, bruteCode)
end

print("\n" .. string.rep("=", 60))
print("💀 GOD MODE MISSION COMPLETE")
print(string.rep("=", 60))
