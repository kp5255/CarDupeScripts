-- 🔍 DEBUG SCRIPT - SEE WHAT'S REALLY HAPPENING
-- Shows all values in real-time as you click around

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🔍 DEBUG SCRIPT LOADED")

-- Create debug UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DebugUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 600)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)

local Title = Instance.new("TextLabel")
Title.Text = "🔍 REAL-TIME DEBUGGER"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold

-- Scrollable log area
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "LogFrame"
ScrollingFrame.Size = UDim2.new(1, -20, 0, 500)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 50)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ScrollingFrame.ScrollBarThickness = 8
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local LogLabel = Instance.new("TextLabel")
LogLabel.Name = "LogLabel"
LogLabel.Text = "DEBUGGER READY\n" .. string.rep("=", 60) .. "\n"
LogLabel.Size = UDim2.new(1, -10, 0, 0)
LogLabel.Position = UDim2.new(0, 5, 0, 5)
LogLabel.BackgroundTransparency = 1
LogLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LogLabel.Font = Enum.Font.Code
LogLabel.TextSize = 12
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextYAlignment = Enum.TextYAlignment.Top
LogLabel.TextWrapped = true
LogLabel.AutomaticSize = Enum.AutomaticSize.Y

-- Buttons
local ScanBtn = Instance.new("TextButton")
ScanBtn.Text = "🔍 SCAN CURRENT UI"
ScanBtn.Size = UDim2.new(1, -20, 0, 35)
ScanBtn.Position = UDim2.new(0, 10, 0, 560)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)

local ClearBtn = Instance.new("TextButton")
ClearBtn.Text = "🗑️ CLEAR LOG"
ClearBtn.Size = UDim2.new(1, -20, 0, 35)
ClearBtn.Position = UDim2.new(0, 10, 0, 600)
ClearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

-- Add corners
local function addCorner(obj)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = obj
end

addCorner(MainFrame)
addCorner(Title)
addCorner(ScrollingFrame)
addCorner(ScanBtn)
addCorner(ClearBtn)

-- Parent everything
LogLabel.Parent = ScrollingFrame
Title.Parent = MainFrame
ScrollingFrame.Parent = MainFrame
ScanBtn.Parent = MainFrame
ClearBtn.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- Update log
local function addLog(text, color)
    color = color or Color3.fromRGB(255, 255, 255)
    
    local timestamp = os.date("%H:%M:%S")
    LogLabel.Text = LogLabel.Text .. string.format("[%s] ", timestamp) .. text .. "\n"
    
    -- Auto-scroll
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, LogLabel.TextBounds.Y + 20)
    ScrollingFrame.CanvasPosition = Vector2.new(0, LogLabel.TextBounds.Y)
    
    -- Also print to console
    print(text)
end

local function clearLog()
    LogLabel.Text = "LOG CLEARED\n" .. string.rep("=", 60) .. "\n"
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 100)
end

