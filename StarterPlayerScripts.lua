-- FIXED CAR DETECTION USING REAL CAR DATA
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🚗 FIXED CAR DETECTION USING REAL CAR DATA")

-- Get car service
local carService = nil
pcall(function()
    carService = require(ReplicatedStorage.Remotes.Services.CarServiceRemotes)
    print("✅ Found CarServiceRemotes")
end)

-- Function to get ALL owned cars with real data
local function getAllOwnedCars()
    print("\n📋 GETTING ALL OWNED CARS...")
    
    local ownedCars = {}
    
    if carService and carService.GetOwnedCars then
        local success, result = pcall(function()
            return carService.GetOwnedCars:InvokeServer()
        end)
        
        if success and type(result) == "table" then
            print("✅ Got " .. #result .. " cars from server")
            
            -- Analyze car structure
            for i, carData in ipairs(result) do
                if type(carData) == "table" then
                    -- Extract key information
                    local carInfo = {
                        index = i,
                        name = carData.Name or carData.CarName or "Unknown",
                        id = carData.Id or carData.CarId or i,
                        isSelected = carData.IsSelected or carData.Selected or false,
                        rawData = carData
                    }
                    
                    table.insert(ownedCars, carInfo)
                    
                    -- Show first car's structure for debugging
                    if i == 1 then
                        print("\n🔬 FIRST CAR STRUCTURE:")
                        for key, value in pairs(carData) do
                            local valueType = type(value)
                            local displayValue = tostring(value)
                            
                            if valueType == "string" and #displayValue > 20 then
                                displayValue = displayValue:sub(1, 20) .. "..."
                            end
                            
                            print("  " .. key .. " = " .. displayValue .. " (" .. valueType .. ")")
                        end
                    end
                end
            end
        else
            print("❌ Failed to get cars:", result)
        end
    else
        print("❌ CarService not available")
    end
    
    return ownedCars
end

-- Function to get CURRENTLY SELECTED car
local function getCurrentSelectedCar()
    print("\n🎯 GETTING CURRENTLY SELECTED CAR...")
    
    local ownedCars = getAllOwnedCars()
    local selectedCar = nil
    
    -- Method 1: Check IsSelected field
    for _, carInfo in ipairs(ownedCars) do
        if carInfo.rawData.IsSelected == true or carInfo.rawData.Selected == true then
            selectedCar = carInfo
            print("✅ Found selected car via IsSelected field: " .. carInfo.name)
            break
        end
    end
    
    -- Method 2: Check garage UI
    if not selectedCar then
        local garageUI = LocalPlayer.PlayerGui:FindFirstChild("Menu")
        if garageUI then
            -- Look for selected car in UI
            for _, element in pairs(garageUI:GetDescendants()) do
                if element:IsA("TextLabel") then
                    local text = element.Text or ""
                    if text:find("Selected:") then
                        local carName = text:gsub("Selected: ", ""):gsub("Vehicle: ", "")
                        print("✅ Found selected car in UI: " .. carName)
                        
                        -- Find this car in owned cars
                        for _, carInfo in ipairs(ownedCars) do
                            if carInfo.name == carName then
                                selectedCar = carInfo
                                break
                            end
                        end
                        break
                    end
                end
            end
        end
    end
    
    -- Method 3: Check current character vehicle
    if not selectedCar then
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("Model") and (part.Name:find("Car") or part.Name:find("Vehicle")) then
                    print("✅ Found current vehicle: " .. part.Name)
                    
                    -- Find this car in owned cars
                    for _, carInfo in ipairs(ownedCars) do
                        if carInfo.name == part.Name then
                            selectedCar = carInfo
                            break
                        end
                    end
                    break
                end
            end
        end
    end
    
    -- Method 4: Use first car if none selected
    if not selectedCar and #ownedCars > 0 then
        selectedCar = ownedCars[1]
        print("⚠️ No selected car found, using first car: " .. selectedCar.name)
    end
    
    if selectedCar then
        print("\n🎯 CURRENT SELECTED CAR:")
        print("Name: " .. selectedCar.name)
        print("ID: " .. tostring(selectedCar.id))
        print("Index: " .. selectedCar.index)
        return selectedCar
    else
        print("❌ No cars found!")
        return nil
    end
end

-- Function to unlock wraps for SPECIFIC car using real car data
local function unlockWrapsForSpecificCar()
    print("\n🎨 UNLOCKING WRAPS FOR SPECIFIC CAR...")
    
    local selectedCar = getCurrentSelectedCar()
    if not selectedCar then
        print("❌ No car selected")
        return
    end
    
    print("Target car: " .. selectedCar.name)
    
    -- Get wraps for this specific car
    local wraps = getWrapsForCar(selectedCar.name)
    if #wraps == 0 then
        print("❌ No wraps found for this car")
        return
    end
    
    -- Find wrap UI
    local wrapUI = findWrapUI()
    if not wrapUI then
        print("❌ Wrap UI not found")
        return
    end
    
    -- Clear existing items
    for _, child in pairs(wrapUI:GetChildren()) do
        if child.Name ~= "UIListLayout" then
            child:Destroy()
        end
    end
    
    -- Add wraps specifically for this car
    local addedCount = 0
    
    for i, wrapName in pairs(wraps) do
        -- Check if wrap is for this car or universal
        local isForThisCar = false
        if wrapName:find("/") then
            local carSpecific = wrapName:match("^(.-)/")
            isForThisCar = (carSpecific == selectedCar.name)
        else
            isForThisCar = true  -- Universal wrap
        end
        
        if isForThisCar then
            -- Create wrap item
            local wrapFrame = Instance.new("Frame")
            wrapFrame.Name = "Wrap_" .. wrapName:gsub("/", "_")
            wrapFrame.Size = UDim2.new(1, -10, 0, 70)
            wrapFrame.Position = UDim2.new(0, 5, 0, addedCount * 75)
            
            -- Color coding
            if wrapName:find("/") then
                wrapFrame.BackgroundColor3 = Color3.fromRGB(138, 43, 226) -- Purple for car-specific
            else
                wrapFrame.BackgroundColor3 = addedCount % 2 == 0 and 
                    Color3.fromRGB(50, 50, 70) or 
                    Color3.fromRGB(60, 60, 80)
            end
            
            wrapFrame.BorderSizePixel = 2
            wrapFrame.BorderColor3 = Color3.new(0.2, 0.6, 1)
            
            -- Wrap name with car indicator
            local displayName = wrapName
            if wrapName:find("/") then
                displayName = wrapName:gsub("^.-/", "") .. " (For: " .. selectedCar.name .. ")"
            end
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Text = "✅ " .. displayName
            nameLabel.Size = UDim2.new(0.7, 0, 0.6, 0)
            nameLabel.TextColor3 = Color3.new(0, 1, 0)
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.PaddingLeft = UDim.new(0, 10)
            nameLabel.Parent = wrapFrame
            
            -- Car-specific label
            if wrapName:find("/") then
                local carLabel = Instance.new("TextLabel")
                carLabel.Text = "🚗 " .. selectedCar.name
                carLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
                carLabel.Position = UDim2.new(0, 10, 0.6, 0)
                carLabel.TextColor3 = Color3.new(1, 1, 0)
                carLabel.TextSize = 12
                carLabel.Parent = wrapFrame
            end
            
            -- Equip button
            local equipBtn = Instance.new("TextButton")
            equipBtn.Text = "EQUIP"
            equipBtn.Size = UDim2.new(0.2, 0, 0.6, 0)
            equipBtn.Position = UDim2.new(0.75, 0, 0.2, 0)
            equipBtn.BackgroundColor3 = wrapName:find("/") and 
                Color3.fromRGB(138, 43, 226) or  -- Purple for car-specific
                Color3.fromRGB(0, 150, 0)        -- Green for universal
            equipBtn.TextColor3 = Color3.new(1, 1, 1)
            equipBtn.Font = Enum.Font.SourceSansBold
            equipBtn.Parent = wrapFrame
            
            equipBtn.MouseButton1Click:Connect(function()
                equipWrapOnCar(wrapName, selectedCar.name)
            end)
            
            wrapFrame.Parent = wrapUI
            addedCount = addedCount + 1
        end
    end
    
    print("✅ Added " .. addedCount .. " wraps for " .. selectedCar.name)
    print("⚠️ Wraps are CAR-SPECIFIC for: " .. selectedCar.name)
end

-- Function to get wraps for specific car (needs implementation)
local function getWrapsForCar(carName)
    -- This should be implemented based on game structure
    -- For now, return some example wraps
    local wraps = {
        "BasicWrap",  -- Universal wrap
        "RacingStripes",  -- Universal wrap
        carName .. "/PremiumWrap",  -- Car-specific
        carName .. "/RacingWrap",   -- Car-specific
        carName .. "/SpecialEdition" -- Car-specific
    }
    
    return wraps
end

-- Function to find wrap UI (needs implementation)
local function findWrapUI()
    -- Implement based on your UI structure
    local wrapUI = LocalPlayer.PlayerGui:FindFirstChild("Customization")
    if wrapUI then
        wrapUI = wrapUI:FindFirstChild("Bottom")
        if wrapUI then
            wrapUI = wrapUI:FindFirstChild("Customization")
            if wrapUI then
                wrapUI = wrapUI:FindFirstChild("Items")
                if wrapUI then
                    wrapUI = wrapUI:FindFirstChild("Pages")
                    if wrapUI then
                        wrapUI = wrapUI:FindFirstChild("List")
                        if wrapUI then
                            wrapUI = wrapUI:FindFirstChild("Wrap")
                            return wrapUI
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- Function to equip wrap (needs implementation)
local function equipWrapOnCar(wrapName, carName)
    print("Equipping " .. wrapName .. " on " .. carName)
    -- Implementation would go here
end

-- CREATE UPDATED CONTROL UI
local controlUI = Instance.new("ScreenGui")
controlUI.Name = "CarSpecificWrapUnlocker"
controlUI.Parent = LocalPlayer.PlayerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 300)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.new(0, 0.7, 1)
mainFrame.Parent = controlUI

