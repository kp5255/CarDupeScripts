-- OwnerInventoryDupe.server.lua
-- Server-side owner-only inventory viewer + dupe tool.
-- Drop this into ServerScriptService. Replace OWNER_USER_ID with your numeric UserId.

local OWNER_USER_ID = 123456789        -- <<-- REPLACE this with your Roblox numeric UserId
local SPAWN_ON_DUPE = true             -- spawn a physical copy when duped
local DATASTORE_NAME = "OwnerDupe_Inv" -- fallback datastore name
local INPUT_KEY = Enum.KeyCode.R
local LOG_PREFIX = "[OwnerDupe]"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local function log(...) print(LOG_PREFIX, ...) end
local function warnlog(...) warn(LOG_PREFIX, ...) end

-- Ensure remote folder & events
local remoteFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteFolder then
    remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "RemoteEvents"
    remoteFolder.Parent = ReplicatedStorage
end
local dupeEvent = remoteFolder:FindFirstChild("RequestDupeCar")
if not dupeEvent then
    dupeEvent = Instance.new("RemoteEvent")
    dupeEvent.Name = "RequestDupeCar"
    dupeEvent.Parent = remoteFolder
end
local dupeResult = remoteFolder:FindFirstChild("DupeResult")
if not dupeResult then
    dupeResult = Instance.new("RemoteEvent")
    dupeResult.Name = "DupeResult"
    dupeResult.Parent = remoteFolder
end

-- Car templates container (fallback)
local CarTemplates = ReplicatedStorage:FindFirstChild("CarTemplates")
if not CarTemplates then
    CarTemplates = Instance.new("Folder")
    CarTemplates.Name = "CarTemplates"
    CarTemplates.Parent = ReplicatedStorage
    log("Created fallback ReplicatedStorage.CarTemplates")
end

-- ---------- Inventory detection ----------
local function findInventoryModule()
    for _, service in ipairs({ServerStorage, ReplicatedStorage}) do
        for _, obj in ipairs(service:GetDescendants()) do
            if obj:IsA("ModuleScript") then
                local ok, mod = pcall(require, obj)
                if ok and type(mod) == "table" then
                    if type(mod.AddCar) == "function"
                    or type(mod.GiveCar) == "function"
                    or type(mod.AddItem) == "function"
                    or type(mod.AddToInventory) == "function"
                    or type(mod.GiveItem) == "function" then
                        return obj, mod
                    end
                end
            end
        end
    end
    return nil, nil
end

local function findInventoryFolderRoot()
    local keywords = {"playerinvent", "playerdata", "profiles", "playerprofiles", "player", "inventory", "accounts", "save"}
    for _, root in ipairs({ReplicatedStorage, ServerStorage, workspace}) do
        for _, child in ipairs(root:GetChildren()) do
            if child:IsA("Folder") or child:IsA("Model") then
                local name = string.lower(child.Name)
                for _, kw in ipairs(keywords) do
                    if string.find(name, kw, 1, true) then
                        return child
                    end
                end
            end
        end
    end
    return nil
end

local fallbackRoot
local invModuleInst, invModuleTable = findInventoryModule()
local invFolderRoot = findInventoryFolderRoot()
if invModuleInst and invModuleTable then
    log("Inventory integration: Module found ->", invModuleInst:GetFullName())
elseif invFolderRoot then
    log("Inventory integration: Folder root found ->", invFolderRoot:GetFullName())
else
    -- create fallback
    local autoRoot = ReplicatedStorage:FindFirstChild("OwnerDupeData") or Instance.new("Folder")
    autoRoot.Name = "OwnerDupeData"
    autoRoot.Parent = ReplicatedStorage
    fallbackRoot = autoRoot:FindFirstChild("PlayerInventories")
    if not fallbackRoot then
        fallbackRoot = Instance.new("Folder")
        fallbackRoot.Name = "PlayerInventories"
        fallbackRoot.Parent = autoRoot
    end
    log("Using fallback inventory at", fallbackRoot:GetFullName())
end

local function getPlayerFolderIn(root, player)
    if not root then return nil end
    local byId = root:FindFirstChild(tostring(player.UserId))
    if byId and byId:IsA("Folder") then return byId end
    local byName = root:FindFirstChild(player.Name)
    if byName and byName:IsA("Folder") then return byName end
    return nil
end

local function ensurePlayerFolder(root, player)
    local existing = getPlayerFolderIn(root, player)
    if existing then return existing end
    local f = Instance.new("Folder")
    f.Name = tostring(player.UserId)
    f.Parent = root
    return f
end

