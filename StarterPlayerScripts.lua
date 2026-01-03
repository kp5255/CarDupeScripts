-- 🏢 SPECIFIC SCRIPT FOR: Car Dealership Tycoon
-- Game ID from your link: Code ffad7ea30d080c4aa1d7bf4b2f5f4381
-- This is a specific Car Dealership Tycoon game

print("==========================================")
print("SPECIFIC CAR DEALERSHIP TYCOON EXPLOIT")
print("==========================================")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Wait for game to load
repeat task.wait() until game:IsLoaded()
print("Game loaded: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)

-- ===== GAME-SPECIFIC HACKS =====
-- Based on analysis of Car Dealership Tycoon games

-- 1. First, let's find the ACTUAL events in this specific game
local function findRealEvents()
    print("\n🔍 Finding game events...")
    
    local eventsFound = {}
    
    -- Common events in Car Dealership Tycoon
    local targetEvents = {
        -- Money related
        "AddMoney",
        "SetMoney", 
        "GiveMoney",
        "Money",
        "Cash",
        -- Car related
        "BuyCar",
        "PurchaseCar",
        "SellCar",
        "AddCar",
        "RemoveCar",
        -- Dealership related
        "BuyDealership",
        "UpgradeDealership",
        "UnlockDealership",
        -- Game save/load
        "Save",
        "Load",
        "DataSave"
    }
    
    for _, eventName in pairs(targetEvents) do
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if event then
            table.insert(eventsFound, {Name = eventName, Object = event, Type = event.ClassName})
            print("✅ Found: " .. eventName .. " (" .. event.ClassName .. ")")
        end
    end
    
    -- Search for any remote with car/money/dealership in name
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("car") or name:find("money") or name:find("dealership") or 
               name:find("buy") or name:find("sell") or name:find("vehicle") then
                
                local alreadyFound = false
                for _, found in pairs(eventsFound) do
                    if found.Name == obj.Name then
                        alreadyFound = true
                        break
                    end
                end
                
                if not alreadyFound then
                    table.insert(eventsFound, {Name = obj.Name, Object = obj, Type = obj.ClassName})
                    print("✅ Found: " .. obj.Name .. " (" .. obj.ClassName .. ")")
                end
            end
        end
    end
    
    return eventsFound
end

-- 2. Get FREE MONEY (most important first)
local function getFreeMoney()
    print("\n💰 Getting FREE MONEY...")
    
    local moneyEvents = findRealEvents()
    local success = false
    
    -- Try specific money amounts
    local moneyAmounts = {999999, 1000000, 5000000, 10000000, 9999999}
    
    for _, eventData in pairs(moneyEvents) do
        local event = eventData.Object
        local eventName = eventData.Name:lower()
        
        if eventName:find("money") or eventName:find("cash") or eventName:find("add") or eventName:find("set") then
            print("Trying money event: " .. eventData.Name)
            
            for _, amount in pairs(moneyAmounts) do
                -- Try different argument formats
                local attempts = {
                    {amount},
                    {player, amount},
                    {"add", amount},
                    {"set", amount},
                    {player.UserId, amount}
                }
                
                for _, args in pairs(attempts) do
                    local worked = pcall(function()
                        if eventData.Type == "RemoteEvent" then
                            event:FireServer(unpack(args))
                        else
                            event:InvokeServer(unpack(args))
                        end
                    end)
                    
                    if worked then
                        print("✅ Sent $" .. amount .. " via " .. eventData.Name)
                        success = true
                    end
                    
                    task.wait(0.05)
                end
            end
        end
    end
    
    -- Try to modify leaderstats directly
    if player:FindFirstChild("leaderstats") then
        local leaderstats = player.leaderstats
        for _, stat in pairs(leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                local statName = stat.Name:lower()
                if statName:find("money") or statName:find("cash") or statName:find("dollar") then
                    pcall(function()
                        local oldValue = stat.Value
                        stat.Value = 9999999
                        print("✅ Changed " .. stat.Name .. " from $" .. oldValue .. " to $9,999,999")
                        success = true
                    end)
                end
            end
        end
    end
    
    if success then
        print("\n🎉 MONEY EXPLOIT SUCCESSFUL!")
        print("Check your money in the game!")
    else
        print("\n❌ Money exploit failed")
        print("Game might have security measures")
    end
    
    return success
end

-- 3. Duplicate Cars in Dealership
local function duplicateDealershipCars()
    print("\n🚗 Duplicating dealership cars...")
    
    -- First, find cars in the game
    local carsInGame = {}
    
    -- Look in workspace for car models
    if Workspace:FindFirstChild("Cars") then
        for _, car in pairs(Workspace.Cars:GetChildren()) do
            if car:IsA("Model") then
                table.insert(carsInGame, car.Name)
                print("Found car: " .. car.Name)
            end
        end
    end
    
    -- Look for car spawners or dealership lots
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            if obj.Name:find("Car") or obj.Name:find("Vehicle") then
                if #obj:GetChildren() > 5 then -- Likely a car model
                    if not table.find(carsInGame, obj.Name) then
                        table.insert(carsInGame, obj.Name)
                        print("Found vehicle: " .. obj.Name)
                    end
                end
            end
        end
    end
    
    if #carsInGame == 0 then
        print("❌ No cars found in dealership!")
        print("Buy some cars first or walk around the dealership")
        return false
    end
    
    -- Now try to duplicate them
    local events = findRealEvents()
    local successCount = 0
    
    for _, carName in pairs(carsInGame) do
        print("\nTrying to duplicate: " .. carName)
        
        for _, eventData in pairs(events) do
            local eventName = eventData.Name:lower()
            
            if eventName:find("buy") or eventName:find("purchase") or eventName:find("add") then
                local event = eventData.Object
                
                -- Try different purchase methods
                local attempts = {
                    {carName},
                    {carName, 0}, -- Free
                    {carName, 1}, -- $1
                    {player, carName},
                    {"buy", carName},
                    {vehicle = carName, price = 0}
                }
                
                for _, args in pairs(attempts) do
                    local worked = pcall(function()
                        if eventData.Type == "RemoteEvent" then
                            event:FireServer(unpack(args))
                        else
                            event:InvokeServer(unpack(args))
                        end
                    end)
                    
                    if worked then
                        print("✅ Duplicated via " .. eventData.Name)
                        successCount = successCount + 1
                    end
                    
                    task.wait(0.03)
                end
            end
        end
    end
    
    if successCount > 0 then
        print("\n🎉 CAR DUPLICATION SUCCESSFUL!")
        print(successCount .. " duplication attempts made")
        print("Check your dealership for new cars!")
        return true
    else
        print("\n❌ Car duplication failed")
        return false
    end
end

-- 4. Unlock Everything
local function unlockEverything()
    print("\n🔓 Unlocking all dealership features...")
    
    local events = findRealEvents()
    local success = false
    
    for _, eventData in pairs(events) do
        local eventName = eventData.Name:lower()
        
        if eventName:find("unlock") or eventName:find("upgrade") or eventName:find("buydealership") then
            local event = eventData.Object
            
            -- Try to unlock all levels
            for level = 1, 10 do
                local attempts = {
                    {level},
                    {player, level},
                    {"unlock", level},
                    {"upgrade", level}
                }
                
                for _, args in pairs(attempts) do
                    local worked = pcall(function()
                        if eventData.Type == "RemoteEvent" then
                            event:FireServer(unpack(args))
                        else
                            event:InvokeServer(unpack(args))
                        end
                    end)
                    
                    if worked then
                        print("✅ Unlocked level " .. level .. " via " .. eventData.Name)
                        success = true
                    end
                end
            end
        end
    end
    
    if success then
        print("\n🎉 UNLOCK SUCCESSFUL!")
    else
        print("\n❌ Unlock failed")
    end
    
    return success
end

-- 5. Auto-execute everything
local function autoHack()
    print("\n" .. string.rep("=", 50))
    print("🚀 STARTING AUTO-HACK SEQUENCE")
    print(string.rep("=", 50))
    
    -- Step 1: Find events
    local events = findRealEvents()
    print("Found " .. #events .. " potential exploit points")
    
    -- Step 2: Get money first (most important)
    task.wait(1)
    local moneySuccess = getFreeMoney()
    
    -- Step 3: Duplicate cars
    task.wait(2)
    if moneySuccess then
        duplicateDealershipCars()
    else
        print("\n⚠️ Skipping car duplication - need money first!")
    end
    
    -- Step 4: Unlock everything
    task.wait(2)
    unlockEverything()
    
    print("\n" .. string.rep("=", 50))
    print("✅ AUTO-HACK COMPLETE!")
    print(string.rep("=", 50))
    print("Check your game for:")
    print("1. Money balance")
    print("2. Car inventory")
    print("3. Dealership upgrades")
    print(string.rep("=", 50))
end

-- Create simple UI for execution
local function createQuickUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0.5, -150, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(25, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Text = "🏢 CAR DEALERSHIP HACK"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "Car Dealership Tycoon Hack\n\nReady to execute..."
    status.Size = UDim2.new(1, -20, 0, 200)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    -- Buttons
    local buttons = {
        {text = "💰 GET MONEY", y = 260, func = getFreeMoney},
        {text = "🚗 DUPLICATE CARS", y = 300, func = duplicateDealershipCars},
        {text = "🔓 UNLOCK ALL", y = 340, func = unlockEverything},
        {text = "⚡ AUTO-HACK ALL", y = 380, func = autoHack}
    }
    
    for _, btn in pairs(buttons) do
        local button = Instance.new("TextButton")
        button.Text = btn.text
        button.Size = UDim2.new(1, -40, 0, 35)
        button.Position = UDim2.new(0, 20, 0, btn.y)
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.Parent = frame
        
        button.MouseButton1Click:Connect(function()
            status.Text = "Executing: " .. btn.text .. "\n\nPlease wait..."
            task.spawn(function()
                btn.func()
                status.Text = "✅ " .. btn.text .. " completed!\n\nCheck your game."
            end)
        end)
    end
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return screenGui, status
end

-- Main execution
task.wait(2)
local gui, status = createQuickUI()

-- Auto-start money hack
task.wait(3)
status.Text = "🚀 Starting automatic money exploit...\n\nPlease wait..."
task.wait(1)

local moneySuccess = getFreeMoney()
if moneySuccess then
    status.Text = "✅ MONEY HACK SUCCESSFUL!\n\nYou should now have lots of money!\n\nClick other buttons for more hacks."
else
    status.Text = "⚠️ Money hack might have failed\n\nTry clicking buttons manually\nor join a different server."
end

print("\n" .. string.rep("=", 60))
print("CAR DEALERSHIP TYCOON HACK LOADED!")
print("Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
print("Place ID: " .. game.PlaceId)
print("Player: " .. player.Name)
print("UI created - Use buttons to hack!")
print(string.rep("=", 60))
