-- Direct Trade Session Manipulation
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

wait(2)

print("=== DIRECT TRADE SESSION DUPLICATOR ===")

-- Store critical remotes we found
local SessionAddItem = ReplicatedStorage:FindFirstChild("SessionAddItem")
local SessionRemoveItem = ReplicatedStorage:FindFirstChild("SessionRemoveItem")
local SessionSetConfirmation = ReplicatedStorage:FindFirstChild("SessionSetConfirmation")

-- Get current trade session ID
local function GetCurrentSessionId()
    -- Look for session data in various places
    if Player.PlayerGui then
        local menu = Player.PlayerGui:FindFirstChild("Menu")
        if menu then
            local trading = menu:FindFirstChild("Trading")
            if trading then
                -- Try to find session ID in UI
                for _, obj in pairs(trading:GetDescendants()) do
                    if obj:IsA("TextLabel") and obj.Text:find("Session") then
                        return obj.Text:match("Session:?(%S+)") or "unknown"
                    end
                end
            end
        end
    end
    return "default_session"
end

-- Get the car ID from trade window
local function GetCarIdFromTrade()
    local container = GetTradeContainer()
    if not container then return nil end
    
    for _, item in pairs(container:GetChildren()) do
        if item:IsA("TextButton") or item:IsA("ImageButton") then
            local name = item.Name
            local text = item:IsA("TextButton") and item.Text or ""
            
            if name:find("Car") or text:find("Car") then
                -- Try to extract car ID from button properties
                for _, child in pairs(item:GetChildren()) do
                    if child:IsA("StringValue") or child:IsA("IntValue") then
                        return child.Value
                    end
                end
                
                -- Try to get from name
                local id = name:match("%d+") or text:match("%d+")
                if id then
                    return tonumber(id)
                end
            end
        end
    end
    return nil
end

-- Get trade container (from your original script)
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

-- DIRECT METHOD: Add duplicate car to session
local function AddDuplicateCarToSession()
    print("\n🎯 ATTEMPTING DIRECT SESSION ADDITION...")
    
    if not SessionAddItem then
        print("❌ SessionAddItem remote not found!")
        return false
    end
    
    local sessionId = GetCurrentSessionId()
    local carId = GetCarIdFromTrade()
    
    if not carId then
        print("❌ Could not get car ID from trade window")
        return false
    end
    
    print("Session ID: " .. sessionId)
    print("Car ID: " .. tostring(carId))
    
    -- Try to add duplicate with different parameters
    local successCount = 0
    
    for i = 1, 5 do  -- Try multiple times with variations
        print("\nAttempt " .. i .. " to add duplicate...")
        
        -- Method 1: Add same car again
        local success1 = pcall(function()
            SessionAddItem:FireServer(sessionId, carId)
            print("✅ Added car to session (same ID)")
            return true
        end)
        
        if success1 then successCount = successCount + 1 end
        
        -- Method 2: Add with modified ID
        local success2 = pcall(function()
            local fakeCarId = carId .. "_DUPLICATE_" .. i
            SessionAddItem:FireServer(sessionId, fakeCarId)
            print("✅ Added car with fake ID: " .. fakeCarId)
            return true
        end)
        
        if success2 then successCount = successCount + 1 end
        
        -- Method 3: Add with table data
        local success3 = pcall(function()
            local itemData = {
                id = carId,
                name = "Car_Duplicate_" .. i,
                type = "vehicle",
                isDuplicate = true
            }
            SessionAddItem:FireServer(sessionId, itemData)
            print("✅ Added car with data table")
            return true
        end)
        
        if success3 then successCount = successCount + 1 end
        
        wait(0.3)
    end
    
    print("\n📊 Total successful additions: " .. successCount)
    return successCount > 0
end

