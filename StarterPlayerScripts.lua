-- 🎯 TEMPORARY VISUAL UNLOCKER
-- Makes cosmetics appear unlocked for all players (client-side only)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(3)

print("🎨 TEMPORARY VISUAL UNLOCKER LOADED")

-- ===== VISUAL MODIFICATION SYSTEM =====
local function ApplyVisualUnlocks()
    print("🎨 Applying visual unlocks...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local modifications = 0
    
    -- 1. Modify ALL cosmetic buttons to look unlocked
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            -- Check if this is a cosmetic button
            local name = gui.Name:lower()
            local text = gui:IsA("TextButton") and gui.Text:lower() or ""
            
            local isCosmetic = name:find("wrap") or name:find("kit") 
                             or name:find("wheel") or name:find("neon")
                             or name:find("paint") or name:find("color")
                             or text:find("wrap") or text:find("kit")
                             or text:find("wheel") or text:find("neon")
                             or text:find("buy") or text:find("purchase")
            
            if isCosmetic then
                -- Make it look unlocked
                if gui:IsA("TextButton") then
                    if gui.Text:find("Buy") or gui.Text:find("Purchase") 
                       or gui.Text:find("$") or gui.Text:find("Locked") then
                        gui.Text = "EQUIP"
                        gui.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
                        modifications = modifications + 1
                    end
                end
                
                -- Make button green
                gui.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                
                -- Remove price labels
                for _, child in pairs(gui:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        local childText = child.Text:lower()
                        if childText:find("$") or childText:find("price")
                           or childText:find("locked") then
                            child.Text = "UNLOCKED"
                            child.TextColor3 = Color3.fromRGB(0, 255, 0)
                            modifications = modifications + 1
                        end
                    end
                    
                    -- Hide lock icons
                    if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                        if child.Name:lower():find("lock") 
                           or tostring(child.Image):lower():find("lock") then
                            child.Visible = false
                            modifications = modifications + 1
                        end
                    end
                end
            end
        end
    end
    
    -- 2. Create a visual effect for ALL cars (makes them look customized)
    for _, car in pairs(workspace:GetDescendants()) do
        if car:FindFirstChild("Body") or car:FindFirstChild("Chassis") then
            -- Apply random cool colors to make it look customized
            local colors = {
                Color3.fromRGB(255, 0, 0),    -- Red
                Color3.fromRGB(0, 255, 0),    -- Green
                Color3.fromRGB(0, 0, 255),    -- Blue
                Color3.fromRGB(255, 255, 0),  -- Yellow
                Color3.fromRGB(255, 0, 255),  -- Magenta
                Color3.fromRGB(0, 255, 255),  -- Cyan
                Color3.fromRGB(255, 128, 0),  -- Orange
            }
            
            local randomColor = colors[math.random(1, #colors)]
            
            -- Apply to all parts
            for _, part in pairs(car:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "Head" then
                    part.BrickColor = BrickColor.new(randomColor)
                    part.Material = Enum.Material.Neon
                    part.Transparency = 0.3
                end
            end
        end
    end
    
    print("✅ Applied " .. modifications .. " visual modifications")
    return modifications
end

-- ===== UI HIJACK SYSTEM =====
local function HijackShopUI()
    print("💻 Hijacking shop UI...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Hook into any purchase function to make it always succeed (visually)
    local function hijackPurchaseCalls()
        -- This makes any purchase attempt appear successful
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Check if this is a purchase call
            if method == "InvokeServer" or method == "FireServer" then
                local remoteName = tostring(self):lower()
                if remoteName:find("purchase") or remoteName:find("buy") 
                   or remoteName:find("unlock") then
                    
                    print("🎯 Intercepted purchase call: " .. remoteName)
                    print("📦 Args: " .. tostring(args[1]))
                    
                    -- Return fake success
                    return {
                        Success = true,
                        Message = "Item purchased successfully!",
                        ItemId = args[1] or "Unknown"
                    }
                end
            end
            
            return oldNamecall(self, ...)
        end)
        
        print("✅ Purchase calls hijacked")
    end
    
    -- Try to hijack (might not work in all games)
    pcall(hijackPurchaseCalls)
end

-- ===== ALL PLAYER VISUAL EFFECT =====
local function ApplyEffectsToAllPlayers()
    print("👥 Applying effects to all players...")
    
    -- Make all player cars look customized
    local function customizePlayerCar(player)
        if player.Character then
            -- Look for car in player's inventory/workspace
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and (obj:FindFirstChild("DriveSeat") 
                   or obj:FindFirstChild("VehicleSeat")) then
                    
                    -- Check if this car belongs to the player
                    local owner = obj:FindFirstChild("Owner") 
                    if owner and owner.Value == player then
                        -- Apply cool visual effects
                        local rainbow = Instance.new("Texture")
                        rainbow.Name = "RainbowWrap"
                        rainbow.Texture = "rbxassetid://2781219493" -- Rainbow texture
                        rainbow.StudsPerTileU = 2
                        rainbow.StudsPerTileV = 2
                        
                        for _, part in pairs(obj:GetDescendants()) do
                            if part:IsA("BasePart") then
                                -- Apply rainbow texture
                                local texture = rainbow:Clone()
                                texture.Parent = part
                                
                                -- Add neon glow
                                part.Material = Enum.Material.Neon
                                part.Transparency = 0.2
                                
                                -- Add sparkling particles
                                local sparkles = Instance.new("ParticleEmitter")
                                sparkles.Texture = "rbxassetid://242019912"
                                sparkles.Rate = 50
                                sparkles.Lifetime = NumberRange.new(1, 2)
                                sparkles.Size = NumberSequence.new(0.1, 0.5)
                                sparkles.Transparency = NumberSequence.new(0, 1)
                                sparkles.Parent = part
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Apply to all players
    for _, player in pairs(Players:GetPlayers()) do
        customizePlayerCar(player)
    end
    
    -- Apply to new players
    Players.PlayerAdded:Connect(customizePlayerCar)
end

-- ===== MAIN UI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VisualUnlockerUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)

local Title = Instance.new("TextLabel")
Title.Text = "🌈 VISUAL UNLOCKER"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold

local Status = Instance.new("TextLabel")
Status.Text = "Ready to apply visual unlocks!\n"
Status.Size = UDim2.new(1, -20, 0, 150)
Status.Position = UDim2.new(0, 10, 0, 60)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextWrapped = true

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Text = "🌈 APPLY VISUAL UNLOCKS"
UnlockBtn.Size = UDim2.new(1, -20, 0, 40)
UnlockBtn.Position = UDim2.new(0, 10, 0, 220)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnlockBtn.Font = Enum.Font.GothamBold

local AllPlayersBtn = Instance.new("TextButton")
AllPlayersBtn.Text = "👥 ALL PLAYERS EFFECT"
AllPlayersBtn.Size = UDim2.new(1, -20, 0, 40)
AllPlayersBtn.Position = UDim2.new(0, 10, 0, 270)
AllPlayersBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 200)
AllPlayersBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AllPlayersBtn.Font = Enum.Font.GothamBold

-- Add corners
local function addCorner(obj)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = obj
end

addCorner(MainFrame)
addCorner(Title)
addCorner(UnlockBtn)
addCorner(AllPlayersBtn)

-- Parent
Title.Parent = MainFrame
Status.Parent = MainFrame
UnlockBtn.Parent = MainFrame
AllPlayersBtn.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- Update status
local function updateStatus(text)
    Status.Text = Status.Text .. text .. "\n"
end

-- Connect buttons
UnlockBtn.MouseButton1Click:Connect(function()
    UnlockBtn.Text = "APPLYING..."
    
    updateStatus("\n🎨 Applying shop unlocks...")
    local shopMods = ApplyVisualUnlocks()
    updateStatus("✅ Modified " .. shopMods .. " shop elements")
    
    updateStatus("💻 Hijacking purchase system...")
    HijackShopUI()
    
    UnlockBtn.Text = "✅ APPLIED!"
    task.wait(2)
    UnlockBtn.Text = "🌈 APPLY VISUAL UNLOCKS"
end)

AllPlayersBtn.MouseButton1Click:Connect(function()
    AllPlayersBtn.Text = "APPLYING..."
    
    updateStatus("\n👥 Applying effects to all players...")
    ApplyEffectsToAllPlayers()
    updateStatus("✅ All player cars now look customized!")
    
    AllPlayersBtn.Text = "✅ APPLIED!"
    task.wait(2)
    AllPlayersBtn.Text = "👥 ALL PLAYERS EFFECT"
end)

-- Initial message
updateStatus("🌈 VISUAL UNLOCKER ACTIVE")
updateStatus("=" .. string.rep("=", 40))
updateStatus("This makes cosmetics APPEAR unlocked")
updateStatus("• Shop buttons show 'EQUIP'")
updateStatus("• Prices show 'UNLOCKED'")
updateStatus("• Lock icons are hidden")
updateStatus("• Cars get cool visual effects")
updateStatus("=" .. string.rep("=", 40))
updateStatus("NOTE: This is CLIENT-SIDE only")
updateStatus("Effects disappear when you rejoin")

-- Auto-apply after 5 seconds
task.wait(5)
updateStatus("\n⏰ Auto-applying in 3 seconds...")
for i = 3, 1, -1 do
    updateStatus(i .. "...")
    task.wait(1)
end

UnlockBtn.Text = "APPLYING..."
updateStatus("\n🎨 Auto-applying visual unlocks...")
ApplyVisualUnlocks()
HijackShopUI()
UnlockBtn.Text = "✅ APPLIED!"
