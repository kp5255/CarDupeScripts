-- 🎯 CDT OFFER TRACKER - CORRECTED PATH
-- Targets: Menu.Trading.PeerToPeer.Main.LocalPlayer.Content.ScrollingFrame

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")

repeat task.wait() until game:IsLoaded()
task.wait(2)

print("🎯 CDT OFFER TRACKER - Corrected Path")

-- ===== CORRECTED PATH TO OFFER CONTAINER =====
local function GetCorrectedOfferContainer()
    if not Player.PlayerGui then 
        print("❌ No PlayerGui")
        return nil 
    end
    
    local menu = Player.PlayerGui:WaitForChild("Menu", 5)
    if not menu then 
        print("❌ No Menu in PlayerGui")
        return nil 
    end
    
    local trading = menu:FindFirstChild("Trading")
    if not trading then 
        print("❌ No Trading in Menu")
        return nil 
    end
    
    local peerToPeer = trading:FindFirstChild("PeerToPeer")
    if not peerToPeer then 
        print("❌ No PeerToPeer in Trading")
        return nil 
    end
    
    local main = peerToPeer:FindFirstChild("Main")
    if not main then 
        print("❌ No Main in PeerToPeer")
        return nil 
    end
    
    -- CORRECTION: No "Inventory" folder here!
    local localPlayer = main:FindFirstChild("LocalPlayer")
    if not localPlayer then 
        print("❌ No LocalPlayer in Main")
        return nil 
    end
    
    local content = localPlayer:FindFirstChild("Content")
    if not content then 
        print("❌ No Content in LocalPlayer")
        return nil 
    end
    
    local scrollingFrame = content:FindFirstChild("ScrollingFrame")
    if not scrollingFrame then 
        print("❌ No ScrollingFrame in Content")
        return nil 
    end
    
    print("✅ Found CORRECTED offer container: " .. scrollingFrame:GetFullName())
    print("   Visible: " .. tostring(scrollingFrame.Visible))
    print("   Child count: " .. #scrollingFrame:GetChildren())
    
    return scrollingFrame
end

-- ===== SCAN OFFERED CARS =====
local function ScanOfferedCars()
    local offerContainer = GetCorrectedOfferContainer()
    local offeredCars = {}
    
    if not offerContainer then
        return offeredCars
    end
    
    if not offerContainer.Visible then
        return offeredCars
    end
    
    print("🔍 Scanning for cars in offer...")
    
    -- Look for ANY children in the ScrollingFrame
    for _, child in pairs(offerContainer:GetChildren()) do
        local name = child.Name
        
        -- Check if it's a car item (Car- prefix or contains "Car")
        if name:find("Car") or name:match("Car%-") then
            print("🚗 Found: " .. name .. " (" .. child.ClassName .. ")")
            
            local carInfo = {
                RawName = name,
                DisplayName = name,
                Object = child,
                Path = child:GetFullName(),
                Class = child.ClassName
            }
            
            -- Try to get display name from Text property
            if child:IsA("TextButton") and child.Text ~= "" then
                carInfo.DisplayName = child.Text
            end
            
            -- Look for TextLabel children
            for _, sub in pairs(child:GetChildren()) do
                if sub:IsA("TextLabel") and sub.Text ~= "" then
                    carInfo.DisplayName = sub.Text
                    break
                end
            end
            
            -- Clean up the name
            carInfo.DisplayName = carInfo.DisplayName:gsub("Car%-", "")
            
            table.insert(offeredCars, carInfo)
        end
    end
    
    -- If no direct children found, check for frames containing cars
    if #offeredCars == 0 then
        for _, child in pairs(offerContainer:GetChildren()) do
            if child:IsA("Frame") then
                -- This frame might contain the car
                for _, subChild in pairs(child:GetChildren()) do
                    local name = subChild.Name
                    if name:find("Car") or name:match("Car%-") then
                        print("🚗 Found in frame: " .. name)
                        
                        local carInfo = {
                            RawName = name,
                            DisplayName = name:gsub("Car%-", ""),
                            Object = subChild,
                            Path = subChild:GetFullName(),
                            Class = subChild.ClassName,
                            ParentFrame = child.Name
                        }
                        
                        table.insert(offeredCars, carInfo)
                    end
                end
            end
        end
    end
    
    return offeredCars
end

-- ===== CREATE SIMPLE TRACKER =====
local function CreateSimpleTracker()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OfferTrackerSimple"
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Window
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 250)
    MainFrame.Position = UDim2.new(0.8, 0, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Text = "🚗 YOUR OFFER"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    
    -- Status
    local Status = Instance.new("TextLabel")
    Status.Text = "Waiting for trade..."
    Status.Size = UDim2.new(1, -20, 0, 40)
    Status.Position = UDim2.new(0, 10, 0, 50)
    Status.BackgroundTransparency = 1
    Status.TextColor3 = Color3.fromRGB(255, 255, 150)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 14
    
    -- Cars List
    local CarsList = Instance.new("ScrollingFrame")
    CarsList.Size = UDim2.new(1, -20, 0, 120)
    CarsList.Position = UDim2.new(0, 10, 0, 100)
    CarsList.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    CarsList.BorderSizePixel = 0
    CarsList.ScrollBarThickness = 6
    CarsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 5)
    
    -- Add corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    
    corner:Clone().Parent = MainFrame
    corner:Clone().Parent = Title
    corner:Clone().Parent = CarsList
    
    -- Parenting
    Title.Parent = MainFrame
    Status.Parent = MainFrame
    ListLayout.Parent = CarsList
    CarsList.Parent = MainFrame
    MainFrame.Parent = ScreenGui
    
    -- Functions
    local function updateStatus(text, color)
        Status.Text = text
        Status.TextColor3 = color or Color3.fromRGB(255, 255, 150)
    end
    
    local function clearList()
        for _, child in pairs(CarsList:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
    end
    
    local function addCarItem(carName, index)
        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(0.95, 0, 0, 40)
        itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        
        local itemCorner = Instance.new("UICorner")
        itemCorner.CornerRadius = UDim.new(0, 6)
        itemCorner.Parent = itemFrame
        
        local number = Instance.new("TextLabel")
        number.Text = tostring(index) .. "."
        number.Size = UDim2.new(0, 30, 1, 0)
        number.Position = UDim2.new(0, 5, 0, 0)
        number.BackgroundTransparency = 1
        number.TextColor3 = Color3.fromRGB(255, 255, 200)
        number.Font = Enum.Font.GothamBold
        number.TextSize = 14
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = carName
        nameLabel.Size = UDim2.new(1, -40, 1, 0)
        nameLabel.Position = UDim2.new(0, 35, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 14
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        number.Parent = itemFrame
        nameLabel.Parent = itemFrame
        itemFrame.Parent = CarsList
        
        return itemFrame
    end
    
    local function refresh()
        clearList()
        
        local cars = ScanOfferedCars()
        
        if #cars > 0 then
            updateStatus(#cars .. " car(s) in offer", Color3.fromRGB(100, 255, 100))
            
            for i, car in ipairs(cars) do
                addCarItem(car.DisplayName, i)
            end
            
            -- Debug output
            print("\n📊 CURRENT OFFER:")
            for _, car in ipairs(cars) do
                print("   " .. car.DisplayName .. " (from " .. car.RawName .. ")")
            end
            
        else
            local container = GetCorrectedOfferContainer()
            
            if container then
                if container.Visible then
                    updateStatus("No cars in offer", Color3.fromRGB(255, 200, 100))
                    addCarItem("Add cars to offer", 1)
                else
                    updateStatus("Trade not active", Color3.fromRGB(255, 150, 100))
                end
            else
                updateStatus("No trade UI", Color3.fromRGB(255, 100, 100))
            end
        end
    end
    
    -- Auto-refresh
    spawn(function()
        while task.wait(0.5) do
            if ScreenGui and ScreenGui.Parent then
                refresh()
            end
        end
    end)
    
    -- Initial refresh
    task.wait(1)
    refresh()
    
    return ScreenGui
end

-- ===== DEBUG: SHOW REAL-TIME STRUCTURE =====
local function ShowStructure()
    spawn(function()
        while task.wait(2) do
            print("\n" .. string.rep("=", 60))
            print("📁 CURRENT STRUCTURE:")
            
            if not Player.PlayerGui then
                print("❌ No PlayerGui")
                continue
            end
            
            local menu = Player.PlayerGui:FindFirstChild("Menu")
            if not menu then
                print("❌ No Menu")
                continue
            end
            
            local trading = menu:FindFirstChild("Trading")
            if not trading then
                print("❌ No Trading")
                continue
            end
            
            local peerToPeer = trading:FindFirstChild("PeerToPeer")
            if not peerToPeer then
                print("❌ No PeerToPeer")
                continue
            end
            
            local main = peerToPeer:FindFirstChild("Main")
            if not main then
                print("❌ No Main")
                continue
            end
            
            print("✅ Menu → Trading → PeerToPeer → Main")
            
            -- Show everything in Main
            print("\n📦 Contents of Main:")
            for _, child in pairs(main:GetChildren()) do
                local status = child.Visible and "🟢" or "🔴"
                print(status .. " " .. child.Name .. " (" .. child.ClassName .. ")")
                
                if child.Name == "LocalPlayer" then
                    for _, sub in pairs(child:GetChildren()) do
                        print("   └─ " .. sub.Name .. " (" .. sub.ClassName .. ")")
                        
                        if sub.Name == "Content" then
                            for _, sub2 in pairs(sub:GetChildren()) do
                                print("      └─ " .. sub2.Name .. " (" .. sub2.ClassName .. ")")
                                
                                if sub2.Name == "ScrollingFrame" then
                                    print("         └─ Children: " .. #sub2:GetChildren())
                                    for _, item in pairs(sub2:GetChildren()) do
                                        print("            • " .. item.Name .. " (" .. item.ClassName .. ")")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- ===== MAIN =====
print("\n" .. string.rep("=", 60))
print("🎯 CDT OFFER TRACKER - CORRECTED PATH")
print("📍 Path: Menu → Trading → PeerToPeer → Main → LocalPlayer → Content → ScrollingFrame")
print("⚡ Updates every 0.5 seconds")
print(string.rep("=", 60))

-- Create tracker
CreateSimpleTracker()

-- Start structure debug
ShowStructure()

print("\n✅ Tracker created!")
print("💡 Drag the window to move it")
print("📊 Will show cars in your offer only")
print("\n🎮 Start a trade and add cars to see them appear!")
