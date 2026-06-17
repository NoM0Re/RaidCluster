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

local UnitIsConnected = UnitIsConnected
local UnitExists = UnitExists
local UnitIsVisible = UnitIsVisible
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local GetPlayerMapPosition = GetPlayerMapPosition
local CreateFrame = CreateFrame

function RaidCluster:IsPositionValid(x, y)
  return x and y and not (x == 0 and y == 0)
end

function RaidCluster:CanCalculateRanges()
  return self.mapReady and self.mapX and self.mapY and self.mapX > 1 and self.mapY > 1
end

function RaidCluster:EnsureRangeWorker()
  if self.rangeWorker then
    return
  end

  self.rangeWorker = CreateFrame("Frame")
  self.rangeWorker:Hide()
  self.rangeWorker:SetScript("OnUpdate", function()
    RaidCluster:ProcessRangeJob()
  end)
end

function RaidCluster:CreateRangeJob(mode, lowHealthOnly)
  local roster = {}
  for i, info in ipairs(self.roster) do
    roster[i] = info
  end

  return {
    mode = mode,
    lowHealthOnly = lowHealthOnly,
    phase = "positions",
    roster = roster,
    rosterIndex = 1,
    positionList = {},
    results = {},
    membership = {},
    sourceIndex = 1,
    targetIndex = 1,
    chainSourceIndex = 1,
    chainNeighborIndex = 1,
    chainNeighbor2Index = 1,
  }
end

function RaidCluster:StartRangeJob(mode, lowHealthOnly)
  if self.rangeJob then
    return
  end

  if not self:CanCalculateRanges() then
    self:HideAllCounters()
    return
  end

  self:EnsureRangeWorker()
  self.rangeJob = self:CreateRangeJob(mode, lowHealthOnly)
  self.rangeWorker:Show()
end

function RaidCluster:ProcessRangePositions(job, budget)
  local processed = 0
  while processed < budget and job.rosterIndex <= #job.roster do
    local info = job.roster[job.rosterIndex]
    local unit = info.unit
    local playerName = info.name

    if UnitExists(unit)
        and UnitIsConnected(unit)
        and UnitIsVisible(unit)
        and not UnitIsDeadOrGhost(unit)
        and (not job.lowHealthOnly or UnitHealth(unit) < UnitHealthMax(unit)) then
      local x, y = GetPlayerMapPosition(unit)
      if self:IsPositionValid(x, y) then
        job.positionList[#job.positionList + 1] = {
          name = playerName,
          x = x,
          y = y,
          subGroup = info.subGroup,
        }
      else
        self:HidePlayerText(playerName)
      end
    else
      self:HidePlayerText(playerName)
    end

    job.rosterIndex = job.rosterIndex + 1
    processed = processed + 12
  end

  if job.rosterIndex > #job.roster then
    job.phase = "ranges"
  end
end

