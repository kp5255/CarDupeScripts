-- 🎯 STEALTH CAR ACQUISITION SYSTEM
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== STEALTH APPROACH =====
local function stealthScan()
    print("👁️ Observing game systems...")
    
    -- Check for existing remotes (non-invasive)
    local foundRemotes = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nameLower = obj.Name:lower()
            if nameLower:find("car") or nameLower:find("vehicle") or 
               nameLower:find("give") or nameLower:find("add") then
                table.insert(foundRemotes, {
                    Object = obj,
                    Name = obj.Name,
                    Path = obj:GetFullName()
                })
            end
        end
    end
    
    print("📡 Found " .. #foundRemotes .. " car-related remotes")
    
    -- Check player data structure
    local playerData = {}
    for _, child in pairs(player:GetChildren()) do
        if child:IsA("Folder") or child:IsA("Configuration") then
            table.insert(playerData, {
                Name = child.Name,
                Type = child.ClassName,
                Items = #child:GetChildren()
            })
        end
    end
    
    print("👤 Player has " .. #playerData .. " data containers")
    
    return foundRemotes, playerData
end

-- ===== MINIMALIST DUPLICATION =====
local function attemptMinimalDuplication(remotes)
    print("🎯 Attempting minimal duplication...")
    
    local testCars = {
        "Bontlay Bontaga",
        "Jegar Model F", 
        "Corsaro T8",
        "Lavish Ventoge",
        "Sportler Tecan"
    }
    
    local successfulAttempts = {}
    
    -- Try only the most promising remotes
    for _, remote in pairs(remotes) do
        local remoteName = remote.Name:lower()
        
        -- Prioritize specific remotes
        if remoteName:find("give") or remoteName:find("add") then
            print("Testing: " .. remote.Name)
            
            -- Try minimal data formats
            local formats = {
                "Bontlay Bontaga",
                {"Bontlay Bontaga"},
                {player, "Bontlay Bontaga"}
            }
            
            for _, data in pairs(formats) do
                local success, result = pcall(function()
                    remote.Object:FireServer(data)
                    return "Sent"
                end)
                
                if success then
                    if not successfulAttempts[remote.Name] then
                        successfulAttempts[remote.Name] = 0
                    end
                    successfulAttempts[remote.Name] = successfulAttempts[remote.Name] + 1
                    print("✅ " .. remote.Name .. " accepted")
                    
                    -- Send a few more quietly
                    for i = 1, 3 do
                        pcall(function()
                            remote.Object:FireServer(data)
                        end)
                        task.wait(0.1)
                    end
                    
                    break
                end
            end
            
            task.wait(0.2) -- Slow to avoid detection
        end
    end
    
    return successfulAttempts
end

-- ===== STEALTH UI =====
local function createStealthUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "GameHelper"
    gui.DisplayOrder = 999
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Minimal window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 250, 0, 180)
    main.Position = UDim2.new(0, 10, 0, 10) -- Top-left corner
    main.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    main.BorderSizePixel = 0
    main.Parent = gui
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    header.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Text = "🛠️ Game Helper"
    title.Size = UDim2.new(1, -10, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.Gotham
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.Gotham
    closeBtn.TextSize = 14
    closeBtn.Parent = header
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -30)
    content.Position = UDim2.new(0, 0, 0, 30)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Helper ready"
    status.Size = UDim2.new(1, -10, 0, 40)
    status.Position = UDim2.new(0, 5, 0, 5)
    status.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    status.TextWrapped = true
    status.Parent = content
    
    -- Buttons (small and subtle)
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🔍 Scan"
    scanBtn.Size = UDim2.new(0.5, -7, 0, 25)
    scanBtn.Position = UDim2.new(0, 5, 0, 50)
    scanBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.Gotham
    scanBtn.TextSize = 11
    scanBtn.Parent = content
    
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "🔄 Try"
    dupeBtn.Size = UDim2.new(0.5, -7, 0, 25)
    dupeBtn.Position = UDim2.new(0.5, 2, 0, 50)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(140, 70, 70)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.Gotham
    dupeBtn.TextSize = 11
    dupeBtn.Parent = content
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Text = "🗑️ Clear"
    clearBtn.Size = UDim2.new(1, -10, 0, 25)
    clearBtn.Position = UDim2.new(0, 5, 0, 80)
    clearBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    clearBtn.TextColor3 = Color3.new(1, 1, 1)
    clearBtn.Font = Enum.Font.Gotham
    clearBtn.TextSize = 11
    clearBtn.Parent = content
    
    -- Results (tiny)
    local results = Instance.new("TextLabel")
    results.Text = ""
    results.Size = UDim2.new(1, -10, 0, 50)
    results.Position = UDim2.new(0, 5, 0, 110)
    results.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    results.TextColor3 = Color3.new(1, 1, 1)
    results.Font = Enum.Font.Code
    results.TextSize = 9
    results.TextWrapped = true
    results.Parent = content
    
    -- Add subtle corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 3)
        corner.Parent = obj
    end
    
    addCorner(main)
    addCorner(header)
    addCorner(status)
    addCorner(scanBtn)
    addCorner(dupeBtn)
    addCorner(clearBtn)
    addCorner(results)
    addCorner(closeBtn)
    
    -- Variables
    local foundRemotes = {}
    
    -- Draggable (simple)
    local dragging = false
    local dragStart
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position - main.AbsolutePosition
        end
    end)
    
    header.InputEnded:Connect(function()
        dragging = false
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            main.Position = UDim2.new(
                0, input.Position.X - dragStart.X,
                0, input.Position.Y - dragStart.Y
            )
        end
    end)
    
    -- Button actions
    scanBtn.MouseButton1Click:Connect(function()
        scanBtn.Text = "..."
        scanBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
        status.Text = "Scanning systems..."
        
        task.spawn(function()
            foundRemotes = stealthScan()
            
            if #foundRemotes > 0 then
                status.Text = "Found " .. #foundRemotes .. " systems"
                results.Text = "Systems ready\nClick Try"
            else
                status.Text = "No systems found"
                results.Text = "No car systems detected"
            end
            
            scanBtn.Text = "🔍 Scan"
            scanBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
        end)
    end)
    
    dupeBtn.MouseButton1Click:Connect(function()
        if #foundRemotes == 0 then
            status.Text = "Scan first"
            results.Text = "Need to scan first"
            return
        end
        
        dupeBtn.Text = "..."
        dupeBtn.BackgroundColor3 = Color3.fromRGB(255, 120, 30)
        status.Text = "Testing systems..."
        results.Text = "Testing..."
        
        task.spawn(function()
            local resultsData = attemptMinimalDuplication(foundRemotes)
            
            if next(resultsData) then
                local successCount = 0
                for _, count in pairs(resultsData) do
                    successCount = successCount + count
                end
                
                status.Text = "Test complete"
                results.Text = successCount .. " successful\nCheck inventory"
            else
                status.Text = "No response"
                results.Text = "Systems not responding"
            end
            
            dupeBtn.Text = "🔄 Try"
            dupeBtn.BackgroundColor3 = Color3.fromRGB(140, 70, 70)
        end)
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        results.Text = ""
        status.Text = "Cleared"
        task.wait(1)
        status.Text = "Helper ready"
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        task.wait(0.5)
        gui:Destroy()
    end)
    
    return gui
