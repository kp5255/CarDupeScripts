-- 🚗 PURE CAR DUPLICATION ONLY
-- Game ID: ffad7ea30d080c4aa1d7bf4b2f5f4381

print("🚗 CAR DUPLICATION EXPLOIT")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()

local function duplicateCars()
    print("\n🎯 Starting CAR DUPLICATION...")
    
    -- FIND WHAT CARS YOU CURRENTLY OWN
    local ownedCars = {}
    
    -- Check common data locations
    local dataFolders = {
        player:WaitForChild("Inventory"),
        player:FindFirstChild("Cars"),
        player:FindFirstChild("Garage"),
        player:FindFirstChild("OwnedVehicles"),
        player:FindFirstChild("PlayerData")
    }
    
    for _, folder in pairs(dataFolders) do
        if folder then
            for _, item in pairs(folder:GetChildren()) do
                if not table.find(ownedCars, item.Name) then
                    table.insert(ownedCars, item.Name)
                    print("Owned: " .. item.Name)
                end
            end
        end
    end
    
    if #ownedCars == 0 then
        print("⚠️ No owned cars found!")
        print("Buy at least ONE car legitimately first!")
        return false
    end
    
    -- FIND DUPLICATION EVENTS
    print("\n🔍 Finding duplication events...")
    
    local dupEvents = {}
    
    -- Look for duplication/save/load events
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("duplicate") or name:find("copy") or 
               name:find("clone") or name:find("save") or
               name:find("load") or name:find("data") then
                
                table.insert(dupEvents, {
                    Object = obj,
                    Name = obj.Name,
                    Type = obj.ClassName
                })
                print("Found dup event: " .. obj.Name)
            end
        end
    end
    
    -- Also check for car spawning events
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("spawn") and name:find("car") then
                if not table.find(dupEvents, obj) then
                    table.insert(dupEvents, {
                        Object = obj,
                        Name = obj.Name,
                        Type = obj.ClassName
                    })
                    print("Found spawn event: " .. obj.Name)
                end
            end
        end
    end
    
    if #dupEvents == 0 then
        print("❌ No duplication events found!")
        print("Trying purchase events instead...")
        
        -- Try purchase events as fallback
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                if name:find("buy") or name:find("purchase") then
                    table.insert(dupEvents, {
                        Object = obj,
                        Name = obj.Name,
                        Type = obj.ClassName
                    })
                    print("Using purchase event: " .. obj.Name)
                end
            end
        end
    end
    
    if #dupEvents == 0 then
        print("❌ NO EVENTS FOUND!")
        return false
    end
    
    -- ATTEMPT DUPLICATION
    print("\n🔄 Attempting to duplicate " .. #ownedCars .. " cars...")
    local successfulAttempts = 0
    
    for _, carName in pairs(ownedCars) do
        print("\nDuplicating: " .. carName)
        
        for _, eventData in pairs(dupEvents) do
            local event = eventData.Object
            
            -- Try different duplication methods
            local methods = {
                -- Simple duplication
                {args = {carName}},
                
                -- With player reference
                {args = {player, carName}},
                
                -- Duplicate command
                {args = {"duplicate", carName}},
                
                -- Save/load method
                {args = {"save", carName}},
                {args = {"load", carName}},
                
                -- Spawn method
                {args = {"spawn", carName}},
                
                -- Multiple copies
                {args = {carName, 5}},
                
                -- Free purchase
                {args = {carName, 0}},
                {args = {carName, false}},
                
                -- Data table method
                {args = {{Vehicle = carName, Action = "Duplicate"}}}
            }
            
            for methodIndex, method in pairs(methods) do
                local success, errorMsg = pcall(function()
                    if eventData.Type == "RemoteEvent" then
                        event:FireServer(unpack(method.args))
                    else
                        event:InvokeServer(unpack(method.args))
                    end
                end)
                
                if success then
                    print("✅ Attempt " .. methodIndex .. " via " .. eventData.Name)
                    successfulAttempts = successfulAttempts + 1
                    
                    -- Wait briefly to avoid rate limits
                    task.wait(0.05)
                end
            end
        end
    end
    
    -- CHECK RESULTS
    print("\n" .. string.rep("=", 50))
    print("RESULTS:")
    print(string.rep("=", 50))
    print("Attempts made: " .. successfulAttempts)
    print("Cars tried: " .. #ownedCars)
    
    -- Count cars after duplication
    task.wait(2)
    
    local finalCarCount = 0
    for _, folder in pairs(dataFolders) do
        if folder then
            finalCarCount = finalCarCount + #folder:GetChildren()
        end
    end
    
    local initialCount = #ownedCars
    local newCount = finalCarCount
    
    print("Cars before: " .. initialCount)
    print("Cars after: " .. newCount)
    
    if newCount > initialCount then
        print("\n🎉 SUCCESS! Duplicated " .. (newCount - initialCount) .. " cars!")
        print("Check your garage/inventory!")
        return true
    else
        print("\n❌ No new cars detected")
        print("Possible reasons:")
        print("1. Server rejects duplication attempts")
        print("2. Wrong event/arguments")
        print("3. Need to buy cars first")
        return false
    end
end

-- AUTO-RUN
task.wait(3)
duplicateCars()

print("\n" .. string.rep("=", 50))
print("CAR DUPLICATION COMPLETE")
print(string.rep("=", 50))
