-- Trade Click Monitor & Reverse Engineer
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== TRADE CLICK MONITOR ===")

-- First, let's hook ALL RemoteEvents to see what gets called
local hookedRemotes = {}
local capturedCalls = {}

-- Hook a remote to monitor it
local function HookRemote(remote)
    if hookedRemotes[remote] then return end
    
    if remote:IsA("RemoteEvent") then
        local originalFire = remote.FireServer
        remote.FireServer = function(self, ...)
            local args = {...}
            
            -- Record the call
            table.insert(capturedCalls, {
                remote = remote.Name,
                path = remote:GetFullName(),
                args = args,
                timestamp = os.time(),
                player = Player.Name
            })
            
            print("\n🎯 CAPTURED REMOTE CALL!")
            print("Remote: " .. remote.Name)
            print("Path: " .. remote:GetFullName())
            print("Args: " .. #args)
            
            for i, arg in ipairs(args) do
                local argType = type(arg)
                print("  [" .. i .. "] Type: " .. argType)
                
                if argType == "string" then
                    print("     Value: \"" .. arg .. "\"")
                elseif argType == "number" then
                    print("     Value: " .. arg)
                elseif argType == "table" then
                    print("     Table with " .. tostring(#arg) .. " items")
                    for k, v in pairs(arg) do
                        print("       " .. tostring(k) .. " = " .. tostring(v))
                    end
                end
            end
            
            -- Call original
            return originalFire(self, ...)
        end
        
        hookedRemotes[remote] = true
        print("✅ Hooked remote: " .. remote.Name)
    end
end

-- Hook all RemoteEvents in TradingServiceRemotes
local function HookTradeRemotes()
    print("\n🔗 HOOKING TRADE REMOTES...")
    
    local TradingServiceRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
    
    for _, remote in pairs(TradingServiceRemotes:GetChildren()) do
        if remote:IsA("RemoteEvent") then
            HookRemote(remote)
        end
    end
    
    print("📊 Hooked " .. #hookedRemotes .. " remotes")
end

-- Get car button
local function GetCarButton()
    if not Player.PlayerGui then return nil end
    
    local success, button = pcall(function()
        return Player.PlayerGui:WaitForChild("Menu"):WaitForChild("Trading"):WaitForChild("PeerToPeer"):WaitForChild("Main"):WaitForChild("LocalPlayer"):WaitForChild("Content"):WaitForChild("ScrollingFrame")
    end)
    
    if not success then return nil end
    
    for _, item in pairs(button:GetChildren()) do
        if item:IsA("ImageButton") and item.Name:sub(1, 4) == "Car-" then
            return item
        end
    end
    
    return nil
end

-- Monitor what happens when car button is clicked
local function MonitorCarClick()
    print("\n🎬 MONITORING CAR BUTTON CLICK...")
    print("1. I will hook all trade remotes")
    print("2. Click the Car-AstonMartin8 button NORMALLY")
    print("3. I will capture what data gets sent")
    
    -- Hook remotes first
    HookTradeRemotes()
    
    local carButton = GetCarButton()
    if not carButton then
        print("❌ No car button found")
        return
    end
    
    print("\n✅ Ready to monitor!")
    print("Car button: " .. carButton.Name)
    print("\n📋 INSTRUCTIONS:")
    print("1. Click the Car-AstonMartin8 button ONCE")
    print("2. Wait for CAPTURED output")
    print("3. Share what you see")
    
    -- Wait for click
    local initialCalls = #capturedCalls
    
    for i = 1, 30 do
        wait(1)
        if #capturedCalls > initialCalls then
            print("\n🎉 GOT IT! Captured a remote call")
            break
        end
        if i % 5 == 0 then
            print("Still waiting... (" .. i .. "/30 seconds)")
        end
    end
    
    if #capturedCalls == initialCalls then
        print("\n❌ No remote calls captured")
        print("Try clicking the car button")
    end
end

-- Alternative: Try to guess the item ID from the car name
local function GuessItemIdFromName()
    print("\n🔍 GUESSING ITEM ID FROM CAR NAME...")
    
    local carButton = GetCarButton()
    if not carButton then return nil end
    
    local carName = carButton.Name  -- "Car-AstonMartin8"
    
    print("Car button name: " .. carName)
    
    -- Try different ID extraction methods
    local possibleIds = {}
    
    -- Method 1: Extract number from end
    local numberId = carName:match("%d+$")
    if numberId then
        table.insert(possibleIds, {
            type = "number",
            value = tonumber(numberId),
            source = "end of name"
        })
    end
    
    -- Method 2: Try "AstonMartin8" part
    local namePart = carName:match("Car%-(.+)")
    if namePart then
        table.insert(possibleIds, {
            type = "string", 
            value = namePart,
            source = "name without Car-"
        })
    end
    
    -- Method 3: Try lowercase version
    table.insert(possibleIds, {
        type = "string",
        value = carName:lower(),
        source = "lowercase full name"
    })
    
    -- Method 4: Try removing "Car-" prefix
    table.insert(possibleIds, {
        type = "string",
        value = carName:sub(5),  -- Remove "Car-"
        source = "without Car- prefix"
    })
    
    print("\n📋 Possible IDs to test:")
    for i, idInfo in ipairs(possibleIds) do
        print(i .. ". " .. idInfo.source .. ": " .. tostring(idInfo.value) .. " (" .. idInfo.type .. ")")
    end
    
    return possibleIds
end

-- Test the guessed IDs
local function TestGuessedIds()
    print("\n🧪 TESTING GUESSED IDs...")
    
    local possibleIds = GuessItemIdFromName()
    if not possibleIds or #possibleIds == 0 then
        print("❌ No IDs to test")
        return false
    end
    
    local SessionAddItem = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes"):WaitForChild("SessionAddItem")
    
    for i, idInfo in ipairs(possibleIds) do
        print("\n--- Test " .. i .. " ---")
        print("ID: " .. tostring(idInfo.value) .. " (" .. idInfo.source .. ")")
        
        -- Try different session IDs
        local sessionTests = {
            "trade_session",
            "session_1", 
            Player.UserId .. "_trade",
            nil  -- No session ID
        }
        
        for _, sessionId in ipairs(sessionTests) do
            local params = sessionId and {sessionId, idInfo.value} or {idInfo.value}
            
            print("  With session: " .. tostring(sessionId))
            
            local success, result = pcall(function()
                return SessionAddItem:InvokeServer(unpack(params))
            end)
            
            if success then
                print("    ✅ SUCCESS!")
                if result then
                    print("    Result: " .. tostring(result))
                end
                return true
            else
                print("    ❌ Failed: " .. tostring(result))
            end
            
            wait(0.3)
        end
    end
    
    return false
end

-- Look for the actual item database
local function FindCarDatabase()
    print("\n🗄️ SEARCHING FOR CAR DATABASE...")
    
    -- Common places where car data might be stored
    local searchLocations = {
        ReplicatedStorage,
        game:GetService("ServerStorage"),
        game:GetService("ServerScriptService")
    }
    
    local foundCars = {}
    
    for _, location in ipairs(searchLocations) do
        pcall(function()
            for _, item in pairs(location:GetDescendants()) do
                if item:IsA("Folder") then
                    local nameLower = item.Name:lower()
                    
                    -- Look for car-related folders
                    if nameLower:find("car") or 
                       nameLower:find("vehicle") or 
                       nameLower:find("aston") or
                       nameLower:find("martin") then
                        
                        print("🚗 Found car folder: " .. item:GetFullName())
                        
                        -- Check for car data
                        for _, child in pairs(item:GetChildren()) do
                            if child:IsA("StringValue") or child:IsA("IntValue") then
                                print("  " .. child.Name .. " = " .. tostring(child.Value))
                                
                                if child.Name:lower():find("id") then
                                    table.insert(foundCars, {
                                        folder = item.Name,
                                        idName = child.Name,
                                        idValue = child.Value,
                                        path = item:GetFullName()
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    
    print("\n📊 Found " .. #foundCars .. " potential car ID entries")
    return foundCars
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ClickMonitor"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "CLICK MONITOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    local status = Instance.new("TextLabel")
    status.Text = "Monitor what happens when clicking car"
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 230, 255)
    status.TextWrapped = true
    
    -- Buttons
    local buttons = {
        {text = "🎬 MONITOR CLICK", func = MonitorCarClick, pos = UDim2.new(0.025, 0, 0, 140)},
        {text = "🔍 GUESS ID", func = GuessItemIdFromName, pos = UDim2.new(0.525, 0, 0, 140)},
        {text = "🧪 TEST IDS", func = TestGuessedIds, pos = UDim2.new(0.025, 0, 0, 175)},
        {text = "🗄️ FIND DB", func = FindCarDatabase, pos = UDim2.new(0.525, 0, 0, 175)},
        {text = "📊 SHOW CAPTURES", func = function()
            print("\n📋 CAPTURED CALLS (" .. #capturedCalls .. "):")
            for i, call in ipairs(capturedCalls) do
                print("\nCall " .. i .. ":")
                print("  Remote: " .. call.remote)
                print("  Time: " .. os.date("%H:%M:%S", call.timestamp))
                print("  Args: " .. call.args)
            end
        end, pos = UDim2.new(0.025, 0, 0, 210)}
    }
    
    for _, btnInfo in pairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.text
        btn.Size = UDim2.new(0.45, 0, 0, 30)
        btn.Position = btnInfo.pos
        btn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        btn.MouseButton1Click:Connect(function()
            status.Text = "Running: " .. btnInfo.text
            spawn(function()
                btnInfo.func()
                wait(0.5)
                status.Text = "Completed"
            end)
        end)
        
        btn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    frame.Parent = gui
    
    return status
end

-- Initialize
CreateUI()

-- Instructions
wait(2)
print("\n=== CLICK MONITOR ACTIVE ===")
print("The car button has NO item ID values!")
print("We need to CAPTURE what happens when you click it")
print("\n📋 WHAT TO DO:")
print("1. Click 'MONITOR CLICK' to hook remotes")
print("2. Click Car-AstonMartin8 button NORMALLY")
print("3. Watch for CAPTURED output")
print("4. Share the captured parameters")

-- Auto-hook remotes
spawn(function()
    wait(3)
    print("\n🔗 Auto-hooking trade remotes...")
    HookTradeRemotes()
    print("✅ Ready to monitor clicks!")
end)
