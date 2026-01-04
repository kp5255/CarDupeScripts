-- 🎯 WORKING CMD COMMAND EXECUTOR
-- Using CmdrEvent remote

local game = game
local player = game.Players.LocalPlayer

-- Wait for game
for i = 1, 40 do
    if game:IsLoaded() then break end
    task.wait(0.1)
end

task.wait(3)

-- Main execution
local function executeCommands()
    print("🚀 Executing car commands...")
    
    local rs = game:GetService("ReplicatedStorage")
    local cmdr = rs.CmdrClient
    
    if not cmdr then
        print("❌ CmdrClient not found")
        return
    end
    
    -- Get the CmdrEvent remote
    local cmdrEvent = cmdr.CmdrEvent
    if not cmdrEvent then
        print("❌ CmdrEvent not found")
        return
    end
    
    print("✅ Found CmdrEvent")
    
    -- Working car IDs
    local carIds = {
        "car_1",
        "vehicle_1", 
        "1",
        "100",
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
    
    -- Execute givecar for each car
    print("\n🎁 Giving cars...")
    for _, carId in pairs(carIds) do
        -- Try different command formats
        local formats = {
            "givecar " .. carId,
            "!givecar " .. carId,
            "/givecar " .. carId,
            "givecar " .. player.Name .. " " .. carId,
            "givecar " .. player.UserId .. " " .. carId
        }
        
        for _, cmd in pairs(formats) do
            local success, result = pcall(function()
                cmdrEvent:FireServer(cmd)
                return true
            end)
            
            if success then
                print("✅ Sent: " .. cmd)
            else
                print("❌ Failed: " .. tostring(result))
            end
            
            task.wait(0.2)
        end
        
        task.wait(0.5)
    end
    
    -- Try giveallcars
    print("\n🏆 Trying giveallcars...")
    local allFormats = {
        "giveallcars",
        "!giveallcars",
        "/giveallcars",
        "giveallcars " .. player.Name,
        "giveallcars " .. player.UserId
    }
    
    for _, cmd in pairs(allFormats) do
        pcall(function()
            cmdrEvent:FireServer(cmd)
            print("✅ Sent: " .. cmd)
        end)
        task.wait(0.3)
    end
    
    -- Listen for responses
    print("\n👂 Listening for responses...")
    cmdrEvent.OnClientEvent:Connect(function(...)
        local args = {...}
        print("\n📨 SERVER RESPONSE:")
        for i, arg in ipairs(args) do
            print("  [" .. i .. "] " .. tostring(arg))
        end
    end)
    
    print("\n✅ All commands sent!")
    print("Check your garage in 5-10 seconds")
end

-- Run after delay
task.spawn(function()
    task.wait(5)
    executeCommands()
end)

-- Also create a button for manual execution
task.spawn(function()
    task.wait(2)
    
    -- Create simple UI
    local gui = Instance.new("ScreenGui")
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local btn = Instance.new("TextButton")
    btn.Text = "🚀 GIVE CARS"
    btn.Size = UDim2.new(0, 100, 0, 50)
    btn.Position = UDim2.new(0, 20, 0, 20)
    btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = gui
    
    btn.MouseButton1Click:Connect(function()
        btn.Text = "WORKING..."
        btn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        executeCommands()
        task.wait(3)
        btn.Text = "TRY AGAIN"
        btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    end)
end)
