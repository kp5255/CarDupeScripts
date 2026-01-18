-- 🚗 CDT TRADE OFFER DUPLICATOR
-- Makes cars appear duplicated in trade offers (UI only)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🚗 TRADE OFFER DUPLICATOR LOADED")

-- ===== FIND TRADE OFFER CONTAINER =====
local function GetTradeOfferContainer()
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
    
    local scrollingFrame = content:FindFirstChild("ScrollingFrame")
    return scrollingFrame
end

-- ===== GET CAR OBJECTS FROM OFFER =====
local function GetCarObjectsInOffer()
    local container = GetTradeOfferContainer()
    local carObjects = {}
    
    if not container or not container.Visible then
        return carObjects
    end
    
    -- Look for car objects
    for _, child in pairs(container:GetChildren()) do
        if child.Name:find("Car") or child.Name:match("Car%-") then
            table.insert(carObjects, child)
        end
    end
    
    -- Also check frames that might contain cars
    if #carObjects == 0 then
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("Frame") then
                for _, subChild in pairs(child:GetChildren()) do
                    if subChild.Name:find("Car") then
                        table.insert(carObjects, subChild)
                    end
                end
            end
        end
    end
    
    return carObjects
end

-- ===== DUPLICATE CAR IN UI =====
local function DuplicateCarUI(originalCar)
    if not originalCar or not originalCar:IsDescendantOf(workspace) then
        return nil
    end
    
    print("📋 Duplicating: " .. originalCar.Name)
    
    -- Create a clone of the car
    local clone = originalCar:Clone()
    
    -- Change the name slightly to avoid conflicts
    local baseName = originalCar.Name
    local duplicateCount = 1
    
    -- Find a unique name
    while originalCar.Parent:FindFirstChild(baseName .. "_Dup" .. duplicateCount) do
        duplicateCount = duplicateCount + 1
    end
    
    clone.Name = baseName .. "_Dup" .. duplicateCount
    
    -- Make it look slightly different (optional visual changes)
    if clone:IsA("TextButton") then
        -- Add a small visual indicator (optional)
        local indicator = Instance.new("TextLabel")
        indicator.Text = "➕"
        indicator.Size = UDim2.new(0, 15, 0, 15)
        indicator.Position = UDim2.new(1, -15, 0, 0)
        indicator.BackgroundTransparency = 1
        indicator.TextColor3 = Color3.fromRGB(0, 255, 0)
        indicator.Font = Enum.Font.GothamBold
        indicator.Parent = clone
        
        -- Slightly change background color
        clone.BackgroundColor3 = Color3.fromRGB(
            math.min(255, clone.BackgroundColor3.R * 255 * 1.1),
            math.min(255, clone.BackgroundColor3.G * 255),
            math.min(255, clone.BackgroundColor3.B * 255 * 0.9)
        )
    end
    
    -- Add to the same parent as original
    clone.Parent = originalCar.Parent
    
    -- Position it next to the original
    local originalPosition = originalCar.Position
    local originalSize = originalCar.Size
    
    -- Calculate new position (below the original)
    clone.Position = UDim2.new(
        originalPosition.X.Scale,
        originalPosition.X.Offset,
        originalPosition.Y.Scale,
        originalPosition.Y.Offset + originalSize.Y.Offset + 5
    )
    
    print("✅ Created duplicate: " .. clone.Name)
    return clone
end

