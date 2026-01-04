print("⚡ REAL-TIME INVENTORY MODIFIER")
print("=" .. string.rep("=", 60))

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- This modifies inventory in real-time as you use it
print("🔧 Setting up real-time modifier...")

-- Track injected cars
local injectedCars = {}

-- Function to inject a car into any car list
local function injectCarIntoList(carList, carData, index)
    if not carList or not carList:IsA("ScrollingFrame") then
        return false
    end
    
    -- Calculate position
    local totalItems = #carList:GetChildren()
    local position = totalItems + 1
    
    -- Create car slot
    local carSlot = Instance.new("Frame")
    carSlot.Name = "RealTimeInjected_" .. index
    carSlot.Size = UDim2.new(0, 140, 0, 180)
    carSlot.Position = UDim2.new(0, ((position-1) % 4) * 150, 0, math.floor((position-1) / 4) * 190)
    carSlot.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    carSlot.BorderSizePixel = 0
    
    -- Add glow effect
    local glow = Instance.new("UIStroke")
    glow.Color = carData.Color
    glow.Thickness = 3
    glow.Parent = carSlot
    
    -- Car image
    local image = Instance.new("Frame")
    image.Size = UDim2.new(1, -20, 0, 100)
    image.Position = UDim2.new(0, 10, 0, 10)
    image.BackgroundColor3 = carData.Color
    image.BackgroundTransparency = 0.5
    image.Parent = carSlot
    
    -- Car name with glow
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = "✨ " .. carData.Name .. " ✨"
    nameLabel.Size = UDim2.new(1, -20, 0, 40)
    nameLabel.Position = UDim2.new(0, 10, 0, 120)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextScaled = true
    nameLabel.Parent = carSlot
    
    -- Add to list
    carSlot.Parent = carList
    
    -- Store reference
    table.insert(injectedCars, {
        slot = carSlot,
        list = carList,
        data = carData
    })
    
    return true
end

-- Monitor for inventory openings
local inventoryMonitor = player.PlayerGui.DescendantAdded:Connect(function(descendant)
    if descendant.Name == "Inventory" or descendant.Name == "NewInventory" then
        print("🎯 Inventory opened: " .. descendant:GetFullName())
        
        -- Wait a bit for it to load
        wait(1)
        
        -- Look for car lists
        for _, child in pairs(descendant:GetDescendants()) do
            if child:IsA("ScrollingFrame") and child:FindFirstChildWhichIsA("Frame") then
                print("Found car list: " .. child:GetFullName())
                
                -- Inject premium cars
                local premiumCars = {
                    {Name = "Bugatti Chiron", Color = Color3.new(0, 0.5, 1)},
                    {Name = "Lamborghini Sian", Color = Color3.new(1, 0, 0)},
                    {Name = "Ferrari SF90", Color = Color3.new(1, 0, 0)},
                    {Name = "McLaren Speedtail", Color = Color3.new(1, 0.5, 0)}
                }
                
                for i, carData in ipairs(premiumCars) do
                    if injectCarIntoList(child, carData, i) then
                        print("✅ Injected: " .. carData.Name)
                    end
                end
            end
        end
    end
end)

-- Also monitor existing inventory
print("\n🔍 Checking for already open inventory...")

local existingInventory = player.PlayerGui.Menu:FindFirstChild("Inventory") 
                      or player.PlayerGui.Menu:FindFirstChild("NewInventory")

if existingInventory and existingInventory.Visible then
    print("✅ Inventory already open")
    
    -- Trigger injection
    local fakeDescendant = Instance.new("Folder")
    fakeDescendant.Name = "Inventory"
    fakeDescendant.Parent = player.PlayerGui
    wait(0.1)
    fakeDescendant:Destroy()
end

print("\n✅ Real-time modifier active!")
print("Open your inventory to see injected cars")
print("Injected cars will have ✨ sparkles ✨")

-- Cleanup function
local function cleanup()
    inventoryMonitor:Disconnect()
    
    for _, injected in ipairs(injectedCars) do
        if injected.slot and injected.slot.Parent then
            injected.slot:Destroy()
        end
    end
    
    print("🛑 Modifier deactivated")
end

-- Auto-cleanup after 5 minutes
delay(300, cleanup)

print("\n💡 Modifier will auto-cleanup in 5 minutes")
print("Or call cleanup() to remove early")
