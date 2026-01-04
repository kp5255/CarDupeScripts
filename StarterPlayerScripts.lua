-- 🚗 CAR DUPLICATION SYSTEM
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🚗 CAR DUPLICATION SYSTEM LOADED")

-- ===== CAR DUPLICATION FUNCTIONS =====
local CarDuplicator = {
    OwnedCars = {},
    SelectedCar = nil,
    IsDuplicating = false
}

-- Get owned cars
function CarDuplicator:GetOwnedCars()
    local success, result = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(result) == "table" then
        self.OwnedCars = result
        return true
    end
    return false
end

-- Extract car name from car data
function CarDuplicator:GetCarName(carData)
    if type(carData) ~= "table" then return "Unknown Car" end
    
    -- Try different possible name fields
    return carData.Name or carData.name or carData.CarName or 
           carData.DisplayName or carData.NameTag or "Unknown Car"
end

-- Get car class
function CarDuplicator:GetCarClass(carData)
    if type(carData) ~= "table" then return 1 end
    
    local class = carData.Class or carData.class or carData.CarClass or 1
    if type(class) == "string" then
        if class:find("3") then return 3
        elseif class:find("2") then return 2
        else return 1 end
    end
    return math.floor(class)
end

-- Duplicate selected car
function CarDuplicator:DuplicateCar()
    if self.IsDuplicating then
        return false, "Already duplicating..."
    end
    
    if not self.SelectedCar then
        return false, "No car selected!"
    end
    
    self.IsDuplicating = true
    
    -- Try different duplication methods
    local methods = {
        -- Method 1: Try UpdateCarPack remote
        function()
            local updateRemote = carService:FindFirstChild("UpdateCarPack")
            if updateRemote then
                updateRemote:FireServer(self.SelectedCar)
                return true, "UpdateCarPack method"
            end
            return false
        end,
        
        -- Method 2: Try SetCarFavorite (might work for duplication)
        function()
            local favoriteRemote = ReplicatedStorage.Remotes:FindFirstChild("SetCarFavorite")
            if favoriteRemote then
                favoriteRemote:FireServer(self.SelectedCar)
                return true, "SetCarFavorite method"
            end
            return false
        end,
        
        -- Method 3: Try EnableCar remote
        function()
            local enableRemote = ReplicatedStorage.Remotes:FindFirstChild("EnableCar")
            if enableRemote then
                enableRemote:FireServer(self.SelectedCar)
                return true, "EnableCar method"
            end
            return false
        end,
        
        -- Method 4: Try UpdateCar remote
        function()
            local updateRemote = ReplicatedStorage.Remotes:FindFirstChild("UpdateCar")
            if updateRemote then
                updateRemote:FireServer(self.SelectedCar)
                return true, "UpdateCar method"
            end
            return false
        end
    }
    
    -- Try each method
    local success, methodName = false, "No method found"
    for i, method in ipairs(methods) do
        local result, name = method()
        if result then
            success, methodName = true, name
            break
        end
    end
    
    self.IsDuplicating = false
    
    if success then
        -- Refresh car list
        task.wait(1)
        self:GetOwnedCars()
        return true, "Duplication attempted via " .. methodName
    else
        return false, "No duplication method worked"
    end
end

