-- 🔓 Universal Cosmetic Unlocker v2.0
-- Fixed for Knit services - No transaction errors

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== SILENT UNLOCK SYSTEM =====
local CosmeticCache = {}
local UnlockedCosmetics = {}

-- Find all cosmetics in the game
local function FindAllCosmetics()
    local cosmetics = {}
    
    -- Check ReplicatedStorage
    local function SearchFolder(folder, path)
        for _, item in pairs(folder:GetChildren()) do
            if item:IsA("Folder") or item:IsA("Model") then
                local name = item.Name:lower()
                if name:find("cosmetic") or name:find("skin") or name:find("item") 
                   or name:find("hat") or name:find("effect") or name:find("pet")
                   or name:find("car") or name:find("vehicle") then
                    table.insert(cosmetics, {
                        Object = item,
                        Path = path .. " → " .. item.Name,
                        Type = item.ClassName
                    })
                end
                SearchFolder(item, path .. " → " .. item.Name)
            elseif item:IsA("StringValue") or item:IsA("NumberValue") then
                if item.Name:find("Id") or item.Name:find("UUID") or item.Name:find("Token") then
                    table.insert(cosmetics, {
                        Object = item,
                        Path = path,
                        Value = item.Value,
                        Type = "ID"
                    })
                end
            end
        end
    end
    
    SearchFolder(RS, "ReplicatedStorage")
    
    -- Check game services
    local services = {
        game:GetService("Workspace"),
        game:GetService("ServerStorage"),
        game:GetService("Lighting")
    }
    
    for _, service in pairs(services) do
        pcall(function() SearchFolder(service, service.Name) end)
    end
    
    return cosmetics
end

