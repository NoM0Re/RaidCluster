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

local AddonName = ...
local RaidCluster = select(2, ...)

-- Libs
local MapSizes = LibStub("LibMapData-1.0");

-- Variables
RaidCluster.mapX, RaidCluster.mapY = 1, 1

-- Callback Function
local function SetMap(_, _, _, x, y)
  x = (x == nil or x == 0) and 1 or x
  y = (y == nil or y == 0) and 1 or y
  RaidCluster.mapX, RaidCluster.mapY = x, y
  print(x, y)
end

-- Map Callback
MapSizes:RegisterCallback("MapChanged", SetMap)

-- Calculates ranges for 2 Units for the given coordinates
function RaidCluster:GetUnitRange(x1, y1, x2, y2)
  local rangeX, rangeY = (x2 - x1) * self.mapX, (y2 - y1) * self.mapY
  local range = (rangeX * rangeX + rangeY * rangeY) ^ 0.5
  return range
end
