-- 🔄 TRADE DUPING SCRIPT - NETWORK LAG METHOD
print("🔄 TRADE DUPING SCRIPT")
print("=" .. string.rep("=", 50))

-- Get services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Player
local Player = Players.LocalPlayer

-- Find trading folder
local tradingFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")

-- Find trading remotes
local sessionAddItem = tradingFolder:WaitForChild("SessionAddItem")  -- Add item to trade
local sessionSetConfirmation = tradingFolder:WaitForChild("SessionSetConfirmation")  -- Confirm trade
local sessionCancel = tradingFolder:WaitForChild("SessionCancel")  -- Cancel trade

print("✅ Found trading remotes")
print("  • SessionAddItem")
print("  • SessionSetConfirmation") 
print("  • SessionCancel")

-- NETWORK LAG ENGINE
local NetworkLag = {
    enabled = false,
    delay = 0.5,  -- Default delay in seconds
    originalMethods = {},
    packets = {}
}

-- Method 1: Packet delay system
function NetworkLag.enablePacketDelay(delay)
    delay = delay or 0.5
    NetworkLag.delay = delay
    NetworkLag.enabled = true
    
    print("⏳ Enabling network delay: " .. delay .. " seconds")
    
    -- Store original remote methods
    for _, remote in pairs(tradingFolder:GetChildren()) do
        if remote:IsA("RemoteFunction") then
            NetworkLag.originalMethods[remote] = remote.InvokeServer
            
            -- Replace with delayed version
            remote.InvokeServer = function(self, ...)
                local args = {...}
                local remoteName = remote.Name
                
                print("📦 Packet delayed for: " .. remoteName)
                
                -- Store packet
                local packetId = #NetworkLag.packets + 1
                NetworkLag.packets[packetId] = {
                    remote = remote,
                    args = args,
                    timestamp = tick(),
                    executed = false
                }
                
                -- Execute after delay
                spawn(function()
                    wait(NetworkLag.delay)
                    
                    if NetworkLag.packets[packetId] and not NetworkLag.packets[packetId].executed then
                        print("🚀 Executing delayed packet: " .. remoteName)
                        NetworkLag.packets[packetId].executed = true
                        return NetworkLag.originalMethods[remote](self, unpack(args))
                    end
                end)
                
                -- Return fake success immediately
                return true
            end
        elseif remote:IsA("RemoteEvent") then
            NetworkLag.originalMethods[remote] = remote.FireServer
            
            remote.FireServer = function(self, ...)
                local args = {...}
                local remoteName = remote.Name
                
                print("📦 Event delayed for: " .. remoteName)
                
                -- Store event
                local eventId = #NetworkLag.packets + 1
                NetworkLag.packets[eventId] = {
                    remote = remote,
                    args = args,
                    timestamp = tick(),
                    executed = false
                }
                
                -- Fire after delay
                spawn(function()
                    wait(NetworkLag.delay)
                    
                    if NetworkLag.packets[eventId] and not NetworkLag.packets[eventId].executed then
                        print("🚀 Firing delayed event: " .. remoteName)
                        NetworkLag.packets[eventId].executed = true
                        NetworkLag.originalMethods[remote](self, unpack(args))
                    end
                end)
                
                return true
            end
        end
    end
    
    return true
end

-- Method 2: Network throttle (slows ALL network)
function NetworkLag.enableNetworkThrottle()
    print("🐌 Enabling network throttle...")
    
    -- Hook __namecall to intercept ALL network calls
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        
        -- Only delay network-related calls
        if method == "InvokeServer" or method == "FireServer" then
            if NetworkLag.enabled then
                print("⏳ Throttling network call: " .. method)
                wait(NetworkLag.delay)
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    return true
end

-- Method 3: Packet duplication
function NetworkLag.enablePacketDuplication()
    print("🔄 Enabling packet duplication...")
    
    -- Duplicate every trade packet
    for _, remote in pairs(tradingFolder:GetChildren()) do
        if remote:IsA("RemoteFunction") then
            local original = remote.InvokeServer
            
            remote.InvokeServer = function(self, ...)
                local args = {...}
                local result = original(self, unpack(args))
                
                -- Send duplicate packet
                spawn(function()
                    wait(NetworkLag.delay / 2)  -- Half delay for duplicate
                    print("📦 Sending duplicate packet")
                    original(self, unpack(args))
                end)
                
                return result
            end
        elseif remote:IsA("RemoteEvent") then
            local original = remote.FireServer
            
            remote.FireServer = function(self, ...)
                local args = {...}
                original(self, unpack(args))
                
                -- Fire duplicate event
                spawn(function()
                    wait(NetworkLag.delay / 2)
                    print("📦 Sending duplicate event")
                    original(self, unpack(args))
                end)
            end
        end
    end
    
    return true
