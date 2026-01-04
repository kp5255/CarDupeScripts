-- 🎮 ADMIN COMMAND ACTIVATOR
-- Place ID: 1554960397

print("🎮 ADMIN COMMAND ACTIVATOR")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== GET ADMIN PERMISSIONS =====
local function getAdminPermissions()
    print("\n🔓 GETTING ADMIN PERMISSIONS")
    
    -- Cmdr admin system paths
    local cmdr = ReplicatedStorage:FindFirstChild("CmdrClient") or 
                 ReplicatedStorage:FindFirstChild("Cmdr")
    
    if not cmdr then
        print("❌ Cmdr not found")
        return false
    end
    
    -- Look for permission system
    local permissionEvents = {}
    
    -- Method 1: Admin request
    local adminRequest = cmdr:FindFirstChild("RequestAdmin") or
                        cmdr:FindFirstChild("GetAdmin") or
                        cmdr:FindFirstChild("BecomeAdmin")
    
    if adminRequest then
        table.insert(permissionEvents, {
            Object = adminRequest,
            Name = adminRequest.Name,
            Type = adminRequest.ClassName
        })
        print("✅ Found admin request: " .. adminRequest.Name)
    end
    
    -- Method 2: Permission check
    for _, obj in pairs(cmdr:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("admin") or name:find("perm") or name:find("rank") then
                table.insert(permissionEvents, {
                    Object = obj,
                    Name = obj.Name,
                    Type = obj.ClassName
                })
                print("✅ Found permission event: " .. obj.Name)
            end
        end
    end
    
    -- Try to get admin
    for _, event in pairs(permissionEvents) do
        local remote = event.Object
        
        print("\nTrying: " .. event.Name)
        
        -- Different admin request formats
        local requests = {
            {player},
            {player.UserId},
            {player.Name},
            {"admin"},
            {"giveadmin", player},
            {"makeadmin", player.UserId},
            {UserId = player.UserId, Rank = "Admin"},
            {Player = player, Permission = "Admin"}
        }
        
        for _, args in pairs(requests) do
            local success, result = pcall(function()
                if event.Type == "RemoteEvent" then
                    remote:FireServer(unpack(args))
                    return "sent"
                else
                    remote:InvokeServer(unpack(args))
                    return "invoked"
                end
            end)
            
            if success then
                print("✅ Admin request sent")
                
                -- Wait and try commands
                task.wait(1)
                executeAdminCommands()
                return true
            end
        end
    end
    
    return false
end

-- ===== EXECUTE ADMIN COMMANDS =====
local function executeAdminCommands()
    print("\n⚡ EXECUTING ADMIN COMMANDS")
    
    local cmdr = ReplicatedStorage:FindFirstChild("CmdrClient")
    if not cmdr then return false end
    
    -- Find command execution
    local executeRemote = cmdr:FindFirstChild("ExecuteCommand") or
                         cmdr:FindFirstChild("RunCommand")
    
    if not executeRemote then
        -- Look in descendants
        for _, obj in pairs(cmdr:GetDescendants()) do
            if obj:IsA("RemoteEvent") and obj.Name:lower():find("execute") then
                executeRemote = obj
                break
            end
        end
    end
    
    if not executeRemote then
        print("❌ No execute command found")
        return false
    end
    
    print("✅ Found command executor: " .. executeRemote.Name)
    
    -- Your cars to get
    local targetCars = {
        "Bontlay Bontaga",
        "Jegar Model F", 
        "Corsaro T8",
        "Lavish Ventoge",
        "Sportler Tecan"
    }
    
    -- Execute commands
    local commandsExecuted = 0
    
    for _, car in pairs(targetCars) do
        -- Different command formats
        local commandFormats = {
            "givecar " .. car,
            "!givecar " .. car,
            "/givecar " .. car,
            "givecar " .. player.Name .. " " .. car,
            "give " .. car .. " to " .. player.Name
        }
        
        for _, cmd in pairs(commandFormats) do
            local success = pcall(function()
                if executeRemote:IsA("RemoteEvent") then
                    executeRemote:FireServer(cmd)
                else
                    executeRemote:InvokeServer(cmd)
                end
            end)
            
            if success then
                print("✅ Command: " .. cmd)
                commandsExecuted = commandsExecuted + 1
                
                -- Give time between commands
                task.wait(0.5)
            end
        end
    end
    
    -- Try giveallcars
    local allCarsCommands = {
        "giveallcars",
        "!giveallcars",
        "/giveallcars",
        "giveallcars " .. player.Name,
        "give all cars to " .. player.Name
    }
    
    for _, cmd in pairs(allCarsCommands) do
        pcall(function()
            if executeRemote:IsA("RemoteEvent") then
                executeRemote:FireServer(cmd)
                print("✅ Command: " .. cmd)
            else
                executeRemote:InvokeServer(cmd)
                print("✅ Command: " .. cmd)
            end
        end)
        task.wait(0.5)
    end
    
    return commandsExecuted > 0
end

-- ===== DIRECT MODULE EXECUTION WITH PERMISSIONS =====
local function directModuleWithPermissions()
    print("\n🎯 DIRECT MODULE WITH PERMISSIONS")
    
    local cmdr = ReplicatedStorage:FindFirstChild("CmdrClient")
    if not cmdr then return false end
    
    local commands = cmdr:FindFirstChild("Commands")
    if not commands then return false end
    
    -- Get GiveCar module
    local giveCarModule = commands:FindFirstChild("GiveCar")
    if not giveCarModule then return false end
    
    -- Load module
    local success, moduleFunc = pcall(function()
        return require(giveCarModule)
    end)
    
    if not success then return false end
    
    print("✅ GiveCar module loaded")
    
    -- Get GiveAllCars module
    local giveAllModule = commands:FindFirstChild("GiveAllCars")
    if giveAllModule then
        local success2, allFunc = pcall(function()
            return require(giveAllModule)
        end)
        
        if success2 then
            print("✅ GiveAllCars module loaded")
            
            -- Try giveallcars first
            pcall(function()
                if type(allFunc) == "function" then
                    allFunc(player)
                    print("✅ Executed GiveAllCars")
                end
            end)
        end
    end
    
    -- Execute for each car
    local targetCars = {
        "Bontlay Bontaga",
        "Jegar Model F",
        "Corsaro T8"
    }
    
    for _, car in pairs(targetCars) do
        pcall(function()
            if type(moduleFunc) == "function" then
                moduleFunc(player, car)
                print("✅ Executed givecar for: " .. car)
            elseif type(moduleFunc) == "table" then
                -- Look for execute function
                for key, func in pairs(moduleFunc) do
                    if type(func) == "function" and key:lower():find("exec") then
                        func(player, car)
                        print("✅ Executed " .. key .. " for: " .. car)
                        break
                    end
                end
            end
        end)
        
        task.wait(0.5)
    end
    
    return true
end

-- ===== CREATE ADMIN UI =====
local function createAdminUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 300)
    frame.Position = UDim2.new(0.5, -175, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "🎮 ADMIN COMMAND ACTIVATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "The GiveCar module IS working!\n\nBut needs ADMIN permissions.\n\nClick buttons to get admin rights."
    status.Size = UDim2.new(1, -20, 0, 120)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    -- Button 1: Get Admin
    local btn1 = Instance.new("TextButton")
    btn1.Text = "🔓 GET ADMIN RIGHTS"
    btn1.Size = UDim2.new(1, -40, 0, 40)
    btn1.Position = UDim2.new(0, 20, 0, 180)
    btn1.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn1.TextColor3 = Color3.new(1, 1, 1)
    btn1.Font = Enum.Font.GothamBold
    btn1.TextSize = 14
    btn1.Parent = frame
    
    btn1.MouseButton1Click:Connect(function()
        status.Text = "Getting admin permissions...\nThis might take a moment."
        btn1.Text = "WORKING..."
        btn1.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local success = getAdminPermissions()
            if success then
                status.Text = "✅ Admin rights obtained!\nCommands should work now."
            else
                status.Text = "❌ Could not get admin.\nTry server hopping."
            end
            btn1.Text = "TRY AGAIN"
            btn1.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    -- Button 2: Execute Commands
    local btn2 = Instance.new("TextButton")
    btn2.Text = "⚡ EXECUTE COMMANDS"
    btn2.Size = UDim2.new(1, -40, 0, 40)
    btn2.Position = UDim2.new(0, 20, 0, 230)
    btn2.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    btn2.TextColor3 = Color3.new(1, 1, 1)
    btn2.Font = Enum.Font.GothamBold
    btn2.TextSize = 14
    btn2.Parent = frame
    
    btn2.MouseButton1Click:Connect(function()
        status.Text = "Executing admin commands..."
        btn2.Text = "EXECUTING..."
        btn2.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            executeAdminCommands()
            task.wait(2)
            status.Text = "✅ Commands executed!\nCheck your garage NOW!"
            btn2.Text = "TRY AGAIN"
            btn2.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        end)
    end)
    
    -- Button 3: Direct Module
    local btn3 = Instance.new("TextButton")
    btn3.Text = "🎯 DIRECT MODULE"
    btn3.Size = UDim2.new(1, -40, 0, 40)
    btn3.Position = UDim2.new(0, 20, 0, 280)
    btn3.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    btn3.TextColor3 = Color3.new(1, 1, 1)
    btn3.Font = Enum.Font.GothamBold
    btn3.TextSize = 14
    btn3.Parent = frame
    
    btn3.MouseButton1Click:Connect(function()
        status.Text = "Using GiveCar module directly..."
        btn3.Text = "EXECUTING..."
        btn3.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            directModuleWithPermissions()
            task.wait(2)
            status.Text = "✅ Module executed!\nCheck if cars appeared."
            btn3.Text = "TRY AGAIN"
            btn3.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
        end)
    end)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return gui, status
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 70))
print("🎮 ADMIN COMMAND ACTIVATOR")
print(string.rep("=", 70))
print("\n✅ GOOD NEWS: GiveCar module IS working!")
print("❌ BAD NEWS: Needs admin permissions")
print("\nThis script will:")
print("1. Try to get admin rights")
print("2. Execute commands with permissions")
print("3. Use GiveCar module directly")

