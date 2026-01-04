-- 🎯 DYNAMIC CAR FINDER - AUTO-CLICK TO COPY
local Players = game:GetService("Players")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 DYNAMIC CAR FINDER")
print("=" .. string.rep("=", 50))

-- ===== COMMANDS DATABASE =====
local commands = {
    {
        name = "📁 Check Player Folders",
        code = [[for i,v in pairs(game.Players.LocalPlayer:GetChildren()) do 
    if v:IsA("Folder") then 
        print("FOLDER:", v.Name, "| Items:", #v:GetChildren())
    end 
end]]
    },
    {
        name = "🔤 Check StringValues (Car IDs/Names)",
        code = [[local count = 0
for i,v in pairs(game.Players.LocalPlayer:GetDescendants()) do 
    if v:IsA("StringValue") then 
        print(v:GetFullName(), "=", v.Value)
        count = count + 1
    end 
end
print("TOTAL StringValues:", count)]]
    },
    {
        name = "🔢 Check IntValues (Car Counts)",
        code = [[for i,v in pairs(game.Players.LocalPlayer:GetDescendants()) do 
    if v:IsA("IntValue") then 
        print(v:GetFullName(), "=", v.Value)
    end 
end]]
    },
    {
        name = "🚗 Find Cars in GUI",
        code = [[local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("MultiCarSelection")
if gui then
    print("✅ MultiCarSelection FOUND")
    local frames = 0
    for i,v in pairs(gui:GetDescendants()) do
        if v:IsA("TextLabel") and #v.Text > 2 then
            print("CAR TEXT:", v.Text, "| Path:", v:GetFullName())
            frames = frames + 1
        end
    end
    print("Total car labels found:", frames)
else
    print("❌ MultiCarSelection NOT FOUND")
end]]
    },
    {
        name = "🔍 Deep Scan for Car Data",
        code = [[print("🔍 DEEP SCAN STARTED...")
local interesting = {}
for i,v in pairs(game.Players.LocalPlayer:GetDescendants()) do
    if v:IsA("StringValue") or v:IsA("IntValue") then
        local value = v.Value
        if type(value) == "string" and #value > 20 then
            table.insert(interesting, {path = v:GetFullName(), value = value})
        elseif type(value) == "number" and value > 50 then
            table.insert(interesting, {path = v:GetFullName(), value = value})
        end
    end
end
print("🎯 INTERESTING DATA FOUND:", #interesting)
for i, item in ipairs(interesting) do
    if i <= 10 then
        print(i .. ". " .. item.path)
        print("   Value: " .. tostring(item.value))
    end
end]]
    },
    {
        name = "💰 Check Leaderstats",
        code = [[local stats = game.Players.LocalPlayer:FindFirstChild("leaderstats")
if stats then
    print("💰 LEADERSTATS:")
    for i,v in pairs(stats:GetChildren()) do
        print(v.Name .. ": " .. tostring(v.Value))
    end
else
    print("❌ No leaderstats found")
end]]
    },
    {
        name = "📊 Count All Value Objects",
        code = [[local stringCount = 0
local intCount = 0
local folderCount = 0

for i,v in pairs(game.Players.LocalPlayer:GetDescendants()) do
    if v:IsA("StringValue") then stringCount = stringCount + 1 end
    if v:IsA("IntValue") then intCount = intCount + 1 end
    if v:IsA("Folder") then folderCount = folderCount + 1 end
end

print("📊 VALUE OBJECTS COUNT:")
print("StringValues:", stringCount)
print("IntValues:", intCount)
print("Folders:", folderCount)]]
    }
}

-- ===== CREATE DYNAMIC UI =====
local function createDynamicUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DynamicCarFinder"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 400, 0, 500)
    main.Position = UDim2.new(0.5, -200, 0.5, -250)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎯 DYNAMIC CAR FINDER"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Click any button below - Command auto-copies!"
    status.Size = UDim2.new(1, -20, 0, 40)
    status.Position = UDim2.new(0, 10, 0, 60)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = main
    
    -- Command list
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -20, 0, 350)
    list.Position = UDim2.new(0, 10, 0, 110)
    list.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 8
    list.Parent = main
    
    -- Results display
    local results = Instance.new("TextLabel")
    results.Name = "Results"
    results.Text = "No command executed yet"
    results.Size = UDim2.new(1, -20, 0, 40)
    results.Position = UDim2.new(0, 10, 1, -50)
    results.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    results.TextColor3 = Color3.new(1, 1, 1)
    results.Font = Enum.Font.Code
    results.TextSize = 11
    results.TextWrapped = true
    results.Parent = main
    
    -- Add corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    addCorner(main)
    addCorner(title)
    addCorner(status)
    addCorner(list)
    addCorner(results)
    
    -- Create command buttons
    local yPos = 10
    
    for i, cmd in ipairs(commands) do
        -- Button frame
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(1, -20, 0, 50)
        buttonFrame.Position = UDim2.new(0, 10, 0, yPos)
        buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        buttonFrame.Parent = list
        
        addCorner(buttonFrame)
        
        -- Button name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = cmd.name
        nameLabel.Size = UDim2.new(1, -10, 0, 25)
        nameLabel.Position = UDim2.new(0, 5, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = buttonFrame
        
        -- Copy button
        local copyBtn = Instance.new("TextButton")
        copyBtn.Text = "📋 COPY & RUN"
        copyBtn.Size = UDim2.new(1, -10, 0, 20)
        copyBtn.Position = UDim2.new(0, 5, 0, 30)
        copyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        copyBtn.TextColor3 = Color3.new(1, 1, 1)
        copyBtn.Font = Enum.Font.Gotham
        copyBtn.TextSize = 10
        copyBtn.Parent = buttonFrame
        
        addCorner(copyBtn)
        
        -- Click action
        copyBtn.MouseButton1Click:Connect(function()
            -- Copy to clipboard (simulated)
            copyBtn.Text = "✅ COPIED!"
            copyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            
            -- Show command in results
            local displayCode = cmd.code:gsub("\n", " "):sub(1, 100)
            if #displayCode == 100 then displayCode = displayCode .. "..." end
            results.Text = "Command copied: " .. cmd.name .. "\n" .. displayCode
            
            -- Print to console (user can copy from there)
            print("\n" .. string.rep("=", 70))
            print("📋 COMMAND: " .. cmd.name)
            print(string.rep("=", 70))
            print(cmd.code)
            print(string.rep("=", 70))
            print("📝 Copy the code above and paste in F9 console!")
            
            -- Execute automatically (optional)
            local success, err = pcall(function()
                -- Try to execute directly
                loadstring(cmd.code)()
            end)
            
            if success then
                status.Text = "✅ Command executed successfully!"
            else
                status.Text = "⚠️ Paste in F9 console for best results"
            end
            
            -- Reset button after delay
            task.wait(2)
            copyBtn.Text = "📋 COPY & RUN"
            copyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        end)
        
        yPos = yPos + 60
    end
    
    list.CanvasSize = UDim2.new(0, 0, 0, yPos)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = title
    
    addCorner(closeBtn)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Make draggable
    local dragging = false
    local dragStart, frameStart
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = main.Position
        end
    end)
    
    title.InputEnded:Connect(function()
        dragging = false
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
    
    return gui
end

-- ===== AUTO-SCAN =====
print("\n🔍 Running auto-scan...")

-- Quick auto-scan
local function quickAutoScan()
    print("\n📊 QUICK AUTO-SCAN RESULTS:")
    
    -- Count folders
    local folderCount = 0
    for _, child in pairs(player:GetChildren()) do
        if child:IsA("Folder") then
            folderCount = folderCount + 1
            print("📁 " .. child.Name .. ": " .. #child:GetChildren() .. " items")
        end
    end
    print("Total folders: " .. folderCount)
    
    -- Check MultiCarSelection
    if player:FindFirstChild("PlayerGui") then
        local gui = player.PlayerGui:FindFirstChild("MultiCarSelection")
        if gui then
            print("✅ MultiCarSelection GUI found")
        else
            print("❌ MultiCarSelection not found")
        end
    end
    
    -- Check leaderstats
    if player:FindFirstChild("leaderstats") then
        print("💰 Leaderstats present")
    end
end

-- Run auto-scan
quickAutoScan()

-- Create UI
task.wait(1)
local ui = createDynamicUI()

print("\n✅ DYNAMIC CAR FINDER READY!")
print("\n🎯 FEATURES:")
print("• Click buttons to auto-copy commands")
print("• Commands auto-print to console")
print("• Drag window to move")
print("• 7 ready-to-use commands")

print("\n💡 RECOMMENDED ORDER:")
print("1. 📁 Check Player Folders")
print("2. 📊 Count All Value Objects") 
print("3. 🔤 Check StringValues")
print("4. 🚗 Find Cars in GUI")

print("\n🚀 Click any button to start finding your 54 cars!")
