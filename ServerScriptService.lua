-- 🎯 FIND REAL DUPLICATION REMOTE
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 FINDING REAL DUPLICATION REMOTE")
print("=" .. string.rep("=", 50))

-- Get car service
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

-- Get your cars
local cars = carService.GetOwnedCars:InvokeServer()
print("✅ Loaded " .. #cars .. " cars")

if #cars == 0 then
    print("❌ No cars found")
    return
end

-- Display first car
local testCar = cars[1]
print("🚗 Test car: " .. tostring(testCar.Name or testCar.name or "Car 1"))

-- ===== TEST ALL REMOTES =====
print("\n🔍 TESTING ALL REMOTES...")
print("=" .. string.rep("=", 50))

local testedRemotes = 0
local workingRemotes = {}

-- Find and test all RemoteEvents
for _, obj in pairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        testedRemotes = testedRemotes + 1
        
        -- Skip ClaimGiveawayCar (we know it works but is one-time)
        if obj.Name == "ClaimGiveawayCar" then
            print("📝 " .. obj.Name .. " - (Known giveaway remote)")
            table.insert(workingRemotes, {Remote = obj, Reason = "Giveaway"})
        else
            -- Test this remote with car data
            local success, result = pcall(function()
                obj:FireServer(testCar)
                return true
            end)
            
            if success then
                print("✅ " .. obj.Name .. " - ACCEPTS car data!")
                table.insert(workingRemotes, {
                    Remote = obj,
                    Path = obj:GetFullName(),
                    Reason = "Accepts car table"
                })
            end
        end
    end
end

print("\n📊 RESULTS:")
print("   Tested " .. testedRemotes .. " remotes")
print("   Found " .. #workingRemotes .. " that accept car data")

-- ===== TEST COMMON DUPLICATION REMOTES =====
print("\n🎯 TESTING SPECIFIC DUPLICATION REMOTES:")
print("=" .. string.rep("=", 50))

-- Common CDT duplication remote names
local possibleDupeRemotes = {
    "DuplicateCar",
    "CopyCar", 
    "CloneCar",
    "DuplicateVehicle",
    "CopyVehicle",
    "CloneVehicle",
    "GetDuplicate",
    "RequestDuplicate",
    "SpawnDuplicate",
    "CreateDuplicate",
    
    -- Purchase/claim remotes
    "PurchaseCar",
    "BuyCar",
    "GetCar",
    "RedeemCar",
    "ClaimCar",
    
    -- Update remotes
    "UpdateCar",
    "AddCar",
    "GiveCar",
    "TransferCar"
}

for _, remoteName in pairs(possibleDupeRemotes) do
    -- Search for this remote
    local foundRemote = nil
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name == remoteName then
            foundRemote = obj
            break
        end
    end
    
    if foundRemote then
        print("🔍 Found: " .. remoteName)
        
        -- Test different data formats
        local formats = {
            testCar,
            {testCar},
            {player, testCar},
            {player.UserId, testCar},
            testCar.Name or testCar.name,
            testCar.Id or testCar.id
        }
        
        for i, format in ipairs(formats) do
            local success = pcall(function()
                foundRemote:FireServer(format)
                return true
            end)
            
            if success then
                print("   ✅ Format " .. i .. " works!")
                
                -- Test rapid fire with this format
                print("   ⚡ Testing rapid fire...")
                for j = 1, 10 do
                    pcall(function() foundRemote:FireServer(format) end)
                    task.wait(0.05)
                end
                print("   🔥 Sent 10 rapid requests")
                break
            end
        end
    end
end

-- ===== CHECK FOR FUNCTION REMOTES =====
print("\n🔧 CHECKING FUNCTION REMOTES (InvokeServer):")
print("=" .. string.rep("=", 50))

local functionRemotes = {}

for _, obj in pairs(game:GetDescendants()) do
    if obj:IsA("RemoteFunction") then
        local name = obj.Name:lower()
        if name:find("duplicate") or name:find("copy") or 
           name:find("clone") or name:find("getcar") then
            print("🔍 Found function: " .. obj.Name)
            
            -- Try to invoke it
            local success, result = pcall(function()
                return obj:InvokeServer(testCar)
            end)
            
            if success then
                print("   ✅ Function returns: " .. tostring(result))
                table.insert(functionRemotes, obj)
            end
        end
    end
end

-- ===== MANUAL TEST COMMANDS =====
print("\n🎮 MANUAL TEST COMMANDS:")
print("=" .. string.rep("=", 50))

-- Show working remotes for manual testing
if #workingRemotes > 0 then
    print("📋 Working remotes to test manually:")
    for i, remoteInfo in ipairs(workingRemotes) do
        print(i .. ". " .. remoteInfo.Remote.Name .. " - " .. remoteInfo.Reason)
        
        -- Create manual test command
        print('   Command: remote:FireServer(car)')
        print('   Path: ' .. remoteInfo.Path)
        print()
    end
end

-- ===== CHECK CAR STRUCTURE =====
print("\n🔬 CAR DATA STRUCTURE:")
print("=" .. string.rep("=", 50))

if #cars > 0 then
    local car = cars[1]
    print("First car fields:")
    
    local fieldCount = 0
    for fieldName, fieldValue in pairs(car) do
        fieldCount = fieldCount + 1
        if fieldCount <= 15 then
            local valueType = type(fieldValue)
            local displayValue = tostring(fieldValue)
            
            if valueType == "string" and #displayValue > 20 then
                displayValue = displayValue:sub(1, 20) .. "..."
            end
            
            print("   " .. fieldName .. " = " .. displayValue .. " (" .. valueType .. ")")
        end
    end
    
    if fieldCount > 15 then
        print("   ... and " .. (fieldCount - 15) .. " more fields")
    end
end

print("\n💡 WHAT TO DO NEXT:")
print("1. Look for 'DuplicateCar' or 'CopyCar' remotes")
print("2. Check ReplicatedStorage.Remotes folder")
print("3. Try the working remotes listed above")
print("4. Use different data formats (car table, car name, car ID)")
