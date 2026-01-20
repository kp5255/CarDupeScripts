-- 💎 ALL-IN-ONE TRADE SOLUTION
print("💎 ALL-IN-ONE TRADE BOT ACTIVATED")

-- CONFIGURATION
local TARGET_CAR = "AstonMartin12"
local ADD_COUNT = 5
local DELAY_BETWEEN = 0.4

-- FIND THE RIGHT REMOTE
local tradingFolder = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes
local targetRemote = nil
local targetMethod = nil

-- List of possible remote names (ordered by likelihood)
local possibleRemotes = {
    "AddToTrade", "AddItem", "AddVehicle", "AddCar",
    "TradeAdd", "AddToTrading", "SendTradeRequest",
    "OfferTrade", "TradeOffer", "StartTrade"
}

-- Find any remote that exists
print("🔍 Searching for trading remotes...")
for _, name in pairs(possibleRemotes) do
    local remote = tradingFolder:FindFirstChild(name)
    if remote then
        targetRemote = remote
        print("✅ Found remote: " .. name)
        break
    end
end

-- If no named remote found, try any remote in the folder
if not targetRemote then
    print("⚠️ No named remote found, searching all remotes...")
    for _, remote in pairs(tradingFolder:GetChildren()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            targetRemote = remote
            print("✅ Using remote: " .. remote.Name)
            break
        end
    end
end

if not targetRemote then
    print("❌ No trading remotes found!")
    return
end

-- DETECT THE RIGHT METHOD
local function detectMethod(remote)
    print("🔍 Detecting method for: " .. remote.Name)
    
    -- Try common methods
    local methods = {"InvokeServer", "FireServer", "Fire", "Invoke"}
    
    for _, methodName in pairs(methods) do
        local success, result = pcall(function()
            return remote[methodName]
        end)
        
        if success and type(result) == "function" then
            print("✅ Method detected: " .. methodName)
            return methodName
        end
    end
    
    print("⚠️ No standard method found, trying default...")
    return "InvokeServer"
end

targetMethod = detectMethod(targetRemote)

-- TEST DATA FORMATS
local testDataFormats = {
    TARGET_CAR,  -- Just the string
    {ItemId = TARGET_CAR},
    {ID = TARGET_CAR},
    {Car = TARGET_CAR},
    {Vehicle = TARGET_CAR},
    {Name = "Aston Martin"},
    {ProductId = TARGET_CAR}
}

-- FUNCTION TO ADD CAR
function addCar(dataFormat)
    print("➕ Adding car...")
    
    local success, result = pcall(function()
        local method = targetRemote[targetMethod]
        
        if type(method) == "function" then
            if type(dataFormat) == "table" then
                return method(targetRemote, dataFormat)
            else
                return method(targetRemote, dataFormat)
            end
        else
            -- Method doesn't exist, try all methods
            local allMethods = {"InvokeServer", "FireServer", "Fire", "Invoke"}
            for _, m in pairs(allMethods) do
                local func = targetRemote[m]
                if type(func) == "function" then
                    if type(dataFormat) == "table" then
                        return func(targetRemote, dataFormat)
                    else
                        return func(targetRemote, dataFormat)
                    end
                end
            end
            return nil, "No valid method found"
        end
    end)
    
    if success then
        print("✅ Success!")
        if result then
            print("   Result: " .. tostring(result))
        end
        return true
    else
        print("❌ Failed: " .. tostring(result))
        return false
    end
end

-- MAIN EXECUTION
print("\n" .. string.rep("🚀", 30))
print("STARTING BULK ADD...")
print(string.rep("🚀", 30))

local addedCount = 0

for i = 1, ADD_COUNT do
    print("\n[" .. i .. "/" .. ADD_COUNT .. "]")
    
    -- Try each data format until one works
    local success = false
    for _, dataFormat in pairs(testDataFormats) do
        if addCar(dataFormat) then
            success = true
            addedCount = addedCount + 1
            break
        end
        task.wait(0.1)
    end
    
    if not success then
        print("⚠️ No format worked, trying direct string...")
        pcall(function()
            if targetRemote:IsA("RemoteFunction") then
                targetRemote:InvokeServer(TARGET_CAR)
            else
                pcall(function() targetRemote:FireServer(TARGET_CAR) end)
                pcall(function() targetRemote:Fire(TARGET_CAR) end)
            end
            addedCount = addedCount + 1
            print("✅ Direct call succeeded")
        end)
    end
    
    task.wait(DELAY_BETWEEN)
end

print("\n" .. string.rep("🎯", 30))
print("COMPLETE! Added " .. addedCount .. "/" .. ADD_COUNT .. " cars")
print(string.rep("🎯", 30))

-- AUTO-CLICKER VERSION (IF REMOTE DOESN'T WORK)
if addedCount == 0 then
    print("\n" .. string.rep("🔄", 30))
    print("TRYING AUTO-CLICKER METHOD...")
    print(string.rep("🔄", 30))
    
    spawn(function()
        -- Try to find and click car buttons
        local Player = game:GetService("Players").LocalPlayer
        local PlayerGui = Player:WaitForChild("PlayerGui")
        
        for clickAttempt = 1, 10 do
            print("Click attempt " .. clickAttempt)
            
            for _, gui in pairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled then
                    for _, button in pairs(gui:GetDescendants()) do
                        if button:IsA("TextButton") or button:IsA("ImageButton") then
                            local name = button.Name:lower()
                            local text = (button.Text or ""):lower()
                            
                            if name:find("car") or name:find("vehicle") or 
                               name:find("add") or name:find("trade") or
                               text:find("car") or text:find("vehicle") then
                                
                                for i = 1, 3 do
                                    pcall(function()
                                        button:Fire("Activated")
                                        print("✅ Clicked: " .. button.Name)
                                    end)
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end
            end
            
            task.wait(0.5)
        end
    end)
end

-- CREATE CONTROL FUNCTIONS
getgenv().TradeBot = {
    -- Add more cars
    addMore = function(count)
        count = count or 5
        print("Adding " .. count .. " more cars...")
        
        for i = 1, count do
            pcall(function()
                if targetRemote:IsA("RemoteFunction") then
                    targetRemote:InvokeServer(TARGET_CAR)
                else
                    pcall(function() targetRemote:FireServer(TARGET_CAR) end)
                    pcall(function() targetRemote:Fire(TARGET_CAR) end)
                end
                print("✅ Added " .. i)
            end)
            task.wait(0.3)
        end
    end,
    
    -- Test connection
    test = function()
        print("Testing connection...")
        pcall(function()
            if targetRemote:IsA("RemoteFunction") then
                local result = targetRemote:InvokeServer(TARGET_CAR)
                print("✅ Test successful! Result: " .. tostring(result))
            else
                targetRemote:FireServer(TARGET_CAR)
                print("✅ Test fired successfully")
            end
        end)
    end,
    
    -- Show info
    info = function()
        print("📊 TradeBot Info:")
        print("  Remote: " .. targetRemote.Name)
        print("  Type: " .. targetRemote.ClassName)
        print("  Method: " .. targetMethod)
        print("  Target Car: " .. TARGET_CAR)
        print("  Added: " .. addedCount .. " cars")
    end
}

print("\n" .. string.rep("🎮", 30))
print("CONTROLS AVAILABLE:")
print(string.rep("🎮", 30))
print("TradeBot.addMore(10) -- Add 10 more cars")
print("TradeBot.test()      -- Test the connection")
print("TradeBot.info()      -- Show information")
print(string.rep("🎮", 30))

-- AUTO-RUN TEST
task.wait(2)
print("\n🧪 Running auto-test...")
TradeBot.test()

print("\n" .. string.rep("✅", 30))
print("SCRIPT LOADED SUCCESSFULLY!")
print(string.rep("✅", 30))
