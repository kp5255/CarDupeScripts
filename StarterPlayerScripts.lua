-- 🚀 ASTON MARTIN 12 TRADE BOT - FIXED VERSION
-- Simple version that works without errors

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

print("=== ASTON MARTIN 12 TRADE BOT ===")

-- Wait for game to fully load
repeat task.wait(1) until game:IsLoaded()
task.wait(2)

-- Get the trading remote
local tradingRemote = RS.Remotes.Services.TradingServiceRemotes.SessionAddItem
print("✅ Remote found: SessionAddItem")

-- ===== THE CORRECT DATA FORMAT =====
local CORRECT_DATA = {
    ItemId = "AstonMartin12",
    itemType = "Car"
}

print("✅ Using format: {ItemId = 'AstonMartin12', itemType = 'Car'}")

-- ===== SIMPLE QUANTITY ASKER =====
local function AskHowMany()
    -- Create popup
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeBotPopup"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 180)
    frame.Position = UDim2.new(0.5, -140, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.BackgroundTransparency = 0.1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 ASTON MARTIN 12 BOT"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    
    -- Question
    local question = Instance.new("TextLabel")
    question.Text = "How many to add to trade?"
    question.Size = UDim2.new(1, -20, 0, 30)
    question.Position = UDim2.new(0, 10, 0, 50)
    question.BackgroundTransparency = 1
    question.TextColor3 = Color3.fromRGB(200, 200, 255)
    question.Font = Enum.Font.Gotham
    question.TextSize = 14
    
    -- Input box
    local inputBox = Instance.new("TextBox")
    inputBox.Text = "10"
    inputBox.PlaceholderText = "Enter number..."
    inputBox.Size = UDim2.new(1, -40, 0, 35)
    inputBox.Position = UDim2.new(0, 20, 0, 85)
    inputBox.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.Font = Enum.Font.GothamBold
    inputBox.TextSize = 16
    inputBox.TextScaled = false
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputBox
    
    -- Quick buttons
    local quickNumbers = {10, 25, 50, 100}
    local quickColors = {
        Color3.fromRGB(70, 120, 180),
        Color3.fromRGB(180, 100, 60),
        Color3.fromRGB(180, 60, 120),
        Color3.fromRGB(60, 180, 120)
    }
    
    for i, number in ipairs(quickNumbers) do
        local quickBtn = Instance.new("TextButton")
        quickBtn.Text = tostring(number)
        quickBtn.Size = UDim2.new(0, 50, 0, 25)
        quickBtn.Position = UDim2.new(0, 20 + (i-1)*65, 0, 125)
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
    
    -- Add button
    local addBtn = Instance.new("TextButton")
    addBtn.Text = "✅ START ADDING"
    addBtn.Size = UDim2.new(1, -40, 0, 35)
    addBtn.Position = UDim2.new(0, 20, 1, -45)
    addBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    addBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    addBtn.Font = Enum.Font.GothamBold
    addBtn.TextSize = 14
    
    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(0, 8)
    addCorner.Parent = addBtn
    
    -- Cancel button
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Text = "✕"
    cancelBtn.Size = UDim2.new(0, 25, 0, 25)
    cancelBtn.Position = UDim2.new(1, -30, 0, 7)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelBtn.Font = Enum.Font.GothamBold
    
    cancelBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
        print("❌ Cancelled by user")
    end)
    
    -- Parent everything
    title.Parent = frame
    question.Parent = frame
    inputBox.Parent = frame
    addBtn.Parent = frame
    cancelBtn.Parent = title
    frame.Parent = gui
    
    -- Return the gui and input box for external control
    return gui, inputBox, addBtn
end

