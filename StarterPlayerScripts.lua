-- ADMIN PANEL EXPLOIT SCRIPT
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🔍 ADMIN PANEL EXPLOIT")
print("Found: StarterGui.Menu.Pages.AdminPanel")

-- Try to access the admin panel directly
local AdminPanel = StarterGui:WaitForChild("Menu"):WaitForChild("Pages"):WaitForChild("AdminPanel")
print("✅ Found AdminPanel:", AdminPanel:GetFullName())

-- Check what's inside the admin panel
print("\n📂 Admin Panel Contents:")
for _, child in pairs(AdminPanel:GetChildren()) do
    print("  • " .. child.Name .. " (" .. child.ClassName .. ")")
    
    -- Look for buttons
    if child:IsA("TextButton") or child:IsA("ImageButton") then
        print("    Button Text: " .. (child.Text or "No text"))
    end
end

-- Look for admin commands in remotes
print("\n🔍 Checking IsLegacyAdmin remote...")
local IsLegacyAdmin = ReplicatedStorage:FindFirstChild("IsLegacyAdmin")
if IsLegacyAdmin then
    print("✅ Found IsLegacyAdmin (" .. IsLegacyAdmin.ClassName .. ")")
    
    -- Try to check if we're admin
    local success, result = pcall(function()
        if IsLegacyAdmin:IsA("RemoteFunction") then
            return IsLegacyAdmin:InvokeServer()
        elseif IsLegacyAdmin:IsA("RemoteEvent") then
            -- Can't invoke RemoteEvent, need to fire
            return "Is RemoteEvent"
        end
    end)
    
    if success then
        print("IsLegacyAdmin result:", result)
    else
        print("❌ Failed to invoke IsLegacyAdmin:", result)
    end
else
    print("❌ IsLegacyAdmin not found in ReplicatedStorage")
end

-- METHOD 1: UNLOCK ADMIN PANEL
local function unlockAdminPanel()
    print("\n🔓 UNLOCKING ADMIN PANEL...")
    
    -- Method A: Try to enable the panel
    AdminPanel.Visible = true
    AdminPanel.Enabled = true
    
    -- Method B: Check if there's a parent that controls visibility
    local topLevel = StarterGui:FindFirstChild("Menu")
    if topLevel then
        topLevel.Enabled = true
        print("Enabled Menu")
    end
    
    -- Method C: Force show through StarterGui
    pcall(function()
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
    end)
    
    print("✅ Attempted to unlock admin panel")
    print("Check your screen for admin buttons!")
end

-- METHOD 2: CLICK ALL ADMIN BUTTONS
local function clickAllAdminButtons()
    print("\n🖱️ CLICKING ALL ADMIN BUTTONS...")
    
    local buttonsClicked = 0
    
    -- Look for all buttons in admin panel
    for _, button in pairs(AdminPanel:GetDescendants()) do
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            print("Found button: " .. button:GetFullName())
            
            -- Try to click it
            pcall(function()
                button:FireEvent("Activated")
                button:FireEvent("MouseButton1Click")
                buttonsClicked = buttonsClicked + 1
                print("  ✅ Clicked: " .. button.Name)
            end)
            
            wait(0.1)
        end
    end
    
    print("✅ Clicked " .. buttonsClicked .. " admin buttons!")
end

-- METHOD 3: FIND ADMIN COMMANDS
local function findAdminCommands()
    print("\n🔍 SEARCHING FOR ADMIN COMMANDS...")
    
    -- Look for scripts that might contain admin commands
    for _, script in pairs(game:GetDescendants()) do
        if script:IsA("Script") or script:IsA("LocalScript") then
            pcall(function()
                local source = script.Source:lower()
                
                -- Look for admin command patterns
                if source:find("givecar") or 
                   source:find("!give") or 
                   source:find("admincmd") or
                   source:find("spawncar") or
                   source:find("unlockall") then
                    
                    print("Found admin script:", script:GetFullName())
                    print("Source preview:", string.sub(script.Source, 1, 200))
                end
            end)
        end
    end
    
    -- Look for RemoteEvents/Functions with admin names
    local adminRemotes = {}
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local name = remote.Name:lower()
            if name:find("admin") or 
               name:find("cmd") or 
               name:find("give") or
               name:find("spawn") or
               name:find("unlock") then
                
                table.insert(adminRemotes, remote)
                print("Found admin remote:", remote:GetFullName())
            end
        end
    end
    
    -- Try common admin commands
    print("\n🎯 TRYING ADMIN COMMANDS...")
    local commandsToTry = {
        "givecar Subaru3",
        "!give Subaru3",
        "spawn Subaru3",
        "unlockall",
        "unlockallcars",
        "givemoney 999999",
        "addmoney 999999",
        "freecars",
        "allcars"
    }
    
    for _, remote in pairs(adminRemotes) do
        print("\nTesting remote:", remote.Name)
        
        for _, cmd in pairs(commandsToTry) do
            pcall(function()
                if remote:IsA("RemoteFunction") then
                    remote:InvokeServer(cmd)
                    print("  Sent:", cmd)
                else
                    remote:FireServer(cmd)
                    print("  Fired:", cmd)
                end
            end)
            wait(0.1)
        end
    end
end

