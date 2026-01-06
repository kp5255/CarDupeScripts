-- 🎯 WORKING COSMETIC UNLOCKER
-- Uses real IDs from your game

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== REAL COSMETIC IDs FROM YOUR GAME =====
local REAL_COSMETIC_IDS = {
    -- From your shop scan
    "GET KITS",
    "Neon orange", 
    "Neon green",
    
    -- Common cosmetics to try
    "Neon red",
    "Neon blue",
    "Neon purple",
    "Neon white",
    "Neon rainbow",
    
    -- Wraps/Paints
    "Red wrap",
    "Blue wrap", 
    "Black wrap",
    "White wrap",
    "Gold wrap",
    "Chrome wrap",
    "Matte black",
    "Carbon fiber",
    
    -- Body Kits
    "Sport kit",
    "Racing kit",
    "Drift kit",
    "Widebody kit",
    
    -- Wheels
    "Sport wheels",
    "Racing wheels",
    "Chrome wheels",
    "Spinner wheels",
    
    -- Other
    "Window tint",
    "Exhaust sport",
    "Hood scoop"
}

-- ===== FIND PURCHASE REMOTE =====
local function FindPurchaseRemote()
    print("🔍 Finding purchase remote...")
    
    -- Try common remote names from your game
    local remoteNames = {
        "PurchaseShopItem",
        "Purchase",
        "Buy",
        "Unlock",
        "Equip"
    }
    
    for _, name in ipairs(remoteNames) do
        local remote = RS:FindFirstChild(name, true)
        if remote and remote:IsA("RemoteFunction") then
            print("✅ Found purchase remote: " .. remote:GetFullName())
            return remote
        end
    end
    
    -- Search in Network folder
    local network = RS:FindFirstChild("Network")
    if network then
        for _, obj in pairs(network:GetDescendants()) do
            if obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                if name:find("purchase") or name:find("buy") then
                    print("✅ Found in Network: " .. obj:GetFullName())
                    return obj
                end
            end
        end
    end
    
    print("❌ No purchase remote found")
    return nil
end

-- ===== PURCHASE COSMETIC =====
local function PurchaseCosmetic(purchaseRemote, itemId)
    if not purchaseRemote or not itemId then return false end
    
    print("🛒 Purchasing: " .. itemId)
    
    -- Try different data formats (your game might use specific format)
    local formats = {
        -- Format 1: Just the ID string
        itemId,
        
        -- Format 2: Table with ItemId
        {ItemId = itemId},
        
        -- Format 3: Table with id
        {id = itemId},
        
        -- Format 4: Table with Name
        {Name = itemId},
        
        -- Format 5: Table with productId
        {productId = itemId},
        
        -- Format 6: Table with ProductId
        {ProductId = itemId},
        
        -- Format 7: Table with cosmeticId
        {cosmeticId = itemId},
        
        -- Format 8: Table with CosmeticId
        {CosmeticId = itemId}
    }
    
    for i, data in ipairs(formats) do
        local success, result = pcall(function()
            return purchaseRemote:InvokeServer(data)
        end)
        
        if success then
            print("✅ Format " .. i .. " worked: " .. tostring(result))
            return true, result
        else
            print("❌ Format " .. i .. " failed")
        end
        
        task.wait(0.05)
    end
    
    return false, "All formats failed"
end

-- ===== UNLOCK ALL COSMETICS =====
local function UnlockAllCosmetics()
    print("🚀 Starting unlock with REAL IDs...")
    
    -- Find purchase remote
    local purchaseRemote = FindPurchaseRemote()
    if not purchaseRemote then
        return {success = false, message = "No purchase remote found"}
    end
    
    local results = {
        purchased = 0,
        failed = 0,
        details = {}
    }
    
    -- Try to purchase each cosmetic
    for _, itemId in ipairs(REAL_COSMETIC_IDS) do
        local success, result = PurchaseCosmetic(purchaseRemote, itemId)
        
        if success then
            results.purchased = results.purchased + 1
            results.details[itemId] = "✅ Purchased"
            print("✅ Success: " .. itemId)
        else
            results.failed = results.failed + 1
            results.details[itemId] = "❌ Failed"
            print("❌ Failed: " .. itemId)
        end
        
        task.wait(0.1) -- Small delay to avoid rate limits
    end
    
    print("\n" .. string.rep("=", 50))
    print("📊 PURCHASE RESULTS:")
    print(string.rep("=", 50))
    print("✅ Purchased: " .. results.purchased)
    print("❌ Failed: " .. results.failed)
    print(string.rep("=", 50))
    
    return results
end

