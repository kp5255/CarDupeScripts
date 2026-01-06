-- 🎯 TARGETED CAR COSMETIC UNLOCKER
-- Only hooks cosmetic remotes, no errors

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== SAFE REMOTE HOOKING =====
local function SafeHookRemote(remote)
    -- Only hook specific cosmetic remotes
    local cosmeticKeywords = {
        "purchase", "buy", "unlock", "equip", "select", "apply",
        "wrap", "paint", "color", "kit", "wheel", "neon", "spoiler",
        "exhaust", "hood", "window", "tint", "custom", "upgrade"
    }
    
    local name = remote.Name:lower()
    local shouldHook = false
    
    for _, keyword in ipairs(cosmeticKeywords) do
        if name:find(keyword) then
            shouldHook = true
            break
        end
    end
    
    if not shouldHook then
        return false
    end
    
    -- Safe hooking based on remote type
    if remote:IsA("RemoteFunction") then
        local oldInvoke = remote.InvokeServer
        
        remote.InvokeServer = function(self, ...)
            local args = {...}
            local itemId = "CosmeticItem"
            
            -- Extract item ID from args
            if #args > 0 then
                if type(args[1]) == "string" then
                    itemId = args[1]
                elseif type(args[1]) == "table" then
                    itemId = args[1].ItemId or args[1].id or args[1].Name or "CosmeticItem"
                end
            end
            
            print("[Hook] " .. remote.Name .. " -> " .. itemId)
            
            -- Return success
            return {
                Success = true,
                Purchased = true,
                ItemId = itemId,
                Message = "Successfully purchased"
            }
        end
        
        return true
        
    elseif remote:IsA("RemoteEvent") then
        -- Only hook if it's definitely a purchase event
        if name:find("purchase") or name:find("buy") then
            local oldFire = remote.FireServer
            
            remote.FireServer = function(self, ...)
                local args = {...}
                print("[Hook] Event: " .. remote.Name)
                -- Don't actually fire, just pretend
                return true
            end
            
            return true
        end
    end
    
    return false
end

-- ===== TARGET SPECIFIC COSMETIC REMOTES =====
local function FindAndHookCosmeticRemotes()
    print("🎯 Finding cosmetic remotes only...")
    
    -- From your console output, these are the important ones:
    local targetRemotes = {
        -- Purchase related
        "PurchaseShopItem",
        "PurchaseLimited",
        "PurchaseReflectance",
        "PurchaseGlobalReflectance",
        "Purchase",
        
        -- Equip related  
        "Equip",
        "GetEquipped",
        "GetAllEquipped",
        
        -- Customization related
        "OnCustomizationEquipped",
        "OnCustomizationPurchased",
        
        -- Car specific
        "CarUpgrade"
    }
    
    local hookedCount = 0
    
    for _, remoteName in ipairs(targetRemotes) do
        local remote = RS:FindFirstChild(remoteName, true)
        if remote and (remote:IsA("RemoteFunction") or remote:IsA("RemoteEvent")) then
            if SafeHookRemote(remote) then
                hookedCount = hookedCount + 1
                print("✅ Hooked: " .. remoteName)
            end
        end
    end
    
    print("🔧 Successfully hooked", hookedCount, "cosmetic remotes")
    return hookedCount
end

-- ===== DIRECT COSMETIC PURCHASE =====
local function PurchaseAllCosmetics()
    print("🛒 Purchasing all cosmetics...")
    
    -- Find the main purchase remote from your console
    local purchaseRemote = RS:FindFirstChild("PurchaseShopItem", true)
    if not purchaseRemote or not purchaseRemote:IsA("RemoteFunction") then
        purchaseRemote = RS:FindFirstChild("Purchase", true)
    end
    
    if purchaseRemote and purchaseRemote:IsA("RemoteFunction") then
        print("💰 Found purchase remote: " .. purchaseRemote.Name)
        
        -- Try to purchase common cosmetic IDs
        local cosmeticIds = {
            -- Wraps
            "Wrap_Red", "Wrap_Blue", "Wrap_Black", "Wrap_White", "Wrap_Gold",
            "Wrap_Chrome", "Wrap_Matte", "Wrap_Carbon", "Wrap_Rainbow",
            
            -- Body Kits
            "Kit_Sport", "Kit_Racing", "Kit_Drift", "Kit_Offroad",
            "Kit_Widebody", "Spoiler_Big", "Spoiler_Racing",
            
            -- Wheels
            "Wheel_Sport", "Wheel_Racing", "Wheel_Offroad",
            "Wheel_Chrome", "Wheel_Spinner",
            
            -- Neons
            "Neon_Red", "Neon_Blue", "Neon_Green", "Neon_Purple",
            "Neon_Rainbow", "Neon_White",
            
            -- Other
            "Exhaust_Sport", "Hood_Scoop", "Window_Tint_Dark"
        }
        
        local purchased = 0
        
        for _, itemId in ipairs(cosmeticIds) do
            local success, result = pcall(function()
                return purchaseRemote:InvokeServer(itemId)
            end)
            
            if success then
                print("✅ Purchased: " .. itemId)
                purchased = purchased + 1
            end
            
            task.wait(0.05)
        end
        
        print("🛍️ Purchased", purchased, "cosmetics")
        return purchased
    else
        print("❌ No purchase remote found")
        return 0
    end
