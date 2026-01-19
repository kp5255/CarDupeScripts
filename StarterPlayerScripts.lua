-- Simple Trade Test - CORRECTED Version
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

print("=== SIMPLE TRADE TEST - CORRECTED ===")

-- Try different click methods
local function TestClickMethods(carButton)
    print("\n🖱️ TESTING CLICK METHODS on: " .. carButton.Name)
    
    -- Method 1: Simulate mouse click via InputBegan/InputEnded
    local function simulateMouseClick(button)
        print("🔄 Method 1: Simulating mouse input...")
        
        -- Create mouse input objects
        local mousePos = button.AbsolutePosition + button.AbsoluteSize / 2
        
        -- Trigger InputBegan
        local inputBegan = {
            UserInputType = Enum.UserInputType.MouseButton1,
            UserInputState = Enum.UserInputState.Begin,
            Position = mousePos
        }
        
        local inputEnded = {
            UserInputType = Enum.UserInputType.MouseButton1,
            UserInputState = Enum.UserInputState.End,
            Position = mousePos
        }
        
        -- Try to fire the events
        local success1 = pcall(function()
            button:Fire("InputBegan", inputBegan)
            return true
        end)
        
        local success2 = pcall(function()
            button:Fire("InputEnded", inputEnded)
            return true
        end)
        
        if success1 then print("✅ Fired InputBegan") end
        if success2 then print("✅ Fired InputEnded") end
        
        return success1 and success2
    end
    
    -- Method 2: Try to find and trigger the event
    local function triggerMouseButton1Click(button)
        print("🔄 Method 2: Looking for MouseButton1Click event...")
        
        -- Check if button has MouseButton1Click event
        local success, event = pcall(function()
            return button.MouseButton1Click
        end)
        
        if success and event then
            print("✅ Found MouseButton1Click event")
            event:Fire()
            return true
        else
            print("❌ No MouseButton1Click event found")
            return false
        end
    end
    
    -- Method 3: Use Activated event (for ImageButtons)
    local function triggerActivated(button)
        print("🔄 Method 3: Looking for Activated event...")
        
        local success, event = pcall(function()
            return button.Activated
        end)
        
        if success and event then
            print("✅ Found Activated event")
            event:Fire()
            return true
        else
            print("❌ No Activated event found")
            return false
        end
    end
    
    -- Method 4: Direct property change (visual only)
    local function simulateSelection(button)
        print("🔄 Method 4: Simulating selection...")
        
        -- Try to change selection visual states
        local success1 = pcall(function()
            if button:IsA("GuiButton") then
                button.Selected = true
                wait(0.1)
                button.Selected = false
                return true
            end
            return false
        end)
        
        local success2 = pcall(function()
            if button:FindFirstChild("SelectionImageObject") then
                button.SelectionImageObject.Visible = true
                wait(0.1)
                button.SelectionImageObject.Visible = false
                return true
            end
            return false
        end)
        
        if success1 then print("✅ Changed Selected property") end
        if success2 then print("✅ Changed SelectionImageObject") end
        
        return success1 or success2
    end
    
    -- Method 5: Hook into the button's click function
    local function hookClickFunction(button)
        print("🔄 Method 5: Attempting to hook click function...")
        
        local oldMouseButton1Down = button.MouseButton1Down
        local oldMouseButton1Up = button.MouseButton1Up
        
        if oldMouseButton1Down then
            print("✅ Found MouseButton1Down event")
            oldMouseButton1Down:Fire()
            return true
        end
        
        if oldMouseButton1Up then
            print("✅ Found MouseButton1Up event")
            oldMouseButton1Up:Fire()
            return true
        end
        
        print("❌ No click events found")
        return false
    end
    
    -- Run all methods
    local results = {
        simulateMouseClick(carButton),
        triggerMouseButton1Click(carButton),
        triggerActivated(carButton),
        simulateSelection(carButton),
        hookClickFunction(carButton)
    }
    
    -- Check if any method succeeded
    local anySuccess = false
    for _, success in ipairs(results) do
        if success then anySuccess = true end
    end
    
    return anySuccess
end

