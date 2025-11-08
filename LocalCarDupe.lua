local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dupeEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestDupeCar")

-- Function to get the car the player is currently sitting in
local function getCurrentCar()
    local character = player.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end

    for _, seat in ipairs(workspace:GetDescendants()) do
        if seat:IsA("VehicleSeat") and seat.Occupant == humanoid then
            local model = seat:FindFirstAncestorOfClass("Model")
            if model then
                return model
            end
        end
    end

    return nil
end

-- Press R to duplicate car into inventory
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        local carModel = getCurrentCar() -- check the seat now
        if carModel then
            dupeEvent:FireServer(carModel.Name)
            print("[Local] Requested duplication of", carModel.Name)
        else
            print("[Local] Not sitting in any car!")
        end
    end
end)