-- Force update session items
local function ForceSessionUpdate()
    print("\n🔄 FORCING SESSION UPDATE...")
    
    -- Look for OnSessionItemsUpdated remote
    local OnSessionItemsUpdated = ReplicatedStorage:FindFirstChild("OnSessionItemsUpdated")
    
    if OnSessionItemsUpdated then
        local sessionId = GetCurrentSessionId()
        
        -- Try to trigger update
        for i = 1, 3 do
            pcall(function()
                OnSessionItemsUpdated:FireServer(sessionId, {forceUpdate = true})
                print("✅ Triggered session update " .. i)
            end)
            wait(0.2)
        end
    else
        print("❌ OnSessionItemsUpdated not found")
    end
end

-- Simulate multiple accept clicks
local function SpamAcceptButton()
    print("\n🤝 SPAMMING ACCEPT BUTTON...")
    
    local acceptButton = FindAcceptButton()
    if not acceptButton then
        print("❌ Accept button not found")
        return false
    end
    
    print("Found accept button: " .. acceptButton.Name)
    
    -- Click multiple times
    for i = 1, 10 do
        pcall(function()
            acceptButton:Fire("MouseButton1Click")
            acceptButton:Fire("Activated")
            
            -- Also try to use SessionSetConfirmation
            if SessionSetConfirmation then
                local sessionId = GetCurrentSessionId()
                SessionSetConfirmation:FireServer(sessionId, true)  -- true = confirmed
            end
            
            print("✅ Accept click " .. i)
        end)
        wait(0.1)
    end
    
    return true
end

