-- 🎯 MONITOR CAR LOADING SYSTEM
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 MONITORING CAR LOADING SYSTEM")
print("=" .. string.rep("=", 50))

-- ===== MONITOR GUI CHANGES =====
local function monitorGUILoading()
    print("\n👁️ Monitoring MultiCarSelection for car loading...")
    
    local gui = player.PlayerGui:FindFirstChild("MultiCarSelection")
    if not gui then
        print("❌ GUI not found")
        return
    end
    
    -- Watch the ScrollingFrame
    local scrollingFrame = gui:FindFirstChild("ScrollingFrame")
    if scrollingFrame then
        print("🎯 Watching ScrollingFrame for changes...")
        
        -- Monitor when children are added
        scrollingFrame.ChildAdded:Connect(function(child)
            print("➕ Child added to car list: " .. child.Name)
            print("   Class: " .. child.ClassName)
            
            -- Check what was added
            if child:IsA("Frame") then
                print("   📦 Frame added - checking contents...")
                
                -- Look for car data in the frame
                for _, obj in pairs(child:GetDescendants()) do
                    if obj:IsA("TextLabel") and #obj.Text > 2 then
                        print("   🚗 Found text: " .. obj.Text)
                    elseif obj:IsA("ImageLabel") then
                        print("   🖼️ Image: " .. obj.Name)
                    elseif obj:IsA("StringValue") or obj:IsA("IntValue") then
                        local success, value = pcall(function()
                            return obj.Value
                        end)
                        if success then
                            print("   💾 Value: " .. obj.Name .. " = " .. tostring(value))
                        end
                    end
                end
            end
        end)
        
        -- Monitor when children are removed
        scrollingFrame.ChildRemoved:Connect(function(child)
            print("➖ Child removed from car list: " .. child.Name)
        end)
    end
    
    print("\n🎮 NOW: Open your garage/car selection!")
    print("💡 The script will show EXACTLY how cars are loaded")
    
    return gui
end

