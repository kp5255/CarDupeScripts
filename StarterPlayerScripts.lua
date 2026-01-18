-- Simple Trade Click Logger
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== SIMPLE TRADE CLICK LOGGER ===")

-- We'll use a different approach: Monitor the game's output
local capturedLogs = {}

-- Hook print to capture logs
local originalPrint = print
print = function(...)
    local args = {...}
    local message = table.concat(args, " ")
    
    -- Store for later
    table.insert(capturedLogs, {
        message = message,
        timestamp = os.time()
    })
    
    -- Also show in output
    originalPrint(message)
end

-- Get the actual remote function
local SessionAddItem = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes"):WaitForChild("SessionAddItem")

-- Simple function to test what works
local function TestWhatWorks()
    print("\n🧪 TESTING DIFFERENT APPROACHES...")
    
    local carName = "Car-AstonMartin8"
    
    -- Approach 1: Maybe the ID is just "AstonMartin8" (without "Car-")
    local carId = carName:match("Car%-(.+)")
    
    -- Try different session ID formats
    local sessionFormats = {
        "trade_session",
        "session_1",
        Player.UserId .. "_session",
        nil  -- No session ID
    }
    
    -- Try different item ID formats
    local itemFormats = {
        {name = "Full name", value = carName},
        {name = "Without Car-", value = carId},
        {name = "Number 8", value = 8},
        {name = "String 8", value = "8"},
        {name = "Lowercase", value = carName:lower()},
        {name = "Table with name", value = {name = carName}},
        {name = "Table with id", value = {id = carId}},
    }
    
    local successCount = 0
    
    for _, sessionId in pairs(sessionFormats) do
        for _, itemFormat in pairs(itemFormats) do
            print("\nTesting: Session=" .. tostring(sessionId) .. ", Item=" .. itemFormat.name)
            
            local params = sessionId and {sessionId, itemFormat.value} or {itemFormat.value}
            
            local success, result = pcall(function()
                return SessionAddItem:InvokeServer(unpack(params))
            end)
            
            if success then
                print("✅ SUCCESS!")
                if result then
                    print("   Result: " .. tostring(result))
                end
                successCount = successCount + 1
                
                -- Try a few more times
                for i = 1, 3 do
                    wait(0.2)
                    pcall(function()
                        SessionAddItem:InvokeServer(unpack(params))
                        print("   Repeated " .. i)
                    end)
                end
                
                return true  -- Stop if successful
            else
                -- Check error message for clues
                local errorMsg = tostring(result)
                print("❌ Failed: " .. errorMsg)
                
                -- Look for useful error messages
                if errorMsg:find("Invalid item") then
                    print("   ⚠️ Item format wrong")
                elseif errorMsg:find("session") then
                    print("   ⚠️ Session ID wrong")
                elseif errorMsg:find("not found") then
                    print("   ⚠️ Item not found in database")
                end
            end
            
            wait(0.3)
        end
    end
    
    print("\n📊 Results: " .. successCount .. " successful tests")
    return successCount > 0
end

