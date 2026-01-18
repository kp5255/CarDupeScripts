-- Simple Trade Duplicator - Fixed Version
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

wait(2)

print("=== SIMPLE TRADE DUPLICATOR ===")

-- Get the critical remote
local SessionAddItem = ReplicatedStorage:FindFirstChild("SessionAddItem")

-- Simple function to get trade container
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

-- Get car ID from button
local function GetCarIdFromButton(button)
    -- First check for StringValue or IntValue
    for _, child in pairs(button:GetChildren()) do
        if child:IsA("StringValue") then
            return child.Value
        elseif child:IsA("IntValue") then
            return child.Value
        end
    end
    
    -- Try to extract from name
    local id = button.Name:match("%d+")
    if id then return tonumber(id) end
    
    -- Try from text
    if button:IsA("TextButton") then
        id = button.Text:match("%d+")
        if id then return tonumber(id) end
    end
    
    -- Return the button name as ID
    return button.Name
end

-- Check what's in trade window (FIXED VERSION)
local function CheckTradeItems()
    print("\n🔍 CHECKING TRADE ITEMS...")
    
    local container = GetTradeContainer()
    if not container then
        print("❌ No trade container found")
        return 0
    end
    
    local itemCount = 0
    print("Items found:")
    
    for _, item in pairs(container:GetChildren()) do
        if item:IsA("TextButton") or item:IsA("ImageButton") then
            itemCount = itemCount + 1
            
            local itemName = item.Name
            local itemText = item:IsA("TextButton") and item.Text or ""
            
            print("  " .. itemCount .. ". " .. itemName .. " - \"" .. itemText .. "\"")
            
            -- Show children info (FIXED: use .Text for TextLabel)
            for _, child in pairs(item:GetChildren()) do
                if child:IsA("TextLabel") then
                    print("    └─ " .. child.Name .. ": \"" .. child.Text .. "\"")
                elseif child:IsA("StringValue") or child:IsA("IntValue") then
                    print("    └─ " .. child.Name .. " [Value]: " .. tostring(child.Value))
                end
            end
            
            -- Check if this is a car
            if itemName:lower():find("car") or itemText:lower():find("car") then
                print("    🚗 THIS IS A CAR ITEM")
            end
        end
    end
    
    print("📊 Total items: " .. itemCount)
    return itemCount
end

-- Simple duplication: Click existing items multiple times
local function SimpleDuplicate()
    print("\n🔄 SIMPLE DUPLICATION METHOD...")
    
    local container = GetTradeContainer()
    if not container then
        print("❌ No trade container")
        return false
    end
    
    local clickCount = 0
    
    -- Find all buttons
    for _, button in pairs(container:GetChildren()) do
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            local buttonName = button.Name
            local buttonText = button:IsA("TextButton") and button.Text or ""
            
            print("Found button: " .. buttonName .. " - \"" .. buttonText .. "\"")
            
            -- Try to click it multiple times
            for i = 1, 5 do
                local success = pcall(function()
                    -- Try different click methods
                    button:Fire("Activated")
                    button:Fire("MouseButton1Click")
                    
                    -- Try to find and click any RemoteEvent
                    for _, child in pairs(button:GetChildren()) do
                        if child:IsA("RemoteEvent") then
                            child:FireServer("click")
                        end
                    end
                    
                    clickCount = clickCount + 1
                    print("  Click " .. i .. " successful")
                    return true
                end)
                
                if not success then
                    print("  Click " .. i .. " failed")
                end
                
                wait(0.1)
            end
        end
    end
    
    print("📊 Total clicks: " .. clickCount)
    return clickCount > 0
end

-- Use SessionAddItem remote directly
local function UseSessionAddItem()
    print("\n🎯 USING SessionAddItem REMOTE...")
    
    if not SessionAddItem then
        print("❌ SessionAddItem remote not found!")
        return false
    end
    
    -- First, get info about current items
    local container = GetTradeContainer()
    if not container then
        print("❌ No container to get item info")
        return false
    end
    
    -- Find a car button to duplicate
    local carButton = nil
    local carId = nil
    
    for _, button in pairs(container:GetChildren()) do
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            local name = button.Name:lower()
            local text = button:IsA("TextButton") and button.Text:lower() or ""
            
            if name:find("car") or text:find("car") then
                carButton = button
                carId = GetCarIdFromButton(button)
                print("Found car button: " .. button.Name)
                print("Car ID: " .. tostring(carId))
                break
            end
        end
    end
    
    if not carButton then
        print("❌ No car button found")
        return false
    end
    
    -- Try to add the car multiple times
    local successCount = 0
    
    for i = 1, 10 do
        print("\nAttempt " .. i .. " to add duplicate...")
        
        -- Method 1: Use the car ID
        local success1 = pcall(function()
            SessionAddItem:FireServer("trade_session", carId)
            print("✅ Added with ID: " .. tostring(carId))
            successCount = successCount + 1
        end)
        
        if not success1 then
            print("❌ Failed with ID method")
        end
        
        -- Method 2: Use button name
        local success2 = pcall(function()
            SessionAddItem:FireServer("trade_session", carButton.Name)
            print("✅ Added with name: " .. carButton.Name)
            successCount = successCount + 1
        end)
        
        if not success2 then
            print("❌ Failed with name method")
        end
        
        -- Method 3: Try table format
        local success3 = pcall(function()
            local itemData = {
                itemName = carButton.Name,
                itemType = "car",
                isDuplicate = true,
                attempt = i
            }
            SessionAddItem:FireServer("trade_session", itemData)
            print("✅ Added with table data")
            successCount = successCount + 1
        end)
        
        if not success3 then
            print("❌ Failed with table method")
        end
        
        wait(0.2)
    end
    
    print("\n📊 Total successful additions: " .. successCount)
    return successCount > 0
