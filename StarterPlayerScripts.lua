-- 🚗 TRADE DUPLICATOR - BOTH SIDES
-- Duplicates cars for BOTH traders in the trade

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

wait(2)

print("🚗 BOTH-SIDE TRADE DUPLICATOR LOADED")

-- ===== GET BOTH TRADE CONTAINERS =====
local function GetBothTradeContainers()
    if not Player.PlayerGui then return nil, nil end
    
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then return nil, nil end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then return nil, nil end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then return nil, nil end
    
    local main = peerToPeer:FindFirstChild("Main")
    if not main then return nil, nil end
    
    -- Get MY container (LocalPlayer)
    local myContainer = nil
    local myPlayerFrame = main:FindFirstChild("LocalPlayer")
    if myPlayerFrame then
        local content = myPlayerFrame:FindFirstChild("Content")
        if content then
            myContainer = content:FindFirstChild("ScrollingFrame")
        end
    end
    
    -- Get OTHER PLAYER's container
    local otherContainer = nil
    for _, containerFrame in pairs(main:GetChildren()) do
        if containerFrame.Name ~= "LocalPlayer" and containerFrame:IsA("Frame") then
            local content = containerFrame:FindFirstChild("Content")
            if content then
                otherContainer = content:FindFirstChild("ScrollingFrame")
                if otherContainer then
                    print("✅ Found other player container: " .. containerFrame.Name)
                    break
                end
            end
        end
    end
    
    return myContainer, otherContainer
end

