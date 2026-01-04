print("🚀 COMPLETE CAR INJECTION SUITE")
print("=" .. string.rep("=", 60))

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local InjectionSuite = {
    CarService = ReplicatedStorage.Remotes.Services.CarServiceRemotes,
    MethodsTried = 0,
    Successes = 0
}

function InjectionSuite:GetCarTemplate()
    local cars = self.CarService.GetOwnedCars:InvokeServer()
    if #cars > 0 then
        return cars[1]
    end
    return nil
end

function InjectionSuite:CreateInjectedCar()
    local template = self:GetCarTemplate()
    if not template then return nil end
    
    local injectedCar = {}
    
    -- Copy all simple values
    for key, value in pairs(template) do
        local valueType = type(value)
        if valueType == "string" or valueType == "number" or valueType == "boolean" then
            injectedCar[key] = value
        end
    end
    
    -- Make unique
    local uniqueId = "inj-" .. tostring(os.time()) .. "-" .. tostring(math.random(1000, 9999))
    injectedCar.Id = uniqueId
    injectedCar.id = uniqueId
    injectedCar.uuid = uniqueId
    
    -- Mark as injected
    if injectedCar.Name then
        injectedCar.Name = injectedCar.Name .. " ✨"
    end
    
    return injectedCar
end

function InjectionSuite:TryMethod1()  -- RemoteEvent method
    self.MethodsTried = self.MethodsTried + 1
    print("\n🎯 Method 1: RemoteEvent injection")
    
    local injectedCar = self:CreateInjectedCar()
    if not injectedCar then return false end
    
    -- Look for OnCarsAdded or similar
    local targetRemote = self.CarService:FindFirstChild("OnCarsAdded")
    if not targetRemote then
        targetRemote = ReplicatedStorage.Remotes:FindFirstChild("UpdateCarPack")
    end
    
    if targetRemote and targetRemote:IsA("RemoteEvent") then
        print("✅ Found RemoteEvent: " .. targetRemote:GetFullName())
        
        local success, result = pcall(function()
            targetRemote:FireServer(injectedCar)
            return true
        end)
        
        return success
    end
    
    return false
end

function InjectionSuite:TryMethod2()  -- RemoteFunction method
    self.MethodsTried = self.MethodsTried + 1
    print("\n🎯 Method 2: RemoteFunction injection")
    
    local injectedCar = self:CreateInjectedCar()
    if not injectedCar then return false end
    
    -- Look for AddCar or similar functions
    local function findAddFunction(folder)
        for _, item in pairs(folder:GetChildren()) do
            if item:IsA("RemoteFunction") then
                local name = item.Name:lower()
                if name:find("add") or name:find("give") or name:find("create") then
                    return item
                end
            elseif item:IsA("Folder") then
                local found = findAddFunction(item)
                if found then return found end
            end
        end
        return nil
    end
    
    local targetFunction = findAddFunction(ReplicatedStorage)
    if targetFunction then
        print("✅ Found RemoteFunction: " .. targetFunction:GetFullName())
        
        local success, result = pcall(function()
            return targetFunction:InvokeServer(injectedCar)
        end)
        
        return success
    end
    
    return false
end

function InjectionSuite:TryMethod3()  -- Data manipulation
    self.MethodsTried = self.MethodsTried + 1
    print("\n🎯 Method 3: Direct data manipulation")
    
    -- Try to get the raw car data table
    local cars = self.CarService.GetOwnedCars:InvokeServer()
    
    if type(cars) == "table" then
        -- Create a hook for when this data is accessed
        local originalCars = cars
        local injectedCar = self:CreateInjectedCar()
        
        if injectedCar then
            -- Try to modify the table directly
            table.insert(cars, injectedCar)
            print("✅ Direct table modification attempted")
            return true
        end
    end
    
    return false
end

function InjectionSuite:TryMethod4()  -- Server module injection
    self.MethodsTried = self.MethodsTried + 1
    print("\n🎯 Method 4: Server module access")
    
    -- Look for server-side modules we can access
    local serverScriptService = game:GetService("ServerScriptService")
    local serverStorage = game:GetService("ServerStorage")
    
    -- Try to find car service modules
    local potentialModules = {}
    
    for _, service in pairs({serverScriptService, serverStorage, ReplicatedStorage}) do
        for _, item in pairs(service:GetDescendants()) do
            if item:IsA("ModuleScript") and item.Name:find("Car") then
                table.insert(potentialModules, item)
            end
        end
    end
    
    if #potentialModules > 0 then
        print("✅ Found " .. #potentialModules .. " car modules")
        
        -- Try to require and use the first one
        local module = potentialModules[1]
        local success, moduleTable = pcall(function()
            return require(module)
        end)
        
        if success and type(moduleTable) == "table" then
            print("✅ Module loaded: " .. module:GetFullName())
            
            -- Look for add/give functions
            for funcName, func in pairs(moduleTable) do
                if type(func) == "function" and funcName:lower():find("add") then
                    print("   Found function: " .. funcName)
                    
                    -- Try to call it
                    local injectedCar = self:CreateInjectedCar()
                    if injectedCar then
                        local callSuccess, result = pcall(function()
                            return func(player, injectedCar)
                        end)
                        
                        if callSuccess then
                            print("   Function call successful")
                            return true
                        end
                    end
                end
            end
        end
    end
    
    return false
end

function InjectionSuite:Run()
    print("🚀 Starting comprehensive injection...")
    
    local initialCount = #self.CarService.GetOwnedCars:InvokeServer()
    print("Initial car count: " .. initialCount)
    
    -- Try all methods
    local methods = {
        self.TryMethod1,
        self.TryMethod2, 
        self.TryMethod3,
        self.TryMethod4
    }
    
    for i, method in ipairs(methods) do
        print("\n" .. string.rep("-", 40))
        print("🔄 ATTEMPT " .. i .. " OF " .. #methods)
        
        local success = method(self)
        
        if success then
            self.Successes = self.Successes + 1
            print("✅ Method executed")
            
            -- Wait and check
            task.wait(3)
            local newCount = #self.CarService.GetOwnedCars:InvokeServer()
            
            if newCount > initialCount then
                print("🎉 CAR ADDED! New count: " .. newCount)
                initialCount = newCount
            else
                print("⚠️ Car count unchanged")
            end
        else
            print("❌ Method failed")
        end
        
        task.wait(2) -- Delay between methods
    end
    
    -- Final results
    print("\n" .. string.rep("=", 60))
    print("📊 INJECTION SUITE COMPLETE")
    print("Methods attempted: " .. self.MethodsTried)
    print("Methods successful: " .. self.Successes)
    
    local finalCount = #self.CarService.GetOwnedCars:InvokeServer()
    print("Initial cars: " .. initialCount)
    print("Final cars: " .. finalCount)
    print("Cars added: " .. (finalCount - initialCount))
    
    if finalCount > initialCount then
        print("\n🎉 SUCCESS! Cars were injected!")
    else
        print("\n❌ No cars were added")
        print("💡 The server has strong validation")
    end
end

-- Run the suite
InjectionSuite:Run()
