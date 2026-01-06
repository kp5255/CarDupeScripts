-- 🔍 DEBUG SCRIPT - SHOW ALL UI DATA
-- Shows everything in the UI to find how items are stored

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🔍 DEBUG SCRIPT LOADED")

-- Create debug UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DebugViewerUI"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 700)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -350)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)

local Title = Instance.new("TextLabel")
Title.Text = "🔍 UI DATA VIEWER"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold

local Output = Instance.new("ScrollingFrame")
Output.Size = UDim2.new(1, -20, 0, 600)
Output.Position = UDim2.new(0, 10, 0, 50)
Output.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
Output.ScrollBarThickness = 8
Output.CanvasSize = UDim2.new(0, 0, 0, 0)

local OutputText = Instance.new("TextLabel")
OutputText.Text = "DEBUG VIEWER READY\n" .. string.rep("=", 70) .. "\n"
OutputText.Size = UDim2.new(1, -10, 0, 0)
OutputText.Position = UDim2.new(0, 5, 0, 5)
OutputText.BackgroundTransparency = 1
OutputText.TextColor3 = Color3.fromRGB(255, 255, 255)
OutputText.Font = Enum.Font.Code
OutputText.TextSize = 12
OutputText.TextXAlignment = Enum.TextXAlignment.Left
OutputText.TextYAlignment = Enum.TextYAlignment.Top
OutputText.TextWrapped = true
OutputText.AutomaticSize = Enum.AutomaticSize.Y

local ScanBtn = Instance.new("TextButton")
ScanBtn.Text = "🔍 SCAN CURRENT UI"
ScanBtn.Size = UDim2.new(1, -20, 0, 40)
ScanBtn.Position = UDim2.new(0, 10, 0, 660)
ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)

-- Add corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)

corner:Clone().Parent = MainFrame
corner:Clone().Parent = Title
corner:Clone().Parent = Output
corner:Clone().Parent = ScanBtn

-- Parent
OutputText.Parent = Output
Title.Parent = MainFrame
Output.Parent = MainFrame
ScanBtn.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- Function to add text
local function addDebug(text, color)
    color = color or Color3.fromRGB(255, 255, 255)
    OutputText.Text = OutputText.Text .. text .. "\n"
    Output.CanvasSize = UDim2.new(0, 0, 0, OutputText.TextBounds.Y + 20)
    Output.CanvasPosition = Vector2.new(0, OutputText.TextBounds.Y)
    print(text)
end

-- Clear function
local function clearDebug()
    OutputText.Text = "DEBUG VIEWER\n" .. string.rep("=", 70) .. "\n"
end

