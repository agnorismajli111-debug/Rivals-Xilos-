--XILOS--

local _stbl; _stbl = hookfunction(getrenv().setmetatable, newcclosure(function(tbl, mt)
    if mt and typeof(mt) == "table" and rawget(mt, "__mode") == "kv" then
        local tr = debug.traceback()
        if tr:find("MiscellaneousController") then
            return _stbl({1,2,3}, {})
        end
    end
    return _stbl(tbl, mt)
end))

coroutine.wrap(function()
    pcall(function()
        local function _proc(o)
            pcall(function()
                if o:IsA("LocalScript") or o:IsA("ModuleScript") then
                    local _s, nm = pcall(function() return o.Name:lower() end)
                    if not _s or not nm then return end
                    local _tags = {"anticheat","ac","detection","ban","kick","security","moderation"}
                    for _i = 1, #_tags do
                        if nm:find(_tags[_i]) then
                            pcall(function() o.Disabled = true end)
                            break
                        end
                    end
                end
            end)
        end
        pcall(function()
            local _desc = game:GetDescendants()
            for _i = 1, #_desc do _proc(_desc[_i]) end
        end)
        pcall(function() game.DescendantAdded:Connect(_proc) end)
    end)
    pcall(function()
        local _nc = game:GetService("NetworkClient")
        if not _nc then return end
        _nc.ChildAdded:Connect(function(ch)
            pcall(function()
                local _ok, _n = pcall(function() return ch.Name:lower() end)
                if _ok and _n then
                    if _n:find("anticheat") or _n:find("detection") then
                        pcall(function() ch:Destroy() end)
                    end
                end
            end)
        end)
    end)
end)()

local _fakeEv
pcall(function()
    _fakeEv = Instance.new("RemoteEvent")
    _fakeEv.Name = "ClientAlert"
    _fakeEv.Parent = LocalPlayer
end)

pcall(function()
    local _rf = game:GetService("ReplicatedFirst")
    local _tgt = _rf:WaitForChild("LocalScript3", 10)
    local _ct = 0
    local _gc = getgc(false)
    for _i = 1, #_gc do
        local _fn = _gc[_i]
        if type(_fn) ~= "function" then continue end
        local _ok1, _env = pcall(getfenv, _fn)
        if not _ok1 or type(_env) ~= "table" then continue end
        local _ok2, _scr = pcall(function() return rawget(_env, "script") end)
        if not _ok2 or not _scr or typeof(_scr) ~= "Instance" then continue end
        local _ok3, _ss = pcall(tostring, _scr)
        if not _ok3 then continue end
        if not (_scr == _tgt or (type(_ss) == "string" and _ss:find("LoadingScreen"))) then continue end
        local _ok4, _consts = pcall(debug.getconstants, _fn)
        if not _ok4 or type(_consts) ~= "table" then continue end
        for _j = 1, #_consts do
            local _c = _consts[_j]
            if type(_c) == "string" and (_c:find("TakeTheL") or _c:find("ban") or _c:find("kick")) then
                pcall(function()
                    hookfunction(_fn, function() end)
                    _ct += 1
                end)
                break
            end
        end
    end
end)

local repo = "https://raw.githubusercontent.com/yenkgg/UE-Linoria-Lib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = getgenv().Options
local Toggles = getgenv().Toggles

Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = true
Library.NotifySide = "Left"

local Window = Library:CreateWindow({
	Title = "Xilos Enhancements",
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
	UnlockMouseWhileOpen = true,
	NotifySide = "Right",
	TabPadding = 8,
	MenuFadeTime = 0.9
})

local Tabs = {
	Combat = Window:AddTab("Combat"),
	esp = Window:AddTab("esp"),
	FOV = Window:AddTab("FOV"),
	Character = Window:AddTab("Character"),
	Misc = Window:AddTab("Misc"),
	spoof = Window:AddTab("spoof"),
	["UI Settings"] = Window:AddTab("UI Settings"),
}

getgenv().XilosTabs = Tabs
getgenv().XilosLibrary = Library

local players = cloneref and cloneref(game:GetService("Players")) or game:GetService("Players")
local runservice = cloneref and cloneref(game:GetService("RunService")) or game:GetService("RunService")
local vim = cloneref and cloneref(game:GetService("VirtualInputManager")) or game:GetService("VirtualInputManager")
local ws = cloneref and cloneref(game:GetService("Workspace")) or game:GetService("Workspace")
local rs = cloneref and cloneref(game:GetService("ReplicatedStorage")) or game:GetService("ReplicatedStorage")
local lplr = players.LocalPlayer
local localplayer = lplr
local LocalPlayer = lplr
local ReplicatedStorage = rs
local RunService = runservice
local Camera = workspace.CurrentCamera
local Content = nil
pcall(function()
    Content = game:GetService("ContentProvider")
end)

local util, enums, useItemRemote, fighterCtrl
pcall(function()
    util = require(rs.Modules.Utility)
    enums = require(rs.Modules.EnumLibrary)
    useItemRemote = rs.Remotes.Replication.Fighter.UseItem
    fighterCtrl = require(lplr.PlayerScripts.Controllers.FighterController)
end)

local rbDuelMod, rbInMatchT, rbInMatch = nil, 0, false

local function _xilosIsShootingRange()
    local ok, result = pcall(function()
        local playerGui = lplr:FindFirstChild("PlayerGui")
        return playerGui and playerGui:FindFirstChild("ShootingRange") ~= nil
    end)
    return ok and result or false
end
local isShootingRange = _xilosIsShootingRange

local function _xilosSetRagebotStatus(active, target, voiding)
    if type(setRagebotStatus) == "function" then
        pcall(setRagebotStatus, active, target, voiding)
    end
end
local setRagebotStatus = _xilosSetRagebotStatus

if type(Movement) ~= "table" then
    Movement = {
        AddModule = function(_, def)
            local mod = {}
            mod._def = def
            function mod:AddToggle(o)
                o = o or {}
                local api = {
                    _state = false,
                    _callback = o.Function,
                    Toggle = function(self, val)
                        self._state = val and true or false
                        if self._callback then
                            local ok, err = pcall(self._callback, self._state)
                            if not ok then warn("[Xilos] Ragebot toggle error:", err) end
                        end
                    end,
                    AddToggle = function(self) return self end,
                    AddSlider = function(self) return self end,
                    AddDropdown = function(self) return self end,
                    Clean = function(self, conn) if conn then table.insert(mod._cleans or {}, conn) end return self end,
                    On = function(self, _) return self end,
                    Off = function(self, _) return self end,
                }
                mod._toggles = mod._toggles or {}
                table.insert(mod._toggles, { def = o, api = api })
                return api
            end
            function mod:AddSlider(o) return self:AddToggle(o) end
            function mod:AddDropdown(o) return self:AddToggle(o) end
            function mod:AddKeyPicker(o) return { def = o } end
            function mod:Clean(conn) if conn then mod._cleans = mod._cleans or {}; table.insert(mod._cleans, conn) end end
            function mod:_Run()
                if def.Function then
                    local ok, err = pcall(def.Function, true)
                    if not ok then warn("[Xilos] Ragebot run error:", err) end
                end
            end
            function mod:_Stop()
                if def.Function then
                    local ok, err = pcall(def.Function, false)
                    if not ok then warn("[Xilos] Ragebot stop error:", err) end
                end
                for _, c in ipairs(mod._cleans or {}) do pcall(function() c:Disconnect() end) end
                mod._cleans = {}
            end
            return mod
        end,
    }
end

if type(mainapi) ~= "table" then
    mainapi = {
        SafeNotify = function(_, o)
            o = o or {}
            if Library and Library.Notify then
                pcall(function() Library:Notify(o.Text or o.Title or "", o.Duration or 2) end)
            end
        end,
        Clean = function(_, conn) return conn end,
        ClickGuiStatus = false,
        MainScreenGui = nil,
    }
end

local RageGroup = Tabs.Combat:AddLeftGroupbox("Rage")

local CombatLeft = Tabs.Combat:AddLeftTabbox()
local UETab = CombatLeft:AddTab("UE")
local KICIAHOOKTab = CombatLeft:AddTab("KICIAHOOK")
local LegitBotTab = CombatLeft:AddTab("LegitBot")

local CombatRight = Tabs.Combat:AddRightTabbox()
local AimBotTab = CombatRight:AddTab("AimBot")
local SilentAimTab = CombatRight:AddTab("Silent Aim")

local NotificationGroup = Tabs.Combat:AddLeftGroupbox("Notification")

local _hitNotifyState = getgenv().__XilosHitNotifierState or {
    Hooked = false,
    Enabled = false,
    OriginalDamageNumberEffect = nil,
    WrappedDamageNumberEffect = nil,
    LastNotifyKey = nil,
    LastNotifyTime = 0,
    NotifyQueue = {},
    Version = 1,
}
getgenv().__XilosHitNotifierState = _hitNotifyState

local _hitNotifyFormat = getgenv().__XilosHitNotifyFormat or "Hit {NAME} for {DMG} in the {PART}"
local _hitNotifyDuration = 2

local function _hitGetCharacterFromInstance(inst)
    local current = inst
    while current and current ~= workspace do
        if current:IsA("Model") then
            local hum = current:FindFirstChildOfClass("Humanoid")
                or current:FindFirstChild("EnemyHumanoid")
            if hum or players:GetPlayerFromCharacter(current) then
                return current
            end
        end
        current = current.Parent
    end
    return nil
end

local function _hitGetPartName(inst)
    if not inst then return "Unknown" end
    local name = inst.Name
    if name == "HitboxHead" or name == "HitboxHeadSmall" or name == "Head" then
        return "Head"
    end
    if name == "HitboxBody" or name == "HitboxBodySmall" then
        return "Body"
    end
    return name
end

local function _hitSafeTableGet(tab, key)
    if typeof(tab) ~= "table" then return nil end
    local ok, v = pcall(rawget, tab, key)
    if ok then return v end
    return nil
end

local function _hitFindInTableValues(tab, callback)
    local found
    pcall(function()
        for _, value in pairs(tab) do
            found = callback(value)
            if found ~= nil then return end
        end
    end)
    return found
end

local function _hitFindInstance(value, depth)
    if depth > 5 then return nil end
    if typeof(value) == "Instance" then
        return _hitGetCharacterFromInstance(value) and value or nil
    end
    if typeof(value) ~= "table" then return nil end

    local direct = _hitSafeTableGet(value, utf8.char(2))
        or _hitSafeTableGet(value, utf8.char(1))
        or _hitSafeTableGet(value, "HitPart")
        or _hitSafeTableGet(value, "Hitbox")
        or _hitSafeTableGet(value, "Instance")
        or _hitSafeTableGet(value, "Part")
        or _hitSafeTableGet(value, "Target")
        or _hitSafeTableGet(value, "TargetPart")
        or _hitSafeTableGet(value, "Humanoid")
    if typeof(direct) == "Instance" and _hitGetCharacterFromInstance(direct) then
        return direct
    end

    return _hitFindInTableValues(value, function(child)
        local found = _hitFindInstance(child, depth + 1)
        if found then return found end
    end)
end

local function _hitGetDamageValue(data, depth)
    if type(data) == "number" and data > 0 and data <= 1000 then
        return data
    end
    if depth > 6 or typeof(data) ~= "table" then return nil end

    local direct = _hitSafeTableGet(data, utf8.char(0))
        or _hitSafeTableGet(data, "Damage")
        or _hitSafeTableGet(data, "damage")
        or _hitSafeTableGet(data, "Amount")
        or _hitSafeTableGet(data, "amount")
        or _hitSafeTableGet(data, "DamageAmount")
        or _hitSafeTableGet(data, "damageAmount")
        or _hitSafeTableGet(data, "HealthRemoved")
        or _hitSafeTableGet(data, "healthRemoved")

    if type(direct) == "number" and direct > 0 then
        return direct
    end

    local nested = _hitFindInTableValues(data, function(child)
        if typeof(child) == "table" then
            local found = _hitGetDamageValue(child, depth + 1)
            if found then return found end
        end
    end)
    if nested then return nested end

    return _hitFindInTableValues(data, function(child)
        if type(child) == "number" and child > 0 and child <= 500 then
            return child
        end
    end)
end

local function _hitGetNotifyDuration()
    return math.clamp(tonumber(_hitNotifyDuration) or 2, 0.5, 10)
end

local function _hitGetWeaponName()
    local ok, name = pcall(function()
        if fighterCtrl then
            local fighter = fighterCtrl.LocalFighter or fighterCtrl:GetFighter(lplr)
            local item = fighter and fighter.EquippedItem
            if not item then return "Unknown" end
            if type(item.Get) == "function" then
                return item:Get("Name") or item:Get("ItemName") or item:Get("WeaponName")
            end
            return item.Name or (item.Info and item.Info.Name)
        end
        return "Unknown"
    end)
    return ok and tostring(name or "Unknown") or "Unknown"
end

local function _hitBuildMessage(playerName, damage, part)
    local format = tostring(_hitNotifyFormat or "")
    if format == "" then
        format = "Hit {NAME} for {DMG} in the {PART}"
    end
    local weapon = _hitGetWeaponName()
    return format
        :gsub("{NAME}", playerName)
        :gsub("{DMG}", damage)
        :gsub("{PART}", part)
        :gsub("{WEAPON}", weapon)
        :gsub("{player}", playerName)
        :gsub("{damage}", damage)
        :gsub("{part}", part)
        :gsub("{weapon}", weapon)
end

local _hitNotifyQueue = _hitNotifyState.NotifyQueue

local function _hitFlush(text, duration)
    if Library and type(Library.Notify) == "function" then
        local ok = pcall(function() Library:Notify(text, duration) end)
        if ok then return end
    end
    if mainapi and type(mainapi.SafeNotify) == "function" then
        pcall(function()
            mainapi:SafeNotify({ Text = text, Duration = duration })
        end)
    end
end

task.spawn(function()
    while true do
        local item = table.remove(_hitNotifyQueue, 1)
        if item then
            _hitFlush(item.Text, item.Duration)
            task.wait(0.02)
        else
            task.wait(0.25)
        end
    end
end)

local function _hitSend(text, duration)
    table.insert(_hitNotifyQueue, { Text = text, Duration = duration })
end

local function _hitFindDamageTarget(value, depth)
    if depth > 6 then return nil end
    if typeof(value) == "Instance" then
        local character = _hitGetCharacterFromInstance(value)
        if character and character ~= lplr.Character then
            return value, character
        end
        return nil
    end
    if typeof(value) ~= "table" then return nil end

    local found = _hitFindInTableValues(value, function(child)
        local part, character = _hitFindDamageTarget(child, depth + 1)
        if part then return { part, character } end
    end)
    if found then return found[1], found[2] end
    return nil
end

local function _hitNotifyDamageIndicator(...)
    local args = table.pack(...)
    local damage, hitPart, character

    for index = 2, args.n do
        local value = args[index]
        damage = damage or _hitGetDamageValue(value, 0)
        if not hitPart then
            hitPart, character = _hitFindDamageTarget(value, 0)
        end
    end

    if not damage or not hitPart or not character then return end
    local player = players:GetPlayerFromCharacter(character)
    if player == lplr then return end

    local playerName = player and player.Name or character.Name
    local part = _hitGetPartName(hitPart)
    local damageText = damage % 1 == 0 and tostring(damage) or string.format("%.1f", damage)
    local text = _hitBuildMessage(playerName, damageText, part)
    local key = playerName .. "|" .. part .. "|" .. tostring(damage)
    local now = tick()

    if _hitNotifyState.LastNotifyKey == key
        and now - (_hitNotifyState.LastNotifyTime or 0) < 0.08 then
        return
    end

    _hitNotifyState.LastNotifyKey = key
    _hitNotifyState.LastNotifyTime = now
    _hitSend(text, _hitGetNotifyDuration())
end

local function _hitInstallHooks()
    local ok, err = pcall(function()
        local fighter = fighterCtrl and (fighterCtrl.LocalFighter or fighterCtrl:GetFighter(lplr))
        local fighterClass = fighter and getmetatable(fighter)
        fighterClass = fighterClass and fighterClass.__index
        if type(fighterClass) ~= "table" or type(fighterClass._DamageNumberEffect) ~= "function" then
            error("_DamageNumberEffect unavailable")
        end

        if _hitNotifyState.WrappedDamageNumberEffect
            and fighterClass._DamageNumberEffect == _hitNotifyState.WrappedDamageNumberEffect then
            _hitNotifyState.Hooked = true
            return
        end

        _hitNotifyState.OriginalDamageNumberEffect = fighterClass._DamageNumberEffect
        _hitNotifyState.WrappedDamageNumberEffect = function(...)
            if _hitNotifyState.Enabled then
                pcall(_hitNotifyDamageIndicator, ...)
            end
            local result = table.pack(_hitNotifyState.OriginalDamageNumberEffect(...))
            return unpack(result, 1, result.n)
        end

        fighterClass._DamageNumberEffect = _hitNotifyState.WrappedDamageNumberEffect
    end)

    if not ok then
        warn("[Hit Notifier] Hook failed:", err)
        return false
    end
    _hitNotifyState.Hooked = true
    return true
end

local function _hitUninstallHooks()
    _hitNotifyState.Enabled = false
    pcall(function()
        local fighter = fighterCtrl and (fighterCtrl.LocalFighter or fighterCtrl:GetFighter(lplr))
        local fighterClass = fighter and getmetatable(fighter)
        fighterClass = fighterClass and fighterClass.__index
        if fighterClass
            and fighterClass._DamageNumberEffect == _hitNotifyState.WrappedDamageNumberEffect
            and _hitNotifyState.OriginalDamageNumberEffect then
            fighterClass._DamageNumberEffect = _hitNotifyState.OriginalDamageNumberEffect
        end
    end)
    _hitNotifyState.Hooked = false
end

NotificationGroup:AddToggle("HitNotifierEnabled", {
    Text = "Hit Notifier",
    Tooltip = "Notifies you when you hit an enemy (name, damage, weapon, part)",
    Default = false,
    Callback = function(Value)
        _hitNotifyState.Enabled = Value == true
        if Value then
            _hitInstallHooks()
        else
            _hitUninstallHooks()
        end
    end
}):AddKeyPicker("HitNotifierKeybind", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Hit Notifier",
    NoUI = false,
})

NotificationGroup:AddInput("HitNotifyFormatInput", {
    Default = "Hit {NAME} for {DMG} in the {PART}",
    Text = "message format",
    Placeholder = "{NAME} took {DMG} from {WEAPON} in the {PART}",
    Numeric = false,
    Finished = true,
    Callback = function(Value)
        if tostring(Value or "") ~= "" then
            _hitNotifyFormat = Value
            getgenv().__XilosHitNotifyFormat = Value
        else
            _hitNotifyFormat = "Hit {NAME} for {DMG} in the {PART}"
            getgenv().__XilosHitNotifyFormat = _hitNotifyFormat
        end
    end
})

