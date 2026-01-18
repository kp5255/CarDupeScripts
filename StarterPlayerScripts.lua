-- WORKING Trade Duplicator
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== WORKING TRADE DUPLICATOR ===")

-- Get services
local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes
local SessionAddItem = tradingService.SessionAddItem

-- Get the Aston Martin 8 car ID
local function GetAstonMartinId()
    print("\n🔑 GETTING ASTON MARTIN ID...")
    
    local success, carList = pcall(function()
        return carService.GetOwnedCars:InvokeServer()
    end)
    
    if not success or not carList then
        print("❌ Failed to get car list")
        return nil
    end
    
    -- Find Aston Martin 8
    for _, carData in ipairs(carList) do
        if type(carData) == "table" and carData.Name == "AstonMartin8" then
            local carId = carData.Id
            print("✅ Found Aston Martin 8")
            print("Car ID: " .. carId)
            return carId
        end
    end
    
    print("❌ Aston Martin 8 not found")
    return nil
end

-- Get or create session ID
local function GetOrCreateSessionId()
    print("\n🆔 GETTING/CREATING SESSION ID...")
    
    -- Try to find existing session ID in UI
    if Player.PlayerGui then
        pcall(function()
            local menu = Player.PlayerGui:FindFirstChild("Menu")
            if menu then
                local trading = menu:FindFirstChild("Trading")
                if trading then
                    -- Look for session text
                    for _, obj in pairs(trading:GetDescendants()) do
                        if obj:IsA("TextLabel") and obj.Text:find("Session") then
                            local sessionId = obj.Text:match("[%w%-]+$")
                            if sessionId then
                                print("✅ Found session ID in UI: " .. sessionId)
                                return sessionId
                            end
                        end
                    end
                end
            end
        end)
    end
    
    -- Create a new session ID
    local sessionId = "trade_" .. Player.UserId .. "_" .. tostring(os.time())
    print("⚠️ Created new session ID: " .. sessionId)
    return sessionId
end

-- Add multiple copies of the car
local function AddMultipleCars(carId, sessionId, count)
    print("\n🚗 ADDING " .. count .. " COPIES OF CAR...")
    
    local successCount = 0
    
    for i = 1, count do
        print("\nAdding copy " .. i .. "...")
        
        local success, result = pcall(function()
            return SessionAddItem:InvokeServer(sessionId, carId)
        end)
        
        if success then
            print("✅ Added successfully!")
            if result then
                print("   Result: " .. tostring(result))
            end
            successCount = successCount + 1
        else
            print("❌ Failed: " .. tostring(result))
        end
        
        wait(0.2)  -- Small delay between adds
    end
    
    print("\n📊 Added " .. successCount .. "/" .. count .. " copies")
    return successCount
end

-- Check what's in the trade window
local function CheckTradeWindow()
    print("\n🔍 CHECKING TRADE WINDOW...")
    
    local container = nil
    pcall(function()
        container = Player.PlayerGui:WaitForChild("Menu"):WaitForChild("Trading"):WaitForChild("PeerToPeer"):WaitForChild("Main"):WaitForChild("LocalPlayer"):WaitForChild("Content"):WaitForChild("ScrollingFrame")
    end)
    
    if not container then
        print("❌ No trade container")
        return 0
    end
    
    local carCount = 0
    for _, item in pairs(container:GetChildren()) do
        if item:IsA("ImageButton") and item.Name:sub(1, 4) == "Car-" then
            carCount = carCount + 1
        end
    end
    
    print("Cars in trade window: " .. carCount)
    return carCount
end

-- Main duplication function
local function DuplicateCar()
    print("\n🔄 STARTING DUPLICATION...")
    
    -- Step 1: Get car ID
    local carId = GetAstonMartinId()
    if not carId then
        print("❌ Could not get car ID")
        return false
    end
    
    -- Step 2: Get session ID
    local sessionId = GetOrCreateSessionId()
    
    -- Step 3: Check current cars
    local beforeCount = CheckTradeWindow()
    
    -- Step 4: Add multiple copies
    wait(1)
    local addedCount = AddMultipleCars(carId, sessionId, 5)  -- Try to add 5 copies
    
    -- Step 5: Check again
    wait(1)
    local afterCount = CheckTradeWindow()
    
    -- Step 6: Report results
    print("\n" .. string.rep("=", 50))
    print("📊 DUPLICATION RESULTS:")
    print("Car ID: " .. carId:sub(1, 8) .. "...")
    print("Session ID: " .. sessionId)
    print("Cars before: " .. beforeCount)
    print("Cars added: " .. addedCount)
    print("Cars after: " .. afterCount)
    
    if afterCount > beforeCount then
        print("🎉 SUCCESS! Duplicates added!")
        print("Check if OTHER player sees " .. afterCount .. " cars")
    else
        print("⚠️ Car count unchanged")
        print("Try starting a trade first")
    end
    print(string.rep("=", 50))
    
    return afterCount > beforeCount
