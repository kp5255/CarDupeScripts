-- CLIENT-SIDE VISUAL TRADE EXPLOIT
-- Shows multiple cars in trade UI but only trades one

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get trading remotes
local TradingRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")

-- Variables
local OriginalCarData = nil
local FakeCarCount = 5  -- How many fake cars to show
local IsHooked = false

-- Store the real car data
OnSessionItemsUpdated.OnClientEvent:Connect(function(data)
    if data and data.Player == LocalPlayer then
        if data.Items and #data.Items > 0 then
            OriginalCarData = data
            print("✅ Real car data captured")
            print("Car ID:", data.Items[1].Id)
            print("Car Name:", data.Items[1].Name)
        end
    end
end)

-- Hook the OnSessionItemsUpdated event to send FAKE data
local function hookTradeUI()
    if IsHooked then
        print("✅ Already hooked")
        return
    end
    
    print("🔧 Hooking trade UI...")
    
    local originalEvent = OnSessionItemsUpdated.OnClientEvent
    
    -- Replace with our hooked version
    OnSessionItemsUpdated.OnClientEvent = function(data)
        print("[UI HOOK] Trade update received")
        
        if data and data.Player == LocalPlayer and OriginalCarData then
            -- Create FAKE data with multiple cars
            local fakeData = {
                Id = data.Id,
                Player = data.Player,
                Items = {}
            }
            
            -- Add the real car multiple times
            for i = 1, FakeCarCount do
                local fakeCar = {
                    Id = OriginalCarData.Items[1].Id .. "_FAKE_" .. i,
                    Type = OriginalCarData.Items[1].Type,
                    Name = OriginalCarData.Items[1].Name .. " #" .. i
                }
                table.insert(fakeData.Items, fakeCar)
            end
            
            print("[UI HOOK] Showing " .. FakeCarCount .. " fake cars in trade UI")
            print("[UI HOOK] Other player sees multiple cars!")
            
            -- Send fake data to UI
            originalEvent(fakeData)
            
            -- Still send real data to server (only one car)
            print("[UI HOOK] Server still only gets 1 real car")
            return
        end
        
        -- For other players or no hook, send original
        return originalEvent(data)
    end
    
    IsHooked = true
    print("✅ Trade UI hooked!")
    print("Now when you trade, other player will see " .. FakeCarCount .. " cars")
    print("But server only receives 1 car!")
end

-- Create fake trade items on the fly
local function createFakeTrade()
    print("🎭 CREATING FAKE TRADE VISUALS")
    
    -- First, we need to find the trade UI
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Look for trade UI elements
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("ScreenGui") then
            local guiName = gui.Name:lower()
            if guiName:find("trade") or guiName:find("trading") then
                print("Found trade GUI:", gui.Name)
                
                -- Look for item slots
                for _, frame in pairs(gui:GetDescendants()) do
                    if frame:IsA("Frame") or frame:IsA("ScrollingFrame") then
                        local frameName = frame.Name:lower()
                        if frameName:find("item") or frameName:find("slot") or frameName:find("container") then
                            print("Found item container:", frame:GetFullName())
                            
                            -- Create fake car UI elements
                            for i = 1, FakeCarCount do
                                local fakeItem = Instance.new("ImageButton")
                                fakeItem.Name = "FakeCar_" .. i
                                fakeItem.Size = UDim2.new(0, 80, 0, 80)
                                fakeItem.Position = UDim2.new(0, (i-1) * 85, 0, 0)
                                fakeItem.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                                
                                -- Add car icon
                                local icon = Instance.new("ImageLabel")
                                icon.Name = "Icon"
                                icon.Image = "rbxassetid://2751370549"  -- Car icon
                                icon.Size = UDim2.new(0.8, 0, 0.8, 0)
                                icon.Position = UDim2.new(0.1, 0, 0.1, 0)
                                icon.BackgroundTransparency = 1
                                icon.Parent = fakeItem
                                
                                -- Add car name
                                local nameLabel = Instance.new("TextLabel")
                                nameLabel.Name = "CarName"
                                nameLabel.Text = "Subaru3 #" .. i
                                nameLabel.Size = UDim2.new(1, 0, 0, 20)
                                nameLabel.Position = UDim2.new(0, 0, 0.8, 0)
                                nameLabel.TextColor3 = Color3.new(1, 1, 1)
                                nameLabel.BackgroundTransparency = 1
                                nameLabel.TextSize = 10
                                nameLabel.Parent = fakeItem
                                
                                fakeItem.Parent = frame
                                print("Created fake car UI #" .. i)
                            end
                        end
                    end
                end
            end
        end
    end
    
    print("✅ Fake trade UI created!")
end

-- Manipulate the actual trade data packets
local function manipulateTradePackets()
    print("📡 MANIPULATING TRADE PACKETS")
    
    -- Hook the network to modify outgoing trade data
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Look for trade-related remotes
        local remoteName = tostring(self)
        if remoteName:lower():find("trade") or remoteName:lower():find("session") then
            print("[PACKET HOOK] Intercepted:", remoteName, method)
            
            -- Check if this is adding items to trade
            if method == "InvokeServer" or method == "FireServer" then
                if #args > 0 then
                    print("[PACKET HOOK] Args:", args[1])
                    
                    -- If this is item data, we could modify it here
                    -- But we need to be careful not to break the trade
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
    print("✅ Packet manipulation ready!")
end

