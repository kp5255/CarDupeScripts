-- 🎯 CDT OFFER DETAIL SCANNER
-- Gets ALL details of cars in your trade offer including UUIDs

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CDT OFFER DETAIL SCANNER - Getting ALL car details")

-- ===== GET OFFER CONTAINER =====
local function GetOfferContainer()
    if not Player.PlayerGui then return nil end
    
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then return nil end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then return nil end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then return nil end
    
    local main = peerToPeer:FindFirstChild("Main")
    if not main then return nil end
    
    local localPlayer = main:FindFirstChild("LocalPlayer")
    if not localPlayer then return nil end
    
    local content = localPlayer:FindFirstChild("Content")
    if not content then return nil end
    
    local scrollingFrame = content:FindFirstChild("ScrollingFrame")
    return scrollingFrame
end

-- ===== EXTRACT ALL CAR DETAILS =====
local function ExtractCarDetails(carObject)
    local details = {
        Name = carObject.Name,
        Class = carObject.ClassName,
        Path = carObject:GetFullName(),
        Properties = {},
        Children = {},
        UUID = nil,
        Value = nil,
        Rarity = nil,
        Owner = nil,
        Customizations = {}
    }
    
    -- Get ALL properties
    for property, _ in pairs(carObject) do
        local success, value = pcall(function()
            return carObject[property]
        end)
        
        if success then
            if type(value) == "string" and #value > 0 then
                details.Properties[property] = value
                
                -- Look for UUID patterns
                if property:lower():find("id") or property:lower():find("uuid") then
                    if value:match("%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x") then
                        details.UUID = value
                    elseif value:match("%d+") and #value > 8 then
                        details.ID = value
                    end
                end
                
                -- Look for value/price
                if property:lower():find("value") or property:lower():find("price") or property:lower():find("cost") then
                    details.Value = value
                end
            end
        end
    end
    
    -- Get TextButton text
    if carObject:IsA("TextButton") and carObject.Text ~= "" then
        details.DisplayName = carObject.Text
    end
    
    -- Scan all children for information
    for _, child in pairs(carObject:GetChildren()) do
        local childInfo = {
            Name = child.Name,
            Class = child.ClassName
        }
        
        -- Get Text from labels
        if child:IsA("TextLabel") and child.Text ~= "" then
            childInfo.Text = child.Text
            
            -- Identify what kind of info this is
            local textLower = child.Text:lower()
            local nameLower = child.Name:lower()
            
            if nameLower:find("name") or textLower:find("nissan") or textLower:find("subaru") then
                details.DisplayName = child.Text
            elseif nameLower:find("value") or nameLower:find("price") or nameLower:find("cost") or textLower:find("$") then
                details.Value = child.Text
            elseif nameLower:find("rarity") or textLower:find("rare") or textLower:find("epic") or textLower:find("legendary") then
                details.Rarity = child.Text
            elseif nameLower:find("owner") or nameLower:find("player") then
                details.Owner = child.Text
            elseif nameLower:find("id") or nameLower:find("uuid") then
                if child.Text:match("%x+") then
                    details.UUID = child.Text
                end
            end
        end
        
        -- Get Image from labels
        if child:IsA("ImageLabel") and child.Image ~= "" then
            childInfo.Image = child.Image
            details.Customizations[child.Name] = child.Image
        end
        
        table.insert(details.Children, childInfo)
    end
    
    -- Check parent for additional info
    local parent = carObject.Parent
    if parent then
        for _, sibling in pairs(parent:GetChildren()) do
            if sibling:IsA("TextLabel") and sibling ~= carObject then
                if sibling.Text ~= "" then
                    local nameLower = sibling.Name:lower()
                    if nameLower:find("value") and not details.Value then
                        details.Value = sibling.Text
                    elseif nameLower:find("name") and not details.DisplayName then
                        details.DisplayName = sibling.Text
                    end
                end
            end
        end
    end
    
    return details
end

