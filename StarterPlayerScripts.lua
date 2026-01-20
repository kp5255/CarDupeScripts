-- 🕵️‍♂️ ULTIMATE TRADE FORMAT DETECTOR
-- This WILL find the truth, no matter what

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

print("🔍 ULTIMATE DETECTIVE MODE ACTIVATED")
print("=" .. string.rep("=", 60))

-- ===== STEP 1: INSPECT EVERYTHING =====
local function InspectRemote()
    print("\n🔎 STEP 1: INSPECTING REMOTE...")
    
    local remote = RS.Remotes.Services.TradingServiceRemotes.SessionAddItem
    print("✅ Remote found:", remote:GetFullName())
    
    -- Get ALL properties
    print("\n📋 REMOTE PROPERTIES:")
    for _, property in pairs({"Name", "ClassName", "Parent", "Archivable"}) do
        local value = remote[property]
        print("  " .. property .. ": " .. tostring(value))
    end
    
    return remote
end

-- ===== STEP 2: CAPTURE REAL CLICK =====
local function CaptureRealClick(remote)
    print("\n🎯 STEP 2: CAPTURING REAL HUMAN CLICK")
    print("=" .. string.rep("=", 40))
    print("INSTRUCTIONS:")
    print("1. I will hook the remote")
    print("2. YOU click AstonMartin12 in your inventory")
    print("3. I will capture EVERYTHING")
    print("=" .. string.rep("=", 40))
    
    local capturedData = nil
    local captureCount = 0
    local originalInvoke = remote.InvokeServer
    
    -- Create PERFECT hook
    remote.InvokeServer = function(self, ...)
        local args = {...}
        captureCount = captureCount + 1
        
        print("\n🔥 CAPTURE #" .. captureCount)
        print("Number of arguments:", #args)
        
        -- Analyze each argument
        for i, arg in ipairs(args) do
            print("\n📦 ARGUMENT " .. i .. ":")
            print("  Type:", type(arg))
            
            if type(arg) == "string" then
                print("  Value: \"" .. arg .. "\"")
                print("  Length:", #arg)
            elseif type(arg) == "number" then
                print("  Value:", arg)
            elseif type(arg) == "boolean" then
                print("  Value:", arg)
            elseif type(arg) == "table" then
                print("  📊 TABLE ANALYSIS:")
                print("  Table string:", tostring(arg))
                
                -- Try to get metatable info
                local success, mt = pcall(getrawmetatable, arg)
                if success and mt then
                    print("  Has metatable: YES")
                end
                
                -- Count table elements
                local elementCount = 0
                for _ in pairs(arg) do elementCount = elementCount + 1 end
                print("  Element count:", elementCount)
                
                -- Show ALL key-value pairs
                for k, v in pairs(arg) do
                    print("    [" .. type(k) .. "] " .. tostring(k) .. " = [" .. type(v) .. "] " .. tostring(v))
                    
                    -- If value is table, show its contents too
                    if type(v) == "table" then
                        for k2, v2 in pairs(v) do
                            print("      [" .. type(k2) .. "] " .. tostring(k2) .. " = [" .. type(v2) .. "] " .. tostring(v2))
                        end
                    end
                end
                
                -- Try to JSON encode it
                local jsonSuccess, jsonResult = pcall(HttpService.JSONEncode, HttpService, arg)
                if jsonSuccess then
                    print("  JSON:", string.sub(jsonResult, 1, 200) .. (#jsonResult > 200 and "..." or ""))
                end
            elseif type(arg) == "nil" then
                print("  Value: nil")
            else
                print("  Full tostring:", tostring(arg))
            end
        end
        
        capturedData = args
        
        -- Call original
        return originalInvoke(self, ...)
    end
    
    print("\n✅ HOOK INSTALLED!")
    print("NOW: Click AstonMartin12 in your inventory")
    print("I will see EXACTLY what gets sent")
    
    -- Wait with countdown
    for i = 1, 45 do
        task.wait(1)
        if capturedData then
            print("\n🎉 CAPTURE SUCCESSFUL!")
            break
        end
        if i % 5 == 0 then
            print("Waiting... " .. i .. "/45 seconds")
        end
    end
    
    if not capturedData then
        print("\n⚠️ No click captured")
        print("Trying alternative approach...")
        
        -- Check if we can find the button and simulate click
        local button = FindCarButton()
        if button then
            print("Found car button, trying to simulate...")
            capturedData = SimulateButtonClick(button, remote)
        end
    end
    
    return capturedData
end

-- ===== STEP 3: FIND CAR BUTTON =====
local function FindCarButton()
    print("\n🔍 STEP 3: FINDING CAR BUTTON...")
    
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local foundButtons = {}
    
    -- Search EVERYWHERE
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            local name = obj.Name:lower()
            local text = ""
            
            if obj:IsA("TextButton") then
                text = obj.Text:lower()
            end
            
            -- Check if it might be our car
            if name:find("aston") or name:find("martin") or 
               text:find("aston") or text:find("martin") or
               name:find("car") or text:find("car") then
                
                table.insert(foundButtons, {
                    object = obj,
                    name = obj.Name,
                    text = obj.Text or "",
                    fullPath = obj:GetFullName()
                })
            end
        end
    end
    
    print("Found " .. #foundButtons .. " potential buttons")
    
    for i, btn in ipairs(foundButtons) do
        print("\n[" .. i .. "] " .. btn.name)
        print("   Text: \"" .. btn.text .. "\"")
        print("   Path: " .. btn.fullPath)
        
        -- Check for attributes
        local attributes = {"ItemId", "ID", "Id", "ItemID", "ProductId", "AssetId"}
        for _, attr in pairs(attributes) do
            local value = btn.object:GetAttribute(attr)
            if value then
                print("   Attribute " .. attr .. ": " .. tostring(value))
            end
        end
    end
    
    return foundButtons[1] and foundButtons[1].object
end

-- ===== STEP 4: DEEP ANALYSIS =====
local function DeepAnalysis(capturedData)
    print("\n🔬 STEP 4: DEEP ANALYSIS")
    print("=" .. string.rep("=", 40))
    
    if not capturedData or #capturedData == 0 then
        print("❌ No data to analyze")
        return nil
    end
    
    local firstArg = capturedData[1]
    
    print("FIRST ARGUMENT TYPE:", type(firstArg))
    
    if type(firstArg) == "table" then
        print("\n🧬 TABLE GENOME SEQUENCING:")
        
        -- Get ALL possible info
        local allKeys = {}
        for k, _ in pairs(firstArg) do
            table.insert(allKeys, k)
        end
        
        print("Total keys:", #allKeys)
        print("Keys:", table.concat(allKeys, ", "))
        
        -- Create ALL possible variations
        local variations = {}
        
        -- Variation 1: Exact copy
        table.insert(variations, {name = "Exact Copy", data = firstArg})
        
        -- Variation 2: Stringified version
        if #allKeys == 1 then
            local key = allKeys[1]
            local value = firstArg[key]
            if type(value) == "string" then
                table.insert(variations, {name = "Single String", data = value})
            end
        end
        
        -- Variation 3: Different key cases
        for _, key in ipairs(allKeys) do
            local value = firstArg[key]
            
            -- Test different key cases
            local keyVariations = {
                key,  -- original
                key:lower(),
                key:upper(),
                key:gsub("^%l", string.upper),  -- Capitalize first letter
                key:gsub("id$", "Id"),  -- Fix id/Id
                key:gsub("type$", "Type")  -- Fix type/Type
            }
            
            for _, newKey in ipairs(keyVariations) do
                if newKey ~= key then
                    local newTable = {}
                    for k2, v2 in pairs(firstArg) do
                        if k2 == key then
                            newTable[newKey] = v2
                        else
                            newTable[k2] = v2
                        end
                    end
                    table.insert(variations, {name = "Key: " .. key .. " → " .. newKey, data = newTable})
                end
            end
        end
        
        -- Variation 4: Different value cases
        for _, key in ipairs(allKeys) do
            local value = firstArg[key]
            if type(value) == "string" then
                local valueVariations = {
                    value,  -- original
                    value:lower(),
                    value:upper(),
                    "Car-" .. value,
                    value .. "-Car",
                    "Vehicle-" .. value,
                    value .. "-Vehicle"
                }
                
                for _, newValue in ipairs(valueVariations) do
                    if newValue ~= value then
                        local newTable = {}
                        for k2, v2 in pairs(firstArg) do
                            if k2 == key then
                                newTable[k2] = newValue
                            else
                                newTable[k2] = v2
                            end
                        end
                        table.insert(variations, {name = "Value: " .. value .. " → " .. newValue, data = newTable})
                    end
                end
            end
        end
        
        return variations
        
    elseif type(firstArg) == "string" then
        print("\n🔤 STRING ANALYSIS:")
        print("Value: \"" .. firstArg .. "\"")
        print("Length:", #firstArg)
        
        -- Create variations
        local variations = {
            {name = "Original String", data = firstArg},
            {name = "Lowercase", data = firstArg:lower()},
            {name = "Uppercase", data = firstArg:upper()},
            {name = "With Car- prefix", data = "Car-" .. firstArg},
            {name = "With Vehicle- prefix", data = "Vehicle-" .. firstArg}
        }
        
        return variations
    end
    
    return nil
end

-- ===== STEP 5: TEST ALL POSSIBILITIES =====
local function TestAllPossibilities(remote, variations)
    print("\n🧪 STEP 5: TESTING ALL POSSIBILITIES")
    print("=" .. string.rep("=", 40))
    
    if not variations then
        print("❌ No variations to test")
        return nil
    end
    
    print("Testing " .. #variations .. " variations...")
    
    local workingFormats = {}
    
    for i, variation in ipairs(variations) do
        print("\n[" .. i .. "/" .. #variations .. "] Testing: " .. variation.name)
        
        local success, result = pcall(function()
            return remote:InvokeServer(variation.data)
        end)
        
        if success then
            print("✅ SUCCESS!")
            print("   Result:", result)
            
            table.insert(workingFormats, {
                name = variation.name,
                data = variation.data,
                result = result
            })
            
            -- If it works, also test if we can add multiple
            print("   Testing duplicate add...")
            task.wait(0.3)
            
            local success2, result2 = pcall(function()
                return remote:InvokeServer(variation.data)
            end)
            
            if success2 then
                print("   ✅ Can add multiple!")
            else
                print("   ⚠️ Might be limited:", result2)
            end
            
        else
            print("❌ Failed:", result)
        end
        
        task.wait(0.2)
    end
    
    return workingFormats
end

-- ===== STEP 6: CREATE FINAL BOT =====
local function CreateFinalBot(remote, workingFormat)
    print("\n🚀 STEP 6: CREATING FINAL BOT")
    print("=" .. string.rep("=", 60))
    
    if not workingFormat then
        print("❌ No working format found")
        return
    end
    
    print("🎉 WORKING FORMAT FOUND!")
    print("Name:", workingFormat.name)
    print("Data:", workingFormat.data)
    print("Result:", workingFormat.result)
    
    -- Create the ultimate bot
    local botCode = [[
-- 🎯 ULTIMATE TRADE BOT - WORKING VERSION
local remote = game:GetService("ReplicatedStorage").Remotes.Services.TradingServiceRemotes.SessionAddItem

-- WORKING DATA FORMAT:
local workingData = ]] .. tostring(workingFormat.data) .. [[

function addCar()
    local success, result = pcall(function()
        return remote:InvokeServer(workingData)
    end)
    
    if success then
        print("✅ Added successfully!")
        return true
    else
        print("❌ Failed:", result)
        return false
    end
end

function addMultiple(count)
    print("📦 Adding " .. count .. " items...")
    
    local added = 0
    for i = 1, count do
        print("[" .. i .. "/" .. count .. "] Adding...")
        
        if addCar() then
            added = added + 1
        end
        
        -- Safe delay
        task.wait(0.5)
    end
    
    print("✅ Finished! Added " .. added .. "/" .. count)
    return added
end

-- Make functions global
getgenv().add1 = function() addMultiple(1) end
getgenv().add5 = function() addMultiple(5) end
getgenv().add10 = function() addMultiple(10) end
getgenv().add50 = function() addMultiple(50) end

print("🎮 BOT READY!")
print("Type: add1(), add5(), add10(), or add50()")
]]
    
    print("\n" .. string.rep("=", 60))
    print("📋 FINAL BOT CODE:")
    print(string.rep("=", 60))
    print(botCode)
    print(string.rep("=", 60))
    
    -- Execute it
    local success, err = pcall(loadstring(botCode))
    if not success then
        print("❌ Error creating bot:", err)
    end
end

-- ===== MAIN EXECUTION =====
print("\n🔥 EXECUTING ULTIMATE DETECTION...")

-- Step 1: Inspect
local remote = InspectRemote()

-- Step 2: Capture real click
task.wait(2)
local capturedData = CaptureRealClick(remote)

-- Step 3: Deep analysis
local variations = DeepAnalysis(capturedData)

-- Step 4: Test all possibilities
local workingFormats = TestAllPossibilities(remote, variations)

-- Step 5: Create final bot
if workingFormats and #workingFormats > 0 then
    CreateFinalBot(remote, workingFormats[1])
else
    print("\n💀 MISSION FAILED")
    print("Even ultimate detection couldn't find working format")
    print("This suggests:")
    print("1. Trading session not active")
    print("2. Car not in inventory")
    print("3. Server-side validation changed")
    print("4. Need different approach")
    
    -- Last resort: brute force all possibilities
    print("\n💥 ATTEMPTING BRUTE FORCE...")
    
    local lastResortTests = {
        {data = "AstonMartin12", name = "Pure string"},
        {data = "Car-AstonMartin12", name = "With Car- prefix"},
        {data = {AstonMartin12 = true}, name = "Table with key"},
        {data = {Item = "AstonMartin12"}, name = "Item key"},
        {data = {Car = "AstonMartin12"}, name = "Car key"},
        {data = {Vehicle = "AstonMartin12"}, name = "Vehicle key"},
        {data = {id = 1, name = "AstonMartin12"}, name = "Numeric id"}
    }
    
    local lastWorking = TestAllPossibilities(remote, lastResortTests)
    if lastWorking and #lastWorking > 0 then
        CreateFinalBot(remote, lastWorking[1])
    end
end

print("\n" .. string.rep("=", 60))
print("🎯 MISSION COMPLETE")
print(string.rep("=", 60))