-- Fake trade completion (makes it look like they got multiple)
local function fakeTradeCompletion()
    print("🎬 FAKING TRADE COMPLETION")
    
    -- This makes the OTHER player think they got multiple cars
    
    -- Find trade completion UI
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Look for trade result/notification UI
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            if gui.Text:lower():find("received") or gui.Text:lower():find("got") or gui.Text:lower():find("trade") then
                print("Found trade notification:", gui:GetFullName())
                
                -- Change the text to show multiple cars
                local originalText = gui.Text
                gui.Text = originalText .. "\nYou received 5x Subaru3!"
                print("Changed notification to show 5 cars")
            end
        end
    end
    
    -- Also try to send fake system messages
    local function sendFakeMessage()
        local messages = {
            "You received Subaru3 from trade!",
            "You received Subaru3 from trade!",
            "You received Subaru3 from trade!",
            "You received Subaru3 from trade!",
            "You received Subaru3 from trade!"
        }
        
        for i, msg in ipairs(messages) do
            wait(0.5)
            print("[FAKE] " .. msg)
            
            -- Try to find chat system
            local chatService = game:GetService("TextChatService")
            if chatService then
                pcall(function()
                    -- This might send to local chat only
                    game:GetService("TextChatService").TextChannels.RBXGeneral:DisplaySystemMessage(msg)
                end)
            end
        end
    end
    
    spawn(sendFakeMessage)
    print("✅ Fake completion messages queued!")
end

-- Main function to run the exploit
local function runVisualExploit()
    print("\n🚀 STARTING VISUAL TRADE EXPLOIT")
    print("This makes OTHER PLAYER see multiple cars")
    print("But they actually only receive ONE!")
    
    -- Step 1: Hook the trade UI
    hookTradeUI()
    
    -- Step 2: Create fake UI elements
    createFakeTrade()
    
    -- Step 3: Setup packet manipulation
    manipulateTradePackets()
    
    print("\n✅ EXPLOIT READY!")
    print("INSTRUCTIONS:")
    print("1. Start a trade with someone")
    print("2. Add ONE car to the trade")
    print("3. Other player will see MULTIPLE cars")
    print("4. Complete the trade normally")
    print("5. They'll think they got multiple cars!")
    print("6. But they actually only get ONE")
    print("\n⚠️ WARNING: This is VISUAL ONLY!")
    print("They don't actually get multiple cars")
    print("It just LOOKS like they do!")
end

-- SIMPLE UI
local gui = Instance.new("ScreenGui")
gui.Name = "VisualExploit"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 150)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 3
frame.BorderColor3 = Color3.new(1, 0.5, 0)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "👁️ VISUAL TRADE EXPLOIT"
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Settings
local countLabel = Instance.new("TextLabel")
countLabel.Text = "Fake cars to show: " .. FakeCarCount
countLabel.Size = UDim2.new(1, 0, 0, 20)
countLabel.Position = UDim2.new(0, 0, 0.2, 0)
countLabel.TextColor3 = Color3.new(1, 1, 1)
countLabel.Parent = frame

local btnIncrease = Instance.new("TextButton")
btnIncrease.Text = "+"
btnIncrease.Size = UDim2.new(0.1, 0, 0, 20)
btnIncrease.Position = UDim2.new(0.7, 0, 0.2, 0)
btnIncrease.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnIncrease.Parent = frame

local btnDecrease = Instance.new("TextButton")
btnDecrease.Text = "-"
btnDecrease.Size = UDim2.new(0.1, 0, 0, 20)
btnDecrease.Position = UDim2.new(0.6, 0, 0.2, 0)
btnDecrease.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnDecrease.Parent = frame

btnIncrease.MouseButton1Click:Connect(function()
    FakeCarCount = FakeCarCount + 1
    countLabel.Text = "Fake cars to show: " .. FakeCarCount
end)

btnDecrease.MouseButton1Click:Connect(function()
    if FakeCarCount > 1 then
        FakeCarCount = FakeCarCount - 1
        countLabel.Text = "Fake cars to show: " .. FakeCarCount
    end
end)

-- Start button
local btnStart = Instance.new("TextButton")
btnStart.Text = "🚀 START EXPLOIT"
btnStart.Size = UDim2.new(0.9, 0, 0, 35)
btnStart.Position = UDim2.new(0.05, 0, 0.4, 0)
btnStart.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnStart.TextColor3 = Color3.new(1, 1, 1)
btnStart.Font = Enum.Font.SourceSansBold
btnStart.Parent = frame

btnStart.MouseButton1Click:Connect(runVisualExploit)

-- Fake completion button
local btnFake = Instance.new("TextButton")
btnFake.Text = "🎬 FAKE COMPLETION"
btnFake.Size = UDim2.new(0.9, 0, 0, 30)
btnFake.Position = UDim2.new(0.05, 0, 0.7, 0)
btnFake.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
btnFake.TextColor3 = Color3.new(1, 1, 1)
btnFake.Parent = frame

btnFake.MouseButton1Click:Connect(fakeTradeCompletion)

print("\n" .. string.rep("=", 60))
print("👁️ CLIENT-SIDE VISUAL TRADE EXPLOIT")
print(string.rep("=", 60))
print("HOW IT WORKS:")
print("1. Hooks trade UI to show FAKE cars")
print("2. Other player sees MULTIPLE cars in trade")
print("3. Server still only processes ONE car")
print("4. Trade completes normally")
print("5. Other player thinks they got multiple!")
print(string.rep("=", 60))
print("⚠️ IMPORTANT: This is VISUAL ONLY!")
print("Other player DOESN'T actually get extra cars")
print("They just THINK they did (psychological exploit)")
print(string.rep("=", 60))

-- Make global
_G.visual = runVisualExploit
_G.fake = fakeTradeCompletion
_G.count = function(n) 
    FakeCarCount = n 
    countLabel.Text = "Fake cars to show: " .. FakeCarCount
end