-- Alternative: Look at what's in ServerStorage for clues
local function CheckServerStorageForCars()
    print("\n🔍 CHECKING SERVERSTORAGE FOR CAR DATA...")
    
    local ServerStorage = game:GetService("ServerStorage")
    local foundItems = {}
    
    -- Look for anything related to AstonMartin
    for _, item in pairs(ServerStorage:GetDescendants()) do
        local name = item.Name:lower()
        if name:find("aston") or name:find("martin") or name:find("car") then
            if item:IsA("Model") or item:IsA("Folder") then
                print("🚗 Found: " .. item:GetFullName())
                
                -- Check for ID values
                for _, child in pairs(item:GetChildren()) do
                    if child:IsA("StringValue") or child:IsA("IntValue") then
                        print("   " .. child.Name .. " = " .. tostring(child.Value))
                        if child.Name:lower():find("id") then
                            table.insert(foundItems, {
                                path = item:GetFullName(),
                                idName = child.Name,
                                idValue = child.Value
                            })
                        end
                    end
                end
            end
        end
    end
    
    print("\n📋 Found " .. #foundItems .. " potential car ID entries")
    return foundItems
end

-- Try to use found IDs
local function TestFoundIds(foundItems)
    if #foundItems == 0 then
        print("❌ No items found to test")
        return false
    end
    
    print("\n🧪 TESTING FOUND IDs...")
    
    for i, item in ipairs(foundItems) do
        print("\nTest " .. i .. ": " .. item.idName .. " = " .. tostring(item.idValue))
        
        -- Try with different session IDs
        local sessionIds = {"trade_session", "session_1", Player.UserId .. "_trade"}
        
        for _, sessionId in pairs(sessionIds) do
            print("  Session: " .. sessionId)
            
            local success, result = pcall(function()
                return SessionAddItem:InvokeServer(sessionId, item.idValue)
            end)
            
            if success then
                print("    ✅ SUCCESS!")
                if result then
                    print("    Result: " .. tostring(result))
                end
                return true
            else
                print("    ❌ Failed: " .. tostring(result))
            end
            
            wait(0.3)
        end
    end
    
    return false
end

-- Maybe the issue is we need to be in a specific state
local function CheckTradeState()
    print("\n🔍 CHECKING TRADE STATE...")
    
    -- Check if we're actually in a trade
    if Player.PlayerGui then
        local menu = Player.PlayerGui:FindFirstChild("Menu")
        if menu then
            local trading = menu:FindFirstChild("Trading")
            if trading then
                print("✅ Trading menu is open")
                
                -- Check PeerToPeer visibility
                local peerToPeer = trading:FindFirstChild("PeerToPeer")
                if peerToPeer then
                    print("✅ PeerToPeer is visible: " .. tostring(peerToPeer.Visible))
                    
                    -- Check if there's a session active
                    for _, child in pairs(peerToPeer:GetDescendants()) do
                        if child:IsA("TextLabel") and child.Text:find("Session") then
                            print("📋 Session info: " .. child.Text)
                        end
                    end
                end
            end
        end
    end
    
    -- Maybe we need to wait for trade to be fully set up
    print("\n⏳ Waiting 2 seconds for trade to initialize...")
    wait(2)
end

-- Main function to try everything
local function TryEverything()
    print("\n🚀 TRYING EVERYTHING...")
    
    -- Step 1: Check trade state
    CheckTradeState()
    
    -- Step 2: Test different approaches
    local test1 = TestWhatWorks()
    
    if test1 then
        print("\n🎉 Found working method!")
        return true
    end
    
    -- Step 3: Look for car data
    wait(1)
    local foundItems = CheckServerStorageForCars()
    
    if #foundItems > 0 then
        wait(1)
        local test2 = TestFoundIds(foundItems)
        
        if test2 then
            print("\n🎉 Found ID in ServerStorage!")
            return true
        end
    end
    
    -- Step 4: Last resort - maybe we need to click the button programmatically
    print("\n🔄 LAST RESORT: Programmatic button click...")
    
    local carButton = nil
    if Player.PlayerGui then
        pcall(function()
            local scrollingFrame = Player.PlayerGui:WaitForChild("Menu"):WaitForChild("Trading"):WaitForChild("PeerToPeer"):WaitForChild("Main"):WaitForChild("LocalPlayer"):WaitForChild("Content"):WaitForChild("ScrollingFrame")
            for _, item in pairs(scrollingFrame:GetChildren()) do
                if item:IsA("ImageButton") and item.Name:sub(1, 4) == "Car-" then
                    carButton = item
                    break
                end
            end
        end)
    end
    
    if carButton then
        print("Found car button: " .. carButton.Name)
        
        -- Try to click it 10 times
        for i = 1, 10 do
            pcall(function()
                carButton:Fire("Activated")
                carButton:Fire("MouseButton1Click")
                print("✅ Click attempt " .. i)
            end)
            wait(0.2)
        end
        
        print("\n⏳ Waiting to see if anything happens...")
        wait(2)
        
        -- Check if car count increased
        local newButton = nil
        pcall(function()
            local scrollingFrame = Player.PlayerGui:WaitForChild("Menu"):WaitForChild("Trading"):WaitForChild("PeerToPeer"):WaitForChild("Main"):WaitForChild("LocalPlayer"):WaitForChild("Content"):WaitForChild("ScrollingFrame")
            local carCount = 0
            for _, item in pairs(scrollingFrame:GetChildren()) do
                if item:IsA("ImageButton") and item.Name:sub(1, 4) == "Car-" then
                    carCount = carCount + 1
                end
            end
            print("Current car count: " .. carCount)
        end)
    end
    
    print("\n❌ Nothing worked")
    return false
end

-- Create simple UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeTester"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "TRADE TESTER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(255, 150, 100)
    
    local status = Instance.new("TextLabel")
    status.Text = "Trying to find correct item ID"
    status.Size = UDim2.new(1, -20, 0, 110)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 220, 255)
    status.TextWrapped = true
    
    local button = Instance.new("TextButton")
    button.Text = "🚀 TRY EVERYTHING"
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 170)
    button.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    button.MouseButton1Click:Connect(function()
        status.Text = "Testing everything...\nThis may take a minute"
        button.Text = "WORKING..."
        
        spawn(function()
            local success = TryEverything()
            
            if success then
                status.Text = "✅ Success!\nCheck other player's screen"
                button.Text = "🎉 DONE"
                button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            else
                status.Text = "❌ Nothing worked\nSee output for details"
                button.Text = "🚀 TRY AGAIN"
            end
            
            wait(2)
            button.Text = "🚀 TRY EVERYTHING"
            button.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
        end)
    end)
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    button.Parent = frame
    frame.Parent = gui
    
    return status
end

-- Initialize
CreateUI()

-- Instructions
wait(2)
print("\n=== TRADE TESTER ===")
print("Trying to find the correct item ID format")
print("\n📋 WHAT WE KNOW:")
print("1. 'Car-AstonMartin8' is NOT the correct item ID")
print("2. The server says 'Invalid item type'")
print("3. We need to find the REAL item ID")
print("\n🔍 Click 'TRY EVERYTHING' to test all possibilities")

-- Auto-run first test
spawn(function()
    wait(3)
    print("\n🔍 Starting initial tests...")
    TestWhatWorks()
end)