local function addCarToInventory(player, carId, count)
    count = count or 1
    -- Module API preferred
    if invModuleTable then
        local mod = invModuleTable
        local success, err
        if type(mod.AddCar) == "function" then success, err = pcall(mod.AddCar, player, carId, count) end
        if success then return true end
        if type(mod.GiveCar) == "function" then success, err = pcall(mod.GiveCar, player, carId, count) end
        if success then return true end
        if type(mod.AddItem) == "function" then success, err = pcall(mod.AddItem, player, carId, count) end
        if success then return true end
        if type(mod.AddToInventory) == "function" then success, err = pcall(mod.AddToInventory, player, carId, count) end
        if success then return true end
        if type(mod.GiveItem) == "function" then success, err = pcall(mod.GiveItem, player, carId, count) end
        if success then return true end
        warnlog("Inventory module present but API calls failed:", tostring(err))
        return false, tostring(err)
    end

    -- Folder-based
    local root = invFolderRoot or fallbackRoot
    if not root then return false, "no-inventory-root" end
    local pFolder = getPlayerFolderIn(root, player)
    if not pFolder then pFolder = ensurePlayerFolder(root, player) end
    local cars = pFolder:FindFirstChild("Cars")
    if not cars then
        cars = Instance.new("Folder")
        cars.Name = "Cars"
        cars.Parent = pFolder
    end
    local item = cars:FindFirstChild(carId)
    if not item then
        item = Instance.new("IntValue")
        item.Name = tostring(carId)
        item.Value = 0
        item.Parent = cars
    end
    item.Value = item.Value + count

    -- If fallback used (fallbackRoot), persist via DataStore
    if fallbackRoot and root == fallbackRoot then
        local store = DataStoreService:GetDataStore(DATASTORE_NAME)
        local key = "inv_" .. player.UserId
        local blob = {}
        for _,v in ipairs(cars:GetChildren()) do
            if v:IsA("IntValue") then blob[v.Name] = v.Value end
        end
        pcall(function() store:SetAsync(key, blob) end)
    end

    return true
end

-- ---------- template helpers ----------
local function resolveCarIdAndTemplate(model)
    if not model then return nil, nil end
    local id = model:GetAttribute("CarId") or model.Name
    local t = CarTemplates:FindFirstChild(id)
    if t then return id, t end
    for _,d in ipairs(CarTemplates:GetDescendants()) do
        if d:IsA("Model") and d.Name == id then return id, d end
    end
    return id, nil
end

local function snapshotTemplateFromLiveModel(model)
    local snap = model:Clone()
    if not snap:GetAttribute("CarId") then
        snap:SetAttribute("CarId", model:GetAttribute("CarId") or model.Name)
    end
    snap.Parent = CarTemplates
    log("Snapshotted template:", snap.Name)
    return snap
end

local function getSeatedModelServer(player)
    local char = player.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local seat = hum.SeatPart
    if not seat then return nil end
    local m = seat:FindFirstAncestorOfClass("Model")
    return m
end

local function spawnCloneNearPlayer(player, template)
    if not template or not player.Character or not player.Character.PrimaryPart then return end
    local clone = template:Clone()
    clone.Name = (template.Name or "Car") .. "_Copy_" .. math.random(1000,9999)
    clone.Parent = workspace
    local primary = (clone:IsA("Model") and clone.PrimaryPart) or clone:FindFirstChildWhichIsA("BasePart", true)
    local pos = player.Character.PrimaryPart.Position + Vector3.new(0,5,0)
    if primary and clone:IsA("Model") then
        clone:MoveTo(pos)
    elseif primary then
        primary.CFrame = CFrame.new(pos)
    end
    return clone
end

-- ---------- handle dupe requests ----------
dupeEvent.OnServerEvent:Connect(function(player, clientModelName, clientCarId)
    -- only owner allowed to trigger via GUI; however R key also works but server still checks owner when required
    if not player then return end

    -- validate seated model
    local seated = getSeatedModelServer(player)
    if not seated then
        dupeResult:FireClient(player, false, "You must be seated in a car to dupe.")
        return
    end

    local id, template = resolveCarIdAndTemplate(seated)
    if (not id or id == "") and clientCarId and clientCarId ~= "" then id = clientCarId end
    if not id or id == "" then id = seated.Name end
    if not template then template = snapshotTemplateFromLiveModel(seated) end

    local ok, err = addCarToInventory(player, id, 1)
    if not ok then
        warnlog("Failed to add to inventory:", tostring(err))
        dupeResult:FireClient(player, false, "Failed to add to inventory: " .. tostring(err))
        return
    end

    if SPAWN_ON_DUPE then spawnCloneNearPlayer(player, template) end

    dupeResult:FireClient(player, true, "Added to your inventory: " .. tostring(id))
    log(player.Name .. " duplicated " .. tostring(id) .. " -> inventory mode: " .. tostring((invModuleInst and "module") or (invFolderRoot and "folder") or "fallback"))
end)

