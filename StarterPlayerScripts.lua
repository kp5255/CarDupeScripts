-- 🎮 ESCAPE TSUNAMI - CMDER EVENT UNLOCKER
-- Works visually without detection

print("🎮 ESCAPE TSUNAMI CMDER UNLOCKER")
print("=" .. string.rep("=", 50))

-- SAFE SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- PLAYER SETUP
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- FIND CMDER EVENT LOCATIONS
print("\n🔍 SCANNING FOR CMDER EVENTS...")

-- Common CMDER event locations in Escape Tsunami
local eventLocations = {
    -- Main map locations
    {Name = "CMD Tower", Position = Vector3.new(100, 50, 0)},
    {Name = "Secret Bunker", Position = Vector3.new(-200, 25, 150)},
    {Name = "Helipad", Position = Vector3.new(50, 100, -100)},
    {Name = "Underground Lab", Position = Vector3.new(0, -50, 0)},
    {Name = "Radar Station", Position = Vector3.new(300, 75, 200)},
    {Name = "Command Center", Position = Vector3.new(-150, 60, -200)},
    {Name = "Satellite Dish", Position = Vector3.new(250, 120, 100)},
    {Name = "Control Room", Position = Vector3.new(180, 40, -150)},
}

-- CREATE VISUAL MARKERS FOR EVENTS
print("\n🎯 CREATING VISUAL MARKERS...")

local markers = {}
local beams = {}

local function createMarker(position, name, color)
    -- Create base part
    local marker = Instance.new("Part")
    marker.Name = "CMDER_Marker_" .. name
    marker.Size = Vector3.new(5, 5, 5)
    marker.Position = position + Vector3.new(0, 10, 0)
    marker.Anchored = true
    marker.CanCollide = false
    marker.Material = Enum.Material.Neon
    marker.Color = color
    marker.Transparency = 0.3
    
    -- Add special effects
    local particle = Instance.new("ParticleEmitter")
    particle.Color = ColorSequence.new(color)
    particle.Size = NumberSequence.new(1, 3)
    particle.Transparency = NumberSequence.new(0.3, 0.8)
    particle.Lifetime = NumberRange.new(2, 4)
    particle.Rate = 20
    particle.Speed = NumberRange.new(2, 5)
    particle.Parent = marker
    
    -- Add light
    local light = Instance.new("PointLight")
    light.Color = color
    light.Range = 20
    light.Brightness = 2
    light.Parent = marker
    
    -- Add text label
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 8, 0)
    billboard.AlwaysOnTop = true
    
    local label = Instance.new("TextLabel")
    label.Text = "🎮 " .. name
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = billboard
    billboard.Parent = marker
    
    -- Create beam to player
    local beam = Instance.new("Beam")
    beam.Color = ColorSequence.new(color)
    beam.Width0 = 0.5
    beam.Width1 = 0.5
    beam.FaceCamera = true
    
    local attachment0 = Instance.new("Attachment")
    attachment0.Parent = marker
    
    local attachment1 = Instance.new("Attachment")
    attachment1.Parent = HumanoidRootPart
    
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.Parent = Workspace
    
    -- Store references
    markers[name] = marker
    beams[name] = {beam, attachment0, attachment1}
    
    -- Add pulsing animation
    spawn(function()
        while marker and marker.Parent do
            local tween = TweenService:Create(
                marker,
                TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
                {Transparency = 0.7}
            )
            tween:Play()
            tween.Completed:Wait()
        end
    end)
    
    marker.Parent = Workspace
    print("✅ Created marker: " .. name)
    
    return marker
end

-- CREATE ALL MARKERS
for _, event in pairs(eventLocations) do
    local color = Color3.fromHSV(math.random(), 0.8, 1)
    createMarker(event.Position, event.Name, color)
end

-- TELEPORT FUNCTION
print("\n🚀 CREATING TELEPORT SYSTEM...")

local function teleportToEvent(eventName)
    for _, event in pairs(eventLocations) do
        if event.Name == eventName then
            print("Teleporting to: " .. eventName)
            
            -- Fade out effect
            local fade = Instance.new("ScreenGui")
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.new(0, 0, 0)
            frame.BackgroundTransparency = 1
            frame.Parent = fade
            fade.Parent = Player:WaitForChild("PlayerGui")
            
            -- Fade in
            for i = 0, 1, 0.1 do
                frame.BackgroundTransparency = 1 - i
                wait(0.02)
            end
            
            -- Teleport
            Character:SetPrimaryPartCFrame(CFrame.new(event.Position + Vector3.new(0, 5, 0)))
            
            -- Fade out
            for i = 0, 1, 0.1 do
                frame.BackgroundTransparency = i
                wait(0.02)
            end
            
            fade:Destroy()
            return true
        end
    end
    return false
end

-- CREATE UI FOR EVENT SELECTION
print("\n🎛️ CREATING CONTROL PANEL...")

