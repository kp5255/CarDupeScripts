print("🎯 AGGRESSIVE INVENTORY MODIFIER")
print("=" .. string.rep("=", 60))

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- First, let's map out the ENTIRE inventory structure
print("🗺️ Mapping inventory structure...")

local inventory = player.PlayerGui.Menu:FindFirstChild("Inventory")
if not inventory then
    print("❌ Inventory not found")
    return
end

print("✅ Inventory found: " .. inventory:GetFullName())
print("Visible: " .. tostring(inventory.Visible))
print("Children: " .. #inventory:GetChildren())

-- Function to print full structure
local function printStructure(gui, depth, maxDepth)
    if depth > maxDepth then return end
    
    local prefix = string.rep("  ", depth)
    
    for _, child in pairs(gui:GetChildren()) do
        local info = child.Name .. " (" .. child.ClassName .. ")"
        
        if child:IsA("GuiObject") then
            info = info .. " | Visible: " .. tostring(child.Visible)
            info = info .. " | Size: " .. tostring(child.Size.X.Scale) .. ", " .. tostring(child.Size.Y.Scale)
        end
        
        print(prefix .. "• " .. info)
        
        -- Special handling for important elements
        if child.Name:lower():find("car") then
            print(prefix .. "  🚗 CAR-RELATED ELEMENT!")
        end
        
        if child:IsA("ScrollingFrame") then
            print(prefix .. "  📜 SCROLLING FRAME - " .. #child:GetChildren() .. " children")
        end
        
        if child:IsA("Frame") and #child:GetChildren() > 0 then
            printStructure(child, depth + 1, maxDepth)
        end
    end
end

print("\n📋 INVENTORY STRUCTURE (depth 3):")
printStructure(inventory, 0, 3)

-- Now let's find ANYTHING that could be a car display
print("\n🔍 Searching for car display candidates...")

local candidates = {}

local function searchForCandidates(gui, path)
    for _, child in pairs(gui:GetChildren()) do
        local currentPath = path .. "." .. child.Name
        
        -- Check if this could be a car container
        local isCandidate = false
        local reason = ""
        
        if child:IsA("ScrollingFrame") then
            isCandidate = true
            reason = "ScrollingFrame"
        elseif child:IsA("Frame") and child.Name:lower():find("car") then
            isCandidate = true
            reason = "Name contains 'car'"
        elseif child:IsA("Frame") and child.BackgroundColor3 ~= Color3.new(1, 1, 1) then
            -- Check for grid-like structure
            local frameChildren = child:GetChildren()
            local frameCount = 0
            for _, subChild in pairs(frameChildren) do
                if subChild:IsA("Frame") then
                    frameCount = frameCount + 1
                end
            end
            if frameCount >= 3 then
                isCandidate = true
                reason = "Grid-like structure with " .. frameCount .. " frames"
            end
        end
        
        if isCandidate then
            table.insert(candidates, {
                element = child,
                path = currentPath,
                reason = reason,
                children = #child:GetChildren()
            })
        end
        
        -- Recursive search
        if #child:GetChildren() > 0 and not child:IsA("ScrollingFrame") then
            searchForCandidates(child, currentPath)
        end
    end
end

searchForCandidates(inventory, "Inventory")

print("\n🎯 FOUND " .. #candidates .. " CANDIDATES:")
for i, candidate in ipairs(candidates) do
    print(i .. ". " .. candidate.path)
    print("   Reason: " .. candidate.reason)
    print("   Children: " .. candidate.children)
end

-- Now FORCE inject into ALL candidates
print("\n💉 FORCE INJECTING INTO ALL CANDIDATES...")

local injectedCars = {
    {Name = "Bugatti Chiron", Class = 3, Color = Color3.fromRGB(0, 100, 200)},
    {Name = "Lamborghini Aventador", Class = 3, Color = Color3.fromRGB(200, 0, 0)},
    {Name = "Ferrari SF90", Class = 3, Color = Color3.fromRGB(200, 0, 0)},
    {Name = "McLaren P1", Class = 3, Color = Color3.fromRGB(255, 165, 0)},
    {Name = "Porsche 918 Spyder", Class = 3, Color = Color3.fromRGB(0, 200, 100)}
}

local totalInjected = 0

for i, candidate in ipairs(candidates) do
    if i <= 5 then  -- Limit to first 5 candidates
        print("\n🔄 Injecting into candidate " .. i .. ": " .. candidate.path)
        
        for j, carData in ipairs(injectedCars) do
            -- Create injection frame
            local injectFrame = Instance.new("Frame")
            injectFrame.Name = "ForceInject_" .. i .. "_" .. j
            injectFrame.Size = UDim2.new(0, 150, 0, 200)
            injectFrame.Position = UDim2.new(0, (j-1) * 160, 0, 0)
            injectFrame.BackgroundColor3 = carData.Color
            injectFrame.BackgroundTransparency = 0.3
            injectFrame.BorderSizePixel = 0
            
            -- Add corner
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = injectFrame
            
            -- Add glow
            local glow = Instance.new("UIStroke")
            glow.Color = Color3.new(1, 1, 1)
            glow.Thickness = 2
            glow.Parent = injectFrame
            
            -- Car name
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Text = "⚡ " .. carData.Name .. " ⚡"
            nameLabel.Size = UDim2.new(1, -10, 0, 40)
            nameLabel.Position = UDim2.new(0, 5, 0, 150)
            nameLabel.BackgroundTransparency = 1
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 12
            nameLabel.TextScaled = true
            nameLabel.Parent = injectFrame
            
            -- Class indicator
            local classLabel = Instance.new("TextLabel")
            classLabel.Text = "CLASS " .. carData.Class
            classLabel.Size = UDim2.new(0, 60, 0, 25)
            classLabel.Position = UDim2.new(0, 5, 0, 5)
            classLabel.BackgroundColor3 = Color3.new(1, 0, 0)
            classLabel.TextColor3 = Color3.new(1, 1, 1)
            classLabel.Font = Enum.Font.GothamBold
            classLabel.TextSize = 12
            classLabel.Parent = injectFrame
            
            local classCorner = Instance.new("UICorner")
            classCorner.CornerRadius = UDim.new(0, 4)
            classCorner.Parent = classLabel
            
            -- Inject
            injectFrame.Parent = candidate.element
            
            totalInjected = totalInjected + 1
            print("   ✅ Injected: " .. carData.Name)
        end
    end
end

print("\n🎉 INJECTION COMPLETE!")
print("Total injection points: " .. #candidates)
print("Total cars injected: " .. totalInjected)
print("\n💡 Look for cars with ⚡ symbols in your inventory!")
