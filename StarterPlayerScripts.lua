-- 🔍 COMMAND CENTER CMDER - BRAINROTS EXPLORER
print("🔍 COMMAND CENTER CMDER EXPLORER")
print("=" .. string.rep("=", 50))

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TextChatService = game:GetService("TextChatService")
local HttpService = game:GetService("HttpService")

-- PLAYER
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- SCAN FOR COMMAND INTERFACES
print("\n🔍 SCANNING COMMAND CENTER...")

-- Look for command terminals in the Command Center
local commandCenter = Workspace:FindFirstChild("CommandCenter") or 
                     Workspace:FindFirstChild("CMD") or
                     Workspace:FindFirstChild("CMDER") or
                     Workspace:FindFirstChild("ControlCenter")

-- COMMAND PATTERNS FOR BRAINROTS
local brainrotCommands = {
    -- Common cheat commands
    "/give brainrots 1000",
    "/add brainrots 9999",
    "/free brainrots",
    "/reward brainrots",
    "/currency add brainrots",
    "/coins add",
    
    -- Event commands
    "/complete cmdr",
    "/unlock all",
    "/finish event",
    "/claim all rewards",
    
    -- Admin commands
    "/admin add brainrots",
    "/mod add currency",
    "/dev give rewards"
}

-- HIDDEN COMMAND TRIGGERS
print("\n🎯 SEARCHING FOR COMMAND TRIGGERS...")

-- Look for interactive parts that might accept commands
local function scanForCommandTriggers()
    local triggers = {}
    
    -- Search in Command Center
    if commandCenter then
        print("✅ Found Command Center: " .. commandCenter.Name)
        
        for _, obj in pairs(commandCenter:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("terminal") or 
               obj.Name:lower():find("console") or 
               obj.Name:lower():find("computer") or
               obj.Name:lower():find("panel")) then
                table.insert(triggers, obj)
                print("  Found terminal: " .. obj.Name)
            end
        end
    end
    
    -- Search entire workspace
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("cmd") then
            if not table.find(triggers, obj) then
                table.insert(triggers, obj)
                print("  Found CMD object: " .. obj.Name)
            end
        end
    end
    
    return triggers
end

-- TEST COMMANDS ON TERMINALS
local function testCommandsOnTerminal(terminal)
    print("\n🧪 Testing commands on: " .. terminal.Name)
    
    -- First, try to interact with it
    pcall(function()
        local prompt = terminal:FindFirstChildWhichIsA("ProximityPrompt")
        if prompt then
            -- Activate the terminal
            prompt:InputHoldBegin()
            wait(0.5)
            prompt:InputHoldEnd()
            print("  ✅ Activated terminal")
        end
    end)
    
    -- Check for scripts that might handle commands
    for _, script in pairs(terminal:GetDescendants()) do
        if script:IsA("Script") or script:IsA("LocalScript") then
            print("  Found script: " .. script.Name)
            
            -- Try to read script source for command patterns
            pcall(function()
                local source = script.Source
                if source and #source > 0 then
                    -- Look for command patterns in source
                    if source:lower():find("brainrot") or 
                       source:lower():find("currency") or 
                       source:lower():find("reward") then
                        print("    🔍 Script mentions rewards!")
                    end
                    
                    -- Look for command handlers
                    if source:lower():find("command") or 
                       source:lower():find("chat") or 
                       source:lower():find("input") then
                        print("    ⌨️  Script handles commands!")
                    end
                end
            end)
        end
    end
end

-- SCAN REMOTES FOR REWARD SYSTEMS
print("\n🔍 SCANNING REWARD SYSTEMS...")

