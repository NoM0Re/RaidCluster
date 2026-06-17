-- *********************************************************
-- **                     RaidCluster                     **
-- **        https://github.com/NoM0Re/RaidCluster        **
-- *********************************************************

local RaidCluster = select(2, ...)

local db = setmetatable({}, {
  __index = function(_, key)
    local database = RaidCluster.db and RaidCluster.db.profile
    return database and database[key]
  end,
  __newindex = function(_, key, value)
    local database = RaidCluster.db and RaidCluster.db.profile
    if database then
      database[key] = value
    end
  end,
})

local LSM = LibStub("LibSharedMedia-3.0")
local LGF = LibStub("LibGetFrame-1.0")

local UnitIsUnit = UnitIsUnit
local UnitExists = UnitExists
local UnitName = UnitName
local UnitClass = UnitClass
local UnitInRaid = UnitInRaid
local GetRaidRosterInfo = GetRaidRosterInfo
local GetNumRaidMembers = GetNumRaidMembers
local GetNumPartyMembers = GetNumPartyMembers
local CreateFrame = CreateFrame
local UIParent = UIParent

local framePriorities = LGF.getDefaultFramePriorities and LGF.getDefaultFramePriorities() or {}
local fallbackPriority = #framePriorities + 1
local MAX_FRAME_LEVEL = 120

local function GetSafeFrameLevel(frame, offset)
  local level = (frame and frame:GetFrameLevel() or 0) + (offset or 0)
  if level > MAX_FRAME_LEVEL then
    return MAX_FRAME_LEVEL
  end
  return level
end

local function GetFrameName(frame)
  if frame and frame.GetName then
    return frame:GetName()
  end
end

local function GetFramePriority(frame)
  local name = GetFrameName(frame)
  if not name then
    return fallbackPriority
  end

  for index, pattern in ipairs(framePriorities) do
    if name:find(pattern) then
      return index
    end
  end

  return fallbackPriority
end

local function CounterResetter(_, frame)
  frame:Hide()
  frame:ClearAllPoints()
  frame:SetParent(UIParent)
  if frame.text then
    frame.text:SetText("")
    frame.text:Hide()
  end
  frame.raidClusterUnit = nil
  frame.raidClusterParent = nil
end

local function CreateCounterFrame()
  local frame = CreateFrame("Frame", nil, UIParent)
  frame:SetSize(5, 5)
  frame:SetFrameStrata("HIGH")
  frame:SetFrameLevel(MAX_FRAME_LEVEL)
  frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
  frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
  frame.text:Hide()
  return frame
end

function RaidCluster:EnsureCounterPool()
  if not self.counterPool then
    self.counterPool = CreateObjectPool(CreateCounterFrame, CounterResetter)
  end
end

function RaidCluster:ReleaseCounters()
  if self.counterPool then
    self.counterPool:ReleaseAll()
  end
  self.currentframes = {}
end

function RaidCluster:ResetFrameBindings()
  self.unitFramesByName = {}
  self.unitFrameCandidatesByName = {}
  self.frameOwnerByFrame = {}
end

function RaidCluster:CancelRangeJob()
  self.rangeJob = nil
  if self.rangeWorker then
    self.rangeWorker:Hide()
  end
end

function RaidCluster:ReleaseCounter(playerName)
  local data = playerName and self.currentframes[playerName]
  if not data then
    return
  end

  if self.counterPool then
    self.counterPool:Release(data.frame)
  end
  self.currentframes[playerName] = nil
end

function RaidCluster:ReleasePlayerBinding(playerName)
  local candidates = self.unitFrameCandidatesByName[playerName]
  if candidates then
    for frame in pairs(candidates) do
      if self.frameOwnerByFrame[frame] == playerName then
        self.frameOwnerByFrame[frame] = nil
      end
    end
  end
  self:ReleaseCounter(playerName)
  self.unitFramesByName[playerName] = nil
  self.unitFrameCandidatesByName[playerName] = nil
end

function RaidCluster:ConfigureCounter(frame, playerClass)
  frame.text:SetFont(LSM:Fetch("font", db.font), db.fontSize, db.fontFlags)
  if db.classColor then
    frame.text:SetTextColor(self:GetClassColor(playerClass))
  else
    frame.text:SetTextColor(db.color.r, db.color.g, db.color.b, db.color.a)
  end
end