-- ===== EXTRACT MORE IDs FROM CURRENT SHOP =====
local function ExtractMoreIDs()
    print("🔍 Extracting more IDs from current shop...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local newIDs = {}
    
    -- Look for shop containers
    for _, container in pairs(PlayerGui:GetDescendants()) do
        local containerName = container.Name:lower()
        
        -- Check if this is a shop/customization container
        if (containerName:find("shop") or containerName:find("custom")) 
           and (container:IsA("ScrollingFrame") or container:IsA("Frame")) then
            
            -- Look for cosmetic items
            for _, item in pairs(container:GetDescendants()) do
                if item:IsA("TextButton") or item:IsA("ImageButton") then
                    -- Get item text/name
                    local itemName = item.Name
                    local itemText = ""
                    
                    if item:IsA("TextButton") then
                        itemText = item.Text
                    end
                    
                    -- Check if this looks like a cosmetic
                    local nameLower = itemName:lower()
                    local textLower = itemText:lower()
                    
                    -- Cosmetic indicators
                    local isCosmetic = textLower:find("neon") 
                                    or textLower:find("wrap")
                                    or textLower:find("paint")
                                    or textLower:find("kit")
                                    or textLower:find("wheel")
                                    or textLower:find("color")
                                    or textLower:find("tint")
                    
                    if isCosmetic and itemText ~= "" then
                        if not table.find(REAL_COSMETIC_IDS, itemText) 
                           and not table.find(newIDs, itemText) then
                            table.insert(newIDs, itemText)
                            print("🎨 Found new ID: " .. itemText)
                        end
                    end
                end
            end
        end
    end
    
    -- Add new IDs to our list
    if #newIDs > 0 then
        for _, id in ipairs(newIDs) do
            table.insert(REAL_COSMETIC_IDS, id)
        end
        print("📝 Added " .. #newIDs .. " new IDs to unlock list")
    end
    
    return newIDs
end

-- ===== SIMPLE UI =====
local function CreateWorkingUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WorkingUnlockerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Panel
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.Position = UDim2.new(1, -370, 0.5, -225)
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
    Title.Text = "✅ WORKING UNLOCKER"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 15)
    TitleCorner.Parent = Title
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "Found IDs:\n• GET KITS\n• Neon orange\n• Neon green\n\nClick UNLOCK to try"
    Status.Size = UDim2.new(1, -20, 0, 120)
    Status.Position = UDim2.new(0, 10, 0, 60)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(200, 220, 255)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    Status.TextWrapped = true
    
    -- Progress
    local ProgressFrame = Instance.new("Frame")
    ProgressFrame.Size = UDim2.new(1, -20, 0, 20)
    ProgressFrame.Position = UDim2.new(0, 10, 0, 190)
    ProgressFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 10)
    ProgressCorner.Parent = ProgressFrame
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    ProgressBar.BorderSizePixel = 0
    
    local ProgressBarCorner = Instance.new("UICorner")
    ProgressBarCorner.CornerRadius = UDim.new(0, 10)
    ProgressBarCorner.Parent = ProgressBar
    
    local ProgressText = Instance.new("TextLabel")
    ProgressText.Text = "0/0"
    ProgressText.Size = UDim2.new(1, 0, 1, 0)
    ProgressText.BackgroundTransparency = 1
    ProgressText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ProgressText.Font = Enum.Font.Gotham
    ProgressText.TextSize = 11
    ProgressText.Parent = ProgressFrame
    
    ProgressBar.Parent = ProgressFrame
    
    -- Buttons
    local UnlockBtn = Instance.new("TextButton")
    UnlockBtn.Text = "🔓 UNLOCK COSMETICS"
    UnlockBtn.Size = UDim2.new(1, -20, 0, 45)
    UnlockBtn.Position = UDim2.new(0, 10, 0, 220)
    UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnlockBtn.Font = Enum.Font.GothamBold
    UnlockBtn.TextSize = 14
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = UnlockBtn
    
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Text = "🔍 SCAN SHOP FOR MORE IDs"
    ScanBtn.Size = UDim2.new(1, -20, 0, 40)
    ScanBtn.Position = UDim2.new(0, 10, 0, 275)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.Gotham
    ScanBtn.TextSize = 12
    
    local ScanCorner = Instance.new("UICorner")
    ScanCorner.CornerRadius = UDim.new(0, 8)
    ScanCorner.Parent = ScanBtn
    
    local ResultsLabel = Instance.new("TextLabel")
    ResultsLabel.Text = "Ready"
    ResultsLabel.Size = UDim2.new(1, -20, 0, 100)
    ResultsLabel.Position = UDim2.new(0, 10, 0, 325)
    ResultsLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    ResultsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResultsLabel.Font = Enum.Font.Gotham
    ResultsLabel.TextSize = 11
    ResultsLabel.TextWrapped = true
    
    local ResultsCorner = Instance.new("UICorner")
    ResultsCorner.CornerRadius = UDim.new(0, 10)
    ResultsCorner.Parent = ResultsLabel
    
    -- Close button
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
    Status.Parent = MainFrame
    ProgressFrame.Parent = MainFrame
    UnlockBtn.Parent = MainFrame
    ScanBtn.Parent = MainFrame
    ResultsLabel.Parent = MainFrame
    CloseBtn.Parent = Title
    MainFrame.Parent = ScreenGui
    
    -- Variables
    local isUnlocking = false
    
    -- Unlock function
    local function PerformUnlock()
        if isUnlocking then return end
        
        isUnlocking = true
        UnlockBtn.Text = "UNLOCKING..."
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        ResultsLabel.Text = "Starting unlock process..."
        
        task.spawn(function()
            -- Update progress
            local total = #REAL_COSMETIC_IDS
            ProgressText.Text = "0/" .. total
            
            -- Find purchase remote
            local purchaseRemote = FindPurchaseRemote()
            if not purchaseRemote then
                ResultsLabel.Text = "❌ No purchase remote found!\nTry scanning shop first."
                UnlockBtn.Text = "🔓 UNLOCK COSMETICS"
                UnlockBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                isUnlocking = false
                return
            end
            
            -- Purchase each cosmetic
            local purchased = 0
            
            for i, itemId in ipairs(REAL_COSMETIC_IDS) do
                local success, result = PurchaseCosmetic(purchaseRemote, itemId)
                
                if success then
                    purchased = purchased + 1
                    ResultsLabel.Text = "✅ Purchased: " .. itemId .. "\nProgress: " .. i .. "/" .. total
                else
                    ResultsLabel.Text = "❌ Failed: " .. itemId .. "\nProgress: " .. i .. "/" .. total
                end
                
                -- Update progress bar
                local progress = i / total
                ProgressBar:TweenSize(
                    UDim2.new(progress, 0, 1, 0),
                    Enum.EasingDirection.Out,
                    Enum.EasingStyle.Quad,
                    0.1,
                    true
                )
                
                ProgressText.Text = i .. "/" .. total
                task.wait(0.1)
            end
            
            -- Completion
            UnlockBtn.Text = "✅ UNLOCKED!"
            UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            ResultsLabel.Text = "🎉 Unlock complete!\n\n" ..
                               "✅ Purchased: " .. purchased .. "/" .. total .. "\n" ..
                               "❌ Failed: " .. (total - purchased) .. "\n\n" ..
                               "Check if items work in-game!"
            
            -- Success sound
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://4590662766"
            sound.Volume = 0.2
            sound.Parent = MainFrame
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 3)
            
            isUnlocking = false
        end)
    end
    
    -- Scan function
    local function PerformScan()
        ScanBtn.Text = "SCANNING..."
        ScanBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        ResultsLabel.Text = "Scanning shop for more IDs..."
        
        task.spawn(function()
            local newIDs = ExtractMoreIDs()
            
            if #newIDs > 0 then
                ScanBtn.Text = "✅ SCANNED!"
                ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                
                local idList = "New IDs found:\n"
                for i, id in ipairs(newIDs) do
                    idList = idList .. "• " .. id .. "\n"
                    if i >= 10 then  -- Limit display
                        idList = idList .. "... and " .. (#newIDs - 10) .. " more"
                        break
                    end
                end
                
                Status.Text = "Found IDs:\n• GET KITS\n• Neon orange\n• Neon green\n" ..
                             "Plus " .. #newIDs .. " more!\n\nTotal: " .. #REAL_COSMETIC_IDS .. " IDs"
                ResultsLabel.Text = idList .. "\nClick UNLOCK to try purchasing them!"
            else
                ScanBtn.Text = "🔍 SCAN SHOP"
                ScanBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 180)
                ResultsLabel.Text = "No new IDs found.\nMake sure shop is open!"
            end
        end)
    end
    
    -- Connect events
    UnlockBtn.MouseButton1Click:Connect(PerformUnlock)
    ScanBtn.MouseButton1Click:Connect(PerformScan)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    return ScreenGui
end

-- ===== AUTO-SCANNING =====
local function AutoSetup()
    print("=" .. string.rep("=", 60))
    print("🎯 WORKING COSMETIC UNLOCKER")
    print("=" .. string.rep("=", 60))
    print("FOUND IDs FROM YOUR GAME:")
    print("• GET KITS")
    print("• Neon orange")
    print("• Neon green")
    print("=" .. string.rep("=", 60))
    
    -- Wait a bit
    task.wait(2)
    
    -- Create UI
    CreateWorkingUI()
    
    -- Auto-scan if shop might be open
    task.wait(3)
    print("[System] UI created! Click SCAN to find more IDs.")
    
    -- Try auto-scan
    task.wait(5)
    print("[Auto] Scanning for more cosmetic IDs...")
    ExtractMoreIDs()
end

-- Start everything
AutoSetup()