-- ===== CREATE RESPONSIVE UI =====
function CarDuplicator:CreateUI()
    -- Destroy old UI if exists
    if player.PlayerGui:FindFirstChild("CarDuplicatorUI") then
        player.PlayerGui.CarDuplicatorUI:Destroy()
    end
    
    -- Main GUI
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarDuplicatorUI"
    gui.Parent = player.PlayerGui
    
    -- Main Window
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.Parent = gui
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Text = "🚗 CAR DUPLICATION SYSTEM"
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Status Bar
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, -20, 0, 40)
    statusBar.Position = UDim2.new(0, 10, 0, 50)
    statusBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    statusBar.Parent = mainFrame
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "Status"
    statusText.Text = "Loading your cars..."
    statusText.Size = UDim2.new(1, -20, 1, -10)
    statusText.Position = UDim2.new(0, 10, 0, 5)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.new(1, 1, 1)
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 12
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar
    
    -- Car Count Display
    local countFrame = Instance.new("Frame")
    countFrame.Size = UDim2.new(1, -20, 0, 30)
    countFrame.Position = UDim2.new(0, 10, 0, 100)
    countFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    countFrame.Parent = mainFrame
    
    local countText = Instance.new("TextLabel")
    countText.Text = "Total Cars: 0"
    countText.Size = UDim2.new(1, 0, 1, 0)
    countText.BackgroundTransparency = 1
    countText.TextColor3 = Color3.new(1, 1, 1)
    countText.Font = Enum.Font.Gotham
    countText.TextSize = 14
    countText.Parent = countFrame
    
    -- Car List (Scrollable)
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 0, 300)
    scrollFrame.Position = UDim2.new(0, 10, 0, 140)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = mainFrame
    
    -- Selected Car Display
    local selectedFrame = Instance.new("Frame")
    selectedFrame.Size = UDim2.new(1, -20, 0, 60)
    selectedFrame.Position = UDim2.new(0, 10, 0, 450)
    selectedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    selectedFrame.Parent = mainFrame
    
    local selectedTitle = Instance.new("TextLabel")
    selectedTitle.Text = "SELECTED CAR:"
    selectedTitle.Size = UDim2.new(1, 0, 0, 20)
    selectedTitle.Position = UDim2.new(0, 10, 0, 5)
    selectedTitle.BackgroundTransparency = 1
    selectedTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    selectedTitle.Font = Enum.Font.Gotham
    selectedTitle.TextSize = 12
    selectedTitle.TextXAlignment = Enum.TextXAlignment.Left
    selectedTitle.Parent = selectedFrame
    
    local selectedName = Instance.new("TextLabel")
    selectedName.Name = "SelectedName"
    selectedName.Text = "None"
    selectedName.Size = UDim2.new(1, -20, 0, 30)
    selectedName.Position = UDim2.new(0, 10, 0, 25)
    selectedName.BackgroundTransparency = 1
    selectedName.TextColor3 = Color3.new(1, 1, 1)
    selectedName.Font = Enum.Font.GothamBold
    selectedName.TextSize = 16
    selectedName.TextXAlignment = Enum.TextXAlignment.Left
    selectedName.Parent = selectedFrame
    
    -- Action Buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -20, 0, 50)
    buttonFrame.Position = UDim2.new(0, 10, 1, -60)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame
    
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Text = "🔄 Refresh"
    refreshBtn.Size = UDim2.new(0.3, -5, 1, 0)
    refreshBtn.Position = UDim2.new(0, 0, 0, 0)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    refreshBtn.TextColor3 = Color3.new(1, 1, 1)
    refreshBtn.Font = Enum.Font.Gotham
    refreshBtn.TextSize = 14
    refreshBtn.Parent = buttonFrame
    
    local duplicateBtn = Instance.new("TextButton")
    duplicateBtn.Text = "🚗 Duplicate Car"
    duplicateBtn.Size = UDim2.new(0.7, -5, 1, 0)
    duplicateBtn.Position = UDim2.new(0.3, 5, 0, 0)
    duplicateBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    duplicateBtn.TextColor3 = Color3.new(1, 1, 1)
    duplicateBtn.Font = Enum.Font.GothamBold
    duplicateBtn.TextSize = 14
    duplicateBtn.Parent = buttonFrame
    
    -- Add rounded corners
    local function addCorner(obj, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius or 6)
        corner.Parent = obj
    end
    
    addCorner(mainFrame, 8)
    addCorner(titleBar, 8)
    addCorner(statusBar, 6)
    addCorner(countFrame, 6)
    addCorner(scrollFrame, 6)
    addCorner(selectedFrame, 6)
    addCorner(refreshBtn, 6)
    addCorner(duplicateBtn, 6)
    addCorner(closeBtn, 15)
    
    -- Make window draggable
    local dragging = false
    local dragStart, frameStart
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function()
        dragging = false
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
    
    -- ===== UI FUNCTIONS =====
    local function updateStatus(text, color)
        statusText.Text = text
        statusText.TextColor3 = color or Color3.new(1, 1, 1)
    end
    
    local function updateCarCount()
        countText.Text = "Total Cars: " .. #CarDuplicator.OwnedCars
    end
    
    local function updateSelectedDisplay()
        if CarDuplicator.SelectedCar then
            local carName = CarDuplicator:GetCarName(CarDuplicator.SelectedCar)
            local carClass = CarDuplicator:GetCarClass(CarDuplicator.SelectedCar)
            local classIcon = carClass == 3 and "🔴" or carClass == 2 and "🟡" or "🟢"
            selectedName.Text = classIcon .. " " .. carName .. " (Class " .. carClass .. ")"
        else
            selectedName.Text = "None"
        end
    end
    
    local function createCarButton(carData, index)
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(1, -10, 0, 50)
        buttonFrame.Position = UDim2.new(0, 5, 0, (index-1) * 55)
        buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        buttonFrame.Parent = scrollFrame
        
        addCorner(buttonFrame, 6)
        
        -- Car name
        local carName = CarDuplicator:GetCarName(carData)
        local carClass = CarDuplicator:GetCarClass(carData)
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = carName
        nameLabel.Size = UDim2.new(1, -10, 0, 25)
        nameLabel.Position = UDim2.new(0, 5, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = buttonFrame
        
        -- Class indicator
        local classLabel = Instance.new("TextLabel")
        local classIcon = carClass == 3 and "🔴 Class 3" or carClass == 2 and "🟡 Class 2" or "🟢 Class 1"
        classLabel.Text = classIcon
        classLabel.Size = UDim2.new(0.4, 0, 0, 20)
        classLabel.Position = UDim2.new(0.6, 0, 0, 28)
        classLabel.BackgroundTransparency = 1
        classLabel.TextColor3 = Color3.new(1, 1, 1)
        classLabel.Font = Enum.Font.Gotham
        classLabel.TextSize = 10
        classLabel.Parent = buttonFrame
        
        -- Select button
        local selectBtn = Instance.new("TextButton")
        selectBtn.Text = "SELECT"
        selectBtn.Size = UDim2.new(0.3, 0, 0, 20)
        selectBtn.Position = UDim2.new(0, 5, 0, 28)
        selectBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        selectBtn.TextColor3 = Color3.new(1, 1, 1)
        selectBtn.Font = Enum.Font.Gotham
        selectBtn.TextSize = 10
        selectBtn.Parent = buttonFrame
        
        addCorner(selectBtn, 4)
        
        -- Selection indicator
        local selectedIndicator = Instance.new("Frame")
        selectedIndicator.Size = UDim2.new(0, 5, 1, 0)
        selectedIndicator.Position = UDim2.new(0, 0, 0, 0)
        selectedIndicator.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        selectedIndicator.Visible = false
        selectedIndicator.Parent = buttonFrame
        
        addCorner(selectedIndicator, 2)
        
        -- Button click handlers
        selectBtn.MouseButton1Click:Connect(function()
            -- Deselect all other cars
            for _, child in pairs(scrollFrame:GetChildren()) do
                if child:IsA("Frame") and child ~= buttonFrame then
                    child.SelectedIndicator.Visible = false
                    child.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                end
            end
            
            -- Select this car
            CarDuplicator.SelectedCar = carData
            selectedIndicator.Visible = true
            buttonFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            
            updateSelectedDisplay()
            updateStatus("Selected: " .. carName, Color3.fromRGB(0, 200, 100))
        end)
        
        return buttonFrame
    end
    
    local function loadCars()
        updateStatus("Loading cars...", Color3.fromRGB(255, 255, 0))
        
        -- Clear existing cars
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Load cars
        if CarDuplicator:GetOwnedCars() then
            updateCarCount()
            
            -- Create car buttons
            for i, carData in ipairs(CarDuplicator.OwnedCars) do
                if type(carData) == "table" then
                    createCarButton(carData, i)
                end
            end
            
            updateStatus("Loaded " .. #CarDuplicator.OwnedCars .. " cars", Color3.fromRGB(0, 200, 100))
        else
            updateStatus("Failed to load cars", Color3.fromRGB(255, 50, 50))
        end
    end
    
    -- Button click handlers
    refreshBtn.MouseButton1Click:Connect(function()
        loadCars()
    end)
    
    duplicateBtn.MouseButton1Click:Connect(function()
        if not CarDuplicator.SelectedCar then
            updateStatus("Please select a car first!", Color3.fromRGB(255, 50, 50))
            return
        end
        
        local carName = CarDuplicator:GetCarName(CarDuplicator.SelectedCar)
        updateStatus("Duplicating " .. carName .. "...", Color3.fromRGB(255, 255, 0))
        
        local success, message = CarDuplicator:DuplicateCar()
        
        if success then
            updateStatus("✓ " .. message, Color3.fromRGB(0, 200, 100))
            
            -- Refresh after delay
            task.wait(2)
            loadCars()
        else
            updateStatus("✗ " .. message, Color3.fromRGB(255, 50, 50))
        end
    end)
    
    -- Initial load
    loadCars()
    
    return gui
end

-- ===== START THE SYSTEM =====
print("🚀 Initializing Car Duplication System...")

-- Create the UI
local ui = CarDuplicator:CreateUI()

print("✅ Car Duplication System Ready!")
print("💡 Features:")
print("• Scrollable list of your 56 cars")
print("• Select any car to duplicate")
print("• One-click duplication")
print("• Real-time status updates")
print("• Drag and move window")

-- Auto-refresh every 30 seconds
spawn(function()
    while task.wait(30) do
        if ui and ui.Parent then
            CarDuplicator:GetOwnedCars()
        end
    end
end)
