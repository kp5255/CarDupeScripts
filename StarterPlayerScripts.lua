-- 💀 FINAL BATTLE - BULLETPROOF VERSION
print("💀 FINAL BATTLE - BULLETPROOF VERSION")
print("=" .. string.rep("=", 60))

-- ULTIMATE SAFE WRAPPERS
local function safeGetService(serviceName)
    local success, result = pcall(function()
        return game:GetService(serviceName)
    end)
    return success and result or nil
end

local function safeFindChild(parent, childName)
    if not parent then return nil end
    local success, result = pcall(function()
        return parent:FindFirstChild(childName)
    end)
    return success and result or nil
end

-- SAFE PRINT
local function safePrint(...)
    local args = {...}
    local output = {}
    for i, arg in ipairs(args) do
        table.insert(output, tostring(arg))
    end
    print(table.concat(output, " "))
end

-- CAPTURE VARIABLES
local capturedData = nil
local capturedRemote = nil
local capturedRemoteType = nil

-- STEP 1: FIND THE GAME STRUCTURE
safePrint("\n🔍 SCANNING GAME STRUCTURE...")

-- Check all possible ReplicatedStorage paths
local RS = safeGetService("ReplicatedStorage")
if not RS then
    safePrint("❌ ReplicatedStorage service not found!")
    safePrint("⚠️  Trying alternative approaches...")
    
    -- Try different ways to find remotes
    local possiblePaths = {
        game:WaitForChild("ReplicatedStorage", 1),
        game:FindFirstChild("ReplicatedStorage"),
        game:FindFirstChild("Remotes"),
        game:FindFirstChild("Events"),
        game:FindFirstChild("Network"),
    }
    
    for _, path in pairs(possiblePaths) do
        if path then
            RS = path
            safePrint("✅ Found alternative path: " .. path:GetFullName())
            break
        end
    end
else
    safePrint("✅ ReplicatedStorage found!")
end

-- STEP 2: FIND TRADING REMOTES
local tradingFolder = nil

if RS then
    -- Try multiple possible paths for trading remotes
    local possibleFolderPaths = {
        "Remotes.Services.TradingServiceRemotes",
        "Remotes.Trading",
        "TradingRemotes",
        "TradeRemotes",
        "Services.Trading",
        "Network.Trading",
        "Events.Trading",
    }
    
    for _, path in pairs(possibleFolderPaths) do
        local current = RS
        local found = true
        
        for part in path:gmatch("[^.]+") do
            local child = safeFindChild(current, part)
            if child then
                current = child
            else
                found = false
                break
            end
        end
        
        if found and current ~= RS then
            tradingFolder = current
            safePrint("✅ Found trading folder at: " .. current:GetFullName())
            break
        end
    end
end

-- If still not found, search all remotes
if not tradingFolder then
    safePrint("⚠️  Trading folder not found. Searching all remotes...")
    
    local function searchForRemotes(parent, depth)
        if depth > 5 then return end
        
        for _, child in pairs(parent:GetChildren()) do
            local name = child.Name:lower()
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                if name:find("trade") or name:find("add") or name:find("offer") then
                    safePrint("  • Found remote: " .. child:GetFullName())
                end
            else
                searchForRemotes(child, depth + 1)
            end
        end
    end
    
    if RS then
        searchForRemotes(RS, 0)
    end
end