local RagebotModule
pcall(function()
    local Ragebot
    local RagebotSettings = {
        on = false,
        targetMode = "Closest",
        autoSwitch = true,
        autoSwapSecondary = true,
        autoReloadPrimary = true,
        attackMode = "gun",
        preferredWeapon = "primary",
        meleeSlot = 3,
        weaponSpecialize = true,
        autoEquipPreferred = true,
        preferProjectile = false,
        autoPriority = false,
        priorityAttackers = true,
        priorityVoided = true,
        sendNotification = false,
        prioritizedPlayer = nil,
        primarySlot = 1,
        secondarySlot = 2,
        acSpd = 0.05,
        shootDelay = 0,
        teleportDelay = 0.04,
        orbitDist = 3,
        orbitHeight = 2,
        randomMovement = false,
        randomRefresh = 0.08,
        mode = "Orbit",
        strafeSpeed = 5,
        undergroundDepth = 6,
        behindDist = 4,
        antiAim = false,
        hyper = false,
        useManipulation = true,
        voidSpam = true,
        voidHideTime = 0.25,
        voidShootTime = 0.03,
        shootAttempts = 1,
        otherMatchAvoidDistance = 1000,
        settleUntil = 0,
        dirBack = true,
        dirFront = false,
        dirLeft = true,
        dirRight = true,
        dirUp = true,
        dirDown = false,
    }

    local function markRagebotSettingsDirty()
        RagebotSettings.settleUntil = 0
    end

    local rbGen = 0
    local rbDuelModInner, rbInMatchTInner, rbInMatchInner = nil, 0, false
    local slotKey = {[1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two, [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four}

    Ragebot = Movement:AddModule({
        Name = 'Ragebot',
        Function = function(callback)
            local cfg = RagebotSettings

            if callback then
                if getgenv().__IDKRagebotStop then
                    pcall(getgenv().__IDKRagebotStop)
                    getgenv().__IDKRagebotStop = nil
                end

                cfg.on = true
                cfg.settleUntil = 0

                local _players = cloneref(game:GetService("Players"))
                local _runservice = cloneref(game:GetService("RunService"))
                local _vim = cloneref(game:GetService("VirtualInputManager"))
                local _ws = cloneref(game:GetService("Workspace"))
                local _rs = cloneref(game:GetService("ReplicatedStorage"))
                local _lplr = _players.LocalPlayer

                local _util, _enums, _useItemRemote, _fighterCtrl
                pcall(function()
                    _util = require(_rs.Modules.Utility)
                    _enums = require(_rs.Modules.EnumLibrary)
                    _useItemRemote = _rs.Remotes.Replication.Fighter.UseItem
                    _fighterCtrl = require(_lplr.PlayerScripts.Controllers.FighterController)
                end)

                local state = {
                    active = true,
                    target = nil,
                    conn = nil,
                    ammoThread = nil,
                    voidThread = nil,
                    voidHbConn = nil,
                    csyncHbConn = nil,
                    voidExposed = false,
                    voidTargetCF = nil,
                    nextTeleportAt = 0,
                    ammoActionAt = 0,
                    hideOrbitUntil = 0,
                    randPos = nil,
                    randT = 0,
                    lastFakePos = nil,
                    csyncCF = nil,
                    csyncLV = nil,
                    csyncAV = nil,
                    csyncLocalCF = nil,
                    csyncLocalLV = nil,
                    csyncLocalAV = nil,
                    csyncWroteFake = false,
                    noclipConn = nil,
                    suspended = isShootingRange(),
                }

                local function getRoot(char)
                    return char and char:FindFirstChild("HumanoidRootPart")
                end

                local function getFighter()
                    if _fighterCtrl and _fighterCtrl.LocalFighter then return _fighterCtrl.LocalFighter end
                    if _fighterCtrl and _fighterCtrl.GetFighter then
                        local ok, fighter = pcall(_fighterCtrl.GetFighter, _fighterCtrl, _lplr)
                        if ok then return fighter end
                    end
                    return nil
                end

                local function pressKey(kc)
                    _vim:SendKeyEvent(true, kc, false, game)
                    task.wait(0.03)
                    _vim:SendKeyEvent(false, kc, false, game)
                end

                local function scanWeapon(plr)
                    local vms = _ws:FindFirstChild("ViewModels")
                    if not vms then return "" end
                    for _, model in vms:GetChildren() do
                        if model:IsA("Model") then
                            local sp = model.Name:find(" - ", 1, true)
                            if sp and model.Name:sub(1, sp - 1) == plr.Name then
                                return model.Name:sub(sp + 3):lower()
                            end
                        end
                    end
                    return ""
                end

                local function playerIsDead(plr)
                    local char = plr and plr.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    return not char or not hum or hum.Health <= 0 or not getRoot(char)
                end

                local function isInvincible(plr)
                    local char = plr and plr.Character
                    if not char then return true end
                    local root = getRoot(char)
                    if not root then return true end
                    for _, obj in root:GetChildren() do
                        if obj:IsA("Attachment") and obj.Name == "Attachment" then
                            return true
                        end
                    end
                    return char:FindFirstChild("InvincibilityParticles", true) ~= nil
                end

                local function isKatana(plr)
                    return scanWeapon(plr):find("katana", 1, true) ~= nil
                end

                local function isRiotShield(plr)
                    local weapon = scanWeapon(plr)
                    return weapon:find("riot", 1, true) ~= nil or weapon:find("shield", 1, true) ~= nil
                end

                local function IsValidMatch(player)
                    return player:GetAttribute("EnvironmentID") == _lplr:GetAttribute("EnvironmentID")
                end

                local function isNearOtherMatch(pos, ignorePlayer)
                    local avoidDistance = cfg.otherMatchAvoidDistance or 1000
                    if typeof(pos) ~= "Vector3" or avoidDistance <= 0 then return false end
                    for _, plr in _players:GetPlayers() do
                        if plr ~= _lplr and plr ~= ignorePlayer and not IsValidMatch(plr) then
                            local otherRoot = getRoot(plr.Character)
                            if otherRoot and (otherRoot.Position - pos).Magnitude <= avoidDistance then
                                return true
                            end
                        end
                    end
                    return false
                end

                local function isSafeRagebotPos(pos, targetPlayer)
                    return not isNearOtherMatch(pos, targetPlayer)
                end

                local function shouldSkip(plr)
                    if plr == _lplr or playerIsDead(plr) then return true end
                    if not IsValidMatch(plr) then return true end
                    if isInvincible(plr) then return true end
                    local root = getRoot(plr.Character)
                    if root and isNearOtherMatch(root.Position, plr) then return true end
                    return root and root:FindFirstChild("TeammateLabel") ~= nil
                end

                local function getBestTarget()
                    local root = getRoot(_lplr.Character)
                    if not root then return nil end
                    if cfg.prioritizedPlayer then
                        local priorityPlayer = _players:FindFirstChild(cfg.prioritizedPlayer)
                        if priorityPlayer and not shouldSkip(priorityPlayer) then
                            return priorityPlayer
                        end
                    end
                    local best, bestV = nil, math.huge
                    local useHP = cfg.targetMode == "Lowest Health"
                    for _, plr in _players:GetPlayers() do
                        if not shouldSkip(plr) then
                            local char = plr.Character
                            local tr = getRoot(char)
                            local hum = char and char:FindFirstChildOfClass("Humanoid")
                            local value = useHP and hum.Health or (tr.Position - root.Position).Magnitude
                            if cfg.autoPriority then
                                if cfg.priorityVoided and tr.Position.Magnitude > 1000000 then
                                    value -= 2000000000
                                end
                                if cfg.priorityAttackers and scanWeapon(plr) ~= "" then
                                    value -= 1000000000
                                end
                            end
                            if value < bestV then
                                bestV = value
                                best = plr
                            end
                        end
                    end
                    return best
                end

                local function hasValidTarget()
                    return state.target and not playerIsDead(state.target) and not isInvincible(state.target)
                end

                local function updateRagebotStatus()
                    local target = hasValidTarget() and state.target or nil
                    local voiding = not target or ((cfg.mode == "Void" or cfg.mode == "Orbit") and not state.voidExposed)
                    setRagebotStatus(state.active and cfg.on, target, voiding)
                end

                local function shouldShoot()
                    if not hasValidTarget() then return false end
                    if isKatana(state.target) then return false end
                    if cfg.mode == "Void" and not state.voidExposed then return false end
                    return true
                end

                local function getEquippedSlot()
                    local fighter = getFighter()
                    local item = fighter and fighter.EquippedItem
                    if not item then return nil end
                    local slot = item:Get("Slot")
                    return tonumber(slot)
                end

                local function equipSlot(slot)
                    slot = tonumber(slot) or 1
                    local key = slotKey[slot] or Enum.KeyCode.One
                    pcall(function()
                        pressKey(key)
                    end)
                end

                local function applyWeaponRageProfile()
                    if cfg.weaponSpecialize == false then return "default" end
                    local slot = getEquippedSlot()
                    local pref = cfg.preferredWeapon or "primary"

                    if cfg.autoEquipPreferred ~= false then
                        local want = (pref == "secondary" and (cfg.secondarySlot or 2))
                            or (pref == "melee" and (cfg.meleeSlot or 3))
                            or (cfg.primarySlot or 1)
                        if slot ~= want then
                            equipSlot(want)
                            slot = want
                        end
                    end

                    local kind
                    if slot == (cfg.meleeSlot or 3) or pref == "melee" then
                        kind = "melee"
                    elseif slot == (cfg.secondarySlot or 2) or pref == "secondary" then
                        kind = "secondary"
                    else
                        kind = "primary"
                    end

                    if kind == "primary" then
                        cfg.mode = "Orbit"
                        cfg.hyper = true
                        cfg.orbitDist = 3.2
                        cfg.orbitHeight = 2.2
                        cfg.strafeSpeed = 6
                        cfg.teleportDelay = 0.035
                        cfg.predictLead = 0.14
                        cfg.behindDist = 3.5
                        cfg.randomMovement = false
                        cfg.dirBack = true
                        cfg.dirFront = false
                        cfg.dirLeft = true
                        cfg.dirRight = true
                    elseif kind == "secondary" then
                        cfg.mode = "Teleport"
                        cfg.hyper = false
                        cfg.orbitDist = 2.6
                        cfg.orbitHeight = 1.6
                        cfg.strafeSpeed = 4
                        cfg.teleportDelay = 0.028
                        cfg.predictLead = 0.11
                        cfg.behindDist = 3.0
                        cfg.randomMovement = true
                        cfg.randomRefresh = 0.07
                        cfg.dirBack = true
                        cfg.dirFront = true
                        cfg.dirLeft = true
                        cfg.dirRight = true
                    else
                        cfg.mode = "Underground"
                        cfg.hyper = true
                        cfg.orbitDist = 1.6
                        cfg.orbitHeight = 0.6
                        cfg.strafeSpeed = 8
                        cfg.teleportDelay = 0.02
                        cfg.predictLead = 0.08
                        cfg.behindDist = 2.2
                        cfg.undergroundDepth = 4
                        cfg.randomMovement = false
                        cfg.dirBack = true
                        cfg.dirFront = false
                        cfg.dirLeft = true
                        cfg.dirRight = true
                        cfg.dirDown = true
                    end

                    state.weaponKind = kind
                    return kind
                end

                local function handleAmmo()
                    local fighter = getFighter()
                    local item = fighter and fighter.EquippedItem
                    if not fighter or not item then return false end
                    local ammo = item:Get("Ammo") or 0
                    local slot = item:Get("Slot") or 1
                    local now = tick()
                    if fighter:Get("Reloading") then
                        state.hideOrbitUntil = math.max(state.hideOrbitUntil or 0, now + 0.25)
                        state.ammoActionAt = math.max(state.ammoActionAt or 0, now + 0.1)
                        return true
                    end
                    if ammo > 0 then return false end
                    if now < (state.ammoActionAt or 0) then return true end

                    local primary = cfg.primarySlot or 1
                    local secondary = cfg.secondarySlot or 2
                    if slot == primary and cfg.autoSwapSecondary then
                        state.ammoActionAt = now + 0.45
                        state.hideOrbitUntil = math.max(state.hideOrbitUntil or 0, now + 0.45)
                        pressKey(slotKey[secondary] or Enum.KeyCode.Two)
                        return true
                    end
                    if slot == secondary and cfg.autoReloadPrimary then
                        state.ammoActionAt = now + 0.6
                        state.hideOrbitUntil = math.max(state.hideOrbitUntil or 0, now + 0.75)
                        pressKey(slotKey[primary] or Enum.KeyCode.One)
                        task.delay(0.18, function()
                            if not state.active then return end
                            local f2 = getFighter()
                            local i2 = f2 and f2.EquippedItem
                            if f2 and i2 and (i2:Get("Slot") or 1) == primary and (i2:Get("Ammo") or 0) <= 0 and not f2:Get("Reloading") then
                                pressKey(Enum.KeyCode.R)
                            end
                        end)
                        return true
                    end
                    if slot == primary and cfg.autoReloadPrimary then
                        state.ammoActionAt = now + 0.5
                        state.hideOrbitUntil = math.max(state.hideOrbitUntil or 0, now + 0.75)
                        pressKey(Enum.KeyCode.R)
                        return true
                    end
                    return true
                end

                local function buildCameraData(fromPos, part)
                    if not _util or not part then return nil end
                    local look = CFrame.new(fromPos, part.Position)
                    local data = {}
                    data[utf8.char(1)] = {
                        [utf8.char(0)] = _util:EncodeCFrame(look),
                        [utf8.char(1)] = _util:EncodeCFrame(look),
                        [utf8.char(2)] = part,
                        [utf8.char(3)] = _util:EncodeCFrame(part.CFrame:ToObjectSpace(CFrame.new(part.Position)))
                    }
                    return data
                end

                local function doFire(part)
                    local fighter = getFighter()
                    local item = fighter and fighter.EquippedItem
                    if not item or not part then return false end

                    local cam = _ws.CurrentCamera
                    local fromPos = (state.csyncCF and state.csyncCF.Position) or (cam and cam.CFrame.Position) or part.Position
                    local anyFired = false
                    local attempts = math.max(1, math.floor(cfg.shootAttempts or 1))

                    for _ = 1, attempts do
                        local fired = false
                        if cfg.useManipulation and _useItemRemote and _enums and _util then
                            local ammo = item.Get and (item:Get("Ammo") or 0) or 0
                            if ammo > 0 then
                                local oid = item:Get("ObjectID")
                                local shootEnum = _enums:ToEnum("StartShooting")
                                local data = buildCameraData(fromPos, part)
                                if oid and shootEnum and data then
                                    fired = pcall(function()
                                        _useItemRemote:FireServer(oid, shootEnum, data, nil)
                                    end)
                                end
                            end
                        end
                        if not fired and item.UseItem then
                            fired = pcall(function() item:UseItem() end)
                        end
                        if not fired and fighter and fighter.UseItem then
                            fired = pcall(function() fighter:UseItem() end)
                        end
                        anyFired = anyFired or fired
                    end
                    return anyFired
                end

                local function isLobby()
                    local playerGui = _lplr:FindFirstChild("PlayerGui")
                    local mainGui = playerGui and playerGui:FindFirstChild("MainGui")
                    local mainFrame = mainGui and mainGui:FindFirstChild("MainFrame")
                    local lobby = mainFrame and mainFrame:FindFirstChild("Lobby")
                    local currency = lobby and lobby:FindFirstChild("Currency")
                    return currency and currency.Visible == true
                end

                local function getDuel()
                    if not rbDuelModInner then
                        local ps = _lplr:FindFirstChild("PlayerScripts")
                        local ct = ps and ps:FindFirstChild("Controllers")
                        local dc = ct and ct:FindFirstChild("DuelController")
                        if dc then
                            local ok, mod = pcall(require, dc)
                            if ok and mod then rbDuelModInner = mod end
                        end
                    end
                    if rbDuelModInner and rbDuelModInner.GetDuel then
                        local ok, duel = pcall(rbDuelModInner.GetDuel, rbDuelModInner, _lplr)
                        if ok then return duel end
                    end
                end

                local function isValidMatch()
                    if isLobby() or isShootingRange() then return false end
                    local char = _lplr.Character
                    local root = getRoot(char)
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not char or not root or not hum or hum.Health <= 0 then
                        return false
                    end
                    local duel = getDuel()
                    if duel ~= nil then return true end
                    local fighter = getFighter()
                    return fighter ~= nil
                end

                local function inMatch()
                    local now = tick()
                    if now - rbInMatchTInner < 0.25 then return rbInMatchInner end
                    rbInMatchTInner = now
                    rbInMatchInner = isValidMatch()
                    return rbInMatchInner
                end

                local function undergroundPos(head, targetRoot)
                    local depth = math.clamp(cfg.undergroundDepth or 6, 3, 8)
                    local radius = math.clamp(cfg.orbitDist or 3, 1.25, 4)
                    return head.Position - targetRoot.CFrame.LookVector * radius + Vector3.new(0, -depth, 0)
                end

                local oldFireServerRagebot
                local rbHookInstalled = false
                local enterVoidState
                local setVoidCsync
                local function installRagebotHook()
                    if rbHookInstalled then return end
                    if not _useItemRemote then return end
                    rbHookInstalled = true
                    oldFireServerRagebot = hookfunction(_useItemRemote.FireServer, newcclosure(function(self, oid, action, cameradata, ...)
                        if state.active and cfg.on and cfg.mode == "Void" and cfg.useManipulation and action == _enums:ToEnum("StartShooting") then
                            if isLobby() or not inMatch() then
                                return oldFireServerRagebot(self, oid, action, cameradata, ...)
                            end

                            local target = state.target
                            if hasValidTarget() and not isKatana(target) then
                                local tc = target.Character
                                local tr = getRoot(tc)
                                local head = tc and (tc:FindFirstChild("Head") or tr)
                                if tr and head then
                                    local shootPos = isRiotShield(target)
                                        and (tr.Position - tr.CFrame.LookVector * (cfg.behindDist or 4))
                                        or (tr.Position - tr.CFrame.LookVector * 2.5 + Vector3.new(0, 1.5, 0))
                                    if not isSafeRagebotPos(shootPos, target) then
                                        enterVoidState()
                                        return oldFireServerRagebot(self, oid, action, cameradata, ...)
                                    end
                                    local shootCF = CFrame.new(shootPos, head.Position)

                                    state.voidExposed = true
                                    state.voidTargetCF = shootCF
                                    setVoidCsync(shootCF, Vector3.zero, Vector3.zero)
                                    updateRagebotStatus()

                                    task.wait(0.02)

                                    local newData = buildCameraData(shootPos, head) or cameradata

                                    task.spawn(function()
                                        task.wait(0.05)
                                        enterVoidState()
                                    end)

                                    return oldFireServerRagebot(self, oid, action, newData, ...)
                                end
                            end
                        end
                        return oldFireServerRagebot(self, oid, action, cameradata, ...)
                    end))
                end

                local function rnd()
                    return math.random() * 2 - 1
                end

                local function rndDir()
                    local angle = math.random() * math.pi * 2
                    return Vector3.new(math.cos(angle), 0, math.sin(angle))
                end

                local function getDirs(targetRoot)
                    local dirs = {}
                    local look = targetRoot.CFrame.LookVector
                    local right = targetRoot.CFrame.RightVector
                    if cfg.dirBack then table.insert(dirs, -look) end
                    if cfg.dirFront then table.insert(dirs, look) end
                    if cfg.dirLeft then table.insert(dirs, -right) end
                    if cfg.dirRight then table.insert(dirs, right) end
                    if #dirs == 0 then
                        dirs[1] = -look
                        dirs[2] = right
                        dirs[3] = -right
                    end
                    return dirs
                end

                local function pickOffset(targetRoot, head)
                    local dirs = getDirs(targetRoot)
                    local dir = dirs[math.random(1, #dirs)]
                    local radius = math.clamp(cfg.orbitDist or 3, 1.25, 5)
                    local height = math.clamp(cfg.orbitHeight or 2, -2, 6)
                    local pos = head.Position + dir * radius + Vector3.new(0, height, 0)
                    if cfg.dirUp and math.random() < 0.2 then
                        pos += Vector3.new(0, math.max(1, height), 0)
                    elseif cfg.dirDown and math.random() < 0.15 then
                        pos += Vector3.new(0, -math.max(1, math.min(3, cfg.undergroundDepth or 2)), 0)
                    end
                    return pos
                end

                local function setCsync(cf, pos, dt)
                    local old = state.lastFakePos
                    state.csyncCF = cf
                    state.csyncLV = old and dt and dt > 0 and (pos - old) / dt or Vector3.zero
                    state.csyncAV = Vector3.zero
                    state.lastFakePos = pos
                end

                local function applyExternalMovementVelocity()
                    local fn = getgenv and getgenv().__LionApplyMovementVelocity
                    if type(fn) == "function" then
                        pcall(fn)
                    end
                end

                local function clearCsyncTarget()
                    state.csyncCF = nil
                    state.csyncLV = nil
                    state.csyncAV = nil
                    state.lastFakePos = nil
                end

                local function isRagebotSettling()
                    return os.clock() < (cfg.settleUntil or 0)
                end

                local function restoreLocalRoot(root)
                    if not root or not state.csyncLocalCF then return false end
                    local liveVelocity = root.AssemblyLinearVelocity
                    root.CFrame = state.csyncLocalCF
                    if state.csyncLocalLV then
                        root.AssemblyLinearVelocity = Vector3.new(state.csyncLocalLV.X, liveVelocity.Y, state.csyncLocalLV.Z)
                    end
                    if state.csyncLocalAV then
                        root.AssemblyAngularVelocity = state.csyncLocalAV
                    end
                    return true
                end

                local function startCsync()
                    if state.csyncHbConn then return end
                    state.csyncHbConn = _runservice.Heartbeat:Connect(function()
                        local root = getRoot(_lplr.Character)
                        if not root then return end
                        if state.csyncWroteFake and state.csyncLocalCF then
                            restoreLocalRoot(root)
                        end
                        if isRagebotSettling() then
                            state.csyncLocalCF = root.CFrame
                            state.csyncLocalLV = root.AssemblyLinearVelocity
                            state.csyncLocalAV = root.AssemblyAngularVelocity
                            state.csyncWroteFake = false
                            return
                        end
                        state.csyncLocalCF = root.CFrame
                        state.csyncLocalLV = root.AssemblyLinearVelocity
                        state.csyncLocalAV = root.AssemblyAngularVelocity
                        if state.csyncCF then
                            root.CFrame = state.csyncCF
                            local fakeVelocity = state.csyncLV or state.csyncLocalLV or root.AssemblyLinearVelocity
                            local localVelocity = state.csyncLocalLV or root.AssemblyLinearVelocity
                            root.AssemblyLinearVelocity = Vector3.new(fakeVelocity.X, localVelocity.Y, fakeVelocity.Z)
                            root.AssemblyAngularVelocity = state.csyncAV or state.csyncLocalAV or root.AssemblyAngularVelocity
                            state.csyncWroteFake = true
                        else
                            state.csyncWroteFake = false
                        end
                    end)
                    _runservice:BindToRenderStep("IDK_RagebotCsync", Enum.RenderPriority.Camera.Value - 1, function()
                        local root = getRoot(_lplr.Character)
                        if not root or not state.csyncLocalCF then return end
                        local restored = false
                        if state.csyncWroteFake and restoreLocalRoot(root) then
                            state.csyncWroteFake = false
                            restored = true
                        end
                        if restored then
                            applyExternalMovementVelocity()
                        end
                    end)
                end

                local function stopCsync()
                    if state.csyncHbConn then state.csyncHbConn:Disconnect(); state.csyncHbConn = nil end
                    _runservice:UnbindFromRenderStep("IDK_RagebotCsync")
                    restoreLocalRoot(getRoot(_lplr.Character))
                    clearCsyncTarget()
                    state.csyncLocalCF = nil
                    state.csyncLocalLV = nil
                    state.csyncLocalAV = nil
                    state.csyncWroteFake = false
                end

                local function voidRand()
                    local n = math.random(-2147483646, 2147483646)
                    repeat
                        n = math.random(-2147483646, 2147483646)
                    until n < -1147483646 or n > 1147483646
                    return n
                end

                local function voidRandCF()
                    return CFrame.new(voidRand(), voidRand(), voidRand()) * CFrame.Angles(math.pi, math.pi, math.pi)
                end

                setVoidCsync = function(cf, lv, av)
                    state.csyncCF = cf
                    state.csyncLV = lv or Vector3.zero
                    state.csyncAV = av or Vector3.zero
                    state.lastFakePos = cf and cf.Position or nil
                end

                enterVoidState = function()
                    state.voidTargetCF = nil
                    state.voidExposed = false
                    state.orbitClientCF = nil

                    if not state.active or not cfg.on then
                        clearCsyncTarget()
                        updateRagebotStatus()
                        return
                    end

                    if cfg.voidSpam then
                        setVoidCsync(voidRandCF())
                    else
                        clearCsyncTarget()
                    end
                    updateRagebotStatus()
                end

                local function enableVoidCsync()
                    if state.voidHbConn then return end
                    startCsync()
                    state.voidHbConn = _runservice.Heartbeat:Connect(function()
                        if isRagebotSettling() then
                            state.voidTargetCF = nil
                            state.voidExposed = false
                            clearCsyncTarget()
                            return
                        end
                        local targetCF = state.voidTargetCF
                        if targetCF then
                            setVoidCsync(targetCF, Vector3.zero, Vector3.zero)
                        elseif cfg.voidSpam then
                            setVoidCsync(voidRandCF())
                        else
                            clearCsyncTarget()
                        end
                    end)
                end

                local function disableVoidCsync()
                    if state.voidHbConn then state.voidHbConn:Disconnect(); state.voidHbConn = nil end
                    _runservice:UnbindFromRenderStep("IDK_RagebotVoid")
                    state.voidTargetCF = nil
                    state.voidThread = nil
                    state.voidExposed = false
                end

                local function StartOrbitRenderFix()
                    if state.orbitRenderRunning then return end
                    state.orbitRenderRunning = true
                    _runservice:BindToRenderStep("IDK_RagebotOrbit", Enum.RenderPriority.First.Value, function()
                        if not state.orbitClientCF then return end
                        local root = getRoot(_lplr.Character)
                        if not root then return end
                        root.CFrame = state.orbitClientCF
                        applyExternalMovementVelocity()
                    end)
                end

                local function StopOrbitRenderFix()
                    if not state.orbitRenderRunning then return end
                    _runservice:UnbindFromRenderStep("IDK_RagebotOrbit")
                    state.orbitRenderRunning = false
                    state.orbitClientCF = nil
                end

                local function startVoidLoop(myGen)
                    if state.voidThread then return end
                    enableVoidCsync()
                    local voidThread
                    voidThread = task.spawn(function()
                        while state.active and cfg.on and rbGen == myGen and not state.suspended do
                            if isRagebotSettling() then
                                state.voidTargetCF = nil
                                state.voidExposed = false
                                clearCsyncTarget()
                                task.wait(0.03)
                                continue
                            end
                            if not inMatch() or not hasValidTarget() or isKatana(state.target) then
                                enterVoidState()
                                task.wait(0.1)
                                continue
                            end

                            enterVoidState()
                            if cfg.voidHideTime > 0 then task.wait(cfg.voidHideTime) end
                            if not state.active or not cfg.on or rbGen ~= myGen or state.suspended or not inMatch() then break end

                            local target = state.target
                            if hasValidTarget() and not isKatana(target) then
                                local tc = target.Character
                                local tr = getRoot(tc)
                                local head = tc and (tc:FindFirstChild("Head") or tr)
                                if tr and head then
                                    local shootPos = isRiotShield(target)
                                        and (tr.Position - tr.CFrame.LookVector * (cfg.behindDist or 4))
                                        or (tr.Position - tr.CFrame.LookVector * 2.5 + Vector3.new(0, 1.5, 0))
                                    if not isSafeRagebotPos(shootPos, target) then
                                        enterVoidState()
                                        task.wait(0.1)
                                        continue
                                    end
                                    local shootCF = CFrame.new(shootPos, head.Position)
                                    state.voidExposed = true
                                    state.voidTargetCF = shootCF
                                    setVoidCsync(shootCF, Vector3.zero, Vector3.zero)
                                    updateRagebotStatus()
                                    if cfg.voidShootTime > 0 then task.wait(cfg.voidShootTime) end
                                    if hasValidTarget() and not isKatana(target) then
                                        doFire(head)
                                    end
                                    task.wait(0.05)
                                    enterVoidState()
                                end
                            end
                        end

                        if state.voidThread == voidThread then
                            state.voidThread = nil
                        end
                        if rbGen == myGen and not state.suspended and state.voidThread == nil then
                            disableVoidCsync()
                        end
                    end)
                    state.voidThread = voidThread
                end

                local function enableNoclip()
                    if state.noclipConn then return end
                    state.noclipConn = _runservice.Stepped:Connect(function()
                        local char = _lplr.Character
                        if not char then return end
                        for _, part in char:GetDescendants() do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end)
                end

                local function startAmmoLoop()
                    if state.ammoThread then return end
                    state.ammoThread = task.spawn(function()
                        while state.active do
                            if isShootingRange() then
                                task.wait(0.1)
                                continue
                            end
                            if not handleAmmo() and shouldShoot() and not cfg.hyper then
                                local tc = state.target and state.target.Character
                                local head = tc and (tc:FindFirstChild("Head") or getRoot(tc))
                                if head then
                                    if cfg.shootDelay > 0 then task.wait(cfg.shootDelay) end
                                    doFire(head)
                                end
                            end
                            task.wait(math.max(0.01, cfg.acSpd))
                        end
                        state.ammoThread = nil
                    end)
                end

                local function stopRagebot()
                    rbGen += 1
                    state.active = false
                    cfg.on = false
                    setRagebotStatus(false)
                    if state.conn then state.conn:Disconnect(); state.conn = nil end
                    if state.noclipConn then state.noclipConn:Disconnect(); state.noclipConn = nil end
                    state.target = nil
                    state.voidExposed = false
                    state.nextTeleportAt = 0
                    state.ammoActionAt = 0
                    state.hideOrbitUntil = 0
                    state.randPos = nil
                    state.randT = 0
                    state.lastFakePos = nil
                    rbInMatchTInner = 0
                    rbInMatchInner = false
                    stopCsync()
                    disableVoidCsync()
                    StopOrbitRenderFix()
                    local char = _lplr.Character
                    if char then
                        for _, part in char:GetDescendants() do
                            if part:IsA("BasePart") then
                                part.CanCollide = true
                            end
                        end
                    end
                end

                rbGen += 1
                local myGen = rbGen
                setRagebotStatus(true, nil, true)
                startAmmoLoop()
                installRagebotHook()
                if not state.suspended then
                    enableNoclip()
                    if cfg.mode == "Void" then
                        startVoidLoop(myGen)
                    elseif cfg.mode == "Orbit" then
                        enableVoidCsync()
                    else
                        startCsync()
                    end
                end

                local aaPhase = 0
                local orbitAngle = math.random() * math.pi * 2

                state.conn = _runservice.Stepped:Connect(function(_, dt)
                    if not state.active or not cfg.on then
                        if state.conn then state.conn:Disconnect(); state.conn = nil end
                        return
                    end

                    if isShootingRange() then
                        if not state.suspended then
                            state.suspended = true
                            state.target = nil
                            state.randPos = nil
                            state.voidTargetCF = nil
                            state.voidExposed = false
                            if state.noclipConn then
                                state.noclipConn:Disconnect()
                                state.noclipConn = nil
                            end
                            stopCsync()
                            disableVoidCsync()
                            StopOrbitRenderFix()
                            updateRagebotStatus()
                        end
                        return
                    end

                    if state.suspended then
                        state.suspended = false
                        enableNoclip()
                        if cfg.mode == "Void" then
                            startVoidLoop(myGen)
                        elseif cfg.mode == "Orbit" then
                            enableVoidCsync()
                            StartOrbitRenderFix()
                        else
                            startCsync()
                        end
                    end

                    local root = getRoot(_lplr.Character)
                    if not root then return end

                    if isRagebotSettling() then
                        state.voidTargetCF = nil
                        state.voidExposed = false
                        state.orbitClientCF = nil
                        clearCsyncTarget()
                        updateRagebotStatus()
                        return
                    end

                    if not inMatch() then
                        clearCsyncTarget()
                        state.target = nil
                        if cfg.mode == "Orbit" then
                            enterVoidState()
                        else
                            updateRagebotStatus()
                        end
                        return
                    end

                    local now = tick()
                    if state.target and playerIsDead(state.target) then
                        state.target = nil
                    end

                    if state.target and isInvincible(state.target) then
                        clearCsyncTarget()
                        if cfg.mode == "Orbit" then
                            enterVoidState()
                        else
                            updateRagebotStatus()
                        end
                        return
                    end

                    if now - rbTgtT >= 0.05 and (cfg.autoSwitch or not state.target) then
                        rbTgtT = now
                        if cfg.autoSwitch then
                            local target = getBestTarget()
                            if target then
                                if cfg.sendNotification and state.target ~= target then
                                    mainapi:SafeNotify({
                                        Title = "ragebot",
                                        Text = "prioritized " .. target.Name,
                                        Duration = 2,
                                    })
                                end
                                state.target = target
                            end
                        elseif not state.target then
                            state.target = getBestTarget()
                        end
                    end

                    if not state.target then
                        clearCsyncTarget()
                        if cfg.mode == "Orbit" then
                            enterVoidState()
                        else
                            updateRagebotStatus()
                        end
                        return
                    end

                    local tc = state.target.Character
                    local tr = getRoot(tc)
                    local head = tc and (tc:FindFirstChild("Head") or tr)
                    if not tc or not tr or not head then
                        state.target = nil
                        updateRagebotStatus()
                        return
                    end

                    if isNearOtherMatch(tr.Position, state.target) then
                        state.target = nil
                        state.randPos = nil
                        if cfg.mode == "Orbit" or cfg.mode == "Void" then
                            enterVoidState()
                        else
                            clearCsyncTarget()
                            updateRagebotStatus()
                        end
                        return
                    end

                    updateRagebotStatus()

                    applyWeaponRageProfile()

                    if cfg.mode == "Void" then return end

                    if cfg.mode == "Orbit" and (now < (state.hideOrbitUntil or 0) or handleAmmo()) then
                        state.voidTargetCF = nil
                        state.voidExposed = false
                        state.orbitClientCF = nil
                        enterVoidState()
                        return
                    end

                    local isUnderground = cfg.mode == "Underground"
                    local isShield = isRiotShield(state.target)
                    local height = math.clamp(cfg.orbitHeight or 2, -2, 6)
                    local radius = math.clamp(cfg.orbitDist or 3, 1.25, 5)
                    local targetPos

                    if isShield then
                        targetPos = tr.Position - tr.CFrame.LookVector * (cfg.behindDist or 3)
                    elseif isUnderground then
                        targetPos = undergroundPos(head, tr)
                    elseif cfg.mode == "Teleport" then
                        if cfg.randomMovement then
                            if not state.randPos or (now - (state.randT or 0)) >= (cfg.randomRefresh or 0.08) then
                                state.randT = now
                                state.randPos = pickOffset(tr, head) + rndDir() * (math.random() * 1.05) + Vector3.new(0, rnd() * 0.7, 0)
                            end
                            targetPos = state.randPos
                        else
                            targetPos = pickOffset(tr, head)
                        end
                    elseif cfg.mode == "Orbit" then
                        orbitAngle += dt * math.max(1, (cfg.strafeSpeed or 5) * 1.5)
                        targetPos = head.Position + Vector3.new(math.cos(orbitAngle) * radius, height, math.sin(orbitAngle) * radius)
                    else
                        targetPos = undergroundPos(head, tr)
                    end

                    if not isSafeRagebotPos(targetPos, state.target) then
                        state.randPos = nil
                        if cfg.mode == "Orbit" then
                            state.voidTargetCF = nil
                            state.voidExposed = false
                            state.orbitClientCF = nil
                            enterVoidState()
                        else
                            clearCsyncTarget()
                            updateRagebotStatus()
                        end
                        return
                    end

                    local faceCF = CFrame.new(targetPos, head.Position)
                    if cfg.antiAim then
                        aaPhase += dt * 20
                        faceCF = CFrame.new(targetPos, head.Position) * CFrame.Angles(0, math.rad(math.sin(aaPhase) * 70), 0)
                    end

                    if cfg.mode == "Orbit" then
                        if cfg.hyper or not isUnderground then
                            state.voidExposed = true
                            state.voidTargetCF = faceCF
                            setCsync(faceCF, targetPos, dt)
                            updateRagebotStatus()

                            if shouldShoot() then
                                doFire(head)
                            end
                        end
                    else
                        setCsync(faceCF, targetPos, dt)

                        if cfg.hyper or (cfg.mode == "Orbit" and not isUnderground) then
                            if shouldShoot() then doFire(head) end
                        elseif cfg.mode == "Teleport" and not isUnderground then
                            if now >= (state.nextTeleportAt or 0) then
                                state.nextTeleportAt = now + math.max(0.01, cfg.teleportDelay or 0.04)
                                if shouldShoot() then doFire(head) end
                            end
                        end
                    end
                end)

                Ragebot:Clean(_lplr.CharacterAdded:Connect(function()
                    stopCsync()
                    disableVoidCsync()
                    StopOrbitRenderFix()
                    state.target = nil
                    clearCsyncTarget()
                    state.csyncLocalCF = nil
                    state.csyncLocalLV = nil
                    state.csyncLocalAV = nil
                    state.csyncWroteFake = false
                    state.voidExposed = false
                    state.hideOrbitUntil = 0
                    if state.active then
                        task.wait(0.5)
                        if state.active then
                            if cfg.mode == "Void" then
                                startVoidLoop(myGen)
                            elseif cfg.mode == "Orbit" then
                                enableVoidCsync()
                                StartOrbitRenderFix()
                            else
                                startCsync()
                            end
                        end
                    end
                end))

                getgenv().__IDKRagebotStop = stopRagebot
                Ragebot:Clean(stopRagebot)
            else
                cfg.on = false
                if getgenv().__IDKRagebotStop then
                    pcall(getgenv().__IDKRagebotStop)
                    getgenv().__IDKRagebotStop = nil
                end
            end
        end
    })

    Ragebot:AddToggle({
        Name = 'void spam',
        Default = true,
        Function = function(callback)
            RagebotSettings.voidSpam = callback
            markRagebotSettingsDirty()
        end
    })

    local RagebotHide = Ragebot:AddSlider({
        Name = 'hide',
        Min = 0,
        Max = 1,
        Default = 0.25,
        Decimal = 100,
        Suffix = 's',
        Compact = true,
        Function = function(value)
            RagebotSettings.voidHideTime = value
            markRagebotSettingsDirty()
        end
    })

    Ragebot:AddSlider({
        Name = 'attack',
        Min = 0,
        Max = 1,
        Default = 0.03,
        Decimal = 100,
        Suffix = 's',
        Compact = true,
        Parent = RagebotHide,
        Function = function(value)
            RagebotSettings.voidShootTime = value
            markRagebotSettingsDirty()
        end
    })

    Ragebot:AddSlider({
        Name = 'shoot attempts',
        Min = 1,
        Max = 10,
        Default = 1,
        Suffix = 'x',
        Function = function(value)
            RagebotSettings.shootAttempts = math.floor(value)
            markRagebotSettingsDirty()
        end
    })

    Ragebot:AddDropdown({
        Name = 'attack mode',
        List = {'gun', 'knife', 'melee'},
        Default = 'gun',
        Function = function(value)
            RagebotSettings.attackMode = value
            markRagebotSettingsDirty()
        end
    })

    Ragebot:AddDropdown({
        Name = 'preferred weapon',
        List = {'primary', 'secondary', 'melee'},
        Default = 'primary',
        Function = function(value)
            RagebotSettings.preferredWeapon = value
            if value == 'primary' then
                RagebotSettings.primarySlot = 1
                RagebotSettings.secondarySlot = 2
            elseif value == 'secondary' then
                RagebotSettings.primarySlot = 2
                RagebotSettings.secondarySlot = 1
            else
                RagebotSettings.primarySlot = 1
                RagebotSettings.secondarySlot = 2
            end
            markRagebotSettingsDirty()
            pcall(function()
                local keys = {[1]=Enum.KeyCode.One,[2]=Enum.KeyCode.Two,[3]=Enum.KeyCode.Three}
                local slot = (value == 'primary' and 1) or (value == 'secondary' and 2) or 3
                local _vim = game:GetService("VirtualInputManager")
                _vim:SendKeyEvent(true, keys[slot], false, game)
                task.wait()
                _vim:SendKeyEvent(false, keys[slot], false, game)
            end)
        end
    })

    Ragebot:AddToggle({
        Name = 'weapon specialize',
        Default = true,
        Function = function(callback)
            RagebotSettings.weaponSpecialize = callback
            markRagebotSettingsDirty()
        end
    })

    Ragebot:AddDropdown({
        Name = 'settings',
        List = {'swap weapons when empty', 'prefer projectile weapon'},
        Default = {['swap weapons when empty'] = true},
        Multi = true,
        Function = function(value)
            RagebotSettings.autoSwapSecondary = value['swap weapons when empty'] == true
            RagebotSettings.autoReloadPrimary = value['swap weapons when empty'] == true
            RagebotSettings.preferProjectile = value['prefer projectile weapon'] == true
            markRagebotSettingsDirty()
        end
    })

    Ragebot:AddToggle({
        Name = 'auto prioritize',
        Tab = 'priority',
        Default = true,
        Function = function(callback)
            RagebotSettings.autoPriority = callback
            RagebotSettings.autoSwitch = callback
            markRagebotSettingsDirty()
        end
    })

    Ragebot:AddToggle({
        Name = 'send notification',
        Tab = 'priority',
        Function = function(callback)
            RagebotSettings.sendNotification = callback
            markRagebotSettingsDirty()
        end
    })

    Ragebot:AddDropdown({
        Name = 'auto priority settings',
        Tab = 'priority',
        List = {'attackers', 'voided players'},
        Default = {attackers = true, ['voided players'] = true},
        Multi = true,
        Function = function(value)
            RagebotSettings.priorityAttackers = value.attackers == true
            RagebotSettings.priorityVoided = value['voided players'] == true
            markRagebotSettingsDirty()
        end
    })

    local function getPlayerNames()
        local names = {}
        for _, player in game:GetService('Players'):GetPlayers() do
            if player ~= game:GetService('Players').LocalPlayer then
                table.insert(names, player.Name)
            end
        end
        table.sort(names)
        return names
    end

    local Prioritized = Ragebot:AddDropdown({
        Name = 'prioritized',
        Tab = 'priority',
        List = getPlayerNames(),
        AllowNull = true,
        Function = function(value)
            RagebotSettings.prioritizedPlayer = value
            markRagebotSettingsDirty()
        end
    })

    local function refreshPriorityPlayers()
        Prioritized:SetList(getPlayerNames())
    end
    Ragebot:Clean(game:GetService('Players').PlayerAdded:Connect(refreshPriorityPlayers))
    Ragebot:Clean(game:GetService('Players').PlayerRemoving:Connect(refreshPriorityPlayers))

    RagebotModule = Ragebot
end)

local VoidModule
pcall(function()
    local Void
    local VoidSettings = {
        on = false,
        voidSpam = true,
        voidHideTime = 0.25,
        voidShootTime = 0.03,
        shootAttempts = 1,
        behindDist = 4,
        useManipulation = true,
        otherMatchAvoidDistance = 1000,
        autoSwapSecondary = true,
        autoReloadPrimary = true,
        primarySlot = 1,
        secondarySlot = 2,
        acSpd = 0.05,
        shootDelay = 0,
    }

    local slotKey = {[1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two, [3] = Enum.KeyCode.Three, [4] = Enum.KeyCode.Four}

    Void = Movement:AddModule({
        Name = 'Void',
        Function = function(callback)
            local cfg = VoidSettings

            if callback then
                if getgenv().__XilosVoidStop then
                    pcall(getgenv().__XilosVoidStop)
                    getgenv().__XilosVoidStop = nil
                end

                cfg.on = true

                local _players = cloneref(game:GetService("Players"))
                local _runservice = cloneref(game:GetService("RunService"))
                local _ws = cloneref(game:GetService("Workspace"))
                local _rs = cloneref(game:GetService("ReplicatedStorage"))
                local _lplr = _players.LocalPlayer

                local _util, _enums, _useItemRemote, _fighterCtrl
                pcall(function()
                    _util = require(_rs.Modules.Utility)
                    _enums = require(_rs.Modules.EnumLibrary)
                    _useItemRemote = _rs.Remotes.Replication.Fighter.UseItem
                    _fighterCtrl = require(_lplr.PlayerScripts.Controllers.FighterController)
                end)

                local state = {
                    active = true,
                    target = nil,
                    voidThread = nil,
                    csyncHbConn = nil,
                    voidExposed = false,
                    voidTargetCF = nil,
                    lastFakePos = nil,
                    csyncCF = nil,
                    csyncLV = nil,
                    csyncAV = nil,
                    csyncLocalCF = nil,
                    csyncLocalLV = nil,
                    csyncLocalAV = nil,
                    csyncWroteFake = false,
                    noclipConn = nil,
                    ammoThread = nil,
                    ammoActionAt = 0,
                }

                local function getRoot(char) return char and char:FindFirstChild("HumanoidRootPart") end
                local function getFighter()
                    if _fighterCtrl and _fighterCtrl.LocalFighter then return _fighterCtrl.LocalFighter end
                    return nil
                end
                local function pressKey(kc)
                    local _vim = cloneref(game:GetService("VirtualInputManager"))
                    _vim:SendKeyEvent(true, kc, false, game)
                    task.wait(0.03)
                    _vim:SendKeyEvent(false, kc, false, game)
                end
                local function scanWeapon(plr)
                    local vms = _ws:FindFirstChild("ViewModels")
                    if not vms then return "" end
                    for _, model in vms:GetChildren() do
                        if model:IsA("Model") then
                            local sp = model.Name:find(" - ", 1, true)
                            if sp and model.Name:sub(1, sp - 1) == plr.Name then
                                return model.Name:sub(sp + 3):lower()
                            end
                        end
                    end
                    return ""
                end
                local function playerIsDead(plr)
                    local char = plr and plr.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    return not char or not hum or hum.Health <= 0 or not getRoot(char)
                end
                local function isInvincible(plr)
                    local char = plr and plr.Character
                    if not char then return true end
                    local root = getRoot(char)
                    if not root then return true end
                    for _, obj in root:GetChildren() do
                        if obj:IsA("Attachment") and obj.Name == "Attachment" then return true end
                    end
                    return char:FindFirstChild("InvincibilityParticles", true) ~= nil
                end
                local function isKatana(plr) return scanWeapon(plr):find("katana", 1, true) ~= nil end
                local function isRiotShield(plr)
                    local weapon = scanWeapon(plr)
                    return weapon:find("riot", 1, true) ~= nil or weapon:find("shield", 1, true) ~= nil
                end
                local function IsValidMatch(player)
                    return player:GetAttribute("EnvironmentID") == _lplr:GetAttribute("EnvironmentID")
                end
                local function isNearOtherMatch(pos, ignorePlayer)
                    local avoidDistance = cfg.otherMatchAvoidDistance or 1000
                    if typeof(pos) ~= "Vector3" or avoidDistance <= 0 then return false end
                    for _, plr in _players:GetPlayers() do
                        if plr ~= _lplr and plr ~= ignorePlayer and not IsValidMatch(plr) then
                            local otherRoot = getRoot(plr.Character)
                            if otherRoot and (otherRoot.Position - pos).Magnitude <= avoidDistance then
                                return true
                            end
                        end
                    end
                    return false
                end
                local function isSafeRagebotPos(pos, targetPlayer)
                    return not isNearOtherMatch(pos, targetPlayer)
                end
                local function hasValidTarget()
                    return state.target and not playerIsDead(state.target) and not isInvincible(state.target)
                end
                local function getBestTarget()
                    local root = getRoot(_lplr.Character)
                    if not root then return nil end
                    local best, bestV = nil, math.huge
                    for _, plr in _players:GetPlayers() do
                        if plr ~= _lplr and not playerIsDead(plr) and not isInvincible(plr) and IsValidMatch(plr) then
                            local tr = getRoot(plr.Character)
                            if tr then
                                local value = (tr.Position - root.Position).Magnitude
                                if value < bestV then
                                    bestV = value
                                    best = plr
                                end
                            end
                        end
                    end
                    return best
                end
                local function buildCameraData(fromPos, part)
                    if not _util or not part then return nil end
                    local look = CFrame.new(fromPos, part.Position)
                    local data = {}
                    data[utf8.char(1)] = {
                        [utf8.char(0)] = _util:EncodeCFrame(look),
                        [utf8.char(1)] = _util:EncodeCFrame(look),
                        [utf8.char(2)] = part,
                        [utf8.char(3)] = _util:EncodeCFrame(part.CFrame:ToObjectSpace(CFrame.new(part.Position)))
                    }
                    return data
                end
                local function doFire(part)
                    local fighter = getFighter()
                    local item = fighter and fighter.EquippedItem
                    if not item or not part then return false end
                    local cam = _ws.CurrentCamera
                    local fromPos = (state.csyncCF and state.csyncCF.Position) or (cam and cam.CFrame.Position) or part.Position
                    local attempts = math.max(1, math.floor(cfg.shootAttempts or 1))
                    local anyFired = false
                    for _ = 1, attempts do
                        local fired = false
                        if cfg.useManipulation and _useItemRemote and _enums and _util then
                            local ammo = item.Get and (item:Get("Ammo") or 0) or 0
                            if ammo > 0 then
                                local oid = item:Get("ObjectID")
                                local shootEnum = _enums:ToEnum("StartShooting")
                                local data = buildCameraData(fromPos, part)
                                if oid and shootEnum and data then
                                    fired = pcall(function()
                                        _useItemRemote:FireServer(oid, shootEnum, data, nil)
                                    end)
                                end
                            end
                        end
                        if not fired and item.UseItem then
                            fired = pcall(function() item:UseItem() end)
                        end
                        if not fired and fighter and fighter.UseItem then
                            fired = pcall(function() fighter:UseItem() end)
                        end
                        anyFired = anyFired or fired
                    end
                    return anyFired
                end
                local function isLobby()
                    local playerGui = _lplr:FindFirstChild("PlayerGui")
                    local mainGui = playerGui and playerGui:FindFirstChild("MainGui")
                    local mainFrame = mainGui and mainGui:FindFirstChild("MainFrame")
                    local lobby = mainFrame and mainFrame:FindFirstChild("Lobby")
                    local currency = lobby and lobby:FindFirstChild("Currency")
                    return currency and currency.Visible == true
                end
                local function isValidMatch()
                    if isLobby() or isShootingRange() then return false end
                    local char = _lplr.Character
                    local root = getRoot(char)
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not char or not root or not hum or hum.Health <= 0 then return false end
                    return getFighter() ~= nil
                end

                local function voidRand()
                    local n = math.random(-2147483646, 2147483646)
                    repeat
                        n = math.random(-2147483646, 2147483646)
                    until n < -1147483646 or n > 1147483646
                    return n
                end
                local function voidRandCF()
                    return CFrame.new(voidRand(), voidRand(), voidRand()) * CFrame.Angles(math.pi, math.pi, math.pi)
                end
                local function setVoidCsync(cf)
                    state.csyncCF = cf
                    state.csyncLV = Vector3.zero
                    state.csyncAV = Vector3.zero
                    state.lastFakePos = cf and cf.Position or nil
                end
                local function clearCsyncTarget()
                    state.csyncCF = nil
                    state.csyncLV = nil
                    state.csyncAV = nil
                    state.lastFakePos = nil
                end
                local function restoreLocalRoot(root)
                    if not root or not state.csyncLocalCF then return false end
                    root.CFrame = state.csyncLocalCF
                    if state.csyncLocalLV then
                        root.AssemblyLinearVelocity = state.csyncLocalLV
                    end
                    if state.csyncLocalAV then
                        root.AssemblyAngularVelocity = state.csyncLocalAV
                    end
                    return true
                end
                local function startCsync()
                    if state.csyncHbConn then return end
                    state.csyncHbConn = _runservice.Heartbeat:Connect(function()
                        local root = getRoot(_lplr.Character)
                        if not root then return end
                        if state.csyncWroteFake and state.csyncLocalCF then
                            restoreLocalRoot(root)
                        end
                        state.csyncLocalCF = root.CFrame
                        state.csyncLocalLV = root.AssemblyLinearVelocity
                        state.csyncLocalAV = root.AssemblyAngularVelocity
                        if state.csyncCF then
                            root.CFrame = state.csyncCF
                            root.AssemblyLinearVelocity = state.csyncLV or Vector3.zero
                            root.AssemblyAngularVelocity = state.csyncAV or Vector3.zero
                            state.csyncWroteFake = true
                        else
                            state.csyncWroteFake = false
                        end
                    end)
                    _runservice:BindToRenderStep("XilosVoidCsync", Enum.RenderPriority.Camera.Value - 1, function()
                        local root = getRoot(_lplr.Character)
                        if not root or not state.csyncLocalCF then return end
                        if state.csyncWroteFake and restoreLocalRoot(root) then
                            state.csyncWroteFake = false
                        end
                    end)
                end
                local function stopCsync()
                    if state.csyncHbConn then state.csyncHbConn:Disconnect(); state.csyncHbConn = nil end
                    _runservice:UnbindFromRenderStep("XilosVoidCsync")
                    restoreLocalRoot(getRoot(_lplr.Character))
                    clearCsyncTarget()
                    state.csyncLocalCF = nil
                    state.csyncLocalLV = nil
                    state.csyncLocalAV = nil
                    state.csyncWroteFake = false
                end
                local function enableNoclip()
                    if state.noclipConn then return end
                    state.noclipConn = _runservice.Stepped:Connect(function()
                        local char = _lplr.Character
                        if not char then return end
                        for _, part in char:GetDescendants() do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end)
                end
                local function handleAmmo()
                    local fighter = getFighter()
                    local item = fighter and fighter.EquippedItem
                    if not fighter or not item then return false end
                    local ammo = item:Get("Ammo") or 0
                    local slot = item:Get("Slot") or 1
                    local now = tick()
                    if fighter:Get("Reloading") then
                        state.ammoActionAt = math.max(state.ammoActionAt or 0, now + 0.1)
                        return true
                    end
                    if ammo > 0 then return false end
                    if now < (state.ammoActionAt or 0) then return true end
                    if slot == cfg.primarySlot and cfg.autoSwapSecondary then
                        state.ammoActionAt = now + 0.45
                        pressKey(slotKey[cfg.secondarySlot] or Enum.KeyCode.Two)
                        return true
                    end
                    if slot == cfg.secondarySlot and cfg.autoReloadPrimary then
                        state.ammoActionAt = now + 0.6
                        pressKey(slotKey[cfg.primarySlot] or Enum.KeyCode.One)
                        return true
                    end
                    return true
                end

                local function voidLoop()
                    while state.active do
                        if not state.target or playerIsDead(state.target) or isInvincible(state.target) then
                            state.target = getBestTarget()
                        end
                        if not state.target then
                            setVoidCsync(voidRandCF())
                            task.wait(0.1)
                            continue
                        end
                        local tc = state.target.Character
                        local tr = getRoot(tc)
                        local head = tc and (tc:FindFirstChild("Head") or tr)
                        if not tr or not head then
                            state.target = nil
                            task.wait(0.05)
                            continue
                        end
                        setVoidCsync(voidRandCF())
                        task.wait(cfg.voidHideTime or 0.25)
                        if not state.active then break end
                        local shootPos = isRiotShield(state.target)
                            and (tr.Position - tr.CFrame.LookVector * (cfg.behindDist or 4))
                            or (tr.Position - tr.CFrame.LookVector * 2.5 + Vector3.new(0, 1.5, 0))
                        if not isSafeRagebotPos(shootPos, state.target) then
                            setVoidCsync(voidRandCF())
                            task.wait(0.1)
                            continue
                        end
                        local shootCF = CFrame.new(shootPos, head.Position)
                        state.voidExposed = true
                        state.voidTargetCF = shootCF
                        setVoidCsync(shootCF)
                        task.wait(cfg.voidShootTime or 0.03)
                        doFire(head)
                        task.wait(0.05)
                        state.voidExposed = false
                    end
                end

                local function stopVoid()
                    state.active = false
                    cfg.on = false
                    if state.noclipConn then state.noclipConn:Disconnect(); state.noclipConn = nil end
                    state.target = nil
                    state.voidExposed = false
                    stopCsync()
                    local char = _lplr.Character
                    if char then
                        for _, part in char:GetDescendants() do
                            if part:IsA("BasePart") then part.CanCollide = true end
                        end
                    end
                end

                enableNoclip()
                startCsync()
                state.voidThread = task.spawn(voidLoop)
                state.ammoThread = task.spawn(function()
                    while state.active do
                        if not isShootingRange() and hasValidTarget() then
                            handleAmmo()
                        end
                        task.wait(math.max(0.01, cfg.acSpd))
                    end
                end)

                getgenv().__XilosVoidStop = stopVoid
                Void:Clean(stopVoid)
            else
                cfg.on = false
                if getgenv().__XilosVoidStop then
                    pcall(getgenv().__XilosVoidStop)
                    getgenv().__XilosVoidStop = nil
                end
            end
        end
    })

    Void:AddToggle({
        Name = 'void spam',
        Default = true,
        Function = function(callback) VoidSettings.voidSpam = callback end
    })
    local VoidHide = Void:AddSlider({
        Name = 'hide',
        Min = 0, Max = 1, Default = 0.25, Decimal = 100, Suffix = 's', Compact = true,
        Function = function(value) VoidSettings.voidHideTime = value end
    })
    Void:AddSlider({
        Name = 'attack',
        Min = 0, Max = 1, Default = 0.03, Decimal = 100, Suffix = 's', Compact = true, Parent = VoidHide,
        Function = function(value) VoidSettings.voidShootTime = value end
    })
    Void:AddSlider({
        Name = 'shoot attempts',
        Min = 1, Max = 10, Default = 1, Suffix = 'x',
        Function = function(value) VoidSettings.shootAttempts = math.floor(value) end
    })
    Void:AddSlider({
        Name = 'behind distance',
        Min = 1, Max = 8, Default = 4, Decimal = 10, Suffix = 'st',
        Function = function(value) VoidSettings.behindDist = value end
    })
    Void:AddToggle({
        Name = 'use manipulation',
        Default = true,
        Function = function(callback) VoidSettings.useManipulation = callback end
    })
    Void:AddToggle({
        Name = 'swap weapons when empty',
        Default = true,
        Function = function(callback)
            VoidSettings.autoSwapSecondary = callback
            VoidSettings.autoReloadPrimary = callback
        end
    })
    Void:AddSlider({
        Name = 'tick speed',
        Min = 0.01, Max = 0.2, Default = 0.05, Decimal = 100, Suffix = 's',
        Function = function(value) VoidSettings.acSpd = value end
    })
    Void:AddSlider({
        Name = 'shoot delay',
        Min = 0, Max = 0.2, Default = 0, Decimal = 100, Suffix = 's',
        Function = function(value) VoidSettings.shootDelay = value end
    })

    VoidModule = Void
end)

RageGroup:AddToggle("XilosRagebot", {
	Text = "Ragebot",
	Tooltip = "Toggles the full Ragebot (sub-settings open in the groupbox below)",
	Default = false,
	Callback = function(Value)
		if not RagebotModule then
			Library:Notify("Ragebot failed to initialize", 3)
			return
		end
		if Value then
			if RagebotModule._Run then RagebotModule:_Run() end
		else
			if RagebotModule._Stop then RagebotModule:_Stop() end
		end
	end
}):AddKeyPicker("XilosRagebotKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Ragebot", NoUI = false,
})

RageGroup:AddToggle("XilosVoid", {
	Text = "Void",
	Tooltip = "Toggles Void mode",
	Default = false,
	Callback = function(Value)
		if not VoidModule then
			Library:Notify("Void failed to initialize", 3)
			return
		end
		if Value then
			if VoidModule._Run then VoidModule:_Run() end
		else
			if VoidModule._Stop then VoidModule:_Stop() end
		end
	end
}):AddKeyPicker("XilosVoidKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Void", NoUI = false,
})

local function _getHrp()
	local lp = game:GetService("Players").LocalPlayer
	if not lp.Character then return nil end
	return lp.Character:FindFirstChild("HumanoidRootPart")
end

local _flyConn = nil
local _flyConfig = { enabled = false, speed = 50 }

local function _startFly()
	if _flyConn then _flyConn:Disconnect() end
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local localplayer = game:GetService("Players").LocalPlayer
	_flyConfig.enabled = true
	_flyConn = RunService.Heartbeat:Connect(function(dt)
		local tHrp = _getHrp()
		if not tHrp or not _flyConfig.enabled then return end
		local h = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
		if h then h:ChangeState(Enum.HumanoidStateType.Physics) end
		local c = workspace.CurrentCamera
		local md = Vector3.zero
		if h and h.MoveDirection.Magnitude > 0 then
			local fl = Vector3.new(c.CFrame.LookVector.X, 0, c.CFrame.LookVector.Z)
			md = fl.Magnitude > 0.001
				and Vector3.new(h.MoveDirection.X, c.CFrame.LookVector.Y * h.MoveDirection:Dot(fl.Unit), h.MoveDirection.Z)
				or Vector3.new(h.MoveDirection.X, c.CFrame.LookVector.Y, h.MoveDirection.Z)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then md = md + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then md = md - Vector3.new(0, 1, 0) end
		tHrp.AssemblyLinearVelocity = Vector3.zero
		tHrp.AssemblyAngularVelocity = Vector3.zero
		if md.Magnitude > 0 then
			tHrp.CFrame = tHrp.CFrame + (md.Unit * (_flyConfig.speed * dt))
		end
	end)
end

local function _stopFly()
	_flyConfig.enabled = false
	if _flyConn then _flyConn:Disconnect() _flyConn = nil end
	local hrp = _getHrp()
	if hrp then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.AssemblyAngularVelocity = Vector3.zero
	end
	local localplayer = game:GetService("Players").LocalPlayer
	local h = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")
	if h then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
end

local _ueCounterGui = nil
local _ueCounterConn = nil

local function _startUECounter()
	if _ueCounterGui then return end
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local TARGET_GAME_ID = 6035872082
	local isTargetGame = (game.GameId == TARGET_GAME_ID)
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "XilosCounterGui_UE"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "XilosCounterText"
	textLabel.Size = UDim2.new(0, 320, 0, 24)
	textLabel.Position = UDim2.new(0.5, 0, 0.14, 0)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = 18
	textLabel.Font = Enum.Font.Code
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(255, 0, 0)
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Text = "Xilos Counter [UE]"
	textLabel.Parent = screenGui

	local baseText = isTargetGame and "Xilos Counter [UE] <>" or "Xilos Counter [UE]"
	local glitchChars = {"!", "@", "#", "$", "%", "^", "&", "*", "?", "/", "\\", "|", "~", "<", ">", "_", "-", "+", "=", ":", ";", "`"}
	local function randomGlitchChar() return glitchChars[math.random(1, #glitchChars)] end
	local glitchChance = isTargetGame and 0.55 or 0.35
	local charChance   = isTargetGame and 0.25 or 0.15
	local function glitchify(text)
		if math.random() > glitchChance then return text end
		local chars = {}
		for i = 1, #text do
			local c = text:sub(i, i)
			if c ~= " " and math.random() < charChance then
				chars[i] = randomGlitchChar()
			else
				chars[i] = c
			end
		end
		return table.concat(chars)
	end
	local rainbowSpeed = isTargetGame and 2.5 or 1.5
	local hue = 0
	local function updateRainbow(deltaTime)
		hue = (hue + deltaTime * rainbowSpeed) % 1
		textLabel.TextColor3 = Color3.fromHSV(hue, 0.9, 1)
		textLabel.TextStrokeColor3 = Color3.fromHSV((hue + 0.5) % 1, 1, 1)
	end
	_ueCounterConn = RunService.RenderStepped:Connect(function(deltaTime)
		updateRainbow(deltaTime)
		textLabel.Text = glitchify(baseText)
	end)
	_ueCounterGui = screenGui
	pcall(_startFly)
end

local function _stopUECounter()
	if _ueCounterConn then _ueCounterConn:Disconnect() _ueCounterConn = nil end
	if _ueCounterGui then _ueCounterGui:Destroy() _ueCounterGui = nil end
	pcall(_stopFly)
end

UETab:AddToggle("UECounter", {
	Text = "UE COUNTER",
	Tooltip = "Toggles UE Counter (+ Fly)",
	Default = false,
	Callback = function(Value)
		if Value then pcall(_startUECounter) else pcall(_stopUECounter) end
	end
}):AddKeyPicker("UECounterKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "UE COUNTER", NoUI = false,
})

local _kiciaGui = nil

local function _startKiciaCounter()
	if _kiciaGui then return end
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "XilosCounterGui_KICIAHOOK"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "XilosCounterText"
	textLabel.Size = UDim2.new(0, 320, 0, 24)
	textLabel.Position = UDim2.new(0.5, 0, 0.18, 0)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = 18
	textLabel.Font = Enum.Font.Code
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(255, 0, 0)
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Text = "KICIA"
	textLabel.Parent = screenGui
	_kiciaGui = screenGui
end

local function _stopKiciaCounter()
	if _kiciaGui then _kiciaGui:Destroy() _kiciaGui = nil end
end

KICIAHOOKTab:AddToggle("KICIAHOOKCounter", {
	Text = "KICIAHOOK COUNTER",
	Tooltip = "Toggles KICIAHOOK Counter",
	Default = false,
	Callback = function(Value)
		if Value then pcall(_startKiciaCounter) else pcall(_stopKiciaCounter) end
	end
}):AddKeyPicker("KICIAHOOKCounterKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "KICIAHOOK COUNTER", NoUI = false,
})

local _legitBotGui = nil
local _legitBotConn = nil
local _legitBotKillConns = {}
local _legitBotHitMsg = nil
local _legitBotKillMsg = nil
local _legitBotMsgTimer = 0
local _legitBotMsgDuration = 2
local _legitBotBaseText = ""
local _legitBotDots = {".", "..", "..."}
local _legitBotDotIndex = 1
local _legitBotTimer = 0
local _legitBotInterval = 0.35
local _legitBotTrackedHumans = setmetatable({}, { __mode = "k" })

local function _legitBotTrackCharacter(character)
    if not character then return end
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid or _legitBotTrackedHumans[humanoid] then return end
    _legitBotTrackedHumans[humanoid] = true
    local lastHealth = humanoid.Health
    table.insert(_legitBotKillConns, humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth < lastHealth then
            local otherPlayer = Players:GetPlayerFromCharacter(character)
            if otherPlayer and otherPlayer ~= LocalPlayer then
                if newHealth <= 0 then
                    _legitBotKillMsg = "Killed " .. otherPlayer.Name
                    _legitBotMsgTimer = 0
                else
                    _legitBotHitMsg = "Hitting " .. otherPlayer.Name
                    _legitBotMsgTimer = 0
                end
            end
        end
        lastHealth = newHealth
    end))
end

local function _startLegitBot()
	if _legitBotGui then return end
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LegitBotVoidGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "LegitBotVoidText"
	textLabel.Size = UDim2.new(0, 320, 0, 24)
	textLabel.Position = UDim2.new(0.5, 0, 0.6, 0)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = 18
	textLabel.Font = Enum.Font.Code
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 200, 0)
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Text = ""
	textLabel.Parent = screenGui

	_legitBotGui = screenGui
	_legitBotHitMsg = nil
	_legitBotKillMsg = nil
	_legitBotMsgTimer = 0

	_legitBotConn = RunService.RenderStepped:Connect(function(deltaTime)
		if _legitBotKillMsg then
			_legitBotMsgTimer = _legitBotMsgTimer + deltaTime
			textLabel.Text = _legitBotKillMsg
			if _legitBotMsgTimer >= _legitBotMsgDuration then
				_legitBotKillMsg = nil
				_legitBotMsgTimer = 0
			end
		elseif _legitBotHitMsg then
			_legitBotMsgTimer = _legitBotMsgTimer + deltaTime
			textLabel.Text = _legitBotHitMsg
			if _legitBotMsgTimer >= _legitBotMsgDuration then
				_legitBotHitMsg = nil
				_legitBotMsgTimer = 0
			end
		else
			textLabel.Text = ""
		end
	end)

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character then
			task.spawn(_legitBotTrackCharacter, otherPlayer.Character)
		end
		table.insert(_legitBotKillConns, otherPlayer.CharacterAdded:Connect(function(char)
			if otherPlayer ~= player then _legitBotTrackCharacter(char) end
		end))
	end
	table.insert(_legitBotKillConns, Players.PlayerAdded:Connect(function(otherPlayer)
		table.insert(_legitBotKillConns, otherPlayer.CharacterAdded:Connect(function(char)
			if otherPlayer ~= player then _legitBotTrackCharacter(char) end
		end))
	end))
end

local function _stopLegitBot()
	if _legitBotConn then _legitBotConn:Disconnect() _legitBotConn = nil end
	for _, conn in ipairs(_legitBotKillConns) do pcall(function() conn:Disconnect() end) end
	_legitBotKillConns = {}
	if _legitBotGui then _legitBotGui:Destroy() _legitBotGui = nil end
	_legitBotHitMsg = nil
	_legitBotKillMsg = nil
end

LegitBotTab:AddToggle("LegitBotEnabled", {
	Text = "LEGIT BOT",
	Tooltip = "Toggles LegitBot counter",
	Default = false,
	Callback = function(Value)
		if Value then pcall(_startLegitBot) else pcall(_stopLegitBot) end
	end
}):AddKeyPicker("LegitBotKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "LEGIT BOT", NoUI = false,
})

