-- Simple Trade Duplicator - Fixed Version
local success, errorMsg = pcall(function()
    
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    print("=== SIMPLE TRADE DUPLICATOR ===")
    
    -- Wait for game to load
    wait(2)
    
    -- Try to get the remote function safely
    local SessionAddItem = nil
    local function GetRemoteFunction()
        if SessionAddItem then return SessionAddItem end
        
        local success, result = pcall(function()
            return ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes"):WaitForChild("SessionAddItem")
        end)
        
        if success then
            SessionAddItem = result
            print("✅ Found SessionAddItem remote")
            return result
        else
            print("❌ Could not find SessionAddItem: " .. result)
            return nil
        end
    end
    
    -- Get trade container
    local function GetTradeContainer()
        local success, container = pcall(function()
            if not Player.PlayerGui then return nil end
            return Player.PlayerGui:WaitForChild("Menu"):WaitForChild("Trading"):WaitForChild("PeerToPeer"):WaitForChild("Main"):WaitForChild("LocalPlayer"):WaitForChild("Content"):WaitForChild("ScrollingFrame")
        end)
        
        if success and container then
            return container
        else
            print("⚠️ Trade container not found")
            return nil
        end
    end
    
    -- Find cars in trade
    local function FindCarsInTrade()
        print("\n🔍 Looking for cars in trade...")
        
        local container = GetTradeContainer()
        if not container then return {} end
        
        local cars = {}
        
        for _, item in pairs(container:GetChildren()) do
            if item:IsA("ImageButton") or item:IsA("TextButton") then
                local name = item.Name
                if name:sub(1, 4) == "Car-" then
                    print("🚗 Found car: " .. name)
                    table.insert(cars, {
                        button = item,
                        name = name
                    })
                end
            end
        end
        
        print("Found " .. #cars .. " car(s)")
        return cars
    end
    
    -- Try to duplicate car
    local function TryDuplicate()
        print("\n🔄 Attempting to duplicate car...")
        
        -- Get remote function
        local remote = GetRemoteFunction()
        if not remote then
            print("❌ No remote function found")
            return false
        end
        
        -- Find cars
        local cars = FindCarsInTrade()
        if #cars == 0 then
            print("❌ No cars in trade")
            return false
        end
        
        local car = cars[1]
        local carName = car.name
        
        print("Trying to duplicate: " .. carName)
        
        -- Try different parameter combinations
        local attempts = {
            {name = "Just car name", params = {carName}},
            {name = "Car with quantity", params = {carName, 1}},
            {name = "Player + car", params = {Player, carName}},
            {name = "Session ID + car", params = {"trade_session", carName}},
            {name = "Table format", params = {{item = carName}}},
        }
        
        for i, attempt in ipairs(attempts) do
            print("\nAttempt " .. i .. ": " .. attempt.name)
            
            local success, result = pcall(function()
                return remote:InvokeServer(unpack(attempt.params))
            end)
            
            if success then
                print("✅ Success!")
                if result then
                    print("Result: " .. tostring(result))
                end
                
                -- Try a few more times
                for j = 1, 3 do
                    wait(0.2)
                    pcall(function()
                        remote:InvokeServer(unpack(attempt.params))
                        print("Repeated " .. j)
                    end)
                end
                
                return true
            else
                print("❌ Failed: " .. tostring(result))
            end
            
            wait(0.3)
        end
        
        return false
    end
    
    -- Create simple UI
    local function CreateUI()
        local gui = Instance.new("ScreenGui")
        gui.Name = "SimpleTradeDuplicator"
        gui.Parent = Player:WaitForChild("PlayerGui")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 250, 0, 150)
        frame.Position = UDim2.new(0.5, -125, 0, 20)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        frame.Active = true
        frame.Draggable = true
        
        local title = Instance.new("TextLabel")
        title.Text = "TRADE DUPLICATOR"
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        title.TextColor3 = Color3.fromRGB(255, 150, 100)
        
        local status = Instance.new("TextLabel")
        status.Text = "Ready\nAdd a Car- item to trade"
        status.Size = UDim2.new(1, -20, 0, 70)
        status.Position = UDim2.new(0, 10, 0, 40)
        status.BackgroundTransparency = 1
        status.TextColor3 = Color3.fromRGB(200, 220, 255)
        status.TextWrapped = true
        
        local button = Instance.new("TextButton")
        button.Text = "🚀 DUPLICATE CAR"
        button.Size = UDim2.new(1, -20, 0, 30)
        button.Position = UDim2.new(0, 10, 0, 120)
        button.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        button.MouseButton1Click:Connect(function()
            status.Text = "Duplicating..."
            button.Text = "WORKING..."
            
            spawn(function()
                local success = TryDuplicate()
                
                if success then
                    status.Text = "✅ Success!\nCheck other player"
                    button.Text = "✅ DONE"
                    button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                else
                    status.Text = "❌ Failed\nSee output window"
                    button.Text = "🚀 TRY AGAIN"
                end
                
                wait(2)
                button.Text = "🚀 DUPLICATE CAR"
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
    
    print("\n✅ Script loaded successfully!")
    print("📋 Instructions:")
    print("1. Start trade with another player")
    print("2. Add a Car- item to trade")
    print("3. Click DUPLICATE CAR button")
    print("4. Check if other player sees duplicate")
    
end)

if not success then
    print("❌ Script error: " .. errorMsg)
end
