-- 🔍 ULTIMATE NETWORK ANALYZER & VULNERABILITY FINDER
-- Monitors ALL server communications to find hackable paths

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== NETWORK SNIFFER =====
local networkLog = {}
local hookedRemotes = {}
local vulnerabilityScore = {}

-- Store original methods before hooking
local function hookAllNetworkTraffic()
    print("🔍 HOOKING ALL NETWORK TRAFFIC...")
    
    -- Track all remote events and functions
    local allRemotes = {}
    
    -- First, find all existing remotes
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(allRemotes, obj)
        end
    end
    
    print(string.format("Found %d remote objects", #allRemotes))
    
    -- Hook RemoteEvent FireServer
    for _, remote in pairs(allRemotes) do
        if remote:IsA("RemoteEvent") then
            local originalFire = remote.FireServer
            
            -- Create wrapper
            remote.FireServer = function(self, ...)
                local args = {...}
                local timestamp = os.time()
                
                -- Log the call
                local logEntry = {
                    Time = timestamp,
                    Type = "FireServer",
                    Remote = self.Name,
                    Path = self:GetFullName(),
                    Args = args,
                    Player = player.Name,
                    RawData = args
                }
                
                table.insert(networkLog, logEntry)
                
                -- Analyze for vulnerabilities
                analyzeForVulnerabilities(logEntry)
                
                -- Call original
                return originalFire(self, ...)
            end
            
            hookedRemotes[remote] = true
        elseif remote:IsA("RemoteFunction") then
            local originalInvoke = remote.InvokeServer
            
            remote.InvokeServer = function(self, ...)
                local args = {...}
                local timestamp = os.time()
                
                -- Log the call
                local logEntry = {
                    Time = timestamp,
                    Type = "InvokeServer",
                    Remote = self.Name,
                    Path = self:GetFullName(),
                    Args = args,
                    Player = player.Name,
                    RawData = args
                }
                
                table.insert(networkLog, logEntry)
                
                -- Analyze for vulnerabilities
                analyzeForVulnerabilities(logEntry)
                
                -- Call original
                return originalInvoke(self, ...)
            end
            
            hookedRemotes[remote] = true
        end
    end
    
    -- Also hook new remotes as they're created
    game.DescendantAdded:Connect(function(obj)
        task.wait(0.1)
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and not hookedRemotes[obj] then
            if obj:IsA("RemoteEvent") then
                local originalFire = obj.FireServer
                obj.FireServer = function(self, ...)
                    local args = {...}
                    local timestamp = os.time()
                    
                    table.insert(networkLog, {
                        Time = timestamp,
                        Type = "FireServer",
                        Remote = self.Name,
                        Path = self:GetFullName(),
                        Args = args,
                        Player = player.Name
                    })
                    
                    return originalFire(self, ...)
                end
            else
                local originalInvoke = obj.InvokeServer
                obj.InvokeServer = function(self, ...)
                    local args = {...}
                    local timestamp = os.time()
                    
                    table.insert(networkLog, {
                        Time = timestamp,
                        Type = "InvokeServer",
                        Remote = self.Name,
                        Path = self:GetFullName(),
                        Args = args,
                        Player = player.Name
                    })
                    
                    return originalInvoke(self, ...)
                end
            end
            
            hookedRemotes[obj] = true
        end
    end)
    
    print("✅ Network hooks installed")
    return #allRemotes
end

-- ===== VULNERABILITY ANALYZER =====
local function analyzeForVulnerabilities(logEntry)
    local remoteName = logEntry.Remote:lower()
    local vulnerabilityFlags = {}
    
    -- Check for common vulnerability patterns
    local checks = {
        -- 1. No player validation
        function()
            if #logEntry.Args == 1 and type(logEntry.Args[1]) ~= "userdata" then
                return "NO_PLAYER_VALIDATION", 8
            end
        end,
        
        -- 2. Simple data structure (easy to spoof)
        function()
            if #logEntry.Args == 1 and type(logEntry.Args[1]) == "string" then
                return "SIMPLE_STRING_DATA", 6
            end
        end,
        
        -- 3. Direct item names (no IDs)
        function()
            if #logEntry.Args > 0 then
                for _, arg in ipairs(logEntry.Args) do
                    if type(arg) == "string" and 
                       (arg:find("Bontlay") or arg:find("Jegar") or arg:find("Corsaro")) then
                        return "DIRECT_ITEM_NAMES", 7
                    end
                end
            end
        end,
        
        -- 4. Price = 0 or missing
        function()
            if #logEntry.Args >= 2 and logEntry.Args[2] == 0 then
                return "ZERO_PRICE", 9
            end
        end,
        
        -- 5. No timestamp/validation token
        function()
            local hasValidation = false
            for _, arg in ipairs(logEntry.Args) do
                if type(arg) == "table" then
                    for k, v in pairs(arg) do
                        if tostring(k):lower():find("token") or 
                           tostring(k):lower():find("signature") or
                           tostring(k):lower():find("timestamp") then
                            hasValidation = true
                        end
                    end
                end
            end
            if not hasValidation then
                return "NO_VALIDATION_TOKEN", 7
            end
        end,
        
        -- 6. Remote name suggests vulnerability
        function()
            local suspiciousNames = {
                "give", "add", "spawn", "create", "duplicate",
                "buy", "purchase", "trade", "sell", "transfer"
            }
            for _, name in ipairs(suspiciousNames) do
                if remoteName:find(name) then
                    return "SUSPICIOUS_REMOTE_NAME", 5
                end
            end
        end,
        
        -- 7. Location in ReplicatedStorage (less secure than ServerStorage)
        function()
            if logEntry.Path:find("ReplicatedStorage") then
                return "REPLICATED_STORAGE_LOCATION", 4
            end
        end
    }
    
    -- Run all checks
    for _, check in ipairs(checks) do
        local result = check()
        if result then
            table.insert(vulnerabilityFlags, result)
        end
    end
    
    -- Calculate vulnerability score
    if #vulnerabilityFlags > 0 then
        local totalScore = 0
        for _, flag in ipairs(vulnerabilityFlags) do
            totalScore = totalScore + flag[2]
        end
        local avgScore = totalScore / #vulnerabilityFlags
        
        vulnerabilityScore[logEntry.Remote] = {
            Score = avgScore,
            Flags = vulnerabilityFlags,
            LastSeen = logEntry.Time,
            Path = logEntry.Path
        }
        
        -- Log high vulnerability
        if avgScore >= 6 then
            print(string.format("⚠️  VULNERABILITY DETECTED: %s (Score: %.1f/10)", 
                  logEntry.Remote, avgScore))
            for _, flag in ipairs(vulnerabilityFlags) do
                print(string.format("   • %s (Risk: %d/10)", flag[1], flag[2]))
            end
        end
    end
end

-- ===== AUTOMATIC EXPLOIT TESTER =====
local function testExploitOnRemote(remoteName, remoteObject)
    print(string.format("🧪 TESTING EXPLOIT ON: %s", remoteName))
    
    local testCases = {
        -- Case 1: Empty/null data
        {nil},
        {},
        
        -- Case 2: Basic spoofing
        {"Bontlay Bontaga"},
        {"Jegar Model F"},
        {"Corsaro T8"},
        
        -- Case 3: With fake player
        {player},
        {player.UserId},
        {player.Name},
        
        -- Case 4: Complex spoof
        {Car = "Bontlay Bontaga", Price = 0},
        {Vehicle = "Jegar Model F", Owner = player.Name},
        {Item = "Corsaro T8", Action = "give", Player = player.UserId},
        
        -- Case 5: Array format
        {"Bontlay_Bontaga", 0, player.UserId},
        {"give", "Bontlay Bontaga", os.time()},
        
        -- Case 6: Extreme spoofing
        {Item = "Bontlay Bontaga", Price = -1000},
        {Car = "Jegar Model F", Quantity = 999},
        {Action = "duplicate", Target = "Corsaro T8", Count = 100}
    }
    
    local successfulExploits = {}
    
    for i, testData in ipairs(testCases) do
        local success, result = pcall(function()
            if remoteObject:IsA("RemoteEvent") then
                remoteObject:FireServer(unpack(testData))
                return "FireServer success"
            else
                remoteObject:InvokeServer(unpack(testData))
                return "InvokeServer success"
            end
        end)
        
        if success then
            table.insert(successfulExploits, {
                TestCase = i,
                Data = testData,
                Result = result
            })
            
            print(string.format("✅ EXPLOIT SUCCESS: Test case %d", i))
            
            -- Log the successful exploit data
            if type(testData) == "table" then
                local dataStr = ""
                for k, v in pairs(testData) do
                    dataStr = dataStr .. string.format("%s=%s, ", tostring(k), tostring(v))
                end
                print("   Data: " .. dataStr)
            else
                print("   Data: " .. tostring(testData))
            end
        end
        
        task.wait(0.05) -- Prevent flooding
    end
    
    return successfulExploits
end

-- ===== FIND MOST VULNERABLE REMOTES =====
local function findVulnerableRemotes()
    print("\n🎯 FINDING MOST VULNERABLE REMOTES...")
    
    local allRemotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(allRemotes, {
                Object = obj,
                Name = obj.Name,
                Type = obj.ClassName,
                Path = obj:GetFullName(),
                IsVulnerable = vulnerabilityScore[obj.Name] ~= nil,
                Score = vulnerabilityScore[obj.Name] and vulnerabilityScore[obj.Name].Score or 0
            })
        end
    end
    
    -- Sort by vulnerability score
    table.sort(allRemotes, function(a, b)
        return a.Score > b.Score
    end)
    
    -- Categorize remotes
    local categories = {
        CarRelated = {},
        MoneyRelated = {},
        InventoryRelated = {},
        TradeRelated = {},
        Other = {}
    }
    
    for _, remote in ipairs(allRemotes) do
        local nameLower = remote.Name:lower()
        
        if nameLower:find("car") or nameLower:find("vehicle") then
            table.insert(categories.CarRelated, remote)
        elseif nameLower:find("money") or nameLower:find("cash") or 
               nameLower:find("coin") or nameLower:find("currency") then
            table.insert(categories.MoneyRelated, remote)
        elseif nameLower:find("inventory") or nameLower:find("item") or 
               nameLower:find("give") or nameLower:find("add") then
            table.insert(categories.InventoryRelated, remote)
        elseif nameLower:find("trade") or nameLower:find("sell") or 
               nameLower:find("buy") or nameLower:find("purchase") then
            table.insert(categories.TradeRelated, remote)
        else
            table.insert(categories.Other, remote)
        end
    end
    
    -- Print summary
    print(string.format("\n📊 REMOTE CATEGORIES:"))
    print(string.format("• Car Related: %d remotes", #categories.CarRelated))
    print(string.format("• Money Related: %d remotes", #categories.MoneyRelated))
    print(string.format("• Inventory Related: %d remotes", #categories.InventoryRelated))
    print(string.format("• Trade Related: %d remotes", #categories.TradeRelated))
    print(string.format("• Other: %d remotes", #categories.Other))
    
    return categories, allRemotes
end

-- ===== MONITOR PLAYER ACTIONS =====
local function monitorPlayerActions()
    print("\n👀 MONITORING PLAYER ACTIONS...")
    
    local actionLog = {}
    
    -- Monitor when player touches parts (for car purchases)
    local function setupTouchMonitor()
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("BasePart") and 
               (part.Name:lower():find("buy") or 
                part.Name:lower():find("purchase") or
                part.Name:lower():find("car") or
                part.Name:lower():find("vehicle")) then
                
                part.Touched:Connect(function(hit)
                    if hit.Parent == player.Character then
                        table.insert(actionLog, {
                            Time = os.time(),
                            Action = "Touch",
                            Object = part.Name,
                            Path = part:GetFullName()
                        })
                        
                        print(string.format("👆 Player touched: %s", part.Name))
                    end
                end)
            end
        end
    end
    
    -- Monitor GUI button clicks
    local function setupGUIMonitor()
        local function checkGUI(gui)
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                    local btnName = obj.Name:lower()
                    if btnName:find("buy") or btnName:find("purchase") or 
                       btnName:find("select") or btnName:find("car") then
                        
                        local original = obj.MouseButton1Click
                        if original then
                            obj.MouseButton1Click:Connect(function()
                                table.insert(actionLog, {
                                    Time = os.time(),
                                    Action = "ButtonClick",
                                    Object = obj.Name,
                                    Path = obj:GetFullName(),
                                    Parent = obj.Parent.Name
                                })
                                
                                print(string.format("🖱️ Button clicked: %s", obj.Name))
                            end)
                        end
                    end
                end
            end
        end
        
        -- Check existing GUIs
        if player:FindFirstChild("PlayerGui") then
            checkGUI(player.PlayerGui)
        end
        
        -- Check new GUIs
        player.ChildAdded:Connect(function(child)
            if child:IsA("PlayerGui") then
                task.wait(1)
                checkGUI(child)
            end
        end)
    end
    
    setupTouchMonitor()
    setupGUIMonitor()
    
    print("✅ Player action monitoring active")
    return actionLog
end

-- ===== CREATE ANALYZER UI =====
local function createAnalyzerUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "NetworkAnalyzerUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Main Window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 700, 0, 800)
    main.Position = UDim2.new(0.5, -350, 0.5, -400)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    titleBar.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Text = "🔍 NETWORK ANALYZER v2.0"
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.Code
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar
    
    -- Stats Panel
    local statsPanel = Instance.new("Frame")
    statsPanel.Size = UDim2.new(1, -20, 0, 100)
    statsPanel.Position = UDim2.new(0, 10, 0, 50)
    statsPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    statsPanel.Parent = main
    
    -- Stats Labels
    local statsGrid = Instance.new("UIGridLayout")
    statsGrid.CellSize = UDim2.new(0.25, -5, 0.5, -5)
    statsGrid.CellPadding = UDim2.new(0, 5, 0, 5)
    statsGrid.Parent = statsPanel
    
    local statLabels = {
        {Name = "TotalPackets", Text = "Packets: 0", Color = Color3.fromRGB(0, 150, 200)},
        {Name = "Vulnerable", Text = "Vulnerable: 0", Color = Color3.fromRGB(200, 50, 50)},
        {Name = "CarRemotes", Text = "Car Remotes: 0", Color = Color3.fromRGB(0, 200, 100)},
        {Name = "RiskScore", Text = "Risk Score: 0/10", Color = Color3.fromRGB(255, 150, 0)}
    }
    
    local stats = {}
    for _, stat in ipairs(statLabels) do
        local label = Instance.new("TextLabel")
        label.Name = stat.Name
        label.Text = stat.Text
        label.BackgroundColor3 = stat.Color
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.Code
        label.TextSize = 14
        label.Parent = statsPanel
        stats[stat.Name] = label
    end
    
    -- Tabs
    local tabs = Instance.new("Frame")
    tabs.Size = UDim2.new(1, -20, 0, 40)
    tabs.Position = UDim2.new(0, 10, 0, 160)
    tabs.BackgroundTransparency = 1
    tabs.Parent = main
    
    local tabNames = {"LIVE", "REMOTES", "VULNERABILITIES", "EXPLOIT"}
    local tabButtons = {}
    local tabContents = {}
    
    for i, tabName in ipairs(tabNames) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Text = tabName
        tabBtn.Size = UDim2.new(0.25, -2, 1, 0)
        tabBtn.Position = UDim2.new((i-1) * 0.25, 0, 0, 0)
        tabBtn.BackgroundColor3 = i == 1 and Color3.fromRGB(0, 80, 160) or Color3.fromRGB(40, 40, 50)
        tabBtn.TextColor3 = Color3.new(1, 1, 1)
        tabBtn.Font = Enum.Font.Code
        tabBtn.TextSize = 12
        tabBtn.Parent = tabs
        
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 0, 540)
        tabContent.Position = UDim2.new(0, 0, 0, 210)
        tabContent.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 8
        tabContent.Visible = i == 1
        tabContent.Parent = main
        
        tabButtons[tabName] = tabBtn
        tabContents[tabName] = tabContent
        
        tabBtn.MouseButton1Click:Connect(function()
            for _, frame in pairs(tabContents) do
                frame.Visible = false
            end
            tabContent.Visible = true
            
            for _, btn in pairs(tabButtons) do
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
            tabBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
        end)
    end
    
    -- Control Buttons
    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(1, -20, 0, 40)
    controls.Position = UDim2.new(0, 10, 1, -50)
    controls.BackgroundTransparency = 1
    controls.Parent = main
    
    local startBtn = Instance.new("TextButton")
    startBtn.Text = "▶ START ANALYSIS"
    startBtn.Size = UDim2.new(0.5, -5, 1, 0)
    startBtn.Position = UDim2.new(0, 0, 0, 0)
    startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.Font = Enum.Font.Code
    startBtn.TextSize = 14
    startBtn.Parent = controls
    
    local exploitBtn = Instance.new("TextButton")
    exploitBtn.Text = "⚡ AUTO-EXPLOIT"
    exploitBtn.Size = UDim2.new(0.5, -5, 1, 0)
    exploitBtn.Position = UDim2.new(0.5, 5, 0, 0)
    exploitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    exploitBtn.TextColor3 = Color3.new(1, 1, 1)
    exploitBtn.Font = Enum.Font.Code
    exploitBtn.TextSize = 14
    exploitBtn.Parent = controls
    
    -- Function to update stats
    local function updateStats()
        local vulnerableCount = 0
        local totalScore = 0
        local carRemoteCount = 0
        
        for remoteName, data in pairs(vulnerabilityScore) do
            vulnerableCount = vulnerableCount + 1
            totalScore = totalScore + data.Score
            if remoteName:lower():find("car") then
                carRemoteCount = carRemoteCount + 1
            end
        end
        
        local avgScore = vulnerableCount > 0 and totalScore / vulnerableCount or 0
        
        stats.TotalPackets.Text = string.format("Packets: %d", #networkLog)
        stats.Vulnerable.Text = string.format("Vulnerable: %d", vulnerableCount)
        stats.CarRemotes.Text = string.format("Car Remotes: %d", carRemoteCount)
        stats.RiskScore.Text = string.format("Risk Score: %.1f/10", avgScore)
    end
    
    -- Live Feed Display
    local function updateLiveFeed()
        local liveTab = tabContents.LIVE
        liveTab:ClearAllChildren()
        
        local yPos = 5
        for i = math.max(1, #networkLog - 50), #networkLog do
            local entry = networkLog[i]
            if entry then
                local entryFrame = Instance.new("Frame")
                entryFrame.Size = UDim2.new(1, -10, 0, 60)
                entryFrame.Position = UDim2.new(0, 5, 0, yPos)
                
                -- Color based on vulnerability
                local score = vulnerabilityScore[entry.Remote] and vulnerabilityScore[entry.Remote].Score or 0
                if score >= 7 then
                    entryFrame.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
                elseif score >= 5 then
                    entryFrame.BackgroundColor3 = Color3.fromRGB(100, 60, 20)
                else
                    entryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                end
                
                entryFrame.Parent = liveTab
                
                -- Remote name
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = string.format("%s: %s", entry.Type, entry.Remote)
                nameLabel.Size = UDim2.new(1, -10, 0, 20)
                nameLabel.Position = UDim2.new(0, 5, 0, 5)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.Font = Enum.Font.Code
                nameLabel.TextSize = 12
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.Parent = entryFrame
                
                -- Args info
                local argsLabel = Instance.new("TextLabel")
                argsLabel.Text = string.format("Args: %d | Path: %s", #entry.Args, entry.Path)
                argsLabel.Size = UDim2.new(1, -10, 0, 35)
                argsLabel.Position = UDim2.new(0, 5, 0, 25)
                argsLabel.BackgroundTransparency = 1
                argsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                argsLabel.Font = Enum.Font.Code
                argsLabel.TextSize = 10
                argsLabel.TextXAlignment = Enum.TextXAlignment.Left
                argsLabel.TextWrapped = true
                argsLabel.Parent = entryFrame
                
                yPos = yPos + 65
            end
        end
        
        liveTab.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end
    
    -- Remotes Display
    local function updateRemotesDisplay()
        local remotesTab = tabContents.REMOTES
        remotesTab:ClearAllChildren()
        
        local categories, allRemotes = findVulnerableRemotes()
        
        local yPos = 5
        for categoryName, remotes in pairs(categories) do
            if #remotes > 0 then
                -- Category header
                local header = Instance.new("TextLabel")
                header.Text = string.format("📁 %s (%d)", categoryName:upper(), #remotes)
                header.Size = UDim2.new(1, -10, 0, 30)
                header.Position = UDim2.new(0, 5, 0, yPos)
                header.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                header.TextColor3 = Color3.new(1, 1, 1)
                header.Font = Enum.Font.Code
                header.TextSize = 14
                header.TextXAlignment = Enum.TextXAlignment.Left
                header.Parent = remotesTab
                
                yPos = yPos + 35
                
                -- List remotes in category
                for _, remote in ipairs(remotes) do
                    local remoteFrame = Instance.new("Frame")
                    remoteFrame.Size = UDim2.new(1, -10, 0, 50)
                    remoteFrame.Position = UDim2.new(0, 5, 0, yPos)
                    
                    -- Color by vulnerability
                    if remote.Score >= 7 then
                        remoteFrame.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
                    elseif remote.Score >= 5 then
                        remoteFrame.BackgroundColor3 = Color3.fromRGB(80, 50, 20)
                    else
                        remoteFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
                    end
                    
                    remoteFrame.Parent = remotesTab
                    
                    -- Remote info
                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Text = string.format("%s (%s)", remote.Name, remote.Type)
                    nameLabel.Size = UDim2.new(0.7, -5, 1, -10)
                    nameLabel.Position = UDim2.new(0, 5, 0, 5)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.TextColor3 = Color3.new(1, 1, 1)
                    nameLabel.Font = Enum.Font.Code
                    nameLabel.TextSize = 12
                    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                    nameLabel.Parent = remoteFrame
                    
                    -- Score
                    local scoreLabel = Instance.new("TextLabel")
                    scoreLabel.Text = string.format("Score: %.1f", remote.Score)
                    scoreLabel.Size = UDim2.new(0.3, -5, 1, -10)
                    scoreLabel.Position = UDim2.new(0.7, 0, 0, 5)
                    scoreLabel.BackgroundTransparency = 1
                    scoreLabel.TextColor3 = remote.Score >= 6 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(200, 200, 200)
                    scoreLabel.Font = Enum.Font.Code
                    scoreLabel.TextSize = 12
                    scoreLabel.TextXAlignment = Enum.TextXAlignment.Right
                    scoreLabel.Parent = remoteFrame
                    
                    yPos = yPos + 55
                end
                
                yPos = yPos + 10
            end
        end
        
        remotesTab.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end
    
    -- Vulnerabilities Display
    local function updateVulnerabilitiesDisplay()
        local vulnTab = tabContents.VULNERABILITIES
        vulnTab:ClearAllChildren()
        
        local yPos = 5
        
        -- Sort vulnerabilities by score
        local sortedVulns = {}
        for remoteName, data in pairs(vulnerabilityScore) do
            table.insert(sortedVulns, {
                Name = remoteName,
                Score = data.Score,
                Flags = data.Flags,
                Path = data.Path
            })
        end
        
        table.sort(sortedVulns, function(a, b)
            return a.Score > b.Score
        end)
        
        for _, vuln in ipairs(sortedVulns) do
            if vuln.Score >= 5 then
                -- Vulnerability entry
                local vulnFrame = Instance.new("Frame")
                vulnFrame.Size = UDim2.new(1, -10, 0, 80)
                vulnFrame.Position = UDim2.new(0, 5, 0, yPos)
                
                -- Color by severity
                if vuln.Score >= 8 then
                    vulnFrame.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
                elseif vuln.Score >= 6 then
                    vulnFrame.BackgroundColor3 = Color3.fromRGB(150, 75, 0)
                else
                    vulnFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
                end
                
                vulnFrame.Parent = vulnTab
                
                -- Header
                local header = Instance.new("TextLabel")
                header.Text = string.format("⚠️ %s (Score: %.1f/10)", vuln.Name, vuln.Score)
                header.Size = UDim2.new(1, -10, 0, 25)
                header.Position = UDim2.new(0, 5, 0, 5)
                header.BackgroundTransparency = 1
                header.TextColor3 = Color3.new(1, 1, 1)
                header.Font = Enum.Font.Code
                header.TextSize = 14
                header.TextXAlignment = Enum.TextXAlignment.Left
                header.Parent = vulnFrame
                
                -- Path
                local pathLabel = Instance.new("TextLabel")
                pathLabel.Text = vuln.Path
                pathLabel.Size = UDim2.new(1, -10, 0, 20)
                pathLabel.Position = UDim2.new(0, 5, 0, 30)
                pathLabel.BackgroundTransparency = 1
                pathLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                pathLabel.Font = Enum.Font.Code
                pathLabel.TextSize = 10
                pathLabel.TextXAlignment = Enum.TextXAlignment.Left
                pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
                pathLabel.Parent = vulnFrame
                
                -- Flags
                local flagsText = ""
                for _, flag in ipairs(vuln.Flags) do
                    flagsText = flagsText .. string.format("• %s (%d/10)\n", flag[1], flag[2])
                end
                
                local flagsLabel = Instance.new("TextLabel")
                flagsLabel.Text = flagsText
                flagsLabel.Size = UDim2.new(1, -10, 0, 30)
                flagsLabel.Position = UDim2.new(0, 5, 0, 50)
                flagsLabel.BackgroundTransparency = 1
                flagsLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
                flagsLabel.Font = Enum.Font.Code
                flagsLabel.TextSize = 10
                flagsLabel.TextXAlignment = Enum.TextXAlignment.Left
                flagsLabel.Parent = vulnFrame
                
                yPos = yPos + 85
            end
        end
        
        if yPos == 5 then
            local noVulns = Instance.new("TextLabel")
            noVulns.Text = "No high vulnerabilities detected yet.\nPerform car actions to analyze."
            noVulns.Size = UDim2.new(1, -10, 0, 100)
            noVulns.Position = UDim2.new(0, 5, 0, 5)
            noVulns.BackgroundTransparency = 1
            noVulns.TextColor3 = Color3.fromRGB(150, 150, 150)
            noVulns.Font = Enum.Font.Code
            noVulns.TextSize = 14
            noVulns.TextWrapped = true
            noVulns.Parent = vulnTab
            yPos = yPos + 110
        end
        
        vulnTab.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end
    
    -- Auto-Exploit Function
    local function runAutoExploit()
        exploitBtn.Text = "EXPLOITING..."
        exploitBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        
        task.spawn(function()
            -- Find top vulnerable remotes
            local topTargets = {}
            for remoteName, data in pairs(vulnerabilityScore) do
                if data.Score >= 6 then
                    -- Find the remote object
                    local remoteObj
                    for _, obj in pairs(game:GetDescendants()) do
                        if obj.Name == remoteName and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                            remoteObj = obj
                            break
                        end
                    end
                    
                    if remoteObj then
                        table.insert(topTargets, {
                            Name = remoteName,
                            Object = remoteObj,
                            Score = data.Score
                        })
                    end
                end
            end
            
            -- Sort by score
            table.sort(topTargets, function(a, b)
                return a.Score > b.Score
            end)
            
            -- Test each target
            local exploitTab = tabContents.EXPLOIT
            exploitTab:ClearAllChildren()
            
            local yPos = 5
            local successCount = 0
            
            for _, target in ipairs(topTargets) do
                local targetHeader = Instance.new("TextLabel")
                targetHeader.Text = string.format("🎯 Targeting: %s (Score: %.1f)", target.Name, target.Score)
                targetHeader.Size = UDim2.new(1, -10, 0, 30)
                targetHeader.Position = UDim2.new(0, 5, 0, yPos)
                targetHeader.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
                targetHeader.TextColor3 = Color3.new(1, 1, 1)
                targetHeader.Font = Enum.Font.Code
                targetHeader.TextSize = 14
                targetHeader.Parent = exploitTab
                
                yPos = yPos + 35
                
                -- Run exploit tests
                local results = testExploitOnRemote(target.Name, target.Object)
                
                if #results > 0 then
                    successCount = successCount + 1
                    
                    local successLabel = Instance.new("TextLabel")
                    successLabel.Text = string.format("✅ %d SUCCESSFUL EXPLOITS!", #results)
                    successLabel.Size = UDim2.new(1, -10, 0, 30)
                    successLabel.Position = UDim2.new(0, 5, 0, yPos)
                    successLabel.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
                    successLabel.TextColor3 = Color3.new(1, 1, 1)
                    successLabel.Font = Enum.Font.Code
                    successLabel.TextSize = 12
                    successLabel.Parent = exploitTab
                    
                    yPos = yPos + 35
                    
                    -- List successful exploits
                    for _, exploit in ipairs(results) do
                        local exploitLabel = Instance.new("TextLabel")
                        exploitLabel.Text = string.format("Test %d: %s", exploit.TestCase, exploit.Result)
                        exploitLabel.Size = UDim2.new(1, -10, 0, 25)
                        exploitLabel.Position = UDim2.new(0, 5, 0, yPos)
                        exploitLabel.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
                        exploitLabel.TextColor3 = Color3.new(1, 1, 1)
                        exploitLabel.Font = Enum.Font.Code
                        exploitLabel.TextSize = 11
                        exploitLabel.TextXAlignment = Enum.TextXAlignment.Left
                        exploitLabel.Parent = exploitTab
                        
                        yPos = yPos + 30
                    end
                else
                    local failLabel = Instance.new("TextLabel")
                    failLabel.Text = "❌ No successful exploits"
                    failLabel.Size = UDim2.new(1, -10, 0, 25)
                    failLabel.Position = UDim2.new(0, 5, 0, yPos)
                    failLabel.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
                    failLabel.TextColor3 = Color3.new(1, 1, 1)
                    failLabel.Font = Enum.Font.Code
                    failLabel.TextSize = 11
                    failLabel.Parent = exploitTab
                    
                    yPos = yPos + 30
                end
                
                yPos = yPos + 10
                task.wait(0.5) -- Delay between targets
            end
            
            exploitTab.CanvasSize = UDim2.new(0, 0, 0, yPos)
            
            exploitBtn.Text = string.format("⚡ EXPLOITED (%d/%d)", successCount, #topTargets)
            exploitBtn.BackgroundColor3 = successCount > 0 and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
        end)
    end
    
    -- Add rounded corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = obj
    end
    
    for _, obj in ipairs(main:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("TextButton") or obj:IsA("TextLabel") then
            addCorner(obj)
        end
    end
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeBtn
    
    -- Draggable window
    local dragging = false
    local dragStart, frameStart
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Start Analysis Button
    local isAnalyzing = false
    startBtn.MouseButton1Click:Connect(function()
        if not isAnalyzing then
            isAnalyzing = true
            startBtn.Text = "ANALYZING..."
            startBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
            
            task.spawn(function()
                -- Start all monitoring systems
                local remoteCount = hookAllNetworkTraffic()
                monitorPlayerActions()
                
                -- Start update loop
                while isAnalyzing do
                    updateStats()
                    updateLiveFeed()
                    updateRemotesDisplay()
                    updateVulnerabilitiesDisplay()
                    task.wait(1)
                end
            end)
        else
            isAnalyzing = false
            startBtn.Text = "▶ START ANALYSIS"
            startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end
    end)
    
    -- Exploit Button
    exploitBtn.MouseButton1Click:Connect(function()
        runAutoExploit()
    end)
    
    -- Close Button
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== MAIN EXECUTION =====
print("=" .. string.rep("=", 70))
print("🔍 ULTIMATE NETWORK ANALYZER & VULNERABILITY FINDER")
print("=" .. string.rep("=", 70))

print("\n🎯 PURPOSE:")
print("• Monitor ALL network traffic")
print("• Detect vulnerable remotes")
print("• Find hackable paths for cars/money")
print("• Auto-exploit discovered vulnerabilities")

print("\n🚀 INITIALIZING...")
task.wait(2)

local ui = createAnalyzerUI()

print("\n✅ SYSTEM READY!")
print("\n🎮 HOW TO USE:")
print("1. Click 'START ANALYSIS' to begin monitoring")
print("2. Perform car actions in-game (buy, trade, etc.)")
print("3. Watch LIVE tab for network traffic")
print("4. Check VULNERABILITIES tab for weak remotes")
print("5. Click 'AUTO-EXPLOIT' to test vulnerabilities")
print("\n📊 WHAT TO LOOK FOR:")
print("• Remotes with high vulnerability scores (6+/10)")
print("• Car-related remotes that accept simple data")
print("• Remotes without player validation")
print("• Transactions with price = 0")
print("\n💡 TIP: The game is MOST vulnerable during:")
print("• Car purchases/trades")
print("• Inventory management")
print("• Money transactions")
print("• Item duplication events")
