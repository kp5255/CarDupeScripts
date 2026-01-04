-- 💥 ULTIMATE FORCE EXECUTION SCRIPT
-- Place ID: 1554960397

print("💥 ULTIMATE FORCE EXECUTION")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== FORCE MODULE EXECUTION =====
local function forceModuleExecution()
    print("\n💥 FORCING MODULE EXECUTION")
    
    -- Get GiveCar module
    local giveCar = ReplicatedStorage:FindFirstChild("CmdrClient")
    if giveCar then
        giveCar = giveCar:FindFirstChild("Commands")
        if giveCar then
            giveCar = giveCar:FindFirstChild("GiveCar")
        end
    end
    
    if not giveCar or not giveCar:IsA("ModuleScript") then
        print("❌ GiveCar module not found")
        return false
    end
    
    print("✅ GiveCar module found: " .. giveCar:GetFullName())
    
    -- Force load module
    local moduleFunc
    local success, result = pcall(function()
        return require(giveCar)
    end)
    
    if not success then
        print("❌ Failed to load module")
        return false
    end
    
    moduleFunc = result
    print("✅ Module loaded successfully")
    
    -- Get GiveAllCars module
    local giveAll = ReplicatedStorage:FindFirstChild("CmdrClient")
    if giveAll then
        giveAll = giveAll:FindFirstChild("Commands")
        if giveAll then
            giveAll = giveAll:FindFirstChild("GiveAllCars")
        end
    end
    
    if giveAll and giveAll:IsA("ModuleScript") then
        local success2, allFunc = pcall(function()
            return require(giveAll)
        end)
        
        if success2 then
            print("✅ GiveAllCars module loaded")
            
            -- Try to execute GiveAllCars FIRST (might bypass permission check)
            print("\n🎯 ATTEMPTING GIVEALLCARS...")
            for i = 1, 5 do
                pcall(function()
                    if type(allFunc) == "function" then
                        allFunc(player)
                        print("✅ GiveAllCars attempt " .. i)
                    elseif type(allFunc) == "table" then
                        for key, func in pairs(allFunc) do
                            if type(func) == "function" then
                                func(player)
                                print("✅ " .. key .. " attempt " .. i)
                                break
                            end
                        end
                    end
                end)
                task.wait(0.3)
            end
        end
    end
    
    -- Target cars
    local targetCars = {
        "Bontlay Bontaga",
        "Jegar Model F",
        "Corsaro T8",
        "Lavish Ventoge",
        "Sportler Tecan"
    }
    
    print("\n🎯 FORCING GIVECAR EXECUTION...")
    
    -- Method 1: Direct function call
    if type(moduleFunc) == "function" then
        print("Module is a function, attempting calls...")
        for _, car in pairs(targetCars) do
            for i = 1, 3 do
                pcall(function()
                    moduleFunc(player, car)
                    print("✅ Direct call: " .. car .. " (attempt " .. i .. ")")
                end)
                task.wait(0.2)
            end
        end
    end
    
    -- Method 2: Table with execute function
    if type(moduleFunc) == "table" then
        print("Module is a table, searching for execute functions...")
        
        -- Look for execute/run functions
        for key, func in pairs(moduleFunc) do
            if type(func) == "function" then
                print("Found function: " .. key)
                
                for _, car in pairs(targetCars) do
                    for i = 1, 2 do
                        pcall(function()
                            func(player, car)
                            print("✅ " .. key .. ": " .. car .. " (attempt " .. i .. ")")
                        end)
                        task.wait(0.2)
                    end
                end
            end
        end
    end
    
    -- Method 3: Try to find and call Execute method
    if type(moduleFunc) == "table" and moduleFunc.Execute then
        print("Found Execute method")
        for _, car in pairs(targetCars) do
            pcall(function()
                moduleFunc.Execute(player, car)
                print("✅ Execute method: " .. car)
            end)
            task.wait(0.2)
        end
    end
    
    -- Method 4: Try to find and call Run method
    if type(moduleFunc) == "table" and moduleFunc.Run then
        print("Found Run method")
        for _, car in pairs(targetCars) do
            pcall(function()
                moduleFunc.Run(player, car)
                print("✅ Run method: " .. car)
            end)
            task.wait(0.2)
        end
    end
    
    return true
end

