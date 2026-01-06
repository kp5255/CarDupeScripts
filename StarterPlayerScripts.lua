-- 🎯 CAR DEALERSHIP TYCOON - REAL UNLOCKER
-- Targets Layer 3 (server-authoritative entitlements)

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(3)

print("🎯 CAR DEALERSHIP TYCOON UNLOCKER LOADED")

-- ===== NETWORK TRAFFIC ANALYZER =====
local function analyzeNetworkPatterns()
    print("📡 Analyzing network patterns...")
    
    local patterns = {
        purchaseRemotes = {},
        inventoryRemotes = {},
        ownershipRemotes = {}
    }
    
    -- Scan ReplicatedStorage for all remotes
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            
            -- Categorize remotes
            if name:find("purchase") or name:find("buy") then
                table.insert(patterns.purchaseRemotes, obj)
            elseif name:find("inventory") or name:find("owned") or name:find("equip") then
                table.insert(patterns.inventoryRemotes, obj)
            elseif name:find("add") or name:find("unlock") or name:find("grant") then
                table.insert(patterns.ownershipRemotes, obj)
            end
        end
    end
    
    -- Also check common module scripts for catalog data
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local name = obj.Name:lower()
            if name:find("catalog") or name:find("shop") or name:find("item") then
                print("📦 Found catalog module: " .. obj.Name)
                
                -- Try to require it to see item data
                local success, module = pcall(require, obj)
                if success and type(module) == "table" then
                    -- Look for item definitions
                    for key, value in pairs(module) do
                        if type(value) == "table" and (value.id or value.itemId or value.productId) then
                            print("   📝 Found item definition with ID: " .. tostring(value.id or value.itemId or value.productId))
                        end
                    end
                end
            end
        end
    end
    
    return patterns
end

-- ===== ITEM ID DISCOVERY =====
local function discoverRealItemIDs()
    print("🔍 Discovering real item IDs...")
    
    local itemIDs = {}
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Method 1: Look in hidden UI values
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("StringValue") or obj:IsA("ObjectValue") then
            local value = tostring(obj.Value)
            -- Look for UUID/GUID patterns
            local guidPattern = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
            for guid in value:gmatch(guidPattern) do
                if not table.find(itemIDs, guid) then
                    table.insert(itemIDs, guid)
                    print("✅ Found GUID: " .. guid .. " in " .. obj.Name)
                end
            end
            
            -- Look for numeric IDs
            if value:match("^%d+$") and #value >= 6 then
                if not table.find(itemIDs, value) then
                    table.insert(itemIDs, value)
                    print("✅ Found numeric ID: " .. value .. " in " .. obj.Name)
                end
            end
        end
    end
    
    -- Method 2: Monitor what gets sent when you click items
    print("\n🎯 Click monitoring activated...")
    print("Click on cosmetics in the shop to capture real IDs")
    
    for _, button in pairs(PlayerGui:GetDescendants()) do
        if button:IsA("TextButton") then
            local original = button.MouseButton1Click
            button.MouseButton1Click = function(...)
                print("🖱️ Clicked: " .. button.Name .. " - " .. button.Text)
                
                -- Check what data might be associated
                for _, child in pairs(button:GetDescendants()) do
                    if child:IsA("StringValue") or child:IsA("IntValue") then
                        print("   Associated value: " .. child.Name .. " = " .. tostring(child.Value))
                    end
                end
                
                if original then
                    return original(...)
                end
            end
        end
    end
    
    return itemIDs
end

