-- 🔍 DEEP CAR STORAGE ANALYSIS
-- Place ID: 1554960397 - NY SALE! Car Dealership Tycoon

print("🔍 DEEP CAR STORAGE ANALYSIS")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== STEP 1: COMPLETE PLAYER DATA SCAN =====
local function deepScanPlayerData()
    print("\n🔬 COMPLETE PLAYER DATA SCAN")
    
    local allData = {}
    
    -- Scan ALL player objects
    for _, obj in pairs(player:GetDescendants()) do
        local data = {
            Path = obj:GetFullName(),
            Name = obj.Name,
            Class = obj.ClassName,
            Children = #obj:GetChildren()
        }
        
        -- Get value if it's a ValueBase
        if obj:IsA("ValueBase") then
            data.Value = obj.Value
        end
        
        -- Get attributes
        local attributes = {}
        for _, attrName in pairs(obj:GetAttributes()) do
            attributes[attrName] = obj:GetAttribute(attrName)
        end
        if next(attributes) then
            data.Attributes = attributes
        end
        
        table.insert(allData, data)
    end
    
    print("Scanned " .. #allData .. " player objects")
    
    -- Look for patterns
    print("\n📊 LOOKING FOR PATTERNS:")
    
    -- Group by similar names
    local namePatterns = {}
    for _, data in pairs(allData) do
        if not namePatterns[data.Name] then
            namePatterns[data.Name] = 0
        end
        namePatterns[data.Name] = namePatterns[data.Name] + 1
    end
    
    -- Show most common names
    print("\nMost common object names:")
    local sortedNames = {}
    for name, count in pairs(namePatterns) do
        table.insert(sortedNames, {Name = name, Count = count})
    end
    table.sort(sortedNames, function(a, b) return a.Count > b.Count end)
    
    for i = 1, math.min(10, #sortedNames) do
        print(string.format("%d. %s (x%d)", i, sortedNames[i].Name, sortedNames[i].Count))
    end
    
    -- Look for car-related data
    print("\n🔍 CAR-RELATED OBJECTS:")
    for _, data in pairs(allData) do
        local nameLower = data.Name:lower()
        if nameLower:find("car") or nameLower:find("vehicle") or 
           (data.Value and tostring(data.Value):lower():find("car")) then
            
            print("\n" .. data.Path)
            print("  Class: " .. data.Class)
            print("  Children: " .. data.Children)
            if data.Value then
                print("  Value: " .. tostring(data.Value))
            end
            if data.Attributes then
                print("  Attributes:")
                for attrName, attrValue in pairs(data.Attributes) do
                    print("    " .. attrName .. " = " .. tostring(attrValue))
                end
            end
        end
    end
    
    return allData
end

-- ===== STEP 2: FIND CAR PURCHASE EVENTS =====
local function findRealPurchaseEvents()
    print("\n💰 FINDING REAL PURCHASE EVENTS")
    
    -- Get ALL remotes
    local allRemotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local remoteData = {
                Object = obj,
                Name = obj.Name,
                Type = obj.ClassName,
                Path = obj:GetFullName()
            }
            table.insert(allRemotes, remoteData)
        end
    end
    
    print("Found " .. #allRemotes .. " remote objects")
    
    -- Show top 20 remotes
    print("\nTop 20 Remote Objects:")
    for i = 1, math.min(20, #allRemotes) do
        print(string.format("%d. %s (%s)", i, allRemotes[i].Name, allRemotes[i].Type))
    end
    
    return allRemotes
end

-- ===== STEP 3: TEST WITH REAL PURCHASE DATA =====
local function testWithPurchaseData(remotes)
    print("\n🧪 TESTING WITH REAL PURCHASE DATA")
    
    -- Based on your car names, create test data
    local testCars = {
        "Bontlay Bontaga",
        "Jegar Model F", 
        "Sportler Tecan",
        "Lavish Ventoge",
        "Corsaro T8"
    }
    
    local purchaseAttempts = 0
    local successfulCalls = {}
    
    for _, remoteData in pairs(remotes) do
        local remote = remoteData.Object
        
        -- Skip if not in ReplicatedStorage (might be internal)
        if not remote:IsDescendantOf(ReplicatedStorage) then
            -- But still try if it's in ServerStorage or similar
            local parentChain = {}
            local current = remote.Parent
            while current and current ~= game do
                table.insert(parentChain, 1, current.Name)
                current = current.Parent
            end
            
            if #parentChain > 0 then
                print("Remote in: " .. table.concat(parentChain, " → "))
            end
        end
        
        -- Test with car purchase data
        for _, carName in pairs(testCars) do
            -- Create realistic purchase data
            local purchaseData = {
                -- Format 1: Simple table
                {carName},
                {carName, 0},
                {carName, 1000},
                
                -- Format 2: With timestamp
                {carName, os.time()},
                
                -- Format 3: With player data
                {player, carName},
                {player.UserId, carName},
                
                -- Format 4: JSON-like
                {Car = carName, Price = 0, Timestamp = os.time()},
                {Vehicle = carName, Purchase = true},
                
                -- Format 5: Command format
                {"buy", carName},
                {"purchase", carName, player},
                
                -- Format 6: For specific car types
                {carName:gsub(" ", "_")},  -- Bontlay_Bontaga
                {carName:gsub(" ", "")},   -- BontlayBontaga
                {string.lower(carName:gsub(" ", "_"))},  -- bontlay_bontaga
                
                -- Format 7: With car ID
                {carName, 1},  -- ID 1
                {carName, math.random(100, 999)},  -- Random ID
                
                -- Format 8: Complete purchase object
                {
                    CarName = carName,
                    Player = player.Name,
                    PlayerId = player.UserId,
                    Price = 0,
                    Currency = "Cash",
                    TransactionId = "TXN_" .. os.time(),
                    Location = "Dealership",
                    Time = os.time()
                }
            }
            
            for _, data in pairs(purchaseData) do
                purchaseAttempts = purchaseAttempts + 1
                
                local success, result = pcall(function()
                    if remoteData.Type == "RemoteEvent" then
                        remote:FireServer(unpack(data))
                        return "FireServer sent"
                    else
                        remote:InvokeServer(unpack(data))
                        return "InvokeServer sent"
                    end
                end)
                
                if success then
                    if not successfulCalls[remoteData.Name] then
                        successfulCalls[remoteData.Name] = {}
                    end
                    table.insert(successfulCalls[remoteData.Name], data)
                    
                    print("✅ " .. remoteData.Name .. " accepted: " .. tostring(data[1]))
                end
                
                if purchaseAttempts % 50 == 0 then
                    print("Attempt " .. purchaseAttempts .. "...")
                end
                
                task.wait(0.02)
            end
        end
    end
    
    print("\n📊 PURCHASE TEST RESULTS:")
    print("Total attempts: " .. purchaseAttempts)
    print("Successful remote calls: " .. #(successfulCalls))
    
    if next(successfulCalls) then
        print("\nRemotes that accepted calls:")
        for remoteName, calls in pairs(successfulCalls) do
            print("  " .. remoteName .. " (" .. #calls .. " calls)")
            for i, call in ipairs(calls) do
                if i <= 3 then  -- Show first 3 successful calls
                    print("    - " .. tostring(call[1]))
                end
            end
        end
    else
        print("\n❌ NO remote accepted any call!")
        print("Game has strong validation or wrong format.")
    end
    
    return successfulCalls
end

-- ===== STEP 4: ANALYZE GAME STRUCTURE =====
local function analyzeGameStructure()
    print("\n🏗️ ANALYZING GAME STRUCTURE")
    
    -- Look for car spawners, dealerships, etc.
    print("\nLooking for car-related objects in Workspace:")
    
    local carObjects = {}
    
    -- Check Workspace
    if Workspace:FindFirstChild("Cars") then
        print("Found Cars folder in Workspace")
        for _, car in pairs(Workspace.Cars:GetChildren()) do
            if car:IsA("Model") then
                table.insert(carObjects, {
                    Name = car.Name,
                    Type = "Workspace Car",
                    Location = "Workspace.Cars"
                })
            end
        end
    end
    
    -- Check for dealership
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj.Name:find("Dealership") then
            print("Found Dealership: " .. obj.Name)
        end
    end
    
    -- Check for spawn points
    local spawnPoints = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:find("Spawn") and obj:IsA("BasePart") then
            table.insert(spawnPoints, obj.Name)
        end
    end
    
    if #spawnPoints > 0 then
        print("Spawn points found: " .. table.concat(spawnPoints, ", "))
    end
end

-- ===== STEP 5: CREATE DIAGNOSTIC REPORT =====
local function createDiagnosticReport()
    print("\n📋 CREATING DIAGNOSTIC REPORT")
    print(string.rep("=", 60))
    
    -- Player info
    print("\n👤 PLAYER INFO:")
    print("Name: " .. player.Name)
    print("UserId: " .. player.UserId)
    
    -- Inventory check
    print("\n📦 INVENTORY CHECK:")
    local hasInventory = false
    for _, folder in pairs(player:GetChildren()) do
        if folder:IsA("Folder") then
            print("Folder: " .. folder.Name .. " (" .. #folder:GetChildren() .. " items)")
            hasInventory = true
        end
    end
    
    if not hasInventory then
        print("❌ No inventory folders found!")
    end
    
    -- Leaderstats check
    print("\n🏆 LEADERSTATS:")
    if player:FindFirstChild("leaderstats") then
        for _, stat in pairs(player.leaderstats:GetChildren()) do
            print("  " .. stat.Name .. ": " .. tostring(stat.Value))
        end
    else
        print("❌ No leaderstats found!")
    end
    
    -- Remote events check
    print("\n📡 REMOTE EVENTS IN REPLICATEDSTORAGE:")
    local remoteCount = 0
    for _, obj in pairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            remoteCount = remoteCount + 1
            if remoteCount <= 10 then  -- Show first 10
                print("  " .. obj.Name .. " (" .. obj.ClassName .. ")")
            end
        end
    end
    print("Total remotes: " .. remoteCount)
    
    -- Module scripts
    print("\n📦 MODULE SCRIPTS:")
    local moduleCount = 0
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            moduleCount = moduleCount + 1
        end
    end
    print("Module scripts: " .. moduleCount)
    
    print(string.rep("=", 60))
end

-- ===== STEP 6: MANUAL CAR LOCATION FINDER =====
local function manualCarFinder()
    print("\n🔍 MANUAL CAR LOCATION FINDER")
    print("Follow these steps:")
    print("\n1. Open the Developer Console (F9)")
    print("2. Type these commands one by one:")
    print("\n   Commands to try:")
    print("   print(game.Players.LocalPlayer:GetChildren())")
    print("   for i,v in pairs(game.Players.LocalPlayer:GetChildren()) do print(v.Name, v.ClassName) end")
    print("   for i,v in pairs(game.Players.LocalPlayer:GetDescendants()) do if v:IsA('StringValue') then print(v.Name, v.Value) end end")
    print("\n3. Look for your car names in the output")
    print("4. Note the exact path where cars are stored")
    
    -- Auto-run some diagnostics
    task.wait(2)
    
    print("\n🔧 AUTO-DIAGNOSTICS:")
    
    -- Check for StringValues with car names
    local carNames = {"Bontlay", "Jegar", "Sportler", "Lavish", "Corsaro", "T8", "Model", "Bontaga"}
    
    for _, obj in pairs(player:GetDescendants()) do
        if obj:IsA("StringValue") then
            local value = tostring(obj.Value)
            for _, carWord in pairs(carNames) do
                if value:find(carWord) then
                    print("Found: " .. obj:GetFullName() .. " = " .. value)
                end
            end
        end
    end
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 70))
print("🔍 DEEP CAR STORAGE ANALYSIS")
print(string.rep("=", 70))

-- Run all diagnostics
task.wait(1)
createDiagnosticReport()

task.wait(1)
deepScanPlayerData()

task.wait(1)
local allRemotes = findRealPurchaseEvents()

task.wait(1)
analyzeGameStructure()

task.wait(1)
local successfulCalls = testWithPurchaseData(allRemotes)

task.wait(1)
manualCarFinder()

-- Final analysis
print("\n" .. string.rep("=", 70))
print("📊 ANALYSIS COMPLETE")
print(string.rep("=", 70))

if next(successfulCalls) then
    print("\n🎯 NEXT STEPS:")
    print("1. Remote events ARE accepting calls")
    print("2. The issue is CAR STORAGE FORMAT")
    print("3. We need to find WHERE cars are saved")
    print("\n💡 Try this:")
    print("• Buy a NEW car and watch where it saves")
    print("• Check F9 console while buying")
    print("• Look for new objects appearing in player")
else
    print("\n❌ CRITICAL ISSUE:")
    print("NO remote events are accepting ANY calls!")
    print("\nThis means:")
    print("1. Game has server-side validation")
    print("2. All client requests are rejected")
    print("3. Car duplication is NOT possible")
    print("\n💡 Last resort:")
    print("Try to find SAVE/LOAD system instead")
end

-- Create simple monitor
task.spawn(function()
    while true do
        task.wait(10)
        print("\n🔍 Quick check - looking for car data...")
        
        local foundAny = false
        for _, obj in pairs(player:GetDescendants()) do
            if obj:IsA("StringValue") then
                local value = tostring(obj.Value)
                if value:find("Bontlay") or value:find("Jegar") or value:find("Corsaro") then
                    print("Still found: " .. obj.Name .. " = " .. value)
                    foundAny = true
                end
            end
        end
        
        if not foundAny then
            print("No car data found in current scan")
        end
    end
end)
