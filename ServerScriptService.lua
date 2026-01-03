-- FIXED CAR DUPE - HANDLES BODY PARTS
print("=== Car Dupe System ===")

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create event
local DupeEvent = Instance.new("RemoteEvent")
DupeEvent.Name = "CarDupeEvent"
DupeEvent.Parent = ReplicatedStorage
print("Event created")

-- Create storage
local CarStorage = Instance.new("Folder")
CarStorage.Name = "DuplicatedCars"
CarStorage.Parent = ServerStorage
print("Storage created")

-- Player setup
Players.PlayerAdded:Connect(function(player)
    local playerFolder = Instance.new("Folder")
    playerFolder.Name = player.Name
    playerFolder.Parent = CarStorage
    print("Ready for: " .. player.Name)
end)

-- Function to find actual car model
local function getRealCarModel(seat)
    -- Seat → Body → CarModel
    if not seat then return nil end
    
    -- Check if seat is in "Body"
    local body = seat.Parent
    if body and body.Name == "Body" then
        -- Body should be in the car model
        local carModel = body.Parent
        if carModel and carModel:IsA("Model") then
            return carModel
        end
    end
    
    -- Try other possible structures
    local current = seat
    for i = 1, 5 do -- Check up to 5 parents
        current = current.Parent
        if not current then break end
        
        if current:IsA("Model") then
            return current
        end
    end
    
    return nil
end

-- Main dupe function
DupeEvent.OnServerEvent:Connect(function(player, seat)
    print("\n=== Dupe Request ===")
    print("From: " .. player.Name)
    
    -- Check seat
    if not seat then
        print("Error: No seat")
        return false
    end
    
    print("Seat: " .. seat.Name)
    print("Seat Parent: " .. (seat.Parent and seat.Parent.Name or "nil"))
    
    -- Get real car model
    local carModel = getRealCarModel(seat)
    
    if not carModel then
        print("Error: Could not find car model")
        print("Seat path: " .. seat:GetFullName())
        return false
    end
    
    print("Found car: " .. carModel.Name)
    print("Car path: " .. carModel:GetFullName())
    
    -- Get player folder
    local playerFolder = CarStorage:FindFirstChild(player.Name)
    if not playerFolder then
        playerFolder = Instance.new("Folder")
        playerFolder.Name = player.Name
        playerFolder.Parent = CarStorage
    end
    
    -- Clone the car
    local clone = carModel:Clone()
    clone.Name = carModel.Name .. "_Copy_" .. os.time()
    
    -- Save
    clone.Parent = playerFolder
    
    print("SUCCESS! Car saved")
    print("Saved as: " .. clone.Name)
    print("Location: ServerStorage/DuplicatedCars/" .. player.Name)
    print("=====================\n")
    
    return true
end)

print("=== System Ready ===")
print("Waiting for requests...")
