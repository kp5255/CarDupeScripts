-- MINIMAL WORKING UNLOCKER
local P = game:GetService("Players")
local R = game:GetService("ReplicatedStorage")
local plr = P.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(3)

print("🚗 CAR UNLOCKER LOADED")

-- Simple UI
local gui = Instance.new("ScreenGui")
gui.Name = "MiniUnlocker"
gui.Parent = plr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)

local title = Instance.new("TextLabel")
title.Text = "🔓 MINI UNLOCKER"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold

local status = Instance.new("TextLabel")
status.Text = "Click SCAN then UNLOCK\n"
status.Size = UDim2.new(1, -20, 0, 80)
status.Position = UDim2.new(0, 10, 0, 50)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextWrapped = true

local scanBtn = Instance.new("TextButton")
scanBtn.Text = "🔍 SCAN"
scanBtn.Size = UDim2.new(1, -20, 0, 30)
scanBtn.Position = UDim2.new(0, 10, 0, 140)
scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)

local unlockBtn = Instance.new("TextButton")
unlockBtn.Text = "🔓 UNLOCK"
unlockBtn.Size = UDim2.new(1, -20, 0, 30)
unlockBtn.Position = UDim2.new(0, 10, 0, 180)
unlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)

-- Add corners
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, 8)
c.Parent = frame
c:Clone().Parent = title
c:Clone().Parent = scanBtn
c:Clone().Parent = unlockBtn

-- Parent
title.Parent = frame
status.Parent = frame
scanBtn.Parent = frame
unlockBtn.Parent = frame
frame.Parent = gui

-- Simple scan function
local function simpleScan()
    status.Text = status.Text .. "🔍 Scanning...\n"
    
    local PlayerGui = plr:WaitForChild("PlayerGui")
    local foundItems = {}
    
    -- Look for cosmetic buttons
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("TextButton") then
            local text = obj.Text:lower()
            if text:find("buy") or text:find("purchase") 
               or obj.Name:lower():find("wrap") 
               or obj.Name:lower():find("kit") 
               or obj.Name:lower():find("wheel") then
                
                table.insert(foundItems, obj)
                status.Text = status.Text .. "Found: " .. obj.Name .. "\n"
            end
        end
    end
    
    status.Text = status.Text .. "✅ Found " .. #foundItems .. " items\n"
    return foundItems
end

-- Simple unlock function
local function simpleUnlock(items)
    status.Text = status.Text .. "🔓 Unlocking...\n"
    
    local unlocked = 0
    
    -- Try to find purchase remotes
    for _, remote in pairs(R:GetDescendants()) do
        if remote:IsA("RemoteFunction") or remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("purchase") or name:find("buy") 
               or name:find("unlock") then
                
                status.Text = status.Text .. "Found remote: " .. remote.Name .. "\n"
                
                -- Try to unlock each item
                for _, item in pairs(items) do
                    local success, result = pcall(function()
                        if remote:IsA("RemoteFunction") then
                            return remote:InvokeServer(item.Name)
                        else
                            remote:FireServer(item.Name)
                            return "FireServer called"
                        end
                    end)
                    
                    if success then
                        unlocked = unlocked + 1
                        item.Text = "EQUIP"
                        item.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                        status.Text = status.Text .. "✅ " .. item.Name .. "\n"
                    end
                end
            end
        end
    end
    
    status.Text = status.Text .. "📊 Unlocked: " .. unlocked .. "/" .. #items .. "\n"
    return unlocked
end

-- Connect buttons
scanBtn.MouseButton1Click:Connect(function()
    scanBtn.Text = "SCANNING..."
    local items = simpleScan()
    
    if #items > 0 then
        unlockBtn.Visible = true
        unlockBtn.Text = "UNLOCK " .. #items
        scanBtn.Text = "✅ SCANNED"
    else
        scanBtn.Text = "❌ NO ITEMS"
    end
end)

local itemsToUnlock = {}
unlockBtn.MouseButton1Click:Connect(function()
    unlockBtn.Text = "UNLOCKING..."
    simpleUnlock(itemsToUnlock)
    unlockBtn.Text = "✅ DONE"
end)

-- Initial message
status.Text = "🚗 MINI CAR UNLOCKER\n"
status.Text = status.Text .. string.rep("=", 30) .. "\n"
status.Text = status.Text .. "1. Open car shop\n"
status.Text = status.Text .. "2. Select a car\n"
status.Text = status.Text .. "3. Open cosmetics\n"
status.Text = status.Text .. "4. Click SCAN\n"
status.Text = status.Text .. "5. Click UNLOCK\n"
status.Text = status.Text .. string.rep("=", 30) .. "\n"

print("✅ UI Created - Open car shop!")