end

-- Find and click accept button
local function ClickAcceptButton()
    print("\n🤝 LOOKING FOR ACCEPT BUTTON...")
    
    local function FindAcceptButton(parent)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("TextButton") then
                local text = child.Text:lower()
                if text:find("accept") or text:find("confirm") or child.Name:lower():find("accept") then
                    return child
                end
            end
            
            if #child:GetChildren() > 0 then
                local result = FindAcceptButton(child)
                if result then return result end
            end
        end
        return nil
    end
    
    local acceptButton = FindAcceptButton(Player.PlayerGui)
    
    if acceptButton then
        print("✅ Found accept button: " .. acceptButton.Name)
        
        -- Click it multiple times
        for i = 1, 3 do
            pcall(function()
                acceptButton:Fire("MouseButton1Click")
                acceptButton:Fire("Activated")
                print("  Click " .. i .. " sent")
            end)
            wait(0.1)
        end
        
        return true
    else
        print("❌ No accept button found")
        return false
    end
end

-- Main execution
local function ExecuteAllMethods()
    print("\n🚀 EXECUTING ALL METHODS...")
    
    -- Check current items
    local beforeCount = CheckTradeItems()
    
    -- Try simple duplication
    wait(1)
    SimpleDuplicate()
    
    -- Try using SessionAddItem
    wait(1)
    UseSessionAddItem()
    
    -- Check again
    wait(1)
    local afterCount = CheckTradeItems()
    
    -- Click accept
    wait(1)
    ClickAcceptButton()
    
    -- Report results
    print("\n" .. string.rep("=", 40))
    print("RESULTS:")
    print("Items before: " .. beforeCount)
    print("Items after: " .. afterCount)
    
    if afterCount > beforeCount then
        print("✅ SUCCESS! Duplicates added!")
    else
        print("❌ No change in item count")
    end
    print(string.rep("=", 40))
    
    return afterCount > beforeCount
end

-- Create simple UI
local function CreateSimpleUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 220)
    frame.Position = UDim2.new(0.5, -150, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 40, 50)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "TRADE DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(50, 70, 90)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local output = Instance.new("TextLabel")
    output.Text = "Ready to duplicate items"
    output.Size = UDim2.new(1, -20, 0, 130)
    output.Position = UDim2.new(0, 10, 0, 50)
    output.BackgroundTransparency = 1
    output.TextColor3 = Color3.fromRGB(200, 220, 255)
    output.TextWrapped = true
    output.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Buttons in a grid
    local buttons = {
        {text = "🔍 Check", func = CheckTradeItems, pos = UDim2.new(0.05, 0, 0, 190)},
        {text = "🔄 Simple", func = SimpleDuplicate, pos = UDim2.new(0.37, 0, 0, 190)},
        {text = "🎯 Session", func = UseSessionAddItem, pos = UDim2.new(0.69, 0, 0, 190)},
        {text = "🚀 ALL", func = ExecuteAllMethods, pos = UDim2.new(0.05, 0, 0, 220)},
        {text = "🤝 Accept", func = ClickAcceptButton, pos = UDim2.new(0.37, 0, 0, 220)},
    }
    
    for _, btnInfo in pairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.text
        btn.Size = UDim2.new(0.29, 0, 0, 25)
        btn.Position = btnInfo.pos
        btn.BackgroundColor3 = Color3.fromRGB(60, 90, 120)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        
        btn.MouseButton1Click:Connect(function()
            output.Text = "Running: " .. btnInfo.text .. "..."
            spawn(function()
                btnInfo.func()
                wait(0.5)
                output.Text = "Completed: " .. btnInfo.text
            end)
        end)
        
        btn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    output.Parent = frame
    frame.Parent = gui
    
    return output
end

-- Initialize
local outputLabel = CreateSimpleUI()

-- Update print to also update UI
local originalPrint = print
print = function(...)
    local args = {...}
    local message = table.concat(args, " ")
    originalPrint(message)
    
    -- Update UI with important messages
    if message:find("✅") or message:find("❌") or message:find("🚗") then
        outputLabel.Text = message .. "\n" .. outputLabel.Text
    end
end

-- Auto-start instructions
wait(3)
print("\n=== SIMPLE TRADE DUPLICATOR ===")
print("SessionAddItem found: " .. tostring(SessionAddItem ~= nil))

print("\n📋 HOW TO USE:")
print("1. Start trade with another player")
print("2. Add ONE car to trade")
print("3. Click 'Check' to see current items")
print("4. Click 'Session' to try duplication")
print("5. Click 'ALL' for complete process")
print("6. Ask other player if they see duplicates")

-- Keybinds
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.C then
        print("\n🎮 C KEY - CHECKING ITEMS")
        CheckTradeItems()
    elseif input.KeyCode == Enum.KeyCode.D then
        print("\n🎮 D KEY - DUPLICATING")
        UseSessionAddItem()
    elseif input.KeyCode == Enum.KeyCode.A then
        print("\n🎮 A KEY - ALL METHODS")
        ExecuteAllMethods()
    end
end)

print("\n🔑 QUICK KEYS:")
print("C = Check items")
print("D = Duplicate (Session method)")
print("A = All methods")

-- Auto-check after delay
spawn(function()
    wait(5)
    print("\n🔍 Auto-checking trade container...")
    CheckTradeItems()
end)