-- METHOD 4: DIRECT UI MANIPULATION
local function manipulateAdminUI()
    print("\n🎨 MANIPULATING ADMIN UI...")
    
    -- Try to find and modify admin buttons
    for _, button in pairs(AdminPanel:GetDescendants()) do
        if button:IsA("TextButton") then
            -- Change button text to useful commands
            local originalText = button.Text
            
            -- Map common admin commands to buttons
            local commandMap = {
                ["Kick"] = "!givecar Subaru3",
                ["Ban"] = "!unlockall",
                ["Teleport"] = "!givemoney 999999",
                ["Message"] = "!spawncar"
            }
            
            for keyword, command in pairs(commandMap) do
                if originalText:find(keyword) then
                    button.Text = command
                    print("Changed button '" .. originalText .. "' to: " .. command)
                    
                    -- Make button clickable
                    button.Active = true
                    button.AutoButtonColor = true
                end
            end
        end
    end
    
    -- Create new admin buttons
    local function createAdminButton(name, command, position)
        local newButton = Instance.new("TextButton")
        newButton.Name = name
        newButton.Text = command
        newButton.Size = UDim2.new(0, 150, 0, 40)
        newButton.Position = position
        newButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        newButton.TextColor3 = Color3.new(1, 1, 1)
        newButton.Font = Enum.Font.SourceSansBold
        newButton.Parent = AdminPanel
        
        newButton.MouseButton1Click:Connect(function()
            print("Clicked: " .. command)
            -- Try to execute the command
            executeAdminCommand(command)
        end)
        
        return newButton
    end
    
    -- Add useful buttons
    createAdminButton("GiveCar", "!givecar", UDim2.new(0, 10, 0, 50))
    createAdminButton("UnlockAll", "!unlockall", UDim2.new(0, 10, 0, 100))
    createAdminButton("Money999K", "!givemoney 999999", UDim2.new(0, 10, 0, 150))
    
    print("✅ Added custom admin buttons!")
end

-- METHOD 5: EXECUTE ADMIN COMMAND
local function executeAdminCommand(command)
    print("\n⚡ EXECUTING: " .. command)
    
    -- Look for appropriate remote to send command to
    local foundRemote = false
    
    -- Check IsLegacyAdmin first
    if IsLegacyAdmin and IsLegacyAdmin:IsA("RemoteFunction") then
        pcall(function()
            local result = IsLegacyAdmin:InvokeServer(command)
            print("IsLegacyAdmin response:", result)
            foundRemote = true
        end)
    end
    
    -- Search for other admin remotes
    if not foundRemote then
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                pcall(function()
                    if remote:IsA("RemoteFunction") then
                        remote:InvokeServer(command)
                    else
                        remote:FireServer(command)
                    end
                    print("Sent to:", remote.Name)
                    foundRemote = true
                end)
            end
        end
    end
    
    if foundRemote then
        print("✅ Command sent!")
    else
        print("❌ No remote found for command")
    end
end

-- CREATE ADMIN EXPLOIT UI
local adminGUI = Instance.new("ScreenGui")
adminGUI.Name = "AdminExploitGUI"
adminGUI.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 3
frame.BorderColor3 = Color3.new(1, 0.5, 0)
frame.Parent = adminGUI

local title = Instance.new("TextLabel")
title.Text = "⚡ ADMIN EXPLOIT ⚡"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Buttons
local buttons = {
    {"🔓 Unlock Panel", unlockAdminPanel},
    {"🖱️ Click All Buttons", clickAllAdminButtons},
    {"🔍 Find Commands", findAdminCommands},
    {"🎨 Manipulate UI", manipulateAdminUI},
    {"🚗 Give Car", function() executeAdminCommand("givecar Subaru3") end},
    {"💰 Money 999K", function() executeAdminCommand("givemoney 999999") end},
    {"🔓 Unlock All", function() executeAdminCommand("unlockall") end}
}

for i, btnData in ipairs(buttons) do
    local btn = Instance.new("TextButton")
    btn.Text = btnData[1]
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0.1 + (i * 0.12), 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = frame
    btn.MouseButton1Click:Connect(btnData[2])
end

-- Custom command input
local commandBox = Instance.new("TextBox")
commandBox.PlaceholderText = "Type admin command here..."
commandBox.Size = UDim2.new(0.9, 0, 0, 30)
commandBox.Position = UDim2.new(0.05, 0, 0.9, 0)
commandBox.Parent = frame

commandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and commandBox.Text ~= "" then
        executeAdminCommand(commandBox.Text)
        commandBox.Text = ""
    end
end)

print("\n" .. string.rep("=", 60))
print("⚡ ADMIN PANEL EXPLOIT LOADED ⚡")
print(string.rep("=", 60))
print("Found Admin Panel at: StarterGui.Menu.Pages.AdminPanel")
print("Methods available:")
print("1. Unlock Panel - Try to enable hidden admin panel")
print("2. Click All Buttons - Auto-click admin buttons")
print("3. Find Commands - Search for admin command system")
print("4. Manipulate UI - Add custom admin buttons")
print("5. Give Car - Try to give yourself a Subaru3")
print("6. Money 999K - Try to get 999,999 money")
print("7. Unlock All - Try to unlock all cars/items")
print(string.rep("=", 60))
print("Try 'Unlock Panel' first, then 'Click All Buttons'")
print(string.rep("=", 60))

-- Make functions global
_G.unlockadmin = unlockAdminPanel
_G.clickbuttons = clickAllAdminButtons
_G.findcmds = findAdminCommands
_G.admincmd = executeAdminCommand

print("\nConsole commands:")
print("_G.unlockadmin() - Unlock admin panel")
print("_G.clickbuttons() - Click all admin buttons")
print("_G.findcmds() - Search for admin commands")
print("_G.admincmd('givecar Subaru3') - Execute command")
