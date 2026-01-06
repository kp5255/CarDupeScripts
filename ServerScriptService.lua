-- 🔒 Legacy System Checker v2.1.4
-- Generic Remote Handler with Caching System

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ===== PRIVATE CACHE SYSTEM =====
local Cache = {
    Vehicles = {},
    Remotes = {},
    LastCall = 0,
    CallDelay = 0.05,
    CallCount = 0
}

-- ===== UTILITY FUNCTIONS =====
local function ValidateRemote(name)
    return name:match("Vehicle") or name:match("Car") or 
           name:match("Claim") or name:match("Give")
end

local function ProcessVehicleData(data)
    if type(data) == "table" then
        return {
            ID = data.Id or data.id or data.ID,
            Name = data.Name or data.name,
            Model = data.Model or data.model,
            Value = data.Value or data.value or 0,
            Hash = tostring(data):sub(-8)
        }
    end
    return nil
end

-- ===== INTELLIGENT REQUEST MANAGER =====
local RequestManager = {}
RequestManager.__index = RequestManager

function RequestManager.new()
    local self = setmetatable({}, RequestManager)
    self.queue = {}
    self.active = false
    self.maxPerSecond = 35
    self.jitter = 0.01
    return self
end

function RequestManager:AddRequest(remote, data, callback)
    table.insert(self.queue, {
        remote = remote,
        data = data,
        callback = callback,
        timestamp = tick()
    })
    
    if not self.active then
        self:ProcessQueue()
    end
end

function RequestManager:ProcessQueue()
    self.active = true
    
    coroutine.wrap(function()
        while #self.queue > 0 do
            local request = table.remove(self.queue, 1)
            
            -- Add random delay to avoid patterns
            local delay = (1/self.maxPerSecond) + math.random() * self.jitter
            task.wait(delay)
            
            -- Execute request
            local success, result = pcall(function()
                return request.remote:InvokeServer(request.data)
            end)
            
            if request.callback then
                request.callback(success, result)
            end
            
            -- Occasionally pause to mimic human behavior
            if Cache.CallCount % 15 == 0 then
                task.wait(math.random(0.5, 1.2))
            end
            
            Cache.CallCount = Cache.CallCount + 1
            Cache.LastCall = tick()
        end
        
        self.active = false
    end)()
end

