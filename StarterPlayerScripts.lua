-- 🥷 STEALTH CAR GIVER (FIXED)
-- Module returns table, not function

local game = game
local player = game.Players.LocalPlayer

-- Silent wait
for i = 1, 50 do
    if game:IsLoaded() then break end
    task.wait(0.1)
end

task.wait(4)

-- Main function
local function giveCarsStealth()
    local rs = game:GetService("ReplicatedStorage")
    local cmdr = rs.CmdrClient
    if not cmdr then return end
    
    local commands = cmdr.Commands
    if not commands then return end
    
    -- Get GiveCar module
    local giveCar = commands.GiveCar
    if not giveCar then return end
    
    -- Load module (returns TABLE)
    local moduleTable
    local success, result = pcall(function()
        return require(giveCar)
    end)
    
    if not success then return end
    moduleTable = result
    
    -- Get GiveAllCars
    local giveAll = commands.GiveAllCars
    if giveAll then
        pcall(function()
            local allTable = require(giveAll)
            -- Try to find execute function
            if type(allTable) == "table" then
                for _, func in pairs(allTable) do
                    if type(func) == "function" then
                        func(player)
                        break
                    end
                end
            elseif type(allTable) == "function" then
                allTable(player)
            end
        end)
        task.wait(1)
    end
    
    -- Working IDs
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
    
    -- Give each car
    for _, id in pairs(ids) do
        task.wait(0.4 + math.random() * 0.3) -- Random delay
        
        -- Try to call function from table
        pcall(function()
            if type(moduleTable) == "table" then
                -- Look for Execute function
                if moduleTable.Execute and type(moduleTable.Execute) == "function" then
                    moduleTable.Execute(player, id)
                -- Look for Run function
                elseif moduleTable.Run and type(moduleTable.Run) == "function" then
                    moduleTable.Run(player, id)
                -- Try any function in table
                else
                    for _, func in pairs(moduleTable) do
                        if type(func) == "function" then
                            func(player, id)
                            break
                        end
                    end
                end
            elseif type(moduleTable) == "function" then
                moduleTable(player, id)
            end
        end)
    end
end

-- Run in background
task.spawn(function()
    task.wait(6)
    giveCarsStealth()
    
    -- Try again after 20 seconds
    task.wait(20)
    giveCarsStealth()
end)
