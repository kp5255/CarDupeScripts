-- 🚀 ASTON MARTIN 12 TRADE BOT - FINAL WORKING VERSION
-- Uses CORRECT format: {Id = "AstonMartin12", Type = "Vehicle"}

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

print("=== ASTON MARTIN 12 TRADE BOT ===")
print("✅ CORRECT FORMAT FOUND!")
print("Format: {Id = 'AstonMartin12', Type = 'Vehicle'}")

-- Wait a moment
task.wait(2)

-- Get the remote
local tradingRemote = RS.Remotes.Services.TradingServiceRemotes.SessionAddItem
print("✅ Remote: SessionAddItem")

-- ===== THE CORRECT DATA FORMAT =====
local CORRECT_DATA = {
    Id = "AstonMartin12",
    Type = "Vehicle"  -- Capital T and V
}

-- ===== SAFE ADD FUNCTION =====
local function AddOneCarSafely()
    print("\n➕ Adding one AstonMartin12...")
    
    local success, result = pcall(function()
        return tradingRemote:InvokeServer(CORRECT_DATA)
    end)
    
    if success then
        print("✅ Success!")
        if result ~= nil then
            print("Result:", result)
        end
        return true
    else
        print("❌ Failed:", result)
        return false
    end
end

-- ===== BULK ADD WITH DELAYS =====
local function BulkAddCarsSafe(quantity)
    print("\n📦 Adding " .. quantity .. " AstonMartin12...")
    print("Using correct format: {Id = 'AstonMartin12', Type = 'Vehicle'}")
    
    local successCount = 0
    local failCount = 0
    
    -- Create simple status
    local statusGui = Instance.new("ScreenGui")
    statusGui.Name = "TradeStatus"
    statusGui.Parent = Player:WaitForChild("PlayerGui")
    
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0, 200, 0, 80)
    statusFrame.Position = UDim2.new(1, -210, 0, 10)
    statusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    statusFrame.BackgroundTransparency = 0.3
    
    local statusText = Instance.new("TextLabel")
    statusText.Text = "Ready"
    statusText.Size = UDim2.new(1, -10, 1, -10)
    statusText.Position = UDim2.new(0, 5, 0, 5)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 12
    
    statusText.Parent = statusFrame
    statusFrame.Parent = statusGui
    
    -- Add cars with delays
    for i = 1, quantity do
        statusText.Text = "Adding: " .. i .. "/" .. quantity
        
        print("\n[" .. i .. "/" .. quantity .. "] Adding...")
        
        local success, result = pcall(function()
            return tradingRemote:InvokeServer(CORRECT_DATA)
        end)
        
        if success then
            successCount = successCount + 1
            print("✅ Success!")
        else
            failCount = failCount + 1
            local errorMsg = tostring(result)
            print("❌ Failed:", errorMsg)
            
            -- If rate limited, wait longer
            if errorMsg:find("rate") or errorMsg:find("wait") then
                print("⚠️ Rate limited, waiting 3 seconds...")
                task.wait(3)
            end
        end
        
        -- IMPORTANT: Longer delay to avoid breaking trade UI
        -- 500-1000ms delay between adds
        local delay = math.random(500, 1000) / 1000
        task.wait(delay)
    end
    
    -- Final status
    statusText.Text = "✅ Complete!\nSuccess: " .. successCount .. "\nFailed: " .. failCount
    
    -- Auto-remove after 5 seconds
    task.wait(5)
    statusGui:Destroy()
    
    -- Final report
    print("\n" .. string.rep("=", 50))
    print("📊 FINAL REPORT")
    print(string.rep("=", 50))
    print("✅ Successfully added:", successCount)
    print("❌ Failed:", failCount)
    print("🎯 Total attempted:", quantity)
    
    if successCount + failCount > 0 then
        local rate = math.floor((successCount / (successCount + failCount)) * 100)
        print("📈 Success rate:", rate .. "%")
    end
    
    print(string.rep("=", 50))
    
    return successCount
end

-- ===== SIMPLE MENU =====
local function CreateSimpleMenu()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeBotMenu"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 250)
    frame.Position = UDim2.new(0, 10, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.BackgroundTransparency = 0.2
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 Trade Bot"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    
    -- Info
    local info = Instance.new("TextLabel")
    info.Text = "Format:\n{Id='AstonMartin12'\nType='Vehicle'}"
    info.Size = UDim2.new(1, -10, 0, 60)
    info.Position = UDim2.new(0, 5, 0, 45)
    info.BackgroundTransparency = 1
    info.TextColor3 = Color3.fromRGB(180, 220, 255)
    info.Font = Enum.Font.Gotham
    info.TextSize = 11
    
    -- Button creator
    local function AddButton(text, y, color, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(1, -20, 0, 35)
        btn.Position = UDim2.new(0, 10, 0, y)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- Buttons
    local testBtn = AddButton("🧪 Test Add", 110, Color3.fromRGB(70, 120, 180), function()
        testBtn.Text = "⏳"
        task.spawn(function()
            AddOneCarSafely()
            task.wait(1)
            testBtn.Text = "🧪 Test Add"
        end)
    end)
    
    local add5Btn = AddButton("📦 Add 5", 150, Color3.fromRGB(70, 180, 120), function()
        add5Btn.Text = "⏳"
        task.spawn(function()
            BulkAddCarsSafe(5)
            task.wait(1)
            add5Btn.Text = "📦 Add 5"
        end)
    end)
    
    local add10Btn = AddButton("📦 Add 10", 190, Color3.fromRGB(180, 120, 60), function()
        add10Btn.Text = "⏳"
        task.spawn(function()
            BulkAddCarsSafe(10)
            task.wait(1)
            add10Btn.Text = "📦 Add 10"
        end)
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 7)
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Parent everything
    title.Parent = frame
    info.Parent = frame
    testBtn.Parent = frame
    add5Btn.Parent = frame
    add10Btn.Parent = frame
    closeBtn.Parent = title
    frame.Parent = gui
    
    return gui
end

-- ===== MAIN =====
print("\n📋 INSTRUCTIONS:")
print("1. Menu appears on left side")
print("2. Click '🧪 Test Add' to test one")
print("3. If successful, use '📦 Add 5' or '📦 Add 10'")
print("4. Status appears top-right")
print("5. IMPORTANT: Wait between adds to avoid UI freeze")

-- Create menu after delay
task.wait(1)
CreateSimpleMenu()

print("\n✅ Bot ready! Check left side for menu.")
print("🎯 Using CORRECT format: {Id = 'AstonMartin12', Type = 'Vehicle'}")
