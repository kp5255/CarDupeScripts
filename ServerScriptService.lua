print("💥 COMPLETE EXPLOIT SUITE")
print("=" .. string.rep("=", 60))

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local ExploitSuite = {
    Successes = 0,
    Attempts = 0
}

function ExploitSuite:TryAllExploits()
    print("🚀 Starting exploit attempts...")
    
    -- Get initial car count
    local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
    local initialCars = carService.GetOwnedCars:InvokeServer()
    local initialCount = #initialCars
    print("Initial cars: " .. initialCount)
    
    -- EXPLOIT 1: SetOwnedState
    self:AttemptExploit1(carService)
    
    -- EXPLOIT 2: ClaimGiveawayCar
    self:AttemptExploit2(carService)
    
    -- EXPLOIT 3: Admin bypass
    self:AttemptExploit3(carService)
    
    -- EXPLOIT 4: Spawn remote
    self:AttemptExploit4(carService)
    
    -- Check results
    task.wait(5)
    local finalCars = carService.GetOwnedCars:InvokeServer()
    local finalCount = #finalCars
    
    print("\n" .. string.rep("=", 60))
    print("📊 EXPLOIT RESULTS:")
    print("Attempts made: " .. self.Attempts)
    print("Successes: " .. self.Successes)
    print("Initial cars: " .. initialCount)
    print("Final cars: " .. finalCount)
    print("Cars added: " .. (finalCount - initialCount))
    
    if finalCount > initialCount then
        print("🎉 SUCCESS! Exploits worked!")
    else
        print("❌ No cars added")
        print("💡 Try different car names/IDs")
    end
end

function ExploitSuite:AttemptExploit1(carService)
    self.Attempts = self.Attempts + 1
    print("\n🎯 EXPLOIT 1: SetOwnedState")
    
    local module = ReplicatedStorage.Components.UI.Menus.Inventory.CarShopScrollList
    if not module then return false end
    
    local success, moduleTable = pcall(require, module)
    if success and moduleTable and moduleTable.SetOwnedState then
        -- Try to set cars as owned
        local carsToOwn = {"Fion", "Bolide", "Chiron"}
        
        for _, carName in ipairs(carsToOwn) do
            local callSuccess = pcall(function()
                moduleTable.SetOwnedState(carName, true)
                return true
            end)
            
            if callSuccess then
                print("✅ Set " .. carName .. " as owned")
                return true
            end
        end
    end
    return false
end

function ExploitSuite:AttemptExploit2(carService)
    self.Attempts = self.Attempts + 1
    print("\n🎯 EXPLOIT 2: ClaimGiveawayCar")
    
    local remote = ReplicatedStorage.Remotes.Services.FreeCarGiveawayServiceRemotes
    if not remote then return false end
    
    remote = remote:FindFirstChild("ClaimGiveawayCar")
    if not remote then return false end
    
    -- Try to claim a car
    local carData = {
        Name = "Exploit Car",
        Id = "exploit-" .. os.time(),
        Class = 3,
        RewardType = "Car"
    }
    
    local success = pcall(function()
        remote:FireServer(carData)
        return true
    end)
    
    if success then
        print("✅ Giveaway claim attempted")
        return true
    end
    return false
end

function ExploitSuite:AttemptExploit3(carService)
    self.Attempts = self.Attempts + 1
    print("\n🎯 EXPLOIT 3: Admin Bypass")
    
    local adminRemote = ReplicatedStorage.Remotes:FindFirstChild("IsLegacyAdmin")
    if not adminRemote then return false end
    
    -- Try to get admin status
    local success, isAdmin = pcall(function()
        return adminRemote:InvokeServer()
    end)
    
    if success and isAdmin then
        print("✅ You have admin access!")
        
        -- Try admin give car command
        local giveRemote = ReplicatedStorage.Remotes:FindFirstChild("GiveCar")
        if giveRemote then
            local giveSuccess = pcall(function()
                if giveRemote:IsA("RemoteEvent") then
                    giveRemote:FireServer(player, "Fion")
                else
                    giveRemote:InvokeServer(player, "Fion")
                end
                return true
            end)
            
            if giveSuccess then
                print("✅ Admin give car command sent")
                return true
            end
        end
    end
    return false
end

function ExploitSuite:AttemptExploit4(carService)
    self.Attempts = self.Attempts + 1
    print("\n🎯 EXPLOIT 4: Spawn Remote")
    
    local spawnRemote = ReplicatedStorage.Remotes:FindFirstChild("Spawn")
    if not spawnRemote then return false end
    
    -- Try different spawn commands
    local commands = {"Fion", "Car", "givecar", "vehicle"}
    
    for _, cmd in ipairs(commands) do
        local success = pcall(function()
            spawnRemote:FireServer(cmd)
            return true
        end)
        
        if success then
            print("✅ Spawn command sent: " .. cmd)
            return true
        end
    end
    return false
end

-- Run the exploit suite
ExploitSuite:TryAllExploits()
