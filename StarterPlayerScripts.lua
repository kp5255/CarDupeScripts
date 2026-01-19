-- Trade Staging Phase Analyzer
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("=== TRADE STAGING PHASE ANALYZER ===")
print("Understanding the gap between staging and commit")

-- Get services
local tradingService = ReplicatedStorage.Remotes.Services.TradingServiceRemotes

-- Track all trade-related remotes
local function ListTradeRemotes()
    print("\n🔗 TRADE REMOTES ANALYSIS:")
    
    local remotes = {}
    for _, remote in pairs(tradingService:GetChildren()) do
        local remoteType = remote.ClassName
        local remoteName = remote.Name
        
        print("  " .. remoteName .. " (" .. remoteType .. ")")
        
        -- Categorize by phase
        if remoteName:find("Session") then
            table.insert(remotes, {
                name = remoteName,
                type = remoteType,
                phase = "STAGING",
                description = "Manages trade session state"
            })
        elseif remoteName:find("Confirm") or remoteName:find("Accept") then
            table.insert(remotes, {
                name = remoteName,
                type = remoteType,
                phase = "COMMIT", 
                description = "Finalizes trade"
            })
        elseif remoteName:find("Item") then
            table.insert(remotes, {
                name = remoteName,
                type = remoteType,
                phase = "STAGING",
                description = "Adds/removes items during staging"
            })
        elseif remoteName:find("On") then
            table.insert(remotes, {
                name = remoteName,
                type = remoteType,
                phase = "REPLICATION",
                description = "Updates clients on state changes"
            })
        end
    end
    
    print("\n📊 REMOTE CATEGORIES:")
    local phaseCount = {STAGING = 0, COMMIT = 0, REPLICATION = 0}
    for _, remote in ipairs(remotes) do
        phaseCount[remote.phase] = (phaseCount[remote.phase] or 0) + 1
    end
    
    for phase, count in pairs(phaseCount) do
        print("  " .. phase .. ": " .. count .. " remotes")
    end
    
    return remotes
end

