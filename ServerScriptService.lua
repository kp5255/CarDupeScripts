print("🚗 SMART CAR INJECTION SYSTEM")
print("=" .. string.rep("=", 60))

-- Get services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get player and car service
local player = Players.LocalPlayer
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes

-- Get the OnCarsAdded remote
local onCarsAdded = carService:FindFirstChild("OnCarsAdded")

if not onCarsAdded then
    print("❌ OnCarsAdded remote not found!")
    return
end

print("✅ OnCarsAdded remote found!")

-- Get current cars
local currentCars = carService.GetOwnedCars:InvokeServer()
local initialCount = #currentCars
print("📊 Initial car count: " .. initialCount)

if #currentCars == 0 then
    print("❌ No cars to use as template")
    return
end

-- Use first car as template
local templateCar = currentCars[1]
print("\n📋 Template car:")
print("Name: " .. tostring(templateCar.Name or templateCar.name))
print("ID: " .. tostring(templateCar.Id or templateCar.id))

-- Try different approaches
print("\n🧪 Testing injection methods...")

local methods = {
    {
        name = "Method 1: Clone with new ID",
        func = function()
            local newCar = {}
            
            -- Copy all fields from template
            for key, value in pairs(templateCar) do
                if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
                    newCar[key] = value
                end
            end
            
            -- Change ID to make it unique
            local newId = "inj-" .. tostring(os.time())
            newCar.Id = newId
            newCar.id = newId
            
            -- Change name
            if newCar.Name then
                newCar.Name = newCar.Name .. " [INJ]"
            end
            
            return newCar
        end
    },
    {
        name = "Method 2: Simple car data",
        func = function()
            return {
                Id = "simple-" .. tostring(os.time()),
                Name = "Injected Car",
                Class = 1,
                DriveType = "RWD",
                Owner = player.Name,
                Purchased = true,
                Timestamp = os.time()
            }
        end
    },
    {
        name = "Method 3: Match template exactly",
        func = function()
            local newCar = {}
            
            -- Copy only essential fields
            local essentialFields = {"Id", "id", "Name", "name", "Class", "class", "DriveType", "driveType"}
            
            for _, field in pairs(essentialFields) do
                if templateCar[field] then
                    newCar[field] = templateCar[field]
                end
            end
            
            -- Make ID unique
            newCar.Id = "copy-" .. tostring(os.time())
            newCar.id = newCar.Id
            
            return newCar
        end
    }
}

-- Test each method
local successfulMethods = {}

for i, method in ipairs(methods) do
    print("\n" .. string.rep("-", 40))
    print("🔄 Testing: " .. method.name)
    
    -- Create car data
    local carData = method.func()
    
    -- Try to send to server
    local success, errorMsg = pcall(function()
        onCarsAdded:FireServer({carData})
        return true
    end)
    
    if success then
        print("✅ Remote fired successfully")
        
        -- Check if car was added
        task.wait(2)
        local newCars = carService.GetOwnedCars:InvokeServer()
        local newCount = #newCars
        
        if newCount > initialCount then
            table.insert(successfulMethods, method.name)
            initialCount = newCount
            print("🎉 SUCCESS! New car count: " .. newCount)
        else
            print("⚠️ Car count unchanged")
        end
    else
        print("❌ Error: " .. errorMsg)
    end
    
    task.wait(1)
end

-- Show results
print("\n" .. string.rep("=", 60))
print("📊 INJECTION RESULTS:")
print("Methods tested: " .. #methods)
print("Successful methods: " .. #successfulMethods)
print("Final car count: " .. initialCount)

if #successfulMethods > 0 then
    print("\n🎉 SUCCESS! Working methods:")
    for i, method in ipairs(successfulMethods) do
        print(i .. ". " .. method)
    end
else
    print("\n❌ No methods worked")
    print("💡 The server validates car ownership")
end
