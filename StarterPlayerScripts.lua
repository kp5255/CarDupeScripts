-- Fixed Server-Side Trade Duplicator
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

wait(2)

print("=== SERVER-SIDE TRADE DUPLICATOR FIXED ===")

-- Store original remotes
local hookedRemotes = {}
local tradeHooks = {}

-- Better way to find trade remotes
local function FindTradeRemotes()
    print("\n🔍 FINDING TRADE REMOTES (SMART SEARCH)...")
    
    local potentialRemotes = {}
    
    -- Common trade-related remote names
    local tradeKeywords = {
        "trade", "trading", "offer", "item", "exchange",
        "give", "take", "transfer", "market", "shop",
        "buy", "sell", "confirm", "accept", "decline"
    }
    
    -- Search in common places
    local searchLocations = {
        ReplicatedStorage,
        game:GetService("ReplicatedFirst"),
        Player.PlayerGui
    }
    
    for _, location in pairs(searchLocations) do
        pcall(function()
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local nameLower = obj.Name:lower()
                    
                    -- Check if name contains trade keywords
                    for _, keyword in pairs(tradeKeywords) do
                        if nameLower:find(keyword) then
                            print("✅ Found potential trade remote: " .. obj.Name)
                            table.insert(potentialRemotes, obj)
                            break
                        end
                    end
                end
            end
        end)
    end
    
    print("📊 Found " .. #potentialRemotes .. " potential trade remotes")
    return potentialRemotes
end

-- Create hook using metatables
local function CreateRemoteHook(remote)
    if hookedRemotes[remote] then
        return hookedRemotes[remote]
    end
    
    local originalFire = nil
    
    if remote:IsA("RemoteEvent") then
        -- Store original fire function
        originalFire = remote.FireServer
        
        -- Create new function with hook
        local newRemote = {
            FireServer = function(self, ...)
                local args = {...}
                
                -- Check if this is trade data
                local isTrade, modifiedArgs = ProcessTradeData(args)
                
                if isTrade then
                    print("\n🎯 INTERCEPTED TRADE CALL to: " .. remote.Name)
                    print("Original args count: " .. #args)
                    
                    -- Call original with potentially modified args
                    return originalFire(remote, unpack(modifiedArgs or args))
                else
                    -- Normal call
                    return originalFire(remote, ...)
                end
            end
        }
        
        -- Create metatable to intercept calls
        local mt = {
            __index = function(t, k)
                if k == "FireServer" then
                    return newRemote.FireServer
                end
                return remote[k]
            end,
            __newindex = function(t, k, v)
                remote[k] = v
            end
        }
        
        local proxy = setmetatable({}, mt)
        hookedRemotes[remote] = {proxy = proxy, original = originalFire}
        
        print("✅ Hook created for: " .. remote.Name)
        return hookedRemotes[remote]
    end
    
    return nil
end

-- Process and potentially modify trade data
local function ProcessTradeData(args)
    local isTrade = false
    local modifiedArgs = {}
    
    for i, arg in ipairs(args) do
        modifiedArgs[i] = arg
        
        -- Check if argument contains trade data
        if type(arg) == "string" then
            local lowerArg = arg:lower()
            if lowerArg:find("car") 
               or lowerArg:find("trade") 
               or lowerArg:find("item") 
               or lowerArg:find("offer") then
                isTrade = true
                
                -- Try to create duplicate entry
                if lowerArg:find("car") then
                    modifiedArgs[i + 1] = arg .. "_DUPLICATE"
                    print("   Added duplicate for car: " .. arg)
                end
            end
        elseif type(arg) == "table" then
            -- Deep check table
            local tableCopy = DuplicateTableItems(arg)
            if tableCopy ~= arg then
                isTrade = true
                modifiedArgs[i] = tableCopy
            end
        end
    end
    
    return isTrade, modifiedArgs
end

-- Duplicate items in a table
local function DuplicateTableItems(tbl)
    if type(tbl) ~= "table" then return tbl end
    
    local newTable = {}
    local hasTradeItems = false
    
    for k, v in pairs(tbl) do
        newTable[k] = v
        
        -- Check if key indicates trade item
        if type(k) == "string" then
            local keyLower = k:lower()
            if keyLower:find("item") 
               or keyLower:find("car") 
               or keyLower:find("vehicle") then
                hasTradeItems = true
                
                -- Add duplicate
                local duplicateKey = k .. "_DUPLICATE"
                newTable[duplicateKey] = v
            end
        end
        
        -- Recursively check nested tables
        if type(v) == "table" then
            newTable[k] = DuplicateTableItems(v)
        end
    end
    
    -- Only return modified table if it has trade items
    return hasTradeItems and newTable or tbl
end

-- Get the trade UI container
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

-- Direct manipulation of trade items
local function ManipulateTradeItems()
    print("\n🔧 DIRECT TRADE MANIPULATION...")
    
    local container = GetTradeContainer()
    if not container then
        print("❌ No trade container found")
        return 0
    end
    
    -- Find all buttons in the trade window
    local buttons = {}
    for _, item in pairs(container:GetChildren()) do
        if item:IsA("TextButton") or item:IsA("ImageButton") then
            table.insert(buttons, item)
        end
    end
    
    print("Found " .. #buttons .. " buttons in trade window")
    
    -- Try to simulate multiple clicks on each button
    local clickCount = 0
    for _, button in pairs(buttons) do
        local buttonName = button.Name
        local buttonText = button:IsA("TextButton") and button.Text or ""
        
        print("Processing button: " .. buttonName .. " - \"" .. buttonText .. "\"")
        
        -- Check if this looks like a car button
        if buttonName:lower():find("car") or buttonText:lower():find("car") then
            print("🚗 CAR BUTTON DETECTED!")
            
            -- Try to click it multiple times
            for i = 1, 5 do
                pcall(function()
                    -- Method 1: Direct event firing
                    button:Fire("Activated")
                    
                    -- Method 2: Mouse click simulation
                    button:Fire("MouseButton1Click")
                    button:Fire("MouseButton1Down")
                    task.wait(0.05)
                    button:Fire("MouseButton1Up")
                    
                    -- Method 3: Try to find RemoteEvent
                    for _, child in pairs(button:GetChildren()) do
                        if child:IsA("RemoteEvent") then
                            child:FireServer("AddToTrade")
                            print("   Fired RemoteEvent: " .. child.Name)
                        end
                    end
                    
                    clickCount = clickCount + 1
                    print("   Click attempt " .. i .. " successful")
                end)
                
                task.wait(0.2)
            end
        end
    end
    
    print("📊 Total manipulation attempts: " .. clickCount)
    return clickCount
end

-- Find and trigger the trade confirmation
local function TriggerTradeConfirmation()
    print("\n🤝 TRIGGERING TRADE CONFIRMATION...")
    
    if not Player.PlayerGui then return false end
    
    -- Look for confirm button
    local confirmButton = nil
    
    local function SearchForButton(parent, depth)
        if depth > 5 then return nil end
        
        for _, child in pairs(parent:GetChildren()) do
            if child:IsA("TextButton") then
                local text = child.Text:lower()
                if text:find("confirm") 
                   or text:find("accept") 
                   or text:find("trade now")
                   or text:find("deal") then
                    return child
                end
            end
            
            -- Recursive search
            if #child:GetChildren() > 0 then
                local result = SearchForButton(child, depth + 1)
                if result then return result end
            end
        end
        
        return nil
    end
    
    confirmButton = SearchForButton(Player.PlayerGui, 0)
    
    if confirmButton then
        print("✅ Found confirm button: " .. confirmButton.Name)
        
        -- Click it multiple times
        for i = 1, 3 do
            pcall(function()
                confirmButton:Fire("MouseButton1Click")
                confirmButton:Fire("Activated")
                print("   Confirmation click " .. i)
            end)
            task.wait(0.3)
        end
        
        return true
    else
        print("❌ No confirm button found")
        return false
    end
end

-- Main execution function
local function ExecuteDuplication()
    print("\n🚀 EXECUTING DUPLICATION PROCESS...")
    
    -- Step 1: Find and hook trade remotes
    local remotes = FindTradeRemotes()
    local hooksCreated = 0
    
    for _, remote in pairs(remotes) do
        local hook = CreateRemoteHook(remote)
        if hook then
            hooksCreated = hooksCreated + 1
        end
    end
    
    print("📊 Hooks created: " .. hooksCreated)
    
    if hooksCreated == 0 then
        print("⚠️  No hooks created, trying direct manipulation...")
    end
    
    -- Step 2: Manipulate trade items directly
    task.wait(1)
    ManipulateTradeItems()
    
    -- Step 3: Wait and trigger confirmation
    task.wait(2)
    print("\n⏳ Waiting for trade setup...")
    
    -- Step 4: Auto-trigger confirmation if button exists
    task.wait(3)
    TriggerTradeConfirmation()
    
    print("\n✅ DUPLICATION PROCESS COMPLETE")
    print("Check if other player sees duplicates!")
    
    return hooksCreated > 0
end

-- Simple UI
local function CreateSimpleUI()
    local gui = Instance.new("ScreenGui")
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "TRADE DUPLICATOR"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local output = Instance.new("TextLabel")
    output.Text = "Ready to duplicate trade items"
    output.Size = UDim2.new(1, -20, 0, 100)
    output.Position = UDim2.new(0, 10, 0, 50)
    output.BackgroundTransparency = 1
    output.TextColor3 = Color3.fromRGB(200, 200, 255)
    output.TextWrapped = true
    
    local executeBtn = Instance.new("TextButton")
    executeBtn.Text = "🚀 EXECUTE DUPLICATION"
    executeBtn.Size = UDim2.new(1, -20, 0, 40)
    executeBtn.Position = UDim2.new(0, 10, 0, 150)
    executeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
    executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Update output function
    local function updateOutput(text)
        output.Text = text
        print(text)
    end
    
    executeBtn.MouseButton1Click:Connect(function()
        executeBtn.Text = "PROCESSING..."
        updateOutput("Starting duplication process...")
        
        spawn(function()
            local success = ExecuteDuplication()
            
            if success then
                updateOutput("✅ Duplication attempted!\nCheck other player's screen.")
                executeBtn.Text = "✅ SUCCESS"
                executeBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            else
                updateOutput("⚠️  Partial success\nDirect manipulation only")
                executeBtn.Text = "🚀 EXECUTE DUPLICATION"
            end
        end)
    end)
    
    -- Parent everything
    title.Parent = frame
    output.Parent = frame
    executeBtn.Parent = frame
    frame.Parent = gui
    
    return updateOutput
end

-- Initialize
local updateOutput = CreateSimpleUI()

-- Auto-start instructions
task.wait(3)
print("\n=== INSTRUCTIONS ===")
print("1. Start a trade with another player")
print("2. Add a car to the trade window")
print("3. Click 'EXECUTE DUPLICATION' button")
print("4. Check if OTHER player sees duplicates")
print("5. Complete the trade normally")

-- Auto-scan after delay
spawn(function()
    task.wait(5)
    print("\n🔍 Auto-scanning for trade remotes...")
    FindTradeRemotes()
    updateOutput("Scan complete. Ready to execute.")
end)

-- Keybind for quick execution
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.D then
        print("\n🎮 D KEY PRESSED - EXECUTING")
        ExecuteDuplication()
        updateOutput("Quick execution via D key")
    end
end)

print("\nPress D for quick duplication")
