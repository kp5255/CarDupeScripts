-- ===== SPECIALIZED CAR FINDER =====
local function findStoredCars()
    print("\n🚗 SPECIALIZED CAR FINDER")
    
    -- Known car names from your list
    local knownCars = {
        "Bontlay Bontaga",
        "Jegar Model F",
        "Sportler Tecan", 
        "Lavish Ventoge",
        "Corsaro T8"
    }
    
    -- Check common storage locations
    local storageLocations = {
        player,
        player:FindFirstChild("Backpack"),
        player:FindFirstChild("PlayerGui"),
        ReplicatedStorage,
        game:GetService("ServerStorage"),
        game:GetService("Workspace")
    }
    
    local foundCars = {}
    
    for _, location in pairs(storageLocations) do
        if location then
            print("\nChecking: " .. location:GetFullName())
            
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("StringValue") or obj:IsA("Folder") or obj:IsA("Model") then
                    local nameLower = obj.Name:lower()
                    local valueCheck = ""
                    
                    if obj:IsA("StringValue") then
                        valueCheck = tostring(obj.Value):lower()
                    end
                    
                    -- Check for car names
                    for _, carName in pairs(knownCars) do
                        local carLower = carName:lower()
                        
                        if nameLower:find(carLower:gsub(" ", "")) or 
                           nameLower:find(carLower:gsub(" ", "_")) or
                           valueCheck:find(carLower) then
                            
                            table.insert(foundCars, {
                                Object = obj,
                                Name = obj.Name,
                                Class = obj.ClassName,
                                Path = obj:GetFullName(),
                                Value = obj:IsA("StringValue") and obj.Value or nil
                            })
                            
                            print("FOUND: " .. obj:GetFullName())
                            if obj:IsA("StringValue") then
                                print("  Value: " .. tostring(obj.Value))
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Also check leaderstats
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        print("\nChecking leaderstats...")
        for _, stat in pairs(leaderstats:GetChildren()) do
            print("  " .. stat.Name .. ": " .. tostring(stat.Value))
        end
    end
    
    print("\n📊 RESULTS:")
    if #foundCars > 0 then
        print("Found " .. #foundCars .. " car references")
        
        -- Group by location
        local byLocation = {}
        for _, car in pairs(foundCars) do
            local parent = car.Object.Parent
            if parent then
                local loc = parent:GetFullName()
                if not byLocation[loc] then
                    byLocation[loc] = 0
                end
                byLocation[loc] = byLocation[loc] + 1
            end
        end
        
        print("\nBy location:")
        for location, count in pairs(byLocation) do
            print("  " .. location .. ": " .. count .. " cars")
        end
    else
        print("❌ No car data found in common locations")
        print("\n💡 Try these manual steps:")
        print("1. Buy a cheap car if possible")
        print("2. Immediately check: game.Players.LocalPlayer")
        print("3. Look for new folders or StringValues")
        print("4. Check the console (F9) for any messages")
    end
    
    return foundCars
end
