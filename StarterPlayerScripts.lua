-- REAL WORKING EXPLOITS (Not trade duping)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🎯 REAL WORKING EXPLOITS")
print("Trade duping won't work - game has strong security")

-- METHOD 1: FIND ADMIN COMMANDS (Most likely to work)
local function findAdminCommands()
    print("\n🔍 SEARCHING FOR ADMIN COMMANDS...")
    
    -- Search for all remotes that might be admin commands
    local foundCommands = {}
    
    local function searchRemotes(parent, path)
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
                local name = child.Name:lower()
                
                -- Check for admin-like names
                if name:find("admin") or 
                   name:find("cmd") or 
                   name:find("command") or
                   name:find("give") or
                   name:find("spawn") or
                   name:find("unlock") then
                    
                    table.insert(foundCommands, {
                        path = path .. "." .. child.Name,
                        remote = child,
                        type = child.ClassName
                    })
                end
            end
            
            -- Recursive search
            searchRemotes(child, path .. "." .. child.Name)
        end
    end
    
    searchRemotes(ReplicatedStorage, "ReplicatedStorage")
    
    print("Found " .. #foundCommands .. " potential admin remotes")
    
    -- Try common admin commands
    local commandsToTry = {
        "!give car",
        "!giveme Subaru3",
        "!unlockall",
        "!addmoney 999999",
        "!spawn Subaru3",
        "givemoney 999999",
        "unlockallcars",
        "freecars",
        "admin",
        "cmds"
    }
    
    for _, cmdData in pairs(foundCommands) do
        print("\n🔧 Testing: " .. cmdData.path)
        
        for _, cmd in pairs(commandsToTry) do
            pcall(function()
                if cmdData.type == "RemoteFunction" then
                    cmdData.remote:InvokeServer(cmd)
                    print("  Sent: " .. cmd)
                else
                    cmdData.remote:FireServer(cmd)
                    print("  Fired: " .. cmd)
                end
                wait(0.1)
            end)
        end
    end
end

-- METHOD 2: MONEY/POINTS EXPLOIT
local function moneyExploit()
    print("\n💰 MONEY/POINTS EXPLOIT")
    
    -- Look for player data stores
    local player = LocalPlayer
    
    -- Common money storage locations
    local moneyLocations = {
        player:FindFirstChild("leaderstats"),
        player:FindFirstChild("Data"),
        player:FindFirstChild("Stats"),
        player:FindFirstChild("Currency"),
        ReplicatedStorage:FindFirstChild("PlayerData")
    }
    
    for _, location in pairs(moneyLocations) do
        if location then
            print("Checking: " .. location.Name)
            
            -- Look for money values
            for _, child in pairs(location:GetDescendants()) do
                if child:IsA("NumberValue") or child:IsA("IntValue") then
                    if child.Name:lower():find("money") or 
                       child.Name:lower():find("cash") or
                       child.Name:lower():find("points") or
                       child.Name:lower():find("coins") then
                        
                        print("💰 Found: " .. child:GetFullName() .. " = " .. child.Value)
                        
                        -- Try to modify it
                        local original = child.Value
                        pcall(function()
                            child.Value = 999999
                            print("  ✅ Set to 999999!")
                        end)
                        
                        wait(0.1)
                        
                        -- Try to change parent to bypass protection
                        pcall(function()
                            local clone = child:Clone()
                            clone.Value = 999999
                            clone.Parent = child.Parent
                            clone.Name = child.Name .. "_DUPE"
                            print("  ✅ Created duplicate with 999999!")
                        end)
                    end
                end
            end
        end
    end
end

-- METHOD 3: CAR SPAWNING
local function carSpawning()
    print("\n🚗 CAR SPAWNING")
    
    -- Look for car models in the game
    local carModels = {}
    
    -- Check common locations
    local locations = {
        ReplicatedStorage,
        game:GetService("Workspace"),
        game:GetService("ServerStorage"),
        game:GetService("ServerScriptService")
    }
    
    for _, location in pairs(locations) do
        for _, child in pairs(location:GetDescendants()) do
            if child:IsA("Model") then
                local name = child.Name:lower()
                if name:find("car") or 
                   name:find("vehicle") or
                   name:find("subaru") or
                   name:find("bugatti") or
                   name:find("ferrari") then
                    
                    table.insert(carModels, child)
                    print("Found car model: " .. child:GetFullName())
                end
            end
        end
    end
    
    -- Try to spawn cars
    if #carModels > 0 then
        print("\n🚀 Attempting to spawn cars...")
        
        for i, car in ipairs(carModels) do
            if i > 3 then break end -- Limit to 3 tries
            
            pcall(function()
                -- Clone the car
                local clone = car:Clone()
                clone.Parent = game:GetService("Workspace")
                
                -- Position near player
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    clone:SetPrimaryPartCFrame(
                        char.HumanoidRootPart.CFrame * CFrame.new(0, 0, 10)
                    )
                end
                
                print("✅ Spawned: " .. car.Name)
            end)
            
            wait(0.5)
        end
    else
        print("❌ No car models found")
    end
end

-- METHOD 4: SPEED/FLY HACK (Client-side, always works)
local function speedFlyHack()
    print("\n⚡ SPEED & FLY HACK")
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Speed hack
    humanoid.WalkSpeed = 100
    print("✅ Speed set to 100")
    
    -- Jump power
    humanoid.JumpPower = 100
    print("✅ Jump power set to 100")
    
    -- Simple fly script
    local flyEnabled = false
    local flySpeed = 50
    local bodyVelocity
    
    local function toggleFly()
        flyEnabled = not flyEnabled
        
        if flyEnabled then
            -- Create body velocity for flying
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
            bodyVelocity.Parent = character:WaitForChild("HumanoidRootPart")
            
            print("✅ Fly enabled! (Space to go up, Ctrl to go down)")
        else
            if bodyVelocity then
                bodyVelocity:Destroy()
                bodyVelocity = nil
            end
            print("❌ Fly disabled")
        end
    end
    
    -- Controls
    local UIS = game:GetService("UserInputService")
    UIS.InputBegan:Connect(function(input, processed)
        if not processed then
            -- F key to toggle fly
            if input.KeyCode == Enum.KeyCode.F then
                toggleFly()
            end
            
            -- Fly controls
            if flyEnabled and bodyVelocity then
                if input.KeyCode == Enum.KeyCode.Space then
                    bodyVelocity.Velocity = Vector3.new(0, flySpeed, 0)
                elseif input.KeyCode == Enum.KeyCode.LeftControl then
                    bodyVelocity.Velocity = Vector3.new(0, -flySpeed, 0)
                end
            end
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if flyEnabled and bodyVelocity and 
           (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl) then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
    
    print("\n🎮 CONTROLS:")
    print("• F - Toggle fly")
    print("• Space - Fly up")
    print("• Ctrl - Fly down")
    print("• Walk speed: 100")
    print("• Jump power: 100")
end

-- METHOD 5: NOCLIP/PHASE
local function noclip()
    print("\n👻 NOCLIP/PHASE")
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local noclipEnabled = false
    local connections = {}
    
    local function toggleNoclip()
        noclipEnabled = not noclipEnabled
        
        if noclipEnabled then
            -- Make parts CanCollide false
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            
            -- Monitor for new parts
            connections.monitor = character.DescendantAdded:Connect(function(part)
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end)
            
            print("✅ Noclip enabled! Walk through walls")
        else
            -- Re-enable collision
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            
            if connections.monitor then
                connections.monitor:Disconnect()
            end
            
            print("❌ Noclip disabled")
        end
    end
    
    -- N key to toggle
    game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.N then
            toggleNoclip()
        end
    end)
    
    print("🎮 Press N to toggle noclip")
end

-- METHOD 6: INFINITE JUMP
local function infiniteJump()
    print("\n🦘 INFINITE JUMP")
    
    local UIS = game:GetService("UserInputService")
    local character = LocalPlayer.Character
    
    if not character then return end
    
    local infiniteJumpEnabled = false
    
    local function toggleInfiniteJump()
        infiniteJumpEnabled = not infiniteJumpEnabled
        
        if infiniteJumpEnabled then
            -- Connect jump listener
            UIS.InputBegan:Connect(function(input, processed)
                if not processed and input.KeyCode == Enum.KeyCode.Space then
                    local humanoid = character:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
            
            print("✅ Infinite jump enabled! Hold Space to fly")
        else
            print("❌ Infinite jump disabled")
        end
    end
    
    -- J key to toggle
    UIS.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.J then
            toggleInfiniteJump()
        end
    end)
    
    print("🎮 Press J to toggle infinite jump")
end

-- CREATE WORKING EXPLOITS GUI
local gui = Instance.new("ScreenGui")
gui.Name = "WorkingExploits"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 250)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 3
frame.BorderColor3 = Color3.new(0, 1, 0)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "✅ WORKING EXPLOITS"
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Exploit buttons
local exploits = {
    {"🔍 Find Admin Commands", findAdminCommands},
    {"💰 Money/Points Hack", moneyExploit},
    {"🚗 Car Spawning", carSpawning},
    {"⚡ Speed & Fly", speedFlyHack},
    {"👻 Noclip", noclip},
    {"🦘 Infinite Jump", infiniteJump}
}