local function scanForRewardSystems()
    local rewardRemotes = {}
    
    -- Look in ReplicatedStorage
    local function searchFolder(folder, path)
        if not folder then return end
        
        for _, obj in pairs(folder:GetChildren()) do
            local fullPath = path .. "." .. obj.Name
            
            -- Check for reward-related names
            local nameLower = obj.Name:lower()
            if nameLower:find("brainrot") or 
               nameLower:find("reward") or 
               nameLower:find("currency") or 
               nameLower:find("coin") or
               nameLower:find("give") or
               nameLower:find("add") then
                
                if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                    table.insert(rewardRemotes, {obj = obj, path = fullPath})
                    print("  🎯 Found reward remote: " .. obj.Name)
                end
            end
            
            -- Recursively search
            searchFolder(obj, fullPath)
        end
    end
    
    searchFolder(ReplicatedStorage, "ReplicatedStorage")
    
    return rewardRemotes
end

-- TEST REWARD REMOTES
local function testRewardRemotes(remotes)
    print("\n🧪 TESTING REWARD REMOTES...")
    
    local testData = {
        "Brainrots",
        "brainrots",
        1000,
        9999,
        10000,
        {Amount = 1000, Currency = "Brainrots"},
        {Brainrots = 1000},
        {Coins = 9999},
        {Reward = "Brainrots", Amount = 1000}
    }
    
    for _, remoteInfo in pairs(remotes) do
        local remote = remoteInfo.obj
        print("\nTesting: " .. remote.Name .. " (" .. remote.ClassName .. ")")
        
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
                print("  ✅ Success with data: " .. tostring(data))
                print("    Result: " .. tostring(result))
            end
            wait(0.1)
        end
    end
end

-- CHAT COMMAND INTERCEPTOR
print("\n🎯 SETTING UP CHAT COMMAND INTERCEPTOR...")

local function setupChatInterceptor()
    -- Hook into chat system
    local function onChatMessage(message)
        -- Check if message is a command
        if message:sub(1, 1) == "/" then
            print("\n💬 Chat command detected: " .. message)
            
            -- Try to execute command
            local success, result = pcall(function()
                -- Send to game chat system
                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(message)
                return "Command sent"
            end)
            
            if success then
                print("  ✅ Command sent successfully")
            else
                print("  ❌ Failed: " .. tostring(result))
            end
        end
    end
    
    -- Hook player chat
    pcall(function()
        Player.Chatted:Connect(onChatMessage)
        print("✅ Chat interceptor active")
    end)
    
    -- Also test sending commands directly
    return function(command)
        onChatMessage(command)
    end
end

-- CREATE COMMAND TESTER UI
print("\n🎛️ CREATING COMMAND TESTER UI...")

