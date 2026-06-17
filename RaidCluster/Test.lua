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
})

local CreateFrame = CreateFrame
local _G = _G
local math_floor = math.floor
local math_random = math.random
local UIParent = UIParent
local UnitClass = UnitClass
local UnitName = UnitName

local TEST_FRAME_NAMES = {
  "NoM0Re",
  "Crum",
  "Zidras",
  "Fanq",
  "Empress",
  "Widget",
  "noname",
  "Merfin",
}

local TEST_CLASS_COLORS = {
  { r = 0.96, g = 0.55, b = 0.73 }, -- Paladin
  { r = 1.00, g = 1.00, b = 1.00 }, -- Priest
  { r = 0.00, g = 0.44, b = 0.87 }, -- Shaman
  { r = 1.00, g = 0.49, b = 0.04 }, -- Druid
}

local MAX_FRAME_LEVEL = 120
local TEST_GLOW_INTERVAL = 4
local TEST_FRAME_WIDTH = 84
local TEST_FRAME_HEIGHT = 51
local TEST_HEALTH_HEIGHT = 45
local TEST_MANA_HEIGHT = 4

local function GetEffectiveScale()
  local scale = UIParent and UIParent.GetEffectiveScale and UIParent:GetEffectiveScale() or 1
  if not scale or scale <= 0 then
    scale = 1
  end
  return scale
end

local function Snap(value)
  local scale = GetEffectiveScale()
  return math_floor(value * scale + 0.5) / scale
end

local function GetSafeFrameLevel(frame, offset)
  local level = (frame and frame:GetFrameLevel() or 0) + (offset or 0)
  if level > MAX_FRAME_LEVEL then
    return MAX_FRAME_LEVEL
  end
  return level
end

local function GetCounterUpdateFrequency()
  local profile = RaidCluster.db and RaidCluster.db.profile
  return profile and profile.update or 0.6
end

local function GetTestGlowDuration()
  local profile = RaidCluster.db and RaidCluster.db.profile
  if profile and profile.glowType == "Proc Glow" then
    return profile.procGlowDuration or 1
  end
  return 1
end

local function PositionTestFrame(frame)
  local interfaceOptionsFrame = _G.InterfaceOptionsFrame
  frame:ClearAllPoints()
  if interfaceOptionsFrame and interfaceOptionsFrame:IsShown() then
    frame:SetPoint("TOPLEFT", interfaceOptionsFrame, "TOPRIGHT", Snap(12), -Snap(80))
  else
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, Snap(120))
  end
end

local function CreateStatusBar(parent, height, color, bgColor)
  local bar = CreateFrame("StatusBar", nil, parent)
  bar:SetHeight(height)
  bar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
  bar:SetStatusBarColor(color.r, color.g, color.b)
  bar:SetMinMaxValues(0, 100)

  bar.bg = bar:CreateTexture(nil, "BACKGROUND")
  bar.bg:SetAllPoints(bar)
  bar.bg:SetTexture("Interface\\Buttons\\WHITE8x8")
  bar.bg:SetVertexColor(bgColor.r, bgColor.g, bgColor.b, 1)

  return bar
end

local function ApplyTestFramePixelLayout(frame, force)
  local scale = GetEffectiveScale()
  if not force and frame.raidClusterTestScale == scale then
    return
  end

  local pixel = 1
  frame.raidClusterTestScale = scale

  frame:SetSize(Snap(TEST_FRAME_WIDTH), Snap(TEST_FRAME_HEIGHT))
  frame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = true,
    tileSize = Snap(16),
    edgeSize = pixel,
    insets = { left = pixel, right = pixel, top = pixel, bottom = pixel },
  })
  frame:SetBackdropColor(0.05, 0.44, 0.14, 1)
  frame:SetBackdropBorderColor(0, 0, 0, 1)

  if frame.health then
    frame.health:SetHeight(Snap(TEST_HEALTH_HEIGHT))
    frame.health:ClearAllPoints()
    frame.health:SetPoint("TOPLEFT", frame, "TOPLEFT", pixel, -pixel)
    frame.health:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -pixel, -pixel)
  end

  if frame.name then
    frame.name:ClearAllPoints()
    frame.name:SetPoint("TOPLEFT", frame.health, "TOPLEFT", Snap(3), -Snap(4))
  end

  if frame.mana then
    frame.mana:SetHeight(Snap(TEST_MANA_HEIGHT))
    frame.mana:ClearAllPoints()
    frame.mana:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", pixel, pixel)
    frame.mana:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -pixel, pixel)
  end
