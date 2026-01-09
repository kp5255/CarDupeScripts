-- NO UI - CONSOLE ONLY VERSION
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TradingRemotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local SessionSetConfirmation = TradingRemotes:WaitForChild("SessionSetConfirmation")

local ItemDetected = false

-- Auto-detect item
local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")
OnSessionItemsUpdated.OnClientEvent:Connect(function(data)
    if data and data[LocalPlayer.UserId] then
        if #data[LocalPlayer.UserId] > 0 then
            ItemDetected = true
            print("✅ Car detected!")
        end
    end
end)

-- Simple function
local function dupe()
    if not ItemDetected then
        print("❌ Add car to trade first!")
        return
    end
    
    print("🚀 Starting dupe...")
    
    -- Step 1: Accept
    pcall(function()
        SessionSetConfirmation:InvokeServer(true)
    end)
    
    wait(1)
    
    -- Step 2: Cancel
    pcall(function()
        SessionSetConfirmation:InvokeServer(false)
    end)
    
    print("✅ Dupe attempt complete!")
    print("Check your inventory!")
end

-- Bind to key (optional)
local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then
        dupe()
    end
end)

print("\n" .. string.rep("=", 40))
print("CONSOLE DUPE SCRIPT")
print("=" .. string.rep("=", 39))
print("INSTRUCTIONS:")
print("1. Start trade")
print("2. Add car to trade")
print("3. Wait for 'Car detected!'")
print("4. Type: dupe()")
print("5. Other player must accept")
print("6. Check if car duplicated!")
print(string.rep("=", 40))

-- Make function global
_G.dupe = dupe
