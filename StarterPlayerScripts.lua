-- Deep Car Button Inspector
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

print("=== DEEP CAR BUTTON INSPECTOR ===")

-- Get trade container
local function GetTradeContainer()
    if not Player.PlayerGui then return nil end
    return Player.PlayerGui:WaitForChild("Menu"):WaitForChild("Trading"):WaitForChild("PeerToPeer"):WaitForChild("Main"):WaitForChild("LocalPlayer"):WaitForChild("Content"):WaitForChild("ScrollingFrame")
end

-- Deep inspect the car button
local function DeepInspectCarButton()
    print("\n🔍 DEEP INSPECTION OF CAR BUTTON...")
    
    local container = GetTradeContainer()
    if not container then
        print("❌ No trade container")
        return nil
    end
    
    -- Find car button
    local carButton = nil
    for _, item in pairs(container:GetChildren()) do
        if item:IsA("ImageButton") and item.Name:sub(1, 4) == "Car-" then
            carButton = item
            break
        end
    end
    
    if not carButton then
        print("❌ No car button found")
        return nil
    end
    
    print("🎯 CAR BUTTON FOUND: " .. carButton.Name)
    print("Class: " .. carButton.ClassName)
    print("Visible: " .. tostring(carButton.Visible))
    
    -- Get ALL properties of the button
    print("\n📋 BUTTON PROPERTIES:")
    pcall(function() print("  Position: " .. tostring(carButton.Position)) end)
    pcall(function() print("  Size: " .. tostring(carButton.Size)) end)
    pcall(function() print("  Image: " .. tostring(carButton.Image)) end)
    pcall(function() print("  ImageColor3: " .. tostring(carButton.ImageColor3)) end)
    
    -- Count ALL descendants
    local allDescendants = carButton:GetDescendants()
    print("\n📊 TOTAL DESCENDANTS: " .. #allDescendants)
    
    -- Group descendants by type
    local byType = {}
    for _, descendant in pairs(allDescendants) do
        local className = descendant.ClassName
        byType[className] = (byType[className] or 0) + 1
    end
    
    print("Descendants by type:")
    for className, count in pairs(byType) do
        print("  " .. className .. ": " .. count)
    end
    
    -- Show EVERY StringValue and IntValue
    print("\n🔑 ALL VALUE OBJECTS:")
    local foundValues = {}
    
    for _, descendant in pairs(allDescendants) do
        if descendant:IsA("StringValue") then
            print("📝 StringValue: " .. descendant.Name .. " = \"" .. descendant.Value .. "\"")
            table.insert(foundValues, {
                type = "string",
                name = descendant.Name,
                value = descendant.Value
            })
        elseif descendant:IsA("IntValue") then
            print("🔢 IntValue: " .. descendant.Name .. " = " .. descendant.Value)
            table.insert(foundValues, {
                type = "int",
                name = descendant.Name,
                value = descendant.Value
            })
        elseif descendant:IsA("NumberValue") then
            print("🔢 NumberValue: " .. descendant.Name .. " = " .. descendant.Value)
            table.insert(foundValues, {
                type = "number",
                name = descendant.Name,
                value = descendant.Value
            })
        elseif descendant:IsA("BoolValue") then
            print("✅ BoolValue: " .. descendant.Name .. " = " .. tostring(descendant.Value))
            table.insert(foundValues, {
                type = "bool",
                name = descendant.Name,
                value = descendant.Value
            })
        elseif descendant:IsA("ObjectValue") then
            if descendant.Value then
                print("🎯 ObjectValue: " .. descendant.Name .. " -> " .. descendant.Value:GetFullName())
                table.insert(foundValues, {
                    type = "object",
                    name = descendant.Name,
                    value = descendant.Value
                })
            end
        end
    end
    
    -- Show ALL TextLabels and their text
    print("\n📝 ALL TEXTLABELS:")
    for _, descendant in pairs(allDescendants) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
            local text = descendant.Text
            if text and text ~= "" then
                print("  " .. descendant.Name .. ": \"" .. text .. "\"")
            end
        end
    end
    
    -- Show ALL Frame children structure
    print("\n🏗️ BUTTON STRUCTURE (first 2 levels):")
    local function PrintStructure(obj, depth, maxDepth)
        if depth > maxDepth then return end
        
        local indent = string.rep("  ", depth)
        print(indent .. obj.Name .. " (" .. obj.ClassName .. ")")
        
        if depth < maxDepth then
            for _, child in pairs(obj:GetChildren()) do
                PrintStructure(child, depth + 1, maxDepth)
            end
        end
    end
    
    PrintStructure(carButton, 0, 2)
    
    return foundValues
end

-- Try to click the button and see what happens
local function TestButtonClick()
    print("\n🖱️ TESTING BUTTON CLICK...")
    
    local container = GetTradeContainer()
    if not container then return nil end
    
    -- Find car button
    local carButton = nil
    for _, item in pairs(container:GetChildren()) do
        if item:IsA("ImageButton") and item.Name:sub(1, 4) == "Car-" then
            carButton = item
            break
        end
    end
    
    if not carButton then
        print("❌ No car button")
        return false
    end
    
    print("Testing clicks on: " .. carButton.Name)
    
    -- Try different click methods
    local methods = {
        {"MouseButton1Click", function() carButton:Fire("MouseButton1Click") end},
        {"Activated", function() carButton:Fire("Activated") end},
        {"MouseButton1Down/Up", function() 
            carButton:Fire("MouseButton1Down")
            wait(0.05)
            carButton:Fire("MouseButton1Up")
        end}
    }
    
    for i = 1, 5 do
        print("\nClick attempt " .. i .. ":")
        
        for _, method in ipairs(methods) do
            local methodName = method[1]
            local methodFunc = method[2]
            
            local success, result = pcall(methodFunc)
            if success then
                print("  ✅ " .. methodName .. " worked")
            else
                print("  ❌ " .. methodName .. " failed: " .. tostring(result))
            end
            
            wait(0.1)
        end
    end
    
    return true
end

-- Look for RemoteEvents on the button
local function FindButtonRemotes()
    print("\n📡 LOOKING FOR REMOTES ON BUTTON...")
    
    local container = GetTradeContainer()
    if not container then return nil end
    
    -- Find car button
    local carButton = nil
    for _, item in pairs(container:GetChildren()) do
        if item:IsA("ImageButton") and item.Name:sub(1, 4) == "Car-" then
            carButton = item
            break
        end
    end
    
    if not carButton then
        print("❌ No car button")
        return {}
    end
    
    local foundRemotes = {}
    
    -- Check button and all descendants for RemoteEvents
    for _, descendant in pairs(carButton:GetDescendants()) do
        if descendant:IsA("RemoteEvent") then
            print("🎯 Found RemoteEvent: " .. descendant.Name)
            print("  Path: " .. descendant:GetFullName())
            table.insert(foundRemotes, descendant)
        elseif descendant:IsA("RemoteFunction") then
            print("🎯 Found RemoteFunction: " .. descendant.Name)
            print("  Path: " .. descendant:GetFullName())
            table.insert(foundRemotes, descendant)
        end
    end
    
    if #foundRemotes == 0 then
        print("❌ No remotes found on button")
    else
        print("📊 Found " .. #foundRemotes .. " remote(s)")
    end
    
    return foundRemotes
end

-- Try to fire remotes if found
local function TestButtonRemotes()
    print("\n🧪 TESTING BUTTON REMOTES...")
    
    local remotes = FindButtonRemotes()
    
    for _, remote in pairs(remotes) do
        print("\nTesting remote: " .. remote.Name)
        
        -- Try different data to send
        local testData = {
            "add",
            "select",
            "click",
            carButton.Name,
            1,
            {action = "add", item = carButton.Name}
        }
        
        for _, data in ipairs(testData) do
            print("  Sending: " .. tostring(data))
            
            local success, result = pcall(function()
                if remote:IsA("RemoteEvent") then
                    return remote:FireServer(data)
                else
                    return remote:InvokeServer(data)
                end
            end)
            
            if success then
                print("    ✅ Success!")
                if result then
                    print("    Result: " .. tostring(result))
                end
            else
                print("    ❌ Failed: " .. tostring(result))
            end
            
            wait(0.2)
        end
    end
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DeepInspector"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "DEEP INSPECTOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(255, 150, 100)
    
    local status = Instance.new("TextLabel")
    status.Text = "Deep inspection of car button\nLooking for hidden values"
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 230, 255)
    status.TextWrapped = true
    
    -- Buttons
    local buttons = {
        {text = "🔍 DEEP INSPECT", func = DeepInspectCarButton, pos = UDim2.new(0.025, 0, 0, 140)},
        {text = "🖱️ TEST CLICKS", func = TestButtonClick, pos = UDim2.new(0.525, 0, 0, 140)},
        {text = "📡 FIND REMOTES", func = FindButtonRemotes, pos = UDim2.new(0.025, 0, 0, 175)},
        {text = "🧪 TEST REMOTES", func = TestButtonRemotes, pos = UDim2.new(0.525, 0, 0, 175)},
        {text = "🚀 RUN ALL", func = function()
            print("\n=== RUNNING ALL TESTS ===")
            DeepInspectCarButton()
            wait(1)
            TestButtonClick()
            wait(1)
            FindButtonRemotes()
            wait(1)
            TestButtonRemotes()
        end, pos = UDim2.new(0.025, 0, 0, 210)}
    }
    
    for _, btnInfo in pairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.text
        btn.Size = UDim2.new(0.45, 0, 0, 30)
        btn.Position = btnInfo.pos
        btn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        btn.MouseButton1Click:Connect(function()
            status.Text = "Running: " .. btnInfo.text
            spawn(function()
                btnInfo.func()
                wait(0.5)
                status.Text = "Completed"
            end)
        end)
        
        btn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    frame.Parent = gui
    
    return status
end

-- Initialize
CreateUI()

-- Auto-run deep inspection
wait(2)
print("\n=== DEEP CAR BUTTON INSPECTOR ===")
print("We need to find the ACTUAL item ID values")
print("\n📋 CRITICAL QUESTIONS:")
print("1. Are there StringValue/IntValue objects INSIDE the car button?")
print("2. What are their names and values?")
print("3. Are there RemoteEvents on the button?")
print("\n🔍 Click 'DEEP INSPECT' to find answers!")

spawn(function()
    wait(3)
    print("\n🔍 Starting deep inspection...")
    DeepInspectCarButton()
end)
