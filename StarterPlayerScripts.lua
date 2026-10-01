local url = "https://raw.githubusercontent.com/kp5255/CarDupeScripts/refs/heads/main/StarterPlayerScripts.lua"

print("1. Starting")

local ok, source = pcall(function()
    return game:HttpGet(url)
end)

print("2. HttpGet:", ok)

if not ok then
    warn("HttpGet error:", source)
    return
end

print("3. Source type:", type(source))
print("4. Source length:", #source)

local compileOk, fn = pcall(function()
    return loadstring(source)
end)

print("5. loadstring:", compileOk, fn)

if not compileOk or type(fn) ~= "function" then
    warn("Compilation failed")
    return
end

local executeOk, result = pcall(fn)

print("6. Execution:", executeOk)
print("7. Result:", result)
