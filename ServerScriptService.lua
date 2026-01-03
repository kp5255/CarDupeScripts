-- SERVER: AUTO DETECT CAR FROM SEAT + REAL DUPE (DEV TEST)
-- COPY AND PASTE THIS ENTIRE SCRIPT EXACTLY AS IS

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

-- Get or create event
local DupeEvent = ReplicatedStorage:FindFirstChild("Dev_DupeCar")
if not DupeEvent then
	DupeEvent = Instance.new("RemoteEvent")
	DupeEvent.Name = "Dev_DupeCar"
	DupeEvent.Parent = ReplicatedStorage
end

-- Inventory setup
local Inventories = ServerStorage:FindFirstChild("Inventories")
if not Inventories then
	Inventories = Instance.new("Folder")
	Inventories.Name = "Inventories"
	Inventories.Parent = ServerStorage
end

-- Player join
Players.PlayerAdded:Connect(function(player)
	local inv = Instance.new("Folder")
	inv.Name = tostring(player.UserId)
	inv.Parent = Inventories

	local cars = Instance.new("Folder")
	cars.Name = "Cars"
	cars.Parent = inv
end)

-- Player leave cleanup
Players.PlayerRemoving:Connect(function(player)
	local playerInv = Inventories:FindFirstChild(tostring(player.UserId))
	if playerInv then
		playerInv:Destroy()
	end
end)

-- Find car from seat
local function findCarModelFromSeat(seat)
	if not seat then return nil end
	
	local current = seat
	local carModel = nil

	while current and current ~= Workspace do
		if current:IsA("Model") then
			carModel = current
		end
		current = current.Parent
	end

	return carModel
end

-- Main duplication
DupeEvent.OnServerEvent:Connect(function(player, seat)
	-- Basic validation
	if not player then return end
	if not seat then
		warn("[DEV] No seat provided")
		return
	end
	
	-- Type check
	if typeof(seat) == "Instance" then
		if not seat:IsA("VehicleSeat") then
			warn("[DEV] Not a VehicleSeat")
			return
		end
	else
		warn("[DEV] Invalid seat type")
		return
	end

	-- Find car model
	local carModel = findCarModelFromSeat(seat)
	if not carModel then
		warn("[DEV] Could not find car model")
		return
	end

	-- Get player inventory
	local inv = Inventories:FindFirstChild(tostring(player.UserId))
	if not inv then
		warn("[DEV] No inventory for player")
		return
	end

	local carsFolder = inv:FindFirstChild("Cars")
	if not carsFolder then
		warn("[DEV] No Cars folder")
		return
	end

	-- Generate unique ID safely
	local success, guid = pcall(function()
		return HttpService:GenerateGUID(false)
	end)
	
	if not success then
		warn("[DEV] Failed to generate GUID")
		return
	end

	-- Clone the car
	local clone = carModel:Clone()
	local uniqueId = "CAR_" .. guid
	clone.Name = uniqueId

	-- Add metadata
	local meta = Instance.new("StringValue")
	meta.Name = "OriginalCarName"
	meta.Value = carModel.Name
	meta.Parent = clone
	
	-- Add owner info
	local owner = Instance.new("StringValue")
	owner.Name = "Owner"
	owner.Value = player.Name
	owner.Parent = clone

	-- Save to inventory
	clone.Parent = carsFolder

	-- Log success
	print("[DEV DUPE] Duplicated:", carModel.Name, "->", uniqueId, "for", player.Name)
	
	return true
end)

print("Car Auto-Detection Duplication System Loaded")