local _aimbotRunning = false
local _aimbotLastShoot = 0

local function _aimbotGetClosest()
	local lp = game:GetService("Players").LocalPlayer
	local cam = workspace.CurrentCamera
	local closest, closestDist = nil, 5000
	local center = cam.ViewportSize / 2
	for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
		if plr == lp then continue end
		if not plr.Character then continue end
		local head = plr.Character:FindFirstChild("Head")
		local hum = plr.Character:FindFirstChildOfClass("Humanoid")
		if not head or not hum or hum.Health <= 0 then continue end
		local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
		if not onScreen then continue end
		local dist = (center - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
		if dist < closestDist then closestDist = dist; closest = plr end
	end
	return closest
end

local function _aimbotHandle()
	if not _aimbotRunning then return end
	local lp = game:GetService("Players").LocalPlayer
	local cl = _aimbotGetClosest()
	local hrp = _getHrp()
	local char = lp.Character
	if cl and cl.Character and cl.Character:FindFirstChild("Head") and hrp and char then
		local hd = cl.Character.Head
		local cam = workspace.CurrentCamera
		cam.CFrame = CFrame.lookAt(cam.CFrame.Position, hd.Position)
		local t = char:FindFirstChildOfClass("Tool")
		if t then t:Activate() end
		if tick() - _aimbotLastShoot > 0.05 then
			_aimbotLastShoot = tick()
			pcall(function()
				local UserInputService = game:GetService("UserInputService")
				if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
					local center = cam.ViewportSize / 2
					if firetouchtap then firetouchtap(center) elseif touchtap then touchtap(center) end
				else
					if mouse1click then mouse1click()
					elseif VirtualUser then VirtualUser:ClickButton1(Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)) end
				end
			end)
		end
	end