end

local function CreateTestFrame()
  local frame = CreateFrame("Frame", "RaidClusterTestUnitFrame", UIParent)
  frame:SetSize(Snap(TEST_FRAME_WIDTH), Snap(TEST_FRAME_HEIGHT))
  PositionTestFrame(frame)
  if frame.SetClampedToScreen then
    frame:SetClampedToScreen(true)
  end
  frame:SetFrameStrata("MEDIUM")
  frame:SetFrameLevel(20)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", function(self)
    self:StartMoving()
  end)
  frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
  end)
  frame:SetScript("OnMouseUp", function(_, button)
    if button == "RightButton" then
      RaidCluster:HideTestFrame()
    end
  end)
  ApplyTestFramePixelLayout(frame, true)

  frame.health = CreateStatusBar(frame, Snap(TEST_HEALTH_HEIGHT), { r = 0.05, g = 0.48, b = 0.14 }, { r = 0.03, g = 0.31, b = 0.08 })
  frame.health:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
  frame.health:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
  frame.health:SetValue(100)

  frame.name = frame.health:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.name:SetPoint("TOPLEFT", frame.health, "TOPLEFT", Snap(3), -Snap(4))
  frame.name:SetJustifyH("LEFT")
  frame.name:SetFontObject(GameFontNormal)
  local nameFont, _, nameFlags = frame.name:GetFont()
  frame.name:SetFont(nameFont, 12, nameFlags)
  frame.name:SetText("Kalura")

  frame.mana = CreateStatusBar(frame, Snap(TEST_MANA_HEIGHT), { r = 0.08, g = 0.36, b = 1 }, { r = 0.01, g = 0.04, b = 0.18 })
  frame.mana:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 1)
  frame.mana:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -1, 1)
  frame.mana:SetValue(66)

  ApplyTestFramePixelLayout(frame, true)

  frame.manaElapsed = 0
  frame.manaValue = 66
  frame.counterElapsed = 0.25
  frame.counterValue = 5
  frame:SetScript("OnUpdate", function(self, elapsed)
    self.manaElapsed = self.manaElapsed + elapsed
    if self.manaElapsed >= 1 then
      self.manaElapsed = 0
      self.manaValue = self.manaValue - 7
      if self.manaValue < 10 then
        self.manaValue = 96
      end
      self.mana:SetValue(self.manaValue)
    end

    self.counterElapsed = self.counterElapsed + elapsed
    if self.counterElapsed >= GetCounterUpdateFrequency() then
      self.counterElapsed = 0
      self.counterValue = math_random(1, 25)
      if RaidCluster.testCounter then
        RaidCluster.testCounter.text:SetText(self.counterValue)
      end
    end
  end)

  frame:Hide()
  return frame
end

