-- ULTRA SIMPLE CAR DUPE CLIENT
print("🚗 CAR DUPE CLIENT STARTING...")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Get the event
local DupeEvent = ReplicatedStorage:FindFirstChild("Dev_DupeCar")
if not DupeEvent then
	print("❌ Waiting for server event...")
	-- Wait a bit and try again
	wait(2)
	DupeEvent = ReplicatedStorage:FindFirstChild("Dev_DupeCar")
	if not DupeEvent then
		warn("❌ Server not responding. Make sure server script is running!")
	else
		print("✅ Found server event!")
	end
else
	print("✅ Server event found immediately")
end

-- Simple button in corner
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CarDupeButton"
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(1, -210, 0, 20)
button.Text = "🚗 DUPE CAR"
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.TextColor3 = Color3.new(1, 1, 1)
button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
button.BorderSizePixel = 0
button.Parent = screenGui

-- Rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = button

-- Status label
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 200, 0, 40)
status.Position = UDim2.new(1, -210, 0, 80)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1, 1, 1)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextWrapped = true
status.Text = "Sit in a car, then click"
status.Parent = screenGui

-- Track current seat
local currentSeat = nil

-- Check for seat periodically
game:GetService("RunService").Heartbeat:Connect(function()
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	local seat = humanoid.SeatPart
	
	if seat and seat:IsA("VehicleSeat") then
		if currentSeat ~= seat then
			currentSeat = seat
			status.Text = "✅ In: " .. (seat.Parent.Name or "Car")
			button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
			print("✅ Sitting in car")
		end
	else
		if currentSeat ~= nil then
			currentSeat = nil
			status.Text = "❌ Not in a car\nSit in vehicle first"
			button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		end
	end
end)

-- Button click
button.MouseButton1Click:Connect(function()
	if not DupeEvent then
		status.Text = "❌ Server offline!\nRun server script first"
		button.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		warn("Server event not found!")
		return
	end
	
	if not currentSeat then
		status.Text = "❌ Sit in a car first!"
		button.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
		return
	end
	
	-- Visual feedback
	status.Text = "🔄 Duplicating..."
	button.Text = "PROCESSING..."
	button.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
	
	-- Send request
	local success = DupeEvent:FireServer(currentSeat)
	
	if success then
		status.Text = "✅ Success!\nCheck ServerStorage"
		button.Text = "SUCCESS!"
		button.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		print("✅ Duplication successful!")
	else
		status.Text = "❌ Failed\nTry again"
		button.Text = "FAILED"
		button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		print("❌ Duplication failed")
	end
	
	-- Reset after 3 seconds
	wait(3)
	
	if currentSeat then
		button.Text = "🚗 DUPE CAR"
		button.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
		status.Text = "✅ In: " .. (currentSeat.Parent.Name or "Car")
	else
		button.Text = "🚗 DUPE CAR"
		button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		status.Text = "❌ Not in a car\nSit in vehicle first"
	end
end)

print("==================================")
print("🚗 CAR DUPE CLIENT READY!")
print("==================================")
print("• Button appears in top-right")
print("• Sit in any car with VehicleSeat")
print("• Click button to duplicate")
print("==================================")
