-- 🎯 CAR DEALERSHIP TYCOON - SIMPLE ITEM UNLOCKER
-- No click monitoring, just direct unlocking

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 SIMPLE TYCOON UNLOCKER LOADED")

-- Simple function to find all GUIDs in the UI
local function findAllGUIDs()
    print("🔍 Searching for GUIDs...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local guids = {}
    
    -- Look for StringValues with GUID patterns
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("StringValue") or obj:IsA("ObjectValue") then
            local value = tostring(obj.Value)
            
            -- GUID pattern: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
            local guidPattern = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
            
            for guid in value:gmatch(guidPattern) do
                if not table.find(guids, guid) then
                    table.insert(guids, guid)
                    print("✅ Found GUID: " .. guid)
                end
            end
        end
    end
    
    return guids
end

-- Simple function to find all purchase remotes
local function findPurchaseRemotes()
    print("📡 Looking for purchase remotes...")
    
    local remotes = {}
    
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("purchase") or name:find("buy") 
               or name:find("unlock") or name:find("additem") 
               or name:find("grant") then
                
                table.insert(remotes, obj)
                print("✅ Found remote: " .. obj.Name .. " (" .. obj.ClassName .. ")")
            end
        end
    end
    
    return remotes
end

-- Try to unlock with all GUIDs
local function attemptUnlockAll(guids, remotes)
    print("🔓 Attempting to unlock " .. #guids .. " GUIDs...")
    
    local unlocked = 0
    
    for i, guid in ipairs(guids) do
        print("\n🔄 [" .. i .. "/" .. #guids .. "] Trying: " .. guid)
        
        local success = false
        
        for _, remote in ipairs(remotes) do
            -- Try different data formats
            local formats = {
                guid,
                {ItemId = guid},
                {id = guid},
                {productId = guid},
                {GUID = guid},
                {item = guid, player = Player}
            }
            
            for formatIndex, data in ipairs(formats) do
                local callSuccess, result = pcall(function()
                    if remote:IsA("RemoteFunction") then
                        return remote:InvokeServer(data)
                    else
                        remote:FireServer(data)
                        return "FireServer called"
                    end
                end)
                
                if callSuccess then
                    print("   ✅ Success with " .. remote.Name .. " (format " .. formatIndex .. ")")
                    print("   Result: " .. tostring(result))
                    unlocked = unlocked + 1
                    success = true
                    break
                else
                    print("   ❌ Failed with " .. remote.Name .. ": " .. tostring(result))
                end
            end
            
            if success then break end
        end
    end
    
    return unlocked
end

-- Create a VERY simple UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleUnlockUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 200)
MainFrame.Position = UDim2.new(0.5, -175, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)

local Title = Instance.new("TextLabel")
Title.Text = "🔓 TYCOON UNLOCKER"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold

local Status = Instance.new("TextLabel")
Status.Text = "Click UNLOCK to try unlocking items\nvia GUIDs found in the UI"
Status.Size = UDim2.new(1, -20, 0, 80)
Status.Position = UDim2.new(0, 10, 0, 50)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextWrapped = true

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Text = "🔓 UNLOCK ITEMS"
UnlockBtn.Size = UDim2.new(1, -20, 0, 40)
UnlockBtn.Position = UDim2.new(0, 10, 0, 140)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnlockBtn.Font = Enum.Font.GothamBold

-- Add corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)

corner:Clone().Parent = MainFrame
corner:Clone().Parent = Title
corner:Clone().Parent = UnlockBtn

-- Parent
Title.Parent = MainFrame
Status.Parent = MainFrame
UnlockBtn.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- Unlock button
UnlockBtn.MouseButton1Click:Connect(function()
    UnlockBtn.Text = "WORKING..."
    Status.Text = "Scanning for GUIDs..."
    
    -- Find GUIDs
    local guids = findAllGUIDs()
    
    if #guids == 0 then
        Status.Text = "❌ No GUIDs found!\nOpen the car shop first."
        UnlockBtn.Text = "🔓 UNLOCK ITEMS"
        return
    end
    
    Status.Text = "Found " .. #guids .. " GUIDs\nLooking for remotes..."
    
    -- Find remotes
    local remotes = findPurchaseRemotes()
    
    if #remotes == 0 then
        Status.Text = "❌ No purchase remotes found!"
        UnlockBtn.Text = "🔓 UNLOCK ITEMS"
        return
    end
    
    Status.Text = "Found " .. #remotes .. " remotes\nAttempting unlock..."
    
    -- Try to unlock
    local unlocked = attemptUnlockAll(guids, remotes)
    
    Status.Text = "📊 RESULTS:\nUnlocked: " .. unlocked .. "/" .. #guids
    
    if unlocked > 0 then
        UnlockBtn.Text = "✅ PARTIAL SUCCESS"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        
        -- Suggest rejoining
        task.wait(3)
        Status.Text = Status.Text .. "\n\n💡 Try rejoining to see\nif unlocks persist!"
    else
        UnlockBtn.Text = "❌ FAILED"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Auto-try after 5 seconds
task.wait(5)
print("\n⏰ Auto-attempting unlock in 3 seconds...")
task.wait(3)

UnlockBtn.Text = "AUTO-ATTEMPTING..."
Status.Text = "Auto-scanning..."

local autoGuids = findAllGUIDs()
local autoRemotes = findPurchaseRemotes()

if #autoGuids > 0 and #autoRemotes > 0 then
    Status.Text = "Found " .. #autoGuids .. " GUIDs\nand " .. #autoRemotes .. " remotes\nAttempting..."
    
    local result = attemptUnlockAll(autoGuids, autoRemotes)
    Status.Text = "AUTO-RESULTS:\nUnlocked: " .. result .. "/" .. #autoGuids
    
    if result > 0 then
        UnlockBtn.Text = "✅ AUTO-SUCCESS"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        UnlockBtn.Text = "🔓 UNLOCK ITEMS"
    end
else
    Status.Text = "❌ Auto-scan failed\nOpen shop and click UNLOCK"
    UnlockBtn.Text = "🔓 UNLOCK ITEMS"
end

-- Instructions
print("\n" .. string.rep("=", 50))
print("🎯 TYCOON UNLOCKER INSTRUCTIONS:")
print("1. Open car customization shop")
print("2. Browse wraps/kits/wheels")
print("3. Click UNLOCK ITEMS button")
print("4. Check if items appear unlocked")
print("5. Rejoin to test persistence")
print(string.rep("=", 50))