-- ===== DEEP SCAN FUNCTION =====
local function deepScanCurrentUI()
    addLog("\n🔍 DEEP SCAN STARTED", Color3.fromRGB(255, 200, 0))
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local foundValues = {}
    
    -- Scan all descendant objects
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        local objName = obj.Name
        local objType = obj.ClassName
        
        -- Check for values that might indicate lock status
        if obj:IsA("IntValue") or obj:IsA("BoolValue") 
           or obj:IsA("StringValue") or obj:IsA("NumberValue")
           or obj:IsA("ObjectValue") then
            
            local isInteresting = objName:lower():find("lock") 
                               or objName:lower():find("owned")
                               or objName:lower():find("purchased")
                               or objName:lower():find("unlocked")
                               or objName:lower():find("bought")
                               or objName:lower():find("equipped")
            
            if isInteresting then
                local valueType = obj.ClassName
                local value = obj.Value
                
                addLog(string.format("📊 %s (%s) = %s", 
                    objName, valueType, tostring(value)), Color3.fromRGB(200, 220, 255))
                
                -- Store for summary
                table.insert(foundValues, {
                    name = objName,
                    type = valueType,
                    value = value,
                    path = obj:GetFullName()
                })
            end
        end
        
        -- Also check TextLabels/Buttons that show status
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            local text = obj.Text
            if text and (text:lower():find("locked") 
               or text:lower():find("buy") 
               or text:lower():find("purchase")
               or text:lower():find("equip")) then
                
                addLog(string.format("📝 %s: \"%s\"", objName, text), Color3.fromRGB(255, 255, 200))
            end
        end
    end
    
    -- Summary
    addLog("\n📊 SCAN SUMMARY:", Color3.fromRGB(255, 200, 0))
    addLog("Found " .. #foundValues .. " interesting values")
    
    -- Group by type
    local byType = {}
    for _, v in ipairs(foundValues) do
        byType[v.type] = (byType[v.type] or 0) + 1
    end
    
    for typeName, count in pairs(byType) do
        addLog(string.format("  %s: %d", typeName, count), Color3.fromRGB(200, 200, 255))
    end
    
    -- Show most promising values to modify
    addLog("\n🎯 RECOMMENDED MODIFICATIONS:", Color3.fromRGB(255, 200, 0))
    for _, v in ipairs(foundValues) do
        if v.type == "IntValue" and tonumber(v.value) == 0 then
            addLog(string.format("  Change %s from 0 to 1", v.name), Color3.fromRGB(0, 255, 0))
        elseif v.type == "BoolValue" and v.value == false then
            addLog(string.format("  Change %s from false to true", v.name), Color3.fromRGB(0, 255, 0))
        elseif v.type == "StringValue" and tostring(v.value):lower() == "locked" then
            addLog(string.format("  Change %s from '%s' to 'unlocked'", v.name, v.value), Color3.fromRGB(0, 255, 0))
        end
    end
    
    return foundValues
end

-- ===== MONITOR CLICKS =====
local function monitorClicks()
    addLog("\n🖱️ CLICK MONITOR ENABLED", Color3.fromRGB(255, 200, 0))
    addLog("Click any button in the shop to see what happens", Color3.fromRGB(255, 255, 200))
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Hook into all buttons
    for _, button in pairs(PlayerGui:GetDescendants()) do
        if button:IsA("TextButton") or button:IsA("ImageButton") then
            local originalClick = button.MouseButton1Click
            
            button.MouseButton1Click:Connect(function()
                addLog("\n🖱️ BUTTON CLICKED:", Color3.fromRGB(255, 100, 255))
                addLog("  Button: " .. button.Name, Color3.fromRGB(255, 200, 255))
                if button:IsA("TextButton") then
                    addLog("  Text: " .. button.Text, Color3.fromRGB(255, 200, 255))
                end
                addLog("  Path: " .. button:GetFullName(), Color3.fromRGB(255, 200, 255))
                
                -- Show parent hierarchy
                local parent = button.Parent
                local depth = 0
                while parent and depth < 5 do
                    addLog("  Parent " .. depth .. ": " .. parent.Name, Color3.fromRGB(200, 200, 200))
                    
                    -- Check for values in parent
                    for _, child in pairs(parent:GetChildren()) do
                        if child:IsA("IntValue") or child:IsA("BoolValue") 
                           or child:IsA("StringValue") then
                            addLog(string.format("    📊 %s = %s", 
                                child.Name, tostring(child.Value)), Color3.fromRGB(150, 200, 255))
                        end
                    end
                    
                    parent = parent.Parent
                    depth = depth + 1
                end
                
                -- Call original click if it exists
                if originalClick then
                    originalClick()
                end
            end)
        end
    end
end

-- ===== MONITOR VALUE CHANGES =====
local function monitorValueChanges()
    addLog("\n📈 VALUE CHANGE MONITOR ENABLED", Color3.fromRGB(255, 200, 0))
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Monitor all value changes
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("IntValue") or obj:IsA("BoolValue") 
           or obj:IsA("StringValue") or obj:IsA("NumberValue") then
            
            -- Hook the Value property
            local originalValue = obj.Value
            
            local mt = getrawmetatable(obj)
            local oldIndex = mt.__index
            
            mt.__index = newcclosure(function(self, key)
                if key == "Value" then
                    local currentValue = oldIndex(self, key)
                    if currentValue ~= originalValue then
                        addLog(string.format("🔄 %s changed: %s → %s", 
                            obj.Name, tostring(originalValue), tostring(currentValue)), 
                            Color3.fromRGB(0, 255, 255))
                        originalValue = currentValue
                    end
                end
                return oldIndex(self, key)
            end)
        end
    end
end

-- ===== QUICK MODIFY FUNCTION =====
local function quickModifyAll()
    addLog("\n⚡ QUICK MODIFY ATTEMPT", Color3.fromRGB(255, 200, 0))
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local modified = 0
    
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("IntValue") and obj.Name:lower():find("lock") then
            if obj.Value == 0 then
                obj.Value = 1
                addLog("✅ Changed " .. obj.Name .. " from 0 to 1", Color3.fromRGB(0, 255, 0))
                modified = modified + 1
            end
        elseif obj:IsA("BoolValue") and obj.Name:lower():find("lock") then
            if obj.Value == false then
                obj.Value = true
                addLog("✅ Changed " .. obj.Name .. " from false to true", Color3.fromRGB(0, 255, 0))
                modified = modified + 1
            end
        elseif obj:IsA("TextButton") then
            local text = obj.Text:lower()
            if text:find("buy") or text:find("purchase") then
                obj.Text = "EQUIP"
                obj.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                addLog("✅ Changed button text to EQUIP", Color3.fromRGB(0, 255, 0))
                modified = modified + 1
            end
        end
    end
    
    addLog("📊 Modified " .. modified .. " items", Color3.fromRGB(255, 200, 0))
    
    if modified > 0 then
        addLog("🎉 Try clicking EQUIP buttons now!", Color3.fromRGB(0, 255, 0))
    else
        addLog("❌ No items to modify - open the shop first", Color3.fromRGB(255, 100, 100))
    end
end

-- Connect buttons
ScanBtn.MouseButton1Click:Connect(function()
    ScanBtn.Text = "SCANNING..."
    deepScanCurrentUI()
    ScanBtn.Text = "🔍 SCAN CURRENT UI"
end)

ClearBtn.MouseButton1Click:Connect(function()
    clearLog()
end)

-- Add a quick modify button
local ModifyBtn = Instance.new("TextButton")
ModifyBtn.Text = "⚡ QUICK MODIFY"
ModifyBtn.Size = UDim2.new(1, -20, 0, 35)
ModifyBtn.Position = UDim2.new(0, 10, 0, 635)
ModifyBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
addCorner(ModifyBtn)
ModifyBtn.Parent = MainFrame

ModifyBtn.MouseButton1Click:Connect(function()
    ModifyBtn.Text = "MODIFYING..."
    quickModifyAll()
    ModifyBtn.Text = "⚡ QUICK MODIFY"
end)

-- Initial instructions
addLog("🔍 DEBUGGER READY", Color3.fromRGB(0, 200, 255))
addLog(string.rep("=", 60), Color3.fromRGB(100, 100, 100))
addLog("INSTRUCTIONS:", Color3.fromRGB(200, 220, 255))
addLog("1. Open car customization shop", Color3.fromRGB(255, 255, 200))
addLog("2. Browse different cosmetics", Color3.fromRGB(255, 255, 200))
addLog("3. Click SCAN to see current values", Color3.fromRGB(255, 255, 200))
addLog("4. Click buttons in shop to monitor", Color3.fromRGB(255, 255, 200))
addLog("5. Click QUICK MODIFY to try unlocking", Color3.fromRGB(255, 255, 200))
addLog(string.rep("=", 60), Color3.fromRGB(100, 100, 100))

-- Start monitors
task.wait(1)
monitorClicks()
monitorValueChanges()

-- Auto-scan after 3 seconds
task.wait(3)
addLog("\n⏰ Auto-scanning UI in 2 seconds...", Color3.fromRGB(255, 200, 0))
task.wait(2)

ScanBtn.Text = "SCANNING..."
deepScanCurrentUI()
ScanBtn.Text = "🔍 SCAN CURRENT UI"

-- Auto-modify after scan
task.wait(1)
addLog("\n⏰ Attempting auto-modify...", Color3.fromRGB(255, 200, 0))
ModifyBtn.Text = "MODIFYING..."
quickModifyAll()
ModifyBtn.Text = "⚡ QUICK MODIFY"
