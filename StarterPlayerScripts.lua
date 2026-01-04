-- 🥷 STEALTH CAR GIVER
-- Minimal, undetectable version

-- No prints, no warnings
local game = game
local player = game.Players.LocalPlayer

-- Silent wait
for i = 1, 60 do
    if game:IsLoaded() then break end
    task.wait(0.1)
end

task.wait(5)

-- Main function (completely silent)
local function silentGiveCars()
    -- Get modules quietly
    local rs = game:GetService("ReplicatedStorage")
    local cmdr = rs:FindFirstChild("CmdrClient")
    if not cmdr then return end
    
    local commands = cmdr:FindFirstChild("Commands")
    if not commands then return end
    
    -- Get GiveCar
    local giveCar = commands:FindFirstChild("GiveCar")
    if not giveCar then return end
    
    -- Load quietly
    local func
    local success, result = pcall(function()
        return require(giveCar)
    end)
    
    if not success then return end
    func = result
    
    -- Get GiveAllCars
    local giveAll = commands:FindFirstChild("GiveAllCars")
    if giveAll then
        pcall(function()
            local allFunc = require(giveAll)
            if type(allFunc) == "function" then
                allFunc(player)
            elseif type(allFunc) == "table" then
                for _, f in pairs(allFunc) do
                    if type(f) == "function" then
                        f(player)
                        break
                    end
                end
            end
        end)
    end
    
    -- Working IDs from your test
    local ids = {
        "car_1",
        "vehicle_1",
        "1",
        "100",
        "bontlay_bontaga",
        "bontlaybontaga",
        "jegar_model_f",
        "jegarmodelf",
        "corsaro_t8",
        "corsarot8"
    }
    
    -- Give cars with random delays
    for _, id in pairs(ids) do
        -- Random delay 0.3-0.7 seconds
        task.wait(0.3 + math.random() * 0.4)
        
        pcall(function()
            if type(func) == "function" then
                func(player, id)
            elseif type(func) == "table" then
                for _, f in pairs(func) do
                    if type(f) == "function" then
                        f(player, id)
                        break
                    end
                end
            end
        end)
    end
end

-- Run in background thread
task.spawn(function()
    task.wait(8) -- Wait longer
    silentGiveCars()
    
    -- Second attempt after 15 seconds
    task.wait(15)
    silentGiveCars()
end)

-- Return nothing