function RaidCluster:AttachCounterToFrame(frame, info)
  local playerFrame = frame
  local playerName = info and info.name
  if not playerFrame or not playerName then
    return
  end

  local current = self.currentframes[playerName]
  if current and current.parent == playerFrame then
    return
  end

  self:ReleaseCounter(playerName)

  self:EnsureCounterPool()

  local counter = self.counterPool:Acquire()
  counter:SetParent(UIParent)
  counter:ClearAllPoints()
  counter:SetPoint("CENTER", playerFrame, "CENTER", db.x, db.y)
  counter:SetFrameStrata("HIGH")
  counter:SetFrameLevel(GetSafeFrameLevel(playerFrame, 10))
  counter:SetToplevel(true)
  counter.raidClusterUnit = info.unit
  counter.raidClusterParent = playerFrame
  self:ConfigureCounter(counter, info.class)
  counter:Show()

  self.currentframes[playerName] = {
    frame = counter,
    parent = playerFrame,
    unit = info.unit,
    subGroup = info.subGroup,
    class = info.class,
  }
end

function RaidCluster:GetBestFrameForPlayer(playerName)
  local candidates = self.unitFrameCandidatesByName[playerName]
  if not candidates then
    return nil
  end

  local bestFrame
  local bestPriority
  local bestName
  for frame, priority in pairs(candidates) do
    local frameName = GetFrameName(frame) or ""
    if not bestFrame or priority < bestPriority or (priority == bestPriority and frameName < bestName) then
      bestFrame = frame
      bestPriority = priority
      bestName = frameName
    end
  end

  return bestFrame
end

function RaidCluster:BindBestFrame(info)
  if not info or not info.name then
    return
  end

  local bestFrame = self:GetBestFrameForPlayer(info.name)
  self.unitFramesByName[info.name] = bestFrame

  if self.IsInit then
    if bestFrame then
      self:AttachCounterToFrame(bestFrame, info)
    else
      self:ReleaseCounter(info.name)
    end
  end
end

function RaidCluster:GetGroupState()
  if UnitInRaid("player") then
    return "raid", GetNumRaidMembers() or 0
  end

  local partyMembers = GetNumPartyMembers()
  if partyMembers and partyMembers > 0 then
    return "party", partyMembers + 1
  end

  return nil, 0
end

function RaidCluster:IsGroupEnabled(groupType, classKey)
  local config = classKey and self.classConfigs[classKey]
  if not config then
    return groupType == "raid" or groupType == "party"
  end

  if groupType == "raid" then
    return db[config.enableInRaid]
  elseif groupType == "party" then
    return db[config.enableInParty]
  end

  return false
end

