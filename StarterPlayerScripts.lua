-- ===== ENHANCED UNLOCK SYSTEM =====
local function EnhancedUnlockCosmetics(carName, cosmetics)
    print("🔓 Enhanced unlocking for: " .. (carName or "Unknown Car"))
    
    local results = {
        total = #cosmetics.All,
        unlocked = 0,
        failed = 0,
        details = {}
    }
    
    if results.total == 0 then
        print("⚠️ No cosmetics to unlock!")
        return results
    end
    
    -- Find ALL purchase remotes (both RemoteFunction AND RemoteEvent)
    local purchaseRemotes = {}
    
    print("📡 Searching for purchase remotes...")
    
    -- Look in common locations
    local locationsToCheck = {
        RS,
        RS:FindFirstChild("Network"),
        RS:FindFirstChild("Remotes"),
        RS:FindFirstChild("Events"),
        RS:FindFirstChild("Functions"),
        RS:FindFirstChild("Purchase"),
        RS:FindFirstChild("Shop")
    }
    
    for _, location in pairs(locationsToCheck) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                -- Check BOTH RemoteFunction AND RemoteEvent
                if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
                    local name = obj.Name:lower()
                    -- Broader search for relevant remotes
                    if name:find("purchase") or name:find("buy") 
                       or name:find("unlock") or name:find("equip")
                       or name:find("select") or name:find("apply")
                       or name:find("cosmetic") or name:find("item") then
                        
                        table.insert(purchaseRemotes, {
                            object = obj,
                            name = obj.Name,
                            className = obj.ClassName,
                            path = obj:GetFullName()
                        })
                    end
                end
            end
        end
    end
    
    -- Also check under PlayerGui for local remotes
    local PlayerGui = Player:WaitForChild("PlayerGui")
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("RemoteFunction") or obj:IsA("RemoteEvent") then
            local name = obj.Name:lower()
            if name:find("purchase") or name:find("buy") 
               or name:find("unlock") or name:find("equip") then
                
                table.insert(purchaseRemotes, {
                    object = obj,
                    name = obj.Name,
                    className = obj.ClassName,
                    path = obj:GetFullName()
                })
            end
        end
    end
    
    print("✅ Found " .. #purchaseRemotes .. " purchase remotes")
    
    -- Display found remotes for debugging
    for i, remote in ipairs(purchaseRemotes) do
        print("  [" .. i .. "] " .. remote.name .. " (" .. remote.className .. ")")
        print("      Path: " .. remote.path)
    end
    
    -- Enhanced unlock attempt with better debugging
    for _, cosmetic in ipairs(cosmetics.All) do
        print("\n🔄 Attempting to unlock: " .. cosmetic.name)
        print("   Category: " .. cosmetic.category)
        local unlocked = false
        
        for _, remote in ipairs(purchaseRemotes) do
            -- Try different data formats
            local formats = {
                -- Simple formats
                cosmetic.name,
                {ItemId = cosmetic.name},
                {id = cosmetic.name},
                {Name = cosmetic.name},
                
                -- With category
                {Item = cosmetic.name, Category = cosmetic.category},
                {id = cosmetic.name, type = cosmetic.category},
                {cosmeticName = cosmetic.name, cosmeticType = cosmetic.category},
                
                -- With car
                {ItemId = cosmetic.name, Car = carName},
                {cosmetic = cosmetic.name, vehicle = carName},
                
                -- Game-specific patterns
                {itemName = cosmetic.name, carName = carName},
                {selectedItem = cosmetic.name, itemType = cosmetic.category},
                {product = cosmetic.name, category = cosmetic.category}
            }
            
            for i, data in ipairs(formats) do
                print("   Trying format " .. i .. " with " .. remote.name .. "...")
                
                local success, result = pcall(function()
                    if remote.className == "RemoteFunction" then
                        return remote.object:InvokeServer(data)
                    else -- RemoteEvent
                        remote.object:FireServer(data)
                        return "FireServer called (no return)"
                    end
                end)
                
                if success then
                    print("   ✅ Success with " .. remote.name .. " (format " .. i .. ")")
                    print("   Result: " .. tostring(result))
                    results.unlocked = results.unlocked + 1
                    results.details[cosmetic.name] = "✅ Unlocked via " .. remote.name
                    unlocked = true
                    
                    -- Small success indication
                    if cosmetic.button then
                        cosmetic.button.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                        if cosmetic.button:IsA("TextButton") then
                            cosmetic.button.Text = "✓ UNLOCKED"
                        end
                    end
                    
                    break
                else
                    -- Print specific error
                    print("   ❌ Failed: " .. tostring(result))
                end
            end
            
            if unlocked then break end
        end
        
        if not unlocked then
            results.failed = results.failed + 1
            results.details[cosmetic.name] = "❌ Failed to unlock"
            print("   ❌ All attempts failed for: " .. cosmetic.name)
            
            -- Mark as failed
            if cosmetic.button then
                cosmetic.button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                if cosmetic.button:IsA("TextButton") then
                    cosmetic.button.Text = "FAILED"
                end
            end
        end
        
        task.wait(0.1) -- Slightly longer delay
    end
    
    -- Final debugging info
    print("\n📊 UNLOCK SESSION SUMMARY:")
    print("Total cosmetics: " .. results.total)
    print("Successfully unlocked: " .. results.unlocked)
    print("Failed: " .. results.failed)
    
    if results.unlocked > 0 then
        print("🎉 Some cosmetics were unlocked!")
    else
        print("⚠️ No cosmetics were unlocked. Possible reasons:")
        print("   - Wrong remote functions/events")
        print("   - Server-side validation")
        print("   - Need different data format")
        print("   - Game has anti-cheat")
    end
    
    return results
end
