-- FIXED: Visual Trade Exploit
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get trading remotes
local TradingRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")

-- Variables
local OriginalCarData = nil
local FakeCarCount = 5
local IsHooked = false
local OriginalConnection = nil

-- Store real car data
local function storeCarData(data)
    if data and data.Player == LocalPlayer then
        if data.Items and #data.Items > 0 then
            OriginalCarData = data
            print("✅ Real car data captured")
            print("Car ID:", data.Items[1].Id)
            print("Car Name:", data.Items[1].Name)
        end
    end
end

-- Connect to store data
OnSessionItemsUpdated:Connect(storeCarData)

-- CORRECT WAY: Create our own event handler
local function hookTradeUI()
    if IsHooked then
        print("✅ Already hooked")
        return
    end
    
    print("🔧 Hooking trade UI...")
    
    -- Disconnect original
    if OriginalConnection then
        OriginalConnection:Disconnect()
    end
    
    -- Create new connection with our logic
    OriginalConnection = OnSessionItemsUpdated:Connect(function(data)
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
            
            print("[UI HOOK] Showing " .. FakeCarCount .. " fake cars")
            print("[UI HOOK] Other player sees multiple cars!")
            
            -- Now we need to update the UI manually
            updateTradeUI(fakeData)
            return
        end
        
        -- For other data, process normally
        storeCarData(data)
    })
    
    IsHooked = true
    print("✅ Trade UI hooked!")
end

-- Function to manually update trade UI
local function updateTradeUI(fakeData)
    print("[UI UPDATE] Trying to update trade UI...")
    
    -- Method 1: Try to find and modify existing UI
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Look for any UI showing trade items
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            local text = gui.Text or ""
            if text:find("Items") or text:find("Trading") or text:find("Offer") then
                print("Found trade text:", gui:GetFullName())
                gui.Text = "Trading " .. FakeCarCount .. "x " .. (OriginalCarData.Items[1].Name or "Car")
            end
        end
    end
    
    -- Method 2: Create overlay UI
    createOverlayUI()
end

-- Create fake overlay UI
local function createOverlayUI()
    -- Remove old overlay if exists
    local oldOverlay = LocalPlayer.PlayerGui:FindFirstChild("FakeTradeOverlay")
    if oldOverlay then
        oldOverlay:Destroy()
    end
    
    -- Create new overlay
    local overlay = Instance.new("ScreenGui")
    overlay.Name = "FakeTradeOverlay"
    overlay.DisplayOrder = 999  -- Show on top
    overlay.Parent = LocalPlayer.PlayerGui
    
    -- Create fake item display
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(0, 150, 255)
    frame.Parent = overlay
    
    local title = Instance.new("TextLabel")
    title.Text = "📦 YOUR TRADE OFFER"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame
    
    local itemText = Instance.new("TextLabel")
    itemText.Text = "Offering: " .. FakeCarCount .. "x " .. (OriginalCarData.Items[1].Name or "Car")
    itemText.Size = UDim2.new(1, 0, 0, 40)
    itemText.Position = UDim2.new(0, 0, 0.3, 0)
    itemText.TextColor3 = Color3.new(1, 1, 1)
    itemText.TextSize = 18
    itemText.Parent = frame
    
    local hint = Instance.new("TextLabel")
    hint.Text = "(Other player sees this)"
    hint.Size = UDim2.new(1, 0, 0, 20)
    hint.Position = UDim2.new(0, 0, 0.7, 0)
    hint.TextColor3 = Color3.new(1, 0, 0)
    hint.TextSize = 12
    hint.Parent = frame
    
    print("✅ Created fake trade overlay")
end

-- Main function
local function runVisualExploit()
    print("\n🚀 STARTING VISUAL EXPLOIT")
    print("This shows fake multiple cars in YOUR UI")
    print("Other player sees normal trade")
    
    -- First capture real car data
    print("1. Add a car to trade first...")
    print("2. Then trade will show " .. FakeCarCount .. "x cars")
    
    hookTradeUI()
    createOverlayUI()
    
    print("\n✅ EXPLOIT READY!")
    print("INSTRUCTIONS:")
    print("1. Start trade with someone")
    print("2. Add ONE car to trade")
    print("3. YOUR screen will show " .. FakeCarCount .. " cars")
    print("4. Other player sees normal 1 car")
    print("5. Use for screenshots/videos")
end