local function createCommandTester()
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Remove existing
    local existing = PlayerGui:FindFirstChild("CommandTester")
    if existing then existing:Destroy() end
    
    -- Create GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CommandTester"
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    MainFrame.BackgroundTransparency = 0.1
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🔍 CMDER COMMAND EXPLORER"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "Ready to explore commands..."
    Status.Size = UDim2.new(1, -20, 0, 30)
    Status.Position = UDim2.new(0, 10, 0, 45)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(150, 255, 150)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    
    -- Command Input
    local InputBox = Instance.new("TextBox")
    InputBox.PlaceholderText = "Enter command (e.g., /give brainrots 1000)"
    InputBox.Size = UDim2.new(1, -40, 0, 35)
    InputBox.Position = UDim2.new(0, 20, 0, 80)
    InputBox.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    InputBox.TextColor3 = Color3.new(1, 1, 1)
    InputBox.Font = Enum.Font.Gotham
    InputBox.TextSize = 12
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = InputBox
    
    -- Quick Command Buttons
    local quickCommands = {
        {text = "/give brainrots 1000", color = Color3.fromRGB(60, 180, 80)},
        {text = "/add coins 9999", color = Color3.fromRGB(180, 120, 60)},
        {text = "/complete event", color = Color3.fromRGB(70, 140, 200)},
        {text = "/unlock all", color = Color3.fromRGB(200, 80, 120)},
        {text = "/claim rewards", color = Color3.fromRGB(160, 80, 200)}
    }
    
    local quickY = 125
    for i, cmd in pairs(quickCommands) do
        local QuickButton = Instance.new("TextButton")
        QuickButton.Text = cmd.text
        QuickButton.Size = UDim2.new(1, -40, 0, 30)
        QuickButton.Position = UDim2.new(0, 20, 0, quickY)
        QuickButton.BackgroundColor3 = cmd.color
        QuickButton.TextColor3 = Color3.new(1, 1, 1)
        QuickButton.Font = Enum.Font.Gotham
        QuickButton.TextSize = 11
        
        QuickButton.MouseButton1Click:Connect(function()
            InputBox.Text = cmd.text
            Status.Text = "Ready: " .. cmd.text
        end)
        
        quickY = quickY + 35
    end
    
    -- Execute Button
    local ExecuteButton = Instance.new("TextButton")
    ExecuteButton.Text = "🚀 EXECUTE COMMAND"
    ExecuteButton.Size = UDim2.new(1, -40, 0, 40)
    ExecuteButton.Position = UDim2.new(0, 20, 0, quickY + 10)
    ExecuteButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    ExecuteButton.TextColor3 = Color3.new(1, 1, 1)
    ExecuteButton.Font = Enum.Font.GothamBold
    ExecuteButton.TextSize = 14
    
    ExecuteButton.MouseButton1Click:Connect(function()
        local command = InputBox.Text
        if command ~= "" then
            Status.Text = "Executing: " .. command
            
            -- Try to execute via chat
            pcall(function()
                Player:Chat(command)
                Status.Text = "✅ Sent to chat: " .. command
            end)
            
            -- Also try remotes
            local rewardRemotes = scanForRewardSystems()
            if #rewardRemotes > 0 then
                for _, remoteInfo in pairs(rewardRemotes) do
                    pcall(function()
                        remoteInfo.obj:InvokeServer(command)
                        Status.Text = "✅ Sent to remote: " .. remoteInfo.obj.Name
                    end)
                end
            end
        end
    end)
    
    -- Scan Button
    local ScanButton = Instance.new("TextButton")
    ScanButton.Text = "🔍 SCAN FOR COMMANDS"
    ScanButton.Size = UDim2.new(1, -40, 0, 35)
    ScanButton.Position = UDim2.new(0, 20, 1, -100)
    ScanButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    ScanButton.TextColor3 = Color3.new(1, 1, 1)
    ScanButton.Font = Enum.Font.Gotham
    ScanButton.TextSize = 13
    
    ScanButton.MouseButton1Click:Connect(function()
        Status.Text = "🔍 Scanning..."
        
        -- Scan terminals
        local triggers = scanForCommandTriggers()
        Status.Text = "Found " .. #triggers .. " terminals"
        
        -- Scan reward systems
        local remotes = scanForRewardSystems()
        Status.Text = Status.Text .. ", " .. #remotes .. " reward remotes"
        
        -- Test them
        if #triggers > 0 then
            testCommandsOnTerminal(triggers[1])
        end
        
        if #remotes > 0 then
            testRewardRemotes(remotes)
        end
    end)
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "✕"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Assemble UI
    Title.Parent = MainFrame
    Status.Parent = MainFrame
    InputBox.Parent = MainFrame
    ExecuteButton.Parent = MainFrame
    ScanButton.Parent = MainFrame
    CloseButton.Parent = Title
    MainFrame.Parent = ScreenGui
    ScreenGui.Parent = PlayerGui
    
    print("✅ Command Tester UI created - Center screen")
    return ScreenGui
end

-- MEMORY SCANNER FOR HIDDEN COMMANDS
print("\n🧠 MEMORY SCANNER ACTIVATED...")

