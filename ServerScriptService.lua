print("🎯 MODIFYING ACTUAL INVENTORY GUI")
print("=" .. string.rep("=", 60))

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Find the main inventory GUI
local inventory = player.PlayerGui.Menu:FindFirstChild("Inventory")
if not inventory then
    inventory = player.PlayerGui.Menu:FindFirstChild("NewInventory")
end

if not inventory then
    print("❌ Inventory GUI not found")
    return
end

print("✅ Found inventory: " .. inventory:GetFullName())

-- Look for the car list/scrolling frame
local carList = nil

-- Search for scrolling frames that might contain cars
local function findCarList(gui)
    for _, child in pairs(gui:GetDescendants()) do
        if child:IsA("ScrollingFrame") then
            -- Check if it has car-like children
            for _, subChild in pairs(child:GetChildren()) do
                if subChild:IsA("Frame") and subChild.Name:find("Car") then
                    return child
                end
            end
        end
    end
    return nil
end

carList = findCarList(inventory)

if not carList then
    print("❌ Could not find car list")
    
    -- Try to find any Frame that might be a car container
    for _, child in pairs(inventory:GetDescendants()) do
        if child:IsA("Frame") and child.Name:find("Car") then
            carList = child
            print("Found car container: " .. child:GetFullName())
            break
        end
    end
end

if carList then
    print("✅ Found car list container: " .. carList:GetFullName())
    print("Current children: " .. #carList:GetChildren())
    
    -- Define cars to inject
    local carsToInject = {
        {Name = "Bugatti Chiron", Class = 3, Color = Color3.new(0, 0.5, 1)},
        {Name = "Lamborghini Aventador", Class = 3, Color = Color3.new(1, 0, 0)},
        {Name = "Ferrari SF90", Class = 3, Color = Color3.new(1, 0, 0)},
        {Name = "McLaren P1", Class = 3, Color = Color3.new(1, 0.5, 0)},
        {Name = "Porsche 918 Spyder", Class = 3, Color = Color3.new(0, 1, 0.5)}
    }
    
    print("\n🎨 Injecting " .. #carsToInject .. " cars into inventory...")
    
    for i, carData in ipairs(carsToInject) do
        -- Create a car slot similar to existing ones
        local carSlot = Instance.new("Frame")
        carSlot.Name = "InjectedCar_" .. i
        carSlot.Size = UDim2.new(0, 180, 0, 220)
        carSlot.Position = UDim2.new(0, ((i-1) % 3) * 190, 0, math.floor((i-1) / 3) * 230)
        carSlot.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        carSlot.BorderSizePixel = 0
        
        -- Add rounded corners
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = carSlot
        
        -- Car image placeholder
        local image = Instance.new("Frame")
        image.Size = UDim2.new(1, -20, 0, 120)
        image.Position = UDim2.new(0, 10, 0, 10)
        image.BackgroundColor3 = carData.Color
        image.Parent = carSlot
        
        local imageCorner = Instance.new("UICorner")
        imageCorner.CornerRadius = UDim.new(0, 6)
        imageCorner.Parent = image
        
        -- Car name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = carData.Name
        nameLabel.Size = UDim2.new(1, -20, 0, 30)
        nameLabel.Position = UDim2.new(0, 10, 0, 140)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextScaled = true
        nameLabel.Parent = carSlot
        
        -- Class badge
        local classBadge = Instance.new("Frame")
        classBadge.Size = UDim2.new(0, 60, 0, 25)
        classBadge.Position = UDim2.new(0, 10, 0, 180)
        classBadge.BackgroundColor3 = Color3.new(1, 0, 0)
        classBadge.Parent = carSlot
        
        local classCorner = Instance.new("UICorner")
        classCorner.CornerRadius = UDim.new(0, 4)
        classCorner.Parent = classBadge
        
        local classText = Instance.new("TextLabel")
        classText.Text = "CLASS " .. carData.Class
        classText.Size = UDim2.new(1, 0, 1, 0)
        classText.BackgroundTransparency = 1
        classText.TextColor3 = Color3.new(1, 1, 1)
        classText.Font = Enum.Font.GothamBold
        classText.TextSize = 12
        classText.Parent = classBadge
        
        -- Add to car list
        carSlot.Parent = carList
        
        print("✅ Added: " .. carData.Name)
    end
    
    print("\n🎉 Successfully injected cars into inventory GUI!")
    print("They should now appear in your inventory display")
    
else
    print("❌ Could not find suitable car list container")
end
