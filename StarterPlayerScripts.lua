-- 🎯 CDT TRADE OFFER DETECTOR - DYNAMIC VERSION
-- Finds ANY trade UI and shows what's inside

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CDT Trade Offer Detector - Dynamic Scan")

-- ===== FIND ANY TRADE UI =====
local function FindAnyTradeUI()
    if not Player.PlayerGui then return nil end
    
    local function deepSearch(parent, depth)
        if depth > 15 then return nil end
        
        for _, child in pairs(parent:GetChildren()) do
            local nameLower = child.Name:lower()
            
            -- Look for trade UI indicators
            if child:IsA("ScreenGui") or child:IsA("Frame") then
                if nameLower:find("trade") or nameLower:find("peer") then
                    if child.Visible then
                        print("🎯 Found VISIBLE trade UI: " .. child.Name .. " at " .. child:GetFullName())
                        return child
                    end
                end
            end
            
            if #child:GetChildren() > 0 then
                local found = deepSearch(child, depth + 1)
                if found then return found end
            end
        end
        
        return nil
    end
    
    return deepSearch(Player.PlayerGui, 0)
end

-- ===== SCAN ALL VISIBLE FRAMES FOR OFFERED ITEMS =====
local function ScanAllVisibleItems()
    local foundItems = {}
    
    if not Player.PlayerGui then return foundItems end
    
    -- First, find if there's a visible trade UI
    local tradeUI = FindAnyTradeUI()
    
    if tradeUI then
        print("🔍 Scanning trade UI for items...")
        
        -- Look for ANY frames/buttons that might be items
        for _, child in pairs(tradeUI:GetDescendants()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
                if child.Visible then
                    local name = child.Name
                    
                    -- Skip common UI elements
                    if name == "" or name:find("Background") or name:find("Border") 
                       or name:find("Corner") or name:find("Padding") 
                       or name:find("Layout") or name:find("Shadow") then
                        continue
                    end
                    
                    -- Look for car indicators
                    if name:find("Car") or name:find("car") or name:match("%-") or name:match("%_") then
                        local itemInfo = {
                            Name = name,
                            DisplayName = name,
                            Object = child,
                            Path = child:GetFullName(),
                            Class = child.ClassName,
                            Visible = child.Visible
                        }
                        
                        -- Try to get text from TextButton
                        if child:IsA("TextButton") and child.Text ~= "" then
                            itemInfo.DisplayName = child.Text
                        end
                        
                        -- Look for text labels
                        for _, sub in pairs(child:GetChildren()) do
                            if sub:IsA("TextLabel") and sub.Text ~= "" then
                                if sub.Name:lower():find("name") or sub.Text:len() > 3 then
                                    itemInfo.DisplayName = sub.Text
                                end
                            end
                        end
                        
                        -- Check if this is likely an item (not a container)
                        local childCount = #child:GetChildren()
                        if childCount < 10 then  -- Items usually have few children
                            table.insert(foundItems, itemInfo)
                            print("📦 Found potential item: " .. itemInfo.DisplayName .. " (" .. child.ClassName .. ")")
                        end
                    end
                end
            end
        end
    end
    
    -- If no trade UI found, scan entire PlayerGui for visible items
    if #foundItems == 0 then
        print("🔍 Scanning entire PlayerGui for visible car items...")
        
        for _, child in pairs(Player.PlayerGui:GetDescendants()) do
            if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
                if child.Visible then
                    local name = child.Name
                    
                    if name:find("Car") or name:find("Nissan") or name:find("Subaru") then
                        local absPos = child.AbsolutePosition
                        local screenSize = workspace.CurrentCamera.ViewportSize
                        
                        -- Only show items on screen (not offscreen)
                        if absPos.X > 0 and absPos.X < screenSize.X 
                           and absPos.Y > 0 and absPos.Y < screenSize.Y then
                            
                            local itemInfo = {
                                Name = name,
                                DisplayName = name,
                                Object = child,
                                Path = child:GetFullName(),
                                Position = absPos,
                                ScreenPosition = UDim2.new(0, absPos.X / screenSize.X, 0, absPos.Y / screenSize.Y)
                            }
                            
                            print("📍 Visible on screen: " .. name .. " at " .. tostring(math.floor(absPos.X)) .. "," .. tostring(math.floor(absPos.Y)))
                            table.insert(foundItems, itemInfo)
                        end
                    end
                end
            end
        end
    end
    
    return foundItems
end

-- ===== CREATE VISUAL OVERLAY UI =====
local function CreateOverlayUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TradeOverlay"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Control Panel
    local ControlPanel = Instance.new("Frame")
    ControlPanel.Size = UDim2.new(0, 400, 0, 150)
    ControlPanel.Position = UDim2.new(0.5, -200, 0, 10)
    ControlPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    ControlPanel.BorderSizePixel = 0
    ControlPanel.Active = true
    ControlPanel.Draggable = true
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🔍 LIVE TRADE ITEM SCANNER"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "Ready - Start a trade and add items"
    Status.Size = UDim2.new(1, -20, 0, 40)
    Status.Position = UDim2.new(0, 10, 0, 40)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(200, 200, 255)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 14
    Status.TextWrapped = true
    
    -- Scan Button
    local ScanButton = Instance.new("TextButton")
    ScanButton.Text = "🔍 SCAN NOW"
    ScanButton.Size = UDim2.new(0.45, 0, 0, 35)
    ScanButton.Position = UDim2.new(0.025, 0, 1, -45)
    ScanButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanButton.Font = Enum.Font.GothamBold
    
    -- Debug Button
    local DebugButton = Instance.new("TextButton")
    DebugButton.Text = "🐛 DEBUG VIEW"
    DebugButton.Size = UDim2.new(0.45, 0, 0, 35)
    DebugButton.Position = UDim2.new(0.525, 0, 1, -45)
    DebugButton.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    DebugButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DebugButton.Font = Enum.Font.GothamBold
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = ControlPanel
    corner:Clone().Parent = Title
    corner:Clone().Parent = ScanButton
    corner:Clone().Parent = DebugButton
    
    -- Parent
    Title.Parent = ControlPanel
    Status.Parent = ControlPanel
    ScanButton.Parent = ControlPanel
    DebugButton.Parent = ControlPanel
    ControlPanel.Parent = ScreenGui
    
    -- Item Highlight Overlays (will be created dynamically)
    local highlightContainer = Instance.new("Frame")
    highlightContainer.Size = UDim2.new(1, 0, 1, 0)
    highlightContainer.BackgroundTransparency = 1
    highlightContainer.Parent = ScreenGui
    
    -- Functions
    local function updateStatus(text, color)
        Status.Text = text
        Status.TextColor3 = color or Color3.fromRGB(200, 200, 255)
    end
    
    local function clearHighlights()
        for _, child in pairs(highlightContainer:GetChildren()) do
            child:Destroy()
        end
    end
    
    local function createHighlight(item)
        local highlight = Instance.new("Frame")
        highlight.Name = "Highlight_" .. item.Name
        highlight.BackgroundTransparency = 0.8
        highlight.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        highlight.BorderSizePixel = 0
        highlight.ZIndex = 999
        
        -- Position highlight around the item
        if item.Position then
            highlight.Size = UDim2.new(0, 100, 0, 100)
            highlight.Position = UDim2.new(
                0, item.Position.X - 50,
                0, item.Position.Y - 50
            )
            
            -- Add label
            local label = Instance.new("TextLabel")
            label.Text = item.DisplayName
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 0, 1, 0)
            label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 12
            label.Parent = highlight
        end
        
        highlight.Parent = highlightContainer
        return highlight
    end
    
    local function performScan()
        clearHighlights()
        updateStatus("🔍 Scanning...", Color3.fromRGB(255, 200, 100))
        
        local items = ScanAllVisibleItems()
        
        if #items > 0 then
            updateStatus("✅ Found " .. #items .. " item(s)", Color3.fromRGB(100, 255, 100))
            
            -- Create highlights for found items
            for _, item in ipairs(items) do
                if item.Position then
                    createHighlight(item)
                end
                
                -- Show in output
                print("📋 Item: " .. item.DisplayName)
                print("   Path: " .. item.Path)
                print("   Class: " .. item.Class)
                if item.Position then
                    print("   Position: " .. tostring(item.Position.X) .. ", " .. tostring(item.Position.Y))
                end
                print(string.rep("-", 40))
            end
        else
            updateStatus("❌ No items found", Color3.fromRGB(255, 100, 100))
        end
    end
    
    local function showDebugView()
        clearHighlights()
        updateStatus("🐛 Debug: Showing ALL visible UI elements...", Color3.fromRGB(255, 150, 200))
        
        if not Player.PlayerGui then return end
        
        local visibleCount = 0
        for _, child in pairs(Player.PlayerGui:GetDescendants()) do
            if child:IsA("GuiObject") and child.Visible then
                visibleCount = visibleCount + 1
                
                -- Only highlight interesting elements
                if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("ImageButton") then
                    local absPos = child.AbsolutePosition
                    local absSize = child.AbsoluteSize
                    
                    if absPos.X > 0 and absPos.Y > 0 and absSize.X > 10 and absSize.Y > 10 then
                        local highlight = Instance.new("Frame")
                        highlight.Name = "Debug_" .. child.Name
                        highlight.BackgroundTransparency = 0.9
                        highlight.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
                        highlight.BorderSizePixel = 1
                        highlight.BorderColor3 = Color3.fromRGB(255, 255, 255)
                        highlight.ZIndex = 998
                        
                        highlight.Size = UDim2.new(0, absSize.X, 0, absSize.Y)
                        highlight.Position = UDim2.new(0, absPos.X, 0, absPos.Y)
                        
                        local label = Instance.new("TextLabel")
                        label.Text = child.Name .. "\n" .. child.ClassName
                        label.Size = UDim2.new(1, 0, 0, 30)
                        label.Position = UDim2.new(0, 0, 1, 0)
                        label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        label.TextColor3 = Color3.fromRGB(255, 255, 255)
                        label.Font = Enum.Font.Gotham
                        label.TextSize = 10
                        label.TextWrapped = true
                        label.Parent = highlight
                        
                        highlight.Parent = highlightContainer
                    end
                end
            end
        end
        
        updateStatus("🐛 " .. visibleCount .. " visible elements highlighted", Color3.fromRGB(255, 150, 200))
    end
    
    -- Event handlers
    ScanButton.MouseButton1Click:Connect(performScan)
    DebugButton.MouseButton1Click:Connect(showDebugView)
    
    -- Auto-scan every 3 seconds
    spawn(function()
        while task.wait(3) do
            if ScreenGui and ScreenGui.Parent then
                performScan()
            end
        end
    end)
    
    -- Initial scan
    task.wait(1)
    performScan()
    
    return ScreenGui
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("🎯 CDT TRADE ITEM DETECTOR")
print("📍 Will find ANY visible trade items on screen")
print("🔍 Auto-scans every 3 seconds")
print(string.rep("=", 60))

-- Create the overlay UI
CreateOverlayUI()

print("\n✅ Overlay UI created!")
print("💡 Controls:")
print("   • Drag the panel to move it")
print("   • SCAN NOW: Manual scan")
print("   • DEBUG VIEW: Show ALL visible UI elements")
print("   • Green highlights: Found items")
print("   • Magenta highlights: All UI elements (debug)")
print("\n🎮 Start a trade, add items, then click SCAN NOW!")
print("📊 Watch Output for detailed item information")