-- ===== ADD CARS FUNCTION =====
local function AddCars(quantity)
    print("\n" .. string.rep("=", 50))
    print("🚀 STARTING TO ADD " .. quantity .. " ASTON MARTIN 12")
    print(string.rep("=", 50))
    
    local successCount = 0
    local failCount = 0
    
    -- Create simple status display
    local statusGui = Instance.new("ScreenGui")
    statusGui.Name = "StatusUI"
    statusGui.Parent = Player:WaitForChild("PlayerGui")
    
    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0, 250, 0, 100)
    statusFrame.Position = UDim2.new(0, 10, 0, 10)
    statusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    statusFrame.BackgroundTransparency = 0.2
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 10)
    statusCorner.Parent = statusFrame
    
    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Text = "Adding: 0/" .. quantity
    statusText.Size = UDim2.new(1, -20, 0.7, 0)
    statusText.Position = UDim2.new(0, 10, 0, 10)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.Font = Enum.Font.Gotham
    statusText.TextSize = 14
    
    -- Stop button
    local stopBtn = Instance.new("TextButton")
    stopBtn.Text = "⏹️ STOP"
    stopBtn.Size = UDim2.new(0.4, 0, 0, 25)
    stopBtn.Position = UDim2.new(0.3, 0, 0.7, 0)
    stopBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.Font = Enum.Font.Gotham
    stopBtn.TextSize = 12
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 6)
    stopCorner.Parent = stopBtn
    
    -- Parent status UI
    statusText.Parent = statusFrame
    stopBtn.Parent = statusFrame
    statusFrame.Parent = statusGui
    
    -- Variable to control adding
    local isAdding = true
    
    -- Stop button action
    stopBtn.MouseButton1Click:Connect(function()
        isAdding = false
        stopBtn.Text = "⏹️ STOPPED"
    end)
    
    -- Start adding in a separate thread
    task.spawn(function()
        for i = 1, quantity do
            if not isAdding then
                print("⏹️ Stopped by user at " .. i .. "/" .. quantity)
                break
            end
            
            -- Update status
            statusText.Text = "Adding: " .. i .. "/" .. quantity
            
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
                print("❌ Failed:", tostring(result))
                
                -- Handle rate limits
                local errorMsg = tostring(result)
                if errorMsg:find("rate") or errorMsg:find("wait") or errorMsg:find("too fast") then
                    print("⚠️ Rate limited, waiting 2 seconds...")
                    task.wait(2)
                end
            end
            
            -- Small random delay
            task.wait(math.random(50, 300) / 1000)
        end
        
        -- Update final status
        statusText.Text = "✅ COMPLETE!\nSuccess: " .. successCount .. "\nFailed: " .. failCount
        stopBtn.Text = "✕ CLOSE"
        
        -- Change stop button to close
        stopBtn.MouseButton1Click:Connect(function()
            statusGui:Destroy()
        end)
        
        -- Auto-close after 8 seconds
        task.wait(8)
        statusGui:Destroy()
        
        -- Final report
        print("\n" .. string.rep("=", 50))
        print("📊 FINAL REPORT")
        print(string.rep("=", 50))
        print("✅ Successfully added:", successCount)
        print("❌ Failed:", failCount)
        print("🎯 Total attempted:", math.min(quantity, successCount + failCount))
        
        if successCount + failCount > 0 then
            local rate = math.floor((successCount / (successCount + failCount)) * 100)
            print("📈 Success rate:", rate .. "%")
        end
        
        print(string.rep("=", 50))
    end)
    
    return statusGui
end

-- ===== MAIN EXECUTION =====
print("\n📋 INSTRUCTIONS:")
print("1. A popup will ask how many AstonMartin12 to add")
print("2. Enter number (or click: 10, 25, 50, 100)")
print("3. Click ✅ START ADDING")
print("4. Watch progress in top-left status")
print("5. Click ⏹️ STOP to stop anytime")

-- Create and show the popup
task.wait(1)

local popupGui, inputBox, addBtn = AskHowMany()

-- Handle add button click
addBtn.MouseButton1Click:Connect(function()
    -- Get quantity from input
    local quantityText = inputBox.Text
    local quantity = tonumber(quantityText)
    
    if not quantity or quantity <= 0 then
        print("❌ Invalid quantity:", quantityText)
        quantity = 10  -- Default to 10
    end
    
    if quantity > 1000 then
        print("⚠️ Limiting to 1000 max")
        quantity = 1000
    end
    
    -- Remove popup
    popupGui:Destroy()
    
    -- Start adding
    AddCars(quantity)
end)

-- Also allow Enter key to submit
inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local quantityText = inputBox.Text
        local quantity = tonumber(quantityText) or 10
        
        popupGui:Destroy()
        AddCars(quantity)
    end
end)

print("\n✅ Bot is ready! Check your screen for the popup.")