-- ===== SCAN ALL OFFERED CARS WITH DETAILS =====
local function ScanOfferedCarsWithDetails()
    local offerContainer = GetOfferContainer()
    local cars = {}
    
    if not offerContainer or not offerContainer.Visible then
        return cars
    end
    
    -- Look for car objects
    for _, child in pairs(offerContainer:GetChildren()) do
        if child.Name:find("Car") or child.Name:match("Car%-") then
            print("\n🔍 Scanning car: " .. child.Name)
            
            local carDetails = ExtractCarDetails(child)
            table.insert(cars, carDetails)
            
            -- Print summary
            print("   Display: " .. (carDetails.DisplayName or carDetails.Name))
            if carDetails.Value then
                print("   Value: " .. carDetails.Value)
            end
            if carDetails.UUID then
                print("   UUID: " .. carDetails.UUID)
            end
            if carDetails.ID then
                print("   ID: " .. carDetails.ID)
            end
        end
    end
    
    -- Also check frames that might contain cars
    if #cars == 0 then
        for _, child in pairs(offerContainer:GetChildren()) do
            if child:IsA("Frame") then
                for _, subChild in pairs(child:GetChildren()) do
                    if subChild.Name:find("Car") then
                        print("\n🔍 Scanning nested car: " .. subChild.Name)
                        
                        local carDetails = ExtractCarDetails(subChild)
                        table.insert(cars, carDetails)
                        
                        print("   Display: " .. (carDetails.DisplayName or carDetails.Name))
                    end
                end
            end
        end
    end
    
    return cars
end

