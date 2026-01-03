-- CLIENT: AUTO DETECT SEATED CAR + BUTTON
-- COPY AND PASTE THIS ENTIRE SCRIPT EXACTLY AS IS

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Get player
local player = Players.LocalPlayer

-- Get or wait for RemoteEvent
local DupeEvent = ReplicatedStorage:WaitForChild("Dev_DupeCar")

-- =========================
-- GUI CREATION
-- =========================
local function createGUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = "AutoCarDupeGUI"
	gui.Parent = player:WaitForChild("PlayerGui")
	gui.ResetOnSpawn = false

	-- Main frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 200)
	frame.Position = UDim2.new(1, -320, 0, 20)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 0.1
	frame.Parent = gui

	-- Title
	local title = Instance.new("TextLabel")
	title.Text = "🚗 CAR DUPLICATOR"
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	title.TextColor3 = Color3.new(1, 1, 1)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.Parent = frame

	-- Status label
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 40)
	label.Position = UDim2.new(0, 10, 0, 50)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.Gotham
	label.TextSize = 16
	label.TextWrapped = true
	label.Text = "Sit in a car to begin..."
	label.Parent = frame

	-- Duplicate button
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -40, 0, 45)
	btn.Position = UDim2.new(0, 20, 0, 120)
	btn.Text = "DUPLICATE CURRENT CAR"
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 16
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	btn.BorderSizePixel = 0
	btn.Parent = frame

	-- Button styling
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = btn

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(255, 255, 255)
	uiStroke.Thickness = 2
	uiStroke.Parent = frame

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = frame

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "X"
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -35, 0, 5)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = frame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 15)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		gui.Enabled = false
	end)

	return gui, btn, label
end

-- =========================
-- VARIABLES
-- =========================
local currentSeat = nil
local isDuplicating = false
local gui, btn, statusLabel = createGUI()

-- =========================
-- SEAT DETECTION
-- =========================
local function setupSeatDetection()
	local function checkSeat()
		local character = player.Character
		if not character then return end
		
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then return end
		
		local seat = humanoid.SeatPart
		if seat and seat:IsA("VehicleSeat") then
			currentSeat = seat
			statusLabel.Text = "✅ Vehicle detected!\nReady to duplicate."
			statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
			btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
			
			-- Visual feedback
			local tween = TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(0, 200, 100)
			})
			tween:Play()
			
			print("[CAR DUPE] Detected vehicle seat:", seat.Name)
		else
			currentSeat = nil
			statusLabel.Text = "❌ Not in a vehicle\nSit in a car to begin"
			statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		end
	end

	-- Check on character added
	player.CharacterAdded:Connect(function(character)
		task.wait(1) -- Wait for humanoid to load
		local humanoid = character:WaitForChild("Humanoid")
		
		-- Check seat when property changes
		humanoid:GetPropertyChangedSignal("SeatPart"):Connect(checkSeat)
		
		-- Initial check
		checkSeat()
	end)

	-- Also check periodically for reliability
	RunService.Heartbeat:Connect(function()
		local character = player.Character
		if character and character:FindFirstChild("Humanoid") then
			checkSeat()
		end
	end)
end

-- =========================
-- BUTTON ACTION
-- =========================
btn.MouseButton1Click:Connect(function()
	if isDuplicating then return end
	if not currentSeat then
		statusLabel.Text = "❌ No vehicle detected!\nSit in a car first."
		statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		
		-- Shake animation
		local originalPos = btn.Position
		for i = 1, 3 do
			btn.Position = originalPos + UDim2.new(0, 5, 0, 0)
			task.wait(0.05)
			btn.Position = originalPos + UDim2.new(0, -5, 0, 0)
			task.wait(0.05)
		end
		btn.Position = originalPos
		return
	end

	-- Prevent multiple clicks
	isDuplicating = true
	
	-- Visual feedback
	statusLabel.Text = "🔄 Duplicating car..."
	statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	btn.Text = "DUPLICATING..."
	btn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)

	-- Animation
	local tween = TweenService:Create(btn, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
		BackgroundColor3 = Color3.fromRGB(255, 140, 0)
	})
	tween:Play()

	-- Send request to server
	print("[CAR DUPE] Sending duplication request...")
	local success = DupeEvent:FireServer(currentSeat)

	-- Handle response
	if success then
		statusLabel.Text = "✅ Car duplicated successfully!\nCheck your inventory."
		statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		btn.Text = "✓ SUCCESS!"
		
		print("[CAR DUPE] Duplication successful!")
	else
		statusLabel.Text = "❌ Duplication failed!\nTry again or check console."
		statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
		btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		btn.Text = "✗ FAILED - TRY AGAIN"
		
		print("[CAR DUPE] Duplication failed")
	end

	-- Reset button after delay
	task.delay(2, function()
		btn.Text = "DUPLICATE CURRENT CAR"
		isDuplicating = false
		
		-- Update seat status
		if currentSeat then
			btn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
			statusLabel.Text = "✅ Vehicle detected!\nReady to duplicate."
			statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		else
			btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			statusLabel.Text = "❌ Not in a vehicle\nSit in a car to begin"
			statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
		end
	end)
end)

-- =========================
-- KEYBIND TOGGLE
-- =========================
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.G then
		gui.Enabled = not gui.Enabled
		print("[CAR DUPE] GUI toggled:", gui.Enabled)
	end
end)

-- =========================
-- INITIALIZE
-- =========================
setupSeatDetection()

print("======================================")
print("🚗 CAR DUPLICATION CLIENT LOADED")
print("======================================")
print("• Press 'G' to toggle GUI")
print("• Sit in any car with VehicleSeat")
print("• Click button to duplicate")
print("• Cars save to: ServerStorage/Inventories/[UserId]/Cars/")
print("======================================")
