-- SPINNER BLACK-BOX AUDITOR
-- Put in StarterPlayerScripts as a LocalScript.
-- Observation only.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KEYWORDS = {
    "spin",
    "spinner",
    "reward",
    "prize",
    "claim",
    "free",
    "standard",
    "hyper",
}

local function interesting(name)
    name = name:lower()

    for _, keyword in ipairs(KEYWORDS) do
        if name:find(keyword, 1, true) then
            return true
        end
    end

    return false
end

local function scan()
    print("================================")
    print("[SPIN-AUDIT] CLIENT SCAN")
    print("================================")

    local count = 0

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do

        if (obj:IsA("RemoteEvent")
            or obj:IsA("RemoteFunction"))
            and interesting(obj.Name)
        then

            count += 1

            print(string.format(
                "[%03d] %s | %s",
                count,
                obj.ClassName,
                obj:GetFullName()
            ))
        end
    end

    print("--------------------------------")
    print("Spinner-related remotes:", count)
    print("================================")
end

scan()

-- Detect newly-created spinner-related remotes.
ReplicatedStorage.DescendantAdded:Connect(function(obj)

    if not (
        obj:IsA("RemoteEvent")
        or obj:IsA("RemoteFunction")
    ) then
        return
    end

    if interesting(obj.Name) then
        warn(
            "[SPIN-AUDIT] NEW REMOTE:",
            obj.ClassName,
            obj:GetFullName()
        )
    end
end)
