-- 🎯 INSPECT MULTI-CAR SELECTION GUI
local Players = game:GetService("Players")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 INSPECTING MULTI-CAR SELECTION")
print("=" .. string.rep("=", 50))

-- ===== ANALYZE MULTI-CAR SELECTION =====
local function analyzeCarGUI()
    print("\n🔍 Analyzing MultiCarSelection GUI...")
    
    local gui = player.PlayerGui:FindFirstChild("MultiCarSelection")
    if not gui then
        print("❌ MultiCarSelection not found")
        return
    end
    
    print("✅ Found MultiCarSelection GUI")
    print("   Contains " .. #gui:GetChildren() .. " children")
    
    -- Look for car list
    local carList = nil
    local buttonCount = 0
    local frameCount = 0
    
    for _, obj in pairs(gui:GetDescendants()) do
        if obj:IsA("ScrollingFrame") then
            carList = obj
            print("📜 Found ScrollingFrame: " .. obj.Name)
            print("   Children: " .. #obj:GetChildren())
        elseif obj:IsA("TextButton") or obj:IsA("ImageButton") then
            buttonCount = buttonCount + 1
            if obj.Name:lower():find("car") then
                print("🚗 Car button: " .. obj.Name)
            end
        elseif obj:IsA("Frame") then
            frameCount = frameCount + 1
        end
    end
    
    print("\n📊 GUI Statistics:")
    print("   Total frames: " .. frameCount)
    print("   Total buttons: " .. buttonCount)
    
    -- Try to extract car names from the GUI
    if carList then
        print("\n🔎 Checking car list contents...")
        
        local carEntries = {}
        for _, child in pairs(carList:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                -- Look for text labels
                for _, label in pairs(child:GetDescendants()) do
                    if label:IsA("TextLabel") and #label.Text > 2 then
                        table.insert(carEntries, {
                            Frame = child.Name,
                            Text = label.Text,
                            Path = label:GetFullName()
                        })
                    end
                end
            end
        end
        
        if #carEntries > 0 then
            print("🎯 Found " .. #carEntries .. " car entries:")
            for i, entry in ipairs(carEntries) do
                if i <= 10 then  -- Show first 10
                    print("   " .. i .. ". " .. entry.Text .. " (" .. entry.Frame .. ")")
                end
            end
        end
    end
    
    return gui
end

-- ===== FIND CAR DATA IN GUI =====
local function extractCarData()
    print("\n📖 Extracting car data from GUI...")
    
    local gui = player.PlayerGui:FindFirstChild("MultiCarSelection")
    if not gui then return {} end
    
    local carData = {}
    
    -- Function to recursively search for data
    local function searchForData(obj, path)
        if obj:IsA("TextLabel") and #obj.Text > 2 then
            local text = obj.Text
            -- Check if it looks like a car name
            if text:find("Bontlay") or text:find("Jegar") or text:find("Corsaro") or
               text:find("Lavish") or text:find("Sportler") or
               text:find("Car") or text:find("Model") then
                table.insert(carData, {
                    Type = "Car Name",
                    Path = obj:GetFullName(),
                    Value = text
                })
            end
        elseif obj:IsA("StringValue") or obj:IsA("IntValue") then
            local success, value = pcall(function()
                return obj.Value
            end)
            if success and tostring(value):len() > 5 then
                table.insert(carData, {
                    Type = obj.ClassName,
                    Path = obj:GetFullName(),
                    Value = tostring(value)
                })
            end
        end
        
        -- Continue searching children
        for _, child in pairs(obj:GetChildren()) do
            searchForData(child, path .. "/" .. child.Name)
        end
    end
    
    searchForData(gui, "MultiCarSelection")
    
    return carData
end

-- ===== CLONE CAR BUTTONS =====
local function cloneCarButtons()
    print("\n🎯 Attempting to clone car selection...")
    
    local gui = player.PlayerGui:FindFirstChild("MultiCarSelection")
    if not gui then
        print("❌ GUI not found")
        return false
    end
    
    -- Find car buttons
    local carButtons = {}
    for _, obj in pairs(gui:GetDescendants()) do
        if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and 
           (obj.Name:lower():find("car") or obj.Name:lower():find("select")) then
            table.insert(carButtons, obj)
        end
    end
    
    print("Found " .. #carButtons .. " car buttons")
    
    if #carButtons > 0 then
        -- Try to click them
        for i, button in ipairs(carButtons) do
            if i <= 5 then  -- Try first 5 buttons
                print("Clicking button: " .. button.Name)
                
                -- Simulate click
                local success = pcall(function()
                    -- Try to fire click event
                    for _, connection in pairs(getconnections(button.MouseButton1Click)) do
                        connection:Fire()
                        print("   ✅ Fired click event")
                    end
                    
                    -- Also try to call Activated if it exists
                    if button:IsA("TextButton") then
                        button.Activated:Fire()
                        print("   ✅ Fired Activated event")
                    end
                end)
                
                if success then
                    print("   Success!")
                else
                    print("   Failed")
                end
                
                task.wait(0.5)
            end
        end
        return true
    end
    
    return false
end

-- ===== CREATE CAR DUPLICATOR =====
local function createCarDuplicator()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarDuplicatorTool"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 320, 0, 350)
    main.Position = UDim2.new(0, 10, 0, 50)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎯 CAR DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = main
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -40)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "MultiCarSelection GUI found!\nThis likely contains your 54 cars."
    status.Size = UDim2.new(1, -20, 0, 50)
    status.Position = UDim2.new(0, 10, 0, 10)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = content
    
    -- Results display
    local results = Instance.new("ScrollingFrame")
    results.Size = UDim2.new(1, -20, 0, 120)
    results.Position = UDim2.new(0, 10, 1, -180)
    results.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    results.BorderSizePixel = 0
    results.ScrollBarThickness = 6
    results.Parent = content
    
    -- Buttons
    local analyzeBtn = Instance.new("TextButton")
    analyzeBtn.Text = "🔍 ANALYZE GUI"
    analyzeBtn.Size = UDim2.new(1, -20, 0, 35)
    analyzeBtn.Position = UDim2.new(0, 10, 0, 70)
    analyzeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    analyzeBtn.TextColor3 = Color3.new(1, 1, 1)
    analyzeBtn.Font = Enum.Font.GothamBold
    analyzeBtn.TextSize = 14
    analyzeBtn.Parent = content
    
    local extractBtn = Instance.new("TextButton")
    extractBtn.Text = "📖 EXTRACT DATA"
    extractBtn.Size = UDim2.new(1, -20, 0, 35)
    extractBtn.Position = UDim2.new(0, 10, 0, 115)
    extractBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    extractBtn.TextColor3 = Color3.new(1, 1, 1)
    extractBtn.Font = Enum.Font.GothamBold
    extractBtn.TextSize = 14
    extractBtn.Parent = content
    
    local cloneBtn = Instance.new("TextButton")
    cloneBtn.Text = "🎯 CLONE CARS"
    cloneBtn.Size = UDim2.new(1, -20, 0, 35)
    cloneBtn.Position = UDim2.new(0, 10, 0, 160)
    cloneBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    cloneBtn.TextColor3 = Color3.new(1, 1, 1)
    cloneBtn.Font = Enum.Font.GothamBold
    cloneBtn.TextSize = 14
    cloneBtn.Parent = content
    
    -- Add corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    addCorner(main)
    addCorner(title)
    addCorner(status)
    addCorner(results)
    addCorner(analyzeBtn)
    addCorner(extractBtn)
    addCorner(cloneBtn)
    
    -- Functions
    local function updateResults(text, color)
        results:ClearAllChildren()
        
        local label = Instance.new("TextLabel")
        label.Text = text
        label.Size = UDim2.new(1, -10, 1, -10)
        label.Position = UDim2.new(0, 5, 0, 5)
        label.BackgroundTransparency = 1
        label.TextColor3 = color or Color3.new(1, 1, 1)
        label.Font = Enum.Font.Code
        label.TextSize = 10
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Parent = results
    end
    
    -- Button actions
    analyzeBtn.MouseButton1Click:Connect(function()
        analyzeBtn.Text = "ANALYZING..."
        analyzeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Analyzing MultiCarSelection GUI..."
        
        task.spawn(function()
            analyzeCarGUI()
            status.Text = "Analysis complete! Check console."
            updateResults("GUI analysis complete.\nCheck ROBLOX console for details.")
            
            analyzeBtn.Text = "🔍 ANALYZE GUI"
            analyzeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        end)
    end)
    
    extractBtn.MouseButton1Click:Connect(function()
        extractBtn.Text = "EXTRACTING..."
        extractBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Extracting car data from GUI..."
        
        task.spawn(function()
            local carData = extractCarData()
            
            if #carData > 0 then
                local resultText = "🎯 EXTRACTED " .. #carData .. " ITEMS:\n\n"
                
                for i, data in ipairs(carData) do
                    if i <= 8 then
                        resultText = resultText .. i .. ". " .. data.Type .. "\n"
                        resultText = resultText .. "   " .. data.Path .. "\n"
                        resultText = resultText .. "   Value: " .. data.Value:sub(1, 30) .. "\n\n"
                    end
                end
                
                updateResults(resultText, Color3.fromRGB(0, 255, 150))
                status.Text = "✅ Extracted " .. #carData .. " data items"
            else
                updateResults("❌ No car data found in GUI", Color3.fromRGB(255, 100, 100))
                status.Text = "❌ No car data found"
            end
            
            extractBtn.Text = "📖 EXTRACT DATA"
            extractBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end)
    end)
    
    cloneBtn.MouseButton1Click:Connect(function()
        cloneBtn.Text = "CLONING..."
        cloneBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        status.Text = "Attempting to clone car selection..."
        updateResults("Cloning car buttons...", Color3.fromRGB(255, 200, 100))
        
        task.spawn(function()
            local success = cloneCarButtons()
            
            if success then
                status.Text = "✅ Clone attempt complete!"
                updateResults("Clone attempts sent.\nCheck if cars were added!", Color3.fromRGB(0, 255, 0))
            else
                status.Text = "❌ Clone failed"
                updateResults("Could not clone cars.", Color3.fromRGB(255, 100, 100))
            end
            
            cloneBtn.Text = "🎯 CLONE CARS"
            cloneBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    -- Initial display
    updateResults("MultiCarSelection GUI found!\nClick ANALYZE to start.", Color3.fromRGB(150, 150, 150))
    
    return gui
end

-- ===== QUICK ANALYSIS =====
print("\n🚀 Quick analysis starting...")

-- First, analyze the GUI
analyzeCarGUI()

task.wait(1)

-- Extract data
local carData = extractCarData()
if #carData > 0 then
    print("\n🎯 Found " .. #carData .. " potential car data items")
    for i, data in ipairs(carData) do
        if i <= 3 then
            print(i .. ". " .. data.Type .. ": " .. data.Value:sub(1, 30))
        end
    end
end

-- Create UI
task.wait(1)
local ui = createCarDuplicator()

print("\n✅ Duplicator Tool Created!")
print("\n💡 Click these buttons:")
print("1. ANALYZE GUI - Detailed analysis")
print("2. EXTRACT DATA - Find car names/IDs")
print("3. CLONE CARS - Try to duplicate selection")

print("\n🎯 MultiCarSelection is YOUR CAR GARAGE!")
print("This is where your 54 cars are displayed.")
print("Now we need to figure out how to ADD more!")
