-- 🚀 NEXT-GEN CAR DUPLICATION SYSTEM
-- Game ID: ffad7ea30d080c4aa1d7bf4b2f5f4381

print("🚀 NEXT-GEN DUPLICATION SYSTEM")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== STEP 1: DEEP GAME ANALYSIS =====
local function analyzeGameStructure()
    print("\n🔬 DEEP GAME ANALYSIS")
    
    local gameInfo = {
        PlaceId = game.PlaceId,
        GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name,
        CreatorId = game.CreatorId
    }
    
    print("Game: " .. gameInfo.GameName)
    print("Place ID: " .. gameInfo.PlaceId)
    
    -- Find ALL server scripts
    local serverScripts = {}
    pcall(function()
        local serverScriptService = game:GetService("ServerScriptService")
        for _, script in pairs(serverScriptService:GetDescendants()) do
            if script:IsA("Script") then
                table.insert(serverScripts, script.Name)
            end
        end
    end)
    
    -- Find ALL modules
    local modules = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            table.insert(modules, obj.Name)
        end
    end
    
    print("Server scripts found: " .. #serverScripts)
    print("Modules found: " .. #modules)
    
    return gameInfo
end

-- ===== STEP 2: MEMORY/STATE MANIPULATION =====
local function attemptStateManipulation()
    print("\n💫 ATTEMPTING STATE MANIPULATION")
    
    -- Strategy: Find and modify the GAME'S INTERNAL STATE
    
    -- 1. Look for game-wide car data
    local carDatabase = Workspace:FindFirstChild("CarDatabase") or 
                       ReplicatedStorage:FindFirstChild("CarDatabase") or
                       game:FindFirstChild("CarDatabase")
    
    if carDatabase then
        print("Found CarDatabase!")
        
        -- Try to add our car to the database
        for _, car in pairs(carDatabase:GetChildren()) do
            if car:IsA("Model") then
                -- Try to clone the car model
                local clone = car:Clone()
                clone.Name = "LirrMedMuseumCar_Duplicate"
                clone.Parent = carDatabase
                print("✅ Added duplicate to database")
            end
        end
    end
    
    -- 2. Look for car spawners
    local carSpawners = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("spawn") and obj:IsA("Model") then
            table.insert(carSpawners, obj)
        end
    end
    
    -- 3. Try to manipulate car spawners
    for _, spawner in pairs(carSpawners) do
        -- Look for scripts in spawner
        for _, child in pairs(spawner:GetDescendants()) do
            if child:IsA("Script") then
                -- Try to disable or modify spawn logic
                pcall(function()
                    child.Disabled = true
                    print("⚠️ Disabled spawner script: " .. child.Name)
                end)
            end
        end
    end
    
    -- 4. Look for car purchase buttons in UI
    if player:FindFirstChild("PlayerGui") then
        for _, gui in pairs(player.PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") and gui.Text:lower():find("buy") then
                -- Try to trigger the button repeatedly
                for i = 1, 10 do
                    pcall(function()
                        gui:Fire("MouseButton1Click")
                    end)
                    task.wait(0.05)
                end
                print("✅ Spammed buy button: " .. gui.Name)
            end
        end
    end
end

-- ===== STEP 3: NETWORK PACKET MANIPULATION =====
local function attemptNetworkManipulation()
    print("\n📡 NETWORK MANIPULATION ATTEMPT")
    
    -- Create FAKE server responses
    
    -- 1. Create a fake remote to intercept calls
    local fakeRemote = Instance.new("RemoteEvent")
    fakeRemote.Name = "FakeCarPurchase"
    fakeRemote.Parent = ReplicatedStorage
    
    -- 2. Try to override existing remotes
    for _, remote in pairs(ReplicatedStorage:GetChildren()) do
        if remote:IsA("RemoteEvent") and remote.Name:find("Car") then
            -- Store original fire function
            local originalFire = remote.FireServer
            
            -- Override it
            remote.FireServer = function(self, ...)
                local args = {...}
                print("Intercepted call to " .. remote.Name)
                print("Args:", ...)
                
                -- Call original
                return originalFire(self, ...)
            end
            
            print("⚠️ Overrode " .. remote.Name)
        end
    end
    
    -- 3. Try to send crafted packets
    local function sendCraftedPacket(eventName, ...)
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if event and event:IsA("RemoteEvent") then
            -- Send with crafted data
            local craftedData = {
                Player = player,
                Car = "LirrMedMuseumCar",
                Price = 0,
                Timestamp = os.time(),
                Verified = true,  -- Fake verification
                Receipt = "FAKE_RECEIPT_" .. math.random(10000, 99999)
            }
            
            pcall(function()
                event:FireServer(craftedData)
                print("✅ Sent crafted packet to " .. eventName)
            end)
        end
    end
    
    sendCraftedPacket("PurchaseCar")
    sendCraftedPacket("BuyVehicle")
    sendCraftedPacket("AddCarToGarage")
end

-- ===== STEP 4: EXPLOIT SESSION DATA =====
local function exploitSessionData()
    print("\n🕒 SESSION DATA EXPLOIT")
    
    -- Games often store temporary session data
    -- Look for it and modify it
    
    -- 1. Check if game stores cars in workspace temporarily
    if Workspace:FindFirstChild("PlayerCars") then
        for _, car in pairs(Workspace.PlayerCars:GetChildren()) do
            if car:IsA("Model") and car.Name == "LirrMedMuseumCar" then
                -- Try to duplicate in workspace
                local duplicate = car:Clone()
                duplicate.Name = "LirrMedMuseumCar_Dup"
                duplicate.Parent = Workspace.PlayerCars
                print("✅ Duplicated car in workspace")
            end
        end
    end
    
    -- 2. Look for temporary data stores
    local tempStores = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj.Name:find("Temp") or obj.Name:find("Session") then
            if obj:IsA("Folder") then
                -- Try to add our car
                local fakeCar = Instance.new("StringValue")
                fakeCar.Name = "LirrMedMuseumCar"
                fakeCar.Value = "DUPLICATED"
                fakeCar.Parent = obj
                print("✅ Added to temp store: " .. obj.Name)
            end
        end
    end
    
    -- 3. Manipulate player's session ID or tokens
    local function generateFakeToken()
        return "TOKEN_" .. player.UserId .. "_" .. os.time() .. "_" .. math.random(1000, 9999)
    end
    
    -- Try to set fake tokens
    for _, child in pairs(player:GetChildren()) do
        if child:IsA("StringValue") and child.Name:find("Token") then
            pcall(function()
                local oldValue = child.Value
                child.Value = generateFakeToken()
                print("⚠️ Changed token: " .. oldValue .. " → " .. child.Value)
            end)
        end
    end
end

-- ===== STEP 5: TIMING ATTACK =====
local function timingAttack()
    print("\n⏱️ TIMING ATTACK")
    
    -- Try to exploit race conditions or timing windows
    
    local function rapidFireEvent(eventName, carName, attempts)
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if event and event:IsA("RemoteEvent") then
            print("Rapid firing " .. eventName .. " x" .. attempts)
            
            -- Fire as fast as possible
            for i = 1, attempts do
                task.spawn(function()
                    pcall(function()
                        event:FireServer(carName)
                    end)
                end)
            end
            
            print("✅ Sent " .. attempts .. " rapid requests")
        end
    end
    
    -- Try rapid fire on multiple events
    rapidFireEvent("BuyCar", "LirrMedMuseumCar", 50)
    rapidFireEvent("PurchaseCar", "LirrMedMuseumCar", 50)
    rapidFireEvent("AddCar", "LirrMedMuseumCar", 50)
    
    -- Try with delays to confuse server
    for i = 1, 20 do
        task.spawn(function()
            task.wait(math.random() * 0.1)  -- Random delays
            local event = ReplicatedStorage:FindFirstChild("BuyCar")
            if event then
                pcall(function()
                    event:FireServer("LirrMedMuseumCar", i)
                end)
            end
        end)
    end
end

-- ===== STEP 6: DATASTORE EXPLOITATION =====
local function attemptDatastoreExploit()
    print("\n💾 DATASTORE EXPLOIT ATTEMPT")
    
    -- Try to intercept or fake DataStore calls
    
    -- Look for DataStore modules
    local datastoreModules = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local name = obj.Name:lower()
            if name:find("datastore") or name:find("save") or name:find("data") then
                table.insert(datastoreModules, obj)
            end
        end
    end
    
    -- Try to require and manipulate modules
    for _, module in pairs(datastoreModules) do
        local success, moduleTable = pcall(function()
            return require(module)
        end)
        
        if success and type(moduleTable) == "table" then
            print("Loaded module: " .. module.Name)
            
            -- Look for save/load functions
            for key, value in pairs(moduleTable) do
                if type(value) == "function" and 
                   (key:lower():find("save") or key:lower():find("set") or 
                    key:lower():find("update")) then
                    
                    -- Try to call with fake data
                    pcall(function()
                        local fakeData = {
                            Cars = {"LirrMedMuseumCar", "LirrMedMuseumCar", "LirrMedMuseumCar"},
                            Money = 9999999,
                            Level = 100
                        }
                        
                        value(fakeData)
                        print("✅ Called " .. key .. " with fake data")
                    end)
                end
            end
        end
    end
end

-- ===== STEP 7: CREATE BACKDOOR =====
local function createBackdoor()
    print("\n🚪 ATTEMPTING TO CREATE BACKDOOR")
    
    -- Try to insert our own script into the game
    
    -- 1. Create a "helper" script in ReplicatedStorage
    local backdoorScript = Instance.new("LocalScript")
    backdoorScript.Name = "CarDuplicationHelper"
    backdoorScript.Source = [[
        -- Backdoor script
        local player = game.Players.LocalPlayer
        
        -- Function to force-add cars
        local function forceAddCar(carName)
            -- Try all known methods
            local events = {"BuyCar", "PurchaseCar", "AddCar"}
            
            for _, eventName in pairs(events) do
                local event = game.ReplicatedStorage:FindFirstChild(eventName)
                if event then
                    for i = 1, 10 do
                        event:FireServer(carName)
                        wait(0.01)
                    end
                end
            end
        end
        
        -- Make it accessible
        getgenv().ForceAddCar = forceAddCar
        print("Backdoor ready. Use ForceAddCar('LirrMedMuseumCar')")
    ]]
    
    backdoorScript.Parent = ReplicatedStorage
    print("✅ Created backdoor script")
    
    -- 2. Try to inject into existing scripts
    for _, script in pairs(ReplicatedStorage:GetDescendants()) do
        if script:IsA("LocalScript") and script.Name:find("Car") then
            pcall(function()
                local originalSource = script.Source
                local modifiedSource = originalSource .. [[
                    -- Injected code
                    if not _G.carHackInjected then
                        _G.carHackInjected = true
                        spawn(function()
                            wait(2)
                            game.ReplicatedStorage:FindFirstChild("BuyCar"):FireServer("LirrMedMuseumCar")
                        end)
                    end
                ]]
                script.Source = modifiedSource
                print("⚠️ Injected into: " .. script.Name)
            end)
        end
    end
end

-- ===== STEP 8: ULTIMATE BRUTE FORCE =====
local function ultimateBruteForce()
    print("\n💥 ULTIMATE BRUTE FORCE")
    
    -- Try EVERYTHING in one go
    
    -- 1. Get all remotes
    local allRemotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(allRemotes, obj)
        end
    end
    
    -- 2. Brute force all remotes with all possible args
    local argSets = {
        {"LirrMedMuseumCar"},
        {player, "LirrMedMuseumCar"},
        {"LirrMedMuseumCar", 0},
        {"LirrMedMuseumCar", 1},
        {"buy", "LirrMedMuseumCar"},
        {"purchase", "LirrMedMuseumCar"},
        {"add", "LirrMedMuseumCar"},
        {"duplicate", "LirrMedMuseumCar"},
        {"clone", "LirrMedMuseumCar"},
        {"LirrMedMuseumCar", true},
        {"LirrMedMuseumCar", "free"},
        {Car = "LirrMedMuseumCar"},
        {Vehicle = "LirrMedMuseumCar"},
        {player.UserId, "LirrMedMuseumCar"},
        {"LirrMedMuseumCar", 9999999},
        {"LirrMedMuseumCar", -1},
        {"LirrMedMuseumCar", math.huge},
        {"LirrMedMuseumCar", player.Name},
        {"Lirr", "MedMuseumCar"},
        {"LirrMedMuseum", "Car"},
        {1, "LirrMedMuseumCar"},
        {true, "LirrMedMuseumCar"},
        {"LirrMedMuseumCar", nil},
        {"LirrMedMuseumCar", {}},
        {"LirrMedMuseumCar", function() end}
    }
    
    print("Brute forcing " .. #allRemotes .. " remotes with " .. #argSets .. " arg sets")
    
    local totalAttempts = 0
    for _, remote in pairs(allRemotes) do
        for _, args in pairs(argSets) do
            totalAttempts = totalAttempts + 1
            if totalAttempts % 100 == 0 then
                print("Attempt " .. totalAttempts .. "...")
            end
            
            task.spawn(function()
                pcall(function()
                    remote:FireServer(unpack(args))
                end)
            end)
            
            task.wait(0.001)  -- Very fast
        end
    end
    
    print("✅ Sent " .. totalAttempts .. " brute force attempts")
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 70))
print("🚀 LAUNCHING NEXT-GEN DUPLICATION ATTACK")
print(string.rep("=", 70))

-- Run ALL methods
task.wait(1)

-- Step 1: Analysis
analyzeGameStructure()

-- Step 2-8: All attack vectors
task.wait(1)
attemptStateManipulation()

task.wait(1)
attemptNetworkManipulation()

task.wait(1)
exploitSessionData()

task.wait(1)
timingAttack()

task.wait(1)
attemptDatastoreExploit()

task.wait(1)
createBackdoor()

task.wait(1)
ultimateBruteForce()

-- Final check
task.wait(5)
print("\n" .. string.rep("=", 70))
print("🎯 ATTACK COMPLETE")
print(string.rep("=", 70))
print("\nCheck your garage NOW!")
print("If still no duplicate, the game is bulletproof.")
print("\nLast resort ideas:")
print("1. Try on a FRESH server")
print("2. Buy a car, then IMMEDIATELY run script")
print("3. Try during server lag/peak hours")
print("4. Combine with other exploits if found")

-- Create monitoring script
task.spawn(function()
    while true do
        task.wait(10)
        print("\n🔍 Monitoring car count...")
        local carCount = 0
        for _, folder in pairs(player:GetChildren()) do
            if folder:IsA("Folder") then
                for _, item in pairs(folder:GetChildren()) do
                    if item.Name:find("Lirr") then
                        carCount = carCount + 1
                    end
                end
            end
        end
        print("Lirr cars detected: " .. carCount)
    end
end)
