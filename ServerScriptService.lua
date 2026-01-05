-- 🎯 FIXED DUPLICATION SYSTEM
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 FIXED DUPLICATION SYSTEM")
print("=" .. string.rep("=", 50))

-- ===== GET CAR DATA =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

local function getCars()
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(cars) == "table" then
        return cars
    end
    return {}
end

-- ===== FIND REMOTES IN ALL LOCATIONS =====
local function findAllRemotes()
    local remotes = {}
    
    -- Search in common locations
    local searchLocations = {
        ReplicatedStorage,
        workspace,
        game:GetService("ServerStorage"),
        game:GetService("ServerScriptService")
    }
    
    -- Also check inside folders
    local function searchInFolder(folder)
        for _, obj in pairs(folder:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                table.insert(remotes, {
                    Object = obj,
                    Name = obj.Name,
                    Path = obj:GetFullName()
                })
            end
        end
    end
    
    -- Search all locations
    for _, location in ipairs(searchLocations) do
        if location then
            searchInFolder(location)
        end
    end
    
    return remotes
end

-- ===== TEST REMOTES WITH CAR =====
local function testRemotes()
    print("\n🔍 TESTING ALL REMOTES")
    print("=" .. string.rep("=", 50))
    
    local cars = getCars()
    if #cars == 0 then
        print("❌ No cars found")
        return nil
    end
    
    local car = cars[1]
    print("🚗 Using car: " .. (car.Name or "Unknown"))
    print("🔑 ID: " .. (car.Id or "Unknown"))
    
    local allRemotes = findAllRemotes()
    print("📡 Found " .. #allRemotes .. " RemoteEvents")
    
    local workingRemotes = {}
    
    -- Test only remotes with car-related names
    for i, remoteInfo in ipairs(allRemotes) do
        local remoteName = remoteInfo.Name:lower()
        
        -- Check if remote name suggests car functionality
        if remoteName:find("car") or remoteName:find("vehicle") or
           remoteName:find("purchase") or remoteName:find("buy") or
           remoteName:find("get") or remoteName:find("claim") or
           remoteName:find("duplicate") or remoteName:find("copy") or
           remoteName:find("add") or remoteName:find("give") then
            
            print("\n🔧 Testing: " .. remoteInfo.Name)
            
            -- Try different formats
            local formats = {
                car,                    -- Full car table
                car.Id,                 -- Just ID
                car.Name,               -- Just name
                {car},                  -- Array with car
                {player, car},          -- With player
                {car, 1},               -- Car + quantity
                {Car = car}             -- Key-value
            }
            
            for formatIndex, format in ipairs(formats) do
                local success = pcall(function()
                    remoteInfo.Object:FireServer(format)
                    return true
                end)
                
                if success then
                    print("   ✅ Format " .. formatIndex .. " ACCEPTED!")
                    
                    -- Test rapid fire
                    print("   ⚡ Testing rapid fire...")
                    local sent = 0
                    for j = 1, 5 do
                        if pcall(function() remoteInfo.Object:FireServer(format) end) then
                            sent = sent + 1
                        end
                        task.wait(0.1)
                    end
                    print("   🔥 Sent " .. sent .. " rapid requests")
                    
                    table.insert(workingRemotes, {
                        Remote = remoteInfo.Object,
                        Name = remoteInfo.Name,
                        Format = format,
                        FormatIndex = formatIndex
                    })
                    
                    break  -- Move to next remote
                end
            end
            
            -- Don't test too many at once
            if #workingRemotes >= 3 then
                break
            end
        end
    end
    
    return workingRemotes
end

-- ===== DIRECT TEST =====
local function directTest()
    print("\n🎯 DIRECT REMOTE TEST")
    print("=" .. string.rep("=", 50))
    
    local cars = getCars()
    if #cars == 0 then return end
    
    local car = cars[1]
    
    -- Test specific remote names directly
    local testNames = {
        "PurchaseCar",
        "BuyCar",
        "GetCar",
        "ClaimCar",
        "DuplicateCar",
        "CopyCar"
    }
    
    for _, remoteName in ipairs(testNames) do
        print("\n🔍 Looking for: " .. remoteName)
        
        -- Search everywhere
        local foundRemote = nil
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name == remoteName then
                foundRemote = obj
                break
            end
        end
        
        if foundRemote then
            print("   ✅ Found remote!")
            
            -- Try the car
            local success = pcall(function()
                foundRemote:FireServer(car)
                return true
            end)
            
            if success then
                print("   ✅ Remote accepts car!")
                
                -- Send multiple requests
                for i = 1, 10 do
                    pcall(function() foundRemote:FireServer(car) end)
                    print("   📤 Sent request " .. i)
                    task.wait(0.1)
                end
                
                return foundRemote  -- Return the working remote
            else
                print("   ❌ Remote rejected car")
            end
        else
            print("   ❌ Remote not found")
        end
    end
    
    return nil
end

-- ===== CREATE SIMPLE UI =====
local function createUI()
    while not player:FindFirstChild("PlayerGui") do
        task.wait(0.1)
    end
    
    -- Remove old
    local oldUI = player.PlayerGui:FindFirstChild("CarTool")
    if oldUI then oldUI:Destroy() end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarTool"
    gui.Parent = player.PlayerGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 250, 0, 180)
    main.Position = UDim2.new(0.5, -125, 0.5, -90)
    main.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🚗 Car Tool"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = main
    
    local status = Instance.new("TextLabel")
    status.Text = "Ready"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 40)
    status.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "SCAN REMOTES"
    scanBtn.Size = UDim2.new(1, -20, 0, 30)
    scanBtn.Position = UDim2.new(0, 10, 0, 110)
    scanBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.Gotham
    scanBtn.TextSize = 12
    scanBtn.Parent = main
    
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "START DUPE"
    dupeBtn.Size = UDim2.new(1, -20, 0, 30)
    dupeBtn.Position = UDim2.new(0, 10, 0, 145)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.GothamBold
    dupeBtn.TextSize = 13
    dupeBtn.Parent = main
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 14
    closeBtn.Parent = title
    
    -- Round corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = main
    
    -- Button actions
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "SCANNING..."
        status.Text = "Scanning for remotes..."
        
        task.spawn(function()
            testRemotes()
            status.Text = "Scan complete\nCheck console"
            scanBtn.Text = "SCAN REMOTES"
        end)
    end)
    
    dupeBtn.MouseButton1Click:Connect(function()
        dupeBtn.Text = "WORKING..."
        status.Text = "Testing duplication..."
        
        task.spawn(function()
            directTest()
            status.Text = "Test complete\nCheck garage"
            dupeBtn.Text = "START DUPE"
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== MAIN =====
print("\n🚀 Starting system...")
createUI()

print("\n✅ SYSTEM READY!")
print("\n💡 Click SCAN REMOTES to find all car remotes")
print("💡 Click START DUPE to test duplication directly")
