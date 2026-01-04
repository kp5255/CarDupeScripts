-- 🚗 SIMPLE CAR BROWSER & DUPLICATOR
-- No external dependencies

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== SIMPLE CAR FINDER =====
local function findCarsSimple()
    print("🔍 Finding cars...")
    
    local cars = {}
    
    -- 1. Check common locations
    local locations = {
        {Name = "Cars Folder", Object = ReplicatedStorage:FindFirstChild("Cars")},
        {Name = "Vehicles Folder", Object = ReplicatedStorage:FindFirstChild("Vehicles")},
        {Name = "CarShop", Object = ReplicatedStorage:FindFirstChild("CarShop")},
        {Name = "VehicleShop", Object = ReplicatedStorage:FindFirstChild("VehicleShop")},
        {Name = "Workspace Cars", Object = Workspace:FindFirstChild("Cars")}
    }
    
    for _, location in pairs(locations) do
        if location.Object then
            for _, item in pairs(location.Object:GetChildren()) do
                if item:IsA("Model") or item:IsA("Folder") then
                    table.insert(cars, {
                        Name = item.Name,
                        Source = location.Name
                    })
                end
            end
        end
    end
    
    -- 2. Look for Configuration objects with car data
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Configuration") then
            local name = obj.Name
            if name:find("Car") or name:find("Vehicle") then
                table.insert(cars, {
                    Name = name,
                    Source = "Configuration"
                })
            end
        end
    end
    
    -- 3. Remove duplicates
    local uniqueCars = {}
    local seen = {}
    
    for _, car in pairs(cars) do
        if not seen[car.Name] then
            seen[car.Name] = true
            table.insert(uniqueCars, car)
        end
    end
    
    -- Sort alphabetically
    table.sort(uniqueCars, function(a, b)
        return a.Name < b.Name
    end)
    
    print("✅ Found " .. #uniqueCars .. " cars")
    return uniqueCars
end

-- ===== DUPLICATE CAR =====
local function duplicateCar(carName)
    print("🔄 Duplicating: " .. carName)
    
    local cmdr = ReplicatedStorage:FindFirstChild("CmdrClient")
    if not cmdr then return false end
    
    local cmdrEvent = cmdr:FindFirstChild("CmdrEvent")
    if not cmdrEvent then return false end
    
    -- Try command
    local success = pcall(function()
        cmdrEvent:FireServer("givecar " .. carName)
        return true
    end)
    
    return success
end

-- ===== CREATE SIMPLE UI =====
local function createSimpleUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 500)
    frame.Position = UDim2.new(0.5, -200, 0.5, -250)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 CAR BROWSER"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = frame
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Loading cars..."
    status.Size = UDim2.new(1, -20, 0, 40)
    status.Position = UDim2.new(0, 10, 0, 60)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    -- Car list
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, -20, 0, 300)
    listFrame.Position = UDim2.new(0, 10, 0, 110)
    listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 8
    listFrame.Parent = frame
    
    -- Buttons frame
    local buttons = Instance.new("Frame")
    buttons.Size = UDim2.new(1, -20, 0, 80)
    buttons.Position = UDim2.new(0, 10, 0, 420)
    buttons.BackgroundTransparency = 1
    buttons.Parent = frame
    
    -- Refresh button
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Text = "🔄 REFRESH"
    refreshBtn.Size = UDim2.new(1, 0, 0, 35)
    refreshBtn.Position = UDim2.new(0, 0, 0, 0)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    refreshBtn.TextColor3 = Color3.new(1, 1, 1)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 14
    refreshBtn.Parent = buttons
    
    -- Duplicate button
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "🎯 DUPLICATE SELECTED"
    dupeBtn.Size = UDim2.new(1, 0, 0, 35)
    dupeBtn.Position = UDim2.new(0, 0, 0, 45)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.GothamBold
    dupeBtn.TextSize = 16
    dupeBtn.Parent = buttons
    
    -- Selected car
    local selectedCar = nil
    
    -- Function to show cars
    local function showCars(carList)
        listFrame:ClearAllChildren()
        
        local y = 5
        for i, car in pairs(carList) do
            -- Entry
            local entry = Instance.new("Frame")
            entry.Size = UDim2.new(1, -10, 0, 40)
            entry.Position = UDim2.new(0, 5, 0, y)
            entry.BackgroundColor3 = selectedCar == car.Name and Color3.fromRGB(60, 80, 60) or Color3.fromRGB(40, 40, 50)
            entry.BorderSizePixel = 0
            entry.Parent = listFrame
            
            -- Name
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Text = car.Name
            nameLabel.Size = UDim2.new(0.7, -5, 1, 0)
            nameLabel.Position = UDim2.new(0, 5, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 14
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = entry
            
            -- Source
            local sourceLabel = Instance.new("TextLabel")
            sourceLabel.Text = car.Source
            sourceLabel.Size = UDim2.new(0.3, -5, 1, 0)
            sourceLabel.Position = UDim2.new(0.7, 0, 0, 0)
            sourceLabel.BackgroundTransparency = 1
            sourceLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            sourceLabel.Font = Enum.Font.Gotham
            sourceLabel.TextSize = 10
            sourceLabel.TextXAlignment = Enum.TextXAlignment.Right
            sourceLabel.Parent = entry
            
            -- Click to select
            entry.MouseButton1Click:Connect(function()
                selectedCar = car.Name
                status.Text = "Selected: " .. car.Name
                showCars(carList) -- Refresh
            end)
            
            y = y + 45
        end
        
        listFrame.CanvasSize = UDim2.new(0, 0, 0, y)
    end
    
    -- Load cars
    local cars = findCarsSimple()
    showCars(cars)
    status.Text = "Found " .. #cars .. " cars. Click to select."
    
    -- Refresh button
    refreshBtn.MouseButton1Click:Connect(function()
        status.Text = "Refreshing..."
        cars = findCarsSimple()
        showCars(cars)
        selectedCar = nil
        status.Text = "Found " .. #cars .. " cars. Click to select."
    end)
    
    -- Duplicate button
    dupeBtn.MouseButton1Click:Connect(function()
        if not selectedCar then
            status.Text = "❌ Select a car first!"
            return
        end
        
        status.Text = "Duplicating " .. selectedCar .. "..."
        dupeBtn.Text = "WORKING..."
        dupeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local success = duplicateCar(selectedCar)
            if success then
                status.Text = "✅ Sent: givecar " .. selectedCar .. "\nCheck garage!"
            else
                status.Text = "❌ Failed to duplicate"
            end
            
            task.wait(2)
            dupeBtn.Text = "🎯 DUPLICATE SELECTED"
            dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    -- Add corners
    local corners = {frame, status, listFrame, refreshBtn, dupeBtn}
    for _, obj in pairs(corners) do
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = obj
    end
    
    return gui, status
end

-- ===== MAIN =====
print("🚗 SIMPLE CAR BROWSER")
task.wait(2)
createSimpleUI()
print("✅ UI Created!")
print("\nInstructions:")
print("1. Browse cars in the UI")
print("2. Click a car to select it")
print("3. Click 'DUPLICATE SELECTED'")
print("4. Check your garage!")
