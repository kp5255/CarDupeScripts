-- Advanced Trade Duplicator - Attempts server-side duplication
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

wait(2)

print("=== ADVANCED TRADE DUPLICATOR ===")

-- Find remote events/functions for trading
local function FindTradeRemotes()
    print("\n🔍 SEARCHING FOR TRADE REMOTES...")
    
    local remotes = {}
    
    -- Check ReplicatedStorage
    local rs = ReplicatedStorage
    for _, child in pairs(rs:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            if child.Name:lower():find("trade") 
               or child.Name:lower():find("offer")
               or child.Name:lower():find("item") then
                print("✅ Found remote: " .. child.Name .. " (" .. child.ClassName .. ")")
                table.insert(remotes, child)
            end
        end
    end
    
    -- Check ReplicatedFirst
    local rf = game:GetService("ReplicatedFirst")
    for _, child in pairs(rf:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            print("✅ Found remote in ReplicatedFirst: " .. child.Name)
            table.insert(remotes, child)
        end
    end
    
    return remotes
end

-- Get the trade container (same as before)
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

-- Find actual car buttons/items in the trade UI
local function FindTradeItems()
    print("\n🔍 FINDING TRADE ITEMS...")
    
    local container = GetTradeContainer()
    if not container then return {} end
    
    local items = {}
    local buttonCount = 0
    
    -- Look for clickable items (buttons, imagebuttons)
    for _, item in pairs(container:GetChildren()) do
        if item:IsA("TextButton") or item:IsA("ImageButton") then
            buttonCount = buttonCount + 1
            
            -- Check if it looks like a car item
            local itemName = item.Name
            local itemText = ""
            
            if item:IsA("TextButton") then
                itemText = item.Text
            end
            
            print("Button " .. buttonCount .. ": " .. itemName .. " - \"" .. itemText .. "\"")
            
            -- Check for car indicators
            if itemName:find("Car") 
               or itemText:find("Car")
               or itemName:find("Vehicle")
               or itemText:find("Vehicle")
               or (string.len(itemName) <= 5 and itemText ~= "") then
                
                print("🚗 Potential car item found!")
                
                -- Get item info from children
                local itemData = {
                    Button = item,
                    Name = itemName,
                    Text = itemText,
                    Children = {}
                }
                
                -- Collect child data (for price, name, etc.)
                for _, child in pairs(item:GetChildren()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        itemData.Children[child.Name] = {
                            Text = child.Text,
                            Class = child.ClassName
                        }
                    end
                end
                
                table.insert(items, itemData)
            end
        end
    end
    
    print("\n📊 Found " .. #items .. " potential car items")
    return items
end

-- Try to simulate clicking the car to add it to trade
local function SimulateAddCar(carButton)
    print("\n🎯 SIMULATING ADD CAR: " .. carButton.Name)
    
    -- Method 1: Fire the button's click
    local success1, result1 = pcall(function()
        -- Try to fire the click event
        carButton:FireServer("AddToTrade")
        return true
    end)
    
    if success1 then
        print("✅ Fired AddToTrade to server")
        return true
    end
    
    -- Method 2: Call remote event directly
    local remotes = FindTradeRemotes()
    for _, remote in pairs(remotes) do
        local success2, result2 = pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer("AddItem", carButton.Name, Player)
                print("✅ Fired " .. remote.Name .. " with item: " .. carButton.Name)
                return true
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer("AddTradeItem", carButton.Name)
                print("✅ Invoked " .. remote.Name .. " with item: " .. carButton.Name)
                return true
            end
        end)
        
        if success2 and result2 then
            return true
        end
    end
    
    -- Method 3: Simulate mouse click
    local success3, result3 = pcall(function()
        local clickDetector = carButton:FindFirstChildOfClass("ClickDetector")
        if clickDetector then
            clickDetector.MaxActivationDistance = 0
            fireclickdetector(clickDetector)
            print("✅ Fired click detector")
            return true
        end
    end)
    
    -- Method 4: Fire mouse events
    local success4 = pcall(function()
        local mouse = game:GetService("Players").LocalPlayer:GetMouse()
        
        -- Store original position
        local originalPos = Vector2.new(mouse.X, mouse.Y)
        
        -- Move mouse to button
        local buttonPos = carButton.AbsolutePosition + carButton.AbsoluteSize/2
        
        -- Try to simulate click
        carButton:Fire("MouseButton1Down")
        wait(0.1)
        carButton:Fire("MouseButton1Up")
        wait(0.1)
        carButton:Fire("Activated")
        
        print("✅ Simulated mouse events")
        return true
    end)
    
    if not (success1 or success3 or success4) then
        print("❌ Could not simulate adding car")
        return false
    end
    
    return true
end

-- Try to duplicate items through the trade system
local function ServerSideDuplication()
    print("\n🔄 ATTEMPTING SERVER-SIDE DUPLICATION...")
    
    local items = FindTradeItems()
    if #items == 0 then
        print("❌ No trade items found")
        return 0
    end
    
    local duplicates = 0
    
    -- Try each potential car item
    for i, itemData in pairs(items) do
        print("\n🔧 Processing item " .. i .. ": " .. itemData.Name)
        
        -- Try multiple methods to add the item
        for attempt = 1, 3 do
            print("Attempt " .. attempt .. " to add: " .. itemData.Name)
            
            -- Try to simulate adding the car
            if SimulateAddCar(itemData.Button) then
                duplicates = duplicates + 1
                print("✅ Attempt " .. attempt .. " successful!")
                
                -- Wait a bit between duplicates
                wait(0.5)
                
                -- Try to add it multiple times
                for repeatCount = 1, 2 do
                    wait(0.3)
                    SimulateAddCar(itemData.Button)
                    print("   Repeated addition #" .. repeatCount)
                end
                
                break
            else
                print("❌ Attempt " .. attempt .. " failed")
                wait(1)
            end
        end
    end
    
    print("\n📊 SERVER-SIDE RESULTS:")
    print("Total items processed: " .. #items)
    print("Successful duplicates attempted: " .. duplicates)
    
    return duplicates
end

-- Monitor the receiver's trade window
local function MonitorReceiverTrade()
    print("\n👀 MONITORING RECEIVER WINDOW...")
    
    -- Try to find the other player's trade window
    local receiverContainer = nil
    local peerToPeer = Player.PlayerGui.Menu.Trading.PeerToPeer
    local main = peerToPeer:FindFirstChild("Main")
    
    if main then
        for _, child in pairs(main:GetChildren()) do
            if child.Name ~= "LocalPlayer" then
                receiverContainer = child:FindFirstChild("Content")
                if receiverContainer then
                    print("✅ Found receiver container: " .. child.Name)
                    break
                end
            end
        end
    end
    
    if receiverContainer then
        local scrollingFrame = receiverContainer:FindFirstChild("ScrollingFrame")
        if scrollingFrame then
            print("Receiver items count: " .. #scrollingFrame:GetChildren())
            
            -- List receiver items
            for _, item in pairs(scrollingFrame:GetChildren()) do
                if item:IsA("TextButton") or item:IsA("ImageButton") then
                    local text = item:IsA("TextButton") and item.Text or item.Name
                    print("   Receiver has: " .. text)
                end
            end
        end
    else
        print("❌ No receiver container found")
    end
end

-- Create enhanced UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeDuplicatorUI"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 350)
    frame.Position = UDim2.new(0.5, -200, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "SERVER-SIDE DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    title.TextColor3 = Color3.fromRGB(255, 200, 100)
    title.Font = Enum.Font.GothamBold
    
    local output = Instance.new("ScrollingFrame")
    output.Name = "Output"
    output.Size = UDim2.new(1, -20, 0, 200)
    output.Position = UDim2.new(0, 10, 0, 50)
    output.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    output.ScrollBarThickness = 6
    
    local outputText = Instance.new("TextLabel")
    outputText.Name = "Text"
    outputText.Size = UDim2.new(1, 0, 1, 0)
    outputText.BackgroundTransparency = 1
    outputText.TextColor3 = Color3.fromRGB(200, 200, 255)
    outputText.TextWrapped = true
    outputText.TextXAlignment = Enum.TextXAlignment.Left
    outputText.TextYAlignment = Enum.TextYAlignment.Top
    outputText.Font = Enum.Font.Code
    outputText.TextSize = 14
    
    outputText.Parent = output
    
    -- Buttons
    local buttons = {
        {Text = "🔍 SCAN ITEMS", Func = function()
            outputText.Text = "Scanning trade items..."
            wait(0.5)
            FindTradeItems()
            outputText.Text = "Scan complete!\nCheck OUTPUT window"
        end},
        
        {Text = "🚗 SERVER DUPLICATE", Func = function()
            outputText.Text = "Attempting server-side duplication...\nThis may take a moment."
            local count = ServerSideDuplication()
            outputText.Text = "Server-side attempts: " .. count .. "\nCheck if receiver sees the items."
        end},
        
        {Text = "👀 CHECK RECEIVER", Func = function()
            outputText.Text = "Checking receiver window..."
            MonitorReceiverTrade()
            outputText.Text = "Receiver check complete.\nCheck OUTPUT window."
        end},
        
        {Text = "📡 FIND REMOTES", Func = function()
            outputText.Text = "Searching for remote events..."
            FindTradeRemotes()
            outputText.Text = "Remote search complete.\nCheck OUTPUT window."
        end},
        
        {Text = "🔄 AUTO-DUPLICATE", Func = function()
            outputText.Text = "Starting auto-duplication sequence..."
            
            spawn(function()
                FindTradeItems()
                wait(1)
                ServerSideDuplication()
                wait(2)
                MonitorReceiverTrade()
                outputText.Text = "Auto-sequence complete!"
            end)
        end}
    }
    
    for i, btnInfo in pairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.Text
        btn.Size = UDim2.new(0.9, 0, 0, 35)
        btn.Position = UDim2.new(0.05, 0, 0, 260 + (i-1)*40)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        btn.MouseButton1Click:Connect(function()
            btn.Text = "PROCESSING..."
            spawn(function()
                btnInfo.Func()
                wait(1)
                btn.Text = btnInfo.Text
            end)
        end)
        
        btn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    output.Parent = frame
    frame.Parent = gui
    
    return outputText
end

-- Update output function
local outputText = CreateUI()

-- Function to add text to UI output
function UpdateUIOutput(text)
    outputText.Text = text .. "\n" .. outputText.Text
end

-- Auto-start
wait(3)
print("\n🎯 READY FOR SERVER-SIDE DUPLICATION")
print("INSTRUCTIONS:")
print("1. Start a trade with another player")
print("2. Add your car to the trade window")
print("3. Click 'SCAN ITEMS' to identify cars")
print("4. Click 'SERVER DUPLICATE' to attempt duplication")
print("5. Ask the other player if they see duplicated cars")

-- Start scanning
spawn(function()
    wait(5)
    print("\n🚀 STARTING AUTO-SCAN...")
    FindTradeItems()
    FindTradeRemotes()
    UpdateUIOutput("Auto-scan complete. Ready for duplication.")
end)

-- Keybind for quick duplication
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        print("\n🎮 P KEY PRESSED - QUICK DUPLICATION")
        ServerSideDuplication()
    end
end)

print("\nPress P for quick duplication")
