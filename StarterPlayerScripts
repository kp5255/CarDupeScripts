-- CLIENT: TEST CAR DUPE
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local DupeEvent = ReplicatedStorage:WaitForChild("Dev_DupeCar")

-- Bind to key (e.g., 'P')
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.P then
		local target = mouse.Target
		
		if target and target:IsA("VehicleSeat") then
			print("[CLIENT] Duplicating car from seat...")
			DupeEvent:FireServer(target)
		else
			print("[CLIENT] Click on a VehicleSeat first!")
		end
	end
end)

print("Press 'P' while hovering over a VehicleSeat to duplicate its car")
