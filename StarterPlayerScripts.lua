-- 💀 FINAL BATTLE - CLEAN CAPTURE
print("💀 FINAL BATTLE - CLEAN CAPTURE")
print("=" .. string.rep("=", 60))

local capturedData = nil
local capturedRemote = nil
local capturedMethod = nil

-- SIMPLE, SAFE INTERCEPTOR WITHOUT INFINITE LOOPS
print("\n🎯 SETTING UP SIMPLE INTERCEPTOR...")

-- Only hook what we need, once
local originalMethods = {}

-- Get trading folder
local tradingFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    :WaitForChild("Services"):WaitForChild("TradingServiceRemotes")

print("📁 Monitoring: " .. tradingFolder:GetFullName())

-- SIMPLE HOOK FOR EACH REMOTE (NO METATABLE HOOKS)
for _, remote in pairs(tradingFolder:GetChildren()) do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
        print("  👁️ Watching: " .. remote.Name)
        
        -- Check what methods actually exist
        local methodsToHook = {}
        
        -- Test which methods exist without causing errors
        local function methodExists(methodName)
            local success, result = pcall(function()
                return remote[methodName]
            end)
            return success and type(result) == "function"
        end
        
        -- Only hook methods that actually exist
        if remote:IsA("RemoteFunction") then
            if methodExists("InvokeServer") then
                table.insert(methodsToHook, "InvokeServer")
            end
        elseif remote:IsA("RemoteEvent") then
            if methodExists("FireServer") then
                table.insert(methodsToHook, "FireServer")
            end
            if methodExists("Fire") then
                table.insert(methodsToHook, "Fire")
            end
        end
        
        if #methodsToHook > 0 then
            print("    Methods found: " .. table.concat(methodsToHook, ", "))
            
            -- Hook each method safely
            for _, methodName in pairs(methodsToHook) do
                local originalMethod = remote[methodName]
                originalMethods[remote] = originalMethods[remote] or {}
                originalMethods[remote][methodName] = originalMethod
                
                -- Create safe wrapper
                if remote:IsA("RemoteFunction") then
                    remote[methodName] = function(self, ...)
                        local args = {...}
                        
                        print("\n" .. string.rep("📡", 30))
                        print("CAPTURED CALL: " .. remote.Name)
                        print("Method: " .. methodName)
                        
                        -- Quick check for car data
                        for i, arg in ipairs(args) do
                            if type(arg) == "string" and (arg:find("Aston") or arg:find("Martin")) then
                                print("🚗 CAR DATA FOUND: " .. arg)
                                capturedData = arg
                                capturedRemote = remote
                                capturedMethod = methodName
                            elseif type(arg) == "table" then
                                for k, v in pairs(arg) do
                                    if type(v) == "string" and (v:find("Aston") or v:find("Martin")) then
                                        print("🚗 CAR TABLE FOUND!")
                                        capturedData = arg
                                        capturedRemote = remote
                                        capturedMethod = methodName
                                        break
                                    end
                                end
                            end
                        end
                        
                        print(string.rep("📡", 30))
                        
                        -- Call original
                        return originalMethod(self, ...)
                    end
                else
                    remote[methodName] = function(self, ...)
                        local args = {...}
                        
                        print("\n" .. string.rep("📡", 30))
                        print("CAPTURED EVENT: " .. remote.Name)
                        print("Method: " .. methodName)
                        
                        -- Quick check for car data
                        for i, arg in ipairs(args) do
                            if type(arg) == "string" and (arg:find("Aston") or arg:find("Martin")) then
                                print("🚗 CAR DATA FOUND: " .. arg)
                                capturedData = arg
                                capturedRemote = remote
                                capturedMethod = methodName
                            end
                        end
                        
                        print(string.rep("📡", 30))
                        
                        -- Call original
                        return originalMethod(self, ...)
                    end
                end
            end
        else
            print("    ⚠️ No standard methods found")
        end
    end
end

-- SIMPLE BUTTON MONITOR (NO INFINITE HOOKS)
print("\n🖱️ SETTING UP BUTTON MONITOR...")