-- Fake chat messages
local function sendFakeMessages()
    print("💬 SENDING FAKE CHAT MESSAGES")
    
    -- Try to send to system chat
    local chatService = game:GetService("TextChatService")
    
    if chatService then
        local messages = {
            "[System] Trade completed: Received " .. FakeCarCount .. " cars!",
            "[Trade] Successfully traded for " .. FakeCarCount .. " vehicles!",
            "[Notification] You received " .. FakeCarCount .. "x " .. (OriginalCarData and OriginalCarData.Items[1].Name or "Car") .. "!",
        }
        
        for _, msg in pairs(messages) do
            wait(1)
            print("[FAKE CHAT] " .. msg)
            
            -- Try different chat methods
            pcall(function()
                -- Method 1: TextChatService
                if chatService:FindFirstChild("TextChannels") then
                    local channels = chatService.TextChannels
                    if channels:FindFirstChild("RBXSystem") then
                        channels.RBXSystem:DisplaySystemMessage(msg)
                    elseif channels:FindFirstChild("RBXGeneral") then
                        channels.RBXGeneral:DisplaySystemMessage(msg)
                    end
                end
                
                -- Method 2: Legacy chat
                game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                    Text = msg,
                    Color = Color3.new(0, 1, 0),
                    Font = Enum.Font.SourceSansBold
                })
            end)
        end
    end
    
    print("✅ Fake messages sent!")
end

-- SIMPLE UI
local gui = Instance.new("ScreenGui")
gui.Name = "VisualExploitUI"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 180)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 3
frame.BorderColor3 = Color3.new(1, 0.5, 0)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "👁️ FAKE TRADE UI"
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Fake count control
local countLabel = Instance.new("TextLabel")
countLabel.Text = "Show: " .. FakeCarCount .. " cars"
countLabel.Size = UDim2.new(1, 0, 0, 20)
countLabel.Position = UDim2.new(0, 0, 0.2, 0)
countLabel.TextColor3 = Color3.new(1, 1, 1)
countLabel.Parent = frame

local btnUp = Instance.new("TextButton")
btnUp.Text = "+"
btnUp.Size = UDim2.new(0.1, 0, 0, 20)
btnUp.Position = UDim2.new(0.7, 0, 0.2, 0)
btnUp.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnUp.Parent = frame

local btnDown = Instance.new("TextButton")
btnDown.Text = "-"
btnDown.Size = UDim2.new(0.1, 0, 0, 20)
btnDown.Position = UDim2.new(0.6, 0, 0.2, 0)
btnDown.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnDown.Parent = frame

btnUp.MouseButton1Click:Connect(function()
    FakeCarCount = FakeCarCount + 1
    countLabel.Text = "Show: " .. FakeCarCount .. " cars"
end)

btnDown.MouseButton1Click:Connect(function()
    if FakeCarCount > 1 then
        FakeCarCount = FakeCarCount - 1
        countLabel.Text = "Show: " .. FakeCarCount .. " cars"
    end
end)

-- Start button
local btnStart = Instance.new("TextButton")
btnStart.Text = "🚀 SHOW FAKE TRADE"
btnStart.Size = UDim2.new(0.9, 0, 0, 35)
btnStart.Position = UDim2.new(0.05, 0, 0.4, 0)
btnStart.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnStart.TextColor3 = Color3.new(1, 1, 1)
btnStart.Font = Enum.Font.SourceSansBold
btnStart.Parent = frame
btnStart.MouseButton1Click:Connect(runVisualExploit)

-- Fake chat button
local btnChat = Instance.new("TextButton")
btnChat.Text = "💬 FAKE CHAT"
btnChat.Size = UDim2.new(0.9, 0, 0, 30)
btnChat.Position = UDim2.new(0.05, 0, 0.7, 0)
btnChat.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
btnChat.TextColor3 = Color3.new(1, 1, 1)
btnChat.Parent = frame
btnChat.MouseButton1Click:Connect(sendFakeMessages)

print("\n" .. string.rep("=", 60))
print("👁️ FAKE TRADE VISUAL EXPLOIT")
print(string.rep("=", 60))
print("This creates FAKE UI showing multiple cars")
print("Perfect for:")
print("• Screenshots")
print("• Videos")
print("• Tricking friends in calls")
print("• Making trades look better")
print(string.rep("=", 60))
print("LIMITATIONS:")
print("• Only affects YOUR screen")
print("• Other player sees normal trade")
print("• Doesn't actually give extra cars")
print(string.rep("=", 60))

-- Make global
_G.faketrade = runVisualExploit
_G.fakechat = sendFakeMessages
_G.setcount = function(n)
    if n > 0 then
        FakeCarCount = n
        countLabel.Text = "Show: " .. FakeCarCount .. " cars"
    end
end

print("\nCommands:")
print("_G.faketrade() - Show fake trade UI")
print("_G.fakechat()  - Send fake chat messages")
print("_G.setcount(10)- Set fake car count")
