-- 🎯 CDT ACTIVE TRADE ITEM TRACKER
-- Shows ONLY items currently being offered in a trade session

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CDT Active Trade Tracker Activated")

-- ===== TRADE STATE TRACKING =====
local ActiveTradeItems = {}
local TradeSessionActive = false
local TradeUI = nil
local YourOfferSlots = {}
local TheirOfferSlots = {}
local LastUpdateTime = 0

-- ===== FIND TRADE UI ELEMENTS =====
local function FindActiveTradeUI()
    if not Player.PlayerGui then return nil end
    
    -- Look for active trade UI
    local function scanForTrade(parent, depth)
        if depth > 10 then return nil end
        
        for _, child in pairs(parent:GetChildren()) do
            local nameLower = child.Name:lower()
            
            -- Look for trade-related UI
            if (nameLower:find("trade") or 
                nameLower:find("exchange") or 
                nameLower:find("offer") or
                nameLower:find("peer")) and
                (child:IsA("ScreenGui") or child:IsA("Frame")) then
                
                -- Check if it's visible (active trade)
                if child:IsA("ScreenGui") or (child.Visible and child.Parent and child.Parent.Visible) then
                    print("🎯 Found ACTIVE Trade UI: " .. child.Name)
                    return child
                end
            end
            
            -- Recursive search
            if #child:GetChildren() > 0 then
                local found = scanForTrade(child, depth + 1)
                if found then return found end
            end
        end
        return nil
    end
    
    return scanForTrade(Player.PlayerGui, 0)
end