function RaidCluster:ProcessRangePairs(job, budget)
  local processed = 0
  local positions = job.positionList
  local positionCount = #positions

  if positionCount == 0 then
    job.phase = "done"
    return
  end

  while processed < budget and job.sourceIndex <= positionCount do
    local source = positions[job.sourceIndex]
    local target = positions[job.targetIndex]

    if source and target then
      if job.mode == "chained" then
        local result = job.results[source.name]
        if not result then
          result = {}
          job.results[source.name] = result
          job.membership[source.name] = {}
        end

        if self:GetUnitRange(source.x, source.y, target.x, target.y) <= self.Range then
          result[#result + 1] = target.name
          job.membership[source.name][target.name] = true
        end
      elseif job.mode == "group" then
        if source.subGroup == target.subGroup
            and self:GetUnitRange(source.x, source.y, target.x, target.y) <= self.Range then
          job.results[source.name] = (job.results[source.name] or 0) + 1
        else
          job.results[source.name] = job.results[source.name] or 0
        end
      else
        if source.name ~= target.name
            and self:GetUnitRange(source.x, source.y, target.x, target.y) <= self.Range then
          job.results[source.name] = (job.results[source.name] or 0) + 1
        else
          job.results[source.name] = job.results[source.name] or 0
        end
      end
    end

    job.targetIndex = job.targetIndex + 1
    if job.targetIndex > positionCount then
      job.targetIndex = 1
      job.sourceIndex = job.sourceIndex + 1
    end

    processed = processed + 1
  end

  if job.sourceIndex > positionCount then
    job.phase = job.mode == "chained" and "chain" or "done"
  end
end

function RaidCluster:ProcessChainClosure(job, budget)
  local processed = 0
  local positions = job.positionList

  while processed < budget and job.chainSourceIndex <= #positions do
    local source = positions[job.chainSourceIndex]
    local sourceList = job.results[source.name] or {}
    local sourceSet = job.membership[source.name] or {}
    local neighborName = sourceList[job.chainNeighborIndex]
    local neighborList = neighborName and job.results[neighborName] or nil
    local chainedName = neighborList and neighborList[job.chainNeighbor2Index] or nil

    if chainedName then
      if chainedName ~= source.name and not sourceSet[chainedName] then
        sourceList[#sourceList + 1] = chainedName
        sourceSet[chainedName] = true
      end
      job.chainNeighbor2Index = job.chainNeighbor2Index + 1
    else
      job.chainNeighbor2Index = 1
      job.chainNeighborIndex = job.chainNeighborIndex + 1
      if job.chainNeighborIndex > #sourceList then
        job.chainNeighborIndex = 1
        job.chainSourceIndex = job.chainSourceIndex + 1
      end
    end

    processed = processed + 1
  end

  if job.chainSourceIndex > #positions then
    job.phase = "done"
  end
end

function RaidCluster:FinishRangeJob(job)
  self.rangeJob = nil
  if self.rangeWorker then
    self.rangeWorker:Hide()
  end

  if job.mode == "chained" then
    self:UpdateFrames(job.results, true)
  else
    self:UpdateFrames(job.results, false)
  end
end

function RaidCluster:ProcessRangeJob()
  local job = self.rangeJob
  if not job or not self.IsInit then
    self.rangeJob = nil
    if self.rangeWorker then
      self.rangeWorker:Hide()
    end
    return
  end

  local budget = db.rangeChecksPerFrame or 220
  if job.phase == "positions" then
    self:ProcessRangePositions(job, budget)
  elseif job.phase == "ranges" then
    self:ProcessRangePairs(job, budget)
  elseif job.phase == "chain" then
    self:ProcessChainClosure(job, budget)
  end

  if job.phase == "done" then
    self:FinishRangeJob(job)
  end
end

function RaidCluster:UpdateFrames(results, chained)
  if next(self.currentframes) == nil then
    return
  end

  for playerName, frameData in pairs(self.currentframes) do
    local result = results[playerName]
    local frame = frameData.frame
    local parent = frameData.parent

    if result and parent and parent:IsShown() then
      frame:ClearAllPoints()
      frame:SetPoint("CENTER", parent, "CENTER", db.x, db.y)
      frame.text:SetText(chained and tostring(#result - 1) or tostring(result))
      frame.text:Show()
      frame:Show()
    else
      self:HidePlayerText(playerName)
    end
  end
end

function RaidCluster:CalculatePlayersToPlayers()
  self:StartRangeJob("players", false)
end

function RaidCluster:CalculateChainedPlayers()
  self:StartRangeJob("chained", true)
end

function RaidCluster:CalculateGroupPlayersToGroupPlayers()
  self:StartRangeJob("group", false)
end

function RaidCluster:OnFPSrefresh()
  if not self.IsInit then
    return
  end

  if self.rangeMode == "chained" then
    self:CalculateChainedPlayers()
  elseif self.rangeMode == "group" then
    self:CalculateGroupPlayersToGroupPlayers()
  else
    self:CalculatePlayersToPlayers()
  end
end
