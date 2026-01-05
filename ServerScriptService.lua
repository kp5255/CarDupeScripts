-- 🎯 CAR DEALERSHIP TYCOON - CUSTOMIZATION FINDER
-- This will find how customizations work in the updated game

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

print("🔍 FINDING CUSTOMIZATION SYSTEM")
print("=" .. string.rep("=", 50))

-- ===== FIND ALL REMOTES =====
print("\n📡 SEARCHING FOR REMOTE EVENTS/FUNCTIONS...")
local allRemotes = {}

for _, obj in pairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        table.insert(allRemotes, {
            Name = obj.Name,
            Type = obj.ClassName,
            Path = obj:GetFullName()
        })
    end
end

print("Found " .. #allRemotes .. " remotes")

-- Filter for customization-related remotes
print("\n🎯 CUSTOMIZATION-RELATED REMOTES:")
local customizationRemotes = {}
for _, remote in ipairs(allRemotes) do
    local nameLower = remote.Name:lower()
    if nameLower:find("custom") or nameLower:find("paint") or nameLower:find("wrap") or 
       nameLower:find("color") or nameLower:find("skin") or nameLower:find("upgrade") or
       nameLower:find("unlock") or nameLower:find("purchase") or nameLower:find("buy") then
        table.insert(customizationRemotes, remote)
        print("• " .. remote.Name .. " (" .. remote.Type .. ")")
        print("  Path: " .. remote.Path)
    end
end

-- ===== FIND CUSTOMIZATION SERVICES =====
print("\n🔧 SEARCHING FOR SERVICES...")
local services = game:GetService("ReplicatedStorage"):GetDescendants()
local customizationServices = {}

for _, service in ipairs(services) do
    if service:IsA("ModuleScript") then
        local nameLower = service.Name:lower()
        if nameLower:find("custom") or nameLower:find("paint") or nameLower:find("wrap") or
           nameLower:find("upgrade") or nameLower:find("mod") then
            table.insert(customizationServices, service)
            print("• " .. service.Name .. " (ModuleScript)")
            print("  Path: " .. service:GetFullName())
        end
    end
end

-- ===== TEST SPECIFIC REMOTES =====
print("\n🧪 TESTING KEY REMOTES...")

-- Common customization remote names (after updates)
local testRemotes = {
    "UnlockAllCustomizations",
    "PurchaseCustomization",
    "BuyCustomization",
    "EquipCustomization",
    "ApplyCustomization",
    "GetCustomizations",
    "CustomizationService",
    "CarCustomization",
    "VehicleCustomization"
}

for _, remoteName in ipairs(testRemotes) do
    local found = false
    
    for _, remote in ipairs(allRemotes) do
        if remote.Name == remoteName then
            found = true
            print("✅ Found: " .. remoteName)
            print("   Type: " .. remote.Type)
            print("   Path: " .. remote.Path)
            
            -- Try to test it
            local success, result = pcall(function()
                if remote.Type == "RemoteFunction" then
                    return game:GetService("ReplicatedStorage"):FindFirstChild(remoteName, true):InvokeServer()
                else
                    game:GetService("ReplicatedStorage"):FindFirstChild(remoteName, true):FireServer()
                    return "Event fired"
                end
            end)
            
            if success then
                print("   Test: SUCCESS - " .. tostring(result))
            else
                print("   Test: FAILED - " .. tostring(result))
            end
            break
        end
    end
    
    if not found then
        print("❌ Not found: " .. remoteName)
    end
end

-- ===== FIND CUSTOMIZATION UI =====
print("\n🖥️ SEARCHING FOR CUSTOMIZATION UI...")
local playerGui = player:WaitForChild("PlayerGui")

if playerGui then
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("ScreenGui") then
            local nameLower = gui.Name:lower()
            if nameLower:find("custom") or nameLower:find("upgrade") or nameLower:find("mod") then
                print("• UI Found: " .. gui.Name)
                print("  Class: " .. gui.ClassName)
            end
        end
    end
end

-- ===== CREATE SIMPLE FIX BUTTON =====
print("\n🎨 CREATING TEMPORARY FIX UI...")

local fixGui = Instance.new("ScreenGui")
fixGui.Name = "CustomizationFix"
fixGui.Parent = player.PlayerGui
fixGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0, 20, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
mainFrame.Parent = fixGui

local title = Instance.new("TextLabel")
title.Text = "🔧 Customization Fix"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

local status = Instance.new("TextLabel")
status.Text = "Run diagnostic above first"
status.Size = UDim2.new(1, -20, 0, 80)
status.Position = UDim2.new(0, 10, 0, 50)
status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
status.TextColor3 = Color3.new(1, 1, 1)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextWrapped = true
status.Parent = mainFrame

local testButton = Instance.new("TextButton")
testButton.Text = "TEST UNLOCK"
testButton.Size = UDim2.new(1, -20, 0, 40)
testButton.Position = UDim2.new(0, 10, 0, 140)
testButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
testButton.TextColor3 = Color3.new(1, 1, 1)
testButton.Font = Enum.Font.GothamBold
testButton.TextSize = 14
testButton.Parent = mainFrame

-- Round corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = mainFrame

local corner2 = Instance.new("UICorner")
corner2.CornerRadius = UDim.new(0, 6)
corner2.Parent = title

local corner3 = Instance.new("UICorner")
corner3.CornerRadius = UDim.new(0, 6)
corner3.Parent = status

local corner4 = Instance.new("UICorner")
corner4.CornerRadius = UDim.new(0, 6)
corner4.Parent = testButton

-- Test button functionality
testButton.MouseButton1Click:Connect(function()
    status.Text = "Testing unlock methods...\nCheck console for results"
    
    -- Method 1: Try common remote
    local methods = {
        {name = "UnlockAllCustomizations", type = "RemoteEvent"},
        {name = "PurchaseAllCustomizations", type = "RemoteFunction"},
        {name = "Customization.UnlockAll", type = "RemoteEvent"},
        {name = "BuyAllCustomizations", type = "RemoteFunction"}
    }
    
    for i, method in ipairs(methods) do
        local success, result = pcall(function()
            local remotePath = "ReplicatedStorage.Remotes." .. method.name
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild(method.name, true)
            
            if remote and remote:IsA(method.type == "RemoteEvent" and "RemoteEvent" or "RemoteFunction") then
                if method.type == "RemoteFunction" then
                    return remote:InvokeServer()
                else
                    remote:FireServer()
                    return "Event fired"
                end
            end
            return "Remote not found"
        end)
        
        print("\nMethod " .. i .. " (" .. method.name .. "):")
        if success then
            print("   Result: " .. tostring(result))
        else
            print("   Error: " .. tostring(result))
        end
    end
    
    status.Text = "Testing complete!\nCheck console output for results"
end)

print("\n" .. string.rep("=", 50))
print("✅ DIAGNOSTIC COMPLETE!")
print("\n📋 WHAT TO DO NEXT:")
print("1. Run this script and check the console output")
print("2. Look for 'CUSTOMIZATION-RELATED REMOTES' section")
print("3. Note the remote names that are found")
print("4. Try the 'TEST UNLOCK' button in the new UI")
print("5. Check which method works in console")
