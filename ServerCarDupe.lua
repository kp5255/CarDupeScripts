local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dupeEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestDupeCar")

local currentCarModel = nil
local lastDupedTime = 0

-- Detect car player is sitting in
local function updateCurrentCar()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    local sitting = false
    for _, seat in ipairs(workspace:GetDescendants()) do
        if seat:IsA("VehicleSeat") and seat.Occupant == humanoid then
            local model = seat:FindFirstAncestorOfClass("Model")
            if model then
                if model ~= currentCarModel then
                    print("[Local] Sitting in car:", model.Name)
                end
                currentCarModel = model
                sitting = true
                break
            end
        end
    end

    if not sitting and tick() - lastDupedTime > 0.5 then
        currentCarModel = nil
    end
end

-- Update current car periodically
game:GetService("RunService").RenderStepped:Connect(updateCurrentCar)

-- Press R to duplicate car into inventory
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        if currentCarModel then
            dupeEvent:FireServer(currentCarModel)
            lastDupedTime = tick()
            print("[Local] Requested duplication of", currentCarModel.Name)
        else
            print("[Local] Not sitting in any car!")
        end
    end
end)

