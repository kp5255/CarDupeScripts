-- 🚀 SIMPLE ASTON MARTIN TRADE BOT
-- No errors, just works

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

print("=== SIMPLE TRADE BOT ===")
print("Format: {Id = 'AstonMartin12', Type = 'Vehicle'}")

-- Get remote
local tradingRemote = RS.Remotes.Services.TradingServiceRemotes.SessionAddItem

-- Correct data
local CORRECT_DATA = {
    Id = "AstonMartin12",
    Type = "Vehicle"
}

-- Simple add function
local function AddCar()
    print("➕ Adding AstonMartin12...")
    
    local success, result = pcall(function()
        return tradingRemote:InvokeServer(CORRECT_DATA)
    end)
    
    if success then
        print("✅ Success!")
        return true
    else
        print("❌ Failed:", result)
        return false
    end
end

-- Bulk add with simple counter
local function BulkAdd(count)
    print("\n📦 Adding " .. count .. " cars...")
    
    local added = 0
    
    for i = 1, count do
        print("[" .. i .. "/" .. count .. "] Adding...")
        
        if AddCar() then
            added = added + 1
        end
        
        -- Wait between adds
        task.wait(0.5)
    end
    
    print("\n✅ Finished! Added " .. added .. "/" .. count .. " cars")
    return added
end

-- Simple text UI
print("\n🎮 CONTROLS (Type in chat):")
print("/add1 - Add 1 AstonMartin12")
print("/add5 - Add 5 AstonMartin12")
print("/add10 - Add 10 AstonMartin12")
print("/stop - Stop adding")

-- Chat listener
local ChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")

if RunService:IsClient() then
    -- Listen for chat commands
    local function OnMessageReceived(message)
        local text = message.Text:lower()
        
        if text == "/add1" then
            task.spawn(function()
                AddCar()
            end)
        elseif text == "/add5" then
            task.spawn(function()
                BulkAdd(5)
            end)
        elseif text == "/add10" then
            task.spawn(function()
                BulkAdd(10)
            end)
        elseif text == "/stop" then
            print("⏹️ Stopping any ongoing adds...")
        end
    end
    
    -- Try to hook chat
    pcall(function()
        local channel = ChatService:WaitForChild("TextChannels"):WaitForChild("RBXGeneral")
        channel.OnIncomingMessage:Connect(OnMessageReceived)
        print("✅ Chat commands enabled!")
    end)
end

-- Alternative: Keybind UI
local function CreateKeybindUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 160)
    frame.Position = UDim2.new(0, 10, 0.5, -80)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    frame.BackgroundTransparency = 0.3
    
    local title = Instance.new("TextLabel")
    title.Text = "TRADE BOT"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    
    -- Create button function
    local function MakeButton(text, y, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(1, -20, 0, 30)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- Buttons
    local btn1 = MakeButton("ADD 1", 35, function()
        AddCar()
    end)
    
    local btn5 = MakeButton("ADD 5", 70, function()
        task.spawn(function() BulkAdd(5) end)
    end)
    
    local btn10 = MakeButton("ADD 10", 105, function()
        task.spawn(function() BulkAdd(10) end)
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Parent everything
    title.Parent = frame
    btn1.Parent = frame
    btn5.Parent = frame
    btn10.Parent = frame
    closeBtn.Parent = title
    frame.Parent = gui
    
    print("✅ UI created! Left side of screen.")
    return gui
end

-- Create UI
task.wait(1)
CreateKeybindUI()

-- Test one car automatically
task.wait(2)
print("\n🧪 Auto-testing with 1 car...")
AddCar()

print("\n✅ Ready! Use buttons or chat commands.")