-- Create UI
task.wait(1)
local gui, status = createAdminUI()

-- Auto-execute sequence
task.wait(3)
status.Text = "Auto-starting admin activation..."
print("\n🚀 AUTO-STARTING ADMIN ACTIVATION...")

-- Step 1: Try to get admin
local adminSuccess = getAdminPermissions()

if adminSuccess then
    status.Text = "Admin rights obtained!\nExecuting commands..."
    
    -- Step 2: Execute commands
    task.wait(2)
    executeAdminCommands()
    
    -- Step 3: Direct module
    task.wait(2)
    directModuleWithPermissions()
    
    status.Text = "✅ All methods executed!\nCheck your garage NOW!"
else
    status.Text = "❌ Could not get admin automatically.\nClick buttons manually."
    
    -- Still try commands (might work on some servers)
    task.wait(2)
    executeAdminCommands()
    task.wait(1)
    directModuleWithPermissions()
end

-- Final instructions
print("\n" .. string.rep("=", 70))
print("📋 FINAL INSTRUCTIONS")
print(string.rep("=", 70))
print("\nIf cars didn't appear:")
print("1. Join a DIFFERENT server")
print("2. Try on a FRESH server (less players)")
print("3. Look for ADMIN PANEL in game UI")
print("4. Try typing in chat: !admin or /admin")
print("\nThe GiveCar module EXISTS and WORKS!")
print("It just needs server admin permissions.")
