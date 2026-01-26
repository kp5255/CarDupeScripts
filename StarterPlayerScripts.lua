-- 🧠 BRAINROTS FREE GIVEAWAY
print("🧠 BRAINROTS FREE GIVEAWAY")
print("=" .. string.rep("=", 50))

-- Wait for game
wait(1)

-- Get player
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Brainrot Commands to Try
local brainrotCommands = {
    -- Direct commands
    "!brainrots 9999",
    "/brainrots 9999",
    "!give brainrots 9999",
    "/give brainrots 9999",
    "!add brainrots 9999",
    "/add brainrots 9999",
    "!free brainrots",
    "/free brainrots",
    
    -- Admin commands
    "!admin brainrots 9999",
    "/admin brainrots 9999",
    "!mod brainrots 9999",
    "/mod brainrots 9999",
    
    -- Event commands
    "!cmdr reward brainrots",
    "/cmdr reward brainrots",
    "!event brainrots",
    "/event brainrots",
    
    -- Currency commands
    "!currency brainrots 9999",
    "/currency brainrots 9999",
    "!coins 9999",
    "/coins 9999",
    "!money 9999",
    "/money 9999",
    
    -- Cheat codes
    "!cheat brainrots",
    "/cheat brainrots",
    "!hack brainrots",
    "/hack brainrots",
    
    -- Special codes
    "!promocode FREEBRAIN",
    "/promocode FREEBRAIN",
    "!code BRAINROTS2024",
    "/code BRAINROTS2024",
    "!rewardcode BRAIN",
    "/rewardcode BRAIN",
    
    -- Game-specific
    "!tsunami brainrots",
    "/tsunami brainrots",
    "!escape brainrots",
    "/escape brainrots",
    "!wave brainrots",
    "/wave brainrots"
}

