-- 🔍 COMPACT NETWORK ANALYZER - Draggable & Responsive
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== COMPACT NETWORK MONITOR =====
local networkLog = {}
local vulnerabilityScore = {}
local isMonitoring = false

local function hookNetwork()
    print("📡 Hooking network...")
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local original = obj.FireServer
            obj.FireServer = function(self, ...)
                if isMonitoring then
                    local args = {...}
                    table.insert(networkLog, {
                        Time = os.time(),
                        Remote = self.Name,
                        Path = self:GetFullName(),
                        Args = args
                    })
                    
                    -- Simple vulnerability check
                    local remoteName = self.Name:lower()
                    if remoteName:find("car") or remoteName:find("give") or 
                       remoteName:find("buy") or remoteName:find("add") then
                        if not vulnerabilityScore[self.Name] then
                            vulnerabilityScore[self.Name] = 5
                        else
                            vulnerabilityScore[self.Name] = vulnerabilityScore[self.Name] + 1
                        end
                    end
                end
                return original(self, ...)
            end
        end
    end
    print("✅ Network hooked")
end

-- ===== COMPACT UI =====
local function createCompactUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CompactAnalyzer"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Main Window (Smaller)
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 350, 0, 400)
    main.Position = UDim2.new(0.5, -175, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    
    -- Title Bar (DRAGGABLE)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleBar.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Text = "🔍 NET ANALYZER"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.Code
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.Code
    closeBtn.TextSize = 12
    closeBtn.Parent = titleBar
    
    -- Content Area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Control Buttons (Compact)
    local controls = Instance.new("Frame")
    controls.Size = UDim2.new(1, -10, 0, 60)
    controls.Position = UDim2.new(0, 5, 0, 5)
    controls.BackgroundTransparency = 1
    controls.Parent = content
    
    local startBtn = Instance.new("TextButton")
    startBtn.Text = "▶ START"
    startBtn.Size = UDim2.new(0.5, -5, 0, 25)
    startBtn.Position = UDim2.new(0, 0, 0, 0)
    startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    startBtn.TextColor3 = Color3.new(1, 1, 1)
    startBtn.Font = Enum.Font.Code
    startBtn.TextSize = 12
    startBtn.Parent = controls
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Text = "🗑️ CLEAR"
    clearBtn.Size = UDim2.new(0.5, -5, 0, 25)
    clearBtn.Position = UDim2.new(0.5, 5, 0, 0)
    clearBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    clearBtn.TextColor3 = Color3.new(1, 1, 1)
    clearBtn.Font = Enum.Font.Code
    clearBtn.TextSize = 12
    clearBtn.Parent = controls
    
    local exploitBtn = Instance.new("TextButton")
    exploitBtn.Text = "⚡ TEST"
    exploitBtn.Size = UDim2.new(0.5, -5, 0, 25)
    exploitBtn.Position = UDim2.new(0, 0, 0, 30)
    exploitBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    exploitBtn.TextColor3 = Color3.new(1, 1, 1)
    exploitBtn.Font = Enum.Font.Code
    exploitBtn.TextSize = 12
    exploitBtn.Parent = controls
    
    local statusBtn = Instance.new("TextButton")
    statusBtn.Text = "📊 STATS"
    statusBtn.Size = UDim2.new(0.5, -5, 0, 25)
    statusBtn.Position = UDim2.new(0.5, 5, 0, 30)
    statusBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    statusBtn.TextColor3 = Color3.new(1, 1, 1)
    statusBtn.Font = Enum.Font.Code
    statusBtn.TextSize = 12
    statusBtn.Parent = controls
    
    -- Stats Display (Small)
    local statsPanel = Instance.new("Frame")
    statsPanel.Size = UDim2.new(1, -10, 0, 60)
    statsPanel.Position = UDim2.new(0, 5, 0, 70)
    statsPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    statsPanel.Visible = false
    statsPanel.Parent = content
    
    local stats = Instance.new("TextLabel")
    stats.Text = "Packets: 0\nVulnerable: 0"
    stats.Size = UDim2.new(1, -10, 1, -10)
    stats.Position = UDim2.new(0, 5, 0, 5)
    stats.BackgroundTransparency = 1
    stats.TextColor3 = Color3.new(1, 1, 1)
    stats.Font = Enum.Font.Code
    stats.TextSize = 10
    stats.TextWrapped = true
    stats.Parent = statsPanel
    
    -- Log Display (Compact)
    local logFrame = Instance.new("ScrollingFrame")
    logFrame.Size = UDim2.new(1, -10, 0, 240)
    logFrame.Position = UDim2.new(0, 5, 0, 135)
    logFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    logFrame.BorderSizePixel = 0
    logFrame.ScrollBarThickness = 4
    logFrame.Parent = content
    
    -- Add rounded corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = obj
    end
    
    addCorner(main)
    addCorner(titleBar)
    addCorner(startBtn)
    addCorner(clearBtn)
    addCorner(exploitBtn)
    addCorner(statusBtn)
    addCorner(statsPanel)
    addCorner(logFrame)
    addCorner(closeBtn)
    
    -- === DRAGGABLE WINDOW ===
    local dragging = false
    local dragStart, frameStart
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = main.Position
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                frameStart.X.Scale, frameStart.X.Offset + delta.X,
                frameStart.Y.Scale, frameStart.Y.Offset + delta.Y
            )
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
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- === FUNCTIONS ===
    local function updateLog()
        logFrame:ClearAllChildren()
        
        local yPos = 2
        for i = math.max(1, #networkLog - 20), #networkLog do
            local entry = networkLog[i]
            if entry then
                local entryFrame = Instance.new("Frame")
                entryFrame.Size = UDim2.new(1, -4, 0, 35)
                entryFrame.Position = UDim2.new(0, 2, 0, yPos)
                
                -- Color based on vulnerability
                local score = vulnerabilityScore[entry.Remote] or 0
                if score > 10 then
                    entryFrame.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
                elseif score > 5 then
                    entryFrame.BackgroundColor3 = Color3.fromRGB(80, 50, 20)
                else
                    entryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                end
                
                addCorner(entryFrame)
                entryFrame.Parent = logFrame
                
                -- Remote name
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Text = entry.Remote
                nameLabel.Size = UDim2.new(1, -10, 0, 15)
                nameLabel.Position = UDim2.new(0, 5, 0, 2)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                nameLabel.Font = Enum.Font.Code
                nameLabel.TextSize = 10
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                nameLabel.Parent = entryFrame
                
                -- Args info
                local argsLabel = Instance.new("TextLabel")
                argsLabel.Text = "Args: " .. #entry.Args
                argsLabel.Size = UDim2.new(1, -10, 0, 15)
                argsLabel.Position = UDim2.new(0, 5, 0, 18)
                argsLabel.BackgroundTransparency = 1
                argsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                argsLabel.Font = Enum.Font.Code
                argsLabel.TextSize = 9
                argsLabel.TextXAlignment = Enum.TextXAlignment.Left
                argsLabel.Parent = entryFrame
                
                yPos = yPos + 40
            end
        end
        
        logFrame.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end
    
    local function updateStats()
        local vulnerableCount = 0
        for _, score in pairs(vulnerabilityScore) do
            if score > 5 then
                vulnerableCount = vulnerableCount + 1
            end
        end
        
        stats.Text = string.format("Packets: %d\nVulnerable: %d\nCar Remotes: %d", 
            #networkLog, vulnerableCount, #networkLog)
    end
    
    local function testExploits()
        exploitBtn.Text = "TESTING..."
        exploitBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            -- Find vulnerable remotes
            local targets = {}
            for remoteName, score in pairs(vulnerabilityScore) do
                if score > 5 then
                    for _, obj in pairs(game:GetDescendants()) do
                        if obj.Name == remoteName and obj:IsA("RemoteEvent") then
                            table.insert(targets, {Name = remoteName, Object = obj})
                            break
                        end
                    end
                end
            end
            
            if #targets == 0 then
                -- Test all car-related remotes
                for _, obj in pairs(game:GetDescendants()) do
                    if obj:IsA("RemoteEvent") and obj.Name:lower():find("car") then
                        table.insert(targets, {Name = obj.Name, Object = obj})
                    end
                end
            end
            
            -- Test each target
            local successCount = 0
            for _, target in ipairs(targets) do
                print("Testing: " .. target.Name)
                
                local testData = {
                    "Bontlay Bontaga",
                    {Car = "Bontlay Bontaga"},
                    {"give", "Bontlay Bontaga"},
                    {player, "Bontlay Bontaga"}
                }
                
                for _, data in ipairs(testData) do
                    local success = pcall(function()
                        target.Object:FireServer(data)
                        return true
                    end)
                    
                    if success then
                        successCount = successCount + 1
                        print("✅ " .. target.Name .. " accepted data")
                        break
                    end
                end
                
                task.wait(0.1)
            end
            
            exploitBtn.Text = string.format("⚡ %d/%d", successCount, #targets)
            exploitBtn.BackgroundColor3 = successCount > 0 and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
            
            if successCount > 0 then
                print(string.format("🎯 %d remotes accepted car data!", successCount))
                print("Check your inventory for new cars!")
            end
        end)
    end
    
    -- === BUTTON ACTIONS ===
    startBtn.MouseButton1Click:Connect(function()
        if not isMonitoring then
            isMonitoring = true
            startBtn.Text = "⏹ STOP"
            startBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            hookNetwork()
            
            -- Start update loop
            task.spawn(function()
                while isMonitoring do
                    updateLog()
                    updateStats()
                    task.wait(1)
                end
            end)
        else
            isMonitoring = false
            startBtn.Text = "▶ START"
            startBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        end
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        networkLog = {}
        vulnerabilityScore = {}
        updateLog()
        updateStats()
    end)
    
    exploitBtn.MouseButton1Click:Connect(function()
        testExploits()
    end)
    
    statusBtn.MouseButton1Click:Connect(function()
        statsPanel.Visible = not statsPanel.Visible
        updateStats()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Initial update
    updateLog()
    
    return gui
end

-- ===== MAIN =====
print("🔍 Compact Network Analyzer")
print("Starting...")
task.wait(1)

local ui = createCompactUI()
print("✅ UI Ready - Drag the blue title bar!")

print("\n🎮 Quick Guide:")
print("• Drag the blue bar to move window")
print("• Click START to monitor network")
print("• Perform car actions in-game")
print("• Click TEST to try exploits")
print("• Check inventory after testing")
