-- Trade Debugger - Shows EXACTLY what's in trade
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

wait(2)

print("=== TRADE DEBUGGER ===")

-- Find trade container (same as your working scanner)
local function GetTradeContainer()
    if not Player.PlayerGui then 
        print("❌ No PlayerGui")
        return nil 
    end
    
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then 
        print("❌ No Menu")
        return nil 
    end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then 
        print("❌ No Trading")
        return nil 
    end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then 
        print("❌ No PeerToPeer")
        return nil 
    end
    
    local main = peerToPeer:FindFirstChild("Main")
    if not main then 
        print("❌ No Main")
        return nil 
    end
    
    local localPlayer = main:FindFirstChild("LocalPlayer")
    if not localPlayer then 
        print("❌ No LocalPlayer")
        return nil 
    end
    
    local content = localPlayer:FindFirstChild("Content")
    if not content then 
        print("❌ No Content")
        return nil 
    end
    
    local scrollingFrame = content:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then 
        print("❌ No ScrollingFrame")
        return nil 
    end
    
    print("✅ FOUND CONTAINER: " .. scrollingFrame:GetFullName())
    return scrollingFrame
end

-- Show EVERYTHING in the container
local function DebugContainer()
    print("\n🔍 DEBUGGING CONTAINER...")
    
    local container = GetTradeContainer()
    if not container then
        print("No trade container found")
        return
    end
    
    print("Container Visible: " .. tostring(container.Visible))
    print("Container Class: " .. container.ClassName)
    
    local itemCount = 0
    local frameCount = 0
    local buttonCount = 0
    local carCount = 0
    
    print("\n📦 ALL ITEMS IN CONTAINER:")
    
    for i, item in pairs(container:GetChildren()) do
        itemCount = itemCount + 1
        print(string.format("[%d] %s (%s)", i, item.Name, item.ClassName))
        
        -- Count types
        if item:IsA("Frame") then
            frameCount = frameCount + 1
        elseif item:IsA("TextButton") then
            buttonCount = buttonCount + 1
        end
        
        -- Check for "Car" in name
        if item.Name:find("Car") or item.Name:match("Car%-") then
            carCount = carCount + 1
            print("   🚗 THIS IS A CAR!")
        end
        
        -- Show more info for frames and buttons
        if item:IsA("Frame") or item:IsA("TextButton") then
            -- Try to get text
            if item:IsA("TextButton") then
                print("   Text: \"" .. item.Text .. "\"")
            end
            
            -- Try to get position
            local success, pos = pcall(function()
                return item.Position
            end)
            if success then
                print("   Position: " .. tostring(pos))
            end
            
            -- Check for children
            local childCount = #item:GetChildren()
            if childCount > 0 then
                print("   Children: " .. childCount)
                for j, child in pairs(item:GetChildren()) do
                    print("     - " .. child.Name .. " (" .. child.ClassName .. ")")
                    if child:IsA("TextLabel") then
                        print("       Text: \"" .. child.Text .. "\"")
                    end
                end
            end
        end
        
        print("") -- Empty line between items
    end
    
    print("\n📊 SUMMARY:")
    print("Total items: " .. itemCount)
    print("Frames: " .. frameCount)
    print("Buttons: " .. buttonCount)
    print("Cars found: " .. carCount)
    
    -- If no cars found, maybe they're nested
    if carCount == 0 then
        print("\n🔍 CHECKING NESTED FRAMES...")
        for _, item in pairs(container:GetChildren()) do
            if item:IsA("Frame") then
                print("Checking frame: " .. item.Name)
                for _, child in pairs(item:GetChildren()) do
                    if child.Name:find("Car") then
                        print("   🚗 Found nested car: " .. child.Name)
                        print("   Class: " .. child.ClassName)
                        if child:IsA("TextButton") then
                            print("   Text: \"" .. child.Text .. "\"")
                        end
                    end
                end
            end
        end
    end
end