-- Find and test the car
local function TestCarInteraction()
    print("\n🔍 LOOKING FOR Car-AstonMartin12")
    
    local carButton = nil
    local carPath = nil
    
    -- Safely search for the car
    local success, result = pcall(function()
        local menu = Player.PlayerGui:WaitForChild("Menu")
        local trading = menu:WaitForChild("Trading")
        local peerToPeer = trading:WaitForChild("PeerToPeer")
        local main = peerToPeer:WaitForChild("Main")
        local inventory = main:WaitForChild("Inventory")
        local list = inventory:WaitForChild("List")
        local scrolling = list:WaitForChild("ScrollingFrame")
        
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name == "Car-AstonMartin12" then
                carButton = item
                carPath = item:GetFullName()
                return item
            end
        end
        return nil
    end)
    
    if not success then
        print("❌ Error: " .. tostring(result))
        return false
    end
    
    if carButton then
        print("✅ FOUND: " .. carPath)
        print("📊 Button Info:")
        print("   Class: " .. carButton.ClassName)
        print("   Visible: " .. tostring(carButton.Visible))
        print("   Active: " .. tostring(carButton.Active))
        
        -- Check what events/properties are available
        print("\n🔍 Checking available properties:")
        
        local propertiesToCheck = {
            "Activated",
            "MouseButton1Click", 
            "MouseButton1Down",
            "MouseButton1Up",
            "Selected",
            "SelectionImageObject",
            "AutoButtonColor",
            "Modal"
        }
        
        for _, prop in ipairs(propertiesToCheck) do
            local success, value = pcall(function()
                return carButton[prop]
            end)
            if success then
                if type(value) == "boolean" then
                    print("   " .. prop .. ": " .. tostring(value))
                elseif value ~= nil then
                    print("   " .. prop .. ": [Exists]")
                end
            end
        end
        
        -- Try to interact with the button
        print("\n🎯 ATTEMPTING INTERACTION...")
        local interactionSuccess = TestClickMethods(carButton)
        
        -- Check if car was added to trade
        wait(2)
        print("\n📊 CHECKING TRADE STATUS...")
        
        local tradeSuccess, tradeResult = pcall(function()
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
        
        if tradeSuccess then
            if #tradeResult > 0 then
                print("✅ CARS IN TRADE OFFER:")
                for _, carName in ipairs(tradeResult) do
                    print("   🚗 " .. carName)
                end
            else
                print("📭 No cars in trade offer")
            end
        else
            print("❌ Could not check trade: " .. tostring(tradeResult))
        end
        
        return interactionSuccess
    else
        print("❌ Car-AstonMartin12 not found in inventory")
        print("💡 Make sure:")
        print("   1. You're in a trade")
        print("   2. The car is in your inventory")
        print("   3. You can see it in the trade window")
        return false
    end
end

-- Try alternative: Look for ANY car
local function TestAnyCar()
    print("\n🔍 LOOKING FOR ANY CAR...")
    
    local foundCars = {}
    
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
                table.insert(foundCars, {
                    Name = item.Name,
                    Object = item,
                    Class = item.ClassName
                })
            end
        end
        return foundCars
    end)
    
    if success then
        if #foundCars > 0 then
            print("✅ FOUND " .. #foundCars .. " CARS:")
            for i, car in ipairs(foundCars) do
                print("   " .. i .. ". " .. car.Name .. " (" .. car.Class .. ")")
            end
            
            -- Try the first car
            print("\n🎯 TESTING FIRST CAR: " .. foundCars[1].Name)
            return TestClickMethods(foundCars[1].Object)
        else
            print("❌ No cars found in inventory")
            return false
        end
    else
        print("❌ Error: " .. tostring(result))
        return false
    end
end

-- Create test UI with options
local function CreateTestUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeTestUI"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "🎮 TRADE INTERACTION TEST"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    
    local button1 = Instance.new("TextButton")
    button1.Text = "🖱️ TEST SPECIFIC CAR"
    button1.Size = UDim2.new(1, -20, 0, 40)
    button1.Position = UDim2.new(0, 10, 0, 40)
    button1.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    button1.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local button2 = Instance.new("TextButton")
    button2.Text = "🔍 TEST ANY CAR"
    button2.Size = UDim2.new(1, -20, 0, 40)
    button2.Position = UDim2.new(0, 10, 0, 90)
    button2.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    button2.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local status = Instance.new("TextLabel")
    status.Text = "Ready to test..."
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 1, -60)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 200, 255)
    status.Font = Enum.Font.Gotham
    status.TextWrapped = true
    
    local function updateStatus(text, color)
        status.Text = text
        status.TextColor3 = color or Color3.fromRGB(200, 200, 255)
    end
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = frame
    corner:Clone().Parent = title
    corner:Clone().Parent = button1
    corner:Clone().Parent = button2
    
    -- Parenting
    title.Parent = frame
    button1.Parent = frame
    button2.Parent = frame
    status.Parent = frame
    frame.Parent = gui
    
    -- Button events
    button1.MouseButton1Click:Connect(function()
        updateStatus("Testing Car-AstonMartin12...", Color3.fromRGB(255, 200, 100))
        button1.Text = "TESTING..."
        spawn(function()
            local success = TestCarInteraction()
            if success then
                updateStatus("✅ Test completed!", Color3.fromRGB(100, 255, 100))
            else
                updateStatus("❌ Test failed", Color3.fromRGB(255, 100, 100))
            end
            wait(2)
            button1.Text = "🖱️ TEST SPECIFIC CAR"
            updateStatus("Ready to test...")
        end)
    end)
    
    button2.MouseButton1Click:Connect(function()
        updateStatus("Testing any car...", Color3.fromRGB(255, 200, 100))
        button2.Text = "TESTING..."
        spawn(function()
            local success = TestAnyCar()
            if success then
                updateStatus("✅ Test completed!", Color3.fromRGB(100, 255, 100))
            else
                updateStatus("❌ Test failed", Color3.fromRGB(255, 100, 100))
            end
            wait(2)
            button2.Text = "🔍 TEST ANY CAR"
            updateStatus("Ready to test...")
        end)
    end)
    
    return gui
end

-- Initialize
CreateTestUI()

print("\n✅ CORRECTED SCRIPT LOADED!")
print("🎮 Use the test panel to try different methods")
print("💡 The script now properly tries to interact with ImageButtons")
