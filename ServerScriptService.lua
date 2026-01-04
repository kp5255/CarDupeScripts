print("🌟 SUPER-VISIBLE INVENTORY INJECTION")
print("=" .. string.rep("=", 60))

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Create a ScreenGui with MAXIMUM priority
local superGui = Instance.new("ScreenGui")
superGui.Name = "SuperInjection"
superGui.DisplayOrder = 99999  -- Highest possible
superGui.IgnoreGuiInset = true  -- Cover entire screen
superGui.ResetOnSpawn = false
superGui.Parent = player.PlayerGui

print("✅ Created SUPER GUI with DisplayOrder: 99999")

-- Create a semi-transparent background to dim everything else
local background = Instance.new("Frame")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.BackgroundColor3 = Color3.new(0, 0, 0)
background.BackgroundTransparency = 0.5  -- 50% transparent black
background.Parent = superGui

print("✅ Added semi-transparent background")

-- Create the MAIN injection container (CENTER OF SCREEN)
local mainContainer = Instance.new("Frame")
mainContainer.Name = "InjectionContainer"
mainContainer.Size = UDim2.new(0.8, 0, 0.8, 0)  -- 80% of screen
mainContainer.Position = UDim2.new(0.1, 0, 0.1, 0)  -- Centered
mainContainer.BackgroundColor3 = Color3.fromRGB(255, 215, 0)  -- GOLD
mainContainer.BackgroundTransparency = 0.1
mainContainer.Parent = superGui

-- Add glowing border
local glow = Instance.new("UIStroke")
glow.Color = Color3.new(1, 1, 0)  -- Yellow glow
glow.Thickness = 8
glow.Transparency = 0.3
glow.Parent = mainContainer

-- Add pulsing animation
local pulseConn
pulseConn = game:GetService("RunService").Heartbeat:Connect(function()
    local pulse = math.sin(os.clock() * 5) * 0.1 + 0.9
    glow.Thickness = 5 + math.sin(os.clock() * 3) * 3
    glow.Transparency = 0.5 + math.sin(os.clock() * 2) * 0.2
end)

print("✅ Created GOLD container with pulsing glow")

-- Title with sparkles
local title = Instance.new("TextLabel")
title.Text = "✨🚗 INJECTED CARS COLLECTION 🚗✨"
title.Size = UDim2.new(1, 0, 0, 80)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.TextScaled = true
title.Parent = mainContainer

print("✅ Added sparkly title")

-- Create car grid
local carGrid = Instance.new("ScrollingFrame")
carGrid.Name = "CarGrid"
carGrid.Size = UDim2.new(1, -40, 1, -100)
carGrid.Position = UDim2.new(0, 20, 0, 90)
carGrid.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
carGrid.BackgroundTransparency = 0.3
carGrid.BorderSizePixel = 0
carGrid.ScrollBarThickness = 12
carGrid.AutomaticCanvasSize = Enum.AutomaticSize.Y
carGrid.Parent = mainContainer

-- Define premium cars
local premiumCars = {
    {Name = "Bugatti Chiron Super Sport", Class = 3, Color = Color3.new(0, 0.5, 1), Speed = 304, Price = "$3,000,000"},
    {Name = "Lamborghini Revuelto", Class = 3, Color = Color3.new(1, 0, 0), Speed = 350, Price = "$600,000"},
    {Name = "Ferrari SF90 Stradale", Class = 3, Color = Color3.new(1, 0, 0), Speed = 340, Price = "$625,000"},
    {Name = "McLaren Speedtail", Class = 3, Color = Color3.new(1, 0.5, 0), Speed = 403, Price = "$2,200,000"},
    {Name = "Porsche 918 Spyder", Class = 3, Color = Color3.new(0, 1, 0.5), Speed = 345, Price = "$845,000"},
    {Name = "Koenigsegg Jesko Absolut", Class = 3, Color = Color3.new(0.5, 0, 1), Speed = 330, Price = "$3,000,000"},
    {Name = "Pagani Huayra BC", Class = 3, Color = Color3.new(1, 1, 0), Speed = 238, Price = "$2,800,000"},
    {Name = "Aston Martin Valkyrie", Class = 3, Color = Color3.new(0, 1, 1), Speed = 250, Price = "$3,200,000"},
    {Name = "Rimac Nevera", Class = 3, Color = Color3.new(0.2, 0.8, 0.2), Speed = 258, Price = "$2,400,000"},
    {Name = "Gordon Murray T.50", Class = 3, Color = Color3.new(1, 0.2, 0.5), Speed = 0, Price = "$3,000,000"}
}

