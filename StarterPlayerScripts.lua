-- 🚗 CDT TRADE DUPLICATOR - FIXED UI OBJECTS
-- Skips UI layout objects, only duplicates car items

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🚗 TRADE DUPLICATOR - UI SAFE VERSION LOADED")

-- ===== FIND AND DUPLICATE CARS (SKIP UI OBJECTS) =====
local function DuplicateTradeCars()
    print("🔍 Looking for cars to duplicate...")
    
    -- First, find the trade interface
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then 
        print("❌ Menu not found")
        return 0 
    end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then 
        print("❌ Trading not found")
        return 0 
    end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then 
        print("❌ PeerToPeer not found")
        return 0 
    end
    
    local main = peerToPeer:FindFirstChild("Main")
    if not main then 
        print("❌ Main not found")
        return 0 
    end
    
    local localPlayer = main:FindFirstChild("LocalPlayer")
    if not localPlayer then 
        print("❌ LocalPlayer not found")
        return 0 
    end
    
    local content = localPlayer:FindFirstChild("Content")
    if not content then 
        print("❌ Content not found")
        return 0 
    end
    
    local scrollingFrame = content:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then 
        print("❌ ScrollingFrame not found")
        return 0 
    end
    
    print("✅ Found trade container: " .. scrollingFrame:GetFullName())
    
    -- Look for actual car/item objects (skip UI layout objects)
    local duplicatesCreated = 0
    
    -- Objects to SKIP (UI layout objects without Position property)
    local skipObjects = {
        "UIPadding", "UIListLayout", "UIGridLayout", "UIStroke", 
        "UICorner", "UIGradient", "UITextSizeConstraint", "UIAspectRatioConstraint",
        "UISizeConstraint", "ScrollingFrame"
    }
    
    for _, item in pairs(scrollingFrame:GetChildren()) do
        -- Skip UI layout objects and already duplicated items
        local shouldSkip = false
        
        for _, skipName in ipairs(skipObjects) do
            if item.Name == skipName or item.ClassName == skipName then
                shouldSkip = true
                break
            end
        end
        
        if shouldSkip or item.Name:find("_Dup") then
            -- Skip this item
            if item.Name ~= "UIPadding" then  -- Don't spam UIPadding messages
                -- print("⏭️ Skipping UI object: " .. item.Name)
            end
        else
            print("📦 Found item: " .. item.Name .. " (" .. item.ClassName .. ")")
            
            -- Check if this looks like a car/item (not a UI layout)
            local isLikelyCar = false
            
            -- Check by name
            local nameLower = item.Name:lower()
            if nameLower:find("car") or nameLower:find("vehicle") 
               or nameLower:find("item") or nameLower:find("product") then
                isLikelyCar = true
            end
            
            -- Check by class (Frame, TextButton, ImageButton are likely items)
            if item:IsA("Frame") or item:IsA("TextButton") or item:IsA("ImageButton") then
                isLikelyCar = true
            end
            
            if isLikelyCar then
                -- Try to clone it
                local success, clone = pcall(function()
                    return item:Clone()
                end)
                
                if success and clone then
                    -- Give it a unique name
                    local baseName = item.Name
                    local duplicateCount = 1
                    
                    while scrollingFrame:FindFirstChild(baseName .. "_Dup" .. duplicateCount) do
                        duplicateCount = duplicateCount + 1
                    end
                    
                    clone.Name = baseName .. "_Dup" .. duplicateCount
                    
                    -- Check if item has Position property before using it
                    local hasPosition = pcall(function()
                        return item.Position
                    end)
                    
                    local hasSize = pcall(function()
                        return item.Size
                    end)
                    
                    if hasPosition and hasSize then
                        -- Position it
                        local originalPos = item.Position
                        local originalSize = item.Size
                        
                        -- Calculate new position (to the right of original)
                        clone.Position = UDim2.new(
                            originalPos.X.Scale,
                            originalPos.X.Offset + originalSize.X.Offset + 10,
                            originalPos.Y.Scale,
                            originalPos.Y.Offset
                        )
                    else
                        -- Default position if no Position property
                        clone.Position = UDim2.new(0, 100, 0, 100)
                    end
                    
                    -- Add visual indicator
                    local indicator = Instance.new("TextLabel")
                    indicator.Name = "DuplicateIndicator"
                    indicator.Text = "🔄"
                    indicator.Size = UDim2.new(0, 20, 0, 20)
                    indicator.Position = UDim2.new(1, -25, 0, 5)
                    indicator.BackgroundTransparency = 1
                    indicator.TextColor3 = Color3.fromRGB(0, 255, 0)
                    indicator.Font = Enum.Font.GothamBold
                    indicator.TextSize = 14
                    indicator.Parent = clone
                    
                    -- Slightly different color for visual distinction
                    if clone:IsA("TextButton") or clone:IsA("Frame") then
                        local currentColor = clone.BackgroundColor3
                        clone.BackgroundColor3 = Color3.new(
                            math.min(1, currentColor.R * 0.9),
                            math.min(1, currentColor.G * 1.1),
                            math.min(1, currentColor.B * 0.9)
                        )
                    end
                    
                    -- Add to container
                    clone.Parent = scrollingFrame
                    
                    print("✅ Duplicated: " .. item.Name .. " → " .. clone.Name)
                    duplicatesCreated = duplicatesCreated + 1
                else
                    print("❌ Failed to clone: " .. item.Name)
                end
            end
        end
    end
    
    -- Also look inside frames within the scrolling frame
    for _, frame in pairs(scrollingFrame:GetChildren()) do
        if frame:IsA("Frame") and not frame.Name:find("_Dup") then
            print("📁 Checking frame: " .. frame.Name)
            
            for _, item in pairs(frame:GetChildren()) do
                -- Skip UI objects
                local shouldSkip = false
                for _, skipName in ipairs(skipObjects) do
                    if item.ClassName == skipName then
                        shouldSkip = true
                        break
                    end
                end
                
                if not shouldSkip and not item.Name:find("_Dup") then
                    print("   Found sub-item: " .. item.Name .. " (" .. item.ClassName .. ")")
                    
                    local success, clone = pcall(function()
                        return item:Clone()
                    end)
                    
                    if success and clone then
                        local baseName = item.Name
                        local duplicateCount = 1
                        
                        while frame:FindFirstChild(baseName .. "_Dup" .. duplicateCount) do
                            duplicateCount = duplicateCount + 1
                        end
                        
                        clone.Name = baseName .. "_Dup" .. duplicateCount
                        
                        -- Check for Position property
                        local hasPosition = pcall(function()
                            return item.Position
                        end)
                        
                        local hasSize = pcall(function()
                            return item.Size
                        end)
                        
                        if hasPosition and hasSize then
                            local originalPos = item.Position
                            local originalSize = item.Size
                            
                            clone.Position = UDim2.new(
                                originalPos.X.Scale,
                                originalPos.X.Offset + originalSize.X.Offset + 5,
                                originalPos.Y.Scale,
                                originalPos.Y.Offset
                            )
                        end
                        
                        clone.Parent = frame
                        
                        print("   ✅ Duplicated: " .. item.Name .. " → " .. clone.Name)
                        duplicatesCreated = duplicatesCreated + 1
                    end
                end
            end
        end
    end
    
    if duplicatesCreated > 0 then
        print("🎯 Created " .. duplicatesCreated .. " duplicates")
        
        -- Try to copy to other player
        MirrorToOtherPlayer(scrollingFrame)
    else
        print("⚠️ No cars/items found to duplicate")
        print("💡 Make sure to add cars to your trade offer first")
    end
    
    return duplicatesCreated
