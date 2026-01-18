-- 🎯 CDT OFFERED CARS ONLY TRACKER
-- Shows ONLY cars in your TRADE OFFER (not owned cars)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CDT OFFERED CARS TRACKER - Looking for OFFER section only")

-- ===== IDENTIFY OFFER SECTION =====
local function FindOfferSection()
    if not Player.PlayerGui then return nil end
    
    -- First, find the trade UI
    local function findTradeUI(parent)
        for _, child in pairs(parent:GetChildren()) do
            local nameLower = child.Name:lower()
            
            if child:IsA("ScreenGui") or child:IsA("Frame") then
                if nameLower:find("trade") or nameLower:find("peer") then
                    if child.Visible then
                        print("🎯 Found trade UI: " .. child.Name)
                        return child
                    end
                end
            end
            
            if #child:GetChildren() > 0 then
                local found = findTradeUI(child)
                if found then return found end
            end
        end
        return nil
    end
    
    local tradeUI = findTradeUI(Player.PlayerGui)
    if not tradeUI then return nil end
    
    print("🔍 Looking for OFFER section in trade UI...")
    
    -- Look for containers that might be the offer section
    -- Common names: "YourOffer", "MyOffer", "LocalPlayer", "Offer", "YourItems"
    local offerContainers = {}
    
    for _, child in pairs(tradeUI:GetDescendants()) do
        if child:IsA("Frame") or child:IsA("ScrollingFrame") then
            local nameLower = child.Name:lower()
            
            if nameLower:find("offer") or 
               nameLower:find("your") or 
               nameLower:find("local") or
               nameLower:find("my") or
               nameLower:find("left") then  -- Left side is usually your offer
                
                -- Check if this container has car items
                local hasCars = false
                for _, item in pairs(child:GetDescendants()) do
                    if item.Name:find("Car") or item.Name:find("car") then
                        hasCars = true
                        break
                    end
                end
                
                if hasCars then
                    table.insert(offerContainers, {
                        Container = child,
                        Name = child.Name,
                        Path = child:GetFullName(),
                        ItemCount = 0
                    })
                    print("📥 Found potential offer container: " .. child.Name .. " at " .. child:GetFullName())
                end
            end
        end
    end
    
    -- If multiple containers found, try to identify the actual offer section
    if #offerContainers > 0 then
        -- Look for the container with "LocalPlayer" or "Your" in path
        for _, container in pairs(offerContainers) do
            if container.Path:lower():find("localplayer") then
                print("✅ Identified as OFFER section (contains LocalPlayer): " .. container.Name)
                return container.Container
            end
        end
        
        -- Check which container has fewer items (offer usually has fewer than owned)
        for _, container in pairs(offerContainers) do
            local itemCount = 0
            for _ in pairs(container.Container:GetDescendants()) do
                itemCount = itemCount + 1
            end
            container.ItemCount = itemCount
        end
        
        -- Sort by item count (ascending - offer usually has fewer items)
        table.sort(offerContainers, function(a, b)
            return a.ItemCount < b.ItemCount
        end)
        
        print("✅ Identified as OFFER section (fewer items): " .. offerContainers[1].Name)
        return offerContainers[1].Container
    end
    
    return nil
end

