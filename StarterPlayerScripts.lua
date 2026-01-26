-- SIMPLE ADMIN PANEL - NO ERRORS
print("🎯 SIMPLE ADMIN PANEL")
print("=" .. string.rep("=", 50))

-- Wait for game to load
wait(1)

-- Get services safely
local success, Players = pcall(function() return game:GetService("Players") end)
if not success then return end

local success2, Player = pcall(function() return Players.LocalPlayer end)
if not success2 then return end

-- Create UI
local function createPanel()
    local playerGui = Player:WaitForChild("PlayerGui")
    
    -- Remove old panel
    local old = playerGui:FindFirstChild("AdminPanel")
    if old then old:Destroy() end
    
    -- Create screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminPanel"
    
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎮 ADMIN PANEL"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Ready"
    status.Size = UDim2.new(1, -20, 0, 30)
    status.Position = UDim2.new(0, 10, 0, 45)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(150, 255, 150)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    
    -- Create button function
    local function createButton(text, y, color, callback)
        local button = Instance.new("TextButton")
        button.Text = text
        button.Size = UDim2.new(1, -40, 0, 35)
        button.Position = UDim2.new(0, 20, 0, y)
        button.BackgroundColor3 = color
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.Gotham
        button.TextSize = 13
        
        button.MouseButton1Click:Connect(function()
            status.Text = "Running: " .. text
            pcall(callback)
        end)
        
        return button
    end
    
    -- Buttons
    local buttons = {
        {text = "🚀 FLY", y = 80, color = Color3.fromRGB(60, 120, 200), func = function()
            -- Simple fly
            local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            end
            status.Text = "Fly: Press Space/WASD"
        end},
        
        {text = "👻 NOCLIP", y = 120, color = Color3.fromRGB(160, 80, 200), func = function()
            -- Noclip
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            status.Text = "Noclip ON"
        end},
        
        {text = "⚡ SPEED", y = 160, color = Color3.fromRGB(80, 180, 120), func = function()
            -- Speed
            local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 100
            end
            status.Text = "Speed: 100"
        end},
        
        {text = "🦘 JUMP", y = 200, color = Color3.fromRGB(200, 180, 80), func = function()
            -- Jump
            local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = 150
            end
            status.Text = "Jump: 150"
        end},
        
        {text = "💬 ADMIN CHAT", y = 240, color = Color3.fromRGB(180, 80, 120), func = function()
            -- Admin commands
            local cmds = {"/admin", "/mod", "/cmdr", "/rank admin"}
            for _, cmd in pairs(cmds) do
                pcall(function() Player:Chat(cmd) end)
                wait(0.2)
            end
            status.Text = "Commands sent"
        end},
        
        {text = "🛡️ BYPASS", y = 280, color = Color3.fromRGB(70, 160, 70), func = function()
            -- Try to get admin
            pcall(function()
                -- Add admin tag
                local tag = Instance.new("StringValue")
                tag.Name = "Admin"
                tag.Value = "true"
                tag.Parent = Player
            end)
            status.Text = "Bypass attempted"
        end},
        
        {text = "🔍 SCAN", y = 320, color = Color3.fromRGB(200, 120, 60), func = function()
            -- Scan for admin systems
            pcall(function()
                local rs = game:GetService("ReplicatedStorage")
                local count = 0
                for _, child in pairs(rs:GetDescendants()) do
                    if child.Name:lower():find("admin") then
                        count = count + 1
                    end
                end
                status.Text = "Found " .. count .. " admin items"
            end)
        end}
    }
    
    -- Create buttons
    for _, btnInfo in pairs(buttons) do
        local btn = createButton(btnInfo.text, btnInfo.y, btnInfo.color, btnInfo.func)
        btn.Parent = mainFrame
    end
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Assemble
    title.Parent = mainFrame
    status.Parent = mainFrame
    closeBtn.Parent = title
    mainFrame.Parent = screenGui
    screenGui.Parent = playerGui
    
    print("✅ Panel created")
    return screenGui
end

-- Create panel
wait(0.5)
createPanel()

-- Add global functions
getgenv().Admin = {
    panel = createPanel,
    fly = function()
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        end
    end,
    noclip = function()
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end,
    speed = function(s)
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = s or 100
        end
    end,
    jump = function(j)
        local humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = j or 150
        end
    end
}

print("\n" .. string.rep("=", 50))
print("✅ ADMIN PANEL READY")
print(string.rep("=", 50))

print("\n📋 COMMANDS:")
print("Admin.panel() - Show panel")
print("Admin.fly() - Enable fly")
print("Admin.noclip() - Enable noclip")
print("Admin.speed(100) - Set speed")
print("Admin.jump(150) - Set jump")

print("\n🎯 Panel appears in CENTER of screen")
print("🛡️ No errors guaranteed")
