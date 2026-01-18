-- Correct Trade Duplicator - Using RemoteFunction
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

wait(2)

print("=== CORRECT TRADE DUPLICATOR ===")
print("Found SessionAddItem as RemoteFunction!")

-- Get the CORRECT remote function path
local TradingServiceRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local SessionAddItem = TradingServiceRemotes:WaitForChild("SessionAddItem")
local SessionRemoveItem = TradingServiceRemotes:WaitForChild("SessionRemoveItem")
local SessionSetConfirmation = TradingServiceRemotes:WaitForChild("SessionSetConfirmation")
local OnSessionItemsUpdated = TradingServiceRemotes:WaitForChild("OnSessionItemsUpdated")

print("✅ Loaded TradingServiceRemotes")
print("SessionAddItem type: " .. SessionAddItem.ClassName)
print("SessionAddItem is RemoteFunction: " .. tostring(SessionAddItem:IsA("RemoteFunction")))

-- Get current session ID
local function GetCurrentSessionId()
    -- Look in the PeerToPeer UI for session ID
    if Player.PlayerGui then
        local menu = Player.PlayerGui:FindFirstChild("Menu")
        if menu then
            local trading = menu:FindFirstChild("Trading")
            if trading then
                local peerToPeer = trading:FindFirstChild("PeerToPeer")
                if peerToPeer then
                    -- Check for session ID in UI elements
                    for _, obj in pairs(peerToPeer:GetDescendants()) do
                        if obj:IsA("TextLabel") and (obj.Text:find("Session") or obj.Name:find("Session")) then
                            local sessionId = obj.Text:match("Session:?(%S+)") or obj.Name:match("Session:?(%S+)")
                            if sessionId then
                                return sessionId
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Default session ID (might work)
    return "current_trade_session"
end

-- Get car ID from trade window
local function GetCarIdFromTrade()
    local container = GetTradeContainer()
    if not container then return nil end
    
    for _, item in pairs(container:GetChildren()) do
        if item:IsA("TextButton") or item:IsA("ImageButton") then
            -- Check for car indicators
            local name = item.Name:lower()
            local text = item:IsA("TextButton") and item.Text:lower() or ""
            
            if name:find("car") or text:find("car") or name:find("vehicle") then
                print("🚗 Found car item: " .. item.Name)
                
                -- Look for item ID in children
                for _, child in pairs(item:GetChildren()) do
                    if child:IsA("StringValue") then
                        print("  StringValue: " .. child.Name .. " = " .. child.Value)
                        return child.Value
                    elseif child:IsA("IntValue") then
                        print("  IntValue: " .. child.Name .. " = " .. child.Value)
                        return tostring(child.Value)
                    end
                end
                
                -- Try to extract from name
                local id = item.Name:match("%d+")
                if id then
                    print("  Extracted ID from name: " .. id)
                    return id
                end
                
                -- Return button name as ID
                print("  Using button name as ID: " .. item.Name)
                return item.Name
            end
        end
    end
    
    return nil
end

-- Get trade container
local function GetTradeContainer()
    if not Player.PlayerGui then return nil end
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then return nil end
    local trading = menu:FindFirstChild("Trading")
    if not trading then return nil end
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then return nil end
    local main = peerToPeer:FindFirstChild("Main")
    if not main then return nil end
    local localPlayer = main:FindFirstChild("LocalPlayer")
    if not localPlayer then return nil end
    local content = localPlayer:FindFirstChild("Content")
    if not content then return nil end
    return content:FindFirstChild("ScrollingFrame")
end

-- CORRECT: Use InvokeServer on RemoteFunction
local function AddCarToSession()
    print("\n🎯 ADDING CAR TO SESSION (CORRECT METHOD)...")
    
    local sessionId = GetCurrentSessionId()
    local carId = GetCarIdFromTrade()
    
    if not carId then
        print("❌ Could not get car ID")
        return false
    end
    
    print("Session ID: " .. sessionId)
    print("Car ID: " .. carId)
    
    local successCount = 0
    
    -- Try multiple times with different approaches
    for i = 1, 10 do
        print("\nAttempt " .. i .. "...")
        
        -- Method 1: Just car ID
        local success1, result1 = pcall(function()
            return SessionAddItem:InvokeServer(sessionId, carId)
        end)
        
        if success1 then
            print("✅ Added with car ID: " .. carId)
            if result1 then
                print("   Server returned: " .. tostring(result1))
            end
            successCount = successCount + 1
        else
            print("❌ Failed with car ID")
        end
        
        wait(0.2)
        
        -- Method 2: Car ID with quantity
        local success2, result2 = pcall(function()
            return SessionAddItem:InvokeServer(sessionId, carId, 1)  -- Quantity = 1
        end)
        
        if success2 then
            print("✅ Added with car ID + quantity")
            successCount = successCount + 1
        end
        
        wait(0.2)
        
        -- Method 3: Table format
        local success3, result3 = pcall(function()
            local itemData = {
                id = carId,
                type = "Car",
                name = "Car_Duplicate_" .. i
            }
            return SessionAddItem:InvokeServer(sessionId, itemData)
        end)
        
        if success3 then
            print("✅ Added with table data")
            successCount = successCount + 1
        end
        
        wait(0.2)
    end
    
    print("\n📊 Successful additions: " .. successCount)
    return successCount > 0
end

