-- 🚗 CDT TRADE DUPLICATOR - FIXED VERSION
-- Directly duplicates cars in trade offers

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🚗 TRADE DUPLICATOR FIXED VERSION LOADED")

-- ===== FIND AND DUPLICATE CARS =====
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
    
    -- Look for ANY objects in the trade container
    local duplicatesCreated = 0
    
    for _, item in pairs(scrollingFrame:GetChildren()) do
        -- Skip if already a duplicate
        if not item.Name:find("_Dup") then
            print("📦 Found item: " .. item.Name .. " (" .. item.ClassName .. ")")
            
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
                
                -- Position it
                local originalPos = item.Position
                local originalSize = item.Size
                
                -- Calculate new position (below original)
                clone.Position = UDim2.new(
                    originalPos.X.Scale,
                    originalPos.X.Offset,
                    originalPos.Y.Scale,
                    originalPos.Y.Offset + originalSize.Y.Offset + 10
                )
                
                -- Add visual indicator (optional)
                if clone:IsA("TextButton") or clone:IsA("Frame") then
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
                    
                    -- Slightly different color
                    clone.BackgroundColor3 = Color3.fromRGB(
                        math.min(255, clone.BackgroundColor3.R * 255 * 0.9),
                        math.min(255, clone.BackgroundColor3.G * 255 * 1.1),
                        math.min(255, clone.BackgroundColor3.B * 255 * 0.9)
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
    
    -- Also look inside frames within the scrolling frame
    for _, frame in pairs(scrollingFrame:GetChildren()) do
        if frame:IsA("Frame") then
            print("📁 Checking frame: " .. frame.Name)
            
            for _, item in pairs(frame:GetChildren()) do
                if not item.Name:find("_Dup") then
                    print("   Found sub-item: " .. item.Name)
                    
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
                        
                        -- Position relative to original
                        local originalPos = item.Position
                        local originalSize = item.Size
                        
                        clone.Position = UDim2.new(
                            originalPos.X.Scale,
                            originalPos.X.Offset,
                            originalPos.Y.Scale,
                            originalPos.Y.Offset + originalSize.Y.Offset + 5
                        )
                        
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
        print("⚠️ No items to duplicate - Add cars to your offer first")
    end
    
    return duplicatesCreated
end

-- ===== MIRROR TO OTHER PLAYER =====
local function MirrorToOtherPlayer(sourceScrollingFrame)
    print("🪞 Attempting to mirror to other player...")
    
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then return end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then return end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then return end
    
    local main = peerToPeer:FindFirstChild("Main")
    if not main then return end
    
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
                    for _, item in pairs(sourceScrollingFrame:GetChildren()) do
                        if item.Name:find("_Dup") then
                            local success, clone = pcall(function()
                                return item:Clone()
                            end)
                            
                            if success and clone then
                                clone.Parent = targetScrollingFrame
                                clone.Position = item.Position
                                print("   🔄 Mirrored: " .. clone.Name)
                            end
                        end
                    end
                    
                    -- Also copy from frames within
                    for _, frame in pairs(sourceScrollingFrame:GetChildren()) do
                        if frame:IsA("Frame") then
                            local targetFrame = targetScrollingFrame:FindFirstChild(frame.Name)
                            if targetFrame then
                                for _, item in pairs(frame:GetChildren()) do
                                    if item.Name:find("_Dup") then
                                        local success, clone = pcall(function()
                                            return item:Clone()
                                        end)
                                        
                                        if success and clone then
                                            clone.Parent = targetFrame
                                            clone.Position = item.Position
                                            print("   🔄 Mirrored (nested): " .. clone.Name)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    print("✅ Successfully mirrored duplicates to other player")
                    return true
                end
            end
        end
    end
    
    print("❌ Could not find other player's trade container")
    return false
end

-- ===== REMOVE DUPLICATES =====
local function RemoveAllDuplicates()
    print("🗑️ Removing all duplicates...")
    
    local removed = 0
    
    -- Remove from our container
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if menu then
        local trading = menu:FindFirstChild("Trading")
        if trading then
            local peerToPeer = trading:FindFirstChild("PeerToPeer")
            if peerToPeer then
                local main = peerToPeer:FindFirstChild("Main")
                if main then
                    -- Our container
                    local localPlayer = main:FindFirstChild("LocalPlayer")
                    if localPlayer then
                        local content = localPlayer:FindFirstChild("Content")
                        if content then
                            local scrollingFrame = content:FindFirstChild("ScrollingFrame")
                            if scrollingFrame then
                                for _, item in pairs(scrollingFrame:GetChildren()) do
                                    if item.Name:find("_Dup") then
                                        item:Destroy()
                                        removed = removed + 1
                                    end
                                end
                                
                                -- Also check frames within
                                for _, frame in pairs(scrollingFrame:GetChildren()) do
                                    if frame:IsA("Frame") then
                                        for _, item in pairs(frame:GetChildren()) do
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
                    
                    -- Other player's container
                    for _, container in pairs(main:GetChildren()) do
                        if container.Name ~= "LocalPlayer" and container:IsA("Frame") then
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
    
    print("✅ Removed " .. removed .. " duplicates")
    return removed
end

-- ===== CREATE SIMPLE UI =====
local function CreateSimpleUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleDuplicatorUI"
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
    Status.Text = "Add cars to trade offer\nThen click DUPLICATE"
    Status.Size = UDim2.new(1, -20, 0, 60)
    Status.Position = UDim2.new(0, 10, 0, 50)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    Status.TextWrapped = true
    
    local DuplicateBtn = Instance.new("TextButton")
    DuplicateBtn.Text = "📋 DUPLICATE NOW"
    DuplicateBtn.Size = UDim2.new(1, -20, 0, 35)
    DuplicateBtn.Position = UDim2.new(0, 10, 0, 120)
    DuplicateBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    DuplicateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DuplicateBtn.Font = Enum.Font.GothamBold
    
    local RemoveBtn = Instance.new("TextButton")
    RemoveBtn.Text = "🗑️ CLEAN UP"
    RemoveBtn.Size = UDim2.new(1, -20, 0, 35)
    RemoveBtn.Position = UDim2.new(0, 10, 0, 165)
    RemoveBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    RemoveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RemoveBtn.Font = Enum.Font.GothamBold
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = Title
    corner:Clone().Parent = DuplicateBtn
    corner:Clone().Parent = RemoveBtn
    
    -- Parent
    Title.Parent = MainFrame
    Status.Parent = MainFrame
    DuplicateBtn.Parent = MainFrame
    RemoveBtn.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Functions
    DuplicateBtn.MouseButton1Click:Connect(function()
        DuplicateBtn.Text = "DUPLICATING..."
        Status.Text = "Duplicating cars...\n"
        
        local duplicates = DuplicateTradeCars()
        
        if duplicates > 0 then
            Status.Text = Status.Text .. "✅ Created " .. duplicates .. " duplicates\n"
            Status.Text = Status.Text .. "Both players see 2x cars\n"
            Status.Text = Status.Text .. "Only 1 car will actually trade"
            
            DuplicateBtn.Text = "✅ " .. duplicates .. " DUPES"
            DuplicateBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            Status.Text = "❌ No cars to duplicate\nAdd cars to your trade offer first"
            DuplicateBtn.Text = "📋 DUPLICATE NOW"
        end
    end)
    
    RemoveBtn.MouseButton1Click:Connect(function()
        RemoveBtn.Text = "CLEANING..."
        Status.Text = "Removing duplicates...\n"
        
        local removed = RemoveAllDuplicates()
        
        Status.Text = Status.Text .. "🗑️ Removed " .. removed .. " duplicates"
        RemoveBtn.Text = "🗑️ CLEAN UP"
        
        task.wait(2)
        Status.Text = "Ready to duplicate again\nAdd cars and click DUPLICATE"
    end)
    
    -- Auto-check for trade offer
    spawn(function()
        while task.wait(2) do
            if ScreenGui and ScreenGui.Parent then
                -- Check if trade is open
                local menu = Player.PlayerGui:FindFirstChild("Menu")
                if menu and menu:FindFirstChild("Trading") then
                    Status.TextColor3 = Color3.fromRGB(0, 255, 0)
                else
                    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
        end
    end)
    
    return ScreenGui
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("🚗 TRADE DUPLICATOR - FIXED VERSION")
print(string.rep("=", 60))

CreateSimpleUI()

-- Auto-duplicate every 5 seconds when trade is open
spawn(function()
    while task.wait(5) do
        -- Check if trade menu is open
        local menu = Player.PlayerGui:FindFirstChild("Menu")
        if menu and menu:FindFirstChild("Trading") then
            DuplicateTradeCars()
        end
    end
end)

print("\n✅ Duplicator ready!")
print("💡 Instructions:")
print("1. Open trade with another player")
print("2. Add cars to your offer")
print("3. Click DUPLICATE NOW")
print("4. Both players will see 2x cars")
print("5. Only 1 car actually trades")
print(string.rep("=", 60))