local function setupButtonMonitor()
    local Player = game:GetService("Players").LocalPlayer
    local PlayerGui = Player:WaitForChild("PlayerGui", 2)
    
    if PlayerGui then
        -- Only hook buttons that look like car buttons
        for _, gui in pairs(PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, button in pairs(gui:GetDescendants()) do
                    if button:IsA("TextButton") or button:IsA("ImageButton") then
                        local name = button.Name:lower()
                        local text = (button.Text or ""):lower()
                        
                        if name:find("car") or name:find("vehicle") or 
                           name:find("add") or name:find("trade") or
                           text:find("car") or text:find("vehicle") then
                            
                            -- Hook this button only once
                            local connection
                            connection = button.Activated:Connect(function()
                                print("\n🔘 BUTTON CLICKED: " .. button.Name)
                                
                                -- Check for car attributes
                                for _, attr in pairs({"ItemId", "ID", "Item"}) do
                                    local value = button:GetAttribute(attr)
                                    if value and tostring(value):find("Aston") then
                                        print("🚗 CAR ATTRIBUTE: " .. value)
                                        capturedData = value
                                        capturedRemote = button
                                        capturedMethod = "Button"
                                        connection:Disconnect() -- Stop monitoring after capture
                                    end
                                end
                            end)
                        end
                    end
                end
            end
        end
    end
end

pcall(setupButtonMonitor)

-- WAIT FOR CLICK
print("\n" .. string.rep("⏳", 30))
print("CLICK THE ASTON MARTIN NOW!")
print("Waiting 20 seconds...")
print(string.rep("⏳", 30))

for i = 1, 20 do
    task.wait(1)
    if capturedData then break end
    if i % 5 == 0 then print("[🕐 " .. i .. "/20] Waiting...") end
end

-- RESULTS
print("\n" .. string.rep("=", 60))

if capturedData then
    print("🎉 SUCCESS! CAPTURED!")
    print(string.rep("🎉", 30))
    
    print("\n📊 CAPTURED:")
    print("Data: " .. tostring(capturedData))
    print("From: " .. capturedRemote:GetFullName())
    print("Method: " .. tostring(capturedMethod))
    
    -- SIMPLE WORKING CODE
    print("\n" .. string.rep("🚀", 30))
    print("GENERATING SIMPLE BOT...")
    print(string.rep("🚀", 30))
    
    local simpleCode = ""
    
    if capturedRemote:IsA("RemoteEvent") or capturedRemote:IsA("RemoteFunction") then
        -- Remote-based bot
        local remotePath = capturedRemote:GetFullName()
        
        simpleCode = [[
            -- SIMPLE TRADE BOT
            local remote = ]] .. remotePath .. [[
            local data = ]] .. 
            (type(capturedData) == "string" and '"' .. capturedData .. '"' or 
             type(capturedData) == "table" and game:GetService("HttpService"):JSONEncode(capturedData) or
             tostring(capturedData)) .. [[
            
            print("Adding car...")
            
            for i = 1, 3 do
                print("Attempt " .. i .. "...")
                
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
            
            print("🎯 Done!")
        ]]
    else
        -- Button-based bot
        simpleCode = [[
            -- SIMPLE BUTTON CLICKER
            function clickCarButton()
                local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        for _, button in pairs(gui:GetDescendants()) do
                            if button:IsA("TextButton") or button:IsA("ImageButton") then
                                local name = button.Name:lower()
                                if name:find("car") or name:find("vehicle") then
                                    return button
                                end
                            end
                        end
                    end
                end
                return nil
            end
            
            local button = clickCarButton()
            if button then
                print("Found button: " .. button.Name)
                
                for i = 1, 5 do
                    print("Click " .. i .. "...")
                    pcall(function()
                        button:Fire("Activated")
                    end)
                    wait(0.3)
                end
                print("✅ Done!")
            else
                print("❌ Button not found")
            end
        ]]
    end
    
    -- Display and execute
    print("\n" .. string.rep("=", 60))
    print("🤖 SIMPLE BOT CODE:")
    print(string.rep("=", 60))
    print(simpleCode)
    print(string.rep("=", 60))
    
    print("\n🚀 EXECUTING...")
    local success, err = pcall(loadstring, simpleCode)
    if not success then
        print("❌ Error: " .. tostring(err))
    end
    
else
    print("❌ NO DATA CAPTURED")
    
    -- MINIMAL FALLBACK
    print("\n🔄 TRYING MINIMAL FALLBACK...")
    
    local fallbackCode = [[
        -- MINIMAL TRADE ATTEMPT
        print("Trying common trading remotes...")
        
        -- Try the known remote
        local remote = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes:FindFirstChild("AddToTrade")
                      or game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes:FindFirstChild("AddItem")
                      or game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes:GetChildren()[1]
        
        if remote then
            print("Using remote: " .. remote.Name)
            
            -- Try different data formats
            local testData = {
                "AstonMartin12",
                {ItemId = "AstonMartin12"},
                {ID = "AstonMartin12"}
            }
            
            for i, data in ipairs(testData) do
                print("\nTrying format " .. i .. "...")
                
                if remote:IsA("RemoteFunction") then
                    pcall(function()
                        remote:InvokeServer(data)
                        print("✅ Called successfully")
                    end)
                else
                    pcall(function()
                        remote:FireServer(data)
                        print("✅ Called successfully")
                    end)
                end
                
                wait(0.5)
            end
        else
            print("❌ No remote found")
        end
        
        print("🎯 Attempts complete")
    ]]
    
    pcall(loadstring, fallbackCode)
end

print("\n" .. string.rep("=", 60))
print("💀 MISSION COMPLETE")
print(string.rep("=", 60))

-- Clean up to prevent lag
print("\n🧹 Cleaning up hooks...")
task.wait(1)

-- Restore original methods to prevent hook overflow
for remote, methods in pairs(originalMethods) do
    for methodName, originalMethod in pairs(methods) do
        remote[methodName] = originalMethod
    end
end

print("✅ Hooks cleaned up")
print("🎯 Script finished - no more lag!")
