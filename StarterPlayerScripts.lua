-- 🚗 CAR COLLECTION BROWSER & DUPLICATOR
-- Shows ALL game cars and lets you duplicate them

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== FIND ALL CARS IN GAME =====
local function findAllCars()
    print("🔍 Finding all cars in game...")
    
    local allCars = {}
    
    -- 1. Look in CarShop modules
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") and obj.Name:lower():find("shop") then
            local success, module = pcall(function()
                return require(obj)
            end)
            
            if success and type(module) == "table" then
                for key, value in pairs(module) do
                    if type(value) == "table" then
                        -- Check if it's a car data table
                        if value.Name and (value.Name:find("Car") or value.Price or value.Model) then
                            table.insert(allCars, {
                                Name = value.Name or key,
                                Price = value.Price or 0,
                                Model = value.Model or value.ID or key,
                                Source = "Shop Module: " .. obj.Name
                            })
                        end
                    end
                end
            end
        end
    end
    
    -- 2. Look for car catalog folders
    if ReplicatedStorage:FindFirstChild("Cars") then
        for _, car in pairs(ReplicatedStorage.Cars:GetChildren()) do
            table.insert(allCars, {
                Name = car.Name,
                Price = 0,
                Model = car.Name,
                Source = "Cars Folder"
            })
        end
    end
    
    -- 3. Look in Workspace for car models
    if Workspace:FindFirstChild("Cars") then
        for _, car in pairs(Workspace.Cars:GetChildren()) do
            if car:IsA("Model") then
                table.insert(allCars, {
                    Name = car.Name,
                    Price = 0,
                    Model = car.Name,
                    Source = "Workspace Cars"
                })
            end
        end
    end
    
    -- 4. Look for car data in Configurations
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Configuration") then
            local carName = obj:GetAttribute("CarName") or obj.Name
            if carName:find("Car") or carName:find("Vehicle") then
                table.insert(allCars, {
                    Name = carName,
                    Price = obj:GetAttribute("Price") or 0,
                    Model = obj:GetAttribute("Model") or carName,
                    Source = "Configuration"
                })
            end
        end
    end
    
    -- 5. Remove duplicates
    local uniqueCars = {}
    local seen = {}
    
    for _, car in pairs(allCars) do
        local key = car.Name:lower()
        if not seen[key] then
            seen[key] = true
            table.insert(uniqueCars, car)
        end
    end
    
    print("✅ Found " .. #uniqueCars .. " unique cars")
    return uniqueCars
end

-- ===== DUPLICATE SELECTED CAR =====
local function duplicateCar(carName)
    print("\n🔄 Duplicating: " .. carName)
    
    local cmdr = ReplicatedStorage:FindFirstChild("CmdrClient")
    if not cmdr then
        print("❌ CmdrClient not found")
        return false
    end
    
    local cmdrEvent = cmdr:FindFirstChild("CmdrEvent")
    if not cmdrEvent then
        print("❌ CmdrEvent not found")
        return false
    end
    
    -- Try multiple command formats
    local formats = {
        "givecar " .. carName,
        "!givecar " .. carName,
        "/givecar " .. carName,
        "duplicatecar " .. carName,
        "copycar " .. carName,
        "addcar " .. carName
    }
    
    local successCount = 0
    
    for _, cmd in pairs(formats) do
        local success, result = pcall(function()
            cmdrEvent:FireServer(cmd)
            return true
        end)
        
        if success then
            print("✅ Sent: " .. cmd)
            successCount = successCount + 1
            
            -- Send rapid duplicates
            for i = 1, 5 do
                pcall(function()
                    cmdrEvent:FireServer(cmd)
                end)
                task.wait(0.05)
            end
        end
        
        task.wait(0.1)
    end
    
    return successCount > 0
end

-- ===== CREATE CAR BROWSER UI =====
local function createCarBrowser()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarBrowser"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 CAR COLLECTION BROWSER"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = mainFrame
    
    -- Search box
    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "Search cars..."
    searchBox.Size = UDim2.new(1, -20, 0, 40)
    searchBox.Position = UDim2.new(0, 10, 0, 60)
    searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    searchBox.TextColor3 = Color3.new(1, 1, 1)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 14
    searchBox.Text = ""
    searchBox.Parent = mainFrame
    
    -- Car list frame
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, -20, 0, 400)
    listFrame.Position = UDim2.new(0, 10, 0, 110)
    listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 8
    listFrame.Parent = mainFrame
    
    -- Status label
    local status = Instance.new("TextLabel")
    status.Text = "Loading cars..."
    status.Size = UDim2.new(1, -20, 0, 40)
    status.Position = UDim2.new(0, 10, 0, 520)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = mainFrame
    
    -- Control buttons frame
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -20, 0, 50)
    buttonFrame.Position = UDim2.new(0, 10, 0, 570)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame
    
    -- Refresh button
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Text = "🔄 REFRESH"
    refreshBtn.Size = UDim2.new(0.3, -5, 1, 0)
    refreshBtn.Position = UDim2.new(0, 0, 0, 0)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    refreshBtn.TextColor3 = Color3.new(1, 1, 1)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 14
    refreshBtn.Parent = buttonFrame
    
    -- Duplicate button
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "🎯 DUPLICATE SELECTED"
    dupeBtn.Size = UDim2.new(0.7, -5, 1, 0)
    dupeBtn.Position = UDim2.new(0.3, 5, 0, 0)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.GothamBold
    dupeBtn.TextSize = 16
    dupeBtn.Parent = buttonFrame
    
    -- Selected car variable
    local selectedCar = nil
    
    -- Function to display cars
    local function displayCars(cars)
        listFrame:ClearAllChildren()
        
        local yPos = 5
        for i, car in pairs(cars) do
            -- Car entry frame
            local entry = Instance.new("Frame")
            entry.Size = UDim2.new(1, -10, 0, 50)
            entry.Position = UDim2.new(0, 5, 0, yPos)
            entry.BackgroundColor3 = selectedCar == car.Name and Color3.fromRGB(60, 60, 80) or Color3.fromRGB(35, 35, 45)
            entry.BorderSizePixel = 0
            entry.Parent = listFrame
            
            -- Car name
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Text = car.Name
            nameLabel.Size = UDim2.new(0.7, -10, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 14
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = entry
            
            -- Car source
            local sourceLabel = Instance.new("TextLabel")
            sourceLabel.Text = car.Source
            sourceLabel.Size = UDim2.new(0.3, -10, 0.5, 0)
            sourceLabel.Position = UDim2.new(0.7, 0, 0, 0)
            sourceLabel.BackgroundTransparency = 1
            sourceLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            sourceLabel.Font = Enum.Font.Gotham
            sourceLabel.TextSize = 10
            sourceLabel.TextXAlignment = Enum.TextXAlignment.Right
            sourceLabel.Parent = entry
            
            -- Select button
            local selectBtn = Instance.new("TextButton")
            selectBtn.Text = "SELECT"
            selectBtn.Size = UDim2.new(0.3, -10, 0.5, -5)
            selectBtn.Position = UDim2.new(0.7, 0, 0.5, 5)
            selectBtn.BackgroundColor3 = selectedCar == car.Name and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 100)
            selectBtn.TextColor3 = Color3.new(1, 1, 1)
            selectBtn.Font = Enum.Font.GothamBold
            selectBtn.TextSize = 12
            selectBtn.Parent = entry
            
            -- Click to select
            selectBtn.MouseButton1Click:Connect(function()
                selectedCar = car.Name
                status.Text = "Selected: " .. car.Name
                displayCars(cars) -- Refresh to update colors
            end)
            
            yPos = yPos + 55
        end
        
        listFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
        status.Text = "Found " .. #cars .. " cars. Select one to duplicate."
    end
    
    -- Load cars
    local allCars = findAllCars()
    displayCars(allCars)
    
    -- Search functionality
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local searchText = searchBox.Text:lower()
        if searchText == "" then
            displayCars(allCars)
        else
            local filtered = {}
            for _, car in pairs(allCars) do
                if car.Name:lower():find(searchText) then
                    table.insert(filtered, car)
                end
            end
            displayCars(filtered)
        end
    end)
    
    -- Refresh button
    refreshBtn.MouseButton1Click:Connect(function()
        status.Text = "Refreshing car list..."
        allCars = findAllCars()
        displayCars(allCars)
    end)
    
    -- Duplicate button
    dupeBtn.MouseButton1Click:Connect(function()
        if not selectedCar then
            status.Text = "❌ Please select a car first!"
            return
        end
        
        status.Text = "Duplicating " .. selectedCar + "..."
        dupeBtn.Text = "WORKING..."
        dupeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local success = duplicateCar(selectedCar)
            if success then
                status.Text = "✅ Duplication attempt sent for: " + selectedCar + "\nCheck your garage!"
            else
                status.Text = "❌ Failed to duplicate " + selectedCar
            end
            
            dupeBtn.Text = "🎯 DUPLICATE SELECTED"
            dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    -- Add rounded corners
    local corners = {mainFrame, searchBox, listFrame, status}
    for _, obj in pairs(corners) do
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = obj
    end
    
    -- Entry corners
    for _, entry in pairs(listFrame:GetChildren()) do
        if entry:IsA("Frame") then
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 5)
            corner.Parent = entry
        end
    end
    
    return gui, status
end

-- ===== MAIN =====
print("🚗 CAR COLLECTION BROWSER LOADING...")

-- Create browser UI
task.wait(2)
local gui, status = createCarBrowser()

-- Auto-refresh after 5 seconds
task.spawn(function()
    task.wait(5)
    if status then
        status.Text = "Auto-refreshing car list..."
        -- Simulate refresh button click
        local refreshBtn = gui:FindFirstChild("MainFrame") and gui.MainFrame:FindFirstChild("ButtonFrame") and gui.MainFrame.ButtonFrame:FindFirstChild("RefreshButton")
        if refreshBtn then
            refreshBtn:Fire("MouseButton1Click")
        end
    end
end)

print("\n✅ CAR BROWSER READY!")
print("Browse all game cars and duplicate any you want!")
