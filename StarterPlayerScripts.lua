-- Trade Interaction Test - ACTUAL CLICK VERSION
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

print("🎮 TRADE CLICK SIMULATOR")

-- Method: Use actual mouse position clicking
local function SimulateActualClick(button)
    print("🖱️ Attempting to simulate actual click...")
    
    -- Get button position and size
    local absPos = button.AbsolutePosition
    local absSize = button.AbsoluteSize
    local centerPos = absPos + absSize / 2
    
    print("   Button position: " .. tostring(absPos.X) .. ", " .. tostring(absPos.Y))
    print("   Button size: " .. tostring(absSize.X) .. "x" .. tostring(absSize.Y))
    print("   Center: " .. tostring(centerPos.X) .. ", " .. tostring(centerPos.Y))
    
    -- Method 1: Try to connect to the event and then trigger it via actual UI interaction
    local success, connection = pcall(function()
        local clicked = false
        local conn = button.MouseButton1Click:Connect(function()
            clicked = true
            print("✅ MouseButton1Click event fired!")
        end)
        
        -- Try to trigger the button's Activated event
        if button.Activated then
            button.Activated:Connect(function()
                print("✅ Activated event fired!")
                clicked = true
            end)
        end
        
        -- Try to simulate a click by changing properties that might trigger the button
        button.Selected = true
        wait(0.05)
        button.Selected = false
        
        wait(0.1)
        
        return clicked
    end)
    
    if success and connection then
        print("✅ Click simulation attempted")
        return true
    end
    
    return false
end

