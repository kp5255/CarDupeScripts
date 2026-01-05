-- 🎯 CAR DUPLICATION SYSTEM - CLEAN VERSION
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CAR DUPLICATION SYSTEM")
print("=" .. string.rep("=", 50))

-- ===== GET CAR DATA =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

local function getCars()
    local success, result = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(result) == "table" then
        print("✅ Loaded " .. #result .. " cars")
        return result
    else
        print("❌ Failed to load cars")
        return {}
    end
end

-- ===== FIND CLAIM REMOTE =====
local function findClaimRemote()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            print("✅ Found ClaimGiveawayCar remote")
            return obj
        end
    end
    
    -- If not found, look for any similar remote
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("claim") or name:find("give") or name:find("get") then
                print("✅ Found remote: " .. obj.Name)
                return obj
            end
        end
    end
    
    print("❌ No claim remote found")
    return nil
end

-- ===== SIMPLE DUPLICATION =====
local function simpleDuplication()
    print("\n🚀 Starting simple duplication...")
    
    -- Get cars
    local cars = getCars()
    if #cars == 0 then return end
    
    -- Find remote
    local claimRemote = findClaimRemote()
    if not claimRemote then return end
    
    -- Use first car
    local car = cars[1]
    print("🎯 Using car: " .. tostring(car.Name or car.name or "Car 1"))
    
    -- Send a few requests
    for i = 1, 5 do
        pcall(function()
            claimRemote:FireServer(car)
            print("📤 Sent request " .. i)
        end)
        task.wait(0.1)
    end
    
    print("✅ Sent 5 requests")
end

-- ===== CREATE SIMPLE UI =====
local function createSimpleUI()
    -- Destroy old UI if exists
    if player:FindFirstChild("PlayerGui") then
        local oldGui = player.PlayerGui:FindFirstChild("CarDupe")
        if oldGui then
            oldGui:Destroy()
        end
    end
    
    -- Create GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarDupe"
    gui.Parent = player.PlayerGui
    
    -- Main frame
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 200)
    main.Position = UDim2.new(0.5, -150, 0.5, -100)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 Car Duplicator"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Text = "Ready to duplicate"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Buttons
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Name = "DupeBtn"
    dupeBtn.Text = "⚡ DUPLICATE"
    dupeBtn.Size = UDim2.new(1, -20, 0, 40)
    dupeBtn.Position = UDim2.new(0, 10, 0, 120)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.GothamBold
    dupeBtn.TextSize = 16
    dupeBtn.Parent = main
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = title
    
    -- Round corners
    local function roundCorners(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    roundCorners(main)
    roundCorners(title)
    roundCorners(status)
    roundCorners(dupeBtn)
    roundCorners(closeBtn)
    
    -- Button actions
    dupeBtn.MouseButton1Click:Connect(function()
        dupeBtn.Text = "WORKING..."
        status.Text = "Starting duplication...\nPlease wait"
        
        task.spawn(function()
            simpleDuplication()
            
            status.Text = "✅ Duplication attempt complete!\nCheck your garage"
            dupeBtn.Text = "⚡ DUPLICATE"
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Make draggable
    local dragging = false
    local dragStart, frameStart
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = main.Position
        end
    end)
    
    title.InputEnded:Connect(function()
        dragging = false
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    print("✅ UI created successfully")
    return gui
end

-- ===== TEST REMOTE =====
local function testRemote()
    print("\n🔍 Testing remote...")
    
    local cars = getCars()
    if #cars == 0 then return end
    
    local claimRemote = findClaimRemote()
    if not claimRemote then return end
    
    local car = cars[1]
    print("🚗 Testing with car: " .. tostring(car.Name or car.name or "Car 1"))
    
    -- Test single request
    local success = pcall(function()
        claimRemote:FireServer(car)
        return true
    end)
    
    if success then
        print("✅ Remote accepts car data")
        return true
    else
        print("❌ Remote rejected car data")
        return false
    end
end

-- ===== MANUAL TEST =====
local function manualTest()
    print("\n🔧 MANUAL TEST MODE")
    print("=" .. string.rep("=", 50))
    
    -- List all remotes
    print("\n📡 ALL REMOTES:")
    local remoteCount = 0
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            remoteCount = remoteCount + 1
            if remoteCount <= 10 then
                print("   " .. obj.Name .. " (" .. obj:GetFullName() .. ")")
            end
        end
    end
    print("   ... and " .. (remoteCount - 10) .. " more")
    
    -- List car data
    print("\n🚗 YOUR CARS:")
    local cars = getCars()
    for i, car in ipairs(cars) do
        if i <= 5 then
            print("   " .. i .. ". " .. tostring(car.Name or car.name or "Car " .. i))
        end
    end
    if #cars > 5 then
        print("   ... and " .. (#cars - 5) .. " more")
    end
    
    -- Test specific remote
    print("\n🎯 TESTING CLAIMGIVEAWAYCAR:")
    testRemote()
end

-- ===== MAIN =====
print("\n🚀 Initializing system...")

-- Run manual test first
manualTest()

-- Create UI
local success, errorMsg = pcall(function()
    createSimpleUI()
end)

if not success then
    print("❌ Failed to create UI: " .. tostring(errorMsg))
    print("\n💡 Running in console mode only...")
    
    -- Run duplication directly
    task.wait(2)
    print("\n🎯 Press Enter to run duplication...")
    
    -- In case UI fails, run duplication directly
    task.wait(5)
    simpleDuplication()
else
    print("✅ UI created successfully")
end

print("\n🎯 SYSTEM READY!")
print("\n💡 Commands:")
print("• Click DUPLICATE button")
print("• Check your garage")
print("• Wait 10 seconds between attempts")
