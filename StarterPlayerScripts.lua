-- 💀 LIFE OR DEATH - FINAL ATTEMPT
-- No errors, just raw analysis

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

print("💀 LIFE OR DEATH MODE")
print("=" .. string.rep("=", 60))

-- First, let's see what SessionAddItem REALLY is
local target = RS.Remotes.Services.TradingServiceRemotes.SessionAddItem
print("🔎 OBJECT ANALYSIS:")
print("Name:", target.Name)
print("ClassName:", target.ClassName)
print("Full Path:", target:GetFullName())

-- Get ALL children to see what we're dealing with
print("\n📋 CHILDREN OF TradingServiceRemotes:")
for _, child in pairs(RS.Remotes.Services.TradingServiceRemotes:GetChildren()) do
    print("  • " .. child.Name .. " (" .. child.ClassName .. ")")
end

-- If it's a RemoteEvent, not RemoteFunction
if target.ClassName == "RemoteEvent" then
    print("\n🎯 IT'S A REMOTEEVENT, NOT REMOTEFUNCTION!")
    print("We need to use FireServer, not InvokeServer")
    
    -- Hook the FireServer instead
    local originalFire = target.FireServer
    local capturedArgs = nil
    
    target.FireServer = function(self, ...)
        local args = {...}
        capturedArgs = args
        
        print("\n🔥 CAPTURED FIRE!")
        print("Args:", #args)
        
        for i, arg in ipairs(args) do
            print("  Arg " .. i .. " type:", type(arg))
            if type(arg) == "table" then
                print("  Table contents:")
                for k, v in pairs(arg) do
                    print("    " .. tostring(k) .. " = " .. tostring(v))
                end
            else
                print("  Value:", arg)
            end
        end
        
        return originalFire(self, ...)
    end
    
    print("\n✅ HOOKED FireServer!")
    print("NOW: Click AstonMartin12 in your inventory")
    print("I will capture EXACT format")
    
    for i = 1, 30 do
        task.wait(1)
        if capturedArgs then break end
        if i % 5 == 0 then print("Waiting... " .. i .. "/30") end
    end
    
    if capturedArgs then
        print("\n🎉 CAPTURE SUCCESS!")
        
        -- Create working bot
        local workingData = capturedArgs[1]
        print("WORKING DATA:", workingData)
        
        -- SIMPLE WORKING BOT
        local botCode = [[
-- 🎯 WORKING TRADE BOT
local remote = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes.SessionAddItem
local data = ]] .. (type(workingData) == "table" and 
    "{" .. 
    (function()
        local parts = {}
        for k, v in pairs(workingData) do
            if type(v) == "string" then
                table.insert(parts, tostring(k) .. ' = "' .. tostring(v) .. '"')
            else
                table.insert(parts, tostring(k) .. ' = ' .. tostring(v))
            end
        end
        return table.concat(parts, ", ")
    end)() .. 
    "}" or 
    '"' .. tostring(workingData) .. '"') .. [[

function addCar()
    local success = pcall(function()
        remote:FireServer(data)
    end)
    
    if success then
        print("✅ Added!")
        return true
    else
        print("❌ Failed")
        return false
    end
end

function addMultiple(count)
    print("📦 Adding " .. count)
    for i = 1, count do
        print("[" .. i .. "]...")
        addCar()
        wait(0.5)
    end
    print("✅ Done")
end

-- Global functions
getgenv().add1 = function() addMultiple(1) end
getgenv().add5 = function() addMultiple(5) end
getgenv().add10 = function() addMultiple(10) end
getgenv().add100 = function() addMultiple(100) end

print("🎮 READY: add1(), add5(), add10(), add100()")
]]
        
        print("\n" .. string.rep("=", 60))
        print("📋 BOT CODE:")
        print(string.rep("=", 60))
        print(botCode)
        print(string.rep("=", 60))
        
        -- Execute it
        loadstring(botCode)()
        
    else
        print("\n❌ NO CLICK CAPTURED")
        
        -- Try to find what works by brute force
        print("\n💥 BRUTE FORCE ATTEMPT...")
        
        local testFormats = {
            "AstonMartin12",
            "Car-AstonMartin12",
            {Id = "AstonMartin12"},
            {ID = "AstonMartin12"},
            {id = "AstonMartin12"},
            {ItemId = "AstonMartin12"},
            {itemId = "AstonMartin12"},
            {Name = "AstonMartin12"},
            {name = "AstonMartin12"},
            {Car = "AstonMartin12"},
            {car = "AstonMartin12"},
            {Vehicle = "AstonMartin12"},
            {vehicle = "AstonMartin12"}
        }
        
        for i, data in ipairs(testFormats) do
            print("\n🧪 Test " .. i .. "...")
            local success = pcall(function()
                target:FireServer(data)
            end)
            
            if success then
                print("✅ SUCCESS WITH:", data)
                
                -- Create bot with this data
                loadstring([[
                    local remote = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes.SessionAddItem
                    local data = ]] .. (type(data) == "table" and 
                        "{" .. 
                        (function()
                            local parts = {}
                            for k, v in pairs(data) do
                                table.insert(parts, tostring(k) .. ' = "' .. tostring(v) .. '"')
                            end
                            return table.concat(parts, ", ")
                        end)() .. 
                        "}" or 
                        '"' .. tostring(data) .. '"') .. [[
                    
                    for i = 1, 10 do
                        print("Adding " .. i)
                        remote:FireServer(data)
                        wait(0.5)
                    end
                    print("✅ Added 10 cars!")
                ]])()
                break
            else
                print("❌ Failed")
            end
            
            task.wait(0.3)
        end
    end
    
elseif target.ClassName == "RemoteFunction" then
    print("\n❓ It IS RemoteFunction but InvokeServer fails?")
    print("Checking metatable...")
    
    -- Try to call it differently
    local success, result = pcall(function()
        return target.InvokeServer(target, "AstonMartin12")
    end)
    
    if success then
        print("✅ Works with target.InvokeServer(target, ...)")
        print("Result:", result)
    else
        print("❌ Still fails:", result)
    end
    
else
    print("\n❓ It's a " .. target.ClassName)
    print("Trying to use it...")
    
    -- Try everything
    local methods = {"InvokeServer", "FireServer", "Invoke", "Fire", "Call"}
    for _, method in ipairs(methods) do
        if target[method] then
            print("Has method:", method)
            local success = pcall(function()
                target[method](target, "AstonMartin12")
            end)
            if success then
                print("✅ " .. method .. " works!")
                break
            end
        end
    end
end

-- LAST RESORT: MONITOR NETWORK TRAFFIC
print("\n📡 NETWORK TRAFFIC MONITOR")
print("Looking for ANY remote calls when clicking...")

-- Get ALL remotes
local allRemotes = {}
for _, child in pairs(RS:GetDescendants()) do
    if child.ClassName == "RemoteEvent" or child.ClassName == "RemoteFunction" then
        table.insert(allRemotes, child)
    end
end

print("Found " .. #allRemotes .. " total remotes")

-- Hook them ALL
local capturedCalls = {}
for _, remote in ipairs(allRemotes) do
    if remote.ClassName == "RemoteEvent" then
        local original = remote.FireServer
        remote.FireServer = function(self, ...)
            table.insert(capturedCalls, {
                remote = remote.Name,
                path = remote:GetFullName(),
                args = {...},
                type = "FireServer"
            })
            return original(self, ...)
        end
    elseif remote.ClassName == "RemoteFunction" then
        local original = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            table.insert(capturedCalls, {
                remote = remote.Name,
                path = remote:GetFullName(),
                args = {...},
                type = "InvokeServer"
            })
            return original(self, ...)
        end
    end
end

print("\n🎯 ALL REMOTES HOOKED!")
print("NOW: Click AstonMartin12 ONE TIME")
print("I will see EVERYTHING that happens")

local initialCount = #capturedCalls

for i = 1, 20 do
    task.wait(1)
    if #capturedCalls > initialCount then
        print("\n🎉 NETWORK TRAFFIC CAPTURED!")
        for j = initialCount + 1, #capturedCalls do
            local call = capturedCalls[j]
            print("\n📞 Call " .. (j - initialCount) .. ":")
            print("  Remote:", call.remote)
            print("  Path:", call.path)
            print("  Type:", call.type)
            
            if #call.args > 0 then
                local arg = call.args[1]
                if type(arg) == "table" then
                    print("  Data (table):")
                    for k, v in pairs(arg) do
                        print("    " .. tostring(k) .. " = " .. tostring(v))
                    end
                else
                    print("  Data:", arg)
                end
            end
        end
        break
    end
    if i % 5 == 0 then print("Listening... " .. i .. "/20") end
end

print("\n" .. string.rep("=", 60))
print("💀 MISSION REPORT")
print(string.rep("=", 60))

if #capturedCalls == initialCount then
    print("❌ NO NETWORK TRAFFIC DETECTED")
    print("This means:")
    print("1. Click doesn't trigger any remote")
    print("2. Trading might be disabled")
    print("3. UI might be frozen")
    print("4. Need to be IN A TRADE")
else
    print("✅ NETWORK ACTIVITY DETECTED")
    print("Check above for captured calls")
end

print(string.rep("=", 60))
