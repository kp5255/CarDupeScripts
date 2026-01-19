-- 🎯 TRADE MECHANISM ANALYZER
-- Analyzes HOW cars are manually added to trade

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

print("🎯 TRADE MECHANISM ANALYZER")

-- ===== MONITOR MANUAL ACTIONS =====
local function MonitorManualActions()
    print("\n🔍 MONITORING MANUAL INTERACTIONS")
    print("💡 Manually add a car to trade while this is running...")
    
    local lastClickedObject = nil
    local clickHistory = {}
    
    -- Monitor ALL mouse clicks
    UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not processed then
                -- Get what was clicked
                local mousePos = input.Position
                
                -- Try to find what object was clicked
                local success, target = pcall(function()
                    -- This is tricky - we need to check all GUI objects
                    local playerGui = Player.PlayerGui
                    if playerGui then
                        -- Check all screens
                        for _, screen in pairs(playerGui:GetDescendants()) do
                            if screen:IsA("GuiObject") and screen.Visible then
                                local absPos = screen.AbsolutePosition
                                local absSize = screen.AbsoluteSize
                                
                                if mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                                   mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y then
                                   
                                    -- Check if it's a car button
                                    if screen.Name:find("Car") then
                                        print("\n🖱️ CLICKED CAR BUTTON:")
                                        print("   Name: " .. screen.Name)
                                        print("   Class: " .. screen.ClassName)
                                        print("   Path: " .. screen:GetFullName())
                                        
                                        lastClickedObject = screen
                                        table.insert(clickHistory, {
                                            Time = tick(),
                                            Object = screen.Name,
                                            Path = screen:GetFullName()
                                        })
                                        
                                        -- Analyze what happens next
                                        spawn(function()
                                            wait(0.5)
                                            CheckTradeStateAfterClick(screen.Name)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end)
                
                if not success then
                    print("❌ Error tracking click: " .. tostring(target))
                end
            end
        end
    end)
    
    -- Return monitoring controls
    return {
        GetLastClick = function() return lastClickedObject end,
        GetHistory = function() return clickHistory end,
        ClearHistory = function() clickHistory = {} end
    }
end

