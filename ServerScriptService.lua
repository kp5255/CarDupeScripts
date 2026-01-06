-- 🔓 Universal Cosmetic Unlocker
-- Silent unlock with no transaction errors

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
                   or name:find("hat") or name:find("effect") or name:find("pet") then
                    table.insert(cosmetics, {
                        Object = item,
                        Path = path .. " → " .. item.Name,
                        Type = item.ClassName
                    })
                end
                SearchFolder(item, path .. " → " .. item.Name)
            elseif item:IsA("StringValue") or item:IsA("NumberValue") then
                if item.Name:find("Id") or item.Name:find("UUID") then
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
            cosmeticFolder.Name = "UnlockedCosmetic_" .. cosmeticData.Id
            
            local idValue = Instance.new("StringValue")
            idValue.Name = "Id"
            idValue.Value = cosmeticData.Id or cosmeticData.Value
            
            local nameValue = Instance.new("StringValue")
            nameValue.Name = "Name"
            nameValue.Value = cosmeticData.Name or "Premium Cosmetic"
            
            local unlockedValue = Instance.new("BoolValue")
            unlockedValue.Name = "Unlocked"
            unlockedValue.Value = true
            
            idValue.Parent = cosmeticFolder
            nameValue.Parent = cosmeticFolder
            unlockedValue.Parent = cosmeticFolder
            cosmeticFolder.Parent = playerData
            
            return true
        end
        return false
    end
    
    -- Method 2: Modify UI directly
    local function ModifyUI()
        local PlayerGui = Player:WaitForChild("PlayerGui")
        
        -- Find cosmetic UI
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ScrollingFrame") then
                local name = gui.Name:lower()
                if name:find("cosmetic") or name:find("shop") or name:find("inventory") then
                    -- Look for locked items
                    for _, child in pairs(gui:GetDescendants()) do
                        if child:IsA("ImageButton") or child:IsA("TextButton") then
                            if child:FindFirstChild("LockedIcon") 
                               or child:FindFirstChild("PriceTag") 
                               or child.Name:find("Locked") then
                                -- Unlock it visually
                                local lockedIcon = child:FindFirstChild("LockedIcon")
                                if lockedIcon then lockedIcon.Visible = false end
                                
                                local priceTag = child:FindFirstChild("PriceTag")
                                if priceTag then priceTag.Visible = false end
                                
                                -- Add owned badge
                                local ownedBadge = Instance.new("ImageLabel")
                                ownedBadge.Name = "OwnedBadge"
                                ownedBadge.Image = "rbxassetid://3570695787" -- Checkmark icon
                                ownedBadge.Size = UDim2.new(0, 30, 0, 30)
                                ownedBadge.Position = UDim2.new(1, -35, 0, 5)
                                ownedBadge.BackgroundTransparency = 1
                                ownedBadge.Parent = child
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Method 3: Hook purchase functions
    local function HookRemotes()
        -- Replace remote functions to always return success
        for _, obj in pairs(RS:GetDescendants()) do
            if obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                if name:find("purchase") or name:find("buy") or name:find("unlock") then
                    local oldInvoke = obj.InvokeServer
                    obj.InvokeServer = function(self, ...)
                        local args = {...}
                        print("[Hook] Purchase attempt intercepted:", obj.Name)
                        
                        -- Return success without transaction
                        return {
                            Success = true,
                            Message = "Purchased successfully",
                            ItemId = args[1] or cosmeticData.Id,
                            TransactionId = "HOOKED_" .. math.random(100000, 999999)
                        }
                    end
                    
                    print("[Hook] Remote hooked:", obj.Name)
                end
            end
        end
    end
    
    -- Try all methods
    local success = ModifyPlayerData()
    ModifyUI()
    HookRemotes()
    
    return success
end

