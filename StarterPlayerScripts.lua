-- 🚀 PERFECT ASTON MARTIN TRADE BOT
print("🚀 PERFECT ASTON MARTIN TRADE BOT")
print("=" .. string.rep("=", 50))

-- SETUP
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

-- GET THE REMOTE
local tradingRemote = RS.Remotes.Services.TradingServiceRemotes.SessionAddItem
print("✅ Remote: SessionAddItem")

-- ===== THE CORRECT DATA FORMAT =====
local CORRECT_DATA = {
    Id = "AstonMartin12",
    Type = "Vehicle"  -- Capital V as required
}

print("✅ Using correct format: {Id = 'AstonMartin12', Type = 'Vehicle'}")

-- ===== SAFE TEST FUNCTION =====
local function TestAdd()
    print("\n🧪 Testing format...")
    
    local success, result = pcall(function()
        return tradingRemote:InvokeServer(CORRECT_DATA)
    end)
    
    if success then
        print("✅ Success! Result: " .. tostring(result))
        return result
    else
        print("❌ Error: " .. tostring(result))
        return false
    end
end

-- ===== BULK ADD FUNCTION =====
local function BulkAdd(quantity)
    quantity = quantity or 5
    print("\n📦 Adding " .. quantity .. " AstonMartin12...")
    
    local added = 0
    local failed = 0
    
    for i = 1, quantity do
        print("[" .. i .. "/" .. quantity .. "]")
        
        local success, result = pcall(function()
            return tradingRemote:InvokeServer(CORRECT_DATA)
        end)
        
        if success then
            print("  ✅ Success!")
            added = added + 1
        else
            print("  ❌ Failed: " .. tostring(result))
            failed = failed + 1
        end
        
        -- Safe delay between adds
        task.wait(0.5)
    end
    
    print("\n🎯 Results: " .. added .. " added, " .. failed .. " failed")
    return added
end

-- ===== SIMPLE UI =====
local function CreateSimpleUI()
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Remove existing UI
    local existing = PlayerGui:FindFirstChild("TradeBotUI")
    if existing then existing:Destroy() end
    
    -- Create UI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TradeBotUI"
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 250, 0, 200)
    Frame.Position = UDim2.new(0, 20, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.BorderSizePixel = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Frame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🚗 ASTON MARTIN BOT"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 10)
    UICorner2.Parent = Title
    
    -- Format info
    local Info = Instance.new("TextLabel")
    Info.Text = "Format: {Id = 'AstonMartin12', Type = 'Vehicle'}"
    Info.Size = UDim2.new(1, -20, 0, 40)
    Info.Position = UDim2.new(0, 10, 0, 45)
    Info.BackgroundTransparency = 1
    Info.TextColor3 = Color3.fromRGB(180, 220, 255)
    Info.Font = Enum.Font.Gotham
    Info.TextSize = 12
    Info.TextWrapped = true
    
    -- Button creator
    local function CreateButton(text, yPosition, callback)
        local Button = Instance.new("TextButton")
        Button.Text = text
        Button.Size = UDim2.new(1, -40, 0, 35)
        Button.Position = UDim2.new(0, 20, 0, yPosition)
        Button.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
        Button.TextColor3 = Color3.new(1, 1, 1)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 14
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(function()
            Button.Text = "⏳"
            task.spawn(function()
                callback()
                task.wait(0.5)
                Button.Text = text
            end)
        end)
        
        return Button
    end
    
    -- Buttons
    local TestButton = CreateButton("🧪 TEST ADD", 90, TestAdd)
    local Add5Button = CreateButton("📦 ADD 5", 130, function() BulkAdd(5) end)
    local Add10Button = CreateButton("📦 ADD 10", 170, function() BulkAdd(10) end)
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "Ready"
    Status.Size = UDim2.new(1, -20, 0, 20)
    Status.Position = UDim2.new(0, 10, 1, -25)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(150, 255, 150)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    
    -- Assemble UI
    Title.Parent = Frame
    Info.Parent = Frame
    TestButton.Parent = Frame
    Add5Button.Parent = Frame
    Add10Button.Parent = Frame
    Status.Parent = Frame
    Frame.Parent = ScreenGui
    ScreenGui.Parent = PlayerGui
    
    -- Update status function
    local function UpdateStatus(text, color)
        Status.Text = text
        Status.TextColor3 = color or Color3.fromRGB(150, 255, 150)
    end
    
    -- Export functions
    getgenv().AstonTrade = {
        test = TestAdd,
        add5 = function() BulkAdd(5) end,
        add10 = function() BulkAdd(10) end,
        add = function(n) BulkAdd(n) end,
        status = UpdateStatus
    }
    
    print("✅ UI created - Check left side of screen")
    return ScreenGui
end

-- ===== AUTO-TEST =====
print("\n🧪 RUNNING AUTO-TEST...")
task.wait(1)

local testResult = TestAdd()
if testResult == true then
    print("\n🎉 FORMAT IS WORKING!")
    print("Use AstonTrade.add5() to add 5 cars")
elseif testResult == false then
    print("\n⚠️ Recognized but returned false")
    print("May need to be in a trade session")
else
    print("\n❌ Something went wrong")
    print("Check the error message above")
end

-- ===== CREATE UI =====
task.wait(1)
CreateSimpleUI()

-- ===== EXPORT FUNCTIONS =====
getgenv().AstonTrade = getgenv().AstonTrade or {
    test = TestAdd,
    add5 = function() BulkAdd(5) end,
    add10 = function() BulkAdd(10) end,
    add = function(n) BulkAdd(n or 5) end
}

-- ===== FINAL MESSAGE =====
print("\n" .. string.rep("=", 50))
print("🚀 BOT READY!")
print(string.rep("=", 50))

print("\n📋 AVAILABLE COMMANDS:")
print("AstonTrade.test()    - Test one car")
print("AstonTrade.add5()    - Add 5 cars")
print("AstonTrade.add10()   - Add 10 cars")
print("AstonTrade.add(20)   - Add custom amount")

print("\n💡 IMPORTANT:")
print("1. Works with format: {Id = 'AstonMartin12', Type = 'Vehicle'}")
print("2. You might need to be in a TRADE SESSION")
print("3. If fails, try starting a trade first")

print("\n🎯 UI appears on LEFT side of screen")
