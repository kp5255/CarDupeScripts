-- 🔒 STEALTH TRADE CLICK REPLICATOR
-- Uses metatable hooking - No errors, undetectable

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== STEALTH TRADE REPLICATOR ===")

-- Stealth console output (minimal)
local function StealthPrint(...)
    local args = {...}
    local message = ""
    for i, arg in ipairs(args) do
        message = message .. tostring(arg) .. (i < #args and " " or "")
    end
    print("[Stealth] " .. message)
end

-- Get services with error handling
local tradingService
pcall(function()
    tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes
end)

if not tradingService then
    StealthPrint("Trading service not found")
    return
end

-- ===== STEALTH METATABLE HOOKING =====
local capturedCalls = {}
local originalFunctions = {}

local function HookRemoteStealth(remote)
    if not remote or not remote:IsA("RemoteFunction") then
        return false
    end
    
    -- Store original function
    if not originalFunctions[remote] then
        originalFunctions[remote] = remote.InvokeServer
    end
    
    -- Create stealth hook using metatable
    local success = pcall(function()
        local mt = getrawmetatable(remote)
        if mt then
            local oldIndex = mt.__index
            
            -- Hook __index to intercept InvokeServer
            mt.__index = function(self, key)
                if key == "InvokeServer" then
                    -- Return our custom function
                    return function(_, ...)
                        local args = {...}
                        
                        -- Capture the call
                        table.insert(capturedCalls, {
                            remote = remote.Name,
                            args = args,
                            timestamp = os.time()
                        })
                        
                        -- Log stealthily
                        StealthPrint("Captured:", remote.Name, "Args:", #args)
                        
                        -- Call original with original function
                        return originalFunctions[remote](remote, ...)
                    end
                end
                
                -- Return normal property
                return oldIndex(self, key)
            end
            
            setreadonly(mt, false)
        else
            -- Alternative method: Direct function replacement
            remote.InvokeServer = function(self, ...)
                local args = {...}
                
                -- Capture
                table.insert(capturedCalls, {
                    remote = remote.Name,
                    args = args,
                    timestamp = os.time()
                })
                
                StealthPrint("Direct hook captured:", remote.Name)
                
                -- Call original
                return originalFunctions[remote](self, ...)
            end
        end
    end)
    
    if success then
        StealthPrint("Hooked:", remote.Name)
        return true
    else
        StealthPrint("Failed to hook:", remote.Name)
        return false
    end
end

local function HookAllRemotesStealth()
    StealthPrint("Starting stealth hook...")
    
    local hookedCount = 0
    
    for _, remote in pairs(tradingService:GetChildren()) do
        if remote:IsA("RemoteFunction") then
            if HookRemoteStealth(remote) then
                hookedCount = hookedCount + 1
            end
        end
    end
    
    StealthPrint("Hooked", hookedCount, "remotes")
    return hookedCount
end

-- ===== SAFE REMOTE CALLER =====
local function SafeInvokeRemote(remote, ...)
    local args = {...}
    
    -- Try multiple methods
    local methods = {
        function()
            return remote:InvokeServer(unpack(args))
        end,
        function()
            return remote.InvokeServer(remote, unpack(args))
        end,
        function()
            -- Create new remote instance to avoid detection
            local tempRemote = Instance.new("RemoteFunction")
            tempRemote.Name = remote.Name
            tempRemote.Parent = remote.Parent
            
            -- Copy behavior
            local mt = getrawmetatable(remote)
            if mt then
                setrawmetatable(tempRemote, mt)
            end
            
            local result = tempRemote:InvokeServer(unpack(args))
            tempRemote:Destroy()
            return result
        end
    }
    
    for i, method in ipairs(methods) do
        local success, result = pcall(method)
        if success then
            StealthPrint("Method", i, "successful")
            return result
        end
    end
    
    return nil
end

-- ===== CAR ANALYZER =====
local function FindCarInInventory(carName)
    StealthPrint("Looking for:", carName)
    
    local foundButton = nil
    
    pcall(function()
        local inventory = Player.PlayerGui:WaitForChild("Menu", 5)
                            :WaitForChild("Trading", 5)
                            :WaitForChild("PeerToPeer", 5)
                            :WaitForChild("Main", 5)
                            :WaitForChild("Inventory", 5)
        
        local scrolling = inventory:FindFirstChild("List")
        if scrolling then
            scrolling = scrolling:FindFirstChild("ScrollingFrame")
        end
        
        if scrolling then
            for _, item in pairs(scrolling:GetChildren()) do
                if item.Name == carName or item.Name:find(carName) then
                    foundButton = item
                    break
                end
            end
        end
    end)
    
    return foundButton
end

-- ===== AUTO-CLICK SIMULATOR =====
local function SimulateCarClick(carName)
    StealthPrint("Simulating click for:", carName)
    
    local carButton = FindCarInInventory(carName)
    if not carButton then
        StealthPrint("Car not found in inventory")
        return false
    end
    
    -- Method 1: Check for RemoteEvent on button
    for _, child in pairs(carButton:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            StealthPrint("Found RemoteEvent:", child.Name)
            
            local success = pcall(function()
                child:FireServer("add")
                return true
            end)
            
            if success then
                StealthPrint("RemoteEvent fired successfully")
                return true
            end
        end
    end
    
    -- Method 2: Try to trigger button
    if carButton:IsA("TextButton") or carButton:IsA("ImageButton") then
        StealthPrint("Attempting button activation")
        
        local success = pcall(function()
            -- Try different activation methods
            if carButton:FindFirstChild("Activate") then
                carButton.Activate:Fire()
            end
            
            -- Simulate mouse click
            if carButton.MouseButton1Click then
                carButton.MouseButton1Click:Fire()
            end
            
            -- Try to call remote via button attributes
            local remoteName = carButton:GetAttribute("Remote") 
                              or carButton:GetAttribute("Function")
            
            if remoteName then
                local remote = tradingService:FindFirstChild(remoteName)
                if remote then
                    SafeInvokeRemote(remote, carName)
                end
            end
            
            return true
        end)
        
        if success then
            StealthPrint("Button activated")
            return true
        end
    end
    
    return false
end

-- ===== REPLICATION ENGINE =====
local function ReplicateCapturedBehavior()
    if #capturedCalls == 0 then
        StealthPrint("No calls captured yet")
        return false
    end
    
    StealthPrint("Replicating", #capturedCalls, "captured calls")
    
    for i, call in ipairs(capturedCalls) do
        local remote = tradingService:FindFirstChild(call.remote)
        if remote then
            StealthPrint("Replicating call", i, "to", call.remote)
            
            -- Add random delay to mimic human behavior
            task.wait(math.random(50, 200) / 1000)
            
            -- Replicate with captured args
            local success, result = pcall(function()
                return SafeInvokeRemote(remote, unpack(call.args))
            end)
            
            if success then
                StealthPrint("Replication successful")
            else
                StealthPrint("Replication failed:", result)
            end
        end
    end
    
    return true
end

-- ===== BULK ADD FUNCTION =====
local function BulkAddCars(carName, count)
    StealthPrint("Starting bulk add:", carName, "x", count)
    
    -- First capture one manual click
    StealthPrint("Please click", carName, "in inventory once...")
    local startCount = #capturedCalls
    
    -- Wait for manual click
    for i = 1, 30 do
        task.wait(1)
        if #capturedCalls > startCount then
            StealthPrint("Click captured!")
            break
        end
    end
    
    if #capturedCalls == startCount then
        StealthPrint("No click captured, trying simulation")
        SimulateCarClick(carName)
        task.wait(2)
    end
    
    -- Now replicate many times
    if #capturedCalls > 0 then
        StealthPrint("Starting bulk replication...")
        
        for i = 1, count do
            ReplicateCapturedBehavior()
            
            -- Random delay between actions
            local delay = math.random(100, 400) / 1000
            task.wait(delay)
            
            -- Progress update
            if i % 10 == 0 then
                StealthPrint("Added", i, "out of", count)
            end
        end
        
        StealthPrint("Bulk add complete!")
        return true
    end
    
    return false
end

-- ===== STEALTH UI =====
local function CreateStealthUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeHelper"
    gui.ResetOnSpawn = false
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    -- Minimal frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 280)
    frame.Position = UDim2.new(1, -210, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    frame.BackgroundTransparency = 0.2
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🔄"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.Font = Enum.Font.Gotham
    
    -- Close button (stealth)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "×"
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -25, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    closeBtn.Font = Enum.Font.GothamBold
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Car input
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -20, 0, 30)
    inputFrame.Position = UDim2.new(0, 10, 0, 40)
    inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 6)
    inputCorner.Parent = inputFrame
    
    local carInput = Instance.new("TextBox")
    carInput.PlaceholderText = "Car name..."
    carInput.Size = UDim2.new(1, -10, 1, 0)
    carInput.Position = UDim2.new(0, 5, 0, 0)
    carInput.BackgroundTransparency = 1
    carInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    carInput.Text = "Car-AstonMartin12"
    carInput.Font = Enum.Font.Gotham
    carInput.TextSize = 12
    
    -- Buttons
    local function CreateButton(text, yPos, color, callback)
        local btn = Instance.new("TextButton")
        btn.Text = text
        btn.Size = UDim2.new(1, -20, 0, 35)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local hookBtn = CreateButton("⚡ Hook Remotes", 80, Color3.fromRGB(60, 100, 180), function()
        HookAllRemotesStealth()
        hookBtn.Text = "✅ Hooked"
    end)
    
    local captureBtn = CreateButton("🎯 Capture Click", 125, Color3.fromRGB(70, 140, 100), function()
        captureBtn.Text = "👀 Watching..."
        StealthPrint("Waiting for click...")
        task.wait(1)
        captureBtn.Text = "🎯 Capture Click"
    end)
    
    local replicateBtn = CreateButton("🔄 Replicate", 170, Color3.fromRGB(100, 100, 200), function()
        replicateBtn.Text = "🔄 Replicating..."
        ReplicateCapturedBehavior()
        task.wait(1)
        replicateBtn.Text = "🔄 Replicate"
    end)
    
    local bulkBtn = CreateButton("📦 Bulk Add (10)", 215, Color3.fromRGB(180, 100, 60), function()
        bulkBtn.Text = "📦 Adding..."
        BulkAddCars(carInput.Text, 10)
        task.wait(1)
        bulkBtn.Text = "📦 Bulk Add (10)"
    end)
    
    local status = Instance.new("TextLabel")
    status.Text = "Ready"
    status.Size = UDim2.new(1, -20, 0, 40)
    status.Position = UDim2.new(0, 10, 1, -50)
    status.BackgroundTransparency = 1
    status.TextColor3 = Color3.fromRGB(150, 200, 150)
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.TextWrapped = true
    
    -- Parent everything
    title.Parent = frame
    closeBtn.Parent = frame
    inputFrame.Parent = frame
    carInput.Parent = inputFrame
    hookBtn.Parent = frame
    captureBtn.Parent = frame
    replicateBtn.Parent = frame
    bulkBtn.Parent = frame
    status.Parent = frame
    frame.Parent = gui
    
    -- Update status
    game:GetService("RunService").Heartbeat:Connect(function()
        status.Text = "Calls: " .. #capturedCalls
    end)
    
    return gui
end

-- ===== AUTO-START =====
task.wait(2)

-- Create UI
CreateStealthUI()

-- Auto-hook after delay
task.wait(3)
HookAllRemotesStealth()

StealthPrint("System ready")
StealthPrint("Use the floating UI to control")
