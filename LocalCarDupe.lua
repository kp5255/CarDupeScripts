local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dupeEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestDupeCar")

local currentCarName = nil
local lastDupedTime = 0

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
                if model.Name ~= currentCarName then
                    print("[Local] Sitting in car:", model.Name)
                end
                currentCarName = model.Name
                sitting = true
                break
            end
        end
    end

    if not sitting and tick() - lastDupedTime > 0.5 then
        currentCarName = nil
    end
end

game:GetService("RunService").RenderStepped:Connect(updateCurrentCar)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        if currentCarName then
            dupeEvent:FireServer(currentCarName) -- send the name, not the instance
            lastDupedTime = tick()
            print("[Local] Requested duplication of", currentCarName)
        else
            print("[Local] Not sitting in any car!")
        end
    end
end)
