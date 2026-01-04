-- 🚗 RESPONSIVE & DRAGGABLE CAR DUPLICATOR
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== QUICK CAR FINDER (Optimized) =====
local function findQuickCars()
    print("🔍 Quick searching for cars...")
    
    local cars = {}
    local seen = {}
    
    -- Known cars database
    local knownCars = {
        "Bontlay Bontaga", "Jegar Model F", "Corsaro T8", "Lavish Ventoge", 
        "Sportler Tecan", "Bontlay Cental RT", "Corsaro Roni", "Corsaro Pursane", 
        "Corsaro G08", "Corsaro P 213", "Bontlay Cental", "Jegar Sport", 
        "Corsaro GT", "Lavish GTX", "Sportler RS", "Bontlay Turbo", "Jegar Turbo",
        "Corsaro Turbo", "Lavish Turbo", "Sportler Turbo", "Bontlay SVR", 
        "Jegar SVR", "Corsaro SVR", "Lavish SVR", "Sportler SVR",
        "Bontlay Aventa", "Jegar Mustang", "Corsaro Corvette", "Lavish Ferrari",
        "Sportler Lamborghini", "Bontlay Porsche", "Jegar Bugatti", "Corsaro Koenigsegg",
        "Lavish McLaren", "Sportler Aston", "Bontlay Mercedes", "Jegar BMW",
        "Corsaro Audi", "Lavish Lexus", "Sportler Tesla", "Bontlay Toyota",
        "Jegar Honda", "Corsaro Nissan", "Lavish Ford", "Sportler Chevrolet",
        "Bontlay Dodge", "Jegar Jeep", "Corsaro Maserati", "Lavish Bentley",
        "Sportler Rolls", "Bontlay Pagani", "Jegar Alfa", "Corsaro Mini",
        "Lavish GT-R", "Sportler M4", "Bontlay RS7", "Jegar AMG",
        "Corsaro 911", "Lavish Huracan", "Sportler Aventador", "Bontlay Chiron",
        "Jegar P1", "Corsaro 720S", "Lavish DB11", "Sportler Vantage"
    }
    
    -- Add all known cars first
    for _, carName in pairs(knownCars) do
        if not seen[carName] then
            seen[carName] = true
            table.insert(cars, {
                Name = carName,
                Source = "Known Database",
                Category = getCarCategory(carName)
            })
        end
    end
    
    -- Quick scan of common locations
    local quickScans = {
        {Location = ReplicatedStorage, Name = "ReplicatedStorage"},
        {Location = Workspace, Name = "Workspace"}
    }
    
    -- Check ServerStorage if accessible
    local success, ServerStorage = pcall(function()
        return game:GetService("ServerStorage")
    end)
    
    if success then
        table.insert(quickScans, {Location = ServerStorage, Name = "ServerStorage"})
    end
    
    for _, scan in pairs(quickScans) do
        local location = scan.Location
        local locationName = scan.Name
        
        -- Check for Cars folder
        local carsFolder = location:FindFirstChild("Cars")
        if carsFolder then
            for _, item in pairs(carsFolder:GetChildren()) do
                if (item:IsA("Model") or item:IsA("Folder")) and not seen[item.Name] then
                    seen[item.Name] = true
                    table.insert(cars, {
                        Name = item.Name,
                        Source = locationName .. "/Cars",
                        Category = getCarCategory(item.Name),
                        Object = item
                    })
                end
            end
        end
        
        -- Check for Vehicles folder
        local vehiclesFolder = location:FindFirstChild("Vehicles")
        if vehiclesFolder then
            for _, item in pairs(vehiclesFolder:GetChildren()) do
                if (item:IsA("Model") or item:IsA("Folder")) and not seen[item.Name] then
                    seen[item.Name] = true
                    table.insert(cars, {
                        Name = item.Name,
                        Source = locationName .. "/Vehicles",
                        Category = getCarCategory(item.Name),
                        Object = item
                    })
                end
            end
        end
    end
    
    -- Sort and return
    table.sort(cars, function(a, b)
        return a.Name < b.Name
    end)
    
    print("✅ Found " .. #cars .. " cars")
    return cars
end

-- Helper function to categorize cars
local function getCarCategory(carName)
    local lowerName = carName:lower()
    
    if lowerName:find("bontlay") then return "Bontlay"
    elseif lowerName:find("jegar") then return "Jegar"
    elseif lowerName:find("corsaro") then return "Corsaro"
    elseif lowerName:find("lavish") then return "Lavish"
    elseif lowerName:find("sportler") then return "Sportler"
    elseif lowerName:find("turbo") then return "Turbo"
    elseif lowerName:find("gt") then return "GT"
    elseif lowerName:find("rs") then return "RS"
    elseif lowerName:find("svr") then return "SVR"
    else return "Other" end
end

-- ===== DUPLICATE CAR =====
local function duplicateCar(carName)
    print("🔄 Duplicating: " .. carName)
    
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
    
    -- Try different formats
    local formats = {
        "givecar " .. carName,
        "givecar " .. carName:gsub(" ", "_"),
        "givecar " .. carName:gsub(" ", ""),
        "car " .. carName,
        "vehicle " .. carName
    }
    
    for _, cmd in pairs(formats) do
        local success, result = pcall(function()
            cmdrEvent:FireServer(cmd)
            return true
        end)
        
        if success then
            print("✅ Sent: " .. cmd)
            return true
        else
            print("❌ Failed: " .. tostring(result))
        end
    end
    
    return false
end

-- ===== CREATE RESPONSIVE & DRAGGABLE UI =====
local function createResponsiveUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarDuplicatorUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 450, 0, 550)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = gui
    
    -- Title bar (for dragging)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "🚗 CAR DUPLICATOR v2.0"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "✕"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 16
    closeButton.Parent = titleBar
    
    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Text = "─"
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -70, 0, 5)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    minimizeButton.TextColor3 = Color3.new(1, 1, 1)
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 16
    minimizeButton.Parent = titleBar
    
    -- Content area
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -40)
    contentFrame.Position = UDim2.new(0, 0, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Search bar
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "SearchBox"
    searchBox.PlaceholderText = "🔍 Search cars..."
    searchBox.Size = UDim2.new(1, -20, 0, 35)
    searchBox.Position = UDim2.new(0, 10, 0, 10)
    searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    searchBox.TextColor3 = Color3.new(1, 1, 1)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 14
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = contentFrame
    
    -- Status label
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Text = "Loading cars..."
    statusLabel.Size = UDim2.new(1, -20, 0, 40)
    statusLabel.Position = UDim2.new(0, 10, 0, 55)
    statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    statusLabel.TextColor3 = Color3.new(1, 1, 1)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextWrapped = true
    statusLabel.Parent = contentFrame
    
    -- Car list
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Name = "ListFrame"
    listFrame.Size = UDim2.new(1, -20, 0, 300)
    listFrame.Position = UDim2.new(0, 10, 0, 105)
    listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 6
    listFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    listFrame.Parent = contentFrame
    
    -- Buttons container
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, -20, 0, 80)
    buttonsFrame.Position = UDim2.new(0, 10, 1, -90)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = contentFrame
    
    -- Refresh button
    local refreshButton = Instance.new("TextButton")
    refreshButton.Name = "RefreshButton"
    refreshButton.Text = "🔄 Refresh"
    refreshButton.Size = UDim2.new(0.5, -5, 0, 35)
    refreshButton.Position = UDim2.new(0, 0, 0, 0)
    refreshButton.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    refreshButton.TextColor3 = Color3.new(1, 1, 1)
    refreshButton.Font = Enum.Font.GothamBold
    refreshButton.TextSize = 14
    refreshButton.Parent = buttonsFrame
    
    -- Duplicate button
    local duplicateButton = Instance.new("TextButton")
    duplicateButton.Name = "DuplicateButton"
    duplicateButton.Text = "🎯 Duplicate"
    duplicateButton.Size = UDim2.new(0.5, -5, 0, 35)
    duplicateButton.Position = UDim2.new(0.5, 5, 0, 0)
    duplicateButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    duplicateButton.TextColor3 = Color3.new(1, 1, 1)
    duplicateButton.Font = Enum.Font.GothamBold
    duplicateButton.TextSize = 16
    duplicateButton.Parent = buttonsFrame
    
    -- Rapid duplicate button
    local rapidButton = Instance.new("TextButton")
    rapidButton.Name = "RapidButton"
    rapidButton.Text = "⚡ Rapid x10"
    rapidButton.Size = UDim2.new(1, 0, 0, 35)
    rapidButton.Position = UDim2.new(0, 0, 0, 40)
    rapidButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    rapidButton.TextColor3 = Color3.new(1, 1, 1)
    rapidButton.Font = Enum.Font.GothamBold
    rapidButton.TextSize = 14
    rapidButton.Visible = false
    rapidButton.Parent = buttonsFrame
    
    -- Add rounded corners
    local cornerRadius = UDim.new(0, 6)
    local elementsToRound = {
        mainFrame, titleBar, searchBox, statusLabel, listFrame,
        refreshButton, duplicateButton, rapidButton, closeButton, minimizeButton
    }
    
    for _, element in pairs(elementsToRound) do
        local corner = Instance.new("UICorner")
        corner.CornerRadius = cornerRadius
        corner.Parent = element
    end
    
    -- Make UI draggable
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Variables
    local allCars = {}
    local displayedCars = {}
    local selectedCar = nil
    local isMinimized = false
    
    -- Function to update car list
    local function updateCarList(searchText)
        listFrame:ClearAllChildren()
        displayedCars = {}
        
        local searchLower = searchText:lower()
        local yPosition = 2
        
        for _, car in ipairs(allCars) do
            if searchText == "" or car.Name:lower():find(searchLower) then
                -- Create car entry
                local entryFrame = Instance.new("Frame")
                entryFrame.Size = UDim2.new(1, -4, 0, 32)
                entryFrame.Position = UDim2.new(0, 2, 0, yPosition)
                entryFrame.BackgroundColor3 = selectedCar == car.Name and Color3.fromRGB(60, 80, 60) or Color3.fromRGB(35, 35, 45)
                entryFrame.Parent = listFrame
                
                local entryCorner = Instance.new("UICorner")
                entryCorner.CornerRadius = UDim.new(0, 4)
                entryCorner.Parent = entryFrame
                
                -- Car name
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = car.Name
                nameLabel.Size = UDim2.new(0.75, -5, 1, 0)
                nameLabel.Position = UDim2.new(0, 5, 0, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.Font = Enum.Font.Gotham
                nameLabel.TextSize = 13
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                nameLabel.Parent = entryFrame
                
                -- Category tag
                local categoryLabel = Instance.new("TextLabel")
                categoryLabel.Text = car.Category or "Other"
                categoryLabel.Size = UDim2.new(0.25, -5, 1, 0)
                categoryLabel.Position = UDim2.new(0.75, 0, 0, 0)
                categoryLabel.BackgroundTransparency = 1
                categoryLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
                categoryLabel.Font = Enum.Font.Gotham
                categoryLabel.TextSize = 10
                categoryLabel.TextXAlignment = Enum.TextXAlignment.Right
                categoryLabel.Parent = entryFrame
                
                -- Click area
                local clickButton = Instance.new("TextButton")
                clickButton.Text = ""
                clickButton.Size = UDim2.new(1, 0, 1, 0)
                clickButton.BackgroundTransparency = 1
                clickButton.Parent = entryFrame
                
                -- Click event
                clickButton.MouseButton1Click:Connect(function()
                    selectedCar = car.Name
                    statusLabel.Text = "Selected: " .. car.Name
                    updateCarList(searchText) -- Update to show selection
                    
                    -- Show rapid button
                    rapidButton.Visible = true
                end)
                
                table.insert(displayedCars, car)
                yPosition = yPosition + 37
            end
        end
        
        listFrame.CanvasSize = UDim2.new(0, 0, 0, yPosition)
        statusLabel.Text = "Showing " .. #displayedCars .. " of " .. #allCars .. " cars" .. 
                          (selectedCar and "\nSelected: " .. selectedCar or "")
    end
    
    -- Function to load cars
    local function loadCars()
        statusLabel.Text = "Searching for cars..."
        refreshButton.Text = "Searching..."
        refreshButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            allCars = findQuickCars()
            updateCarList(searchBox.Text)
            
            refreshButton.Text = "🔄 Refresh"
            refreshButton.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
        end)
    end
    
    -- Initial load
    loadCars()
    
    -- Event handlers
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        updateCarList(searchBox.Text)
    end)
    
    refreshButton.MouseButton1Click:Connect(function()
        loadCars()
    end)
    
    duplicateButton.MouseButton1Click:Connect(function()
        if not selectedCar then
            statusLabel.Text = "❌ Please select a car first!"
            return
        end
        
        statusLabel.Text = "Duplicating: " .. selectedCar .. "..."
        duplicateButton.Text = "Working..."
        duplicateButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local success = duplicateCar(selectedCar)
            
            if success then
                statusLabel.Text = "✅ Success! Check your garage.\nCar: " .. selectedCar
            else
                statusLabel.Text = "❌ Failed to duplicate.\nTry another car or server."
            end
            
            task.wait(2)
            duplicateButton.Text = "🎯 Duplicate"
            duplicateButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    rapidButton.MouseButton1Click:Connect(function()
        if not selectedCar then return end
        
        statusLabel.Text = "⚡ Rapid duplication: " .. selectedCar
        rapidButton.Text = "Sending x10..."
        rapidButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        
        task.spawn(function()
            local successCount = 0
            for i = 1, 10 do
                if duplicateCar(selectedCar) then
                    successCount = successCount + 1
                end
                task.wait(0.1)
            end
            
            statusLabel.Text = "⚡ Sent " .. successCount .. "/10 attempts\nCheck your garage!"
            
            task.wait(2)
            rapidButton.Text = "⚡ Rapid x10"
            rapidButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        end)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        if isMinimized then
            -- Restore
            contentFrame.Visible = true
            mainFrame.Size = UDim2.new(0, 450, 0, 550)
            minimizeButton.Text = "─"
            isMinimized = false
        else
            -- Minimize
            contentFrame.Visible = false
            mainFrame.Size = UDim2.new(0, 450, 0, 40)
            minimizeButton.Text = "+"
            isMinimized = true
        end
    end)
    
    -- Make UI resizable
    local resizeButton = Instance.new("TextButton")
    resizeButton.Text = "↘"
    resizeButton.Size = UDim2.new(0, 20, 0, 20)
    resizeButton.Position = UDim2.new(1, -20, 1, -20)
    resizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    resizeButton.TextColor3 = Color3.new(1, 1, 1)
    resizeButton.Font = Enum.Font.GothamBold
    resizeButton.TextSize = 12
    resizeButton.Parent = mainFrame
    
    local resizeCorner = Instance.new("UICorner")
    resizeCorner.CornerRadius = UDim.new(0, 4)
    resizeCorner.Parent = resizeButton
    
    local resizing = false
    local resizeStart, resizeStartSize
    
    resizeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            resizeStartSize = mainFrame.Size
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    resizing = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newWidth = math.max(400, resizeStartSize.X.Offset + delta.X)
            local newHeight = math.max(300, resizeStartSize.Y.Offset + delta.Y)
            
            mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
            
            -- Adjust content
            listFrame.Size = UDim2.new(1, -20, 0, newHeight - 220)
        end
    end)
    
    -- Add shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundTransparency = 1
    shadow.Parent = mainFrame
    shadow.ZIndex = -1
    
    return gui
end

-- ===== MAIN =====
print("🚗 RESPONSIVE CAR DUPLICATOR")
print("Loading...")
task.wait(1)

local ui = createResponsiveUI()
print("✅ UI Created Successfully!")
print("\n🎮 CONTROLS:")
print("• Drag the blue title bar to move")
print("• Click ↘ in bottom-right to resize")
print("• Use ─/+ to minimize/restore")
print("• Click ✕ to close")
print("\n🚀 FEATURES:")
print("• Shows 80+ cars instantly")
print("• Fast search and filtering")
print("• One-click duplication")
print("• Rapid x10 duplication")
print("• Fully draggable & resizable")
print("\n💡 TIP: Try different servers if it doesn't work!")
