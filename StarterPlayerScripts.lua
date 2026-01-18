-- 🎯 CDT ACTIVE TRADE ITEM TRACKER - DIRECT VERSION
-- Shows ONLY items currently being offered in a trade session

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CDT Active Trade Tracker Activated")

-- ===== TRADE STATE =====
local ActiveTradeItems = {}
local TradeSessionActive = false
local YourItems = {}
local TradeUI = nil

-- ===== DIRECT PATH TO TRADING UI =====
local function FindTradeUI()
    -- Direct path based on your error: Players.kp5255.PlayerGui.Menu.Trading.PeerToPeer.Main.Inventory
    local playerGui = Player.PlayerGui
    if not playerGui then return nil end
    
    local menu = playerGui:FindFirstChild("Menu")
    if not menu then 
        -- Try to find any trading UI
        for _, child in pairs(playerGui:GetDescendants()) do
            if child.Name:lower():find("trad") and child:IsA("ScreenGui") then
                return child
            end
        end
        return nil 
    end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then return nil end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then return nil end
    
    -- Check if this UI is visible (active trade)
    if peerToPeer:IsA("ScreenGui") then
        return peerToPeer
    elseif peerToPeer:IsA("Frame") and peerToPeer.Visible then
        return peerToPeer
    end
    
    return nil
end

-- ===== DIRECT SCAN FOR OFFERED ITEMS =====
local function ScanOfferedItems()
    local foundItems = {}
    
    local tradeUI = FindTradeUI()
    if not tradeUI then
        TradeSessionActive = false
        return foundItems
    end
    
    TradeSessionActive = true
    TradeUI = tradeUI
    
    print("🔍 Scanning for your offered items...")
    
    -- Look for the Main frame
    local main = tradeUI:FindFirstChild("Main")
    if main then
        -- Look for Inventory or Items frame
        local inventory = main:FindFirstChild("Inventory") or main:FindFirstChild("Items")
        
        if inventory then
            print("📦 Found inventory at: " .. inventory:GetFullName())
            
            -- Check if there are item slots or direct items
            for _, child in pairs(inventory:GetDescendants()) do
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
                    local name = child.Name
                    local lowerName = name:lower()
                    
                    -- Look for car/item slots (based on your Car_Subaru3 example)
                    if lowerName:find("car_") or lowerName:find("item_") or lowerName:find("_") then
                        -- Skip templates
                        if lowerName:find("template") or lowerName:find("placeholder") then
                            continue
                        end
                        
                        -- Check if this is in YOUR offer area
                        local parent = child.Parent
                        local isYourOffer = false
                        
                        -- Check parent names for clues
                        while parent and parent ~= inventory do
                            local parentName = parent.Name:lower()
                            if parentName:find("your") or parentName:find("my") or parentName:find("left") then
                                isYourOffer = true
                                break
                            end
                            parent = parent.Parent
                        end
                        
                        -- Also check by position (left side is usually your offer)
                        if not isYourOffer then
                            local absPos = child.AbsolutePosition
                            local screenSize = workspace.CurrentCamera.ViewportSize
                            if absPos.X < screenSize.X / 2 then
                                isYourOffer = true
                            end
                        end
                        
                        if isYourOffer then
                            local itemInfo = {
                                Name = name,
                                DisplayName = name,
                                Path = child:GetFullName(),
                                TimeFound = tick()
                            }
                            
                            -- Try to get display name
                            if child:IsA("TextButton") and child.Text ~= "" then
                                itemInfo.DisplayName = child.Text
                            else
                                -- Look for TextLabel children
                                for _, sub in pairs(child:GetChildren()) do
                                    if sub:IsA("TextLabel") and sub.Text ~= "" then
                                        if sub.Name:lower():find("name") or sub.Name:lower():find("title") then
                                            itemInfo.DisplayName = sub.Text
                                        end
                                    end
                                end
                            end
                            
                            -- Check if we already have this item
                            local exists = false
                            for _, existing in pairs(foundItems) do
                                if existing.Name == itemInfo.Name and existing.Path == itemInfo.Path then
                                    exists = true
                                    break
                                end
                            end
                            
                            if not exists then
                                table.insert(foundItems, itemInfo)
                                print("✅ Found your offered item: " .. itemInfo.DisplayName)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Also check for List container directly
    local list = tradeUI:FindFirstChild("List") or main and main:FindFirstChild("List")
    if list and #foundItems == 0 then
        print("📋 Checking List container...")
        for _, item in pairs(list:GetDescendants()) do
            if (item:IsA("Frame") or item:IsA("TextButton") or item:IsA("ImageButton")) and 
               item.Name:find("Car_") then
                print("   Found car in list: " .. item.Name)
            end
        end
    end
    
    return foundItems
end