function RaidCluster:AddRosterInfo(unit, playerName, subGroup, playerClass, changes, oldRosterByName)
  if not playerName then
    return
  end

  local info = {
    unit = unit,
    name = playerName,
    subGroup = subGroup,
    class = playerClass,
  }
  self.roster[#self.roster + 1] = info
  self.rosterByUnit[unit] = info
  self.rosterByName[playerName] = info
  self.unitByName[playerName] = unit

  local oldInfo = oldRosterByName[playerName]
  if not oldInfo then
    changes.changed = true
    changes.memberChanged = true
  else
    if oldInfo.unit ~= unit then
      changes.changed = true
      changes.unitChanged = true
    end
    if oldInfo.subGroup ~= subGroup or oldInfo.class ~= playerClass then
      changes.changed = true
      changes.metaChanged = true
    end
  end

  local current = self.currentframes[playerName]
  if current then
    current.unit = unit
    current.subGroup = subGroup
    current.class = playerClass
    self:ConfigureCounter(current.frame, playerClass)
  end
end

function RaidCluster:RefreshRoster(classKey)
  local oldRosterByName = self.rosterByName or {}
  local oldCount = self.roster and #self.roster or 0
  local oldGroupType = self.groupType
  local changes = {
    changed = false,
    groupChanged = false,
    memberChanged = false,
    unitChanged = false,
    metaChanged = false,
  }

  self.roster = {}
  self.rosterByUnit = {}
  self.rosterByName = {}
  self.unitByName = {}

  local groupType, members = self:GetGroupState()
  self.groupType = groupType
  if oldGroupType ~= groupType then
    changes.changed = true
    changes.groupChanged = true
  end

  if not self:IsGroupEnabled(groupType, classKey or self.activeClass) or not members or members < 1 then
    if oldCount > 0 then
      for playerName in pairs(oldRosterByName) do
        self:ReleasePlayerBinding(playerName)
      end
      changes.changed = true
      changes.memberChanged = true
      return 0, changes
    end
    return 0, changes
  end

  if groupType == "raid" then
    for i = 1, members do
      local unit = "raid" .. i
      local playerName, _, subGroup, _, _, playerClass = GetRaidRosterInfo(i)
      if playerName and (not db.subGroup or (subGroup and subGroup <= 5)) then
        self:AddRosterInfo(unit, playerName, subGroup, playerClass, changes, oldRosterByName)
      end
    end
  elseif groupType == "party" then
    local playerName = UnitName("player")
    local _, playerClass = UnitClass("player")
    self:AddRosterInfo("player", playerName, 1, playerClass, changes, oldRosterByName)

    for i = 1, members - 1 do
      local unit = "party" .. i
      if UnitExists(unit) then
        local memberName = UnitName(unit)
        local _, memberClass = UnitClass(unit)
        self:AddRosterInfo(unit, memberName, 1, memberClass, changes, oldRosterByName)
      end
    end
  end

  if oldCount ~= #self.roster then
    changes.changed = true
    changes.memberChanged = true
  end

  for playerName in pairs(oldRosterByName) do
    if not self.rosterByName[playerName] then
      changes.changed = true
      changes.memberChanged = true
      self:ReleasePlayerBinding(playerName)
    end
  end

  return #self.roster, changes
end

function RaidCluster:RefreshCounters()
  self:ReleaseCounters()
  if not self.IsInit then
    return
  end

  self:RefreshRoster(self.activeClass)
  for _, info in ipairs(self.roster) do
    self:BindBestFrame(info)
  end
end

function RaidCluster:GetRosterInfoForLGFUnit(unit)
  if not unit then
    return
  end

  local info = self.rosterByUnit[unit]
  if info then
    return info
  end

  for _, rosterInfo in ipairs(self.roster) do
    if UnitIsUnit(rosterInfo.unit, unit) then
      return rosterInfo
    end
  end
end

function RaidCluster:HandleLGFFrameUnitUpdate(frame, unit)
  if not self.activeClass then
    return
  end

  local info = self:GetRosterInfoForLGFUnit(unit)
  if info then
    local oldPlayerName = self.frameOwnerByFrame[frame]
    if oldPlayerName and oldPlayerName ~= info.name then
      local oldCandidates = self.unitFrameCandidatesByName[oldPlayerName]
      if oldCandidates then
        oldCandidates[frame] = nil
        if not next(oldCandidates) then
          self.unitFrameCandidatesByName[oldPlayerName] = nil
        end
      end

      local oldInfo = self.rosterByName and self.rosterByName[oldPlayerName]
      if oldInfo then
        self:BindBestFrame(oldInfo)
      else
        self:ReleasePlayerBinding(oldPlayerName)
      end
    end

    local candidates = self.unitFrameCandidatesByName[info.name]
    if not candidates then
      candidates = {}
      self.unitFrameCandidatesByName[info.name] = candidates
    end
    candidates[frame] = GetFramePriority(frame)
    self.frameOwnerByFrame[frame] = info.name
    self:BindBestFrame(info)
  end
end

function RaidCluster:HandleLGFFrameUnitRemoved(frame, unit)
  local playerName = self.frameOwnerByFrame[frame]
  local info = playerName and self.rosterByName and self.rosterByName[playerName] or self:GetRosterInfoForLGFUnit(unit)
  if info then
    local candidates = self.unitFrameCandidatesByName[info.name]
    if candidates then
      candidates[frame] = nil
      if not next(candidates) then
        self.unitFrameCandidatesByName[info.name] = nil
      end
    end
    if self.frameOwnerByFrame[frame] == info.name then
      self.frameOwnerByFrame[frame] = nil
    end
    self:BindBestFrame(info)
  else
    self.frameOwnerByFrame[frame] = nil
  end
end

function RaidCluster:HidePlayerText(playerName)
  local frameData = self.currentframes and self.currentframes[playerName]
  local frame = frameData and frameData.frame
  if frame and frame.text then
    frame.text:SetText("")
    frame.text:Hide()
  end
end

function RaidCluster:HideAllCounters()
  for playerName in pairs(self.currentframes) do
    self:HidePlayerText(playerName)
  end
end
