-- 🎯 CDT CURRENT TRADE OFFER TRACKER
-- Shows ONLY items currently in your trade offer (LocalPlayer.Content.ScrollingFrame)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CDT Current Offer Tracker Activated")

-- ===== STATE =====
local ActiveTradeItems = {}
local LastOfferCount = 0
local TradeUI = nil

-- ===== FIND TRADE OFFER CONTAINER =====
local function GetOfferContainer()
    -- Direct path: PlayerGui.Menu.Trading.PeerToPeer.Main.Inventory.LocalPlayer.Content.ScrollingFrame
    local playerGui = Player.PlayerGui
    if not playerGui then return nil end
    
    local menu = playerGui:FindFirstChild("Menu")
    if not menu then return nil end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then return nil end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then return nil end
    
    local main = peerToPeer:FindFirstChild("Main")
    if not main then return nil end
    
    local inventory = main:FindFirstChild("Inventory")
    if not inventory then return nil end
    
    local localPlayer = inventory:FindFirstChild("LocalPlayer")
    if not localPlayer then return nil end
    
    local content = localPlayer:FindFirstChild("Content")
    if not content then return nil end
    
    local scrollingFrame = content:FindFirstChild("ScrollingFrame")
    return scrollingFrame
end

-- ===== SCAN CURRENT OFFER =====
local function ScanCurrentOffer()
    local offerContainer = GetOfferContainer()
    local currentItems = {}
    
    if not offerContainer then
        print("❌ No trade offer container found")
        return currentItems
    end
    
    -- Check if the trade UI is visible (active trade)
    if not offerContainer.Visible then
        return currentItems
    end
    
    print("🔍 Scanning offer container: " .. offerContainer:GetFullName())
    
    -- Look for items directly in the scrolling frame
    for _, child in pairs(offerContainer:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
            local name = child.Name
            local lowerName = name:lower()
            
            -- Look for car/item frames
            if lowerName:find("car") or lowerName:find("item") or name:match("Car%-") then
                local itemInfo = {
                    Name = name,
                    DisplayName = name,
                    Object = child,
                    TimeFound = tick()
                }
                
                -- Try to extract display name
                if child:IsA("TextButton") and child.Text ~= "" then
                    itemInfo.DisplayName = child.Text
                else
                    -- Look for TextLabel in children
                    for _, sub in pairs(child:GetChildren()) do
                        if sub:IsA("TextLabel") and sub.Text ~= "" then
                            if sub.Name == "Name" or sub.Name:lower():find("name") then
                                itemInfo.DisplayName = sub.Text
                            elseif sub.Name:lower():find("price") or sub.Name:lower():find("value") then
                                itemInfo.Value = sub.Text
                            end
                        elseif sub:IsA("ImageLabel") then
                            itemInfo.HasImage = true
                            if sub.Image then
                                itemInfo.ImageId = sub.Image
                            end
                        end
                    end
                end
                
                -- Check siblings for name
                if itemInfo.DisplayName == name then
                    local parent = child.Parent
                    if parent then
                        for _, sibling in pairs(parent:GetChildren()) do
                            if sibling:IsA("TextLabel") and sibling.Name:lower():find("name") then
                                itemInfo.DisplayName = sibling.Text
                                break
                            end
                        end
                    end
                end
                
                table.insert(currentItems, itemInfo)
                print("✅ Found in offer: " .. itemInfo.DisplayName)
            end
        end
    end
    
    return currentItems
end

-- ===== CREATE TRACKER UI =====
local function CreateOfferTrackerUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CurrentOfferTracker"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 300)
    MainFrame.Position = UDim2.new(0.75, 0, 0.25, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
    TitleBar.BorderSizePixel = 0
    TitleBar.Active = true
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Text = "📤 YOUR CURRENT OFFER"
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 15
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "✕"
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -30, 0.5, -12.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    
    -- Status Area
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 40)
    StatusFrame.Position = UDim2.new(0, 10, 0, 45)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "🔍 Waiting for trade..."
    StatusText.Size = UDim2.new(1, -20, 1, 0)
    StatusText.Position = UDim2.new(0, 10, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 150)
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextSize = 13
    StatusText.TextWrapped = true
    
    -- Items List
    local ItemsFrame = Instance.new("ScrollingFrame")
    ItemsFrame.Size = UDim2.new(1, -20, 0, 170)
    ItemsFrame.Position = UDim2.new(0, 10, 0, 95)
    ItemsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ItemsFrame.BorderSizePixel = 0
    ItemsFrame.ScrollBarThickness = 6
    ItemsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ItemsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    
    local ItemsLayout = Instance.new("UIListLayout")
    ItemsLayout.Padding = UDim.new(0, 6)
    ItemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Counter
    local CounterFrame = Instance.new("Frame")
    CounterFrame.Size = UDim2.new(1, -20, 0, 30)
    CounterFrame.Position = UDim2.new(0, 10, 0, 275)
    CounterFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    
    local CounterText = Instance.new("TextLabel")
    CounterText.Text = "Items: 0"
    CounterText.Size = UDim2.new(1, -20, 1, 0)
    CounterText.Position = UDim2.new(0, 10, 0, 0)
    CounterText.BackgroundTransparency = 1
    CounterText.TextColor3 = Color3.fromRGB(200, 255, 200)
    CounterText.Font = Enum.Font.GothamBold
    CounterText.TextSize = 14
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = TitleBar
    corner:Clone().Parent = StatusFrame
    corner:Clone().Parent = ItemsFrame
    corner:Clone().Parent = CounterFrame
    corner:Clone().Parent = CloseButton
    
    -- Parenting
    TitleText.Parent = TitleBar
    CloseButton.Parent = TitleBar
    TitleBar.Parent = MainFrame
    
    StatusText.Parent = StatusFrame
    StatusFrame.Parent = MainFrame
    
    ItemsLayout.Parent = ItemsFrame
    ItemsFrame.Parent = MainFrame
    
    CounterText.Parent = CounterFrame
    CounterFrame.Parent = MainFrame
    
    MainFrame.Parent = ScreenGui
    
    -- UI Functions
    local function updateStatus(message, color)
        StatusText.Text = message
        StatusText.TextColor3 = color or Color3.fromRGB(255, 255, 150)
    end
    
    local function updateCounter(count)
        CounterText.Text = "Items: " .. count
    end
    
    local function clearItems()
        for _, child in pairs(ItemsFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
    
    local function createItemDisplay(itemInfo, index)
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(0.95, 0, 0, 45)
        itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 75)
        itemFrame.Name = "Item_" .. index
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 5)
        itemCorner.Parent = itemFrame
        
        -- Icon
        local icon = Instance.new("TextLabel")
        icon.Text = "🚗"
        icon.Size = UDim2.new(0, 35, 0, 35)
        icon.Position = UDim2.new(0, 5, 0.5, -17.5)
        icon.BackgroundTransparency = 1
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 18
        
        -- Item Name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = itemInfo.DisplayName
        nameLabel.Size = UDim2.new(0.7, -40, 1, 0)
        nameLabel.Position = UDim2.new(0, 45, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 13
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Type indicator
        local typeLabel = Instance.new("TextLabel")
        typeLabel.Text = "📥"
        typeLabel.Size = UDim2.new(0, 25, 1, 0)
        typeLabel.Position = UDim2.new(0.7, 0, 0, 0)
        typeLabel.BackgroundTransparency = 1
        typeLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        typeLabel.Font = Enum.Font.GothamBold
        typeLabel.TextSize = 14
        
        -- Value if available
        if itemInfo.Value then
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Text = itemInfo.Value
            valueLabel.Size = UDim2.new(0.3, -30, 0, 15)
            valueLabel.Position = UDim2.new(0.7, 5, 1, -20)
            valueLabel.BackgroundTransparency = 1
            valueLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.TextSize = 11
            valueLabel.TextXAlignment = Enum.TextXAlignment.Left
            valueLabel.Parent = itemFrame
        end
        
        -- Add tooltip on hover
        local tooltip = Instance.new("TextLabel")
        tooltip.Text = itemInfo.Name
        tooltip.Size = UDim2.new(1, 0, 0, 0)
        tooltip.Position = UDim2.new(0, 0, 1, 5)
        tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        tooltip.TextColor3 = Color3.fromRGB(180, 180, 255)
        tooltip.Font = Enum.Font.Code
        tooltip.TextSize = 10
        tooltip.TextWrapped = true
        tooltip.Visible = false
        tooltip.AutomaticSize = Enum.AutomaticSize.Y
        tooltip.Name = "Tooltip"
        
        itemFrame.MouseEnter:Connect(function()
            tooltip.Visible = true
        end)
        
        itemFrame.MouseLeave:Connect(function()
            tooltip.Visible = false
        end)
        
        -- Parenting
        icon.Parent = itemFrame
        nameLabel.Parent = itemFrame
        typeLabel.Parent = itemFrame
        tooltip.Parent = itemFrame
        itemFrame.Parent = ItemsFrame
        
        return itemFrame
    end
    
    local function refreshDisplay()
        local currentItems = ScanCurrentOffer()
        
        clearItems()
        
        if #currentItems > 0 then
            -- Trade active with items
            updateStatus("✅ Offering " .. #currentItems .. " item(s)", Color3.fromRGB(100, 255, 100))
            
            for i, item in ipairs(currentItems) do
                createItemDisplay(item, i)
            end
            
            -- Update counter
            updateCounter(#currentItems)
            
            -- Store for comparison
            if #currentItems ~= LastOfferCount then
                print("📊 Offer changed: " .. LastOfferCount .. " → " .. #currentItems .. " items")
                LastOfferCount = #currentItems
            end
            
        else
            -- Check if trade UI exists but no items
            local container = GetOfferContainer()
            if container and container.Visible then
                updateStatus("📭 No items in offer", Color3.fromRGB(255, 200, 100))
                updateCounter(0)
                
                -- Show empty message
                local emptyFrame = Instance.new("Frame")
                emptyFrame.Size = UDim2.new(0.9, 0, 0, 60)
                emptyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                
                local emptyCorner = Instance.new("UICorner")
                emptyCorner.CornerRadius = UDim.new(0, 5)
                emptyCorner.Parent = emptyFrame
                
                local emptyText = Instance.new("TextLabel")
                emptyText.Text = "Add items to\nyour trade offer"
                emptyText.Size = UDim2.new(1, 0, 1, 0)
                emptyText.BackgroundTransparency = 1
                emptyText.TextColor3 = Color3.fromRGB(150, 150, 150)
                emptyText.Font = Enum.Font.Gotham
                emptyText.TextSize = 12
                emptyText.TextWrapped = true
                
                emptyText.Parent = emptyFrame
                emptyFrame.Parent = ItemsFrame
            else
                updateStatus("🔍 No active trade", Color3.fromRGB(255, 150, 100))
                updateCounter(0)
            end
        end
    end
    
    -- UI Events
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Make title bar draggable
    local dragging = false
    local dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if dragging then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Auto-refresh loop
    spawn(function()
        local refreshRate = 0.5 -- Refresh every 0.5 seconds
        
        while task.wait(refreshRate) do
            if not ScreenGui or not ScreenGui.Parent then break end
            refreshDisplay()
        end
    end)
    
    -- Initial display
    task.wait(0.5)
    refreshDisplay()
    
    return ScreenGui
end

-- ===== DEBUG: MONITOR TRADE EVENTS =====
local function MonitorTradeEvents()
    spawn(function()
        while task.wait(1) do
            local container = GetOfferContainer()
            
            if container then
                local isVisible = container.Visible
                local itemCount = #container:GetChildren()
                
                print("📊 Trade Container Status:")
                print("   Path: " .. container:GetFullName())
                print("   Visible: " .. tostring(isVisible))
                print("   Children: " .. itemCount)
                
                if isVisible and itemCount > 0 then
                    print("   Contents:")
                    for _, child in pairs(container:GetChildren()) do
                        print("     • " .. child.Name .. " (" .. child.ClassName .. ")")
                    end
                end
            else
                print("❌ No trade container found")
            end
            
            print(string.rep("-", 40))
        end
    end)
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("🎯 CDT CURRENT TRADE OFFER TRACKER")
print("📍 Monitoring: Menu.Trading.PeerToPeer.Main.Inventory.LocalPlayer.Content.ScrollingFrame")
print("📊 Will show ONLY items currently in your trade offer")
print(string.rep("=", 60))

-- Create UI
CreateOfferTrackerUI()

-- Start debug monitoring
MonitorTradeEvents()

print("\n✅ Tracker UI created successfully!")
print("💡 Features:")
print("   • Drag the blue title bar to move")
print("   • Shows ONLY items in LocalPlayer.Content.ScrollingFrame")
print("   • Real-time updates (0.5s refresh)")
print("   • Item count display")
print("   • Hover tooltips with original item names")
print("\n🎮 Start a trade and add items to your offer!")
print("📊 Watch the Output window for debug information")