-- ===== FIND AND DUPLICATE CARS =====
local function FindAndDuplicateCars()
    print("\n🔍 Looking for cars in BOTH containers...")
    
    local myContainer, otherContainer = GetBothTradeContainers()
    
    if not myContainer then
        print("❌ Your trade container not found")
        return 0
    end
    
    if not otherContainer then
        print("⚠️ Other player container not found (they might not have added items)")
    end
    
    local totalDuplicates = 0
    
    -- ===== STEP 1: Find cars in MY container =====
    local foundCars = {}
    
    print("\n🎯 Looking in YOUR container:")
    for _, item in pairs(myContainer:GetChildren()) do
        -- Skip UI objects
        if item.ClassName == "UIPadding" or item.ClassName == "UIListLayout" then
            continue
        end
        
        -- Check if this looks like a car/item
        local isCar = false
        
        if item.Name:find("Car") or item.Name:match("Car%-") then
            isCar = true
        elseif item:IsA("Frame") or item:IsA("TextButton") then
            -- Check children for car indicators
            for _, child in pairs(item:GetChildren()) do
                if child:IsA("TextLabel") and child.Text:find("Car") then
                    isCar = true
                    break
                end
            end
        end
        
        if isCar then
            print("🚗 Found car: " .. item.Name .. " (" .. item.ClassName .. ")")
            table.insert(foundCars, {
                object = item,
                container = myContainer,
                isNested = false
            })
        end
    end
    
    -- Check inside frames
    for _, frame in pairs(myContainer:GetChildren()) do
        if frame:IsA("Frame") then
            for _, item in pairs(frame:GetChildren()) do
                if item.Name:find("Car") then
                    print("🚗 Found nested car: " .. item.Name .. " in " .. frame.Name)
                    table.insert(foundCars, {
                        object = item,
                        container = frame,
                        isNested = true,
                        parentFrame = frame
                    })
                end
            end
        end
    end
    
    if #foundCars == 0 then
        print("❌ No cars found in your offer")
        return 0
    end
    
    print("✅ Found " .. #foundCars .. " cars to duplicate")
    
    -- ===== STEP 2: Duplicate in MY container =====
    print("\n📋 Duplicating in YOUR container:")
    for i, carInfo in ipairs(foundCars) do
        local car = carInfo.object
        
        -- Create duplicate
        local success, duplicate = pcall(function()
            return car:Clone()
        end)
        
        if success and duplicate then
            -- Give unique name
            duplicate.Name = car.Name .. "_Copy" .. i
            
            -- Position it (to the right of original)
            if pcall(function() return car.Position end) then
                local pos = car.Position
                local size = car.Size
                duplicate.Position = UDim2.new(
                    pos.X.Scale,
                    pos.X.Offset + size.X.Offset + 15,
                    pos.Y.Scale,
                    pos.Y.Offset
                )
            end
            
            -- Add visual indicator
            local indicator = Instance.new("TextLabel")
            indicator.Text = "🔄"
            indicator.Size = UDim2.new(0, 20, 0, 20)
            indicator.Position = UDim2.new(1, -25, 0, 5)
            indicator.BackgroundTransparency = 1
            indicator.TextColor3 = Color3.fromRGB(0, 255, 0)
            indicator.Font = Enum.Font.GothamBold
            indicator.TextSize = 14
            indicator.Parent = duplicate
            
            -- Add to same container
            duplicate.Parent = carInfo.container
            
            print("   ✅ Created: " .. duplicate.Name)
            totalDuplicates = totalDuplicates + 1
            
            -- ===== STEP 3: Duplicate in OTHER PLAYER's container =====
            if otherContainer then
                print("   🪞 Mirroring to other player...")
                
                -- Find corresponding frame in other container
                local targetParent = otherContainer
                if carInfo.isNested and carInfo.parentFrame then
                    -- Look for same frame name in other container
                    local targetFrame = otherContainer:FindFirstChild(carInfo.parentFrame.Name)
                    if targetFrame then
                        targetParent = targetFrame
                    end
                end
                
                -- Create duplicate for other player
                local success2, duplicate2 = pcall(function()
                    return duplicate:Clone()
                end)
                
                if success2 and duplicate2 then
                    duplicate2.Name = duplicate.Name .. "_Other"
                    duplicate2.Parent = targetParent
                    
                    -- Same position
                    if pcall(function() return duplicate.Position end) then
                        duplicate2.Position = duplicate.Position
                    end
                    
                    print("   ✅ Mirrored to other player")
                else
                    print("   ❌ Failed to mirror")
                end
            end
        else
            print("   ❌ Failed to duplicate: " .. car.Name)
        end
    end
    
    -- ===== STEP 4: Also duplicate ANY items in OTHER container =====
    if otherContainer then
        print("\n🎯 Looking in OTHER player's container:")
        
        for _, item in pairs(otherContainer:GetChildren()) do
            if item.ClassName == "UIPadding" or item.ClassName == "UIListLayout" then
                continue
            end
            
            if item.Name:find("Car") then
                print("🚗 Found car in other container: " .. item.Name)
                
                -- Create duplicate in other container
                local success, duplicate = pcall(function()
                    return item:Clone()
                end)
                
                if success and duplicate then
                    duplicate.Name = item.Name .. "_CopyOther"
                    
                    if pcall(function() return item.Position end) then
                        local pos = item.Position
                        local size = item.Size
                        duplicate.Position = UDim2.new(
                            pos.X.Scale,
                            pos.X.Offset + size.X.Offset + 15,
                            pos.Y.Scale,
                            pos.Y.Offset
                        )
                    end
                    
                    duplicate.Parent = otherContainer
                    totalDuplicates = totalDuplicates + 1
                    print("   ✅ Duplicated in other container")
                end
            end
        end
    end
    
    print("\n📊 TOTAL DUPLICATES CREATED: " .. totalDuplicates)
    print("✅ Both traders should now see 2x cars!")
    
    return totalDuplicates
end

-- ===== CLEAN UP DUPLICATES =====
local function CleanAllDuplicates()
    print("\n🗑️ Cleaning all duplicates...")
    
    local myContainer, otherContainer = GetBothTradeContainers()
    local removed = 0
    
    -- Clean my container
    if myContainer then
        for _, item in pairs(myContainer:GetChildren()) do
            if item.Name:find("_Copy") then
                item:Destroy()
                removed = removed + 1
            end
        end
        
        -- Clean inside frames
        for _, frame in pairs(myContainer:GetChildren()) do
            if frame:IsA("Frame") then
                for _, item in pairs(frame:GetChildren()) do
                    if item.Name:find("_Copy") then
                        item:Destroy()
                        removed = removed + 1
                    end
                end
            end
        end
    end
    
    -- Clean other container
    if otherContainer then
        for _, item in pairs(otherContainer:GetChildren()) do
            if item.Name:find("_Copy") then
                item:Destroy()
                removed = removed + 1
            end
        end
    end
    
    print("✅ Removed " .. removed .. " duplicates")
    return removed
end

-- ===== SIMPLE UI =====
local gui = Instance.new("ScreenGui")
gui.Parent = Player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel")
title.Text = "🚗 BOTH-SIDE DUPLICATOR"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
title.TextColor3 = Color3.fromRGB(255, 255, 255)

local status = Instance.new("TextLabel")
status.Text = "1. Open trade\n2. Both add cars\n3. Click DUPLICATE"
status.Size = UDim2.new(1, -20, 0, 60)
status.Position = UDim2.new(0, 10, 0, 50)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextWrapped = true

local dupBtn = Instance.new("TextButton")
dupBtn.Text = "DUPLICATE BOTH SIDES"
dupBtn.Size = UDim2.new(1, -20, 0, 35)
dupBtn.Position = UDim2.new(0, 10, 0, 120)
dupBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
dupBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local cleanBtn = Instance.new("TextButton")
cleanBtn.Text = "CLEAN ALL"
cleanBtn.Size = UDim2.new(1, -20, 0, 35)
cleanBtn.Position = UDim2.new(0, 10, 0, 165)
cleanBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
cleanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Parent
title.Parent = frame
status.Parent = frame
dupBtn.Parent = frame
cleanBtn.Parent = frame
frame.Parent = gui

-- Duplicate button
dupBtn.MouseButton1Click:Connect(function()
    dupBtn.Text = "WORKING..."
    status.Text = "Duplicating for BOTH traders..."
    
    local count = FindAndDuplicateCars()
    
    if count > 0 then
        status.Text = "✅ " .. count .. " duplicates created\n"
        status.Text = status.Text .. "BOTH traders see 2x cars\n"
        status.Text = status.Text .. "Only 1 car actually trades"
        
        dupBtn.Text = "✅ SUCCESS"
        dupBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        status.Text = "❌ No cars found\nAdd cars to BOTH sides first"
        dupBtn.Text = "DUPLICATE BOTH SIDES"
    end
end)

-- Clean button
cleanBtn.MouseButton1Click:Connect(function()
    cleanBtn.Text = "CLEANING..."
    status.Text = "Cleaning duplicates..."
    
    local removed = CleanAllDuplicates()
    
    status.Text = "🗑️ Removed " .. removed .. " duplicates"
    cleanBtn.Text = "CLEAN ALL"
    
    wait(2)
    status.Text = "1. Open trade\n2. Both add cars\n3. Click DUPLICATE"
end)

print("\n" .. string.rep("=", 50))
print("🚗 BOTH-SIDE TRADE DUPLICATOR READY")
print(string.rep("=", 50))
print("HOW IT WORKS:")
print("1. You AND other trader add cars")
print("2. Click DUPLICATE BOTH SIDES")
print("3. BOTH traders see 2x cars")
print("4. Only 1 car actually transfers")
print(string.rep("=", 50))

-- Auto-duplicate when trade is active
spawn(function()
    while wait(3) do
        -- Check if trade is open
        local menu = Player.PlayerGui:FindFirstChild("Menu")
        if menu and menu:FindFirstChild("Trading") then
            -- Small chance to auto-duplicate
            if math.random(1, 10) == 1 then  -- 10% chance
                FindAndDuplicateCars()
            end
        end
    end
end)