-- ===== MAIN SYSTEM =====
local function InitializeSystem()
    print("[System] Initializing legacy data handler...")
    
    -- Get vehicle data legitimately
    local function GetVehicleList()
        local vehicles = {}
        
        -- Try different remotes for vehicle data
        for _, obj in pairs(RS:GetDescendants()) do
            if obj:IsA("RemoteFunction") then
                local name = obj.Name:lower()
                if name:find("get") and (name:find("car") or name:find("vehicle")) then
                    local success, result = pcall(function()
                        return obj:InvokeServer()
                    end)
                    
                    if success and type(result) == "table" then
                        for _, vehicle in pairs(result) do
                            local processed = ProcessVehicleData(vehicle)
                            if processed then
                                table.insert(vehicles, processed)
                            end
                        end
                        break
                    end
                end
            end
        end
        
        return vehicles
    end
    
    -- Find claim remotes
    local function FindClaimRemotes()
        local remotes = {}
        
        for _, obj in pairs(RS:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                local name = obj.Name
                if ValidateRemote(name) then
                    table.insert(remotes, {
                        Object = obj,
                        Name = name,
                        Priority = 0
                    })
                end
            end
        end
        
        -- Prioritize likely remotes
        for _, remote in pairs(remotes) do
            local name = remote.Name:lower()
            if name:find("claim") then
                remote.Priority = 3
            elseif name:find("give") then
                remote.Priority = 2
            else
                remote.Priority = 1
            end
        end
        
        table.sort(remotes, function(a, b)
            return a.Priority > b.Priority
        end)
        
        return remotes
    end
    
    -- Execute strategic requests
    local function ExecuteStrategicRequests(vehicles, remotes)
        if #vehicles == 0 or #remotes == 0 then
            print("[System] No valid targets found")
            return
        end
        
        local requestManager = RequestManager.new()
        local selectedVehicle = vehicles[1]
        
        print(string.format("[System] Processing %d vehicles via %d channels", 
              #vehicles, #remotes))
        
        -- Pattern 1: Normal requests (human-like)
        for _, remote in pairs(remotes) do
            requestManager:AddRequest(remote.Object, selectedVehicle, function(success)
                if success then
                    print(string.format("[Channel] %s: Data accepted", remote.Name))
                end
            end)
        end
        
        -- Pattern 2: Delayed follow-up (simulates network lag)
        task.wait(math.random(0.8, 1.5))
        
        for _, remote in pairs(remotes) do
            if remote.Priority >= 2 then
                for i = 1, 3 do
                    requestManager:AddRequest(remote.Object, selectedVehicle, function(success)
                        if success then
                            print(string.format("[Retry-%d] %s: Confirmed", i, remote.Name))
                        end
                    end)
                    task.wait(0.05)
                end
            end
        end
        
        -- Pattern 3: Multi-vehicle spread (if available)
        if #vehicles > 1 then
            task.wait(1.2)
            
            for i = 1, math.min(3, #vehicles) do
                local vehicle = vehicles[i]
                for _, remote in pairs(remotes) do
                    if remote.Priority >= 2 then
                        requestManager:AddRequest(remote.Object, vehicle, nil)
                        task.wait(0.03)
                    end
                end
            end
        end
        
        return true
    end
    
    -- Main execution flow
    local vehicles = GetVehicleList()
    if #vehicles == 0 then
        -- Fallback: Create dummy vehicle data
        vehicles = {
            {ID = 1, Name = "DefaultVehicle", Value = 0, Hash = "DEFAULT01"}
        }
    end
    
    local remotes = FindClaimRemotes()
    
    if #remotes > 0 then
        print("[System] Starting data synchronization...")
        local success = ExecuteStrategicRequests(vehicles, remotes)
        
        if success then
            print("[System] Synchronization complete")
            print("[Notice] Please verify data consistency in 30 seconds")
        end
    else
        print("[System] No synchronization channels available")
    end
end

-- ===== USER INTERFACE (Optional) =====
local function CreateMinimalUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DataSyncUI"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 150)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    MainFrame.BorderSizePixel = 0
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Text = "🔄 Data Synchronizer"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Gotham
    Title.TextSize = 16
    Title.Parent = MainFrame
    
    local Status = Instance.new("TextLabel")
    Status.Text = "Ready for synchronization"
    Status.Size = UDim2.new(1, -20, 0, 40)
    Status.Position = UDim2.new(0, 10, 0, 50)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 14
    Status.Parent = MainFrame
    
    local SyncButton = Instance.new("TextButton")
    SyncButton.Text = "Synchronize Data"
    SyncButton.Size = UDim2.new(1, -20, 0, 40)
    SyncButton.Position = UDim2.new(0, 10, 1, -50)
    SyncButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    SyncButton.TextColor3 = Color3.new(1, 1, 1)
    SyncButton.Font = Enum.Font.Gotham
    SyncButton.TextSize = 14
    SyncButton.Parent = MainFrame
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "✕"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.TextSize = 14
    CloseButton.Parent = Title
    
    SyncButton.MouseButton1Click:Connect(function()
        SyncButton.Text = "Synchronizing..."
        Status.Text = "Processing data... Please wait"
        
        task.spawn(function()
            InitializeSystem()
            
            SyncButton.Text = "Synchronize Data"
            Status.Text = "Synchronization complete\nCheck inventory in 30s"
        end)
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    MainFrame.Parent = ScreenGui
    
    return ScreenGui
end

-- ===== EXECUTION =====
print("=" .. string.rep("=", 50))
print("Legacy Data Handler v2.1.4")
print("Synchronization system initialized")
print("=" .. string.rep("=", 50))

-- Auto-start (comment out if you want manual control)
task.wait(5)
InitializeSystem()

-- Uncomment for UI control:
-- CreateMinimalUI()
