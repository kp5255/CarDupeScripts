-- AGGRESSIVE DUPE METHODS (Last Resort)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get trading system
local TradingRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")

-- Find ALL trading remotes
print("🔍 Finding all trading remotes...")
local allRemotes = {}
for _, remote in pairs(TradingRemotes:GetChildren()) do
    allRemotes[remote.Name] = remote
    print("Found: " .. remote.Name .. " (" .. remote.ClassName .. ")")
end

-- METHOD 1: MASS PACKET FLOOD
local function massPacketFlood()
    print("🌊 MASS PACKET FLOOD")
    
    local SessionSetConfirmation = allRemotes["SessionSetConfirmation"]
    if not SessionSetConfirmation then return end
    
    -- Flood the server with conflicting packets
    for i = 1, 100 do
        spawn(function()
            -- Accept
            pcall(function()
                SessionSetConfirmation:InvokeServer(true)
            end)
        end)
        
        spawn(function()
            -- Cancel  
            pcall(function()
                SessionSetConfirmation:InvokeServer(false)
            end)
        end)
        
        wait(0.01)
    end
    
    print("✅ Flooded with 200 packets!")
end

-- METHOD 2: REMOTE FUNCTION EXPLOIT
local function remoteFunctionExploit()
    print("💥 REMOTE FUNCTION EXPLOIT")
    
    -- Try to break RemoteFunctions by calling them wrong
    for name, remote in pairs(allRemotes) do
        if remote:IsA("RemoteFunction") then
            print("Attacking: " .. name)
            
            -- Send invalid data
            for i = 1, 20 do
                spawn(function()
                    pcall(function()
                        -- Send garbage data
                        remote:InvokeServer(
                            math.huge,  -- Very large number
                            -math.huge, -- Very small number
                            nil,        -- nil value
                            {},         -- Empty table
                            function() end, -- Function
                            coroutine.create(function() end), -- Coroutine
                            "A" .. string.rep("B", 10000) -- Huge string
                        )
                    end)
                end)
                wait(0.05)
            end
        end
    end
end

-- METHOD 3: SESSION HIJACK
local function sessionHijack()
    print("🎭 SESSION HIJACK")
    
    -- Try to manipulate session data
    local SessionAddItem = allRemotes["SessionAddItem"]
    local SessionRemoveItem = allRemotes["SessionRemoveItem"]
    
    if SessionAddItem then
        -- Try to add invalid items
        local fakeItems = {
            "INVALID_ITEM",
            nil,
            999999,
            "",
            "CAR_DUPE_GLITCH",
            string.rep("A", 1000)
        }
        
        for _, fakeItem in pairs(fakeItems) do
            pcall(function()
                SessionAddItem:InvokeServer(fakeItem)
            end)
            wait(0.1)
        end
    end
end

-- METHOD 4: NETWORK LAG EXPLOIT
local function networkLagExploit()
    print("🐌 NETWORK LAG EXPLOIT")
    
    local SessionSetConfirmation = allRemotes["SessionSetConfirmation"]
    if not SessionSetConfirmation then return end
    
    -- Create artificial lag by spamming
    -- then send critical packet at last moment
    
    -- First, spam garbage
    for i = 1, 50 do
        spawn(function()
            pcall(function()
                SessionSetConfirmation:InvokeServer("LAG_PACKET_" .. i)
            end)
        end)
    end
    
    -- Wait for countdown to be low
    local waited = 0
    while waited < 45 do  -- Wait 4.5 seconds
        wait(0.1)
        waited = waited + 1
    end
    
    -- Send critical cancel at perfect time
    print("🚨 SENDING CRITICAL CANCEL!")
    for i = 1, 10 do
        pcall(function()
            SessionSetConfirmation:InvokeServer(false)
        end)
        wait(0.01)
    end
end

