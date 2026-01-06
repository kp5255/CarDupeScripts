-- 🎯 CAR UNLOCKER FOR DELTA EXECUTOR
-- Optimized for Delta with proper output

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- Function to safely print (Delta compatible)
local function safePrint(...)
    local args = {...}
    local message = ""
    for i, v in ipairs(args) do
        message = message .. tostring(v) .. (i < #args and " " or "")
    end
    
    -- Multiple print methods for Delta
    print(message)
    rconsoleprint(message .. "\n")
    
    -- Also try to show in UI
    if StatusLabel then
        StatusLabel.Text = StatusLabel.Text .. "\n" .. message
    end
end

-- Wait for game
repeat task.wait() until game:IsLoaded()
safePrint("✅ Game loaded")
task.wait(2)

-- Create simple UI that always shows status
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaUnlocker"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 400)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "🚗 DELTA CAR UNLOCKER"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 15)
TitleCorner.Parent = Title

-- Status display
local StatusFrame = Instance.new("ScrollingFrame")
StatusFrame.Size = UDim2.new(1, -20, 0, 250)
StatusFrame.Position = UDim2.new(0, 10, 0, 60)
StatusFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
StatusFrame.ScrollBarThickness = 8
StatusFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Text = "Ready...\n"
StatusLabel.Size = UDim2.new(1, -10, 0, 0)
StatusLabel.Position = UDim2.new(0, 5, 0, 5)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
StatusLabel.TextWrapped = true
StatusLabel.AutomaticSize = Enum.AutomaticSize.Y

StatusLabel.Parent = StatusFrame

-- Buttons
local ScanBtn = Instance.new("TextButton")
ScanBtn.Text = "🔍 SCAN CAR"
ScanBtn.Size = UDim2.new(1, -20, 0, 40)
ScanBtn.Position = UDim2.new(0, 10, 0, 320)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanBtn.Font = Enum.Font.GothamBold

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Text = "🔓 UNLOCK ALL"
UnlockBtn.Size = UDim2.new(1, -20, 0, 40)
UnlockBtn.Position = UDim2.new(0, 10, 0, 370)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnlockBtn.Font = Enum.Font.GothamBold

-- Add corners to buttons
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)

btnCorner:Clone().Parent = ScanBtn
btnCorner:Clone().Parent = UnlockBtn

-- Parent everything
Title.Parent = MainFrame
StatusFrame.Parent = MainFrame
ScanBtn.Parent = MainFrame
UnlockBtn.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- Function to update status
local function updateStatus(text, color)
    if color then
        StatusLabel.TextColor3 = color
    end
    StatusLabel.Text = StatusLabel.Text .. text .. "\n"
    
    -- Auto-scroll
    StatusFrame.CanvasPosition = Vector2.new(0, StatusLabel.AbsoluteSize.Y)
    
    -- Also print to console for Delta
    rconsoleprint(text .. "\n")
end

-- Clear status
local function clearStatus()
    StatusLabel.Text = ""
end

-- SIMPLE CAR SCAN
local function simpleCarScan()
    clearStatus()
    updateStatus("🔍 Scanning for car name...", Color3.fromRGB(255, 200, 0))
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local foundCar = nil
    
    -- Look in common locations based on your screenshot
    local pathsToCheck = {
        "Menu.Inventory.Cars",
        "Menu.Inventory.CarConfig",
        "Customization",
        "Shop"
    }
    
    for _, pathStart in ipairs(pathsToCheck) do
        local obj = PlayerGui:FindFirstChild(pathStart, true)
        if obj then
            updateStatus("✅ Found: " .. obj:GetFullName())
            
            -- Look for text labels
            for _, child in pairs(obj:GetDescendants()) do
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local text = child.Text
                    if text and text ~= "" and #text > 3 then
                        updateStatus("📝 Text found: " .. text)
                        if text:find("Pagani") or text:find("Huayra") then
                            foundCar = text
                            updateStatus("🎯 CAR FOUND: " .. text, Color3.fromRGB(0, 255, 0))
                            break
                        end
                    end
                end
            end
        end
    end
    
    if not foundCar then
        updateStatus("❌ Could not find car name", Color3.fromRGB(255, 100, 100))
        updateStatus("💡 Make sure:", Color3.fromRGB(255, 200, 0))
        updateStatus("   • You're viewing a car in shop", Color3.fromRGB(255, 255, 200))
        updateStatus("   • The car name is visible", Color3.fromRGB(255, 255, 200))
    end
    
    return foundCar or "Unknown Car"
