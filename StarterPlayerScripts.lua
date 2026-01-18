-- 📋 CDT Trade Item Scanner
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
                if gui.Name:lower():find("invent") or 
                   gui.Name:lower():find("items") or 
                   gui.Name:lower():find("cars") then
                    
                    print("📊 Found inventory UI: " .. gui.Name)
                    
                    -- Scan for item buttons/thumbnails
                    for _, child in pairs(gui:GetDescendants()) do
                        if child:IsA("TextButton") or child:IsA("ImageButton") then
                            if child.Name:lower():find("car") or 
                               child.Name:lower():find("item") or
                               child.Name:lower():find("vehicle") then
                                
                                -- Extract info from button
                                local itemInfo = {
                                    Name = child.Name,
                                    DisplayName = child.Text or "No Text",
                                    Position = child.AbsolutePosition
                                }
                                
                                -- Look for related labels
                                for _, sibling in pairs(child.Parent:GetChildren()) do
                                    if sibling:IsA("TextLabel") and sibling.Name:lower():find("name") then
                                        itemInfo.DisplayName = sibling.Text
                                    elseif sibling:IsA("TextLabel") and sibling.Name:lower():find("price") then
                                        itemInfo.Price = sibling.Text
                                    elseif sibling:IsA("TextLabel") and sibling.Name:lower():find("value") then
                                        itemInfo.Value = sibling.Text
                                    end
                                end
                                
                                table.insert(InventoryData, itemInfo)
                            end
                        end
                    end
                end
            end
        end
    end
    
    return InventoryData
end

-- ===== TRADE SESSION MONITOR =====
local function MonitorTrades()
    -- Hook into potential trade UI
    local function HookTradeUI()
        if not Player.PlayerGui then return end
        
        local function scanForTradeUI(parent)
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA("ScreenGui") then
                    local nameLower = child.Name:lower()
                    
                    if nameLower:find("trade") or 
                       nameLower:find("exchange") or
                       nameLower:find("offer") then
                        
                        print("🎯 Found Trade UI: " .. child.Name)
                        
                        -- Monitor all frames in trade UI
                        for _, frame in pairs(child:GetDescendants()) do
                            if frame:IsA("Frame") then
                                -- Look for item slots
                                if frame.Name:lower():find("slot") or 
                                   frame.Name:lower():find("item") or
                                   frame.Name:lower():find("car") then
                                    
                                    print("📥 Found trade slot: " .. frame.Name)
                                    
                                    -- Check for item information in this slot
                                    for _, element in pairs(frame:GetChildren()) do
                                        if element:IsA("TextLabel") then
                                            print("   Label: " .. element.Name .. " = " .. element.Text)
                                        elseif element:IsA("ImageLabel") then
                                            print("   Image: " .. element.Name .. " (" .. tostring(element.Image) .. ")")
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
        task.wait(1) -- Wait for GUI to fully load
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
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.Position = UDim2.new(0, 10, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    MainFrame.BorderSizePixel = 0
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🚗 TRADE SCANNER"
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    
    local StatusBox = Instance.new("ScrollingFrame")
    StatusBox.Size = UDim2.new(1, -20, 0, 300)
    StatusBox.Position = UDim2.new(0, 10, 0, 45)
    StatusBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    StatusBox.BorderSizePixel = 0
    StatusBox.ScrollBarThickness = 8
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(1, -10, 0, 0)
    StatusText.Position = UDim2.new(0, 5, 0, 5)
    StatusText.BackgroundTransparency = 1
    StatusText.TextColor3 = Color3.fromRGB(200, 200, 255)
    StatusText.Font = Enum.Font.Code
    StatusText.TextSize = 14
    StatusText.TextWrapped = true
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.TextYAlignment = Enum.TextYAlignment.Top
    StatusText.AutomaticSize = Enum.AutomaticSize.Y
    
    local ScanButton = Instance.new("TextButton")
    ScanButton.Text = "🔍 SCAN NOW"
    ScanButton.Size = UDim2.new(1, -20, 0, 30)
    ScanButton.Position = UDim2.new(0, 10, 0, 355)
    ScanButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanButton.Font = Enum.Font.GothamBold
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = Title
    corner:Clone().Parent = StatusBox
    corner:Clone().Parent = ScanButton
    
    -- Parent
    Title.Parent = MainFrame
    StatusBox.Parent = MainFrame
    StatusText.Parent = StatusBox
    ScanButton.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Update function
    local function updateStatus(text)
        StatusText.Text = text
        StatusBox.CanvasSize = UDim2.new(0, 0, 0, StatusText.TextBounds.Y + 20)
    end
    
    -- Scan function
    ScanButton.MouseButton1Click:Connect(function()
        updateStatus("🔍 Scanning...\n" .. string.rep("-", 40))
        
        -- Scan inventory
        local inventory = ScanForInventory()
        updateStatus(StatusText.Text .. "\n📦 Inventory Items Found: " .. #inventory)
        
        for _, item in ipairs(inventory) do
            updateStatus(StatusText.Text .. "\n  • " .. item.Name .. " - " .. tostring(item.DisplayName))
        end
        
        -- Scan for trade system
        local foundTrade = FindTradeSystem()
        updateStatus(StatusText.Text .. "\n\n🎯 Trade System: " .. (foundTrade and "✅ DETECTED" or "❌ NOT FOUND"))
        
        if #TradeRemotes > 0 then
            updateStatus(StatusText.Text .. "\n📡 Trade Remotes:")
            for _, remote in ipairs(TradeRemotes) do
                updateStatus(StatusText.Text .. "\n  • " .. remote.Name .. " (" .. remote.Type .. ")")
            end
        end
        
        updateStatus(StatusText.Text .. "\n\n" .. string.rep("=", 40))
        updateStatus(StatusText.Text .. "\n📊 READY - Start a trade to see item data")
    end)
    
    -- Auto-update for trade events
    spawn(function()
        while task.wait(1) do
            if LastTradeData.Time and os.time() - LastTradeData.Time < 5 then
                -- Recent trade detected
                updateStatus("🔄 Recent Trade Data:\n" .. string.rep("-", 40))
                
                if LastTradeData.Sent then
                    for i, arg in ipairs(LastTradeData.Sent) do
                        if type(arg) == "table" then
                            updateStatus(StatusText.Text .. "\n📦 Item Data (Table):")
                            for k, v in pairs(arg) do
                                if type(v) == "string" and #v < 100 then  -- Avoid huge strings
                                    updateStatus(StatusText.Text .. "\n  " .. tostring(k) .. ": " .. tostring(v))
                                end
                            end
                        else
                            updateStatus(StatusText.Text .. "\n📤 Argument " .. i .. ": " .. tostring(arg))
                        end
                    end
                end
            end
        end
    end)
    
    -- Initial scan
    task.wait(2)
    updateStatus("🚗 CDT Trade Scanner Ready\n" .. string.rep("=", 40))
    updateStatus("Click SCAN NOW to analyze trade system\nOr start a trade to auto-detect")
    
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
print("🎯 Look for the 'TRADE SCANNER' window on your screen")

-- Continuous monitoring
spawn(function()
    while task.wait(5) do
        if #TradeRemotes == 0 then
            FindTradeSystem()  -- Retry finding trade system
        end
    end
end)

-- Output status
print("\n✅ Script running successfully!")
print("📍 Trade Scanner UI should appear on your screen")
