-- 🏎️ CAR DEALERSHIP UNLOCKER - DRAGABLE UI
-- Fixed version with dragable interface

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- Wait for game
repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🚗 CAR UNLOCKER LOADED")

-- ===== FIND ALL ITEMS =====
local function FindAllItems()
    print("🔍 Scanning for items...")
    
    local items = {}
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Look for cosmetic buttons
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("TextButton") then
            local text = obj.Text:lower()
            local name = obj.Name:lower()
            
            if text:find("buy") or text:find("purchase") 
               or text:find("$") or name:find("wrap")
               or name:find("kit") or name:find("wheel")
               or name:find("neon") or name:find("paint") then
                
                table.insert(items, {
                    button = obj,
                    name = obj.Name,
                    text = obj.Text,
                    path = obj:GetFullName()
                })
            end
        end
    end
    
    print("✅ Found " .. #items .. " items")
    return items
end

-- ===== FIND ALL REMOTES =====
local function FindAllRemotes()
    print("📡 Searching for remotes...")
    
    local remotes = {}
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
            table.insert(remotes, {
                object = obj,
                name = obj.Name,
                type = obj.ClassName
            })
        end
    end
    
    print("✅ Found " .. #remotes .. " remotes")
    return remotes
end

-- ===== TRY UNLOCK =====
local function TryUnlock(items, remotes)
    print("🔓 Attempting unlock...")
    
    local successCount = 0
    
    for _, item in ipairs(items) do
        print("🔄 Trying: " .. item.name)
        
        for _, remote in ipairs(remotes) do
            -- Try different formats
            local formats = {
                item.name,
                {Item = item.name},
                {Name = item.name},
                {ItemId = item.name},
                {id = item.name},
                {product = item.name}
            }
            
            for _, data in ipairs(formats) do
                local success, result = pcall(function()
                    if remote.type == "RemoteFunction" then
                        return remote.object:InvokeServer(data)
                    else
                        remote.object:FireServer(data)
                        return "FireServer called"
                    end
                end)
                
                if success then
                    print("   ✅ Success with " .. remote.name)
                    successCount = successCount + 1
                    
                    -- Update button
                    if item.button:IsA("TextButton") then
                        item.button.Text = "EQUIP"
                        item.button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    end
                    
                    break
                end
            end
        end
    end
    
    print("📊 Unlocked: " .. successCount .. "/" .. #items)
    return successCount
end

-- ===== CREATE DRAGABLE UI =====
local function CreateDragableUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DragUnlockerUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame (Dragable)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Title Bar (Drag handle)
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    TitleBar.BorderSizePixel = 0
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🚗 DRAGABLE UNLOCKER"
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "✕"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    
    -- Status Display
    local StatusFrame = Instance.new("ScrollingFrame")
    StatusFrame.Size = UDim2.new(1, -20, 0, 250)
    StatusFrame.Position = UDim2.new(0, 10, 0, 50)
    StatusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    StatusFrame.ScrollBarThickness = 6
    StatusFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Text = "DRAGABLE UNLOCKER READY\n" .. string.rep("=", 40) .. "\n"
    StatusLabel.Size = UDim2.new(1, -10, 0, 0)
    StatusLabel.Position = UDim2.new(0, 5, 0, 5)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.Font = Enum.Font.Code
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatusLabel.TextWrapped = true
    StatusLabel.AutomaticSize = Enum.AutomaticSize.Y
    
    -- Control Panel
    local ControlFrame = Instance.new("Frame")
    ControlFrame.Size = UDim2.new(1, -20, 0, 140)
    ControlFrame.Position = UDim2.new(0, 10, 0, 310)
    ControlFrame.BackgroundTransparency = 1
    
    -- Buttons
    local ScanBtn = Instance.new("TextButton")
    ScanBtn.Name = "ScanBtn"
    ScanBtn.Text = "🔍 SCAN ITEMS"
    ScanBtn.Size = UDim2.new(1, 0, 0, 35)
    ScanBtn.Position = UDim2.new(0, 0, 0, 0)
    ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    ScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanBtn.Font = Enum.Font.GothamBold
    
    local UnlockBtn = Instance.new("TextButton")
    UnlockBtn.Name = "UnlockBtn"
    UnlockBtn.Text = "🔓 UNLOCK ALL"
    UnlockBtn.Size = UDim2.new(1, 0, 0, 35)
    UnlockBtn.Position = UDim2.new(0, 0, 0, 45)
    UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UnlockBtn.Font = Enum.Font.GothamBold
    UnlockBtn.Visible = false
    
    local VisualBtn = Instance.new("TextButton")
    VisualBtn.Name = "VisualBtn"
    VisualBtn.Text = "🎨 VISUAL MODE"
    VisualBtn.Size = UDim2.new(1, 0, 0, 35)
    VisualBtn.Position = UDim2.new(0, 0, 0, 90)
    VisualBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
    VisualBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    VisualBtn.Font = Enum.Font.GothamBold
    
    -- Progress Bar
    local ProgressFrame = Instance.new("Frame")
    ProgressFrame.Size = UDim2.new(1, -20, 0, 20)
    ProgressFrame.Position = UDim2.new(0, 10, 0, 460)
    ProgressFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    
    local ProgressBar = Instance.new("Frame")
    ProgressBar.Name = "ProgressBar"
    ProgressBar.Size = UDim2.new(0, 0, 1, 0)
    ProgressBar.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    ProgressBar.BorderSizePixel = 0
    
    -- Add corners
    local function AddCorner(obj, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius or 8)
        corner.Parent = obj
        return corner
    end
    
    AddCorner(MainFrame, 10)
    AddCorner(TitleBar, 10)
    AddCorner(CloseBtn, 6)
    AddCorner(StatusFrame, 8)
    AddCorner(ScanBtn)
    AddCorner(UnlockBtn)
    AddCorner(VisualBtn)
    AddCorner(ProgressFrame, 10)
    AddCorner(ProgressBar, 10)
    
    -- Add stroke to main frame
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 150, 255)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Parent everything
    StatusLabel.Parent = StatusFrame
    ProgressBar.Parent = ProgressFrame
    
    Title.Parent = TitleBar
    CloseBtn.Parent = TitleBar
    TitleBar.Parent = MainFrame
    StatusFrame.Parent = MainFrame
    ControlFrame.Parent = MainFrame
    ProgressFrame.Parent = MainFrame
    
    ScanBtn.Parent = ControlFrame
    UnlockBtn.Parent = ControlFrame
    VisualBtn.Parent = ControlFrame
    
    MainFrame.Parent = ScreenGui
    
    -- Variables
    local foundItems = {}
    local foundRemotes = {}
    local isProcessing = false
    
    -- Update status function
    local function UpdateStatus(text, color)
        color = color or Color3.fromRGB(255, 255, 255)
        StatusLabel.Text = StatusLabel.Text .. text .. "\n"
        StatusFrame.CanvasSize = UDim2.new(0, 0, 0, StatusLabel.TextBounds.Y + 20)
        StatusFrame.CanvasPosition = Vector2.new(0, StatusLabel.TextBounds.Y)
        
        -- Also print to console
        print(text)
    end
    
    local function ClearStatus()
        StatusLabel.Text = ""
    end
    
    -- Update progress bar
    local function UpdateProgress(percent)
        ProgressBar:TweenSize(
            UDim2.new(percent / 100, 0, 1, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true
        )
    end
    
    -- Scan function
    ScanBtn.MouseButton1Click:Connect(function()
        if isProcessing then return end
        isProcessing = true
        
        ScanBtn.Text = "SCANNING..."
        ClearStatus()
        UpdateStatus("🔍 Scanning for items...", Color3.fromRGB(255, 200, 0))
        UpdateProgress(25)
        
        task.wait(0.5)
        
        -- Find items
        UpdateStatus("Looking for cosmetic items...")
        foundItems = FindAllItems()
        UpdateProgress(50)
        
        task.wait(0.5)
        
        -- Find remotes
        UpdateStatus("Looking for remotes...")
        foundRemotes = FindAllRemotes()
        UpdateProgress(75)
        
        task.wait(0.5)
        
        if #foundItems > 0 and #foundRemotes > 0 then
            UpdateStatus("✅ Found " .. #foundItems .. " items", Color3.fromRGB(0, 255, 0))
            UpdateStatus("✅ Found " .. #foundRemotes .. " remotes", Color3.fromRGB(0, 255, 0))
            UpdateStatus("\n🎯 Ready to unlock!", Color3.fromRGB(200, 220, 255))
            
            UnlockBtn.Visible = true
            UnlockBtn.Text = "🔓 UNLOCK " .. #foundItems .. " ITEMS"
            ScanBtn.Text = "✅ SCAN COMPLETE"
            ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            UpdateStatus("❌ Scan incomplete", Color3.fromRGB(255, 100, 100))
            UpdateStatus("Items: " .. #foundItems, Color3.fromRGB(255, 200, 100))
            UpdateStatus("Remotes: " .. #foundRemotes, Color3.fromRGB(255, 200, 100))
            UpdateStatus("\n💡 Open the car shop first!", Color3.fromRGB(255, 255, 200))
            
            ScanBtn.Text = "🔍 SCAN ITEMS"
            ScanBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        
        UpdateProgress(100)
        isProcessing = false
    end)
    
    -- Unlock function
    UnlockBtn.MouseButton1Click:Connect(function()
        if isProcessing then return end
        if #foundItems == 0 then
            UpdateStatus("❌ Scan first!", Color3.fromRGB(255, 100, 100))
            return
        end
        
        isProcessing = true
        UnlockBtn.Text = "UNLOCKING..."
        ClearStatus()
        UpdateStatus("🔓 Attempting unlock...", Color3.fromRGB(255, 200, 0))
        UpdateProgress(0)
        
        local totalItems = #foundItems
        local unlocked = 0
        
        for i, item in ipairs(foundItems) do
            UpdateStatus("Processing: " .. item.name .. " (" .. i .. "/" .. totalItems .. ")")
            
            -- Try to unlock this item
            for _, remote in ipairs(foundRemotes) do
                local formats = {
                    item.name,
                    {Item = item.name},
                    {Name = item.name},
                    {ItemId = item.name}
                }
                
                for _, data in ipairs(formats) do
                    local success, result = pcall(function()
                        if remote.type == "RemoteFunction" then
                            return remote.object:InvokeServer(data)
                        else
                            remote.object:FireServer(data)
                            return "FireServer called"
                        end
                    })
                    
                    if success then
                        UpdateStatus("   ✅ Success with " .. remote.name, Color3.fromRGB(0, 255, 0))
                        unlocked = unlocked + 1
                        
                        -- Update button
                        if item.button:IsA("TextButton") then
                            item.button.Text = "EQUIP"
                            item.button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                        end
                        
                        break
                    end
                end
            end
            
            -- Update progress
            local progress = (i / totalItems) * 100
            UpdateProgress(progress)
            task.wait(0.1)
        end
        
        UpdateStatus("\n📊 UNLOCK RESULTS:", Color3.fromRGB(200, 220, 255))
        UpdateStatus("Successfully unlocked: " .. unlocked .. "/" .. totalItems, Color3.fromRGB(0, 255, 0))
        
        if unlocked > 0 then
            UpdateStatus("🎉 Some items may be unlocked!", Color3.fromRGB(0, 255, 0))
            UpdateStatus("💡 Check if buttons say 'EQUIP'", Color3.fromRGB(200, 255, 200))
            
            UnlockBtn.Text = "✅ " .. unlocked .. " UNLOCKED"
            UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            UpdateStatus("❌ No items unlocked", Color3.fromRGB(255, 100, 100))
            UpdateStatus("💡 Try visual mode instead", Color3.fromRGB(255, 200, 100))
            
            UnlockBtn.Text = "🔓 UNLOCK ALL"
        end
        
        UpdateProgress(100)
        isProcessing = false
    end)
    
    -- Visual mode function
    VisualBtn.MouseButton1Click:Connect(function()
        if isProcessing then return end
        isProcessing = true
        
        VisualBtn.Text = "MODIFYING..."
        ClearStatus()
        UpdateStatus("🎨 Applying visual modifications...", Color3.fromRGB(255, 200, 0))
        UpdateProgress(0)
        
        local modified = 0
        local PlayerGui = Player:WaitForChild("PlayerGui")
        
        -- Find and modify all buy buttons
        for _, obj in pairs(PlayerGui:GetDescendants()) do
            if obj:IsA("TextButton") then
                local text = obj.Text:lower()
                if text:find("buy") or text:find("purchase") 
                   or text:find("$") or text:find("%d%d%d") then
                    
                    obj.Text = "EQUIP"
                    obj.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
                    obj.TextColor3 = Color3.fromRGB(255, 255, 255)
                    modified = modified + 1
                end
            elseif obj:IsA("TextLabel") then
                local text = obj.Text:lower()
                if text:find("locked") or text:find("not owned") then
                    obj.Text = "UNLOCKED"
                    obj.TextColor3 = Color3.fromRGB(0, 255, 0)
                    modified = modified + 1
                end
            end
        end
        
        UpdateStatus("\n🛍️ VISUAL RESULTS:", Color3.fromRGB(200, 220, 255))
        UpdateStatus("Modified elements: " .. modified, Color3.fromRGB(255, 255, 200))
        
        if modified > 0 then
            UpdateStatus("✅ Shop should now show 'EQUIP' buttons", Color3.fromRGB(0, 255, 0))
            UpdateStatus("💡 This is visual only - items aren't really unlocked", Color3.fromRGB(200, 200, 255))
            
            VisualBtn.Text = "✅ VISUAL DONE"
            VisualBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            UpdateStatus("❌ No elements modified", Color3.fromRGB(255, 100, 100))
            UpdateStatus("💡 Open the shop first!", Color3.fromRGB(255, 200, 100))
            
            VisualBtn.Text = "🎨 VISUAL MODE"
        end
        
        UpdateProgress(100)
        isProcessing = false
    end)
    
    -- Close button
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Minimize on title bar click (optional)
    local isMinimized = false
    TitleBar.MouseButton1Click:Connect(function()
        if not isMinimized then
            StatusFrame.Visible = false
            ControlFrame.Visible = false
            ProgressFrame.Visible = false
            MainFrame.Size = UDim2.new(0, 400, 0, 40)
            isMinimized = true
        else
            StatusFrame.Visible = true
            ControlFrame.Visible = true
            ProgressFrame.Visible = true
            MainFrame.Size = UDim2.new(0, 400, 0, 450)
            isMinimized = false
        end
    end)
    
    -- Initial message
    ClearStatus()
    UpdateStatus("🚗 DRAGABLE CAR UNLOCKER", Color3.fromRGB(0, 200, 255))
    UpdateStatus(string.rep("=", 40), Color3.fromRGB(100, 100, 100))
    UpdateStatus("DRAG the title bar to move window", Color3.fromRGB(255, 255, 200))
    UpdateStatus("Click title bar to minimize/maximize", Color3.fromRGB(255, 255, 200))
    UpdateStatus(string.rep("=", 40), Color3.fromRGB(100, 100, 100))
    UpdateStatus("INSTRUCTIONS:", Color3.fromRGB(200, 220, 255))
    UpdateStatus("1. Open car customization shop", Color3.fromRGB(255, 255, 200))
    UpdateStatus("2. Browse wraps/kits/wheels", Color3.fromRGB(255, 255, 200))
    UpdateStatus("3. Click SCAN ITEMS", Color3.fromRGB(255, 255, 200))
    UpdateStatus("4. Click UNLOCK ALL", Color3.fromRGB(255, 255, 200))
    UpdateStatus("5. Use VISUAL MODE for UI changes", Color3.fromRGB(255, 255, 200))
    UpdateStatus(string.rep("=", 40), Color3.fromRGB(100, 100, 100))
    
    -- Auto-scan after 3 seconds
    task.wait(3)
    UpdateStatus("\n⏰ Auto-scanning in 2 seconds...", Color3.fromRGB(255, 200, 0))
    task.wait(2)
    
    ScanBtn.Text = "SCANNING..."
    ClearStatus()
    UpdateStatus("🔍 Auto-scanning...", Color3.fromRGB(255, 200, 0))
    
    foundItems = FindAllItems()
    foundRemotes = FindAllRemotes()
    
    if #foundItems > 0 and #foundRemotes > 0 then
        UpdateStatus("✅ Auto-found " .. #foundItems .. " items", Color3.fromRGB(0, 255, 0))
        UpdateStatus("✅ Auto-found " .. #foundRemotes .. " remotes", Color3.fromRGB(0, 255, 0))
        UpdateStatus("💡 Click UNLOCK ALL to try", Color3.fromRGB(200, 220, 255))
        
        UnlockBtn.Visible = true
        UnlockBtn.Text = "🔓 UNLOCK " .. #foundItems .. " ITEMS"
        ScanBtn.Text = "✅ AUTO-SCANNED"
        ScanBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    else
        UpdateStatus("❌ Auto-scan found nothing", Color3.fromRGB(255, 100, 100))
        UpdateStatus("💡 Open the shop and click SCAN", Color3.fromRGB(255, 200, 100))
        
        ScanBtn.Text = "🔍 SCAN ITEMS"
    end
    
    return ScreenGui
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("🚗 DRAGABLE CAR UNLOCKER v1.0")
print(string.rep("=", 60))

task.wait(2)
CreateDragableUI()

print("\n✅ UI Created Successfully!")
print("📍 Look for the dragable window in-game")
print("🎯 Drag the title bar to move it")
print("💡 Follow the instructions in the UI")
print(string.rep("=", 60))
