-- Server-Side Trade Data Manipulation
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

wait(2)

print("=== SERVER-SIDE TRADE DUPLICATOR ===")
print("Goal: Make duplicates visible to BOTH players")

-- Track the actual trade data being sent to server
local originalRemoteEvents = {}
local tradeDataCache = {}
local isInTrade = false

-- Find ALL remote events/functions
local function FindAllRemotes()
    print("\n🔍 FINDING ALL REMOTE EVENTS...")
    
    local remotes = {}
    
    -- Search ReplicatedStorage
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            table.insert(remotes, remote)
        end
    end
    
    -- Search other important places
    local places = {
        game:GetService("ReplicatedFirst"),
        game:GetService("ServerScriptService"),
        game:GetService("ServerStorage"),
        Player.PlayerGui
    }
    
    for _, place in pairs(places) do
        pcall(function()
            for _, remote in pairs(place:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    table.insert(remotes, remote)
                end
            end
        end)
    end
    
    print("📊 Found " .. #remotes .. " remote events/functions")
    return remotes
end

-- Hook into remote events to intercept trade data
local function HookTradeRemotes()
    print("\n🎣 HOOKING INTO REMOTE EVENTS...")
    
    local remotes = FindAllRemotes()
    local tradeRemotes = {}
    
    for _, remote in pairs(remotes) do
        -- Save original function
        if remote:IsA("RemoteEvent") then
            originalRemoteEvents[remote] = remote.FireServer
            
            -- Hook FireServer
            remote.FireServer = function(self, ...)
                local args = {...}
                
                -- Check if this is trade-related data
                local isTradeData = CheckIfTradeData(args)
                
                if isTradeData then
                    print("\n🎯 INTERCEPTED TRADE DATA!")
                    print("Remote: " .. remote.Name)
                    
                    -- Store the data
                    table.insert(tradeDataCache, {
                        remote = remote,
                        args = args,
                        timestamp = os.time()
                    })
                    
                    -- Try to modify for duplication
                    local modifiedArgs = InjectDuplicateData(args)
                    
                    -- Call original with modified data
                    return originalRemoteEvents[remote](self, unpack(modifiedArgs))
                end
                
                -- Normal call for non-trade data
                return originalRemoteEvents[remote](self, ...)
            end
            
            table.insert(tradeRemotes, remote)
            print("✅ Hooked: " .. remote.Name)
        end
    end
    
    return tradeRemotes
end

-- Check if data is trade-related
local function CheckIfTradeData(args)
    for _, arg in pairs(args) do
        if type(arg) == "string" then
            local lowerArg = arg:lower()
            if lowerArg:find("trade") 
               or lowerArg:find("offer") 
               or lowerArg:find("item") 
               or lowerArg:find("car")
               or lowerArg:find("vehicle") then
                return true
            end
        elseif type(arg) == "table" then
            -- Check table contents
            for k, v in pairs(arg) do
                if type(k) == "string" and (k:lower():find("item") or k:lower():find("trade")) then
                    return true
                end
            end
        end
    end
    return false
end

-- Inject duplicate data into trade arguments
local function InjectDuplicateData(args)
    print("📦 INJECTING DUPLICATE DATA...")
    
    local modifiedArgs = {}
    
    for i, arg in pairs(args) do
        if type(arg) == "table" then
            -- Try to duplicate items in the table
            local newTable = DuplicateItemsInTable(arg)
            modifiedArgs[i] = newTable
            
            print("✅ Modified table at position " .. i)
            print("Original item count: " .. CountItems(arg))
            print("New item count: " .. CountItems(newTable))
            
        elseif type(arg) == "string" and (arg:lower():find("car") or arg:lower():find("vehicle")) then
            -- Duplicate string item
            modifiedArgs[i] = arg .. "_DUPLICATE"
            print("✅ Duplicated string: " .. arg)
            
        else
            modifiedArgs[i] = arg
        end
    end
    
    return modifiedArgs
end

-- Duplicate items in a table
local function DuplicateItemsInTable(tbl)
    local newTable = {}
    
    for k, v in pairs(tbl) do
        newTable[k] = v
        
        -- If value is a table (nested items), duplicate those too
        if type(v) == "table" then
            newTable[k] = DuplicateItemsInTable(v)
        end
        
        -- If key indicates an item, add a duplicate
        if type(k) == "string" and (k:lower():find("item") or k:lower():find("car")) then
            local duplicateKey = k .. "_DUPLICATE"
            newTable[duplicateKey] = v
            print("   Added duplicate for: " .. k)
        end
    end
    
    -- Add extra duplicate entries
    if #newTable > 0 then
        for i = 1, 3 do  -- Add 3 extra duplicates
            local duplicateEntry = {}
            for k, v in pairs(tbl) do
                if type(k) == "string" then
                    duplicateEntry[k .. "_COPY" .. i] = v
                end
            end
            table.insert(newTable, duplicateEntry)
        end
    end
    
    return newTable
end

-- Count items in table
local function CountItems(tbl)
    local count = 0
    if type(tbl) ~= "table" then return 0 end
    
    for k, v in pairs(tbl) do
        count = count + 1
    end
    
    return count
end

-- Monitor the actual trade UI for changes
local function MonitorTradeUI()
    print("\n👀 MONITORING TRADE UI...")
    
    local lastItemCount = 0
    
    while true do
        task.wait(1)
        
        if not Player.PlayerGui then continue end
        
        local tradeContainer = GetTradeContainer()
        if tradeContainer then
            local currentItems = {}
            
            -- Count all items in trade
            for _, item in pairs(tradeContainer:GetChildren()) do
                if item:IsA("TextButton") or item:IsA("ImageButton") then
                    table.insert(currentItems, item)
                end
            end
            
            if #currentItems ~= lastItemCount then
                print("📊 UI Item count changed: " .. lastItemCount .. " -> " .. #currentItems)
                lastItemCount = #currentItems
                
                -- List all items
                for _, item in pairs(currentItems) do
                    local text = item:IsA("TextButton") and item.Text or item.Name
                    print("   - " .. text)
                end
            end
        end
    end
end

-- Get trade container
local function GetTradeContainer()
    if not Player.PlayerGui then return nil end
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then return nil end
    local trading = menu:FindFirstChild("Trading")
    if not trading then return nil end
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then return nil end
    local main = peerToPeer:FindFirstChild("Main")
    if not main then return nil end
    local localPlayer = main:FindFirstChild("LocalPlayer")
    if not localPlayer then return nil end
    local content = localPlayer:FindFirstChild("Content")
    if not content then return nil end
    return content:FindFirstChild("ScrollingFrame")
end

-- Simulate adding items multiple times
local function SpamAddToTrade()
    print("\n⚡ SPAMMING ADD TO TRADE...")
    
    local container = GetTradeContainer()
    if not container then return 0 end
    
    local addedCount = 0
    
    -- Find all car items
    local carButtons = {}
    for _, item in pairs(container:GetChildren()) do
        if item:IsA("TextButton") or item:IsA("ImageButton") then
            local text = item:IsA("TextButton") and item.Text or item.Name
            if text:lower():find("car") or item.Name:lower():find("car") then
                table.insert(carButtons, item)
            end
        end
    end
    
    if #carButtons == 0 then
        print("❌ No car buttons found")
        return 0
    end
    
    print("Found " .. #carButtons .. " car buttons")
    
    -- Try to add each car multiple times
    for _, button in pairs(carButtons) do
        for i = 1, 5 do  -- Try 5 times per button
            print("Attempt " .. i .. " for: " .. button.Name)
            
            -- Try different methods
            local success = pcall(function()
                -- Method 1: Direct click simulation
                button:Fire("MouseButton1Click")
                
                -- Method 2: Activated event
                button:Fire("Activated")
                
                -- Method 3: Try to find and fire remote
                if button:FindFirstChild("RemoteClick") then
                    button.RemoteClick:FireServer()
                end
                
                addedCount = addedCount + 1
                return true
            end)
            
            if success then
                print("✅ Success!")
            else
                print("❌ Failed")
            end
            
            task.wait(0.2)  -- Small delay
        end
    end
    
    print("📊 Total spam attempts: " .. addedCount)
    return addedCount
end

-- Main function to execute the exploit
local function ExecuteServerSideDuplication()
    print("\n🚀 EXECUTING SERVER-SIDE DUPLICATION...")
    
    -- Step 1: Hook into remote events
    local hookedRemotes = HookTradeRemotes()
    if #hookedRemotes == 0 then
        print("❌ Failed to hook any remotes")
        return false
    end
    
    print("✅ Hooked " .. #hookedRemotes .. " remote events")
    
    -- Step 2: Start monitoring
    spawn(MonitorTradeUI)
    
    -- Step 3: Try to spam add items
    task.wait(2)
    SpamAddToTrade()
    
    -- Step 4: Create a fake trade confirmation
    task.wait(2)
    SimulateTradeConfirmation()
    
    return true
end

-- Simulate trade confirmation with modified data
local function SimulateTradeConfirmation()
    print("\n🤝 SIMULATING TRADE CONFIRMATION...")
    
    -- Look for confirm/accept button
    local confirmButton = FindConfirmButton()
    
    if confirmButton then
        print("✅ Found confirm button: " .. confirmButton.Name)
        
        -- Create fake trade data
        local fakeTradeData = {
            player1 = Player.Name,
            player2 = "OtherPlayer",  -- This should be detected
            items = {
                {name = "Car_Original", type = "vehicle", value = 1000},
                {name = "Car_Duplicate_1", type = "vehicle", value = 1000},
                {name = "Car_Duplicate_2", type = "vehicle", value = 1000},
                {name = "Car_Duplicate_3", type = "vehicle", value = 1000}
            },
            timestamp = os.time(),
            tradeId = math.random(100000, 999999)
        }
        
        print("📦 Sending fake trade data with " .. #fakeTradeData.items .. " items")
        
        -- Try to send this through hooked remotes
        for remoteName, originalFunc in pairs(originalRemoteEvents) do
            pcall(function()
                remoteName:FireServer("TradeConfirm", fakeTradeData)
                print("✅ Sent fake data via: " .. remoteName.Name)
            end)
        end
        
        -- Also try to click the actual button
        task.wait(0.5)
        confirmButton:Fire("MouseButton1Click")
        
    else
        print("❌ No confirm button found")
    end
end

-- Find confirm button
local function FindConfirmButton()
    if not Player.PlayerGui then return nil end
    
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then return nil end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then return nil end
    
    -- Search for confirm buttons
    for _, obj in pairs(trading:GetDescendants()) do
        if obj:IsA("TextButton") then
            local text = obj.Text:lower()
            if text:find("confirm") or text:find("accept") or text:find("trade") then
                return obj
            end
        end
    end
    
    return nil
end

-- Create UI
local function CreateServerSideUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 350)
    frame.Position = UDim2.new(0.5, -250, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(20, 30, 40)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "SERVER-SIDE DUPLICATION"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(30, 50, 70)
    title.TextColor3 = Color3.fromRGB(100, 200, 255)
    title.Font = Enum.Font.GothamBold
    
    local log = Instance.new("ScrollingFrame")
    log.Size = UDim2.new(1, -20, 0, 200)
    log.Position = UDim2.new(0, 10, 0, 50)
    log.BackgroundColor3 = Color3.fromRGB(10, 20, 30)
    log.ScrollBarThickness = 8
    
    local logText = Instance.new("TextLabel")
    logText.Size = UDim2.new(1, 0, 10, 0)  -- Large height to allow scrolling
    logText.Position = UDim2.new(0, 5, 0, 5)
    logText.BackgroundTransparency = 1
    logText.TextColor3 = Color3.fromRGB(200, 230, 255)
    logText.TextWrapped = true
    logText.TextXAlignment = Enum.TextXAlignment.Left
    logText.TextYAlignment = Enum.TextYAlignment.Top
    logText.Font = Enum.Font.Code
    logText.TextSize = 12
    logText.Text = "Server-side duplicator loaded...\n"
    
    logText.Parent = log
    
    -- Buttons
    local buttons = {
        {text = "🎣 HOOK REMOTES", func = HookTradeRemotes, pos = UDim2.new(0.025, 0, 0, 260)},
        {text = "⚡ SPAM ADD", func = SpamAddToTrade, pos = UDim2.new(0.025, 0, 0, 300)},
        {text = "🚀 FULL EXPLOIT", func = ExecuteServerSideDuplication, pos = UDim2.new(0.525, 0, 0, 260)},
        {text = "🤝 FAKE CONFIRM", func = SimulateTradeConfirmation, pos = UDim2.new(0.525, 0, 0, 300)}
    }
    
    for _, btnInfo in pairs(buttons) do
        local btn = Instance.new("TextButton")
        btn.Text = btnInfo.text
        btn.Size = UDim2.new(0.45, 0, 0, 35)
        btn.Position = btnInfo.pos
        btn.BackgroundColor3 = Color3.fromRGB(40, 80, 120)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        btn.MouseButton1Click:Connect(function()
            logText.Text = "Executing: " .. btnInfo.text .. "...\n" .. logText.Text
            spawn(btnInfo.func)
        end)
        
        btn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    log.Parent = frame
    frame.Parent = gui
    
    -- Hook print to UI
    local originalPrint = print
    print = function(...)
        local args = {...}
        local message = table.concat(args, " ")
        originalPrint(message)
        logText.Text = "> " .. message .. "\n" .. logText.Text
    end
    
    return logText
end

-- Initialize
CreateServerSideUI()

-- Auto-start
task.wait(3)
print("\n=== SERVER-SIDE DUPLICATOR READY ===")
print("This modifies data sent to SERVER")
print("Both players should see duplicates!")

-- Start monitoring
spawn(function()
    task.wait(5)
    print("\n🔍 Starting auto-scan for remotes...")
    HookTradeRemotes()
end)

-- Keybinds
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        print("\n🎮 F KEY - FULL EXPLOIT")
        ExecuteServerSideDuplication()
    elseif input.KeyCode == Enum.KeyCode.H then
        print("\n🎮 H KEY - HOOK REMOTES")
        HookTradeRemotes()
    end
end)

print("\n🔑 CONTROLS:")
print("F = Full server-side exploit")
print("H = Hook remote events only")
print("\n⚠️  This modifies SERVER-BOUND data")
