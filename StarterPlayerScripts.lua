-- Trade Duplicator - Simple Version
local P = game:GetService("Players")
local plr = P.LocalPlayer

wait(2)

print("Trade Duplicator Loaded")

-- Make UI
local gui = Instance.new("ScreenGui")
gui.Parent = plr:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0.5, -150, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel")
title.Text = "Trade Duplicator"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
title.TextColor3 = Color3.fromRGB(255, 255, 255)

local status = Instance.new("TextLabel")
status.Text = "Add cars to trade\nClick DUPLICATE"
status.Size = UDim2.new(1, -20, 0, 60)
status.Position = UDim2.new(0, 10, 0, 50)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255, 255, 255)
status.TextWrapped = true

local dupBtn = Instance.new("TextButton")
dupBtn.Text = "DUPLICATE"
dupBtn.Size = UDim2.new(1, -20, 0, 35)
dupBtn.Position = UDim2.new(0, 10, 0, 120)
dupBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)

local cleanBtn = Instance.new("TextButton")
cleanBtn.Text = "CLEAN"
cleanBtn.Size = UDim2.new(1, -20, 0, 35)
cleanBtn.Position = UDim2.new(0, 10, 0, 165)
cleanBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

-- Parent
title.Parent = frame
status.Parent = frame
dupBtn.Parent = frame
cleanBtn.Parent = frame
frame.Parent = gui

-- Duplicate function
dupBtn.MouseButton1Click:Connect(function()
    dupBtn.Text = "WORKING..."
    
    -- Find trade container
    local menu = plr.PlayerGui:FindFirstChild("Menu")
    if not menu then 
        status.Text = "Open trade first"
        dupBtn.Text = "DUPLICATE"
        return 
    end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then 
        status.Text = "Open trade first"
        dupBtn.Text = "DUPLICATE"
        return 
    end
    
    local peer = trading:FindFirstChild("PeerToPeer")
    if not peer then 
        status.Text = "Open trade first"
        dupBtn.Text = "DUPLICATE"
        return 
    end
    
    local main = peer:FindFirstChild("Main")
    if not main then 
        status.Text = "Open trade first"
        dupBtn.Text = "DUPLICATE"
        return 
    end
    
    local localPlayer = main:FindFirstChild("LocalPlayer")
    if not localPlayer then 
        status.Text = "Open trade first"
        dupBtn.Text = "DUPLICATE"
        return 
    end
    
    local content = localPlayer:FindFirstChild("Content")
    if not content then 
        status.Text = "Open trade first"
        dupBtn.Text = "DUPLICATE"
        return 
    end
    
    local scroll = content:FindFirstChild("ScrollingFrame")
    if not scroll then 
        status.Text = "Open trade first"
        dupBtn.Text = "DUPLICATE"
        return 
    end
    
    print("Found trade container")
    status.Text = "Looking for cars..."
    
    -- Look for car objects
    local dupCount = 0
    for _, obj in pairs(scroll:GetChildren()) do
        -- Skip UI objects
        if obj.ClassName == "UIPadding" or obj.ClassName == "UIListLayout" then
            continue
        end
        
        -- Check if it looks like a car/item
        if obj:IsA("Frame") or obj:IsA("TextButton") then
            local name = obj.Name:lower()
            if name:find("car") or obj:IsA("Frame") then
                print("Found: " .. obj.Name)
                
                -- Try to clone it
                local success, clone = pcall(function()
                    return obj:Clone()
                end)
                
                if success and clone then
                    -- Give unique name
                    clone.Name = obj.Name .. "_Dup"
                    
                    -- Position next to original
                    if pcall(function() return obj.Position end) then
                        local pos = obj.Position
                        local size = obj.Size
                        clone.Position = UDim2.new(
                            pos.X.Scale,
                            pos.X.Offset + size.X.Offset + 10,
                            pos.Y.Scale,
                            pos.Y.Offset
                        )
                    end
                    
                    clone.Parent = scroll
                    dupCount = dupCount + 1
                    print("Duplicated: " .. obj.Name)
                end
            end
        end
    end
    
    status.Text = "Created " .. dupCount .. " duplicates"
    dupBtn.Text = "DONE"
end)

-- Clean function
cleanBtn.MouseButton1Click:Connect(function()
    cleanBtn.Text = "CLEANING..."
    
    local removed = 0
    
    -- Find and remove duplicates
    local menu = plr.PlayerGui:FindFirstChild("Menu")
    if menu then
        local trading = menu:FindFirstChild("Trading")
        if trading then
            local peer = trading:FindFirstChild("PeerToPeer")
            if peer then
                local main = peer:FindFirstChild("Main")
                if main then
                    for _, container in pairs(main:GetChildren()) do
                        if container:IsA("Frame") then
                            local content = container:FindFirstChild("Content")
                            if content then
                                local scroll = content:FindFirstChild("ScrollingFrame")
                                if scroll then
                                    for _, obj in pairs(scroll:GetChildren()) do
                                        if obj.Name:find("_Dup") then
                                            obj:Destroy()
                                            removed = removed + 1
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    status.Text = "Removed " .. removed .. " duplicates"
    cleanBtn.Text = "CLEAN"
end)

print("UI Created - Drag to move")
