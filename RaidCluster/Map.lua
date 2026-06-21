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

-- This file contains MapSizes and registers them into a table, also Helper Functions.

local RaidCluster = select(2, ...)

-- Libs
local MapSizes = LibStub("LibMapData-1.0");

local GetMapInfo = GetMapInfo
local GetCurrentMapDungeonLevel = GetCurrentMapDungeonLevel

-- Variables
RaidCluster.mapX, RaidCluster.mapY = 1, 1
RaidCluster.mapReady = false

-- Callback Function
local function SetMap(_, _, _, x, y)
  x = (x == nil or x == 0) and 1 or x
  y = (y == nil or y == 0) and 1 or y
  RaidCluster.mapX, RaidCluster.mapY = x, y
  RaidCluster.mapReady = x > 1 and y > 1
  if RaidCluster.QueueStartup then
    RaidCluster:QueueStartup(0.2)
  end
end

-- Map Callback
MapSizes:RegisterCallback("MapChanged", SetMap)

function RaidCluster:RefreshCurrentMapData()
  local map = GetMapInfo and GetMapInfo()
  if not map then
    return false
  end

  local floor = GetCurrentMapDungeonLevel and GetCurrentMapDungeonLevel() or nil
  local x, y = MapSizes:MapArea(map, floor)
  if (not x or x <= 1 or not y or y <= 1) and floor and floor > 0 then
    x, y = MapSizes:MapArea(map)
  end

  if x and x > 1 and y and y > 1 then
    self.mapX, self.mapY = x, y
    self.mapReady = true
    return true
  end

  return false
end

-- Calculates ranges for 2 Units for the given coordinates
function RaidCluster:GetUnitRange(x1, y1, x2, y2)
  local rangeX, rangeY = (x2 - x1) * self.mapX, (y2 - y1) * self.mapY
  local range = (rangeX * rangeX + rangeY * rangeY) ^ 0.5
  return range
end