-- ===== FIND CAR LOADING REMOTES =====
local function findLoadingRemotes()
    print("\n🔍 Looking for car loading remotes...")
    
    local loadingRemotes = {}
    
    -- Search all RemoteEvents
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nameLower = obj.Name:lower()
            
            -- Look for loading/request remotes
            if nameLower:find("get") or nameLower:find("load") or 
               nameLower:find("request") or nameLower:find("fetch") then
                
                table.insert(loadingRemotes, {
                    Object = obj,
                    Name = obj.Name,
                    Path = obj:GetFullName()
                })
            end
        end
    end
    
    print("Found " .. #loadingRemotes .. " loading remotes")
    
    -- Try to request car data
    for _, remote in pairs(loadingRemotes) do
        print("\nTesting: " .. remote.Name)
        
        -- Try different request formats
        local formats = {
            {player},
            {player.UserId},
            {"cars"},
            {"vehicles"},
            {"inventory"},
            {player, "cars"}
        }
        
        for _, data in pairs(formats) do
            local success, result = pcall(function()
                remote.Object:FireServer(unpack(data))
                return "Request sent"
            end)
            
            if success then
                print("✅ " .. remote.Name .. " accepted request")
                break
            end
        end
        
        task.wait(0.1)
    end
    
    return loadingRemotes
end

-- ===== INTERCEPT CAR DATA =====
local function interceptCarData()
    print("\n📡 Intercepting car data transmission...")
    
    local interceptedData = {}
    
    -- Hook RemoteEvents to see what data is sent
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local nameLower = obj.Name:lower()
            
            -- Look for data response remotes
            if nameLower:find("update") or nameLower:find("receive") or 
               nameLower:find("data") or nameLower:find("cars") then
                
                local success, original = pcall(function()
                    return obj.FireServer
                end)
                
                if success then
                    -- Create wrapper to intercept
                    obj.FireServer = function(self, ...)
                        local args = {...}
                        
                        -- Check if this looks like car data
                        if #args > 0 then
                            local firstArg = args[1]
                            
                            if type(firstArg) == "table" then
                                -- Table data - might be car list
                                print("\n🎯 INTERCEPTED CAR DATA from: " .. self.Name)
                                print("   Table with " .. #firstArg .. " items")
                                
                                -- Try to extract car info
                                for i, item in ipairs(firstArg) do
                                    if i <= 5 then  -- Show first 5
                                        if type(item) == "table" then
                                            print("   Item " .. i .. ": TABLE")
                                            for k, v in pairs(item) do
                                                print("     " .. tostring(k) .. ": " .. tostring(v))
                                            end
                                        else
                                            print("   Item " .. i .. ": " .. tostring(item))
                                        end
                                    end
                                }
                                
                                table.insert(interceptedData, {
                                    Remote = self.Name,
                                    Data = firstArg
                                })
                            elseif type(firstArg) == "string" and #firstArg > 50 then
                                -- Long string - might be JSON
                                print("\n🎯 INTERCEPTED STRING DATA from: " .. self.Name)
                                print("   Length: " .. #firstArg .. " chars")
                                print("   Preview: " .. firstArg:sub(1, 100))
                            end
                        end
                        
                        return original(self, ...)
                    end
                    
                    print("✅ Hooked: " .. obj.Name)
                end
            end
        end
    end
    
    print("\n📡 Now opening garage/car menu...")
    print("💡 The script will show what data is sent to load your cars")
    
    return interceptedData
end

-- ===== TRIGGER CAR LOAD =====
local function triggerCarLoad()
    print("\n🎯 Triggering car load sequence...")
    
    -- First, try to find and click garage buttons
    local gui = player.PlayerGui:FindFirstChild("MultiCarSelection")
    if gui then
        -- Look for buttons that might load/show cars
        local loadButtons = {}
        
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                local nameLower = obj.Name:lower()
                if nameLower:find("load") or nameLower:find("show") or 
                   nameLower:find("refresh") or nameLower:find("open") then
                    table.insert(loadButtons, obj)
                end
            end
        end
        
        if #loadButtons > 0 then
            print("Found " .. #loadButtons .. " load buttons")
            
            for _, button in pairs(loadButtons) do
                print("Clicking: " .. button.Name)
                
                -- Try to click
                pcall(function()
                    button:Fire("Activated")
                    button:Fire("MouseButton1Click")
                end)
                
                task.wait(0.5)
            end
        else
            print("No load buttons found")
        end
    end
    
    -- Also try common remotes
    local remotes = findLoadingRemotes()
    
    return #remotes > 0
end

-- ===== CREATE MONITOR UI =====
local function createMonitorUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "CarMonitor"
    gui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main window
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 350, 0, 400)
    main.Position = UDim2.new(0, 10, 0, 10)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    main.Parent = gui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "🎯 CAR LOAD MONITOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = main
    
    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -40)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    -- Status
    local status = Instance.new("TextLabel")
    status.Text = "Monitoring car loading system...\nYour 54 cars are loaded DYNAMICALLY."
    status.Size = UDim2.new(1, -20, 0, 60)
    status.Position = UDim2.new(0, 10, 0, 10)
    status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    status.TextColor3 = Color3.new(1, 1, 1)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextWrapped = true
    status.Parent = content
    
    -- Log display
    local log = Instance.new("ScrollingFrame")
    log.Size = UDim2.new(1, -20, 0, 200)
    log.Position = UDim2.new(0, 10, 0, 80)
    log.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    log.BorderSizePixel = 0
    log.ScrollBarThickness = 6
    log.Parent = content
    
    -- Buttons
    local monitorBtn = Instance.new("TextButton")
    monitorBtn.Text = "👁️ MONITOR GUI"
    monitorBtn.Size = UDim2.new(1, -20, 0, 35)
    monitorBtn.Position = UDim2.new(0, 10, 0, 290)
    monitorBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    monitorBtn.TextColor3 = Color3.new(1, 1, 1)
    monitorBtn.Font = Enum.Font.GothamBold
    monitorBtn.TextSize = 14
    monitorBtn.Parent = content
    
    local interceptBtn = Instance.new("TextButton")
    interceptBtn.Text = "📡 INTERCEPT DATA"
    interceptBtn.Size = UDim2.new(1, -20, 0, 35)
    interceptBtn.Position = UDim2.new(0, 10, 0, 335)
    interceptBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    interceptBtn.TextColor3 = Color3.new(1, 1, 1)
    interceptBtn.Font = Enum.Font.GothamBold
    interceptBtn.TextSize = 14
    interceptBtn.Parent = content
    
    -- Add corners
    local function addCorner(obj)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = obj
    end
    
    addCorner(main)
    addCorner(title)
    addCorner(status)
    addCorner(log)
    addCorner(monitorBtn)
    addCorner(interceptBtn)
    
    -- Log functions
    local logEntries = {}
    
    local function addLog(text, color)
        table.insert(logEntries, {
            Text = text,
            Color = color or Color3.new(1, 1, 1),
            Time = os.time()
        })
        
        -- Keep only last 20 entries
        if #logEntries > 20 then
            table.remove(logEntries, 1)
        end
        
        -- Update display
        log:ClearAllChildren()
        
        local yPos = 5
        for i, entry in ipairs(logEntries) do
            local label = Instance.new("TextLabel")
            label.Text = entry.Text
            label.Size = UDim2.new(1, -10, 0, 20)
            label.Position = UDim2.new(0, 5, 0, yPos)
            label.BackgroundTransparency = 1
            label.TextColor3 = entry.Color
            label.Font = Enum.Font.Code
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextWrapped = true
            label.Parent = log
            
            yPos = yPos + 25
        end
        
        log.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end
    
    -- Button actions
    monitorBtn.MouseButton1Click:Connect(function()
        monitorBtn.Text = "MONITORING..."
        monitorBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Monitoring GUI for car loading..."
        addLog("🎯 Started GUI monitoring", Color3.fromRGB(0, 255, 200))
        
        task.spawn(function()
            monitorGUILoading()
            
            monitorBtn.Text = "👁️ MONITOR GUI"
            monitorBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
        end)
    end)
    
    interceptBtn.MouseButton1Click:Connect(function()
        interceptBtn.Text = "INTERCEPTING..."
        interceptBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        status.Text = "Intercepting network data..."
        addLog("📡 Started data interception", Color3.fromRGB(0, 255, 200))
        
        task.spawn(function()
            interceptCarData()
            
            interceptBtn.Text = "📡 INTERCEPT DATA"
            interceptBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        end)
    end)
    
    -- Initial logs
    addLog("🚗 Car Load Monitor Ready", Color3.fromRGB(0, 255, 150))
    addLog("💡 Open your garage/car menu", Color3.fromRGB(255, 200, 100))
    addLog("👁️ Click MONITOR GUI first", Color3.fromRGB(150, 150, 255))
    
    return gui
end

-- ===== AUTOMATIC START =====
print("\n🚀 Starting monitoring system...")

-- Create UI first
local ui = createMonitorUI()

print("\n✅ Monitor UI Created!")
print("\n💡 HOW THIS WORKS:")
print("1. Click MONITOR GUI - Watch for car frame additions")
print("2. Open your garage/car selection menu IN-GAME")
print("3. The script will show EXACTLY how cars are loaded")
print("4. Click INTERCEPT DATA - See what data is sent")

print("\n🎯 WHAT WE'RE LOOKING FOR:")
print("• When you open garage, what RemoteEvents fire")
print("• What data is sent to load your 54 cars")
print("• The FORMAT of car data (IDs, names, tables, JSON)")

print("\n🔍 Once we see the DATA FORMAT,")
print("we can SEND our own car data!")