end

local function _startAimbot()
	if _aimbotRunning then return end
	_aimbotRunning = true
	local RunService = game:GetService("RunService")
	RunService:BindToRenderStep("XilosAimbot", Enum.RenderPriority.Camera.Value + 1, _aimbotHandle)
end

local function _stopAimbot()
	_aimbotRunning = false
	local RunService = game:GetService("RunService")
	pcall(function() RunService:UnbindFromRenderStep("XilosAimbot") end)
end

AimBotTab:AddToggle("AimBotEnabled", {
	Text = "AIMBOT",
	Tooltip = "Toggles AimBot",
	Default = false,
	Callback = function(Value)
		if Value then pcall(_startAimbot) else pcall(_stopAimbot) end
	end
}):AddKeyPicker("AimBotKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "AIMBOT", NoUI = false,
})

local _silentAimConfig = { HitPart = "Head", FOVRadius = 5000, ShowFOV = false }
local _silentAimCircle = nil
local _silentAimConn = nil
local _silentAimOrigRaycast = nil

local function _startSilentAim()
	if _silentAimOrigRaycast then return end
	local phem1_plrs = game:GetService("Players")
	local phem2_cs = game:GetService("CollectionService")
	local phem5 = game:GetService("ReplicatedStorage")
	local phem6 = phem1_plrs.LocalPlayer

	local ok, phem7 = pcall(function() return require(phem5.Modules.Utility) end)
	if not ok or not phem7 then return end

	local phem8 = phem7.Raycast
	_silentAimOrigRaycast = phem8

	_silentAimCircle = Drawing.new("Circle")
	_silentAimCircle.Visible = _silentAimConfig.ShowFOV
	_silentAimCircle.Radius = _silentAimConfig.FOVRadius
	_silentAimCircle.Color = Color3.fromRGB(255, 255, 255)
	_silentAimCircle.Thickness = 1
	_silentAimCircle.Filled = false

	_silentAimConn = game:GetService("RunService").RenderStepped:Connect(function()
		if not _silentAimCircle then return end
		_silentAimCircle.Position = workspace.CurrentCamera.ViewportSize / 2
		_silentAimCircle.Radius = _silentAimConfig.FOVRadius
		_silentAimCircle.Visible = _silentAimConfig.ShowFOV
	end)

	local function getClosestHead()
		local center = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
		local closest = nil
		local closestDist = _silentAimConfig.FOVRadius
		for _, entity in ipairs(phem2_cs:GetTagged("Entity")) do
			if entity == phem6.Character then continue end
			local part = entity:FindFirstChild(_silentAimConfig.HitPart, true)
			if not part or not part:IsA("BasePart") then continue end
			local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
			if not onScreen then continue end
			local dist = (center - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
			if dist < closestDist then closestDist = dist; closest = part end
		end
		return closest
	end

	phem7.Raycast = function(self, origin, direction, maxDist, ...)
		if type(maxDist) ~= "number" or maxDist < 100 then
			return phem8(self, origin, direction, maxDist, ...)
		end
		local target = getClosestHead()
		if not target then return phem8(self, origin, direction, maxDist, ...) end
		local targetPos = target.Position
		local dir = (targetPos - origin).Unit
		local dist = (targetPos - origin).Magnitude
		if dist > maxDist then dist = maxDist; targetPos = origin + (dir * maxDist) end
		return { Position = targetPos, Distance = dist, Instance = target, Material = target.Material, Normal = -dir }
	end
end

local function _stopSilentAim()
	local phem5 = game:GetService("ReplicatedStorage")
	local ok, phem7 = pcall(function() return require(phem5.Modules.Utility) end)
	if ok and phem7 and _silentAimOrigRaycast then
		phem7.Raycast = _silentAimOrigRaycast
	end
	_silentAimOrigRaycast = nil
	if _silentAimConn then _silentAimConn:Disconnect() _silentAimConn = nil end
	if _silentAimCircle then _silentAimCircle:Remove() _silentAimCircle = nil end
end

SilentAimTab:AddToggle("SilentAimEnabled", {
	Text = "SILENT AIM",
	Tooltip = "Toggles Silent Aim",
	Default = false,
	Callback = function(Value)
		if Value then pcall(_startSilentAim) else pcall(_stopSilentAim) end
	end
}):AddKeyPicker("SilentAimKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "SILENT AIM", NoUI = false,
})