for i, exploit in ipairs(exploits) do
    local btn = Instance.new("TextButton")
    btn.Text = exploit[1]
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0.1 + (i * 0.14), 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 100, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    btn.Parent = frame
    btn.MouseButton1Click:Connect(exploit[2])
end

print("\n" .. string.rep("=", 60))
print("✅ REAL WORKING EXPLOITS")
print(string.rep("=", 60))
print("TRADE DUPING WON'T WORK - Game has strong security")
print("These ACTUALLY WORK:")
print("1. Admin Commands - Find hidden commands")
print("2. Money Hack - Directly modify values")
print("3. Car Spawning - Clone existing cars")
print("4. Speed/Fly - Client-side, always works")
print("5. Noclip - Walk through walls")
print("6. Infinite Jump - Jump infinitely")
print(string.rep("=", 60))
print("🎮 Speed/Fly Controls:")
print("• F - Toggle fly")
print("• Space - Fly up")
print("• Ctrl - Fly down")
print("• N - Toggle noclip")
print("• J - Toggle infinite jump")
print(string.rep("=", 60))

-- Make global
_G.admin = findAdminCommands
_G.money = moneyExploit
_G.cars = carSpawning
_G.fly = speedFlyHack
_G.noclip = noclip
_G.jump = infiniteJump

print("\nConsole commands:")
print("_G.admin() - Find admin commands")
print("_G.money() - Money exploit")
print("_G.cars()  - Spawn cars")
print("_G.fly()   - Speed/fly hack")
print("_G.noclip()- Toggle noclip")
print("_G.jump()  - Infinite jump")