function RaidCluster:GetTestFrame(keepIdentity)
  if not self.testFrame then
    self.testFrame = CreateTestFrame()
  end

  ApplyTestFramePixelLayout(self.testFrame)
  PositionTestFrame(self.testFrame)

  if not keepIdentity then
    local playerName = UnitName("player")
    local nameCount = #TEST_FRAME_NAMES
    local nameIndex = math_random(1, nameCount + (playerName and 1 or 0))
    if nameIndex == nameCount + 1 then
      self.testFrame.name:SetText(playerName)
    else
      self.testFrame.name:SetText(TEST_FRAME_NAMES[nameIndex])
    end
    local color = TEST_CLASS_COLORS[math_random(1, #TEST_CLASS_COLORS)]
    self.testFrame.name:SetTextColor(color.r, color.g, color.b, 1)
  end

  self.testFrame:Show()
  return self.testFrame
end

function RaidCluster:ShowTestPreview(keepIdentity, passive)
  local frame = self:GetTestFrame(keepIdentity)
  local _, playerClass = UnitClass("player")
  frame:EnableMouse(not passive)

  if not self.testCounter then
    self:EnsureCounterPool()
    self.testCounter = self.counterPool:Acquire()
  end

  self.testCounter:SetParent(frame)
  self.testCounter:ClearAllPoints()
  self.testCounter:SetPoint("CENTER", frame, "CENTER", db.x, db.y)
  self.testCounter:SetFrameStrata(frame:GetFrameStrata())
  self.testCounter:SetFrameLevel(GetSafeFrameLevel(frame, 10))
  self:ConfigureCounter(self.testCounter, playerClass or "PRIEST")
  self.testCounter.text:SetText(frame.counterValue)
  self.testCounter.text:Show()
  self.testCounter:Show()
  self:StartTestGlowLoop(frame)
end

function RaidCluster:ShowTestCounter()
  self:ShowTestPreview()
end

function RaidCluster:ShowTestGlow()
  self:ShowTestPreview()
end

function RaidCluster:RefreshTestPreview()
  if self.testFrame and self.testFrame:IsShown() then
    self:ShowTestPreview(true, true)
  end
end

function RaidCluster:StopTestGlowLoop()
  if self.testGlowTimer then
    self:CancelTimer(self.testGlowTimer, true)
    self.testGlowTimer = nil
  end

  if self.testFrame then
    if self.glowTimers and self.glowTimers[self.testFrame] then
      self:CancelTimer(self.glowTimers[self.testFrame], true)
      self.glowTimers[self.testFrame] = nil
    end
    self:StopGlow(self.testFrame)
  end
end

function RaidCluster:StartTestGlowLoop(frame)
  if not frame then
    return
  end

  if self.testGlowTimer then
    return
  end

  local function Pulse()
    if not RaidCluster.testFrame or not RaidCluster.testFrame:IsShown() then
      RaidCluster:StopTestGlowLoop()
      return
    end

    local duration = GetTestGlowDuration()
    RaidCluster:StartGlow(frame)
    RaidCluster.testGlowTimer = RaidCluster:ScheduleTimer(function()
      RaidCluster.testGlowTimer = nil
      RaidCluster:StartTestGlowLoop(frame)
    end, duration + TEST_GLOW_INTERVAL)
  end

  Pulse()
end

function RaidCluster:IsOptionsPreviewSelected()
  local group = self.optionsPreviewGroup
  if not group or not group.frame or not group.frame:IsShown() then
    return false
  end

  local container = _G.InterfaceOptionsFramePanelContainer
  local displayedPanel = container and (container.displayedPanel or container.currentPanel)
  if displayedPanel and displayedPanel ~= group.frame then
    return false
  end

  return true
end

function RaidCluster:UpdateOptionsPreviewVisibility()
  if self:IsOptionsPreviewSelected() then
    if not self.testFrame or not self.testFrame:IsShown() then
      self:ShowTestPreview(nil, true)
    else
      self:ShowTestPreview(true, true)
    end
  else
    self:HideTestFrame()
  end
end

function RaidCluster:HookOptionsPreview(ACD)
  if not ACD or self.optionsPreviewHooked then
    return
  end

  local group = ACD.BlizOptions
    and ACD.BlizOptions.RaidCluster
    and ACD.BlizOptions.RaidCluster.RaidCluster
  if not group or not group.events then
    return
  end

  self.optionsPreviewHooked = true
  self.optionsPreviewGroup = group

  local onShow = group.events.OnShow
  local onHide = group.events.OnHide

  group:SetCallback("OnShow", function(widget, event, ...)
    if onShow then
      onShow(widget, event, ...)
    end
    RaidCluster:UpdateOptionsPreviewVisibility()
  end)

  group:SetCallback("OnHide", function(widget, event, ...)
    if onHide then
      onHide(widget, event, ...)
    end
    RaidCluster:HideTestFrame()
  end)

  local frame = _G.InterfaceOptionsFrame
  if frame and not self.optionsPreviewFrameHooked then
    self.optionsPreviewFrameHooked = true
    frame:HookScript("OnUpdate", function()
      RaidCluster:UpdateOptionsPreviewVisibility()
    end)
    frame:HookScript("OnHide", function()
      RaidCluster:HideTestFrame()
    end)
  end
end

function RaidCluster:HideTestFrame()
  self:StopTestGlowLoop()

  if self.testCounter then
    if self.counterPool then
      self.counterPool:Release(self.testCounter)
    else
      self.testCounter:Hide()
    end
    self.testCounter = nil
  end

  if self.testFrame then
    self.testFrame:Hide()
  end
end
