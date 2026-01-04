-- 🎯 DIRECT CAR INJECTION - FIXED
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CAR INJECTION SYSTEM")
print("=" .. string.rep("=", 50))

-- ===== DIRECT REMOTE FINDER =====
local function findRemotesDirect()
    print("🔍 Searching for remotes...")
    
    local remotesFound = {}
    local remoteNames = {
        "OnCarsAdded", "OnSubscriptionCarAdded", 
        "ClaimGiveawayCar", "OnWrapsAdded"
    }
    
    -- Search all locations
    local searchLocations = {
        ReplicatedStorage,
        game:GetService("ServerScriptService"),
        game:GetService("ServerStorage")
    }
    
    for _, location in pairs(searchLocations) do
        pcall(function()
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    for _, remoteName in pairs(remoteNames) do
                        if obj.Name == remoteName then
                            table.insert(remotesFound, {
                                Name = obj.Name,
                                Object = obj,
                                Path = obj:GetFullName()
                            })
                            print("✅ Found: " .. obj.Name)
                        end
                    end
                end
            end
        end)
    end
    
    return remotesFound
end

-- ===== IMMEDIATE INJECTION =====
local function injectNow()
    print("\n🚀 STARTING IMMEDIATE INJECTION...")
    
    local remotes = findRemotesDirect()
    
    if #remotes == 0 then
        print("❌ No remotes found")
        return
    end
    
    print("🎯 Targeting " .. #remotes .. " remotes")
    
    local cars = {
        "Bontlay Bontaga", "Jegar Model F", "Corsaro T8", 
        "Lavish Ventoge", "Sportler Tecan"
    }
    
    for _, remote in pairs(remotes) do
        print("\n📤 Using: " .. remote.Name)
        
        -- Try multiple formats
        local formats = {
            function(car) return car end,
            function(car) return {car} end,
            function(car) return {player, car} end,
            function(car) return {Car = car, Player = player.Name} end
        }
        
        for _, car in pairs(cars) do
            for _, formatFunc in pairs(formats) do
                local data = formatFunc(car)
                
                local success = pcall(function()
                    remote.Object:FireServer(data)
                    return true
                end)
                
                if success then
                    print("✅ Sent: " .. car)
                    
                    -- Send 3 more copies
                    for i = 1, 3 do
                        pcall(function()
                            remote.Object:FireServer(data)
                        end)
                    end
                    
                    break
                end
            end
            
            task.wait(0.05)
        end
        
        task.wait(0.2)
    end
    
    print("\n🎉 INJECTION COMPLETE!")
    print("📦 CHECK YOUR INVENTORY NOW!")
end

-- ===== SIMPLE UI =====
local function createSimpleUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarInjector"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Tiny button in corner
    local button = Instance.new("TextButton")
    button.Text = "🚗"
    button.Size = UDim2.new(0, 40, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 10)
    button.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.Parent = gui
    
    local status = Instance.new("TextLabel")
    status.Text = "READY"
    status.Size = UDim2.new(0, 80, 0, 20)
    status.Position = UDim2.new(0, 55, 0, 10)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.Parent = gui
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 4)
    statusCorner.Parent = status
    
    -- Button action
    local isRunning = false
    
    button.MouseButton1Click:Connect(function()
        if isRunning then return end
        
        isRunning = true
        button.Text = "..."
        button.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "INJECTING"
        
        task.spawn(function()
            injectNow()
            
            button.Text = "✅"
            button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            status.Text = "DONE"
            
            task.wait(2)
            
            button.Text = "🚗"
            button.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
            status.Text = "READY"
            isRunning = false
        end)
    end)
    
    -- Make draggable
    local dragging = false
    local dragStart
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position - button.AbsolutePosition
        end
    end)
    
    button.InputEnded:Connect(function()
        dragging = false
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newPos = input.Position - dragStart
            button.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
            status.Position = UDim2.new(0, newPos.X + 45, 0, newPos.Y)
        end
    end)
    
    return gui
end

-- ===== AUTOMATIC START =====
print("\n🚀 Starting automatic injection in 3 seconds...")
for i = 3, 1, -1 do
    print(i .. "...")
    task.wait(1)
end

-- Run injection immediately
injectNow()

-- Create UI
task.wait(1)
createSimpleUI()

print("\n✅ Injection complete!")
print("\n📱 Green button in top-left corner")
print("💡 Click it to inject more cars")
print("📦 Check your inventory now!")
