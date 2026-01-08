-- Car Duplication Script for Trading System
-- Use with Delta Executor

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Find the trading remote
local TradingRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Services"):WaitForChild("TradingServiceRemotes")
local OnSessionItemsUpdated = TradingRemotes:WaitForChild("OnSessionItemsUpdated")

-- Store original remote fire function
local originalFireServer
local isHooked = false

-- Item cache to duplicate
local itemsToDuplicate = {}
local tradeSession = nil

-- Hook the remote to intercept trades
local function hookTradeRemote()
    if isHooked then return end
    
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Check if this is our trading remote being fired
        if method == "FireServer" and tostring(self) == "OnSessionItemsUpdated" then
            print("[TRADE HOOK] Intercepted trade update")
            
            -- args[1] is usually the trade session data
            if args[1] and type(args[1]) == "table" then
                tradeSession = args[1]
                print("[TRADE HOOK] Session captured:", tradeSession)
                
                -- Look for your items in the trade
                if tradeSession.players then
                    for playerId, items in pairs(tradeSession.players) do
                        if playerId == LocalPlayer.UserId then
                            print("[TRADE HOOK] Your items in trade:", #items)
                            itemsToDuplicate = items
                        end
                    end
                end
                
                -- Here's the dupe logic - we could modify the data before it reaches server
                -- OR we could send false data back to client
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
    isHooked = true
    print("[TRADE HOOK] Remote hooked successfully!")
end

-- Alternative: Listen to the remote and try to disrupt the trade
local function setupTradeListener()
    -- First, let's see what other remotes exist in TradingServiceRemotes
    for _, remote in pairs(TradingRemotes:GetChildren()) do
        print("Found trade remote:", remote.Name, remote.ClassName)
    end
    
    -- Common trade remotes might include:
    -- AddItemToTrade, RemoveItemFromTrade, AcceptTrade, CancelTrade, StartTrade
    
    -- Try to find and hook all trade remotes
    local tradeRemotes = {
        "AddItemToTrade",
        "RemoveItemFromTrade", 
        "AcceptTrade",
        "ConfirmTrade",
        "StartTrade",
        "CancelTrade",
        "TradeRequest"
    }
    
    for _, remoteName in pairs(tradeRemotes) do
        local remote = TradingRemotes:FindFirstChild(remoteName)
        if remote then
            print("Hooking remote:", remoteName)
            
            -- Store original
            local originalFire = remote.FireServer
            remote.FireServer = function(self, ...)
                local args = {...}
                print("[TRADE] " .. remoteName .. " fired with args:", args)
                
                -- DUPE TECHNIQUE 1: Delay the accept to cause desync
                if remoteName == "AcceptTrade" then
                    wait(2) -- Add delay to cause timing issue
                    print("[DUPE] Added delay to accept trade - might cause desync!")
                end
                
                -- DUPE TECHNIQUE 2: Send duplicate accept packets
                if remoteName == "AcceptTrade" then
                    spawn(function()
                        for i = 1, 3 do
                            originalFire(remote, unpack(args))
                            wait(0.1)
                        end
                    end)
                    return
                end
                
                return originalFire(self, ...)
            end
        end
    end
end

-- Try to duplicate by cancelling at the right moment
local function quickCancelDupe()
    -- This method tries to accept and cancel simultaneously
    local AddItemRemote = TradingRemotes:FindFirstChild("AddItemToTrade")
    local CancelRemote = TradingRemotes:FindFirstChild("CancelTrade")
    local AcceptRemote = TradingRemotes:FindFirstChild("AcceptTrade")
    
    if AddItemRemote and CancelRemote and AcceptRemote then
        print("[QUICK CANCEL DUPE] Attempting duplication...")
        
        -- Step 1: Add your car to trade
        -- You need to find your car's instance or ID
        AddItemRemote:FireServer("car_instance_or_id_here")
        
        -- Step 2: Wait for other player to accept (or auto-accept if you control both accounts)
        wait(1)
        
        -- Step 3: The dupe - accept and cancel at nearly the same time
        spawn(function()
            AcceptRemote:FireServer()
        end)
        
        spawn(function()
            wait(0.05) -- Tiny delay
            CancelRemote:FireServer()
        end)
        
        print("[QUICK CANCEL DUPE] Dupe attempt completed!")
    else
        warn("[QUICK CANCEL DUPE] Missing required remotes!")
    end
end

-- Main function to try different dupe methods
local function attemptDuplication()
    print("=== CAR DUPLICATION SCRIPT ===")
    print("1. Hooking trade remotes...")
    hookTradeRemote()
    
    print("2. Setting up trade listeners...")
    setupTradeListener()
    
    print("3. Ready for duplication!")
    print("")
    print("HOW TO USE:")
    print("1. Start a trade with another player")
    print("2. Add your car to the trade")
    print("3. Try accepting/cancelling rapidly")
    print("4. If successful, you'll keep the car AND they'll get it too")
    print("")
    print("Alternative: Use quickCancelDupe() function")
end

-- Run the script
attemptDuplication()

-- UI for easy access
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "Car Duplicator v1.0"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Parent = Frame

local QuickDupeBtn = Instance.new("TextButton")
QuickDupeBtn.Text = "Quick Cancel Dupe"
QuickDupeBtn.Size = UDim2.new(0.9, 0, 0, 40)
QuickDupeBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
QuickDupeBtn.Parent = Frame
QuickDupeBtn.MouseButton1Click:Connect(quickCancelDupe)

local Status = Instance.new("TextLabel")
Status.Text = "Status: Ready"
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0.7, 0)
Status.TextColor3 = Color3.new(0, 1, 0)
Status.Parent = Frame

print("Duplication script loaded! GUI created.")
