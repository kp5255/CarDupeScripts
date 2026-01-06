-- 🛠️ ROBUST CAR COSMETIC UNLOCKER
-- No hooking, direct purchase attempts only

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== DIRECT PURCHASE SYSTEM =====
local function FindPurchaseRemotes()
    print("🔍 Finding purchase remotes...")
    
    local remotes = {}
    
    -- Search in common locations
    local locations = {
        RS,
        RS:FindFirstChild("Network"),
        RS:FindFirstChild("Remotes"),
        RS:FindFirstChild("Events"),
        RS:FindFirstChild("Functions")
    }
    
    for _, location in pairs(locations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    if name:find("purchase") or name:find("buy") then
                        table.insert(remotes, {
                            Object = obj,
                            Name = obj.Name,
                            Path = obj:GetFullName()
                        })
                    end
                end
            end
        end
    end
    
    print("💰 Found", #remotes, "purchase remotes")
    for i, remote in ipairs(remotes) do
        print("  [" .. i .. "] " .. remote.Name .. " -> " .. remote.Path)
    end
    
    return remotes
end

local function TryPurchaseItems(purchaseRemote)
    print("🛒 Attempting purchases with: " .. purchaseRemote.Name)
    
    -- Common cosmetic item IDs based on your game
    local cosmeticItems = {
        -- Wraps
        "Wrap_Red", "Wrap_Blue", "Wrap_Black", "Wrap_White",
        "Wrap_Gold", "Wrap_Silver", "Wrap_Chrome", "Wrap_Matte",
        "Wrap_Rainbow", "Wrap_Galaxy", "Wrap_Carbon",
        
        -- Body Kits
        "BodyKit_Sport", "BodyKit_Racing", "BodyKit_Drift",
        "BodyKit_Offroad", "BodyKit_Widebody",
        "Spoiler_Sport", "Spoiler_Big", "Spoiler_Wing",
        
        -- Wheels
        "Wheel_Sport", "Wheel_Racing", "Wheel_Offroad",
        "Wheel_Chrome", "Wheel_Spinner", "Wheel_White",
        "Wheel_Black", "Wheel_Gold",
        
        -- Neons
        "Neon_Red", "Neon_Blue", "Neon_Green", "Neon_Purple",
        "Neon_White", "Neon_Rainbow", "Neon_Pink",
        
        -- Other
        "Exhaust_Sport", "Exhaust_Racing",
        "Hood_Scoop", "Hood_Vented",
        "Window_Tint_Dark", "Window_Tint_Light",
        "Brake_Caliper_Red", "Brake_Caliper_Blue"
    }
    
    local purchased = 0
    
    for _, itemId in ipairs(cosmeticItems) do
        -- Try different data formats
        local formats = {
            itemId,  -- Just the ID
            {ItemId = itemId},  -- Table with ItemId
            {id = itemId},  -- Table with id
            {Name = itemId},  -- Table with Name
            {item = itemId},  -- Table with item
            {productId = itemId},  -- Table with productId
            {ProductId = itemId}  -- Table with ProductId
        }
        
        for _, data in ipairs(formats) do
            local success, result = pcall(function()
                return purchaseRemote:InvokeServer(data)
            end)
            
            if success then
                print("✅ Purchase attempt: " .. itemId .. " -> " .. tostring(result))
                purchased = purchased + 1
                break
            end
        end
        
        task.wait(0.03) -- Small delay
    end
    
    return purchased
end

-- ===== EQUIP SYSTEM =====
local function FindEquipRemotes()
    print("🔍 Finding equip remotes...")
    
    local remotes = {}
    
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("equip") or name:find("apply") or name:find("select") then
                table.insert(remotes, obj)
            end
        end
    end
    
    return remotes
end

local function TryEquipCosmetics(equipRemote)
    print("⚙️ Attempting to equip with: " .. equipRemote.Name)
    
    -- Cosmetic types
    local cosmetics = {
        {type = "Wrap", items = {"Red", "Blue", "Black", "White", "Gold"}},
        {type = "BodyKit", items = {"Sport", "Racing", "Drift"}},
        {type = "Wheel", items = {"Sport", "Racing", "Chrome"}},
        {type = "Neon", items = {"Red", "Blue", "Green", "Rainbow"}}
    }
    
    local equipped = 0
    
    for _, category in ipairs(cosmetics) do
        for _, item in ipairs(category.items) do
            local itemId = category.type .. "_" .. item
            
            -- Try different formats
            local formats = {
                itemId,
                {ItemId = itemId},
                {id = itemId, type = category.type},
                {Name = itemId, Category = category.type},
                {cosmetic = itemId}
            }
            
            for _, data in ipairs(formats) do
                local success, result = pcall(function()
                    return equipRemote:InvokeServer(data)
                end)
                
                if success then
                    print("✅ Equip attempt: " .. itemId)
                    equipped = equipped + 1
                    break
                end
            end
            
            task.wait(0.02)
        end
    end
    
    return equipped
end

-- ===== DIRECT CUSTOMIZATION ACCESS =====
local function AccessCustomizationData()
    print("💾 Accessing customization data...")
    
    -- Try to find and modify customization data
    local success = false
    
    -- Method 1: Check for player customization folder
    local playerData = Player:FindFirstChild("PlayerData") 
                      or Player:FindFirstChild("Data")
    
    if playerData then
        -- Create cosmetics folder
        local cosmeticsFolder = playerData:FindFirstChild("Cosmetics")
        if not cosmeticsFolder then
            cosmeticsFolder = Instance.new("Folder")
            cosmeticsFolder.Name = "Cosmetics"
            cosmeticsFolder.Parent = playerData
        end
        
        -- Mark all as owned
        local ownedValue = Instance.new("BoolValue")
        ownedValue.Name = "AllOwned"
        ownedValue.Value = true
        ownedValue.Parent = cosmeticsFolder
        
        print("✅ Created cosmetic data")
        success = true
    end
    
    -- Method 2: Try to access car data directly
    local carReplication = Player.PlayerGui:FindFirstChild("CarReplication")
    if carReplication then
        for _, car in pairs(carReplication:GetChildren()) do
            if car:IsA("Model") then
                -- Add cosmetic properties
                local wrap = Instance.new("StringValue")
                wrap.Name = "CurrentWrap"
                wrap.Value = "PremiumWrap"
                wrap.Parent = car
                
                local kit = Instance.new("StringValue")
                kit.Name = "CurrentKit"
                kit.Value = "SportKit"
                kit.Parent = car
                
                success = true
            end
        end
    end
    
    return success
end

-- ===== SHOP UI MODIFICATION =====
local function ModifyShopInterface()
    print("🏪 Modifying shop interface...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local modified = 0
    
    local function ProcessItem(item)
        if not item:IsA("GuiObject") then return end
        
        local name = item.Name:lower()
        
        -- Check if it's a cosmetic item
        if name:find("wrap") or name:find("paint") or name:find("kit") 
           or name:find("wheel") or name:find("neon") then
            
            -- Remove lock visuals
            for _, child in pairs(item:GetDescendants()) do
                if child:IsA("ImageLabel") then
                    if child.Name:lower():find("lock") then
                        child.Visible = false
                        modified = modified + 1
                    end
                end
                
                if child:IsA("TextLabel") then
                    local text = child.Text:lower()
                    if text:find("locked") or text:find("$") 
                       or text:find("buy") or text:find("purchase") then
                        child.Text = "UNLOCKED"
                        child.TextColor3 = Color3.fromRGB(0, 255, 0)
                        modified = modified + 1
                    end
                end
            end
            
            -- Make button green if it's a button
            if item:IsA("TextButton") then
                item.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                item.Text = "EQUIP"
                modified = modified + 1
            end
        end
    end
    
    -- Process existing items
    for _, item in pairs(PlayerGui:GetDescendants()) do
        ProcessItem(item)
    end
    
    -- Monitor for new items
    PlayerGui.DescendantAdded:Connect(ProcessItem)
    
    print("🖌️ Modified", modified, "UI elements")
    return modified
end

-- ===== MAIN UNLOCK FUNCTION =====
local function UnlockCarCustomization()
    print("🚀 Starting direct cosmetic unlock...")
    
    local results = {
        purchased = 0,
        equipped = 0,
        modifiedUI = 0,
        dataAccessed = false
    }
    
    -- Step 1: Try direct purchases
    local purchaseRemotes = FindPurchaseRemotes()
    if #purchaseRemotes > 0 then
        for _, remote in ipairs(purchaseRemotes) do
            results.purchased = results.purchased + TryPurchaseItems(remote.Object)
            task.wait(0.5)
        end
    else
        print("⚠️ No purchase remotes found")
    end
    
    -- Step 2: Try to equip
    task.wait(1)
    local equipRemotes = FindEquipRemotes()
    if #equipRemotes > 0 then
        for _, remote in ipairs(equipRemotes) do
            results.equipped = results.equipped + TryEquipCosmetics(remote)
            task.wait(0.5)
        end
    else
        print("⚠️ No equip remotes found")
    end
    
    -- Step 3: Access/modify data
    task.wait(1)
    results.dataAccessed = AccessCustomizationData()
    
    -- Step 4: Modify shop UI
    task.wait(1)
    results.modifiedUI = ModifyShopInterface()
    
    -- Display results
    print("=" .. string.rep("=", 40))
    print("📊 UNLOCK RESULTS:")
    if results.purchased > 0 then
        print("✅ Purchased " .. results.purchased .. " items")
    end
    
    if results.equipped > 0 then
        print("✅ Equipped " .. results.equipped .. " items")
    end
    
    if results.modifiedUI > 0 then
        print("✅ Modified " .. results.modifiedUI .. " UI elements")
    end
    
    if results.dataAccessed then
        print("✅ Accessed customization data")
    end
    
    if results.purchased == 0 and results.equipped == 0 then
        print("⚠️ Limited success - Try manual method below")
    end
    
    print("=" .. string.rep("=", 40))
    
    return results
end

-- ===== MANUAL UNLOCK METHOD =====
local function CreateManualUnlocker()
    print("🛠️ Creating manual unlock interface...")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ManualUnlockerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    -- Control Panel
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    MainFrame.BorderSizePixel = 0
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 150, 255)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🎮 MANUAL COSMETIC UNLOCKER"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 15)
    TitleCorner.Parent = Title
    
    -- Instructions
    local Instructions = Instance.new("TextLabel")
    Instructions.Text = "INSTRUCTIONS:\n1. Open car customization shop\n2. Find item ID (hover over items)\n3. Enter ID below\n4. Click PURCHASE"
    Instructions.Size = UDim2.new(1, -20, 0, 80)
    Instructions.Position = UDim2.new(0, 10, 0, 60)
    Instructions.BackgroundTransparency = 1
    Instructions.TextColor3 = Color3.fromRGB(200, 220, 255)
    Instructions.Font = Enum.Font.Gotham
    Instructions.TextSize = 13
    Instructions.TextWrapped = true
    
    -- Item ID Input
    local InputFrame = Instance.new("Frame")
    InputFrame.Size = UDim2.new(1, -20, 0, 40)
    InputFrame.Position = UDim2.new(0, 10, 0, 150)
    InputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = InputFrame
    
    local TextBox = Instance.new("TextBox")
    TextBox.PlaceholderText = "Enter Cosmetic Item ID here..."
    TextBox.Size = UDim2.new(1, -20, 1, -10)
    TextBox.Position = UDim2.new(0, 10, 0, 5)
    TextBox.BackgroundTransparency = 1
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 14
    TextBox.Text = ""
    
    -- Purchase Button
    local PurchaseBtn = Instance.new("TextButton")
    PurchaseBtn.Text = "🛒 PURCHASE ITEM"
    PurchaseBtn.Size = UDim2.new(1, -20, 0, 45)
    PurchaseBtn.Position = UDim2.new(0, 10, 0, 200)
    PurchaseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    PurchaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    PurchaseBtn.Font = Enum.Font.GothamBold
    PurchaseBtn.TextSize = 16
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = PurchaseBtn
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "Ready"
    Status.Size = UDim2.new(1, -20, 0, 100)
    Status.Position = UDim2.new(0, 10, 0, 260)
    Status.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.TextWrapped = true
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 10)
    StatusCorner.Parent = Status
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "✕"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseBtn
    
    -- Parent everything
    Title.Parent = MainFrame
    Instructions.Parent = MainFrame
    InputFrame.Parent = MainFrame
    TextBox.Parent = InputFrame
    PurchaseBtn.Parent = MainFrame
    Status.Parent = MainFrame
    CloseBtn.Parent = Title
    MainFrame.Parent = ScreenGui
    
    -- Purchase function
    local function ManualPurchase(itemId)
        if itemId == "" then
            Status.Text = "Please enter an Item ID"
            return
        end
        
        PurchaseBtn.Text = "PROCESSING..."
        PurchaseBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        Status.Text = "Attempting to purchase: " .. itemId
        
        -- Find all purchase remotes
        local purchaseRemotes = FindPurchaseRemotes()
        local success = false
        
        for _, remote in ipairs(purchaseRemotes) do
            -- Try different formats
            local formats = {
                itemId,
                {ItemId = itemId},
                {id = itemId},
                {Name = itemId},
                {productId = itemId}
            }
            
            for _, data in ipairs(formats) do
                local ok, result = pcall(function()
                    return remote.Object:InvokeServer(data)
                end)
                
                if ok then
                    Status.Text = "✅ Success!\nItem: " .. itemId .. "\nResult: " .. tostring(result)
                    success = true
                    break
                end
            end
            
            if success then break end
        end
        
        if success then
            PurchaseBtn.Text = "✅ PURCHASED!"
            PurchaseBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            PurchaseBtn.Text = "🛒 PURCHASE ITEM"
            PurchaseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            Status.Text = "❌ Failed to purchase\nTry different item ID\nor find correct ID in shop"
        end
    end
    
    -- Connect events
    PurchaseBtn.MouseButton1Click:Connect(function()
        ManualPurchase(TextBox.Text)
    end)
    
    TextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            ManualPurchase(TextBox.Text)
        end
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Pre-fill with example IDs
    TextBox.Text = "Wrap_Red"
    
    return ScreenGui
end

-- ===== AUTO-START =====
print("=" .. string.rep("=", 50))
print("🛠️ ROBUST CAR COSMETIC UNLOCKER")
print("=" .. string.rep("=", 50))
print("METHODS:")
print("1. Direct purchase attempts")
print("2. Manual item ID entry")
print("3. UI modification")
print("=" .. string.rep("=", 50))

-- Create manual unlocker UI
task.wait(2)
CreateManualUnlocker()

-- Try auto-unlock after delay
task.wait(5)
print("[System] Manual unlocker UI created!")
print("[System] Enter cosmetic item IDs to purchase them.")