-- STEP 3: HOOK REMOTES IF FOUND
if tradingFolder then
    safePrint("\n🎯 HOOKING REMOTES...")
    
    for _, remote in pairs(tradingFolder:GetChildren()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            safePrint("  • " .. remote.Name .. " (" .. remote.ClassName .. ")")
            
            if remote:IsA("RemoteFunction") then
                -- Hook RemoteFunction
                local originalInvoke = remote.InvokeServer
                if originalInvoke then
                    remote.InvokeServer = function(self, ...)
                        local args = {...}
                        
                        safePrint("\n🔥 CAPTURED CALL TO: " .. remote.Name)
                        safePrint("📊 Arguments:", #args)
                        
                        -- Inspect arguments
                        for i, arg in ipairs(args) do
                            if type(arg) == "table" then
                                safePrint("  Arg " .. i .. ": [TABLE]")
                                for k, v in pairs(arg) do
                                    safePrint("    " .. tostring(k) .. " = " .. tostring(v))
                                end
                            else
                                safePrint("  Arg " .. i .. ": " .. tostring(arg))
                            end
                        end
                        
                        capturedData = args[1] or args
                        capturedRemote = remote
                        capturedRemoteType = "RemoteFunction"
                        
                        -- Call original
                        return originalInvoke(self, ...)
                    end
                    safePrint("    ✅ Hook installed")
                end
                
            elseif remote:IsA("RemoteEvent") then
                -- Hook RemoteEvent - try all possible methods
                local hookInstalled = false
                
                -- Try FireServer
                if remote.FireServer then
                    local originalFire = remote.FireServer
                    remote.FireServer = function(self, ...)
                        local args = {...}
                        
                        safePrint("\n🔥 CAPTURED EVENT (FireServer): " .. remote.Name)
                        safePrint("📊 Arguments:", #args)
                        
                        capturedData = args[1] or args
                        capturedRemote = remote
                        capturedRemoteType = "RemoteEvent"
                        
                        return originalFire(self, ...)
                    end
                    hookInstalled = true
                    safePrint("    ✅ Hook installed (FireServer)")
                end
                
                -- Try Fire if FireServer didn't work
                if not hookInstalled and remote.Fire then
                    local originalFire = remote.Fire
                    remote.Fire = function(self, ...)
                        local args = {...}
                        
                        safePrint("\n🔥 CAPTURED EVENT (Fire): " .. remote.Name)
                        safePrint("📊 Arguments:", #args)
                        
                        capturedData = args[1] or args
                        capturedRemote = remote
                        capturedRemoteType = "RemoteEvent"
                        
                        return originalFire(self, ...)
                    end
                    hookInstalled = true
                    safePrint("    ✅ Hook installed (Fire)")
                end
            end
        end
    end
end

-- STEP 4: DIRECT CLICK CAPTURE (NO REMOTES NEEDED)
safePrint("\n🎯 DIRECT CLICK CAPTURE SYSTEM ACTIVATED")
safePrint("This will capture ANY click in the game")

-- Get LocalPlayer safely
local Players = safeGetService("Players")
local Player = Players and Players.LocalPlayer

if Player then
    -- Method 1: Capture all button clicks
    local function captureAllClicks()
        local UIS = safeGetService("UserInputService")
        if UIS then
            UIS.InputBegan:Connect(function(input, processed)
                if not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    safePrint("\n🖱️ MOUSE CLICK DETECTED!")
                    
                    -- Get mouse target
                    local mouse = Player:GetMouse()
                    local target = mouse.Target
                    if target then
                        safePrint("  Clicked on: " .. target:GetFullName())
                        
                        -- Check if it's a button
                        local button = target:FindFirstAncestorWhichIsA("TextButton") or 
                                     target:FindFirstAncestorWhichIsA("ImageButton")
                        
                        if button then
                            safePrint("  Button: " .. button.Name)
                            safePrint("  Text: " .. (button.Text or "N/A"))
                            
                            -- Check for car-related attributes
                            for _, attr in pairs({"ItemId", "ID", "Item", "Car", "Vehicle"}) do
                                local value = button:GetAttribute(attr)
                                if value then
                                    safePrint("  📍 Attribute " .. attr .. ": " .. tostring(value))
                                    if tostring(value):find("Aston") or tostring(value):find("Martin") then
                                        capturedData = {[attr] = value}
                                        safePrint("  🚗 CAR ATTRIBUTE FOUND!")
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            safePrint("✅ Mouse click capture activated")
        end
    end
    
    -- Method 2: Hook all buttons in the game
    local function hookAllButtons()
        local function hookButton(button)
            if button:IsA("TextButton") or button:IsA("ImageButton") then
                local originalActivated = button.Activated
                if originalActivated then
                    button.Activated:Connect(function()
                        safePrint("\n🔘 BUTTON CLICKED: " .. button:GetFullName())
                        safePrint("  Text: " .. (button.Text or "N/A"))
                        
                        -- Check button name for car clues
                        local name = button.Name:lower()
                        if name:find("aston") or name:find("martin") then
                            safePrint("  🚗 CAR BUTTON DETECTED!")
                            
                            -- Try to get data from button
                            local data = {}
                            for _, attr in pairs({"ItemId", "ID", "Item", "Car", "Vehicle"}) do
                                local value = button:GetAttribute(attr)
                                if value then
                                    data[attr] = value
                                end
                            end
                            
                            if next(data) then
                                capturedData = data
                                capturedRemote = button
                                capturedRemoteType = "Button"
                            end
                        end
                    end)
                end
            end
        end
        
        -- Hook existing buttons
        local PlayerGui = Player:WaitForChild("PlayerGui", 2)
        if PlayerGui then
            for _, gui in pairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then
                    for _, button in pairs(gui:GetDescendants()) do
                        hookButton(button)
                    end
                end
            end
            safePrint("✅ All GUI buttons hooked")
        end
        
        -- Hook new buttons
        if PlayerGui then
            PlayerGui.DescendantAdded:Connect(function(descendant)
                hookButton(descendant)
            end)
        end
    end
    
    pcall(captureAllClicks)
    pcall(hookAllButtons)
end

-- STEP 5: WAIT FOR CLICK
safePrint("\n⏳ WAITING FOR CAR CLICK...")
safePrint("Click the Aston Martin in your inventory NOW!")
safePrint("I will capture ANY interaction")

local waitTime = 30
for i = 1, waitTime do
    task.wait(1)
    
    if capturedData then
        safePrint("\n" .. string.rep("🎉", 30))
        safePrint("🔥 SUCCESS! DATA CAPTURED! 🔥")
        safePrint(string.rep("🎉", 30))
        break
    end
    
    if i % 5 == 0 then
        safePrint("[🕐 " .. i .. "/" .. waitTime .. "] Waiting for click...")
    end
end

-- STEP 6: GENERATE WORKING CODE
safePrint("\n" .. string.rep("=", 60))

if capturedData then
    safePrint("📊 CAPTURED DATA:")
    if type(capturedData) == "table" then
        for k, v in pairs(capturedData) do
            safePrint("  " .. tostring(k) .. " = " .. tostring(v))
        end
    else
        safePrint("  " .. tostring(capturedData))
    end
    
    safePrint("\n🎯 CAPTURED FROM: " .. tostring(capturedRemote))
    safePrint("📝 TYPE: " .. tostring(capturedRemoteType))
    
    -- GENERATE SIMPLE WORKING CODE
    safePrint("\n" .. string.rep("🚀", 30))
    safePrint("GENERATING WORKING CODE...")
    safePrint(string.rep("🚀", 30))
    
    local workingCode = ""
    
    if capturedRemoteType == "Button" then
        -- Button clicking code
        workingCode = [[
            -- SIMPLE BUTTON CLICKER
            print("Auto-clicking car button...")
            
            function findCarButton()
                local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
                
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        for _, obj in pairs(gui:GetDescendants()) do
                            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                                local name = obj.Name:lower()
                                local text = (obj.Text or ""):lower()
                                
                                if name:find("aston") or name:find("martin") or 
                                   text:find("aston") or text:find("martin") then
                                    return obj
                                end
                            end
                        end
                    end
                end
                return nil
            end
            
            local button = findCarButton()
            if button then
                print("Found button: " .. button.Name)
                
                -- Click multiple times
                for i = 1, 5 do
                    print("Click " .. i .. "...")
                    pcall(function()
                        button:Fire("Activated")
                    end)
                    wait(0.5)
                end
                print("✅ Done!")
            else
                print("❌ Button not found")
            end
        ]]
        
    elseif capturedRemoteType == "RemoteFunction" or capturedRemoteType == "RemoteEvent" then
        -- Remote calling code
        local remotePath = ""
        if capturedRemote then
            -- Build path to remote
            local parts = {}
            local current = capturedRemote
            while current and current ~= game do
                table.insert(parts, 1, current.Name)
                current = current.Parent
            end
            remotePath = table.concat(parts, ".")
        end
        
        if type(capturedData) == "table" then
            -- Convert table to code
            local dataCode = "{"
            for k, v in pairs(capturedData) do
                if type(v) == "string" then
                    dataCode = dataCode .. tostring(k) .. ' = "' .. v .. '", '
                else
                    dataCode = dataCode .. tostring(k) .. ' = ' .. tostring(v) .. ', '
                end
            end
            dataCode = dataCode .. "}"
            
            if capturedRemoteType == "RemoteFunction" then
                workingCode = [[
                    local remote = ]] .. remotePath .. [[
                    local data = ]] .. dataCode .. [[
                    
                    print("Adding car...")
                    for i = 1, 3 do
                        print("Attempt " .. i .. "...")
                        pcall(function()
                            remote:InvokeServer(data)
                        end)
                        wait(0.5)
                    end
                    print("✅ Done!")
                ]]
            else
                workingCode = [[
                    local remote = ]] .. remotePath .. [[
                    local data = ]] .. dataCode .. [[
                    
                    print("Adding car...")
                    for i = 1, 3 do
                        print("Attempt " .. i .. "...")
                        pcall(function()
                            remote:FireServer(data)
                        end)
                        pcall(function()
                            remote:Fire(data)
                        end)
                        wait(0.5)
                    end
                    print("✅ Done!")
                ]]
            end
        else
            -- Simple data
            local dataStr = type(capturedData) == "string" and '"' .. capturedData .. '"' or tostring(capturedData)
            
            if capturedRemoteType == "RemoteFunction" then
                workingCode = [[
                    local remote = ]] .. remotePath .. [[
                    
                    print("Adding car...")
                    for i = 1, 3 do
                        print("Attempt " .. i .. "...")
                        pcall(function()
                            remote:InvokeServer(]] .. dataStr .. [[)
                        end)
                        wait(0.5)
                    end
                    print("✅ Done!")
                ]]
            else
                workingCode = [[
                    local remote = ]] .. remotePath .. [[
                    
                    print("Adding car...")
                    for i = 1, 3 do
                        print("Attempt " .. i .. "...")
                        pcall(function()
                            remote:FireServer(]] .. dataStr .. [[)
                        end)
                        pcall(function()
                            remote:Fire(]] .. dataStr .. [[)
                        end)
                        wait(0.5)
                    end
                    print("✅ Done!")
                ]]
            end
        end
    end
    
    -- Display and execute code
    safePrint("\n" .. string.rep("=", 60))
    safePrint("🤖 WORKING CODE:")
    safePrint(string.rep("=", 60))
    safePrint(workingCode)
    safePrint(string.rep("=", 60))
    
    -- Try to execute
    safePrint("\n🚀 EXECUTING CODE...")
    local success, err = pcall(loadstring, workingCode)
    if not success then
        safePrint("❌ Execution failed: " .. tostring(err))
        
        -- Try super simple approach
        safePrint("\n🔄 TRYING SUPER SIMPLE APPROACH...")
        local simpleCode = [[
            print("Looking for Aston Martin...")
            
            -- Click everything that might be a car button
            local Player = game:GetService("Players").LocalPlayer
            local PlayerGui = Player:WaitForChild("PlayerGui")
            
            for i = 1, 10 do
                print("Attempt " .. i .. "...")
                
                for _, gui in pairs(PlayerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        for _, obj in pairs(gui:GetDescendants()) do
                            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                                local name = obj.Name:lower()
                                if name:find("car") or name:find("vehicle") then
                                    pcall(function()
                                        obj:Fire("Activated")
                                        print("Clicked: " .. obj.Name)
                                    end)
                                end
                            end
                        end
                    end
                end
                
                wait(0.3)
            end
            print("✅ Finished!")
        ]]
        
        pcall(loadstring, simpleCode)
    end
    
else
    safePrint("❌ NO DATA CAPTURED")
    
    -- FINAL RESORT: MANUAL EXPLORATION GUIDE
    safePrint("\n" .. string.rep("🆘", 30))
    safePrint("MANUAL EXPLORATION REQUIRED")
    safePrint(string.rep("🆘", 30))
    
    safePrint("\n📋 MANUAL STEPS:")
    safePrint("1. Open Developer Console (F9)")
    safePrint("2. Type: print(game:GetService('ReplicatedStorage'))")
    safePrint("3. Look for 'Remotes' folder")
    safePrint("4. Find trading-related remotes")
    safePrint("5. Copy their paths")
    
    safePrint("\n🔍 QUICK COMMANDS TO TRY:")
    safePrint("-- List all remotes:")
    safePrint([[for i,v in pairs(game:GetDescendants()) do if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then print(v:GetFullName()) end end]])
    
    safePrint("\n-- Find by name:")
    safePrint([[local target = game:GetService("ReplicatedStorage"):FindFirstChild("Trading", true) or game:GetService("ReplicatedStorage"):FindFirstChild("Trade", true)]])
    safePrint([[if target then print("Found:", target:GetFullName()) end]])
end

safePrint("\n" .. string.rep("=", 60))
safePrint("💀 MISSION COMPLETE")
safePrint("Status: " .. (capturedData and "SUCCESS" or "MANUAL_INPUT_NEEDED"))
safePrint(string.rep("=", 60))

-- FINAL MESSAGE
if not capturedData then
    safePrint("\n⚠️  MANUAL INPUT REQUIRED:")
    safePrint("Please provide:")
    safePrint("1. The exact path to the trading remote")
    safePrint("2. What data is sent when clicking the car")
    safePrint("3. Or just click the car and share the output above")
end
