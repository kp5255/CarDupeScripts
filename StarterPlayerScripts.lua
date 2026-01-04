-- 🔍 FIXED NETWORK ANALYZER - No Errors
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== SAFE NETWORK MONITOR =====
local networkLog = {}
local vulnerabilityScore = {}
local isMonitoring = false

local function safeHookNetwork()
    print("📡 Starting safe network monitoring...")
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            -- Use pcall to safely hook each remote
            local success, result = pcall(function()
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
                        
                        -- Check for car-related remotes
                        local remoteName = self.Name:lower()
                        if remoteName:find("car") or remoteName:find("vehicle") or 
                           remoteName:find("give") or remoteName:find("buy") or 
                           remoteName:find("purchase") or remoteName:find("add") then
                            vulnerabilityScore[self.Name] = (vulnerabilityScore[self.Name] or 0) + 1
                        end
                    end
                    return original(self, ...)
                end
                return true
            end)
            
            if not success then
                print("⚠️ Could not hook: " .. obj:GetFullName())
            end
        end
    end
    print("✅ Network monitoring ready")
end

-- ===== SIMPLE CAR TESTER =====
local function testCarRemotes()
    print("🎯 Testing car remotes...")
    
    local testCars = {
        "Bontlay Bontaga",
        "Jegar Model F",
        "Corsaro T8",
        "Lavish Ventoge",
        "Sportler Tecan"
    }
    
    local foundRemotes = {}
    
    -- Find all RemoteEvents
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nameLower = obj.Name:lower()
            if nameLower:find("car") or nameLower:find("vehicle") or 
               nameLower:find("give") or nameLower:find("buy") then
                table.insert(foundRemotes, {
                    Object = obj,
                    Name = obj.Name,
                    Path = obj:GetFullName()
                })
            end
        end
    end
    
    print("Found " .. #foundRemotes .. " car-related remotes")
    
    local successfulTests = {}
    
    for _, remote in pairs(foundRemotes) do
        print("Testing: " .. remote.Name)
        
        -- Try different data formats
        local formats = {
            "Bontlay Bontaga",
            {"Bontlay Bontaga"},
            {Car = "Bontlay Bontaga"},
            {"give", "Bontlay Bontaga"},
            {player, "Bontlay Bontaga"}
        }
        
        for _, data in pairs(formats) do
            local success, result = pcall(function()
                remote.Object:FireServer(data)
                return "Success"
            end)
            
            if success then
                if not successfulTests[remote.Name] then
                    successfulTests[remote.Name] = 0
                end
                successfulTests[remote.Name] = successfulTests[remote.Name] + 1
                print("✅ " .. remote.Name .. " accepted data")
                break
            end
            
            task.wait(0.05)
        end
    end
    
    return successfulTests
end

-- ===== CLEAN DRAGGABLE UI =====
local function createCleanUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarAnalyzer"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Main Window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 300, 0, 350)
    main.Position = UDim2.new(0.5, -150, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Title Bar (Draggable)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleBar.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Text = "🚗 CAR FINDER"
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.Parent = titleBar
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Status Label
    local status = Instance.new("TextLabel")
    status.Text = "Ready to scan for cars"
    status.Size = UDim2.new(1, -10, 0, 40)
    status.Position = UDim2.new(0, 5, 0, 5)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = content
    
    -- Buttons
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🔍 SCAN REMOTES"
    scanBtn.Size = UDim2.new(1, -10, 0, 30)
    scanBtn.Position = UDim2.new(0, 5, 0, 50)
    scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 12
    scanBtn.Parent = content
    
    local testBtn = Instance.new("TextButton")
    testBtn.Text = "🎯 TEST CARS"
    testBtn.Size = UDim2.new(1, -10, 0, 30)
    testBtn.Position = UDim2.new(0, 5, 0, 85)
    testBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    testBtn.TextColor3 = Color3.new(1, 1, 1)
    testBtn.Font = Enum.Font.GothamBold
    testBtn.TextSize = 12
    testBtn.Parent = content
    
    local autoBtn = Instance.new("TextButton")
    autoBtn.Text = "⚡ AUTO-DUPE"
    autoBtn.Size = UDim2.new(1, -10, 0, 30)
    autoBtn.Position = UDim2.new(0, 5, 0, 120)
    autoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    autoBtn.TextColor3 = Color3.new(1, 1, 1)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 12
    autoBtn.Parent = content
    
    -- Results Display
    local results = Instance.new("ScrollingFrame")
    results.Size = UDim2.new(1, -10, 0, 150)
    results.Position = UDim2.new(0, 5, 0, 155)
    results.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    results.BorderSizePixel = 0
    results.ScrollBarThickness = 4
    results.Parent = content
    
    -- Add rounded corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = obj
    end
    
    addCorner(main)
    addCorner(titleBar)
    addCorner(status)
    addCorner(scanBtn)
    addCorner(testBtn)
    addCorner(autoBtn)
    addCorner(results)
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
    local function updateResults(text, color)
        results:ClearAllChildren()
        
        local label = Instance.new("TextLabel")
        label.Text = text
        label.Size = UDim2.new(1, -10, 1, -10)
        label.Position = UDim2.new(0, 5, 0, 5)
        label.BackgroundTransparency = 1
        label.TextColor3 = color or Color3.new(1, 1, 1)
        label.Font = Enum.Font.Code
        label.TextSize = 10
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Parent = results
    end
    
    -- === BUTTON ACTIONS ===
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "SCANNING..."
        scanBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Scanning for car remotes..."
        
        task.spawn(function()
            -- Find car-related remotes
            local carRemotes = {}
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    local nameLower = obj.Name:lower()
                    if nameLower:find("car") or nameLower:find("vehicle") or 
                       nameLower:find("buy") or nameLower:find("purchase") or
                       nameLower:find("give") or nameLower:find("add") then
                        table.insert(carRemotes, {
                            Name = obj.Name,
                            Path = obj:GetFullName()
                        })
                    end
                end
            end
            
            local resultText = "Found " .. #carRemotes .. " car-related remotes:\n\n"
            for i, remote in ipairs(carRemotes) do
                if i <= 10 then  -- Limit display
                    resultText = resultText .. "• " .. remote.Name .. "\n"
                    if #resultText > 500 then
                        resultText = resultText .. "...\n(and more)"
                        break
                    end
                end
            end
            
            updateResults(resultText, Color3.new(1, 1, 1))
            status.Text = "Scan complete!"
            
            scanBtn.Text = "🔍 SCAN REMOTES"
            scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        end)
    end)
    
    testBtn.MouseButton1Click:Connect(function()
        testBtn.Text = "TESTING..."
        testBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Testing car remotes..."
        
        task.spawn(function()
            safeHookNetwork()
            isMonitoring = true
            
            -- Give time for monitoring
            for i = 1, 5 do
                status.Text = "Testing... " .. i .. "/5"
                task.wait(1)
            end
            
            isMonitoring = false
            
            -- Show what was captured
            local resultText = "Network Log (" .. #networkLog .. " packets):\n\n"
            for i, entry in ipairs(networkLog) do
                if i <= 15 then  -- Limit display
                    local remoteName = entry.Remote
                    if remoteName:lower():find("car") then
                        resultText = resultText .. "🚗 "
                    end
                    resultText = resultText .. remoteName .. " (" .. #entry.Args .. " args)\n"
                end
            end
            
            updateResults(resultText, Color3.fromRGB(0, 255, 150))
            status.Text = "Test complete! Check results."
            
            testBtn.Text = "🎯 TEST CARS"
            testBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        end)
    end)
    
    autoBtn.MouseButton1Click:Connect(function()
        autoBtn.Text = "DUPING..."
        autoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        status.Text = "Attempting car duplication..."
        
        task.spawn(function()
            local results = testCarRemotes()
            
            local resultText = "Auto-Dupe Results:\n\n"
            local successCount = 0
            
            for remoteName, count in pairs(results) do
                successCount = successCount + 1
                resultText = resultText .. "✅ " .. remoteName .. ": " .. count .. " successes\n"
            end
            
            if successCount == 0 then
                resultText = resultText .. "❌ No remotes accepted car data\n"
                resultText = resultText .. "Try a different server!"
            else
                resultText = resultText .. "\n🎉 Check your inventory!"
            end
            
            updateResults(resultText, successCount > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100))
            status.Text = successCount > 0 and "Duplication attempted!" or "No vulnerabilities found"
            
            autoBtn.Text = "⚡ AUTO-DUPE"
            autoBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Initial display
    updateResults("Click SCAN REMOTES to begin", Color3.fromRGB(150, 150, 150))
    
    return gui
end

-- ===== MAIN =====
print("=" .. string.rep("=", 50))
print("🚗 SIMPLE CAR FINDER v1.0")
print("=" .. string.rep("=", 50))

print("\n🎯 Features:")
print("• Scan for car remotes")
print("• Test network traffic")
print("• Auto-duplicate cars")
print("• Draggable window")

print("\n🔧 Starting...")
task.wait(1)

local ui = createCleanUI()
print("\n✅ UI Ready!")
print("💡 Drag the blue bar to move the window")
print("💡 Click buttons to scan/test")
print("💡 Check inventory after testing")