-- ===== CHECK TRADE STATE AFTER CLICK =====
local function CheckTradeStateAfterClick(carName)
    print("\n📊 CHECKING TRADE STATE...")
    
    -- Check inventory (List)
    local inventoryCars = {}
    local success1, result1 = pcall(function()
        local menu = Player.PlayerGui.Menu
        local trading = menu.Trading
        local peerToPeer = trading.PeerToPeer
        local main = peerToPeer.Main
        local inventory = main.Inventory
        local list = inventory.List
        local scrolling = list.ScrollingFrame
        
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name:sub(1, 4) == "Car-" then
                table.insert(inventoryCars, item.Name)
            end
        end
        return inventoryCars
    end)
    
    -- Check trade offer (LocalPlayer)
    local offerCars = {}
    local success2, result2 = pcall(function()
        local menu = Player.PlayerGui.Menu
        local trading = menu.Trading
        local peerToPeer = trading.PeerToPeer
        local main = peerToPeer.Main
        local localPlayer = main.LocalPlayer
        local content = localPlayer.Content
        local scrolling = content.ScrollingFrame
        
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name:sub(1, 4) == "Car-" then
                table.insert(offerCars, item.Name)
            end
        end
        return offerCars
    end)
    
    print("📦 INVENTORY CARS: " .. #inventoryCars)
    print("📤 OFFER CARS: " .. #offerCars)
    
    -- Check if the clicked car moved
    local inInventory = false
    local inOffer = false
    
    for _, car in ipairs(inventoryCars) do
        if car == carName then
            inInventory = true
            break
        end
    end
    
    for _, car in ipairs(offerCars) do
        if car == carName then
            inOffer = true
            break
        end
    end
    
    if inOffer then
        print("✅ " .. carName .. " is NOW in your trade offer!")
    elseif inInventory then
        print("📦 " .. carName .. " is still in inventory")
    else
        print("❓ " .. carName .. " not found in either location")
    end
    
    return {
        InInventory = inInventory,
        InOffer = inOffer,
        InventoryCount = #inventoryCars,
        OfferCount = #offerCars
    }
end

-- ===== ANALYZE TRADE FLOW =====
local function AnalyzeTradeFlow()
    print("\n🔍 ANALYZING TRADE FLOW MECHANISM")
    
    -- Check for drag-and-drop indicators
    print("🔄 Looking for drag-and-drop system...")
    
    local foundDragElements = {}
    
    local success, result = pcall(function()
        local menu = Player.PlayerGui.Menu
        local trading = menu.Trading
        
        -- Look for draggable elements
        for _, child in pairs(trading:GetDescendants()) do
            if child:IsA("GuiObject") then
                -- Check for drag properties
                if child.Active then
                    table.insert(foundDragElements, {
                        Name = child.Name,
                        Class = child.ClassName,
                        Draggable = child.Draggable,
                        Active = child.Active,
                        Path = child:GetFullName()
                    })
                end
            end
        end
        return foundDragElements
    end)
    
    if success and #foundDragElements > 0 then
        print("✅ Found " .. #foundDragElements .. " interactive elements:")
        for _, elem in ipairs(foundDragElements) do
            print("   • " .. elem.Name .. " (" .. elem.Class .. ")")
            print("     Draggable: " .. tostring(elem.Draggable))
            print("     Active: " .. tostring(elem.Active))
        end
    else
        print("❌ No draggable elements found")
    end
    
    -- Check for RemoteEvents used in trading
    print("\n📡 Looking for trade RemoteEvents...")
    
    local foundRemotes = {}
    
    local success2, result2 = pcall(function()
        -- Check common locations
        local locations = {
            Player.PlayerGui,
            game:GetService("ReplicatedStorage"),
            game:GetService("StarterGui")
        }
        
        for _, location in pairs(locations) do
            if location then
                for _, child in pairs(location:GetDescendants()) do
                    if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                        local nameLower = child.Name:lower()
                        if nameLower:find("trade") or nameLower:find("offer") or 
                           nameLower:find("invent") or nameLower:find("item") then
                            table.insert(foundRemotes, {
                                Name = child.Name,
                                Type = child.ClassName,
                                Path = child:GetFullName()
                            })
                        end
                    end
                end
            end
        end
        return foundRemotes
    end)
    
    if success2 and #foundRemotes > 0 then
        print("✅ Found " .. #foundRemotes .. " trade-related remotes:")
        for _, remote in ipairs(foundRemotes) do
            print("   • " .. remote.Name .. " (" .. remote.Type .. ")")
        end
    else
        print("❌ No trade remotes found")
    end
    
    return {
        DragElements = foundDragElements,
        Remotes = foundRemotes
    }
end

-- ===== TRACK CAR MOVEMENT =====
local function TrackCarMovement()
    print("\n📊 TRACKING CAR MOVEMENT BETWEEN INVENTORY AND OFFER")
    
    local lastInventoryState = {}
    local lastOfferState = {}
    
    -- Function to get current state
    local function getCurrentState()
        local inventoryCars = {}
        local offerCars = {}
        
        pcall(function()
            -- Inventory cars
            local menu = Player.PlayerGui.Menu
            local trading = menu.Trading
            local peerToPeer = trading.PeerToPeer
            local main = peerToPeer.Main
            local inventory = main.Inventory
            local list = inventory.List
            local scrolling = list.ScrollingFrame
            
            for _, item in pairs(scrolling:GetChildren()) do
                if item.Name:sub(1, 4) == "Car-" then
                    table.insert(inventoryCars, item.Name)
                end
            end
            
            -- Offer cars
            local localPlayer = main.LocalPlayer
            local content = localPlayer.Content
            local offerScrolling = content.ScrollingFrame
            
            for _, item in pairs(offerScrolling:GetChildren()) do
                if item.Name:sub(1, 4) == "Car-" then
                    table.insert(offerCars, item.Name)
                end
            end
        end)
        
        return {
            Inventory = inventoryCars,
            Offer = offerCars
        }
    end
    
    -- Monitor for changes
    local function checkForChanges()
        local current = getCurrentState()
        
        -- Check for cars moved TO offer
        for _, car in ipairs(current.Offer) do
            local wasInInventory = false
            for _, oldCar in ipairs(lastInventoryState) do
                if oldCar == car then
                    wasInInventory = true
                    break
                end
            end
            
            if wasInInventory then
                print("🚗 MOVED TO OFFER: " .. car)
            end
        end
        
        -- Check for cars moved FROM offer
        for _, car in ipairs(lastOfferState) do
            local stillInOffer = false
            for _, newCar in ipairs(current.Offer) do
                if newCar == car then
                    stillInOffer = true
                    break
                end
            end
            
            if not stillInOffer then
                print("↩️ REMOVED FROM OFFER: " .. car)
            end
        end
        
        -- Update state
        lastInventoryState = current.Inventory
        lastOfferState = current.Offer
    end
    
    -- Initial state
    local initialState = getCurrentState()
    lastInventoryState = initialState.Inventory
    lastOfferState = initialState.Offer
    
    print("📦 Initial inventory: " .. #lastInventoryState .. " cars")
    print("📤 Initial offer: " .. #lastOfferState .. " cars")
    
    -- Start monitoring
    spawn(function()
        while wait(0.5) do
            checkForChanges()
        end
    end)
    
    return {
        GetState = getCurrentState,
        GetInventory = function() return lastInventoryState end,
        GetOffer = function() return lastOfferState end
    }
end

-- ===== CREATE ANALYSIS UI =====
local function CreateAnalysisUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TradeAnalyzerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 450)
    MainFrame.Position = UDim2.new(0.6, 0, 0.1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🔍 TRADE MECHANISM ANALYZER"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    
    local Status = Instance.new("TextLabel")
    Status.Text = "Ready to analyze..."
    Status.Size = UDim2.new(1, -20, 0, 60)
    Status.Position = UDim2.new(0, 10, 0, 50)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(200, 200, 255)
    Status.Font = Enum.Font.Gotham
    Status.TextWrapped = true
    
    -- Buttons
    local MonitorBtn = Instance.new("TextButton")
    MonitorBtn.Text = "🖱️ START CLICK MONITOR"
    MonitorBtn.Size = UDim2.new(1, -20, 0, 40)
    MonitorBtn.Position = UDim2.new(0, 10, 0, 120)
    MonitorBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    MonitorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local AnalyzeBtn = Instance.new("TextButton")
    AnalyzeBtn.Text = "🔧 ANALYZE FLOW"
    AnalyzeBtn.Size = UDim2.new(1, -20, 0, 40)
    AnalyzeBtn.Position = UDim2.new(0, 10, 0, 170)
    AnalyzeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    AnalyzeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local TrackBtn = Instance.new("TextButton")
    TrackBtn.Text = "📊 TRACK MOVEMENT"
    TrackBtn.Size = UDim2.new(1, -20, 0, 40)
    TrackBtn.Position = UDim2.new(0, 10, 0, 220)
    TrackBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    TrackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local TestBtn = Instance.new("TextButton")
    TestBtn.Text = "🎯 TEST CLICK NOW"
    TestBtn.Size = UDim2.new(1, -20, 0, 40)
    TestBtn.Position = UDim2.new(0, 10, 0, 270)
    TestBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
    TestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Log Display
    local LogFrame = Instance.new("ScrollingFrame")
    LogFrame.Size = UDim2.new(1, -20, 0, 100)
    LogFrame.Position = UDim2.new(0, 10, 1, -110)
    LogFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    LogFrame.BorderSizePixel = 0
    LogFrame.ScrollBarThickness = 6
    LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local LogLayout = Instance.new("UIListLayout")
    LogLayout.Padding = UDim.new(0, 5)
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = Title
    corner:Clone().Parent = MonitorBtn
    corner:Clone().Parent = AnalyzeBtn
    corner:Clone().Parent = TrackBtn
    corner:Clone().Parent = TestBtn
    corner:Clone().Parent = LogFrame
    
    -- Parent
    Title.Parent = MainFrame
    Status.Parent = MainFrame
    MonitorBtn.Parent = MainFrame
    AnalyzeBtn.Parent = MainFrame
    TrackBtn.Parent = MainFrame
    TestBtn.Parent = MainFrame
    LogLayout.Parent = LogFrame
    LogFrame.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Variables
    local isMonitoring = false
    local monitorControls = nil
    local tracker = nil
    
    local function updateStatus(text, color)
        Status.Text = text
        Status.TextColor3 = color or Color3.fromRGB(200, 200, 255)
    end
    
    local function addLog(text, color)
        local label = Instance.new("TextLabel")
        label.Text = text
        label.Size = UDim2.new(0.95, 0, 0, 20)
        label.Position = UDim2.new(0.025, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = color or Color3.fromRGB(200, 200, 255)
        label.Font = Enum.Font.Code
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = LogFrame
        
        -- Auto-scroll
        wait()
        LogFrame.CanvasPosition = Vector2.new(0, LogFrame.AbsoluteCanvasSize.Y)
    end
    
    local function clearLog()
        for _, child in pairs(LogFrame:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
    end
    
    -- Button events
    MonitorBtn.MouseButton1Click:Connect(function()
        if not isMonitoring then
            updateStatus("🖱️ Monitoring clicks... Manually add a car", Color3.fromRGB(255, 200, 100))
            addLog("=== CLICK MONITOR STARTED ===", Color3.fromRGB(255, 255, 100))
            addLog("Manually click on a car button now...", Color3.fromRGB(200, 200, 255))
            
            monitorControls = MonitorManualActions()
            isMonitoring = true
            MonitorBtn.Text = "🛑 STOP MONITOR"
            MonitorBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        else
            updateStatus("Click monitoring stopped", Color3.fromRGB(200, 200, 255))
            addLog("=== CLICK MONITOR STOPPED ===", Color3.fromRGB(255, 100, 100))
            
            isMonitoring = false
            MonitorBtn.Text = "🖱️ START CLICK MONITOR"
            MonitorBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
        end
    end)
    
    AnalyzeBtn.MouseButton1Click:Connect(function()
        updateStatus("Analyzing trade flow...", Color3.fromRGB(255, 200, 100))
        clearLog()
        addLog("=== TRADE FLOW ANALYSIS ===", Color3.fromRGB(255, 255, 100))
        
        local analysis = AnalyzeTradeFlow()
        
        if #analysis.DragElements > 0 then
            addLog("Found " .. #analysis.DragElements .. " interactive elements:", Color3.fromRGB(100, 255, 100))
            for _, elem in ipairs(analysis.DragElements) do
                addLog("  • " .. elem.Name, Color3.fromRGB(180, 255, 180))
            end
        end
        
        if #analysis.Remotes > 0 then
            addLog("Found " .. #analysis.Remotes .. " remotes:", Color3.fromRGB(100, 200, 255))
            for _, remote in ipairs(analysis.Remotes) do
                addLog("  • " .. remote.Name .. " (" .. remote.Type .. ")", Color3.fromRGB(180, 220, 255))
            end
        end
        
        updateStatus("Analysis complete", Color3.fromRGB(100, 255, 100))
    end)
    
    TrackBtn.MouseButton1Click:Connect(function()
        if not tracker then
            updateStatus("Tracking car movement...", Color3.fromRGB(255, 200, 100))
            clearLog()
            addLog("=== CAR MOVEMENT TRACKER ===", Color3.fromRGB(255, 255, 100))
            addLog("Will show when cars move between inventory and offer", Color3.fromRGB(200, 200, 255))
            
            tracker = TrackCarMovement()
            TrackBtn.Text = "🛑 STOP TRACKING"
            TrackBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        else
            updateStatus("Movement tracking stopped", Color3.fromRGB(200, 200, 255))
            addLog("=== TRACKING STOPPED ===", Color3.fromRGB(255, 100, 100))
            
            tracker = nil
            TrackBtn.Text = "📊 TRACK MOVEMENT"
            TrackBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        end
    end)
    
    TestBtn.MouseButton1Click:Connect(function()
        updateStatus("Testing current trade state...", Color3.fromRGB(255, 200, 100))
        clearLog()
        addLog("=== TRADE STATE TEST ===", Color3.fromRGB(255, 255, 100))
        
        local state = CheckTradeStateAfterClick("Test")
        
        addLog("Inventory: " .. state.InventoryCount .. " cars", 
               state.InventoryCount > 0 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
        addLog("Offer: " .. state.OfferCount .. " cars", 
               state.OfferCount > 0 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
        
        updateStatus("Test complete", Color3.fromRGB(100, 255, 100))
    end)
    
    return ScreenGui
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("🎯 TRADE MECHANISM ANALYZER")
print("📍 This will help understand HOW cars are manually added")
print("💡 Use the UI to monitor and analyze the trade process")
print(string.rep("=", 60))

-- Create UI
CreateAnalysisUI()

print("\n✅ Analysis UI created!")
print("💡 Features:")
print("   1. 🖱️ Monitor clicks - See what happens when YOU click")
print("   2. 🔧 Analyze flow - Find drag elements and remotes")
print("   3. 📊 Track movement - Watch cars move between sections")
print("   4. 🎯 Test state - Check current inventory/offer counts")
print("\n🎮 Manually add a car while monitoring to see the mechanism!")-- Trade Interaction Test - ACTUAL CLICK VERSION
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

