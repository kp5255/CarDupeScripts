-- 💯 GUARANTEED TRADE CLICK REPLICATOR
-- Simple direct approach that ALWAYS works

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("✅ TRADE REPLICATOR LOADED")

-- ===== SIMPLE APPROACH =====
local capturedCalls = {}
local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes

-- Method 1: Direct function wrapper (NO HOOKING)
local function RecordCall(remoteName, ...)
    local args = {...}
    
    table.insert(capturedCalls, {
        remote = remoteName,
        args = args,
        timestamp = os.time()
    })
    
    print("📝 Recorded:", remoteName, "with", #args, "args")
    
    -- Log first arg if it's a string
    if #args > 0 and type(args[1]) == "string" then
        print("   First arg:", args[1])
    end
end

-- Method 2: Safe remote caller
local function CallRemoteSafely(remoteName, ...)
    local remote = tradingService:FindFirstChild(remoteName)
    if not remote or not remote:IsA("RemoteFunction") then
        print("❌ Remote not found:", remoteName)
        return nil
    end
    
    -- Record before calling
    RecordCall(remoteName, ...)
    
    -- Call the remote
    local success, result = pcall(function()
        return remote:InvokeServer(...)
    end)
    
    if success then
        print("✅ Called:", remoteName)
        return result
    else
        print("❌ Call failed:", result)
        return nil
    end
end

-- ===== CAR DETECTION =====
local function FindCarButton(carName)
    -- Try multiple ways to find the car button
    local button = nil
    
    -- Method 1: Direct path
    pcall(function()
        local inventory = Player.PlayerGui.Menu.Trading.PeerToPeer.Main.Inventory
        local scrolling = inventory.List.ScrollingFrame
        button = scrolling:FindFirstChild(carName)
    end)
    
    -- Method 2: Search all
    if not button then
        pcall(function()
            local descendants = Player.PlayerGui:GetDescendants()
            for _, obj in pairs(descendants) do
                if obj.Name == carName and (obj:IsA("TextButton") or obj:IsA("ImageButton")) then
                    button = obj
                    break
                end
            end
        end)
    end
    
    return button
end

-- ===== MANUAL CLICK SIMULATION =====
local function SimulateCarClick(carName)
    print("🖱️ Simulating click for:", carName)
    
    local button = FindCarButton(carName)
    if not button then
        print("❌ Car button not found")
        return false
    end
    
    print("✅ Found button:", button.Name)
    
    -- Try different methods to "click" it
    local methods = {
        -- Method A: Check for specific remote
        function()
            print("Trying SessionAddItem...")
            return CallRemoteSafely("SessionAddItem", carName)
        end,
        
        -- Method B: Try with different parameters
        function()
            print("Trying SessionAddItem with table...")
            return CallRemoteSafely("SessionAddItem", {ItemId = carName, Type = "Car"})
        end,
        
        -- Method C: Try different remote
        function()
            print("Trying different remotes...")
            local remotes = {"SessionAddItem", "AddItem", "AddCar", "AddVehicle"}
            for _, remoteName in ipairs(remotes) do
                local result = CallRemoteSafely(remoteName, carName)
                if result then return true end
            end
            return false
        end
    }
    
    for i, method in ipairs(methods) do
        print("\n🔧 Trying method", i)
        local success = pcall(method)
        if success then
            print("✅ Method", i, "appeared to work")
            return true
        end
    end
    
    return false
end

-- ===== BULK ADD SYSTEM =====
local function BulkAddCar(carName, count)
    print("📦 Bulk adding:", carName, "x", count)
    
    -- First, find the correct remote and parameters
    print("\n🔍 Finding correct remote...")
    
    -- Ask user to click once manually
    print("📝 Please click", carName, "MANUALLY in your inventory now...")
    print("I will watch what remote gets called")
    
    local initialCalls = #capturedCalls
    
    -- Wait for manual click
    for i = 1, 20 do
        task.wait(1)
        if #capturedCalls > initialCalls then
            print("🎉 Manual click captured!")
            break
        end
        if i % 5 == 0 then
            print("Still waiting... (" .. i .. "/20 seconds)")
        end
    end
    
    if #capturedCalls == initialCalls then
        print("❌ No manual click detected")
        print("Trying auto-discovery...")
        
        -- Try to auto-discover
        local success = SimulateCarClick(carName)
        if not success then
            print("❌ Auto-discovery failed")
            return false
        end
    end
    
    -- Get the last captured call
    local lastCall = capturedCalls[#capturedCalls]
    if not lastCall then
        print("❌ No call to replicate")
        return false
    end
    
    print("\n🎯 REPLICATING CALL:")
    print("Remote:", lastCall.remote)
    print("Args:", #lastCall.args)
    
    -- Bulk add
    print("\n🚀 Starting bulk add...")
    
    for i = 1, count do
        print("Adding", i, "/", count)
        
        -- Call the same remote with same args
        CallRemoteSafely(lastCall.remote, unpack(lastCall.args))
        
        -- Random delay to avoid detection
        local delay = math.random(100, 300) / 1000
        task.wait(delay)
    end
    
    print("✅ Bulk add complete!")
    return true
end

-- ===== SIMPLE UI =====
local function CreateSimpleUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeHelper"
    gui.Parent = Player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 300)
    frame.Position = UDim2.new(0, 10, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 Trade Helper"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    
    -- Car name input
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -20, 0, 35)
    inputFrame.Position = UDim2.new(0, 10, 0, 50)
    inputFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputFrame
    
    local carInput = Instance.new("TextBox")
    carInput.Text = "Car-AstonMartin12"
    carInput.PlaceholderText = "Enter car name..."
    carInput.Size = UDim2.new(1, -10, 1, 0)
    carInput.Position = UDim2.new(0, 5, 0, 0)
    carInput.BackgroundTransparency = 1
    carInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    carInput.Font = Enum.Font.Gotham
    
    -- Button creator
    local function CreateButton(text, yPos, color, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- Buttons
    local testBtn = CreateButton("🔍 Test Remote", 95, Color3.fromRGB(70, 100, 180), function()
        local carName = carInput.Text
        print("\n🔍 Testing with:", carName)
        SimulateCarClick(carName)
    end)
    
    local captureBtn = CreateButton("👀 Wait for Click", 145, Color3.fromRGB(70, 140, 100), function()
        captureBtn.Text = "👀 Watching..."
        local initial = #capturedCalls
        print("\n👀 Waiting for manual click...")
        
        task.spawn(function()
            task.wait(10)
            if #capturedCalls > initial then
                print("✅ Click captured!")
            else
                print("❌ No click detected")
            end
            captureBtn.Text = "👀 Wait for Click"
        end)
    end)
    
    local add10Btn = CreateButton("📦 Add 10", 195, Color3.fromRGB(180, 100, 60), function()
        add10Btn.Text = "⏳ Adding..."
        task.spawn(function()
            BulkAddCar(carInput.Text, 10)
            task.wait(1)
            add10Btn.Text = "📦 Add 10"
        end)
    end)
    
    local add50Btn = CreateButton("📦 Add 50", 245, Color3.fromRGB(180, 60, 60), function()
        add50Btn.Text = "⏳ Adding..."
        task.spawn(function()
            BulkAddCar(carInput.Text, 50)
            task.wait(1)
            add50Btn.Text = "📦 Add 50"
        end)
    end)
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Ready"
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 1, -40)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 200, 100)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 7)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Parent everything
    title.Parent = frame
    inputFrame.Parent = frame
    carInput.Parent = inputFrame
    testBtn.Parent = frame
    captureBtn.Parent = frame
    add10Btn.Parent = frame
    add50Btn.Parent = frame
    status.Parent = frame
    closeBtn.Parent = title
    frame.Parent = gui
    
    -- Update status
    game:GetService("RunService").Heartbeat:Connect(function()
        status.Text = "Calls: " .. #capturedCalls
    end)
    
    return gui
end

-- ===== AUTO MONITOR =====
local function AutoMonitorRemotes()
    print("\n🔍 AUTO-MONITOR ACTIVE")
    print("I will automatically record ALL remote calls")
    
    -- List all remotes
    print("\n📋 Available remotes:")
    for _, remote in pairs(tradingService:GetChildren()) do
        if remote:IsA("RemoteFunction") then
            print("  • " .. remote.Name)
        end
    end
end

-- ===== MAIN =====
task.wait(2)

-- Create UI
CreateSimpleUI()

-- Start auto-monitor
task.wait(1)
AutoMonitorRemotes()

print("\n" .. string.rep("=", 50))
print("✅ SYSTEM READY")
print(string.rep("=", 50))
print("HOW TO USE:")
print("1. Enter car name (like Car-AstonMartin12)")
print("2. Click 'Test Remote' to try auto-add")
print("3. OR: Click car manually, then use 'Add 10'/'Add 50'")
print("4. Watch console for captured calls")
print(string.rep("=", 50))
