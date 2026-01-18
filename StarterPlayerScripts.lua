-- Remote Event Scanner & Trade Duplicator
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

wait(2)

print("=== REMOTE EVENT SCANNER ===")

-- Search ALL remote events in the game
local function ScanAllRemotes()
    print("\n🔍 SCANNING ALL REMOTE EVENTS...")
    
    local allRemotes = {}
    local tradeRemotes = {}
    
    -- Search in important locations
    local locations = {
        ReplicatedStorage,
        game:GetService("ReplicatedFirst"),
        game:GetService("ServerScriptService"),
        game:GetService("ServerStorage"),
        Player.PlayerGui
    }
    
    for _, location in pairs(locations) do
        pcall(function()
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    table.insert(allRemotes, {
                        name = obj.Name,
                        class = obj.ClassName,
                        path = obj:GetFullName()
                    })
                    
                    -- Check if it's trade-related
                    local nameLower = obj.Name:lower()
                    if nameLower:find("trade") or nameLower:find("offer") or nameLower:find("session") then
                        table.insert(tradeRemotes, obj)
                        print("🎯 TRADE REMOTE: " .. obj.Name .. " (" .. obj.ClassName .. ")")
                        print("   Path: " .. obj:GetFullName())
                    end
                end
            end
        end)
    end
    
    print("\n📊 SCAN RESULTS:")
    print("Total remotes found: " .. #allRemotes)
    print("Trade-related remotes: " .. #tradeRemotes)
    
    -- List all remotes for reference
    if #tradeRemotes == 0 then
        print("\n⚠️ No trade remotes found. Listing all remotes:")
        for i, remote in ipairs(allRemotes) do
            print(i .. ". " .. remote.name .. " (" .. remote.class .. ")")
            print("   " .. remote.path)
        end
    end
    
    return tradeRemotes, allRemotes
end

-- Try to find trade UI elements
local function FindTradeUI()
    print("\n🔍 LOOKING FOR TRADE UI...")
    
    local tradeElements = {}
    
    if Player.PlayerGui then
        -- Check for Menu
        local menu = Player.PlayerGui:FindFirstChild("Menu")
        if menu then
            print("✅ Found Menu")
            
            -- Check for Trading
            local trading = menu:FindFirstChild("Trading")
            if trading then
                print("✅ Found Trading")
                table.insert(tradeElements, trading)
                
                -- List everything in Trading
                print("\n📁 Contents of Trading:")
                for _, child in pairs(trading:GetChildren()) do
                    print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
                    
                    -- Check PeerToPeer
                    if child.Name == "PeerToPeer" then
                        print("    📍 Found PeerToPeer!")
                        for _, subchild in pairs(child:GetChildren()) do
                            print("      - " .. subchild.Name .. " (" .. subchild.ClassName .. ")")
                        end
                    end
                end
            else
                print("❌ No Trading found in Menu")
            end
        else
            print("❌ No Menu found")
        end
    end
    
    return tradeElements
end

-- Get the exact trade container path from your working script
local function GetTradeContainer()
    print("\n📍 GETTING TRADE CONTAINER...")
    
    -- Your exact path from the working script
    local path = {
        "PlayerGui",
        "Menu", 
        "Trading",
        "PeerToPeer",
        "Main",
        "LocalPlayer",
        "Content",
        "ScrollingFrame"
    }
    
    local current = Player
    for i, part in ipairs(path) do
        current = current:FindFirstChild(part)
        if not current then
            print("❌ Stopped at: " .. part)
            return nil
        end
        print("✅ " .. part)
    end
    
    print("🎯 Found exact container: " .. current:GetFullName())
    return current
end

-- Direct manipulation of trade items
local function DirectTradeManipulation()
    print("\n🔄 DIRECT TRADE MANIPULATION...")
    
    local container = GetTradeContainer()
    if not container then
        print("❌ Cannot find trade container")
        return false
    end
    
    print("Container class: " .. container.ClassName)
    print("Container visible: " .. tostring(container.Visible))
    print("Number of children: " .. #container:GetChildren())
    
    -- List ALL items in container
    local items = {}
    local buttons = {}
    
    print("\n📦 ALL ITEMS IN CONTAINER:")
    for i, child in pairs(container:GetChildren()) do
        print(i .. ". " .. child.Name .. " (" .. child.ClassName .. ")")
        
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
            table.insert(items, child)
            
            if child:IsA("TextButton") or child:IsA("ImageButton") then
                table.insert(buttons, child)
                
                -- Show button text if available
                if child:IsA("TextButton") then
                    print("   Text: \"" .. child.Text .. "\"")
                end
                
                -- Show children
                for _, subchild in pairs(child:GetChildren()) do
                    print("   - " .. subchild.Name .. " (" .. subchild.ClassName .. ")")
                    if subchild:IsA("TextLabel") then
                        print("     Text: \"" .. subchild.Text .. "\"")
                    end
                end
            end
        end
    end
    
    print("\n📊 SUMMARY:")
    print("Total items: " .. #items)
    print("Clickable buttons: " .. #buttons)
    
    -- Try to duplicate by clicking
    if #buttons > 0 then
        print("\n🎯 ATTEMPTING DUPLICATION VIA CLICKS...")
        
        for _, button in pairs(buttons) do
            local buttonName = button.Name
            local buttonText = button:IsA("TextButton") and button.Text or ""
            
            print("\nProcessing button: " .. buttonName .. " - \"" .. buttonText .. "\"")
            
            -- Check if this looks like a car
            if buttonName:lower():find("car") or buttonText:lower():find("car") then
                print("🚗 CAR DETECTED! Attempting duplication...")
                
                -- Try multiple click methods
                for attempt = 1, 10 do
                    print("  Attempt " .. attempt .. "...")
                    
                    -- Method 1: Standard click
                    local success1 = pcall(function()
                        button:Fire("MouseButton1Click")
                        return true
                    end)
                    
                    -- Method 2: Activated event
                    local success2 = pcall(function()
                        button:Fire("Activated")
                        return true
                    end)
                    
                    -- Method 3: Mouse events
                    local success3 = pcall(function()
                        button:Fire("MouseButton1Down")
                        wait(0.05)
                        button:Fire("MouseButton1Up")
                        return true
                    end)
                    
                    -- Method 4: Try to find and use remote events on button
                    for _, child in pairs(button:GetChildren()) do
                        if child:IsA("RemoteEvent") then
                            pcall(function()
                                child:FireServer("add")
                                child:FireServer("click")
                                child:FireServer("select")
                                print("    Fired remote: " .. child.Name)
                            end)
                        end
                    end
                    
                    if success1 or success2 or success3 then
                        print("    ✅ Click successful")
                    else
                        print("    ❌ Click failed")
                    end
                    
                    wait(0.1)
                end
            end
        end
    end
    
    -- Try to clone the items
    print("\n📋 ATTEMPTING TO CLONE ITEMS...")
    local clonesCreated = 0
    
    for _, item in pairs(items) do
        if item:IsA("Frame") or item:IsA("TextButton") then
            local success, clone = pcall(function()
                return item:Clone()
            end)
            
            if success then
                clone.Name = item.Name .. "_Copy"
                
                -- Try to position it differently
                pcall(function()
                    clone.Position = clone.Position + UDim2.new(0, 0, 0, 50)
                end)
                
                clone.Parent = container
                clonesCreated = clonesCreated + 1
                print("✅ Cloned: " .. item.Name)
            end
        end
    end
    
    print("\n📊 CLONING RESULTS:")
    print("Clones created: " .. clonesCreated)
    
    return clonesCreated > 0
end

-- Find the accept/confirm button
local function FindAndClickAccept()
    print("\n🤝 FINDING ACCEPT/CONFIRM BUTTON...")
    
    local acceptButton = nil
    
    local function SearchForButton(parent, depth)
        if depth > 10 then return nil end
        
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("TextButton") then
                local text = child.Text:lower()
                if text:find("accept") 
                   or text:find("confirm") 
                   or text:find("trade") 
                   or text:find("deal")
                   or child.Name:lower():find("accept")
                   or child.Name:lower():find("confirm") then
                    return child
                end
            end
            
            -- Recursive search
            local result = SearchForButton(child, depth + 1)
            if result then return result end
        end
        
        return nil
    end
    
    if Player.PlayerGui then
        acceptButton = SearchForButton(Player.PlayerGui, 0)
    end
    
    if acceptButton then
        print("✅ Found accept button: " .. acceptButton.Name)
        print("Button text: \"" .. acceptButton.Text .. "\"")
        
        -- Click it multiple times
        for i = 1, 5 do
            pcall(function()
                acceptButton:Fire("MouseButton1Click")
                acceptButton:Fire("Activated")
                print("  Click " .. i .. " sent")
            end)
            wait(0.1)
        end
        
        return true
    else
        print("❌ No accept button found")
        return false
    end
end

-- Try to find any working remote events
local function TestRemotes()
    print("\n🧪 TESTING REMOTE EVENTS...")
    
    local remotes, allRemotes = ScanAllRemotes()
    
    if #remotes == 0 and #allRemotes > 0 then
        print("\n⚠️ Testing some random remotes...")
        
        -- Test a few remotes that might be related
        for i = 1, math.min(10, #allRemotes) do
            local remoteInfo = allRemotes[i]
            print("\nTesting: " .. remoteInfo.name)
            
            -- Try to find the actual remote object
            local remote = nil
            pcall(function()
                remote = game:GetService("ReplicatedStorage"):FindFirstChild(remoteInfo.name)
                if not remote then
                    -- Try to get it from path
                    remote = game:GetService("ReplicatedStorage"):FindFirstChild(remoteInfo.name, true)
                end
            end)
            
            if remote and remote:IsA("RemoteEvent") then
                print("  Found remote, testing with trade data...")
                
                -- Try different data formats
                local testData = {
                    "trade",
                    "car",
                    {item = "car", trade = true},
                    Player,
                    "add_to_trade"
                }
                
                for _, data in ipairs(testData) do
                    local success = pcall(function()
                        remote:FireServer(data)
                        print("    ✅ Fired with: " .. tostring(data))
                        return true
                    end)
                    
                    if success then
                        wait(0.2)
                    end
                end
            end
        end
    end
    
    return #remotes
end

-- Create diagnostic UI
local function CreateDiagnosticUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeDiagnostic"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "TRADE DIAGNOSTIC TOOL"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(50, 70, 90)
    title.TextColor3 = Color3.fromRGB(255, 200, 100)
    title.Font = Enum.Font.GothamBold
    
    local output = Instance.new("ScrollingFrame")
    output.Size = UDim2.new(1, -20, 0, 180)
    output.Position = UDim2.new(0, 10, 0, 50)
    output.BackgroundColor3 = Color3.fromRGB(20, 30, 40)
    output.ScrollBarThickness = 8
    
    local outputText = Instance.new("TextLabel")
    outputText.Size = UDim2.new(1, 0, 5, 0)  -- Large for scrolling
    outputText.Position = UDim2.new(0, 5, 0, 5)
    outputText.BackgroundTransparency = 1
    outputText.TextColor3 = Color3.fromRGB(200, 230, 255)
    outputText.TextWrapped = true
    outputText.TextXAlignment = Enum.TextXAlignment.Left
    outputText.TextYAlignment = Enum.TextYAlignment.Top
    outputText.Font = Enum.Font.Code
    outputText.TextSize = 12
    outputText.Text = "Diagnostic tool loaded...\n"
    
    outputText.Parent = output
    
    -- Buttons
    local buttons = {
        {text = "🔍 SCAN REMOTES", func = ScanAllRemotes, color = Color3.fromRGB(70, 100, 140)},
        {text = "📍 FIND UI", func = FindTradeUI, color = Color3.fromRGB(70, 140, 100)},
        {text = "🔄 MANIPULATE", func = DirectTradeManipulation, color = Color3.fromRGB(140, 100, 70)},
        {text = "🧪 TEST REMOTES", func = TestRemotes, color = Color3.fromRGB(140, 70, 140)},
        {text = "🤝 ACCEPT", func = FindAndClickAccept, color = Color3.fromRGB(100, 140, 70)}
    }
    
    for i, btnInfo in ipairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.text
        btn.Size = UDim2.new(0.48, 0, 0, 30)
        btn.Position = UDim2.new(i % 2 == 1 and 0.01 or 0.51, 0, 0, 240 + math.floor((i-1)/2)*35)
        btn.BackgroundColor3 = btnInfo.color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        
        btn.MouseButton1Click:Connect(function()
            outputText.Text = "Running: " .. btnInfo.text .. "...\n" .. outputText.Text
            spawn(function()
                btnInfo.func()
                outputText.Text = "Completed: " .. btnInfo.text .. "\n" .. outputText.Text
            end)
        end)
        
        btn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    output.Parent = frame
    frame.Parent = gui
    
    -- Hook print to UI
    local originalPrint = print
    print = function(...)
        local args = {...}
        local message = table.concat(args, " ")
        originalPrint(message)
        outputText.Text = "> " .. message .. "\n" .. outputText.Text
    end
    
    return outputText
end

-- Initialize
CreateDiagnosticUI()

-- Auto-start scan
wait(3)
print("\n=== TRADE DIAGNOSTIC TOOL ===")
print("This will help us understand the trade system")
print("\n📋 RECOMMENDED STEPS:")
print("1. Click 'SCAN REMOTES' to find all remote events")
print("2. Click 'FIND UI' to locate trade interface")
print("3. Start a trade with another player")
print("4. Click 'MANIPULATE' to try duplication")
print("5. Share the output with me")

-- Run initial scans
spawn(function()
    wait(2)
    print("\n🔍 Running initial scans...")
    ScanAllRemotes()
    FindTradeUI()
end)

-- Keybinds
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.R then
        print("\n🎮 R KEY - SCANNING REMOTES")
        ScanAllRemotes()
    elseif input.KeyCode == Enum.KeyCode.T then
        print("\n🎮 T KEY - TRADE MANIPULATION")
        DirectTradeManipulation()
    end
end)

print("\n🔑 QUICK KEYS:")
print("R = Scan remotes")
print("T = Trade manipulation")
print("\n⚠️  Run this while in a trade for best results")