local title = Instance.new("TextLabel")
title.Text = "🚗 CAR-SPECIFIC WRAPS"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Current car display
local carDisplay = Instance.new("TextLabel")
carDisplay.Name = "CarDisplay"
carDisplay.Text = "Car: Detecting..."
carDisplay.Size = UDim2.new(1, 0, 0, 25)
carDisplay.Position = UDim2.new(0, 0, 0.12, 0)
carDisplay.TextColor3 = Color3.new(1, 1, 1)
carDisplay.Parent = mainFrame

-- Car list display
local carListDisplay = Instance.new("TextLabel")
carListDisplay.Name = "CarListDisplay"
carListDisplay.Text = "Owned cars: Loading..."
carListDisplay.Size = UDim2.new(1, 0, 0, 40)
carListDisplay.Position = UDim2.new(0, 0, 0.2, 0)
carListDisplay.TextColor3 = Color3.new(1, 1, 0)
carListDisplay.TextSize = 12
carListDisplay.TextWrapped = true
carListDisplay.Parent = mainFrame

-- Buttons
local buttons = {
    {"🔍 Detect Selected Car", function()
        local car = getCurrentSelectedCar()
        if car then
            carDisplay.Text = "Car: " .. car.name
            carDisplay.TextColor3 = Color3.new(0, 1, 0)
        end
    end},
    {"📋 Show All Cars", function()
        local cars = getAllOwnedCars()
        if #cars > 0 then
            local carNames = ""
            for i, car in ipairs(cars) do
                if i <= 5 then  -- Limit display
                    carNames = carNames .. (i > 1 and ", " or "") .. car.name
                end
            end
            if #cars > 5 then
                carNames = carNames .. " and " .. (#cars - 5) .. " more"
            end
            carListDisplay.Text = "Owned cars: " .. carNames
        end
    end},
    {"🎨 Unlock Car-Specific Wraps", unlockWrapsForSpecificCar},
    {"🔧 Change Selected Car", function()
        -- Let user pick a different car
        local cars = getAllOwnedCars()
        if #cars > 0 then
            -- Create car selection UI
            createCarSelectionUI(cars)
        end
    end}
}

for i, btnData in ipairs(buttons) do
    local btn = Instance.new("TextButton")
    btn.Text = btnData[1]
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0.35 + (i * 0.15), 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(btnData[2])
end

-- Create car selection UI
local function createCarSelectionUI(cars)
    local selectionUI = Instance.new("ScreenGui")
    selectionUI.Name = "CarSelectionUI"
    selectionUI.Parent = LocalPlayer.PlayerGui
    
    local selectionFrame = Instance.new("Frame")
    selectionFrame.Size = UDim2.new(0, 350, 0, 400)
    selectionFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    selectionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    selectionFrame.BorderSizePixel = 3
    selectionFrame.BorderColor3 = Color3.new(0, 1, 0)
    selectionFrame.Parent = selectionUI
    
    local title = Instance.new("TextLabel")
    title.Text = "🚗 SELECT A CAR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.Parent = selectionFrame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 0.8, 0)
    scrollFrame.Position = UDim2.new(0, 10, 0.1, 0)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #cars * 60)
    scrollFrame.Parent = selectionFrame
    
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = scrollFrame
    
    -- Add car buttons
    for i, carInfo in ipairs(cars) do
        local carBtn = Instance.new("TextButton")
        carBtn.Text = carInfo.name .. " (ID: " .. carInfo.id .. ")"
        carBtn.Size = UDim2.new(1, -10, 0, 50)
        carBtn.Position = UDim2.new(0, 5, 0, (i-1) * 55)
        carBtn.BackgroundColor3 = i % 2 == 0 and 
            Color3.fromRGB(50, 50, 70) or 
            Color3.fromRGB(60, 60, 80)
        carBtn.TextColor3 = Color3.new(1, 1, 1)
        carBtn.Font = Enum.Font.SourceSansBold
        
        -- Highlight if selected
        if carInfo.rawData.IsSelected or carInfo.rawData.Selected then
            carBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            carBtn.Text = "✅ " .. carBtn.Text .. " (SELECTED)"
        end
        
        carBtn.MouseButton1Click:Connect(function()
            -- Update selected car display
            carDisplay.Text = "Car: " .. carInfo.name
            carDisplay.TextColor3 = Color3.new(0, 1, 0)
            
            -- Close selection UI
            selectionUI:Destroy()
            
            print("Selected car: " .. carInfo.name)
        end)
        
        carBtn.Parent = scrollFrame
    end
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "CLOSE"
    closeBtn.Size = UDim2.new(0.3, 0, 0.1, 0)
    closeBtn.Position = UDim2.new(0.35, 0, 0.92, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Parent = selectionFrame
    
    closeBtn.MouseButton1Click:Connect(function()
        selectionUI:Destroy()
    end)
end

print("\n" .. string.rep("=", 60))
print("🚗 FIXED CAR-SPECIFIC WRAP UNLOCKER")
print(string.rep("=", 60))
print("USES REAL CAR DATA FROM:")
print("CarServiceRemotes.GetOwnedCars:InvokeServer()")
print(string.rep("=", 60))
print("FEATURES:")
print("• Uses actual car data from server")
print("• Detects IsSelected/Selected field")
print("• Shows ALL owned cars")
print("• Car-specific wrap targeting")
print("• Manual car selection")
print(string.rep("=", 60))

-- Make global
_G.getcars = getAllOwnedCars
_G.getselected = getCurrentSelectedCar
_G.unlockwraps = unlockWrapsForSpecificCar

print("\nConsole commands:")
print("_G.getcars() - Get all owned cars")
print("_G.getselected() - Get selected car")
print("_G.unlockwraps() - Unlock wraps for selected car")
