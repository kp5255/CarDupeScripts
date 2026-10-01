--[[
    ADVANCED CLIENT INSTRUMENTATION / REMOTE-SPY DETECTOR
    =====================================================

    Authorized security research / private sandbox use.

    Architecture:
        Environment
             |
        +----+----------------------+
        |                           |
    Capability                  Integrity
      checks                      checks
        |                           |
        +------------+--------------+
                     |
              Behavioral signals
                     |
              Evidence engine
                     |
              Confidence score
                     |
              Incident report

    IMPORTANT:
      This is a heuristic client-side detector.
      It is NOT a replacement for server-side validation.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--==================================================
-- CONFIGURATION
--==================================================

local CONFIG = {

    -- General
    VERBOSE = true,
    PERIODIC_SCAN = true,

    -- Scan scheduling
    LIGHT_SCAN_INTERVAL = 3,
    DEEP_SCAN_INTERVAL = 15,

    -- Detection
    DETECTION_THRESHOLD = 10,
    HIGH_CONFIDENCE_THRESHOLD = 14,

    -- Avoid repeatedly counting identical evidence
    DUPLICATE_SUPPRESS = true,

    -- Features
    SCAN_ENVIRONMENT = true,
    SCAN_GLOBALS = true,
    SCAN_DEBUG = true,
    SCAN_REMOTES = true,
    SCAN_CONNECTIONS = true,
    SCAN_REGISTRY = true,
    SCAN_GC = true,
    CHECK_METAMETHODS = true,

    -- Expensive scans
    ENABLE_DEEP_SCANS = true,

    -- Incident history
    MAX_INCIDENTS = 20,
    MAX_EVIDENCE = 100,

    -- Optional response
    AUTO_KICK = false,

    -- Signature matching
    SIGNATURE_MATCHING = true,
}

--==================================================
-- STATE
--==================================================

local State = {
    started = os.clock(),

    detected = false,
    confidence = "LOW",

    score = 0,

    scans = {
        light = 0,
        deep = 0,
        failed = 0,
    },

    evidence = {},
    reasons = {},
    incidents = {},

    baseline = nil,
    currentProfile = nil,

    remoteInventory = {
        events = {},
        functions = {},
    },

    statistics = {
        capabilityCount = 0,
        suspiciousGlobals = 0,
        signatureMatches = 0,
        remoteCount = 0,
    },
}

--==================================================
-- LOGGING
--==================================================

local PREFIX = "[ADV-ANTI-SPY]"

local function log(...)
    if CONFIG.VERBOSE then
        print(PREFIX, ...)
    end
end

local function warnLog(...)
    warn(PREFIX, ...)
end

--==================================================
-- SAFE HELPERS
--==================================================

local function safeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    if ok then
        return true, result
    end

    State.scans.failed += 1

    return false, nil
end

local function safeType(value)
    local ok, result = pcall(type, value)

    if ok then
        return result
    end

    return "unknown"
end

local function safeString(value)
    local ok, result = pcall(tostring, value)

    if ok then
        return result
    end

    return "<unprintable>"
end

local function getEnvironment()
    if type(getfenv) ~= "function" then
        return nil
    end

    local ok, env = safeCall(getfenv, 0)

    if ok and type(env) == "table" then
        return env
    end

    return nil
end

--==================================================
-- SIGNATURE DATABASE
--==================================================

local SIGNATURES = {

    "simplespy",
    "remotespy",
    "hydroxide",
    "cobalt",
    "darkspy",
    "sunspy",
    "utopia",
    "spy.lua",
}

local SUSPICIOUS_GLOBALS = {

    "RemoteSpy",
    "SimpleSpy",
    "RemoteEventSpy",
    "Hydroxide",
    "Cobalt",
    "DarkSpy",
    "SunSpy",
    "Utopia",
}

local EXECUTOR_APIS = {

    "getrawmetatable",
    "hookmetamethod",
    "hookfunction",
    "getconnections",
    "getgc",
    "getreg",
    "checkcaller",
    "getrenv",
    "getgenv",
    "identifyexecutor",
    "isexecutorclosure",
    "getcallingscript",
    "getsenv",
    "gethui",
}

--==================================================
-- SIGNATURE MATCHING
--==================================================

local function containsSignature(value)
    if type(value) ~= "string" then
        return nil
    end

    local lowered = value:lower()

    for _, signature in ipairs(SIGNATURES) do

        if lowered:find(signature, 1, true) then
            return signature
        end

    end

    return nil
end

--==================================================
-- EVIDENCE ENGINE
--==================================================

local function addEvidence(
    id,
    description,
    points,
    category
)

    if State.detected then
        return
    end

    if CONFIG.DUPLICATE_SUPPRESS
        and State.evidence[id] ~= nil
    then
        return
    end

    State.evidence[id] = {
        points = points,
        category = category or "unknown",
        description = description,
        timestamp = os.clock(),
    }

    State.score += points

    table.insert(
        State.reasons,
        description
    )

    if #State.reasons > CONFIG.MAX_EVIDENCE then
        table.remove(State.reasons, 1)
    end

    warnLog(
        string.format(
            "[+%d] [%s] %s | score=%d",
            points,
            category or "unknown",
            description,
            State.score
        )
    )

    if State.score >= CONFIG.HIGH_CONFIDENCE_THRESHOLD then
        State.confidence = "HIGH"

    elseif State.score >= CONFIG.DETECTION_THRESHOLD then
        State.confidence = "MEDIUM"

    elseif State.score >= 4 then
        State.confidence = "LOW-MEDIUM"
    end

    if State.score >= CONFIG.DETECTION_THRESHOLD then

        State.detected = true

        local incident = {
            id = HttpService:GenerateGUID(false),
            timestamp = os.clock(),
            score = State.score,
            confidence = State.confidence,
            reasons = table.clone(State.reasons),
        }

        table.insert(
            State.incidents,
            incident
        )

        if #State.incidents > CONFIG.MAX_INCIDENTS then
            table.remove(State.incidents, 1)
        end

        warn("==============================================")
        warn(" ADVANCED CLIENT INSTRUMENTATION DETECTED")
        warn("==============================================")
        warn("Incident:", incident.id)
        warn("Score:", State.score)
        warn("Confidence:", State.confidence)

        for index, reason in ipairs(State.reasons) do
            warn(
                string.format(
                    "[%d] %s",
                    index,
                    reason
                )
            )
        end

        warn("==============================================")

        if CONFIG.AUTO_KICK
            and LocalPlayer
        then

            task.defer(function()

                pcall(function()

                    LocalPlayer:Kick(
                        "Unauthorized client instrumentation detected."
                    )

                end)

            end)

        end

    end
end

--==================================================
-- ENVIRONMENT CAPABILITY SCAN
--==================================================

local function scanCapabilities()

    if not CONFIG.SCAN_ENVIRONMENT then
        return {}
    end

    local env = getEnvironment()

    if not env then
        return {}
    end

    local capabilities = {}

    for _, name in ipairs(EXECUTOR_APIS) do

        local ok, value = safeCall(function()
            return env[name]
        end)

        if ok and safeType(value) == "function" then

            capabilities[name] = true

        end

    end

    local count = 0

    for _ in pairs(capabilities) do
        count += 1
    end

    State.statistics.capabilityCount = count

    -- Capability clusters are stronger than one isolated API.
    if count >= 3 then

        addEvidence(
            "capability_cluster_3",
            string.format(
                "%d instrumentation/executor capabilities exposed",
                count
            ),
            2,
            "environment"
        )

    end

    if count >= 6 then

        addEvidence(
            "capability_cluster_6",
            string.format(
                "large instrumentation capability cluster exposed (%d)",
                count
            ),
            2,
            "environment"
        )

    end

    -- Executor identity
    if capabilities.identifyexecutor then

        local ok, identity = safeCall(
            env.identifyexecutor
        )

        if ok and identity then

            addEvidence(
                "executor_identity",
                "executor identity exposed: "
                    .. safeString(identity),
                3,
                "environment"
            )

        end

    end

    return capabilities
end

--==================================================
-- GLOBAL SCAN
--==================================================

local function scanGlobals()

    if not CONFIG.SCAN_GLOBALS then
        return {}
    end

    local env = getEnvironment()

    if not env then
        return {}
    end

    local found = {}

    for _, name in ipairs(SUSPICIOUS_GLOBALS) do

        local ok, value = safeCall(function()
            return env[name]
        end)

        if ok and value ~= nil then

            found[name] = safeType(value)

            State.statistics.suspiciousGlobals += 1

            addEvidence(
                "global_" .. name,
                "known instrumentation global detected: "
                    .. name,
                5,
                "signature"
            )

        end

    end

    return found
end

--==================================================
-- DEBUG ENVIRONMENT
--==================================================

local function scanDebug()

    if not CONFIG.SCAN_DEBUG then
        return {}
    end

    local result = {
        debugAvailable = type(debug) == "table",
        getinfo = false,
        traceback = false,
        getupvalue = false,
    }

    if type(debug) ~= "table" then
        return result
    end

    result.getinfo =
        type(debug.getinfo) == "function"

    result.traceback =
        type(debug.traceback) == "function"

    result.getupvalue =
        type(debug.getupvalue) == "function"

    return result
end

--==================================================
-- REMOTE INVENTORY
--==================================================

local function scanRemotes()

    if not CONFIG.SCAN_REMOTES then
        return
    end

    local events = {}
    local functions = {}

    local ok, descendants = safeCall(
        function()
            return ReplicatedStorage:GetDescendants()
        end
    )

    if not ok then
        return
    end

    for _, object in ipairs(descendants) do

        if object:IsA("RemoteEvent") then

            table.insert(
                events,
                object:GetFullName()
            )

        elseif object:IsA("RemoteFunction") then

            table.insert(
                functions,
                object:GetFullName()
            )

        end

    end

    State.remoteInventory.events = events
    State.remoteInventory.functions = functions

    State.statistics.remoteCount =
        #events + #functions

    log(
        string.format(
            "Remote inventory: %d events / %d functions",
            #events,
            #functions
        )
    )
end

--==================================================
-- GLOBAL STRING / SIGNATURE SCAN
--==================================================

local function scanRegistry()

    if not CONFIG.SCAN_REGISTRY then
        return
    end

    local env = getEnvironment()

    if not env then
        return
    end

    local getregFn = env.getreg

    if safeType(getregFn) ~= "function" then
        return
    end

    local ok, registry = safeCall(getregFn)

    if not ok or type(registry) ~= "table" then
        return
    end

    local matches = {}

    for _, value in pairs(registry) do

        if type(value) == "string" then

            local signature =
                containsSignature(value)

            if signature then

                matches[signature] =
                    (matches[signature] or 0) + 1

            end

        end

    end

    local total = 0

    for signature, count in pairs(matches) do

        total += count

        if count >= 2 then

            State.statistics.signatureMatches += 1

            addEvidence(
                "registry_" .. signature,
                string.format(
                    "registry contains repeated '%s' signature",
                    signature
                ),
                3,
                "registry"
            )

        end

    end

    if total >= 5 then

        addEvidence(
            "registry_signature_cluster",
            string.format(
                "multiple instrumentation signatures found in registry (%d)",
                total
            ),
            2,
            "registry"
        )

    end
end

--==================================================
-- GC SIGNATURE SCAN
--==================================================

local function scanGC()

    if not CONFIG.SCAN_GC then
        return
    end

    local env = getEnvironment()

    if not env then
        return
    end

    local getgcFn = env.getgc

    if safeType(getgcFn) ~= "function" then
        return
    end

    local ok, objects =
        safeCall(getgcFn, true)

    if not ok or type(objects) ~= "table" then
        return
    end

    local signatures = {}

    for _, object in pairs(objects) do

        if type(object) == "string" then

            local signature =
                containsSignature(object)

            if signature then

                signatures[signature] =
                    (signatures[signature] or 0) + 1

            end

        end

    end

    for signature, count in pairs(signatures) do

        if count >= 2 then

            State.statistics.signatureMatches += 1

            addEvidence(
                "gc_" .. signature,
                string.format(
                    "GC contains repeated '%s' signature",
                    signature
                ),
                3,
                "gc"
            )

        end

    end
end

--==================================================
-- CONNECTION SCAN
--==================================================

local function scanConnections()

    if not CONFIG.SCAN_CONNECTIONS then
        return
    end

    local env = getEnvironment()

    if not env then
        return
    end

    local getconnectionsFn =
        env.getconnections

    if safeType(getconnectionsFn)
        ~= "function"
    then
        return
    end

    local descendants = game:GetDescendants()

    local inspected = 0
    local signatureMatches = 0

    for _, instance in ipairs(descendants) do

        if State.detected then
            return
        end

        if instance:IsA("RemoteEvent") then

            local ok, connections =
                safeCall(
                    getconnectionsFn,
                    instance.OnClientEvent
                )

            if ok and type(connections) == "table" then

                inspected += #connections

                for _, connection in ipairs(connections) do

                    if type(connection) == "table" then

                        local callback =
                            connection.Function

                        if safeType(callback)
                            == "function"
                        then

                            if type(debug) == "table"
                                and type(debug.getinfo)
                                    == "function"
                            then

                                local infoOk, info =
                                    safeCall(
                                        debug.getinfo,
                                        callback,
                                        "S"
                                    )

                                if infoOk
                                    and type(info)
                                        == "table"
                                then

                                    local source =
                                        info.source

                                    local signature =
                                        containsSignature(
                                            source
                                        )

                                    if signature then

                                        signatureMatches += 1

                                        addEvidence(
                                            "connection_"
                                                .. signature,
                                            "known instrumentation signature in event connection: "
                                                .. instance:GetFullName(),
                                            5,
                                            "connection"
                                        )

                                    end

                                end

                            end

                        end

                    end

                end

            end

        end

    end

    log(
        string.format(
            "Connections inspected: %d | signatures: %d",
            inspected,
            signatureMatches
        )
    )
end

--==================================================
-- METAMETHOD CHECK
--==================================================

local function scanMetamethods()

    if not CONFIG.CHECK_METAMETHODS then
        return
    end

    local env = getEnvironment()

    if not env then
        return
    end

    local getraw =
        env.getrawmetatable

    if safeType(getraw) ~= "function" then
        return
    end

    local ok, mt =
        safeCall(
            getraw,
            game
        )

    if not ok or type(mt) ~= "table" then
        return
    end

    local namecall =
        rawget(mt, "__namecall")

    if safeType(namecall)
        ~= "function"
    then
        return
    end

    if type(debug) ~= "table"
        or type(debug.getinfo)
            ~= "function"
    then
        return
    end

    local infoOk, info =
        safeCall(
            debug.getinfo,
            namecall,
            "S"
        )

    if not infoOk
        or type(info) ~= "table"
    then
        return
    end

    local source = info.source

    local signature =
        containsSignature(source)

    if signature then

        State.statistics.signatureMatches += 1

        addEvidence(
            "namecall_" .. signature,
            "known instrumentation signature associated with __namecall: "
                .. signature,
            5,
            "metamethod"
        )

    end
end

--==================================================
-- PROFILE
--==================================================

local function collectProfile()

    return {
        timestamp = os.clock(),

        capabilities =
            scanCapabilities(),

        globals =
            scanGlobals(),

        debug =
            scanDebug(),

        remotes = {
            events =
                #State.remoteInventory.events,

            functions =
                #State.remoteInventory.functions,
        },
    }
end

--==================================================
-- PROFILE DELTA
--==================================================

local function compareProfiles(old, new)

    if not old then
        return
    end

    local oldCaps =
        old.capabilities or {}

    local newCaps =
        new.capabilities or {}

    for name, enabled in pairs(newCaps) do

        if enabled
            and not oldCaps[name]
        then

            addEvidence(
                "capability_appeared_" .. name,
                "new instrumentation capability appeared after baseline: "
                    .. name,
                2,
                "delta"
            )

        end

    end

    local oldGlobals =
        old.globals or {}

    local newGlobals =
        new.globals or {}

    for name in pairs(newGlobals) do

        if oldGlobals[name] == nil then

            addEvidence(
                "global_appeared_" .. name,
                "new suspicious global appeared after baseline: "
                    .. name,
                4,
                "delta"
            )

        end

    end

end

--==================================================
-- DEEP SCAN
--==================================================

local function runDeepScan()

    if State.detected then
        return
    end

    State.scans.deep += 1

    log(
        "Starting deep scan #"
            .. State.scans.deep
    )

    local previous =
        State.currentProfile

    local current =
        collectProfile()

    compareProfiles(
        previous,
        current
    )

    State.currentProfile =
        current

    State.baseline =
        State.baseline or current
end

--==================================================
-- LIGHT SCAN
--==================================================

local function runLightScan()

    if State.detected then
        return
    end

    State.scans.light += 1

    local profile = {
        timestamp = os.clock(),
        capabilities =
            scanCapabilities(),
        globals =
            scanGlobals(),
    }

    compareProfiles(
        State.currentProfile,
        profile
    )

    State.currentProfile =
        profile
end

--==================================================
-- FULL INITIAL SCAN
--==================================================

local function runInitialScan()

    log("Starting initial security scan.")

    scanCapabilities()
    scanGlobals()
    scanDebug()
    scanRemotes()
    scanMetamethods()

    if CONFIG.ENABLE_DEEP_SCANS then
        scanRegistry()
        scanGC()
        scanConnections()
    end

    State.currentProfile =
        collectProfile()

    State.baseline =
        State.currentProfile

    log(
        string.format(
            "Initial scan complete | score=%d | confidence=%s",
            State.score,
            State.confidence
        )
    )
end

--==================================================
-- REPORT
--==================================================

local function getReport()

    local evidence = {}

    for id, data in pairs(State.evidence) do

        evidence[id] = {
            points = data.points,
            category = data.category,
            description = data.description,
            timestamp = data.timestamp,
        }

    end

    return {
        detected = State.detected,

        score = State.score,

        confidence =
            State.confidence,

        scans = table.clone(
            State.scans
        ),

        statistics =
            table.clone(
                State.statistics
            ),

        evidence = evidence,

        reasons =
            table.clone(
                State.reasons
            ),

        remoteInventory = {
            events =
                table.clone(
                    State.remoteInventory.events
                ),

            functions =
                table.clone(
                    State.remoteInventory.functions
                ),
        },

        incidents =
            table.clone(
                State.incidents
            ),
    }
end

--==================================================
-- PUBLIC API
--==================================================

_G.__AdvancedSecurityDetector = {

    IsDetected = function()
        return State.detected
    end,

    GetScore = function()
        return State.score
    end,

    GetConfidence = function()
        return State.confidence
    end,

    GetReasons = function()
        return table.clone(
            State.reasons
        )
    end,

    GetEvidence = function()
        return table.clone(
            State.evidence
        )
    end,

    GetReport = function()
        return getReport()
    end,

    GetRemoteInventory = function()
        return {
            events =
                table.clone(
                    State.remoteInventory.events
                ),

            functions =
                table.clone(
                    State.remoteInventory.functions
                ),
        }
    end,

    Rescan = function()
        if not State.detected then
            runDeepScan()
        end
    end,
}

--==================================================
-- START
--==================================================

log("==============================================")
log(" ADVANCED SECURITY DETECTOR")
log(" Starting...")
log("==============================================")

runInitialScan()

if CONFIG.PERIODIC_SCAN then

    task.spawn(function()

        local deepTimer = 0

        while not State.detected do

            task.wait(
                CONFIG.LIGHT_SCAN_INTERVAL
            )

            if State.detected then
                break
            end

            runLightScan()

            deepTimer +=
                CONFIG.LIGHT_SCAN_INTERVAL

            if CONFIG.ENABLE_DEEP_SCANS
                and deepTimer
                    >= CONFIG.DEEP_SCAN_INTERVAL
            then

                deepTimer = 0

                runDeepScan()

            end

        end

    end)

end

task.defer(function()

    task.wait(1)

    if State.detected then

        warn(
            string.format(
                "%s DETECTED | score=%d | confidence=%s",
                PREFIX,
                State.score,
                State.confidence
            )
        )

    else

        print(
            string.format(
                "%s No strong evidence | score=%d | confidence=%s",
                PREFIX,
                State.score,
                State.confidence
            )
        )

    end

end)

return State
