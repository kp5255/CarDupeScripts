-- 🎯 ADVANCED CAR DUPLICATION SYSTEM v3.0
-- With ANTI-VALIDATION techniques
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 ADVANCED CAR DUPLICATION SYSTEM v3.0")
print("=" .. string.rep("=", 60))
print("\n🧠 ANTI-VALIDATION TECHNIQUES:")
print("• Request flooding")
print("• Race condition exploitation")
print("• State manipulation")
print("=" .. string.rep("=", 60))

-- ===== GET REAL CAR DATA =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

local function getRealCarData()
    print("\n🔍 Getting REAL car data from server...")
    
    local success, result = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(result) == "table" and #result > 0 then
        print("✅ Successfully loaded " .. #result .. " real cars")
        return result
    else
        print("❌ Failed to get car data")
        return {}
    end
end

-- ===== FIND ALL REMOTES =====
local function findAllRemotes()
    print("\n🔍 Finding ALL remotes...")
    
    local remotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(remotes, {
                Object = obj,
                Name = obj.Name,
                Path = obj:GetFullName()
            })
        end
    end
    
    print("📡 Found " .. #remotes .. " RemoteEvents")
    return remotes
end

-- ===== FLOOD ATTACK TECHNIQUE =====
local function floodAttack(remote, carTable, attackName)
    print("\n💣 " .. attackName .. " FLOOD ATTACK")
    print("🎯 Target: " .. remote.Name)
    print("🚗 Using: " .. tostring(carTable.Name or carTable.name or "Unknown"))
    
    local packetsSent = 0
    local startTime = tick()
    
    -- Different flood patterns
    local floodPatterns = {
        -- Pattern 1: Ultra-fast burst
        function()
            print("⚡ ULTRA-FAST BURST (100 requests)")
            for i = 1, 100 do
                pcall(function() remote:FireServer(carTable) end)
                packetsSent = packetsSent + 1
                if i % 5 == 0 then
                    task.wait(0.001) -- Minimal delay
                end
            end
        end,
        
        -- Pattern 2: Wave attack
        function()
            print("🌊 WAVE ATTACK (3 waves of 33)")
            for wave = 1, 3 do
                print("   Wave " .. wave .. "...")
                for i = 1, 33 do
                    pcall(function() remote:FireServer(carTable) end)
                    packetsSent = packetsSent + 1
                    task.wait(0.005)
                end
                task.wait(0.2) -- Wave delay
            end
        end,
        
        -- Pattern 3: Mixed data attack
        function()
            print("🎲 MIXED DATA ATTACK (various formats)")
            local formats = {
                carTable,
                {carTable},
                {carTable, 1},
                {carTable, player.UserId},
                {carTable, os.time()},
                {Car = carTable, Player = player}
            }
            
            for i = 1, 50 do
                local format = formats[math.random(1, #formats)]
                pcall(function() remote:FireServer(format) end)
                packetsSent = packetsSent + 1
                task.wait(0.01)
            end
        end
    }
    
    -- Execute all flood patterns
    for i, pattern in ipairs(floodPatterns) do
        pattern()
        if i < #floodPatterns then
            print("   ⏳ Brief pause between patterns...")
            task.wait(0.5)
        end
    end
    
    local totalTime = tick() - startTime
    print("\n📊 FLOOD RESULTS:")
    print("   Packets sent: " .. packetsSent)
    print("   Total time: " .. string.format("%.2f", totalTime) .. "s")
    print("   Rate: " .. string.format("%.0f", packetsSent/totalTime) .. " packets/sec")
    
    return packetsSent
end

-- ===== RACE CONDITION EXPLOIT =====
local function raceConditionExploit()
    print("\n🏁 RACE CONDITION EXPLOIT")
    print("=" .. string.rep("=", 50))
    
    -- Get car data
    local cars = getRealCarData()
    if #cars == 0 then return end
    
    -- Find relevant remotes
    local allRemotes = findAllRemotes()
    local targetRemotes = {}
    
    for _, remote in pairs(allRemotes) do
        local name = remote.Name:lower()
        if name:find("claim") or name:find("give") or 
           name:find("get") or name:find("add") or
           name:find("duplicate") or name:find("copy") then
            table.insert(targetRemotes, remote)
        end
    end
    
    if #targetRemotes == 0 then
        print("❌ No target remotes found")
        return
    end
    
    print("🎯 Found " .. #targetRemotes .. " target remotes")
    
    -- Select a car
    local selectedCar = cars[1]
    if not selectedCar then return end
    
    print("🚗 Using car: " .. tostring(selectedCar.Name or selectedCar.name or "Car 1"))
    
    -- SIMULTANEOUS attack on multiple remotes
    print("\n💥 SIMULTANEOUS ATTACK ON " .. #targetRemotes .. " REMOTES")
    
    local attackThreads = {}
    for i, remote in ipairs(targetRemotes) do
        local thread = coroutine.create(function()
            print("   Thread " .. i .. " targeting: " .. remote.Name)
            floodAttack(remote.Object, selectedCar, "RACE-" .. i)
        end)
        table.insert(attackThreads, thread)
    end
    
    -- Start all threads at nearly the same time
    for _, thread in ipairs(attackThreads) do
        coroutine.resume(thread)
        task.wait(0.001) -- Tiny delay to create race condition
    end
    
    -- Wait for all to complete
    task.wait(3)
    print("\n✅ Race condition attack complete!")
end

-- ===== STATE MANIPULATION ATTACK =====
local function stateManipulationAttack()
    print("\n🌀 STATE MANIPULATION ATTACK")
    print("=" .. string.rep("=", 50))
    
    local cars = getRealCarData()
    if #cars < 2 then
        print("❌ Need at least 2 cars for state manipulation")
        return
    end
    
    -- Find ClaimGiveawayCar remote (from your logs)
    local claimRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if not claimRemote then
        print("❌ ClaimGiveawayCar remote not found")
        return
    end
    
    print("🎯 Found ClaimGiveawayCar remote")
    
    -- STATE MANIPULATION STRATEGY:
    -- Rapidly switch between different cars to confuse server state
    
    print("\n🔄 RAPID CAR SWITCHING ATTACK")
    print("   Switching between " .. math.min(5, #cars) .. " cars rapidly")
    
    local packetsSent = 0
    local startTime = tick()
    
    for cycle = 1, 3 do  -- 3 cycles
        print("   Cycle " .. cycle .. "...")
        
        for i = 1, 20 do  -- 20 rapid switches per cycle
            -- Pick random car
            local randomCar = cars[math.random(1, math.min(5, #cars))]
            
            -- Send with random delay
            pcall(function() claimRemote:FireServer(randomCar) end)
            packetsSent = packetsSent + 1
            
            -- Random delay to avoid pattern detection
            task.wait(math.random(10, 50) / 1000)  -- 10-50ms
        end
        
        -- Brief pause between cycles
        if cycle < 3 then
            task.wait(0.3)
        end
    end
    
    local totalTime = tick() - startTime
    print("\n📊 STATE MANIPULATION RESULTS:")
    print("   Packets sent: " .. packetsSent)
    print("   Cars used: " .. math.min(5, #cars))
    print("   Time: " .. string.format("%.2f", totalTime) .. "s")
    
    return packetsSent
end

-- ===== BACK-TO-BACK FLOOD =====
local function backToBackFlood()
    print("\n⚡ BACK-TO-BACK FLOOD ATTACK")
    print("=" .. string.rep("=", 50))
    
    local cars = getRealCarData()
    if #cars == 0 then return end
    
    -- Find ClaimGiveawayCar
    local claimRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if not claimRemote then
        print("❌ ClaimGiveawayCar remote not found")
        return
    end
    
    local selectedCar = cars[1]
    print("🎯 Target: ClaimGiveawayCar")
    print("🚗 Car: " .. tostring(selectedCar.Name or selectedCar.name or "Car 1"))
    
    -- MULTIPLE BACK-TO-BACK ATTACKS
    local totalPackets = 0
    
    for attackNum = 1, 5 do
        print("\n💥 ATTACK #" .. attackNum)
        
        local attackPackets = 0
        local attackStart = tick()
        
        -- Ultra-dense packet burst
        for i = 1, 50 do
            pcall(function() 
                claimRemote:FireServer(selectedCar)
                claimRemote:FireServer(selectedCar)  -- Double fire
            end)
            attackPackets = attackPackets + 2
            
            -- Increasing delay to avoid rate limits
            task.wait(0.001 * attackNum)
        end
        
        totalPackets = totalPackets + attackPackets
        
        print("   Sent: " .. attackPackets .. " packets")
        print("   Time: " .. string.format("%.2f", tick() - attackStart) .. "s")
        
        if attackNum < 5 then
            print("   ⏳ Brief cooldown...")
            task.wait(1)  -- Cooldown between attacks
        end
    end
    
    print("\n📊 BACK-TO-BACK RESULTS:")
    print("   Total packets: " .. totalPackets)
    print("   Attacks: 5")
    
    return totalPackets
end

-- ===== MAIN ATTACK SEQUENCE =====
local function executeFullAttack()
    print("\n🚀 EXECUTING FULL ATTACK SEQUENCE")
    print("=" .. string.rep("=", 60))
    
    -- Phase 1: Initial flood
    print("\n📡 PHASE 1: INITIAL FLOOD")
    raceConditionExploit()
    
    task.wait(2)
    
    -- Phase 2: State manipulation
    print("\n📡 PHASE 2: STATE MANIPULATION")
    stateManipulationAttack()
    
    task.wait(3)
    
    -- Phase 3: Back-to-back flood
    print("\n📡 PHASE 3: BACK-TO-BACK FLOOD")
    backToBackFlood()
    
    task.wait(2)
    
    -- Phase 4: Final massive flood
    print("\n📡 PHASE 4: FINAL MASSIVE FLOOD")
    
    local cars = getRealCarData()
    local claimRemote = nil
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
            claimRemote = obj
            break
        end
    end
    
    if claimRemote and #cars > 0 then
        local selectedCar = cars[1]
        print("🎯 FINAL ATTACK: 200 packets to ClaimGiveawayCar")
        
        local finalCount = 0
        for i = 1, 200 do
            pcall(function() claimRemote:FireServer(selectedCar) end)
            finalCount = finalCount + 1
            
            if i % 20 == 0 then
                print("   Sent " .. i .. "/200 packets...")
                task.wait(0.1)  -- Brief pause every 20
            else
                task.wait(0.002)  -- Ultra-fast
            end
        end
        
        print("✅ Final attack complete: " .. finalCount .. " packets sent")
    end
    
    print("\n🎯 FULL ATTACK SEQUENCE COMPLETE!")
    print("💡 Check your inventory NOW")
    print("🔄 Wait 30 seconds and run again")
end

-- ===== CREATE ATTACK UI =====
local function createAttackUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarAttackSystem"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 350)
    main.Position = UDim2.new(0.5, -200, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "💣 CAR ATTACK SYSTEM v3.0"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    local status = Instance.new("TextLabel")
    status.Text = "Anti-validation attack system\nTarget: ClaimGiveawayCar remote"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 60)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Attack buttons
    local floodBtn = Instance.new("TextButton")
    floodBtn.Text = "💣 FLOOD ATTACK"
    floodBtn.Size = UDim2.new(1, -20, 0, 40)
    floodBtn.Position = UDim2.new(0, 10, 0, 130)
    floodBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    floodBtn.TextColor3 = Color3.new(1, 1, 1)
    floodBtn.Font = Enum.Font.GothamBold
    floodBtn.TextSize = 14
    floodBtn.Parent = main
    
    local raceBtn = Instance.new("TextButton")
    raceBtn.Text = "🏁 RACE ATTACK"
    raceBtn.Size = UDim2.new(1, -20, 0, 40)
    raceBtn.Position = UDim2.new(0, 10, 0, 180)
    raceBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    raceBtn.TextColor3 = Color3.new(1, 1, 1)
    raceBtn.Font = Enum.Font.GothamBold
    raceBtn.TextSize = 14
    raceBtn.Parent = main
    
    local stateBtn = Instance.new("TextButton")
    stateBtn.Text = "🌀 STATE ATTACK"
    stateBtn.Size = UDim2.new(1, -20, 0, 40)
    stateBtn.Position = UDim2.new(0, 10, 0, 230)
    stateBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)
    stateBtn.TextColor3 = Color3.new(1, 1, 1)
    stateBtn.Font = Enum.Font.GothamBold
    stateBtn.TextSize = 14
    stateBtn.Parent = main
    
    local fullBtn = Instance.new("TextButton")
    fullBtn.Text = "⚡ FULL ATTACK SEQUENCE"
    fullBtn.Size = UDim2.new(1, -20, 0, 50)
    fullBtn.Position = UDim2.new(0, 10, 0, 290)
    fullBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    fullBtn.TextColor3 = Color3.new(1, 1, 1)
    fullBtn.Font = Enum.Font.GothamBold
    fullBtn.TextSize = 16
    fullBtn.Parent = main
    
    -- Add corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    for _, obj in pairs({main, title, status, floodBtn, raceBtn, stateBtn, fullBtn}) do
        addCorner(obj)
    end
    
    -- Button actions
    floodBtn.MouseButton1Click:Connect(function()
        floodBtn.Text = "ATTACKING..."
        status.Text = "Executing flood attack..."
        
        task.spawn(function()
            local cars = getRealCarData()
            local claimRemote = nil
            
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
                    claimRemote = obj
                    break
                end
            end
            
            if claimRemote and #cars > 0 then
                floodAttack(claimRemote, cars[1], "FLOOD")
                status.Text = "✅ Flood attack complete!\nCheck inventory"
            else
                status.Text = "❌ Target not found"
            end
            
            floodBtn.Text = "💣 FLOOD ATTACK"
        end)
    end)
    
    raceBtn.MouseButton1Click:Connect(function()
        raceBtn.Text = "ATTACKING..."
        status.Text = "Executing race condition attack..."
        
        task.spawn(function()
            raceConditionExploit()
            status.Text = "✅ Race attack complete!\nCheck inventory"
            raceBtn.Text = "🏁 RACE ATTACK"
        end)
    end)
    
    stateBtn.MouseButton1Click:Connect(function()
        stateBtn.Text = "ATTACKING..."
        status.Text = "Executing state manipulation..."
        
        task.spawn(function()
            stateManipulationAttack()
            status.Text = "✅ State attack complete!\nCheck inventory"
            stateBtn.Text = "🌀 STATE ATTACK"
        end)
    end)
    
    fullBtn.MouseButton1Click:Connect(function()
        fullBtn.Text = "EXECUTING..."
        status.Text = "Starting full attack sequence...\nThis will take ~30 seconds"
        
        task.spawn(function()
            executeFullAttack()
            status.Text = "✅ FULL ATTACK COMPLETE!\nCheck inventory NOW\nWait 30s and try again"
            fullBtn.Text = "⚡ FULL ATTACK SEQUENCE"
        end)
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = title
    addCorner(closeBtn)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== MAIN =====
print("\n🎯 ANTI-VALIDATION ATTACK SYSTEM")
print("=" .. string.rep("=", 60))
print("\n💡 ISSUE IDENTIFIED:")
print("• Requests are being accepted (102.5% success rate)")
print("• But cars aren't duplicating")
print("• Server has validation preventing duplication")
print("\n🎯 SOLUTION:")
print("• Flood the server with requests")
print("• Create race conditions")
print("• Manipulate server state")
print("• Overwhelm validation checks")

print("\n🚀 Creating attack interface...")
createAttackUI()

print("\n✅ ATTACK SYSTEM READY!")
print("\n💡 RECOMMENDED STRATEGY:")
print("1. Click FULL ATTACK SEQUENCE")
print("2. Wait for all attacks to complete")
print("3. IMMEDIATELY check inventory")
print("4. If no duplicates, wait 30s")
print("5. Try individual attacks")
print("6. Try different cars")
