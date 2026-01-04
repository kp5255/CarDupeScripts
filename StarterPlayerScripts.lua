-- Simple car command
wait(5)

local RS = game:GetService("ReplicatedStorage")
local cmdr = RS:FindFirstChild("CmdrClient")
if cmdr then
    local commands = cmdr:FindFirstChild("Commands")
    if commands then
        local givecar = commands:FindFirstChild("GiveCar")
        if givecar then
            local func = require(givecar)
            local player = game.Players.LocalPlayer
            
            -- Try to give cars
            local cars = {"Bontlay Bontaga", "Jegar Model F", "Corsaro T8"}
            
            for _, car in pairs(cars) do
                wait(1)
                pcall(function()
                    if type(func) == "function" then
                        func(player, car)
                    end
                end)
            end
        end
    end
end
