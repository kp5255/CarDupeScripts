-- LocalCarDupe.lua (clean version)
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dupeEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestDupeCar")

-- Returns the model the player is seated in (if any)
local function getSeatedCar()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return nil end

	local seat = humanoid.SeatPart
	if seat then
		local model = seat:FindFirstAncestorOfClass("Model")
		if model then
			return model
		end
	end
	return nil
end

-- Listen for R key to dupe
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.R then
		local car = getSeatedCar()
		if car then
			print("[Local] Requesting dupe of:", car.Name)
			dupeEvent:FireServer(car.Name)
		else
			warn("[Local] Not sitting in any car.")
		end
	end
end)


