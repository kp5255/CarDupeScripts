-- FINAL WORKING CAR DUPE CLIENT
print("==========================================")
print("🚗 CAR DUPLICATION CLIENT - STARTING")
print("==========================================")

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Get RemoteEvent (wait with timeout)
local DupeEvent = nil
local serverReady = false

local function connectToServer()
	for i = 1, 15 do -- 15 second timeout
		DupeEvent = ReplicatedStorage:FindFirstChild("Dev_DupeCar")
		if DupeEvent then
			print("✅ Connected to server!")
			serverReady = true
			return true
		end
		wait(1)
		print("⏳ Waiting for server... (" .. i .. "/15)")
	end
	print("❌ Server timeout - make sure server script is running!")
	return false
end

-- Try to connect
task.spawn(connectToServer)

-- Create simple GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CarDupeGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(1, -320, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Text = "🚗 CAR DUPLICATOR"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

-- Status
local status = Instance.new("TextLabel")
status.Text = "Initializing..."
status.Size = UDim2.new(1, -20, 0, 60)
status.Position = UDim2.new(0, 10, 0, 45)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1, 1, 1)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextWrapped = true
status.Parent = frame

-- Button
local button = Instance.new("TextButton")
button.Text = "INITIALIZING..."
button.Size = UDim2.new(1, -40, 0, 50)
button.Position = UDim2.new(0, 20, 0, 110)
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.TextColor3 = Color3.new(1, 1, 1)
button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
button.BorderSizePixel = 0
button.Parent = frame

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = button

-- Border
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 150, 255)
stroke.Thickness = 2
stroke.Parent = frame

-- Track seat
local currentSeat = nil

-- Update seat status
RunService.Heartbeat:Connect(function()
	-- Check server connection
	if not serverReady and DupeEvent then
		serverReady = true
		status.Text = "✅ Server connected!\nSit in a car to begin"
		button.Text = "WAITING FOR CAR"
		button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	end
	
	-- Check character
	local character = player.Character
	if not character then
		currentSeat = nil
		return
	end
	
	-- Check humanoid
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then
		currentSeat = nil
		return
	end
	
	-- Check seat
	local seat = humanoid.SeatPart
	
	if seat and seat:IsA("VehicleSeat") then
		if currentSeat ~= seat then
			currentSeat = seat
			if serverReady then
				status.Text = "✅ IN CAR: " .. (seat.Parent.Name or "Unknown Car")
				button.Text = "DUPLICATE THIS CAR"
				button.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
				print("✅ Sitting in car:", seat.Parent.Name)
			end
		end
	else
		if currentSeat ~= nil then
			currentSeat = nil
			if serverReady then
				status.Text = "❌ NOT IN A CAR\nSit in a vehicle first"
				button.Text = "NEED TO SIT IN CAR"
				button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			end
		end
	end
end)

-- Button click handler
button.MouseButton1Click:Connect(function()
	-- Check server
	if not serverReady or not DupeEvent then
		status.Text = "❌ SERVER OFFLINE\nRun server script first!"
		button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		button.Text = "SERVER ERROR"
		
		-- Try to reconnect
		task.spawn(function()
			wait(2)
			connectToServer()
		end)
		
		return
	end
	
	-- Check seat
	if not currentSeat then
		status.Text = "❌ NO CAR DETECTED\nSit in a car first!"
		button.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
		button.Text = "NO CAR"
		
		-- Flash red
		for i = 1, 3 do
			button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
			wait(0.1)
			button.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
			wait(0.1)
		end
		
		wait(1)
		if not currentSeat then
			button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			button.Text = "NEED TO SIT IN CAR"
			status.Text = "❌ NOT IN A CAR\nSit in a vehicle first"
		end
		return
	end
	
	-- Send duplication request
	print("🔄 Sending duplication request...")
	
	status.Text = "🔄 DUPLICATING CAR...\nPlease wait..."
	button.Text = "PROCESSING..."
	button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
	
	-- Send to server
	local success = DupeEvent:FireServer(currentSeat)
	
	-- Handle response
	if success then
		print("✅ Server confirmed duplication!")
		status.Text = "✅ CAR DUPLICATED!\nCheck ServerStorage/Inventories/"
		button.Text = "SUCCESS!"
		button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	else
		print("❌ Server reported failure")
		status.Text = "❌ DUPLICATION FAILED\nCheck server output for details"
		button.Text = "FAILED - TRY AGAIN"
		button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
	
	-- Reset after 3 seconds
	task.delay(3, function()
		if currentSeat then
			button.Text = "DUPLICATE THIS CAR"
			button.BackgroundColor3 = Color3.fromRGB(0, 180, 80)
			status.Text = "✅ IN CAR: " .. (currentSeat.Parent.Name or "Unknown Car")
		else
			button.Text = "NEED TO SIT IN CAR"
			button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			status.Text = "❌ NOT IN A CAR\nSit in a vehicle first"
		end
	end)
end)

-- Keybind to toggle GUI
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F2 then
		screenGui.Enabled = not screenGui.Enabled
		print("GUI toggled:", screenGui.Enabled)
	end
end)

print("==========================================")
print("🚗 CLIENT READY!")
print("==========================================")
print("• GUI appears in top-right corner")
print("• Press F2 to show/hide GUI")
print("• Sit in any car with VehicleSeat")
print("• Click button to duplicate")
print("==========================================")
