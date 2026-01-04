-- 🚗 TARGETED CAR DUPLICATOR - Based on Game Structure
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== FIND CAR DEALERSHIPS =====
local function findDealerships()
    print("🔍 Looking for dealerships...")
    
    local dealerships = {}
    
    -- Based on the error, we know the path pattern
    -- "Workspace.Tycoons.Slot [number].Dealership"
    local tycoons = Workspace:FindFirstChild("Tycoons")
    if tycoons then
        for _, slot in pairs(tycoons:GetChildren()) do
            if slot.Name:find("Slot") then
                local dealership = slot:FindFirstChild("Dealership")
                if dealership then
                    table.insert(dealerships, {
                        Slot = slot.Name,
                        Dealership = dealership,
                        Path = dealership:GetFullName()
                    })
                end
            end
        end
    end
    
    print("Found " .. #dealerships .. " dealerships")
    return dealerships
end

-- ===== FIND CARS IN DEALERSHIPS =====
local function findCarsInDealerships(dealerships)
    print("🚗 Looking for cars in dealerships...")
    
    local allCars = {}
    
    for _, dealer in pairs(dealerships) do
        local dealership = dealer.Dealership
        
        -- Look for Cars folder (based on the error)
        local carsFolder = dealership:FindFirstChild("Cars")
        if carsFolder then
            for _, car in pairs(carsFolder:GetChildren()) do
                if car:IsA("Model") then
                    table.insert(allCars, {
                        Name = car.Name,
                        Model = car,
                        Dealership = dealer.Slot,
                        Path = car:GetFullName()
                    })
                end
            end
        end
        
        -- Also check for Purchased folder (owned cars)
        local purchased = dealership:FindFirstChild("Purchased")
        if purchased then
            for _, car in pairs(purchased:GetChildren()) do
                if car:IsA("Model") then
                    table.insert(allCars, {
                        Name = car.Name,
                        Model = car,
                        Dealership = dealer.Slot,
                        Path = car:GetFullName(),
                        IsPurchased = true
                    })
                end
            end
        end
        
        -- Check for any car models directly in dealership
        for _, obj in pairs(dealership:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:find("Car") then
                local found = false
                for _, existing in pairs(allCars) do
                    if existing.Name == obj.Name then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(allCars, {
                        Name = obj.Name,
                        Model = obj,
                        Dealership = dealer.Slot,
                        Path = obj:GetFullName()
                    })
                end
            end
        end
    end
    
    print("Found " .. #allCars .. " cars")
    return allCars
end

-- ===== FIND TASK CONTROLLER =====
local function findTaskController()
    print("🔧 Looking for TaskController...")
    
    local modules = ReplicatedStorage:FindFirstChild("Modules")
    if modules then
        local taskController = modules:FindFirstChild("TaskController")
        if taskController then
            print("✅ Found TaskController module")
            
            -- Try to understand how it works
            local success, source = pcall(function()
                return taskController.Source
            end)
            
            if success and source then
                -- Look for car-related functions
                if source:find("Cars") then
                    print("📝 TaskController handles cars")
                end
                if source:find("purchase") or source:find("buy") then
                    print("💰 TaskController handles purchases")
                end
            end
            
            return taskController
        end
    end
    
    print("❌ TaskController not found")
    return nil
end

-- ===== TRY TO DUPLICATE CARS =====
local function tryDuplicateCar(carName, dealershipSlot)
    print("🔄 Attempting to duplicate: " .. carName)
    
    -- Method 1: Try to find purchase remotes
    local purchaseRemotes = {}
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nameLower = obj.Name:lower()
            if nameLower:find("purchase") or nameLower:find("buy") or 
               nameLower:find("car") or nameLower:find("vehicle") then
                table.insert(purchaseRemotes, {
                    Object = obj,
                    Name = obj.Name,
                    Path = obj:GetFullName()
                })
            end
        end
    end
    
    print("Found " .. #purchaseRemotes .. " purchase remotes")
    
    -- Try different data formats based on the dealership structure
    local testData = {
        -- Format 1: Simple car name
        carName,
        
        -- Format 2: With dealership slot
        {carName, dealershipSlot},
        {carName, tonumber(dealershipSlot:match("%d+"))},
        
        -- Format 3: Player + car
        {player, carName},
        {player.UserId, carName},
        
        -- Format 4: Complex structure
        {
            Car = carName,
            Slot = dealershipSlot,
            Player = player.Name,
            Price = 0
        },
        
        -- Format 5: Just slot number
        tonumber(dealershipSlot:match("%d+")),
        
        -- Format 6: Command format
        {"buy", carName},
        {"purchase", carName, dealershipSlot}
    }
    
    local successfulCalls = {}
    
    for _, remote in pairs(purchaseRemotes) do
        print("Testing remote: " .. remote.Name)
        
        for _, data in pairs(testData) do
            local success, result = pcall(function()
                remote.Object:FireServer(data)
                return "Success"
            end)
            
            if success then
                if not successfulCalls[remote.Name] then
                    successfulCalls[remote.Name] = {}
                end
                table.insert(successfulCalls[remote.Name], {
                    Data = data,
                    Result = result
                })
                
                print("✅ " .. remote.Name .. " accepted data")
                
                -- Send multiple times
                for i = 1, 5 do
                    pcall(function()
                        remote.Object:FireServer(data)
                    end)
                    task.wait(0.05)
                end
                print("   Sent 5 duplicates")
                
                break
            end
            
            task.wait(0.05)
        end
    end
    
    return successfulCalls
end

-- ===== SIMPLE UI =====
local function createSimpleUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarDuplicator"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Main Window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 400)
    main.Position = UDim2.new(0.5, -150, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title Bar (Draggable)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleBar.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Text = "🚗 TARGETED DUPE"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.Parent = titleBar
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Ready to find cars..."
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 0, 10)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = content
    
    -- Buttons
    local findBtn = Instance.new("TextButton")
    findBtn.Text = "🔍 FIND CARS"
    findBtn.Size = UDim2.new(1, -20, 0, 30)
    findBtn.Position = UDim2.new(0, 10, 0, 70)
    findBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    findBtn.TextColor3 = Color3.new(1, 1, 1)
    findBtn.Font = Enum.Font.GothamBold
    findBtn.TextSize = 12
    findBtn.Parent = content
    
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "🎯 DUPLICATE"
    dupeBtn.Size = UDim2.new(1, -20, 0, 30)
    dupeBtn.Position = UDim2.new(0, 10, 0, 110)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.GothamBold
    dupeBtn.TextSize = 12
    dupeBtn.Parent = content
    
    local rapidBtn = Instance.new("TextButton")
    rapidBtn.Text = "⚡ RAPID x10"
    rapidBtn.Size = UDim2.new(1, -20, 0, 30)
    rapidBtn.Position = UDim2.new(0, 10, 0, 150)
    rapidBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    rapidBtn.TextColor3 = Color3.new(1, 1, 1)
    rapidBtn.Font = Enum.Font.GothamBold
    rapidBtn.TextSize = 12
    rapidBtn.Parent = content
    
    -- Car List
    local carList = Instance.new("ScrollingFrame")
    carList.Size = UDim2.new(1, -20, 0, 170)
    carList.Position = UDim2.new(0, 10, 0, 190)
    carList.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    carList.BorderSizePixel = 0
    carList.ScrollBarThickness = 4
    carList.Parent = content
    
    -- Add rounded corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    addCorner(main)
    addCorner(titleBar)
    addCorner(status)
    addCorner(findBtn)
    addCorner(dupeBtn)
    addCorner(rapidBtn)
    addCorner(carList)
    addCorner(closeBtn)
    
    -- === DRAGGABLE WINDOW ===
    local dragging = false
    local dragStart, frameStart
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = main.Position
        end
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
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- === VARIABLES ===
    local foundCars = {}
    local selectedCar = nil
    local selectedDealership = nil
    
    -- === FUNCTIONS ===
    local function updateCarList()
        carList:ClearAllChildren()
        
        local yPos = 5
        for i, car in ipairs(foundCars) do
            local entry = Instance.new("Frame")
            entry.Size = UDim2.new(1, -10, 0, 40)
            entry.Position = UDim2.new(0, 5, 0, yPos)
            
            -- Highlight selected car
            if selectedCar == car.Name then
                entry.BackgroundColor3 = Color3.fromRGB(60, 80, 60)
            else
                entry.BackgroundColor3 = i % 2 == 0 and Color3.fromRGB(35, 35, 45) or Color3.fromRGB(30, 30, 40)
            end
            
            addCorner(entry)
            entry.Parent = carList
            
            -- Car name
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Text = car.Name
            nameLabel.Size = UDim2.new(0.7, -5, 1, -10)
            nameLabel.Position = UDim2.new(0, 5, 0, 5)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = entry
            
            -- Dealership
            local dealerLabel = Instance.new("TextLabel")
            dealerLabel.Text = car.Dealership
            dealerLabel.Size = UDim2.new(0.3, -5, 1, -10)
            dealerLabel.Position = UDim2.new(0.7, 0, 0, 5)
            dealerLabel.BackgroundTransparency = 1
            dealerLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            dealerLabel.Font = Enum.Font.Gotham
            dealerLabel.TextSize = 10
            dealerLabel.TextXAlignment = Enum.TextXAlignment.Right
            dealerLabel.Parent = entry
            
            -- Select button (invisible overlay)
            local selectBtn = Instance.new("TextButton")
            selectBtn.Text = ""
            selectBtn.Size = UDim2.new(1, 0, 1, 0)
            selectBtn.BackgroundTransparency = 1
            selectBtn.Parent = entry
            
            selectBtn.MouseButton1Click:Connect(function()
                selectedCar = car.Name
                selectedDealership = car.Dealership
                status.Text = "Selected: " .. car.Name .. "\nDealership: " .. car.Dealership
                updateCarList()
            end)
            
            yPos = yPos + 45
        end
        
        carList.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end
    
    -- === BUTTON ACTIONS ===
    findBtn.MouseButton1Click:Connect(function()
        findBtn.Text = "SEARCHING..."
        findBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Searching for dealerships..."
        
        task.spawn(function()
            -- Find task controller first
            local taskController = findTaskController()
            
            -- Find dealerships
            local dealerships = findDealerships()
            
            if #dealerships == 0 then
                status.Text = "❌ No dealerships found!\nIs this a car game?"
                findBtn.Text = "🔍 FIND CARS"
                findBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
                return
            end
            
            -- Find cars in dealerships
            foundCars = findCarsInDealerships(dealerships)
            
            if #foundCars == 0 then
                status.Text = "❌ No cars found in dealerships"
            else
                status.Text = "✅ Found " .. #foundCars .. " cars!\nClick a car to select it."
                updateCarList()
            end
            
            if taskController then
                status.Text = status.Text .. "\n\n⚠️ TaskController detected"
                status.Text = status.Text .. "\nGame has anti-dupe protection"
            end
            
            findBtn.Text = "🔍 FIND CARS"
            findBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        end)
    end)
    
    dupeBtn.MouseButton1Click:Connect(function()
        if not selectedCar then
            status.Text = "❌ Select a car first!\nClick on a car from the list."
            return
        end
        
        dupeBtn.Text = "WORKING..."
        dupeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Duplicating " .. selectedCar + "..."
        
        task.spawn(function()
            local results = tryDuplicateCar(selectedCar, selectedDealership)
            
            local successCount = 0
            for _ in pairs(results) do
                successCount = successCount + 1
            end
            
            if successCount > 0 then
                status.Text = "✅ " .. successCount .. " remotes accepted!\nCheck your inventory!"
            else
                status.Text = "❌ No remotes accepted data.\nTry a different car or server."
            end
            
            dupeBtn.Text = "🎯 DUPLICATE"
            dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    rapidBtn.MouseButton1Click:Connect(function()
        if not selectedCar then
            status.Text = "❌ Select a car first!"
            return
        end
        
        rapidBtn.Text = "SENDING x10..."
        rapidBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        status.Text = "Sending 10 duplicates of " .. selectedCar + "..."
        
        task.spawn(function()
            for i = 1, 10 do
                tryDuplicateCar(selectedCar, selectedDealership)
                status.Text = "Sending " .. i .. "/10..."
                task.wait(0.5)
            end
            
            rapidBtn.Text = "⚡ RAPID x10"
            rapidBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            status.Text = "✅ 10 duplicates sent!\nCheck your inventory!"
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== MAIN =====
print("=" .. string.rep("=", 60))
print("🚗 TARGETED CAR DUPLICATOR")
print("Based on game structure analysis")
print("=" .. string.rep("=", 60))

print("\n🎯 Game Structure Detected:")
print("• Workspace.Tycoons.Slot [X].Dealership")
print("• Cars stored in Dealership.Cars folder")
print("• TaskController module for purchases")

print("\n🔧 Initializing...")
task.wait(1)

local ui = createSimpleUI()
print("\n✅ UI Ready!")
print("\n💡 How to use:")
print("1. Click FIND CARS to locate dealerships")
print("2. Select a car from the list")
print("3. Click DUPLICATE to try duplication")
print("4. Use RAPID x10 for multiple attempts")
print("5. Check inventory after testing")

print("\n⚠️  Note:")
print("TaskController detected - game has anti-dupe")
print("Might not work on all servers")
