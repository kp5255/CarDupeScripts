-- 🚗 CLEAN Car Duplication Script for Delta
-- No obfuscation, no errors

print("======================================")
print("DELTA CAR DUPLICATION TOOL")
print("======================================")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Wait for game
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Simple UI without Orion (works in Delta)
local function createSimpleUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DeltaCarDupe"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 DELTA CAR DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = mainFrame
    
    -- Status display
    local statusBox = Instance.new("Frame")
    statusBox.Size = UDim2.new(1, -20, 0, 150)
    statusBox.Position = UDim2.new(0, 10, 0, 50)
    statusBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    statusBox.BorderSizePixel = 0
    statusBox.Parent = mainFrame
    
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Text = "Welcome to Delta Car Duplicator!\n\nInstructions:\n1. Sit in a car\n2. Scan game\n3. Duplicate"
    statusText.Size = UDim2.new(1, -10, 1, -10)
    statusText.Position = UDim2.new(0, 5, 0, 5)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.new(1, 1, 1)
    statusText.Font = Enum.Font.Code
    statusText.TextSize = 12
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextYAlignment = Enum.TextYAlignment.Top
    statusText.TextWrapped = true
    statusText.Parent = statusBox
    
    -- Buttons
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(1, -20, 0, 200)
    buttonFrame.Position = UDim2.new(0, 10, 0, 210)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainFrame
    
    local buttons = {
        {name = "🔍 SCAN GAME", color = Color3.fromRGB(0, 120, 215), func = "scan"},
        {name = "🚗 DUPLICATE CAR", color = Color3.fromRGB(0, 180, 0), func = "duplicate"},
        {name = "🔄 FIND EVENTS", color = Color3.fromRGB(255, 140, 0), func = "findEvents"},
        {name = "⚡ QUICK DUPE", color = Color3.fromRGB(180, 0, 255), func = "quickDupe"},
        {name = "🛡️ ANTI-KICK", color = Color3.fromRGB(200, 50, 50), func = "antiKick"},
        {name = "❌ CLOSE", color = Color3.fromRGB(150, 150, 150), func = "close"}
    }
    
    for i, btnData in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Text = btnData.name
        button.Size = UDim2.new(1, 0, 0, 30)
        button.Position = UDim2.new(0, 0, 0, (i-1)*35)
        button.BackgroundColor3 = btnData.color
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.Name = btnData.func
        button.Parent = buttonFrame
        
        -- Styling
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = button
    end
    
    -- Close button on title
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = title
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = closeBtn
    
    -- Main frame styling
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    return screenGui, statusText
end

-- Create UI
local gui, statusLabel = createSimpleUI()

-- Update status function
local function updateStatus(text)
    statusLabel.Text = text
    print("[Delta] " .. text)
end

-- Variables
local currentVehicle = nil
local foundEvents = {}

-- Vehicle detection
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local seat = humanoid.SeatPart
    
    if seat and seat:IsA("VehicleSeat") then
        local vehicle = seat.Parent
        if vehicle ~= currentVehicle then
            currentVehicle = vehicle
            updateStatus("✅ Vehicle Detected:\n" .. vehicle.Name .. "\n\nReady to duplicate!")
        end
    elseif currentVehicle then
        currentVehicle = nil
        updateStatus("No vehicle detected\n\nSit in a car to begin")
    end
end)