-- Force session update
local function ForceSessionUpdate()
    print("\n🔄 FORCING SESSION UPDATE...")
    
    local sessionId = GetCurrentSessionId()
    
    -- Try to trigger the update event
    for i = 1, 3 do
        pcall(function()
            OnSessionItemsUpdated:FireServer(sessionId, {force = true, update = true})
            print("✅ Triggered update " .. i)
        end)
        wait(0.2)
    end
end

-- Set confirmation to true (accept trade)
local function AcceptTrade()
    print("\n🤝 ACCEPTING TRADE...")
    
    local sessionId = GetCurrentSessionId()
    
    for i = 1, 5 do
        local success, result = pcall(function()
            return SessionSetConfirmation:InvokeServer(sessionId, true)  -- true = confirmed
        end)
        
        if success then
            print("✅ Set confirmation to TRUE (attempt " .. i .. ")")
            if result then
                print("   Server response: " .. tostring(result))
            end
        else
            print("❌ Failed to set confirmation")
        end
        
        wait(0.2)
    end
end

-- Check current session items
local function CheckSessionItems()
    print("\n🔍 CHECKING SESSION...")
    
    -- Get the container
    local container = GetTradeContainer()
    if container then
        print("Items in trade window:")
        local count = 0
        for _, item in pairs(container:GetChildren()) do
            if item:IsA("TextButton") or item:IsA("ImageButton") then
                count = count + 1
                local name = item.Name
                local text = item:IsA("TextButton") and item.Text or ""
                print("  " .. count .. ". " .. name .. " - \"" .. text .. "\"")
            end
        end
        print("Total: " .. count .. " items")
        return count
    end
    
    return 0
end

-- Main execution
local function ExecuteCorrectDuplication()
    print("\n🚀 EXECUTING CORRECT DUPLICATION...")
    
    -- Step 1: Check current items
    local beforeCount = CheckSessionItems()
    
    -- Step 2: Add duplicate using CORRECT method
    wait(1)
    AddCarToSession()
    
    -- Step 3: Force update
    wait(1)
    ForceSessionUpdate()
    
    -- Step 4: Check again
    wait(1)
    local afterCount = CheckSessionItems()
    
    -- Step 5: If successful, accept trade
    if afterCount > beforeCount then
        print("\n🎉 DUPLICATION SUCCESSFUL!")
        print("Items increased from " .. beforeCount .. " to " .. afterCount)
        wait(1)
        AcceptTrade()
    else
        print("\n❌ No change in item count")
    end
    
    return afterCount > beforeCount
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CorrectDuplicator"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "CORRECT DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 255, 100)
    title.Font = Enum.Font.GothamBold
    
    local status = Instance.new("TextLabel")
    status.Text = "Status: Ready\nUsing RemoteFunction"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 255, 200)
    status.TextWrapped = true
    
    -- Buttons
    local buttons = {
        {text = "🔍 Check", func = CheckSessionItems, pos = UDim2.new(0.025, 0, 0, 120)},
        {text = "🎯 Add Car", func = AddCarToSession, pos = UDim2.new(0.025, 0, 0, 150)},
        {text = "🔄 Update", func = ForceSessionUpdate, pos = UDim2.new(0.025, 0, 0, 180)},
        {text = "🚀 Execute All", func = ExecuteCorrectDuplication, pos = UDim2.new(0.025, 0, 0, 210)},
        {text = "🤝 Accept", func = AcceptTrade, pos = UDim2.new(0.525, 0, 0, 120)},
        {text = "📊 Get Car ID", func = GetCarIdFromTrade, pos = UDim2.new(0.525, 0, 0, 150)},
        {text = "🆔 Get Session", func = GetCurrentSessionId, pos = UDim2.new(0.525, 0, 0, 180)}
    }
    
    for _, btnInfo in pairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.text
        btn.Size = UDim2.new(0.45, 0, 0, 25)
        btn.Position = btnInfo.pos
        btn.BackgroundColor3 = Color3.fromRGB(70, 100, 120)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        
        btn.MouseButton1Click:Connect(function()
            status.Text = "Running: " .. btnInfo.text
            spawn(function()
                btnInfo.func()
                wait(0.5)
                status.Text = "Completed: " .. btnInfo.text
            end)
        end)
        
        btn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    frame.Parent = gui
    
    return status
end

-- Initialize
CreateUI()

-- Auto-start
wait(3)
print("\n=== CORRECT TRADE DUPLICATOR LOADED ===")
print("Using SessionAddItem as RemoteFunction")
print("Must use :InvokeServer() not :FireServer()")

print("\n📋 HOW TO USE:")
print("1. Start trade with another player")
print("2. Add ONE car to trade normally")
print("3. Click 'Get Car ID' to identify car")
print("4. Click 'Add Car' to attempt duplication")
print("5. Click 'Execute All' for complete process")
print("6. Check if OTHER player sees duplicates!")

-- Keybinds
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.A then
        print("\n🎮 A KEY - ADDING CAR")
        AddCarToSession()
    elseif input.KeyCode == Enum.KeyCode.E then
        print("\n🎮 E KEY - EXECUTE ALL")
        ExecuteCorrectDuplication()
    elseif input.KeyCode == Enum.KeyCode.C then
        print("\n🎮 C KEY - CHECK ITEMS")
        CheckSessionItems()
    end
end)

print("\n🔑 QUICK KEYS:")
print("A = Add car to session")
print("E = Execute all methods")
print("C = Check current items")