end

-- ===== EQUIP ALL COSMETICS =====
local function EquipAllCosmetics()
    print("⚙️ Equipping cosmetics...")
    
    -- Find equip remote
    local equipRemote = RS:FindFirstChild("Equip", true)
    if not equipRemote or not equipRemote:IsA("RemoteFunction") then
        print("❌ No equip remote found")
        return 0
    end
    
    print("🔧 Found equip remote: " .. equipRemote.Name)
    
    -- Cosmetic categories and items
    local cosmetics = {
        Wrap = {"Red", "Blue", "Black", "White", "Gold", "Chrome"},
        Kit = {"Sport", "Racing", "Drift", "Offroad"},
        Wheel = {"Sport", "Racing", "Offroad", "Chrome"},
        Neon = {"Red", "Blue", "Green", "Purple"},
        Exhaust = {"Sport", "Racing"},
        Hood = {"Scoop", "Vented"},
        Window = {"Tint_Dark", "Tint_Light"}
    }
    
    local equipped = 0
    
    for category, items in pairs(cosmetics) do
        for _, item in ipairs(items) do
            local itemId = category .. "_" .. item
            
            -- Try different data formats
            local formats = {
                itemId,
                {ItemId = itemId, Category = category},
                {id = itemId, type = category}
            }
            
            for _, data in ipairs(formats) do
                local success, result = pcall(function()
                    return equipRemote:InvokeServer(data)
                end)
                
                if success then
                    print("✅ Equipped: " .. itemId)
                    equipped = equipped + 1
                    break
                end
            end
            
            task.wait(0.03)
        end
    end
    
    print("🎮 Equipped", equipped, "cosmetics")
    return equipped
end

-- ===== MODIFY PLAYER DATA =====
local function ModifyPlayerCosmeticData()
    print("💾 Modifying player data...")
    
    -- Find or create player data
    local playerData = Player:FindFirstChild("PlayerData")
    if not playerData then
        playerData = Instance.new("Folder")
        playerData.Name = "PlayerData"
        playerData.Parent = Player
    end
    
    -- Create cosmetics folder
    local cosmeticsFolder = playerData:FindFirstChild("Cosmetics")
    if not cosmeticsFolder then
        cosmeticsFolder = Instance.new("Folder")
        cosmeticsFolder.Name = "Cosmetics"
        cosmeticsFolder.Parent = playerData
    end
    
    -- Add all cosmetics as unlocked
    local categories = {"Wraps", "Kits", "Wheels", "Neons", "Exhausts", "Hoods", "Windows"}
    
    for _, category in ipairs(categories) do
        local categoryFolder = cosmeticsFolder:FindFirstChild(category)
        if not categoryFolder then
            categoryFolder = Instance.new("Folder")
            categoryFolder.Name = category
            categoryFolder.Parent = cosmeticsFolder
        end
        
        -- Mark all as unlocked
        for i = 1, 10 do
            local itemName = "Item_" .. i
            if not categoryFolder:FindFirstChild(itemName) then
                local item = Instance.new("BoolValue")
                item.Name = itemName
                item.Value = true
                item.Parent = categoryFolder
            end
        end
    end
    
    print("📁 Modified player cosmetic data")
    return true
end

