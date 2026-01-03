-- SERVICES
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- =========================
-- GUI CREATION
-- =========================
local gui = Instance.new("ScreenGui")
gui.Name = "DuplicarAutoGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local fondo = Instance.new("Frame")
fondo.Size = UDim2.new(0, 340, 0, 210)
fondo.Position = UDim2.new(0, 100, 0, 100)
fondo.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fondo.BorderSizePixel = 0
fondo.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Car Detector (Client Test)"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.TextScaled = true
title.Parent = fondo

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0, 260, 0, 32)
textBox.Position = UDim2.new(0, 40, 0, 50)
textBox.PlaceholderText = "Sit in a car..."
textBox.TextEditable = false
textBox.Text = ""
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
-- CHARACTER / HUMANOID
-- =========================
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

-- =========================
-- ROOT CAR FINDER (FIXED)
-- =========================
local function getRootCarModel(seat)
    local current = seat
    local rootModel = nil

    while current do
        if current:IsA("Model") then
            rootModel = current
        end
        current = current.Parent
    end

    return rootModel
end

-- =========================
-- CAR DETECTION
-- =========================
local function setupCarDetection()
    local character = getCharacter()
    local humanoid = character:WaitForChild("Humanoid")

    humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
        local seat = humanoid.SeatPart

        if seat and seat:IsA("VehicleSeat") then
            local carModel = getRootCarModel(seat)

            if carModel then
                textBox.Text = carModel.Name
                status.Text = "Car detected: " .. carModel.Name
                print("[CLIENT] ROOT car detected:", carModel.Name)
            else
                textBox.Text = ""
                status.Text = "Car not detected"
                warn("[CLIENT] No root car model found")
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
    local carName = textBox.Text

    if carName == "" then
        status.Text = "No car detected"
        warn("[CLIENT] Duplicate failed: no car")
        return
    end

    local car = workspace:FindFirstChild(carName)
    if not car then
        status.Text = "Car not in workspace"
        warn("[CLIENT] Car not found in workspace:", carName)
        return
    end

    local clone = car:Clone()
    clone.Name = carName .. "_CLIENT"
    clone.Parent = workspace

    status.Text = "Client clone created"
    print("[CLIENT] Cloned locally:", clone.Name)
end

boton.MouseButton1Click:Connect(duplicarAuto)

-- =========================
-- INIT
-- =========================
setupCarDetection()
print("[CLIENT] Car detector loaded")