end

-- TRADE DUPING FUNCTION
local TradeDupe = {}

-- Step 1: Add brainrots to trade
function TradeDupe.addBrainrots(amount)
    amount = amount or 1000
    
    print("➕ Adding " .. amount .. " brainrots to trade...")
    
    -- Try different data formats
    local formats = {
        {Id = "Brainrots", Type = "Currency", Amount = amount},
        {ItemId = "Brainrots", Quantity = amount},
        {Currency = "Brainrots", Value = amount},
        "Brainrots:" .. amount
    }
    
    for _, data in pairs(formats) do
        local success, result = pcall(function()
            return sessionAddItem:InvokeServer(data)
        end)
        
        if success then
            print("✅ Added brainrots with format: " .. type(data))
            print("   Result: " .. tostring(result))
            return true
        end
    end
    
    return false
end

-- Step 2: Enable lag and confirm trade
function TradeDupe.executeDupe(amount, delay)
    amount = amount or 1000
    delay = delay or 1.0
    
    print("\n" .. string.rep("🔄", 40))
    print("EXECUTING TRADE DUPE...")
    print(string.rep("🔄", 40))
    
    -- Enable network lag
    NetworkLag.enablePacketDelay(delay)
    
    -- Add brainrots
    TradeDupe.addBrainrots(amount)
    
    -- Wait a bit
    wait(0.5)
    
    -- Confirm trade (this will be delayed)
    print("⏳ Confirming trade (will be delayed)...")
    local success, result = pcall(function()
        return sessionSetConfirmation:InvokeServer(true)
    end)
    
    if success then
        print("✅ Trade confirmation sent (delayed)")
    else
        print("❌ Failed: " .. tostring(result))
    end
    
    -- On alt account, accept immediately
    print("\n⚠️ ON ALT ACCOUNT:")
    print("1. Accept the trade IMMEDIATELY")
    print("2. Both accounts will receive brainrots")
    print("3. Due to network delay, trade happens twice")
    
    return success
end

-- Step 3: Auto dupe with timing
function TradeDupe.autoDupe(amount, delay)
    amount = amount or 1000
    delay = delay or 1.5
    
    print("\n🤖 AUTO DUPING PROCESS")
    print("=" .. string.rep("=", 30))
    
    -- Step 1: Add item
    print("Step 1: Adding brainrots...")
    TradeDupe.addBrainrots(amount)
    wait(0.5)
    
    -- Step 2: Enable lag
    print("Step 2: Enabling network lag...")
    NetworkLag.enablePacketDelay(delay)
    
    -- Step 3: Confirm (delayed)
    print("Step 3: Sending delayed confirmation...")
    sessionSetConfirmation:InvokeServer(true)
    
    -- Step 4: Instructions
    print("\n" .. string.rep("📋", 40))
    print("DUPE INSTRUCTIONS:")
    print(string.rep("📋", 40))
    print("MAIN ACCOUNT (this one):")
    print("• Already sent delayed confirmation")
    print("• Wait " .. delay .. " seconds")
    print("\nALT ACCOUNT:")
    print("1. Accept trade NOW")
    print("2. Trade completes immediately for alt")
    print("3. Delayed confirmation arrives later")
    print("4. Trade happens again for main account")
    print("5. BOTH get brainrots!")
    
    return true
end

