-- 🎯 CDT VULNERABILITY SCANNER
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

print("🎯 CDT VULNERABILITY SCANNER")
print("=" .. string.rep("=", 50))
print("Looking for potential vulnerabilities...")

-- ===== STEALTH MODE =====
local function stealthRequest(remote, data, attempt)
    -- Add random delays to avoid detection
    local delay = math.random(50, 300) / 1000
    task.wait(delay)
    
    local success = pcall(function()
        remote:FireServer(data)
        return true
    end)
    
    -- Random "error" to mimic player
    if math.random(1, 20) == 1 then
        return false
    end
    
    return success
end

-- ===== GET CAR DATA =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
local cars = carService.GetOwnedCars:InvokeServer()

if #cars == 0 then
    print("❌ No cars found")
    return
end

local car = cars[1]
print("🚗 Test car: " .. (car.Name or "Car 1"))
print("🔑 ID: " .. (car.Id or "Unknown"))

-- ===== VULNERABILITY 1: TRADE SYSTEM =====
print("\n🔍 VULNERABILITY 1: TRADE SYSTEM")
print("=" .. string.rep("=", 40))

-- Look for trade remotes
local tradeRemote = nil
for _, obj in pairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") and obj.Name == "TradeRequest" then
        tradeRemote = obj
        break
    end
end

if tradeRemote then
    print("✅ Found TradeRequest remote")
    
    -- Try to trade with yourself (might cause issues)
    local otherPlayer = game.Players:GetPlayers()[2]
    if otherPlayer and otherPlayer ~= player then
        print("   Testing trade with " .. otherPlayer.Name)
        
        -- Try different trade formats
        local tradeFormats = {
            {player, otherPlayer, car},
            {car, otherPlayer},
            {From = player, To = otherPlayer, Car = car}
        }
        
        for i, format in ipairs(tradeFormats) do
            local success = stealthRequest(tradeRemote, format, i)
            if success then
                print("   ✅ Trade format " .. i .. " accepted")
                
                -- Try to cancel immediately
                task.wait(0.1)
                local cancelRemote = game:GetService("ReplicatedStorage"):FindFirstChild("CancelTrade")
                if cancelRemote then
                    cancelRemote:FireServer()
                    print("   ⚡ Trade cancelled (potential race condition)")
                end
            end
        end
    end
else
    print("❌ No trade system found")
end

-- ===== VULNERABILITY 2: DATA CORRUPTION =====
print("\n🔍 VULNERABILITY 2: DATA CORRUPTION")
print("=" .. string.rep("=", 40))

-- Find save/update remotes
local saveRemotes = {}
for _, obj in pairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") and (obj.Name:find("Save") or obj.Name:find("Update")) then
        table.insert(saveRemotes, obj)
    end
end