-- Method: Try to find and trigger the button's functionality directly
local function TriggerButtonFunctionality(button)
    print("🔧 Looking for button functionality...")
    
    -- Check what kind of button this is
    print("   Button type: " .. button.ClassName)
    
    -- Look for scripts attached to the button
    local scriptsFound = 0
    for _, child in pairs(button:GetDescendants()) do
        if child:IsA("LocalScript") or child:IsA("Script") then
            scriptsFound = scriptsFound + 1
            print("   Found script: " .. child.Name)
        end
    end
    
    if scriptsFound > 0 then
        print("   Total scripts: " .. scriptsFound)
    end
    
    -- Try to find RemoteEvents that might be triggered
    for _, child in pairs(button:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            print("   Found RemoteEvent: " .. child.Name)
            
            -- Try to fire the remote with different data
            local success, result = pcall(function()
                child:FireServer("select", button.Name)
                return true
            end)
            
            if success then
                print("   ✅ Fired RemoteEvent")
                return true
            end
        end
    end
    
    -- Look for the parent frame that might handle clicks
    local parent = button.Parent
    if parent then
        print("   Parent: " .. parent.Name .. " (" .. parent.ClassName .. ")")
        
        -- Check parent for scripts
        for _, child in pairs(parent:GetDescendants()) do
            if child:IsA("LocalScript") and child.Name:lower():find("click") then
                print("   Found click handler script: " .. child.Name)
            end
        end
    end
    
    return false
end

-- Method: Check if we can duplicate the visual appearance
local function CheckVisualDuplication(button)
    print("🎨 Analyzing button for duplication...")
    
    -- Get all properties
    local properties = {}
    
    local function safeGet(prop)
        local success, value = pcall(function()
            return button[prop]
        end)
        if success then
            properties[prop] = value
        end
    end
    
    -- Get visual properties
    safeGet("Image")
    safeGet("ImageColor3")
    safeGet("ImageTransparency")
    safeGet("BackgroundColor3")
    safeGet("BackgroundTransparency")
    safeGet("BorderColor3")
    safeGet("BorderSizePixel")
    safeGet("Position")
    safeGet("Size")
    safeGet("Rotation")
    safeGet("ScaleType")
    safeGet("SliceScale")
    safeGet("TileSize")
    
    print("   Visual properties found: " .. #properties)
    
    -- Check for children that make up the car display
    local childrenInfo = {}
    for _, child in pairs(button:GetChildren()) do
        local info = child.Name .. " (" .. child.ClassName .. ")"
        if child:IsA("TextLabel") and child.Text ~= "" then
            info = info .. ": \"" .. child.Text .. "\""
        elseif child:IsA("ImageLabel") and child.Image ~= "" then
            info = info .. " [Image]"
        end
        table.insert(childrenInfo, info)
    end
    
    if #childrenInfo > 0 then
        print("   Children:")
        for _, info in ipairs(childrenInfo) do
            print("     • " .. info)
        end
    end
    
    return properties
end

-- Main test function
local function TestCarButton(carName)
    print("\n" .. string.rep("=", 60))
    print("🎯 TESTING: " .. carName)
    
    -- Find the car button
    local carButton = nil
    local success, result = pcall(function()
        local menu = Player.PlayerGui.Menu
        local trading = menu.Trading
        local peerToPeer = trading.PeerToPeer
        local main = peerToPeer.Main
        local inventory = main.Inventory
        local list = inventory.List
        local scrolling = list.ScrollingFrame
        
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name == carName then
                return item
            end
        end
        return nil
    end)
    
    if not success then
        print("❌ Error finding button: " .. tostring(result))
        return false
    end
    
    if not carButton then
        print("❌ Button not found: " .. carName)
        return false
    end
    
    print("✅ Found button: " .. carButton:GetFullName())
    
    -- Test different methods
    local methods = {
        SimulateActualClick,
        TriggerButtonFunctionality,
        CheckVisualDuplication
    }
    
    local methodNames = {
        "Click Simulation",
        "Functionality Trigger",
        "Visual Analysis"
    }
    
    local anySuccess = false
    
    for i, method in ipairs(methods) do
        print("\n🔄 Method " .. i .. ": " .. methodNames[i])
        local success = method(carButton)
        if success then
            print("✅ " .. methodNames[i] .. " succeeded!")
            anySuccess = true
        else
            print("❌ " .. methodNames[i] .. " failed")
        end
    end
    
    -- Check if car appeared in trade
    wait(1)
    print("\n📊 CHECKING TRADE OFFER...")
    
    local checkSuccess, carsInOffer = pcall(function()
        local menu = Player.PlayerGui.Menu
        local trading = menu.Trading
        local peerToPeer = trading.PeerToPeer
        local main = peerToPeer.Main
        local localPlayer = main.LocalPlayer
        local content = localPlayer.Content
        local scrolling = content.ScrollingFrame
        
        local cars = {}
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name:sub(1, 4) == "Car-" then
                table.insert(cars, item.Name)
            end
        end
        return cars
    end)
    
    if checkSuccess then
        if #carsInOffer > 0 then
            print("✅ Cars in trade offer:")
            for _, car in ipairs(carsInOffer) do
                print("   🚗 " .. car)
            end
            
            -- Check if our tested car is there
            local found = false
            for _, car in ipairs(carsInOffer) do
                if car == carName then
                    found = true
                    break
                end
            end
            
            if found then
                print("🎉 SUCCESS! " .. carName .. " was added to trade!")
                anySuccess = true
            else
                print("❌ " .. carName .. " was NOT added to trade")
            end
        else
            print("📭 No cars in trade offer")
        end
    else
        print("❌ Could not check trade: " .. tostring(carsInOffer))
    end
    
    print(string.rep("=", 60))
    return anySuccess
end

-- Find and test all cars
local function TestAllCars()
    print("\n🔍 SCANNING FOR ALL CARS...")
    
    local carsFound = {}
    
    local success, result = pcall(function()
        local menu = Player.PlayerGui.Menu
        local trading = menu.Trading
        local peerToPeer = trading.PeerToPeer
        local main = peerToPeer.Main
        local inventory = main.Inventory
        local list = inventory.List
        local scrolling = list.ScrollingFrame
        
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name:sub(1, 4) == "Car-" then
                table.insert(carsFound, {
                    Name = item.Name,
                    Object = item,
                    Index = #carsFound + 1
                })
            end
        end
        return carsFound
    end)
    
    if not success then
        print("❌ Error: " .. tostring(result))
        return {}
    end
    
    if #carsFound > 0 then
        print("✅ Found " .. #carsFound .. " cars:")
        for i, car in ipairs(carsFound) do
            print("   " .. i .. ". " .. car.Name)
        end
    else
        print("❌ No cars found")
    end
    
    return carsFound
end

-- Create control panel
local function CreateControlPanel()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeClickTester"
    gui.Parent = Player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 300)
    frame.Position = UDim2.new(0.7, 0, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "🎮 TRADE CLICK TESTER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    
    local status = Instance.new("TextLabel")
    status.Text = "Ready..."
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 200, 255)
    status.Font = Enum.Font.Gotham
    status.TextWrapped = true
    
    local scanButton = Instance.new("TextButton")
    scanButton.Text = "🔍 SCAN CARS"
    scanButton.Size = UDim2.new(1, -20, 0, 40)
    scanButton.Position = UDim2.new(0, 10, 0, 120)
    scanButton.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    scanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local testButton = Instance.new("TextButton")
    testButton.Text = "🖱️ TEST CLICK"
    testButton.Size = UDim2.new(1, -20, 0, 40)
    testButton.Position = UDim2.new(0, 10, 0, 170)
    testButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    testButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local carList = Instance.new("ScrollingFrame")
    carList.Size = UDim2.new(1, -20, 0, 80)
    carList.Position = UDim2.new(0, 10, 1, -100)
    carList.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    carList.BorderSizePixel = 0
    carList.ScrollBarThickness = 6
    carList.Visible = false
    
    local carLayout = Instance.new("UIListLayout")
    carLayout.Padding = UDim.new(0, 5)
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = frame
    corner:Clone().Parent = title
    corner:Clone().Parent = scanButton
    corner:Clone().Parent = testButton
    corner:Clone().Parent = carList
    
    -- Parent
    title.Parent = frame
    status.Parent = frame
    scanButton.Parent = frame
    testButton.Parent = frame
    carLayout.Parent = carList
    carList.Parent = frame
    frame.Parent = gui
    
    -- Variables
    local cars = {}
    local selectedCar = nil
    
    local function updateStatus(text, color)
        status.Text = text
        status.TextColor3 = color or Color3.fromRGB(200, 200, 255)
    end
    
    local function addCarButton(carInfo)
        local btn = Instance.new("TextButton")
        btn.Text = carInfo.Name
        btn.Size = UDim2.new(0.9, 0, 0, 30)
        btn.Position = UDim2.new(0.05, 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        btn.MouseButton1Click:Connect(function()
            selectedCar = carInfo.Name
            updateStatus("Selected: " .. carInfo.Name, Color3.fromRGB(255, 255, 200))
            
            -- Highlight selected
            for _, child in pairs(carList:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        end)
        
        btn.Parent = carList
        return btn
    end
    
    -- Button events
    scanButton.MouseButton1Click:Connect(function()
        updateStatus("Scanning for cars...", Color3.fromRGB(255, 200, 100))
        scanButton.Text = "SCANNING..."
        
        -- Clear old list
        for _, child in pairs(carList:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        cars = TestAllCars()
        
        if #cars > 0 then
            updateStatus("Found " .. #cars .. " cars", Color3.fromRGB(100, 255, 100))
            carList.Visible = true
            
            for _, car in ipairs(cars) do
                addCarButton(car)
            end
            
            -- Auto-select first car
            selectedCar = cars[1].Name
        else
            updateStatus("No cars found", Color3.fromRGB(255, 100, 100))
            carList.Visible = false
        end
        
        scanButton.Text = "🔍 SCAN CARS"
    end)
    
    testButton.MouseButton1Click:Connect(function()
        if not selectedCar then
            updateStatus("Please select a car first!", Color3.fromRGB(255, 100, 100))
            return
        end
        
        updateStatus("Testing " .. selectedCar .. "...", Color3.fromRGB(255, 200, 100))
        testButton.Text = "TESTING..."
        
        local success = TestCarButton(selectedCar)
        
        if success then
            updateStatus("✅ Test completed for " .. selectedCar, Color3.fromRGB(100, 255, 100))
        else
            updateStatus("❌ Test failed for " .. selectedCar, Color3.fromRGB(255, 100, 100))
        end
        
        testButton.Text = "🖱️ TEST CLICK"
    end)
    
    -- Initial scan
    wait(1)
    scanButton:Click()
    
    return gui
end

-- Initialize
print("\n" .. string.rep("=", 60))
print("🎮 TRADE CLICK SIMULATOR LOADED")
print("📍 Will analyze and test car buttons")
print("💡 Click SCAN CARS, select a car, then TEST CLICK")
print(string.rep("=", 60))

CreateControlPanel()

print("\n✅ Control panel created!")
print("💡 Features:")
print("   • Scan all available cars")
print("   • Select specific car to test")
print("   • Multiple click simulation methods")
print("   • Detailed output analysis")