end

-- ===== MIRROR TO OTHER PLAYER =====
local function MirrorToOtherPlayer(sourceScrollingFrame)
    print("🪞 Attempting to mirror to other player...")
    
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then 
        print("❌ Menu not found")
        return false 
    end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then 
        print("❌ Trading not found")
        return false 
    end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then 
        print("❌ PeerToPeer not found")
        return false 
    end
    
    local main = peerToPeer:FindFirstChild("Main")
    if not main then 
        print("❌ Main not found")
        return false 
    end
    
    -- Find other player's container
    for _, container in pairs(main:GetChildren()) do
        if container.Name ~= "LocalPlayer" and container:IsA("Frame") then
            print("🎯 Found other player container: " .. container.Name)
            
            local content = container:FindFirstChild("Content")
            if content then
                local targetScrollingFrame = content:FindFirstChild("ScrollingFrame")
                if targetScrollingFrame then
                    print("✅ Found target scrolling frame")
                    
                    -- Clear existing duplicates first
                    for _, item in pairs(targetScrollingFrame:GetChildren()) do
                        if item.Name:find("_Dup") then
                            item:Destroy()
                        end
                    end
                    
                    -- Copy duplicates from our container
                    local mirroredCount = 0
                    for _, item in pairs(sourceScrollingFrame:GetChildren()) do
                        if item.Name:find("_Dup") then
                            local success, clone = pcall(function()
                                return item:Clone()
                            end)
                            
                            if success and clone then
                                clone.Parent = targetScrollingFrame
                                
                                -- Try to copy position
                                local successPos = pcall(function()
                                    clone.Position = item.Position
                                end)
                                
                                if not successPos then
                                    -- Default position
                                    clone.Position = UDim2.new(0, 100 + (mirroredCount * 120), 0, 100)
                                end
                                
                                mirroredCount = mirroredCount + 1
                                print("   🔄 Mirrored: " .. clone.Name)
                            end
                        end
                    end
                    
                    -- Also copy from frames within
                    for _, frame in pairs(sourceScrollingFrame:GetChildren()) do
                        if frame:IsA("Frame") and not frame.Name:find("_Dup") then
                            local targetFrame = targetScrollingFrame:FindFirstChild(frame.Name)
                            if targetFrame then
                                for _, item in pairs(frame:GetChildren()) do
                                    if item.Name:find("_Dup") then
                                        local success, clone = pcall(function()
                                            return item:Clone()
                                        })
                                        
                                        if success and clone then
                                            clone.Parent = targetFrame
                                            
                                            -- Try to copy position
                                            pcall(function()
                                                clone.Position = item.Position
                                            end)
                                            
                                            print("   🔄 Mirrored (nested): " .. clone.Name)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    print("✅ Successfully mirrored " .. mirroredCount .. " duplicates to other player")
                    return true
                end
            end
        end
    end
    
    print("❌ Could not find other player's trade container")
    return false
