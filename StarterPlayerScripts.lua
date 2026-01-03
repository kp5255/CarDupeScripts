-- 🚗 CAR DUPLICATION (Safe Version)
-- Game ID: ffad7ea30d080c4aa1d7bf4b2f5f4381

print("🚗 CAR DUPLICATION")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()

local function duplicateCars()
    print("\n🎯 Starting car duplication...")
    
    -- FIND WHAT CARS YOU OWN (SAFELY)
    local ownedCars = {}
    
    -- Check for inventory safely
    local inventory = player:FindFirstChild("Inventory")
    if inventory then
        for _, item in pairs(inventory:GetChildren()) do
            if not table.find(ownedCars, item.Name) then
                table.insert(ownedCars, item.Name)
                print("Owned in Inventory: " .. item.Name)
            end
        end
    else
        print("No Inventory folder found")
    end
    
    -- Check other possible locations
    local possibleFolders = {"Cars", "Garage", "OwnedVehicles", "PlayerData", "Data"}
    
    for _, folderName in pairs(possibleFolders) do
        local folder = player:FindFirstChild(folderName)
        if folder then
            for _, item in pairs(folder:GetChildren()) do
                if not table.find(ownedCars, item.Name) then
                    table.insert(ownedCars, item.Name)
                    print("Owned in " .. folderName .. ": " .. item.Name)
                end
            end
        end
    end
    
    if #ownedCars == 0 then
        print("⚠️ No owned cars detected!")
        print("You need to buy at least one car first.")
        print("Try buying the cheapest car in the store.")
        return false
    end
    
    print("\nFound " .. #ownedCars .. " owned cars")
    
    -- FIND DUPLICATION/PURCHASE EVENTS
    local carEvents = {}
    
    -- Search ReplicatedStorage for car-related events
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("car") or name:find("vehicle") or 
               name:find("buy") or name:find("purchase") or
               name:find("add") or name:find("spawn") then
                
                table.insert(carEvents, {
                    Object = obj,
                    Name = obj.Name,
                    Type = obj.ClassName
                })
                print("Found event: " .. obj.Name .. " (" .. obj.ClassName .. ")")
            end
        end
    end
    
    -- Also check common folders
    local checkFolders = {
        ReplicatedStorage:FindFirstChild("Events"),
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("Functions")
    }
    
    for _, folder in pairs(checkFolders) do
        if folder then
            for _, obj in pairs(folder:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    if not table.find(carEvents, obj) then
                        table.insert(carEvents, {
                            Object = obj,
                            Name = obj.Name,
                            Type = obj.ClassName
                        })
                        print("Found in folder: " .. obj.Name)
                    end
                end
            end
        end
    end
    
    if #carEvents == 0 then
        print("❌ No car-related events found!")
        return false
    end
    
    print("\n🔄 Attempting duplication...")
    
    -- Try to duplicate each car
    for _, carName in pairs(ownedCars) do
        print("\nTrying to duplicate: " .. carName)
        
        for _, eventData in pairs(carEvents) do
            local event = eventData.Object
            
            -- Different ways to request duplication
            local attempts = {
                {carName},  -- Just the car name
                {player, carName},  -- With player
                {carName, 0},  -- With price 0
                {carName, 1},  -- With price 1
                {"buy", carName},  -- As buy command
                {"duplicate", carName},  -- As duplicate command
                {vehicle = carName}  -- As table
            }
            
            for i, args in pairs(attempts) do
                local success, errorMsg = pcall(function()
                    if eventData.Type == "RemoteEvent" then
                        event:FireServer(unpack(args))
                    else
                        event:InvokeServer(unpack(args))
                    end
                end)
                
                if success then
                    print("✅ Attempt " .. i .. " via " .. eventData.Name)
                else
                    -- Show helpful errors
                    if errorMsg and not errorMsg:find("Not connected") then
                        print("❌ Error: " .. tostring(errorMsg):sub(1, 50))
                    end
                end
                
                task.wait(0.1)
            end
        end
    end
    
    -- Wait and check results
    print("\n⏳ Waiting for server response...")
    task.wait(2)
    
    -- Check current car count
    local finalCarCount = 0
    for _, folderName in pairs(possibleFolders) do
        local folder = player:FindFirstChild(folderName)
        if folder then
            finalCarCount = finalCarCount + #folder:GetChildren()
        end
    end
    
    if inventory then
        finalCarCount = finalCarCount + #inventory:GetChildren()
    end
    
    print("\n" .. string.rep("=", 40))
    print("RESULT:")
    print("Cars before: " .. #ownedCars)
    print("Cars after: " .. finalCarCount)
    
    if finalCarCount > #ownedCars then
        print("🎉 SUCCESS! Gained " .. (finalCarCount - #ownedCars) .. " cars!")
    else
        print("❌ No new cars gained")
        print("Server may be rejecting requests.")
    end
    
    print(string.rep("=", 40))
    
    return finalCarCount > #ownedCars
end

-- Run the function
task.wait(2)
duplicateCars()

print("\n💡 TIP: If this doesn't work, you need to:")
print("1. Buy at least one car first")
print("2. Look at the game's actual event names")
print("3. Check server scripts for correct arguments")