-- Try to duplicate based on what we find
local function TryDuplicates()
    print("\n🔄 ATTEMPTING DUPLICATION...")
    
    local container = GetTradeContainer()
    if not container then return 0 end
    
    local duplicates = 0
    
    -- Method 1: Direct cars in container
    for _, item in pairs(container:GetChildren()) do
        if item.Name:find("Car") then
            print("Trying to duplicate: " .. item.Name)
            
            local success, clone = pcall(function()
                return item:Clone()
            end)
            
            if success then
                clone.Name = item.Name .. "_Copy"
                clone.Parent = container
                duplicates = duplicates + 1
                print("✅ Duplicated")
            else
                print("❌ Failed to clone")
            end
        end
    end
    
    -- Method 2: Cars inside frames
    if duplicates == 0 then
        for _, frame in pairs(container:GetChildren()) do
            if frame:IsA("Frame") then
                for _, item in pairs(frame:GetChildren()) do
                    if item.Name:find("Car") then
                        print("Trying to duplicate nested: " .. item.Name)
                        
                        local success, clone = pcall(function()
                            return item:Clone()
                        end)
                        
                        if success then
                            clone.Name = item.Name .. "_Copy"
                            clone.Parent = frame
                            duplicates = duplicates + 1
                            print("✅ Duplicated nested")
                        end
                    end
                end
            end
        end
    end
    
    print("Total duplicates created: " .. duplicates)
    return duplicates
end

-- Create debug UI
local gui = Instance.new("ScreenGui")
gui.Parent = Player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 200)
frame.Position = UDim2.new(0.5, -175, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel")
title.Text = "TRADE DEBUGGER"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
title.TextColor3 = Color3.fromRGB(255, 255, 255)

local output = Instance.new("TextLabel")
output.Name = "Output"
output.Text = "Click DEBUG to see what's in trade"
output.Size = UDim2.new(1, -20, 0, 100)
output.Position = UDim2.new(0, 10, 0, 50)
output.BackgroundTransparency = 1
output.TextColor3 = Color3.fromRGB(255, 255, 255)
output.TextWrapped = true
output.TextXAlignment = Enum.TextXAlignment.Left

local debugBtn = Instance.new("TextButton")
debugBtn.Text = "🔍 DEBUG CONTAINER"
debugBtn.Size = UDim2.new(1, -20, 0, 30)
debugBtn.Position = UDim2.new(0, 10, 0, 160)
debugBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)

local dupBtn = Instance.new("TextButton")
dupBtn.Text = "📋 TRY DUPLICATE"
dupBtn.Size = UDim2.new(1, -20, 0, 30)
dupBtn.Position = UDim2.new(0, 10, 0, 200)
dupBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)

-- Parent
title.Parent = frame
output.Parent = frame
debugBtn.Parent = frame
dupBtn.Parent = frame
frame.Parent = gui

-- Update output
local function updateOutput(text)
    output.Text = text
end

-- Debug button
debugBtn.MouseButton1Click:Connect(function()
    debugBtn.Text = "DEBUGGING..."
    updateOutput("Debugging container...\nCheck OUTPUT window")
    
    -- Run debug in separate thread
    spawn(function()
        DebugContainer()
        debugBtn.Text = "🔍 DEBUG CONTAINER"
        updateOutput("Debug complete!\nCheck Roblox OUTPUT window")
    end)
end)

-- Duplicate button
dupBtn.MouseButton1Click:Connect(function()
    dupBtn.Text = "DUPLICATING..."
    updateOutput("Attempting duplication...")
    
    spawn(function()
        local count = TryDuplicates()
        
        if count > 0 then
            updateOutput("Created " .. count .. " duplicates\nCheck if cars are duplicated")
            dupBtn.Text = "✅ " .. count .. " DUPES"
            dupBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        else
            updateOutput("No cars found to duplicate\nClick DEBUG first")
            dupBtn.Text = "📋 TRY DUPLICATE"
        end
    end)
end)

print("\n🎯 DEBUGGER READY")
print("1. Open trade with cars")
print("2. Click DEBUG CONTAINER")
print("3. Check OUTPUT window")
print("4. Tell me what it shows")

-- Auto-debug on startup
wait(3)
debugBtn:Click()
