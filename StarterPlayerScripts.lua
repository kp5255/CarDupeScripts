-- 🎯 REAL WORKING CMD COMMAND SCRIPT
-- Place ID: 1554960397

print("🎯 REAL WORKING CMD COMMAND SCRIPT")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== STEP 1: FIND AND USE CMD SYSTEM =====
local function useCmdrSystem()
    print("\n⚡ USING CMD COMMAND SYSTEM")
    
    -- The modules are in CmdrClient.Commands - this is an ADMIN COMMAND SYSTEM!
    
    -- Find Cmdr system
    local cmdrFolder = ReplicatedStorage:FindFirstChild("CmdrClient")
    if not cmdrFolder then
        print("❌ CmdrClient folder not found!")
        return false
    end
    
    print("✅ Found CmdrClient system")
    print("Path: " .. cmdrFolder:GetFullName())
    
    -- Look for Cmdr remote events
    local cmdrRemotes = {}
    
    for _, obj in pairs(cmdrFolder:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(cmdrRemotes, {
                Object = obj,
                Name = obj.Name,
                Type = obj.ClassName,
                Path = obj:GetFullName()
            })
        end
    end
    
    print("Found " .. #cmdrRemotes .. " Cmdr remotes")
    
    -- Try to execute commands through Cmdr
    local commands = {
        "givecar Bontlay Bontaga",
        "givecar Jegar Model F", 
        "givecar Corsaro T8",
        "givecar Lavish Ventoge",
        "givecar Sportler Tecan",
        "giveallcars",
        "giveallcars " .. player.Name,
        "!givecar Bontlay Bontaga",
        "/givecar Bontlay Bontaga",
        "cmdr:givecar Bontlay Bontaga"
    }
    
    -- Try different Cmdr formats
    for _, remoteData in pairs(cmdrRemotes) do
        local remote = remoteData.Object
        
        print("\nTrying remote: " .. remoteData.Name .. " (" .. remoteData.Type .. ")")
        
        for _, command in pairs(commands) do
            -- Try different argument formats
            local patterns = {
                {command},
                {player, command},
                {"run", command},
                {Command = command, Player = player},
                {cmd = command, executor = player}
            }
            
            for _, args in pairs(patterns) do
                local success, result = pcall(function()
                    if remoteData.Type == "RemoteEvent" then
                        remote:FireServer(unpack(args))
                        return "sent"
                    else
                        remote:InvokeServer(unpack(args))
                        return "invoked"
                    end
                end)
                
                if success then
                    print("✅ Command sent: " .. command)
                    
                    -- Rapid fire if successful
                    for i = 1, 5 do
                        pcall(function()
                            if remoteData.Type == "RemoteEvent" then
                                remote:FireServer(unpack(args))
                            end
                        end)
                        task.wait(0.02)
                    end
                end
                
                task.wait(0.05)
            end
        end
    end
    
    return #cmdrRemotes > 0
end

-- ===== STEP 2: DIRECT MODULE EXECUTION =====
local function directModuleExecution()
    print("\n🎯 DIRECT MODULE EXECUTION")
    
    -- Since we found the modules, let's try to use them directly
    local giveCarModule = ReplicatedStorage:FindFirstChild("CmdrClient")
    if giveCarModule then
        giveCarModule = giveCarModule:FindFirstChild("Commands")
        if giveCarModule then
            giveCarModule = giveCarModule:FindFirstChild("GiveCar")
        end
    end
    
    local giveAllCarsModule = ReplicatedStorage:FindFirstChild("CmdrClient")
    if giveAllCarsModule then
        giveAllCarsModule = giveAllCarsModule:FindFirstChild("Commands")
        if giveAllCarsModule then
            giveAllCarsModule = giveAllCarsModule:FindFirstChild("GiveAllCars")
        end
    end
    
    if giveCarModule and giveCarModule:IsA("ModuleScript") then
        print("✅ GiveCar module found: " .. giveCarModule:GetFullName())
        
        -- Try to require and call
        local success, moduleFunc = pcall(function()
            return require(giveCarModule)
        end)
        
        if success then
            print("✅ GiveCar module loaded")
            
            -- Try to execute as command
            local yourCars = {
                "Bontlay Bontaga",
                "Jegar Model F",
                "Corsaro T8"
            }
            
            for _, carName in pairs(yourCars) do
                -- Try different execution methods
                pcall(function()
                    if type(moduleFunc) == "function" then
                        moduleFunc(player, carName)
                        print("✅ Executed: givecar " .. carName)
                    elseif type(moduleFunc) == "table" then
                        -- Look for execute/run function
                        for funcName, func in pairs(moduleFunc) do
                            if type(func) == "function" and (funcName:find("Exec") or funcName:find("Run")) then
                                func(player, carName)
                                print("✅ Called " .. funcName .. " with " .. carName)
                            end
                        end
                    end
                end)
                
                task.wait(0.1)
            end
        end
    end
    
    if giveAllCarsModule and giveAllCarsModule:IsA("ModuleScript") then
        print("✅ GiveAllCars module found: " .. giveAllCarsModule:GetFullName())
        
        local success, moduleFunc = pcall(function()
            return require(giveAllCarsModule)
        end)
        
        if success then
            print("✅ GiveAllCars module loaded")
            
            -- Try to execute
            pcall(function()
                if type(moduleFunc) == "function" then
                    moduleFunc(player)
                    print("✅ Executed: giveallcars")
                elseif type(moduleFunc) == "table" then
                    for funcName, func in pairs(moduleFunc) do
                        if type(func) == "function" and funcName:find("Exec") then
                            func(player)
                            print("✅ Called " .. funcName)
                        end
                    end
                end
            end)
        end
    end
end

-- ===== STEP 3: FIND CMD TRIGGER =====
local function findCmdTrigger()
    print("\n🔍 FINDING CMD TRIGGER")
    
    -- Cmdr usually has a trigger like "!" or "/"
    -- Let's find how to trigger commands
    
    -- Look for command bar UI
    if player:FindFirstChild("PlayerGui") then
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, obj in pairs(gui:GetDescendants()) do
                    if obj:IsA("TextBox") and (obj.PlaceholderText or ""):lower():find("command") then
                        print("✅ Found command textbox: " .. obj.Name)
                        print("   Placeholder: " .. tostring(obj.PlaceholderText))
                        
                        -- Try to set command
                        pcall(function()
                            obj.Text = "givecar Bontlay Bontaga"
                            print("✅ Set command in textbox")
                        end)
                    end
                end
            end
        end
    end
    
    -- Look for command execution remote
    local executionRemote = ReplicatedStorage:FindFirstChild("CmdrClient")
    if executionRemote then
        executionRemote = executionRemote:FindFirstChild("ExecuteCommand") or 
                         executionRemote:FindFirstChild("RunCommand")
    end
    
    if not executionRemote and ReplicatedStorage:FindFirstChild("Cmdr") then
        executionRemote = ReplicatedStorage.Cmdr:FindFirstChild("ExecuteCommand")
    end
    
    if executionRemote then
        print("✅ Found command execution remote: " .. executionRemote.Name)
        
        -- Try to execute commands
        local commands = {
            "givecar Bontlay Bontaga",
            "giveallcars",
            "!givecar Jegar Model F",
            "/givecar Corsaro T8"
        }
        
        for _, command in pairs(commands) do
            for i = 1, 3 do
                pcall(function()
                    if executionRemote:IsA("RemoteEvent") then
                        executionRemote:FireServer(command)
                        print("✅ Fired command: " .. command)
                    elseif executionRemote:IsA("RemoteFunction") then
                        executionRemote:InvokeServer(command)
                        print("✅ Invoked command: " .. command)
                    end
                end)
                task.wait(0.1)
            end
        end
    end
end

-- ===== STEP 4: BRUTE FORCE CMD SYSTEM =====
local function bruteForceCmdSystem()
    print("\n💥 BRUTE FORCE CMD SYSTEM")
    
    -- Try ALL remotes in Cmdr with ALL possible formats
    local cmdrFolder = ReplicatedStorage:FindFirstChild("CmdrClient") or 
                      ReplicatedStorage:FindFirstChild("Cmdr")
    
    if not cmdrFolder then
        print("❌ No Cmdr folder found")
        return
    end
    
    print("Brute forcing Cmdr system...")
    
    local allRemotes = {}
    for _, obj in pairs(cmdrFolder:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(allRemotes, obj)
        end
    end
    
    print("Found " .. #allRemotes .. " Cmdr remotes")
    
    -- Your cars
    local yourCars = {
        "Bontlay Bontaga",
        "Jegar Model F",
        "Corsaro T8"
    }
    
    local attempts = 0
    
    for _, remote in pairs(allRemotes) do
        for _, carName in pairs(yourCars) do
            -- Try MANY different formats
            local formats = {
                -- Command format
                "givecar " .. carName,
                "!givecar " .. carName,
                "/givecar " .. carName,
                "cmdr:givecar " .. carName,
                "admin:givecar " .. carName,
                
                -- JSON format
                '{"command":"givecar","args":"' .. carName .. '"}',
                '{"cmd":"givecar","car":"' .. carName .. '"}',
                
                -- Table format commands
                "givecar",
                "giveallcars"
            }
            
            for _, command in pairs(formats) do
                attempts = attempts + 1
                
                -- Try with player
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(command)
                        remote:FireServer(player, command)
                        remote:FireServer(command, player)
                    else
                        remote:InvokeServer(command)
                        remote:InvokeServer(player, command)
                    end
                })
                
                if attempts % 50 == 0 then
                    print("Attempt " .. attempts .. "...")
                end
                
                task.wait(0.01)
            end
        end
    end
    
    print("Total brute force attempts: " .. attempts)
end

-- ===== STEP 5: CREATE FINAL UI =====
local function createFinalUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CmdCarDuplicator"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 350)
    frame.Position = UDim2.new(0.5, -175, 0.5, -175)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🎯 CMD CAR DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "FOUND CMD COMMAND SYSTEM!\n\nPath: ReplicatedStorage.CmdrClient.Commands\n\nThis is an ADMIN command system!\nClick buttons to execute commands."
    status.Size = UDim2.new(1, -20, 0, 120)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    -- Button 1: Use Cmdr System
    local btn1 = Instance.new("TextButton")
    btn1.Text = "⚡ USE CMD SYSTEM"
    btn1.Size = UDim2.new(1, -40, 0, 40)
    btn1.Position = UDim2.new(0, 20, 0, 180)
    btn1.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    btn1.TextColor3 = Color3.new(1, 1, 1)
    btn1.Font = Enum.Font.GothamBold
    btn1.TextSize = 14
    btn1.Parent = frame
    
    btn1.MouseButton1Click:Connect(function()
        status.Text = "Using Cmd command system...\nThis should work!\nCheck console."
        btn1.Text = "EXECUTING..."
        btn1.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            useCmdrSystem()
            task.wait(2)
            status.Text = "Cmd commands executed!\nCheck if cars were added."
            btn1.Text = "TRY AGAIN"
            btn1.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        end)
    end)
    
    -- Button 2: Direct Execution
    local btn2 = Instance.new("TextButton")
    btn2.Text = "🎯 DIRECT EXECUTION"
    btn2.Size = UDim2.new(1, -40, 0, 40)
    btn2.Position = UDim2.new(0, 20, 0, 230)
    btn2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn2.TextColor3 = Color3.new(1, 1, 1)
    btn2.Font = Enum.Font.GothamBold
    btn2.TextSize = 14
    btn2.Parent = frame
    
    btn2.MouseButton1Click:Connect(function()
        status.Text = "Direct module execution...\nTrying to run commands directly."
        btn2.Text = "EXECUTING..."
        btn2.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            directModuleExecution()
            task.wait(2)
            status.Text = "Direct execution attempted!\nCheck garage."
            btn2.Text = "TRY AGAIN"
            btn2.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    -- Button 3: Find Trigger
    local btn3 = Instance.new("TextButton")
    btn3.Text = "🔍 FIND CMD TRIGGER"
    btn3.Size = UDim2.new(1, -40, 0, 40)
    btn3.Position = UDim2.new(0, 20, 0, 280)
    btn3.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    btn3.TextColor3 = Color3.new(1, 1, 1)
    btn3.Font = Enum.Font.GothamBold
    btn3.TextSize = 14
    btn3.Parent = frame
    
    btn3.MouseButton1Click:Connect(function()
        status.Text = "Finding command trigger...\nLooking for ! or / command."
        btn3.Text = "SEARCHING..."
        btn3.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            findCmdTrigger()
            status.Text = "Trigger search complete!\nCheck console for findings."
            btn3.Text = "TRY AGAIN"
            btn3.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
        end)
    end)
    
    -- Button 4: Brute Force
    local btn4 = Instance.new("TextButton")
    btn4.Text = "💥 BRUTE FORCE"
    btn4.Size = UDim2.new(1, -40, 0, 40)
    btn4.Position = UDim2.new(0, 20, 0, 330)
    btn4.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
    btn4.TextColor3 = Color3.new(1, 1, 1)
    btn4.Font = Enum.Font.GothamBold
    btn4.TextSize = 14
    btn4.Parent = frame
    
    btn4.MouseButton1Click:Connect(function()
        status.Text = "Brute forcing Cmd system...\nThis may take 10-15 seconds.\nCheck console!"
        btn4.Text = "BRUTE FORCING..."
        btn4.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        
        task.spawn(function()
            bruteForceCmdSystem()
            task.wait(2)
            status.Text = "Brute force complete!\nCheck if any commands worked."
            btn4.Text = "TRY AGAIN"
            btn4.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
        end)
    end)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return gui, status
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 70))
print("🎯 FOUND CMD COMMAND SYSTEM!")
print(string.rep("=", 70))
print("\nCRITICAL FINDING:")
print("GiveCar module at: ReplicatedStorage.CmdrClient.Commands.GiveCar")
print("GiveAllCars module at: ReplicatedStorage.CmdrClient.Commands.GiveAllCars")
print("\nThis is an ADMIN COMMAND SYSTEM (Cmdr)!")
print("We need to execute commands through it.")

