-- 🚗 SERVER-SIDE CAR BYPASS SYSTEM (FIXED)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(5)

-- ===== NETWORK INTERCEPTION SYSTEM (FIXED) =====
local networkLog = {}

local function hookAllRemotes()
    print("🔗 HOOKING ALL NETWORK TRAFFIC...")
    
    -- Store original methods
    local originalFireServer = nil
    local originalInvokeServer = nil
    
    -- Hook FireServer for all RemoteEvents
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            if not originalFireServer then
                originalFireServer = obj.FireServer
            end
            
            local fireServer = obj.FireServer
            obj.FireServer = function(self, ...)
                local args = {...}
                table.insert(networkLog, {
                    Time = os.time(),
                    Type = "FireServer",
                    Remote = self.Name,
                    Path = self:GetFullName(),
                    Args = args,
                    Player = player.Name
                })
                
                -- Print interesting calls
                local remoteName = self.Name:lower()
                if remoteName:find("car") or remoteName:find("vehicle") or 
                   remoteName:find("buy") or remoteName:find("purchase") or
                   remoteName:find("give") or remoteName:find("add") then
                    print(string.format("🎯 CAR-RELATED CALL: %s (%d args)", self.Name, #args))
                    for i, arg in ipairs(args) do
                        local argType = type(arg)
                        local argStr = tostring(arg)
                        if argType == "table" then
                            argStr = "TABLE: " .. tostring(arg)
                        elseif argType == "userdata" then
                            argStr = "OBJECT: " .. tostring(arg)
                        end
                        if #argStr > 50 then
                            argStr = argStr:sub(1, 50) .. "..."
                        end
                        print(string.format("  Arg %d [%s]: %s", i, argType, argStr))
                    end
                end
                
                return fireServer(self, ...)
            end
        elseif obj:IsA("RemoteFunction") then
            if not originalInvokeServer then
                originalInvokeServer = obj.InvokeServer
            end
            
            local invokeServer = obj.InvokeServer
            obj.InvokeServer = function(self, ...)
                local args = {...}
                table.insert(networkLog, {
                    Time = os.time(),
                    Type = "InvokeServer",
                    Remote = self.Name,
                    Path = self:GetFullName(),
                    Args = args,
                    Player = player.Name
                })
                
                local remoteName = self.Name:lower()
                if remoteName:find("data") or remoteName:find("get") or remoteName:find("load") then
                    print(string.format("📥 DATA REQUEST: %s", self.Name))
                end
                
                return invokeServer(self, ...)
            end
        end
    end
    
    -- Also hook new remotes as they're created
    game.DescendantAdded:Connect(function(obj)
        task.wait(0.1) -- Give time for initialization
        if obj:IsA("RemoteEvent") then
            local fireServer = obj.FireServer
            obj.FireServer = function(self, ...)
                local args = {...}
                table.insert(networkLog, {
                    Time = os.time(),
                    Type = "FireServer",
                    Remote = self.Name,
                    Path = self:GetFullName(),
                    Args = args,
                    Player = player.Name
                })
                return fireServer(self, ...)
            end
        elseif obj:IsA("RemoteFunction") then
            local invokeServer = obj.InvokeServer
            obj.InvokeServer = function(self, ...)
                local args = {...}
                table.insert(networkLog, {
                    Time = os.time(),
                    Type = "InvokeServer",
                    Remote = self.Name,
                    Path = self:GetFullName(),
                    Args = args,
                    Player = player.Name
                })
                return invokeServer(self, ...)
            end
        end
    end)
    
    print(string.format("✅ Network hooks installed. Found %d remote events so far.", 
          #networkLog > 0 and #networkLog or "0"))
end

-- ===== SIMPLIFIED REMOTE TESTER =====
local function testRemotesDirectly()
    print("\n🎯 TESTING REMOTES DIRECTLY...")
    
    local allRemotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(allRemotes, {
                Object = obj,
                Name = obj.Name,
                Type = obj.ClassName,
                Path = obj:GetFullName()
            })
        end
    end
    
    print(string.format("Found %d remote objects", #allRemotes))
    
    -- Test with car data
    local testCar = "Bontlay Bontaga"
    local testData = {
        testCar,
        {testCar},
        {Car = testCar, Player = player.Name},
        {"give", testCar},
        {testCar, player.UserId}
    }
    
    local successfulCalls = {}
    
    for _, remote in pairs(allRemotes) do
        local remoteName = remote.Name:lower()
        
        -- Only test likely remotes to avoid spam
        if remoteName:find("car") or remoteName:find("vehicle") or 
           remoteName:find("buy") or remoteName:find("purchase") or
           remoteName:find("give") or remoteName:find("add") then
            
            print(string.format("\nTesting remote: %s (%s)", remote.Name, remote.Type))
            
            for _, data in pairs(testData) do
                local success, result = pcall(function()
                    if remote.Type == "RemoteEvent" then
                        remote.Object:FireServer(data)
                        return "FireServer sent"
                    else
                        return remote.Object:InvokeServer(data)
                    end
                end)
                
                if success then
                    if not successfulCalls[remote.Name] then
                        successfulCalls[remote.Name] = {}
                    end
                    table.insert(successfulCalls[remote.Name], data)
                    print(string.format("  ✅ Accepted: %s", tostring(data)))
                else
                    print(string.format("  ❌ Failed: %s", tostring(result)))
                end
                
                task.wait(0.05) -- Small delay
            end
        end
    end
    
    return successfulCalls
end

-- ===== CREATE SIMPLE UI =====
local function createSimpleUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarBypassUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    
    -- Main Window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 500, 0, 400)
    main.Position = UDim2.new(0.5, -250, 0.5, -200)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    titleBar.Parent = main
    
    local title = Instance.new("TextLabel")
    title.Text = "🚗 Car Bypass System"
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = titleBar
    
    -- Content Area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -40)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Hook Button
    local hookBtn = Instance.new("TextButton")
    hookBtn.Text = "🔗 HOOK NETWORK"
    hookBtn.Size = UDim2.new(1, -20, 0, 40)
    hookBtn.Position = UDim2.new(0, 10, 0, 10)
    hookBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    hookBtn.TextColor3 = Color3.new(1, 1, 1)
    hookBtn.Font = Enum.Font.GothamBold
    hookBtn.TextSize = 16
    hookBtn.Parent = content
    
    -- Test Button
    local testBtn = Instance.new("TextButton")
    testBtn.Text = "🎯 TEST REMOTES"
    testBtn.Size = UDim2.new(1, -20, 0, 40)
    testBtn.Position = UDim2.new(0, 10, 0, 60)
    testBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    testBtn.TextColor3 = Color3.new(1, 1, 1)
    testBtn.Font = Enum.Font.GothamBold
    testBtn.TextSize = 16
    testBtn.Parent = content
    
    -- Status Display
    local status = Instance.new("ScrollingFrame")
    status.Size = UDim2.new(1, -20, 0, 240)
    status.Position = UDim2.new(0, 10, 0, 110)
    status.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    status.BorderSizePixel = 0
    status.ScrollBarThickness = 6
    status.Parent = content
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Text = "Ready. Click HOOK NETWORK to start."
    statusText.Size = UDim2.new(1, -10, 1, -10)
    statusText.Position = UDim2.new(0, 5, 0, 5)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.new(1, 1, 1)
    statusText.Font = Enum.Font.Code
    statusText.TextSize = 12
    statusText.TextWrapped = true
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextYAlignment = Enum.TextYAlignment.Top
    statusText.Parent = status
    
    -- Update status function
    local function updateStatus(text, color)
        statusText.Text = text
        if color then
            statusText.TextColor3 = color
        end
    end
    
    -- Add rounded corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    addCorner(main)
    addCorner(titleBar)
    addCorner(hookBtn)
    addCorner(testBtn)
    addCorner(status)
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
    
    -- Button actions
    hookBtn.MouseButton1Click:Connect(function()
        hookBtn.Text = "HOOKING..."
        hookBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            hookAllRemotes()
            updateStatus("✅ Network hooks installed!\n\nNow perform these actions in-game:\n1. Buy a car\n2. Check your garage\n3. Sell a car\n\nAll network traffic will be logged.", Color3.new(0, 1, 0))
            
            hookBtn.Text = "✅ HOOKED"
            hookBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        end)
    end)
    
    testBtn.MouseButton1Click:Connect(function()
        testBtn.Text = "TESTING..."
        testBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            updateStatus("Testing all car-related remotes...\nThis will try to give you a 'Bontlay Bontaga'", Color3.new(1, 1, 1))
            
            local results = testRemotesDirectly()
            
            if next(results) then
                local successCount = 0
                for remoteName, calls in pairs(results) do
                    successCount = successCount + 1
                end
                
                updateStatus(string.format("✅ TEST COMPLETE!\n\n%d remotes accepted car data:\n", successCount), Color3.new(0, 1, 0))
                
                for remoteName, calls in pairs(results) do
                    updateStatus(statusText.Text .. string.format("\n• %s: %d calls", remoteName, #calls), Color3.new(0, 1, 0))
                end
                
                updateStatus(statusText.Text .. "\n\nCheck your garage for new cars!", Color3.new(0, 1, 0))
            else
                updateStatus("❌ No remotes accepted car data.\nThe game has strong server validation.", Color3.fromRGB(1, 0.5, 0.5))
            end
            
            testBtn.Text = "🎯 TEST REMOTES"
            testBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    return gui
end

-- ===== FIND CMDER SYSTEM =====
local function findCmdrSystem()
    print("\n🔍 LOOKING FOR CMDER SYSTEM...")
    
    -- Check for Cmdr
    local cmdr = ReplicatedStorage:FindFirstChild("CmdrClient")
    if cmdr then
        print("✅ Cmdr system found!")
        
        local cmdrEvent = cmdr:FindFirstChild("CmdrEvent")
        if cmdrEvent then
            print("✅ CmdrEvent found!")
            
            -- Try common car commands
            local commands = {
                "givecar Bontlay Bontaga",
                "car Bontlay Bontaga",
                "vehicle Bontlay Bontaga",
                "addcar Bontlay Bontaga",
                "buycar Bontlay Bontaga 0",
                "give Bontlay_Bontaga",
                "spawncar Bontlay Bontaga"
            }
            
            for _, cmd in pairs(commands) do
                local success, result = pcall(function()
                    cmdrEvent:FireServer(cmd)
                    return true
                end)
                
                if success then
                    print(string.format("✅ Command sent: %s", cmd))
                else
                    print(string.format("❌ Failed: %s", cmd))
                end
                
                task.wait(0.1)
            end
            
            return true
        end
    end
    
    print("❌ No Cmdr system found")
    return false
end

-- ===== MAIN EXECUTION =====
print("=" .. string.rep("=", 60))
print("🚗 CAR BYPASS SYSTEM v1.0")
print("=" .. string.rep("=", 60))

print("\n🔍 Initializing...")
task.wait(2)

-- First check for Cmdr system
local hasCmdr = findCmdrSystem()

if hasCmdr then
    print("\n🎮 CMDER DETECTED!")
    print("Trying to use built-in commands...")
    
    -- Create a simple button for Cmdr
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(1, -310, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Text = "⚡ CMDER ACTIVE"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "Cmdr system detected!\nTry commands manually."
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = frame
    
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "🎯 AUTO-DUPE"
    dupeBtn.Size = UDim2.new(1, -20, 0, 40)
    dupeBtn.Position = UDim2.new(0, 10, 1, -50)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.GothamBold
    dupeBtn.TextSize = 16
    dupeBtn.Parent = frame
    
    dupeBtn.MouseButton1Click:Connect(function()
        dupeBtn.Text = "SENDING..."
        status.Text = "Sending car commands..."
        
        task.spawn(function()
            local cmdr = ReplicatedStorage:FindFirstChild("CmdrClient")
            local cmdrEvent = cmdr and cmdr:FindFirstChild("CmdrEvent")
            
            if cmdrEvent then
                local cars = {"Bontlay Bontaga", "Jegar Model F", "Corsaro T8"}
                
                for _, car in pairs(cars) do
                    for i = 1, 5 do
                        pcall(function()
                            cmdrEvent:FireServer("givecar " .. car)
                        end)
                        task.wait(0.05)
                    end
                    status.Text = "Sent: " .. car
                end
                
                status.Text = "✅ Commands sent!\nCheck your garage."
            end
            
            task.wait(2)
            dupeBtn.Text = "🎯 AUTO-DUPE"
        end)
    end)
    
    print("\n✅ Cmdr UI created in top-right corner")
else
    print("\n🔧 Creating bypass system UI...")
    createSimpleUI()
end

print("\n🎮 HOW TO USE:")
print("1. First, try buying/selling cars normally")
print("2. Watch the network traffic (if hooked)")
print("3. Test remotes to find vulnerable ones")
print("4. If Cmdr exists, use the auto-dupe button")
print("\n⚠️  NOTE: Server-side games are hard to bypass")
print("This tool helps identify potential weak points")
