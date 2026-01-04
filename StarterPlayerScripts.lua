-- 🚗 COMPLETE CAR BROWSER & DUPLICATOR
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== COMPREHENSIVE CAR FINDER =====
local function findAllCars()
    print("🔍 Searching for ALL cars...")
    
    local cars = {}
    local locationsChecked = {}
    
    -- Known car brands/names for filtering
    local carKeywords = {
        "Bontlay", "Jegar", "Corsaro", "Sportler", "Lavish",
        "Cental", "Model", "T8", "Tecan", "Ventoge", "Roni",
        "Pursane", "G08", "Turbo", "GT", "RS", "RT", "SVR",
        "Aventa", "Mustang", "Corvette", "Ferrari", "Lamborghini",
        "Porsche", "Bugatti", "Koenigsegg", "McLaren", "Aston",
        "Mercedes", "BMW", "Audi", "Lexus", "Tesla", "Toyota",
        "Honda", "Nissan", "Ford", "Chevrolet", "Dodge", "Jeep",
        "Maserati", "Bentley", "Rolls", "Pagani", "Alfa", "Mini"
    }
    
    -- Function to check if name looks like a car
    local function isCarName(name)
        local lowerName = name:lower()
        
        -- Common non-car names to skip
        local skipNames = {
            "template", "spawn", "dealer", "shop", "store", "base",
            "example", "test", "default", "placeholder", "gui",
            "ui", "button", "frame", "label", "text", "image",
            "sound", "music", "script", "module", "local", "remote",
            "event", "function", "value", "folder", "model", "part"
        }
        
        for _, skip in ipairs(skipNames) do
            if lowerName:find(skip) then
                return false
            end
        end
        
        -- Check for car keywords
        for _, keyword in ipairs(carKeywords) do
            if name:find(keyword) then
                return true
            end
        end
        
        -- Check for car-like patterns
        if #name > 2 and #name < 50 then
            -- Has spaces (multi-word names like "Bontlay Bontaga")
            if name:find(" ") then
                return true
            end
            
            -- Has numbers (like "G08", "T8", "Aventa_12")
            if name:find("%d") then
                return true
            end
            
            -- Has underscores (common for car names)
            if name:find("_") then
                return true
            end
            
            -- Looks like a model name with letters and numbers
            if name:match("^[%a%s]+%d+") then
                return true
            end
        end
        
        return false
    end
    
    -- Function to search location
    local function searchLocation(location, locationName)
        if not location or locationsChecked[location] then
            return
        end
        
        locationsChecked[location] = true
        
        for _, obj in pairs(location:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("Part") then
                -- Check the object itself
                if isCarName(obj.Name) then
                    local found = false
                    for _, existingCar in ipairs(cars) do
                        if existingCar.Name == obj.Name then
                            found = true
                            break
                        end
                    end
                    
                    if not found then
                        table.insert(cars, {
                            Name = obj.Name,
                            Source = locationName,
                            Object = obj
                        })
                    end
                end
                
                -- Search inside the object
                searchLocation(obj, locationName .. " → " .. obj.Name)
            end
        end
    end
    
    -- ===== SEARCH ALL RELEVANT LOCATIONS =====
    
    print("📂 Searching ReplicatedStorage...")
    searchLocation(ReplicatedStorage, "ReplicatedStorage")
    
    print("📂 Searching ServerStorage...")
    local ServerStorage = game:GetService("ServerStorage")
    if ServerStorage then
        searchLocation(ServerStorage, "ServerStorage")
    end
    
    print("📂 Searching Workspace for cars...")
    -- Check for car showrooms, dealerships, etc.
    local carPlaces = {}
    
    -- Look for car-related folders in Workspace
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") or obj:IsA("Folder") then
            local lowerName = obj.Name:lower()
            if lowerName:find("car") or lowerName:find("vehicle") or 
               lowerName:find("showroom") or lowerName:find("dealership") or
               lowerName:find("garage") or lowerName:find("lot") then
                searchLocation(obj, "Workspace." .. obj.Name)
            end
        end
    end
    
    -- Check Workspace directly for car models
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and isCarName(obj.Name) then
            local found = false
            for _, existingCar in ipairs(cars) do
                if existingCar.Name == obj.Name then
                    found = true
                    break
                end
            end
            
            if not found then
                table.insert(cars, {
                    Name = obj.Name,
                    Source = "Workspace",
                    Object = obj
                })
            end
        end
    end
    
    -- ===== SEARCH FOR CAR DATA IN MODULES =====
    
    print("📦 Searching module scripts for car data...")
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local nameLower = obj.Name:lower()
            if nameLower:find("car") or nameLower:find("vehicle") or 
               nameLower:find("data") or nameLower:find("shop") then
                
                -- Try to get module source to find car names
                local success, source = pcall(function()
                    return obj.Source
                end)
                
                if success and source then
                    -- Look for car names in the source code
                    for _, keyword in ipairs(carKeywords) do
                        if source:find(keyword) then
                            -- Extract potential car names from source
                            for line in source:gmatch("[^\r\n]+") do
                                if line:find(keyword) and line:find('"') then
                                    -- Try to extract quoted strings
                                    for quoted in line:gmatch('"([^"]+)"') do
                                        if isCarName(quoted) then
                                            local found = false
                                            for _, existingCar in ipairs(cars) do
                                                if existingCar.Name == quoted then
                                                    found = true
                                                    break
                                                end
                                            end
                                            
                                            if not found then
                                                table.insert(cars, {
                                                    Name = quoted,
                                                    Source = "Module: " .. obj.Name,
                                                    FromSource = true
                                                })
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- ===== ADD KNOWN CARS =====
    
    print("📋 Adding known cars...")
    local knownCars = {
        "Bontlay Bontaga", "Jegar Model F", "Corsaro T8", "Lavish Ventoge", 
        "Sportler Tecan", "Bontlay Cental RT", "Corsaro Roni", "Corsaro Pursane", 
        "Corsaro G08", "Corsaro P 213", "Bontlay Cental", "Jegar Sport", 
        "Corsaro GT", "Lavish GTX", "Sportler RS", "Bontlay Turbo", "Jegar Turbo",
        "Corsaro Turbo", "Lavish Turbo", "Sportler Turbo", "Bontlay SVR", 
        "Jegar SVR", "Corsaro SVR", "Lavish SVR", "Sportler SVR"
    }
    
    for _, carName in pairs(knownCars) do
        local found = false
        for _, existingCar in ipairs(cars) do
            if existingCar.Name == carName then
                found = true
                break
            end
        end
        
        if not found then
            table.insert(cars, {
                Name = carName,
                Source = "Known Cars",
                IsKnown = true
            })
        end
    end
    
    -- ===== SORT AND FILTER =====
    
    -- Remove duplicates
    local uniqueCars = {}
    local seenNames = {}
    
    for _, car in ipairs(cars) do
        if not seenNames[car.Name] then
            seenNames[car.Name] = true
            table.insert(uniqueCars, car)
        end
    end
    
    -- Sort alphabetically
    table.sort(uniqueCars, function(a, b)
        return a.Name < b.Name
    end)
    
    print("✅ Found " .. #uniqueCars .. " unique cars")
    
    -- Print categories
    local categories = {}
    for _, car in ipairs(uniqueCars) do
        local source = car.Source or "Unknown"
        if not categories[source] then
            categories[source] = 0
        end
        categories[source] = categories[source] + 1
    end
    
    print("\n📊 By location:")
    for source, count in pairs(categories) do
        print(string.format("  %s: %d cars", source, count))
    end
    
    return uniqueCars
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
        "vehicle " .. carName,
        "addcar " .. carName,
        "spawncar " .. carName
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

-- ===== CREATE ADVANCED UI =====
local function createAdvancedUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 600)
    frame.Position = UDim2.new(0.5, -250, 0.5, -300)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 COMPLETE CAR DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Parent = frame
    
    -- Search bar
    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "🔍 Search cars..."
    searchBox.Size = UDim2.new(1, -20, 0, 40)
    searchBox.Position = UDim2.new(0, 10, 0, 70)
    searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    searchBox.TextColor3 = Color3.new(1, 1, 1)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 14
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = frame
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Loading ALL cars... This may take a moment."
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 0, 120)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = frame
    
    -- Car list
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, -20, 0, 350)
    listFrame.Position = UDim2.new(0, 10, 0, 180)
    listFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 8
    listFrame.Parent = frame
    
    -- Filter buttons
    local filterFrame = Instance.new("Frame")
    filterFrame.Size = UDim2.new(1, -20, 0, 30)
    filterFrame.Position = UDim2.new(0, 10, 0, 540)
    filterFrame.BackgroundTransparency = 1
    filterFrame.Parent = frame
    
    local allFilter = Instance.new("TextButton")
    allFilter.Text = "ALL"
    allFilter.Size = UDim2.new(0.2, -2, 1, 0)
    allFilter.Position = UDim2.new(0, 0, 0, 0)
    allFilter.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    allFilter.TextColor3 = Color3.new(1, 1, 1)
    allFilter.Font = Enum.Font.GothamBold
    allFilter.TextSize = 12
    allFilter.Parent = filterFrame
    
    local popularFilter = Instance.new("TextButton")
    popularFilter.Text = "POPULAR"
    popularFilter.Size = UDim2.new(0.2, -2, 1, 0)
    popularFilter.Position = UDim2.new(0.2, 2, 0, 0)
    popularFilter.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    popularFilter.TextColor3 = Color3.new(1, 1, 1)
    popularFilter.Font = Enum.Font.GothamBold
    popularFilter.TextSize = 12
    popularFilter.Parent = filterFrame
    
    local luxuryFilter = Instance.new("TextButton")
    luxuryFilter.Text = "LUXURY"
    luxuryFilter.Size = UDim2.new(0.2, -2, 1, 0)
    luxuryFilter.Position = UDim2.new(0.4, 4, 0, 0)
    luxuryFilter.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    luxuryFilter.TextColor3 = Color3.new(1, 1, 1)
    luxuryFilter.Font = Enum.Font.GothamBold
    luxuryFilter.TextSize = 12
    luxuryFilter.Parent = filterFrame
    
    local sportsFilter = Instance.new("TextButton")
    sportsFilter.Text = "SPORTS"
    sportsFilter.Size = UDim2.new(0.2, -2, 1, 0)
    sportsFilter.Position = UDim2.new(0.6, 6, 0, 0)
    sportsFilter.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    sportsFilter.TextColor3 = Color3.new(1, 1, 1)
    sportsFilter.Font = Enum.Font.GothamBold
    sportsFilter.TextSize = 12
    sportsFilter.Parent = filterFrame
    
    -- Action buttons
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Text = "🔄 REFRESH ALL"
    refreshBtn.Size = UDim2.new(0.5, -15, 0, 40)
    refreshBtn.Position = UDim2.new(0, 10, 1, -50)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    refreshBtn.TextColor3 = Color3.new(1, 1, 1)
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 14
    refreshBtn.Parent = frame
    
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "🎯 DUPLICATE SELECTED"
    dupeBtn.Size = UDim2.new(0.5, -15, 0, 40)
    dupeBtn.Position = UDim2.new(0.5, 5, 1, -50)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.GothamBold
    dupeBtn.TextSize = 16
    dupeBtn.Parent = frame
    
    -- Variables
    local allCars = {}
    local filteredCars = {}
    local selectedCar = nil
    local currentFilter = "ALL"
    
    -- Function to filter cars
    local function filterCars(searchText, filterType)
        local results = {}
        local lowerSearch = searchText:lower()
        
        for _, car in ipairs(allCars) do
            local lowerName = car.Name:lower()
            local matchesSearch = searchText == "" or lowerName:find(lowerSearch)
            local matchesFilter = true
            
            if filterType == "POPULAR" then
                matchesFilter = car.Name:find("Bontlay") or car.Name:find("Corsaro") or car.Name:find("Jegar")
            elseif filterType == "LUXURY" then
                matchesFilter = car.Name:find("Lavish") or car.Name:find("Bentley") or car.Name:find("Rolls")
            elseif filterType == "SPORTS" then
                matchesFilter = car.Name:find("Sportler") or car.Name:find("GT") or car.Name:find("RS") or car.Name:find("Turbo")
            end
            
            if matchesSearch and matchesFilter then
                table.insert(results, car)
            end
        end
        
        return results
    end
    
    -- Function to show cars
    local function showCars(carList)
        listFrame:ClearAllChildren()
        
        local y = 5
        for i, car in ipairs(carList) do
            -- Entry frame
            local entry = Instance.new("Frame")
            entry.Name = "Entry_" .. i
            entry.Size = UDim2.new(1, -10, 0, 35)
            entry.Position = UDim2.new(0, 5, 0, y)
            entry.BackgroundColor3 = selectedCar == car.Name and Color3.fromRGB(60, 80, 60) or Color3.fromRGB(40, 40, 50)
            entry.BorderSizePixel = 0
            entry.Parent = listFrame
            
            -- Car name
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
            
            -- Click detection
            local clickBtn = Instance.new("TextButton")
            clickBtn.Text = ""
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.Position = UDim2.new(0, 0, 0, 0)
            clickBtn.BackgroundTransparency = 1
            clickBtn.Parent = entry
            
            -- Click event
            clickBtn.MouseButton1Click:Connect(function()
                selectedCar = car.Name
                status.Text = "Selected: " .. car.Name .. " (" .. car.Source .. ")"
                showCars(carList)
            end)
            
            y = y + 40
        end
        
        listFrame.CanvasSize = UDim2.new(0, 0, 0, y)
        status.Text = "Found " .. #carList .. " cars (Total: " .. #allCars .. ")"
        if selectedCar then
            status.Text = status.Text .. " | Selected: " .. selectedCar
        end
    end
    
    -- Initial load
    task.spawn(function()
        allCars = findAllCars()
        filteredCars = filterCars("", "ALL")
        showCars(filteredCars)
    end)
    
    -- Search functionality
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        filteredCars = filterCars(searchBox.Text, currentFilter)
        showCars(filteredCars)
    end)
    
    -- Filter buttons
    local function updateFilter(button, filterType)
        currentFilter = filterType
        allFilter.BackgroundColor3 = filterType == "ALL" and Color3.fromRGB(50, 120, 220) or Color3.fromRGB(60, 60, 70)
        popularFilter.BackgroundColor3 = filterType == "POPULAR" and Color3.fromRGB(50, 120, 220) or Color3.fromRGB(60, 60, 70)
        luxuryFilter.BackgroundColor3 = filterType == "LUXURY" and Color3.fromRGB(50, 120, 220) or Color3.fromRGB(60, 60, 70)
        sportsFilter.BackgroundColor3 = filterType == "SPORTS" and Color3.fromRGB(50, 120, 220) or Color3.fromRGB(60, 60, 70)
        
        filteredCars = filterCars(searchBox.Text, filterType)
        showCars(filteredCars)
    end
    
    allFilter.MouseButton1Click:Connect(function() updateFilter(allFilter, "ALL") end)
    popularFilter.MouseButton1Click:Connect(function() updateFilter(popularFilter, "POPULAR") end)
    luxuryFilter.MouseButton1Click:Connect(function() updateFilter(luxuryFilter, "LUXURY") end)
    sportsFilter.MouseButton1Click:Connect(function() updateFilter(sportsFilter, "SPORTS") end)
    
    -- Refresh button
    refreshBtn.MouseButton1Click:Connect(function()
        status.Text = "Refreshing... Searching for ALL cars..."
        refreshBtn.Text = "SEARCHING..."
        refreshBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            allCars = findAllCars()
            filteredCars = filterCars(searchBox.Text, currentFilter)
            selectedCar = nil
            showCars(filteredCars)
            
            refreshBtn.Text = "🔄 REFRESH ALL"
            refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
        end)
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
                
                -- Send multiple attempts
                task.wait(0.5)
                for i = 1, 10 do
                    pcall(function()
                        duplicateCar(selectedCar)
                    end)
                    task.wait(0.05)
                end
                
                status.Text = status.Text .. "\n🎉 Sent 10 duplication attempts!"
            else
                status.Text = "❌ Failed to send command\nTry a different car or server"
            end
            
            task.wait(3)
            dupeBtn.Text = "🎯 DUPLICATE SELECTED"
            dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    -- Add rounded corners
    local corners = {frame, title, searchBox, status, listFrame, allFilter, popularFilter, 
                     luxuryFilter, sportsFilter, refreshBtn, dupeBtn}
    for _, obj in pairs(corners) do
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = obj
    end
    
    -- Add close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = title
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== MAIN =====
print("🚗 COMPLETE CAR DUPLICATOR")
task.wait(2)
createAdvancedUI()
print("✅ Advanced UI Created!")
print("\n🔥 Features:")
print("• Searches EVERYWHERE for cars")
print("• Shows 100+ car models")
print("• Search and filter functionality")
print("• One-click duplication")
print("\n💡 Tips:")
print("1. Use search box to find specific cars")
print("2. Click 'REFRESH ALL' to update list")
print("3. Try different filters (ALL, POPULAR, etc.)")
print("4. Click on any car to select it")
print("5. Click 'DUPLICATE SELECTED' to get the car")