end

-- SIMPLE COSMETIC SCAN
local function simpleCosmeticScan()
    updateStatus("\n🎨 Scanning for cosmetics...", Color3.fromRGB(255, 200, 0))
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local cosmetics = {}
    
    -- Look for cosmetic containers
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
            local name = obj.Name:lower()
            if name:find("wrap") or name:find("kit") 
               or name:find("wheel") or name:find("neon")
               or name:find("cosmetic") or name:find("custom") then
                
                updateStatus("📦 Found container: " .. obj.Name)
                
                -- Look for buttons
                for _, btn in pairs(obj:GetDescendants()) do
                    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                        table.insert(cosmetics, {
                            button = btn,
                            name = btn.Name,
                            path = btn:GetFullName()
                        })
                    end
                end
            end
        end
    end
    
    updateStatus("✅ Found " .. #cosmetics .. " cosmetic items", Color3.fromRGB(0, 255, 0))
    return cosmetics
end

-- SIMPLE UNLOCK ATTEMPT
local function simpleUnlock()
    updateStatus("\n🔓 Attempting to unlock...", Color3.fromRGB(255, 200, 0))
    
    -- Look for remotes
    updateStatus("📡 Searching for remotes...")
    
    local foundRemotes = {}
    
    -- Check common remote locations
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("purchase") or name:find("buy") 
               or name:find("unlock") or name:find("equip") then
                
                table.insert(foundRemotes, {
                    object = obj,
                    name = obj.Name,
                    type = obj.ClassName
                })
                updateStatus("✅ Found remote: " .. obj.Name .. " (" .. obj.ClassName .. ")")
            end
        end
    end
    
    if #foundRemotes == 0 then
        updateStatus("❌ No purchase remotes found!", Color3.fromRGB(255, 100, 100))
        return
    end
    
    -- Try each remote
    updateStatus("\n🔄 Testing remotes...")
    for _, remote in ipairs(foundRemotes) do
        updateStatus("Testing: " .. remote.name)
        
        -- Try different data formats
        local testData = {
            "TestItem",
            {ItemId = "TestItem"},
            {id = "TestItem"},
            {Name = "TestItem", Category = "Wrap"}
        }
        
        for i, data in ipairs(testData) do
            local success, result = pcall(function()
                if remote.type == "RemoteFunction" then
                    return remote.object:InvokeServer(data)
                else
                    remote.object:FireServer(data)
                    return "FireServer called"
                end
            end)
            
            if success then
                updateStatus("  ✅ Format " .. i .. " worked!", Color3.fromRGB(0, 255, 0))
                updateStatus("  Result: " .. tostring(result))
            else
                updateStatus("  ❌ Format " .. i .. " failed", Color3.fromRGB(255, 100, 100))
            end
        end
    end
end

-- Connect buttons
ScanBtn.MouseButton1Click:Connect(function()
    ScanBtn.Text = "SCANNING..."
    ScanBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    
    local carName = simpleCarScan()
    simpleCosmeticScan()
    
    ScanBtn.Text = "🔍 SCAN CAR"
    ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
end)

UnlockBtn.MouseButton1Click:Connect(function()
    UnlockBtn.Text = "UNLOCKING..."
    UnlockBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    
    simpleUnlock()
    
    UnlockBtn.Text = "🔓 UNLOCK ALL"
    UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
end)

-- Initial message
clearStatus()
updateStatus("🚗 DELTA CAR UNLOCKER READY", Color3.fromRGB(0, 200, 255))
updateStatus("=" .. string.rep("=", 40))
updateStatus("HOW TO USE:", Color3.fromRGB(200, 220, 255))
updateStatus("1. Open car shop/customization", Color3.fromRGB(255, 255, 200))
updateStatus("2. Select the Pagani Huayra R", Color3.fromRGB(255, 255, 200))
updateStatus("3. Open wraps/kits/wheels tabs", Color3.fromRGB(255, 255, 200))
updateStatus("4. Click SCAN CAR", Color3.fromRGB(255, 255, 200))
updateStatus("5. Click UNLOCK ALL", Color3.fromRGB(255, 255, 200))
updateStatus("=" .. string.rep("=", 40))

-- Also force Delta to show output
rconsoleclear()
rconsoleprint("🎯 DELTA CAR UNLOCKER LOADED\n")
rconsoleprint("📍 Look for the UI window in-game\n")
rconsoleprint("📝 All output will show here too\n")
