-- 🚗 SIMPLE CAR BROWSER & DUPLICATOR (FIXED)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== SIMPLE CAR FINDER =====
local function findCarsSimple()
    print("🔍 Finding cars...")
    
    local cars = {}
    
    -- Add your known cars first
    local knownCars = {
        "Bontlay Bontaga",
        "Jegar Model F",
        "Corsaro T8",
        "Lavish Ventoge",
        "Sportler Tecan",
        "Bontlay Cental RT",
        "Corsaro Roni",
        "Corsaro Pursane",
        "Corsaro G08",
        "Corsaro P 213"
    }
    
    for _, carName in pairs(knownCars) do
        table.insert(cars, {
            Name = carName,
            Source = "Known Cars"
        })
    end
    
    -- Check folders
    local checkFolders = {
        ReplicatedStorage:FindFirstChild("Cars"),
        ReplicatedStorage:FindFirstChild("Vehicles"),
        ReplicatedStorage:FindFirstChild("CarShop"),
        Workspace:FindFirstChild("Cars")
    }
    
    for _, folder in pairs(checkFolders) do
        if folder then
            for _, item in pairs(folder:GetChildren()) do
                table.insert(cars, {
                    Name = item.Name,
                    Source = folder.Name
                })
            end
        end
    end
    
    -- Remove duplicates
    local unique = {}
    local seen = {}
    for _, car in pairs(cars) do
        if not seen[car.Name] then
            seen[car.Name] = true
            table.insert(unique, car)
        end
    end
    
    -- Sort
    table.sort(unique, function(a, b)
        return a.Name < b.Name
    end)
    
    print("✅ Found " .. #unique .. " cars")
    return unique
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
        "givecar " .. carName:gsub(" ", "")
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
    title.Text = "🚗 CAR DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = frame
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Loading cars..."
    status.Size = UDim2.new(1, -20, 0, 60)
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
    listFrame.Position = UDim2.new(0, 10, 0, 130)
    listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 8
    listFrame.Parent = frame
    
    -- Buttons
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Text = "🔄 REFRESH LIST"
    refreshBtn.Size = UDim2.new(1, -20, 0, 40)
    refreshBtn.Position = UDim2.new(0, 10, 0, 440)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    refreshBtn.TextColor3 = Color3.new(1, 1, 1)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 14
    refreshBtn.Parent = frame
    
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "🎯 DUPLICATE SELECTED"
    dupeBtn.Size = UDim2.new(1, -20, 0, 40)
    dupeBtn.Position = UDim2.new(0, 10, 0, 490)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.GothamBold
    dupeBtn.TextSize = 16
    dupeBtn.Parent = frame
    
    -- Selected car
    local selectedCar = nil
    
    -- Function to show cars
    local function showCars(carList)
        listFrame:ClearAllChildren()
        
        local y = 5
        for i, car in pairs(carList) do
            -- Entry frame
            local entry = Instance.new("Frame")
            entry.Name = "Entry_" .. i
            entry.Size = UDim2.new(1, -10, 0, 40)
            entry.Position = UDim2.new(0, 5, 0, y)
            entry.BackgroundColor3 = selectedCar == car.Name and Color3.fromRGB(60, 80, 60) or Color3.fromRGB(40, 40, 50)
            entry.BorderSizePixel = 0
            entry.Parent = listFrame
            
            -- Car name
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Text = car.Name
            nameLabel.Size = UDim2.new(0.8, -5, 1, 0)
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
            sourceLabel.Size = UDim2.new(0.2, -5, 1, 0)
            sourceLabel.Position = UDim2.new(0.8, 0, 0, 0)
            sourceLabel.BackgroundTransparency = 1
            sourceLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            sourceLabel.Font = Enum.Font.Gotham
            sourceLabel.TextSize = 10
            sourceLabel.TextXAlignment = Enum.TextXAlignment.Right
            sourceLabel.Parent = entry
            
            -- Click detection using TextButton overlay
            local clickBtn = Instance.new("TextButton")
            clickBtn.Text = ""
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.Position = UDim2.new(0, 0, 0, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Parent = entry
            
            -- Click event
            clickBtn.MouseButton1Click:Connect(function()
                selectedCar = car.Name
                status.Text = "Selected: " .. car.Name
                showCars(carList) -- Refresh to update colors
            end)
            
            y = y + 45
        end
        
        listFrame.CanvasSize = UDim2.new(0, 0, 0, y)
    end
    
    -- Initial load
    local cars = findCarsSimple()
    showCars(cars)
    status.Text = "Found " .. #cars .. " cars\nClick to select, then click DUPLICATE"
    
    -- Refresh button
    refreshBtn.MouseButton1Click:Connect(function()
        status.Text = "Refreshing..."
        cars = findCarsSimple()
        selectedCar = nil
        showCars(cars)
        status.Text = "Found " .. #cars .. " cars\nClick to select, then click DUPLICATE"
    end)
    
    -- Duplicate button
    dupeBtn.MouseButton1Click:Connect(function()
        if not selectedCar then
            status.Text = "❌ Please select a car first!\nClick on a car from the list."
            return
        end
        
        status.Text = "Duplicating: " .. selectedCar .. "\nSending command..."
        dupeBtn.Text = "WORKING..."
        dupeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local success = duplicateCar(selectedCar)
            
            if success then
                status.Text = "✅ Command sent: givecar " .. selectedCar .. "\nCheck your garage in 5 seconds!"
                
                -- Try rapid duplicates
                task.wait(1)
                for i = 1, 5 do
                    pcall(function()
                        duplicateCar(selectedCar)
                    end)
                    task.wait(0.1)
                end
                
                status.Text = status.Text .. "\n🎉 Sent multiple duplication attempts!"
            else
                status.Text = "❌ Failed to send command\nTry a different car or server"
            end
            
            task.wait(2)
            dupeBtn.Text = "🎯 DUPLICATE SELECTED"
            dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    -- Add rounded corners
    local corners = {frame, status, listFrame, refreshBtn, dupeBtn}
    for _, obj in pairs(corners) do
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = obj
    end
    
    return gui
end

-- ===== MAIN =====
print("🚗 SIMPLE CAR DUPLICATOR")
task.wait(2)
createSimpleUI()
print("✅ UI Created!")
print("\nHow to use:")
print("1. Click any car in the list to select it")
print("2. Click 'DUPLICATE SELECTED' button")
print("3. Check your garage for the car")
print("4. If it doesn't work, try a different server")
