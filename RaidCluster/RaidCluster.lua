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

RaidCluster = LibStub("AceAddon-3.0"):NewAddon(RaidCluster, "RaidCluster", "AceConsole-3.0", "AceTimer-3.0")

RaidCluster.version = AddonName .. " v" .. GetAddOnMetadata(AddonName, "Version")
RaidCluster.IsInit = false
RaidCluster.cleuInit = false
RaidCluster.lgfReady = false
RaidCluster.lgfRequested = false
RaidCluster.lgfPendingStartup = false
RaidCluster.startupReady = false
RaidCluster.currentframes = {}
RaidCluster.roster = {}
RaidCluster.rosterByUnit = {}
RaidCluster.rosterByName = {}
RaidCluster.unitByName = {}
RaidCluster.unitFramesByName = {}
RaidCluster.unitFrameCandidatesByName = {}
RaidCluster.frameOwnerByFrame = {}
RaidCluster.glowTimers = {}
RaidCluster.Range = 0
RaidCluster.activeClass = nil
RaidCluster.rangeMode = nil
RaidCluster.groupType = nil

local CLASS_RANGES = {
  PALADIN = 9.5,
  SHAMAN = 12.5,
  PRIEST = { 16.5, 30 },
  DRUID = 16.5,
}

RaidCluster.classConfigs = {
  PALADIN = {
    class = "PALADIN",
    range = function() return CLASS_RANGES.PALADIN end,
    rangeMode = "players",
    enabled = "paladinEnable",
    enableInRaid = "paladinEnableInRaid",
    enableInParty = "paladinEnableInParty",
    raidEnabled = "paladinRaidFrameEnable",
    glowEnabled = "paladinGlowEnable",
    talent = "paladinTalents",
    spellID = 54968,
    subEvents = { SPELL_HEAL = true },
  },
  SHAMAN = {
    class = "SHAMAN",
    range = function() return CLASS_RANGES.SHAMAN end,
    rangeMode = "chained",
    enabled = "shamanEnable",
    enableInRaid = "shamanEnableInRaid",
    enableInParty = "shamanEnableInParty",
    raidEnabled = "shamanRaidFrameEnable",
    glowEnabled = "shamanGlowEnable",
    talent = "shamanTalents",
    spellID = 55459,
    subEvents = { SPELL_HEAL = true },
  },
  HPRIEST = {
    class = "PRIEST",
    range = function() return CLASS_RANGES.PRIEST[1] end,
    rangeMode = "players",
    enabled = "holyPriestEnable",
    enableInRaid = "holyPriestEnableInRaid",
    enableInParty = "holyPriestEnableInParty",
    raidEnabled = "holyPriestRaidFrameEnable",
    glowEnabled = "holyPriestGlowEnable",
    talent = "holyPriestTalents",
    spellID = 48089,
    subEvents = { SPELL_HEAL = true },
  },
  DPRIEST = {
    class = "PRIEST",
    range = function() return CLASS_RANGES.PRIEST[2] end,
    rangeMode = "group",
    enabled = "discoPriestEnable",
    enableInRaid = "discoPriestEnableInRaid",
    enableInParty = "discoPriestEnableInParty",
    raidEnabled = "discoPriestRaidFrameEnable",
    glowEnabled = "discoPriestGlowEnable",
    talent = "discoPriestTalents",
    spellID = 48072,
    subEvents = { SPELL_HEAL = true },
  },
  DRUID = {
    class = "DRUID",
    range = function() return CLASS_RANGES.DRUID end,
    rangeMode = "players",
    enabled = "druidEnable",
    enableInRaid = "druidEnableInRaid",
    enableInParty = "druidEnableInParty",
    raidEnabled = "druidRaidFrameEnable",
    glowEnabled = "druidGlowEnable",
    talent = "druidTalents",
    spellID = 53251,
    subEvents = { SPELL_AURA_APPLIED = true, SPELL_AURA_REFRESH = true },
  },
}