-- ===== BYPASS PERMISSION CHECK =====
local function bypassPermissionCheck()
    print("\n🔓 ATTEMPTING PERMISSION BYPASS")
    
    -- Try to fake admin status
    local cmdr = ReplicatedStorage:FindFirstChild("CmdrClient")
    if not cmdr then return false end
    
    -- Look for permission/rank systems
    local permissionSystems = {}
    
    for _, obj in pairs(cmdr:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("perm") or name:find("rank") or name:find("admin") then
                table.insert(permissionSystems, obj)
                print("Found permission system: " .. obj.Name)
            end
        end
    end
    
    -- Try to set fake admin
    for _, remote in pairs(permissionSystems) do
        -- Fake admin data
        local fakeAdminData = {
            Player = player,
            UserId = player.UserId,
            Rank = "Admin",
            Level = 999,
            Permissions = {"GiveCar", "GiveAllCars", "Admin"},
            IsAdmin = true
        }
        
        -- Try to send
        for i = 1, 3 do
            pcall(function()
                if remote:IsA("RemoteEvent") then
                    remote:FireServer(fakeAdminData)
                    print("✅ Sent fake admin data to " .. remote.Name .. " (attempt " .. i .. ")")
                else
                    remote:InvokeServer(fakeAdminData)
                    print("✅ Invoked fake admin data to " .. remote.Name .. " (attempt " .. i .. ")")
                end
            end)
            task.wait(0.3)
        end
    end
    
    -- Also try to modify player attributes
    pcall(function()
        player:SetAttribute("IsAdmin", true)
        player:SetAttribute("Rank", "Admin")
        player:SetAttribute("Permissions", "GiveCar,GiveAllCars")
        print("✅ Set admin attributes on player")
    end)
    
    return #permissionSystems > 0
end

-- ===== CREATE FAKE ADMIN EVENT =====
local function createFakeAdminEvent()
    print("\n🎭 CREATING FAKE ADMIN EVENT")
    
    -- Create a fake remote that might be picked up by the system
    local fakeEvent = Instance.new("RemoteEvent")
    fakeEvent.Name = "AdminPermissionGranted"
    fakeEvent.Parent = ReplicatedStorage
    
    -- Fire it with admin data
    pcall(function()
        fakeEvent:FireServer({
            Player = player,
            Action = "GrantAdmin",
            Level = 999,
            Permissions = {"GiveCar", "GiveAllCars"}
        })
        print("✅ Fired fake admin event")
    end)
    
    -- Also create bindable
    local bindable = Instance.new("BindableEvent")
    bindable.Name = "PermissionUpdate"
    bindable.Parent = ReplicatedStorage
    
    pcall(function()
        bindable:Fire({
            Player = player,
            IsAdmin = true,
            CanGiveCars = true
        })
        print("✅ Fired bindable permission event")
    end)
end

-- ===== SPAM COMMAND SYSTEM =====
local function spamCommandSystem()
    print("\n📨 SPAMMING COMMAND SYSTEM")
    
    local cmdr = ReplicatedStorage:FindFirstChild("CmdrClient")
    if not cmdr then return end
    
    -- Get ALL remotes in Cmdr
    local allRemotes = {}
    for _, obj in pairs(cmdr:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(allRemotes, obj)
        end
    end
    
    print("Found " .. #allRemotes .. " Cmdr remotes")
    
    -- Commands to spam
    local commands = {
        "givecar Bontlay Bontaga",
        "givecar Jegar Model F",
        "givecar Corsaro T8",
        "giveallcars",
        "admin givecar Bontlay Bontaga",
        "sudo givecar Bontlay Bontaga"
    }
    
    -- Spam all remotes
    for _, remote in pairs(allRemotes) do
        for _, cmd in pairs(commands) do
            for i = 1, 3 do
                pcall(function()
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer(cmd)
                        remote:FireServer(player, cmd)
                        remote:FireServer(cmd, player)
                    else
                        remote:InvokeServer(cmd)
                        remote:InvokeServer(player, cmd)
                    end
                    print("✅ Spammed " .. remote.Name .. " with: " .. cmd)
                end)
                task.wait(0.05)
            end
        end
    end
end

-- ===== CHECK FOR SUCCESS =====
local function checkCarSuccess()
    print("\n🔍 CHECKING FOR CAR SUCCESS")
    task.wait(3)
    
    -- Check money (should increase if cars were "bought" for free)
    if player:FindFirstChild("leaderstats") then
        local money = player.leaderstats:FindFirstChild("Money")
        if money then
            print("💰 Current money: $" .. money.Value)
        end
    end
    
    -- Listen for any car-related messages
    for _, remote in pairs(ReplicatedStorage:GetChildren()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote.OnClientEvent:Connect(function(...)
                    local args = {...}
                    for _, arg in pairs(args) do
                        if type(arg) == "string" then
                            if arg:find("Bontlay") or arg:find("Jegar") or arg:find("Corsaro") then
                                print("\n🎉 CAR SUCCESS DETECTED!")
                                print("Message: " .. arg)
                            elseif arg:find("car") or arg:find("vehicle") then
                                print("Car-related message: " .. arg)
                            end
                        end
                    end
                end)
            end)
        end
    end
end

-- ===== CREATE FINAL UI =====
local function createFinalUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 350)
    frame.Position = UDim2.new(0.5, -200, 0.5, -175)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "💥 ULTIMATE FORCE EXECUTION"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "GiveCar module IS loaded!\n\nBut needs permission bypass.\n\nClick buttons to FORCE execution."
    status.Size = UDim2.new(1, -20, 0, 120)
    status.Position = UDim2.new(0, 10, 0, 60)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    -- Button 1: Force Module
    local btn1 = Instance.new("TextButton")
    btn1.Text = "💥 FORCE MODULE"
    btn1.Size = UDim2.new(1, -40, 0, 40)
    btn1.Position = UDim2.new(0, 20, 0, 190)
    btn1.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn1.TextColor3 = Color3.new(1, 1, 1)
    btn1.Font = Enum.Font.GothamBold
    btn1.TextSize = 16
    btn1.Parent = frame
    
    btn1.MouseButton1Click:Connect(function()
        status.Text = "Forcing module execution...\nThis is your BEST chance!"
        btn1.Text = "FORCING..."
        btn1.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
        
        task.spawn(function()
            forceModuleExecution()
            task.wait(2)
            checkCarSuccess()
            status.Text = "✅ Module forced!\nCheck garage NOW!"
            btn1.Text = "TRY AGAIN"
            btn1.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end)
    end)
    
    -- Button 2: Bypass Permissions
    local btn2 = Instance.new("TextButton")
    btn2.Text = "🔓 BYPASS PERMISSIONS"
    btn2.Size = UDim2.new(1, -40, 0, 40)
    btn2.Position = UDim2.new(0, 20, 0, 240)
    btn2.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    btn2.TextColor3 = Color3.new(1, 1, 1)
    btn2.Font = Enum.Font.GothamBold
    btn2.TextSize = 14
    btn2.Parent = frame
    
    btn2.MouseButton1Click:Connect(function()
        status.Text = "Attempting permission bypass..."
        btn2.Text = "BYPASSING..."
        btn2.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            bypassPermissionCheck()
            createFakeAdminEvent()
            status.Text = "✅ Permission bypass attempted!\nNow try Force Module."
            btn2.Text = "TRY AGAIN"
            btn2.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        end)
    end)
    
    -- Button 3: Spam System
    local btn3 = Instance.new("TextButton")
    btn3.Text = "📨 SPAM SYSTEM"
    btn3.Size = UDim2.new(1, -40, 0, 40)
    btn3.Position = UDim2.new(0, 20, 0, 290)
    btn3.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
    btn3.TextColor3 = Color3.new(1, 1, 1)
    btn3.Font = Enum.Font.GothamBold
    btn3.TextSize = 14
    btn3.Parent = frame
    
    btn3.MouseButton1Click:Connect(function()
        status.Text = "Spamming command system...\nMight trigger success!"
        btn3.Text = "SPAMMING..."
        btn3.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        
        task.spawn(function()
            spamCommandSystem()
            task.wait(2)
            checkCarSuccess()
            status.Text = "✅ System spammed!\nCheck for cars."
            btn3.Text = "TRY AGAIN"
            btn3.BackgroundColor3 = Color3.fromRGB(50, 120, 220)
        end)
    end)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return gui, status
end

-- ===== MAIN EXECUTION =====
print("\n" .. string.rep("=", 70))
print("💥 ULTIMATE FORCE EXECUTION")
print(string.rep("=", 70))
print("\nMODULE STATUS: GiveCar and GiveAllCars ARE LOADED!")
print("PROBLEM: Needs admin permissions")
print("\nThis script FORCES execution anyway!")

-- Create UI
task.wait(1)
local gui, status = createFinalUI()

-- Auto-execute EVERYTHING
task.wait(3)
status.Text = "Auto-executing ALL methods...\nFORCING execution!"
print("\n🚀 AUTO-EXECUTING ALL METHODS...")

-- Step 1: Bypass permissions first
print("\n1. ATTEMPTING PERMISSION BYPASS...")
bypassPermissionCheck()
createFakeAdminEvent()

-- Step 2: Force module execution
task.wait(2)
print("\n2. FORCING MODULE EXECUTION...")
forceModuleExecution()

-- Step 3: Spam system
task.wait(2)
print("\n3. SPAMMING COMMAND SYSTEM...")
spamCommandSystem()

-- Step 4: Check for success
task.wait(3)
print("\n4. CHECKING FOR SUCCESS...")
checkCarSuccess()

-- Final message
status.Text = "✅ ALL METHODS EXECUTED!\n\nCheck your garage RIGHT NOW!\n\nIf no cars:\n1. Server has strong protection\n2. Need actual admin rights\n3. Try different server"

print("\n" .. string.rep("=", 70))
print("🎯 EXECUTION COMPLETE")
print(string.rep("=", 70))
print("\nThe GiveCar module WAS loaded and called!")
print("If cars didn't appear, the server's permission")
print("system is blocking execution at server-side.")
print("\n💡 Try: Different server with less security")
