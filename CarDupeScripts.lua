-- LocalCarDupe.lua (fixed car detection)
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dupeEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestDupeCar")

local currentCarModel = nil

-- Function to detect the car player is sitting in
local function updateCurrentCar()
    currentCarModel = nil
    local character = player.Character
    if not character then return end

    -- Check all VehicleSeats in the workspace
    for _, seat in ipairs(workspace:GetDescendants()) do
        if seat:IsA("VehicleSeat") and seat.Occupant == character:FindFirstChildOfClass("Humanoid") then
            local model = seat:FindFirstAncestorOfClass("Model")
            if model then
                currentCarModel = model
                print("[Local] Sitting in car:", model.Name)
                break
            end
        end
    end
end

-- Update when character spawns
player.CharacterAdded:Connect(function()
    wait(1) -- small delay for character to load
    updateCurrentCar()
end)

-- Also check periodically
game:GetService("RunService").RenderStepped:Connect(updateCurrentCar)

-- Press R to duplicate
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        if currentCarModel then
            print("[Local] Requesting dupe of:", currentCarModel.Name)
            dupeEvent:FireServer(currentCarModel.Name)
        else
            print("[Local] Not sitting in any car!")
        end
    end
end)
