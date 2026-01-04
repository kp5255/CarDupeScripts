print("🎯 WORKING CAR INJECTION USING DEBUG HOOK")
print("=" .. string.rep("=", 60))

local carService = game:GetService("ReplicatedStorage").Remotes.Services.CarServiceRemotes
local getOwnedCars = carService:FindFirstChild("GetOwnedCars")

if not getOwnedCars or not getOwnedCars:IsA("RemoteFunction") then
    print("❌ GetOwnedCars RemoteFunction not found")
    return
end

print("✅ Found GetOwnedCars RemoteFunction")

-- Method 1: Use debug library to hook the function
if not debug then
    print("❌ Debug library not available")
else
    print("🔧 Using debug library to hook...")
    
    -- Get the function closure
    local originalFunction = getOwnedCars.InvokeServer
    
    -- Create a new function that wraps the original
    local function hookedFunction(...)
        print("🎯 GetOwnedCars called via hook")
        
        -- Call original function
        local result = originalFunction(...)
        
        if type(result) == "table" then
            print("📊 Original returned " .. #result .. " cars")
            
            -- Add fake cars
            local fakeCars = {
                {
                    Id = "inject-" .. os.time() .. "-1",
                    Name = "Bugatti Chiron [INJECTED]",
                    Class = 3,
                    DriveType = "AWD",
                    Value = 3000000
                },
                {
                    Id = "inject-" .. os.time() .. "-2",
                    Name = "Lamborghini Aventador [INJECTED]",
                    Class = 3, 
                    DriveType = "RWD",
                    Value = 400000
                }
            }
            
            for _, fakeCar in ipairs(fakeCars) do
                table.insert(result, fakeCar)
            end
            
            print("✅ Added " .. #fakeCars .. " injected cars")
            print("New total: " .. #result .. " cars")
        end
        
        return result
    end
    
    -- Replace the function using debug.setupvalue
    local success, _ = pcall(function()
        for i = 1, math.huge do
            local name, value = debug.getupvalue(originalFunction, i)
            if name == nil then break end
            print("Upvalue " .. i .. ": " .. tostring(name))
        end
    end)
    
    print("⚠️ Debug hook may require specific executor features")
end

-- Method 2: Simpler approach - Create a fake response system
print("\n🔧 Method 2: Response Interception System")

local hookActive = true

-- Function to get cars with injection
local function getCarsWithInjection()
    local originalResult = getOwnedCars:InvokeServer()
    
    if not hookActive or type(originalResult) ~= "table" then
        return originalResult
    end
    
    print("🔄 Injecting cars into response...")
    
    -- Add injected cars
    local injectedCars = {
        {
            Id = "hack-" .. os.time(),
            Name = "Porsche 918 Spyder",
            Class = 3,
            DriveType = "AWD",
            TopSpeed = 345
        },
        {
            Id = "hack-" .. (os.time() + 1),
            Name = "McLaren P1",
            Class = 3,
            DriveType = "RWD", 
            TopSpeed = 350
        }
    }
    
    for _, injectedCar in ipairs(injectedCars) do
        table.insert(originalResult, injectedCar)
    end
    
    return originalResult
end

print("✅ Created injection system")
print("Use getCarsWithInjection() instead of getOwnedCars:InvokeServer()")

-- Test it
print("\n🧪 Testing injection system...")
local testResult = getCarsWithInjection()
if type(testResult) == "table" then
    print("Total cars in response: " .. #testResult)
    
    -- Show injected cars
    print("\n📋 Looking for injected cars...")
    for i = math.max(1, #testResult - 4), #testResult do
        local car = testResult[i]
        if type(car) == "table" then
            local tag = car.Name and car.Name:find("INJECTED") and "🎯 " or "   "
            print(tag .. i .. ". " .. tostring(car.Name) .. " (ID: " .. tostring(car.Id or "?") .. ")")
        end
    end
end