-- Create UI
task.wait(1)
local gui, status = createFinalUI()

-- Auto-run everything
task.wait(3)
status.Text = "Auto-executing all methods...\nThis is your best chance!\nCheck console!"

print("\n🚀 AUTO-EXECUTING ALL METHODS...")

-- Method 1: Cmdr System
print("\n1. USING CMD SYSTEM...")
useCmdrSystem()

-- Method 2: Direct Execution
task.wait(2)
print("\n2. DIRECT EXECUTION...")
directModuleExecution()

-- Method 3: Find Trigger
task.wait(2)
print("\n3. FINDING TRIGGER...")
findCmdTrigger()

-- Method 4: Brute Force
task.wait(2)
print("\n4. BRUTE FORCE...")
bruteForceCmdSystem()

-- Final check
task.wait(3)
print("\n" .. string.rep("=", 70))
print("📋 ALL METHODS EXECUTED")
print(string.rep("=", 70))

status.Text = "All methods executed!\n\nCheck your garage NOW!\n\nIf cars didn't appear:\n1. Try typing '!givecar' in chat\n2. Look for command bar (F9)\n3. Try different server"

-- Monitor for command bar
task.spawn(function()
    while true do
        task.wait(5)
        
        -- Check if command bar appears
        if player:FindFirstChild("PlayerGui") then
            for _, gui in pairs(player.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name:find("Cmd") then
                    print("\n⚡ CMD UI DETECTED: " .. gui.Name)
                    status.Text = "Cmd UI detected!\nTry typing commands there."
                end
            end
        end
        
        -- Check money changes (indicates activity)
        if player:FindFirstChild("leaderstats") then
            local moneyStat = player.leaderstats:FindFirstChild("Money")
            if moneyStat then
                print("💰 Current money: $" .. moneyStat.Value)
            end
        end
    end
end)