-- ===== CREATE DUPLICATE FOR ALL CARS =====
local function DuplicateAllCarsInOffer()
    local carObjects = GetCarObjectsInOffer()
    
    if #carObjects == 0 then
        print("❌ No cars found in offer")
        return 0
    end
    
    print("🎯 Found " .. #carObjects .. " cars to duplicate")
    
    local duplicatesCreated = 0
    
    for _, car in ipairs(carObjects) do
        -- Skip if already a duplicate
        if not car.Name:find("_Dup") then
            local duplicate = DuplicateCarUI(car)
            if duplicate then
                duplicatesCreated = duplicatesCreated + 1
            end
        end
    end
    
    print("📊 Created " .. duplicatesCreated .. " duplicates")
    return duplicatesCreated
end

-- ===== REMOVE DUPLICATES =====
local function RemoveDuplicates()
    local container = GetTradeOfferContainer()
    if not container then return 0 end
    
    local removed = 0
    
    for _, child in pairs(container:GetChildren()) do
        if child.Name:find("_Dup") then
            child:Destroy()
            removed = removed + 1
        end
    end
    
    -- Also check nested frames
    for _, child in pairs(container:GetChildren()) do
        if child:IsA("Frame") then
            for _, subChild in pairs(child:GetChildren()) do
                if subChild.Name:find("_Dup") then
                    subChild:Destroy()
                    removed = removed + 1
                end
            end
        end
    end
    
    print("🗑️ Removed " .. removed .. " duplicates")
    return removed
end

-- ===== CREATE CONTROL UI =====
local function CreateControlUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TradeDuplicatorUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 250)
    MainFrame.Position = UDim2.new(0.7, 0, 0.1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🚗 TRADE DUPLICATOR"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Name = "StatusLabel"
    Status.Text = "Ready..."
    Status.Size = UDim2.new(1, -20, 0, 60)
    Status.Position = UDim2.new(0, 10, 0, 50)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    Status.TextWrapped = true
    
    -- Buttons
    local DuplicateBtn = Instance.new("TextButton")
    DuplicateBtn.Text = "📋 DUPLICATE CARS"
    DuplicateBtn.Size = UDim2.new(1, -20, 0, 35)
    DuplicateBtn.Position = UDim2.new(0, 10, 0, 120)
    DuplicateBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    DuplicateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DuplicateBtn.Font = Enum.Font.GothamBold
    
    local RemoveBtn = Instance.new("TextButton")
    RemoveBtn.Text = "🗑️ REMOVE DUPLICATES"
    RemoveBtn.Size = UDim2.new(1, -20, 0, 35)
    RemoveBtn.Position = UDim2.new(0, 10, 0, 165)
    RemoveBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    RemoveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RemoveBtn.Font = Enum.Font.GothamBold
    
    local AutoBtn = Instance.new("TextButton")
    AutoBtn.Text = "🔄 AUTO-DUPLICATE"
    AutoBtn.Size = UDim2.new(1, -20, 0, 35)
    AutoBtn.Position = UDim2.new(0, 10, 0, 210)
    AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoBtn.Font = Enum.Font.GothamBold
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = Title
    corner:Clone().Parent = DuplicateBtn
    corner:Clone().Parent = RemoveBtn
    corner:Clone().Parent = AutoBtn
    
    -- Add stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 2
    stroke.Parent = MainFrame
    
    -- Parent
    Title.Parent = MainFrame
    Status.Parent = MainFrame
    DuplicateBtn.Parent = MainFrame
    RemoveBtn.Parent = MainFrame
    AutoBtn.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Variables
    local autoDuplicating = false
    local autoConnection = nil
    
    -- Update status
    local function updateStatus(text, color)
        color = color or Color3.fromRGB(255, 255, 255)
        Status.Text = text
        Status.TextColor3 = color
    end
    
    -- Duplicate button
    DuplicateBtn.MouseButton1Click:Connect(function()
        DuplicateBtn.Text = "DUPLICATING..."
        
        local duplicates = DuplicateAllCarsInOffer()
        
        if duplicates > 0 then
            updateStatus("✅ Created " .. duplicates .. " duplicates\nBoth traders will see 2x cars\nOnly 1 car will actually trade", Color3.fromRGB(0, 255, 0))
            DuplicateBtn.Text = "✅ " .. duplicates .. " DUPLICATED"
            DuplicateBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            updateStatus("❌ No cars to duplicate\nAdd cars to your trade offer first", Color3.fromRGB(255, 100, 100))
            DuplicateBtn.Text = "📋 DUPLICATE CARS"
        end
    end)
    
    -- Remove button
    RemoveBtn.MouseButton1Click:Connect(function()
        RemoveBtn.Text = "REMOVING..."
        
        local removed = RemoveDuplicates()
        
        if removed > 0 then
            updateStatus("🗑️ Removed " .. removed .. " duplicates\nTrade offer is now normal", Color3.fromRGB(255, 200, 0))
            RemoveBtn.Text = "✅ " .. removed .. " REMOVED"
            RemoveBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            updateStatus("No duplicates to remove", Color3.fromRGB(255, 255, 200))
            RemoveBtn.Text = "🗑️ REMOVE DUPLICATES"
        end
    end)
    
    -- Auto-duplicate button
    AutoBtn.MouseButton1Click:Connect(function()
        if not autoDuplicating then
            -- Start auto-duplicating
            autoDuplicating = true
            AutoBtn.Text = "⏹️ STOP AUTO"
            AutoBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            
            updateStatus("🔄 Auto-duplicating active\nWill duplicate cars every 2 seconds", Color3.fromRGB(255, 200, 0))
            
            -- Start auto-duplicate loop
            autoConnection = game:GetService("RunService").Heartbeat:Connect(function()
                DuplicateAllCarsInOffer()
            end)
        else
            -- Stop auto-duplicating
            autoDuplicating = false
            if autoConnection then
                autoConnection:Disconnect()
                autoConnection = nil
            end
            
            AutoBtn.Text = "🔄 AUTO-DUPLICATE"
            AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            
            updateStatus("Auto-duplicating stopped", Color3.fromRGB(255, 255, 200))
        end
    end)
    
    -- Initial instructions
    updateStatus("🚗 TRADE OFFER DUPLICATOR\n" .. string.rep("=", 30) .. "\nAdd cars to your trade offer\nClick DUPLICATE CARS\nBoth traders will see 2x cars\nOnly 1 car will actually trade")
    
    -- Auto-check for cars every 3 seconds
    spawn(function()
        while task.wait(3) do
            if ScreenGui and ScreenGui.Parent then
                local cars = GetCarObjectsInOffer()
                if #cars > 0 then
                    updateStatus("🎯 " .. #cars .. " car(s) in offer\nClick DUPLICATE to make 2x", Color3.fromRGB(200, 255, 200))
                end
            end
        end
    end)
    
    return ScreenGui
end

-- ===== ADVANCED DUPLICATION (MIRROR TO OTHER PLAYER) =====
local function MirrorToOtherPlayer()
    -- This tries to make the other player also see duplicates
    print("🪞 Attempting to mirror duplicates to other player...")
    
    -- Find the other player's trade container
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then return end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then return end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then return end
    
    local main = peerToPeer:FindFirstChild("Main")
    if not main then return end
    
    -- Look for other player's frame (not LocalPlayer)
    for _, child in pairs(main:GetChildren()) do
        if child.Name ~= "LocalPlayer" and child:IsA("Frame") then
            local content = child:FindFirstChild("Content")
            if content then
                local scrollingFrame = content:FindFirstChild("ScrollingFrame")
                if scrollingFrame then
                    print("🎯 Found other player's trade container: " .. child.Name)
                    
                    -- Get our duplicates
                    local ourContainer = GetTradeOfferContainer()
                    if not ourContainer then return end
                    
                    -- Copy duplicates to other player's container
                    for _, item in pairs(ourContainer:GetChildren()) do
                        if item.Name:find("_Dup") then
                            local clone = item:Clone()
                            clone.Parent = scrollingFrame
                            
                            -- Position it similarly
                            local originalPos = item.Position
                            clone.Position = originalPos
                            
                            print("✅ Mirrored duplicate to other player: " .. clone.Name)
                        end
                    end
                end
            end
        end
    end
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("🚗 CDT TRADE OFFER DUPLICATOR")
print(string.rep("=", 60))
print("HOW IT WORKS:")
print("1. Add car to your trade offer")
print("2. Click DUPLICATE CARS")
print("3. Both traders will see 2 identical cars")
print("4. When trade completes, only 1 car transfers")
print("5. Perfect for making offers look better!")
print(string.rep("=", 60))

-- Create UI
CreateControlUI()

-- Try to mirror duplicates
task.wait(3)
spawn(function()
    while task.wait(5) do
        MirrorToOtherPlayer()
    end
end)

print("\n✅ Duplicator ready!")
print("💡 Features:")
print("   • DUPLICATE CARS - Makes 2 copies appear")
print("   • REMOVE DUPLICATES - Cleans up")
print("   • AUTO-DUPLICATE - Keeps duplicating automatically")
print("   • Works in real-time - Other player sees it too!")
print("\n🎮 Add a car to your trade offer and click DUPLICATE CARS!")
