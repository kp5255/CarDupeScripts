-- 🚀 ASTON MARTIN 12 TRADE BOT
-- Asks how many to add, then adds them

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

print("=== ASTON MARTIN 12 TRADE BOT ===")
print("✅ CORRECT FORMAT FOUND!")
print("Format: {ItemId = 'AstonMartin12', itemType = 'Car'}")

-- Get the trading remote
local tradingRemote = RS.Remotes.Services.TradingServiceRemotes.SessionAddItem
print("✅ Remote: SessionAddItem")

-- ===== THE CORRECT DATA FORMAT =====
local CORRECT_DATA = {
    ItemId = "AstonMartin12",
    itemType = "Car"
}

-- ===== ASK FOR QUANTITY =====
local function AskQuantity()
    local gui = Instance.new("ScreenGui")
    gui.Name = "QuantityPopup"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 HOW MANY ASTON MARTIN 12?"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    
    -- Instruction
    local instruction = Instance.new("TextLabel")
    instruction.Text = "Enter number of cars to add to trade:"
    instruction.Size = UDim2.new(1, -20, 0, 40)
    instruction.Position = UDim2.new(0, 10, 0, 60)
    instruction.BackgroundTransparency = 1
    instruction.TextColor3 = Color3.fromRGB(200, 200, 255)
    instruction.Font = Enum.Font.Gotham
    instruction.TextSize = 14
    
    -- Input box
    local inputBox = Instance.new("TextBox")
    inputBox.Text = "10"
    inputBox.PlaceholderText = "Enter number..."
    inputBox.Size = UDim2.new(1, -40, 0, 40)
    inputBox.Position = UDim2.new(0, 20, 0, 110)
    inputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.Font = Enum.Font.GothamBold
    inputBox.TextSize = 18
    inputBox.TextScaled = true
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputBox
    
    -- Buttons
    local function CreateButton(text, x, color, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(0, 120, 0, 35)
        btn.Position = UDim2.new(0, x, 1, -45)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 14
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            gui:Destroy()
            callback()
        end)
        
        return btn
    end
    
    local okBtn = CreateButton("✅ ADD", 20, Color3.fromRGB(0, 150, 80), function()
        local quantity = tonumber(inputBox.Text) or 10
        StartAdding(quantity)
    end)
    
    local cancelBtn = CreateButton("❌ CANCEL", 160, Color3.fromRGB(150, 50, 50), function()
        print("❌ Cancelled by user")
    end)
    
    -- Quick quantity buttons
    local quickBtnsY = 155
    local quickNumbers = {10, 50, 100, 500}
    local quickColors = {
        Color3.fromRGB(70, 120, 180),
        Color3.fromRGB(180, 100, 60),
        Color3.fromRGB(180, 60, 120),
        Color3.fromRGB(60, 180, 120)
    }
    
    for i, number in ipairs(quickNumbers) do
        local quickBtn = Instance.new("TextButton")
        quickBtn.Text = tostring(number)
        quickBtn.Size = UDim2.new(0, 60, 0, 25)
        quickBtn.Position = UDim2.new(0, 20 + (i-1)*70, 0, quickBtnsY)
        quickBtn.BackgroundColor3 = quickColors[i]
        quickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        quickBtn.Font = Enum.Font.GothamBold
        quickBtn.TextSize = 12
        
        local quickCorner = Instance.new("UICorner")
        quickCorner.CornerRadius = UDim.new(0, 6)
        quickCorner.Parent = quickBtn
        
        quickBtn.MouseButton1Click:Connect(function()
            inputBox.Text = tostring(number)
        end)
        
        quickBtn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    instruction.Parent = frame
    inputBox.Parent = frame
    okBtn.Parent = frame
    cancelBtn.Parent = frame
    frame.Parent = gui
    
    -- Focus on input
    task.wait(0.1)
    inputBox:CaptureFocus()
    
    return gui
end

