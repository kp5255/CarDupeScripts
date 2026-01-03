-- 💾 CAR SAVE/LOAD EXPLOIT
-- Game ID: ffad7ea30d080c4aa1d7bf4b2f5f4381

print("💾 SAVE/LOAD EXPLOIT")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- ===== FIND SAVE/LOAD EVENTS =====
local function findSaveLoadEvents()
    print("\n🔍 Finding Save/Load events...")
    
    local events = {}
    
    -- Look for save/load/data events
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            if name:find("save") or name:find("load") or name:find("data") then
                print("Found: " .. obj.Name)
                table.insert(events, {
                    Object = obj,
                    Name = obj.Name,
                    Type = obj.ClassName
                })
            end
        end
    end
    
    return events
end

-- ===== GET YOUR CURRENT CAR DATA =====
local function getCarData()
    print("\n📊 Getting your car data...")
    
    local carData = {}
    
    -- Find LirrMedMuseumCar data
    for _, folder in pairs(player:GetChildren()) do
        if folder:IsA("Folder") then
            for _, item in pairs(folder:GetChildren()) do
                if item.Name == "LirrMedMuseumCar" then
                    -- Get all properties
                    local data = {
                        Name = item.Name,
                        ClassName = item.ClassName,
                        Properties = {}
                    }
                    
                    -- Try to get value if it's a ValueBase
                    if item:IsA("ValueBase") then
                        data.Value = item.Value
                    end
                    
                    -- Get children
                    data.Children = {}
                    for _, child in pairs(item:GetChildren()) do
                        table.insert(data.Children, {
                            Name = child.Name,
                            ClassName = child.ClassName
                        })
                    end
                    
                    table.insert(carData, data)
                    print("Found LirrMedMuseumCar data")
                end
            end
        end
    end
    
    return carData
end

-- ===== ATTEMPT SAVE/LOAD EXPLOIT =====
local function attemptSaveLoadExploit()
    print("\n💾 Attempting Save/Load exploit...")
    
    local events = findSaveLoadEvents()
    local carData = getCarData()
    
    if #events == 0 then
        print("❌ No save/load events found!")
        return false
    end
    
    if #carData == 0 then
        print("❌ No car data found!")
        return false
    end
    
    -- Create fake save data with duplicated cars
    local fakeSaveData = {
        Cars = {
            "LirrMedMuseumCar",
            "LirrMedMuseumCar",  -- Duplicated
            "LirrMedMuseumCar",  -- Duplicated
            "LirrMedMuseumCar"   -- Duplicated
        },
        Money = 9999999,
        Timestamp = os.time(),
        PlayerId = player.UserId,
        Version = "1.0"
    }
    
    -- Convert to JSON
    local jsonData
    pcall(function()
        jsonData = HttpService:JSONEncode(fakeSaveData)
    end)
    
    if not jsonData then
        jsonData = "Cars=LirrMedMuseumCar,LirrMedMuseumCar,LirrMedMuseumCar"
    end
    
    -- Try to send fake save data
    for _, eventData in pairs(events) do
        local event = eventData.Object
        
        print("\nTrying event: " .. eventData.Name)
        
        -- Different save data formats
        local saveAttempts = {
            {jsonData},
            {player, jsonData},
            {"load", jsonData},
            {"setdata", jsonData},
            {Data = jsonData},
            {SaveData = jsonData},
            {player.UserId, jsonData}
        }
        
        for i, args in pairs(saveAttempts) do
            local success, errorMsg = pcall(function()
                if eventData.Type == "RemoteEvent" then
                    event:FireServer(unpack(args))
                else
                    event:InvokeServer(unpack(args))
                end
            end)
            
            if success then
                print("✅ Save attempt " .. i .. " sent")
            else
                if errorMsg and #errorMsg > 0 then
                    print("❌ Error: " .. errorMsg:sub(1, 50))
                end
            end
            
            task.wait(0.1)
        end
    end
    
    return true
end

-- ===== SERVER-SIDE EVENT LISTENER =====
local function listenForServerEvents()
    print("\n👂 Listening for server events...")
    
    -- Create a fake remote event to catch server responses
    local listener = Instance.new("RemoteEvent")
    listener.Name = "CarDuplicationListener_" .. player.UserId
    listener.Parent = ReplicatedStorage
    
    -- Also try to intercept actual game events
    for _, obj in pairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") then
            -- Try to connect to see what the server sends
            local connection
            pcall(function()
                connection = obj.OnClientEvent:Connect(function(...)
                    print("\n📨 Server sent via " .. obj.Name .. ":")
                    print("Args: ", ...)
                end)
            end)
        end
    end
end

