-- ULTRA SIMPLE CAR DUPE SERVER
print("🚗 CAR DUPE SERVER STARTING...")

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get the event (should exist after command bar setup)
local DupeEvent = ReplicatedStorage:FindFirstChild("Dev_DupeCar")
if not DupeEvent then
	error("❌ Dev_DupeCar not found! Run command bar setup first.")
end

print("✅ RemoteEvent connected")

-- Handle duplication
DupeEvent.OnServerEvent:Connect(function(player, seat)
	print("📦 Dupe request from:", player.Name)
	
	-- Quick validation
	if not seat or not seat:IsA("VehicleSeat") then
		print("❌ Invalid seat from", player.Name)
		return false
	end
	
	-- Find car model (simple method)
	local carModel = seat.Parent
	if carModel and carModel:IsA("Model") then
		print("✅ Found car:", carModel.Name)
	else
		-- Try to find parent model
		carModel = nil
		local parent = seat
		for i = 1, 10 do -- Max 10 parents up
			parent = parent.Parent
			if not parent then break end
			if parent:IsA("Model") then
				carModel = parent
				break
			end
		end
		
		if not carModel then
			print("❌ Could not find car model")
			return false
		end
	end
	
	-- Ensure Inventories folder exists
	local inventories = ServerStorage:FindFirstChild("Inventories")
	if not inventories then
		inventories = Instance.new("Folder")
		inventories.Name = "Inventories"
		inventories.Parent = ServerStorage
	end
	
	-- Get or create player folder
	local playerFolder = inventories:FindFirstChild(tostring(player.UserId))
	if not playerFolder then
		playerFolder = Instance.new("Folder")
		playerFolder.Name = tostring(player.UserId)
		playerFolder.Parent = inventories
	end
	
	-- Get or create cars folder
	local carsFolder = playerFolder:FindFirstChild("Cars")
	if not carsFolder then
		carsFolder = Instance.new("Folder")
		carsFolder.Name = "Cars"
		carsFolder.Parent = playerFolder
	end
	
	-- Clone the car
	local clone = carModel:Clone()
	
	-- Simple unique ID (using timestamp)
	local uniqueId = "CAR_" .. tostring(math.floor(tick() * 1000))
	clone.Name = uniqueId
	
	-- Add info
	local info = Instance.new("StringValue")
	info.Name = "DuplicatedFrom"
	info.Value = carModel.Name
	info.Parent = clone
	
	-- Save
	clone.Parent = carsFolder
	
	print("✅ SUCCESS! Duplicated", carModel.Name, "for", player.Name)
	print("   Saved to: ServerStorage/Inventories/" .. player.UserId .. "/Cars/" .. uniqueId)
	
	return true
end)

-- Player join handler (optional)
Players.PlayerAdded:Connect(function(player)
	print("👤 Player joined:", player.Name)
end)

print("==================================")
print("🚗 CAR DUPE SERVER READY!")
print("==================================")
print("Waiting for player requests...")
