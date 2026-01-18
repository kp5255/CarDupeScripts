-- 📋 CDT Trade Item Scanner - FIXED VERSION
-- Monitors trade sessions and extracts item information

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🚗 CDT Trade Item Scanner Activated")

-- ===== TRADE SYSTEM DETECTION =====
local TradeSystem = nil
local TradeRemotes = {}
local LastTradeData = {}

-- Find trade-related objects
local function FindTradeSystem()
    print("🔍 Searching for trade system...")
    
    -- Common locations for trade systems
    local searchLocations = {
        Player.PlayerGui,
        ReplicatedStorage,
        game:GetService("ServerScriptService"),
        workspace
    }
    
    for _, location in pairs(searchLocations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                local nameLower = obj.Name:lower()
                
                -- Look for trade-related objects
                if (nameLower:find("trade") or 
                    nameLower:find("exchange") or 
                    nameLower:find("offer") or
                    nameLower:find("deal") or
                    nameLower:find("swap")) then
                    
                    print("✅ Found trade-related: " .. obj.Name .. " (" .. obj.ClassName .. ")")
                    
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        table.insert(TradeRemotes, {
                            Object = obj,
                            Name = obj.Name,
                            Type = obj.ClassName,
                            Path = obj:GetFullName()
                        })
                        
                        -- Hook into the remote to monitor data
                        if obj:IsA("RemoteEvent") then
                            local oldFireServer = obj.FireServer
                            obj.FireServer = function(self, ...)
                                local args = {...}
                                print("📤 Trade Remote Fired: " .. obj.Name)
                                
                                -- Log the data being sent
                                for i, arg in ipairs(args) do
                                    if type(arg) == "table" then
                                        print("   Argument " .. i .. " (table):")
                                        for k, v in pairs(arg) do
                                            print("     " .. tostring(k) .. ": " .. tostring(v))
                                        end
                                    else
                                        print("   Argument " .. i .. ": " .. tostring(arg))
                                    end
                                end
                                
                                LastTradeData.Sent = args
                                LastTradeData.Time = os.time()
                                
                                return oldFireServer(self, ...)
                            end
                        end
                    end
                end
            end
        end
    end
    
    return #TradeRemotes > 0
end

-- ===== INVENTORY & ITEM DETECTION =====
local function ScanForInventory()
    print("📦 Searching for inventory system...")
    
    local InventoryData = {}
    
    -- Check PlayerGui for inventory UI
    if Player:FindFirstChild("PlayerGui") then
        local playerGui = Player.PlayerGui
        
        -- Look for inventory frames
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ScrollingFrame") then
                local guiName = gui.Name:lower()
                
                if guiName:find("invent") or 
                   guiName:find("items") or 
                   guiName:find("cars") or
                   guiName:find("list") then
                    
                    print("📊 Found inventory UI: " .. gui.Name .. " at " .. gui:GetFullName())
                    
                    -- Scan for item buttons/thumbnails
                    for _, child in pairs(gui:GetDescendants()) do
                        if child:IsA("TextButton") or child:IsA("ImageButton") then
                            local childName = child.Name:lower()
                            
                            if childName:find("car") or 
                               childName:find("item") or
                               childName:find("vehicle") or
                               childName:find("subaru") or  -- Based on your error
                               childName:find("_") then     -- Many car names have underscores
                                
                                -- Extract info from button - FIXED: Check for Text property safely
                                local itemInfo = {
                                    Name = child.Name,
                                    DisplayName = child.Name, -- Default to object name
                                    ClassName = child.ClassName,
                                    FullPath = child:GetFullName()
                                }
                                
                                -- Try to get text from TextButton
                                if child:IsA("TextButton") and child.Text then
                                    itemInfo.DisplayName = child.Text
                                end
                                
                                -- Look for related labels in the same container
                                local parent = child.Parent
                                if parent then
                                    for _, sibling in pairs(parent:GetChildren()) do
                                        if sibling:IsA("TextLabel") then
                                            local siblingName = sibling.Name:lower()
                                            
                                            if siblingName:find("name") then
                                                itemInfo.DisplayName = sibling.Text
                                            elseif siblingName:find("title") then
                                                itemInfo.DisplayName = sibling.Text
                                            elseif siblingName:find("price") or siblingName:find("cost") then
                                                itemInfo.Price = sibling.Text
                                            elseif siblingName:find("value") then
                                                itemInfo.Value = sibling.Text
                                            end
                                        end
                                    end
                                end
                                
                                -- Also check child elements
                                for _, subChild in pairs(child:GetChildren()) do
                                    if subChild:IsA("TextLabel") then
                                        local subName = subChild.Name:lower()
                                        
                                        if subName:find("name") or subName:find("title") then
                                            itemInfo.DisplayName = subChild.Text
                                        elseif subName:find("price") then
                                            itemInfo.Price = subChild.Text
                                        end
                                    end
                                end
                                
                                print("   Found item: " .. itemInfo.Name .. " -> " .. itemInfo.DisplayName)
                                table.insert(InventoryData, itemInfo)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Also check for specific trading inventory UI
    local function scanTradingInventory()
        print("🔍 Looking for trading inventory...")
        
        -- Based on your error path: Players.kp5255.PlayerGui.Menu.Trading.PeerToPeer.Main.Inventory
        local tradingPath = Player.PlayerGui:FindFirstChild("Menu")
        if tradingPath then
            tradingPath = tradingPath:FindFirstChild("Trading")
            if tradingPath then
                tradingPath = tradingPath:FindFirstChild("PeerToPeer")
                if tradingPath then
                    tradingPath = tradingPath:FindFirstChild("Main")
                    if tradingPath then
                        local inventory = tradingPath:FindFirstChild("Inventory")
                        if inventory then
                            print("🎯 Found TRADING INVENTORY at: " .. inventory:GetFullName())
                            
                            -- Scan all items in the trading inventory
                            for _, child in pairs(inventory:GetDescendants()) do
                                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
                                    local childName = child.Name:lower()
                                    
                                    if childName:find("car") or childName:find("item") or childName == "subaru3" then
                                        local itemInfo = {
                                            Name = child.Name,
                                            DisplayName = child.Name,
                                            IsTradingItem = true,
                                            FullPath = child:GetFullName()
                                        }
                                        
                                        -- Try to find a display name
                                        for _, sub in pairs(child:GetChildren()) do
                                            if sub:IsA("TextLabel") then
                                                if sub.Name:lower():find("name") then
                                                    itemInfo.DisplayName = sub.Text
                                                end
                                            end
                                        end
                                        
                                        table.insert(InventoryData, itemInfo)
                                        print("   Trading Item: " .. itemInfo.Name .. " -> " .. itemInfo.DisplayName)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    scanTradingInventory()
    
    return InventoryData
end

-- ===== TRADE SESSION MONITOR =====
local function MonitorTrades()
    -- Hook into potential trade UI
    local function HookTradeUI()
        if not Player.PlayerGui then return end
        
        local function scanForTradeUI(parent)
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("ScreenGui") or child:IsA("Frame") then
                    local nameLower = child.Name:lower()
                    
                    if nameLower:find("trade") or 
                       nameLower:find("exchange") or
                       nameLower:find("offer") or
                       nameLower:find("peer") then
                        
                        print("🎯 Found Trade UI: " .. child.Name)
                        
                        -- Monitor all frames in trade UI
                        for _, frame in pairs(child:GetDescendants()) do
                            if frame:IsA("Frame") then
                                -- Look for item slots
                                local frameName = frame.Name:lower()
                                
                                if frameName:find("slot") or 
                                   frameName:find("item") or
                                   frameName:find("car") or
                                   frameName:find("offer") then
                                    
                                    print("📥 Found trade slot: " .. frame.Name .. " at " .. frame:GetFullName())
                                    
                                    -- Check for item information in this slot
                                    for _, element in pairs(frame:GetChildren()) do
                                        if element:IsA("TextLabel") then
                                            print("   Label: " .. element.Name .. " = " .. element.Text)
                                        elseif element:IsA("ImageLabel") then
                                            print("   Image: " .. element.Name .. " (" .. tostring(element.Image) .. ")")
                                        elseif element:IsA("TextButton") or element:IsA("ImageButton") then
                                            print("   Button: " .. element.Name)
                                        end
                                    end
                                    
                                    -- Hook click events on slots
                                    for _, btn in pairs(frame:GetChildren()) do
                                        if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                                            local oldClick = btn.MouseButton1Click
                                            btn.MouseButton1Click:Connect(function()
                                                print("🖱️ Clicked trade slot: " .. frame.Name)
                                                print("   Button: " .. btn.Name)
                                                print("   Full Path: " .. btn:GetFullName())
                                                
                                                -- Get parent info
                                                for _, sibling in pairs(frame:GetChildren()) do
                                                    if sibling:IsA("TextLabel") then
                                                        print("   Sibling Label: " .. sibling.Name .. " = " .. sibling.Text)
                                                    end
                                                end
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                if #child:GetChildren() > 0 then
                    scanForTradeUI(child)
                end
            end
        end
        
        scanForTradeUI(Player.PlayerGui)
    end
    
    -- Monitor for new GUI elements
    Player.PlayerGui.ChildAdded:Connect(function(child)
        task.wait(0.5) -- Wait for GUI to fully load
        HookTradeUI()
    end)
    
    -- Initial scan
    HookTradeUI()
end

-- ===== DATA DISPLAY UI =====
local function CreateScannerUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TradeScannerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0, 10, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    MainFrame.BorderSizePixel = 0
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🚗 CDT TRADE SCANNER"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    
    local StatusBox = Instance.new("ScrollingFrame")
    StatusBox.Size = UDim2.new(1, -20, 0, 360)
    StatusBox.Position = UDim2.new(0, 10, 0, 50)
    StatusBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    StatusBox.BorderSizePixel = 0
    StatusBox.ScrollBarThickness = 8
    StatusBox.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = StatusBox
    
    local ScanButton = Instance.new("TextButton")
    ScanButton.Text = "🔍 SCAN INVENTORY"
    ScanButton.Size = UDim2.new(1, -20, 0, 35)
    ScanButton.Position = UDim2.new(0, 10, 0, 420)
    ScanButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanButton.Font = Enum.Font.GothamBold
    
    local ClearButton = Instance.new("TextButton")
    ClearButton.Text = "🗑️ CLEAR"
    ClearButton.Size = UDim2.new(1, -20, 0, 35)
    ClearButton.Position = UDim2.new(0, 10, 0, 460)
    ClearButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ClearButton.Font = Enum.Font.GothamBold
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = Title
    corner:Clone().Parent = StatusBox
    corner:Clone().Parent = ScanButton
    corner:Clone().Parent = ClearButton
    
    -- Parent
    Title.Parent = MainFrame
    StatusBox.Parent = MainFrame
    ScanButton.Parent = MainFrame
    ClearButton.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Add status line function
    local function addStatusLine(text, color)
        local textLabel = Instance.new("TextLabel")
        textLabel.Text = text
        textLabel.Size = UDim2.new(1, -10, 0, 20)
        textLabel.Position = UDim2.new(0, 5, 0, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = color or Color3.fromRGB(200, 200, 255)
        textLabel.Font = Enum.Font.Code
        textLabel.TextSize = 14
        textLabel.TextWrapped = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.AutomaticSize = Enum.AutomaticSize.Y
        textLabel.Parent = StatusBox
        
        return textLabel
    end
    
    -- Scan function
    ScanButton.MouseButton1Click:Connect(function()
        ScanButton.Text = "SCANNING..."
        ScanButton.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        
        -- Clear existing content
        for _, child in pairs(StatusBox:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        
        addStatusLine("🔍 Scanning inventory...", Color3.fromRGB(255, 200, 0))
        addStatusLine(string.rep("-", 50), Color3.fromRGB(100, 100, 100))
        
        -- Scan inventory
        local inventory = ScanForInventory()
        addStatusLine("📦 Items Found: " .. #inventory, Color3.fromRGB(0, 200, 255))
        
        for _, item in ipairs(inventory) do
            local line = "  • " .. item.DisplayName
            if item.IsTradingItem then
                line = line .. " [TRADING]"
                addStatusLine(line, Color3.fromRGB(255, 255, 100))
            else
                addStatusLine(line, Color3.fromRGB(200, 200, 255))
            end
            
            if item.Price then
                addStatusLine("    💰 Price: " .. item.Price, Color3.fromRGB(100, 255, 100))
            end
        end
        
        -- Scan for trade system
        local foundTrade = FindTradeSystem()
        addStatusLine("\n🎯 Trade System: " .. (foundTrade and "✅ DETECTED" or "❌ NOT FOUND"), 
                     foundTrade and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100))
        
        if #TradeRemotes > 0 then
            addStatusLine("📡 Trade Remotes Found:", Color3.fromRGB(200, 150, 255))
            for _, remote in ipairs(TradeRemotes) do
                addStatusLine("  • " .. remote.Name .. " (" .. remote.Type .. ")", Color3.fromRGB(180, 180, 255))
            end
        end
        
        addStatusLine("\n" .. string.rep("=", 50), Color3.fromRGB(100, 100, 100))
        addStatusLine("📊 READY - Start a trade to see item data", Color3.fromRGB(100, 255, 100))
        
        task.wait(0.5)
        ScanButton.Text = "🔍 SCAN INVENTORY"
        ScanButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    end)
    
    -- Clear function
    ClearButton.MouseButton1Click:Connect(function()
        for _, child in pairs(StatusBox:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        addStatusLine("🗑️ Cleared", Color3.fromRGB(255, 150, 150))
        addStatusLine("Click SCAN to refresh", Color3.fromRGB(200, 200, 255))
    end)
    
    -- Initial scan
    task.wait(1)
    addStatusLine("🚗 CDT Trade Scanner Ready", Color3.fromRGB(100, 255, 100))
    addStatusLine(string.rep("=", 50), Color3.fromRGB(100, 100, 100))
    addStatusLine("Click SCAN to analyze inventory", Color3.fromRGB(200, 200, 255))
    addStatusLine("Start a trade to auto-detect items", Color3.fromRGB(200, 200, 255))
    
    -- Auto-update for trade events
    spawn(function()
        while task.wait(1) do
            if LastTradeData.Time and os.time() - LastTradeData.Time < 5 then
                -- Recent trade detected
                addStatusLine("\n🔄 Trade Detected!", Color3.fromRGB(255, 255, 100))
                addStatusLine(string.rep("-", 40), Color3.fromRGB(100, 100, 100))
                
                if LastTradeData.Sent then
                    for i, arg in ipairs(LastTradeData.Sent) do
                        if type(arg) == "table" then
                            addStatusLine("📦 Item Data (Table):", Color3.fromRGB(200, 200, 255))
                            for k, v in pairs(arg) do
                                if type(v) == "string" and #v < 100 then
                                    addStatusLine("  " .. tostring(k) .. ": " .. tostring(v), Color3.fromRGB(180, 180, 255))
                                end
                            end
                        else
                            addStatusLine("📤 Argument " .. i .. ": " .. tostring(arg), Color3.fromRGB(180, 180, 255))
                        end
                    end
                end
            end
        end
    end)
    
    return ScreenGui
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 50))
print("🚗 CDT TRADE ITEM SCANNER INITIALIZED")
print(string.rep("=", 50))

-- Create the UI
CreateScannerUI()

-- Start monitoring
task.wait(1)
FindTradeSystem()
ScanForInventory()
MonitorTrades()

print("\n📊 Monitoring trade sessions...")
print("💡 Start a trade to see item information")
print("🎯 Look for the 'CDT TRADE SCANNER' window on your screen")

-- Continuous monitoring
spawn(function()
    while task.wait(10) do
        if #TradeRemotes == 0 then
            print("🔄 Rescanning for trade system...")
            FindTradeSystem()  -- Retry finding trade system
        end
    end
end)

print("\n✅ Script running successfully!")
