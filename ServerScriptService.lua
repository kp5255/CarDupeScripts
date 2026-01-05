-- 🎯 WORKING CAR DUPLICATION SYSTEM
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CAR DUPLICATION SYSTEM LOADED")

-- ===== DUPLICATION FUNCTIONS =====
local function getCars()
    local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
    
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(cars) == "table" then
        return cars
    end
    return {}
end

local function findClaimRemote()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            return obj
        end
    end
    return nil
end

local function runDuplication()
    print("\n🚀 Starting duplication...")
    
    local cars = getCars()
    if #cars == 0 then
        print("❌ No cars found")
        return "No cars found"
    end
    
    local claimRemote = findClaimRemote()
    if not claimRemote then
        print("❌ ClaimGiveawayCar not found")
        return "Remote not found"
    end
    
    print("✅ Found " .. #cars .. " cars")
    print("🎯 Using car: " .. tostring(cars[1].Name or cars[1].name or "Car 1"))
    
    -- Send requests with natural timing
    for i = 1, 5 do
        pcall(function()
            claimRemote:FireServer(cars[1])
        end)
        print("📤 Sent request " .. i)
        task.wait(math.random(500, 1500) / 1000)
    end
    
    print("✅ Duplication attempt complete")
    return "Sent 5 requests"
end

-- ===== CREATE WORKING UI =====
local function createUI()
    -- Wait for PlayerGui
    while not player:FindFirstChild("PlayerGui") do
        task.wait(0.1)
    end
    
    -- Remove old UI
    local oldUI = player.PlayerGui:FindFirstChild("CarDupeUI")
    if oldUI then oldUI:Destroy() end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarDupeUI"
    gui.Parent = player.PlayerGui
    gui.ResetOnSpawn = false
    
    -- Main frame (BLUE for visibility)
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 200)
    main.Position = UDim2.new(0.5, -150, 0.5, -100)
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 255)  -- BLUE
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title (RED for contrast)
    local title = Instance.new("TextLabel")
    title.Text = "🚗 CAR DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)  -- RED
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    -- Status (GREEN)
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Text = "Ready to duplicate"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(0, 255, 0)  -- GREEN
    status.TextColor3 = Color3.new(0, 0, 0)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Button (YELLOW)
    local button = Instance.new("TextButton")
    button.Text = "⚡ START DUPLICATION"
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 120)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 0)  -- YELLOW
    button.TextColor3 = Color3.new(0, 0, 0)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = main
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)  -- PINK
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = title
    
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
    
    -- Button click event
    button.MouseButton1Click:Connect(function()
        button.Text = "WORKING..."
        status.Text = "Starting duplication...\nPlease wait"
        
        task.spawn(function()
            local result = runDuplication()
            status.Text = "✅ " .. result .. "\nCheck your garage!"
            button.Text = "⚡ START DUPLICATION"
        end)
    end)
    
    -- Close button event
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    print("✅ UI created - Look for BLUE window!")
    return gui
end

-- ===== MAIN =====
print("\n🚀 Creating UI...")
createUI()

print("\n✅ SYSTEM READY!")
print("💡 Look for a BLUE window with:")
print("• RED title bar")
print("• GREEN status area")
print("• YELLOW button")
print("• PINK close button")

print("\n🎯 Click the YELLOW button to start!")
