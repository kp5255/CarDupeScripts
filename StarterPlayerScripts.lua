-- Trade Duplicator - Inside ScrollingFrame
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

wait(2)

print("=== TRADE DUPLICATOR - INSIDE SCROLLINGFRAME ===")

-- Get remotes
local TradingServiceRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local SessionAddItem = TradingServiceRemotes:WaitForChild("SessionAddItem")
local SessionSetConfirmation = TradingServiceRemotes:WaitForChild("SessionSetConfirmation")
local OnSessionItemsUpdated = TradingServiceRemotes:WaitForChild("OnSessionItemsUpdated")

print("✅ Loaded TradingServiceRemotes")

-- Get the ScrollingFrame container
local function GetScrollingFrame()
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
    return content:FindFirstChild("ScrollingFrame")
end

-- Search INSIDE the ScrollingFrame for car items
local function FindCarItemsInScrollingFrame()
    print("\n🔍 SEARCHING INSIDE SCROLLINGFRAME...")
    
    local scrollingFrame = GetScrollingFrame()
    if not scrollingFrame then
        print("❌ No ScrollingFrame found")
        return {}
    end
    
    print("✅ Found ScrollingFrame")
    print("ScrollingFrame children count: " .. #scrollingFrame:GetChildren())
    
    local carItems = {}
    
    -- Check ALL children of ScrollingFrame
    for _, child in pairs(scrollingFrame:GetChildren()) do
        print("\nChecking: " .. child.Name .. " (" .. child.ClassName .. ")")
        
        -- If child is a Frame, check its contents
        if child:IsA("Frame") then
            print("  This is a Frame, checking its children...")
            
            for _, frameChild in pairs(child:GetChildren()) do
                print("    - " .. frameChild.Name .. " (" .. frameChild.ClassName .. ")")
                
                -- Look for TextButtons, ImageButtons, or TextLabels that might contain car info
                if frameChild:IsA("TextButton") or frameChild:IsA("ImageButton") then
                    local buttonName = frameChild.Name
                    local buttonText = frameChild:IsA("TextButton") and frameChild.Text or ""
                    
                    print("      Button: " .. buttonName .. " - \"" .. buttonText .. "\"")
                    
                    -- Check if it contains car info
                    if buttonName:lower():find("car") or buttonText:lower():find("car") then
                        print("      🚗 CAR FOUND!")
                        table.insert(carItems, {
                            object = frameChild,
                            name = buttonName,
                            text = buttonText,
                            parent = child
                        })
                    end
                elseif frameChild:IsA("TextLabel") then
                    print("      Label: \"" .. frameChild.Text .. "\"")
                    if frameChild.Text:lower():find("car") then
                        print("      🚗 CAR TEXT FOUND!")
                    end
                end
            end
        elseif child:IsA("TextButton") or child:IsA("ImageButton") then
            -- Direct button in ScrollingFrame
            local buttonName = child.Name
            local buttonText = child:IsA("TextButton") and child.Text or ""
            
            print("  Direct button: " .. buttonName .. " - \"" .. buttonText .. "\"")
            
            if buttonName:lower():find("car") or buttonText:lower():find("car") then
                print("  🚗 DIRECT CAR BUTTON FOUND!")
                table.insert(carItems, {
                    object = child,
                    name = buttonName,
                    text = buttonText,
                    parent = scrollingFrame
                })
            end
        end
        
        -- Also check for any StringValue/IntValue that might be car ID
        for _, valueChild in pairs(child:GetDescendants()) do
            if (valueChild:IsA("StringValue") or valueChild:IsA("IntValue")) and 
               valueChild.Name:lower():find("id") then
                print("  Found ID value: " .. valueChild.Name .. " = " .. tostring(valueChild.Value))
            end
        end
    end
    
    print("\n📊 Found " .. #carItems .. " car items in ScrollingFrame")
    return carItems
end

-- Get the actual car ID from a car item
local function GetCarIdFromItem(carItem)
    print("\n🔑 EXTRACTING CAR ID FROM ITEM...")
    print("Item name: " .. carItem.name)
    print("Item text: \"" .. carItem.text .. "\"")
    
    -- Method 1: Look for ID in children
    for _, child in pairs(carItem.object:GetDescendants()) do
        if child:IsA("StringValue") then
            if child.Name:lower():find("id") or child.Name:lower():find("car") then
                print("✅ Found StringValue ID: " .. child.Value)
                return child.Value
            end
        elseif child:IsA("IntValue") then
            if child.Name:lower():find("id") then
                print("✅ Found IntValue ID: " .. child.Value)
                return tostring(child.Value)
            end
        end
    end
    
    -- Method 2: Extract from name
    local idFromName = carItem.name:match("%d+")
    if idFromName then
        print("✅ Extracted ID from name: " .. idFromName)
        return idFromName
    end
    
    -- Method 3: Extract from text
    if carItem.text ~= "" then
        local idFromText = carItem.text:match("%d+")
        if idFromText then
            print("✅ Extracted ID from text: " .. idFromText)
            return idFromText
        end
    end
    
    -- Method 4: Use the object name
    print("⚠️ Using object name as ID: " .. carItem.object.Name)
    return carItem.object.Name
end

-- Get session ID (try to find it in UI)
local function GetSessionId()
    print("\n🆔 LOOKING FOR SESSION ID...")
    
    -- Look for session ID in the trade UI
    if Player.PlayerGui then
        local menu = Player.PlayerGui:FindFirstChild("Menu")
        if menu then
            local trading = menu:FindFirstChild("Trading")
            if trading then
                -- Search for any text containing "session"
                for _, obj in pairs(trading:GetDescendants()) do
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        local text = obj.Text:lower()
                        if text:find("session") then
                            local sessionId = text:match("session[%s:]?([%w_]+)")
                            if sessionId then
                                print("✅ Found session ID in UI: " .. sessionId)
                                return sessionId
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- If not found, use a default
    print("⚠️ Using default session ID")
    return "trade_session_" .. Player.UserId
end

-- Main duplication function
local function DuplicateCar()
    print("\n🚀 ATTEMPTING CAR DUPLICATION...")
    
    -- Step 1: Find car items in ScrollingFrame
    local carItems = FindCarItemsInScrollingFrame()
    
    if #carItems == 0 then
        print("❌ No cars found in trade window")
        print("Add a car to the trade first!")
        return false
    end
    
    print("\n🎯 Found " .. #carItems .. " car(s). Using first one:")
    local firstCar = carItems[1]
    
    -- Step 2: Get car ID
    local carId = GetCarIdFromItem(firstCar)
    local sessionId = GetSessionId()
    
    print("\n📋 DUPLICATION PARAMETERS:")
    print("Session ID: " .. sessionId)
    print("Car ID: " .. carId)
    print("Car Name: " .. firstCar.name)
    
    -- Step 3: Try to add duplicate
    local successCount = 0
    local totalAttempts = 0
    
    print("\n🔄 TRYING TO ADD DUPLICATE...")
    
    -- Try multiple parameter formats
    local testParams = {
        {desc = "Simple ID", params = {sessionId, carId}},
        {desc = "ID with quantity", params = {sessionId, carId, 1}},
        {desc = "ID with quantity and flag", params = {sessionId, carId, 1, "duplicate"}},
        {desc = "Table format", params = {sessionId, {id = carId, name = firstCar.name}}},
        {desc = "Just car name", params = {sessionId, firstCar.name}},
        {desc = "Car name with quantity", params = {sessionId, firstCar.name, 2}}
    }
    
    for i, test in ipairs(testParams) do
        totalAttempts = totalAttempts + 1
        print("\nAttempt " .. i .. ": " .. test.desc)
        print("Params: " .. tostring(test.params[2]) .. " ...")
        
        local success, result = pcall(function()
            return SessionAddItem:InvokeServer(unpack(test.params))
        end)
        
        if success then
            print("✅ Success!")
            if result then
                print("   Server response: " .. tostring(result))
            end
            successCount = successCount + 1
        else
            print("❌ Failed")
        end
        
        wait(0.3)  -- Small delay between attempts
    end
    
    -- Step 4: Also try clicking the car button multiple times
    print("\n🖱️ TRYING BUTTON CLICKS...")
    for i = 1, 5 do
        pcall(function()
            firstCar.object:Fire("MouseButton1Click")
            firstCar.object:Fire("Activated")
            print("✅ Button click " .. i)
            successCount = successCount + 1
        end)
        wait(0.2)
    end
    
    -- Step 5: Force update
    if successCount > 0 then
        print("\n🔄 FORCING SESSION UPDATE...")
        pcall(function()
            OnSessionItemsUpdated:FireServer(sessionId, {forceUpdate = true})
        end)
        
        -- Wait and check
        wait(1)
        
        local newCarItems = FindCarItemsInScrollingFrame()
        print("\n📊 FINAL RESULTS:")
        print("Original cars: " .. #carItems)
        print("Current cars: " .. #newCarItems)
        print("Success attempts: " .. successCount .. "/" .. (totalAttempts + 5))
        
        if #newCarItems > #carItems then
            print("🎉 DUPLICATION SUCCESSFUL!")
            return true
        else
            print("⚠️ Item count unchanged")
        end
    else
        print("❌ All attempts failed")
    end
    
    return successCount > 0
end

-- Create UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "InsideScrollingFrameDuplicator"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 250)
    frame.Position = UDim2.new(0.5, -175, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "INSIDE SCROLLINGFRAME"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.Font = Enum.Font.GothamBold
    
    local status = Instance.new("TextLabel")
    status.Text = "Status: Ready\nWill search INSIDE ScrollingFrame"
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 230, 255)
    status.TextWrapped = true
    
    -- Buttons
    local buttons = {
        {text = "🔍 FIND CARS", func = FindCarItemsInScrollingFrame, pos = UDim2.new(0.025, 0, 0, 140)},
        {text = "🚀 DUPLICATE", func = DuplicateCar, pos = UDim2.new(0.525, 0, 0, 140)},
        {text = "🆔 GET SESSION", func = GetSessionId, pos = UDim2.new(0.025, 0, 0, 175)},
        {text = "🔄 FORCE UPDATE", func = function()
            pcall(function()
                OnSessionItemsUpdated:FireServer(GetSessionId(), {force = true})
            end)
        end, pos = UDim2.new(0.525, 0, 0, 175)},
        {text = "🎯 SCROLLINGFRAME INFO", func = function()
            local sf = GetScrollingFrame()
            if sf then
                print("ScrollingFrame Info:")
                print("Children: " .. #sf:GetChildren())
                print("Visible: " .. tostring(sf.Visible))
            end
        end, pos = UDim2.new(0.025, 0, 0, 210)}
    }
    
    for _, btnInfo in pairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.text
        btn.Size = UDim2.new(0.45, 0, 0, 30)
        btn.Position = btnInfo.pos
        btn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        
        btn.MouseButton1Click:Connect(function()
            status.Text = "Running: " .. btnInfo.text
            spawn(function()
                btnInfo.func()
                wait(0.5)
                status.Text = "Completed: " .. btnInfo.text
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

-- Auto-start
wait(3)
print("\n=== INSIDE SCROLLINGFRAME DUPLICATOR ===")
print("This searches INSIDE the ScrollingFrame for car items")
print("\n📋 HOW TO USE:")
print("1. Start trade with another player")
print("2. Add a CAR to the trade")
print("3. Click 'FIND CARS' to locate car in ScrollingFrame")
print("4. Click 'DUPLICATE' to attempt duplication")
print("5. Check other player's screen for duplicates")

-- Run initial scan
spawn(function()
    wait(5)
    print("\n🔍 Initial scan of ScrollingFrame...")
    FindCarItemsInScrollingFrame()
end)

-- Keybinds
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        print("\n🎮 F KEY - FINDING CARS")
        FindCarItemsInScrollingFrame()
    elseif input.KeyCode == Enum.KeyCode.D then
        print("\n🎮 D KEY - DUPLICATING")
        DuplicateCar()
    end
end)

print("\n🔑 QUICK KEYS:")
print("F = Find cars in ScrollingFrame")
print("D = Duplicate car")
print("\n⚠️ Make sure you're IN A TRADE with a car added!")
