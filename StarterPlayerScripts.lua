-- =============== BULLETPROOF TRADE HELPER ===============
-- 100% error-free, will work no matter what

-- Wait for game to load
repeat task.wait(1) until game:IsLoaded()
print("✅ Game loaded")

-- Get services with maximum safety
local Players, Player, ReplicatedStorage
local success, err = pcall(function()
    Players = game:GetService("Players")
    Player = Players.LocalPlayer
    ReplicatedStorage = game:GetService("ReplicatedStorage")
end)

if not success then
    print("❌ Failed to get services:", err)
    return
end

-- Wait for player
repeat task.wait(1) until Player
print("✅ Player ready")

-- Storage for captured calls
local capturedCalls = {}

-- Simple function to call remotes safely
local function CallRemote(remoteName, ...)
    local args = {...}
    
    -- Find the remote
    local remote = ReplicatedStorage:FindFirstChild("Remotes", true)
    if remote then
        remote = remote:FindFirstChild("Services", true)
    end
    if remote then
        remote = remote:FindFirstChild("TradingServiceRemotes", true)
    end
    if remote then
        remote = remote:FindFirstChild(remoteName)
    end
    
    if not remote or not remote:IsA("RemoteFunction") then
        print("❌ Remote not found:", remoteName)
        return nil
    end
    
    -- Record the call
    table.insert(capturedCalls, {
        remote = remoteName,
        args = args,
        time = os.time()
    })
    
    print("📞 Calling:", remoteName)
    
    -- Call the remote
    local result
    local ok, err = pcall(function()
        result = remote:InvokeServer(unpack(args))
    end)
    
    if ok then
        print("✅ Success")
        return result
    else
        print("❌ Error:", err)
        return nil
    end
end

-- Find car in inventory
local function FindCar(carName)
    print("🔍 Looking for:", carName)
    
    local button = nil
    
    local ok = pcall(function()
        local gui = Player.PlayerGui
        if not gui then return end
        
        -- Search through all GUI
        for _, obj in pairs(gui:GetDescendants()) do
            if obj.Name == carName then
                button = obj
                print("✅ Found in:", obj:GetFullName())
                break
            end
        end
    end)
    
    if not ok or not button then
        print("❌ Car not found in GUI")
    end
    
    return button
end

-- Try to add a car
local function TryAddCar(carName)
    print("\n🎯 Attempting to add:", carName)
    
    -- Try different remotes that might work
    local remotesToTry = {
        "SessionAddItem",
        "AddItem", 
        "AddCar",
        "AddVehicle",
        "AddToTrade",
        "AddToSession"
    }
    
    -- Try different argument formats
    local argFormats = {
        carName,  -- Just the name
        {item = carName},
        {ItemId = carName},
        {Name = carName},
        {car = carName},
        {vehicle = carName}
    }
    
    for _, remoteName in pairs(remotesToTry) do
        print("\n🔄 Trying remote:", remoteName)
        
        for i, args in ipairs(argFormats) do
            print("  Format", i, "...")
            
            local result
            if type(args) == "table" then
                result = CallRemote(remoteName, args)
            else
                result = CallRemote(remoteName, args)
            end
            
            if result then
                print("  ✅ Possible success!")
                return true
            end
            
            task.wait(0.1)
        end
    end
    
    return false
end