-- ===== BRUTE FORCE ALL METHODS =====
local function bruteForceAllMethods()
    print("\n💥 BRUTE FORCE ALL METHODS")
    
    -- Method 1: Try to find and call module scripts
    print("\n[1] Looking for module scripts...")
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("ModuleScript") then
            local name = obj.Name:lower()
            if name:find("car") or name:find("vehicle") then
                print("Found module: " .. obj.Name)
                -- Try to require it
                local success, module = pcall(function()
                    return require(obj)
                end)
                if success and type(module) == "table" then
                    -- Try to call functions
                    for funcName, func in pairs(module) do
                        if type(func) == "function" then
                            pcall(function()
                                func("LirrMedMuseumCar")
                                print("Called: " .. funcName)
                            end)
                        end
                    end
                end
            end
        end
    end
    
    -- Method 2: Try to trigger achievement/reward events
    print("\n[2] Trying achievement events...")
    local achievementEvents = {"AchievementComplete", "RewardPlayer", "GiveReward"}
    for _, eventName in pairs(achievementEvents) do
        local event = ReplicatedStorage:FindFirstChild(eventName)
        if event then
            pcall(function()
                event:FireServer("CarDuplication", "LirrMedMuseumCar")
                print("Triggered: " .. eventName)
            end)
        end
    end
    
    -- Method 3: Try to find and use BindableEvents
    print("\n[3] Looking for BindableEvents...")
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
            local name = obj.Name:lower()
            if name:find("car") or name:find("spawn") then
                pcall(function()
                    if obj:IsA("BindableEvent") then
                        obj:Fire("LirrMedMuseumCar")
                    else
                        obj:Invoke("LirrMedMuseumCar")
                    end
                    print("Triggered Bindable: " .. obj.Name)
                end)
            end
        end
    end
end

-- ===== CREATE GUI =====
local function createGUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 300)
    frame.Position = UDim2.new(0.5, -175, 0.5, -150)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local title = Instance.new("TextLabel")
    title.Text = "💾 ADVANCED DUPLICATION METHODS"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame
    
    local status = Instance.new("TextLabel")
    status.Text = "Target: LirrMedMuseumCar\n\nGame has strong protection.\nTrying alternative methods..."
    status.Size = UDim2.new(1, -20, 0, 100)
    status.Position = UDim2.new(0, 10, 0, 50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 14
    status.TextWrapped = true
    status.Parent = frame
    
    -- Method buttons
    local methods = {
        {
            Text = "💾 SAVE/LOAD EXPLOIT",
            Y = 160,
            Action = function()
                status.Text = "Trying save/load exploit..."
                task.spawn(function()
                    attemptSaveLoadExploit()
                    task.wait(2)
                    status.Text = "Save/load attempted.\nCheck if cars duplicated."
                end)
            end
        },
        {
            Text = "👂 LISTEN FOR EVENTS",
            Y = 210,
            Action = function()
                status.Text = "Listening for server events..."
                task.spawn(function()
                    listenForServerEvents()
                    status.Text = "Listening active.\nCheck console for responses."
                end)
            end
        },
        {
            Text = "💥 BRUTE FORCE ALL",
            Y = 260,
            Action = function()
                status.Text = "Brute forcing all methods...\nThis may take a moment."
                task.spawn(function()
                    bruteForceAllMethods()
                    task.wait(3)
                    status.Text = "Brute force complete.\nCheck your garage."
                end)
            end
        }
    }
    
    for _, method in pairs(methods) do
        local button = Instance.new("TextButton")
        button.Text = method.Text
        button.Size = UDim2.new(1, -40, 0, 40)
        button.Position = UDim2.new(0, 20, 0, method.Y)
        button.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.Parent = frame
        
        button.MouseButton1Click:Connect(method.Action)
    end
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    return gui, status
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("FINAL ATTEMPT: Alternative Methods")
print(string.rep("=", 60))
print("\nSince direct duplication fails,")
print("trying alternative approaches...")

-- Create GUI
task.wait(1)
local gui, status = createGUI()

-- Auto-start method 1
task.wait(3)
status.Text = "Auto-starting save/load exploit..."
task.wait(1)
attemptSaveLoadExploit()

-- Auto-start method 2
task.wait(2)
status.Text = "Now listening for server events..."
listenForServerEvents()

-- Auto-start method 3
task.wait(2)
status.Text = "Finally, brute forcing all methods..."
task.wait(1)
bruteForceAllMethods()

-- Final check
task.wait(3)
status.Text = "All methods attempted!\n\nCheck your garage now.\nIf nothing changed, the game\nhas impenetrable protection."

print("\n" .. string.rep("=", 60))
print("ALL METHODS EXHAUSTED")
print(string.rep("=", 60))
print("\nIf cars still didn't duplicate:")
print("1. Game has server-side validation")
print("2. All requests are being rejected")
print("3. No client-side exploit is possible")
print("\nYou would need:")
print("• Server access")
print("• A game vulnerability")
print("• Or play legitimately")