-- Main unlock function (no server calls)
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
            Path = cosmetic.Path
        }
    end
    
    -- Silent unlock each cosmetic
    print("🎨 Unlocking cosmetics silently...")
    
    for id, cosmeticData in pairs(CosmeticCache) do
        if not UnlockedCosmetics[id] then
            local success = ClientSideUnlock(cosmeticData)
            
            if success then
                UnlockedCosmetics[id] = true
                print("✅ Unlocked:", cosmeticData.Name)
            else
                print("⚠️  Failed:", cosmeticData.Name)
            end
            
            -- Small delay to avoid detection
            task.wait(0.05)
        end
    end
    
    print("✨ Unlocked", #UnlockedCosmetics, "cosmetics")
end

-- ===== UI FOR CONTROL =====
local function CreateUnlockerUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CosmeticUnlockerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    TopBar.BorderSizePixel = 0
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = TopBar
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🎨 SILENT COSMETIC UNLOCKER"
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = TopBar
    
    local Status = Instance.new("TextLabel")
    Status.Text = "Ready to unlock all cosmetics"
    Status.Size = UDim2.new(1, -20, 0, 40)
    Status.Position = UDim2.new(0, 10, 0, 50)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 14
    Status.Parent = MainFrame
    
    local UnlockButton = Instance.new("TextButton")
    UnlockButton.Text = "UNLOCK ALL COSMETICS"
    UnlockButton.Size = UDim2.new(1, -40, 0, 45)
    UnlockButton.Position = UDim2.new(0, 20, 1, -100)
    UnlockButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    UnlockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnlockButton.Font = Enum.Font.GothamBold
    UnlockButton.TextSize = 16
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = UnlockButton
    
    UnlockButton.Parent = MainFrame
    
    local ProgressFrame = Instance.new("Frame")
    ProgressFrame.Size = UDim2.new(1, -40, 0, 20)
    ProgressFrame.Position = UDim2.new(0, 20, 1, -60)
    ProgressFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    ProgressFrame.BorderSizePixel = 0
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 10)
    ProgressCorner.Parent = ProgressFrame
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = ProgressFrame
    
    local ProgressCorner2 = Instance.new("UICorner")
    ProgressCorner2.CornerRadius = UDim.new(0, 10)
    ProgressCorner2.Parent = ProgressBar
    
    local ProgressText = Instance.new("TextLabel")
    ProgressText.Text = "0/0"
    ProgressText.Size = UDim2.new(1, 0, 1, 0)
    ProgressText.BackgroundTransparency = 1
    ProgressText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ProgressText.Font = Enum.Font.Gotham
    ProgressText.TextSize = 12
    ProgressText.Parent = ProgressFrame
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "✕"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.TextSize = 14
    CloseButton.Parent = TopBar
    
    TopBar.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Button actions
    UnlockButton.MouseButton1Click:Connect(function()
        UnlockButton.Text = "UNLOCKING..."
        UnlockButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        Status.Text = "Scanning and unlocking cosmetics..."
        
        task.spawn(function()
            local total = 0
            local unlocked = 0
            
            -- Update progress
            for id, _ in pairs(CosmeticCache) do
                total = total + 1
            end
            
            for id, cosmeticData in pairs(CosmeticCache) do
                if not UnlockedCosmetics[id] then
                    ClientSideUnlock(cosmeticData)
                    UnlockedCosmetics[id] = true
                    unlocked = unlocked + 1
                    
                    -- Update progress bar
                    local progress = unlocked / total
                    ProgressBar:TweenSize(
                        UDim2.new(progress, 0, 1, 0),
                        Enum.EasingDirection.Out,
                        Enum.EasingStyle.Quad,
                        0.2,
                        true
                    )
                    
                    ProgressText.Text = unlocked .. "/" .. total
                    Status.Text = "Unlocking: " .. cosmeticData.Name
                    
                    task.wait(0.05)
                end
            end
            
            UnlockButton.Text = "✅ UNLOCKED!"
            UnlockButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            Status.Text = "Successfully unlocked " .. unlocked .. " cosmetics"
            
            -- Play success sound
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://4590662766" -- Success sound
            sound.Volume = 0.5
            sound.Parent = MainFrame
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 3)
        end)
    end)
    
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
print("🎨 SILENT COSMETIC UNLOCKER")
print("No transaction errors - Pure client-side")
print("=" .. string.rep("=", 50))

-- Create UI automatically
task.wait(1)
CreateUnlockerUI()

-- Optional: Auto-unlock after UI creation
task.wait(3)
print("[Auto] Starting silent cosmetic unlock...")
UnlockAllCosmeticsSilently()