local espLeft = Tabs.esp:AddLeftGroupbox("esp")
local espRight = Tabs.esp:AddRightGroupbox("Options")

local _boxEsp = { running = false, conn = nil, boxes = {}, addedConn = nil, removingConn = nil }

local function _boxCreate(player)
	if player == game:GetService("Players").LocalPlayer then return end
	if _boxEsp.boxes[player] then return end
	local box = {}
	for i = 1, 4 do
		local line = Drawing.new("Line")
		line.Color = Color3.fromRGB(255, 255, 255)
		line.Thickness = 1
		line.Transparency = 0.5
		line.Visible = false
		table.insert(box, line)
	end
	_boxEsp.boxes[player] = box
end

local function _boxRemove(player)
	if _boxEsp.boxes[player] then
		for _, line in ipairs(_boxEsp.boxes[player]) do
			pcall(function() line:Remove() end)
		end
		_boxEsp.boxes[player] = nil
	end
end

local function _startBoxEsp()
	if _boxEsp.running then return end
	_boxEsp.running = true
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer
	local TEAM_CHECK = false
	local function getBoundingBox(character)
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local head = character:FindFirstChild("Head")
		local humanoid = character:FindFirstChild("Humanoid")
		if not rootPart or not head or not humanoid then return nil end
		if humanoid.Health <= 0 then return nil end
		return head.Position + Vector3.new(0, head.Size.Y / 2, 0), rootPart.Position - Vector3.new(0, 3, 0)
	end
	local function shouldShowPlayer(player)
		if player == LocalPlayer then return false end
		if not player.Character then return false end
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return false end
		if TEAM_CHECK and player.Team == LocalPlayer.Team then return false end
		return true
	end	_boxEsp.conn = RunService.RenderStepped:Connect(function()
		local Camera = workspace.CurrentCamera
		if not Camera then return end
		for player, box in pairs(_boxEsp.boxes) do
			if not shouldShowPlayer(player) then
				for _, line in ipairs(box) do line.Visible = false end
				continue
			end
			local top, bottom = getBoundingBox(player.Character)
			if not top or not bottom then
				for _, line in ipairs(box) do line.Visible = false end
				continue
			end
			local topScreen, topOnScreen = Camera:WorldToViewportPoint(top)
			local bottomScreen, bottomOnScreen = Camera:WorldToViewportPoint(bottom)
			if not topOnScreen or not bottomOnScreen then
				for _, line in ipairs(box) do line.Visible = false end
				continue
			end
			local height = math.abs(topScreen.Y - bottomScreen.Y)
			local width = height * 0.6
			local centerX = (topScreen.X + bottomScreen.X) / 2
			local centerY = (topScreen.Y + bottomScreen.Y) / 2
			local left = centerX - width / 2
			local right = centerX + width / 2
			local topY = centerY - height / 2
			local bottomY = centerY + height / 2
			box[1].From = Vector2.new(left, topY);     box[1].To = Vector2.new(right, topY);     box[1].Visible = true
			box[2].From = Vector2.new(left, bottomY);  box[2].To = Vector2.new(right, bottomY);  box[2].Visible = true
			box[3].From = Vector2.new(left, topY);     box[3].To = Vector2.new(left, bottomY);   box[3].Visible = true
			box[4].From = Vector2.new(right, topY);    box[4].To = Vector2.new(right, bottomY);  box[4].Visible = true
		end
	end)
	_boxEsp.addedConn = Players.PlayerAdded:Connect(_boxCreate)
	_boxEsp.removingConn = Players.PlayerRemoving:Connect(_boxRemove)
	for _, player in ipairs(Players:GetPlayers()) do _boxCreate(player) end
