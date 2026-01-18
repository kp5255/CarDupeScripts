-- 🎯 CDT EXACT OFFER TRACKER
-- Targets: PlayerGui.Menu.Trading.PeerToPeer.Main.Inventory.LocalPlayer.Content.ScrollingFrame

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CDT EXACT OFFER TRACKER - Targeting LocalPlayer.Content.ScrollingFrame")

-- ===== EXACT PATH TO OFFER CONTAINER =====
local function GetExactOfferContainer()
    if not Player.PlayerGui then 
        print("❌ No PlayerGui")
        return nil 
    end
    
    local menu = Player.PlayerGui:WaitForChild("Menu", 5)
    if not menu then 
        print("❌ No Menu in PlayerGui")
        return nil 
    end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then 
        print("❌ No Trading in Menu")
        return nil 
    end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then 
        print("❌ No PeerToPeer in Trading")
        return nil 
    end
    
    local main = peerToPeer:FindFirstChild("Main")
    if not main then 
        print("❌ No Main in PeerToPeer")
        return nil 
    end
    
    local inventory = main:FindFirstChild("Inventory")
    if not inventory then 
        print("❌ No Inventory in Main")
        return nil 
    end
    
    local localPlayer = inventory:FindFirstChild("LocalPlayer")
    if not localPlayer then 
        print("❌ No LocalPlayer in Inventory")
        return nil 
    end
    
    local content = localPlayer:FindFirstChild("Content")
    if not content then 
        print("❌ No Content in LocalPlayer")
        return nil 
    end
    
    local scrollingFrame = content:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then 
        print("❌ No ScrollingFrame in Content")
        return nil 
    end
    
    print("✅ Found exact offer container: " .. scrollingFrame:GetFullName())
    print("   Visible: " .. tostring(scrollingFrame.Visible))
    print("   Child count: " .. #scrollingFrame:GetChildren())
    
    return scrollingFrame
end

-- ===== SCAN ONLY OFFERED CARS =====
local function ScanOfferedCarsExact()
    local offerContainer = GetExactOfferContainer()
    local offeredCars = {}
    
    if not offerContainer then
        print("⚠️ No offer container found - may not be in trade")
        return offeredCars
    end
    
    if not offerContainer.Visible then
        print("⚠️ Offer container not visible - trade may not be active")
        return offeredCars
    end
    
    print("🔍 Scanning offer container for cars...")
    
    -- Look DIRECTLY in the ScrollingFrame
    for _, child in pairs(offerContainer:GetChildren()) do
        local name = child.Name
        
        -- Check for car items (Car-Nissan2 format or similar)
        if name:find("Car") or name:find("car") or name:match("%-") then
            print("🚗 Found car in offer: " .. name .. " (" .. child.ClassName .. ")")
            
            local carInfo = {
                RawName = name,
                DisplayName = name,
                Object = child,
                Path = child:GetFullName(),
                Class = child.ClassName
            }
            
            -- Try to get better display name
            if child:IsA("TextButton") and child.Text ~= "" then
                carInfo.DisplayName = child.Text
            else
                -- Look for TextLabels in children
                for _, sub in pairs(child:GetChildren()) do
                    if sub:IsA("TextLabel") and sub.Text ~= "" then
                        carInfo.DisplayName = sub.Text
                        break
                    end
                end
            end
            
            -- Clean up display name (remove "Car-" prefix)
            carInfo.DisplayName = carInfo.DisplayName:gsub("Car%-", "")
            
            table.insert(offeredCars, carInfo)
        end
    end
    
    -- Also check grandchildren (sometimes items are nested)
    if #offeredCars == 0 then
        print("🔍 Checking nested items in offer container...")
        for _, child in pairs(offerContainer:GetDescendants()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
                local name = child.Name
                if name:find("Car") or name:find("car") then
                    print("🚗 Found nested car: " .. name)
                    
                    local carInfo = {
                        RawName = name,
                        DisplayName = name:gsub("Car%-", ""),
                        Object = child,
                        Path = child:GetFullName(),
                        Class = child.ClassName,
                        IsNested = true
                    }
                    
                    table.insert(offeredCars, carInfo)
                end
            end
        end
    end
    
    return offeredCars
end

-- ===== CREATE EXACT TRACKER UI =====
local function CreateExactTrackerUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ExactOfferTracker"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 320)
    MainFrame.Position = UDim2.new(0.75, 0, 0.3, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
    TitleBar.BorderSizePixel = 0
    TitleBar.Active = true
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Text = "🎯 CURRENT OFFER"
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 16
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "✕"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    
    -- Status
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 50)
    StatusFrame.Position = UDim2.new(0, 10, 0, 50)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(40, 50, 65)
    
    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "🔍 Checking offer..."
    StatusText.Size = UDim2.new(1, -20, 1, 0)
    StatusText.Position = UDim2.new(0, 10, 0, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 150)
    StatusText.Font = Enum.Font.Gotham
    StatusText.TextSize = 14
    StatusText.TextWrapped = true
    
    -- Cars List
    local CarsFrame = Instance.new("ScrollingFrame")
    CarsFrame.Size = UDim2.new(1, -20, 0, 170)
    CarsFrame.Position = UDim2.new(0, 10, 0, 110)
    CarsFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    CarsFrame.BorderSizePixel = 0
    CarsFrame.ScrollBarThickness = 6
    CarsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local CarsLayout = Instance.new("UIListLayout")
    CarsLayout.Padding = UDim.new(0, 8)
    CarsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    -- Path Display
    local PathFrame = Instance.new("Frame")
    PathFrame.Size = UDim2.new(1, -20, 0, 40)
    PathFrame.Position = UDim2.new(0, 10, 1, -50)
    PathFrame.BackgroundColor3 = Color3.fromRGB(40, 50, 65)
    
    local PathText = Instance.new("TextLabel")
    PathText.Text = "📁 Menu.Trading.PeerToPeer.Main..."
    PathText.Size = UDim2.new(1, -20, 1, 0)
    PathText.Position = UDim2.new(0, 10, 0, 0)
    PathText.BackgroundTransparency = 1
    PathText.TextColor3 = Color3.fromRGB(180, 200, 255)
    PathText.Font = Enum.Font.Code
    PathText.TextSize = 11
    PathText.TextWrapped = true
    PathText.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = TitleBar
    corner:Clone().Parent = StatusFrame
    corner:Clone().Parent = CarsFrame
    corner:Clone().Parent = PathFrame
    corner:Clone().Parent = CloseButton
    
    -- Parenting
    TitleText.Parent = TitleBar
    CloseButton.Parent = TitleBar
    TitleBar.Parent = MainFrame
    
    StatusText.Parent = StatusFrame
    StatusFrame.Parent = MainFrame
    
    CarsLayout.Parent = CarsFrame
    CarsFrame.Parent = MainFrame
    
    PathText.Parent = PathFrame
    PathFrame.Parent = MainFrame
    
    MainFrame.Parent = ScreenGui
    
    -- UI Functions
    local function updateStatus(message, color)
        StatusText.Text = message
        StatusText.TextColor3 = color or Color3.fromRGB(255, 255, 150)
    end
    
    local function updatePath(path)
        PathText.Text = "📁 " .. path
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
        carFrame.Size = UDim2.new(0.95, 0, 0, 55)
        carFrame.BackgroundColor3 = Color3.fromRGB(60, 70, 95)
        carFrame.Name = "OfferCar_" .. index
        
        local carCorner = Instance.new("UICorner")
        carCorner.CornerRadius = UDim.new(0, 6)
        carCorner.Parent = carFrame
        
        -- Car icon with color based on type
        local icon = Instance.new("TextLabel")
        icon.Text = "🚗"
        icon.Size = UDim2.new(0, 45, 0, 45)
        icon.Position = UDim2.new(0, 5, 0.5, -22.5)
        icon.BackgroundTransparency = 1
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 24
        
        -- Car name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = carInfo.DisplayName
        nameLabel.Size = UDim2.new(0.6, -50, 0, 40)
        nameLabel.Position = UDim2.new(0, 55, 0.5, -20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 14
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Index badge
        local indexBadge = Instance.new("Frame")
        indexBadge.Size = UDim2.new(0, 25, 0, 25)
        indexBadge.Position = UDim2.new(1, -30, 0.5, -12.5)
        indexBadge.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        
        local badgeCorner = Instance.new("UICorner")
        badgeCorner.CornerRadius = UDim.new(0, 12.5)
        badgeCorner.Parent = indexBadge
        
        local indexText = Instance.new("TextLabel")
        indexText.Text = tostring(index)
        indexText.Size = UDim2.new(1, 0, 1, 0)
        indexText.BackgroundTransparency = 1
        indexText.TextColor3 = Color3.fromRGB(255, 255, 255)
        indexText.Font = Enum.Font.GothamBold
        indexText.TextSize = 12
        
        indexText.Parent = indexBadge
        indexBadge.Parent = carFrame
        
        -- Parenting
        icon.Parent = carFrame
        nameLabel.Parent = carFrame
        carFrame.Parent = CarsFrame
        
        return carFrame
    end
    
    local function refreshDisplay()
        local offeredCars = ScanOfferedCarsExact()
        
        clearCarsList()
        
        if #offeredCars > 0 then
            updateStatus("✅ " .. #offeredCars .. " car(s) in offer", Color3.fromRGB(100, 255, 100))
            
            for i, car in ipairs(offeredCars) do
                createCarDisplay(car, i)
            end
            
            -- Update path display
            local container = GetExactOfferContainer()
            if container then
                updatePath(container:GetFullName())
            end
            
            -- Print to console
            print("\n📊 OFFERED CARS FOUND:")
            for _, car in ipairs(offeredCars) do
                print("   🚗 " .. car.DisplayName .. " (from " .. car.RawName .. ")")
            end
            print(string.rep("=", 50))
            
        else
            local container = GetExactOfferContainer()
            
            if container then
                if container.Visible then
                    updateStatus("📭 No cars in offer", Color3.fromRGB(255, 200, 100))
                    
                    -- Show empty state
                    local emptyFrame = Instance.new("Frame")
                    emptyFrame.Size = UDim2.new(0.9, 0, 0, 80)
                    emptyFrame.BackgroundColor3 = Color3.fromRGB(40, 50, 65)
                    
                    local emptyCorner = Instance.new("UICorner")
                    emptyCorner.CornerRadius = UDim.new(0, 6)
                    emptyCorner.Parent = emptyFrame
                    
                    local emptyText = Instance.new("TextLabel")
                    emptyText.Text = "Add cars to\nyour offer"
                    emptyText.Size = UDim2.new(1, 0, 1, 0)
                    emptyText.BackgroundTransparency = 1
                    emptyText.TextColor3 = Color3.fromRGB(150, 150, 150)
                    emptyText.Font = Enum.Font.Gotham
                    emptyText.TextSize = 13
                    emptyText.TextWrapped = true
                    
                    emptyText.Parent = emptyFrame
                    emptyFrame.Parent = CarsFrame
                else
                    updateStatus("🔍 Trade not active", Color3.fromRGB(255, 150, 100))
                end
                updatePath(container:GetFullName())
            else
                updateStatus("❌ No trade UI found", Color3.fromRGB(255, 100, 100))
                updatePath("Menu.Trading.PeerToPeer.Main.Inventory.LocalPlayer.Content.ScrollingFrame")
            end
        end
    end
    
    -- UI Events
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
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
    
    -- Auto-refresh loop (FAST - 0.5 seconds)
    spawn(function()
        while task.wait(0.5) do
            if not ScreenGui or not ScreenGui.Parent then break end
            refreshDisplay()
        end
    end)
    
    -- Initial display
    task.wait(1)
    refreshDisplay()
    
    return ScreenGui
end

-- ===== DEBUG: MONITOR OFFER CONTAINER =====
local function DebugMonitorOffer()
    spawn(function()
        local lastChildCount = 0
        
        while task.wait(1) do
            local container = GetExactOfferContainer()
            
            if container then
                local childCount = #container:GetChildren()
                local isVisible = container.Visible
                
                if childCount ~= lastChildCount or isVisible then
                    print("\n🔍 OFFER CONTAINER STATUS:")
                    print("   Path: " .. container:GetFullName())
                    print("   Visible: " .. tostring(isVisible))
                    print("   Children: " .. childCount)
                    
                    if childCount > 0 then
                        print("   Contents:")
                        for _, child in pairs(container:GetChildren()) do
                            print("     • " .. child.Name .. " (" .. child.ClassName .. ")")
                            
                            -- Show child properties
                            if child:IsA("TextButton") and child.Text ~= "" then
                                print("       Text: " .. child.Text)
                            end
                            
                            -- Show grandchildren
                            for _, grandchild in pairs(child:GetChildren()) do
                                if grandchild:IsA("TextLabel") and grandchild.Text ~= "" then
                                    print("       Label: " .. grandchild.Name .. " = " .. grandchild.Text)
                                end
                            end
                        end
                    end
                    
                    lastChildCount = childCount
                end
            else
                print("❌ No offer container - not in trade")
            end
        end
    end)
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("🎯 CDT EXACT OFFER TRACKER")
print("📍 Targeting: LocalPlayer.Content.ScrollingFrame")
print("⚡ Updates every 0.5 seconds")
print(string.rep("=", 60))

-- Create UI
CreateExactTrackerUI()

-- Start debug monitor
DebugMonitorOffer()

print("\n✅ Tracker created!")
print("💡 Will show ONLY cars in your offer")
print("📊 Check Output for detailed container information")
print("\n🎮 Start a trade and add cars to see them appear!")
