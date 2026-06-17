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

local LGF = LibStub("LibGetFrame-1.0")
local LCG = LibStub("LibCustomGlow-1.0")
local MAX_FRAME_LEVEL = 120

local function GetSafeGlowOffset(frame, offset)
  local level = frame and frame:GetFrameLevel() or 0
  local maxOffset = MAX_FRAME_LEVEL - level
  if maxOffset < 0 then
    return 0
  end
  if offset > maxOffset then
    return maxOffset
  end
  return offset
end

function RaidCluster:ChangeAppearance()
  for _, data in pairs(self.currentframes) do
    if data.frame and data.frame.text then
      self:ConfigureCounter(data.frame, data.class)
      if data.parent then
        data.frame:ClearAllPoints()
        data.frame:SetPoint("CENTER", data.parent, "CENTER", db.x, db.y)
      end
    end
  end

  self:RefreshTestPreview()
end

function RaidCluster:GetGlowColor()
  return { db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a }
end

function RaidCluster:StopGlow(frame)
  if not frame then
    return
  end

  if LCG.ProcGlow_Stop then
    LCG.ProcGlow_Stop(frame, "RaidCluster")
  end
  if LCG.AutoCastGlow_Stop then
    LCG.AutoCastGlow_Stop(frame, "RaidCluster")
  end
  if LCG.ButtonGlow_Stop then
    LCG.ButtonGlow_Stop(frame)
  end
  if LCG.PixelGlow_Stop then
    LCG.PixelGlow_Stop(frame, "RaidCluster")
  end
end

function RaidCluster:StartGlow(frame, duration, options)
  if not frame then
    return
  end

  options = options or {}

  if self.glowTimers[frame] then
    self:CancelTimer(self.glowTimers[frame], true)
    self.glowTimers[frame] = nil
  end

  self:StopGlow(frame)

  local color = options.color or self:GetGlowColor()
  local glowType = options.glowType or db.glowType or "Pixel Glow"
  local persistent = duration and duration <= 0
  local frameLevelOffset = GetSafeGlowOffset(frame, options.frameLevelOffset or 8)
  local lines = options.lines or db.lines
  local frequency = options.frequency or db.frequency
  local length = options.length or db.length
  local thickness = options.thickness or db.thickness
  local xOffset = options.xOffset ~= nil and options.xOffset or db.xOffset
  local yOffset = options.yOffset ~= nil and options.yOffset or db.yOffset
  local border = options.border ~= nil and options.border or db.border
  if glowType == "Proc Glow" and LCG.ProcGlow_Start then
    LCG.ProcGlow_Start(frame, {
      color = color,
      key = "RaidCluster",
      xOffset = xOffset,
      yOffset = yOffset,
      duration = persistent and 86400 or (options.procGlowDuration or db.procGlowDuration),
      startAnim = options.procGlowStartAnim ~= nil and options.procGlowStartAnim or db.procGlowStartAnim,
      frameLevel = frameLevelOffset,
    })
  elseif glowType == "Autocast Shine" and LCG.AutoCastGlow_Start then
    LCG.AutoCastGlow_Start(frame, color, lines, frequency, options.glowScale or db.glowScale,
      xOffset, yOffset, "RaidCluster", frameLevelOffset)
  elseif glowType == "Action Button Glow" and LCG.ButtonGlow_Start then
    LCG.ButtonGlow_Start(frame, color, frequency, frameLevelOffset)
  else
    LCG.PixelGlow_Start(frame, color, lines, frequency, length, thickness,
      xOffset, yOffset, border, "RaidCluster", frameLevelOffset)
  end

  if persistent then
    return
  end

  self.glowTimers[frame] = self:ScheduleTimer(function()
    RaidCluster:StopGlow(frame)
    RaidCluster.glowTimers[frame] = nil
  end, duration or 1)
end

function RaidCluster:GetUnitForCombatLogName(name)
  return self.unitByName[name] or name
end

function RaidCluster:HandleCombatLog(...)
  local _, subEvent, _, sourceName, _, _, destName, _, spellID = ...
  local config = self.activeClass and RaidCluster.classConfigs[self.activeClass]
  if not config
      or not config.subEvents[subEvent]
      or sourceName ~= self.playerName
      or spellID ~= config.spellID
      or not destName then
    return
  end

  local frame = self.unitFramesByName[destName] or LGF.GetUnitFrame(self:GetUnitForCombatLogName(destName))
  if frame then
    self:StartGlow(frame)
  end
end

function RaidCluster:StartCLEU(classKey)
  if self.cleuInit and self.activeClass == classKey then
    return
  end

  self.cleuInit = true
  self.activeClass = classKey
  self.CLEU:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self.CLEU:SetScript("OnEvent", function(_, _, ...)
    RaidCluster:HandleCombatLog(...)
  end)
end

function RaidCluster:StopCLEU()
  if self.CLEU then
    self.CLEU:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.CLEU:SetScript("OnEvent", nil)
  end
  self.cleuInit = false
end
