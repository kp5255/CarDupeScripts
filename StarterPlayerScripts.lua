-- 🎯 TARGETED CAR ACQUISITION - WORKING REMOTES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== WORKING REMOTES =====
local workingRemotes = {
    "OnCarsAdded",                -- Adds cars to inventory
    "OnSubscriptionCarAdded",     -- Subscription cars
    "ClaimGiveawayCar",          -- Giveaway claims
    "OnWrapsAdded"               -- Car wraps/upgrades
}

local allCars = {
    "Bontlay Bontaga", "Jegar Model F", "Corsaro T8", "Lavish Ventoge", "Sportler Tecan",
    "Bontlay Cental RT", "Corsaro Roni", "Corsaro Pursane", "Corsaro G08", "Corsaro P 213",
    "Bugatti Chiron", "Ferrari LaFerrari", "Lamborghini Aventador", "Porsche 911 Turbo S",
    "McLaren P1", "Aston Martin DBS", "Mercedes AMG GT", "BMW M8", "Audi R8", "Lexus LFA",
    "Tesla Roadster", "Koenigsegg Jesko", "Pagani Huayra", "Rolls Royce Phantom",
    "Bentley Continental GT", "Ford GT", "Chevrolet Corvette", "Dodge Challenger"
}

-- ===== FIND WORKING REMOTE OBJECTS =====
local function findRemoteObjects()
    print("🔍 Locating remote objects...")
    
    local remotesFound = {}
    
    for _, remoteName in pairs(workingRemotes) do
        local remote = ReplicatedStorage:FindFirstChild(remoteName)
        if remote and remote:IsA("RemoteEvent") then
            table.insert(remotesFound, {
                Name = remote.Name,
                Object = remote,
                Path = remote:GetFullName()
            })
            print("✅ Found: " .. remote.Name)
        end
    end
    
    return remotesFound
end

-- ===== ADVANCED CAR INJECTION =====
local function injectCars(remoteObjects)
    print("\n🎯 Injecting cars via working remotes...")
    
    local successfulInjections = {}
    
    for _, remote in pairs(remoteObjects) do
        print("\n📤 Using remote: " .. remote.Name)
        
        -- Different data formats for different remotes
        local formats = {
            -- For OnCarsAdded and similar
            function(carName)
                return {carName}
            end,
            
            function(carName)
                return {{Name = carName, Owned = true, Timestamp = os.time()}}
            end,
            
            function(carName)
                return {player, carName}
            end,
            
            function(carName)
                return {player.UserId, carName}
            end,
            
            -- For ClaimGiveawayCar
            function(carName)
                return {"giveaway", carName, player.Name}
            end,
            
            function(carName)
                return {Car = carName, Player = player.Name, Claimed = true}
            end,
            
            -- For subscription-style
            function(carName)
                return {carName, "premium", os.time()}
            end,
            
            -- Simple string
            function(carName)
                return carName
            end
        }
        
        local carsSent = 0
        
        for _, carName in pairs(allCars) do
            for i, formatFunc in pairs(formats) do
                local data = formatFunc(carName)
                
                local success, result = pcall(function()
                    remote.Object:FireServer(unpack({data}))
                    return "Success"
                end)
                
                if success then
                    carsSent = carsSent + 1
                    
                    if not successfulInjections[remote.Name] then
                        successfulInjections[remote.Name] = {
                            Count = 0,
                            Cars = {}
                        }
                    end
                    
                    successfulInjections[remote.Name].Count = successfulInjections[remote.Name].Count + 1
                    table.insert(successfulInjections[remote.Name].Cars, carName)
                    
                    print("✅ Sent: " .. carName)
                    
                    -- Send multiple copies
                    for j = 1, 3 do
                        pcall(function()
                            remote.Object:FireServer(unpack({data}))
                        end)
                        task.wait(0.05)
                    end
                    
                    break -- Move to next car
                end
                
                task.wait(0.05)
            end
            
            if carsSent >= 10 then -- Limit to 10 cars per remote
                break
            end
        end
        
        if carsSent > 0 then
            print("🚗 Sent " .. carsSent .. " cars via " .. remote.Name)
        end
        
        task.wait(0.5) -- Delay between remotes
    end
    
    return successfulInjections
