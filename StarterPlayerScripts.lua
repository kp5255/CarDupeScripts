-- 🔓 LOCKED VALUE UNLOCKER
-- Changes "locked" or "Locked" values to 0 to unlock items

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(3)

print("🔓 LOCKED VALUE UNLOCKER LOADED")

-- ===== FIND AND UNLOCK ITEMS =====
local function UnlockAllLockedValues()
    print("🔍 Searching for locked values...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local unlockedCount = 0
    
    -- Look for ALL values in the UI
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        -- Check IntValues, NumberValues, StringValues, BoolValues
        if obj:IsA("IntValue") or obj:IsA("NumberValue") 
           or obj:IsA("StringValue") or obj:IsA("BoolValue") then
            
            local valueName = obj.Name:lower()
            
            -- Check if this looks like a lock/unlock value
            if valueName:find("lock") or valueName:find("owned")
               or valueName:find("purchased") or valueName:find("unlocked")
               or valueName:find("equipped") or valueName:find("bought") then
                
                print("🔓 Found value: " .. obj.Name .. " = " .. tostring(obj.Value))
                
                -- Try to unlock it
                local originalValue = obj.Value
                
                if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                    -- For numeric values, change to 1 (unlocked) or 0 if it's > 0
                    if tonumber(obj.Value) == 0 then
                        obj.Value = 1  -- 0 = locked, 1 = unlocked
                        unlockedCount = unlockedCount + 1
                        print("   ✅ Changed from " .. originalValue .. " to 1")
                    elseif tonumber(obj.Value) > 1 then
                        obj.Value = 1
                        unlockedCount = unlockedCount + 1
                        print("   ✅ Changed from " .. originalValue .. " to 1")
                    end
                elseif obj:IsA("StringValue") then
                    -- For string values, change "false" to "true", "locked" to "unlocked"
                    local lowerValue = tostring(obj.Value):lower()
                    if lowerValue == "false" or lowerValue == "locked" 
                       or lowerValue == "no" or lowerValue == "0" then
                        obj.Value = "true"
                        unlockedCount = unlockedCount + 1
                        print("   ✅ Changed from '" .. originalValue .. "' to 'true'")
                    end
                elseif obj:IsA("BoolValue") then
                    -- For boolean values, change false to true
                    if obj.Value == false then
                        obj.Value = true
                        unlockedCount = unlockedCount + 1
                        print("   ✅ Changed from false to true")
                    end
                end
            end
        end
        
        -- Also check TextLabels/TextButtons that might show locked status
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local text = obj.Text:lower()
            if text:find("locked") or text:find("not owned") 
               or text:find("purchase") or text:find("buy") then
                
                -- Change the text to show unlocked
                if text:find("locked") then
                    obj.Text = "UNLOCKED"
                    obj.TextColor3 = Color3.fromRGB(0, 255, 0)
                    unlockedCount = unlockedCount + 1
                    print("✅ Changed text from 'locked' to 'UNLOCKED'")
                elseif text:find("buy") or text:find("purchase") then
                    obj.Text = "EQUIP"
                    obj.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    unlockedCount = unlockedCount + 1
                    print("✅ Changed button from 'buy' to 'EQUIP'")
                end
            end
        end
    end
    
    -- Also look for specific patterns like "locked = 1" in properties
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
            -- Check for common property names
            for _, child in pairs(obj:GetChildren()) do
                if child.Name:lower():find("lock") and (child:IsA("IntValue") or child:IsA("BoolValue")) then
                    print("🔓 Found lock property: " .. child.Name)
                    
                    if child:IsA("IntValue") then
                        if child.Value == 0 then
                            child.Value = 1
                            unlockedCount = unlockedCount + 1
                            print("   ✅ Set " .. child.Name .. " from 0 to 1")
                        end
                    elseif child:IsA("BoolValue") and child.Value == false then
                        child.Value = true
                        unlockedCount = unlockedCount + 1
                        print("   ✅ Set " .. child.Name .. " from false to true")
                    end
                end
            end
        end
    end
    
    return unlockedCount
end

-- ===== REAL-TIME MONITOR =====
local function StartRealTimeUnlockMonitor()
    print("👁️ Starting real-time unlock monitor...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Monitor for new UI elements
    local connection = PlayerGui.DescendantAdded:Connect(function(obj)
        task.wait(0.1)  -- Wait for properties to load
        
        -- Check if this is a lock-related value
        if obj:IsA("IntValue") or obj:IsA("BoolValue") then
            local name = obj.Name:lower()
            if name:find("lock") or name:find("owned") then
                print("👁️ New lock value detected: " .. obj.Name)
                
                -- Try to unlock it
                if obj:IsA("IntValue") and obj.Value == 0 then
                    obj.Value = 1
                    print("   ✅ Auto-unlocked: " .. obj.Name .. " (0 → 1)")
                elseif obj:IsA("BoolValue") and obj.Value == false then
                    obj.Value = true
                    print("   ✅ Auto-unlocked: " .. obj.Name .. " (false → true)")
                end
            end
        end
        
        -- Check for locked text
        if obj:IsA("TextLabel") then
            local text = obj.Text:lower()
            if text:find("locked") or text:find("not owned") then
                obj.Text = "UNLOCKED"
                obj.TextColor3 = Color3.fromRGB(0, 255, 0)
                print("✅ Auto-changed text to UNLOCKED")
            end
        end
    end)
    
    return connection
end

-- ===== SIMPLE UI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LockedValueUnlockerUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)

local Title = Instance.new("TextLabel")
Title.Text = "🔓 LOCKED VALUE UNLOCKER"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

local Status = Instance.new("TextLabel")
Status.Name = "StatusLabel"
Status.Text = "Ready...\n"
Status.Size = UDim2.new(1, -20, 0, 130)
Status.Position = UDim2.new(0, 10, 0, 50)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.Font = Enum.Font.Code
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextYAlignment = Enum.TextYAlignment.Top
Status.TextWrapped = true

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Text = "🔓 UNLOCK ALL VALUES"
UnlockBtn.Size = UDim2.new(1, -20, 0, 35)
UnlockBtn.Position = UDim2.new(0, 10, 0, 190)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnlockBtn.Font = Enum.Font.GothamBold

local MonitorBtn = Instance.new("TextButton")
MonitorBtn.Text = "👁️ ENABLE AUTO-MONITOR"
MonitorBtn.Size = UDim2.new(1, -20, 0, 35)
MonitorBtn.Position = UDim2.new(0, 10, 0, 235)
MonitorBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
MonitorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MonitorBtn.Font = Enum.Font.GothamBold

-- Add corners
local function addCorner(obj)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = obj
end

addCorner(MainFrame)
addCorner(Title)
addCorner(UnlockBtn)
addCorner(MonitorBtn)

-- Parent
Title.Parent = MainFrame
Status.Parent = MainFrame
UnlockBtn.Parent = MainFrame
MonitorBtn.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- Update status (FIXED VERSION)
local function updateStatus(text)
    Status.Text = Status.Text .. text .. "\n"
    
    -- Calculate text height and update canvas size if in a ScrollingFrame
    if Status.Parent:IsA("ScrollingFrame") then
        local textHeight = #Status.Text:split("\n") * 15
        Status.Parent.CanvasSize = UDim2.new(0, 0, 0, textHeight + 20)
    end
end

local function clearStatus()
    Status.Text = ""
end

-- Variables
local monitorConnection = nil
local isMonitoring = false

-- Unlock button
UnlockBtn.MouseButton1Click:Connect(function()
    UnlockBtn.Text = "UNLOCKING..."
    clearStatus()
    
    updateStatus("🔍 Searching for locked values...")
    
    local unlocked = UnlockAllLockedValues()
    
    updateStatus("\n📊 RESULTS:")
    updateStatus("✅ Unlocked " .. unlocked .. " values")
    
    if unlocked > 0 then
        updateStatus("🎉 Items should now appear unlocked!")
        updateStatus("Check the shop - buttons should say 'EQUIP'")
        
        UnlockBtn.Text = "✅ UNLOCKED!"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        updateStatus("❌ No locked values found")
        updateStatus("\n💡 Try:")
        updateStatus("1. Open the car shop")
        updateStatus("2. Browse different cosmetics")
        updateStatus("3. Click UNLOCK again")
        
        UnlockBtn.Text = "🔓 UNLOCK ALL VALUES"
    end
end)

-- Monitor button
MonitorBtn.MouseButton1Click:Connect(function()
    if isMonitoring then
        -- Stop monitoring
        if monitorConnection then
            monitorConnection:Disconnect()
            monitorConnection = nil
        end
        isMonitoring = false
        MonitorBtn.Text = "👁️ ENABLE AUTO-MONITOR"
        MonitorBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        updateStatus("\n⏹️ Auto-monitor stopped")
    else
        -- Start monitoring
        monitorConnection = StartRealTimeUnlockMonitor()
        isMonitoring = true
        MonitorBtn.Text = "⏹️ DISABLE AUTO-MONITOR"
        MonitorBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        updateStatus("\n👁️ Auto-monitor enabled")
        updateStatus("Will auto-unlock new items as they appear")
    end
end)

-- Initial instructions
clearStatus()
updateStatus("🔓 LOCKED VALUE UNLOCKER")
updateStatus("=" .. string.rep("=", 30))
updateStatus("Changes 'locked' values to 0/1")
updateStatus("to unlock items temporarily")
updateStatus("=" .. string.rep("=", 30))
updateStatus("HOW TO USE:")
updateStatus("1. Open car shop")
updateStatus("2. Browse cosmetics")
updateStatus("3. Click UNLOCK ALL VALUES")
updateStatus("4. Enable auto-monitor")
updateStatus("=" .. string.rep("=", 30))

-- Auto-scan after 3 seconds
task.wait(3)
updateStatus("\n⏰ Auto-scanning in 2 seconds...")
task.wait(2)

UnlockBtn.Text = "UNLOCKING..."
clearStatus()
updateStatus("🔍 Auto-scanning for locked values...")

local unlocked = UnlockAllLockedValues()

if unlocked > 0 then
    updateStatus("✅ Auto-unlocked " .. unlocked .. " values")
    updateStatus("Items should now appear unlocked!")
    UnlockBtn.Text = "✅ UNLOCKED!"
    UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
else
    updateStatus("❌ No locked values found")
    updateStatus("Open the shop and click UNLOCK")
    UnlockBtn.Text = "🔓 UNLOCK ALL VALUES"
end