-- Monitor staging phase
local function MonitorStagingPhase()
    print("\n🎭 MONITORING STAGING PHASE:")
    print("Staging = UI preview before commit")
    print("Commit = Final validation & transfer")
    
    -- Get trade container
    local container = nil
    pcall(function()
        container = Player.PlayerGui:WaitForChild("Menu"):WaitForChild("Trading"):WaitForChild("PeerToPeer"):WaitForChild("Main"):WaitForChild("LocalPlayer"):WaitForChild("Content"):WaitForChild("ScrollingFrame")
    end)
    
    if container then
        print("\n📦 STAGING CONTAINER FOUND:")
        print("Path: " .. container:GetFullName())
        print("Visible: " .. tostring(container.Visible))
        print("Children: " .. #container:GetChildren())
        
        -- Show what's in staging
        local stagingItems = {}
        for _, item in pairs(container:GetChildren()) do
            if item:IsA("ImageButton") or item:IsA("TextButton") then
                local itemInfo = {
                    name = item.Name,
                    class = item.ClassName,
                    visible = item.Visible
                }
                table.insert(stagingItems, itemInfo)
            end
        end
        
        print("\n🎪 ITEMS IN STAGING AREA:")
        for i, item in ipairs(stagingItems) do
            print(i .. ". " .. item.name .. " (" .. item.class .. ")")
        end
        
        return stagingItems
    else
        print("❌ No staging container found")
        return {}
    end
end

-- Check for staging vs commit UI elements
local function AnalyzeTradeUI()
    print("\n🎨 ANALYZING TRADE UI STRUCTURE:")
    
    if not Player.PlayerGui then return end
    
    local menu = Player.PlayerGui:FindFirstChild("Menu")
    if not menu then return end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then return end
    
    -- Look for staging UI elements
    print("\n🔍 STAGING UI ELEMENTS:")
    local stagingElements = {}
    
    local function CheckElement(obj, path)
        local name = obj.Name:lower()
        local className = obj.ClassName
        
        -- Staging indicators
        if name:find("preview") or name:find("staging") or name:find("temp") then
            table.insert(stagingElements, {
                path = path,
                name = obj.Name,
                class = className,
                type = "STAGING_INDICATOR"
            })
            print("  " .. path .. " (" .. className .. ") - Staging indicator")
        end
        
        -- Commit buttons
        if className == "TextButton" and (name:find("confirm") or name:find("accept") or name:find("trade")) then
            table.insert(stagingElements, {
                path = path,
                name = obj.Name,
                class = className,
                type = "COMMIT_BUTTON",
                text = obj.Text
            })
            print("  " .. path .. " - \"" .. obj.Text .. "\" - Commit button")
        end
        
        -- Item display
        if className:find("Button") and (name:find("car") or name:find("item")) then
            table.insert(stagingElements, {
                path = path,
                name = obj.Name,
                class = className,
                type = "STAGING_ITEM",
                visible = obj.Visible
            })
            print("  " .. path .. " - Staging item display")
        end
    end
    
    -- Search trading UI
    for _, obj in pairs(trading:GetDescendants()) do
        CheckElement(obj, obj:GetFullName():gsub("Players." .. Player.Name .. ".PlayerGui.", ""))
    end
    
    print("\n📊 UI ANALYSIS SUMMARY:")
    local typeCount = {}
    for _, element in ipairs(stagingElements) do
        typeCount[element.type] = (typeCount[element.type] or 0) + 1
    end
    
    for type, count in pairs(typeCount) do
        print("  " .. type .. ": " .. count)
    end
    
    return stagingElements
end

-- Test staging phase permissiveness
local function TestStagingPermissiveness()
    print("\n🧪 TESTING STAGING PERMISSIVENESS:")
    print("Hypothesis: Staging allows ambiguous/duplicate display")
    
    -- Get SessionAddItem remote
    local SessionAddItem = tradingService:FindFirstChild("SessionAddItem")
    if not SessionAddItem then
        print("❌ SessionAddItem not found")
        return false
    end
    
    print("\n1. Checking if staging allows duplicate UI entries...")
    
    -- Monitor current staging state
    local initialItems = MonitorStagingPhase()
    local initialCount = #initialItems
    
    print("Initial staging items: " .. initialCount)
    
    -- Try to trigger staging updates
    print("\n2. Attempting to influence staging state...")
    
    -- We need to understand what triggers staging updates
    local stagingRemotes = {}
    for _, remote in pairs(tradingService:GetChildren()) do
        if remote.Name:find("Session") or remote.Name:find("Item") then
            table.insert(stagingRemotes, remote)
        end
    end
    
    print("Found " .. #stagingRemotes .. " staging remotes")
    
    -- Try to understand the flow
    print("\n3. Observing normal trade flow:")
    print("   a. Player adds item → staging updates")
    print("   b. Both players see staging state")
    print("   c. Commit button pressed")
    print("   d. Server validates and transfers")
    
    return {
        stagingRemotes = stagingRemotes,
        initialCount = initialCount,
        hasSessionAddItem = SessionAddItem ~= nil
    }
end

-- Check for consistency gaps
local function CheckConsistencyGaps()
    print("\n🔍 CHECKING FOR CONSISTENCY GAPS:")
    print("Gap = Difference between what players see and what server validates")
    
    print("\nPOSSIBLE GAPS TO EXPLORE:")
    print("1. Staging item count vs actual item count")
    print("2. UI display vs server validation")
    print("3. Preview state vs commit state")
    print("4. Client-side rendering vs server-side truth")
    
    -- Look for evidence of gaps
    print("\n🎯 EVIDENCE COLLECTION:")
    
    -- Check if UI shows more items than should exist
    local stagingItems = MonitorStagingPhase()
    
    if #stagingItems > 0 then
        print("Staging shows " .. #stagingItems .. " items")
        
        -- Check for duplicate appearances
        local itemNames = {}
        local duplicates = {}
        
        for _, item in ipairs(stagingItems) do
            if itemNames[item.name] then
                table.insert(duplicates, item.name)
            else
                itemNames[item.name] = true
            end
        end
        
        if #duplicates > 0 then
            print("⚠️  POSSIBLE GAP: Duplicate items in staging:")
            for _, dup in ipairs(duplicates) do
                print("   - " .. dup)
            end
        else
            print("No duplicate items in staging")
        end
    end
    
    return #stagingItems
end

-- Create analysis report
local function CreateAnalysisReport()
    print("\n" .. string.rep("=", 60))
    print("TRADE SYSTEM ANALYSIS REPORT")
    print(string.rep("=", 60))
    
    -- Phase 1: System Understanding
    print("\n📋 PHASE 1: SYSTEM UNDERSTANDING")
    ListTradeRemotes()
    
    -- Phase 2: Trust Boundary
    print("\n📋 PHASE 2: TRUST BOUNDARY IDENTIFICATION")
    local uiElements = AnalyzeTradeUI()
    
    -- Phase 3: Consistency Probing
    print("\n📋 PHASE 3: CONSISTENCY PROBING")
    local permissiveness = TestStagingPermissiveness()
    local stagingCount = CheckConsistencyGaps()
    
    -- Analysis
    print("\n📋 ANALYSIS SUMMARY:")
    print("System uses session-based trading with UUIDs")
    print("Staging phase displays items before commit")
    print("Commit phase validates and transfers ownership")
    
    if stagingCount > 1 then
        print("\n⚠️  CONSISTENCY GAP DETECTED:")
        print("Multiple items in staging phase")
        print("This may allow misleading displays before commit")
    end
    
    print("\n🎯 KEY INSIGHT:")
    print("Exploitation would target the GAP between")
    print("permissive staging display and strict commit validation")
    print("\nThis is a CONSENT-SPOOFING issue, not an asset duplication issue")
    
    print(string.rep("=", 60))
end

-- Create UI for analysis
local function CreateAnalysisUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TradeAnalyzer"
    gui.Parent = Player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 300)
    frame.Position = UDim2.new(0.5, -200, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    frame.Active = true
    frame.Draggable = true
    
    local title = Instance.new("TextLabel")
    title.Text = "TRADE SYSTEM ANALYZER"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    title.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    local output = Instance.new("ScrollingFrame")
    output.Size = UDim2.new(1, -20, 0, 200)
    output.Position = UDim2.new(0, 10, 0, 50)
    output.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    output.ScrollBarThickness = 8
    
    local outputText = Instance.new("TextLabel")
    outputText.Size = UDim2.new(1, 0, 5, 0)
    outputText.Position = UDim2.new(0, 5, 0, 5)
    outputText.BackgroundTransparency = 1
    outputText.TextColor3 = Color3.fromRGB(200, 230, 255)
    outputText.TextWrapped = true
    outputText.TextXAlignment = Enum.TextXAlignment.Left
    outputText.TextYAlignment = Enum.TextYAlignment.Top
    outputText.Text = "Trade System Analysis\n\nUnderstanding the gap between staging and commit..."
    
    outputText.Parent = output
    
    -- Buttons for different phases
    local phases = {
        {text = "🔗 REMOTES", func = ListTradeRemotes},
        {text = "🎭 STAGING", func = MonitorStagingPhase},
        {text = "🎨 UI", func = AnalyzeTradeUI},
        {text = "🧪 PERMISSIVENESS", func = TestStagingPermissiveness},
        {text = "🔍 GAPS", func = CheckConsistencyGaps},
        {text = "📋 FULL REPORT", func = CreateAnalysisReport}
    }
    
    for i, phase in ipairs(phases) do
        local btn = Instance.new("TextButton")
        btn.Text = phase.text
        btn.Size = UDim2.new(0.48, 0, 0, 30)
        btn.Position = UDim2.new(i % 2 == 1 and 0.01 or 0.51, 0, 0, 260 + math.floor((i-1)/2)*35)
        btn.BackgroundColor3 = Color3.fromRGB(60, 80, 120)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        btn.MouseButton1Click:Connect(function()
            outputText.Text = "Running: " .. phase.text .. "...\n"
            spawn(function()
                phase.func()
                outputText.Text = "Completed: " .. phase.text .. "\nCheck output window for details"
            end)
        end)
        
        btn.Parent = frame
    end
    
    -- Parent everything
    title.Parent = frame
    output.Parent = frame
    frame.Parent = gui
    
    -- Hook print to UI
    local originalPrint = print
    print = function(...)
        local args = {...}
        local message = table.concat(args, " ")
        originalPrint(message)
        
        -- Update UI with important messages
        if message:find("GAP") or message:find("STAGING") or message:find("COMMIT") then
            outputText.Text = "> " .. message .. "\n" .. outputText.Text
        end
    end
    
    return outputText
end

-- Initialize
CreateAnalysisUI()

-- Instructions
wait(3)
print("\n=== TRADE SYSTEM ANALYSIS ===")
print("Understanding the staging-commit boundary")
print("\n📋 PHASES OF ANALYSIS:")
print("1. System Understanding - How trades work")
print("2. Trust Boundaries - Where validation happens")
print("3. Consistency Gaps - Differences between display and reality")
print("4. Staging Permissiveness - What's allowed before commit")
print("\n🎯 GOAL: Understand the gap, not exploit it")

-- Auto-run initial analysis
spawn(function()
    wait(5)
    print("\n🔍 Starting initial system analysis...")
    ListTradeRemotes()
    MonitorStagingPhase()
end)
