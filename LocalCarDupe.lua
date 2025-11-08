-- Auto Car Dupe for Car Dealership Tycoon
-- Delta Executor ready

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ==============================
-- Automatically find inventory RemoteEvent
-- ==============================
local function findInventoryEvent()
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("inventory") or obj.Name:lower():find("addcar") then
            print("[AutoDupe] Found inventory event:", obj.Name)
            return obj
        end
    end
    warn("[AutoDupe] Could not find inventory RemoteEvent automatically!")
    return nil
end

local inventoryEvent = findInventoryEvent()
if not inventoryEvent then
    return -- stop if not found
end

-- ==============================
-- Detect the car player is sitting in
-- ==============================
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

-- ==============================
-- Press R to duplicate car into real in-game inventory
-- ==============================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.R then
        local car = getCurrentCar()
        if car then
            -- Fire the game inventory event automatically
            inventoryEvent:FireServer(car.Name)
            print("[AutoDupe] Requested duplication of", car.Name, "into real inventory")
        else
            print("[AutoDupe] Not sitting in any car!")
        end
    end
end)

print("[AutoDupe] Script loaded! Sit in a car and press R to duplicate it into your inventory.")