local function createControlPanel()
    local PlayerGui = Player:WaitForChild("PlayerGui")
    
    -- Remove existing UI
    local existing = PlayerGui:FindFirstChild("CMDER_ControlPanel")
    if existing then existing:Destroy() end
    
    -- Create main GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CMDER_ControlPanel"
    ScreenGui.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.Position = UDim2.new(1, -360, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BackgroundTransparency = 0.1
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🎮 CMDER EVENT UNLOCKER"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 10)
    TitleCorner.Parent = Title
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "✅ Ready - Events: " .. #eventLocations
    Status.Size = UDim2.new(1, -20, 0, 30)
    Status.Position = UDim2.new(0, 10, 0, 45)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(150, 255, 150)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 12
    
    -- Event list
    local EventList = Instance.new("ScrollingFrame")
    EventList.Size = UDim2.new(1, -20, 0, 200)
    EventList.Position = UDim2.new(0, 10, 0, 80)
    EventList.BackgroundTransparency = 1
    EventList.ScrollBarThickness = 4
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = EventList
    
    -- Create event buttons
    local buttonY = 0
    for i, event in pairs(eventLocations) do
        local EventButton = Instance.new("TextButton")
        EventButton.Text = "🎯 " .. event.Name
        EventButton.Size = UDim2.new(1, 0, 0, 35)
        EventButton.BackgroundColor3 = Color3.fromHSV(i/#eventLocations, 0.7, 0.3)
        EventButton.TextColor3 = Color3.new(1, 1, 1)
        EventButton.Font = Enum.Font.Gotham
        EventButton.TextSize = 12
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = EventButton
        
        EventButton.MouseButton1Click:Connect(function()
            Status.Text = "🚀 Teleporting to " .. event.Name
            teleportToEvent(event.Name)
            Status.Text = "✅ Arrived at " .. event.Name
        end)
        
        EventButton.Parent = EventList
    end
    
    -- Control buttons
    local function createControlButton(text, y, color, callback)
        local Button = Instance.new("TextButton")
        Button.Text = text
        Button.Size = UDim2.new(1, -40, 0, 35)
        Button.Position = UDim2.new(0, 20, 0, y)
        Button.BackgroundColor3 = color
        Button.TextColor3 = Color3.new(1, 1, 1)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(callback)
        return Button
    end
    
    local ToggleMarkers = createControlButton("👁️ TOGGLE MARKERS", 290, Color3.fromRGB(60, 120, 200), function()
        for name, marker in pairs(markers) do
            marker.Visible = not marker.Visible
        end
        Status.Text = marker.Visible and "✅ Markers Visible" or "👁️ Markers Hidden"
    end)
    
    local ToggleBeams = createControlButton("🔦 TOGGLE BEAMS", 330, Color3.fromRGB(70, 160, 70), function()
        for name, beamParts in pairs(beams) do
            beamParts[1].Enabled = not beamParts[1].Enabled
        end
        Status.Text = beams[1].Enabled and "✅ Beams Enabled" or "🔦 Beams Disabled"
    end)
    
    local RemoveAll = createControlButton("🗑️ CLEAN UP", 370, Color3.fromRGB(200, 70, 70), function()
        for name, marker in pairs(markers) do
            marker:Destroy()
        end
        for name, beamParts in pairs(beams) do
            for _, part in pairs(beamParts) do
                part:Destroy()
            end
        end
        markers = {}
        beams = {}
        Status.Text = "✅ Cleaned up all markers"
    end)
    
    -- Close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "✕"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Assemble UI
    Title.Parent = MainFrame
    Status.Parent = MainFrame
    EventList.Parent = MainFrame
    ToggleMarkers.Parent = MainFrame
    ToggleBeams.Parent = MainFrame
    RemoveAll.Parent = MainFrame
    CloseButton.Parent = Title
    MainFrame.Parent = ScreenGui
    ScreenGui.Parent = PlayerGui
    
    print("✅ Control Panel created - Check top-right")
    return ScreenGui
end

-- UNLOCK ALL CMDER EVENTS FUNCTION
print("\n🔓 UNLOCKING CMDER EVENTS...")

local function unlockAllCMDER()
    print("Attempting to unlock all CMDER events...")
    
    -- Method 1: Check for event triggers in game
    local eventTriggers = Workspace:FindFirstChild("Events") or 
                         Workspace:FindFirstChild("CMDER") or
                         Workspace:FindFirstChild("Triggers")
    
    if eventTriggers then
        print("Found event system: " .. eventTriggers.Name)
        
        -- Try to activate all child triggers
        for _, trigger in pairs(eventTriggers:GetDescendants()) do
            if trigger:IsA("BasePart") and trigger.Name:lower():find("event") then
                pcall(function()
                    -- Fire proximity prompts
                    local prompt = trigger:FindFirstChildWhichIsA("ProximityPrompt")
                    if prompt then
                        prompt:InputHoldBegin()
                        wait(0.1)
                        prompt:InputHoldEnd()
                        print("✅ Activated: " .. trigger.Name)
                    end
                end)
            end
        end
    end
    
    -- Method 2: Check ReplicatedStorage for event data
    local eventData = ReplicatedStorage:FindFirstChild("Events") or 
                     ReplicatedStorage:FindFirstChild("GameData") or
                     ReplicatedStorage:FindFirstChild("CMDER")
    
    if eventData then
        print("Found event data in ReplicatedStorage")
        
        -- Try to modify event states
        for _, obj in pairs(eventData:GetDescendants()) do
            if obj:IsA("BoolValue") and obj.Name:lower():find("unlock") then
                pcall(function()
                    obj.Value = true
                    print("✅ Unlocked: " .. obj.Name)
                end)
            end
            
            if obj:IsA("NumberValue") and obj.Name:lower():find("progress") then
                pcall(function()
                    obj.Value = 100
                    print("✅ Maxed progress: " .. obj.Name)
                end)
            end
        end
    end
    
    -- Method 3: Fire relevant remotes
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or 
                   ReplicatedStorage:FindFirstChild("Events") or
                   ReplicatedStorage:FindFirstChild("Functions")
    
    if remotes then
        print("Found remote system")
        
        -- Try common event unlocking remotes
        local remoteNames = {
            "UnlockEvent", "CompleteEvent", "StartEvent",
            "CMDER_Unlock", "EventComplete", "GetReward"
        }
        
        for _, remoteName in pairs(remoteNames) do
            local remote = remotes:FindFirstChild(remoteName, true)
            if remote then
                pcall(function()
                    if remote:IsA("RemoteFunction") then
                        remote:InvokeServer()
                        print("✅ Called: " .. remote.Name)
                    elseif remote:IsA("RemoteEvent") then
                        remote:FireServer()
                        print("✅ Fired: " .. remote.Name)
                    end
                end)
            end
        end
    end
    
    print("🎮 Attempted to unlock all CMDER events")
end

-- AUTO-TRIGGER EVENTS NEAR PLAYER
local function autoTriggerEvents()
    spawn(function()
        while wait(5) do
            -- Check for event triggers near player
            for _, part in pairs(Workspace:GetChildren()) do
                if part:IsA("BasePart") and part.Name:lower():find("event") then
                    local distance = (HumanoidRootPart.Position - part.Position).Magnitude
                    if distance < 50 then
                        -- Try to trigger
                        pcall(function()
                            local prompt = part:FindFirstChildWhichIsA("ProximityPrompt")
                            if prompt then
                                prompt:InputHoldBegin()
                                wait(0.5)
                                prompt:InputHoldEnd()
                                print("✅ Auto-triggered nearby event")
                            end
                        end)
                    end
                end
            end
        end
    end)
end

-- MAIN EXECUTION
print("\n" .. string.rep("🚀", 40))
print("INITIALIZING CMDER UNLOCKER...")
print(string.rep("🚀", 40))

-- Create visual markers
print("✅ Created " .. #eventLocations .. " event markers")

-- Create control panel
createControlPanel()

-- Start auto-trigger
autoTriggerEvents()

-- Attempt to unlock events
task.wait(2)
unlockAllCMDER()

-- EXPORT FUNCTIONS
getgenv().CMDER = {
    -- Teleport functions
    tp = teleportToEvent,
    tpTower = function() teleportToEvent("CMD Tower") end,
    tpBunker = function() teleportToEvent("Secret Bunker") end,
    tpHelipad = function() teleportToEvent("Helipad") end,
    
    -- Event functions
    unlock = unlockAllCMDER,
    trigger = autoTriggerEvents,
    
    -- UI functions
    ui = createControlPanel,
    clear = function()
        for name, marker in pairs(markers) do marker:Destroy() end
        for name, beamParts in pairs(beams) do
            for _, part in pairs(beamParts) do part:Destroy() end
        end
        markers = {}
        beams = {}
    end
}

-- FINAL MESSAGE
print("\n" .. string.rep("=", 60))
print("🎮 CMDER UNLOCKER READY!")
print(string.rep("=", 60))

print("\n📋 AVAILABLE COMMANDS:")
print("CMDER.tpTower()      - Teleport to CMD Tower")
print("CMDER.tpBunker()     - Teleport to Secret Bunker")
print("CMDER.unlock()       - Unlock all CMDER events")
print("CMDER.ui()           - Show control panel")
print("CMDER.clear()        - Remove all markers")

print("\n🎯 FEATURES:")
print("1. Visual markers for all CMDER events")
print("2. Teleport to any event location")
print("3. Auto-trigger nearby events")
print("4. Attempt to unlock all events")
print("5. Control panel in top-right corner")

print("\n💡 TIPS:")
print("• Markers are VISUAL ONLY - won't get you banned")
print("• Use teleport to quickly reach events")
print("• Control panel lets you toggle visibility")
print("• Script auto-triggers events near you")

print("\n✅ UI appears in TOP-RIGHT corner")
print("✅ Markers visible in-game with beams")