-- CREATE DUPING UI
local function createDupeUI()
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Remove old
    local old = PlayerGui:FindFirstChild("DupeUI")
    if old then old:Destroy() end
    
    -- Create GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DupeUI"
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🔄 TRADE DUPING SYSTEM"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(60, 40, 80)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Ready to dupe brainrots..."
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 55)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 150, 255)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    
    -- Amount input
    local amountBox = Instance.new("TextBox")
    amountBox.PlaceholderText = "Brainrot amount"
    amountBox.Text = "1000"
    amountBox.Size = UDim2.new(1, -40, 0, 35)
    amountBox.Position = UDim2.new(0, 20, 0, 90)
    amountBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    amountBox.TextColor3 = Color3.new(1, 1, 1)
    
    -- Delay input
    local delayBox = Instance.new("TextBox")
    delayBox.PlaceholderText = "Network delay (seconds)"
    delayBox.Text = "1.5"
    delayBox.Size = UDim2.new(1, -40, 0, 35)
    delayBox.Position = UDim2.new(0, 20, 0, 135)
    delayBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    delayBox.TextColor3 = Color3.new(1, 1, 1)
    
    -- Button creator
    local function createButton(text, y, color, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(1, -40, 0, 40)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        
        btn.MouseButton1Click:Connect(function()
            status.Text = "Running: " .. text
            local amount = tonumber(amountBox.Text) or 1000
            local delay = tonumber(delayBox.Text) or 1.5
            
            spawn(function()
                pcall(function()
                    callback(amount, delay)
                end)
            end)
        end)
        
        return btn
    end
    
    -- Buttons
    local addBtn = createButton("➕ ADD BRAINROTS TO TRADE", 180, Color3.fromRGB(70, 160, 70), function(amount)
        TradeDupe.addBrainrots(amount)
        status.Text = "Added " .. amount .. " brainrots"
    end)
    
    local lagBtn = createButton("⏳ ENABLE NETWORK LAG", 230, Color3.fromRGB(60, 120, 200), function(amount, delay)
        NetworkLag.enablePacketDelay(delay)
        status.Text = "Network lag: " .. delay .. "s"
    end)
    
    local dupeBtn = createButton("🔄 EXECUTE DUPE", 280, Color3.fromRGB(200, 60, 60), function(amount, delay)
        TradeDupe.executeDupe(amount, delay)
        status.Text = "Dupe executing..."
    end)
    
    local autoBtn = createButton("🤖 AUTO DUPE PROCESS", 330, Color3.fromRGB(180, 80, 200), function(amount, delay)
        TradeDupe.autoDupe(amount, delay)
        status.Text = "Auto dupe started"
    end)
    
    -- Instructions
    local instructions = Instance.new("TextLabel")
    instructions.Text = "INSTRUCTIONS:\n1. Start trade with alt account\n2. Add brainrots\n3. Enable lag\n4. Execute dupe\n5. Accept on alt immediately"
    instructions.Size = UDim2.new(1, -20, 0, 80)
    instructions.Position = UDim2.new(0, 10, 1, -90)
    instructions.BackgroundTransparency = 1
    instructions.TextColor3 = Color3.fromRGB(150, 200, 255)
    instructions.Font = Enum.Font.Gotham
    instructions.TextSize = 11
    instructions.TextWrapped = true
    
    -- Close
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Assemble
    title.Parent = mainFrame
    status.Parent = mainFrame
    amountBox.Parent = mainFrame
    delayBox.Parent = mainFrame
    addBtn.Parent = mainFrame
    lagBtn.Parent = mainFrame
    dupeBtn.Parent = mainFrame
    autoBtn.Parent = mainFrame
    instructions.Parent = mainFrame
    closeBtn.Parent = title
    mainFrame.Parent = screenGui
    screenGui.Parent = PlayerGui
    
    return screenGui
end

-- EXPORT FUNCTIONS
getgenv().TradeDupe = TradeDupe
getgenv().NetworkLag = NetworkLag

-- MAIN EXECUTION
print("\n" .. string.rep("🔄", 40))
print("TRADE DUPING SYSTEM READY")
print(string.rep("🔄", 40))

-- Create UI
wait(1)
createDupeUI()

-- Instructions
print("\n📋 HOW TO DUPE BRAINROTS:")
print("1. Start a trade with your ALT account")
print("2. Use the UI to add brainrots to trade")
print("3. Enable network lag (1-2 seconds)")
print("4. Execute the dupe")
print("5. On ALT account: Accept trade IMMEDIATELY")
print("6. Due to network delay, trade happens twice")
print("7. Both accounts keep the brainrots!")

print("\n⚙️ AVAILABLE COMMANDS:")
print("TradeDupe.addBrainrots(1000)")
print("TradeDupe.executeDupe(1000, 1.5)")
print("TradeDupe.autoDupe(1000, 1.5)")
print("NetworkLag.enablePacketDelay(1.5)")

print("\n⚠️ IMPORTANT:")
print("• Works best with 1-2 second delay")
print("• Alt account must accept immediately")
print("• Test with small amounts first")
print("• May not work with strong anti-cheat")

print("\n🎯 UI appears in CENTER of screen")