-- Detailed scan function
local function detailedUIScan()
    clearDebug()
    addDebug("🔍 STARTING DETAILED UI SCAN...", Color3.fromRGB(255, 200, 0))
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local totalObjects = 0
    local interestingObjects = {}
    
    addDebug("\n📁 SCANNING ALL OBJECTS IN Playergui...")
    
    -- First, show the structure
    addDebug("📂 Top-level children:", Color3.fromRGB(200, 200, 255))
    for _, child in pairs(PlayerGui:GetChildren()) do
        addDebug("  " .. child.Name .. " (" .. child.ClassName .. ")")
    end
    
    -- Now scan everything
    addDebug("\n🔎 DETAILED SCAN:", Color3.fromRGB(200, 220, 255))
    
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        totalObjects = totalObjects + 1
        
        -- Only show interesting objects
        local isInteresting = false
        
        -- Check class type
        if obj:IsA("StringValue") or obj:IsA("IntValue") or obj:IsA("BoolValue") 
           or obj:IsA("NumberValue") or obj:IsA("ObjectValue") then
            isInteresting = true
        elseif obj:IsA("TextButton") or obj:IsA("TextLabel") then
            -- Check if it has interesting text
            local text = obj.Text or ""
            if text:find("buy", 1, true) or text:find("purchase", 1, true) 
               or text:find("equip", 1, true) or text:find("locked", 1, true) 
               or obj.Name:find("wrap", 1, true) or obj.Name:find("kit", 1, true) 
               or obj.Name:find("wheel", 1, true) then
                isInteresting = true
            end
        elseif obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
            -- Check if it's a shop/customization container
            local name = obj.Name:lower()
            if name:find("shop") or name:find("custom") 
               or name:find("inventory") or name:find("menu") then
                isInteresting = true
            end
        end
        
        if isInteresting then
            table.insert(interestingObjects, obj)
            
            -- Show object info
            local indent = string.rep("  ", obj:GetFullName():gsub("[^%.]", ""):len())
            local line = indent .. obj.Name .. " (" .. obj.ClassName .. ")"
            
            -- Add extra info based on type
            if obj:IsA("StringValue") or obj:IsA("IntValue") 
               or obj:IsA("BoolValue") or obj:IsA("NumberValue") then
                line = line .. " = " .. tostring(obj.Value)
                
                -- Check for GUID pattern
                local valueStr = tostring(obj.Value)
                if valueStr:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
                    line = line .. " 🎯 <-- THIS IS A GUID!"
                end
            elseif obj:IsA("TextButton") or obj:IsA("TextLabel") then
                if obj.Text and obj.Text ~= "" then
                    line = line .. ' Text: "' .. obj.Text .. '"'
                end
            end
            
            addDebug(line)
        end
    end
    
    -- Summary
    addDebug("\n📊 SCAN SUMMARY:", Color3.fromRGB(255, 200, 0))
    addDebug("Total objects scanned: " .. totalObjects)
    addDebug("Interesting objects found: " .. #interestingObjects)
    
    -- Look specifically for the paths you showed earlier
    addDebug("\n🎯 LOOKING FOR KNOWN PATHS:", Color3.fromRGB(255, 200, 0))
    local knownPaths = {
        "Menu.Inventory.Cars",
        "Menu.Inventory.CarConfig",
        "Customization",
        "Shop"
    }
    
    for _, path in pairs(knownPaths) do
        local obj = PlayerGui:FindFirstChild(path, true)
        if obj then
            addDebug("✅ Found: " .. obj:GetFullName())
            
            -- Show its children
            for _, child in pairs(obj:GetChildren()) do
                addDebug("  ├─ " .. child.Name .. " (" .. child.ClassName .. ")")
            end
        else
            addDebug("❌ Not found: " .. path)
        end
    end
    
    -- Try to find ANY StringValues with ANY content
    addDebug("\n🔎 ALL STRING VALUES:", Color3.fromRGB(200, 220, 255))
    local stringCount = 0
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("StringValue") then
            stringCount = stringCount + 1
            local value = tostring(obj.Value)
            if value ~= "" then
                addDebug("  " .. obj.Name .. " = \"" .. value .. "\"")
            end
        end
    end
    addDebug("Total StringValues found: " .. stringCount)
    
    addDebug("\n✅ SCAN COMPLETE", Color3.fromRGB(0, 255, 0))
end

-- Connect scan button
ScanBtn.MouseButton1Click:Connect(function()
    ScanBtn.Text = "SCANNING..."
    detailedUIScan()
    ScanBtn.Text = "🔍 SCAN CURRENT UI"
end)

-- Initial instructions
addDebug("🔍 UI DATA DEBUGGER", Color3.fromRGB(0, 200, 255))
addDebug(string.rep("=", 70))
addDebug("INSTRUCTIONS:", Color3.fromRGB(200, 220, 255))
addDebug("1. Open car customization shop", Color3.fromRGB(255, 255, 200))
addDebug("2. Browse wraps/kits/wheels", Color3.fromRGB(255, 255, 200))
addDebug("3. Click SCAN CURRENT UI", Color3.fromRGB(255, 255, 200))
addDebug("4. Look for GUIDs or item IDs", Color3.fromRGB(255, 255, 200))
addDebug(string.rep("=", 70))
addDebug("\n🎯 Look for lines ending with: 🎯 <-- THIS IS A GUID!")
addDebug("🎯 Or look for StringValues with long codes")
addDebug(string.rep("=", 70))

-- Auto-scan after 3 seconds
task.wait(3)
addDebug("\n⏰ Auto-scanning in 2 seconds...", Color3.fromRGB(255, 200, 0))
task.wait(2)

ScanBtn.Text = "SCANNING..."
detailedUIScan()
ScanBtn.Text = "🔍 SCAN CURRENT UI"