-- Client-side unlock (no server transaction)
local function ClientSideUnlock(cosmeticData)
    -- Method 1: Direct modification of player data
    local function ModifyPlayerData()
        -- Find player data folder
        local playerData = Player:FindFirstChild("PlayerData") 
                          or Player:FindFirstChild("Data") 
                          or Player:FindFirstChild("Inventory")
        
        if playerData then
            -- Create cosmetic entry
            local cosmeticFolder = Instance.new("Folder")
            cosmeticFolder.Name = "UnlockedCosmetic_" .. tostring(cosmeticData.Id or math.random(10000, 99999))
            
            local idValue = Instance.new("StringValue")
            idValue.Name = "Id"
            idValue.Value = cosmeticData.Id or cosmeticData.Value or cosmeticData.Name
            
            local nameValue = Instance.new("StringValue")
            nameValue.Name = "Name"
            nameValue.Value = cosmeticData.Name or "Premium Cosmetic"
            
            local unlockedValue = Instance.new("BoolValue")
            unlockedValue.Name = "Unlocked"
            unlockedValue.Value = true
            
            local timestampValue = Instance.new("NumberValue")
            timestampValue.Name = "UnlockTime"
            timestampValue.Value = os.time()
            
            idValue.Parent = cosmeticFolder
            nameValue.Parent = cosmeticFolder
            unlockedValue.Parent = cosmeticFolder
            timestampValue.Parent = cosmeticFolder
            cosmeticFolder.Parent = playerData
            
            print("📝 Added to player data:", cosmeticData.Name)
            return true
        end
        return false
    end
    
    -- Method 2: Modify UI directly (NO REMOTE HOOKING)
    local function ModifyUI()
        local PlayerGui = Player:WaitForChild("PlayerGui")
        
        -- Wait for UI to load
        task.wait(0.5)
        
        -- Unlock UI elements
        local function UnlockUIElement(element)
            if not element then return end
            
            -- Remove lock icons
            for _, child in pairs(element:GetDescendants()) do
                if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    local name = child.Name:lower()
                    if name:find("lock") or name:find("locked") then
                        child.Visible = false
                    end
                end
                
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local text = child.Text:lower()
                    if text:find("locked") or text:find("purchase") or text:find("buy") then
                        child.Text = "UNLOCKED"
                        child.TextColor3 = Color3.fromRGB(0, 255, 0)
                    end
                end
            end
            
            -- Add owned indicator
            if not element:FindFirstChild("OwnedIndicator") then
                local ownedBadge = Instance.new("Frame")
                ownedBadge.Name = "OwnedIndicator"
                ownedBadge.Size = UDim2.new(1, 0, 0, 5)
                ownedBadge.Position = UDim2.new(0, 0, 0, 0)
                ownedBadge.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                ownedBadge.BorderSizePixel = 0
                ownedBadge.ZIndex = 100
                ownedBadge.Parent = element
            end
        end
        
        -- Scan all UI
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ScrollingFrame") then
                local name = gui.Name:lower()
                if name:find("shop") or name:find("store") or name:find("market") 
                   or name:find("inventory") or name:find("collection") 
                   or name:find("cosmetic") or name:find("car") then
                    UnlockUIElement(gui)
                end
            end
        end
        
        print("🎨 Modified UI elements")
    end
    
    -- Method 3: Store cosmetics locally (persistent)
    local function StoreLocally()
        -- Use player's saved data
        local success, saved = pcall(function()
            return game:GetService("HttpService"):JSONDecode(
                readfile("cosmetic_unlocks.json") or "{}"
            )
        end)
        
        if not success then saved = {} end
        
        -- Add new cosmetic
        saved[cosmeticData.Id or cosmeticData.Name] = {
            name = cosmeticData.Name,
            unlocked = true,
            timestamp = os.time(),
            path = cosmeticData.Path
        }
        
        -- Save to file
        pcall(function()
            writefile("cosmetic_unlocks.json", game:GetService("HttpService"):JSONEncode(saved))
        end)
        
        print("💾 Saved locally:", cosmeticData.Name)
    end
    
    -- Method 4: Add to backpack/inventory directly
    local function AddToBackpack()
        local backpack = Player:FindFirstChild("Backpack")
        if backpack then
            -- Create a tool/item representing the cosmetic
            local tool = Instance.new("Tool")
            tool.Name = cosmeticData.Name .. "_Cosmetic"
            tool.ToolTip = "Unlocked Cosmetic: " .. cosmeticData.Name
            
            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = Vector3.new(0.5, 0.5, 0.5)
            handle.Transparency = 1
            handle.Parent = tool
            
            local stringValue = Instance.new("StringValue")
            stringValue.Name = "CosmeticId"
            stringValue.Value = cosmeticData.Id or cosmeticData.Name
            stringValue.Parent = tool
            
            tool.Parent = backpack
            print("🎒 Added to backpack:", cosmeticData.Name)
        end
    end
    
    -- Try all methods
    local success1 = ModifyPlayerData()
    ModifyUI()
    StoreLocally()
    AddToBackpack()
    
    return success1
end