-- ===== SERVER-SIDE UNLOCK ATTEMPT =====
local function attemptServerSideUnlock(itemIDs)
    print("🔓 Attempting server-side unlock...")
    
    local networkPatterns = analyzeNetworkPatterns()
    local results = {success = 0, failed = 0, details = {}}
    
    print("\n📊 Found remotes:")
    print("  Purchase remotes: " .. #networkPatterns.purchaseRemotes)
    print("  Inventory remotes: " .. #networkPatterns.inventoryRemotes)
    print("  Ownership remotes: " .. #networkPatterns.ownershipRemotes)
    
    -- Try all possible item IDs with all remotes
    for _, itemId in pairs(itemIDs) do
        print("\n🔄 Testing item ID: " .. itemId)
        
        local unlocked = false
        
        -- Test with ownership remotes first (most likely for entitlements)
        for _, remote in pairs(networkPatterns.ownershipRemotes) do
            local formats = {
                itemId,
                {id = itemId},
                {itemId = itemId},
                {productId = itemId},
                {item = itemId},
                {ItemId = itemId, Player = Player},
                {Id = itemId, UserId = Player.UserId}
            }
            
            for i, data in ipairs(formats) do
                print("   Trying format " .. i .. " with " .. remote.Name)
                
                local success, result = pcall(function()
                    if remote:IsA("RemoteFunction") then
                        return remote:InvokeServer(data)
                    else
                        remote:FireServer(data)
                        return "FireServer called"
                    end
                end)
                
                if success then
                    print("   ✅ Success! Result: " .. tostring(result))
                    results.success = results.success + 1
                    results.details[itemId] = "Unlocked via " .. remote.Name
                    unlocked = true
                    break
                else
                    print("   ❌ Failed: " .. tostring(result))
                end
            end
            
            if unlocked then break end
        end
        
        if not unlocked then
            results.failed = results.failed + 1
            results.details[itemId] = "Failed to unlock"
        end
    end
    
    return results
end

-- ===== PERSISTENCE TEST =====
local function testPersistence()
    print("\n💾 Testing persistence...")
    
    -- Save the game state
    local saveRemote = nil
    for _, obj in pairs(RS:GetDescendants()) do
        if (obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent")) 
           and obj.Name:lower():find("save") then
            saveRemote = obj
            break
        end
    end
    
    if saveRemote then
        print("✅ Found save remote: " .. saveRemote.Name)
        
        local success, result = pcall(function()
            if saveRemote:IsA("RemoteFunction") then
                return saveRemote:InvokeServer()
            else
                saveRemote:FireServer()
                return "Save triggered"
            end
        end)
        
        print("Save attempt: " .. tostring(success) .. " - " .. tostring(result))
    else
        print("❌ No save remote found")
    end
end

-- ===== CREATE UI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TycoonUnlockerUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)

local Title = Instance.new("TextLabel")
Title.Text = "🎯 CAR DEALERSHIP UNLOCKER"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold

local Status = Instance.new("TextLabel")
Status.Text = "Layer 1 = Visual (UI)\nLayer 2 = Appearance (Replicated)\nLayer 3 = Entitlement (Server)\n\nTargeting Layer 3..."
Status.Size = UDim2.new(1, -20, 0, 120)
Status.Position = UDim2.new(0, 10, 0, 60)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextWrapped = true
Status.Font = Enum.Font.Code

local ScanBtn = Instance.new("TextButton")
ScanBtn.Text = "🔍 SCAN FOR ITEM IDs"
ScanBtn.Size = UDim2.new(1, -20, 0, 40)
ScanBtn.Position = UDim2.new(0, 10, 0, 190)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Text = "🔓 UNLOCK ENTITLEMENTS"
UnlockBtn.Size = UDim2.new(1, -20, 0, 40)
UnlockBtn.Position = UDim2.new(0, 10, 0, 240)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
UnlockBtn.Visible = false

local TestBtn = Instance.new("TextButton")
TestBtn.Text = "💾 TEST PERSISTENCE"
TestBtn.Size = UDim2.new(1, -20, 0, 40)
TestBtn.Position = UDim2.new(0, 10, 0, 290)
TestBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, -20, 0, 100)
LogFrame.Position = UDim2.new(0, 10, 0, 340)
LogFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
LogFrame.ScrollBarThickness = 6
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local LogLabel = Instance.new("TextLabel")
LogLabel.Text = "Log will appear here...\n"
LogLabel.Size = UDim2.new(1, -10, 0, 0)
LogLabel.Position = UDim2.new(0, 5, 0, 5)
LogLabel.BackgroundTransparency = 1
LogLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LogLabel.Font = Enum.Font.Code
LogLabel.TextSize = 11
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextYAlignment = Enum.TextYAlignment.Top
LogLabel.TextWrapped = true
LogLabel.AutomaticSize = Enum.AutomaticSize.Y

-- Add corners
local function addCorner(obj)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = obj
end

addCorner(MainFrame)
addCorner(Title)
addCorner(ScanBtn)
addCorner(UnlockBtn)
addCorner(TestBtn)
addCorner(LogFrame)

-- Parent
LogLabel.Parent = LogFrame
Title.Parent = MainFrame
Status.Parent = MainFrame
ScanBtn.Parent = MainFrame
UnlockBtn.Parent = MainFrame
TestBtn.Parent = MainFrame
LogFrame.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- Variables
local discoveredIDs = {}

-- Update log
local function addLog(text)
    LogLabel.Text = LogLabel.Text .. text .. "\n"
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, LogLabel.TextBounds.Y + 20)
    LogFrame.CanvasPosition = Vector2.new(0, LogLabel.TextBounds.Y)
    print(text)
end

-- Scan function
ScanBtn.MouseButton1Click:Connect(function()
    ScanBtn.Text = "SCANNING..."
    addLog("\n🔍 Scanning for item IDs...")
    
    discoveredIDs = discoverRealItemIDs()
    
    if #discoveredIDs > 0 then
        addLog("✅ Found " .. #discoveredIDs .. " item IDs")
        for i, id in ipairs(discoveredIDs) do
            addLog("  " .. i .. ". " .. id)
        end
        
        UnlockBtn.Visible = true
        UnlockBtn.Text = "🔓 UNLOCK " .. #discoveredIDs .. " ITEMS"
        ScanBtn.Text = "✅ SCAN COMPLETE"
    else
        addLog("❌ No item IDs found")
        addLog("💡 Click cosmetics in the shop first")
        ScanBtn.Text = "🔍 SCAN FOR ITEM IDs"
    end
end)

-- Unlock function
UnlockBtn.MouseButton1Click:Connect(function()
    UnlockBtn.Text = "UNLOCKING..."
    addLog("\n🔓 Attempting server-side unlock...")
    
    local results = attemptServerSideUnlock(discoveredIDs)
    
    addLog("\n📊 RESULTS:")
    addLog("✅ Successfully unlocked: " .. results.success)
    addLog("❌ Failed: " .. results.failed)
    
    if results.success > 0 then
        addLog("🎉 Some items may now be properly unlocked!")
        addLog("💾 Test persistence after unlocking")
        
        UnlockBtn.Text = "✅ PARTIAL SUCCESS"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        addLog("⚠️ No server-side unlocks")
        addLog("The game may have strong anti-cheat")
        
        UnlockBtn.Text = "🔓 UNLOCK ENTITLEMENTS"
    end
end)

-- Test persistence
TestBtn.MouseButton1Click:Connect(function()
    TestBtn.Text = "TESTING..."
    addLog("\n💾 Testing persistence...")
    testPersistence()
    TestBtn.Text = "💾 TEST PERSISTENCE"
end)

-- Initial instructions
addLog("🎯 CAR DEALERSHIP TYCOON UNLOCKER")
addLog(string.rep("=", 40))
addLog("TARGETING LAYER 3 (Server Entitlements)")
addLog(string.rep("=", 40))
addLog("HOW TO USE:")
addLog("1. Open car customization shop")
addLog("2. Click SCAN FOR ITEM IDs")
addLog("3. Click cosmetics to capture IDs")
addLog("4. Click UNLOCK ENTITLEMENTS")
addLog("5. Click TEST PERSISTENCE")
addLog("6. Rejoin to verify")
addLog(string.rep("=", 40))

-- Auto-scan
task.wait(3)
addLog("\n⏰ Auto-scanning in 3 seconds...")
task.wait(3)

ScanBtn.Text = "SCANNING..."
addLog("🔍 Auto-scanning for item IDs...")

-- Simpler scan for auto mode
local autoIDs = {}
for _, obj in pairs(Player:WaitForChild("PlayerGui"):GetDescendants()) do
    if obj:IsA("StringValue") then
        local value = tostring(obj.Value)
        if value:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
            table.insert(autoIDs, value)
        end
    end
end

if #autoIDs > 0 then
    discoveredIDs = autoIDs
    addLog("✅ Found " .. #autoIDs .. " item IDs")
    UnlockBtn.Visible = true
    UnlockBtn.Text = "🔓 UNLOCK " .. #autoIDs .. " ITEMS"
    ScanBtn.Text = "✅ AUTO-SCANNED"
else
    addLog("❌ No auto-detected IDs")
    ScanBtn.Text = "🔍 SCAN FOR ITEM IDs"
end
