-- 🎯 SMART CAR UNLOCKER - ITEM DETECTION EDITION
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(3)

-- Create UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ItemHunterUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 500)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)

local Title = Instance.new("TextLabel")
Title.Text = "🔍 ITEM HUNTER - FIND REAL ITEM IDs"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold

local Status = Instance.new("TextLabel")
Status.Text = "Ready...\n"
Status.Size = UDim2.new(1, -20, 0, 300)
Status.Position = UDim2.new(0, 10, 0, 60)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextYAlignment = Enum.TextYAlignment.Top
Status.TextWrapped = true

local ScanItemsBtn = Instance.new("TextButton")
ScanItemsBtn.Text = "🔍 SCAN FOR ITEM IDs"
ScanItemsBtn.Size = UDim2.new(1, -20, 0, 40)
ScanItemsBtn.Position = UDim2.new(0, 10, 0, 370)
ScanItemsBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)

local TestPurchaseBtn = Instance.new("TextButton")
TestPurchaseBtn.Text = "💰 TEST PURCHASE"
TestPurchaseBtn.Size = UDim2.new(1, -20, 0, 40)
TestPurchaseBtn.Position = UDim2.new(0, 10, 0, 420)
TestPurchaseBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)

-- Add corners
local function addCorner(obj)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = obj
end

addCorner(MainFrame)
addCorner(Title)
addCorner(ScanItemsBtn)
addCorner(TestPurchaseBtn)

-- Parent
Title.Parent = MainFrame
Status.Parent = MainFrame
ScanItemsBtn.Parent = MainFrame
TestPurchaseBtn.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- Update status
local function updateStatus(text)
    Status.Text = Status.Text .. text .. "\n"
end

local function clearStatus()
    Status.Text = ""
end

-- ===== ITEM ID DETECTION =====
local function findRealItemIDs()
    clearStatus()
    updateStatus("🔍 Hunting for real item IDs...")
    
    local foundItems = {}
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- METHOD 1: Look for hidden data in cosmetic buttons
    updateStatus("\n📦 METHOD 1: Checking cosmetic buttons...")
    
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            -- Check the button itself
            local buttonInfo = {
                Name = gui.Name,
                Text = gui:IsA("TextButton") and gui.Text or "",
                ClassName = gui.ClassName
            }
            
            -- Check for IntValues, StringValues, etc. (common for storing item IDs)
            for _, child in pairs(gui:GetDescendants()) do
                if child:IsA("IntValue") or child:IsA("StringValue") 
                   or child:IsA("NumberValue") or child:IsA("ObjectValue") then
                    
                    buttonInfo[child.Name] = child.Value
                end
            end
            
            -- Check if this looks like a cosmetic item
            if gui.Name:lower():find("wrap") or gui.Name:lower():find("kit")
               or gui.Name:lower():find("wheel") or gui.Name:lower():find("neon") then
                
                table.insert(foundItems, buttonInfo)
                updateStatus("✅ Found: " .. gui.Name)
                for k, v in pairs(buttonInfo) do
                    if k ~= "ClassName" then
                        updateStatus("   " .. k .. ": " .. tostring(v))
                    end
                end
            end
        end
    end
    
    -- METHOD 2: Look for ModuleScripts that might contain item data
    updateStatus("\n📦 METHOD 2: Checking game modules...")
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local name = obj.Name:lower()
            if name:find("item") or name:find("shop") 
               or name:find("cosmetic") or name:find("catalog") then
                
                updateStatus("📁 Found module: " .. obj.Name)
                
                -- Try to get its contents
                local success, module = pcall(require, obj)
                if success and type(module) == "table" then
                    -- Look for item data in the module
                    for key, value in pairs(module) do
                        if type(value) == "table" and (value.Name or value.Id or value.ItemId) then
                            updateStatus("   📝 Found item data in module")
                            if value.Name then updateStatus("      Name: " .. value.Name) end
                            if value.Id then updateStatus("      Id: " .. value.Id) end
                            if value.ItemId then updateStatus("      ItemId: " .. value.ItemId) end
                            if value.Price then updateStatus("      Price: " .. value.Price) end
                        end
                    end
                end
            end
        end
    end
    
    -- METHOD 3: Monitor network traffic (what the game actually sends)
    updateStatus("\n📦 METHOD 3: Setting up network monitor...")
    
    -- Find the purchase remote that's giving the error
    local purchaseRemote = nil
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("purchase") or name:find("buy") then
                purchaseRemote = obj
                updateStatus("🎯 Found purchase remote: " .. obj.Name)
                break
            end
        end
    end
    
    if purchaseRemote then
        updateStatus("\n🎯 Now click on a cosmetic in-game to see what data is sent!")
        updateStatus("💡 Click a wrap/kit/wheel in the shop UI")
        
        -- Hook into the remote to see what data is sent
        local originalFunction
        if purchaseRemote:IsA("RemoteFunction") then
            originalFunction = purchaseRemote.InvokeServer
            purchaseRemote.InvokeServer = function(self, ...)
                local args = {...}
                updateStatus("\n📡 PURCHASE DATA CAPTURED:")
                updateStatus("Remote: " .. purchaseRemote.Name)
                for i, arg in ipairs(args) do
                    updateStatus("  Arg " .. i .. ": " .. tostring(arg))
                    if type(arg) == "table" then
                        for k, v in pairs(arg) do
                            updateStatus("    " .. k .. " = " .. tostring(v))
                        end
                    end
                end
                return originalFunction(self, ...)
            end
        end
    end
    
    return foundItems