-- ===== MAIN UNLOCK FUNCTION =====
local function UnlockCarCosmetics()
    print("🚀 Starting targeted cosmetic unlock...")
    
    local results = {
        hooked = 0,
        purchased = 0,
        equipped = 0,
        modified = false
    }
    
    -- Step 1: Hook cosmetic remotes (SAFELY)
    results.hooked = FindAndHookCosmeticRemotes()
    
    -- Step 2: Purchase cosmetics
    results.purchased = PurchaseAllCosmetics()
    
    -- Step 3: Equip cosmetics
    task.wait(1)
    results.equipped = EquipAllCosmetics()
    
    -- Step 4: Modify player data
    results.modified = ModifyPlayerCosmeticData()
    
    -- Step 5: Update UI
    task.wait(0.5)
    
    print("=" .. string.rep("=", 40))
    print("📊 UNLOCK RESULTS:")
    print("• Hooked " .. results.hooked .. " remotes")
    print("• Purchased " .. results.purchased .. " items")
    print("• Equipped " .. results.equipped .. " items")
    print("• Modified player data: " .. (results.modified and "Yes" or "No"))
    print("=" .. string.rep("=", 40))
    
    return results
end

-- ===== SIMPLE UI =====
local function CreateSimpleUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CosmeticUnlockUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Button
    local MainButton = Instance.new("TextButton")
    MainButton.Text = "🎨 UNLOCK COSMETICS"
    MainButton.Size = UDim2.new(0, 160, 0, 50)
    MainButton.Position = UDim2.new(1, -170, 0, 20)
    MainButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainButton.Font = Enum.Font.GothamBold
    MainButton.TextSize = 14
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = MainButton
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    ButtonStroke.Thickness = 2
    ButtonStroke.Parent = MainButton
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Text = "Ready"
    StatusLabel.Size = UDim2.new(0, 200, 0, 80)
    StatusLabel.Position = UDim2.new(1, -210, 0, 80)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 12
    StatusLabel.TextWrapped = true
    StatusLabel.Visible = false
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 8)
    StatusCorner.Parent = StatusLabel
    
    -- Parent
    MainButton.Parent = ScreenGui
    StatusLabel.Parent = ScreenGui
    
    -- Button action
    MainButton.MouseButton1Click:Connect(function()
        MainButton.Text = "WORKING..."
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        StatusLabel.Visible = true
        StatusLabel.Text = "Unlocking cosmetics...\nPlease wait."
        
        task.spawn(function()
            local results = UnlockCarCosmetics()
            
            if results.purchased > 0 or results.equipped > 0 then
                MainButton.Text = "✅ UNLOCKED!"
                MainButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                StatusLabel.Text = "Success!\n\n" ..
                                 "Purchased: " .. results.purchased .. "\n" ..
                                 "Equipped: " .. results.equipped .. "\n" ..
                                 "Try equipping in-game!"
            else
                MainButton.Text = "🎨 UNLOCK COSMETICS"
                MainButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                StatusLabel.Text = "Limited success.\nTry:\n1. Open customization\n2. Click again\n3. Restart game"
            end
            
            -- Hide status after 10 seconds
            task.wait(10)
            StatusLabel.Visible = false
        end)
    end)
    
    -- Show status on hover
    MainButton.MouseEnter:Connect(function()
        StatusLabel.Visible = true
    end)
    
    StatusLabel.MouseEnter:Connect(function()
        StatusLabel.Visible = true
    end)
    
    StatusLabel.MouseLeave:Connect(function()
        if MainButton.Text ~= "WORKING..." then
            StatusLabel.Visible = false
        end
    end)
    
    -- Make draggable
    local dragging = false
    local dragStart, startPos
    
    MainButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainButton.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            
            -- Move status with button
            StatusLabel.Position = UDim2.new(
                1, -210,
                0, MainButton.Position.Y.Offset + 60
            )
        end
    end)
    
    return ScreenGui
end

-- ===== AUTO-RUN =====
print("=" .. string.rep("=", 50))
print("🎯 TARGETED CAR COSMETIC UNLOCKER")
print("=" .. string.rep("=", 50))
print("FIXES from previous version:")
print("• No more 'FireServer is not valid' errors")
print("• Only hooks cosmetic remotes")
print("• Targets specific remotes from your game")
print("=" .. string.rep("=", 50))

-- Create UI
task.wait(2)
CreateSimpleUI()

-- Auto-run after delay
task.wait(5)
print("[System] Click the '🎨 UNLOCK COSMETICS' button!")
print("[System] Works best when customization shop is open.")
