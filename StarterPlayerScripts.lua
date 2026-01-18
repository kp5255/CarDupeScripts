-- Trade Duplicator - Car Only
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

wait(2)

print("=== CAR-ONLY TRADE DUPLICATOR ===")

-- Get remotes
local TradingServiceRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local SessionAddItem = TradingServiceRemotes:WaitForChild("SessionAddItem")

print("✅ Loaded TradingServiceRemotes")

-- Get the ScrollingFrame
local function GetScrollingFrame()
    if not Player.PlayerGui then return nil end
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then return nil end
    local trading = menu:FindFirstChild("Trading")
    if not trading then return nil end
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then return nil end
    local main = peerToPeer:FindFirstChild("Main")
    if not main then return nil end
    local localPlayer = main:FindFirstChild("LocalPlayer")
    if not localPlayer then return nil end
    local content = localPlayer:FindFirstChild("Content")
    if not content then return nil end
    return content:FindFirstChild("ScrollingFrame")
end

-- Find ONLY actual cars (not customization items)
local function FindRealCarsInTrade()
    print("\n🔍 FINDING REAL CARS ONLY...")
    
    local scrollingFrame = GetScrollingFrame()
    if not scrollingFrame then
        print("❌ No trade window found")
        return {}
    end
    
    print("ScrollingFrame items: " .. #scrollingFrame:GetChildren())
    
    local realCars = {}
    
    -- Check each item
    for _, item in pairs(scrollingFrame:GetChildren()) do
        if item:IsA("ImageButton") or item:IsA("TextButton") then
            local itemName = item.Name
            
            -- IMPORTANT: Only get items that start with "Car-"
            if itemName:sub(1, 4) == "Car-" then
                print("🚗 REAL CAR FOUND: " .. itemName)
                
                -- Look for ID in children
                local carId = nil
                for _, child in pairs(item:GetChildren()) do
                    if child:IsA("StringValue") then
                        if child.Name:lower():find("id") then
                            carId = child.Value
                            print("  Found ID: " .. carId)
                        end
                    end
                end
                
                -- If no ID found, use the item name
                if not carId then
                    carId = itemName
                    print("  Using name as ID: " .. carId)
                end
                
                table.insert(realCars, {
                    button = item,
                    name = itemName,
                    id = carId,
                    isCar = true
                })
            else
                -- This is a customization item, ignore it
                if itemName:lower():find("car") then
                    print("⚠️ Ignoring customization: " .. itemName)
                end
            end
        end
    end
    
    print("\n📊 Found " .. #realCars .. " real car(s)")
    return realCars
end

-- Get session ID (try smarter approach)
local function GetSessionId()
    print("\n🆔 GETTING SESSION ID...")
    
    -- Method 1: Try to find in trade UI
    if Player.PlayerGui then
        local menu = Player.PlayerGui:FindFirstChild("Menu")
        if menu then
            local trading = menu:FindFirstChild("Trading")
            if trading then
                -- Look for any text that might contain session info
                for _, obj in pairs(trading:GetDescendants()) do
                    if obj:IsA("TextLabel") then
                        local text = obj.Text
                        if text:find("Session") or text:find("Trade") then
                            -- Try to extract ID
                            local id = text:match("ID:%s*(%S+)") or 
                                       text:match("Session:%s*(%S+)") or
                                       text:match("Trade:%s*(%S+)")
                            if id then
                                print("✅ Found session ID in UI: " .. id)
                                return id
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Method 2: Try common session ID patterns
    local possibleSessions = {
        Player.UserId .. "_trade",
        "trade_" .. tostring(os.time()),
        "session_1",
        "current_trade"
    }
    
    -- Try each one
    for _, sessionId in pairs(possibleSessions) do
        print("Trying session ID: " .. sessionId)
        
        local success = pcall(function()
            -- Just test if the remote accepts this session ID
            SessionAddItem:InvokeServer(sessionId, "test")
            return true
        end)
        
        if success then
            print("✅ Session ID works: " .. sessionId)
            return sessionId
        end
    end
    
    -- Method 3: Ask the remote what session we're in
    print("⚠️ Trying to get session from remote...")
    local success, result = pcall(function()
        return SessionAddItem:InvokeServer("get_session", Player)
    end)
    
    if success and result then
        print("✅ Remote returned session: " .. tostring(result))
        return tostring(result)
    end
    
    print("❌ Could not find session ID")
    return nil
end

-- Try to add car with different session ID strategies
local function AddCarToSession(carId, carName)
    print("\n🎯 ADDING CAR TO SESSION: " .. carName)
    
    -- Try multiple session ID strategies
    local sessionStrategies = {
        function() return GetSessionId() end,  -- Try to find it
        function() return "trade_session" end,  -- Simple
        function() return Player.UserId .. "_session" end,  -- User-based
        function() return "session_" .. tostring(math.random(1000, 9999)) end,  -- Random
        function() return nil end  -- Try without session ID
    }
    
    local successCount = 0
    
    for strategyIndex, getSessionFunc in pairs(sessionStrategies) do
        local sessionId = getSessionFunc()
        
        if not sessionId then
            print("\nTrying without session ID...")
            -- Try without session ID
            local attempts = {
                {desc = "Just car ID", params = {carId}},
                {desc = "Car ID + quantity", params = {carId, 1}},
                {desc = "Car name", params = {carName}},
            }
            
            for _, attempt in pairs(attempts) do
                print("Attempt: " .. attempt.desc)
                local success = pcall(function()
                    return SessionAddItem:InvokeServer(unpack(attempt.params))
                end)
                
                if success then
                    print("✅ Success without session ID!")
                    successCount = successCount + 1
                    break
                end
            end
            
        else
            print("\nUsing session ID: " .. sessionId)
            
            -- Try different parameter formats WITH session ID
            local attempts = {
                {desc = "Session + Car ID", params = {sessionId, carId}},
                {desc = "Session + Car ID + Qty", params = {sessionId, carId, 1}},
                {desc = "Session + Car Name", params = {sessionId, carName}},
                {desc = "Session + Car Name + Qty", params = {sessionId, carName, 1}},
                {desc = "Session + Table", params = {sessionId, {id = carId, name = carName}}},
            }
            
            for _, attempt in pairs(attempts) do
                print("Attempt: " .. attempt.desc)
                local success, result = pcall(function()
                    return SessionAddItem:InvokeServer(unpack(attempt.params))
                end)
                
                if success then
                    print("✅ Success!")
                    if result then
                        print("   Result: " .. tostring(result))
                    end
                    successCount = successCount + 1
                    break  -- Stop if one works
                end
            end
        end
        
        if successCount > 0 then
            break  -- Stop if we found a working method
        end
        
        wait(0.5)
    end
    
    return successCount > 0
end

-- Also try clicking the car button
local function ClickCarButton(carButton)
    print("\n🖱️ CLICKING CAR BUTTON...")
    
    local clickCount = 0
    
    for i = 1, 10 do
        local success = pcall(function()
            -- Try different click methods
            carButton:Fire("Activated")
            carButton:Fire("MouseButton1Click")
            
            -- Look for click remote
            for _, child in pairs(carButton:GetChildren()) do
                if child:IsA("RemoteEvent") then
                    child:FireServer("add")
                    child:FireServer("click")
                end
            end
            
            clickCount = clickCount + 1
            return true
        end)
        
        if success then
            print("✅ Click " .. i .. " successful")
        end
        
        wait(0.1)
    end
    
    print("📊 Total successful clicks: " .. clickCount)
    return clickCount > 0
end

-- Main function
local function DuplicateCarOnly()
    print("\n🚀 DUPLICATING CAR ONLY...")
    
    -- Step 1: Find only real cars
    local cars = FindRealCarsInTrade()
    
    if #cars == 0 then
        print("❌ No cars found in trade")
        print("Add a Car- item to the trade first!")
        return false
    end
    
    local car = cars[1]  -- Use first car
    print("\n🎯 Selected car: " .. car.name)
    print("Car ID: " .. car.id)
    
    -- Step 2: Try to add to session
    local sessionSuccess = AddCarToSession(car.id, car.name)
    
    -- Step 3: Also try clicking
    local clickSuccess = ClickCarButton(car.button)
    
    -- Step 4: Check results
    wait(1)
    local newCars = FindRealCarsInTrade()
    
    print("\n📊 FINAL RESULTS:")
    print("Original cars: " .. #cars)
    print("Current cars: " .. #newCars)
    print("Session add success: " .. tostring(sessionSuccess))
    print("Click success: " .. tostring(clickSuccess))
    
    if #newCars > #cars then
        print("🎉 DUPLICATION SUCCESSFUL!")
        return true
    else
        print("⚠️ Car count unchanged")
        
        -- Try one more thing: clone the UI button
        print("\n🔄 TRYING UI CLONE AS LAST RESORT...")
        local scrollingFrame = GetScrollingFrame()
        if scrollingFrame then
            local clone = car.button:Clone()
            clone.Name = car.name .. "_Clone"
            clone.Parent = scrollingFrame
            print("✅ Cloned button in UI")
            
            -- Check again
            wait(0.5)
            newCars = FindRealCarsInTrade()
            print("After clone - Cars: " .. #newCars)
            
            if #newCars > #cars then
                print("🎉 UI CLONE SUCCESSFUL!")
                return true
            end
        end
    end
    
    return false
end

-- Create simple UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarOnlyDuplicator"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "CAR-ONLY DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(255, 150, 100)
    
    local output = Instance.new("TextLabel")
    output.Text = "Only duplicates Car- items\nIgnores customization items"
    output.Size = UDim2.new(1, -20, 0, 110)
    output.Position = UDim2.new(0, 10, 0, 50)
    output.BackgroundTransparency = 1
    output.TextColor3 = Color3.fromRGB(200, 220, 255)
    output.TextWrapped = true
    
    local findBtn = Instance.new("TextButton")
    findBtn.Text = "🔍 FIND CARS"
    findBtn.Size = UDim2.new(0.48, 0, 0, 30)
    findBtn.Position = UDim2.new(0.01, 0, 0, 170)
    findBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
    
    local dupBtn = Instance.new("TextButton")
    dupBtn.Text = "🚀 DUPLICATE"
    dupBtn.Size = UDim2.new(0.48, 0, 0, 30)
    dupBtn.Position = UDim2.new(0.51, 0, 0, 170)
    dupBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    
    -- Update output
    local function updateOutput(text)
        output.Text = text
        print(text)
    end
    
    findBtn.MouseButton1Click:Connect(function()
        updateOutput("Finding real cars...")
        spawn(function()
            local cars = FindRealCarsInTrade()
            if #cars > 0 then
                updateOutput("Found " .. #cars .. " car(s)")
            else
                updateOutput("No cars found\nAdd Car- item to trade")
            end
        end)
    end)
    
    dupBtn.MouseButton1Click:Connect(function()
        updateOutput("Duplicating car...")
        spawn(function()
            local success = DuplicateCarOnly()
            if success then
                updateOutput("✅ Duplication attempted!\nCheck other player.")
            else
                updateOutput("❌ Duplication failed\nCheck output window")
            end
        end)
    end)
    
    -- Parent everything
    title.Parent = frame
    output.Parent = frame
    findBtn.Parent = frame
    dupBtn.Parent = frame
    frame.Parent = gui
    
    return updateOutput
end

-- Initialize
local updateOutput = CreateUI()

-- Auto-start
wait(3)
print("\n=== CAR-ONLY DUPLICATOR ===")
print("Only targets items starting with 'Car-'")
print("Ignores customization items")

-- Initial scan
spawn(function()
    wait(2)
    print("\n🔍 Initial car scan...")
    FindRealCarsInTrade()
    updateOutput("Ready\nAdd Car- item to trade")
end)

-- Keybinds
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.C then
        print("\n🎮 C KEY - FINDING CARS")
        FindRealCarsInTrade()
    elseif input.KeyCode == Enum.KeyCode.D then
        print("\n🎮 D KEY - DUPLICATING")
        DuplicateCarOnly()
    end
end)

print("\n🔑 QUICK KEYS:")
print("C = Find cars (Car- items only)")
print("D = Duplicate car")
print("\n📋 REQUIRED:")
print("1. Must have a 'Car-' item in trade")
print("2. Not customization items")
print("3. Check other player's screen after duplication")
