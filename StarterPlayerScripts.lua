-- 🔓 ACCESS HIDDEN CDT COMMANDS
-- Activates the existing CMDR system in Car Dealership Tycoon

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🔓 CDT CMDR ACCESS SCRIPT")

-- ===== FIND EXISTING CMDR SYSTEM =====
local function FindExistingCMDR()
    print("🔍 Searching for existing CMDR system...")
    
    -- Common places where CMDR might be hidden
    local possibleLocations = {
        Player.PlayerGui,
        game:GetService("StarterGui"),
        game:GetService("ReplicatedStorage"),
        game:GetService("Workspace"),
        game:GetService("ServerScriptService"),
        game:GetService("StarterPack"),
        game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
    }
    
    local foundCommands = {}
    
    for _, location in pairs(possibleLocations) do
        if location then
            -- Look for command-related objects
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                    local name = obj.Name:lower()
                    
                    -- Check for command-related names
                    if name:find("command") or name:find("cmdr") 
                       or name:find("admin") or name:find("cheat")
                       or name:find("unlock") or name:find("give") then
                        
                        table.insert(foundCommands, {
                            object = obj,
                            name = obj.Name,
                            type = obj.ClassName,
                            location = location.Name,
                            path = obj:GetFullName()
                        })
                        print("✅ Found command object: " .. obj.Name .. " (" .. obj.ClassName .. ")")
                    end
                end
                
                -- Look for LocalScripts/ModuleScripts with command functions
                if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                    local name = obj.Name:lower()
                    if name:find("command") or name:find("cmdr") 
                       or name:find("admin") or name:find("cheat") then
                        
                        print("📜 Found command script: " .. obj.Name)
                        
                        -- Try to get its source
                        local success, source = pcall(function()
                            if obj:IsA("ModuleScript") then
                                local module = require(obj)
                                return "Module loaded: " .. tostring(type(module))
                            else
                                return "LocalScript found"
                            end
                        end)
                        
                        if success then
                            print("   " .. source)
                        end
                    end
                end
            end
        end
    end
    
    return foundCommands
end

-- ===== ACTIVATE HIDDEN COMMANDS =====
local function ActivateHiddenCommands(commands)
    print("\n🔓 Attempting to activate hidden commands...")
    
    -- Try common unlock commands
    local unlockCommands = {
        -- Give/unlock commands
        "unlockall",
        "unlockallcosmetics", 
        "unlockallcars",
        "giveall",
        "giveallitems",
        "giveallcosmetics",
        "unlockwraps",
        "unlockkits",
        "unlockwheels",
        
        -- Money/currency commands
        "givemoney",
        "givemoney 999999",
        "givecash",
        "givecash 999999",
        "addmoney 999999",
        
        -- Admin commands
        "admin",
        "admin unlockall",
        "cheat",
        "cheat unlockall",
        
        -- Specific item commands
        "giveitem all",
        "unlockitem all",
        "purchaseall",
        "buyall"
    }
    
    for _, command in ipairs(commands) do
        print("\n🔄 Testing command object: " .. command.name)
        
        -- Try different command formats
        local testData = {
            -- Just command name
            command.name,
            
            -- With unlock parameter
            {command = "unlockall"},
            {cmd = "unlockall"},
            {action = "unlockall"},
            
            -- With specific parameters
            {Command = "unlockall", Player = Player},
            {Cmd = "unlockall", User = Player},
            
            -- Simple unlock
            "unlockall",
            "unlock all",
            "unlockallcosmetics",
            
            -- Give commands
            "giveall",
            "give all",
            "giveallitems",
            
            -- With player reference
            {UnlockAll = true, Player = Player},
            {GiveAll = true, Player = Player}
        }
        
        for i, data in ipairs(testData) do
            print("   Trying format " .. i)
            
            local success, result = pcall(function()
                if command.type == "RemoteFunction" then
                    return command.object:InvokeServer(data)
                else
                    command.object:FireServer(data)
                    return "FireServer called"
                end
            end)
            
            if success then
                print("   ✅ Success! Result: " .. tostring(result))
            else
                -- Don't spam errors
                if i == 1 then
                    print("   ❌ Failed: " .. tostring(result))
                end
            end
            
            task.wait(0.05)
        end
    end