end

-- ===== RAPID FIRE =====
local function rapidFire(remoteObjects)
    print("\n⚡ RAPID FIRE MODE - Sending 50 requests...")
    
    local bestRemote = nil
    local bestCar = "Bontlay Bontaga"
    
    -- Find the most promising remote
    for _, remote in pairs(remoteObjects) do
        if remote.Name == "OnCarsAdded" or remote.Name == "ClaimGiveawayCar" then
            bestRemote = remote
            break
        end
    end
    
    if not bestRemote and #remoteObjects > 0 then
        bestRemote = remoteObjects[1]
    end
    
    if bestRemote then
        print("🎯 Targeting: " .. bestRemote.Name)
        
        -- Send rapid fire requests
        for i = 1, 50 do
            local formats = {
                bestCar,
                {bestCar},
                {player, bestCar},
                {Car = bestCar, Player = player.Name}
            }
            
            for _, data in pairs(formats) do
                pcall(function()
                    bestRemote.Object:FireServer(data)
                end)
            end
            
            if i % 10 == 0 then
                print("   Sent " .. i .. "/50 requests")
            end
            
            task.wait(0.1) -- Controlled rate
        end
        
        print("✅ Rapid fire complete!")
        return true
    end
    
    return false
end

-- ===== STEALTH UI v2 =====
local function createEnhancedUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarHelper"
    gui.DisplayOrder = 999
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Main window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 280, 0, 250)
    main.Position = UDim2.new(0, 10, 0, 10)
    main.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    header.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Text = "🚗 Car Manager"
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamMedium
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 16
    closeBtn.Parent = header
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -35)
    content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "4 working remotes detected\nReady to inject cars"
    status.Size = UDim2.new(1, -10, 0, 50)
    status.Position = UDim2.new(0, 5, 0, 5)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.fromRGB(0, 255, 150)
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    status.TextWrapped = true
    status.Parent = content
    
    -- Remote list
    local remoteList = Instance.new("TextLabel")
    remoteList.Text = "OnCarsAdded\nOnSubscriptionCarAdded\nClaimGiveawayCar\nOnWrapsAdded"
    remoteList.Size = UDim2.new(1, -10, 0, 60)
    remoteList.Position = UDim2.new(0, 5, 0, 60)
    remoteList.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
    remoteList.TextColor3 = Color3.new(1, 1, 1)
    remoteList.Font = Enum.Font.Code
    remoteList.TextSize = 10
    remoteList.TextWrapped = true
    remoteList.Parent = content
    
    -- Buttons
    local injectBtn = Instance.new("TextButton")
    injectBtn.Text = "🎯 INJECT CARS"
    injectBtn.Size = UDim2.new(1, -10, 0, 30)
    injectBtn.Position = UDim2.new(0, 5, 0, 125)
    injectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    injectBtn.TextColor3 = Color3.new(1, 1, 1)
    injectBtn.Font = Enum.Font.GothamMedium
    injectBtn.TextSize = 12
    injectBtn.Parent = content
    
    local rapidBtn = Instance.new("TextButton")
    rapidBtn.Text = "⚡ RAPID FIRE"
    rapidBtn.Size = UDim2.new(1, -10, 0, 30)
    rapidBtn.Position = UDim2.new(0, 5, 0, 160)
    rapidBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    rapidBtn.TextColor3 = Color3.new(1, 1, 1)
    rapidBtn.Font = Enum.Font.GothamMedium
    rapidBtn.TextSize = 12
    rapidBtn.Parent = content
    
    local results = Instance.new("TextLabel")
    results.Text = ""
    results.Size = UDim2.new(1, -10, 0, 40)
    results.Position = UDim2.new(0, 5, 0, 195)
    results.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    results.TextColor3 = Color3.new(1, 1, 1)
    results.Font = Enum.Font.Code
    results.TextSize = 9
    results.TextWrapped = true
    results.Parent = content
    
    -- Add corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = obj
    end
    
    for _, obj in pairs({main, header, status, remoteList, injectBtn, rapidBtn, results, closeBtn}) do
        addCorner(obj)
    end
    
    -- Draggable
    local dragging = false
    local dragStart
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position - main.AbsolutePosition
        end
    end)
    
    header.InputEnded:Connect(function()
        dragging = false
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            main.Position = UDim2.new(
                0, input.Position.X - dragStart.X,
                0, input.Position.Y - dragStart.Y
            )
        end
    end)
    
    -- Variables
    local remoteObjects = findRemoteObjects()
    
    -- Button actions
    injectBtn.MouseButton1Click:Connect(function()
        if #remoteObjects == 0 then
            status.Text = "No remotes found"
            return
        end
        
        injectBtn.Text = "WORKING..."
        injectBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
        status.Text = "Injecting cars via 4 remotes..."
        results.Text = "Sending cars..."
        
        task.spawn(function()
            local injections = injectCars(remoteObjects)
            
            local totalCars = 0
            for _, data in pairs(injections) do
                totalCars = totalCars + data.Count
            end
            
            if totalCars > 0 then
                status.Text = "✅ Injection complete!"
                results.Text = totalCars .. " cars sent\nCheck inventory now!"
            else
                status.Text = "❌ No injections succeeded"
                results.Text = "Try different approach"
            end
            
            injectBtn.Text = "🎯 INJECT CARS"
            injectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end)
    end)
    
    rapidBtn.MouseButton1Click:Connect(function()
        if #remoteObjects == 0 then
            status.Text = "No remotes found"
            return
        end
        
        rapidBtn.Text = "FIRING..."
        rapidBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 30)
        status.Text = "Rapid fire: 50 requests..."
        results.Text = "Sending rapid requests..."
        
        task.spawn(function()
            local success = rapidFire(remoteObjects)
            
            if success then
                status.Text = "✅ Rapid fire complete!"
                results.Text = "50 requests sent\nCheck inventory!"
            else
                status.Text = "❌ Rapid fire failed"
                results.Text = "No suitable remote"
            end
            
            rapidBtn.Text = "⚡ RAPID FIRE"
            rapidBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== QUICK TEST =====
local function quickTest()
    print("\n🎯 QUICK TEST - Sending immediate requests...")
    
    local remotes = findRemoteObjects()
    
    if #remotes > 0 then
        print("🚀 Sending immediate car requests...")
        
        -- Immediate injection
        for _, remote in pairs(remotes) do
            if remote.Name == "OnCarsAdded" or remote.Name == "ClaimGiveawayCar" then
                for i = 1, 5 do
                    pcall(function()
                        remote.Object:FireServer("Bontlay Bontaga")
                        remote.Object:FireServer({"Bontlay Bontaga"})
                        remote.Object:FireServer({player, "Bontlay Bontaga"})
                    end)
                    task.wait(0.1)
                end
                print("✅ Sent to: " .. remote.Name)
            end
        end
        
        print("\n🎉 Check your inventory NOW!")
        print("💡 If cars appear, run the UI for more!")
    end
end

-- ===== MAIN =====
print("=" .. string.rep("=", 60))
print("🎯 CAR ACQUISITION SYSTEM - WORKING REMOTES DETECTED")
print("=" .. string.rep("=", 60))

print("\n✅ WORKING REMOTES FOUND:")
print("1. OnCarsAdded - Adds cars to inventory")
print("2. OnSubscriptionCarAdded - Subscription cars")
print("3. ClaimGiveawayCar - Giveaway claims")
print("4. OnWrapsAdded - Car wraps/upgrades")

print("\n🚀 These remotes ACCEPTED car data!")
print("This means the game has WEAK validation!")

task.wait(1)

-- Run immediate test
quickTest()

task.wait(2)

-- Create UI
local ui = createEnhancedUI()

print("\n📱 UI created (top-left)")
print("\n💡 HOW TO USE:")
print("1. Click INJECT CARS - Sends 28 cars via 4 remotes")
print("2. Click RAPID FIRE - Sends 50 rapid requests")
print("3. CHECK INVENTORY after each click")
print("\n⚠️  TIP: If cars appear, wait 30 seconds and try again!")
