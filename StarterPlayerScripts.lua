local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function scan(root, label)
    print("\n========== " .. label .. " ==========")

    local count = 0

    for _, obj in ipairs(root:GetDescendants()) do
        local class = obj.ClassName
        local name = obj.Name:lower()

        if name:find("car")
        or name:find("vehicle")
        or name:find("inventory")
        or name:find("garage")
        or name:find("owned")
        or name:find("collection")
        or class == "Folder"
        or class == "Value"
        or class:find("Value") then

            count += 1

            print(
                string.format(
                    "[%d] %s | %s",
                    count,
                    class,
                    obj:GetFullName()
                )
            )
        end
    end

    print("Objects discovered:", count)
end

scan(Players.LocalPlayer, "LOCAL PLAYER")
scan(ReplicatedStorage, "REPLICATED STORAGE")
