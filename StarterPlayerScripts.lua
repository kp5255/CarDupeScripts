-- 🎯 REAL CAR DUPLICATOR - CORRECT FORMAT
-- Place ID: 1554960397 - NY SALE! Car Dealership Tycoon

print("🎯 REAL CAR DUPLICATOR - TARGETING YOUR ACTUAL CARS")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== YOUR ACTUAL CARS FROM SCREENSHOT =====
local YOUR_CARS = {
    "Bontlay Bontaga",
    "Jegar Model F", 
    "Sportler Tecan",
    "Lavish Ventoge",
    "Lavish Ventoge Car",
    "Corsaro T8"
}

-- ===== STEP 1: FIND WHERE CARS ARE STORED =====
local function findCarStorage()
    print("\n🔍 FINDING CAR STORAGE SYSTEM...")
    
    -- Look for OWNEDCARS or similar
    local storageLocations = {}
    
    -- Check all player folders
    for _, folder in pairs(player:GetChildren()) do
        if folder:IsA("Folder") then
            print("Checking folder: " .. folder.Name)
            
            -- Check folder contents
            for _, item in pairs(folder:GetChildren()) do
                print("  - " .. item.Name .. " (" .. item.ClassName .. ")")
                
                -- If it's a car or has car data
                if item:IsA("StringValue") or item:IsA("Folder") then
                    local name = item.Name:lower()
                    if name:find("car") or name:find("vehicle") or name:find("owned") then
                        table.insert(storageLocations, folder)
                        print("  ✅ Potential car storage!")
                        break
                    end
                end
            end
        end
    end
    
    -- Check for specific values with car names
    for _, value in pairs(player:GetDescendants()) do
        if value:IsA("StringValue") then
            for _, carName in pairs(YOUR_CARS) do
                if value.Value == carName or value.Name == carName then
                    print("Found car value: " .. value.Name .. " = " .. value.Value)
                    table.insert(storageLocations, value.Parent)
                end
            end
        end
    end
    
    return storageLocations
end