end

-- ===== SEND DIRECT COMMANDS =====
local function SendDirectCommand(commandText)
    print("\n📡 Sending command: " .. commandText)
    
    -- Look for a command remote
    local foundRemotes = FindExistingCMDR()
    
    if #foundRemotes == 0 then
        print("❌ No command system found")
        return false
    end
    
    -- Try each remote with the command
    for _, remote in ipairs(foundRemotes) do
        print("🔄 Trying with: " .. remote.name)
        
        local formats = {
            commandText,
            {command = commandText},
            {cmd = commandText},
            {text = commandText},
            {Command = commandText},
            {Cmd = commandText}
        }
        
        for i, data in ipairs(formats) do
            local success, result = pcall(function()
                if remote.type == "RemoteFunction" then
                    return remote.object:InvokeServer(data)
                else
                    remote.object:FireServer(data)
                    return "FireServer called"
                end
            end)
            
            if success then
                print("   ✅ Format " .. i .. " - Success: " .. tostring(result))
                return true
            end
        end
    end
    
    print("❌ Command failed")
    return false
end

-- ===== CREATE COMMAND INTERFACE =====
local function CreateCommandInterface()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CDTCommandAccess"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🔓 CDT HIDDEN COMMAND ACCESS"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    
    local Status = Instance.new("TextLabel")
    Status.Text = "Status: Ready\n"
    Status.Size = UDim2.new(1, -20, 0, 200)
    Status.Position = UDim2.new(0, 10, 0, 50)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    Status.TextWrapped = true
    Status.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Command Input
    local CommandBox = Instance.new("TextBox")
    CommandBox.PlaceholderText = "Type command here (e.g., unlockall)"
    CommandBox.Size = UDim2.new(1, -20, 0, 30)
    CommandBox.Position = UDim2.new(0, 10, 0, 260)
    CommandBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    CommandBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    CommandBox.Font = Enum.Font.Code
    
    local SendBtn = Instance.new("TextButton")
    SendBtn.Text = "🚀 SEND COMMAND"
    SendBtn.Size = UDim2.new(1, -20, 0, 30)
    SendBtn.Position = UDim2.new(0, 10, 0, 300)
    SendBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SendBtn.Font = Enum.Font.GothamBold
    
    -- Quick Command Buttons
    local QuickFrame = Instance.new("Frame")
    QuickFrame.Size = UDim2.new(1, -20, 0, 60)
    QuickFrame.Position = UDim2.new(0, 10, 0, 340)
    QuickFrame.BackgroundTransparency = 1
    
    local UnlockBtn = Instance.new("TextButton")
    UnlockBtn.Text = "🔓 UNLOCK ALL"
    UnlockBtn.Size = UDim2.new(0.48, 0, 0, 25)
    UnlockBtn.Position = UDim2.new(0, 0, 0, 0)
    UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnlockBtn.Font = Enum.Font.Gotham
    
    local MoneyBtn = Instance.new("TextButton")
    MoneyBtn.Text = "💰 GIVE MONEY"
    MoneyBtn.Size = UDim2.new(0.48, 0, 0, 25)
    MoneyBtn.Position = UDim2.new(0.52, 0, 0, 0)
    MoneyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    MoneyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MoneyBtn.Font = Enum.Font.Gotham
    
    local CarsBtn = Instance.new("TextButton")
    CarsBtn.Text = "🚗 UNLOCK CARS"
    CarsBtn.Size = UDim2.new(0.48, 0, 0, 25)
    CarsBtn.Position = UDim2.new(0, 0, 0, 35)
    CarsBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    CarsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CarsBtn.Font = Enum.Font.Gotham
    
    local CosmeticsBtn = Instance.new("TextButton")
    CosmeticsBtn.Text = "🎨 UNLOCK COSMETICS"
    CosmeticsBtn.Size = UDim2.new(0.48, 0, 0, 25)
    CosmeticsBtn.Position = UDim2.new(0.52, 0, 0, 35)
    CosmeticsBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    CosmeticsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CosmeticsBtn.Font = Enum.Font.Gotham
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = Title
    corner:Clone().Parent = CommandBox
    corner:Clone().Parent = SendBtn
    corner:Clone().Parent = UnlockBtn
    corner:Clone().Parent = MoneyBtn
    corner:Clone().Parent = CarsBtn
    corner:Clone().Parent = CosmeticsBtn
    
    -- Parent
    Title.Parent = MainFrame
    Status.Parent = MainFrame
    CommandBox.Parent = MainFrame
    SendBtn.Parent = MainFrame
    QuickFrame.Parent = MainFrame
    
    UnlockBtn.Parent = QuickFrame
    MoneyBtn.Parent = QuickFrame
    CarsBtn.Parent = QuickFrame
    CosmeticsBtn.Parent = QuickFrame
    
    MainFrame.Parent = ScreenGui
    
    -- Update status
    local function updateStatus(text)
        Status.Text = Status.Text .. text .. "\n"
    end
    
    -- Send command
    SendBtn.MouseButton1Click:Connect(function()
        local cmd = CommandBox.Text
        if cmd == "" then return end
        
        SendBtn.Text = "SENDING..."
        updateStatus("\n> " .. cmd)
        
        local success = SendDirectCommand(cmd)
        
        if success then
            updateStatus("✅ Command sent successfully")
            SendBtn.Text = "✅ COMMAND SENT"
            SendBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            updateStatus("❌ Command failed")
            SendBtn.Text = "❌ FAILED"
            SendBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        
        task.wait(1)
        SendBtn.Text = "🚀 SEND COMMAND"
        SendBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    end)
    
    -- Enter key to send
    CommandBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            SendBtn:Click()
        end
    end)
    
    -- Quick buttons
    UnlockBtn.MouseButton1Click:Connect(function()
        CommandBox.Text = "unlockall"
        SendBtn:Click()
    end)
    
    MoneyBtn.MouseButton1Click:Connect(function()
        CommandBox.Text = "givemoney 999999"
        SendBtn:Click()
    end)
    
    CarsBtn.MouseButton1Click:Connect(function()
        CommandBox.Text = "unlockallcars"
        SendBtn:Click()
    end)
    
    CosmeticsBtn.MouseButton1Click:Connect(function()
        CommandBox.Text = "unlockallcosmetics"
        SendBtn:Click()
    end)
    
    -- Initial scan
    updateStatus("🔍 Scanning for CDT command system...")
    
    local commands = FindExistingCMDR()
    
    if #commands > 0 then
        updateStatus("✅ Found " .. #commands .. " command objects")
        updateStatus("\n🎮 READY TO SEND COMMANDS")
        updateStatus("Try commands like:")
        updateStatus("  unlockall")
        updateStatus("  givemoney 999999")
        updateStatus("  unlockallcosmetics")
        updateStatus("  giveall")
    else
        updateStatus("❌ No command system found")
        updateStatus("CDT may have removed it")
    end
    
    return ScreenGui
end

-- ===== AUTO-ACTIVATE =====
print("\n🎮 INITIALIZING CDT COMMAND ACCESS...")
task.wait(1)

CreateCommandInterface()

-- Auto-scan for commands
task.wait(2)
print("\n🔍 Auto-scanning for commands...")
local foundCommands = FindExistingCMDR()

if #foundCommands > 0 then
    print("✅ Found " .. #foundCommands .. " command objects")
    print("💡 Try typing commands in the UI")
    
    -- Try common commands automatically
    task.wait(3)
    print("\n🔄 Trying common unlock commands...")
    
    local commonCommands = {
        "unlockall",
        "givemoney 999999",
        "unlockallcosmetics",
        "giveall"
    }
    
    for _, cmd in ipairs(commonCommands) do
        print("Trying: " .. cmd)
        SendDirectCommand(cmd)
        task.wait(1)
    end
else
    print("❌ No command system found")
    print("💡 The game may have patched it")
end

print("\n" .. string.rep("=", 60))
print("🎮 CDT COMMAND ACCESS READY")
print("📍 Look for the command window")
print("💡 Try commands like: unlockall, givemoney 999999")
print(string.rep("=", 60))
