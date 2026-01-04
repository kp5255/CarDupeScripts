-- 🥷 CORRECT CAR COMMAND EXECUTION
-- Module returns command config table

local game = game
local player = game.Players.LocalPlayer

-- Silent wait
for i = 1, 40 do
    if game:IsLoaded() then break end
    task.wait(0.1)
end

task.wait(3)

-- Main execution
local function executeCarCommands()
    local rs = game:GetService("ReplicatedStorage")
    local cmdr = rs.CmdrClient
    if not cmdr then return end
    
    -- Find command executor
    local executor
    for _, obj in pairs(cmdr:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:find("Execute") then
            executor = obj
            break
        end
    end
    
    if not executor then
        -- Try to find any remote that might execute commands
        for _, obj in pairs(cmdr:GetChildren()) do
            if obj:IsA("RemoteEvent") then
                executor = obj
                break
            end
        end
    end
    
    if not executor then return end
    
    -- Get command config from GiveCar module
    local commandsFolder = cmdr.Commands
    if not commandsFolder then return end
    
    local giveCarModule = commandsFolder.GiveCar
    if not giveCarModule then return end
    
    local commandConfig
    local success, result = pcall(function()
        return require(giveCarModule)
    end)
    
    if not success then return end
    commandConfig = result
    
    -- Get GiveAllCars config
    local giveAllModule = commandsFolder.GiveAllCars
    local giveAllConfig
    if giveAllModule then
        pcall(function()
            giveAllConfig = require(giveAllModule)
        end)
    end
    
    -- Working car IDs
    local carIds = {
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
    
    -- Execute commands
    for _, carId in pairs(carIds) do
        task.wait(0.5)
        
        -- Format 1: Command string
        pcall(function()
            executor:FireServer("givecar " .. carId)
        end)
        
        task.wait(0.2)
        
        -- Format 2: With player
        pcall(function()
            executor:FireServer(player, "givecar " .. carId)
        end)
        
        task.wait(0.2)
        
        -- Format 3: Command table
        pcall(function()
            executor:FireServer({
                Command = "givecar",
                Arguments = carId,
                Player = player
            })
        end)
    end
    
    -- Try giveallcars
    if giveAllConfig then
        task.wait(1)
        pcall(function() executor:FireServer("giveallcars") end)
        task.wait(0.3)
        pcall(function() executor:FireServer(player, "giveallcars") end)
    end
end

-- Run
task.spawn(function()
    task.wait(5)
    executeCarCommands()
end)
