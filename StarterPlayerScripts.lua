-- Trade Click Replicator
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== TRADE CLICK REPLICATOR ===")
print("Goal: Replicate manual click behavior")

-- Get services
local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes

-- Hook ALL remote functions to see what gets called
local originalCalls = {}
local capturedCalls = {}

local function HookAllRemotes()
    print("\n🔗 HOOKING ALL TRADING REMOTES...")
    
    for _, remote in pairs(tradingService:GetChildren()) do
        if remote:IsA("RemoteFunction") then
            originalCalls[remote] = remote.InvokeServer
            
            -- Create hook
            remote.InvokeServer = function(self, ...)
                local args = {...}
                
                -- Record the call
                table.insert(capturedCalls, {
                    remote = remote.Name,
                    args = args,
                    timestamp = os.time(),
                    player = Player.Name
                })
                
                print("\n🎯 CAPTURED REMOTE CALL!")
                print("Remote: " .. remote.Name)
                print("Args: " .. #args)
                
                for i, arg in ipairs(args) do
                    local argType = type(arg)
                    print("  [" .. i .. "] Type: " .. argType)
                    
                    if argType == "string" then
                        print("     Value: \"" .. arg .. "\"")
                    elseif argType == "number" then
                        print("     Value: " .. arg)
                    elseif argType == "table" then
                        print("     Table contents:")
                        for k, v in pairs(arg) do
                            print("       " .. tostring(k) .. " = " .. tostring(v))
                        end
                    end
                end
                
                -- Call original
                return originalCalls[remote](self, ...)
            end
            
            print("✅ Hooked: " .. remote.Name)
        end
    end
end

-- Find Car-AstonMartin12 in inventory and analyze it
local function AnalyzeInventoryCar()
    print("\n🔍 ANALYZING INVENTORY CAR...")
    
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
        print("❌ Car-AstonMartin12 not in inventory")
        return nil
    end
    
    print("✅ Found Car-AstonMartin12 in inventory")
    print("Class: " .. carButton.ClassName)
    
    -- Get ALL data from the button
    print("\n📊 BUTTON DATA ANALYSIS:")
    
    local buttonData = {
        name = carButton.Name,
        class = carButton.ClassName,
        children = {},
        values = {},
        events = {}
    }
    
    -- Get all children
    for _, child in pairs(carButton:GetChildren()) do
        buttonData.children[child.Name] = child.ClassName
        
        if child:IsA("StringValue") then
            buttonData.values[child.Name] = child.Value
            print("  StringValue: " .. child.Name .. " = \"" .. child.Value .. "\"")
        elseif child:IsA("IntValue") then
            buttonData.values[child.Name] = child.Value
            print("  IntValue: " .. child.Name .. " = " .. child.Value)
        elseif child:IsA("RemoteEvent") then
            buttonData.events[child.Name] = true
            print("  RemoteEvent: " .. child.Name)
        end
    end
    
    -- Check for any ClickDetector
    local clickDetector = carButton:FindFirstChildOfClass("ClickDetector")
    if clickDetector then
        print("  ClickDetector found!")
        buttonData.clickDetector = true
    end
    
    return carButton, buttonData
end

-- Monitor what happens during manual click
local function MonitorManualClick()
    print("\n👀 MONITOR MANUAL CLICK INSTRUCTIONS:")
    print("1. I will hook all remotes first")
    print("2. Then YOU click Car-AstonMartin12 in inventory")
    print("3. I will capture what remote gets called")
    print("4. We'll see the EXACT parameters used")
    
    HookAllRemotes()
    
    print("\n✅ READY!")
    print("Now click Car-AstonMartin12 in your inventory")
    print("Watch for 'CAPTURED REMOTE CALL!' output")
    
    local initialCalls = #capturedCalls
    
    -- Wait for click
    for i = 1, 30 do
        wait(1)
        if #capturedCalls > initialCalls then
            print("\n🎉 GOT IT! Captured the click!")
            break
        end
        if i % 5 == 0 then
            print("Still waiting... (" .. i .. "/30 seconds)")
        end
    end
    
    if #capturedCalls == initialCalls then
        print("\n❌ No click captured")
        print("Try clicking the car in inventory")
    end
    
    return capturedCalls
end

-- Try to replicate the captured call
local function ReplicateCapturedCall()
    print("\n🔄 ATTEMPTING TO REPLICATE CAPTURED CALL...")
    
    if #capturedCalls == 0 then
        print("❌ No calls captured yet")
        return false
    end
    
    local lastCall = capturedCalls[#capturedCalls]
    
    print("\n📋 LAST CAPTURED CALL:")
    print("Remote: " .. lastCall.remote)
    print("Args: " .. #lastCall.args)
    
    -- Get the remote object
    local remote = tradingService:FindFirstChild(lastCall.remote)
    if not remote then
        print("❌ Remote not found: " .. lastCall.remote)
        return false
    end
    
    print("\n🧪 REPLICATING THE CALL...")
    
    -- Try to call it with same parameters
    local success, result = pcall(function()
        return remote:InvokeServer(unpack(lastCall.args))
    end)
    
    if success then
        print("✅ REPLICATION SUCCESSFUL!")
        if result then
            print("Result: " .. tostring(result))
        end
        
        -- Try multiple times
        print("\n📦 ATTEMPTING MULTIPLE ADDS...")
        for i = 1, 5 do
            wait(0.2)
            pcall(function()
                remote:InvokeServer(unpack(lastCall.args))
                print("Added copy " .. i)
            end)
        end
        
        return true
    else
        print("❌ Replication failed: " .. tostring(result))
        return false
    end
end

-- Alternative: Simulate the button click directly
local function SimulateButtonClick()
    print("\n🖱️ SIMULATING BUTTON CLICK...")
    
    local carButton, buttonData = AnalyzeInventoryCar()
    if not carButton then return false end
    
    print("\n🎯 SIMULATION METHODS:")
    
    -- Method 1: Direct event firing
    print("\n1. Direct event firing:")
    local events = {"Activated", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up"}
    
    for _, event in ipairs(events) do
        print("  Firing: " .. event)
        local success = pcall(function()
            carButton:Fire(event)
            return true
        end)
        
        if success then
            print("    ✅ Success")
        else
            print("    ❌ Failed")
        end
        wait(0.1)
    end
    
    -- Method 2: Check for RemoteEvents on button
    print("\n2. Checking for RemoteEvents on button...")
    for eventName, _ in pairs(buttonData.events) do
        print("  Found RemoteEvent: " .. eventName)
        
        -- Try to fire it
        local remoteEvent = carButton:FindFirstChild(eventName)
        if remoteEvent then
            print("  Attempting to fire: " .. eventName)
            
            local success, result = pcall(function()
                return remoteEvent:FireServer("add")
            end)
            
            if success then
                print("    ✅ Success")
            else
                print("    ❌ Failed: " .. tostring(result))
            end
            
            wait(0.2)
        end
    end
    
    -- Method 3: Try fireclickdetector if available
    if buttonData.clickDetector then
        print("\n3. Using fireclickdetector...")
        
        local success = pcall(function()
            fireclickdetector(carButton:FindFirstChildOfClass("ClickDetector"))
            return true
        end)
        
        if success then
            print("  ✅ Success")
        else
            print("  ❌ Failed")
        end
    end
    
    -- Check if car was added
    wait(1)
    print("\n🔍 CHECKING TRADE WINDOW...")
    
    pcall(function()
        local main = Player.PlayerGui.Menu.Trading.PeerToPeer.Main
        local localPlayer = main.LocalPlayer
        local scrolling = localPlayer.Content.ScrollingFrame
        
        local carCount = 0
        for _, item in pairs(scrolling:GetChildren()) do
            if item.Name:sub(1, 4) == "Car-" then
                carCount = carCount + 1
                print("  Found: " .. item.Name)
            end
        end
        
        print("Total cars in trade: " .. carCount)
    end)
    
    return true
end

-- Main test sequence
local function RunReplicationTest()
    print("\n🚀 RUNNING REPLICATION TEST...")
    
    -- Step 1: Analyze current state
    AnalyzeInventoryCar()
    
    -- Step 2: Monitor manual click
    wait(1)
    local calls = MonitorManualClick()
    
    if #calls > 0 then
        -- Step 3: Try to replicate
        wait(1)
        local success = ReplicateCapturedCall()
        
        if success then
            print("\n🎉 SUCCESS! We can replicate manual clicks!")
            return true
        end
    end
    
    -- Step 4: Try simulation if capture failed
    wait(1)
    print("\n🔄 TRYING SIMULATION INSTEAD...")
    SimulateButtonClick()
    
    print("\n" .. string.rep("=", 60))
    print("TEST COMPLETE")
    print("Key: We need to capture WHAT happens when you click")
    print(string.rep("=", 60))
    
    return false
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ClickReplicator"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "CLICK REPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    local status = Instance.new("TextLabel")
    status.Text = "Will capture manual click\nThen try to replicate it"
    status.Size = UDim2.new(1, -20, 0, 110)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 230, 255)
    status.TextWrapped = true
    
    local log = Instance.new("ScrollingFrame")
    log.Size = UDim2.new(1, -20, 0, 80)
    log.Position = UDim2.new(0, 10, 0, 170)
    log.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    log.ScrollBarThickness = 6
    
    local logText = Instance.new("TextLabel")
    logText.Size = UDim2.new(1, 0, 2, 0)
    logText.Position = UDim2.new(0, 5, 0, 5)
    logText.BackgroundTransparency = 1
    logText.TextColor3 = Color3.fromRGB(180, 220, 255)
    logText.TextWrapped = true
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.TextYAlignment = Enum.TextYAlignment.Top
    logText.Text = "Waiting for click..."
    
    logText.Parent = log
    
    local testBtn = Instance.new("TextButton")
    testBtn.Text = "🎬 START MONITORING"
    testBtn.Size = UDim2.new(1, -20, 0, 30)
    testBtn.Position = UDim2.new(0, 10, 0, 120)
    testBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    testBtn.MouseButton1Click:Connect(function()
        status.Text = "Monitoring...\nClick Car-AstonMartin12 in inventory!"
        testBtn.Text = "MONITORING..."
        
        spawn(function()
            local calls = MonitorManualClick()
            
            if #calls > 0 then
                logText.Text = "✅ Captured " .. #calls .. " calls\nCheck output window!"
                status.Text = "Captured click!\nCheck output for details"
            else
                logText.Text = "❌ No calls captured\nTry clicking the car"
                status.Text = "No click captured\nTry again"
            end
            
            wait(2)
            testBtn.Text = "🎬 START MONITORING"
        end)
    end)
    
    local replicateBtn = Instance.new("TextButton")
    replicateBtn.Text = "🔄 REPLICATE CALL"
    replicateBtn.Size = UDim2.new(1, -20, 0, 30)
    replicateBtn.Position = UDim2.new(0, 10, 0, 210)
    replicateBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
    replicateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    replicateBtn.MouseButton1Click:Connect(function()
        status.Text = "Replicating captured call..."
        replicateBtn.Text = "REPLICATING..."
        
        spawn(function()
            local success = ReplicateCapturedCall()
            
            if success then
                logText.Text = "✅ Replication successful!\nCheck trade window"
                status.Text = "Replication worked!"
            else
                logText.Text = "❌ Replication failed\nSee output for details"
                status.Text = "Replication failed"
            end
            
            wait(2)
            replicateBtn.Text = "🔄 REPLICATE CALL"
        end)
    end)
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    log.Parent = frame
    testBtn.Parent = frame
    replicateBtn.Parent = frame
    frame.Parent = gui
    
    return logText
end

-- Initialize
CreateUI()

-- Instructions
wait(3)
print("\n=== CLICK REPLICATOR ===")
print("Since you added Car-AstonMartin12 MANUALLY...")
print("We will CAPTURE what happens when you click")
print("Then REPLICATE it automatically!")
print("\n📋 INSTRUCTIONS:")
print("1. Click 'START MONITORING'")
print("2. Click Car-AstonMartin12 in your inventory")
print("3. Watch for 'CAPTURED REMOTE CALL!' output")
print("4. Click 'REPLICATE CALL' to try duplication")
print("\n🎯 This should reveal the SECRET to adding cars!")