end

local function _stopBoxEsp()
	_boxEsp.running = false
	if _boxEsp.conn then _boxEsp.conn:Disconnect(); _boxEsp.conn = nil end
	if _boxEsp.addedConn then _boxEsp.addedConn:Disconnect(); _boxEsp.addedConn = nil end
	if _boxEsp.removingConn then _boxEsp.removingConn:Disconnect(); _boxEsp.removingConn = nil end
	for player, _ in pairs(_boxEsp.boxes) do _boxRemove(player) end
	_boxEsp.boxes = {}
end

espLeft:AddToggle("espBox", {
	Text = "Box",
	Tooltip = "Draws a box around players",
	Default = false,
	Callback = function(Value)
		if Value then pcall(_startBoxEsp) else pcall(_stopBoxEsp) end
	end
}):AddKeyPicker("espBoxKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Box", NoUI = false,
})

local FOVLeft = Tabs.FOV:AddLeftGroupbox("FOV")
local FOVRight = Tabs.FOV:AddRightGroupbox("Options")

FOVLeft:AddToggle("FOVEnabled", {
	Text = "FOV",
	Tooltip = "Toggles FOV",
	Default = false,
	Callback = function(Value) print("[cb] FOV:", Value) end
}):AddKeyPicker("FOVKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "FOV", NoUI = false,
})

local CharacterLeft = Tabs.Character:AddLeftGroupbox("Character")
local CharacterRight = Tabs.Character:AddRightGroupbox("Options")

CharacterLeft:AddToggle("Fly", {
	Text = "Fly",
	Tooltip = "Toggles Fly",
	Default = false,
	Callback = function(Value)
		if Value then pcall(_startFly) else pcall(_stopFly) end
	end
}):AddKeyPicker("FlyKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Fly", NoUI = false,
})

local _noclipConn = nil

local function _startNoclip()
	if _noclipConn then return end
	local RunService = game:GetService("RunService")
	local localplayer = game:GetService("Players").LocalPlayer
	_noclipConn = RunService.Stepped:Connect(function()
		if localplayer.Character then
			for _, p in ipairs(localplayer.Character:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end
	end)
end

local function _stopNoclip()
	if _noclipConn then _noclipConn:Disconnect() _noclipConn = nil end
	local localplayer = game:GetService("Players").LocalPlayer
	if localplayer.Character then
		for _, p in ipairs(localplayer.Character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = true end
		end
	end
end

CharacterLeft:AddToggle("Noclip", {
	Text = "Noclip",
	Tooltip = "Toggles Noclip",
	Default = false,
	Callback = function(Value)
		if Value then pcall(_startNoclip) else pcall(_stopNoclip) end
	end
}):AddKeyPicker("NoclipKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Noclip", NoUI = false,
})

local _rapidFireConn = nil
local _rapidFireEnabled = false
local _fastMeleeEnabled = false
local _fastMeleeThread = nil
local _origItemValues = {}

local function _startRapidFire()
    if _rapidFireConn then _rapidFireConn:Disconnect() end
    _rapidFireConn = runservice.Heartbeat:Connect(function()
        if _rapidFireEnabled then
            local t = localplayer.Character and localplayer.Character:FindFirstChildOfClass("Tool")
            if t then t:Activate() end
        end
    end)
end

local function _stopRapidFire()
    _rapidFireEnabled = false
    if _rapidFireConn then _rapidFireConn:Disconnect() _rapidFireConn = nil end
end

local function _startFastMelee()
    if _fastMeleeThread then task.cancel(_fastMeleeThread) end
    _fastMeleeThread = task.spawn(function()
        while _fastMeleeEnabled do
            pcall(function()
                local ok, ItemLibrary = pcall(function()
                    return require(game:GetService("ReplicatedStorage").Modules.ItemLibrary)
                end)
                if ok and ItemLibrary then
                    local Items = rawget(ItemLibrary, "Items")
                    if Items then
                        for _, Item in pairs(Items) do
                            pcall(function()
                                if not _origItemValues[Item] then
                                    _origItemValues[Item] = {
                                        ReloadLength   = Item.ReloadLength,
                                        FireRate       = Item.FireRate,
                                        Cooldown       = Item.Cooldown,
                                        AttackCooldown = Item.AttackCooldown,
                                        SwingCooldown  = Item.SwingCooldown,
                                        ThrowCooldown  = Item.ThrowCooldown,
                                        RecoverTime    = Item.RecoverTime,
                                        WindupTime     = Item.WindupTime,
                                    }
                                end
                                local speed = Item.Name == "Daggers" and 0.09 or 0
                                rawset(Item, "ReloadLength",   speed)
                                rawset(Item, "FireRate",       0)
                                rawset(Item, "Cooldown",       0)
                                rawset(Item, "AttackCooldown", 0)
                                rawset(Item, "SwingCooldown",  0)
                                rawset(Item, "ThrowCooldown",  0)
                                rawset(Item, "RecoverTime",    0)
                                rawset(Item, "WindupTime",     0)
                            end)
                        end
                    end
                end
            end)
            task.wait(0.1)
        end
    end)
end

local function _stopFastMelee()
    _fastMeleeEnabled = false
    if _fastMeleeThread then task.cancel(_fastMeleeThread) _fastMeleeThread = nil end
    pcall(function()
        local ItemLibrary = require(game:GetService("ReplicatedStorage").Modules.ItemLibrary)
        local Items = rawget(ItemLibrary, "Items")
        if Items then
            for Item, orig in pairs(_origItemValues) do
                for k, v in pairs(orig) do
                    pcall(rawset, Item, k, v)
                end
            end
        end
    end)
    _origItemValues = {}
end

CharacterLeft:AddToggle("RapidFire", {
	Text = "Rapid Fire",
	Tooltip = "Enable rapid fire (also works on melee!)",
	Default = false,
	Callback = function(Value)
		_rapidFireEnabled = Value
		if Value then _startRapidFire() else _stopRapidFire() end
	end
}):AddKeyPicker("RapidFireKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Rapid Fire", NoUI = false,
})

CharacterLeft:AddToggle("FastMelee", {
	Text = "Fast Melee / Fast Reload",
	Tooltip = "Enable fast melee attacks & instant reload",
	Default = false,
	Callback = function(Value)
		_fastMeleeEnabled = Value
		if Value then _startFastMelee() else _stopFastMelee() end
	end
}):AddKeyPicker("FastMeleeKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Fast Melee / Fast Reload", NoUI = false,
})

-- =====================================================================
-- CHARACTER TAB — No Animation
-- =====================================================================

local VisualStateAnim = {
    ViewmodelHooked = false,
    AimingHooked = false,
    OriginalViewmodelUpdate = nil,
    OriginalViewmodelMuzzleFlash = nil,
    OriginalViewmodelSetAiming = nil,
    OriginalViewmodelPlayAnimation = nil,
    OriginalAnimatorPlayAnimation = nil,
    OriginalGunStartAiming = nil,
    OriginalGunGetAimSpeed = nil,
}

local viewmodelDisableList = {
    "sway", "tilt", "bobbing", "muzzle flash", "idle animation", "jump animation",
    "slide animation", "equip animation", "shoot animation", "aiming animation", "sprint animation",
    "reload animation",
}

local VMDisabled = { Value = {} }

local function _vmHas(tbl, key)
    if type(tbl) ~= "table" then return false end
    return tbl[key] == true
end

local function _disableSelected(name)
    return _vmHas(VMDisabled.Value, name)
end

local function _shouldBlockAnimationKey(key)
    local lower = tostring(key or ""):lower()
    if lower == "" then return false end
    if _disableSelected("idle animation") and lower:find("idle", 1, true) then return true end
    if _disableSelected("jump animation") and lower:find("jump", 1, true) then return true end
    if _disableSelected("slide animation") and lower:find("slide", 1, true) then return true end
    if _disableSelected("equip animation") and lower:find("equip", 1, true) then return true end
    if _disableSelected("reload animation") and lower:find("reload", 1, true) then return true end
    if _disableSelected("shoot animation") and (lower:find("shoot", 1, true) or lower:find("fire", 1, true) or lower:find("attack", 1, true)) then return true end
    if _disableSelected("sprint animation") and (lower:find("sprint", 1, true) or lower:find("run", 1, true)) then return true end
    return false
end

local function _zeroSpring(spring, value)
    if not spring then return end
    pcall(function()
        spring.Value = value
        spring.Target = value
    end)
end

local function _forceViewmodelAimValue(vm, enabled)
    if not vm then return end
    local value = enabled and 1 or 0
    vm.IsAiming = enabled == true
    vm.Aiming = enabled == true
    vm._is_aiming = enabled == true
    if vm.CurrentAimValue ~= nil then
        vm.CurrentAimValue = value
    end
end

local function _applyViewmodelDisableToObject(vm)
    if not vm then return end
    if _disableSelected("sway") then _zeroSpring(vm._sway_spring, Vector2.zero) end
    if _disableSelected("tilt") then
        _zeroSpring(vm._tilt_spring, Vector2.zero)
        _zeroSpring(vm._raycast_tilt_spring, 0)
    end
    if _disableSelected("bobbing") then
        _zeroSpring(vm._bobbing_speed_spring, 0)
        _zeroSpring(vm._bobbing_value_spring, Vector2.zero)
        vm._bobbing_tick = 0
    end
    if _disableSelected("jump animation") then
        _zeroSpring(vm._jump_spring, 0)
        vm.CurrentJumpValue = 0
    end
    if _disableSelected("sprint animation") then
        _zeroSpring(vm._sprinting_spring, 0)
    end
    if _disableSelected("aiming animation") then
        local item = vm.ClientItem
        local isAiming = vm.IsAiming == true or vm.Aiming == true or vm._is_aiming == true
        pcall(function()
            if item and item.Get then
                isAiming = isAiming or item:Get("IsAiming") == true
            end
        end)
        if isAiming and vm.CurrentAimValue ~= nil then
            _forceViewmodelAimValue(vm, true)
        end
    end
end

local function _installAimingHooks()
    if VisualStateAnim.AimingHooked then return end
    local success, gunModule = pcall(function()
        return require(LocalPlayer.PlayerScripts.Modules.ItemTypes.Gun)
    end)
    if not success or not gunModule then return end

    if gunModule.StartAiming then
        VisualStateAnim.OriginalGunStartAiming = VisualStateAnim.OriginalGunStartAiming or gunModule.StartAiming
        gunModule.StartAiming = function(self, ...)
            if not _disableSelected("aiming animation") then
                return VisualStateAnim.OriginalGunStartAiming(self, ...)
            end
            self:SetReplicate("IsAiming", true)
            if self.StopSprinting then self.StopSprinting:Fire() end
            if self.ViewModel and self.ViewModel.SetAiming then self.ViewModel:SetAiming(true) end
            self:SetReplicate("FOVOffset", self.Info and self.Info.AimFOVOffset or 0)
            if self.ViewModel and self.ViewModel.CurrentAimValue ~= nil then
                self.ViewModel.CurrentAimValue = 1
            end
            return true, "StartAiming"
        end
    end

    if gunModule.GetAimSpeed then
        VisualStateAnim.OriginalGunGetAimSpeed = VisualStateAnim.OriginalGunGetAimSpeed or gunModule.GetAimSpeed
        gunModule.GetAimSpeed = function(self)
            if _disableSelected("aiming animation") then return 999 end
            return VisualStateAnim.OriginalGunGetAimSpeed(self)
        end
    end

    VisualStateAnim.AimingHooked = true
end

local function _installViewmodelHooks()
    if VisualStateAnim.ViewmodelHooked then return end
    local ok, viewmodelModule = pcall(function()
        return require(LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel)
    end)
    if ok and type(viewmodelModule) == "table" then
        if type(viewmodelModule.Update) == "function" then
            VisualStateAnim.OriginalViewmodelUpdate = VisualStateAnim.OriginalViewmodelUpdate or viewmodelModule.Update
            viewmodelModule.Update = function(self, ...)
                _applyViewmodelDisableToObject(self)
                local result = {VisualStateAnim.OriginalViewmodelUpdate(self, ...)}
                _applyViewmodelDisableToObject(self)
                return unpack(result)
            end
        end
        if type(viewmodelModule.MuzzleFlash) == "function" then
            VisualStateAnim.OriginalViewmodelMuzzleFlash = VisualStateAnim.OriginalViewmodelMuzzleFlash or viewmodelModule.MuzzleFlash
            viewmodelModule.MuzzleFlash = function(self, ...)
                if _disableSelected("muzzle flash") then return end
                return VisualStateAnim.OriginalViewmodelMuzzleFlash(self, ...)
            end
        end
        if type(viewmodelModule.SetAiming) == "function" then
            VisualStateAnim.OriginalViewmodelSetAiming = VisualStateAnim.OriginalViewmodelSetAiming or viewmodelModule.SetAiming
            viewmodelModule.SetAiming = function(self, enabled, ...)
                local result = {VisualStateAnim.OriginalViewmodelSetAiming(self, enabled, ...)}
                if _disableSelected("aiming animation") then
                    _forceViewmodelAimValue(self, enabled == true)
                end
                return unpack(result)
            end
        end
        if type(viewmodelModule.PlayAnimation) == "function" then
            VisualStateAnim.OriginalViewmodelPlayAnimation = VisualStateAnim.OriginalViewmodelPlayAnimation or viewmodelModule.PlayAnimation
            viewmodelModule.PlayAnimation = function(self, key, ...)
                if _shouldBlockAnimationKey(key) then return nil end
                return VisualStateAnim.OriginalViewmodelPlayAnimation(self, key, ...)
            end
        end
    end

    pcall(function()
        local animatorModule = require(LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel.ViewModelAnimator)
        if type(animatorModule) == "table" and type(animatorModule.PlayAnimation) == "function" then
            VisualStateAnim.OriginalAnimatorPlayAnimation = VisualStateAnim.OriginalAnimatorPlayAnimation or animatorModule.PlayAnimation
            animatorModule.PlayAnimation = function(self, key, ...)
                if _shouldBlockAnimationKey(key) then return nil end
                return VisualStateAnim.OriginalAnimatorPlayAnimation(self, key, ...)
            end
        end
    end)

    VisualStateAnim.ViewmodelHooked = true
end

local NoAnimGroup = Tabs.Character:AddRightGroupbox("No Animation")

NoAnimGroup:AddToggle("NoAnimationToggle", {
    Text = "No Animation",
    Tooltip = "Disables selected viewmodel animations / effects",
    Default = false,
    Callback = function(Value)
        if Value then
            _installViewmodelHooks()
            if _disableSelected("aiming animation") then _installAimingHooks() end
        end
    end
}):AddKeyPicker("NoAnimationKeybind", {
    Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "No Animation", NoUI = false,
})

NoAnimGroup:AddDropdown("NoAnimationList", {
    Values = viewmodelDisableList,
    Default = {},
    Multi = true,
    Text = "disable",
    Searchable = false,
    Callback = function(value)
        if type(value) == "table" then
            VMDisabled.Value = value
        end
        _installViewmodelHooks()
        if _disableSelected("aiming animation") then _installAimingHooks() end
    end
})

-- =====================================================================
-- WIREFRAME (Misc)
-- =====================================================================

local MAX_WIREFRAME_POOL = 96

local function _getWireframeParent()
    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or Camera or workspace
end

local function _acquireWireframe(name, buildKey, adornee)
    VisualStateAnim.WireframePool = VisualStateAnim.WireframePool or {}
    VisualStateAnim.WireframePoolCount = VisualStateAnim.WireframePoolCount or {}

    local poolKey = name .. "|" .. tostring(buildKey or "")
    local bucket = VisualStateAnim.WireframePool[poolKey]
    local wire
    if bucket and #bucket > 0 then
        wire = table.remove(bucket)
        VisualStateAnim.WireframePoolCount[poolKey] = math.max((VisualStateAnim.WireframePoolCount[poolKey] or 1) - 1, 0)
    else
        local ok, created = pcall(function()
            return Instance.new("WireframeHandleAdornment")
        end)
        if not ok or not created then return nil end
        wire = created
    end

    wire.Name = name
    pcall(function() wire.Adornee = adornee end)
    pcall(function() wire.AlwaysOnTop = true end)
    pcall(function() wire.ZIndex = 10 end)
    pcall(function() wire.Thickness = 1 end)
    pcall(function() wire.Transparency = 0 end)
    pcall(function() wire.Visible = true end)
    pcall(function() wire.Parent = _getWireframeParent() end)
    return wire
end

local function _releaseWireframe(wire)
    if not wire then return end
    local buildKey
    pcall(function()
        buildKey = wire:GetAttribute("LionWireBuildKey")
    end)
    if not buildKey then
        pcall(function() wire:Destroy() end)
        return
    end

    VisualStateAnim.WireframePool = VisualStateAnim.WireframePool or {}
    VisualStateAnim.WireframePoolCount = VisualStateAnim.WireframePoolCount or {}
    local poolKey = wire.Name .. "|" .. tostring(buildKey)
    local count = VisualStateAnim.WireframePoolCount[poolKey] or 0
    if count >= MAX_WIREFRAME_POOL then
        pcall(function() wire:Destroy() end)
        return
    end

    pcall(function() wire.Visible = false end)
    pcall(function() wire.Adornee = nil end)
    pcall(function() wire.Parent = nil end)
    VisualStateAnim.WireframePool[poolKey] = VisualStateAnim.WireframePool[poolKey] or {}
    table.insert(VisualStateAnim.WireframePool[poolKey], wire)
    VisualStateAnim.WireframePoolCount[poolKey] = count + 1
end

