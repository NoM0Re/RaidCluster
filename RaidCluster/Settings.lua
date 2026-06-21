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

-- This file contains the SV-Defaults and the OptionsTable structure.

local AddonName = ...
local RaidCluster = select(2, ...)
local L = RaidCluster.L or setmetatable({}, {
  __index = function(_, key)
    return key
  end,
})
RaidCluster.L = L

-- Libs
local LSM = LibStub("LibSharedMedia-3.0")
local fonts = LSM:HashTable("font")

-- WoW Api
local GetAddOnMetadata = GetAddOnMetadata

-- Always reference to the current profile
local db
function RaidCluster:UpdateDB()
  db = self.db.profile
end

local function RestartAddon()
  RaidCluster:StopAddon()
  RaidCluster:specDetection()
end

local function SetAndRestart(info, value)
  db[info[#info]] = value
  RestartAddon()
end

local function SetAndRefreshAppearance(info, value)
  db[info[#info]] = value
  RaidCluster:ChangeAppearance()
end

local function BuildSpecOptions(def, orderOffset)
  local args = {}
  orderOffset = orderOffset or 0

  args[def.enabled] = {
    type = "toggle",
    name = ENABLE,
    width = "full",
    order = orderOffset + 1,
    set = SetAndRestart,
  }
  args[def.counter] = {
    type = "toggle",
    name = L["Enable Counter"],
    order = orderOffset + 2,
    set = SetAndRestart,
  }
  if def.lowHealthOnly then
    args[def.lowHealthOnly] = {
      type = "toggle",
      name = L["Only Low Health Targets"],
      desc = L["Only count players below 100% health for this counter."],
      order = orderOffset + 3,
      set = SetAndRestart,
    }
  end
  args[def.key .. "CounterDesc"] = {
    type = "description",
    name = def.counterDesc,
    order = orderOffset + 4,
    fontSize = "small",
  }
  args[def.glow] = {
    type = "toggle",
    name = L["Enable Glow"],
    order = orderOffset + 5,
    set = SetAndRestart,
  }
  args[def.key .. "GlowDesc"] = {
    type = "description",
    name = def.glowDesc,
    order = orderOffset + 6,
    fontSize = "small",
  }
  args[def.raid] = {
    type = "toggle",
    name = L["Only in Raid"],
    width = "full",
    order = orderOffset + 7,
    set = SetAndRestart,
  }
  args[def.party] = {
    type = "toggle",
    name = L["Only in Party"],
    width = "full",
    order = orderOffset + 8,
    set = SetAndRestart,
  }
  args[def.key .. "Activation"] = {
    type = "header",
    name = L["Activation"],
    order = orderOffset + 9,
  }
  args[def.talent] = {
    type = "select",
    name = L["Talent"],
    order = orderOffset + 10,
    values = function()
      return RaidCluster:genTalentDropdown(def.talentClass)
    end,
    set = function(i, val)
      db[i[#i]] = val
      RestartAddon()
    end,
  }
  args[def.key .. "TalentDesc"] = {
    type = "description",
    name = def.talentDesc,
    order = orderOffset + 11,
    fontSize = "small",
  }

  return args
end

local function MergeOptions(target, source)
  for key, value in pairs(source) do
    target[key] = value
  end
end

local function BuildClassOptions(name, order, specs)
  local args = {}

  for index, spec in ipairs(specs) do
    local offset = (index - 1) * 100
    if spec.header then
      args[spec.key .. "Header"] = {
        type = "header",
        name = L[spec.header],
        order = offset,
      }
    end
    MergeOptions(args, BuildSpecOptions(spec, offset))
  end

  return {
    type = "group",
    name = L[name],
    order = order,
    get = function(i)
      return db[i[#i]]
    end,
    set = function(i, val)
      db[i[#i]] = val
    end,
    args = args,
  }
end

local SPEC_OPTIONS = {
  paladin = {
    key = "paladin",
    talentClass = "PALADIN",
    enabled = "paladinEnable",
    raid = "paladinEnableInRaid",
    party = "paladinEnableInParty",
    counter = "paladinRaidFrameEnable",
    glow = "paladinGlowEnable",
    talent = "paladinTalents",
    counterDesc = L["Displays the number of players in range for %s."]:format(RaidCluster:GetSpellLink(55121)),
    glowDesc = L["Glows players that you healed with %s."]:format(RaidCluster:GetSpellLink(55121)),
    talentDesc = L["Select the talent that identifies when this Paladin setup should be active."],
  },
  shaman = {
    key = "shaman",
    talentClass = "SHAMAN",
    enabled = "shamanEnable",
    raid = "shamanEnableInRaid",
    party = "shamanEnableInParty",
    counter = "shamanRaidFrameEnable",
    glow = "shamanGlowEnable",
    talent = "shamanTalents",
    lowHealthOnly = "shamanLowHealthOnly",
    counterDesc = L["Displays the number of players in range for %s."]:format(RaidCluster:GetSpellLink(55459)) ..
      "\n" .. L["Shows players with less than 100% health and chained together."],
    glowDesc = L["Glows players that you healed with %s."]:format(RaidCluster:GetSpellLink(55459)),
    talentDesc = L["Select the talent that identifies when this Shaman setup should be active."],
  },
  discipline = {
    key = "discoPriest",
    header = "Discipline",
    talentClass = "PRIEST",
    enabled = "discoPriestEnable",
    raid = "discoPriestEnableInRaid",
    party = "discoPriestEnableInParty",
    counter = "discoPriestRaidFrameEnable",
    glow = "discoPriestGlowEnable",
    talent = "discoPriestTalents",
    counterDesc = L["Displays the number of players in group in range for %s."]:format(RaidCluster:GetSpellLink(48072)),
    glowDesc = L["Glows players that you healed with %s."]:format(RaidCluster:GetSpellLink(48072)),
    talentDesc = L["Select the talent that identifies when this Discipline setup should be active."],
  },
  holy = {
    key = "holyPriest",
    header = "Holy",
    talentClass = "PRIEST",
    enabled = "holyPriestEnable",
    raid = "holyPriestEnableInRaid",
    party = "holyPriestEnableInParty",
    counter = "holyPriestRaidFrameEnable",
    glow = "holyPriestGlowEnable",
    talent = "holyPriestTalents",
    counterDesc = L["Displays the number of players in range for %s."]:format(RaidCluster:GetSpellLink(48089)),
    glowDesc = L["Glows players that you healed with %s."]:format(RaidCluster:GetSpellLink(48089)),
    talentDesc = L["Select the talent that identifies when this Holy setup should be active."],
  },
  druid = {
    key = "druid",
    talentClass = "DRUID",
    enabled = "druidEnable",
    raid = "druidEnableInRaid",
    party = "druidEnableInParty",
    counter = "druidRaidFrameEnable",
    glow = "druidGlowEnable",
    talent = "druidTalents",
    counterDesc = L["Displays the number of players in range for %s."]:format(RaidCluster:GetSpellLink(53251)),
    glowDesc = L["Glows players that you healed with %s."]:format(RaidCluster:GetSpellLink(53251)),
    talentDesc = L["Select the talent that identifies when this Druid setup should be active."],
  },
}

-- Default Settings
RaidCluster.defaults = {
  profile = {
    enabled = true,
    update = 0.6,
    rangeChecksPerFrame = 220,
    subGroup = true,
    x = 0,
    y = 0,
    classColor = false,
    color = { r = 1, g = 1, b = 1, a = 1 },
    font = "Friz Quadrata TT",
    fontFlags = "OUTLINE",
    fontSize = 14,
    glowColorEnable = false,
    glowType = "Pixel Glow",
    glowColor = { r = 0.95, g = 0.95, b = 0.32, a = 1 },
    lines = 10,
    frequency = 0.25,
    glowScale = 1,
    length = 16,
    thickness = 1,
    border = false,
    xOffset = 0,
    yOffset = 0,
    procGlowDuration = 1,
    procGlowStartAnim = true,
    paladinEnable = true,
    paladinEnableInRaid = true,
    paladinEnableInParty = true,
    paladinRaidFrameEnable = true,
    paladinGlowEnable = true,
    paladinTalents = 53563,
    shamanEnable = true,
    shamanEnableInRaid = true,
    shamanEnableInParty = true,
    shamanRaidFrameEnable = true,
    shamanGlowEnable = true,
    shamanLowHealthOnly = true,
    shamanTalents = 974,
    holyPriestEnable = true,
    holyPriestEnableInRaid = true,
    holyPriestEnableInParty = true,
    holyPriestRaidFrameEnable = true,
    holyPriestGlowEnable = true,
    holyPriestTalents = 34861,
    discoPriestEnable = true,
    discoPriestEnableInRaid = true,
    discoPriestEnableInParty = true,
    discoPriestRaidFrameEnable = true,
    discoPriestGlowEnable = true,
    discoPriestTalents = 10060,
    druidEnable = true,
    druidEnableInRaid = true,
    druidEnableInParty = true,
    druidRaidFrameEnable = true,
    druidGlowEnable = true,
    druidTalents = 48438,
  }
}

-- Options Table
RaidCluster.options = {
  type = "group",
  name = L["Raid Cluster"],
  args = {
    github = {
      type = "header",
      name = L["Github: |c007289d9%s|r"]:format(GetAddOnMetadata(AddonName, "X-Website")),
      order = 0
    },
    General = {
      type = "group",
      name = L["General"],
      order = 1,
      get = function(i)
        return db[i[#i]]
      end,
      set = function(i, val)
        db[i[#i]] = val
      end,
      args = {
        enabled = {
          type = "toggle",
          name = L["Enable Addon"],
          order = 1,
          set = function(i, val)
            db[i[#i]] = val
            if val then
              RaidCluster:EnableAddon()
            else
              RaidCluster:DisableAddon()
            end
          end,
        },
        Separator = {
          type = "description",
          name = " ",
          fontSize = "small",
          order = 2,
        },
        update = {
          type = "range",
          name = L["Update Frequency"],
          order = 3,
          min = 0.4,
          softMax = 2,
          step = 0.05,
          set = SetAndRestart,
        },
        desc = {
          type = "description",
          name = L["How often counters are recalculated. Lower values update faster and cost more CPU."],
          order = 4,
          fontSize = "small",
        },
        rangeChecksPerFrame = {
          type = "range",
          name = L["Range Checks / Frame"],
          order = 5,
          min = 40,
          softMax = 800,
          step = 20,
          desc = L["Spreads range work over frames. Higher values finish faster but can spike more."],
        },
        Separator2 = {
          type = "description",
          name = L["Limits how many range comparisons are processed per rendered frame. Lower values reduce spikes but may make counter updates finish later."],
          fontSize = "small",
          order = 6,
        },
        subGroup = {
          name = L["Raid: Only Groups 1-5"],
          type = "toggle",
          width = "full",
          order = 7,
          set = function(i, val)
            db[i[#i]] = val
            RaidCluster:CancelRangeJob()
            RaidCluster:ReleaseCounters()
            RaidCluster:ResetFrameBindings()
            RaidCluster:specDetection()
          end
        },
        desc2 = {
          type = "description",
          name = L["Raid-only filter. Party mode always uses player and party members."],
          order = 8,
          fontSize = "small",
        },
      },
    },
    Appearance = {
      type = "group",
      name = L["Appearance"],
      order = 2,
      get = function(i)
        return db[i[#i]]
      end,
      set = function(i, val)
        db[i[#i]] = val
      end,
      args = {
        raidframes = {
          type = "group",
          name = L["Counter Appearance"],
          order = 1,
          inline = true,
          args = {
            x = {
              type = "range",
              name = L["X Offset"],
              order = 1,
              min = -100,
              softMax = 100,
              step = 0.25,
              set = SetAndRefreshAppearance,
            },
            y = {
              type = "range",
              name = L["Y Offset"],
              order = 2,
              min = -100,
              softMax = 100,
              step = 0.25,
              set = SetAndRefreshAppearance,
            },
            classColor = {
              type = "toggle",
              name = L["Class Color"],
              order = 3,
              set = SetAndRefreshAppearance,
            },
            color = {
              type = "color",
              name = L["Color"],
              order = 4,
              hasAlpha = true,
              hidden = function()
                return db.classColor
              end,
              get = function()
                return db.color.r, db.color.g, db.color.b, db.color.a
              end,
              set = function(_, r, g, b, a)
                db.color.r, db.color.g, db.color.b, db.color.a = r, g, b, a
                RaidCluster:ChangeAppearance()
              end
            },
            font = {
              type = "select",
              name = L["Font"],
              order = 5,
              values = fonts,
              dialogControl = "LSM30_Font",
              set = SetAndRefreshAppearance,
            },
            fontFlags = {
              type = "select",
              name = L["Font Outline"],
              order = 6,
              values = {
                [""] = NONE,
                ["OUTLINE"] = "Outline",
                ["THINOUTLINE"] = "Thin Outline",
                ["THICKOUTLINE"] = "Thick Outline",
                ["MONOCHROME"] = "Monochrome",
                ["OUTLINEMONOCHROME"] = "Outlined Monochrome"
              },
              set = SetAndRefreshAppearance,
            },
            fontSize = {
              type = "range",
              name = L["Font Size"],
              order = 7,
              min = 6,
              softMax = 72,
              step = 1,
              set = SetAndRefreshAppearance,
            },
          },
        },
        glow = {
          type = "group",
          name = L["Glow Appearance"],
          order = 2,
          inline = true,
          args = {
            glowType = {
              type = "select",
              name = L["Glow Type"],
              order = 1,
              set = SetAndRefreshAppearance,
              values = {
                ["Autocast Shine"] = "Autocast Shine",
                ["Pixel Glow"] = "Pixel Glow",
                ["Action Button Glow"] = "Action Button Glow",
                ["Proc Glow"] = "Proc Glow",
              },
            },
            glowColorEnable = {
              type = "toggle",
              name = L["Custom Color"],
              order = 2,
              set = function(i, val)
                db[i[#i]] = val
                if not val then
                  db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a = 0.95, 0.95, 0.32, 1
                end
                RaidCluster:ChangeAppearance()
              end
            },
            glowColor = {
              type = "color",
              name = L["Color"],
              order = 3,
              hasAlpha = true,
              hidden = function()
                return not db.glowColorEnable
              end,
              get = function()
                return db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a
              end,
              set = function(_, r, g, b, a)
                db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a = r, g, b, a
                RaidCluster:ChangeAppearance()
              end
            },
            lines = {
              type = "range",
              name = L["Lines & Particles"],
              order = 4,
              min = 1,
              softMax = 30,
              step = 1,
              set = SetAndRefreshAppearance,
              hidden = function()
                return db.glowType == "Action Button Glow" or db.glowType == "Proc Glow"
              end,
            },
            frequency = {
              type = "range",
              name = L["Frequency"],
              order = 5,
              min = -2,
              softMax = 2,
              step = 0.05,
              set = SetAndRefreshAppearance,
              hidden = function()
                return db.glowType == "Proc Glow"
              end,
            },
            length = {
              type = "range",
              name = L["Length"],
              order = 6,
              min = 0.05,
              softMax = 20,
              step = 0.05,
              set = SetAndRefreshAppearance,
              hidden = function()
                return db.glowType ~= "Pixel Glow"
              end,
            },
            glowScale = {
              type = "range",
              name = L["Scale"],
              order = 7,
              min = 0.05,
              softMax = 10,
              step = 0.05,
              isPercent = true,
              set = SetAndRefreshAppearance,
              hidden = function()
                return db.glowType ~= "Autocast Shine"
              end,
            },
            thickness = {
              type = "range",
              name = L["Thickness"],
              order = 8,
              min = 0.05,
              softMax = 20,
              step = 0.05,
              set = SetAndRefreshAppearance,
              hidden = function()
                return db.glowType ~= "Pixel Glow"
              end,
            },
            border = {
              type = "toggle",
              name = L["Border"],
              order = 9,
              set = SetAndRefreshAppearance,
              hidden = function()
                return db.glowType ~= "Pixel Glow"
              end,
            },
            xOffset = {
              type = "range",
              name = L["X Offset"],
              order = 10,
              min = -100,
              softMax = 100,
              step = 0.05,
              set = SetAndRefreshAppearance,
              hidden = function()
                return db.glowType == "Action Button Glow"
              end,
            },
            yOffset = {
              type = "range",
              name = L["Y Offset"],
              order = 11,
              min = -100,
              softMax = 100,
              step = 0.05,
              set = SetAndRefreshAppearance,
              hidden = function()
                return db.glowType == "Action Button Glow"
              end,
            },
            procGlowDuration = {
              type = "range",
              name = L["Proc Duration"],
              order = 12,
              min = 0.1,
              softMax = 3,
              step = 0.05,
              set = SetAndRefreshAppearance,
              hidden = function()
                return db.glowType ~= "Proc Glow"
              end,
            },
            procGlowStartAnim = {
              type = "toggle",
              name = L["Start Animation"],
              order = 13,
              set = SetAndRefreshAppearance,
              hidden = function()
                return db.glowType ~= "Proc Glow"
              end,
            },
          },
        },
      },
    },
    Paladin = BuildClassOptions("Paladin", 3, { SPEC_OPTIONS.paladin }),
    Shaman = BuildClassOptions("Shaman", 4, { SPEC_OPTIONS.shaman }),
    Priest = BuildClassOptions("Priest", 5, { SPEC_OPTIONS.discipline, SPEC_OPTIONS.holy }),
    Druid = BuildClassOptions("Druid", 6, { SPEC_OPTIONS.druid }),
  },
}
