-- 🎯 TARGETED ATTACK: NY SALE! Car Dealership Tycoon
-- Place ID: 1554960397

print("🎯 TARGETED ATTACK: NY SALE! CAR DEALERSHIP")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== STEP 1: ANALYZE 18,844 MODULES =====
local function analyzeModules()
    print("\n🔍 ANALYZING 18,844 MODULES...")
    
    -- Look for car-related modules
    local carModules = {}
    local purchaseModules = {}
    local moneyModules = {}
    local garageModules = {}
    
    local checked = 0
    local maxCheck = 500  -- Check first 500 modules
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") and checked < maxCheck then
            checked = checked + 1
            
            local name = obj.Name:lower()
            
            if name:find("car") or name:find("vehicle") then
                table.insert(carModules, obj)
            end
            
            if name:find("purchase") or name:find("buy") then
                table.insert(purchaseModules, obj)
            end
            
            if name:find("money") or name:find("cash") then
                table.insert(moneyModules, obj)
            end
            
            if name:find("garage") or name:find("inventory") then
                table.insert(garageModules, obj)
            end
        end
    end
    
    print("Found:")
    print("- Car modules: " .. #carModules)
    print("- Purchase modules: " .. #purchaseModules)
    print("- Money modules: " .. #moneyModules)
    print("- Garage modules: " .. #garageModules)
    
    -- Show top modules
    if #carModules > 0 then
        print("\nTop car modules:")
        for i = 1, math.min(5, #carModules) do
            print("  " .. carModules[i].Name)
        end
    end
    
    return {
        CarModules = carModules,
        PurchaseModules = purchaseModules,
        MoneyModules = moneyModules,
        GarageModules = garageModules
    }
end

-- ===== STEP 2: ATTACK MODULES DIRECTLY =====
local function attackModules(modules)
    print("\n⚡ ATTACKING MODULES...")
    
    -- Try to require and exploit car modules
    for _, module in pairs(modules.CarModules) do
        local success, moduleTable = pcall(function()
            return require(module)
        end)
        
        if success and type(moduleTable) == "table" then
            print("\n✅ Loaded module: " .. module.Name)
            
            -- Look for important functions
            for key, value in pairs(moduleTable) do
                if type(value) == "function" then
                    print("  Function: " .. key)
                    
                    -- Try to call with car name
                    if key:lower():find("add") or key:lower():find("give") or 
                       key:lower():find("spawn") or key:lower():find("create") then
                        
                        pcall(function()
                            value("LirrMedMuseumCar")
                            print("    ✅ Called with LirrMedMuseumCar")
                        end)
                        
                        pcall(function()
                            value(player, "LirrMedMuseumCar")
                            print("    ✅ Called with player")
                        end)
                    end
                end
            end
            
            -- Look for car tables/lists
            for key, value in pairs(moduleTable) do
                if type(value) == "table" then
                    -- Check if it's a car list
                    if key:lower():find("car") or key:lower():find("vehicle") then
                        print("  Found car table: " .. key)
                        
                        -- Try to add our car
                        pcall(function()
                            table.insert(value, "LirrMedMuseumCar")
                            print("    ✅ Added to car table")
                        end)
                    end
                elseif type(value) == "string" then
                    if value:lower():find("lirr") then
                        print("  Found Lirr reference: " .. value)
                    end
                end
            end
        end
    end
end

-- ===== STEP 3: FIND CAR PURCHASE SYSTEM =====
local function findPurchaseSystem()
    print("\n💰 FINDING PURCHASE SYSTEM...")
    
    -- Look for purchase-related remotes
    local purchaseRemotes = {}
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            
            if name:find("purchase") or name:find("buy") or 
               name:find("shop") or name:find("store") then
                table.insert(purchaseRemotes, obj)
                print("Purchase remote: " .. obj.Name)
            end
        end
    end
    
    -- Try common purchase patterns for THIS game
    local attempts = 0
    
    for _, remote in pairs(purchaseRemotes) do
        -- Try different purchase formats
        local patterns = {
            -- Format 1: Just car name
            {"LirrMedMuseumCar"},
            
            -- Format 2: Car name + price
            {"LirrMedMuseumCar", 0},
            {"LirrMedMuseumCar", 1},
            {"LirrMedMuseumCar", 100},
            
            -- Format 3: With player
            {player, "LirrMedMuseumCar"},
            {player.UserId, "LirrMedMuseumCar"},
            
            -- Format 4: Table format
            {Car = "LirrMedMuseumCar", Price = 0},
            {Vehicle = "LirrMedMuseumCar", Purchase = true},
            
            -- Format 5: String command
            {"buycar", "LirrMedMuseumCar"},
            {"purchase", "LirrMedMuseumCar"},
            
            -- Format 6: For NY SALE game
            {"LirrMedMuseumCar", "SALE"},
            {"LirrMedMuseumCar", true, "NY_SALE"},
            {"LirrMedMuseumCar", player.Name, os.time()}
        }
        
        for _, args in pairs(patterns) do
            attempts = attempts + 1
            local success = pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(unpack(args))
                else
                    remote:InvokeServer(unpack(args))
                end
            end)
            
            if success then
                print("✅ Purchase attempt " .. attempts .. " via " .. remote.Name)
            end
            
            task.wait(0.05)
        end
    end
    
    return attempts
end

-- ===== STEP 4: EXPLOIT GARAGE SYSTEM =====
local function exploitGarageSystem()
    print("\n🏢 EXPLOITING GARAGE SYSTEM...")
    
    -- Look for garage/storage modules
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") and obj.Name:lower():find("garage") then
            local success, moduleTable = pcall(function()
                return require(obj)
            end)
            
            if success and type(moduleTable) == "table" then
                print("Found garage module: " .. obj.Name)
                
                -- Look for add/get functions
                for key, value in pairs(moduleTable) do
                    if type(value) == "function" then
                        if key:lower():find("add") or key:lower():find("store") then
                            -- Try to add car
                            pcall(function()
                                value(player, "LirrMedMuseumCar")
                                print("  ✅ Called " .. key .. " with our car")
                            end)
                            
                            -- Try to add multiple
                            for i = 1, 5 do
                                pcall(function()
                                    value(player, "LirrMedMuseumCar")
                                end)
                                task.wait(0.01)
                            end
                        end
                        
                        if key:lower():find("get") or key:lower():find("list") then
                            -- Try to get garage contents
                            pcall(function()
                                local result = value(player)
                                print("  Garage contents: " .. tostring(result))
                            end)
                        end
                    end
                end
            end
        end
    end
end

-- ===== STEP 5: INTERCEPT NETWORK TRAFFIC =====
local function interceptNetwork()
    print("\n📡 INTERCEPTING NETWORK...")
    
    -- Try to hook into network events
    local hookedRemotes = {}
    
    for _, remote in pairs(ReplicatedStorage:GetChildren()) do
        if remote:IsA("RemoteEvent") then
            -- Hook OnClientEvent
            local success = pcall(function()
                local connection = remote.OnClientEvent:Connect(function(...)
                    local args = {...}
                    print("\n📨 Received from " .. remote.Name .. ":")
                    
                    -- Check if it's car-related
                    for _, arg in pairs(args) do
                        if type(arg) == "string" and arg:find("Lirr") then
                            print("  ⚡ Contains our car! Attempting duplication...")
                            
                            -- Try to send duplicate request
                            task.wait(0.1)
                            pcall(function()
                                remote:FireServer("LirrMedMuseumCar")
                                print("  ✅ Sent duplicate request")
                            end)
                        end
                    end
                end)
                
                table.insert(hookedRemotes, {Remote = remote, Connection = connection})
                print("Hooked: " .. remote.Name)
            end)
        end
    end
    
    return hookedRemotes
end

-- ===== STEP 6: DECOMPILE AND ANALYZE =====
local function attemptDecompile()
    print("\n🔧 ATTEMPTING TO ANALYZE GAME LOGIC...")
    
    -- Look for client scripts that handle car purchases
    local clientScripts = {}
    
    if player:FindFirstChild("PlayerGui") then
        for _, script in pairs(player.PlayerGui:GetDescendants()) do
            if script:IsA("LocalScript") then
                local name = script.Name:lower()
                if name:find("car") or name:find("purchase") or name:find("shop") then
                    table.insert(clientScripts, script)
                end
            end
        end
    end
    
    -- Also check StarterGui
    pcall(function()
        for _, script in pairs(game.StarterGui:GetDescendants()) do
            if script:IsA("LocalScript") then
                local name = script.Name:lower()
                if name:find("car") or name:find("purchase") then
                    table.insert(clientScripts, script)
                end
            end
        end
    end)
    
    print("Found " .. #clientScripts .. " car-related client scripts")
    
    -- Try to extract event names from scripts
    for _, script in pairs(clientScripts) do
        pcall(function()
            local source = script.Source
            if #source > 0 then
                -- Look for remote event calls
                for line in source:gmatch("[^\r\n]+") do
                    if line:find("FireServer") or line:find("InvokeServer") then
                        -- Extract event name
                        for eventName in line:gmatch('["\']([^"\']+)["\']') do
                            if not eventName:find(" ") then  -- Probably an event name
                                print("Found event in script: " .. eventName)
                                
                                -- Try to call it
                                local event = ReplicatedStorage:FindFirstChild(eventName)
                                if event then
                                    pcall(function()
                                        event:FireServer("LirrMedMuseumCar")
                                        print("  ✅ Called from script analysis")
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- ===== STEP 7: CREATE BACKDOOR EVENT =====
local function createBackdoorEvent()
    print("\n🚪 CREATING BACKDOOR EVENT...")
    
    -- Create a custom event that might be picked up by game scripts
    local backdoor = Instance.new("RemoteEvent")
    backdoor.Name = "CarDealershipBackdoor"
    backdoor.Parent = ReplicatedStorage
    
    -- Also create a BindableEvent for intra-client communication
    local bindable = Instance.new("BindableEvent")
    bindable.Name = "CarDuplicationSignal"
    bindable.Parent = ReplicatedStorage
    
    -- Trigger our backdoor
    pcall(function()
        backdoor:FireServer("LirrMedMuseumCar", "DUPLICATE")
        print("✅ Fired backdoor event")
    end)
    
    pcall(function()
        bindable:Fire("LirrMedMuseumCar", player)
        print("✅ Fired bindable event")
    end)
    
    -- Try to mimic game's own events
    local fakeEvents = {
        "CarPurchaseComplete",
        "VehicleAddedToGarage", 
        "DealershipTransaction",
        "NY_SALE_Purchase"
    }
    
    for _, eventName in pairs(fakeEvents) do
        local fakeEvent = Instance.new("RemoteEvent")
        fakeEvent.Name = eventName
        fakeEvent.Parent = ReplicatedStorage
        
        pcall(function()
            fakeEvent:FireServer("LirrMedMuseumCar", true, os.time())
        end)
        
        print("Created fake event: " .. eventName)
    end
end

-- ===== STEP 8: MONITOR AND RETRY =====
local function startMonitoring()
    print("\n👁️ STARTING MONITORING...")
    
    -- Monitor car count
    local lastCarCount = 0
    
    while true do
        task.wait(5)
        
        -- Count Lirr cars
        local currentCount = 0
        for _, folder in pairs(player:GetChildren()) do
            if folder:IsA("Folder") then
                for _, item in pairs(folder:GetChildren()) do
                    if tostring(item):find("Lirr") then
                        currentCount = currentCount + 1
                    end
                end
            end
        end
        
        if currentCount > lastCarCount then
            print("🎉 CAR COUNT INCREASED: " .. lastCarCount .. " → " .. currentCount)
            lastCarCount = currentCount
        elseif currentCount < lastCarCount then
            print("⚠️ Car count decreased: " .. currentCount)
            lastCarCount = currentCount
        end
        
        -- Periodically retry duplication
        if math.random(1, 10) == 1 then  -- 10% chance each check
            print("🔄 Periodic retry...")
            local event = ReplicatedStorage:FindFirstChild("BuyCar")
            if event then
                pcall(function()
                    event:FireServer("LirrMedMuseumCar")
                end)
            end
        end
    end
end

-- ===== MAIN ATTACK =====
print("\n" .. string.rep("=", 70))
print("🎯 LAUNCHING TARGETED ATTACK ON NY SALE CAR DEALERSHIP")
print(string.rep("=", 70))

-- Step 1: Analyze modules
local modules = analyzeModules()

-- Step 2: Attack modules
task.wait(1)
attackModules(modules)

-- Step 3: Find purchase system
task.wait(1)
local purchaseAttempts = findPurchaseSystem()
print("Total purchase attempts: " .. purchaseAttempts)

-- Step 4: Exploit garage
task.wait(1)
exploitGarageSystem()

-- Step 5: Intercept network
task.wait(1)
local hooks = interceptNetwork()

-- Step 6: Decompile
task.wait(1)
attemptDecompile()

-- Step 7: Backdoor
task.wait(1)
createBackdoorEvent()

-- Step 8: Start monitoring
task.wait(1)
task.spawn(startMonitoring)

-- Final instructions
print("\n" .. string.rep("=", 70))
print("📋 ATTACK DEPLOYED")
print(string.rep("=", 70))
print("\nNOW DO THIS:")
print("1. WAIT 30 seconds")
print("2. Try to BUY a cheap car normally")
print("3. Check if LirrMedMuseumCar duplicated")
print("4. Walk around dealership")
print("5. Open/close garage menu")
print("\nThe script is MONITORING for changes.")
print("If cars increase, you'll see a message.")
