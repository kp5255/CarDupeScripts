-- FINAL WORKING CAR DUPE SERVER
print("==========================================")
print("🚗 CAR DUPLICATION SERVER - STARTING")
print("==========================================")

-- Services
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- Ensure HttpService is enabled
if not pcall(function() HttpService:GenerateGUID(false) end) then
	warn("⚠️ HttpService may be disabled. Enable in Game Settings > Security")
end

-- 1. CREATE EVENT IF NOT EXISTS
local DupeEvent = ReplicatedStorage:FindFirstChild("Dev_DupeCar")
if not DupeEvent then
	DupeEvent = Instance.new("RemoteEvent")
	DupeEvent.Name = "Dev_DupeCar"
	DupeEvent.Parent = ReplicatedStorage
	print("✅ Created RemoteEvent: Dev_DupeCar")
else
	print("✅ Found existing RemoteEvent")
end

-- 2. CREATE FOLDERS
local function ensureFolders()
	-- Inventories folder
	if not ServerStorage:FindFirstChild("Inventories") then
		local inv = Instance.new("Folder")
		inv.Name = "Inventories"
		inv.Parent = ServerStorage
		print("✅ Created Inventories folder")
	end
	
	-- CarModels folder (optional)
	if not ServerStorage:FindFirstChild("CarModels") then
		local cm = Instance.new("Folder")
		cm.Name = "CarModels"
		cm.Parent = ServerStorage
		print("✅ Created CarModels folder")
	end
end

ensureFolders()

-- 3. PLAYER JOIN HANDLER
Players.PlayerAdded:Connect(function(player)
	print("👤 Player joined:", player.Name)
	
	local inventories = ServerStorage:WaitForChild("Inventories")
	
	-- Create player folder
	local playerFolder = Instance.new("Folder")
	playerFolder.Name = tostring(player.UserId)
	playerFolder.Parent = inventories
	
	-- Create cars folder
	local carsFolder = Instance.new("Folder")
	carsFolder.Name = "Cars"
	carsFolder.Parent = playerFolder
	
	print("📁 Created inventory for:", player.Name)
end)

-- 4. FIND CAR MODEL FROM SEAT
local function getCarFromSeat(seat)
	if not seat then return nil end
	
	-- Method 1: Direct parent
	if seat.Parent and seat.Parent:IsA("Model") then
		return seat.Parent
	end
	
	-- Method 2: Search up hierarchy
	local current = seat
	for i = 1, 20 do -- Limit search depth
		current = current.Parent
		if not current then break end
		if current == game.Workspace then break end
		if current:IsA("Model") then
			return current
		end
	end
	
	return nil
end

-- 5. MAIN DUPLICATION FUNCTION
DupeEvent.OnServerEvent:Connect(function(player, seat)
	print("\n" .. string.rep("=", 50))
	print("📦 DUPLICATION REQUEST FROM:", player.Name)
	
	-- VALIDATION 1: Check seat exists
	if not seat then
		print("❌ ERROR: No seat provided")
		return false
	end
	
	-- VALIDATION 2: Check seat type
	if not seat:IsA("VehicleSeat") then
		print("❌ ERROR: Not a VehicleSeat. Type:", typeof(seat))
		return false
	end
	
	print("✅ Seat validated:", seat.Name)
	
	-- FIND CAR MODEL
	local carModel = getCarFromSeat(seat)
	
	if not carModel then
		print("❌ ERROR: Could not find car model from seat")
		return false
	end
	
	print("✅ Found car model:", carModel.Name)
	print("   Path:", carModel:GetFullName())
	
	-- GET INVENTORY FOLDERS
	local inventories = ServerStorage:FindFirstChild("Inventories")
	if not inventories then
		print("❌ ERROR: Inventories folder missing")
		return false
	end
	
	local playerFolder = inventories:FindFirstChild(tostring(player.UserId))
	if not playerFolder then
		print("❌ ERROR: No inventory folder for player")
		return false
	end
	
	local carsFolder = playerFolder:FindFirstChild("Cars")
	if not carsFolder then
		print("❌ ERROR: No Cars folder for player")
		return false
	end
	
	print("✅ Player inventory located")
	
	-- GENERATE UNIQUE ID
	local uniqueId
	local success, guid = pcall(function()
		return HttpService:GenerateGUID(false)
	end)
	
	if success then
		uniqueId = "CAR_" .. string.sub(guid, 1, 8)
	else
		-- Fallback: Use timestamp
		uniqueId = "CAR_" .. tostring(math.floor(tick() * 1000)) .. "_" .. player.UserId
		print("⚠️ Using fallback ID (HttpService issue)")
	end
	
	-- CLONE THE CAR
	print("🔄 Cloning car model...")
	local clone = carModel:Clone()
	clone.Name = uniqueId
	
	-- ADD METADATA
	local info = Instance.new("StringValue")
	info.Name = "DuplicatedInfo"
	info.Value = "Original: " .. carModel.Name .. " | Player: " .. player.Name .. " | Time: " .. os.date()
	info.Parent = clone
	
	-- SAVE TO INVENTORY
	clone.Parent = carsFolder
	
	-- VERIFY SAVE
	if clone.Parent == carsFolder then
		print("✅ SUCCESS: Car saved to inventory")
		print("   Path: ServerStorage/Inventories/" .. player.UserId .. "/Cars/" .. uniqueId)
		print("   Original: " .. carModel.Name)
		
		-- Count cars in inventory
		local carCount = #carsFolder:GetChildren()
		print("   Player now has " .. carCount .. " cars")
	else
		print("❌ ERROR: Failed to save car to inventory")
		return false
	end
	
	print(string.rep("=", 50) .. "\n")
	return true
end)

-- 6. PLAYER LEAVE CLEANUP (Optional)
Players.PlayerRemoving:Connect(function(player)
	print("👤 Player leaving:", player.Name)
	-- Keep inventory for now
end)

print("==========================================")
print("🚗 SERVER READY - Waiting for requests...")
print("==========================================")
print("To test: Sit in any car and click dupe button")
print("Cars save to: ServerStorage/Inventories/[UserId]/Cars/")
print("==========================================")
