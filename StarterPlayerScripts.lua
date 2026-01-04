-- 🥷 STEALTH CAR DUPLICATOR
-- Place ID: 1554960397

-- Disguise as normal script
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Wait discreetly
for i = 1, 30 do
    if game:IsLoaded() then break end
    task.wait(0.1)
end

task.wait(2)

-- ===== STEALTH MODULE ACCESS =====
local function stealthAccess()
    -- Use minimal logging
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Find Cmdr system quietly
    local cmdrPath = ReplicatedStorage:FindFirstChild("CmdrClient")
    if not cmdrPath then return end
    
    -- Get commands folder
    local commands = cmdrPath:FindFirstChild("Commands")
    if not commands then return end
    
    -- Get givecar module
    local giveCar = commands:FindFirstChild("GiveCar")
    if not giveCar then return end
    
    -- Try to load it quietly
    local success, moduleFunc = pcall(function()
        return require(giveCar)
    end)
    
    if not success then return end
    
    -- Your cars
    local targetCars = {
        "Bontlay Bontaga",
        "Jegar Model F",
        "Corsaro T8"
    }
    
    -- Execute commands with delay
    for _, car in ipairs(targetCars) do
        task.wait(0.5) -- Slow to avoid detection
        
        -- Try to execute command
        pcall(function()
            if type(moduleFunc) == "function" then
                moduleFunc(player, car)
            elseif type(moduleFunc) == "table" then
                -- Look for execute function
                for key, value in pairs(moduleFunc) do
                    if type(value) == "function" and key:lower():find("exec") then
                        value(player, car)
                        break
                    end
                end
            end
        end)
    end
end

-- ===== STEALTH REMOTE EXECUTION =====
local function stealthRemote()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Look for command execution remote
    local executeRemote = ReplicatedStorage:FindFirstChild("CmdrClient")
    if executeRemote then
        executeRemote = executeRemote:FindFirstChild("ExecuteCommand")
    end
    
    if not executeRemote then return end
    
    -- Try commands slowly
    local commands = {
        "givecar Bontlay Bontaga",
        "giveallcars"
    }
    
    for _, cmd in ipairs(commands) do
        task.wait(1) -- Slow delay
        
        pcall(function()
            if executeRemote:IsA("RemoteEvent") then
                executeRemote:FireServer(cmd)
            elseif executeRemote:IsA("RemoteFunction") then
                executeRemote:InvokeServer(cmd)
            end
        end)
    end
end

-- ===== MAIN (DISGUISED) =====
-- Run in background thread
task.spawn(function()
    -- Wait longer to avoid detection
    task.wait(5)
    
    -- Try stealth methods
    stealthAccess()
    
    task.wait(3)
    stealthRemote()
    
    -- Check for results
    task.wait(5)
    
    -- Minimal success check
    if player:FindFirstChild("leaderstats") then
        local money = player.leaderstats:FindFirstChild("Money")
        if money then
            -- Just note money, don't print
            local _ = money.Value
        end
    end
end)

-- Return innocent value
return "Script loaded successfully"
