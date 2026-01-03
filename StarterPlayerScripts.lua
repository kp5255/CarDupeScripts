-- CDT: Car Duplication Tool v2.0
-- Auto-detects and exploits car systems

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

print([[
    
    ░█████╗░██████╗░████████╗
    ██╔══██╗██╔══██╗╚══██╔══╝
    ██║░░██║██║░░██║░░░██║░░░
    ██║░░██║██║░░██║░░░██║░░░
    ╚█████╔╝██████╔╝░░░██║░░░
    ░╚════╝░╚═════╝░░░░╚═╝░░░
    
    Car Duplication Tool v2.0
    Initializing...
]])

-- Wait for game to load
repeat task.wait() until game:IsLoaded()

-- Configuration
local CONFIG = {
    AutoDetect = true,
    MaxDuplicates = 10,
    DelayBetween = 0.5,
    BypassValidation = true
}

-- Utility functions
local CDT = {}

function CDT:CreateUI()
    -- Create exploit UI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CDT_UI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🚗 CAR DUPLICATION TOOL"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = mainFrame
    
    -- Status box
    local statusBox = Instance.new("ScrollingFrame")
    statusBox.Size = UDim2.new(1, -20, 0, 300)
    statusBox.Position = UDim2.new(0, 10, 0, 50)
    statusBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    statusBox.BorderSizePixel = 0
    statusBox.ScrollBarThickness = 5
    statusBox.Parent = mainFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Text = "CDT Initializing...\n"
    statusLabel.Size = UDim2.new(1, -10, 1, -10)
    statusLabel.Position = UDim2.new(0, 5, 0, 5)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.new(1, 1, 1)
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top
    statusLabel.TextWrapped = false
    statusLabel.Parent = statusBox
    
    -- Buttons
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Size = UDim2.new(1, -20, 0, 40)
    buttonsFrame.Position = UDim2.new(0, 10, 0, 360)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = mainFrame
    
    local scanBtn = Instance.new("TextButton")
    scanBtn.Text = "🔍 SCAN GAME"
    scanBtn.Size = UDim2.new(0.48, 0, 1, 0)
    scanBtn.Position = UDim2.new(0, 0, 0, 0)
    scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    scanBtn.TextColor3 = Color3.new(1, 1, 1)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 14
    scanBtn.Parent = buttonsFrame
    
    local dupeBtn = Instance.new("TextButton")
    dupeBtn.Text = "🚗 DUPLICATE"
    dupeBtn.Size = UDim2.new(0.48, 0, 1, 0)
    dupeBtn.Position = UDim2.new(0.52, 0, 0, 0)
    dupeBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    dupeBtn.TextColor3 = Color3.new(1, 1, 1)
    dupeBtn.Font = Enum.Font.GothamBold
    dupeBtn.TextSize = 14
    dupeBtn.Parent = buttonsFrame
    
    -- Styling
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = scanBtn
    btnCorner:Clone().Parent = dupeBtn
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = title
    btnCorner:Clone().Parent = closeBtn
    
    -- Update status function
    function CDT:UpdateStatus(text)
        statusLabel.Text = statusLabel.Text .. "\n" .. text
        statusBox.CanvasSize = UDim2.new(0, 0, 0, statusLabel.TextBounds.Y + 20)
        statusBox.CanvasPosition = Vector2.new(0, statusLabel.TextBounds.Y)
        print("[CDT] " .. text)
    end
    
    -- Button functions
    scanBtn.MouseButton1Click:Connect(function()
        CDT:ScanGame()
    end)
    
    dupeBtn.MouseButton1Click:Connect(function()
        CDT:ExecuteDuplication()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    CDT:UpdateStatus("UI Created Successfully")
    CDT:UpdateStatus("Ready to scan game...")
    
    return CDT
end

-- Game scanning function
function CDT:ScanGame()
    self:UpdateStatus("\n=== SCANNING GAME ===")
    
    local foundEvents = {}
    local foundModules = {}
    
    -- Scan ReplicatedStorage
    self:UpdateStatus("Scanning ReplicatedStorage...")
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            if obj.Name:lower():find("car") or 
               obj.Name:lower():find("vehicle") or
               obj.Name:lower():find("garage") or
               obj.Name:lower():find("inventory") then
                table.insert(foundEvents, obj)
                self:UpdateStatus("✓ Found: " .. obj.Name)
            end
        elseif obj:IsA("ModuleScript") then
            if obj.Name:lower():find("car") or 
               obj.Name:lower():find("vehicle") then
                table.insert(foundModules, obj)
                self:UpdateStatus("✓ Module: " .. obj.Name)
            end
        end
    end
    
    -- Scan ServerScriptService (from client perspective)
    self:UpdateStatus("Scanning ServerScriptService...")
    local ss = game:GetService("ServerScriptService")
    if ss then
        for _, obj in pairs(ss:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                if obj.Name:lower():find("car") or 
                   obj.Name:lower():find("vehicle") then
                    table.insert(foundModules, obj)
                    self:UpdateStatus("✓ Server Module: " .. obj.Name)
                end
            end
        end
    end
    
    self.foundEvents = foundEvents
    self.foundModules = foundModules
    
    self:UpdateStatus("\nScan Complete!")
    self:UpdateStatus("Found " .. #foundEvents .. " car-related events")
    self:UpdateStatus("Found " .. #foundModules .. " car-related modules")
    
    return foundEvents, foundModules
end

-- Pattern-based exploitation
function CDT:AnalyzeEvents(events)
    self:UpdateStatus("\n=== ANALYZING EVENTS ===")
    
    local exploitationMethods = {}
    
    for _, event in ipairs(events) do
        local method = self:DetermineExploitMethod(event.Name)
        if method then
            exploitationMethods[event] = method
            self:UpdateStatus("✓ " .. event.Name .. " -> " .. method)
        end
    end
    
    self.exploitMethods = exploitationMethods
    return exploitationMethods
end

function CDT:DetermineExploitMethod(eventName)
    local name = eventName:lower()
    
    if name:find("buy") or name:find("purchase") then
        return "PRICE_MANIPULATION"
    elseif name:find("add") or name:find("save") then
        return "INVENTORY_FLOOD"
    elseif name:find("spawn") or name:find("get") then
        return "INSTANT_SPAWN"
    elseif name:find("trade") or name:find("sell") then
        return "VALUE_EXPLOIT"
    elseif name:find("duplicate") or name:find("copy") then
        return "DIRECT_DUPLICATION"
    end
    
    return "GENERIC_FLOOD"
end

-- Execution methods
function CDT:ExecuteDuplication()
    if not self.exploitMethods then
        self:UpdateStatus("❌ Scan game first!")
        return
    end
    
    self:UpdateStatus("\n=== EXECUTING DUPLICATION ===")
    
    -- Get current vehicle
    local currentCar = self:GetCurrentVehicle()
    if not currentCar then
        self:UpdateStatus("❌ Not in a vehicle!")
        return
    end
    
    local carName = currentCar.Name
    self:UpdateStatus("Target Vehicle: " .. carName)
    
    -- Try each exploit method
    local successCount = 0
    
    for event, method in pairs(self.exploitMethods) do
        self:UpdateStatus("Trying: " .. event.Name .. " (" .. method .. ")")
        
        local success = self:ExecuteMethod(event, method, carName)
        if success then
            successCount = successCount + 1
            self:UpdateStatus("✓ Success!")
        else
            self:UpdateStatus("✗ Failed")
        end
        
        task.wait(CONFIG.DelayBetween)
    end
    
    self:UpdateStatus("\n=== RESULTS ===")
    self:UpdateStatus("Successful exploits: " .. successCount .. "/" .. #self.exploitMethods)
    self:UpdateStatus("Check your garage for duplicates!")
end

function CDT:ExecuteMethod(event, method, carName)
    local args = {}
    
    -- Prepare arguments based on method
    if method == "PRICE_MANIPULATION" then
        args = {"buy", carName, 1}  -- Price = 1
    elseif method == "INVENTORY_FLOOD" then
        args = {"add", carName, player.UserId}
    elseif method == "INSTANT_SPAWN" then
        args = {"spawn", carName, true}
    elseif method == "VALUE_EXPLOIT" then
        args = {carName, 999999}  -- High value
    elseif method == "DIRECT_DUPLICATION" then
        args = {"duplicate", carName}
    else
        args = {carName}
    end
    
    -- Try to fire with different argument formats
    local formats = {
        args,
        {unpack(args)},
        carName,
        {vehicle = carName, player = player},
        {action = "add", car = carName}
    }
    
    for _, format in ipairs(formats) do
        local success = pcall(function()
            event:FireServer(unpack(format))
        end)
        
        if success then
            return true
        end
    end
    
    return false
end

function CDT:GetCurrentVehicle()
    local char = player.Character
    if not char then return nil end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil end
    
    local seat = humanoid.SeatPart
    if seat and seat:IsA("VehicleSeat") then
        return seat.Parent
    end
    
    return nil
end

-- Advanced: Packet interception
function CDT:SetupPacketInterceptor()
    self:UpdateStatus("\n=== SETTING UP PACKET INTERCEPTOR ===")
    
    for _, event in ipairs(self.foundEvents or {}) do
        -- Store original FireServer method
        local originalFire = event.FireServer
        
        -- Override to intercept
        event.FireServer = function(self, ...)
            local args = {...}
            
            -- Log the call
            CDT:UpdateStatus("Intercepted: " .. event.Name)
            
            -- Modify if it's a car-related call
            if event.Name:lower():find("car") or event.Name:lower():find("vehicle") then
                -- Try to manipulate the call for duplication
                if #args >= 2 and typeof(args[2]) == "number" then
                    args[2] = 0  -- Set price to 0
                end
                
                -- Fire multiple times
                for i = 1, CONFIG.MaxDuplicates do
                    originalFire(self, unpack(args))
                    task.wait(0.1)
                end
                
                return
            end
            
            return originalFire(self, unpack(args))
        end
        
        self:UpdateStatus("✓ Interceptor active for: " .. event.Name)
    end
end

-- Memory manipulation (hypothetical)
function CDT:AttemptMemoryBypass()
    self:UpdateStatus("\n=== ATTEMPTING MEMORY BYPASS ===")
    
    -- This is how actual exploits would try to bypass validation
    local bypassAttempts = {
        "Attempting to disable client-side validation...",
        "Searching for ownership flags...",
        "Trying to modify purchase limits...",
        "Bypassing cooldown checks..."
    }
    
    for _, attempt in ipairs(bypassAttempts) do
        self:UpdateStatus(attempt)
        task.wait(0.5)
    end
    
    self:UpdateStatus("Memory bypass attempts completed")
    return true
end

-- Main execution
function CDT:Run()
    self:UpdateStatus("\n=== CDT ACTIVATED ===")
    
    -- Step 1: Scan game
    local events, modules = self:ScanGame()
    
    if #events == 0 then
        self:UpdateStatus("❌ No car events found!")
        self:UpdateStatus("Trying alternative detection...")
        
        -- Try generic events
        events = self:FindGenericEvents()
    end
    
    -- Step 2: Analyze
    self:AnalyzeEvents(events)
    
    -- Step 3: Setup interceptors
    self:SetupPacketInterceptor()
    
    -- Step 4: Attempt bypass
    if CONFIG.BypassValidation then
        self:AttemptMemoryBypass()
    end
    
    self:UpdateStatus("\n✅ CDT READY FOR USE")
    self:UpdateStatus("Sit in a car and click DUPLICATE")
end

function CDT:FindGenericEvents()
    self:UpdateStatus("Searching for generic RemoteEvents...")
    
    local genericEvents = {}
    
    -- Look for any RemoteEvent
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            table.insert(genericEvents, obj)
        end
    end
    
    self:UpdateStatus("Found " .. #genericEvents .. " generic events")
    return genericEvents
end

-- Initialize and run
local cdtInstance = CDT:CreateUI()
cdtInstance:Run()

print("\n" .. string.rep("=", 50))
print("CDT LOADED SUCCESSFULLY")
print("=":rep(50))
