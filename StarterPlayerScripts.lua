-- ADMIN PANEL EXPLOIT (FIXED)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🔍 ADMIN PANEL EXPLOIT")

-- SAFE: Check if admin panel exists without WaitForChild
local function findAdminPanel()
    print("Searching for admin panel...")
    
    local menu = StarterGui:FindFirstChild("Menu")
    if not menu then
        print("❌ 'Menu' not found in StarterGui")
        return nil
    end
    
    local pages = menu:FindFirstChild("Pages")
    if not pages then
        print("❌ 'Pages' not found in Menu")
        return nil
    end
    
    local adminPanel = pages:FindFirstChild("AdminPanel")
    if not adminPanel then
        print("❌ 'AdminPanel' not found in Pages")
        return nil
    end
    
    print("✅ Found AdminPanel!")
    print("Path: StarterGui.Menu.Pages.AdminPanel")
    
    -- List contents
    print("\n📂 Admin Panel Contents:")
    for _, child in pairs(adminPanel:GetChildren()) do
        print("  • " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    
    return adminPanel
end

-- Find admin panel
local AdminPanel = findAdminPanel()

-- Check IsLegacyAdmin
local IsLegacyAdmin = ReplicatedStorage:FindFirstChild("IsLegacyAdmin")
if IsLegacyAdmin then
    print("\n✅ Found IsLegacyAdmin (" .. IsLegacyAdmin.ClassName .. ")")
else
    print("\n❌ IsLegacyAdmin not found")
end

-- METHOD 1: CLONE ADMIN PANEL TO PLAYERGUI
local function cloneAdminPanel()
    print("\n📋 CLONING ADMIN PANEL...")
    
    if not AdminPanel then
        print("❌ No admin panel found to clone")
        return
    end
    
    -- Remove old clone
    local oldClone = LocalPlayer.PlayerGui:FindFirstChild("AdminPanelClone")
    if oldClone then
        oldClone:Destroy()
    end
    
    -- Clone the admin panel
    local clone = AdminPanel:Clone()
    clone.Name = "AdminPanelClone"
    
    -- Make it visible and enabled
    clone.Visible = true
    clone.Enabled = true
    
    -- Position it nicely
    if clone:IsA("Frame") or clone:IsA("ScrollingFrame") then
        clone.Position = UDim2.new(0.5, -150, 0.5, -100)
        clone.Size = UDim2.new(0, 300, 0, 200)
    end
    
    clone.Parent = LocalPlayer.PlayerGui
    
    print("✅ Admin panel cloned to your screen!")
    print("Look for 'AdminPanelClone' in your GUI")
    
    -- Enable all buttons in clone
    local enabledCount = 0
    for _, button in pairs(clone:GetDescendants()) do
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            button.Active = true
            button.Visible = true
            enabledCount = enabledCount + 1
        end
    end
    
    print("Enabled " .. enabledCount .. " buttons")
end

-- METHOD 2: SEARCH FOR ADMIN COMMANDS IN SCRIPTS
local function searchAdminScripts()
    print("\n🔍 SEARCHING SCRIPTS FOR ADMIN COMMANDS...")
    
    local foundCommands = {}
    
    -- Search in key locations
    local locations = {
        game:GetService("ServerScriptService"),
        game:GetService("ServerStorage"),
        ReplicatedStorage,
        game:GetService("Workspace")
    }
    
    for _, location in pairs(locations) do
        for _, script in pairs(location:GetDescendants()) do
            if script:IsA("Script") or script:IsA("LocalScript") then
                pcall(function()
                    local source = script.Source
                    
                    -- Look for admin command patterns
                    local patterns = {
                        "givecar", "!give", "admincmd", "spawncar",
                        "unlockall", "givemoney", "addmoney", "freecars",
                        "IsLegacyAdmin", "CheckAdmin", "IsAdmin"
                    }
                    
                    for _, pattern in pairs(patterns) do
                        if source:lower():find(pattern:lower()) then
                            table.insert(foundCommands, {
                                script = script,
                                pattern = pattern,
                                path = script:GetFullName()
                            })
                            break
                        end
                    end
                end)
            end
        end
    end
    
    print("Found " .. #foundCommands .. " scripts with admin patterns:")
    for i, cmd in ipairs(foundCommands) do
        if i <= 10 then  -- Limit output
            print("  " .. i .. ". " .. cmd.path .. " (contains: " .. cmd.pattern .. ")")
        end
    end
    
    if #foundCommands > 10 then
        print("  ... and " .. (#foundCommands - 10) .. " more")
    end
    
    return foundCommands
end

-- METHOD 3: TEST ALL REMOTES FOR ADMIN COMMANDS
local function testAdminRemotes()
    print("\n🎯 TESTING ALL REMOTES...")
    
    local commandsToTry = {
        "givecar Subaru3",
        "!give Subaru3",
        "spawn Subaru3",
        "unlockall",
        "unlockallcars",
        "givemoney 999999",
        "addmoney 999999",
        "freecars",
        "allcars",
        "admin",
        "cmds",
        "help",
        "!help"
    }
    
    -- Collect all remotes
    local allRemotes = {}
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            table.insert(allRemotes, remote)
        end
    end
    
    print("Found " .. #allRemotes .. " remotes in ReplicatedStorage")
    
    -- Test each remote
    for i, remote in pairs(allRemotes) do
        print("\nTesting remote " .. i .. "/" .. #allRemotes .. ": " .. remote.Name)
        
        for _, cmd in pairs(commandsToTry) do
            pcall(function()
                if remote:IsA("RemoteFunction") then
                    local result = remote:InvokeServer(cmd)
                    print("  ✅ " .. cmd .. " → " .. tostring(result))
                else
                    remote:FireServer(cmd)
                    print("  ✅ Fired: " .. cmd)
                end
            end)
            wait(0.1)
        end
    end
    
    print("\n✅ Finished testing all remotes!")
end

-- METHOD 4: BRUTE FORCE ISLEGACYADMIN
local function bruteForceLegacyAdmin()
    print("\n💥 BRUTE FORCE ISLEGACYADMIN...")
    
    if not IsLegacyAdmin then
        print("❌ IsLegacyAdmin not found")
        return
    end
    
    if IsLegacyAdmin:IsA("RemoteFunction") then
        -- Try different parameters
        local testParams = {
            LocalPlayer.UserId,
            LocalPlayer.Name,
            "admin",
            "true",
            "1",
            1,
            true,
            "legacyadmin",
            "owner"
        }
        
        for _, param in pairs(testParams) do
            pcall(function()
                local result = IsLegacyAdmin:InvokeServer(param)
                print("IsLegacyAdmin(" .. tostring(param) .. ") = " .. tostring(result))
            end)
            wait(0.2)
        end
        
        -- Try command-like parameters
        local commands = {
            "givecar Subaru3",
            "unlockall",
            "addadmin " .. LocalPlayer.UserId,
            "makeadmin " .. LocalPlayer.Name
        }
        
        for _, cmd in pairs(commands) do
            pcall(function()
                local result = IsLegacyAdmin:InvokeServer(cmd)
                print("IsLegacyAdmin('" .. cmd .. "') = " .. tostring(result))
            end)
            wait(0.2)
        end
    else
        print("IsLegacyAdmin is a " .. IsLegacyAdmin.ClassName)
        print("Trying to fire events...")
        
        local events = {
            LocalPlayer.UserId,
            LocalPlayer.Name,
            "admin",
            "givecar Subaru3"
        }
        
        for _, event in pairs(events) do
            pcall(function()
                IsLegacyAdmin:FireServer(event)
                print("Fired: " .. tostring(event))
            end)
            wait(0.2)
        end
    end
end

-- METHOD 5: DIRECT GUI INJECTION
local function injectAdminGUI()
    print("\n💉 INJECTING ADMIN GUI...")
    
    -- Create a custom admin panel
    local adminGUI = Instance.new("ScreenGui")
    adminGUI.Name = "InjectedAdminPanel"
    adminGUI.Parent = LocalPlayer.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 3
    frame.BorderColor3 = Color3.new(0, 1, 0)
    frame.Parent = adminGUI
    
    local title = Instance.new("TextLabel")
    title.Text = "⚡ INJECTED ADMIN PANEL ⚡"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    -- Create admin command buttons
    local commands = {
        {"🚗 Give Subaru3", "givecar Subaru3"},
        {"💰 999,999 Money", "givemoney 999999"},
        {"🔓 Unlock All Cars", "unlockallcars"},
        {"🎮 Unlock All", "unlockall"},
        {"⚡ Fly Mode", "fly on"},
        {"👻 Noclip", "noclip"},
        {"🏎️ Speed", "speed 100"},
        {"🔧 Admin Tools", "admin tools"}
    }
    
    for i, cmdData in ipairs(commands) do
        local btn = Instance.new("TextButton")
        btn.Text = cmdData[1]
        btn.Size = UDim2.new(0.9, 0, 0, 35)
        btn.Position = UDim2.new(0.05, 0, 0.1 + (i * 0.1), 0)
        btn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = frame
        
        btn.MouseButton1Click:Connect(function()
            print("Executing: " .. cmdData[2])
            executeCommand(cmdData[2])
        end)
    end
    
    -- Custom command input
    local inputBox = Instance.new("TextBox")
    inputBox.PlaceholderText = "Enter admin command..."
    inputBox.Size = UDim2.new(0.9, 0, 0, 30)
    inputBox.Position = UDim2.new(0.05, 0, 0.9, 0)
    inputBox.Parent = frame
    
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and inputBox.Text ~= "" then
            executeCommand(inputBox.Text)
            inputBox.Text = ""
        end
    end)
    
    print("✅ Injected admin GUI created!")
    print("Try clicking the buttons!")
end

-- Execute command through all possible channels
local function executeCommand(cmd)
    print("\n⚡ EXECUTING: " .. cmd)
    
    -- Try IsLegacyAdmin first
    if IsLegacyAdmin and IsLegacyAdmin:IsA("RemoteFunction") then
        pcall(function()
            local result = IsLegacyAdmin:InvokeServer(cmd)
            print("IsLegacyAdmin result: " .. tostring(result))
        end)
    end
    
    -- Try all remotes
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            pcall(function()
                if remote:IsA("RemoteFunction") then
                    remote:InvokeServer(cmd)
                else
                    remote:FireServer(cmd)
                end
                print("Sent to: " .. remote.Name)
            end)
            wait(0.05)
        end
    end
    
    print("✅ Command execution attempted")
end

-- CREATE CONTROL PANEL
local controlGUI = Instance.new("ScreenGui")
controlGUI.Name = "AdminExploitControl"
controlGUI.Parent = LocalPlayer.PlayerGui

local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(0, 250, 0, 350)
controlFrame.Position = UDim2.new(0, 20, 0, 100)
controlFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
controlFrame.BorderSizePixel = 3
controlFrame.BorderColor3 = Color3.new(1, 0.5, 0)
controlFrame.Parent = controlGUI

local controlTitle = Instance.new("TextLabel")
controlTitle.Text = "⚡ ADMIN EXPLOIT"
controlTitle.Size = UDim2.new(1, 0, 0, 30)
controlTitle.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
controlTitle.TextColor3 = Color3.new(1, 1, 1)
controlTitle.Font = Enum.Font.SourceSansBold
controlTitle.Parent = controlFrame

-- Buttons
local methods = {
    {"📋 Clone Admin Panel", cloneAdminPanel},
    {"🔍 Search Scripts", searchAdminScripts},
    {"🎯 Test All Remotes", testAdminRemotes},
    {"💥 Brute Force LegacyAdmin", bruteForceLegacyAdmin},
    {"💉 Inject Admin GUI", injectAdminGUI},
    {"🚗 Give Car", function() executeCommand("givecar Subaru3") end},
    {"💰 999K Money", function() executeCommand("givemoney 999999") end},
    {"🔓 Unlock All", function() executeCommand("unlockall") end}
}

for i, method in ipairs(methods) do
    local btn = Instance.new("TextButton")
    btn.Text = method[1]
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0.08 + (i * 0.11), 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = controlFrame
    btn.MouseButton1Click:Connect(method[2])
end

print("\n" .. string.rep("=", 60))
print("⚡ ADMIN EXPLOIT CONTROL PANEL LOADED")
print(string.rep("=", 60))
print("Found: StarterGui.Menu.Pages.AdminPanel")
print(string.rep("=", 60))
print("RECOMMENDED ORDER:")
print("1. Clone Admin Panel - Copy admin UI to your screen")
print("2. Search Scripts - Find admin command patterns")
print("3. Test All Remotes - Try commands on every remote")
print("4. Brute Force LegacyAdmin - Test IsLegacyAdmin")
print("5. Inject Admin GUI - Create custom admin panel")
print(string.rep("=", 60))

-- Make global
_G.cloneadmin = cloneAdminPanel
_G.searchcmds = searchAdminScripts
_G.testremotes = testAdminRemotes
_G.bruteforce = bruteForceLegacyAdmin
_G.injectgui = injectAdminGUI
_G.admin = executeCommand

print("\nConsole commands:")
print("_G.cloneadmin() - Clone admin panel")
print("_G.searchcmds() - Search for admin commands")
print("_G.testremotes() - Test all remotes")
print("_G.bruteforce() - Brute force IsLegacyAdmin")
print("_G.injectgui() - Inject custom admin GUI")
print("_G.admin('givecar Subaru3') - Execute command")
