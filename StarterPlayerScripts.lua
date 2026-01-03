-- CLIENT: AUTO DETECT SEATED CAR + BUTTON (DELTA SAFE)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- DO NOT WAIT FOREVER
local DupeEvent = ReplicatedStorage:FindFirstChild("Dev_DupeCar")

if not DupeEvent then
    warn("[CLIENT] Dev_DupeCar not found (server not running)")
end

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
btn.Text = "Dupe Car I'm Sitting In"
btn.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 360, 0, 30)
label.Position = UDim2.new(0, 100, 0, 150)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.new(1,1,1)
label.Text = "Sit in a car"
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
            label.Text = "Vehicle detected"
            print("[CLIENT] Sitting in:", seat:GetFullName())
        else
            currentSeat = nil
            label.Text = "Not seated"
        end
    end)
end

setupHumanoid()

-- =========================
-- BUTTON ACTION
-- =========================
btn.MouseButton1Click:Connect(function()
    if not currentSeat then
        warn("[CLIENT] No vehicle seat detected")
        return
    end

    if not DupeEvent then
        warn("[CLIENT] Cannot dupe — server event missing")
        return
    end

    DupeEvent:FireServer(currentSeat)
    print("[CLIENT] Dupe request sent")
end)
