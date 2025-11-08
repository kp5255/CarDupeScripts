-- LocalCarDupe.lua
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dupeEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestDupeCar")

local currentCarModel = nil

-- Detect the car player is sitting in
player.CharacterAdded:Connect(function(character)
    currentCarModel = nil
    character.ChildAdded:Connect(function(child)
        if child:IsA("VehicleSeat") and child.Occupant == character:FindFirstChildOfClass("Humanoid") then
            local model = child:FindFirstAncestorOfClass("Model")
            if model then
                currentCarModel = model
                print("[Local] Sitting in car:", model.Name)
            end
        end
    end)
end)

local function checkSitting()
    local character = player.Character
    if not character then return end
    for _, seat in ipairs(character:GetDescendants()) do
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

player.CharacterAdded:Connect(checkSitting)
checkSitting()

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
