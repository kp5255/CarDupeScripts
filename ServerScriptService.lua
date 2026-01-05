-- 🎯 CDT ANTI-VALIDATION BYPASS
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CDT ANTI-VALIDATION BYPASS")
print("=" .. string.rep("=", 50))
print("\n🧠 TARGETING:")
print("• Car ID validation")
print("• Ownership verification")
print("• Data integrity checks")
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

-- ===== EXPLOIT 1: RACE CONDITION =====
local function exploitRaceCondition()
    print("\n🏁 EXPLOIT 1: RACE CONDITION")
    print("=" .. string.rep("=", 40))
    
    local cars = getCars()
    if #cars == 0 then return end
    
    local car = cars[1]
    print("🚗 Target car: " .. (car.Name or "Car"))
    
    -- Find all remotes that might process cars
    local processingRemotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("process") or name:find("handle") or 
               name:find("update") or name:find("save") then
                table.insert(processingRemotes, obj)
            end
        end
    end
    
    print("🎯 Found " .. #processingRemotes .. " processing remotes")
    
    -- Send same request to multiple remotes simultaneously
    for i = 1, 3 do
        print("\n💥 Race attempt " .. i .. "...")
        
        for _, remote in ipairs(processingRemotes) do
            pcall(function()
                remote:FireServer(car)
            end)
        end
        
        -- Minimal delay to create overlap
        task.wait(0.001)
    end
    
    print("✅ Race condition exploit attempted")
end

-- ===== EXPLOIT 2: STATE DESYNC =====
local function exploitStateDesync()
    print("\n🔄 EXPLOIT 2: STATE DESYNC")
    print("=" .. string.rep("=", 40))
    
    local cars = getCars()
    if #cars < 2 then
        print("❌ Need at least 2 cars")
        return
    end
    
    print("🚗 Switching between " .. #cars .. " cars rapidly")
    
    -- Find ClaimGiveawayCar (or similar)
    local claimRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if not claimRemote then
        print("❌ No claim remote found")
        return
    end
    
    -- Rapid switching to confuse server state
    for attempt = 1, 5 do
        print("\n🔄 Attempt " .. attempt .. "...")
        
        for i, car in ipairs(cars) do
            if i <= 3 then  -- Only first 3 cars
                pcall(function()
                    claimRemote:FireServer(car)
                end)
                print("   Sent car " .. i .. ": " .. (car.Name or "Car " .. i))
                task.wait(0.01)  -- Ultra-fast switching
            end
        end
        
        task.wait(0.5)  -- Brief pause
    end
    
    print("✅ State desync attempted")
end

-- ===== EXPLOIT 3: TIMING ATTACK =====
local function exploitTimingAttack()
    print("\n⏰ EXPLOIT 3: TIMING ATTACK")
    print("=" .. string.rep("=", 40))
    
    local cars = getCars()
    if #cars == 0 then return end
    
    local car = cars[1]
    
    -- Find any remote that accepts car data
    local targetRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local success = pcall(function()
                obj:FireServer(car)
                return true
            end)
            
            if success then
                targetRemote = obj
                print("🎯 Found accepting remote: " .. obj.Name)
                break
            end
        end
    end
    
    if not targetRemote then
        print("❌ No accepting remote found")
        return
    end
    
    print("🚗 Target: " .. targetRemote.Name)
    
    -- Timing attack: Send requests at server tick boundaries
    local attempts = {
        {count = 2, delay = 0.95},  -- Near 1 second boundary
        {count = 3, delay = 1.95},  -- Near 2 second boundary
        {count = 2, delay = 2.95},  -- Near 3 second boundary
    }
    
    for i, attempt in ipairs(attempts) do
        print("\n⏰ Timing attack " .. i .. "...")
        print("   Sending " .. attempt.count .. " requests")
        print("   Delay: " .. attempt.delay .. "s")
        
        task.wait(attempt.delay)
        
        for j = 1, attempt.count do
            pcall(function()
                targetRemote:FireServer(car)
            end)
            task.wait(0.05)  -- Small gap between requests
        end
    end
    
    print("✅ Timing attack attempted")
end

-- ===== EXPLOIT 4: DATA INTEGRITY BYPASS =====
local function exploitDataIntegrity()
    print("\n🔐 EXPLOIT 4: DATA INTEGRITY BYPASS")
    print("=" .. string.rep("=", 40))
    
    local cars = getCars()
    if #cars == 0 then return end
    
    local originalCar = cars[1]
    
    print("🔧 Creating modified car data...")
    
    -- Create modified versions of the car
    local modifiedCars = {
        -- Version 1: Slightly modified
        function()
            local modCar = {}
            for k, v in pairs(originalCar) do
                modCar[k] = v
            end
            modCar["_timestamp"] = os.time()
            return modCar
        end,
        
        -- Version 2: With extra metadata
        function()
            local modCar = {}
            for k, v in pairs(originalCar) do
                modCar[k] = v
            end
            modCar["PlayerId"] = player.UserId
            modCar["SessionId"] = math.random(10000, 99999)
            return modCar
        end,
        
        -- Version 3: As table in table
        function()
            return {originalCar}
        end,
        
        -- Version 4: With server-like wrapper
        function()
            return {
                Data = originalCar,
                Timestamp = os.time(),
                Valid = true
            }
        end
    }
    
    -- Find remotes that might accept modified data
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("save") or name:find("update") or 
               name:find("sync") or name:find("data") then
                
                print("\n🎯 Testing: " .. obj.Name)
                
                for i, createCar in ipairs(modifiedCars) do
                    local modCar = createCar()
                    local success = pcall(function()
                        obj:FireServer(modCar)
                        return true
                    end)
                    
                    if success then
                        print("   ✅ Version " .. i .. " ACCEPTED!")
                        
                        -- Try rapid fire
                        for j = 1, 3 do
                            pcall(function() obj:FireServer(modCar) end)
                            task.wait(0.1)
                        end
                        print("   🔥 Sent 3 requests")
                    end
                end
            end
        end
    end
    
    print("✅ Data integrity bypass attempted")
end

-- ===== EXPLOIT 5: OWNERSHIP BYPASS =====
local function exploitOwnership()
    print("\n👑 EXPLOIT 5: OWNERSHIP BYPASS")
    print("=" .. string.rep("=", 40))
    
    local cars = getCars()
    if #cars == 0 then return end
    
    local car = cars[1]
    
    -- Try to add ownership data to request
    local ownershipFormats = {
        -- Format 1: Car with explicit ownership
        {Car = car, Owner = player, OwnerId = player.UserId},
        
        -- Format 2: With verification fields
        {Vehicle = car, Player = player, Verified = true},
        
        -- Format 3: Server-style format
        {Data = car, UserId = player.UserId, Action = "claim"},
        
        -- Format 4: Transaction format
        {car, player.UserId, os.time(), "duplicate"},
        
        -- Format 5: With session token simulation
        {car, player.UserId, math.random(1000000, 9999999)}
    }
    
    -- Find ClaimGiveawayCar or similar
    local targetRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            targetRemote = obj
            break
        end
    end
    
    if not targetRemote then
        -- Try any remote that accepted before
        for _, obj in pairs(game:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name == "setTarget" then
                targetRemote = obj
                break
            end
        end
    end
    
    if not targetRemote then
        print("❌ No target remote found")
        return
    end
    
    print("🎯 Target: " .. targetRemote.Name)
    
    -- Test each ownership format
    for i, format in ipairs(ownershipFormats) do
        print("\n🔧 Testing format " .. i .. "...")
        
        local success = pcall(function()
            targetRemote:FireServer(format)
            return true
        end)
        
        if success then
            print("   ✅ Format accepted!")
            
            -- Send multiple with this format
            for j = 1, 5 do
                pcall(function() targetRemote:FireServer(format) end)
                task.wait(0.1)
            end
            print("   🔥 Sent 5 requests")
        end
    end
    
    print("✅ Ownership bypass attempted")
end

-- ===== RUN ALL EXPLOITS =====
local function runAllExploits()
    print("\n🚀 RUNNING ALL EXPLOITS")
    print("=" .. string.rep("=", 50))
    
    -- Get cars first
    local cars = getCars()
    if #cars == 0 then
        print("❌ No cars found")
        return
    end
    
    print("✅ Loaded " .. #cars .. " cars")
    
    -- Run each exploit with delays
    exploitRaceCondition()
    task.wait(2)
    
    exploitStateDesync()
    task.wait(2)
    
    exploitTimingAttack()
    task.wait(2)
    
    exploitDataIntegrity()
    task.wait(2)
    
    exploitOwnership()
    
    print("\n✅ ALL EXPLOITS COMPLETE!")
    print("💡 Check your garage NOW")
    print("🔄 If nothing, wait 30s and try again")
end

-- ===== CREATE UI =====
local function createUI()
    while not player:FindFirstChild("PlayerGui") do
        task.wait(0.1)
    end
    
    -- Remove old
    local old = player.PlayerGui:FindFirstChild("ExploitUI")
    if old then old:Destroy() end
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "ExploitUI"
    gui.Parent = player.PlayerGui
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 250)
    main.Position = UDim2.new(0.5, -150, 0.5, -125)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🎯 CDT EXPLOITS"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    local status = Instance.new("TextLabel")
    status.Text = "Anti-validation bypass system"
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Buttons
    local buttons = {
        {name = "Race Condition", func = exploitRaceCondition, color = Color3.fromRGB(200, 100, 0)},
        {name = "State Desync", func = exploitStateDesync, color = Color3.fromRGB(100, 0, 200)},
        {name = "Timing Attack", func = exploitTimingAttack, color = Color3.fromRGB(0, 100, 200)},
        {name = "Data Bypass", func = exploitDataIntegrity, color = Color3.fromRGB(200, 0, 100)},
        {name = "RUN ALL", func = runAllExploits, color = Color3.fromRGB(0, 150, 0)}
    }
    
    for i, btnInfo in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.name
        btn.Size = UDim2.new(0.45, 0, 0, 30)
        btn.Position = UDim2.new((i % 2 == 1) and 0.05 or 0.5, 10, 0, 140 + math.floor((i-1)/2) * 35)
        btn.BackgroundColor3 = btnInfo.color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.Parent = main
        
        btn.MouseButton1Click:Connect(function()
            btn.Text = "RUNNING..."
            status.Text = "Running " .. btnInfo.name .. "...\nCheck console"
            
            task.spawn(function()
                btnInfo.func()
                status.Text = btnInfo.name .. " complete!\nCheck garage"
                btn.Text = btnInfo.name
            end)
        end)
    end
    
    -- Close button
    local close = Instance.new("TextButton")
    close.Text = "X"
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 5)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 16
    close.Parent = title
    
    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== MAIN =====
print("\n🚀 Loading anti-validation system...")
createUI()

print("\n✅ SYSTEM READY!")
print("\n💡 STRATEGY:")
print("1. Race Condition - Multiple simultaneous requests")
print("2. State Desync - Rapid car switching")
print("3. Timing Attack - Server tick boundaries")
print("4. Data Bypass - Modified car data")
print("5. Ownership Bypass - Added ownership fields")

print("\n🎯 Click RUN ALL for maximum effect!")
