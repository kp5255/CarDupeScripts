-- SERVICES
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- =========================
-- GUI
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "DuplicarAutoGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local fondo = Instance.new("Frame")
fondo.Size = UDim2.new(0, 340, 0, 210)
fondo.Position = UDim2.new(0, 100, 0, 100)
fondo.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fondo.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Car Detector (Client Test)"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = fondo

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0, 260, 0, 32)
textBox.Position = UDim2.new(0, 40, 0, 50)
textBox.PlaceholderText = "Sit in a car..."
textBox.TextEditable = false
textBox.Parent = fondo

local boton = Instance.new("TextButton")
boton.Size = UDim2.new(0, 140, 0, 34)
boton.Position = UDim2.new(0, 100, 0, 120)
boton.Text = "Duplicate (Client)"
boton.Parent = fondo

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 0, 165)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200,200,200)
status.TextScaled = true
status.Text = "Waiting..."
status.Parent = fondo

-- =========================
-- CHARACTER
-- =========================
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- =========================
-- CORRECT ROOT CAR DETECTOR
-- =========================
local function findCarModelFromSeat(seat)
    local current = seat

    while current and current ~= Workspace do
        if current:IsA("Model") then
            -- Validate this model is a car
            if current:FindFirstChildWhichIsA("VehicleSeat", true) then
                return current
            end
        end
        current = current.Parent
    end

    return nil
end

-- =========================
-- DETECTION
-- =========================
local function setupDetection()
    local character = getCharacter()
    local humanoid = character:WaitForChild("Humanoid")

    humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
        local seat = humanoid.SeatPart

        if seat and seat:IsA("VehicleSeat") then
            local carModel = findCarModelFromSeat(seat)

            if carModel then
                textBox.Text = carModel.Name
                status.Text = "Car detected: " .. carModel.Name
                print("[CLIENT] Car detected:", carModel.Name)
            else
                textBox.Text = ""
                status.Text = "Car not detected"
                warn("[CLIENT] Seat found but no car model")
            end
        else
            textBox.Text = ""
            status.Text = "Not seated"
            print("[CLIENT] Not seated")
        end
    end)
end

-- =========================
-- CLIENT DUPLICATION
-- =========================
local function duplicarAuto()
    local name = textBox.Text
    if name == "" then
        warn("[CLIENT] No car to duplicate")
        return
    end

    local car = Workspace:FindFirstChild(name)
    if not car then
        warn("[CLIENT] Car not found in workspace:", name)
        return
    end

    local clone = car:Clone()
    clone.Name = name .. "_CLIENT"
    clone.Parent = Workspace

    print("[CLIENT] Local clone created:", clone.Name)
end

boton.MouseButton1Click:Connect(duplicarAuto)

-- =========================
-- INIT
-- =========================
setupDetection()
print("[CLIENT] Car detector loaded correctly")

