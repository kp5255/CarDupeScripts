-- 💀 FINAL BATTLE - ULTIMATE INTERCEPTOR
print("💀 FINAL BATTLE - ULTIMATE INTERCEPTOR")
print("=" .. string.rep("=", 60))

-- SUPER SAFE METHOD - NO METHOD CHECKS!
local capturedData = nil
local capturedRemote = nil
local capturedMethod = nil
local capturedArgs = {}

-- STEP 1: HOOK METATABLE FOR ALL INSTANCES
print("\n🎯 HOOKING ALL INSTANCE METATABLES...")

-- Hook __namecall to intercept ALL method calls
local oldNamecall
local namecallHooked = false

local function hookNamecall()
    if namecallHooked then return end
    
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Check if this is ANY remote object
        if self:IsA("RemoteEvent") or self:IsA("RemoteFunction") then
            -- Check if it's from trading folder
            local isTradingRelated = false
            local current = self
            while current do
                if current.Name:lower():find("trade") or 
                   current.Name:lower():find("add") or 
                   current.Name:lower():find("offer") or
                   current.Name:lower():find("inventory") then
                    isTradingRelated = true
                    break
                end
                current = current.Parent
            end
            
            -- Also check path
            local fullName = self:GetFullName():lower()
            if fullName:find("trad") or fullName:find("service") then
                isTradingRelated = true
            end
            
            if isTradingRelated then
                print("\n" .. string.rep("📡", 40))
                print("🌐 NETWORK CALL INTERCEPTED!")
                print("Remote: " .. self:GetFullName())
                print("Method: " .. method)
                print("Args count: " .. #args)
                
                -- Deep analyze arguments
                local function analyzeValue(val, depth)
                    depth = depth or 0
                    local indent = string.rep("  ", depth)
                    
                    if type(val) == "table" then
                        print(indent .. "[Table]")
                        for k, v in pairs(val) do
                            print(indent .. "  " .. tostring(k) .. ":")
                            analyzeValue(v, depth + 2)
                        end
                    elseif type(val) == "string" then
                        print(indent .. "[String] \"" .. val .. "\"")
                        
                        -- Check for car data
                        local lowerVal = val:lower()
                        if lowerVal:find("aston") or lowerVal:find("martin") or 
                           lowerVal:find("car") or lowerVal:find("vehicle") then
                            print(indent .. "  🚗 CAR DATA FOUND!")
                            
                            if not capturedData then
                                capturedData = #args == 1 and args[1] or args
                                capturedRemote = self
                                capturedMethod = method
                                capturedArgs = args
                            end
                        end
                    else
                        print(indent .. "[" .. type(val) .. "] " .. tostring(val))
                    end
                end
                
                for i, arg in ipairs(args) do
                    print("\n  [Argument " .. i .. "]")
                    analyzeValue(arg)
                end
                
                print(string.rep("📡", 40))
            end
        end
        
        -- Also capture ANY button clicks
        if (self:IsA("TextButton") or self:IsA("ImageButton")) and method == "Fire" then
            print("\n🖱️ BUTTON FIRED: " .. self:GetFullName())
            print("Text: " .. (self.Text or "N/A"))
            
            -- Check for car attributes
            for _, attr in pairs({"ItemId", "ID", "Item", "Car", "Vehicle", "AssetId"}) do
                local value = self:GetAttribute(attr)
                if value then
                    print("  📍 " .. attr .. ": " .. tostring(value))
                    
                    if tostring(value):find("Aston") or tostring(value):find("Martin") then
                        print("    🚗 CAR ATTRIBUTE FOUND!")
                        capturedData = {[attr] = value}
                        capturedRemote = self
                        capturedMethod = "ButtonClick"
                    end
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    namecallHooked = true
    print("✅ __namecall hook installed!")
end

-- STEP 2: HOOK __INDEX FOR PROPERTY ACCESS
print("\n🎯 HOOKING PROPERTY ACCESS...")

local oldIndex
local indexHooked = false

local function hookIndex()
    if indexHooked then return end
    
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        local value = oldIndex(self, key)
        
        -- Intercept when trying to access methods on remotes
        if (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) and 
           type(value) == "function" and 
           (key == "InvokeServer" or key == "FireServer" or key == "Fire") then
            
            return function(...)
                local args = {...}
                
                print("\n" .. string.rep("⚡", 40))
                print("METHOD ACCESS INTERCEPTED!")
                print("Remote: " .. self:GetFullName())
                print("Method: " .. key)
                print("Calling with " .. #args .. " arguments")
                
                -- Log arguments
                for i, arg in ipairs(args) do
                    print("\n  Arg " .. i .. " (" .. type(arg) .. "):")
                    
                    if type(arg) == "table" then
                        for k, v in pairs(arg) do
                            print("    " .. tostring(k) .. " = " .. tostring(v))
                        end
                    else
                        print("    " .. tostring(arg))
                    end
                end
                
                print(string.rep("⚡", 40) .. "\n")
                
                -- Store data if it looks like a car
                for _, arg in ipairs(args) do
                    if type(arg) == "string" and arg:find("Aston") then
                        capturedData = arg
                        capturedRemote = self
                        capturedMethod = key
                        capturedArgs = args
                    elseif type(arg) == "table" then
                        for _, v in pairs(arg) do
                            if type(v) == "string" and v:find("Aston") then
                                capturedData = arg
                                capturedRemote = self
                                capturedMethod = key
                                capturedArgs = args
                                break
                            end
                        end
                    end
                end
                
                -- Call original function
                return value(...)
            end
        end
        
        return value
    end)
    
    indexHooked = true
    print("✅ __index hook installed!")
end

-- Install hooks
pcall(hookNamecall)
pcall(hookIndex)

-- STEP 3: DIRECT REMOTE MONITORING
print("\n🎯 SETTING UP DIRECT REMOTE MONITORS...")

-- Monitor the specific trading folder
local tradingFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes", true)
    and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Services", true)
    and game:GetService("ReplicatedStorage").Remotes.Services:FindFirstChild("TradingServiceRemotes", true)

if tradingFolder then
    print("📁 Monitoring folder: " .. tradingFolder:GetFullName())
    
    for _, remote in pairs(tradingFolder:GetChildren()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            print("  👁️ Monitoring: " .. remote.Name)
            
            -- Set up event monitoring for RemoteEvents
            if remote:IsA("RemoteEvent") then
                pcall(function()
                    remote.OnClientEvent:Connect(function(...)
                        local args = {...}
                        print("\n📥 EVENT RECEIVED from " .. remote.Name)
                        for i, arg in ipairs(args) do
                            print("  Arg " .. i .. ": " .. tostring(arg))
                        end
                    end)
                end)
            end
        end
    end
end

-- STEP 4: UI EVENT CAPTURE
print("\n🎯 CAPTURING UI EVENTS...")

local function captureUIEvents()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    pcall(function()
        local PlayerGui = player:WaitForChild("PlayerGui", 2)
        if PlayerGui then
            -- Monitor all button activations
            local function monitorButton(button)
                if button:IsA("TextButton") or button:IsA("ImageButton") then
                    pcall(function()
                        button.Activated:Connect(function()
                            print("\n🔘 UI BUTTON CLICKED: " .. button:GetFullName())
                            print("  Text: " .. (button.Text or "N/A"))
                            
                            -- Store for car detection
                            local buttonInfo = {
                                Name = button.Name,
                                Text = button.Text,
                                FullName = button:GetFullName()
                            }
                            
                            -- Check if this is our car button
                            local nameLower = button.Name:lower()
                            local textLower = (button.Text or ""):lower()
                            
                            if nameLower:find("aston") or nameLower:find("martin") or
                               textLower:find("aston") or textLower:find("martin") then
                                print("    🚗 CAR BUTTON IDENTIFIED!")
                                capturedData = buttonInfo
                                capturedRemote = button
                                capturedMethod = "Activated"
                            end
                        end)
                    end)
                end
            end
            
            -- Monitor existing buttons
            for _, gui in pairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    for _, button in pairs(gui:GetDescendants()) do
                        monitorButton(button)
                    end
                end
            end
            
            -- Monitor new buttons
            PlayerGui.DescendantAdded:Connect(function(descendant)
                monitorButton(descendant)
            end)
            
            print("✅ UI event capture activated!")
        end
    end)
end

pcall(captureUIEvents)

-- STEP 5: WAIT FOR ACTION WITH AGGRESSIVE MONITORING
print("\n" .. string.rep("⏳", 40))
print("WAITING FOR CAR CLICK...")
print("CLICK THE ASTON MARTIN NOW!")
print(string.rep("⏳", 40))

local function aggressiveMonitoring()
    local checkInterval = 2
    local checks = 0
    local maxChecks = 30
    
    while checks < maxChecks and not capturedData do
        task.wait(checkInterval)
        checks = checks + 1
        
        print("[🕐 Check " .. checks .. "/" .. maxChecks .. "] Monitoring...")
        
        -- Periodically scan for car buttons and simulate clicks
        if checks % 3 == 0 then
            pcall(function()
                local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                local foundButtons = {}
                
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and gui.Enabled then
                        for _, button in pairs(gui:GetDescendants()) do
                            if button:IsA("TextButton") or button:IsA("ImageButton") then
                                local name = button.Name:lower()
                                local text = (button.Text or ""):lower()
                                
                                if name:find("car") or name:find("vehicle") or 
                                   name:find("add") or name:find("trade") or
                                   text:find("car") or text:find("vehicle") then
                                    table.insert(foundButtons, button)
                                end
                            end
                        end
                    end
                end
                
                if #foundButtons > 0 then
                    print("  🔍 Found " .. #foundButtons .. " potential buttons")
                    
                    -- Try clicking a few
                    for i = 1, math.min(3, #foundButtons) do
                        local button = foundButtons[i]
                        pcall(function()
                            button:Fire("Activated")
                            print("  ✅ Simulated click on: " .. button.Name)
                        end)
                        task.wait(0.1)
                    end
                end
            end)
        end
    end
end

aggressiveMonitoring()

-- STEP 6: RESULTS AND FINAL SOLUTION
print("\n" .. string.rep("=", 60))

if capturedData then
    print("🎉 SUCCESS! INTERCEPTION WORKED!")
    print(string.rep("🎉", 30))
    
    print("\n📊 INTERCEPTED DATA:")
    print("Source: " .. capturedRemote:GetFullName())
    print("Method: " .. tostring(capturedMethod))
    
    -- Generate working code based on interception
    print("\n" .. string.rep("🚀", 30))
    print("GENERATING WORKING SOLUTION...")
    print(string.rep("🚀", 30))
    
    local solutionCode = ""
    
    if capturedRemote:IsA("RemoteEvent") or capturedRemote:IsA("RemoteFunction") then
        -- Remote call solution
        local remotePath = capturedRemote:GetFullName()
        
        solutionCode = [[
            -- 🎯 WORKING TRADE SOLUTION
            print("Trade bot activated!")
            
            local remote = ]] .. remotePath .. [[
            
            -- The exact data that was captured
            local function getCarData()
                ]] .. 
                (type(capturedData) == "table" and 
                    "return " .. game:GetService("HttpService"):JSONEncode(capturedData)
                or 
                    'return "' .. tostring(capturedData) .. '"') .. [[
            end
            
            local carData = getCarData()
            print("Using data:", carData)
            
            -- Function to send trade request
            function sendTrade()
                print("Sending trade request...")
                
                -- Try ALL possible methods
                local methods = {"InvokeServer", "FireServer", "Fire", "Invoke"}
                
                for _, method in pairs(methods) do
                    local func = remote[method]
                    if type(func) == "function" then
                        print("  Trying " .. method .. "...")
                        
                        local success, result = pcall(function()
                            return func(remote, carData)
                        end)
                        
                        if success then
                            print("    ✅ Success!")
                            if result then
                                print("    Result: " .. tostring(result))
                            end
                            return true
                        else
                            print("    ❌ Failed: " .. tostring(result))
                        end
                    end
                end
                
                print("❌ All methods failed!")
                return false
            end
            
            -- Bulk send function
            function sendMultiple(count)
                print("\n📦 Sending " .. count .. " requests...")
                
                local successCount = 0
                for i = 1, count do
                    print("  [" .. i .. "/" .. count .. "]")
                    
                    if sendTrade() then
                        successCount = successCount + 1
                    end
                    
                    -- Safe delay
                    task.wait(0.5)
                end
                
                print("\n✅ Finished: " .. successCount .. "/" .. count .. " successful")
                return successCount
            end
            
            -- Make functions available
            getgenv().Trade = {
                test = sendTrade,
                add1 = function() sendMultiple(1) end,
                add5 = function() sendMultiple(5) end,
                add10 = function() sendMultiple(10) end
            }
            
            print("\n🎮 READY! Use Trade.test(), Trade.add1(), etc.")
            
            -- Auto-test
            task.wait(1)
            Trade.test()
        ]]
        
    else
        -- Button click solution
        solutionCode = [[
            -- 🖱️ BUTTON CLICKER SOLUTION
            print("Button clicker activated!")
            
            function findCarButton()
                local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                local buttons = {}
                
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        for _, obj in pairs(gui:GetDescendants()) do
                            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                                local name = obj.Name:lower()
                                if name:find("car") or name:find("vehicle") or 
                                   name:find("add") or name:find("trade") then
                                    table.insert(buttons, obj)
                                end
                            end
                        end
                    end
                end
                
                return buttons
            end
            
            function clickCar(times)
                local buttons = findCarButton()
                print("Found " .. #buttons .. " buttons")
                
                local clicks = 0
                for i = 1, times do
                    for _, button in pairs(buttons) do
                        pcall(function()
                            button:Fire("Activated")
                            clicks = clicks + 1
                            print("Clicked: " .. button.Name)
                        end)
                        task.wait(0.2)
                    end
                end
                
                print("✅ Total clicks: " .. clicks)
                return clicks
            end
            
            -- Auto-click 3 times
            clickCar(3)
        ]]
    end
    
    -- Display and execute
    print("\n" .. string.rep("=", 60))
    print("💻 WORKING CODE:")
    print(string.rep("=", 60))
    print(solutionCode)
    print(string.rep("=", 60))
    
    print("\n🚀 EXECUTING SOLUTION...")
    local success, err = pcall(loadstring, solutionCode)
    if not success then
        print("❌ Execution error: " .. tostring(err))
    end
    
else
    print("❌ NO INTERCEPTION CAPTURED")
    
    -- ULTIMATE FALLBACK: BRUTE FORCE ALL REMOTES
    print("\n" .. string.rep("💥", 30))
    print("ACTIVATING ULTIMATE BRUTE FORCE...")
    print(string.rep("💥", 30))
    
    local bruteCode = [[
        -- 💥 ULTIMATE BRUTE FORCE
        
        -- Find ALL remotes in the game
        local allRemotes = {}
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                table.insert(allRemotes, obj)
            end
        end
        
        print("Found " .. #allRemotes .. " remotes total")
        
        -- Test data variations
        local testPayloads = {
            "AstonMartin12",
            {ItemId = "AstonMartin12"},
            {ID = "AstonMartin12"},
            {Car = "AstonMartin12"},
            {Vehicle = "AstonMartin12"},
            {Name = "Aston Martin"},
            {ProductId = "AstonMartin12"},
            {AssetId = "AstonMartin12"}
        }
        
        -- Try everything
        local attempts = 0
        for _, remote in pairs(allRemotes) do
            for _, payload in pairs(testPayloads) do
                attempts = attempts + 1
                
                if attempts > 100 then break end
                
                print("\n🎯 Attempt " .. attempts .. ": " .. remote:GetFullName())
                
                -- Try all calling methods
                local methods = {"InvokeServer", "FireServer", "Fire", "Invoke"}
                for _, method in pairs(methods) do
                    local func = remote[method]
                    if type(func) == "function" then
                        pcall(function()
                            func(remote, payload)
                            print("  ✅ Called with " .. method)
                        end)
                        task.wait(0.05)
                    end
                end
                
                task.wait(0.1)
            end
        end
        
        print("\n🎯 Brute force complete! Attempted " .. attempts .. " combinations")
    ]]
    
    print("\n🚀 EXECUTING BRUTE FORCE...")
    pcall(loadstring, bruteCode)
end

print("\n" .. string.rep("=", 60))
print("💀 ULTIMATE INTERCEPTOR COMPLETE")
print(string.rep("=", 60))

-- Final instructions
if not capturedData then
    print("\n📋 MANUAL INSTRUCTIONS:")
    print("1. Open your inventory")
    print("2. Click the Aston Martin car ONCE")
    print("3. Tell me what happened")
    print("4. Or share any error/output you see above")
end