-- ===== SIMPLE DRAGGABLE UI =====
local function CreateSimpleTrackerUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TradeOfferTracker"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    TitleBar.BorderSizePixel = 0
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Text = "🎯 YOUR TRADE OFFER"
    TitleText.Size = UDim2.new(1, -80, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 16
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    
    -- Status
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 60)
    StatusFrame.Position = UDim2.new(0, 10, 0, 50)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "🔄 Waiting for trade..."
    StatusText.Size = UDim2.new(1, -20, 1, 0)
    StatusText.Position = UDim2.new(0, 10, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 150)
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextSize = 14
    StatusText.TextWrapped = true
    
    -- Items Display
    local ItemsFrame = Instance.new("ScrollingFrame")
    ItemsFrame.Size = UDim2.new(1, -20, 1, -140)
    ItemsFrame.Position = UDim2.new(0, 10, 0, 120)
    ItemsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ItemsFrame.BorderSizePixel = 0
    ItemsFrame.ScrollBarThickness = 6
    ItemsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local ItemsLayout = Instance.new("UIListLayout")
    ItemsLayout.Padding = UDim.new(0, 8)
    ItemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Refresh Button
    local RefreshButton = Instance.new("TextButton")
    RefreshButton.Text = "🔄 MANUAL SCAN"
    RefreshButton.Size = UDim2.new(1, -20, 0, 35)
    RefreshButton.Position = UDim2.new(0, 10, 1, -45)
    RefreshButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    RefreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RefreshButton.Font = Enum.Font.GothamBold
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = TitleBar
    corner:Clone().Parent = StatusFrame
    corner:Clone().Parent = ItemsFrame
    corner:Clone().Parent = CloseButton
    corner:Clone().Parent = RefreshButton
    
    -- Parenting
    TitleText.Parent = TitleBar
    CloseButton.Parent = TitleBar
    TitleBar.Parent = MainFrame
    
    StatusText.Parent = StatusFrame
    StatusFrame.Parent = MainFrame
    
    ItemsLayout.Parent = ItemsFrame
    ItemsFrame.Parent = MainFrame
    
    RefreshButton.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Functions
    local function updateStatus(message, color)
        StatusText.Text = message
        StatusText.TextColor3 = color or Color3.fromRGB(255, 255, 150)
    end
    
    local function clearItems()
        for _, child in pairs(ItemsFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
    
    local function addItem(itemName, index)
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(0.9, 0, 0, 50)
        itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 6)
        itemCorner.Parent = itemFrame
        
        local icon = Instance.new("TextLabel")
        icon.Text = "🚗"
        icon.Size = UDim2.new(0, 40, 1, 0)
        icon.Position = UDim2.new(0, 5, 0, 0)
        icon.BackgroundTransparency = 1
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 20
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = itemName
        nameLabel.Size = UDim2.new(1, -50, 1, 0)
        nameLabel.Position = UDim2.new(0, 45, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 14
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        icon.Parent = itemFrame
        nameLabel.Parent = itemFrame
        itemFrame.Parent = ItemsFrame
        
        return itemFrame
    end
    
    local function scanAndDisplay()
        local items = ScanOfferedItems()
        clearItems()
        
        if #items > 0 then
            updateStatus("✅ Offering " .. #items .. " items", Color3.fromRGB(100, 255, 100))
            for i, item in ipairs(items) do
                addItem(item.DisplayName, i)
            end
        else
            if TradeSessionActive then
                updateStatus("📭 No items in your offer", Color3.fromRGB(255, 200, 100))
                addItem("Add items to your trade offer", 1)
            else
                updateStatus("🔍 No active trade found", Color3.fromRGB(255, 150, 100))
                addItem("Start a trade to see items here", 1)
            end
        end
    end
    
    -- UI Events
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    RefreshButton.MouseButton1Click:Connect(function()
        RefreshButton.Text = "SCANNING..."
        RefreshButton.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
        scanAndDisplay()
        task.wait(0.5)
        RefreshButton.Text = "🔄 MANUAL SCAN"
        RefreshButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    end)
    
    -- Auto-scan loop
    spawn(function()
        while task.wait(1) do
            if not ScreenGui or not ScreenGui.Parent then break end
            scanAndDisplay()
        end
    end)
    
    -- Initial scan
    task.wait(1)
    scanAndDisplay()
    
    return ScreenGui
end

-- ===== DEBUG LOGGING =====
local function DebugTradeUI()
    print("\n🔍 DEBUG: Scanning for trade UI structure...")
    
    local playerGui = Player.PlayerGui
    if not playerGui then
        print("❌ No PlayerGui found")
        return
    end
    
    -- Look for Menu
    local menu = playerGui:FindFirstChild("Menu")
    if menu then
        print("✅ Found Menu")
        
        local trading = menu:FindFirstChild("Trading")
        if trading then
            print("✅ Found Trading")
            
            for _, child in pairs(trading:GetChildren()) do
                print("   📁 " .. child.Name .. " (" .. child.ClassName .. ")")
                
                if child:IsA("Frame") or child:IsA("ScreenGui") then
                    for _, sub in pairs(child:GetDescendants()) do
                        if sub:IsA("Frame") and (sub.Name:lower():find("invent") or sub.Name:lower():find("list")) then
                            print("      📦 Found container: " .. sub.Name .. " at " .. sub:GetFullName())
                            
                            -- List items in container
                            for _, item in pairs(sub:GetChildren()) do
                                print("         • " .. item.Name .. " (" .. item.ClassName .. ")")
                            end
                        end
                    end
                end
            end
        else
            print("❌ No Trading found in Menu")
        end
    else
        print("❌ No Menu found")
    end
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("🎯 CDT TRADE OFFER TRACKER")
print("📍 Will show ONLY items in YOUR current trade offer")
print(string.rep("=", 60))

-- Run debug scan first
DebugTradeUI()

-- Create UI
CreateSimpleTrackerUI()

print("\n✅ Tracker UI created!")
print("💡 Features:")
print("   • Drag window to move")
print("   • Shows ONLY your offered items")
print("   • Auto-updates every second")
print("   • Manual scan button")
print("\n🎮 Start a trade and add items to see them appear!")