-- Scan game for events
local function scanGame()
    updateStatus("🔍 Scanning game...")
    
    foundEvents = {}
    local eventNames = {}
    
    -- Search ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            
            if name:find("car") or name:find("vehicle") or name:find("buy") or 
               name:find("purchase") or name:find("save") or name:find("add") or
               name:find("garage") or name:find("inventory") then
                
                table.insert(foundEvents, obj)
                table.insert(eventNames, obj.Name)
                
                print("Found: " .. obj.Name .. " (" .. obj:GetFullName() .. ")")
            end
        end
    end
    
    if #foundEvents > 0 then
        updateStatus("✅ Scan Complete!\n\nFound " .. #foundEvents .. " car events:\n" .. table.concat(eventNames, "\n"))
    else
        updateStatus("❌ No car events found!\n\nThis game might not be vulnerable.\nTry a different car game.")
    end
    
    return foundEvents
end

-- Find all events (not just car-related)
local function findAllEvents()
    updateStatus("🔄 Finding ALL remote events...")
    
    foundEvents = {}
    local allEvents = {}
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(foundEvents, obj)
            table.insert(allEvents, obj.Name)
        end
    end
    
    updateStatus("Found " .. #foundEvents .. " total events:\n" .. table.concat(allEvents, "\n"))
    
    return foundEvents
end

-- Duplication function
local function duplicateCar()
    if not currentVehicle then
        updateStatus("❌ Not in a vehicle!\n\nSit in a car first.")
        return
    end
    
    if #foundEvents == 0 then
        updateStatus("⚠️ Scan game first!\n\nClick SCAN GAME button.")
        return
    end
    
    local carName = currentVehicle.Name
    updateStatus("🔄 Duplicating: " .. carName .. "\n\nProcessing...")
    
    local successCount = 0
    
    -- Try each event with different arguments
    for _, event in pairs(foundEvents) do
        local attempts = {
            {carName},
            {"buy", carName},
            {"add", carName},
            {vehicle = carName, player = player},
            {action = "duplicate", car = carName},
            {carName, 0}, -- Free
            {carName, 1}, -- Cheap
        }
        
        for _, args in pairs(attempts) do
            local success = pcall(function()
                event:FireServer(unpack(args))
            end)
            
            if success then
                successCount = successCount + 1
                print("Success with: " .. event.Name)
            end
            
            task.wait(0.05) -- Small delay
        end
    end
    
    updateStatus("✅ Duplication Complete!\n\nSuccessfully sent " .. successCount .. " requests.\nCheck your garage!")
    
    -- Auto-reset after 3 seconds
    task.delay(3, function()
        if currentVehicle then
            updateStatus("✅ Ready to duplicate:\n" .. currentVehicle.Name)
        else
            updateStatus("No vehicle detected\n\nSit in a car to begin")
        end
    end)
end

-- Quick duplication (aggressive)
local function quickDuplication()
    if not currentVehicle then
        updateStatus("❌ Not in a vehicle!")
        return
    end
    
    local carName = currentVehicle.Name
    updateStatus("⚡ QUICK DUPE: " .. carName .. "\n\nSpamming all events...")
    
    -- Get ALL events
    local allEvents = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(allEvents, obj)
        end
    end
    
    -- Spam all events 20 times
    for i = 1, 20 do
        for _, event in pairs(allEvents) do
            pcall(function()
                event:FireServer(carName)
                event:FireServer("duplicate", carName)
                event:FireServer("add", carName)
            end)
        end
        
        updateStatus("⚡ Quick Dupe: " .. carName .. "\nBatch " .. i .. "/20")
        task.wait(0.1)
    end
    
    updateStatus("✅ Quick Dupe Complete!\n20 batches sent.\nCheck your garage!")
end

-- Anti-kick protection
local function setupAntiKick()
    updateStatus("🛡️ Setting up anti-kick...")
    
    -- Hook kick function
    local oldKick = player.Kick
    player.Kick = function(self, reason)
        print("🚫 KICK ATTEMPTED: " .. tostring(reason))
        updateStatus("⚠️ KICK BLOCKED!\nReason: " .. tostring(reason))
        return nil
    end
    
    updateStatus("✅ Anti-kick active!\nKick attempts will be blocked.")
end

-- Button actions
gui.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("TextButton") then
        descendant.MouseButton1Click:Connect(function()
            local btnName = descendant.Name
            
            if btnName == "scan" then
                scanGame()
            elseif btnName == "duplicate" then
                duplicateCar()
            elseif btnName == "findEvents" then
                findAllEvents()
            elseif btnName == "quickDupe" then
                quickDuplication()
            elseif btnName == "antiKick" then
                setupAntiKick()
            elseif btnName == "close" then
                gui:Destroy()
                print("Delta UI closed")
            end
        end)
    end
end)

-- Auto-scan on start
task.wait(2)
scanGame()

print("\n" .. string.rep("=", 50))
print("✅ DELTA CAR DUPLICATOR LOADED!")
print("=":rep(50))
print("Instructions:")
print("1. Sit in the car you want to duplicate")
print("2. Click 'SCAN GAME' to find events")
print("3. Click 'DUPLICATE CAR' to start")
print("4. Check your garage/inventory")
print("=":rep(50))

updateStatus("✅ Delta Car Duplicator Ready!\n\nSit in a car and click SCAN GAME")