local function memoryScanForBrainrots()
    print("Scanning game memory for Brainrot references...")
    
    -- Look for Brainrot values in game state
    local foundValues = {}
    
    -- Check player stats
    pcall(function()
        local leaderstats = Player:FindFirstChild("leaderstats")
        if leaderstats then
            for _, stat in pairs(leaderstats:GetChildren()) do
                if stat.Name:lower():find("brainrot") or 
                   stat.Name:lower():find("coin") or 
                   stat.Name:lower():find("currency") then
                    print("🎯 Found currency stat: " .. stat.Name)
                    print("  Current value: " .. tostring(stat.Value))
                    table.insert(foundValues, stat)
                end
            end
        end
    end)
    
    -- Check Data Stores (via remotes)
    local function checkDataStoreRemotes()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            for _, remote in pairs(remotes:GetDescendants()) do
                if remote:IsA("RemoteFunction") then
                    local nameLower = remote.Name:lower()
                    if nameLower:find("data") or nameLower:find("save") or nameLower:find("load") then
                        print("📊 Data remote: " .. remote.Name)
                        
                        -- Try to get data
                        pcall(function()
                            local data = remote:InvokeServer()
                            if data and type(data) == "table" then
                                for key, value in pairs(data) do
                                    if tostring(key):lower():find("brainrot") then
                                        print("  🎯 Found Brainrots in data: " .. tostring(value))
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
    
    checkDataStoreRemotes()
    
    return foundValues
end

-- MAIN EXECUTION
print("\n" .. string.rep("🚀", 40))
print("STARTING COMMAND CENTER EXPLORER...")
print(string.rep("🚀", 40))

-- Create UI
createCommandTester()

-- Setup chat interceptor
local sendCommand = setupChatInterceptor()

-- Initial scan
task.wait(1)
print("\n🔍 INITIAL SCAN...")

local terminals = scanForCommandTriggers()
print("Found " .. #terminals .. " command terminals")

local rewardRemotes = scanForRewardSystems()
print("Found " .. #rewardRemotes .. " reward remotes")

-- Test first terminal
if #terminals > 0 then
    testCommandsOnTerminal(terminals[1])
end

-- Memory scan
task.wait(1)
memoryScanForBrainrots()

-- EXPORT FUNCTIONS
getgenv().CMDERCommands = {
    -- Command execution
    exec = sendCommand or function(cmd) Player:Chat(cmd) end,
    giveBrainrots = function(amount)
        local cmd = "/give brainrots " .. (amount or 1000)
        Player:Chat(cmd)
    end,
    
    -- Scanning
    scan = function()
        terminals = scanForCommandTriggers()
        rewardRemotes = scanForRewardSystems()
        return #terminals, #rewardRemotes
    end,
    
    -- Testing
    testTerminal = function(index)
        if terminals[index] then
            testCommandsOnTerminal(terminals[index])
        end
    end,
    
    testRemotes = function()
        testRewardRemotes(rewardRemotes)
    end,
    
    -- UI
    ui = createCommandTester,
    
    -- Memory
    memoryScan = memoryScanForBrainrots
}

-- AUTO-TEST COMMON COMMANDS
print("\n🧪 AUTO-TESTING COMMON COMMANDS...")

task.wait(2)
for _, command in pairs(brainrotCommands) do
    print("Testing: " .. command)
    pcall(function()
        Player:Chat(command)
    end)
    wait(0.5)
end

-- FINAL MESSAGE
print("\n" .. string.rep("=", 60))
print("🔍 CMDER COMMAND EXPLORER READY!")
print(string.rep("=", 60))

print("\n📋 AVAILABLE FUNCTIONS:")
print("CMDERCommands.exec('/give brainrots 1000')")
print("CMDERCommands.giveBrainrots(5000)")
print("CMDERCommands.scan() - Find terminals & remotes")
print("CMDERCommands.testRemotes() - Test reward remotes")
print("CMDERCommands.ui() - Show command tester")
print("CMDERCommands.memoryScan() - Scan for Brainrot values")

print("\n🎯 COMMAND TESTER UI:")
print("• Center of screen")
print("• Enter commands in text box")
print("• Quick buttons for common commands")
print("• Scan button to find systems")

print("\n💡 TIPS FOR FINDING COMMANDS:")
print("1. Try typing /help or /commands in chat")
print("2. Look for terminals with ProximityPrompts")
print("3. Check the Scripts in Command Center objects")
print("4. Try common admin/cheat commands")
print("5. Watch for any response messages")

print("\n⚠️ REMEMBER:")
print("• Not all commands will work")
print("• Some may require admin privileges")
print("• Game may have anti-cheat for commands")
print("• Use the scanner to find what works")