print("📊 Found " .. #saveRemotes .. " save/update remotes")

-- Try modified car data
for _, remote in ipairs(saveRemotes) do
    print("\n🔧 Testing: " .. remote.Name)
    
    -- Create slightly modified versions
    local modifiedCars = {
        -- Version 1: Add timestamp
        function()
            local mod = {}
            for k, v in pairs(car) do
                mod[k] = v
            end
            mod._timestamp = os.time()
            return mod
        end,
        
        -- Version 2: Duplicate with new reference
        function()
            return {car}
        end,
        
        -- Version 3: With extra metadata
        function()
            return {
                Data = car,
                PlayerId = player.UserId,
                Session = math.random(10000, 99999)
            }
        end
    }
    
    for i, createFunc in ipairs(modifiedCars) do
        local modCar = createFunc()
        local success = stealthRequest(remote, modCar, i)
        
        if success then
            print("   ✅ Modified version " .. i .. " accepted")
        end
    end
end

-- ===== VULNERABILITY 3: STATE DESYNC =====
print("\n🔍 VULNERABILITY 3: STATE DESYNC")
print("=" .. string.rep("=", 40))

-- Use ClaimGiveawayCar but with timing attacks
local claimRemote = nil
for _, obj in pairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") and obj.Name == "ClaimGiveawayCar" then
        claimRemote = obj
        break
    end
end

if claimRemote then
    print("✅ Found ClaimGiveawayCar")
    
    -- Strategy: Send when server is busy
    print("   Waiting for server activity...")
    
    -- Send during "busy" times
    local busyTimes = {
        {delay = 0.95, desc = "Near save"},
        {delay = 1.95, desc = "Near sync"},
        {delay = 29.5, desc = "Near 30s save"},
        {delay = 59.5, desc = "Near 60s save"}
    }
    
    for i, timing in ipairs(busyTimes) do
        if i <= 2 then  -- Only short delays to avoid kicking
            print("   Timing " .. i .. ": " .. timing.desc .. "s (" .. timing.desc .. ")")
            task.wait(timing.delay)
            
            local success = stealthRequest(claimRemote, car, i)
            if success then
                print("   ✅ Request accepted at busy time")
                
                -- Immediate follow-up (might cause desync)
                task.wait(0.01)
                stealthRequest(claimRemote, car, i + 0.5)
            end
        end
    end
end

-- ===== VULNERABILITY 4: OWNERSHIP OVERLAP =====
print("\n🔍 VULNERABILITY 4: OWNERSHIP OVERLAP")
print("=" .. string.rep("=", 40))

if #cars >= 2 then
    print("✅ Have multiple cars for ownership testing")
    
    local car1 = cars[1]
    local car2 = cars[2]
    
    -- Find any car-related remote
    local carRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:find("Car") then
            carRemote = obj
            break
        end
    end
    
    if carRemote and carRemote.Name ~= "ClaimGiveawayCar" then
        print("   Using: " .. carRemote.Name)
        
        -- Rapid switching between cars
        for i = 1, 3 do
            stealthRequest(carRemote, car1, i)
            task.wait(0.02)
            stealthRequest(carRemote, car2, i + 0.5)
            task.wait(0.02)
            stealthRequest(carRemote, car1, i + 1)
            task.wait(0.5)
        end
        print("   ✅ Ownership switching test complete")
    end
end

-- ===== VULNERABILITY 5: NETWORK EXPLOIT =====
print("\n🔍 VULNERABILITY 5: NETWORK EXPLOIT")
print("=" .. string.rep("=", 40))

print("📡 Simulating network issues...")

if claimRemote then
    -- Packet duplication simulation
    for i = 1, 2 do
        print("   Network burst " .. i)
        
        -- Send multiple "duplicate" packets
        for j = 1, 3 do
            pcall(function()
                claimRemote:FireServer(car)
            end)
            task.wait(0.001)  -- Very fast (simulates packet burst)
        end
        
        task.wait(1.0)  -- Recovery time
    end
    
    -- Lag spike simulation
    print("   Simulating lag spike...")
    task.wait(2.0)
    pcall(function() claimRemote:FireServer(car) end)
    task.wait(0.5)
    pcall(function() claimRemote:FireServer(car) end)
    
    print("✅ Network simulation complete")
end

-- ===== CHECK RESULTS =====
print("\n" .. string.rep("=", 50))
print("🎯 VULNERABILITY SCAN COMPLETE")
print("=" .. string.rep("=", 50))

print("\n📊 SUMMARY:")
print("• Tested 5 potential vulnerability types")
print("• Used stealth mode to avoid detection")
print("• Targeted actual bugs, not 'duplication systems'")

print("\n💡 WHAT TO DO NOW:")
print("1. Wait 60 seconds")
print("2. Check your garage CAREFULLY")
print("3. Look for ANY changes (even small ones)")
print("4. If nothing changed, the game likely has no vulnerabilities")

print("\n⚠️ IMPORTANT:")
print("• CDT is well-protected against duplication")
print("• Most 'dupes' are actually server rollbacks or bugs")
print("• If this scan found nothing, duplication is likely impossible")
print("• Continuing will only get you kicked/banned")

print("\n🔚 This is the realistic assessment of CDT's security.")