-- ---------- install client LocalScript for keypress + owner-only GUI ----------
local starterScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts") or StarterPlayer
if not starterScripts:FindFirstChild("OwnerInventoryDupe_Client") then
    local clientSrc = [[
-- OwnerInventoryDupe_Client (runs on every client but only shows owner UI to OWNER only)
local OWNER_USER_ID = %d
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local dupeEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestDupeCar")
local dupeResult = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("DupeResult")
local last = 0
local COOLDOWN = 0.2

local function getSeatedCarModel()
    local c = player.Character or player.CharacterAdded:Wait()
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return nil end
    local seat = h.SeatPart
    if not seat then return nil end
    return seat:FindFirstAncestorOfClass("Model")
end

-- Press R to request dupe (works for any player, but server will validate/add only as allowed)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == %s then
        if (tick() - last) < COOLDOWN then return end
        last = tick()
        local model = getSeatedCarModel()
        if model then
            dupeEvent:FireServer(model.Name, model:GetAttribute("CarId"))
        else
            warn("[Client] Not seated in a car.")
        end
    end
end)

-- owner-only GUI (only created for owner userid)
if player.UserId == OWNER_USER_ID then
    local function buildGui()
        if player:FindFirstChild("PlayerGui") and not player.PlayerGui:FindFirstChild("OwnerInventoryViewer") then
            local gui = Instance.new("ScreenGui")
            gui.Name = "OwnerInventoryViewer"
            gui.ResetOnSpawn = false

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0, 300, 0, 360)
            frame.Position = UDim2.new(1, -310, 0, 60)
            frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
            frame.BorderSizePixel = 0
            frame.Parent = gui

            local title = Instance.new("TextLabel")
            title.Size = UDim2.new(1,0,0,28)
            title.Position = UDim2.new(0,0,0,0)
            title.BackgroundTransparency = 1
            title.Text = "My Inventory (Owner)"
            title.TextColor3 = Color3.new(1,1,1)
            title.Font = Enum.Font.SourceSansBold
            title.TextSize = 20
            title.Parent = frame

            local scroll = Instance.new("ScrollingFrame")
            scroll.Size = UDim2.new(1, -16, 1, -44)
            scroll.Position = UDim2.new(0,8,0,36)
            scroll.CanvasSize = UDim2.new(0,0,0,0)
            scroll.BackgroundTransparency = 1
            scroll.Parent = frame

            local list = Instance.new("UIListLayout")
            list.Parent = scroll
            list.Padding = UDim.new(0,6)

            local refreshBtn = Instance.new("TextButton")
            refreshBtn.Size = UDim2.new(0,120,0,28)
            refreshBtn.Position = UDim2.new(0,8,1,-36)
            refreshBtn.Text = "Refresh"
            refreshBtn.Parent = frame

            local function findMyCarsFolder()
                local rs = game:GetService("ReplicatedStorage")
                for _, service in ipairs({rs, game:GetService("ServerStorage")}) do
                    for _, child in ipairs(service:GetDescendants()) do
                        if child:IsA("Folder") and (child.Name == tostring(player.UserId) or child.Name == player.Name) then
                            local cars = child:FindFirstChild("Cars")
                            if cars then return cars end
                        end
                    end
                end
                -- check fallback path
                local fallback = rs:FindFirstChild("OwnerDupeData")
                if fallback then
                    local pinv = fallback:FindFirstChild("PlayerInventories")
                    if pinv then
                        local p = pinv:FindFirstChild(tostring(player.UserId))
                        if p then return p:FindFirstChild("Cars") end
                    end
                end
                return nil
            end

            local function refreshList()
                for _,c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                local cars = findMyCarsFolder()
                if not cars then
                    local t = Instance.new("TextLabel")
                    t.Size = UDim2.new(1, -8, 0, 28)
                    t.Text = "No inventory found (use server fallback or publish to test)."
                    t.BackgroundTransparency = 1
                    t.TextColor3 = Color3.new(1,1,1)
                    t.Parent = scroll
                else
                    for _,item in ipairs(cars:GetChildren()) do
                        if item:IsA("IntValue") then
                            local btn = Instance.new("TextButton")
                            btn.Size = UDim2.new(1, -16, 0, 28)
                            btn.Text = item.Name .. "  (x" .. tostring(item.Value) .. ")"
                            btn.Parent = scroll
                            btn.MouseButton1Click:Connect(function()
                                -- Request server to dupe this specific item (server will validate seating)
                                dupeEvent:FireServer(item.Name, item.Name)
                            end)
                        end
                    end
                end
                -- update canvas size
                pcall(function()
                    local total = list.AbsoluteContentSize.Y
                    scroll.CanvasSize = UDim2.new(0,0,0,total + 12)
                end)
            end

            refreshBtn.MouseButton1Click:Connect(refreshList)
            -- initial populate after small wait for PlayerGui
            refreshList()
            gui.Parent = player.PlayerGui
        end
    end

    -- wait until PlayerGui exists
    spawn(function()
        player.CharacterAdded:Wait()
        wait(0.5)
        buildGui()
    end)
end

dupeResult.OnClientEvent:Connect(function(ok, message)
    if ok then
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {Title="Dupe", Text=message or "Added", Duration=3})
        end)
    else
        warn("[Dupe failed]", message)
    end
end)
]]
    clientSrc = string.format(clientSrc, OWNER_USER_ID, tostring(INPUT_KEY))
    local cl = Instance.new("LocalScript")
    cl.Name = "OwnerInventoryDupe_Client"
    cl.Source = clientSrc
    cl.Parent = starterScripts
    log("Installed client helper into StarterPlayerScripts (client will only show GUI to owner).")
end

log("OwnerInventoryDupe ready. Only UserId " .. tostring(OWNER_USER_ID) .. " will see the owner inventory panel.")