end

-- ===== QUICK CHECK =====
local function quickCheck()
    print("\n🔍 Quick system check:")
    
    -- Check for Cmdr
    local cmdr = ReplicatedStorage:FindFirstChild("CmdrClient")
    if cmdr then
        print("✅ Cmdr system available")
        local cmdrEvent = cmdr:FindFirstChild("CmdrEvent")
        if cmdrEvent then
            print("✅ CmdrEvent found")
            
            -- Try simple commands
            local commands = {"givecar", "car", "vehicle", "addcar"}
            for _, cmd in pairs(commands) do
                local success = pcall(function()
                    cmdrEvent:FireServer(cmd .. " Bontlay Bontaga")
                    return true
                end)
                if success then
                    print("✅ Command accepted: " .. cmd)
                end
                task.wait(0.1)
            end
        end
    end
    
    -- Check leaderstats
    if player:FindFirstChild("leaderstats") then
        print("💰 Leaderstats:")
        for _, stat in pairs(player.leaderstats:GetChildren()) do
            print("  " .. stat.Name .. ": " .. tostring(stat.Value))
        end
    end
end

-- ===== MAIN =====
print("🛠️ Helper initialized")
task.wait(1)

quickCheck()
task.wait(1)

local ui = createStealthUI()
print("\n✅ Helper active (top-left)")
print("💡 Use scan → try → check inventory")
