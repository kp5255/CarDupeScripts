-- Session ID Hunter
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

print("=== SESSION ID HUNTER ===")

-- Function to search for session ID in trade UI
local function HuntSessionId()
    print("\n🔍 HUNTING FOR SESSION ID...")
    
    if not Player.PlayerGui then
        print("❌ No PlayerGui")
        return nil
    end
    
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then
        print("❌ No Menu")
        return nil
    end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then
        print("❌ Trading not open")
        return nil
    end
    
    -- Focus on PeerToPeer (actual trade interface)
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then
        print("❌ Not in PeerToPeer trade")
        return nil
    end
    
    print("✅ Found trade interface")
    
    -- Search strategies for finding session ID:
    local foundIds = {}
    
    print("\n🔎 STRATEGY 1: Looking for 'Session' text...")
    -- Look for TextLabels with session info
    for _, obj in pairs(peerToPeer:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local text = obj.Text
            if text and text ~= "" then
                -- Check for session patterns
                if text:lower():find("session") or text:find("ID:") or text:find("Trade:") then
                    print("Found text: \"" .. text .. "\"")
                    print("  Path: " .. obj:GetFullName())
                    
                    -- Try to extract ID
                    local patterns = {
                        "Session%s*[:%-]?%s*([%w%-_]+)",
                        "session%s*[:%-]?%s*([%w%-_]+)",
                        "ID%s*[:%-]?%s*([%w%-_]+)",
                        "Trade%s*[:%-]?%s*([%w%-_]+)",
                        "([%w%-_]+%-[%w%-_]+%-[%w%-_]+)", -- UUID-like
                    }
                    
                    for _, pattern in ipairs(patterns) do
                        local id = text:match(pattern)
                        if id and #id > 5 and id ~= "Session" and id ~= "session" then
                            print("  ✅ Extracted: " .. id)
                            table.insert(foundIds, {
                                id = id,
                                source = "TextLabel: " .. obj.Name,
                                text = text
                            })
                        end
                    end
                end
            end
        end
    end
    
    print("\n🔎 STRATEGY 2: Looking for StringValues...")
    -- Check for StringValue/IntValue objects
    for _, obj in pairs(peerToPeer:GetDescendants()) do
        if obj:IsA("StringValue") or obj:IsA("IntValue") then
            local name = obj.Name:lower()
            if name:find("session") or name:find("trade") or name:find("id") then
                print("Found value: " .. obj.Name .. " = " .. tostring(obj.Value))
                print("  Path: " .. obj:GetFullName())
                
                table.insert(foundIds, {
                    id = tostring(obj.Value),
                    source = obj.Name .. " Value",
                    text = nil
                })
            end
        end
    end
    
    print("\n🔎 STRATEGY 3: Looking for hidden Frame names...")
    -- Check Frame names for session indicators
    for _, obj in pairs(peerToPeer:GetDescendants()) do
        if obj:IsA("Frame") then
            local name = obj.Name:lower()
            if name:find("session") or name:find("trade") and not name:find("template") then
                print("Found Frame: " .. obj.Name)
                print("  Path: " .. obj:GetFullName())
                
                -- Check if it has children with IDs
                for _, child in pairs(obj:GetChildren()) do
                    if child:IsA("StringValue") then
                        print("    Child value: " .. child.Name .. " = " .. child.Value)
                    end
                end
            end
        end
    end
    
    print("\n🔎 STRATEGY 4: Check Top bar for session info...")
    -- Look at the Top bar (where "ACCEPT TRADE" button is)
    local top = peerToPeer:FindFirstChild("Top")
    if top then
        print("Checking Top bar...")
        for _, obj in pairs(top:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local text = obj.Text
                if text and text ~= "" then
                    print("  " .. obj.Name .. ": \"" .. text .. "\"")
                end
            end
        end
    end
    
    print("\n🔎 STRATEGY 5: Check Main container structure...")
    local main = peerToPeer:FindFirstChild("Main")
    if main then
        print("Main container children:")
        for _, child in pairs(main:GetChildren()) do
            print("  " .. child.Name .. " (" .. child.ClassName .. ")")
            
            -- Check LocalPlayer vs OtherPlayer containers
            if child.Name == "LocalPlayer" or child.Name == "LocalPlayer" then
                print("    This is player container")
                for _, subchild in pairs(child:GetChildren()) do
                    print("      " .. subchild.Name .. " (" .. subchild.ClassName .. ")")
                end
            end
        end
    end
    
    -- Report findings
    print("\n" .. string.rep("=", 60))
    print("SESSION ID HUNT RESULTS:")
    print(string.rep("=", 60))
    
    if #foundIds > 0 then
        print("✅ Found " .. #foundIds .. " potential session IDs:")
        for i, found in ipairs(foundIds) do
            print("\n" .. i .. ". " .. found.id)
            print("   Source: " .. found.source)
            if found.text then
                print("   Context: \"" .. found.text .. "\"")
            end
        end
        
        -- Return the most likely one (first)
        return foundIds[1].id, foundIds
    else
        print("❌ No session IDs found")
        print("\n⚠️ POSSIBLE REASONS:")
        print("1. Not in an active trade session")
        print("2. Session ID is stored differently")
        print("3. Need to wait for trade to fully initialize")
        print("4. Session ID might be in a different format")
        
        -- Alternative: Try to create a session
        print("\n🔄 ALTERNATIVE: Try to create/join a session")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes
        
        -- Check Invite remote
        local Invite = tradingService:FindFirstChild("Invite")
        if Invite then
            print("Found Invite remote - could start a session")
        end
        
        return nil, {}
    end
end

-- Try to use found session ID with car
local function TestWithSession(sessionId)
    print("\n🧪 TESTING WITH SESSION ID: " .. (sessionId or "nil"))
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local carService = ReplicatedStorage.Remotes.Services.CarServiceRemotes
    local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes
    local SessionAddItem = tradingService.SessionAddItem
    
    -- Get car ID
    local carId = nil
    pcall(function()
        local carList = carService.GetOwnedCars:InvokeServer()
        for _, carData in ipairs(carList) do
            if type(carData) == "table" and carData.Name == "AstonMartin8" then
                carId = carData.Id
                break
            end
        end
    end)
    
    if not carId then
        print("❌ Could not get car ID")
        return false
    end
    
    print("Car ID: " .. carId:sub(1, 8) + "...")
    
    if not sessionId then
        print("⚠️ No session ID - trying without...")
        
        local success, result = pcall(function()
            return SessionAddItem:InvokeServer(carId)
        end)
        
        if success then
            print("✅ Success without session ID!")
            return true
        else
            print("❌ Failed: " .. tostring(result))
            return false
        end
    end
    
    -- Try with session ID
    print("Testing: SessionAddItem:InvokeServer(\"" .. sessionId .. "\", \"" .. carId:sub(1, 8) + "...\")")
    
    local success, result = pcall(function()
        return SessionAddItem:InvokeServer(sessionId, carId)
    end)
    
    if success then
        print("✅ SUCCESS!")
        if result then
            print("Result: " .. tostring(result))
        end
        
        -- Try multiple times
        for i = 1, 3 do
            wait(0.2)
            pcall(function()
                SessionAddItem:InvokeServer(sessionId, carId)
                print("Repeated " .. i)
            end)
        end
        
        return true
    else
        print("❌ Failed: " .. tostring(result))
        return false
    end
end

-- Create simple UI
local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "SessionHunter"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "SESSION ID HUNTER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    
    local status = Instance.new("TextLabel")
    status.Text = "Looking for session ID\nStart a trade first!"
    status.Size = UDim2.new(1, -20, 0, 110)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(200, 230, 255)
    status.TextWrapped = true
    
    local huntBtn = Instance.new("TextButton")
    huntBtn.Text = "🔍 HUNT SESSION ID"
    huntBtn.Size = UDim2.new(1, -20, 0, 30)
    huntBtn.Position = UDim2.new(0, 10, 0, 170)
    huntBtn.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    huntBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    huntBtn.MouseButton1Click:Connect(function()
        status.Text = "Hunting for session ID..."
        huntBtn.Text = "SEARCHING..."
        
        spawn(function()
            local sessionId, allIds = HuntSessionId()
            
            if sessionId then
                status.Text = "✅ Found: " .. sessionId:sub(1, 20) + "..."
                
                -- Test it
                wait(1)
                TestWithSession(sessionId)
            else
                status.Text = "❌ No session ID found\nSee output for details"
            end
            
            wait(2)
            huntBtn.Text = "🔍 HUNT SESSION ID"
        end)
    end)
    
    -- Parent everything
    title.Parent = frame
    status.Parent = frame
    huntBtn.Parent = frame
    frame.Parent = gui
    
    return status
end

-- Initialize
CreateUI()

-- Instructions
wait(3)
print("\n=== SESSION ID HUNTER ===")
print("We need to find the ACTUAL session ID from a live trade")
print("\n📋 INSTRUCTIONS:")
print("1. Start a trade with another player")
print("2. Wait for trade to fully load (both players connected)")
print("3. Click 'HUNT SESSION ID' button")
print("4. Check the output - it should find session ID")
print("5. Share what it finds!")

-- Auto-hunt after delay
spawn(function()
    wait(10)
    print("\n🔍 Auto-hunting session ID in 10 seconds...")
    print("Make sure you're in a trade!")
    
    wait(10)
    print("\n🔍 Starting auto-hunt...")
    HuntSessionId()
end)
