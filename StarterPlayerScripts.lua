-- 🥷 STEALTH CAR ID FINDER
-- Place ID: 1554960397

-- Use minimal code to avoid detection
local game = game
local player = game.Players.LocalPlayer

-- Wait quietly
for i = 1, 50 do
    if game:IsLoaded() then break end
    task.wait(0.1)
end

task.wait(3)

-- ===== STEALTH CAR ID TEST =====
local function stealthTest()
    -- Get GiveCar module quietly
    local rs = game:GetService("ReplicatedStorage")
    local cmdr = rs:FindFirstChild("CmdrClient")
    if not cmdr then return end
    
    local commands = cmdr:FindFirstChild("Commands")
    if not commands then return end
    
    local giveCar = commands:FindFirstChild("GiveCar")
    if not giveCar then return end
    
    -- Try to load module
    local func
    local success, result = pcall(function()
        return require(giveCar)
    end)
    
    if not success then return end
    func = result
    
    -- Test a FEW key IDs quietly
    local testIds = {
        -- Common formats
        "car_1",
        "vehicle_1",
        "1",
        "100",
        
        -- Your cars in different formats
        "bontlay_bontaga",
        "bontlaybontaga",
        "BontlayBontaga",
        
        "jegar_model_f",
        "jegarmodelf",
        "JegarModelF",
        
        "corsaro_t8",
        "corsarot8",
        "CorsaroT8"
    }
    
    -- Test quietly with minimal output
    for _, id in pairs(testIds) do
        task.wait(0.2) -- Slow to avoid detection
        
        local callSuccess = pcall(function()
            if type(func) == "function" then
                func(player, id)
                return true
            elseif type(func) == "table" then
                for key, f in pairs(func) do
                    if type(f) == "function" then
                        f(player, id)
                        return true
                    end
                end
            end
        end)
        
        if callSuccess then
            -- Minimal success logging
            warn("[SUCCESS] ID: " .. id)
        end
    end
end

-- ===== GET CAR DATA FROM UI =====
local function getCarIdsFromUI()
    -- Look at what cars you actually own in the UI
    
    -- Wait for UI to load
    task.wait(5)
    
    if player:FindFirstChild("PlayerGui") then
        -- Look for car lists in UI
        for _, gui in pairs(player.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                -- Search for text showing your cars
                for _, obj in pairs(gui:GetDescendants()) do
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        local text = obj.Text
                        if text and (text:find("Bontlay") or text:find("Jegar") or text:find("Corsaro")) then
                            warn("[UI FOUND] " .. text)
                        end
                    end
                end
            end
        end
    end
end

-- ===== MAIN (HIDDEN) =====
-- Run in background
task.spawn(function()
    task.wait(5) -- Wait longer to avoid detection
    
    -- Try stealth test
    stealthTest()
    
    -- Get UI data
    task.wait(3)
    getCarIdsFromUI()
    
    -- Wait and try one more time
    task.wait(5)
    stealthTest()
end)

-- Return nothing to look innocent
