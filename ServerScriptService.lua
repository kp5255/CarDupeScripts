-- 🎯 STEALTH CAR DUPLICATION - WORKING UI VERSION
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 STEALTH CAR SYSTEM LOADED")

-- ===== CREATE SIMPLE WORKING UI =====
local function createWorkingUI()
    -- Wait for PlayerGui
    while not player:FindFirstChild("PlayerGui") do
        task.wait(0.1)
    end
    
    -- Remove old UI if exists
    local oldUI = player.PlayerGui:FindFirstChild("CarDupeUI")
    if oldUI then
        oldUI:Destroy()
    end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CarDupeUI"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "🚗 Car Tools"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = mainFrame
    
    -- Status label
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Text = "Ready to use"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = mainFrame
    
    -- Button
    local actionBtn = Instance.new("TextButton")
    actionBtn.Name = "ActionButton"
    actionBtn.Text = "⚡ OPTIMIZE CARS"
    actionBtn.Size = UDim2.new(1, -20, 0, 40)
    actionBtn.Position = UDim2.new(0, 10, 0, 120)
    actionBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    actionBtn.TextColor3 = Color3.new(1, 1, 1)
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.TextSize = 14
    actionBtn.Parent = mainFrame
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = title
    
    -- Add rounded corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    addCorner(mainFrame)
    addCorner(title)
    addCorner(status)
    addCorner(actionBtn)
    addCorner(closeBtn)
    
    -- Make draggable
    local dragging = false
    local dragStart, frameStart
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
        end
    end)
    
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Button functionality
    actionBtn.MouseButton1Click:Connect(function()
        actionBtn.Text = "WORKING..."
        status.Text = "Optimizing car collection...\nPlease wait"
        
        task.spawn(function()
            -- Get car service
            local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
            
            -- Get cars
            local success, cars = pcall(function()
                return carService.GetOwnedCars:InvokeServer()
            end)
            
            if success and cars and #cars > 0 then
                status.Text = "Found " .. #cars .. " cars\nLooking for duplication..."
                
                -- Find ClaimGiveawayCar
                local claimRemote
                for _, obj in pairs(game:GetDescendants()) do
                    if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
                        claimRemote = obj
                        break
                    end
                end
                
                if claimRemote then
                    status.Text = "Found remote\nSending requests..."
                    
                    local car = cars[1]
                    
                    -- Send a few requests with natural timing
                    for i = 1, 3 do
                        pcall(function()
                            claimRemote:FireServer(car)
                        end)
                        status.Text = "Sent request " .. i .. "/3"
                        task.wait(math.random(800, 2000) / 1000)
                    end
                    
                    status.Text = "✅ Optimization complete!\nCheck your garage"
                else
                    status.Text = "❌ Remote not found"
                end
            else
                status.Text = "❌ Failed to load cars"
            end
            
            actionBtn.Text = "⚡ OPTIMIZE CARS"
        end)
    end)
    
    -- Close button functionality
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    print("✅ UI created successfully")
    return screenGui
end

-- ===== CONSOLE TEST FUNCTION =====
local function consoleTest()
    print("\n🎯 CONSOLE TEST MODE")
    print("=" .. string.rep("=", 50))
    
    local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
    
    -- Get cars
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if not success or not cars or #cars == 0 then
        print("❌ Failed to get cars")
        return
    end
    
    print("✅ Loaded " .. #cars .. " cars")
    
    -- Find ClaimGiveawayCar
    local claimRemote
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if not claimRemote then
        print("❌ ClaimGiveawayCar not found")
        return
    end
    
    print("🎯 Found ClaimGiveawayCar remote")
    print("🚗 Using first car")
    
    local car = cars[1]
    
    -- Send a few requests
    for i = 1, 5 do
        pcall(function()
            claimRemote:FireServer(car)
        end)
        print("📤 Sent request " .. i)
        task.wait(0.5)
    end
    
    print("✅ Test complete")
end

-- ===== MAIN =====
print("🚀 Starting system...")

-- Try to create UI
local uiSuccess, uiError = pcall(function()
    createWorkingUI()
end)

if uiSuccess then
    print("✅ UI created successfully")
else
    print("❌ UI failed: " .. tostring(uiError))
    print("\n🔄 Running console mode...")
    
    -- Run console test
    task.wait(2)
    consoleTest()
end

print("\n💡 Commands:")
print("• Click OPTIMIZE CARS button")
print("• Or check console for output")
