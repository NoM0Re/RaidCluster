-- *********************************************************
-- **                     RaidCluster                     **
-- **        https://github.com/NoM0Re/RaidCluster        **
-- *********************************************************
--
-- This addon is written and copyrighted by:
-- - NoM0Re
--
-- The code of this addon is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 4.0 License.
--
--  You are free:
--    * to Share - to copy, distribute, display, and perform the work
--    * to Remix - to make derivative works
--  Under the following conditions:
--    * Attribution. You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work).
--    * Noncommercial. You may not use this work for commercial purposes.
--    * Share Alike. If you alter, transform, or build upon this work, you may distribute the resulting work only under the same or similar license to this one.

local AddonName = ...
local RaidCluster = select(2, ...)

-- Libs
RaidCluster = LibStub("AceAddon-3.0"):NewAddon(RaidCluster, "RaidCluster", "AceConsole-3.0", "AceTimer-3.0")
_G.RaidCluster = RaidCluster
local LGF = LibStub("LibGetFrame-1.0")
local LCG = LibStub("LibCustomGlow-1.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ADB = LibStub("AceDB-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local LibDualSpec = LibStub("LibDualSpec-1.0")
local GetFrame = LGF.GetUnitFrame
local PixelGlow_Start = LCG.PixelGlow_Start
local PixelGlow_Stop = LCG.PixelGlow_Stop

RaidCluster.version = AddonName.." v"..GetAddOnMetadata(AddonName, "Version")

-- WoW Api
local UnitName = UnitName
local UnitIsConnected = UnitIsConnected
local UnitIsVisible = UnitIsVisible
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local GetRaidRosterInfo = GetRaidRosterInfo
local GetNumRaidMembers = GetNumRaidMembers
local GetPlayerMapPosition = GetPlayerMapPosition
local UnitClass = UnitClass
local UnitInRaid = UnitInRaid

-- Variables
local isInit
local db
local eventLock = RaidCluster.eventLock
RaidCluster.IsInit = false
RaidCluster.cleuInit = false
RaidCluster.frames = {}
RaidCluster.currentframes = {}
RaidCluster.frameCount = {25, 40}
RaidCluster.Range = 0
RaidCluster.ClassRanges = {
    ["PALADIN"] = 9.5,
    ["SHAMAN"] = 12.5,
    ["PRIEST"] = { 16.5, 30 },
    ["DRUID"] = 16.5
}
RaidCluster.Action = {
    ["PALADIN"] = false,
    ["SHAMAN"] = false,
    ["HPRIEST"] = false,
    ["DPRIEST"] = false,
    ["DRUID"] = false
}
-- Pixel Glow CLEU Functions
local cleuFunctions = {
    ["PALADIN"] = function(self, ...)
        local _, _, subEvent, _, sourceName, _, _, destName,_ , spellID = ...
        if subEvent == "SPELL_HEAL" and sourceName == RaidCluster.playerName and spellID == 54968 and destName then
            local f = GetFrame(destName)
            if f and db then
                PixelGlow_Start(f, {db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a}, db.lines, db.frequency, db.length, db.thickness, db.xOffset, db.yOffset)
                RaidCluster:ScheduleTimer(function() PixelGlow_Stop(f) end, 1)
            end
        end
    end,
    ["SHAMAN"] = function(self, ...)
        local _, _, subEvent, _, sourceName, _, _, destName,_ , spellID = ...
        if subEvent == "SPELL_HEAL" and sourceName == RaidCluster.playerName and spellID == 55459 and destName then
            local f = GetFrame(destName)
            if f and db then
                PixelGlow_Start(f, {db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a}, db.lines, db.frequency, db.length, db.thickness, db.xOffset, db.yOffset)
                RaidCluster:ScheduleTimer(function() PixelGlow_Stop(f) end, 1)
            end
        end
    end,
    ["HPRIEST"] = function(self, ...)
        local _, _, subEvent, _, sourceName, _, _, destName,_ , spellID = ...
        if subEvent == "SPELL_HEAL" and sourceName == RaidCluster.playerName and spellID == 48089 and destName then
            local f = GetFrame(destName)
            if f and db then
                PixelGlow_Start(f, {db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a}, db.lines, db.frequency, db.length, db.thickness, db.xOffset, db.yOffset)
                RaidCluster:ScheduleTimer(function() PixelGlow_Stop(f) end, 1)
            end
        end
    end,
    ["DPRIEST"] = function(self, ...)
        local _, _, subEvent, _, sourceName, _, _, destName,_ , spellID = ...
        if subEvent == "SPELL_HEAL" and sourceName == RaidCluster.playerName and spellID == 48072 and destName then
            local f = GetFrame(destName)
            if f and db then
                PixelGlow_Start(f, {db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a}, db.lines, db.frequency, db.length, db.thickness, db.xOffset, db.yOffset)
                RaidCluster:ScheduleTimer(function() PixelGlow_Stop(f) end, 1)
            end
        end
    end,
    ["DRUID"] = function(self, ...)
        local _, _, subEvent, _, sourceName, _, _, destName,_ , spellID = ...
        if (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH") and sourceName == RaidCluster.playerName and spellID == 53251 and destName then
            local f = GetFrame(destName)
            if f and db then
                PixelGlow_Start(f, {db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a}, db.lines, db.frequency, db.length, db.thickness, db.xOffset, db.yOffset)
                RaidCluster:ScheduleTimer(function() PixelGlow_Stop(f) end, 1)
            end
        end
    end
}

function RaidCluster:ResetActions()
    for key, _ in pairs(self.Action) do
        self.Action[key] = false
    end
end

function RaidCluster:CreateAnchorFrame()
    local f = CreateFrame("Frame", "RaidCluster Anchor")
    f:SetWidth(0)
    f:SetHeight(0)
    f:SetPoint("BOTTOMLEFT", -200, -200)
    f:SetFrameStrata("MEDIUM")
    f:SetFrameLevel(20)
    f:EnableMouse(false)
    f:EnableMouseWheel(false)
    f:EnableJoystick(false)
    f:Show()
    self.parent = f
end

function RaidCluster:CreateCounterFrame(index)
    if not self.parent then
        self:CreateAnchorFrame()
    end
    local frameName = "RaidClusterCounter" .. index
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetSize(1, 1)
    f:SetFrameStrata("MEDIUM")
    f:SetFrameLevel(170)
    f:SetPoint("BOTTOMLEFT", self.parent, "BOTTOMLEFT", -200, -200)
    f:SetToplevel(true)
    f:Show()
    f.text = f:CreateFontString(frameName, "OVERLAY", "GameFontWhite")
    f.text:SetFont(LSM:Fetch("font", db.font), db.fontSize, db.fontFlags)
    f.text:SetTextColor(db.color.r, db.color.g, db.color.b, db.color.a)
    f.text:SetPoint("CENTER", f, "CENTER", db.x, db.y)
    f.text:SetText("")
    f.text:Show()

    self.frames[frameName] = {
        frame = f,
        inUse = false
    }
end

function RaidCluster:GetUnusedCounter() -- Get next Free Text
    for frameName, data in pairs(self.frames) do
        if not data.inUse then
            return self.frames[frameName].frame, frameName
        end
    end
    return nil
end

function RaidCluster:FrameReseter() -- Frame reseter
    if next(self.frames) ~= nil then
        for _, data in pairs(self.frames) do
            data.frame.text:SetText("")
            data.frame:SetParent(self.parent)
            data.frame:SetPoint("CENTER", self.parent, "CENTER", 0, 0)
            data.inUse = false
        end
    end
end

function RaidCluster:UpdateFrames(results, bool)
    if next(self.currentframes) == nil then return end
    for unit, count in pairs(results) do
        local frame, subGroup = self.currentframes[unit] and self.currentframes[unit].frame, self.currentframes[unit] and self.currentframes[unit].subGroup
        if db.subGroup and subGroup and subGroup > 5 then
            --immitate continue
        else
            if frame then
                count = bool and tostring(#count - 1) or tostring(count)
                frame.text:SetText(count)
                frame.text:Show()
            end
        end
    end
end

function RaidCluster:HidePlayerText(PlayerName) -- Hide Text for a single Player
    if self.currentframes and next(self.currentframes) ~= nil then
        local frameData = self.currentframes[PlayerName] and self.currentframes[PlayerName].frame
        if frameData and frameData:IsShown() then
            frameData:Hide()
            frameData.text:SetText("")
        end
    end
end

function RaidCluster:GetPlayerPositions(Members)
    local playerPositions = {}
    for i = 1, Members do
        local unit = "raid" .. i
        local unitName = UnitName(unit)
        if unitName then
            if UnitIsConnected(unit) and UnitIsVisible(unit) and (not UnitIsDeadOrGhost(unit)) then
                local x, y = GetPlayerMapPosition(unit)
                if x and y then
                    playerPositions[unitName] = { x = x, y = y }
                else
                    self:HidePlayerText(unitName)
                end
            else
                self:HidePlayerText(unitName)
            end
        end
    end
    return playerPositions
end

function RaidCluster:GetPlayerPositionsLowHealth(Members)
    local playerPositions = {}
    for i = 1, Members do
        local unit = "raid" .. i
        local unitName = UnitName(unit)
        if unitName then
            if UnitIsConnected(unit) and UnitIsVisible(unit) and (not UnitIsDeadOrGhost(unit)) and UnitHealth(unit) < UnitHealthMax(unit) then
                local x, y = GetPlayerMapPosition(unit)
                if x and y then
                    playerPositions[unitName] = { x = x, y = y }
                else
                    self:HidePlayerText(unitName)
                end
            else
                self:HidePlayerText(unitName)
            end
        end
    end
    return playerPositions
end

function RaidCluster:GetPlayersChainedInRangeCount(playerPositions)
    local playersInRange = {}
    for unitA, positionA in pairs(playerPositions) do
        local playersInUnitARange = {}
        for unitB, positionB in pairs(playerPositions) do
            local distance = self:GetUnitRange(positionA.x, positionA.y, positionB.x, positionB.y)
            if distance <= self.Range then
                table.insert(playersInUnitARange, unitB)
            end
        end
        playersInRange[unitA] = playersInUnitARange
    end
    for unitA, unitsInRangeA in pairs(playersInRange) do
        for _, unitB in ipairs(unitsInRangeA) do
            for _, unitC in ipairs(playersInRange[unitB]) do
                if unitC ~= unitA and not self:tableFind(playersInRange[unitA], unitC) then
                    table.insert(playersInRange[unitA], unitC)
                end
            end
        end
    end
    return playersInRange
end

function RaidCluster:CalculateChainedPlayers()
    local Members = GetNumRaidMembers()
    if not Members or Members < 1 then return end
    local playerPositions = self:GetPlayerPositionsLowHealth(Members)
    local playersInRangeCount = self:GetPlayersChainedInRangeCount(playerPositions)
    self:UpdateFrames(playersInRangeCount, true)
end

function RaidCluster:GetPlayersInRangeCount(playerPositions)
    local playersInRangeCount = {}
    for unitA, positionA in pairs(playerPositions) do
        local playersInUnitARange = 0
        for unitB, positionB in pairs(playerPositions) do
            if unitA ~= unitB then
                local distance = self:GetUnitRange(positionA.x, positionA.y, positionB.x, positionB.y)
                if distance <= self.Range then
                    playersInUnitARange = playersInUnitARange + 1
                end
            end
        end
        playersInRangeCount[unitA] = playersInUnitARange
    end
    return playersInRangeCount
end

function RaidCluster:CalculatePlayersToPlayers()
    local Members = GetNumRaidMembers()
    if not Members or Members < 0 then return end
    local playerPositions = self:GetPlayerPositions(Members)
    local playersInRangeCount = self:GetPlayersInRangeCount(playerPositions)
    self:UpdateFrames(playersInRangeCount, false)
end

function RaidCluster:GetPlayersInGroupRangeCount(playerPositions)
    local groups = {}
    for playerName, position in pairs(playerPositions) do
        local group = self.currentframes[playerName] and self.currentframes[playerName].subGroup
        if group then
            groups[group] = groups[group] or {}
            table.insert(groups[group], { unitName = playerName, x = position.x, y = position.y })
        end
    end
    local playersInRangeCount = {}
    for _, players in pairs(groups) do
        for _, playerA in ipairs(players) do
            local playerName = playerA.unitName
            local playersInUnitARange = 0
            for _, playerB in ipairs(players) do
                local distance = self:GetUnitRange(playerA.x, playerA.y, playerB.x, playerB.y)
                if distance <= self.Range then
                    playersInUnitARange = playersInUnitARange + 1
                end
            end
            playersInRangeCount[playerName] = playersInUnitARange
        end
    end
    return playersInRangeCount
end

function RaidCluster:CalculateGroupPlayersToGroupPlayers()
    local Members = GetNumRaidMembers()
    if not Members or Members < 0 then return end
    local playerPositions = self:GetPlayerPositions(Members)
    local playersInRangeCount = self:GetPlayersInGroupRangeCount(playerPositions)
    self:UpdateFrames(playersInRangeCount, false)
end

function RaidCluster:ProcessPlayerFrame(playerName, subGroup, playerClass)
    local counter, frameName = self:GetUnusedCounter()
    if counter and frameName then
        local playerFrame = GetFrame(playerName) -- Get the Raidframe
        if playerFrame then
            counter:ClearAllPoints()
            counter:SetParent(playerFrame)
            counter:SetPoint("CENTER", playerFrame, "CENTER", db.x, db.y)
            if db.classColor then
                counter.text:SetTextColor(self:GetClassColor(playerClass))
            end
            self.frames[frameName].inUse = true
            self.currentframes[playerName] = {
                frame = counter,
                parent = playerFrame,
                subGroup = subGroup,
                class = playerClass
            }
        end
    end
end

function RaidCluster:ParentPlayerRaidFrames()
    self.currentframes = {}
    local Members = GetNumRaidMembers()
    if not Members or Members < 1 then return end

    for i = 1, Members do
        local playerName, _, subGroup, _, _, playerClass = GetRaidRosterInfo(i)
        if db.subGroup then
            if subGroup and subGroup <= 5 then
                self:ProcessPlayerFrame(playerName, subGroup, playerClass)
            end
        else
            self:ProcessPlayerFrame(playerName, subGroup, playerClass)
        end
    end
end

function RaidCluster:OnFPSrefresh()
    if self.IsInit then
        if self.Action.PALADIN then
            self:CalculatePlayersToPlayers()
        elseif self.Action.SHAMAN then
            self:CalculateChainedPlayers()
        elseif self.Action.HPRIEST then
            self:CalculatePlayersToPlayers()
        elseif self.Action.DPRIEST then
            self:CalculateGroupPlayersToGroupPlayers()
        elseif self.Action.DRUID then
            self:CalculatePlayersToPlayers()
        end
    end
end

function RaidCluster:ChangeApperance()
    if not db then return end
    -- Font, FontSize, FontFlags, FontColor
    if self.frames and next(self.frames) ~= nil then
        for _, data in pairs(self.frames) do
            if data.frame and data.frame.text then
                data.frame.text:SetFont(LSM:Fetch("font", db.font), db.fontSize, db.fontFlags)
                if db.classColor then
                    data.frame.text:SetTextColor(self:GetClassColor(data.class))
                else
                    data.frame.text:SetTextColor(db.color.r, db.color.g, db.color.b, db.color.a)
                end
                data.frame:SetPoint("CENTER", data.parent, "CENTER", db.x, db.y)
            end
        end
    end
end

function RaidCluster:EventLock()
    self:StopAddon()
    self:specDetection()
end

function RaidCluster:StartCLEU(Class)
    self.cleuInit = true
    self.CLEU:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.CLEU:SetScript("OnEvent", cleuFunctions[Class])
end

function RaidCluster:StopCLEU()
    self.cleuInit = false
    self.CLEU:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.CLEU:SetScript("OnEvent", nil)
end

function RaidCluster:StopAddon()
    self.IsInit = false
    if self.FPSTimer then
        self:CancelTimer(self.FPSTimer)
    end
    self:StopCLEU()
    self:FrameReseter()
    self:ResetActions()
end

function RaidCluster:DisableAddon()
    self:StopAddon()
    self.EventHandler:UnregisterEvent("RAID_ROSTER_UPDATE")
    self.EventHandler:UnregisterEvent("PARTY_MEMBERS_CHANGED")
    self.EventHandler:UnregisterEvent("PLAYER_TALENT_UPDATE")
end

function RaidCluster:EnableAddon()
    self.EventHandler:RegisterEvent("RAID_ROSTER_UPDATE")
    self.EventHandler:RegisterEvent("PARTY_MEMBERS_CHANGED")
    self.EventHandler:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:specDetection()
end

function RaidCluster:StartAddon(Class)
    self.IsInit = true
    if Class == "PALADIN" then
        self.Range = self.ClassRanges.PALADIN
        self.Action.PALADIN = true
    elseif Class  == "SHAMAN" then
        self.Range = self.ClassRanges.SHAMAN
        self.Action.SHAMAN = true
    elseif Class == "HPRIEST" then
        self.Range = self.ClassRanges.PRIEST[1]
        self.Action.HPRIEST = true
    elseif Class == "DPRIEST" then
        self.Range = self.ClassRanges.PRIEST[2]
        self.Action.DPRIEST = true
    elseif Class == "DRUID" then
        self.Range = self.ClassRanges.DRUID
        self.Action.DRUID = true
    end
    if next(self.frames) == nil then
        local count = db.subGroup and self.frameCount[1] or self.frameCount[2]
        for i = 1, count do
            self:CreateCounterFrame(i)
        end
    end
    self:ParentPlayerRaidFrames()
    self.FPSTimer = self:ScheduleRepeatingTimer("OnFPSrefresh", db.update or 1)
end

function RaidCluster:specDetection()
    if not (db or db.enabled or UnitInRaid("player")) then return end
    local Class = select(2, UnitClass("player"))
    if Class == "PALADIN" then
        local RaidFrame, PixelGlow = db.paladinRaidFrameEnable, db.paladinPixelGlowEnable
        if not (RaidFrame or PixelGlow) then return end
        local talents = self:FindTalentPosition(Class, db.paladinTalents)
        if talents then
            if (not self.cleuInit) and PixelGlow then
                self:StartCLEU(Class)
            end
            if (not self.IsInit) and RaidFrame then
                self:StartAddon(Class)
            end
        else
            if self.IsInit then
                self:StopAddon()
            end
            if self.cleuInit then
                self:StopCLEU()
            end
        end
    elseif Class == "SHAMAN" then
        local RaidFrame, PixelGlow = db.shamanRaidFrameEnable, db.shamanPixelGlowEnable
        if not (RaidFrame or PixelGlow) then return end
        local talents = self:FindTalentPosition(Class, db.shamanTalents)
        if talents then
            if (not self.cleuInit) and PixelGlow then
                self:StartCLEU(Class)
            end
            if (not self.IsInit) and RaidFrame then
                self:StartAddon(Class)
            end
        else
            if self.IsInit then
                self:StopAddon()
            end
            if self.cleuInit then
                self:StopCLEU()
            end
        end
    elseif Class == "PRIEST" then
        local hRaidFrame, hPixelGlow, dRaidFrame, dPixelGlow = db.holyPriestRaidFrameEnable, db.discoPriestRaidFrameEnable,db.holyPriestPixelGlowEnable, db.discoPriestPixelGlowEnable
        if not (hRaidFrame or hPixelGlow) and not (dRaidFrame or dPixelGlow) then return end
        local htalents = self:FindTalentPosition(Class, db.holyPriestTalents)
        local dtalents = self:FindTalentPosition(Class, db.discoPriestTalents)
        if htalents then
            if (not self.cleuInit) and hPixelGlow then
                self:StartCLEU("HPRIEST")
            end
            if (not self.IsInit) and hRaidFrame then
                self:StartAddon("HPRIEST")
            end
        elseif dtalents then
            if (not self.cleuInit) and dPixelGlow then
                self:StartCLEU("DPRIEST")
            end
            if (not self.IsInit) and dRaidFrame then
                self:StartAddon("DPRIEST")
            end
        else
            if self.IsInit then
                self:StopAddon()
            end
            if self.cleuInit then
                self:StopCLEU()
            end
        end
    elseif Class == "DRUID" then
        local RaidFrame, PixelGlow = db.druidRaidFrameEnable, db.druidPixelGlowEnable
        if not (RaidFrame or PixelGlow) then return end
        local talents = self:FindTalentPosition(Class, db.druidTalents)
        if talents then
            if (not self.cleuInit) and PixelGlow then
                self:StartCLEU(Class)
            end
            if (not self.IsInit) and RaidFrame then
                self:StartAddon(Class)
            end
        else
            if self.IsInit then
                self:StopAddon()
            end
            if self.cleuInit then
                self:StopCLEU()
            end
        end
    end
end

function RaidCluster:OnProfileChanged()
    self:FixProfileDefaults(self.db.profile, self.defaults.profile)
    db = self.db.profile
    self:UpdateDB()
    if (isInit and not self.OnEnable) then
        self:StopAddon()
        self:ChangeApperance()
        self:specDetection()
    end
end

-- Event Handler
local function EventHandler(self, event, ...)
    if (event == "RAID_ROSTER_UPDATE") or (event == "PARTY_MEMBERS_CHANGED") then
        if (self.IsInit and (not eventLock)) then
            eventLock = RaidCluster:ScheduleTimer("EventLock", 1.5)
        else
            RaidCluster:specDetection()
        end
    elseif (event == "PLAYER_TALENT_UPDATE") then
        RaidCluster:specDetection()
    end
end

-- Init Addon
function RaidCluster:OnInitialize()
    -- DB
    self.db = ADB:New("RaidCluster_DB", self.defaults, true)

    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
    LibDualSpec:EnhanceDatabase(self.db, "RaidCluster");

    -- BlizzOpt
    AC:RegisterOptionsTable("RaidCluster", self.options)
    ACR:RegisterOptionsTable("RaidCluster_Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
    LibDualSpec:EnhanceOptions(LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db), self.db)

    ACD:AddToBlizOptions("RaidCluster")
    ACD:AddToBlizOptions("RaidCluster_Profiles", "Profiles", "RaidCluster")

    -- SlashCmds
	self:RegisterChatCommand("rac", "SlashCommand")
	self:RegisterChatCommand("raidcluster", "SlashCommand")

    -- DB Ref
    db = self.db.profile
    self:UpdateDB()

    -- Frame Creation
    self.EventHandler = CreateFrame("Frame")
    self.EventHandler:RegisterEvent("PLAYER_TALENT_UPDATE")
    self.EventHandler:SetScript("OnEvent", EventHandler)

    self.CLEU = CreateFrame("Frame")

    self.OnInitialize = nil
end

function RaidCluster:OnEnable()
    self.playerName = UnitName("player")

    if isInit then
        RaidCluster:specDetection()
    end

    self.OnEnable = nil
end

-- This is tricky first we need to init LibGetFrame, it needs some time to be ready,
-- so we call LGF:ScanForUnitFrames() and wait for an answer, then we startup the addon.
local function LGFStartup(...)
    isInit = true
    LGF.UnregisterCallback("RaidCluster", "GETFRAME_REFRESH")
    if not RaidCluster.OnEnable then
        RaidCluster:specDetection()
    end
end
LGF.RegisterCallback("RaidCluster", "GETFRAME_REFRESH", LGFStartup)
LGF:ScanForUnitFrames()
