-- CAR CUSTOMIZATION DATA ANALYZER
-- Finds where customization data is stored in your car objects

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("🔍 CAR CUSTOMIZATION STRUCTURE ANALYZER")
print("=" .. string.rep("=", 60))

-- ===== GET CAR DATA =====
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
local function getCars()
    local success, cars = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if success and type(cars) == "table" then
        print("✅ Loaded " .. #cars .. " cars")
        return cars
    end
    return {}
end

-- ===== DEEP ANALYZE CAR STRUCTURE =====
local function deepAnalyzeCar(car, depth)
    if depth > 3 then return end -- Limit recursion depth
    
    print("\n" .. string.rep("  ", depth) .. "📦 Analyzing level " .. depth .. "...")
    
    local customizationFields = {}
    local nestedTables = {}
    
    for key, value in pairs(car) do
        local valueType = type(value)
        local keyStr = tostring(key)
        local valueStr = tostring(value)
        
        -- Check if this might be customization-related
        if valueType == "table" then
            table.insert(nestedTables, {key = key, value = value})
        
        elseif valueType == "string" then
            -- Look for customization-related field names
            local keyLower = keyStr:lower()
            if keyLower:find("wrap") or keyLower:find("skin") or keyLower:find("paint") or
               keyLower:find("color") or keyLower:find("wheel") or keyLower:find("rim") or
               keyLower:find("underglow") or keyLower:find("neon") or keyLower:find("light") or
               keyLower:find("engine") or keyLower:find("horn") or keyLower:find("exhaust") or
               keyLower:find("spoiler") or keyLower:find("kit") or keyLower:find("custom") then
                
                table.insert(customizationFields, {
                    key = keyStr,
                    value = valueStr,
                    type = valueType
                })
            end
        end
    end
    
    -- Display customization fields found at this level
    if #customizationFields > 0 then
        print(string.rep("  ", depth) .. "🎨 CUSTOMIZATION FOUND at level " .. depth .. ":")
        for _, field in ipairs(customizationFields) do
            print(string.rep("  ", depth) .. "  • " .. field.key .. " = " .. field.value .. " (" .. field.type .. ")")
        end
    end
    
    -- Recursively analyze nested tables
    for _, nested in ipairs(nestedTables) do
        print(string.rep("  ", depth) .. "📁 Entering table: " .. nested.key)
        deepAnalyzeCar(nested.value, depth + 1)
    end
end

-- ===== FIND CUSTOMIZATION DATABASE =====
local function findCustomizationDatabase()
    print("\n🔎 SEARCHING FOR CUSTOMIZATION DATABASE...")
    
    local databases = {}
    
    -- Search common database locations
    local searchPaths = {
        "Databases",
        "Data",
        "GameData",
        "Configuration",
        "Config",
        "Settings",
        "Storage"
    }
    
    for _, path in ipairs(searchPaths) do
        local db = ReplicatedStorage:FindFirstChild(path)
        if db then
            -- Look for customization-related folders
            for _, child in ipairs(db:GetDescendants()) do
                if child:IsA("Folder") or child:IsA("ModuleScript") then
                    local name = child.Name:lower()
                    if name:find("custom") or name:find("wrap") or name:find("skin") or
                       name:find("paint") or name:find("wheel") or name:find("engine") or
                       name:find("horn") or name:find("underglow") or name:find("upgrade") then
                        
                        table.insert(databases, {
                            Name = child.Name,
                            Path = child:GetFullName(),
                            Type = child.ClassName
                        })
                    end
                end
            end
        end
    end
    
    if #databases > 0 then
        print("📁 Found " .. #databases .. " customization databases:")
        for i, db in ipairs(databases) do
            print(i .. ". " .. db.Name .. " (" .. db.Type .. ")")
            print("   Path: " .. db.Path)
        end
    else
        print("❌ No customization database found")
    end
    
    return databases
end

-- ===== GET EQUIPPED CUSTOMIZATIONS =====
local function getEquippedCustomizations()
    print("\n🔧 SEARCHING FOR EQUIPPED CUSTOMIZATIONS...")
    
    -- Try to find customization controller
    local controllers = ReplicatedStorage:FindFirstChild("Controllers")
    if not controllers then
        print("❌ Controllers folder not found")
        return {}
    end
    
    -- Look for customization controller
    local customizationController = controllers:FindFirstChild("CustomizationController")
    if not customizationController then
        print("❌ CustomizationController not found")
        return {}
    end
    
    print("✅ Found CustomizationController")
    
    -- Try to get equipped customizations via remotes
    local remotes = {
        "GetEquippedCustomizations",
        "GetEquippedItems",
        "GetCurrentCustomizations",
        "LoadCustomizations",
        "GetPlayerCustomizations"
    }
    
    for _, remoteName in ipairs(remotes) do
        local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
        if remote and remote:IsA("RemoteFunction") then
            print("🎯 Testing remote: " .. remote.Name)
            
            local success, result = pcall(function()
                return remote:InvokeServer()
            end)
            
            if success then
                print("✅ Remote returned data: " .. type(result))
                
                if type(result) == "table" then
                    print("\n📋 EQUIPPED CUSTOMIZATIONS:")
                    for key, value in pairs(result) do
                        print("  " .. tostring(key) .. " = " .. tostring(value))
                    end
                    return result
                end
            else
                print("❌ Remote failed: " .. tostring(result))
            end
        end
    end
    
    return {}
end

-- ===== ANALYZE SPECIFIC CAR CUSTOMIZATIONS =====
local function analyzeCarCustomizations(car)
    print("\n🚗 ANALYZING CAR: " .. tostring(car.Name or "Unknown"))
    print(string.rep("-", 50))
    
    -- First, check if car has a customization table directly
    for key, value in pairs(car) do
        local keyStr = tostring(key):lower()
        
        if keyStr == "customizations" or keyStr == "upgrades" or 
           keyStr == "mods" or keyStr == "tuning" then
            
            if type(value) == "table" then
                print("🎯 Found customization table: " .. key)
                print("\n📋 Customization items:")
                
                for custKey, custValue in pairs(value) do
                    local valueType = type(custValue)
                    print("  • " .. tostring(custKey) .. " = " .. 
                          tostring(custValue) .. " (" .. valueType .. ")")
                end
                return value
            end
        end
    end
    
    -- If no direct customization table, check all tables
    print("🔍 Searching for nested customization data...")
    deepAnalyzeCar(car, 0)
    
    return nil
end

-- ===== MAIN ANALYSIS =====
local cars = getCars()
if #cars > 0 then
    -- Analyze first car
    local firstCar = cars[1]
    
    -- First, show basic car info
    print("\n📊 BASIC CAR INFO:")
    for key, value in pairs(firstCar) do
        local valueType = type(value)
        if valueType ~= "table" then
            print("  " .. tostring(key) .. " = " .. tostring(value) .. " (" .. valueType .. ")")
        else
            print("  " .. tostring(key) .. " = [TABLE]")
        end
    end
    
    -- Try to analyze customizations
    analyzeCarCustomizations(firstCar)
    
    -- Look for customization database
    findCustomizationDatabase()
    
    -- Try to get equipped customizations
    getEquippedCustomizations()
    
    print("\n" .. string.rep("=", 60))
    print("🎯 NEXT STEPS:")
    print("1. Look for 'Customizations', 'Upgrades', or 'Mods' table in your car data")
    print("2. Check if there's a separate database with customization items")
    print("3. Look for remote events that handle customization changes")
    print("4. The 'update' button likely calls a remote to open customization UI")
    
else
    print("❌ No cars found")
end

print("\n✅ Analysis complete!")
