-- UNIVERSAL TRADE DUPE SCRIPT
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🔍 Searching for ALL trading remotes...")

-- Find ALL remotes in the entire game that might be trading related
local allRemotes = {}
local function collectRemotes(parent, path)
    for _, child in pairs(parent:GetChildren()) do
        local fullPath = path .. "." .. child.Name
        
        if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
            -- Check if it might be trading related
            local nameLower = child.Name:lower()
            if nameLower:find("trade") or 
               nameLower:find("session") or 
               nameLower:find("confirm") or
               nameLower:find("accept") or
               nameLower:find("cancel") then
                allRemotes[fullPath] = child
                print("Found: " .. fullPath .. " (" .. child.ClassName .. ")")
            end
        end
        
        -- Recursively search
        if #child:GetChildren() > 0 then
            collectRemotes(child, fullPath)
        end
    end
end

collectRemotes(game, "game")

-- Also check common locations
local commonPaths = {
    ReplicatedStorage:WaitForChild("Remotes"),
    ReplicatedStorage:WaitForChild("Events"),
    ReplicatedStorage:WaitForChild("Network"),
    ReplicatedStorage:WaitForChild("Trading"),
    game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
}

for _, path in pairs(commonPaths) do
    if path then
        collectRemotes(path, path.Name)
    end
end

print("\n🎯 Found " .. #allRemotes .. " potential trading remotes")

-- Try to find the main trade confirmation remote
local mainTradeRemote = nil
for path, remote in pairs(allRemotes) do
    if remote.Name:lower():find("confirm") or remote.Name:lower():find("accept") then
        mainTradeRemote = remote
        print("🎯 Selected main remote: " .. path)
        break
    end
end

if not mainTradeRemote then
    -- Just use the first remote found
    for path, remote in pairs(allRemotes) do
        mainTradeRemote = remote
        print("⚠️ Using first remote: " .. path)
        break
    end
end

if not mainTradeRemote then
    warn("❌ No trading remotes found!")
    return
end

-- Install UNIVERSAL hook on ALL trading remotes
print("\n🔧 Installing universal hook on ALL trading remotes...")

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local hookInstalled = false

local function installUniversalHook()
    if hookInstalled then return end
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Check if this is ANY remote call
        if method == "InvokeServer" or method == "FireServer" then
            local remoteName = tostring(self)
            
            -- Check if it's a trading-related remote
            if remoteName:lower():find("trade") or 
               remoteName:lower():find("session") or
               remoteName:lower():find("confirm") or
               table.find(allRemotes, self) then
                
                print("[UNIVERSAL HOOK] " .. remoteName .. ":" .. method .. "(" .. tostring(args[1]) .. ")")
                
                -- If this looks like an accept (true or "accept")
                local isAccept = false
                if args[1] == true then
                    isAccept = true
                elseif type(args[1]) == "string" and args[1]:lower():find("accept") then
                    isAccept = true
                elseif type(args[1]) == "number" and args[1] == 1 then
                    isAccept = true
                end
                
                if isAccept then
                    print("[UNIVERSAL HOOK] 🎯 ACCEPT DETECTED!")
                    
                    -- Send original
                    local result = oldNamecall(self, ...)
                    
                    -- Queue auto-cancel
                    spawn(function()
                        wait(0.001)
                        
                        -- Try different cancel methods
                        if method == "InvokeServer" then
                            -- Try false
                            pcall(function()
                                print("[UNIVERSAL HOOK] Sending cancel (false)")
                                oldNamecall(self, false)
                            end)
                            
                            -- Try 0
                            pcall(function()
                                print("[UNIVERSAL HOOK] Sending cancel (0)")
                                oldNamecall(self, 0)
                            end)
                            
                            -- Try "cancel"
                            pcall(function()
                                print("[UNIVERSAL HOOK] Sending cancel (string)")
                                oldNamecall(self, "cancel")
                            end)
                        else
                            -- For FireServer, just try multiple times
                            for i = 1, 3 do
                                pcall(function()
                                    oldNamecall(self, false)
                                end)
                                wait(0.001)
                            end
                        end
                    end)
                    
                    return result
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
    hookInstalled = true
    print("✅ UNIVERSAL HOOK INSTALLED!")
    print("Will intercept ALL trading remote calls")
end

-- Simple dupe function
local function universalDupe()
    print("\n🚀 UNIVERSAL DUPE STARTING...")
    
    -- Install hook if not already
    if not hookInstalled then
        installUniversalHook()
    end
    
    -- Try to trigger trade with main remote
    print("Attempting to trigger trade...")
    
    -- Try different parameter combinations
    local testParams = {true, false, 1, 0, "accept", "cancel", "trade", {}}
    
    for _, param in pairs(testParams) do
        pcall(function()
            if mainTradeRemote:IsA("RemoteFunction") then
                print("Testing: " .. mainTradeRemote.Name .. ":InvokeServer(" .. tostring(param) .. ")")
                mainTradeRemote:InvokeServer(param)
            elseif mainTradeRemote:IsA("RemoteEvent") then
                print("Testing: " .. mainTradeRemote.Name .. ":FireServer(" .. tostring(param) .. ")")
                mainTradeRemote:FireServer(param)
            end
        end)
        wait(0.5)
    end
    
    print("✅ Universal dupe attempt complete!")
    print("Check your inventory!")
end

-- BRUTE FORCE ATTACK
local function bruteForceAttack()
    print("\n💥 BRUTE FORCE ATTACK")
    
    -- Install hook
    if not hookInstalled then
        installUniversalHook()
    end
    
    -- Attack ALL found remotes
    for path, remote in pairs(allRemotes) do
        print("\nAttacking: " .. path)
        
        -- Send multiple packets to each remote
        for i = 1, 10 do
            spawn(function()
                pcall(function()
                    if remote:IsA("RemoteFunction") then
                        remote:InvokeServer(true)
                        remote:InvokeServer(false)
                    elseif remote:IsA("RemoteEvent") then
                        remote:FireServer(true)
                        remote:FireServer(false)
                    end
                end)
            end)
            wait(0.01)
        end
        
        wait(0.5)
    end
    
    print("✅ Brute force attack complete!")
end

-- CREATE UI
local gui = Instance.new("ScreenGui")
gui.Name = "UniversalDupe"
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 140)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
frame.BorderSizePixel = 3
frame.BorderColor3 = Color3.new(1, 0.5, 0)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "🎯 UNIVERSAL DUPE"
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Buttons
local btnInstall = Instance.new("TextButton")
btnInstall.Text = "🔧 INSTALL HOOK"
btnInstall.Size = UDim2.new(0.9, 0, 0, 25)
btnInstall.Position = UDim2.new(0.05, 0, 0.2, 0)
btnInstall.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
btnInstall.TextColor3 = Color3.new(1, 1, 1)
btnInstall.Parent = frame
btnInstall.MouseButton1Click:Connect(installUniversalHook)