local function _updateWireframe(part, enabled, color)
    VisualStateAnim.PrimitiveWireframes = VisualStateAnim.PrimitiveWireframes or setmetatable({}, {__mode = "k"})
    local buildKey = "box|" .. tostring(part.Size)
    local wire = VisualStateAnim.PrimitiveWireframes[part]
    if not enabled and not wire then return end
    local oldWire = part:FindFirstChild("__LionVMWireframe")
    local oldBox = part:FindFirstChild("__LionVMWireframeBox")
    if (oldWire or oldBox) and not wire then
        if oldWire then oldWire:Destroy() end
        if oldBox then oldBox:Destroy() end
    end
    if enabled then
        if wire and not wire:IsA("WireframeHandleAdornment") then
            _releaseWireframe(wire)
            wire = nil
        end
        if not wire then
            wire = _acquireWireframe("__LionVMWireframe", buildKey, part)
            if wire then
                VisualStateAnim.PrimitiveWireframes[part] = wire
            else
                return
            end
        end
        if wire then
            local c = color or Color3.fromRGB(255, 255, 255)
            if wire.Color3 ~= c then
                pcall(function() wire.Color3 = c end)
            end
            if wire:GetAttribute("LionWireBuildKey") ~= buildKey then
                pcall(function() wire:Clear() end)
                local half = part.Size * 0.5
                local corners = {
                    Vector3.new(-half.X, -half.Y, -half.Z), Vector3.new( half.X, -half.Y, -half.Z),
                    Vector3.new(-half.X,  half.Y, -half.Z), Vector3.new( half.X,  half.Y, -half.Z),
                    Vector3.new(-half.X, -half.Y,  half.Z), Vector3.new( half.X, -half.Y,  half.Z),
                    Vector3.new(-half.X,  half.Y,  half.Z), Vector3.new( half.X,  half.Y,  half.Z),
                }
                local edges = {{1,2},{2,4},{4,3},{3,1},{5,6},{6,8},{8,7},{7,5},{1,5},{2,6},{3,7},{4,8}}
                for _, edge in ipairs(edges) do
                    pcall(function()
                        wire:AddLine(corners[edge[1]], corners[edge[2]])
                    end)
                end
                pcall(function()
                    wire:SetAttribute("LionWireBuildKey", buildKey)
                end)
            end
        end
    else
        _releaseWireframe(wire)
        VisualStateAnim.PrimitiveWireframes[part] = nil
    end
end

local _wireframeSelectedParts = setmetatable({}, { __mode = "k" })
local _wireframeColor = Color3.fromRGB(255, 255, 255)
local _wireframeEnabled = false

local function _refreshWireframe()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if _wireframeEnabled then
                _wireframeSelectedParts[part] = true
                _updateWireframe(part, true, _wireframeColor)
            else
                _updateWireframe(part, false)
                _wireframeSelectedParts[part] = nil
            end
        end
    end
end

local WireframeGroup = Tabs.Misc:AddLeftGroupbox("Wireframe")

WireframeGroup:AddToggle("WireframeToggle", {
    Text = "Wireframe",
    Tooltip = "Draws a wireframe around every part on your character",
    Default = false,
    Callback = function(Value)
        _wireframeEnabled = Value == true
        _refreshWireframe()
    end
}):AddKeyPicker("WireframeKeybind", {
    Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Wireframe", NoUI = false,
})

WireframeGroup:AddColorPicker("WireframeColor", {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "wireframe color",
    Transparency = 0,
    Callback = function(color)
        _wireframeColor = color
        if _wireframeEnabled then
            _refreshWireframe()
        end
    end
})

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    if _wireframeEnabled then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                _wireframeSelectedParts[part] = true
                _updateWireframe(part, true, _wireframeColor)
            end
        end
    end
end)

LocalPlayer.CharacterRemoving:Connect(function(character)
    for part, _ in pairs(_wireframeSelectedParts) do
        if part:IsDescendantOf(character) then
            _updateWireframe(part, false)
            _wireframeSelectedParts[part] = nil
        end
    end
end)

task.spawn(function()
    while true do
        if _wireframeEnabled then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and not _wireframeSelectedParts[part] then
                        _wireframeSelectedParts[part] = true
                        _updateWireframe(part, true, _wireframeColor)
                    end
                end
            end
        end
        task.wait(0.25)
    end
end)

local MiscLeft = Tabs.Misc:AddLeftGroupbox("Misc")
local MiscRight = Tabs.Misc:AddRightGroupbox("Options")

local ArcadeGroup = Tabs.Misc:AddLeftGroupbox("Arcade")

local _arcadeEnabled = false
local _arcadeCollectEnabled = true
local _arcadeRespawnEnabled = true

local _arcadeTrackedDrops = {}
local _arcadeNextCollect = 0
local _arcadeCollectInterval = 0.2
local _arcadeDeathConn = nil
local _arcadeAddedConn = nil
local _arcadeRemovedConn = nil
local _arcadeHeartbeatConn = nil
local _arcadeCharacterConn = nil

local function _arcadeTrackDrop(obj)
    if obj.Name == "_drop" and obj:IsA("BasePart") then
        _arcadeTrackedDrops[obj] = true
    end
end

local function _arcadeUntrackDrop(obj)
    _arcadeTrackedDrops[obj] = nil
end

local function _arcadeDisconnectDeath()
    if _arcadeDeathConn then
        _arcadeDeathConn:Disconnect()
        _arcadeDeathConn = nil
    end
end

local function _arcadeGetRespawnRemote()
    local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    local duels = remotes and remotes:FindFirstChild("Duels")
    return duels and duels:FindFirstChild("RespawnNow")
end

local function _arcadeSetupRespawn(character)
    _arcadeDisconnectDeath()
    if not (_arcadeEnabled and _arcadeRespawnEnabled) then return end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    _arcadeDeathConn = humanoid.Died:Connect(function()
        task.wait()
        if _arcadeEnabled and _arcadeRespawnEnabled then
            pcall(function()
                local respawnRemote = _arcadeGetRespawnRemote()
                if respawnRemote then
                    respawnRemote:FireServer()
                end
            end)
        end
    end)
end

local function _arcadeStart()
    if _arcadeEnabled then return end
    _arcadeEnabled = true

    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    for _, obj in ipairs(Workspace:GetChildren()) do
        _arcadeTrackDrop(obj)
    end

    _arcadeAddedConn = Workspace.ChildAdded:Connect(_arcadeTrackDrop)
    _arcadeRemovedConn = Workspace.ChildRemoved:Connect(_arcadeUntrackDrop)

    _arcadeCharacterConn = LocalPlayer.CharacterAdded:Connect(function(character)
        task.defer(_arcadeSetupRespawn, character)
    end)

    _arcadeSetupRespawn(LocalPlayer.Character)

    _arcadeHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not _arcadeEnabled then return end
        local now = os.clock()
        if now < _arcadeNextCollect then return end
        _arcadeNextCollect = now + _arcadeCollectInterval
        if not _arcadeCollectEnabled then return end

        local character = LocalPlayer.Character
        if not character then return end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local humanoid = character:FindFirstChild("Humanoid")
        local needsHealth = humanoid and humanoid.Health < humanoid.MaxHealth

        for obj in next, _arcadeTrackedDrops do
            if not obj.Parent then
                _arcadeTrackedDrops[obj] = nil
            elseif (obj:FindFirstChild("Health") and needsHealth)
                or obj:FindFirstChild("Ammo") then
                if firetouchinterest then
                    pcall(firetouchinterest, hrp, obj, 0)
                    pcall(firetouchinterest, hrp, obj, 1)
                end
            end
        end
    end)
end

local function _arcadeStop()
    if not _arcadeEnabled then return end
    _arcadeEnabled = false

    if _arcadeAddedConn then _arcadeAddedConn:Disconnect(); _arcadeAddedConn = nil end
    if _arcadeRemovedConn then _arcadeRemovedConn:Disconnect(); _arcadeRemovedConn = nil end
    if _arcadeHeartbeatConn then _arcadeHeartbeatConn:Disconnect(); _arcadeHeartbeatConn = nil end
    if _arcadeCharacterConn then _arcadeCharacterConn:Disconnect(); _arcadeCharacterConn = nil end

    _arcadeDisconnectDeath()
    _arcadeTrackedDrops = {}
end

ArcadeGroup:AddToggle("ArcadeEnabled", {
    Text = "Arcade",
    Tooltip = "Toggles Arcade (collect Drops + Auto Respawn)",
    Default = false,
    Callback = function(Value)
        if Value then
            pcall(_arcadeStart)
        else
            pcall(_arcadeStop)
        end
    end
}):AddKeyPicker("ArcadeKeybind", {
    Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Arcade", NoUI = false,
})

ArcadeGroup:AddToggle("ArcadeCollectDrops", {
    Text = "collect Drops",
    Tooltip = "Auto-collects nearby drops",
    Default = true,
    Callback = function(Value)
        _arcadeCollectEnabled = Value
    end
})

ArcadeGroup:AddToggle("ArcadeAutoRespawn", {
    Text = "Auto Respawn",
    Tooltip = "Auto-respawns on death via RespawnNow remote",
    Default = true,
    Callback = function(Value)
        _arcadeRespawnEnabled = Value
        if _arcadeEnabled then
            if Value then
                _arcadeSetupRespawn(game:GetService("Players").LocalPlayer.Character)
            else
                _arcadeDisconnectDeath()
            end
        end
    end
})

-- ============================================================
-- ITEM STATUS MODULE (spoof tab)
-- ============================================================

local VisualStateItem = {
    ItemStatusValue = nil,
    ItemStatusAppliedAt = nil,
    OriginalStatuses = {},
    RemoveVignetteInstalled = false,
    OriginalVignette = nil,
}

local statusList = {"Prime", "Contraband"}

local function applyItemStatus()
    if not (OverrideWeaponStatus and OverrideWeaponStatus.Value) then return end
    local selected = (WeaponStatus and WeaponStatus.Value) or "Prime"
    local now = tick()

    if VisualStateItem.ItemStatusValue == selected
        and VisualStateItem.ItemStatusAppliedAt
        and now - VisualStateItem.ItemStatusAppliedAt < 1 then
        return
    end

    VisualStateItem.ItemStatusValue = selected
    VisualStateItem.ItemStatusAppliedAt = now

    pcall(function()
        local itemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
        for name, info in pairs(itemLibrary.Items or {}) do
            if type(info) == "table" then
                VisualStateItem.OriginalStatuses[name] = VisualStateItem.OriginalStatuses[name] or info.Status
                info.Status = selected
            end
        end
    end)
end

local function installRemoveVignette()
    if VisualStateItem.RemoveVignetteInstalled then return end
    pcall(function()
        local itemInterface = require(LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ItemInterface)
        if type(itemInterface) == "table" and type(itemInterface.Vignette) == "function" then
            VisualStateItem.OriginalVignette = VisualStateItem.OriginalVignette or itemInterface.Vignette
            itemInterface.Vignette = function(self, ...)
                if RemoveVignette and RemoveVignette.Value then
                    return
                end
                return VisualStateItem.OriginalVignette(self, ...)
            end
        end
    end)

    pcall(function()
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not playerGui then return end
        for _, gui in ipairs(playerGui:GetDescendants()) do
            if gui.Name:lower():find("vignette", 1, true) then
                if gui:IsA("ScreenGui") then
                    gui.Enabled = false
                elseif gui:IsA("GuiObject") then
                    gui.Visible = false
                end
            end
        end
    end)

    VisualStateItem.RemoveVignetteInstalled = true
end

local function restoreItemStatus()
    if not VisualStateItem.OriginalStatuses then return end
    pcall(function()
        local itemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
        for name, info in pairs(itemLibrary.Items or {}) do
            if type(info) == "table" and VisualStateItem.OriginalStatuses[name] ~= nil then
                info.Status = VisualStateItem.OriginalStatuses[name]
            end
        end
    end)
    VisualStateItem.OriginalStatuses = {}
    VisualStateItem.ItemStatusValue = nil
    VisualStateItem.ItemStatusAppliedAt = nil
end

local ItemGroup = Tabs.spoof:AddLeftGroupbox("Item")

RemoveVignette = ItemGroup:AddToggle("RemoveVignette", {
    Text = "remove vignette",
    Default = false,
    Callback = function(callback)
        if callback then
            installRemoveVignette()
        elseif VisualStateItem.OriginalVignette then
            pcall(function()
                local itemInterface = require(LocalPlayer.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ItemInterface)
                itemInterface.Vignette = VisualStateItem.OriginalVignette
            end)
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
                if not playerGui then return end
                for _, gui in ipairs(playerGui:GetDescendants()) do
                    if gui.Name:lower():find("vignette", 1, true) then
                        if gui:IsA("ScreenGui") then
                            gui.Enabled = true
                        elseif gui:IsA("GuiObject") then
                            gui.Visible = true
                        end
                    end
                end
            end)
        end
    end
}):AddKeyPicker("RemoveVignetteKeybind", {
    Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "remove vignette", NoUI = false,
})

OverrideWeaponStatus = ItemGroup:AddToggle("OverrideWeaponStatus", {
    Text = "override weapon status",
    Default = false,
    Callback = function(callback)
        if callback then
            applyItemStatus()
        else
            restoreItemStatus()
        end
    end
}):AddKeyPicker("OverrideWeaponStatusKeybind", {
    Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "override weapon status", NoUI = false,
})

WeaponStatus = ItemGroup:AddDropdown("WeaponStatus", {
    Values = statusList,
    Default = "Prime",
    Multi = false,
    Text = "status",
    Callback = function(val)
        if OverrideWeaponStatus and OverrideWeaponStatus.Value then
            VisualStateItem.ItemStatusValue = nil
            VisualStateItem.ItemStatusAppliedAt = 0
            applyItemStatus()
        end
    end
})

task.spawn(function()
    while true do
        if OverrideWeaponStatus and OverrideWeaponStatus.Value then
            pcall(applyItemStatus)
        end
        task.wait(0.75)
    end
end)

local SpooferGroup = Tabs.spoof:AddLeftGroupbox("Spoofer")

local _spoofBinders = setmetatable({}, { __mode = 'k' })
local _spoofConnections = {}

local _spoofState = {
	Winstreak = { enabled = false, value = "999" },
	Level     = { enabled = false, value = "999" },
	Rank      = { enabled = false, value = "3600" },
	Charm     = { enabled = false, value = "Prime" },
	Admin     = { enabled = false },
}

local _spoofFields = {
	{ key = "Winstreak", attribute = "StatisticDuelsWinStreak", kind = "number" },
	{ key = "Level",     attribute = "Level",                 kind = "number" },
	{ key = "Rank",      attribute = "DisplayELO",            kind = "number" },
	{ key = "Charm",     attribute = "PlayerStatus",          kind = "text"   },
}

local function _spoofCreateBinder(instance, attribute)
	local binder = {
		Instance = instance,
		Attribute = attribute,
		Original = instance:GetAttribute(attribute),
		IsWriting = false,
		Spoofed = nil,
		Connection = nil,
	}
	binder.Connection = instance:GetAttributeChangedSignal(attribute):Connect(function()
		if binder.IsWriting then return end
		binder.Original = instance:GetAttribute(attribute)
		binder.IsWriting = true
		if binder.Spoofed ~= nil then
			instance:SetAttribute(attribute, binder.Spoofed.value)
		end
		binder.IsWriting = false
	end)
	return binder
end

local function _spoofBinderSet(binder, spoofed)
	binder.Spoofed = spoofed
	binder.IsWriting = true
	if spoofed == nil then
		binder.Instance:SetAttribute(binder.Attribute, binder.Original)
	else
		binder.Instance:SetAttribute(binder.Attribute, spoofed.value)
	end
	binder.IsWriting = false
end

local function _spoofBinderDestroy(binder)
	if binder.Connection then binder.Connection:Disconnect() end
	pcall(function()
		binder.Instance:SetAttribute(binder.Attribute, binder.Original)
	end)
end

local function _spoofBind(player, attribute)
	local entries = _spoofBinders[player]
	if entries == nil then
		entries = {}
		_spoofBinders[player] = entries
	end
	local binder = entries[attribute]
	if binder == nil then
		binder = _spoofCreateBinder(player, attribute)
		entries[attribute] = binder
	end
	return binder
end

local function _spoofUnbind(player, attribute)
	local entries = _spoofBinders[player]
	if entries == nil then return end
	local binder = entries[attribute]
	if binder ~= nil then
		_spoofBinderDestroy(binder)
		entries[attribute] = nil
	end
end

local function _spoofSetAttribute(player, attribute, enabled, value)
	if enabled then
		_spoofBinderSet(_spoofBind(player, attribute), { value = value })
	else
		_spoofUnbind(player, attribute)
	end
end

local function _spoofApply(player)
	if not player or player.Parent == nil then return end
	for _, field in ipairs(_spoofFields) do
		local state = _spoofState[field.key]
		local value = state.value
		if field.kind == "number" then
			value = tonumber(value)
		elseif type(value) == "string" and value == "" then
			value = nil
		end
		_spoofSetAttribute(player, field.attribute, state.enabled and value ~= nil, value)
	end
	if _spoofState.Admin.enabled then
		_spoofSetAttribute(player, "IsInfluencer", true, true)
		_spoofSetAttribute(player, "IsRobloxEmployee", true, true)
		_spoofSetAttribute(player, "GroupRank", true, 255)
	else
		_spoofUnbind(player, "IsInfluencer")
		_spoofUnbind(player, "IsRobloxEmployee")
		_spoofUnbind(player, "GroupRank")
	end
end

local function _spoofCleanup(player)
	local entries = _spoofBinders[player]
	if entries == nil then return end
	for _, binder in pairs(entries) do
		_spoofBinderDestroy(binder)
	end
	_spoofBinders[player] = nil
end

local function _spoofRefreshAll()
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		_spoofApply(player)
	end
end

local function _spoofStart()
	local Players = game:GetService("Players")
	table.insert(_spoofConnections, Players.PlayerAdded:Connect(function(player)
		task.defer(_spoofApply, player)
	end))
	table.insert(_spoofConnections, Players.PlayerRemoving:Connect(_spoofCleanup))
	_spoofRefreshAll()
end

local function _spoofStop()
	for _, conn in ipairs(_spoofConnections) do
		pcall(function() conn:Disconnect() end)
	end
	_spoofConnections = {}
	for player in pairs(_spoofBinders) do
		_spoofCleanup(player)
	end
end

SpooferGroup:AddToggle("SpoofWinstreak", {
	Text = "Winstreak",
	Default = false,
	Callback = function(Value)
		_spoofState.Winstreak.enabled = Value
		_spoofRefreshAll()
	end
})
SpooferGroup:AddInput("SpoofWinstreakValue", {
	Default = "999",
	Text = "winstreak value",
	Placeholder = "999",
	Numeric = false,
	Finished = true,
	Callback = function(Value)
		_spoofState.Winstreak.value = Value
		_spoofRefreshAll()
	end
})

SpooferGroup:AddToggle("SpoofLevel", {
	Text = "Level",
	Default = false,
	Callback = function(Value)
		_spoofState.Level.enabled = Value
		_spoofRefreshAll()
	end
})
SpooferGroup:AddInput("SpoofLevelValue", {
	Default = "999",
	Text = "level value",
	Placeholder = "999",
	Numeric = false,
	Finished = true,
	Callback = function(Value)
		_spoofState.Level.value = Value
		_spoofRefreshAll()
	end
})

SpooferGroup:AddToggle("SpoofRank", {
	Text = "Rank",
	Default = false,
	Callback = function(Value)
		_spoofState.Rank.enabled = Value
		_spoofRefreshAll()
	end
})
SpooferGroup:AddInput("SpoofRankValue", {
	Default = "3600",
	Text = "rank value",
	Placeholder = "3600",
	Numeric = false,
	Finished = true,
	Callback = function(Value)
		_spoofState.Rank.value = Value
		_spoofRefreshAll()
	end
})

