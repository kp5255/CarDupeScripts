-- Manual finder for CDT
local player = game.Players.LocalPlayer

-- List all remotes
print("🔍 ALL REMOTE EVENTS:")
for _, obj in pairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") then
        print("   " .. obj:GetFullName())
    end
end

-- Try common CDT remote names manually
local commonRemotes = {
    "ClaimCar",
    "RedeemVehicle",
    "PurchaseCar",
    "GetVehicle",
    "DuplicateCar",
    "SpawnVehicle",
    "SelectCar"
}

print("\n🎯 TRY THESE MANUALLY:")
for _, remoteName in pairs(commonRemotes) do
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild(remoteName)
    if not remote then
        remote = game:GetService("ServerStorage"):FindFirstChild(remoteName)
    end
    if remote and remote:IsA("RemoteEvent") then
        print("   Testing: " .. remoteName)
        -- Try different data
        remote:FireServer("car_1")
        remote:FireServer("1")
        remote:FireServer(player.Name)
        print("   ✅ Sent test data to " .. remoteName)
    end
end