-- ===== CREATE DETAILED UI =====
local function CreateDetailedUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CarDetailsUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.7, 0, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🔍 CAR DETAILS SCANNER"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "Ready to scan..."
    Status.Size = UDim2.new(1, -20, 0, 40)
    Status.Position = UDim2.new(0, 10, 0, 50)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(200, 200, 255)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 14
    
    -- Cars List
    local CarsFrame = Instance.new("ScrollingFrame")
    CarsFrame.Size = UDim2.new(1, -20, 0, 250)
    CarsFrame.Position = UDim2.new(0, 10, 0, 100)
    CarsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    CarsFrame.BorderSizePixel = 0
    CarsFrame.ScrollBarThickness = 6
    CarsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local CarsLayout = Instance.new("UIListLayout")
    CarsLayout.Padding = UDim.new(0, 10)
    
    -- Details Panel
    local DetailsFrame = Instance.new("ScrollingFrame")
    DetailsFrame.Size = UDim2.new(1, -20, 0, 100)
    DetailsFrame.Position = UDim2.new(0, 10, 0, 360)
    DetailsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    DetailsFrame.BorderSizePixel = 0
    DetailsFrame.ScrollBarThickness = 6
    DetailsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local DetailsTitle = Instance.new("TextLabel")
    DetailsTitle.Text = "Selected Car Details:"
    DetailsTitle.Size = UDim2.new(1, -10, 0, 20)
    DetailsTitle.Position = UDim2.new(0, 5, 0, 5)
    DetailsTitle.BackgroundTransparency = 1
    DetailsTitle.TextColor3 = Color3.fromRGB(255, 255, 200)
    DetailsTitle.Font = Enum.Font.GothamBold
    DetailsTitle.TextSize = 13
    
    -- Buttons
    local ScanButton = Instance.new("TextButton")
    ScanButton.Text = "🔍 SCAN DETAILS"
    ScanButton.Size = UDim2.new(0.48, 0, 0, 35)
    ScanButton.Position = UDim2.new(0.02, 0, 1, -45)
    ScanButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    ScanButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanButton.Font = Enum.Font.GothamBold
    
    local ExportButton = Instance.new("TextButton")
    ExportButton.Text = "📋 EXPORT JSON"
    ExportButton.Size = UDim2.new(0.48, 0, 0, 35)
    ExportButton.Position = UDim2.new(0.5, 0, 1, -45)
    ExportButton.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    ExportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExportButton.Font = Enum.Font.GothamBold
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = Title
    corner:Clone().Parent = CarsFrame
    corner:Clone().Parent = DetailsFrame
    corner:Clone().Parent = ScanButton
    corner:Clone().Parent = ExportButton
    
    -- Parenting
    Title.Parent = MainFrame
    Status.Parent = MainFrame
    CarsLayout.Parent = CarsFrame
    CarsFrame.Parent = MainFrame
    DetailsTitle.Parent = DetailsFrame
    DetailsFrame.Parent = MainFrame
    ScanButton.Parent = MainFrame
    ExportButton.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Variables
    local currentCars = {}
    local selectedCarIndex = nil
    
    -- Functions
    local function updateStatus(text, color)
        Status.Text = text
        Status.TextColor3 = color or Color3.fromRGB(200, 200, 255)
    end
    
    local function clearCarsList()
        for _, child in pairs(CarsFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
    
    local function clearDetails()
        for _, child in pairs(DetailsFrame:GetChildren()) do
            if child ~= DetailsTitle then
                child:Destroy()
            end
        end
    end
    
    local function addDetailLine(text, color)
        local label = Instance.new("TextLabel")
        label.Text = text
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0, 5, 0, #DetailsFrame:GetChildren() * 20)
        label.BackgroundTransparency = 1
        label.TextColor3 = color or Color3.fromRGB(200, 200, 255)
        label.Font = Enum.Font.Code
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = true
        label.AutomaticSize = Enum.AutomaticSize.Y
        label.Parent = DetailsFrame
    end
    
    local function showCarDetails(carIndex)
        clearDetails()
        
        if not currentCars[carIndex] then
            addDetailLine("No car selected", Color3.fromRGB(255, 100, 100))
            return
        end
        
        local car = currentCars[carIndex]
        
        -- Show basic info
        addDetailLine("🚗 " .. (car.DisplayName or car.Name), Color3.fromRGB(255, 255, 100))
        addDetailLine("Class: " .. car.Class, Color3.fromRGB(180, 180, 255))
        
        -- Show UUID if found
        if car.UUID then
            addDetailLine("UUID: " .. car.UUID, Color3.fromRGB(100, 255, 100))
        end
        
        if car.ID then
            addDetailLine("ID: " .. car.ID, Color3.fromRGB(100, 255, 100))
        end
        
        -- Show value
        if car.Value then
            addDetailLine("Value: " .. car.Value, Color3.fromRGB(255, 200, 100))
        end
        
        -- Show rarity
        if car.Rarity then
            addDetailLine("Rarity: " .. car.Rarity, Color3.fromRGB(200, 100, 255))
        end
        
        -- Show owner
        if car.Owner then
            addDetailLine("Owner: " .. car.Owner, Color3.fromRGB(100, 200, 255))
        end
        
        -- Show important properties
        addDetailLine("Properties:", Color3.fromRGB(255, 255, 200))
        for prop, value in pairs(car.Properties) do
            if #value < 50 then  -- Don't show huge values
                addDetailLine("  " .. prop .. ": " .. value, Color3.fromRGB(180, 180, 180))
            end
        end
        
        -- Show children
        if #car.Children > 0 then
            addDetailLine("Children (" .. #car.Children .. "):", Color3.fromRGB(200, 200, 255))
            for _, child in ipairs(car.Children) do
                local line = "  • " .. child.Name .. " (" .. child.Class .. ")"
                if child.Text then
                    line = line .. ": " .. child.Text
                end
                addDetailLine(line, Color3.fromRGB(150, 150, 150))
            end
        end
        
        -- Update details frame size
        DetailsFrame.CanvasSize = UDim2.new(0, 0, 0, #DetailsFrame:GetChildren() * 20)
    end
    
    local function createCarButton(car, index)
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(0.95, 0, 0, 50)
        buttonFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        buttonFrame.Name = "CarBtn_" .. index
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = buttonFrame
        
        -- Car icon
        local icon = Instance.new("TextLabel")
        icon.Text = "🚗"
        icon.Size = UDim2.new(0, 40, 0, 40)
        icon.Position = UDim2.new(0, 5, 0.5, -20)
        icon.BackgroundTransparency = 1
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.Font = Enum.Font.GothamBold
        icon.TextSize = 20
        
        -- Car name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = car.DisplayName or car.Name
        nameLabel.Size = UDim2.new(0.5, -50, 0, 40)
        nameLabel.Position = UDim2.new(0, 50, 0.5, -20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 14
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Info badge
        local infoBadge = Instance.new("Frame")
        infoBadge.Size = UDim2.new(0, 80, 0, 20)
        infoBadge.Position = UDim2.new(0.5, 10, 0.5, -10)
        infoBadge.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        
        local badgeCorner = Instance.new("UICorner")
        badgeCorner.CornerRadius = UDim.new(0, 4)
        badgeCorner.Parent = infoBadge
        
        local badgeText = Instance.new("TextLabel")
        badgeText.Text = "Click for details"
        badgeText.Size = UDim2.new(1, 0, 1, 0)
        badgeText.BackgroundTransparency = 1
        badgeText.TextColor3 = Color3.fromRGB(200, 200, 255)
        badgeText.Font = Enum.Font.Gotham
        badgeText.TextSize = 10
        
        badgeText.Parent = infoBadge
        infoBadge.Parent = buttonFrame
        
        -- Click event
        buttonFrame.MouseButton1Click:Connect(function()
            selectedCarIndex = index
            showCarDetails(index)
            
            -- Highlight selected
            for _, otherBtn in pairs(CarsFrame:GetChildren()) do
                if otherBtn:IsA("Frame") then
                    otherBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
                end
            end
            buttonFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        end)
        
        -- Parenting
        icon.Parent = buttonFrame
        nameLabel.Parent = buttonFrame
        buttonFrame.Parent = CarsFrame
        
        return buttonFrame
    end
    
    local function performScan()
        clearCarsList()
        clearDetails()
        
        updateStatus("🔍 Scanning car details...", Color3.fromRGB(255, 200, 100))
        
        currentCars = ScanOfferedCarsWithDetails()
        
        if #currentCars > 0 then
            updateStatus("✅ Found " .. #currentCars .. " car(s) with details", Color3.fromRGB(100, 255, 100))
            
            for i, car in ipairs(currentCars) do
                createCarButton(car, i)
            end
            
            -- Auto-select first car
            selectedCarIndex = 1
            showCarDetails(1)
            
            -- Highlight first button
            local firstBtn = CarsFrame:FindFirstChild("CarBtn_1")
            if firstBtn then
                firstBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
            end
            
        else
            updateStatus("❌ No cars in offer", Color3.fromRGB(255, 100, 100))
            addDetailLine("No cars found in offer", Color3.fromRGB(150, 150, 150))
        end
    end
    
    local function exportToJSON()
        if #currentCars == 0 then
            updateStatus("❌ No cars to export", Color3.fromRGB(255, 100, 100))
            return
        end
        
        local exportData = {
            ScanTime = os.date("%Y-%m-%d %H:%M:%S"),
            Player = Player.Name,
            UserId = Player.UserId,
            Cars = currentCars
        }
        
        local json
        local success, err = pcall(function()
            json = HttpService:JSONEncode(exportData)
        end)
        
        if success and json then
            -- Copy to clipboard (simulated)
            print("\n" .. string.rep("=", 60))
            print("📋 EXPORTED CAR DATA (JSON):")
            print(string.rep("=", 60))
            print(json)
            print(string.rep("=", 60))
            
            updateStatus("✅ JSON exported to Output", Color3.fromRGB(100, 255, 100))
        else
            updateStatus("❌ Failed to export JSON", Color3.fromRGB(255, 100, 100))
            print("Export error: " .. tostring(err))
        end
    end
    
    -- Event handlers
    ScanButton.MouseButton1Click:Connect(performScan)
    ExportButton.MouseButton1Click:Connect(exportToJSON)
    
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

-- ===== DEEP SCAN FOR HIDDEN DATA =====
local function DeepScanForData()
    spawn(function()
        while task.wait(5) do
            local container = GetOfferContainer()
            if not container or not container.Visible then
                continue
            end
            
            print("\n🔍 DEEP SCAN - Looking for hidden data...")
            
            for _, child in pairs(container:GetDescendants()) do
                -- Check for StringValues, IntValues, etc.
                if child:IsA("StringValue") or child:IsA("IntValue") or child:IsA("NumberValue") then
                    print("📊 Found Value object: " .. child.Name .. " = " .. tostring(child.Value))
                end
                
                -- Check for ObjectValues pointing to assets
                if child:IsA("ObjectValue") and child.Value then
                    print("📦 ObjectValue: " .. child.Name .. " -> " .. child.Value.Name)
                end
                
                -- Check for attributes
                if child:IsA("Instance") then
                    local attrs = child:GetAttributes()
                    if next(attrs) then
                        print("🏷️ Attributes on " .. child.Name .. ":")
                        for attrName, attrValue in pairs(attrs) do
                            print("   " .. attrName .. " = " .. tostring(attrValue))
                        end
                    end
                end
            end
        end
    end)
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("🎯 CDT CAR DETAIL SCANNER")
print("📍 Extracts ALL details from offered cars")
print("🔍 Includes: UUID, Value, Rarity, Properties, Children")
print("📋 JSON export available")
print(string.rep("=", 60))

-- Create UI
CreateDetailedUI()

-- Start deep scan
DeepScanForData()

print("\n✅ Scanner activated!")
print("💡 Features:")
print("   • Click SCAN DETAILS for fresh scan")
print("   • Click car buttons to see ALL details")
print("   • Click EXPORT JSON to save all data")
print("   • Auto-scans every 3 seconds")
print("\n🎮 Add cars to your offer and click SCAN DETAILS!")
