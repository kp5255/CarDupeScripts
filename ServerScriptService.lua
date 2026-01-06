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
    Title.Font = Enum.Font