-- METHOD 5: DATA CORRUPTION
local function dataCorruption()
    print("💀 DATA CORRUPTION")
    
    -- Try to corrupt player data directly
    local player = LocalPlayer
    
    -- Common data stores
    local dataStores = {
        player:FindFirstChild("Data"),
        player:FindFirstChild("Inventory"),
        player:FindFirstChild("Cars"),
        player:FindFirstChild("Vehicles"),
        ReplicatedStorage:FindFirstChild("PlayerData")
    }
    
    for _, store in pairs(dataStores) do
        if store then
            print("Found data store: " .. store.Name)
            
            -- Try to duplicate items in data
            for _, item in pairs(store:GetDescendants()) do
                if item:IsA("StringValue") or item:IsA("NumberValue") then
                    if item.Name:lower():find("car") or item.Value then
                        print("Attempting to modify: " .. item.Name)
                        -- Try to set value
                        pcall(function()
                            item.Value = item.Value .. "_DUPE"
                        end)
                    end
                end
            end
        end
    end
end

-- METHOD 6: DIRECT INVENTORY MODIFICATION
local function directInventoryMod()
    print("🎯 DIRECT INVENTORY MOD")
    
    -- Try to find where cars are stored
    local function searchForCars(parent, depth)
        if depth > 3 then return end
        
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("Folder") and child.Name:lower():find("car") then
                print("Found car folder: " .. child:GetFullName())
                -- Try to clone it
                local clone = child:Clone()
                clone.Name = child.Name .. "_DUPLICATE"
                clone.Parent = child.Parent
                print("Cloned car folder!")
            end
            
            if child:IsA("Configuration") or child:IsA("Model") then
                if child.Name:lower():find("subaru") or child.Name:lower():find("car") then
                    print("Found car object: " .. child.Name)
                end
            end
            
            searchForCars(child, depth + 1)
        end
    end
    
    searchForCars(game, 0)
end

-- METHOD 7: TRADE ROLLBACK
local function tradeRollback()
    print("↩️ TRADE ROLLBACK")
    
    -- Accept trade
    local SessionSetConfirmation = allRemotes["SessionSetConfirmation"]
    if SessionSetConfirmation then
        pcall(function()
            SessionSetConfirmation:InvokeServer(true)
        end)
    end
    
    -- Wait 4.8 seconds
    wait(4.8)
    
    -- Try to trigger a server error/crash
    -- by calling non-existent methods
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        -- If it's a trading remote, cause chaos
        if tostring(self):find("Trading") then
            -- Randomly return errors
            if math.random(1, 3) == 1 then
                error("Trade rollback error")
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
    
    print("✅ Rollback chaos activated!")
end

-- CREATE UI
local gui = Instance.new("ScreenGui")
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 250)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(1, 0, 0)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "⚠️ AGGRESSIVE METHODS"
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = frame

-- Methods
local methods = {
    {"🌊 Mass Packet Flood", massPacketFlood},
    {"💥 Remote Function Exploit", remoteFunctionExploit},
    {"🎭 Session Hijack", sessionHijack},
    {"🐌 Network Lag", networkLagExploit},
    {"💀 Data Corruption", dataCorruption},
    {"🎯 Direct Inventory", directInventoryMod},
    {"↩️ Trade Rollback", tradeRollback}
}

for i, method in ipairs(methods) do
    local btn = Instance.new("TextButton")
    btn.Text = method[1]
    btn.Size = UDim2.new(0.9, 0, 0, 25)
    btn.Position = UDim2.new(0.05, 0, 0.1 + (i * 0.12), 0)
    btn.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 11
    btn.Parent = frame
    btn.MouseButton1Click:Connect(method[2])
end

print("\n" .. string.rep("=", 60))
print("⚠️  AGGRESSIVE DUPE METHODS  ⚠️")
print(string.rep("=", 60))
print("WARNING: These methods are more likely to:")
print("• Get you BANNED")
print("• Crash the game")
print("• Not work at all")
print("• Get you kicked")
print(string.rep("=", 60))
print("Try in order:")
print("1. Mass Packet Flood (overwhelm server)")
print("2. Network Lag (timing attack)")
print("3. Data Corruption (direct modify)")
print(string.rep("=", 60))