-- ===== EXTRACT OFFERED CARS ONLY =====
local function GetOfferedCarsOnly()
    local offerSection = FindOfferSection()
    local offeredCars = {}
    
    if not offerSection then
        print("❌ No offer section found")
        return offeredCars
    end
    
    print("🎯 Scanning OFFER section: " .. offerSection.Name)
    
    -- Look for car items in the offer section ONLY
    for _, child in pairs(offerSection:GetDescendants()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
            local name = child.Name
            
            -- Look for cars (case insensitive)
            if name:lower():find("car") or name:match("Car%-") or name:match("%-Car") then
                local itemInfo = {
                    Name = name,
                    DisplayName = name,
                    Object = child,
                    Path = child:GetFullName(),
                    Class = child.ClassName,
                    IsInOffer = true
                }
                
                -- Get display name
                if child:IsA("TextButton") and child.Text ~= "" then
                    itemInfo.DisplayName = child.Text
                else
                    -- Look for text labels
                    for _, sub in pairs(child:GetChildren()) do
                        if sub:IsA("TextLabel") and sub.Text ~= "" then
                            itemInfo.DisplayName = sub.Text
                            break
                        end
                    end
                end
                
                -- Check if this is a duplicate
                local exists = false
                for _, existing in pairs(offeredCars) do
                    if existing.Path == itemInfo.Path then
                        exists = true
                        break
                    end
                end
                
                if not exists then
                    table.insert(offeredCars, itemInfo)
                    print("🚗 Found in OFFER: " .. itemInfo.DisplayName)
                end
            end
        end
    end
    
    return offeredCars
end

-- ===== CREATE OFFER-ONLY UI =====
local function CreateOfferOnlyUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OfferedCarsOnly"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 350)
    MainFrame.Position = UDim2.new(0.7, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    TitleBar.BorderSizePixel = 0
    TitleBar.Active = true
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Text = "🚗 OFFERED CARS ONLY"
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
    
    -- Status
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 60)
    StatusFrame.Position = UDim2.new(0, 10, 0, 50)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "🔍 Looking for trade offer..."
    StatusText.Size = UDim2.new(1, -20, 1, 0)
    StatusText.Position = UDim2.new(0, 10, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 150)
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextSize = 14
    StatusText.TextWrapped = true
    
    -- Offered Cars List
    local CarsFrame = Instance.new("ScrollingFrame")
    CarsFrame.Size = UDim2.new(1, -20, 0, 200)
    CarsFrame.Position = UDim2.new(0, 10, 0, 120)
    CarsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    CarsFrame.BorderSizePixel = 0
    CarsFrame.ScrollBarThickness = 6
    CarsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local CarsLayout = Instance.new("UIListLayout")
    CarsLayout.Padding = UDim.new(0, 8)
    CarsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Refresh Button
    local RefreshButton = Instance.new("TextButton")
    RefreshButton.Text = "🔄 REFRESH OFFER"
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
    corner:Clone().Parent = CarsFrame
    corner:Clone().Parent = RefreshButton
    corner:Clone().Parent = CloseButton
    
    -- Parenting
    TitleText.Parent = TitleBar
    CloseButton.Parent = TitleBar
    TitleBar.Parent = MainFrame
    
    StatusText.Parent = StatusFrame
    StatusFrame.Parent = MainFrame
    
    CarsLayout.Parent = CarsFrame
    CarsFrame.Parent = MainFrame
    
    RefreshButton.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- UI Functions
    local function updateStatus(message, color)
        StatusText.Text = message
        StatusText.TextColor3 = color or Color3.fromRGB(255, 255, 150)
    end
    
    local function clearCarsList()
        for _, child in pairs(CarsFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
    
    local function createCarDisplay(carInfo, index)
        local carFrame = Instance.new("Frame")
        carFrame.Size = UDim2.new(0.95, 0, 0, 60)
        carFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        carFrame.Name = "Car_" .. index
        
        local carCorner = Instance.new("UICorner")
        carCorner.CornerRadius = UDim.new(0, 6)
        carCorner.Parent = carFrame
        
        -- Car icon
        local icon = Instance.new("TextLabel")
        icon.Text = "🚗"
        icon.Size = UDim2.new(0, 40, 0, 40)
        icon.Position = UDim2.new(0, 10, 0.5, -20)
        icon.BackgroundTransparency = 1
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 22
        
        -- Car name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = carInfo.DisplayName
        nameLabel.Size = UDim2.new(0.6, -50, 0, 40)
        nameLabel.Position = UDim2.new(0, 60, 0.5, -20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 14
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Offer badge
        local badge = Instance.new("Frame")
        badge.Size = UDim2.new(0, 60, 0, 20)
        badge.Position = UDim2.new(0.6, 10, 0.5, -10)
        badge.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
        
        local badgeCorner = Instance.new("UICorner")
        badgeCorner.CornerRadius = UDim.new(0, 4)
        badgeCorner.Parent = badge
        
        local badgeText = Instance.new("TextLabel")
        badgeText.Text = "OFFER"
        badgeText.Size = UDim2.new(1, 0, 1, 0)
        badgeText.BackgroundTransparency = 1
        badgeText.TextColor3 = Color3.fromRGB(255, 255, 255)
        badgeText.Font = Enum.Font.GothamBold
        badgeText.TextSize = 10
        
        badgeText.Parent = badge
        badge.Parent = carFrame
        
        -- Parenting
        icon.Parent = carFrame
        nameLabel.Parent = carFrame
        carFrame.Parent = CarsFrame
        
        return carFrame
    end
    
    local function refreshOfferDisplay()
        clearCarsList()
        
        local offeredCars = GetOfferedCarsOnly()
        
        if #offeredCars > 0 then
            updateStatus("✅ " .. #offeredCars .. " car(s) in your offer", Color3.fromRGB(100, 255, 100))
            
            for i, car in ipairs(offeredCars) do
                createCarDisplay(car, i)
            end
            
            -- Print to console
            print("\n📋 OFFERED CARS SUMMARY:")
            for _, car in ipairs(offeredCars) do
                print("   🚗 " .. car.DisplayName)
            end
            print("📊 Total: " .. #offeredCars .. " car(s) in offer")
            
        else
            -- Check if trade is active
            local offerSection = FindOfferSection()
            
            if offerSection then
                updateStatus("📭 No cars in your offer", Color3.fromRGB(255, 200, 100))
                
                -- Show empty message
                local emptyFrame = Instance.new("Frame")
                emptyFrame.Size = UDim2.new(0.9, 0, 0, 80)
                emptyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                
                local emptyCorner = Instance.new("UICorner")
                emptyCorner.CornerRadius = UDim.new(0, 6)
                emptyCorner.Parent = emptyFrame
                
                local emptyText = Instance.new("TextLabel")
                emptyText.Text = "Drag cars from your inventory\nto add them to your offer"
                emptyText.Size = UDim2.new(1, 0, 1, 0)
                emptyText.BackgroundTransparency = 1
                emptyText.TextColor3 = Color3.fromRGB(150, 150, 150)
                emptyText.Font = Enum.Font.Gotham
                emptyText.TextSize = 13
                emptyText.TextWrapped = true
                
                emptyText.Parent = emptyFrame
                emptyFrame.Parent = CarsFrame
            else
                updateStatus("🔍 No active trade found", Color3.fromRGB(255, 150, 100))
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
        refreshOfferDisplay()
        task.wait(0.5)
        RefreshButton.Text = "🔄 REFRESH OFFER"
        RefreshButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    end)
    
    -- Drag functionality
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
        while task.wait(1) do
            if not ScreenGui or not ScreenGui.Parent then break end
            refreshOfferDisplay()
        end
    end)
    
    -- Initial display
    task.wait(1)
    refreshOfferDisplay()
    
    return ScreenGui
end

-- ===== DEBUG: COMPARE OFFER VS OWNED =====
local function DebugCompareSections()
    spawn(function()
        while task.wait(3) do
            print("\n" .. string.rep("=", 60))
            print("🔍 DEBUG: Comparing sections...")
            
            if not Player.PlayerGui then
                print("❌ No PlayerGui")
                return
            end
            
            -- Find all sections with cars
            local sections = {}
            
            for _, child in pairs(Player.PlayerGui:GetDescendants()) do
                if child:IsA("Frame") or child:IsA("ScrollingFrame") then
                    local carCount = 0
                    
                    for _, item in pairs(child:GetDescendants()) do
                        if item.Name:find("Car") or item.Name:lower():find("car") then
                            carCount = carCount + 1
                        end
                    end
                    
                    if carCount > 0 then
                        table.insert(sections, {
                            Name = child.Name,
                            Path = child:GetFullName(),
                            CarCount = carCount,
                            IsVisible = child.Visible
                        })
                    end
                end
            end
            
            -- Sort by car count
            table.sort(sections, function(a, b)
                return a.CarCount < b.CarCount
            end)
            
            print("📊 Found " .. #sections .. " sections with cars:")
            for i, section in ipairs(sections) do
                local status = section.IsVisible and "🟢 VISIBLE" or "🔴 HIDDEN"
                print("   " .. i .. ". " .. section.Name .. " - " .. section.CarCount .. " cars - " .. status)
                print("      Path: " .. section.Path)
            end
            
            -- Offer section is usually the one with fewer cars
            if #sections >= 2 then
                print("\n🎯 OFFER SECTION DETECTED:")
                print("   Likely: " .. sections[1].Name .. " (" .. sections[1].CarCount .. " cars)")
                print("   Reason: Fewest cars (offer has fewer than owned)")
            end
        end
    end)
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("🎯 CDT OFFERED CARS ONLY TRACKER")
print("📍 Shows ONLY cars in your TRADE OFFER (not owned cars)")
print("🔍 Auto-refreshes every second")
print(string.rep("=", 60))

-- Create UI
CreateOfferOnlyUI()

-- Start debug comparison
DebugCompareSections()

print("\n✅ Tracker UI created!")
print("💡 Features:")
print("   • Drag title bar to move")
print("   • Shows ONLY cars in your OFFER")
print("   • Green 'OFFER' badge on each car")
print("   • Auto-refresh every second")
print("   • Manual refresh button")
print("\n🎮 Start a trade, add cars to your offer!")
print("📊 Watch Output for section comparison debug info")
