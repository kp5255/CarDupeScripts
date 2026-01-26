-- 🛡️ ULTIMATE ADMIN PRIVILEGE ESCALATOR - FIXED VERSION
print("🛡️ ULTIMATE ADMIN ESCALATOR")
print("=" .. string.rep("=", 50))

-- SAFE SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

-- PLAYER
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- SAFE SCAN FUNCTION
local function safeScan()
    print("\n🔍 SAFE SCANNING FOR ADMIN SYSTEMS...")
    
    local foundSystems = {
        panels = {},
        remotes = {},
        scripts = {}
    }
    
    -- Scan ReplicatedStorage safely
    pcall(function()
        for _, child in pairs(ReplicatedStorage:GetDescendants()) do
            local nameLower = child.Name:lower()
            
            -- Look for admin panels (UIs)
            if child:IsA("ScreenGui") and nameLower:find("admin") then
                table.insert(foundSystems.panels, {
                    object = child,
                    path = child:GetFullName()
                })
                print("✅ Found Admin Panel: " .. child.Name)
            end
            
            -- Look for admin remotes
            if (child:IsA("RemoteFunction") or child:IsA("RemoteEvent")) and 
               (nameLower:find("admin") or nameLower:find("mod") or nameLower:find("rank")) then
                table.insert(foundSystems.remotes, {
                    object = child,
                    path = child:GetFullName(),
                    type = child.ClassName
                })
                print("✅ Found Admin Remote: " .. child.Name)
            end
        end
    end)
    
    -- Scan Workspace for terminals
    pcall(function()
        for _, child in pairs(Workspace:GetDescendants()) do
            if child:IsA("Part") and child.Name:lower():find("terminal") then
                print("✅ Found Terminal: " .. child.Name)
            end
        end
    end)
    
    return foundSystems
end

-- SIMPLE BYPASS METHODS
local bypassMethods = {}

-- Method 1: Simple admin data injection
bypassMethods.injectAdminData = function(remote)
    return function(...)
        local success, result = pcall(function()
            if remote:IsA("RemoteFunction") then
                -- Create admin data
                local adminData = {
                    UserId = Player.UserId,
                    Player = Player,
                    IsAdmin = true,
                    Rank = "Administrator",
                    Permissions = {"All"},
                    Timestamp = os.time()
                }
                
                -- Try with admin data
                return remote:InvokeServer(adminData, ...)
            else
                -- For RemoteEvents
                local adminData = {
                    UserId = Player.UserId,
                    IsAdmin = true
                }
                remote:FireServer(adminData, ...)
                return "Event fired with admin data"
            end
        end)
        return success, result
    end
end

-- Method 2: Permission override
bypassMethods.overridePermissions = function()
    print("🔓 Attempting permission override...")
    
    -- Add admin tag to player
    pcall(function()
        local tag = Instance.new("StringValue")
        tag.Name = "Admin"
        tag.Value = "True"
        tag.Parent = Player
        print("✅ Added Admin tag")
    end)
    
    -- Add to leaderstats
    pcall(function()
        local leaderstats = Player:FindFirstChild("leaderstats")
        if not leaderstats then
            leaderstats = Instance.new("Folder")
            leaderstats.Name = "leaderstats"
            leaderstats.Parent = Player
        end
        
        local rank = Instance.new("StringValue")
        rank.Name = "Rank"
        rank.Value = "Admin"
        rank.Parent = leaderstats
        print("✅ Added Admin rank")
    end)
    
    return true
end