end

-- ===== INTELLIGENT PURCHASE TESTER =====
local function testIntelligentPurchase()
    clearStatus()
    updateStatus("💰 Testing purchase with captured data...")
    
    -- First, let the user manually click an item
    updateStatus("\n🎯 STEP 1: Manually click a cosmetic in the shop")
    updateStatus("Wait for it to show 'CAPTURED DATA' above")
    updateStatus("Then click TEST PURCHASE again")
    
    -- Look for the purchase remote
    local purchaseRemote = nil
    for _, obj in pairs(RS:GetDescendants()) do
        if (obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent")) 
           and obj.Name:lower():find("purchase") then
            purchaseRemote = obj
            break
        end
    end
    
    if not purchaseRemote then
        updateStatus("❌ No purchase remote found")
        return
    end
    
    updateStatus("✅ Found remote: " .. purchaseRemote.Name)
    
    -- Common item IDs from your game (you'll need to fill these)
    local possibleItemIDs = {
        -- Pagani Huayra R cosmetics
        "Pagani_HuayraR_Wrap_1",
        "Pagani_HuayraR_Kit_1", 
        "Pagani_HuayraR_Wheels_1",
        "HuayraR_Wrap_01",
        "HuayraR_BodyKit_01",
        -- Try numeric IDs
        "1001", "1002", "1003", "1004",
        -- Try with underscores
        "pagani_huayra_r_wrap",
        "huayra_r_kit",
    }
    
    updateStatus("\n🔄 Testing different item IDs...")
    
    local successCount = 0
    for _, itemId in ipairs(possibleItemIDs) do
        updateStatus("Testing: " .. itemId)
        
        -- Try different formats
        local formats = {
            itemId,
            {ItemId = itemId},
            {id = itemId},
            {item = itemId},
            {Item = itemId, Vehicle = "Pagani Huayra R"},
            {productId = itemId, carModel = "HuayraR"}
        }
        
        for i, data in ipairs(formats) do
            local success, result = pcall(function()
                if purchaseRemote:IsA("RemoteFunction") then
                    return purchaseRemote:InvokeServer(data)
                else
                    purchaseRemote:FireServer(data)
                    return "FireServer called"
                end
            end)
            
            if success then
                updateStatus("  ✅ Format " .. i .. " - Success!")
                updateStatus("  Result: " .. tostring(result))
                successCount = successCount + 1
                break
            else
                updateStatus("  ❌ Format " .. i .. " - Failed: " .. tostring(result))
            end
            
            task.wait(0.2)
        end
    end
    
    updateStatus("\n📊 Test complete: " .. successCount .. " successful attempts")
    
    if successCount == 0 then
        updateStatus("💡 TIP: Manually click a cosmetic first")
        updateStatus("The script will capture the REAL item data")
        updateStatus("Then we can use that exact data!")
    end
end

-- Connect buttons
ScanItemsBtn.MouseButton1Click:Connect(function()
    ScanItemsBtn.Text = "SCANNING..."
    findRealItemIDs()
    ScanItemsBtn.Text = "🔍 SCAN FOR ITEM IDs"
end)

TestPurchaseBtn.MouseButton1Click:Connect(function()
    TestPurchaseBtn.Text = "TESTING..."
    testIntelligentPurchase()
    TestPurchaseBtn.Text = "💰 TEST PURCHASE"
end)

-- Initial instructions
clearStatus()
updateStatus("🎯 ITEM HUNTER - HOW TO USE:")
updateStatus("=" .. string.rep("=", 40))
updateStatus("1. Open car customization shop")
updateStatus("2. Select Pagani Huayra R")
updateStatus("3. Click 'SCAN FOR ITEM IDs'")
updateStatus("4. Manually click a cosmetic in-game")
updateStatus("5. Watch the captured data appear above")
updateStatus("6. Click 'TEST PURCHASE' with that data")
updateStatus("=" .. string.rep("=", 40))
updateStatus("\nThe error you got means we have the RIGHT remote,")
updateStatus("but the WRONG item data. This tool will find the real data!")