-- ===== IDENTIFY YOUR OFFER SLOTS =====
local function IdentifyOfferSlots(tradeUI)
    YourOfferSlots = {}
    TheirOfferSlots = {}
    
    print("🔍 Scanning for offer slots...")
    
    -- Look for frames that might contain your offer
    local function scanSlots(parent)
        for _, child in pairs(parent:GetChildren()) do
            local nameLower = child.Name:lower()
            
            -- Look for slot containers
            if child:IsA("Frame") or child:IsA("ScrollingFrame") then
                if nameLower:find("slot") or 
                   nameLower:find("offer") or 
                   nameLower:find("item") or
                   nameLower:find("your") or
                   nameLower:find("my") then
                    
                    print("📥 Found slot container: " .. child.Name)
                    
                    -- Check if it contains items
                    local hasItems = false
                    for _, item in pairs(child:GetChildren()) do
                        local itemName = item.Name:lower()
                        if itemName:find("car") or itemName:find("item") or itemName:find("_") then
                            hasItems = true
                            break
                        end
                    end
                    
                    if hasItems then
                        -- Try to determine if it's your offer or theirs
                        if nameLower:find("your") or nameLower:find("my") or nameLower:find("left") then
                            table.insert(YourOfferSlots, child)
                            print("   -> Identified as YOUR offer slot")
                        elseif nameLower:find("their") or nameLower:find("right") or nameLower:find("partner") then
                            table.insert(TheirOfferSlots, child)
                            print("   -> Identified as THEIR offer slot")
                        else
                            -- Default: first found is yours, second is theirs
                            if #YourOfferSlots == 0 then
                                table.insert(YourOfferSlots, child)
                                print("   -> Assumed as YOUR offer slot (first)")
                            else
                                table.insert(TheirOfferSlots, child)
                                print("   -> Assumed as THEIR offer slot")
                            end
                        end
                    end
                end
            end
            
            if #child:GetChildren() > 0 then
                scanSlots(child)
            end
        end
    end
    
    scanSlots(tradeUI)
    
    print("✅ Identified " .. #YourOfferSlots .. " your offer slots")
    print("✅ Identified " .. #TheirOfferSlots .. " their offer slots")
end

-- ===== EXTRACT ITEMS FROM YOUR OFFER =====
local function ExtractYourOfferedItems()
    local offeredItems = {}
    
    if #YourOfferSlots == 0 then
        return offeredItems
    end
    
    for _, slot in pairs(YourOfferSlots) do
        -- Look for actual item objects in the slot
        for _, child in pairs(slot:GetDescendants()) do
            if child:IsA("TextButton") or child:IsA("ImageButton") or child:IsA("Frame") then
                local itemName = child.Name:lower()
                
                if itemName:find("car") or itemName:find("item") or itemName:find("_") then
                    -- Skip if it's just a template or placeholder
                    if itemName:find("template") or itemName:find("placeholder") then
                        continue
                    end
                    
                    local itemInfo = {
                        Name = child.Name,
                        DisplayName = child.Name,
                        Slot = slot.Name,
                        FullPath = child:GetFullName(),
                        LastSeen = tick()
                    }
                    
                    -- Try to extract display name
                    if child:IsA("TextButton") and child.Text ~= "" then
                        itemInfo.DisplayName = child.Text
                    else
                        -- Look for text labels
                        for _, sub in pairs(child:GetChildren()) do
                            if sub:IsA("TextLabel") then
                                local subName = sub.Name:lower()
                                if subName:find("name") or subName:find("title") then
                                    itemInfo.DisplayName = sub.Text
                                elseif subName:find("price") or subName:find("value") then
                                    itemInfo.Value = sub.Text
                                end
                            end
                        end
                        
                        -- Check siblings
                        local parent = child.Parent
                        if parent then
                            for _, sibling in pairs(parent:GetChildren()) do
                                if sibling:IsA("TextLabel") and sibling ~= child then
                                    local sibName = sibling.Name:lower()
                                    if sibName:find("name") and itemInfo.DisplayName == child.Name then
                                        itemInfo.DisplayName = sibling.Text
                                    end
                                end
                            end
                        end
                    end
                    
                    -- Check if this is a duplicate
                    local isDuplicate = false
                    for _, existing in pairs(offeredItems) do
                        if existing.FullPath == itemInfo.FullPath then
                            isDuplicate = true
                            break
                        end
                    end
                    
                    if not isDuplicate then
                        table.insert(offeredItems, itemInfo)
                        print("📤 Your Offer: " .. itemInfo.DisplayName)
                    end
                end
            end
        end
    end
    
    return offeredItems
end

-- ===== CREATE RESPONSIVE DRAGGABLE UI =====
local function CreateTradeTrackerUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ActiveTradeTracker"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "TrackerWindow"
    MainFrame.Size = UDim2.new(0, 380, 0, 300)
    MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    
    -- Title Bar (Drag Area)
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    TitleBar.BorderSizePixel = 0
    TitleBar.Active = true
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Text = "🎯 ACTIVE TRADE ITEMS"
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 16
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "✕"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Text = "─"
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -70, 0.5, -15)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 140)
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.Font = Enum.Font.GothamBold
    
    -- Content Area
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    
    -- Status Header
    local StatusHeader = Instance.new("Frame")
    StatusHeader.Size = UDim2.new(1, -20, 0, 30)
    StatusHeader.Position = UDim2.new(0, 10, 0, 10)
    StatusHeader.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "🔄 Scanning for active trade..."
    StatusText.Size = UDim2.new(1, -20, 1, 0)
    StatusText.Position = UDim2.new(0, 10, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 150)
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextSize = 14
    
    -- Items List
    local ItemsScroll = Instance.new("ScrollingFrame")
    ItemsScroll.Name = "ItemsList"
    ItemsScroll.Size = UDim2.new(1, -20, 1, -100)
    ItemsScroll.Position = UDim2.new(0, 10, 0, 50)
    ItemsScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ItemsScroll.BorderSizePixel = 0
    ItemsScroll.ScrollBarThickness = 6
    ItemsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ItemsScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    
    local ItemsLayout = Instance.new("UIListLayout")
    ItemsLayout.Padding = UDim.new(0, 5)
    ItemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Stats Bar
    local StatsBar = Instance.new("Frame")
    StatsBar.Size = UDim2.new(1, -20, 0, 40)
    StatsBar.Position = UDim2.new(0, 10, 1, -50)
    StatsBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    
    local ItemsCount = Instance.new("TextLabel")
    ItemsCount.Text = "Items: 0"
    ItemsCount.Size = UDim2.new(0.5, -5, 1, 0)
    ItemsCount.Position = UDim2.new(0, 10, 0, 0)
    ItemsCount.BackgroundTransparency = 1
    ItemsCount.TextColor3 = Color3.fromRGB(200, 255, 200)
    ItemsCount.Font = Enum.Font.GothamBold
    ItemsCount.TextSize = 14
    
    local LastUpdate = Instance.new("TextLabel")
    LastUpdate.Text = "Updated: Never"
    LastUpdate.Size = UDim2.new(0.5, -5, 1, 0)
    LastUpdate.Position = UDim2.new(0.5, 5, 0, 0)
    LastUpdate.BackgroundTransparency = 1
    LastUpdate.TextColor3 = Color3.fromRGB(200, 200, 255)
    LastUpdate.Font = Enum.Font.Gotham
    LastUpdate.TextSize = 12
    LastUpdate.TextXAlignment = Enum.TextXAlignment.Right
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = TitleBar
    corner:Clone().Parent = StatusHeader
    corner:Clone().Parent = ItemsScroll
    corner:Clone().Parent = StatsBar
    corner:Clone().Parent = CloseButton
    corner:Clone().Parent = MinimizeButton
    
    local smallCorner = Instance.new("UICorner")
    smallCorner.CornerRadius = UDim.new(0, 4)
    smallCorner.Parent = ItemsScroll
    
    -- Add drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 0, 0, 0)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = MainFrame
    shadow.ZIndex = -1
    
    -- Parenting
    TitleText.Parent = TitleBar
    CloseButton.Parent = TitleBar
    MinimizeButton.Parent = TitleBar
    TitleBar.Parent = MainFrame
    
    StatusText.Parent = StatusHeader
    StatusHeader.Parent = ContentFrame
    
    ItemsLayout.Parent = ItemsScroll
    ItemsScroll.Parent = ContentFrame
    
    ItemsCount.Parent = StatsBar
    LastUpdate.Parent = StatsBar
    StatsBar.Parent = ContentFrame
    
    ContentFrame.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- UI State
    local isMinimized = false
    local originalSize = MainFrame.Size
    local minimizedSize = UDim2.new(0, 380, 0, 40)
    local originalContentSize = ContentFrame.Size
    
    -- ===== UI FUNCTIONS =====
    local function updateStatus(message, color)
        StatusText.Text = message
        StatusText.TextColor3 = color or Color3.fromRGB(255, 255, 150)
    end
    
    local function updateItemsCount(count)
        ItemsCount.Text = "Your Items: " .. count
    end
    
    local function updateLastUpdate()
        local timeStr = os.date("%H:%M:%S")
        LastUpdate.Text = "Updated: " .. timeStr
        LastUpdateTime = tick()
    end
    
    local function clearItemsList()
        for _, child in pairs(ItemsScroll:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
    
    local function addItemToDisplay(itemInfo, index)
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = "Item_" .. index
        itemFrame.Size = UDim2.new(1, -10, 0, 60)
        itemFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        itemFrame.BorderSizePixel = 0
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 6)
        itemCorner.Parent = itemFrame
        
        -- Item Icon/Type
        local icon = Instance.new("TextLabel")
        icon.Text = "🚗"
        icon.Size = UDim2.new(0, 40, 0, 40)
        icon.Position = UDim2.new(0, 10, 0.5, -20)
        icon.BackgroundTransparency = 1
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 20
        
        -- Item Name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = itemInfo.DisplayName
        nameLabel.Size = UDim2.new(0.7, -60, 0, 40)
        nameLabel.Position = UDim2.new(0, 60, 0.5, -20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 14
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextWrapped = true
        
        -- Slot Info
        local slotLabel = Instance.new("TextLabel")
        slotLabel.Text = "📥 " .. itemInfo.Slot
        slotLabel.Size = UDim2.new(0.3, -10, 0, 20)
        slotLabel.Position = UDim2.new(0.7, 10, 0, 5)
        slotLabel.BackgroundTransparency = 1
        slotLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        slotLabel.Font = Enum.Font.Gotham
        slotLabel.TextSize = 11
        
        -- Value if available
        if itemInfo.Value then
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Text = "💰 " .. itemInfo.Value
            valueLabel.Size = UDim2.new(0.3, -10, 0, 20)
            valueLabel.Position = UDim2.new(0.7, 10, 1, -25)
            valueLabel.BackgroundTransparency = 1
            valueLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextSize = 12
            valueLabel.Parent = itemFrame
        end
        
        -- Parenting
        icon.Parent = itemFrame
        nameLabel.Parent = itemFrame
        slotLabel.Parent = itemFrame
        itemFrame.Parent = ItemsScroll
        
        return itemFrame
    end
    
    local function displayOfferedItems(items)
        clearItemsList()
        
        if #items == 0 then
            local emptyMsg = Instance.new("TextLabel")
            emptyMsg.Text = "No items currently offered\nStart a trade and add items!"
            emptyMsg.Size = UDim2.new(1, -20, 0, 80)
            emptyMsg.Position = UDim2.new(0, 10, 0, 20)
            emptyMsg.BackgroundTransparency = 1
            emptyMsg.TextColor3 = Color3.fromRGB(150, 150, 150)
            emptyMsg.Font = Enum.Font.Gotham
            emptyMsg.TextSize = 14
            emptyMsg.TextWrapped = true
            emptyMsg.Parent = ItemsScroll
        else
            for i, item in ipairs(items) do
                addItemToDisplay(item, i)
            end
        end
        
        updateItemsCount(#items)
        updateLastUpdate()
    end
    
    -- ===== UI CONTROLS =====
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        if isMinimized then
            -- Restore
            MainFrame.Size = originalSize
            ContentFrame.Visible = true
            MinimizeButton.Text = "─"
            isMinimized = false
        else
            -- Minimize
            MainFrame.Size = minimizedSize
            ContentFrame.Visible = false
            MinimizeButton.Text = "+"
            isMinimized = true
        end
    end)
    
    -- Make title bar draggable
    local dragging = false
    local dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
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
    
    -- Initial state
    updateStatus("🔍 Waiting for trade session...", Color3.fromRGB(255, 200, 100))
    
    -- ===== TRADE MONITORING LOOP =====
    spawn(function()
        while task.wait(0.5) do
            if not ScreenGui or not ScreenGui.Parent then break end
            
            -- Look for active trade UI
            local activeTradeUI = FindActiveTradeUI()
            
            if activeTradeUI then
                if not TradeSessionActive or activeTradeUI ~= TradeUI then
                    -- New trade session detected
                    TradeSessionActive = true
                    TradeUI = activeTradeUI
                    YourOfferSlots = {}
                    TheirOfferSlots = {}
                    
                    updateStatus("✅ ACTIVE TRADE DETECTED", Color3.fromRGB(100, 255, 100))
                    IdentifyOfferSlots(TradeUI)
                end
                
                -- Update offered items
                local currentOffers = ExtractYourOfferedItems()
                displayOfferedItems(currentOffers)
                
                -- Update status
                if #currentOffers > 0 then
                    updateStatus("📤 Offering " .. #currentOffers .. " items", Color3.fromRGB(100, 255, 100))
                else
                    updateStatus("📭 No items offered yet", Color3.fromRGB(255, 255, 150))
                end
                
            else
                if TradeSessionActive then
                    -- Trade ended
                    TradeSessionActive = false
                    TradeUI = nil
                    YourOfferSlots = {}
                    TheirOfferSlots = {}
                    
                    updateStatus("❌ TRADE ENDED", Color3.fromRGB(255, 100, 100))
                    displayOfferedItems({})
                    updateItemsCount(0)
                else
                    -- No trade active
                    if tick() - LastUpdateTime > 5 then
                        updateStatus("🔍 Waiting for trade session...", Color3.fromRGB(255, 200, 100))
                    end
                end
            end
        end
    end)
    
    -- Auto-refresh display every 2 seconds
    spawn(function()
        while task.wait(2) do
            if not ScreenGui or not ScreenGui.Parent then break end
            
            if TradeSessionActive and TradeUI and TradeUI.Parent then
                local currentOffers = ExtractYourOfferedItems()
                displayOfferedItems(currentOffers)
            end
        end
    end)
    
    return ScreenGui
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 60))
print("🎯 CDT ACTIVE TRADE ITEM TRACKER INITIALIZED")
print("📍 Will ONLY show items you're currently offering in trade")
print("🎮 Start a trade to see your offered items appear instantly")
print(string.rep("=", 60))

-- Create the UI
CreateTradeTrackerUI()

-- Initial instructions
task.wait(1)
print("\n✅ Tracker UI created successfully!")
print("💡 Features:")
print("   • Drag the title bar to move window")
print("   • Click ─ to minimize/restore")
print("   • Real-time updates of your trade offers")
print("   • Shows ONLY items you're currently offering")
print("\n📊 Start a trade and add items to see them appear!")