-- Find accept button
local function FindAcceptButton()
    if not Player.PlayerGui then return nil end
    
    local function SearchButton(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("TextButton") then
                local text = child.Text:lower()
                if text:find("accept") 
                   or text:find("confirm") 
                   or text:find("trade") 
                   or child.Name:lower():find("accept") then
                    return child
                end
            end
            
            if #child:GetChildren() > 0 then
                local result = SearchButton(child)
                if result then return result end
            end
        end
        return nil
    end
    
    return SearchButton(Player.PlayerGui)
end

-- Check what items are in the session
local function CheckSessionItems()
    print("\n🔍 CHECKING SESSION ITEMS...")
    
    local container = GetTradeContainer()
    if not container then
        print("❌ No trade container")
        return 0
    end
    
    local itemCount = 0
    print("Items in trade window:")
    
    for _, item in pairs(container:GetChildren()) do
        if item:IsA("TextButton") or item:IsA("ImageButton") then
            itemCount = itemCount + 1
            local name = item.Name
            local text = item:IsA("TextButton") and item.Text or ""
            print("  " .. itemCount .. ". " .. name .. " - \"" .. text .. "\"")
            
            -- Show children
            for _, child in pairs(item:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("StringValue") then
                    print("    └─ " .. child.Name .. ": " .. tostring(child.Value or child.Text))
                end
            end
        end
    end
    
    print("📊 Total items: " .. itemCount)
    return itemCount
end

-- Main execution
local function ExecuteDirectDuplication()
    print("\n🚀 EXECUTING DIRECT DUPLICATION...")
    
    -- Step 1: Check current items
    local initialCount = CheckSessionItems()
    
    -- Step 2: Try to add duplicate directly to session
    AddDuplicateCarToSession()
    
    -- Step 3: Force session update
    wait(1)
    ForceSessionUpdate()
    
    -- Step 4: Check again
    wait(1)
    local newCount = CheckSessionItems()
    
    -- Step 5: If items increased, try to spam accept
    if newCount > initialCount then
        print("\n🎉 DUPLICATION SUCCESSFUL! Items: " .. initialCount .. " → " .. newCount)
        print("Attempting to secure with accept spam...")
        wait(1)
        SpamAcceptButton()
    else
        print("\n❌ Duplication failed. Items unchanged: " .. initialCount)
    end
    
    return newCount > initialCount
end

-- Create focused UI
local function CreateFocusedUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "DIRECT SESSION DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.TextColor3 = Color3.fromRGB(255, 150, 100)
    title.Font = Enum.Font.GothamBold
    
    local status = Instance.new("TextLabel")
    status.Text = "Status: Ready"
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 200, 255)
    status.TextWrapped = true
    
    local log = Instance.new("ScrollingFrame")
    log.Size = UDim2.new(1, -20, 0, 80)
    log.Position = UDim2.new(0, 10, 0, 120)
    log.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    log.ScrollBarThickness = 6
    
    local logText = Instance.new("TextLabel")
    logText.Size = UDim2.new(1, 0, 2, 0)  -- Larger for scrolling
    logText.BackgroundTransparency = 1
    logText.TextColor3 = Color3.fromRGB(180, 220, 255)
    logText.TextWrapped = true
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.TextYAlignment = Enum.TextYAlignment.Top
    logText.Font = Enum.Font.Code
    logText.TextSize = 12
    logText.Text = "Waiting for action...\n"
    
    logText.Parent = log
    
    -- Buttons
    local buttons = {
        {text = "🔍 CHECK ITEMS", func = CheckSessionItems, pos = UDim2.new(0.025, 0, 0, 210)},
        {text = "🚗 ADD DUPLICATE", func = AddDuplicateCarToSession, pos = UDim2.new(0.025, 0, 0, 240)},
        {text = "🚀 FULL EXECUTE", func = ExecuteDirectDuplication, pos = UDim2.new(0.525, 0, 0, 210)},
        {text = "🤝 SPAM ACCEPT", func = SpamAcceptButton, pos = UDim2.new(0.525, 0, 0, 240)}
    }
    
    for _, btnInfo in pairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.text
        btn.Size = UDim2.new(0.45, 0, 0, 25)
        btn.Position = btnInfo.pos
        btn.BackgroundColor3 = Color3.fromRGB(50, 70, 100)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        btn.MouseButton1Click:Connect(function()
            btn.Text = "RUNNING..."
            status.Text = "Executing: " .. btnInfo.text
            
            spawn(function()
                btnInfo.func()
                wait(1)
                btn.Text = btnInfo.text
                status.Text = "Status: Completed"
            end)
        end)
        
        btn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    log.Parent = frame
    frame.Parent = gui
    
    -- Hook print to log
    local originalPrint = print
    print = function(...)
        local args = {...}
        local message = table.concat(args, " ")
        originalPrint(message)
        logText.Text = "> " .. message .. "\n" .. logText.Text
    end
    
    return status
end

-- Initialize
CreateFocusedUI()

-- Auto-start
wait(3)
print("\n=== DIRECT SESSION DUPLICATOR LOADED ===")
print("Found critical remotes:")
print("  • SessionAddItem: " .. tostring(SessionAddItem ~= nil))
print("  • SessionRemoveItem: " .. tostring(SessionRemoveItem ~= nil))
print("  • SessionSetConfirmation: " .. tostring(SessionSetConfirmation ~= nil))

print("\n📋 INSTRUCTIONS:")
print("1. Start trade with other player")
print("2. Add a car to trade normally")
print("3. Click 'CHECK ITEMS' to see current count")
print("4. Click 'ADD DUPLICATE' to try duplication")
print("5. Click 'FULL EXECUTE' for complete process")
print("6. Check if OTHER player sees the duplicate")

-- Keybinds
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.A then
        print("\n🎮 A KEY - ADD DUPLICATE")
        AddDuplicateCarToSession()
    elseif input.KeyCode == Enum.KeyCode.S then
        print("\n🎮 S KEY - CHECK ITEMS")
        CheckSessionItems()
    elseif input.KeyCode == Enum.KeyCode.F then
        print("\n🎮 F KEY - FULL EXECUTE")
        ExecuteDirectDuplication()
    end
end)

print("\n🔑 CONTROLS:")
print("A = Add duplicate to session")
print("S = Check current items")
print("F = Full execution")
