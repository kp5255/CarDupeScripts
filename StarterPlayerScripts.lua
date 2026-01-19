-- Trade Click Monitor - Fixed Version
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== TRADE CLICK MONITOR - FIXED ===")

-- Get trading service
local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes

-- We'll use a simpler approach: Just print when remotes are called
local capturedCalls = {}

-- Function to monitor a specific remote
local function MonitorRemote(remote)
    if remote:IsA("RemoteFunction") then
        print("🎯 Monitoring remote: " .. remote.Name)
        
        -- We can't hook InvokeServer directly, but we can watch for calls
        -- by checking what happens after clicks
    end
end

-- Monitor all trading remotes
local function StartMonitoring()
    print("\n🔍 STARTING MONITORING...")
    
    for _, remote in pairs(tradingService:GetChildren()) do
        if remote:IsA("RemoteFunction") then
            MonitorRemote(remote)
        end
    end
    
    print("\n✅ READY TO MONITOR!")
    print("Now click Car-AstonMartin12 in your inventory")
    print("I'll try to infer what happens")
}

-- Alternative approach: Check what changes after clicking
local function AnalyzeClickEffects()
    print("\n🔍 ANALYZING CLICK EFFECTS...")
    
    -- Check trade window BEFORE click
    print("\n📊 TRADE WINDOW BEFORE CLICK:")
    local beforeCars = {}
    
    pcall(function()
        local main = Player.PlayerGui.Menu.Trading.PeerToPeer.Main
        local localPlayer = main.LocalPlayer
        local scrolling = localPlayer.Content.ScrollingFrame
        
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name:sub(1, 4) == "Car-" then
                table.insert(beforeCars, item.Name)
            end
        end
    end)
    
    if #beforeCars > 0 then
        for _, carName in ipairs(beforeCars) do
            print("  - " .. carName)
        end
    else
        print("  (empty)")
    end
    
    -- Instructions for user
    print("\n🖱️ INSTRUCTIONS:")
    print("1. Note the cars above (BEFORE)")
    print("2. Click Car-AstonMartin12 in inventory NOW")
    print("3. Wait 2 seconds")
    print("4. I'll check what changed")
    
    -- Wait for user to click
    for i = 1, 10 do
        print("Waiting... (" .. i .. "/10)")
        wait(1)
    end
    
    -- Check trade window AFTER click
    print("\n📊 TRADE WINDOW AFTER CLICK:")
    local afterCars = {}
    
    pcall(function()
        local main = Player.PlayerGui.Menu.Trading.PeerToPeer.Main
        local localPlayer = main.LocalPlayer
        local scrolling = localPlayer.Content.ScrollingFrame
        
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name:sub(1, 4) == "Car-" then
                table.insert(afterCars, item.Name)
            end
        end
    end)
    
    if #afterCars > 0 then
        for _, carName in ipairs(afterCars) do
            print("  - " .. carName)
        end
    else
        print("  (empty)")
    end
    
    -- Analyze changes
    print("\n🔍 ANALYSIS:")
    print("Cars before: " .. #beforeCars)
    print("Cars after: " .. #afterCars)
    
    if #afterCars > #beforeCars then
        print("✅ Car was added to trade!")
        
        -- Find which car was added
        for _, afterCar in ipairs(afterCars) do
            local found = false
            for _, beforeCar in ipairs(beforeCars) do
                if afterCar == beforeCar then
                    found = true
                    break
                end
            end
            
            if not found then
                print("🎯 NEW CAR ADDED: " .. afterCar)
                
                -- Get car data for this car
                GetCarDataForTradeCar(afterCar)
            end
        end
    else
        print("❌ No new cars added")
        print("Maybe Car-AstonMartin12 was already in trade?")
    end
end

-- Get data for a car that's in trade
local function GetCarDataForTradeCar(carNameInTrade)
    print("\n🔑 GETTING DATA FOR TRADE CAR: " .. carNameInTrade)
    
    local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
    
    local success, carList = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if not success or not carList then
        print("❌ Failed to get car list")
        return nil
    end
    
    -- Extract car number from name (e.g., "Car-AstonMartin12" → "AstonMartin12")
    local carBaseName = carNameInTrade:match("Car%-(.+)")
    if not carBaseName then
        print("❌ Could not parse car name")
        return nil
    end
    
    print("Looking for: " .. carBaseName)
    
    -- Find the car in inventory
    for _, carData in ipairs(carList) do
        if type(carData) == "table" and carData.Name == carBaseName then
            print("✅ Found car data!")
            print("Car ID: " .. carData.Id)
            
            -- Show minimal data
            print("\n📋 ESSENTIAL DATA:")
            print("  Name: " .. carData.Name)
            print("  Id: " .. carData.Id)
            
            if carData.Created then
                print("  Created: " .. carData.Created)
            end
            
            return carData
        end
    end
    
    print("❌ Car not found in inventory")
    return nil
end

-- Try to add car using educated guess
local function TryEducatedGuess()
    print("\n🎯 MAKING EDUCATED GUESS...")
    
    -- Based on what we know:
    print("KNOWLEDGE BASE:")
    print("1. Session ID 'otherplayer' works for SessionSetConfirmation")
    print("2. Manual clicking adds cars to trade")
    print("3. SessionAddItem exists but gives 'Invalid item type'")
    
    print("\n🧠 HYPOTHESIS:")
    print("Maybe SessionAddItem needs DIFFERENT parameters")
    print("Let's test some educated guesses...")
    
    -- Get car data
    local carData = GetCarDataForTradeCar("Car-AstonMartin12")
    if not carData then
        print("❌ No car data")
        return false
    end
    
    local SessionAddItem = tradingService:FindFirstChild("SessionAddItem")
    if not SessionAddItem then
        print("❌ SessionAddItem not found")
        return false
    end
    
    -- Test different hypotheses
    local testCases = {
        -- Hypothesis 1: Maybe it needs the full car data table
        {name = "Full car table", params = {"otherplayer", carData}},
        
        -- Hypothesis 2: Maybe it needs the Data field from car
        {name = "Data field only", params = {"otherplayer", carData.Data}},
        
        -- Hypothesis 3: Maybe it needs a specific format from Data
        {name = "Specific Data entry", params = {"otherplayer", carData.Data and carData.Data.Id}},
        
        -- Hypothesis 4: Maybe no session ID needed when in trade
        {name = "No session, just car", params = {carData}},
        {name = "No session, just car ID", params = {carData.Id}},
        
        -- Hypothesis 5: Maybe different session ID format
        {name = "Session 'trade'", params = {"trade", carData.Id}},
        {name = "Session 'session'", params = {"session", carData.Id}},
        
        -- Hypothesis 6: Maybe it needs player reference
        {name = "Player + car", params = {Player, carData.Id}},
        {name = "Session + Player + car", params = {"otherplayer", Player, carData.Id}},
    }
    
    for i, testCase in ipairs(testCases) do
        print("\nTest " .. i .. ": " .. testCase.name)
        
        local success, result = pcall(function()
            return SessionAddItem:InvokeServer(unpack(testCase.params))
        end)
        
        if success then
            print("✅ SUCCESS!")
            if result then
                print("Result: " .. tostring(result))
            end
            
            -- Try multiple times
            for j = 1, 3 do
                wait(0.2)
                pcall(function()
                    SessionAddItem:InvokeServer(unpack(testCase.params))
                    print("Repeated " .. j)
                end)
            end
            
            return true
        else
            print("❌ Failed: " .. tostring(result))
        end
        
        wait(0.3)
    end
    
    return false
end

-- Check what's actually happening when we click
local function InvestigateButtonClick()
    print("\n🔍 INVESTIGATING BUTTON CLICK...")
    
    -- Find the car button in inventory
    local carButton = nil
    
    pcall(function()
        local inventory = Player.PlayerGui.Menu.Trading.PeerToPeer.Main.Inventory
        local scrolling = inventory.List.ScrollingFrame
        
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name == "Car-AstonMartin12" then
                carButton = item
                break
            end
        end
    end)
    
    if not carButton then
        print("❌ Car button not found")
        return false
    end
    
    print("✅ Found Car-AstonMartin12 button")
    
    -- Analyze the button
    print("\n📊 BUTTON ANALYSIS:")
    print("Class: " .. carButton.ClassName)
    
    -- Check for any special properties
    local hasRemote = false
    for _, child in pairs(carButton:GetChildren()) do
        if child:IsA("RemoteEvent") then
            print("🎯 Found RemoteEvent: " .. child.Name)
            hasRemote = true
            
            -- Try to fire it
            print("  Testing RemoteEvent...")
            local success, result = pcall(function()
                child:FireServer("add")
                return true
            end)
            
            if success then
                print("    ✅ Fired successfully")
            else
                print("    ❌ Failed: " .. tostring(result))
            end
        end
    end
    
    if not hasRemote then
        print("❌ No RemoteEvent found on button")
        print("The click might trigger a different mechanism")
    end
    
    -- Try clicking it programmatically
    print("\n🖱️ PROGRAMMATIC CLICK TEST:")
    
    local clickMethods = {
        {"MouseButton1Click", function() carButton:Fire("MouseButton1Click") end},
        {"Activated", function() carButton:Fire("Activated") end},
        {"MouseButton1Down/Up", function()
            carButton:Fire("MouseButton1Down")
            wait(0.05)
            carButton:Fire("MouseButton1Up")
        end},
    }
    
    for _, method in ipairs(clickMethods) do
        local methodName = method[1]
        local methodFunc = method[2]
        
        print("  Testing: " .. methodName)
        
        local success, result = pcall(methodFunc)
        if success then
            print("    ✅ Success")
            
            -- Check if car was added
            wait(0.5)
            pcall(function()
                local main = Player.PlayerGui.Menu.Trading.PeerToPeer.Main
                local localPlayer = main.LocalPlayer
                local scrolling = localPlayer.Content.ScrollingFrame
                
                local found = false
                for _, item in pairs(scrolling:GetChildren()) do
                    if item.Name == "Car-AstonMartin12" then
                        found = true
                        break
                    end
                end
                
                if found then
                    print("    🎯 Car was added to trade!")
                else
                    print("    ❌ Car was NOT added")
                end
            end)
        else
            print("    ❌ Failed: " .. tostring(result))
        end
        
        wait(0.5)
    end
    
    return true
end

-- Main investigation
local function RunInvestigation()
    print("\n🔍 RUNNING COMPLETE INVESTIGATION...")
    
    -- Start monitoring
    StartMonitoring()
    
    -- Analyze click effects
    wait(2)
    AnalyzeClickEffects()
    
    -- Try educated guesses
    wait(2)
    TryEducatedGuess()
    
    -- Investigate button click
    wait(2)
    InvestigateButtonClick()
    
    print("\n" .. string.rep("=", 60))
    print("INVESTIGATION COMPLETE")
    print("Next: Try the programmatic click test above")
    print(string.rep("=", 60))
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ClickInvestigator"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "CLICK INVESTIGATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    local status = Instance.new("TextLabel")
    status.Text = "Investigating manual click\nFollow instructions below"
    status.Size = UDim2.new(1, -20, 0, 110)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 230, 255)
    status.TextWrapped = true
    
    local startBtn = Instance.new("TextButton")
    startBtn.Text = "🔍 START INVESTIGATION"
    startBtn.Size = UDim2.new(1, -20, 0, 30)
    startBtn.Position = UDim2.new(0, 10, 0, 170)
    startBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local clickBtn = Instance.new("TextButton")
    clickBtn.Text = "🖱️ TEST PROGRAMMATIC CLICK"
    clickBtn.Size = UDim2.new(1, -20, 0, 30)
    clickBtn.Position = UDim2.new(0, 10, 0, 210)
    clickBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
    clickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    startBtn.MouseButton1Click:Connect(function()
        status.Text = "Starting investigation...\nCheck output!"
        startBtn.Text = "INVESTIGATING..."
        
        spawn(function()
            RunInvestigation()
            
            status.Text = "✅ Investigation complete!\nSee output for details"
            
            wait(2)
            startBtn.Text = "🔍 START INVESTIGATION"
        end)
    end)
    
    clickBtn.MouseButton1Click:Connect(function()
        status.Text = "Testing programmatic click..."
        clickBtn.Text = "TESTING..."
        
        spawn(function()
            InvestigateButtonClick()
            
            status.Text = "✅ Click test complete!\nCheck output"
            
            wait(2)
            clickBtn.Text = "🖱️ TEST PROGRAMMATIC CLICK"
        end)
    end)
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    startBtn.Parent = frame
    clickBtn.Parent = frame
    frame.Parent = gui
    
    return status
end

-- Initialize
CreateUI()

-- Instructions
wait(3)
print("\n=== CLICK INVESTIGATOR ===")
print("Trying to understand manual click mechanics")
print("\n📋 WHAT WE'LL DO:")
print("1. Monitor what happens when you click")
print("2. Analyze before/after trade state")
print("3. Test educated guesses about SessionAddItem")
print("4. Try programmatic clicking")
print("\n🔍 Click 'START INVESTIGATION' to begin!")