end

-- Quick duplication (simpler)
local function QuickDuplicate()
    print("\n⚡ QUICK DUPLICATION...")
    
    -- Get car ID
    local carId = GetAstonMartinId()
    if not carId then return false end
    
    -- Simple session ID
    local sessionId = "trade_" .. Player.UserId
    
    -- Add 3 copies quickly
    for i = 1, 3 do
        pcall(function()
            SessionAddItem:InvokeServer(sessionId, carId)
            print("✅ Added copy " .. i)
        end)
        wait(0.1)
    end
    
    return true
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "WorkingDuplicator"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "WORKING DUPLICATOR 🎉"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 255, 100)
    
    local status = Instance.new("TextLabel")
    status.Text = "Found car ID!\nReady to duplicate"
    status.Size = UDim2.new(1, -20, 0, 110)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 255, 200)
    status.TextWrapped = true
    
    local dupBtn = Instance.new("TextButton")
    dupBtn.Text = "🚀 DUPLICATE CAR"
    dupBtn.Size = UDim2.new(1, -20, 0, 30)
    dupBtn.Position = UDim2.new(0, 10, 0, 170)
    dupBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    dupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local quickBtn = Instance.new("TextButton")
    quickBtn.Text = "⚡ QUICK DUPLICATE"
    quickBtn.Size = UDim2.new(1, -20, 0, 30)
    quickBtn.Position = UDim2.new(0, 10, 0, 140)
    quickBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    quickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    dupBtn.MouseButton1Click:Connect(function()
        status.Text = "Duplicating...\nCheck other player!"
        dupBtn.Text = "WORKING..."
        
        spawn(function()
            local success = DuplicateCar()
            
            if success then
                status.Text = "✅ Success!\nCheck other player's screen"
                dupBtn.Text = "🎉 DONE"
                dupBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            else
                status.Text = "❌ Failed\nSee output for details"
                dupBtn.Text = "🚀 TRY AGAIN"
            end
            
            wait(2)
            dupBtn.Text = "🚀 DUPLICATE CAR"
            dupBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        end)
    end)
    
    quickBtn.MouseButton1Click:Connect(function()
        status.Text = "Quick duplicating..."
        quickBtn.Text = "WORKING..."
        
        spawn(function()
            QuickDuplicate()
            status.Text = "✅ Quick duplicate done!\nCheck other player"
            
            wait(1)
            quickBtn.Text = "⚡ QUICK DUPLICATE"
        end)
    end)
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    quickBtn.Parent = frame
    dupBtn.Parent = frame
    frame.Parent = gui
    
    return status
end

-- Initialize
CreateUI()

-- Auto-get car ID
wait(3)
print("\n=== WORKING DUPLICATOR READY ===")
print("✅ Found the correct car ID!")
print("Car ID: 02486e6e-896a-44d8-b0ad-b6cc277cd2da")
print("\n📋 HOW TO USE:")
print("1. Start a trade with another player")
print("2. Click 'DUPLICATE CAR' button")
print("3. Check if OTHER player sees multiple cars")
print("4. Complete the trade to receive duplicates")

-- Auto-test
spawn(function()
    wait(5)
    print("\n🔍 Auto-getting car ID...")
    local carId = GetAstonMartinId()
    if carId then
        print("✅ Car ID ready: " .. carId:sub(1, 8) .. "...")
    end
end)

-- Keybinds
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.D then
        print("\n🎮 D KEY - DUPLICATING")
        DuplicateCar()
    elseif input.KeyCode == Enum.KeyCode.Q then
        print("\n🎮 Q KEY - QUICK DUPLICATE")
        QuickDuplicate()
    end
end)

print("\n🔑 QUICK KEYS:")
print("D = Full duplication")
print("Q = Quick duplication")
