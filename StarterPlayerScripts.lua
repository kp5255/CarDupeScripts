-- CLIENT: AUTO DETECT SEATED CAR + BUTTON (UPDATED)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Wait for server event with timeout
local DupeEvent = nil
local attempts = 0

local function findEvent()
    while attempts < 10 do  -- Try 10 times
        DupeEvent = ReplicatedStorage:FindFirstChild("Dev_DupeCar")
        if DupeEvent then
            print("[CLIENT] Found Dev_DupeCar!")
            return true
        end
        attempts += 1
        wait(1)
        print("[CLIENT] Waiting for server... (" .. attempts .. "/10)")
    end
    warn("[CLIENT] Server not responding after 10 seconds")
    return false
end

-- Start looking for event
task.spawn(findEvent)

-- =========================
-- GUI
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "AutoCarDupeGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 260, 0, 40)
btn.Position = UDim2.new(0, 100, 0, 100)
btn.Text = "Waiting for server..."
btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
btn.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 360, 0, 60)
label.Position = UDim2.new(0, 100, 0, 150)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1,1,1)
label.Font = Enum.Font.Gotham
label.TextSize = 14
label.TextWrapped = true
label.Text = "Connecting to server..."
label.Parent = gui

-- =========================
-- SEAT DETECTION
-- =========================
local currentSeat = nil

local function setupHumanoid()
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
        local seat = humanoid.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            currentSeat = seat
            label.Text = "✅ Vehicle detected!"
            print("[CLIENT] Sitting in:", seat:GetFullName())
            
            -- Only enable button if server is ready
            if DupeEvent then
                btn.Text = "Dupe Car I'm Sitting In"
                btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            end
        else
            currentSeat = nil
            label.Text = "❌ Not seated in vehicle"
            btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        end
    end)
end

setupHumanoid()

-- =========================
-- BUTTON ACTION
-- =========================
btn.MouseButton1Click:Connect(function()
    -- Check server connection
    if not DupeEvent then
        label.Text = "❌ Server not ready!\nRestart or wait..."
        btn.Text = "SERVER OFFLINE"
        btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        warn("[CLIENT] Cannot dupe — server event missing")
        return
    end

    if not currentSeat then
        label.Text = "❌ No vehicle detected!\nSit in a car first."
        warn("[CLIENT] No vehicle seat detected")
        return
    end

    -- Send request
    DupeEvent:FireServer(currentSeat)
    label.Text = "🔄 Duplicating car..."
    btn.Text = "DUPLICATING..."
    btn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    
    print("[CLIENT] Dupe request sent for:", currentSeat:GetFullName())
    
    -- Reset button after 2 seconds
    task.delay(2, function()
        if currentSeat then
            btn.Text = "Dupe Car I'm Sitting In"
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
            label.Text = "✅ Request sent!\nCheck server output."
        else
            btn.Text = "Dupe Car I'm Sitting In"
            btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            label.Text = "❌ Not seated\nSit in a car first"
        end
    end)
end)

-- Update when server is ready
task.spawn(function()
    if findEvent() then
        btn.Text = "Dupe Car I'm Sitting In"
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        label.Text = "✅ Server connected!\nSit in a car to begin."
    else
        btn.Text = "SERVER ERROR"
        btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        label.Text = "❌ Server failed to load\nCheck server script!"
    end
end)

print("[CLIENT] Car duplication UI loaded")
