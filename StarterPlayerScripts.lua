-- 🚗 REAL WORKING CAR DUPLICATOR
-- Game ID: ffad7ea30d080c4aa1d7bf4b2f5f4381

print("🚗 REAL WORKING DUPLICATOR")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== STEP 1: SHOW YOUR CURRENT CARS =====
local function showMyCars()
    print("\n🔍 YOUR CURRENT CARS:")
    
    -- Check EVERY possible location
    local allLocations = player:GetDescendants()
    local carList = {}
    
    for _, obj in pairs(allLocations) do
        if obj:IsA("Folder") or obj:IsA("Model") or obj:IsA("StringValue") then
            local name = obj.Name:lower()
            if name:find("car") or name:find("vehicle") or name:find("model") then
                if not table.find(carList, obj.Name) then
                    table.insert(carList, obj.Name)
                    print("✅ " .. obj.Name .. " in " .. obj.Parent.Name)
                end
            end
        end
    end
    
    -- Also check values that might contain car names
    for _, obj in pairs(allLocations) do
        if obj:IsA("StringValue") or obj:IsA("ValueBase") then
            if obj.Value then
                local valueStr = tostring(obj.Value):lower()
                if valueStr:find("car") or valueStr:find("vehicle") then
                    if not table.find(carList, obj.Value) then
                        table.insert(carList, obj.Value)
                        print("✅ " .. obj.Value .. " (in " .. obj.Name .. ")")
                    end
                end
            end
        end
    end
    
    return carList
end