-- CREATE SIMPLE ADMIN PANEL
local function createSimpleAdminPanel()
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Remove existing
    local existing = PlayerGui:FindFirstChild("SimpleAdminPanel")
    if existing then existing:Destroy() end
    
    -- Create GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleAdminPanel"
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BackgroundTransparency = 0.1
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🛡️ ADMIN ESCALATOR"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "Ready to escalate privileges..."
    Status.Size = UDim2.new(1, -20, 0, 30)
    Status.Position = UDim2.new(0, 10, 0, 45)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(150, 255, 150)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    
    -- Button creator
    local function createButton(text, yPos, color, callback)
        local Button = Instance.new("TextButton")
        Button.Text = text
        Button.Size = UDim2.new(1, -40, 0, 40)
        Button.Position = UDim2.new(0, 20, 0, yPos)
        Button.BackgroundColor3 = color
        Button.TextColor3 = Color3.new(1, 1, 1)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(function()
            Button.Text = "⏳"
            task.spawn(function()
                pcall(callback)
                task.wait(0.5)
                Button.Text = text
            end)
        end)
        
        return Button
    end
    
    -- Scan systems
    local foundSystems = {panels = {}, remotes = {}}
    
    -- Buttons
    local ScanButton = createButton("🔍 SCAN SYSTEMS", 80, Color3.fromRGB(60, 120, 200), function()
        Status.Text = "Scanning..."
        foundSystems = safeScan()
        Status.Text = "Found: " .. #foundSystems.panels .. " panels, " .. #foundSystems.remotes .. " remotes"
    end)
    
    local BypassButton = createButton("🔓 BYPASS CHECKS", 130, Color3.fromRGB(70, 180, 70), function()
        Status.Text = "Bypassing..."
        bypassMethods.overridePermissions()
        
        -- Try admin remotes
        for _, remoteInfo in pairs(foundSystems.remotes) do
            pcall(function()
                bypassMethods.injectAdminData(remoteInfo.object)()
                print("✅ Bypassed: " .. remoteInfo.object.Name)
            end)
        end
        
        Status.Text = "✅ Checks bypassed"
    end)
    
    local FlyButton = createButton("🚀 FLY MODE", 180, Color3.fromRGB(200, 120, 60), function()
        Status.Text = "Enabling fly..."
        
        -- Simple fly script
        local flyEnabled = false
        local bodyVelocity
        
        local function toggleFly()
            flyEnabled = not flyEnabled
            
            if flyEnabled then
                Status.Text = "Fly: ON"
                
                -- Create body velocity for flying
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                bodyVelocity.MaxForce = Vector3.new(40000, 40000, 40000)
                bodyVelocity.Parent = Player.Character.HumanoidRootPart
                
                -- Flying control
                game:GetService("RunService").RenderStepped:Connect(function()
                    if flyEnabled and bodyVelocity then
                        local cam = workspace.CurrentCamera
                        local root = Player.Character.HumanoidRootPart
                        
                        local forward = cam.CFrame.LookVector
                        local right = cam.CFrame.RightVector
                        
                        local speed = 50
                        local velocity = Vector3.new(0, 0, 0)
                        
                        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                            velocity = velocity + forward * speed
                        end
                        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                            velocity = velocity - forward * speed
                        end
                        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                            velocity = velocity - right * speed
                        end
                        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                            velocity = velocity + right * speed
                        end
                        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                            velocity = velocity + Vector3.new(0, speed, 0)
                        end
                        if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
                            velocity = velocity - Vector3.new(0, speed, 0)
                        end
                        
                        bodyVelocity.Velocity = velocity
                    end
                end)
            else
                Status.Text = "Fly: OFF"
                if bodyVelocity then
                    bodyVelocity:Destroy()
                end
            end
        end
        
        toggleFly()
    end)
    
    local NoclipButton = createButton("👻 NOCLIP", 230, Color3.fromRGB(160, 80, 200), function()
        Status.Text = "Toggling noclip..."
        
        local noclipEnabled = false
        local connection
        
        local function toggleNoclip()
            noclipEnabled = not noclipEnabled
            
            if noclipEnabled then
                Status.Text = "Noclip: ON"
                connection = game:GetService("RunService").Stepped:Connect(function()
                    if noclipEnabled then
                        for _, part in pairs(Player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            else
                Status.Text = "Noclip: OFF"
                if connection then
                    connection:Disconnect()
                end
            end
        end
        
        toggleNoclip()
    end)
    
    local SpeedButton = createButton("⚡ SPEED BOOST", 280, Color3.fromRGB(80, 180, 200), function()
        Status.Text = "Speed: 100"
        Player.Character.Humanoid.WalkSpeed = 100
    end)
    
    local JumpButton = createButton("🦘 JUMP BOOST", 330, Color3.fromRGB(200, 180, 80), function()
        Status.Text = "Jump: 150"
        Player.Character.Humanoid.JumpPower = 150
    end)
    
    local ChatButton = createButton("💬 ADMIN CHAT", 380, Color3.fromRGB(180, 80, 120), function()
        -- Try admin chat commands
        local commands = {
            "/admin",
            "/mod",
            "/cmdr",
            "/rank admin",
            "/privileges all"
        }
        
        for _, cmd in pairs(commands) do
            pcall(function()
                Player:Chat(cmd)
                print("Sent: " .. cmd)
            end)
            wait(0.5)
        end
        Status.Text = "Admin commands sent"
    end)
    
    -- Close button
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
    ScanButton.Parent = MainFrame
    BypassButton.Parent = MainFrame
    FlyButton.Parent = MainFrame
    NoclipButton.Parent = MainFrame
    SpeedButton.Parent = MainFrame
    JumpButton.Parent = MainFrame
    ChatButton.Parent = MainFrame
    CloseButton.Parent = Title
    MainFrame.Parent = ScreenGui
    ScreenGui.Parent = PlayerGui
    
    print("✅ Admin Panel created - Center screen")
    return ScreenGui
end

-- SIMPLE METATABLE HOOK (SAFE)
local function setupSafeHook()
    print("🛡️ Setting up safe hooks...")
    
    local success, result = pcall(function()
        -- Try to hook permission checks
        local mt = getrawmetatable(game)
        if mt then
            local oldIndex = mt.__index
            local oldNamecall = mt.__namecall
            
            -- Safe __index hook
            setreadonly(mt, false)
            mt.__index = newcclosure(function(self, key)
                -- Intercept admin checks
                if key == "IsAdmin" or key == "isAdmin" then
                    if self == Player then
                        print("✅ Admin check intercepted - returning true")
                        return true
                    end
                end
                
                if key == "Rank" or key == "rank" then
                    if self == Player then
                        return "Admin"
                    end
                end
                
                return oldIndex(self, key)
            end)
            
            -- Safe __namecall hook
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                
                -- Intercept permission checks
                if method:lower():find("check") or method:lower():find("verify") then
                    if self:IsA("RemoteFunction") and self.Name:lower():find("admin") then
                        print("✅ Permission check intercepted")
                        setnamecallmethod("InvokeServer")
                        return true, "Admin", 999
                    end
                end
                
                return oldNamecall(self, ...)
            end)
            
            setreadonly(mt, true)
            print("✅ Safe hooks installed")
            return true
        end
        return false
    end)
    
    return success, result
end

-- MAIN EXECUTION
print("\n" .. string.rep("🚀", 40))
print("STARTING ADMIN ESCALATION...")
print(string.rep("🚀", 40))

-- Create admin panel
task.wait(1)
local panel = createSimpleAdminPanel()

-- Setup safe hooks
task.wait(0.5)
setupSafeHook()

-- Initial scan
task.wait(0.5)
print("\n🔍 Performing initial scan...")
local foundSystems = safeScan()

-- Try bypass
task.wait(0.5)
print("\n🔓 Attempting bypass...")
bypassMethods.overridePermissions()

-- EXPORT SIMPLE SYSTEM
getgenv().AdminEscalator = {
    -- Basic functions
    scan = safeScan,
    bypass = bypassMethods.overridePermissions,
    hook = setupSafeHook,
    
    -- Admin commands
    fly = function()
        Player.Character.HumanoidRootPart.Anchored = false
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(40000, 40000, 40000)
        bv.Parent = Player.Character.HumanoidRootPart
    end,
    
    noclip = function()
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end,
    
    speed = function(value)
        Player.Character.Humanoid.WalkSpeed = value or 100
    end,
    
    jump = function(value)
        Player.Character.Humanoid.JumpPower = value or 150
    end,
    
    -- UI
    panel = createSimpleAdminPanel,
    
    -- Info
    info = function()
        return {
            player = Player.Name,
            userId = Player.UserId,
            panels = #foundSystems.panels,
            remotes = #foundSystems.remotes
        }
    end
}

-- FINAL MESSAGE
print("\n" .. string.rep("✅", 40))
print("ADMIN ESCALATOR READY!")
print(string.rep("✅", 40))

print("\n📊 SCAN RESULTS:")
print("Panels Found: " .. #foundSystems.panels)
print("Remotes Found: " .. #foundSystems.remotes)

print("\n🎮 AVAILABLE COMMANDS:")
print("AdminEscalator.scan() - Scan for admin systems")
print("AdminEscalator.bypass() - Bypass permission checks")
print("AdminEscalator.fly() - Enable flying")
print("AdminEscalator.noclip() - Enable noclip")
print("AdminEscalator.speed(100) - Set walk speed")
print("AdminEscalator.jump(150) - Set jump power")
print("AdminEscalator.panel() - Show admin panel")
print("AdminEscalator.info() - Get system info")

print("\n🛡️ FEATURES:")
print("• Safe scanning (no errors)")
print("• Permission bypass")
print("• Fly mode with WASD + Space/Shift")
print("• Noclip toggle")
print("• Speed/Jump boost")
print("• Admin chat commands")
print("• Safe metatable hooks")

print("\n🎯 ADMIN PANEL:")
print("• Center of screen")
print("• Click SCAN to find systems")
print("• Click BYPASS to get admin")
print("• Use other buttons for features")

print("\n⚠️ NOTE:")
print("Some features may not work if game has")
print("strong anti-cheat. Try different methods.")