SpooferGroup:AddToggle("SpoofCharm", {
	Text = "Charm",
	Default = false,
	Callback = function(Value)
		_spoofState.Charm.enabled = Value
		_spoofRefreshAll()
	end
})
SpooferGroup:AddInput("SpoofCharmValue", {
	Default = "Prime",
	Text = "charm value",
	Placeholder = "Prime",
	Numeric = false,
	Finished = true,
	Callback = function(Value)
		_spoofState.Charm.value = Value
		_spoofRefreshAll()
	end
})

SpooferGroup:AddToggle("SpoofAdmin", {
	Text = "Admin",
	Default = false,
	Callback = function(Value)
		_spoofState.Admin.enabled = Value
		_spoofRefreshAll()
	end
})

_spoofStart()

-- ============================================================
-- AUTO QUEUE (Misc tab)
-- ============================================================

local _QueueGonnaUse = "1v1"
local _AutoMatch = false

local function _isInMatch()
    local char = lplr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum or hum.Health <= 0 then return false end
    pcall(function()
        if fighterCtrl and (fighterCtrl.LocalFighter or fighterCtrl:GetFighter(lplr)) then
            return true
        end
    end)
    local playerGui = lplr:FindFirstChild("PlayerGui")
    local mainGui = playerGui and playerGui:FindFirstChild("MainGui")
    local mainFrame = mainGui and mainGui:FindFirstChild("MainFrame")
    local inGame = mainFrame and mainFrame:FindFirstChild("InGame")
    if inGame and inGame.Visible then return true end
    return false
end

local AutoQueueGroup = Tabs.Misc:AddRightGroupbox("Auto Queue")

AutoQueueGroup:AddToggle("AutoQueueEnabled", {
    Text = "Enabled",
    Tooltip = "Auto-joins a queue when not in a match",
    Default = false,
    Callback = function(v)
        _AutoMatch = v == true
    end
}):AddKeyPicker("AutoQueueKeybind", {
    Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Auto Queue", NoUI = false,
})

AutoQueueGroup:AddDropdown("AutoQueueMatch", {
    Values = {"1v1", "2v2", "3v3", "4v4", "5v5", "2v2_beginner"},
    Default = "1v1",
    Multi = false,
    Text = "Select Match",
    Callback = function(v)
        _QueueGonnaUse = v
    end
})

runservice.Heartbeat:Connect(function()
    if _AutoMatch then
        if not _isInMatch() then
            pcall(function()
                rs.Remotes.Matchmaking.JoinQueue:InvokeServer(_QueueGonnaUse)
            end)
        end
    end
end)

-- ============================================================
-- SKINCHANGER
-- ============================================================

local _skinChangerEnabled = false

local function setupSkinchanger()
    if not _skinChangerEnabled then return end

    local _plrs    = game:GetService("Players")
    local _rs      = game:GetService("ReplicatedStorage")
    local _http    = game:GetService("HttpService")
    local _run     = game:GetService("RunService")
    local _ws      = game:GetService("Workspace")
    local _lp      = _plrs.LocalPlayer
    local _pscripts = _lp.PlayerScripts
    local _ctrl    = _pscripts.Controllers
    local _mods    = _rs:WaitForChild("Modules", 10)

    local _enumLib = require(_mods:WaitForChild("EnumLibrary", 10))
    if _enumLib then pcall(function() _enumLib:WaitForEnumBuilder() end) end

    local _cosLib  = require(_mods:WaitForChild("CosmeticLibrary", 10))
    local _itmLib  = require(_mods:WaitForChild("ItemLibrary", 10))
    local _datCtrl = require(_ctrl:WaitForChild("PlayerDataController", 10))

    local _eq, _favs = {}, {}
    local _buildingWep, _viewProf = nil, nil
    local _lastWep = nil
    local _fakeInv = {}

    local function _mkCosmetic(nm, ctype, opts)
        local _base = _cosLib.Cosmetics[nm]
        if not _base then return nil end
        local _d = {}
        for k, v in pairs(_base) do _d[k] = v end
        _d.Name = nm
        _d.Type = _d.Type or ctype
        _d.Seed = _d.Seed or math.random(1, 1000000)
        if _enumLib then
            local _s, _eid = pcall(_enumLib.ToEnum, _enumLib, nm)
            if _s and _eid then
                _d.Enum = _eid
                _d.ObjectID = _d.ObjectID or _eid
            end
        end
        if opts then
            if opts.inverted ~= nil then _d.Inverted = opts.inverted end
            if opts.favoritesOnly ~= nil then _d.OnlyUseFavorites = opts.favoritesOnly end
        end
        return _d
    end

    local _cfgFile = "Xilos/Rivalsv3/skins.json"
    local _saveLock = false

    local function _stripForSave()
        local _out = {}
        for wn, cos in pairs(_eq) do
            _out[wn] = {}
            for ct, cd in pairs(cos) do
                if cd and cd.Name then
                    _out[wn][ct] = {
                        Name = cd.Name,
                        Inverted = cd.Inverted,
                        OnlyUseFavorites = cd.OnlyUseFavorites
                    }
                end
            end
        end
        return { equipped = _out, favorites = _favs }
    end

    local function _loadCfg()
        if not isfile or not readfile then return end
        local _ok1, _ex = pcall(isfile, _cfgFile)
        if not _ok1 or not _ex then return end
        local _ok2, _raw = pcall(readfile, _cfgFile)
        if not _ok2 or not _raw or _raw == "" then return end
        local _ok3, _dec = pcall(_http.JSONDecode, _http, _raw)
        if not _ok3 or not _dec then return end
        if _dec.favorites then
            _favs = _dec.favorites
        end
        if _dec.equipped then
            _eq = {}
            local _cnt = 0
            for wn, cos in pairs(_dec.equipped) do
                _eq[wn] = {}
                for ct, sd in pairs(cos) do
                    if sd and sd.Name then
                        if _cosLib.Cosmetics[sd.Name] then
                            local _cloned = _mkCosmetic(sd.Name, ct, {
                                inverted = sd.Inverted,
                                favoritesOnly = sd.OnlyUseFavorites
                            })
                            if _cloned then
                                _eq[wn][ct] = _cloned
                                _cnt += 1
                            end
                        end
                    end
                end
                if not next(_eq[wn]) then _eq[wn] = nil end
            end
        end
    end

    local function _saveCfg()
        if not writefile or _saveLock then return end
        _saveLock = true
        task.spawn(function()
            task.wait(1)
            local _payload = _stripForSave()
            local _ok, _enc = pcall(_http.JSONEncode, _http, _payload)
            if _ok then
                pcall(writefile, _cfgFile, _enc)
            end
            _saveLock = false
        end)
    end

    _loadCfg()

    local _cosTypes = {"Skin","Wrap","Charm","Dance","Emote"}
    local function _isCosType(cosObj)
        if not cosObj then return false end
        for _, t in ipairs(_cosTypes) do
            if cosObj.Type == t then return true end
        end
        return false
    end

    _cosLib.OwnsCosmeticNormally = function(self, inv, nm, wep)
        local c = _cosLib.Cosmetics[nm]
        if c and c.Type == "Skin" then return true end
        return false
    end
    _cosLib.OwnsCosmeticUniversally = function(self, inv, nm, wep)
        local c = _cosLib.Cosmetics[nm]
        if c and c.Type == "Skin" then return true end
        return false
    end
    _cosLib.OwnsCosmeticForWeapon = function(self, inv, nm, wep)
        local c = _cosLib.Cosmetics[nm]
        if c and c.Type == "Skin" then return true end
        return false
    end

    local _origOwns = _cosLib.OwnsCosmetic
    _cosLib.OwnsCosmetic = function(self, inv, nm, wep)
        if nm:find("MISSING_") or nm == "Bubble Gun" then
            return _origOwns(self, inv, nm, wep)
        end
        local c = _cosLib.Cosmetics[nm]
        if c and _isCosType(c) then return true end
        return _origOwns(self, inv, nm, wep)
    end

    local _origGet = _datCtrl.Get
    _datCtrl.Get = function(self, key)
        local _val = _origGet(self, key)
        if key == "CosmeticInventory" then
            local _prx = {}
            if _val then
                for k, v in pairs(_val) do
                    local c = _cosLib.Cosmetics[k]
                    if c and _isCosType(c) then _prx[k] = v end
                end
            end
            return setmetatable(_prx, {
                __index = function(t, k)
                    local c = _cosLib.Cosmetics[k]
                    if c and _isCosType(c) then return true end
                    return nil
                end
            })
        end
        if key == "FavoritedCosmetics" then
            local _res = _val and table.clone(_val) or {}
            for wep, fv in pairs(_favs) do
                _res[wep] = _res[wep] or {}
                for nm, isFav in pairs(fv) do
                    local c = _cosLib.Cosmetics[nm]
                    if c and _isCosType(c) then
                        _res[wep][nm] = isFav
                    end
                end
            end
            return _res
        end
        return _val
    end

    local _origGetWep = _datCtrl.GetWeaponData
    _datCtrl.GetWeaponData = function(self, wn)
        local _d = _origGetWep(self, wn)
        if not _d then return nil end
        local _m = {}
        for k, v in pairs(_d) do _m[k] = v end
        _m.Name = wn
        if _eq[wn] then
            for ct, cd in pairs(_eq[wn]) do
                _m[ct] = cd
            end
        end
        return _m
    end

    local _fightCtrl
    pcall(function()
        _fightCtrl = require(_ctrl:WaitForChild("FighterController", 10))
    end)

    if hookmetamethod then
        local _remotes   = _rs:FindFirstChild("Remotes")
        local _dataRem   = _remotes and _remotes:FindFirstChild("Data")
        local _equipRem  = _dataRem and _dataRem:FindFirstChild("EquipCosmetic")
        local _favRem    = _dataRem and _dataRem:FindFirstChild("FavoriteCosmetic")
        local _repRem    = _remotes and _remotes:FindFirstChild("Replication")
        local _fightRem  = _repRem and _repRem:FindFirstChild("Fighter")
        local _useItmRem = _fightRem and _fightRem:FindFirstChild("UseItem")

        if _equipRem then
            local _onc
            _onc = hookmetamethod(game, "__namecall", function(self, ...)
                if getnamecallmethod() ~= "FireServer" then
                    return _onc(self, ...)
                end
                local _a = {...}

                if _useItmRem and self == _useItmRem then
                    local _oid = _a[1]
                    if _fightCtrl then
                        pcall(function()
                            local _f = _fightCtrl:GetFighter(_lp)
                            if _f and _f.Items then
                                for _, itm in pairs(_f.Items) do
                                    if itm:Get("ObjectID") == _oid then
                                        _lastWep = itm.Name
                                        break
                                    end
                                end
                            end
                        end)
                    end
                end

                if self == _equipRem then
                    local _wn   = _a[1]
                    local _ct   = _a[2]
                    local _cn   = _a[3]
                    local _opts = _a[4] or {}
                    if _cn and _cn ~= "None" and _cn ~= "" then
                        local _inv = _datCtrl:Get("CosmeticInventory")
                        if _inv and rawget(_inv, _cn) then
                            return _onc(self, ...)
                        end
                    end
                    _eq[_wn] = _eq[_wn] or {}
                    if not _cn or _cn == "None" or _cn == "" then
                        _eq[_wn][_ct] = nil
                        if not next(_eq[_wn]) then _eq[_wn] = nil end
                    else
                        local _cloned = _mkCosmetic(_cn, _ct, {
                            inverted = _opts.IsInverted,
                            favoritesOnly = _opts.OnlyUseFavorites
                        })
                        if _cloned then _eq[_wn][_ct] = _cloned end
                    end
                    task.defer(function()
                        pcall(function() _datCtrl.CurrentData:Replicate("WeaponInventory") end)
                    end)
                    _saveCfg()
                    return
                end

                if self == _favRem then
                    local _cos = _cosLib.Cosmetics[_a[2]]
                    if _cos then
                        _favs[_a[1]] = _favs[_a[1]] or {}
                        _favs[_a[1]][_a[2]] = _a[3] or nil
                        task.spawn(function()
                            pcall(function() _datCtrl.CurrentData:Replicate("FavoritedCosmetics") end)
                        end)
                        _saveCfg()
                    end
                    return
                end

                return _onc(self, ...)
            end)
        end
    end

    local _cliItem
    pcall(function()
        _cliItem = require(_lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
    end)

    if _cliItem and _cliItem._CreateViewModel then
        local _origCVM = _cliItem._CreateViewModel
        _cliItem._CreateViewModel = function(self, vmRef)
            local _wn  = self.Name
            local _wp  = self.ClientFighter and self.ClientFighter.Player
            _buildingWep = (_wp == _lp) and _wn or nil
            if _wp == _lp and _eq[_wn] then
                local _dk = self:ToEnum("Data")
                if vmRef[_dk] then
                    if _eq[_wn].Skin then
                        vmRef[_dk][self:ToEnum("Skin")] = _eq[_wn].Skin
                        vmRef[_dk][self:ToEnum("Name")] = _eq[_wn].Skin.Name
                    end
                    if _eq[_wn].Charm then vmRef[_dk][self:ToEnum("Charm")] = _eq[_wn].Charm end
                    if _eq[_wn].Wrap  then vmRef[_dk][self:ToEnum("Wrap")]  = _eq[_wn].Wrap  end
                elseif vmRef.Data then
                    if _eq[_wn].Skin  then vmRef.Data.Skin  = _eq[_wn].Skin; vmRef.Data.Name = _eq[_wn].Skin.Name end
                    if _eq[_wn].Charm then vmRef.Data.Charm = _eq[_wn].Charm end
                    if _eq[_wn].Wrap  then vmRef.Data.Wrap  = _eq[_wn].Wrap  end
                end
            end
            local _r = _origCVM(self, vmRef)
            _buildingWep = nil
            return _r
        end
    end

    local _vmMod = _lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
    if _vmMod then
        local _CVM = require(_vmMod)
        local _origNew = _CVM.new
        _CVM.new = function(repData, cliItm)
            local _wp  = cliItm.ClientFighter and cliItm.ClientFighter.Player
            local _wn  = _buildingWep or cliItm.Name
            if _wp == _lp and _eq[_wn] then
                local _RC  = require(_rs.Modules.ReplicatedClass)
                local _dk  = _RC:ToEnum("Data")
                repData[_dk] = repData[_dk] or {}
                local _cos = _eq[_wn]
                if _cos.Skin  then repData[_dk][_RC:ToEnum("Skin")]  = _cos.Skin  end
                if _cos.Charm then repData[_dk][_RC:ToEnum("Charm")] = _cos.Charm end
                if _cos.Wrap  then repData[_dk][_RC:ToEnum("Wrap")]  = _cos.Wrap  end
            end
            return _origNew(repData, cliItm)
        end
    end
end

MiscLeft:AddToggle('SkinChangerToggle', {
    Text = 'Skinchanger',
    Default = false,
    Tooltip = "Enables the skinchanger",
    Callback = function(enabled)
        _skinChangerEnabled = enabled == true
        if _skinChangerEnabled then
            task.spawn(function()
                pcall(setupSkinchanger)
            end)
        end
    end,
}):AddKeyPicker("SkinChangerKeybind", {
    Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Skinchanger", NoUI = false,
})

local AutoLoadout = Tabs.Misc:AddLeftGroupbox("AutoLoadout")
local chosenWeapons = { Primary = "Assault Rifle", Secondary = "Handgun", Melee = "Fists", Utility = "Grenade" }
local AutoLoadSelect = false
local rs2 = game:GetService("ReplicatedStorage")
local runservice2 = game:GetService("RunService")

AutoLoadout:AddDropdown("AutoLoadoutList1", {
	Values = { "Assault Rifle", "Shotgun", "Sniper", "Bow", "Burst Rifle", "Crossbow", "Energy Rifle", "Flamethrower", "Grenade Launcher", "Minigun", "Paintball Gun", "RPG", "Permafrost", "Distortion" },
	Default = "Assault Rifle", Multi = false, Text = "Primary", Searchable = true,
	Callback = function(Value) chosenWeapons.Primary = Value end
})
AutoLoadout:AddDropdown("AutoLoadoutList2", {
	Values = { "Handgun", "Uzi", "Revolver", "Shorty", "Flare Gun", "Daggers", "Slingshot", "Exogun", "Energy Pistols", "Spray", "Warper" },
	Default = "Handgun", Multi = false, Text = "Secondary", Searchable = true,
	Callback = function(Value) chosenWeapons.Secondary = Value end
})
AutoLoadout:AddDropdown("AutoLoadoutList3", {
	Values = { "Fists", "Katana", "Scythe", "Knife", "Chainsaw", "Trowel", "Battle Axe", "Riot Shield", "Maul" },
	Default = "Fists", Multi = false, Text = "Melee", Searchable = true,
	Callback = function(Value) chosenWeapons.Melee = Value end
})
AutoLoadout:AddDropdown("AutoLoadoutList4", {
	Values = { "Flashbang", "Freeze Ray", "Grappler", "Grenade", "Jump Pad", "Medkit", "Molotov", "Satchel", "Smoke Grenade", "Subspace Tripmine", "War Horn", "Warpstone", "Elixir", "RNG Dice" },
	Default = "Grenade", Multi = false, Text = "Utility", Searchable = true,
	Callback = function(Value) chosenWeapons.Utility = Value end
})
AutoLoadout:AddToggle("AutoLoad", {
	Text = "Auto Load", Default = false,
	Callback = function(Value) AutoLoadSelect = Value end
}):AddKeyPicker("AutoLoadKeybind", {
	Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Auto Load", NoUI = false,
})

runservice2.Heartbeat:Connect(function()
	if AutoLoadSelect then
		pcall(function()
			rs2.Remotes.Replication.Fighter.PickWeapons:FireServer({
				chosenWeapons.Primary, chosenWeapons.Secondary, chosenWeapons.Melee, chosenWeapons.Utility
			})
		end)
		task.wait(2)
	end
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value) Library.KeybindFrame.Visible = value end
})

MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value) Library.ShowCustomCursor = Value end
})

MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Menu keybind"
})

MenuGroup:AddButton("Unload", function() Library:Unload() end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("Xilos/Rivalsv3/themes")
SaveManager:SetFolder("Xilos/Rivalsv3/configs")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

SaveManager:LoadAutoloadConfig()

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60
local GetPing = (function() return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
local CanDoPing = pcall(function() return GetPing(); end)

local WatermarkConnection = game:GetService("RunService").RenderStepped:Connect(function()
	FrameCounter += 1
	if (tick() - FrameTimer) >= 1 then
		FPS = FrameCounter
		FrameTimer = tick()
		FrameCounter = 0
	end
	if CanDoPing then
		Library:SetWatermark(("XE | %d fps | %d ms"):format(math.floor(FPS), GetPing()))
	else
		Library:SetWatermark(("XE | %d fps"):format(math.floor(FPS)))
	end
end)

Library:OnUnload(function()
	WatermarkConnection:Disconnect()
	pcall(function() if RagebotModule and RagebotModule._Stop then RagebotModule:_Stop() end end)
	pcall(function() if VoidModule and VoidModule._Stop then VoidModule:_Stop() end end)
	pcall(function() if _arcadeEnabled then _arcadeStop() end end)
	pcall(function() _spoofStop() end)
	pcall(function() _stopRapidFire() end)
	pcall(function() _stopFastMelee() end)
	pcall(function() _AutoMatch = false end)
	pcall(function() _wireframeEnabled = false; _refreshWireframe() end)
	print("Unloaded!")
	Library.Unloaded = true
end)