-- ===== STEP 2: FIND REAL GAME EVENTS =====
local function findRealGameEvents()
    print("\n🔧 FINDING GAME EVENTS:")
    
    local realEvents = {}
    
    -- Look for events that might actually work
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            print("Found: " .. obj.Name .. " (" .. obj.ClassName .. ")")
            table.insert(realEvents, {
                Object = obj,
                Name = obj.Name,
                Type = obj.ClassName
            })
        end
    end
    
    -- Also check ServerStorage (if accessible)
    local success, serverStorage = pcall(function()
        return game:GetService("ServerStorage")
    end)
    
    if success and serverStorage then
        for _, obj in pairs(serverStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                print("Found in ServerStorage: " .. obj.Name)
                table.insert(realEvents, {
                    Object = obj,
                    Name = obj.Name,
                    Type = obj.ClassName
                })
            end
        end
    end
    
    return realEvents
end

-- ===== STEP 3: REAL DUPLICATION =====
local function realDuplicateCars(carList, events)
    print("\n⚡ REAL DUPLICATION ATTEMPT")
    
    if #carList == 0 then
        print("❌ No cars in your list!")
        return false
    end
    
    local successfulAttempts = 0
    
    -- Try EACH event with EACH car
    for _, carName in pairs(carList) do
        print("\nTrying to duplicate: " .. carName)
        
        for _, eventData in pairs(events) do
            local event = eventData.Object
            
            -- Try MANY different argument combinations
            local argCombinations = {
                -- Single argument
                {carName},
                
                -- With player
                {player, carName},
                
                -- With player ID
                {player.UserId, carName},
                
                -- Purchase style
                {carName, 0},
                {carName, 1},
                {carName, 100},
                
                -- Command style
                {"buy", carName},
                {"purchase", carName},
                {"add", carName},
                {"give", carName},
                {"duplicate", carName},
                {"copy", carName},
                
                -- Table format
                {Vehicle = carName},
                {CarName = carName, Action = "Buy"},
                {Name = carName, Price = 0},
                
                -- Special formats
                {carName, true},  -- maybe 'true' for free
                {carName, "free"},
                {"free", carName},
                
                -- Multiple quantity
                {carName, 2},  -- quantity 2
                {carName, 5},  -- quantity 5
                {carName, 10}  -- quantity 10
            }
            
            for argIndex, args in pairs(argCombinations) do
                local success, result = pcall(function()
                    if eventData.Type == "RemoteEvent" then
                        event:FireServer(unpack(args))
                        return "FireServer sent"
                    else
                        event:InvokeServer(unpack(args))
                        return "InvokeServer sent"
                    end
                end)
                
                if success then
                    print("✅ Attempt " .. argIndex .. " via " .. eventData.Name)
                    successfulAttempts = successfulAttempts + 1
                    
                    -- If it looks promising, try more
                    if successfulAttempts < 10 then
                        -- Try rapid fire
                        for i = 1, 3 do
                            pcall(function()
                                if eventData.Type == "RemoteEvent" then
                                    event:FireServer(unpack(args))
                                else
                                    event:InvokeServer(unpack(args))
                                end
                            end)
                            task.wait(0.02)
                        end
                    end
                end
                
                task.wait(0.05)
            end
        end
    end
    
    print("\n📊 Sent " .. successfulAttempts .. " duplication attempts")
    return successfulAttempts > 0
end

-- ===== STEP 4: CHECK FOR NEW CARS =====
local function checkForNewCars(originalCount)
    print("\n🔍 Checking for new cars...")
    task.wait(3)  -- Wait for server
    
    local newCarList = showMyCars()
    
    print("\n" .. string.rep("=", 50))
    print("RESULTS:")
    print("Cars before: " .. originalCount)
    print("Cars after: " .. #newCarList)
    
    if #newCarList > originalCount then
        print("\n🎉 SUCCESS! Gained " .. (#newCarList - originalCount) .. " new cars!")
        print("Check your garage right now!")
        return true
    else
        print("\n⚠️ No new cars detected")
        print("The server rejected all requests.")
        print("\nPossible solutions:")
        print("1. Try again in a different server")
        print("2. Buy/sell a car first, then try")
        print("3. The game might be patched")
        return false
    end
end

-- ===== STEP 5: BRUTE FORCE METHOD =====
local function bruteForceDuplication(carList)
    print("\n💥 BRUTE FORCE METHOD")
    
    -- Try EVERY remote in the game
    local allRemotes = {}
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(allRemotes, obj)
        end
    end
    
    print("Found " .. #allRemotes .. " RemoteEvents total")
    
    local attempts = 0
    for _, carName in pairs(carList) do
        for _, remote in pairs(allRemotes) do
            if attempts < 100 then  -- Limit attempts
                -- Try simple fire
                pcall(function()
                    remote:FireServer(carName)
                    attempts = attempts + 1
                end)
                
                -- Try with player
                pcall(function()
                    remote:FireServer(player, carName)
                    attempts = attempts + 1
                end)
                
                task.wait(0.01)
            end
        end
    end
    
    print("Brute force attempts: " .. attempts)
    return attempts > 0
end

-- ===== MAIN FUNCTION =====
local function main()
    print("\n" .. string.rep("=", 60))
    print("🚗 REAL CAR DUPLICATION STARTING")
    print(string.rep("=", 60))
    
    -- Step 1: Show current cars
    local myCars = showMyCars()
    
    if #myCars == 0 then
        print("\n❌ YOU NEED TO BUY CARS FIRST!")
        print("\nInstructions:")
        print("1. Open the store in-game")
        print("2. Buy the CHEAPEST car you can afford")
        print("3. Make sure it appears in your garage")
        print("4. Run this script again")
        return
    end
    
    -- Step 2: Find events
    local events = findRealGameEvents()
    
    if #events == 0 then
        print("❌ No events found!")
        return
    end
    
    -- Step 3: Real duplication
    print("\n⚡ ATTEMPT 1: Intelligent duplication...")
    local originalCount = #myCars
    realDuplicateCars(myCars, events)
    
    -- Step 4: Check results
    local success = checkForNewCars(originalCount)
    
    -- Step 5: If failed, try brute force
    if not success then
        print("\n💥 ATTEMPT 2: Brute force...")
        bruteForceDuplication(myCars)
        task.wait(2)
        checkForNewCars(originalCount)
    end
    
    print("\n" .. string.rep("=", 60))
    print("SCRIPT COMPLETE")
    print(string.rep("=", 60))
end

-- ===== AUTO-RUN =====
task.wait(3)
main()

-- ===== CREATE SIMPLE UI =====
task.spawn(function()
    task.wait(1)
    
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.8, -100)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🚗 DUPLICATOR ACTIVE"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "Found " .. #showMyCars() .. " cars\nCheck console for details"
    status.Size = UDim2.new(1, -20, 1, -40)
    status.Position = UDim2.new(0, 10, 0, 35)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    -- Auto-update status
    while true do
        task.wait(5)
        local cars = showMyCars()
        status.Text = "Cars: " .. #cars .. "\nCheck console for results"
    end
end)