-- Create Brainrots Giveaway UI
local function createBrainrotUI()
    -- Remove old
    local old = PlayerGui:FindFirstChild("BrainrotUI")
    if old then old:Destroy() end
    
    -- Create GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BrainrotUI"
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🧠 FREE BRAINROTS"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(60, 30, 80)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Ready to get free Brainrots!"
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 55)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 150, 255)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    
    -- Amount input
    local amountBox = Instance.new("TextBox")
    amountBox.PlaceholderText = "Enter amount (default: 9999)"
    amountBox.Text = "9999"
    amountBox.Size = UDim2.new(1, -40, 0, 35)
    amountBox.Position = UDim2.new(0, 20, 0, 90)
    amountBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    amountBox.TextColor3 = Color3.new(1, 1, 1)
    amountBox.Font = Enum.Font.Gotham
    amountBox.TextSize = 12
    
    -- Command list
    local commandList = Instance.new("ScrollingFrame")
    commandList.Size = UDim2.new(1, -40, 0, 180)
    commandList.Position = UDim2.new(0, 20, 0, 135)
    commandList.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    commandList.ScrollBarThickness = 4
    
    -- Add commands to list
    for i, cmd in pairs(brainrotCommands) do
        local cmdButton = Instance.new("TextButton")
        cmdButton.Text = cmd
        cmdButton.Size = UDim2.new(1, 0, 0, 30)
        cmdButton.Position = UDim2.new(0, 0, 0, (i-1)*35)
        cmdButton.BackgroundColor3 = Color3.fromHSV(i/#brainrotCommands, 0.7, 0.3)
        cmdButton.TextColor3 = Color3.new(1, 1, 1)
        cmdButton.Font = Enum.Font.Gotham
        cmdButton.TextSize = 11
        
        cmdButton.MouseButton1Click:Connect(function()
            local amount = amountBox.Text
            local commandWithAmount = cmd:gsub("9999", amount)
            status.Text = "Sending: " .. commandWithAmount
            pcall(function()
                Player:Chat(commandWithAmount)
            end)
        end)
        
        cmdButton.Parent = commandList
    end
    
    -- Quick buttons
    local function createQuickButton(text, y, color, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(1, -40, 0, 35)
        btn.Position = UDim2.new(0, 20, 0, y)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        
        btn.MouseButton1Click:Connect(function()
            status.Text = "Running: " .. text
            pcall(callback)
        end)
        
        return btn
    end
    
    -- Auto-try all button
    local autoAllBtn = createQuickButton("🚀 AUTO-TRY ALL COMMANDS", 325, Color3.fromRGB(200, 60, 60), function()
        local amount = amountBox.Text
        status.Text = "Trying all commands..."
        
        for _, cmd in pairs(brainrotCommands) do
            local commandWithAmount = cmd:gsub("9999", amount)
            pcall(function()
                Player:Chat(commandWithAmount)
                print("Tried: " .. commandWithAmount)
            end)
            wait(0.3)
        end
        
        status.Text = "All commands tried!"
    end)
    
    -- Find currency system button
    local findSystemBtn = createQuickButton("🔍 FIND CURRENCY SYSTEM", 370, Color3.fromRGB(60, 120, 200), function()
        status.Text = "Scanning for currency..."
        
        -- Look for brainrots in game
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local found = 0
            
            for _, obj in pairs(rs:GetDescendants()) do
                local name = obj.Name:lower()
                if name:find("brainrot") or name:find("currency") or name:find("coin") then
                    print("Found: " .. obj:GetFullName())
                    found = found + 1
                end
            end
            
            status.Text = "Found " .. found .. " currency items"
        end)
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Assemble UI
    title.Parent = mainFrame
    status.Parent = mainFrame
    amountBox.Parent = mainFrame
    commandList.Parent = mainFrame
    autoAllBtn.Parent = mainFrame
    findSystemBtn.Parent = mainFrame
    closeBtn.Parent = title
    mainFrame.Parent = screenGui
    screenGui.Parent = PlayerGui
    
    return screenGui
end

-- Create REMOTE FINDER for Brainrots
local function findBrainrotRemotes()
    print("\n🔍 SEARCHING FOR BRAINROT REMOTES...")
    
    local remotes = {}
    
    -- Check ReplicatedStorage
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        
        for _, child in pairs(rs:GetDescendants()) do
            if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
                local name = child.Name:lower()
                
                if name:find("brainrot") or 
                   name:find("currency") or 
                   name:find("coin") or 
                   name:find("reward") or
                   name:find("give") or
                   name:find("add") then
                    
                    table.insert(remotes, child)
                    print("✅ Found: " .. child:GetFullName())
                end
            end
        end
    end)
    
    return remotes
end

-- TEST REMOTES WITH DIFFERENT DATA
local function testRemotes(remotes)
    print("\n🧪 TESTING BRAINROT REMOTES...")
    
    local testData = {
        "Brainrots",
        "brainrots",
        9999,
        10000,
        5000,
        {Amount = 9999, Currency = "Brainrots"},
        {Brainrots = 9999},
        {Coins = 9999},
        {Currency = "Brainrots", Amount = 9999},
        {Item = "Brainrots", Quantity = 9999}
    }
    
    for _, remote in pairs(remotes) do
        print("\nTesting remote: " .. remote.Name)
        
        for _, data in pairs(testData) do
            local success, result = pcall(function()
                if remote:IsA("RemoteFunction") then
                    return remote:InvokeServer(data)
                else
                    remote:FireServer(data)
                    return "Event fired"
                end
            end)
            
            if success then
                print("  ✅ Success with: " .. tostring(data))
                if result then
                    print("    Result: " .. tostring(result))
                end
            end
            wait(0.1)
        end
    end
end

-- Check player stats for Brainrots
local function checkPlayerBrainrots()
    print("\n📊 CHECKING PLAYER BRAINROTS...")
    
    -- Check leaderstats
    pcall(function()
        local leaderstats = Player:FindFirstChild("leaderstats")
        if leaderstats then
            for _, stat in pairs(leaderstats:GetChildren()) do
                if stat.Name:lower():find("brainrot") or 
                   stat.Name:lower():find("coin") or 
                   stat.Name:lower():find("currency") then
                    print("🎯 Found currency stat: " .. stat.Name)
                    print("  Value: " .. tostring(stat.Value))
                end
            end
        end
    end)
    
    -- Check other places
    pcall(function()
        for _, child in pairs(Player:GetChildren()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                if child.Name:lower():find("brainrot") then
                    print("🎯 Found brainrot value: " .. child.Name)
                    print("  Value: " .. tostring(child.Value))
                end
            end
        end
    end)
end

-- CREATE BRAINROT GIVER FUNCTION
local brainrotGiver = {
    -- Try all chat commands
    tryCommands = function(amount)
        amount = amount or 9999
        
        print("Trying all brainrot commands...")
        for _, cmd in pairs(brainrotCommands) do
            local command = cmd:gsub("9999", tostring(amount))
            pcall(function()
                Player:Chat(command)
                print("Sent: " .. command)
            end)
            wait(0.3)
        end
    end,
    
    -- Find and test remotes
    tryRemotes = function()
        local remotes = findBrainrotRemotes()
        if #remotes > 0 then
            testRemotes(remotes)
        else
            print("No brainrot remotes found")
        end
    end,
    
    -- Check current brainrots
    check = function()
        checkPlayerBrainrots()
    end,
    
    -- Auto-give brainrots
    autoGive = function(amount)
        amount = amount or 9999
        
        -- Try commands
        brainrotGiver.tryCommands(amount)
        
        -- Try remotes
        wait(1)
        brainrotGiver.tryRemotes()
        
        -- Check result
        wait(1)
        brainrotGiver.check()
    end,
    
    -- Show UI
    ui = createBrainrotUI
}

-- Export to global
getgenv().BrainrotGiver = brainrotGiver

-- MAIN EXECUTION
print("\n" .. string.rep("🧠", 40))
print("STARTING BRAINROT GIVEAWAY...")
print(string.rep("🧠", 40))

-- Create UI
wait(1)
createBrainrotUI()

-- Initial scan
wait(1)
local remotes = findBrainrotRemotes()
print("Found " .. #remotes .. " brainrot remotes")

-- Check current brainrots
wait(0.5)
checkPlayerBrainrots()

-- Auto-try some commands
print("\n🚀 AUTO-TRYING SOME COMMANDS...")
for i = 1, 5 do
    local cmd = brainrotCommands[i]
    if cmd then
        pcall(function()
            Player:Chat(cmd)
            print("Tried: " .. cmd)
        end)
        wait(0.3)
    end
end

-- FINAL MESSAGE
print("\n" .. string.rep("=", 60))
print("🧠 BRAINROT GIVEAWAY READY!")
print(string.rep("=", 60))

print("\n📋 AVAILABLE COMMANDS:")
print("BrainrotGiver.tryCommands(5000)")
print("BrainrotGiver.tryRemotes()")
print("BrainrotGiver.check()")
print("BrainrotGiver.autoGive(9999)")
print("BrainrotGiver.ui() - Show UI")

print("\n🎯 HOW TO GET BRAINROTS:")
print("1. Use the UI in center of screen")
print("2. Click any command button to try it")
print("3. Click 'AUTO-TRY ALL' to try everything")
print("4. Check if any worked with 'FIND SYSTEM'")
print("5. Try different amounts")

print("\n💡 TIPS:")
print("• Some commands might require special access")
print("• Try during events or in specific areas")
print("• Watch for response messages in chat")
print("• Check if your brainrots increase")

print("\n⚠️ NOTE:")
print("Not all commands may work. The game might")
print("have protection against free currency.")
