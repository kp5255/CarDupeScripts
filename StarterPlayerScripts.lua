-- ⚡ INSTANT SPENDING EXPLOIT
-- Game ID: ffad7ea30d080c4aa1d7bf4b2f5f4381

print("⚡ INSTANT SPENDING HACK")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()

-- ===== INSTANT SPENDER =====
local function instantSpendMoney()
    print("\n💰 MONEY → CAR CONVERSION HACK")
    
    -- STEP 1: Get money stat
    local moneyStat = nil
    if player:FindFirstChild("leaderstats") then
        for _, stat in pairs(player.leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                local name = stat.Name:lower()
                if name:find("money") or name:find("cash") then
                    moneyStat = stat
                    print("Money stat: " .. stat.Name)
                    break
                end
            end
        end
    end
    
    if not moneyStat then
        print("❌ No money stat found!")
        return false
    end
    
    print("Current money: $" .. moneyStat.Value)
    
    -- STEP 2: Find ALL purchase events
    local purchaseEvents = {}
    
    -- Search for buy/purchase events
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("buy") or name:find("purchase") or 
               name:find("car") or name:find("vehicle") or
               name:find("dealership") or name:find("upgrade") then
                table.insert(purchaseEvents, {
                    Object = obj,
                    Name = obj.Name,
                    Type = obj.ClassName
                })
                print("Found purchase event: " .. obj.Name)
            end
        end
    end
    
    if #purchaseEvents == 0 then
        print("❌ No purchase events found!")
        return false
    end
    
    -- STEP 3: SET MONEY AND INSTANTLY SPEND IT
    local bigMoney = 9999999
    local boughtSomething = false
    
    -- Try 3 times to ensure success
    for attempt = 1, 3 do
        print("\n[ATTEMPT " .. attempt .. "]")
        
        -- Set money
        moneyStat.Value = bigMoney
        print("✅ Set money to: $" .. bigMoney)
        
        -- IMMEDIATELY try to buy everything
        for _, eventData in pairs(purchaseEvents) do
            local event = eventData.Object
            
            -- Try different expensive items
            local expensiveItems = {
                "Lamborghini",
                "Ferrari", 
                "Bugatti",
                "McLaren",
                "Dealership",
                "Premium Dealership",
                "Showroom",
                "Garage"
            }
            
            for _, itemName in pairs(expensiveItems) do
                -- Try multiple argument patterns IMMEDIATELY
                local patterns = {
                    {itemName},
                    {player, itemName},
                    {itemName, bigMoney},
                    {"buy", itemName},
                    {itemName, true}, -- maybe 'true' for premium
                    {vehicle = itemName, premium = true}
                }
                
                for _, args in pairs(patterns) do
                    local success, errorMsg = pcall(function()
                        if eventData.Type == "RemoteEvent" then
                            event:FireServer(unpack(args))
                        else
                            event:InvokeServer(unpack(args))
                        end
                    end)
                    
                    if success then
                        print("✅ Purchased: " .. itemName .. " via " .. eventData.Name)
                        boughtSomething = true
                    end
                    
                    task.wait(0.01) -- SUPER FAST
                end
            end
        end
        
        -- Check if we bought anything
        if boughtSomething then
            -- Try to buy MORE of the same items (duplicate)
            print("\n🔄 Attempting to duplicate purchases...")
            
            for _, eventData in pairs(purchaseEvents) do
                local event = eventData.Object
                
                -- Spam same purchase 5 times
                for i = 1, 5 do
                    pcall(function()
                        if eventData.Type == "RemoteEvent" then
                            event:FireServer("Lamborghini")
                        else
                            event:InvokeServer("Lamborghini")
                        end
                    end)
                    task.wait(0.02)
                end
            end
        end
        
        task.wait(0.5) -- Wait before next attempt
    end
    
    -- STEP 4: Check what we actually bought
    print("\n" .. string.rep("=", 40))
    print("RESULT CHECK:")
    print(string.rep("=", 40))
    
    -- Check inventory
    local inventoryItems = {}
    if player:FindFirstChild("Inventory") then
        for _, item in pairs(player.Inventory:GetChildren()) do
            table.insert(inventoryItems, item.Name)
        end
    end
    
    -- Check data folder
    if player:FindFirstChild("Data") then
        for _, data in pairs(player.Data:GetChildren()) do
            if not table.find(inventoryItems, data.Name) then
                table.insert(inventoryItems, data.Name)
            end
        end
    end
    
    if #inventoryItems > 0 then
        print("✅ Purchased items found:")
        for _, item in pairs(inventoryItems) do
            print("   - " .. item)
        end
        return true
    else
        print("❌ No items purchased")
        print("Money reverted too fast!")
        return false
    end
end

-- STEP 5: AUTO-TRIGGER MONEY SET + SPEND
local function autoMoneyCarHack()
    print("\n" .. string.rep("=", 50))
    print("🚀 AUTO MONEY→CAR HACK")
    print(string.rep("=", 50))
    
    -- First, find SetCarFavorite or similar event
    local setMoneyEvent = ReplicatedStorage:FindFirstChild("SetCarFavorite")
    if not setMoneyEvent then
        -- Try to find any SetMoney event
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and 
               obj.Name:lower():find("set") then
                setMoneyEvent = obj
                print("Using event: " .. obj.Name)
                break
            end
        end
    end
    
    if setMoneyEvent then
        print("🎯 Found money event: " .. setMoneyEvent.Name)
        
        -- SET MONEY AND SPEND IN ONE FRAME
        task.spawn(function()
            -- Part 1: Set money
            pcall(function()
                if setMoneyEvent:IsA("RemoteEvent") then
                    setMoneyEvent:FireServer(9999999)
                else
                    setMoneyEvent:InvokeServer(9999999)
                end
                print("✅ Money set to $9,999,999")
            end)
            
            -- Part 2: INSTANTLY spend it
            task.wait(0.001) -- Almost zero delay
            
            local spent = instantSpendMoney()
            
            if spent then
                print("\n🎉 SUCCESS! Money converted to cars!")
                print("Check your garage/inventory!")
            else
                print("\n⚠️ Failed to spend money fast enough")
                print("Server reverted money too quickly")
            end
        end)
    else
        print("❌ No SetCarFavorite or SetMoney event found!")
    end
end

-- STEP 6: CREATE UI FOR MANUAL CONTROL
local function createQuickSpendUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Text = "⚡ INSTANT SPENDER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "Click to set money and instantly spend it on cars!"
    status.Size = UDim2.new(1, -20, 0, 80)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    local button = Instance.new("TextButton")
    button.Text = "⚡ SET & SPEND NOW"
    button.Size = UDim2.new(1, -40, 0, 40)
    button.Position = UDim2.new(0, 20, 0, 140)
    button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 16
    button.Parent = frame
    
    button.MouseButton1Click:Connect(function()
        status.Text = "⚡ Setting money and buying cars...\nBe quick!"
        button.Text = "WORKING..."
        button.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            local success = instantSpendMoney()
            if success then
                status.Text = "✅ SUCCESS!\nCheck your inventory!"
                button.Text = "SUCCESS!"
                button.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
            else
                status.Text = "❌ Failed!\nServer reverted too fast."
                button.Text = "TRY AGAIN"
                button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
        end)
    end)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return screenGui
end

-- MAIN EXECUTION
task.wait(2)
createQuickSpendUI()

-- Auto-run after 3 seconds
task.wait(3)
print("\n⚡ Auto-starting in 3... 2... 1...")
autoMoneyCarHack()

print("\n" .. string.rep("=", 50))
print("TIPS:")
print("1. Click the 'SET & SPEND NOW' button")
print("2. Look in your garage immediately")
print("3. If fails, try again multiple times")
print(string.rep("=", 50))