-- ===== ADDING FUNCTION =====
local function StartAdding(quantity)
    print("\n" .. string.rep("=", 50))
    print("🚀 STARTING TO ADD " .. quantity .. " ASTON MARTIN 12")
    print(string.rep("=", 50))
    
    -- Create progress UI
    local progressGui = Instance.new("ScreenGui")
    progressGui.Name = "ProgressUI"
    progressGui.Parent = Player:WaitForChild("PlayerGui")
    
    local progressFrame = Instance.new("Frame")
    progressFrame.Size = UDim2.new(0, 350, 0, 150)
    progressFrame.Position = UDim2.new(0.5, -175, 0, 20)
    progressFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 12)
    progressCorner.Parent = progressFrame
    
    -- Progress title
    local progressTitle = Instance.new("TextLabel")
    progressTitle.Text = "🚗 ADDING ASTON MARTIN 12"
    progressTitle.Size = UDim2.new(1, 0, 0, 40)
    progressTitle.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    progressTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    progressTitle.Font = Enum.Font.GothamBold
    progressTitle.TextSize = 16
    
    -- Progress bar background
    local progressBarBg = Instance.new("Frame")
    progressBarBg.Size = UDim2.new(1, -40, 0, 25)
    progressBarBg.Position = UDim2.new(0, 20, 0, 70)
    progressBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 6)
    barCorner.Parent = progressBarBg
    
    -- Progress bar fill
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    progressBar.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 6)
    fillCorner.Parent = progressBar
    
    -- Progress text
    local progressText = Instance.new("TextLabel")
    progressText.Text = "0/" .. quantity
    progressText.Size = UDim2.new(1, 0, 0, 25)
    progressText.Position = UDim2.new(0, 0, 0, 100)
    progressText.BackgroundTransparency = 1
    progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
    progressText.Font = Enum.Font.Gotham
    progressText.TextSize = 14
    
    -- Stop button
    local stopBtn = Instance.new("TextButton")
    stopBtn.Text = "⏹️ STOP"
    stopBtn.Size = UDim2.new(0, 80, 0, 30)
    stopBtn.Position = UDim2.new(1, -90, 1, -40)
    stopBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.Font = Enum.Font.Gotham
    stopBtn.TextSize = 12
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 6)
    stopCorner.Parent = stopBtn
    
    -- Parent progress UI
    progressBar.Parent = progressBarBg
    progressBarBg.Parent = progressFrame
    progressTitle.Parent = progressFrame
    progressText.Parent = progressFrame
    stopBtn.Parent = progressFrame
    progressFrame.Parent = progressGui
    
    -- Variables for adding
    local successCount = 0
    local failCount = 0
    local isAdding = true
    
    -- Stop function
    stopBtn.MouseButton1Click:Connect(function()
        isAdding = false
        stopBtn.Text = "⏹️ STOPPING..."
    end)
    
    -- Start adding in a separate thread
    task.spawn(function()
        for i = 1, quantity do
            if not isAdding then
                print("⏹️ Stopped by user")
                break
            end
            
            -- Update progress
            progressText.Text = i .. "/" .. quantity
            local progress = i / quantity
            progressBar:TweenSize(
                UDim2.new(progress, 0, 1, 0),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.2,
                true
            )
            
            -- Add car
            print("[" .. i .. "/" .. quantity .. "] Adding AstonMartin12...")
            
            local success, result = pcall(function()
                return tradingRemote:InvokeServer(CORRECT_DATA)
            end)
            
            if success then
                successCount = successCount + 1
                print("✅ Success!")
            else
                failCount = failCount + 1
                print("❌ Failed:", result)
                
                -- If rate limited, wait longer
                if tostring(result):find("rate") or tostring(result):find("wait") then
                    print("⚠️ Rate limited, waiting 3 seconds...")
                    task.wait(3)
                end
            end
            
            -- Random delay (100-500ms)
            local delay = math.random(100, 500) / 1000
            task.wait(delay)
        end
        
        -- Complete
        progressTitle.Text = "✅ COMPLETE!"
        progressText.Text = "Success: " .. successCount .. " | Failed: " .. failCount
        stopBtn.Text = "✕ CLOSE"
        
        -- Change stop button to close
        stopBtn.MouseButton1Click:Connect(function()
            progressGui:Destroy()
        end)
        
        -- Auto-close after 10 seconds
        task.wait(10)
        progressGui:Destroy()
        
        -- Final report
        print("\n" .. string.rep("=", 50))
        print("📊 FINAL REPORT")
        print(string.rep("=", 50))
        print("✅ Successfully added:", successCount)
        print("❌ Failed:", failCount)
        print("🎯 Total attempted:", quantity)
        print("📈 Success rate:", math.floor((successCount/quantity)*100) .. "%")
        print(string.rep("=", 50))
    end)
    
    return progressGui
end

-- ===== MAIN EXECUTION =====
task.wait(1)

-- Show quantity popup
AskQuantity()

print("\n📋 INSTRUCTIONS:")
print("1. A popup will ask how many AstonMartin12 to add")
print("2. Enter number (or use quick buttons: 10, 50, 100, 500)")
print("3. Click ✅ ADD to start")
print("4. Watch progress in the top UI")
print("5. Click ⏹️ STOP to stop anytime")