print("🎨 Adding " .. #premiumCars .. " premium cars...")

-- Add cars to grid
local cellWidth = 200
local cellHeight = 180
local padding = 15
local columns = 4

for i, carData in ipairs(premiumCars) do
    local row = math.floor((i-1) / columns)
    local col = (i-1) % columns
    
    -- Car card
    local carCard = Instance.new("Frame")
    carCard.Name = "Car_" .. i
    carCard.Size = UDim2.new(0, cellWidth, 0, cellHeight)
    carCard.Position = UDim2.new(0, col * (cellWidth + padding), 0, row * (cellHeight + padding))
    carCard.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    carCard.BackgroundTransparency = 0.2
    carCard.Parent = carGrid
    
    -- Add rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = carCard
    
    -- Color stripe
    local colorStripe = Instance.new("Frame")
    colorStripe.Size = UDim2.new(1, 0, 0, 10)
    colorStripe.Position = UDim2.new(0, 0, 0, 0)
    colorStripe.BackgroundColor3 = carData.Color
    colorStripe.BorderSizePixel = 0
    colorStripe.Parent = carCard
    
    -- Car name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = carData.Name
    nameLabel.Size = UDim2.new(1, -20, 0, 40)
    nameLabel.Position = UDim2.new(0, 10, 0, 15)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextScaled = true
    nameLabel.Parent = carCard
    
    -- Class badge
    local classBadge = Instance.new("Frame")
    classBadge.Size = UDim2.new(0, 70, 0, 25)
    classBadge.Position = UDim2.new(0, 10, 0, 60)
    classBadge.BackgroundColor3 = Color3.new(1, 0, 0)
    classBadge.Parent = carCard
    
    local classCorner = Instance.new("UICorner")
    classCorner.CornerRadius = UDim.new(0, 6)
    classCorner.Parent = classBadge
    
    local classText = Instance.new("TextLabel")
    classText.Text = "CLASS " .. carData.Class
    classText.Size = UDim2.new(1, 0, 1, 0)
    classText.BackgroundTransparency = 1
    classText.TextColor3 = Color3.new(1, 1, 1)
    classText.Font = Enum.Font.GothamBold
    classText.TextSize = 12
    classText.Parent = classBadge
    
    -- Speed
    if carData.Speed > 0 then
        local speedLabel = Instance.new("TextLabel")
        speedLabel.Text = "⚡ " .. carData.Speed .. " MPH"
        speedLabel.Size = UDim2.new(1, -20, 0, 25)
        speedLabel.Position = UDim2.new(0, 10, 0, 90)
        speedLabel.BackgroundTransparency = 1
        speedLabel.TextColor3 = Color3.new(1, 1, 1)
        speedLabel.Font = Enum.Font.Gotham
        speedLabel.TextSize = 12
        speedLabel.Parent = carCard
    end
    
    -- Price
    local priceLabel = Instance.new("TextLabel")
    priceLabel.Text = carData.Price
    priceLabel.Size = UDim2.new(1, -20, 0, 25)
    priceLabel.Position = UDim2.new(0, 10, 0, 120)
    priceLabel.BackgroundTransparency = 1
    priceLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    priceLabel.Font = Enum.Font.GothamBold
    priceLabel.TextSize = 14
    priceLabel.Parent = carCard
    
    -- Hover effect
    carCard.MouseEnter:Connect(function()
        carCard.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end)
    
    carCard.MouseLeave:Connect(function()
        carCard.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    end)
    
    print("   ✅ Added: " .. carData.Name)
end

-- Set grid size
local totalRows = math.ceil(#premiumCars / columns)
carGrid.CanvasSize = UDim2.new(0, 0, 0, totalRows * (cellHeight + padding))

-- Control buttons
local buttonFrame = Instance.new("Frame")
buttonFrame.Size = UDim2.new(1, -40, 0, 60)
buttonFrame.Position = UDim2.new(0, 20, 1, -70)
buttonFrame.BackgroundTransparency = 1
buttonFrame.Parent = mainContainer

-- Select All button
local selectAllBtn = Instance.new("TextButton")
selectAllBtn.Text = "🎮 SELECT ALL CARS"
selectAllBtn.Size = UDim2.new(0.4, -10, 1, 0)
selectAllBtn.Position = UDim2.new(0, 0, 0, 0)
selectAllBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
selectAllBtn.TextColor3 = Color3.new(1, 1, 1)
selectAllBtn.Font = Enum.Font.GothamBold
selectAllBtn.TextSize = 18
selectAllBtn.Parent = buttonFrame

selectAllBtn.MouseButton1Click:Connect(function()
    print("🎯 Attempting to select all injected cars...")
    selectAllBtn.Text = "⏳ PROCESSING..."
    
    -- Try to add cars via OnCarsAdded
    local carService = game:GetService("ReplicatedStorage").Remotes.Services.CarServiceRemotes
    local onCarsAdded = carService:FindFirstChild("OnCarsAdded")
    
    if onCarsAdded then
        for i, carData in ipairs(premiumCars) do
            local fakeCar = {
                Id = "super-inject-" .. i .. "-" .. os.time(),
                Name = carData.Name,
                Class = carData.Class,
                Injected = true
            }
            
            local success = pcall(function()
                onCarsAdded:FireServer({fakeCar})
                return true
            end)
            
            if success then
                print("✅ Injection attempted: " .. carData.Name)
            end
        end
        selectAllBtn.Text = "✅ INJECTION ATTEMPTED"
    else
        selectAllBtn.Text = "❌ REMOTE NOT FOUND"
    end
end)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "❌ CLOSE INJECTION"
closeBtn.Size = UDim2.new(0.4, -10, 1, 0)
closeBtn.Position = UDim2.new(0.6, 0, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = buttonFrame

closeBtn.MouseButton1Click:Connect(function()
    print("🛑 Closing injection interface...")
    superGui:Destroy()
    if pulseConn then
        pulseConn:Disconnect()
    end
end)

-- Add rounded corners to main container
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainContainer

print("\n" .. string.rep("=", 60))
print("🎉 SUPER-VISIBLE INJECTION CREATED!")
print("✅ 10 Premium cars displayed")
print("✅ Pulsing gold border")
print("✅ Semi-transparent background")
print("✅ Control buttons")
print("✅ DisplayOrder: 99999 (TOP MOST)")
print("\n💡 Click 'SELECT ALL CARS' to attempt injection")
print("💡 Click 'CLOSE INJECTION' to remove")
print("\n🚨 THIS SHOULD BE IMPOSSIBLE TO MISS! 🚨")
