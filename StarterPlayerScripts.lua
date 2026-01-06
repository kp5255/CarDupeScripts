-- 🎯 CAR DEALERSHIP TYCOON - REAL UNLOCK SCRIPT
-- Finds and uses the ACTUAL unlock method

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

print("=" .. string.rep("=", 70))
print("🎯 REAL UNLOCK SCRIPT v2.0")
print("=" .. string.rep("=", 70))

-- ===== FIND ALL ITEM GUIDs =====
local function FindAllItemGUIDs()
    print("🔍 Searching for ALL GUIDs in the game...")
    
    local allGUIDs = {}
    local guiGUIDs = {}
    local workspaceGUIDs = {}
    
    -- Pattern for GUID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
    local guidPattern = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"
    
    -- 1. Search PlayerGui (where cosmetics are shown)
    local PlayerGui = Player:WaitForChild("PlayerGui")
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("StringValue") then
            local value = tostring(obj.Value)
            for guid in value:gmatch(guidPattern) do
                if not table.find(guiGUIDs, guid) then
                    table.insert(guiGUIDs, guid)
                    print("🎯 Found GUI GUID: " .. guid .. " in " .. obj.Name)
                end
            end
        end
        
        -- Also check TextLabels (sometimes GUIDs are displayed)
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local text = obj.Text
            for guid in text:gmatch(guidPattern) do
                if not table.find(guiGUIDs, guid) then
                    table.insert(guiGUIDs, guid)
                    print("🎯 Found GUI GUID in text: " .. guid)
                end
            end
        end
    end
    
    -- 2. Search workspace for car models (might have GUIDs)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("StringValue") then
            local value = tostring(obj.Value)
            for guid in value:gmatch(guidPattern) do
                if not table.find(workspaceGUIDs, guid) then
                    table.insert(workspaceGUIDs, guid)
                end
            end
        end
    end
    
    -- 3. Search ReplicatedStorage for item catalogs
    local catalogGUIDs = {}
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("StringValue") or obj:IsA("ModuleScript") then
            if obj:IsA("StringValue") then
                local value = tostring(obj.Value)
                for guid in value:gmatch(guidPattern) do
                    if not table.find(catalogGUIDs, guid) then
                        table.insert(catalogGUIDs, guid)
                        print("🎯 Found RS GUID: " .. guid .. " in " .. obj.Name)
                    end
                end
            elseif obj:IsA("ModuleScript") then
                -- Try to require module scripts to find GUIDs
                local success, module = pcall(require, obj)
                if success and type(module) == "table" then
                    -- Convert table to string and search for GUIDs
                    local tableStr = tostring(module)
                    for guid in tableStr:gmatch(guidPattern) do
                        if not table.find(catalogGUIDs, guid) then
                            table.insert(catalogGUIDs, guid)
                            print("🎯 Found Module GUID: " .. guid .. " in " .. obj.Name)
                        end
                    end
                end
            end
        end
    end
    
    -- Combine all GUIDs
    for _, guid in ipairs(guiGUIDs) do
        if not table.find(allGUIDs, guid) then
            table.insert(allGUIDs, guid)
        end
    end
    
    for _, guid in ipairs(workspaceGUIDs) do
        if not table.find(allGUIDs, guid) then
            table.insert(allGUIDs, guid)
        end
    end
    
    for _, guid in ipairs(catalogGUIDs) do
        if not table.find(allGUIDs, guid) then
            table.insert(allGUIDs, guid)
        end
    end
    
    print("\n📊 GUID SEARCH RESULTS:")
    print("PlayerGui GUIDs: " .. #guiGUIDs)
    print("Workspace GUIDs: " .. #workspaceGUIDs)
    print("Catalog GUIDs: " .. #catalogGUIDs)
    print("TOTAL UNIQUE GUIDs: " .. #allGUIDs)
    
    if #allGUIDs > 0 then
        print("\n🎯 FOUND GUIDs:")
        for i, guid in ipairs(allGUIDs) do
            print(i .. ". " .. guid)
        end
    end
    
    return allGUIDs
end

-- ===== FIND UNLOCK REMOTE =====
local function FindUnlockRemote()
    print("\n📡 Searching for unlock remote...")
    
    local possibleRemotes = {}
    
    -- Common remote names for unlocking
    local remoteNamesToTry = {
        -- Purchase related
        "PurchaseItem", "BuyItem", "PurchaseProduct", "BuyProduct",
        "PurchaseVehicle", "BuyVehicle", "PurchaseCosmetic", "BuyCosmetic",
        -- Unlock related
        "UnlockItem", "UnlockProduct", "UnlockCosmetic", "UnlockVehicle",
        "AddToInventory", "GrantItem", "GiveItem", "GetItem",
        -- Generic
        "RemoteEvent", "RemoteFunction", "Function", "Event",
        "Server", "Client", "Request", "Call",
        -- Game specific (common in tycoons)
        "TycoonPurchase", "TycoonBuy", "ShopPurchase", "ShopBuy",
        "VehicleShop", "CosmeticShop", "ItemShop"
    }
    
    -- Search in ReplicatedStorage
    for _, remoteName in ipairs(remoteNamesToTry) do
        local remote = RS:FindFirstChild(remoteName)
        if remote and (remote:IsA("RemoteFunction") or remote:IsA("RemoteEvent")) then
            table.insert(possibleRemotes, {
                object = remote,
                name = remote.Name,
                type = remote.ClassName,
                source = "ReplicatedStorage"
            })
            print("✅ Found remote: " .. remote.Name .. " (" .. remote.ClassName .. ")")
        end
    end
    
    -- Search deeper in ReplicatedStorage
    for _, obj in pairs(RS:GetDescendants()) do
        if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
            local alreadyFound = false
            for _, foundRemote in ipairs(possibleRemotes) do
                if foundRemote.object == obj then
                    alreadyFound = true
                    break
                end
            end
            
            if not alreadyFound then
                table.insert(possibleRemotes, {
                    object = obj,
                    name = obj.Name,
                    type = obj.ClassName,
                    source = obj:GetFullName()
                })
                print("✅ Found hidden remote: " .. obj.Name .. " (" .. obj.ClassName .. ")")
            end
        end
    end
    
    -- Search in Network folder (common location)
    local networkFolder = RS:FindFirstChild("Network")
    if networkFolder then
        for _, obj in pairs(networkFolder:GetDescendants()) do
            if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                table.insert(possibleRemotes, {
                    object = obj,
                    name = obj.Name,
                    type = obj.ClassName,
                    source = "Network"
                })
                print("✅ Found network remote: " .. obj.Name)
            end
        end
    end
    
    print("\n📊 REMOTE SEARCH RESULTS:")
    print("Found " .. #possibleRemotes .. " possible remotes")
    
    return possibleRemotes
end

-- ===== TEST UNLOCK WITH GUI =====
local function TestUnlockWithGUI(guids, remotes)
    print("\n🔓 Testing unlock with GUI...")
    
    local results = {
        tested = 0,
        successful = 0,
        failed = 0,
        workingRemotes = {}
    }
    
    -- First, let user manually click an item to see what happens
    print("🎯 STEP 1: Manually click a cosmetic in the shop")
    print("   This helps us see what data the game sends")
    
    -- Monitor the console for when user clicks
    print("\n🎯 STEP 2: The script will monitor for GUIDs being sent")
    print("   After you click, check the output for captured data")
    
    -- Try each remote with each GUID
    for _, remote in ipairs(remotes) do
        print("\n🔄 Testing remote: " .. remote.name .. " (" .. remote.type .. ")")
        
        for _, guid in ipairs(guids) do
            results.tested = results.tested + 1
            
            -- Try different data formats
            local formats = {
                -- Format 1: Just the GUID
                guid,
                -- Format 2: With ItemId key
                {ItemId = guid},
                -- Format 3: With id key
                {id = guid},
                -- Format 4: With productId key
                {productId = guid},
                -- Format 5: With GUID key
                {GUID = guid},
                -- Format 6: With UUID key
                {UUID = guid},
                -- Format 7: With item key
                {item = guid},
                -- Format 8: With additional data
                {ItemId = guid, Player = Player, Price = 0},
                -- Format 9: Different case
                {itemId = guid},
                -- Format 10: For vehicle cosmetics
                {VehiclePart = guid, Player = Player}
            }
            
            local successForThisGuid = false
            
            for formatIndex, data in ipairs(formats) do
                print("   Trying format " .. formatIndex .. " with GUID: " .. string.sub(guid, 1, 8) .. "...")
                
                local success, result = pcall(function()
                    if remote.type == "RemoteFunction" then
                        return remote.object:InvokeServer(data)
                    else
                        remote.object:FireServer(data)
                        return "FireServer called"
                    end
                end)
                
                if success then
                    print("      ✅ SUCCESS!")
                    print("      Result: " .. tostring(result))
                    
                    results.successful = results.successful + 1
                    successForThisGuid = true
                    
                    -- Record working remote
                    if not results.workingRemotes[remote.name] then
                        results.workingRemotes[remote.name] = {
                            remote = remote.object,
                            guid = guid,
                            format = formatIndex,
                            result = result
                        }
                    end
                    
                    break  -- Stop trying other formats for this GUID
                else
                    -- Don't show every error to avoid spam
                    if formatIndex == 1 then
                        -- print("      ❌ Failed: " .. tostring(result))
                    end
                end
                
                task.wait(0.05)  -- Small delay
            end
            
            if successForThisGuid then
                print("   🎉 GUID " .. string.sub(guid, 1, 8) .. " unlocked successfully!")
                break  -- Move to next remote
            end
            
            task.wait(0.1)  -- Small delay between GUIDs
        end
        
        -- If we found a working remote, try it with ALL GUIDs
        if results.workingRemotes[remote.name] then
            print("\n💡 Found working remote: " .. remote.name)
            print("   Trying to unlock ALL GUIDs with this remote...")
            
            local workingRemote = remote.object
            local workingFormat = results.workingRemotes[remote.name].format
            
            for _, guid in ipairs(guids) do
                -- Use the format that worked
                local data
                if workingFormat == 1 then
                    data = guid
                elseif workingFormat == 2 then
                    data = {ItemId = guid}
                elseif workingFormat == 3 then
                    data = {id = guid}
                elseif workingFormat == 4 then
                    data = {productId = guid}
                elseif workingFormat == 5 then
                    data = {GUID = guid}
                elseif workingFormat == 6 then
                    data = {UUID = guid}
                elseif workingFormat == 7 then
                    data = {item = guid}
                elseif workingFormat == 8 then
                    data = {ItemId = guid, Player = Player, Price = 0}
                elseif workingFormat == 9 then
                    data = {itemId = guid}
                else
                    data = {VehiclePart = guid, Player = Player}
                end
                
                local success, result = pcall(function()
                    if remote.type == "RemoteFunction" then
                        return remote.object:InvokeServer(data)
                    else
                        remote.object:FireServer(data)
                        return "FireServer called"
                    end
                })
                
                if success then
                    print("   ✅ Unlocked: " .. string.sub(guid, 1, 8))
                end
                
                task.wait(0.05)
            end
            
            break  -- Stop testing other remotes since we found a working one
        end
    end
    
    print("\n📊 TEST RESULTS:")
    print("Total tests: " .. results.tested)
    print("Successful unlocks: " .. results.successful)
    print("Failed: " .. results.failed)
    
    if results.successful > 0 then
        print("\n🎉 SUCCESS! Found working unlock method!")
        print("Working remotes:")
        for remoteName, info in pairs(results.workingRemotes) do
            print("  ✅ " .. remoteName)
            print("     GUID: " .. string.sub(info.guid, 1, 8) + "...")
            print("     Format: " .. info.format)
        end
    else
        print("\n❌ No successful unlocks")
        print("💡 Try manually clicking a cosmetic first")
        print("   Then run the script again")
    end
    
    return results
end

-- ===== REAL-TIME CLICK MONITOR =====
local function SetupClickMonitor()
    print("\n🖱️ Setting up click monitor...")
    print("Click on cosmetics in the shop to capture real data")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local capturedClicks = {}
    
    -- Hook into all TextButtons
    for _, button in pairs(PlayerGui:GetDescendants()) do
        if button:IsA("TextButton") then
            local originalClick = button.MouseButton1Click
            
            button.MouseButton1Click = function(...)
                print("\n🎯 BUTTON CLICKED:")
                print("   Button: " .. button.Name)
                print("   Text: " .. button.Text)
                print("   Path: " .. button:GetFullName())
                
                -- Look for GUIDs near this button
                local parent = button.Parent
                for i = 1, 5 do  -- Check 5 levels up
                    if parent then
                        for _, child in pairs(parent:GetDescendants()) do
                            if child:IsA("StringValue") then
                                local value = tostring(child.Value)
                                if value:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
                                    print("   📦 Nearby GUID: " .. value)
                                    table.insert(capturedClicks, {
                                        button = button.Name,
                                        guid = value,
                                        path = child:GetFullName()
                                    })
                                end
                            end
                        end
                        parent = parent.Parent
                    end
                end
                
                -- Call original function
                if originalClick then
                    return originalClick(...)
                end
            end
        end
    end
    
    print("✅ Click monitor ready")
    print("💡 Click cosmetics to see their GUIDs")
    
    return capturedClicks
end

-- ===== CREATE SIMPLE WORKING UI =====
local function CreateWorkingUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WorkingUnlockerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🎯 REAL UNLOCKER v2"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    
    local Status = Instance.new("TextLabel")
    Status.Text = "Ready to find real unlock method\n"
    Status.Size = UDim2.new(1, -20, 0, 300)
    Status.Position = UDim2.new(0, 10, 0, 60)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(255, 255, 255)
    Status.TextWrapped = true
    Status.TextXAlignment = Enum.TextXAlignment.Left
    
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Text = "🔍 FIND GUIDs & REMOTES"
    ScanBtn.Size = UDim2.new(1, -20, 0, 40)
    ScanBtn.Position = UDim2.new(0, 10, 0, 370)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    
    local UnlockBtn = Instance.new("TextButton")
    UnlockBtn.Text = "🔓 TEST UNLOCK"
    UnlockBtn.Size = UDim2.new(1, -20, 0, 40)
    UnlockBtn.Position = UDim2.new(0, 10, 0, 420)
    UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    UnlockBtn.Visible = false
    
    local MonitorBtn = Instance.new("TextButton")
    MonitorBtn.Text = "🖱️ ENABLE CLICK MONITOR"
    MonitorBtn.Size = UDim2.new(1, -20, 0, 40)
    MonitorBtn.Position = UDim2.new(0, 10, 0, 470)
    MonitorBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = Title
    corner:Clone().Parent = ScanBtn
    corner:Clone().Parent = UnlockBtn
    corner:Clone().Parent = MonitorBtn
    
    -- Parent
    Title.Parent = MainFrame
    Status.Parent = MainFrame
    ScanBtn.Parent = MainFrame
    UnlockBtn.Parent = MainFrame
    MonitorBtn.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Variables
    local foundGUIDs = {}
    local foundRemotes = {}
    local isMonitoring = false
    
    -- Update status
    local function updateStatus(text)
        Status.Text = Status.Text .. text .. "\n"
    end
    
    local function clearStatus()
        Status.Text = ""
    end
    
    -- Scan button
    ScanBtn.MouseButton1Click:Connect(function()
        ScanBtn.Text = "SCANNING..."
        clearStatus()
        
        updateStatus("🔍 Step 1: Searching for GUIDs...")
        foundGUIDs = FindAllItemGUIDs()
        
        updateStatus("\n📡 Step 2: Searching for remotes...")
        foundRemotes = FindUnlockRemote()
        
        if #foundGUIDs > 0 and #foundRemotes > 0 then
            updateStatus("\n✅ READY TO TEST!")
            updateStatus("Found " .. #foundGUIDs .. " GUIDs")
            updateStatus("Found " .. #foundRemotes .. " remotes")
            updateStatus("\nClick TEST UNLOCK to try unlocking")
            
            UnlockBtn.Visible = true
            UnlockBtn.Text = "🔓 TEST " .. #foundGUIDs .. " GUIDs"
            ScanBtn.Text = "✅ SCAN COMPLETE"
        else
            updateStatus("\n❌ Scan incomplete")
            updateStatus("GUIDs found: " .. #foundGUIDs)
            updateStatus("Remotes found: " .. #foundRemotes)
            updateStatus("\n💡 Open the shop first!")
            
            ScanBtn.Text = "🔍 FIND GUIDs & REMOTES"
        end
    end)
    
    -- Unlock button
    UnlockBtn.MouseButton1Click:Connect(function()
        UnlockBtn.Text = "TESTING..."
        updateStatus("\n🔓 Testing unlock methods...")
        
        local results = TestUnlockWithGUI(foundGUIDs, foundRemotes)
        
        updateStatus("\n📊 RESULTS:")
        updateStatus("Successful: " .. results.successful)
        updateStatus("Failed: " .. results.failed)
        
        if results.successful > 0 then
            updateStatus("🎉 Found working method!")
            updateStatus("Check console for details")
            
            UnlockBtn.Text = "✅ SUCCESS!"
            UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            updateStatus("❌ No working method found")
            updateStatus("💡 Enable click monitor and click cosmetics")
            
            UnlockBtn.Text = "🔓 TEST UNLOCK"
        end
    end)
    
    -- Monitor button
    MonitorBtn.MouseButton1Click:Connect(function()
        if not isMonitoring then
            updateStatus("\n🖱️ Click monitor ENABLED")
            updateStatus("Click cosmetics in the shop")
            updateStatus("Check OUTPUT for GUIDs")
            
            SetupClickMonitor()
            MonitorBtn.Text = "🖱️ MONITOR ACTIVE"
            MonitorBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
            isMonitoring = true
        else
            updateStatus("\n🖱️ Click monitor DISABLED")
            MonitorBtn.Text = "🖱️ ENABLE CLICK MONITOR"
            MonitorBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
            isMonitoring = false
        end
    end)
    
    -- Initial message
    clearStatus()
    updateStatus("🎯 REAL UNLOCKER v2")
    updateStatus(string.rep("=", 40))
    updateStatus("FINDS REAL UNLOCK METHOD")
    updateStatus(string.rep("=", 40))
    updateStatus("HOW TO USE:")
    updateStatus("1. Open car shop")
    updateStatus("2. Browse cosmetics")
    updateStatus("3. Click FIND GUIDs & REMOTES")
    updateStatus("4. Click TEST UNLOCK")
    updateStatus("5. Enable click monitor for help")
    updateStatus(string.rep("=", 40))
    updateStatus("NOTE: This finds REAL server unlock")
    updateStatus("Not just visual changes!")
    
    return ScreenGui
end

-- ===== MAIN EXECUTION =====
print("\n🎯 INITIALIZING REAL UNLOCKER...")
task.wait(2)

CreateWorkingUI()

-- Auto-scan after 5 seconds
task.wait(5)
print("\n⏰ Auto-scanning in 3 seconds...")
for i = 3, 1, -1 do
    print(i .. "...")
    task.wait(1)
end

print("🔍 Performing initial scan...")
local initialGUIDs = FindAllItemGUIDs()
local initialRemotes = FindUnlockRemote()

if #initialGUIDs > 0 and #initialRemotes > 0 then
    print("\n✅ Initial scan successful!")
    print("Found " .. #initialGUIDs .. " GUIDs")
    print("Found " .. #initialRemotes .. " remotes")
    print("💡 Open the UI and click TEST UNLOCK")
else
    print("\n❌ Initial scan incomplete")
    print("💡 Open the car shop first, then scan from UI")
end

print("\n" .. string.rep("=", 70))
print("✅ REAL UNLOCKER READY")
print("📍 Look for 'REAL UNLOCKER v2' window")
print("🎯 This finds ACTUAL server unlock method")
print("💡 Not just visual changes!")
print(string.rep("=", 70))