end

-- ===== SIMPLE UI =====
local function CreateSimpleUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TradeDuplicatorUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🚗 TRADE DUPLICATOR"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    
    local Status = Instance.new("TextLabel")
    Status.Text = "1. Open trade\n2. Add cars\n3. Click DUPLICATE"
    Status.Size = UDim2.new(1, -20, 0, 60)
    Status.Position = UDim2.new(0, 10, 0, 50)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    Status.TextWrapped = true
    
    local DuplicateBtn = Instance.new("TextButton")
    DuplicateBtn.Text = "📋 DUPLICATE"
    DuplicateBtn.Size = UDim2.new(1, -20, 0, 35)
    DuplicateBtn.Position = UDim2.new(0, 10, 0, 120)
    DuplicateBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    DuplicateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DuplicateBtn.Font = Enum.Font.GothamBold
    
    local CleanBtn = Instance.new("TextButton")
    CleanBtn.Text = "🗑️ CLEAN"
    CleanBtn.Size = UDim2.new(1, -20, 0, 35)
    CleanBtn.Position = UDim2.new(0, 10, 0, 165)
    CleanBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CleanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CleanBtn.Font = Enum.Font.GothamBold
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = Title
    corner:Clone().Parent = DuplicateBtn
    corner:Clone().Parent = CleanBtn
    
    -- Parent
    Title.Parent = MainFrame
    Status.Parent = MainFrame
    DuplicateBtn.Parent = MainFrame
    CleanBtn.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Functions
    DuplicateBtn.MouseButton1Click:Connect(function()
        DuplicateBtn.Text = "WORKING..."
        local duplicates = DuplicateTradeCars()
        
        if duplicates > 0 then
            Status.Text = "✅ " .. duplicates .. " duplicates created\n"
            Status.Text = Status.Text .. "Both players see 2x cars\n"
            Status.Text = Status.Text .. "Only 1 car actually trades"
            
            DuplicateBtn.Text = "✅ DONE"
            DuplicateBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            Status.Text = "❌ No cars found\nAdd cars to trade offer first"
            DuplicateBtn.Text = "📋 DUPLICATE"
        end
    end)
    
    CleanBtn.MouseButton1Click:Connect(function()
        CleanBtn.Text = "CLEANING..."
        
        -- Simple clean function
        local removed = 0
        local menu = Player.PlayerGui:FindFirstChild("Menu")
        if menu then
            local trading = menu:FindFirstChild("Trading")
            if trading then
                local peerToPeer = trading:FindFirstChild("PeerToPeer")
                if peerToPeer then
                    local main = peerToPeer:FindFirstChild("Main")
                    if main then
                        for _, container in pairs(main:GetChildren()) do
                            if container:IsA("Frame") then
                                local content = container:FindFirstChild("Content")
                                if content then
                                    local scrollingFrame = content:FindFirstChild("ScrollingFrame")
                                    if scrollingFrame then
                                        for _, item in pairs(scrollingFrame:GetChildren()) do
                                            if item.Name:find("_Dup") then
                                                item:Destroy()
                                                removed = removed + 1
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        
        Status.Text = "🗑️ Removed " .. removed .. " duplicates"
        CleanBtn.Text = "🗑️ CLEAN"
        
        task.wait(2)
        Status.Text = "1. Open trade\n2. Add cars\n3. Click DUPLICATE"
    end)
    
    return ScreenGui
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("🚗 TRADE DUPLICATOR - UI SAFE VERSION")
print(string.rep("=", 60))

CreateSimpleUI()

-- Auto-duplicate when trade is open
spawn(function()
    while task.wait(3) do
        -- Check if trade is open
        local menu = Player.PlayerGui:FindFirstChild("Menu")
        if menu and menu:FindFirstChild("Trading") then
            -- Check if we're in a trade
            local trading = menu.Trading
            local peerToPeer = trading:FindFirstChild("PeerToPeer")
            if peerToPeer then
                DuplicateTradeCars()
            end
        end
    end
end)

print("\n✅ Ready! Follow these steps:")
print("1. Open trade with another player")
print("2. Add cars to your offer")
print("3. Click DUPLICATE button")
print("4. Both players will see 2x cars")
print("5. Only 1 car actually transfers")
print(string.rep("=", 60))