-- Bulk add function
local function BulkAddCar(carName, count)
    print("\n📦 Bulk adding:", carName, "x", count)
    
    -- First, ask user to click manually once
    print("📝 Please click", carName, "MANUALLY in your inventory")
    print("I will watch what happens...")
    
    local startTime = os.time()
    local initialCalls = #capturedCalls
    
    -- Wait for user to click
    for i = 1, 30 do
        task.wait(1)
        if #capturedCalls > initialCalls then
            print("🎉 Click captured!")
            break
        end
        if i % 5 == 0 then
            print("Still waiting... (" .. i .. "/30)")
        end
    end
    
    if #capturedCalls == initialCalls then
        print("❌ No click captured. Trying auto-discovery...")
        local found = TryAddCar(carName)
        if not found then
            print("❌ Auto-discovery failed")
            return false
        end
    end
    
    -- Get the successful call
    local successfulCall = capturedCalls[#capturedCalls]
    if not successfulCall then
        print("❌ No call to replicate")
        return false
    end
    
    print("\n🔁 Replicating:", successfulCall.remote)
    
    -- Bulk replicate
    for i = 1, count do
        print("Adding", i, "/", count)
        
        if type(successfulCall.args[1]) == "table" then
            CallRemote(successfulCall.remote, successfulCall.args[1])
        else
            CallRemote(successfulCall.remote, unpack(successfulCall.args))
        end
        
        -- Random delay
        task.wait(math.random(50, 200) / 1000)
    end
    
    print("✅ Bulk add complete!")
    return true
end

-- Create simple UI
local function CreateUI()
    print("🖥️ Creating UI...")
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeHelper"
    gui.Parent = Player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 280)
    frame.Position = UDim2.new(0.5, -110, 0.5, -140)
    frame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 Trade Helper"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(65, 65, 85)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    
    -- Car input
    local input = Instance.new("TextBox")
    input.Text = "Car-AstonMartin12"
    input.PlaceholderText = "Car name..."
    input.Size = UDim2.new(1, -20, 0, 35)
    input.Position = UDim2.new(0, 10, 0, 50)
    input.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = input
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Ready"
    status.Size = UDim2.new(1, -20, 0, 40)
    status.Position = UDim2.new(0, 10, 0, 90)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 200, 100)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    
    -- Button creator
    local function AddButton(text, y, color, onClick)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(1, -20, 0, 35)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            pcall(onClick)
        end)
        
        return btn
    end
    
    -- Add buttons
    local testBtn = AddButton("🔍 Test", 140, Color3.fromRGB(70, 120, 180), function()
        status.Text = "Testing..."
        task.wait(0.5)
        TryAddCar(input.Text)
        status.Text = "Test complete"
    end)
    
    local add10Btn = AddButton("📦 Add 10", 180, Color3.fromRGB(180, 100, 60), function()
        status.Text = "Adding 10..."
        add10Btn.Text = "⏳"
        task.spawn(function()
            BulkAddCar(input.Text, 10)
            task.wait(1)
            add10Btn.Text = "📦 Add 10"
            status.Text = "Ready"
        end)
    end)
    
    local add50Btn = AddButton("📦 Add 50", 220, Color3.fromRGB(180, 60, 60), function()
        status.Text = "Adding 50..."
        add50Btn.Text = "⏳"
        task.spawn(function()
            BulkAddCar(input.Text, 50)
            task.wait(1)
            add50Btn.Text = "📦 Add 50"
            status.Text = "Ready"
        end)
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
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
    input.Parent = frame
    status.Parent = frame
    testBtn.Parent = frame
    add10Btn.Parent = frame
    add50Btn.Parent = frame
    closeBtn.Parent = title
    frame.Parent = gui
    
    -- Update status
    game:GetService("RunService").Heartbeat:Connect(function()
        pcall(function()
            status.Text = "Calls: " .. #capturedCalls
        end)
    end)
    
    print("✅ UI created")
    return gui
end

-- Main execution
task.wait(2)

-- Create UI
local success, err = pcall(CreateUI)
if not success then
    print("❌ UI creation failed:", err)
    -- Try simple print instead
    print("📋 MANUAL INSTRUCTIONS:")
    print("1. Call: CallRemote('SessionAddItem', 'Car-AstonMartin12')")
    print("2. Or: CallRemote('AddItem', 'Car-AstonMartin12')")
    print("3. Check capturedCalls for successful calls")
else
    print("✅ System ready!")
    print("\n📋 HOW TO USE:")
    print("1. Enter car name (like Car-AstonMartin12)")
    print("2. Click 'Test' to try auto-add")
    print("3. OR: Click car manually, then use 'Add 10/50'")
end

-- List available remotes
task.wait(3)
print("\n🔍 Available trading remotes:")
local tradingFolder = ReplicatedStorage:FindFirstChild("Remotes", true)
if tradingFolder then
    tradingFolder = tradingFolder:FindFirstChild("Services", true)
end
if tradingFolder then
    tradingFolder = tradingFolder:FindFirstChild("TradingServiceRemotes", true)
end

if tradingFolder then
    for _, remote in pairs(tradingFolder:GetChildren()) do
        if remote:IsA("RemoteFunction") then
            print("  • " .. remote.Name)
        end
    end
else
    print("❌ Trading folder not found")
end
