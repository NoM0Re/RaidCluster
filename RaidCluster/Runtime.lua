-- *********************************************************
-- **                     RaidCluster                     **
-- **        https://github.com/NoM0Re/RaidCluster        **
-- *********************************************************

local RaidCluster = select(2, ...)
local L = RaidCluster.L

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

local LGF = LibStub("LibGetFrame-1.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ADB = LibStub("AceDB-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local LibDualSpec = LibStub("LibDualSpec-1.0")

local UnitName = UnitName
local UnitClass = UnitClass
local GetZoneText = GetZoneText
local CreateFrame = CreateFrame

function RaidCluster:StopAddon()
  self.IsInit = false
  self.activeClass = nil
  self.rangeMode = nil
  self.lgfReady = false
  self.lgfRequested = false
  self.lgfPendingStartup = false
  self:ResetFrameBindings()
  self:CancelRangeJob()
  if self.FPSTimer then
    self:CancelTimer(self.FPSTimer, true)
    self.FPSTimer = nil
  end
  if self.startupTimer then
    self:CancelTimer(self.startupTimer, true)
    self.startupTimer = nil
  end
  if self.frameRefreshTimer then
    self:CancelTimer(self.frameRefreshTimer, true)
    self.frameRefreshTimer = nil
  end
  for frame, timer in pairs(self.glowTimers) do
    self:CancelTimer(timer, true)
    self:StopGlow(frame)
    self.glowTimers[frame] = nil
  end
  self:StopCLEU()
  self:ReleaseCounters()
end

function RaidCluster:DisableAddon()
  self:StopAddon()
  if self.startupFrame then
    self.startupFrame:Hide()
    self.startupFrame:SetScript("OnUpdate", nil)
  end
  if self.EventHandler then
    self.EventHandler:UnregisterAllEvents()
  end
end

function RaidCluster:EnableAddon()
  self.EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
  self.EventHandler:RegisterEvent("RAID_ROSTER_UPDATE")
  self.EventHandler:RegisterEvent("PARTY_MEMBERS_CHANGED")
  self.EventHandler:RegisterEvent("PLAYER_TALENT_UPDATE")
  self.EventHandler:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  self.EventHandler:RegisterEvent("ZONE_CHANGED_INDOORS")

  self:StartWhenZoneIsReady()
end

function RaidCluster:StartAddon(classKey)
  local config = RaidCluster.classConfigs[classKey]
  if not config then
    return
  end

  self.IsInit = true
  self.activeClass = classKey
  self.rangeMode = config.rangeMode
  self.Range = config.range()
  self:RefreshCounters()

  if self.FPSTimer then
    self:CancelTimer(self.FPSTimer, true)
  end
  self.FPSTimer = self:ScheduleRepeatingTimer("OnFPSrefresh", db.update or 0.6)
end

function RaidCluster:GetWantedClass()
  local _, playerClass = UnitClass("player")
  if playerClass == "PRIEST" then
    if self:FindTalentPosition(playerClass, db.holyPriestTalents) then
      return "HPRIEST"
    end
    if self:FindTalentPosition(playerClass, db.discoPriestTalents) then
      return "DPRIEST"
    end
    return nil
  end

  local config = RaidCluster.classConfigs[playerClass]
  if config and self:FindTalentPosition(playerClass, db[config.talent]) then
    return playerClass
  end
end

function RaidCluster:IsBasicStartupReady()
  if not self.startupReady then
    if GetZoneText() ~= "" then
      self.startupReady = true
    else
      return false
    end
  end

  if not db.enabled then
    return false
  end

  self.playerName = UnitName("player")

  local groupType, members = self:GetGroupState()
  if not groupType or not members or members < 1 then
    return false
  end

  return true
end

function RaidCluster:RequestLGFScan()
  if self.lgfRequested then
    return
  end

  self.lgfRequested = true
  self.lgfReady = false
  LGF.ScanForUnitFrames()
end

function RaidCluster:specDetection()
  if not db.enabled then
    self:StopAddon()
    return
  end

  if not self:IsBasicStartupReady() then
    self:StopAddon()
    self:QueueStartup(1)
    return
  end

  local classKey = self:GetWantedClass()
  local config = classKey and RaidCluster.classConfigs[classKey]
  if not config then
    self:StopAddon()
    return
  end

  local groupType = self:GetGroupState()
  if not db[config.enabled] or not self:IsGroupEnabled(groupType, classKey) then
    self:StopAddon()
    return
  end

  local raidFrameEnabled = db[config.raidEnabled]
  local glowEnabled = db[config.glowEnabled]
  if not raidFrameEnabled and not glowEnabled then
    self:StopAddon()
    return
  end

  if not self.lgfReady then
    self.lgfPendingStartup = true
    self:RequestLGFScan()
    return
  end

  self.lgfPendingStartup = false
  self:RefreshRoster(classKey)

  if glowEnabled then
    self:StartCLEU(classKey)
  else
    self:StopCLEU()
  end

  if raidFrameEnabled then
    if not self.IsInit or self.activeClass ~= classKey then
      self:StartAddon(classKey)
    else
      self:RefreshRoster(classKey)
    end
  elseif self.IsInit then
    self:ReleaseCounters()
    self.IsInit = false
  end
end

function RaidCluster:QueueStartup(delay)
  if not db.enabled then
    return
  end

  if self.startupTimer then
    self:CancelTimer(self.startupTimer, true)
  end
  self.startupTimer = self:ScheduleTimer("specDetection", delay or 0.5)
end

function RaidCluster:OnProfileChanged()
  self:Modernize(self.db.profile)
  self:FixProfileDefaults(self.db.profile, self.defaults.profile)
  db = self.db.profile
  self:UpdateDB()
  self:StopAddon()
  self:ChangeAppearance()
  self:QueueStartup(0.2)
end

function RaidCluster:StartWhenZoneIsReady()
  if self.startupReady then
    self:QueueStartup(0.1)
    return
  end

  if self.startupFrame then
    self.startupFrame:Hide()
    self.startupFrame:SetScript("OnUpdate", nil)
  else
    self.startupFrame = CreateFrame("Frame")
  end

  local elapsed = 0
  self.startupFrame:SetScript("OnUpdate", function(frame, elaps)
    elapsed = elapsed + elaps

    if GetZoneText() ~= "" or elapsed > 30 then
      frame:SetScript("OnUpdate", nil)
      frame:Hide()
      RaidCluster.startupReady = true
      RaidCluster:QueueStartup(0.1)
    end
  end)
  self.startupFrame:Show()
end

local function EventHandler(_, event)
  if event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" then
    RaidCluster:CancelRangeJob()
    local _, rosterChanges = RaidCluster:RefreshRoster()
    if rosterChanges.groupChanged or rosterChanges.memberChanged or rosterChanges.unitChanged then
      RaidCluster.lgfReady = false
      RaidCluster.lgfRequested = false
      RaidCluster.lgfPendingStartup = false
      RaidCluster:ResetFrameBindings()
    end
    RaidCluster:QueueStartup(0.2)
  elseif event == "PLAYER_TALENT_UPDATE" then
    RaidCluster:StopAddon()
    RaidCluster:QueueStartup(0.2)
  elseif event == "PLAYER_ENTERING_WORLD" then
    RaidCluster:StartWhenZoneIsReady()
  elseif event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED_INDOORS" then
    RaidCluster:CancelRangeJob()
    RaidCluster:HideAllCounters()
    RaidCluster.lgfReady = false
    RaidCluster.lgfRequested = false
    RaidCluster.lgfPendingStartup = false
    RaidCluster:ResetFrameBindings()
    RaidCluster:QueueStartup(0.2)
  end
end

local function LGFCallback(event, frame, unit, previousUnit)
  if event == "GETFRAME_REFRESH" then
    RaidCluster.lgfReady = true
    RaidCluster.lgfRequested = false
    if RaidCluster.lgfPendingStartup then
      RaidCluster:specDetection()
    else
      RaidCluster:RefreshRoster()
    end
  elseif event == "FRAME_UNIT_ADDED" or event == "FRAME_UNIT_UPDATE" then
    if RaidCluster.lgfReady then
      if previousUnit then
        RaidCluster:HandleLGFFrameUnitRemoved(frame, previousUnit)
      end
      RaidCluster:HandleLGFFrameUnitUpdate(frame, unit)
    end
  elseif event == "FRAME_UNIT_REMOVED" then
    if RaidCluster.lgfReady then
      RaidCluster:HandleLGFFrameUnitRemoved(frame, unit)
    end
  end
end

function RaidCluster:OnInitialize()
  self.db = ADB:New("RaidCluster_DB", self.defaults, true)

  self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
  self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
  self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
  LibDualSpec:EnhanceDatabase(self.db, "RaidCluster")

  AC:RegisterOptionsTable("RaidCluster", self.options)
  ACR:RegisterOptionsTable("RaidCluster_Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
  LibDualSpec:EnhanceOptions(LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db), self.db)

  ACD:AddToBlizOptions("RaidCluster")
  ACD:AddToBlizOptions("RaidCluster_Profiles", L["Profiles"], "RaidCluster")
  self:HookOptionsPreview(ACD)

  self:RegisterChatCommand("rac", "SlashCommand")
  self:RegisterChatCommand("raidcluster", "SlashCommand")

  db = self.db.profile
  self:Modernize(db)
  self:FixProfileDefaults(db, self.defaults.profile)
  self:UpdateDB()

  self.EventHandler = CreateFrame("Frame")
  self.EventHandler:SetScript("OnEvent", EventHandler)
  self.CLEU = CreateFrame("Frame")

  LGF.RegisterCallback("RaidCluster", "GETFRAME_REFRESH", LGFCallback)
  LGF.RegisterCallback("RaidCluster", "FRAME_UNIT_ADDED", LGFCallback)
  LGF.RegisterCallback("RaidCluster", "FRAME_UNIT_UPDATE", LGFCallback)
  LGF.RegisterCallback("RaidCluster", "FRAME_UNIT_REMOVED", LGFCallback)
end

function RaidCluster:OnEnable()
  if db.enabled then
    self:EnableAddon()
  end
end

function RaidCluster:OnDisable()
  self:DisableAddon()
end

function RaidCluster:SlashCommand()
  InterfaceOptionsFrame_OpenToCategory("RaidCluster")
end