-- ===== STEP 2: DUPLICATE YOUR ACTUAL CARS =====
local function duplicateYourActualCars()
    print("\n⚡ DUPLICATING YOUR ACTUAL CARS...")
    
    print("Your cars to duplicate:")
    for i, carName in pairs(YOUR_CARS) do
        print(i .. ". " .. carName)
    end
    
    -- Find purchase events
    local events = {}
    
    for _, obj in pairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(events, {
                Object = obj,
                Name = obj.Name,
                Type = obj.ClassName
            })
        end
    end
    
    print("Found " .. #events .. " events to try")
    
    -- Try to duplicate EACH of your cars
    local totalAttempts = 0
    local successfulEvents = {}
    
    for _, carName in pairs(YOUR_CARS) do
        print("\n🎯 Targeting: " .. carName)
        
        for _, eventData in pairs(events) do
            local event = eventData.Object
            
            -- Try different formats for THIS specific game
            local patterns = {
                -- Basic format
                {carName},
                
                -- With price
                {carName, 0},
                {carName, 1},
                {carName, 100},
                
                -- With player
                {player, carName},
                
                -- Purchase format
                {"buy", carName},
                {"purchase", carName},
                {"add", carName},
                
                -- For multi-word names like "Bontlay Bontaga"
                {carName:gsub(" ", "")},  -- Remove spaces: "BontlayBontaga"
                {carName:split(" ")[1]},  -- First word: "Bontlay"
                {carName:split(" ")[2]},  -- Second word: "Bontaga"
                
                -- Special formats
                {Vehicle = carName},
                {CarName = carName},
                {Model = carName}
            }
            
            for patternIndex, args in pairs(patterns) do
                totalAttempts = totalAttempts + 1
                
                local success, errorMsg = pcall(function()
                    if eventData.Type == "RemoteEvent" then
                        event:FireServer(unpack(args))
                        return "sent"
                    else
                        event:InvokeServer(unpack(args))
                        return "invoked"
                    end
                end)
                
                if success then
                    print("✅ Attempt via " .. eventData.Name .. " (pattern " .. patternIndex .. ")")
                    
                    if not successfulEvents[eventData.Name] then
                        successfulEvents[eventData.Name] = true
                    end
                    
                    -- Rapid fire if successful
                    for i = 1, 5 do
                        pcall(function()
                            if eventData.Type == "RemoteEvent" then
                                event:FireServer(unpack(args))
                            end
                        end)
                        task.wait(0.01)
                    end
                end
                
                task.wait(0.05)
            end
        end
    end
    
    print("\n📊 STATISTICS:")
    print("Total attempts: " .. totalAttempts)
    print("Successful events: " .. #(successfulEvents))
    
    if next(successfulEvents) then
        print("Events that accepted calls:")
        for eventName in pairs(successfulEvents) do
            print("  - " .. eventName)
        end
    end
    
    return totalAttempts
end

-- ===== STEP 3: CHECK ACTUAL CAR COUNT =====
local function checkActualCarCount()
    print("\n📦 CHECKING ACTUAL CAR COUNT...")
    
    local foundCars = {}
    
    -- Look for your cars in ANY format
    for _, carName in pairs(YOUR_CARS) do
        -- Check if car exists in player data
        local found = false
        
        for _, obj in pairs(player:GetDescendants()) do
            if obj:IsA("StringValue") and obj.Value == carName then
                found = true
                break
            elseif obj.Name == carName then
                found = true
                break
            end
        end
        
        if found then
            table.insert(foundCars, carName)
        end
    end
    
    print("Found " .. #foundCars .. "/" .. #YOUR_CARS .. " of your cars")
    
    if #foundCars > 0 then
        print("Your cars:")
        for i, car in ipairs(foundCars) do
            print(i .. ". " .. car)
        end
    end
    
    return #foundCars
end

-- ===== STEP 4: CREATE TARGETED UI =====
local function createTargetedUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 300)
    frame.Position = UDim2.new(0.5, -175, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🎯 TARGETED CAR DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "Targeting YOUR cars:\n\n• Bontlay Bontaga\n• Jegar Model F\n• Sportler Tecan\n• Lavish Ventoge\n• Corsaro T8"
    status.Size = UDim2.new(1, -20, 0, 130)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame
    
    -- Button 1: Check Storage
    local btn1 = Instance.new("TextButton")
    btn1.Text = "🔍 FIND STORAGE"
    btn1.Size = UDim2.new(1, -40, 0, 35)
    btn1.Position = UDim2.new(0, 20, 0, 190)
    btn1.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    btn1.TextColor3 = Color3.new(1, 1, 1)
    btn1.Font = Enum.Font.GothamBold
    btn1.TextSize = 14
    btn1.Parent = frame
    
    btn1.MouseButton1Click:Connect(function()
        status.Text = "Finding car storage..."
        task.spawn(function()
            findCarStorage()
            local count = checkActualCarCount()
            status.Text = "Found " .. count .. " cars in storage.\nCheck console for details."
        end)
    end)
    
    -- Button 2: Duplicate All
    local btn2 = Instance.new("TextButton")
    btn2.Text = "⚡ DUPLICATE ALL"
    btn2.Size = UDim2.new(1, -40, 0, 35)
    btn2.Position = UDim2.new(0, 20, 0, 235)
    btn2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn2.TextColor3 = Color3.new(1, 1, 1)
    btn2.Font = Enum.Font.GothamBold
    btn2.TextSize = 14
    btn2.Parent = frame
    
    btn2.MouseButton1Click:Connect(function()
        status.Text = "Duplicating ALL your cars...\nThis may take 10-15 seconds.\nCheck console!"
        btn2.Text = "WORKING..."
        btn2.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local beforeCount = checkActualCarCount()
            local attempts = duplicateYourActualCars()
            
            task.wait(3)
            
            local afterCount = checkActualCarCount()
            status.Text = "Complete!\n\nBefore: " .. beforeCount .. " cars\nAfter: " .. afterCount .. " cars\n\nAttempts: " .. attempts
            
            btn2.Text = "DUPLICATE ALL"
            btn2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return gui, status
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 70))
print("🎯 TARGETING YOUR ACTUAL CARS")
print(string.rep("=", 70))
print("\nYOUR CARS IDENTIFIED:")
print("1. Bontlay Bontaga")
print("2. Jegar Model F")
print("3. Sportler Tecan")
print("4. Lavish Ventoge")
print("5. Corsaro T8")

-- Create UI
task.wait(1)
local gui, status = createTargetedUI()

-- Auto-start after 3 seconds
task.wait(3)
status.Text = "Auto-starting duplication...\n\nTargeting your 5 cars.\nCheck console!"

-- Initial check
local initialCount = checkActualCarCount()
print("\nInitial car count: " .. initialCount)

-- Run duplication
task.wait(2)
local attempts = duplicateYourActualCars()

-- Check results
task.wait(3)
local finalCount = checkActualCarCount()

print("\n" .. string.rep("=", 70))
print("🎯 RESULTS")
print(string.rep("=", 70))
print("Cars before: " .. initialCount)
print("Cars after: " .. finalCount)
print("Duplication attempts: " .. attempts)

if finalCount > initialCount then
    print("\n🎉 SUCCESS! Gained " .. (finalCount - initialCount) .. " new cars!")
    status.Text = "🎉 SUCCESS!\n\nGained " .. (finalCount - initialCount) .. " cars!\nCheck your garage!"
else
    print("\n⚠️ No new cars gained.")
    print("\nPossible issues:")
    print("1. Server rejecting all requests")
    print("2. Cars stored in different format")
    print("3. Need specific event arguments")
    
    status.Text = "⚠️ No new cars.\n\nServer is rejecting requests.\nTry buying/selling a car first."
end

-- Final tip
print("\n💡 TIP: Try this:")
print("1. Sell one of your cars")
print("2. Buy it back")
print("3. Run script again")
print("4. Game might sync differently")
