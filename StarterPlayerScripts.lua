-- 🔓 SIMPLE LOCKED VALUE UNLOCKER
-- Just changes "Locked" values from 0 to 1

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🔓 SIMPLE UNLOCKER LOADED")

-- Simple function to unlock everything
local function unlockAllLockedValues()
    print("🔓 Looking for 'Locked' values...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local unlocked = 0
    
    -- Find ALL IntValues, BoolValues, etc. named "Locked"
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        -- Check for values that control locking
        if obj:IsA("IntValue") or obj:IsA("NumberValue") then
            if obj.Name == "Locked" or obj.Name == "locked" or obj.Name:lower():find("lock") then
                print("🔓 Found: " .. obj.Name .. " = " .. tostring(obj.Value))
                
                -- Change 0 to 1 (unlocked)
                if tonumber(obj.Value) == 0 then
                    obj.Value = 1
                    unlocked = unlocked + 1
                    print("✅ Changed from 0 to 1")
                elseif tonumber(obj.Value) > 1 then
                    obj.Value = 1
                    unlocked = unlocked + 1
                    print("✅ Changed from " .. obj.Value .. " to 1")
                end
            end
        elseif obj:IsA("BoolValue") then
            if obj.Name == "Locked" or obj.Name == "locked" or obj.Name:lower():find("lock") then
                print("🔓 Found: " .. obj.Name .. " = " .. tostring(obj.Value))
                
                -- Change false to true (unlocked)
                if obj.Value == false then
                    obj.Value = true
                    unlocked = unlocked + 1
                    print("✅ Changed from false to true")
                end
            end
        elseif obj:IsA("StringValue") then
            if obj.Name == "Locked" or obj.Name == "locked" or obj.Name:lower():find("lock") then
                print("🔓 Found: " .. obj.Name .. " = " .. tostring(obj.Value))
                
                -- Change "locked" to "unlocked"
                if tostring(obj.Value):lower() == "locked" then
                    obj.Value = "unlocked"
                    unlocked = unlocked + 1
                    print("✅ Changed from 'locked' to 'unlocked'")
                end
            end
        end
    end
    
    -- Also change UI text
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("TextButton") then
            if obj.Text:lower():find("buy") or obj.Text:lower():find("purchase") then
                obj.Text = "EQUIP"
                obj.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
                unlocked = unlocked + 1
                print("✅ Changed button to EQUIP")
            end
        elseif obj:IsA("TextLabel") then
            if obj.Text:lower():find("locked") then
                obj.Text = "UNLOCKED"
                obj.TextColor3 = Color3.fromRGB(0, 255, 0)
                unlocked = unlocked + 1
                print("✅ Changed text to UNLOCKED")
            end
        end
    end
    
    print("📊 Total modifications: " .. unlocked)
    return unlocked
end

-- Create simple UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleUnlockerUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 150)
MainFrame.Position = UDim2.new(0.5, -150, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)

local Title = Instance.new("TextLabel")
Title.Text = "🔓 SIMPLE UNLOCKER"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold

local Status = Instance.new("TextLabel")
Status.Text = "Click UNLOCK to change 'Locked' values\nfrom 0 to 1"
Status.Size = UDim2.new(1, -20, 0, 60)
Status.Position = UDim2.new(0, 10, 0, 50)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextWrapped = true

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Text = "🔓 UNLOCK NOW"
UnlockBtn.Size = UDim2.new(1, -20, 0, 40)
UnlockBtn.Position = UDim2.new(0, 10, 0, 120)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnlockBtn.Font = Enum.Font.GothamBold

-- Add corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = MainFrame

corner:Clone().Parent = Title
corner:Clone().Parent = UnlockBtn

-- Parent
Title.Parent = MainFrame
Status.Parent = MainFrame
UnlockBtn.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- Unlock button
UnlockBtn.MouseButton1Click:Connect(function()
    UnlockBtn.Text = "UNLOCKING..."
    
    local unlocked = unlockAllLockedValues()
    
    if unlocked > 0 then
        Status.Text = "✅ Unlocked " .. unlocked .. " items!\nCheck the shop - buttons should say 'EQUIP'"
        UnlockBtn.Text = "✅ DONE!"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        
        -- Auto-hide after 3 seconds
        task.wait(3)
        MainFrame.Visible = false
    else
        Status.Text = "❌ No 'Locked' values found\nOpen the car shop first!"
        UnlockBtn.Text = "🔓 UNLOCK NOW"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Auto-unlock after 3 seconds
task.wait(3)
print("⏰ Auto-unlocking in 2 seconds...")
task.wait(2)

UnlockBtn.Text = "UNLOCKING..."
local unlocked = unlockAllLockedValues()

if unlocked > 0 then
    Status.Text = "✅ Auto-unlocked " .. unlocked .. " items!\nShop should now show 'EQUIP' buttons"
    UnlockBtn.Text = "✅ DONE!"
    UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    
    task.wait(3)
    MainFrame.Visible = false
else
    Status.Text = "❌ No 'Locked' values found yet\nOpen the car shop and click UNLOCK"
    UnlockBtn.Text = "🔓 UNLOCK NOW"
end

-- Instructions in console
print("\n" .. string.rep("=", 50))
print("🔓 SIMPLE UNLOCKER INSTRUCTIONS:")
print("1. Open car customization shop")
print("2. Browse wraps/kits/wheels")
print("3. Click UNLOCK NOW button")
print("4. 'Buy' buttons should change to 'EQUIP'")
print("5. You can now equip items normally!")
print(string.rep("=", 50))