local btnDupe = Instance.new("TextButton")
btnDupe.Text = "🚀 START DUPE"
btnDupe.Size = UDim2.new(0.9, 0, 0, 25)
btnDupe.Position = UDim2.new(0.05, 0, 0.45, 0)
btnDupe.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btnDupe.TextColor3 = Color3.new(1, 1, 1)
btnDupe.Parent = frame
btnDupe.MouseButton1Click:Connect(universalDupe)

local btnBrute = Instance.new("TextButton")
btnBrute.Text = "💥 BRUTE FORCE"
btnBrute.Size = UDim2.new(0.9, 0, 0, 25)
btnBrute.Position = UDim2.new(0.05, 0, 0.7, 0)
btnBrute.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
btnBrute.TextColor3 = Color3.new(1, 1, 1)
btnBrute.Parent = frame
btnBrute.MouseButton1Click:Connect(bruteForceAttack)

-- Status
local status = Instance.new("TextLabel")
status.Text = "Found " .. #allRemotes .. " remotes"
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0.95, 0)
status.TextColor3 = Color3.new(1, 1, 1)
status.TextSize = 10
status.Parent = frame

print("\n" .. string.rep("=", 60))
print("🎯 UNIVERSAL TRADE DUPE")
print(string.rep("=", 60))
print("This script:")
print("1. Searches ALL remotes in the game")
print("2. Finds trading-related remotes")
print("3. Hooks ALL of them automatically")
print("4. Auto-cancels when detects accepts")
print(string.rep("=", 60))
print("INSTRUCTIONS:")
print("1. Click '🔧 INSTALL HOOK'")
print("2. Start trade normally in game")
print("3. Add car to trade")
print("4. Click '🚀 START DUPE'")
print("5. Accept trade in game")
print("6. Hook will auto-cancel")
print(string.rep("=", 60))

-- Make global
_G.install = installUniversalHook
_G.dupe = universalDupe
_G.brute = bruteForceAttack
_G.remotes = allRemotes

print("\nConsole commands:")
print("_G.install() - Install universal hook")
print("_G.dupe()    - Run universal dupe")
print("_G.brute()   - Brute force attack")
print("_G.remotes   - List of found remotes")
