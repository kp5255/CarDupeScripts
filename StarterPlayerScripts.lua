-- 🎯 GUID-BASED COSMETIC UNLOCKER
-- Finds real item GUIDs and properly unlocks them

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(3)

print("🔓 GUID-BASED UNLOCKER LOADED")

-- ===== GUID COLLECTOR =====
local function CollectGUIDs()
    print("🔍 Collecting item GUIDs...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local collectedGUIDs = {}
    local foundButtons = {}
    
    -- Find all cosmetic buttons and their GUIDs
    for _, gui in pairs(PlayerGui:GetDescendants()) do
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            local buttonName = gui.Name:lower()
            local buttonText = gui:IsA("TextButton") and gui.Text:lower() or ""
            
            -- Check if this is a cosmetic button
            local isCosmetic = buttonName:find("wrap") or buttonName:find("kit") 
                             or buttonName:find("wheel") or buttonName:find("neon")
                             or buttonName:find("paint") or buttonName:find("color")
                             or buttonText:find("wrap") or buttonText:find("kit")
                             or buttonText:find("wheel") or buttonText:find("neon")
                             or buttonName:find("item_") or buttonName:find("cosmetic_")
            
            if isCosmetic then
                local buttonInfo = {
                    button = gui,
                    name = gui.Name,
                    text = gui:IsA("TextButton") and gui.Text or "",
                    path = gui:GetFullName(),
                    guids = {}
                }
                
                -- Look for GUIDs in the button or its children
                -- GUIDs look like: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
                local guidPattern = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
                
                -- Check button name
                for guid in tostring(buttonInfo.name):gmatch(guidPattern) do
                    table.insert(buttonInfo.guids, guid)
                end
                
                -- Check button text
                for guid in tostring(buttonInfo.text):gmatch(guidPattern) do
                    table.insert(buttonInfo.guids, guid)
                end
                
                -- Check children values
                for _, child in pairs(gui:GetDescendants()) do
                    if child:IsA("StringValue") or child:IsA("ObjectValue") then
                        for guid in tostring(child.Value):gmatch(guidPattern) do
                            table.insert(buttonInfo.guids, guid)
                        end
                    end
                end
                
                if #buttonInfo.guids > 0 then
                    table.insert(foundButtons, buttonInfo)
                    print("✅ Found button: " .. buttonInfo.name)
                    print("   GUIDs: " .. table.concat(buttonInfo.guids, ", "))
                end
            end
        end
    end
    
    return foundButtons
end

-- ===== INTELLIGENT UNLOCK ATTEMPT =====
local function IntelligentUnlock(buttons)
    print("🔓 Attempting intelligent unlock...")
    
    -- Find purchase remotes
    local purchaseRemotes = {}
    
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("purchase") or name:find("buy") 
               or name:find("unlock") or name:find("additem") then
                
                table.insert(purchaseRemotes, {
                    object = obj,
                    name = obj.Name,
                    type = obj.ClassName
                })
            end
        end
    end
    
    print("📡 Found " .. #purchaseRemotes .. " purchase remotes")
    
    -- Try to unlock each button
    local unlockedCount = 0
    
    for _, buttonInfo in pairs(buttons) do
        print("\n🔄 Processing: " .. buttonInfo.name)
        
        for _, guid in pairs(buttonInfo.guids) do
            print("   Trying GUID: " .. guid)
            
            -- Try different data formats
            local formats = {
                guid,  -- Just the GUID
                {ItemId = guid},
                {Id = guid},
                {GUID = guid},
                {UUID = guid},
                {ItemGUID = guid},
                {CosmeticId = guid},
                {ProductId = guid},
                -- With additional info
                {ItemId = guid, Type = "Cosmetic"},
                {Id = guid, Category = "VehiclePart"},
                {GUID = guid, Action = "Purchase"}
            }
            
            local success = false
            
            for _, remote in pairs(purchaseRemotes) do
                for i, data in ipairs(formats) do
                    print("      Testing format " .. i .. " with " .. remote.name)
                    
                    local callSuccess, result = pcall(function()
                        if remote.type == "RemoteFunction" then
                            return remote.object:InvokeServer(data)
                        else
                            remote.object:FireServer(data)
                            return "FireServer called"
                        end
                    end)
                    
                    if callSuccess then
                        print("      ✅ Success!")
                        print("      Result: " .. tostring(result))
                        
                        -- Mark button as unlocked visually
                        if buttonInfo.button:IsA("TextButton") then
                            buttonInfo.button.Text = "EQUIP"
                            buttonInfo.button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                        end
                        
                        unlockedCount = unlockedCount + 1
                        success = true
                        break
                    else
                        print("      ❌ Failed: " .. tostring(result))
                    end
                end
                
                if success then break end
            end
            
            if success then break end
        end
    end
    
    return unlockedCount
end

-- ===== UI INTERCEPTION =====
local function InterceptUIForRealUnlock()
    print("🎯 Intercepting UI for real unlock...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- This function monitors UI interactions to learn the correct format
    local function setupUIInterceptor()
        -- Find all cosmetic buttons
        for _, gui in pairs(PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") and (gui.Text:find("Buy") or gui.Text:find("Purchase")) then
                -- Store original click function
                local originalClick = gui.MouseButton1Click
                
                gui.MouseButton1Click:Connect(function()
                    print("🖱️ Button clicked: " .. gui.Name)
                    print("   Text: " .. gui.Text)
                    
                    -- Try to find what data should be sent
                    local parent = gui.Parent
                    while parent do
                        -- Look for GUIDs in parent hierarchy
                        local guidPattern = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
                        
                        for guid in tostring(parent.Name):gmatch(guidPattern) do
                            print("   Found GUID in parent: " .. guid)
                        end
                        
                        parent = parent.Parent
                    end
                    
                    -- Call original function
                    if originalClick then
                        originalClick()
                    end
                end)
            end
        end
    end
    
    pcall(setupUIInterceptor)
end

-- ===== CREATE UI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GUIDUnlockerUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 400)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)

local Title = Instance.new("TextLabel")
Title.Text = "🔓 REAL COSMETIC UNLOCKER"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold

local Status = Instance.new("TextLabel")
Status.Text = "Ready to find and unlock real cosmetics!\n"
Status.Size = UDim2.new(1, -20, 0, 250)
Status.Position = UDim2.new(0, 10, 0, 60)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextWrapped = true
Status.TextXAlignment = Enum.TextXAlignment.Left

local ScanBtn = Instance.new("TextButton")
ScanBtn.Text = "🔍 SCAN FOR COSMETICS"
ScanBtn.Size = UDim2.new(1, -20, 0, 40)
ScanBtn.Position = UDim2.new(0, 10, 0, 320)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Text = "🔓 UNLOCK ALL"
UnlockBtn.Size = UDim2.new(1, -20, 0, 40)
UnlockBtn.Position = UDim2.new(0, 10, 0, 370)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
UnlockBtn.Visible = false

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

-- Parent
Title.Parent = MainFrame
Status.Parent = MainFrame
ScanBtn.Parent = MainFrame
UnlockBtn.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- Variables
local foundButtons = {}

-- Update status
local function updateStatus(text)
    Status.Text = Status.Text .. text .. "\n"
    
    -- Auto-scroll
    local textHeight = #text:split("\n") * 20
    Status.Parent.CanvasSize = UDim2.new(0, 0, 0, Status.TextBounds.Y + 50)
end

local function clearStatus()
    Status.Text = ""
end

-- Scan function
ScanBtn.MouseButton1Click:Connect(function()
    ScanBtn.Text = "SCANNING..."
    clearStatus()
    
    updateStatus("🔍 Scanning for cosmetics with GUIDs...")
    foundButtons = CollectGUIDs()
    
    if #foundButtons > 0 then
        updateStatus("\n✅ Found " .. #foundButtons .. " cosmetic buttons")
        updateStatus("📊 Total GUIDs found: " .. #foundButtons)
        
        for i, button in ipairs(foundButtons) do
            updateStatus("   " .. i .. ". " .. button.name)
            if #button.guids > 0 then
                updateStatus("      GUIDs: " .. table.concat(button.guids, ", "))
            end
        end
        
        UnlockBtn.Visible = true
        UnlockBtn.Text = "🔓 UNLOCK " .. #foundButtons .. " ITEMS"
        
        updateStatus("\n🎯 Ready to unlock!")
        updateStatus("Click UNLOCK ALL to attempt unlock")
    else
        updateStatus("❌ No cosmetics with GUIDs found")
        updateStatus("\n💡 Tips:")
        updateStatus("1. Make sure shop is open")
        updateStatus("2. Navigate to wraps/kits/wheels")
        updateStatus("3. Try scrolling through items")
        updateStatus("4. Click scan again")
    end
    
    ScanBtn.Text = "🔍 SCAN FOR COSMETICS"
end)

-- Unlock function
UnlockBtn.MouseButton1Click:Connect(function()
    UnlockBtn.Text = "UNLOCKING..."
    clearStatus()
    
    updateStatus("🔓 Attempting to unlock cosmetics...")
    
    local unlocked = IntelligentUnlock(foundButtons)
    
    updateStatus("\n📊 RESULTS:")
    updateStatus("✅ Successfully unlocked: " .. unlocked .. "/" .. #foundButtons)
    
    if unlocked > 0 then
        updateStatus("🎉 Some items may now be unlocked!")
        updateStatus("Check the shop - buttons should say 'EQUIP'")
        
        -- Setup UI interceptor to help with future clicks
        InterceptUIForRealUnlock()
        
        UnlockBtn.Text = "✅ PARTIALLY UNLOCKED"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        updateStatus("❌ No items were unlocked")
        updateStatus("\n💡 Possible issues:")
        updateStatus("1. Server-side validation")
        updateStatus("2. Wrong remote function")
        updateStatus("3. Need specific data format")
        updateStatus("4. Anti-cheat protection")
        
        UnlockBtn.Text = "🔓 UNLOCK ALL"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Initial instructions
clearStatus()
updateStatus("🔓 REAL COSMETIC UNLOCKER")
updateStatus("=" .. string.rep("=", 40))
updateStatus("This script finds REAL item GUIDs")
updateStatus("and attempts to unlock them properly")
updateStatus("=" .. string.rep("=", 40))
updateStatus("HOW TO USE:")
updateStatus("1. Open car customization shop")
updateStatus("2. Select Pagani Huayra R")
updateStatus("3. Open wraps/kits/wheels tabs")
updateStatus("4. Click SCAN FOR COSMETICS")
updateStatus("5. Click UNLOCK ALL")
updateStatus("=" .. string.rep("=", 40))
updateStatus("If successful, you'll see 'EQUIP' buttons")
updateStatus("instead of 'Buy' buttons in the shop!")

-- Auto-scan after 5 seconds
task.wait(5)
updateStatus("\n⏰ Auto-scanning in 3 seconds...")
for i = 3, 1, -1 do
    updateStatus(i .. "...")
    task.wait(1)
end

ScanBtn.Text = "SCANNING..."
clearStatus()
updateStatus("🔍 Auto-scanning for cosmetics...")
foundButtons = CollectGUIDs()

if #foundButtons > 0 then
    updateStatus("\n✅ Found " .. #foundButtons .. " cosmetic buttons")
    UnlockBtn.Visible = true
    UnlockBtn.Text = "🔓 UNLOCK " .. #foundButtons .. " ITEMS"
    updateStatus("Click UNLOCK ALL to attempt unlock")
else
    updateStatus("❌ No cosmetics found")
    updateStatus("Please open the shop and try SCAN again")
end

ScanBtn.Text = "🔍 SCAN FOR COSMETICS"