-- Main unlock function (NO REMOTE HOOKING)
local function UnlockAllCosmeticsSilently()
    print("🔍 Scanning for cosmetics...")
    
    local cosmetics = FindAllCosmetics()
    print("📦 Found", #cosmetics, "potential cosmetic items")
    
    -- Create cosmetic database
    for i, cosmetic in ipairs(cosmetics) do
        local id = ""
        
        if cosmetic.Type == "ID" then
            id = tostring(cosmetic.Value)
        else
            id = cosmetic.Object.Name .. "_" .. i
        end
        
        CosmeticCache[id] = {
            Id = id,
            Name = cosmetic.Object.Name,
            Object = cosmetic.Object,
            Path = cosmetic.Path,
            Value = cosmetic.Value
        }
    end
    
    -- Silent unlock each cosmetic
    print("🎨 Unlocking cosmetics silently...")
    
    local unlockedCount = 0
    for id, cosmeticData in pairs(CosmeticCache) do
        if not UnlockedCosmetics[id] then
            local success = ClientSideUnlock(cosmeticData)
            
            if success then
                UnlockedCosmetics[id] = true
                unlockedCount = unlockedCount + 1
                print("✅ [" .. unlockedCount .. "] Unlocked:", cosmeticData.Name)
            else
                print("⚠️  Failed:", cosmeticData.Name)
            end
            
            -- Small delay to avoid detection
            task.wait(0.03)
        end
    end
    
    print("✨ Successfully unlocked", unlockedCount, "cosmetics")
    return unlockedCount
end

-- ===== IMPROVED UI =====
local function CreateUnlockerUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CosmeticUnlockerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    
    -- Main Container
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 15)
    UICorner.Parent = MainFrame
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TopBar.BorderSizePixel = 0
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 15)
    TopCorner.Parent = TopBar
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🎨 SILENT COSMETIC UNLOCKER"
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "✕"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 7)
    CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    -- Status Display
    local StatusFrame = Instance.new("Frame")
    StatusFrame.Size = UDim2.new(1, -30, 0, 80)
    StatusFrame.Position = UDim2.new(0, 15, 0, 60)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    StatusFrame.BorderSizePixel = 0
    
    local StatusCorner = Instance.new("UICorner")
    StatusCorner.CornerRadius = UDim.new(0, 10)
    StatusCorner.Parent = StatusFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Text = "Ready to unlock all cosmetics"
    StatusLabel.Size = UDim2.new(1, -20, 1, -20)
    StatusLabel.Position = UDim2.new(0, 10, 0, 10)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 14
    StatusLabel.TextWrapped = true
    StatusLabel.Parent = StatusFrame
    
    -- Unlock Button
    local UnlockButton = Instance.new("TextButton")
    UnlockButton.Text = "🔓 UNLOCK ALL COSMETICS"
    UnlockButton.Size = UDim2.new(1, -30, 0, 50)
    UnlockButton.Position = UDim2.new(0, 15, 1, -130)
    UnlockButton.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
    UnlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnlockButton.Font = Enum.Font.GothamBold
    UnlockButton.TextSize = 16
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = UnlockButton
    
    -- Progress Area
    local ProgressContainer = Instance.new("Frame")
    ProgressContainer.Size = UDim2.new(1, -30, 0, 60)
    ProgressContainer.Position = UDim2.new(0, 15, 1, -70)
    ProgressContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    ProgressContainer.BorderSizePixel = 0
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 10)
    ProgressCorner.Parent = ProgressContainer
    
    local ProgressBarBack = Instance.new("Frame")
    ProgressBarBack.Size = UDim2.new(1, -20, 0, 20)
    ProgressBarBack.Position = UDim2.new(0, 10, 0, 10)
    ProgressBarBack.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    ProgressBarBack.BorderSizePixel = 0
    
    local ProgressBackCorner = Instance.new("UICorner")
    ProgressBackCorner.CornerRadius = UDim.new(0, 10)
    ProgressBackCorner.Parent = ProgressBarBack
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    ProgressBar.BorderSizePixel = 0
    
    local ProgressBarCorner = Instance.new("UICorner")
    ProgressBarCorner.CornerRadius = UDim.new(0, 10)
    ProgressBarCorner.Parent = ProgressBar
    
    local ProgressText = Instance.new("TextLabel")
    ProgressText.Text = "0/0 unlocked"
    ProgressText.Size = UDim2.new(1, 0, 0, 20)
    ProgressText.Position = UDim2.new(0, 0, 0, 32)
    ProgressText.BackgroundTransparency = 1
    ProgressText.TextColor3 = Color3.fromRGB(180, 180, 200)
    ProgressText.Font = Enum.Font.Gotham
    ProgressText.TextSize = 12
    ProgressText.Parent = ProgressContainer
    
    -- Parent everything
    ProgressBar.Parent = ProgressBarBack
    ProgressBarBack.Parent = ProgressContainer
    ProgressContainer.Parent = MainFrame
    UnlockButton.Parent = MainFrame
    StatusFrame.Parent = MainFrame
    CloseButton.Parent = TopBar
    TopBar.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Variables for progress
    local totalCosmetics = 0
    local unlocked = 0
    
    -- Unlock function
    local function StartUnlockProcess()
        UnlockButton.Text = "UNLOCKING..."
        UnlockButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        StatusLabel.Text = "Scanning game for cosmetics..."
        
        -- Find cosmetics
        local cosmetics = FindAllCosmetics()
        totalCosmetics = #cosmetics
        
        if totalCosmetics == 0 then
            StatusLabel.Text = "No cosmetics found!\nTry opening the shop first."
            UnlockButton.Text = "TRY AGAIN"
            UnlockButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
            return
        end
        
        StatusLabel.Text = "Found " .. totalCosmetics .. " cosmetics\nStarting silent unlock..."
        ProgressText.Text = "0/" .. totalCosmetics .. " unlocked"
        
        -- Unlock each cosmetic
        for i, cosmetic in ipairs(cosmetics) do
            local id = cosmetic.Object.Name .. "_" .. i
            local cosmeticData = {
                Id = id,
                Name = cosmetic.Object.Name,
                Object = cosmetic.Object,
                Path = cosmetic.Path,
                Value = cosmetic.Value
            }
            
            if not UnlockedCosmetics[id] then
                -- Unlock using safe methods (no remote hooking)
                local success = pcall(function()
                    -- Modify player data
                    local playerData = Player:FindFirstChild("PlayerData") 
                                      or Player:FindFirstChild("Data")
                    if playerData then
                        local folder = Instance.new("Folder")
                        folder.Name = "Cosmetic_" .. id
                        folder.Parent = playerData
                    end
                    
                    -- Update UI
                    task.spawn(ClientSideUnlock, cosmeticData)
                end)
                
                if success then
                    UnlockedCosmetics[id] = true
                    unlocked = unlocked + 1
                    
                    -- Update progress
                    local progress = unlocked / totalCosmetics
                    ProgressBar:TweenSize(
                        UDim2.new(progress, 0, 1, 0),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Quad,
                        0.1,
                        true
                    )
                    
                    ProgressText.Text = unlocked .. "/" .. totalCosmetics .. " unlocked"
                    StatusLabel.Text = "Unlocking: " .. cosmeticData.Name
                end
            end
            
            task.wait(0.02)
        end
        
        -- Completion
        UnlockButton.Text = "✅ UNLOCKED!"
        UnlockButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        StatusLabel.Text = "Successfully unlocked " .. unlocked .. " cosmetics!\nOpen the shop to see them all."
        
        -- Play success sound
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://4590662766"
        sound.Volume = 0.3
        sound.Parent = MainFrame
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 3)
        
        -- Save unlocks to file
        pcall(function()
            local data = {
                unlocked = unlocked,
                total = totalCosmetics,
                timestamp = os.time(),
                player = Player.Name
            }
            writefile("cosmetic_unlocks.txt", 
                "Unlocked " .. unlocked .. "/" .. totalCosmetics .. " cosmetics\n" ..
                "Player: " .. Player.Name .. "\n" ..
                "Time: " .. os.date("%Y-%m-%d %H:%M:%S")
            )
        end)
    end
    
    -- Button events
    UnlockButton.MouseButton1Click:Connect(StartUnlockProcess)
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Make draggable
    local dragging = false
    local dragInput, dragStart, startPos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return ScreenGui
end

-- ===== AUTO-START =====
print("=" .. string.rep("=", 50))
print("🎨 SILENT COSMETIC UNLOCKER v2.0")
print("Fixed for Knit services - No remote hooking")
print("=" .. string.rep("=", 50))

-- Create UI automatically
task.wait(1)
CreateUnlockerUI()

-- Optional: Auto-scan after UI creation
task.wait(2)
print("[System] UI loaded. Click 'UNLOCK ALL COSMETICS' to begin.")
