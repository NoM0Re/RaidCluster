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

-- Libs
local LSM = LibStub("LibSharedMedia-3.0")
local fonts = LSM:HashTable("font")

-- WoW Api
local GetAddOnMetadata = GetAddOnMetadata

-- Fixes Profile Defaults, if some are missing
function RaidCluster:FixProfileDefaults(profile, defaults)
    for key, defaultValue in pairs(defaults) do
        local currentValue = profile[key]

        if type(defaultValue) == "table" then
            if (key == "color" or key == "glowColor") and type(currentValue) ~= "table" then
                profile[key] = CopyTable(defaultValue)
            elseif type(currentValue) ~= "table" then
                profile[key] = CopyTable(defaultValue)
            end
        else
            if currentValue == nil then
                profile[key] = defaultValue
            end
        end
    end
end

-- Always reference to the current profile
local db
function RaidCluster:UpdateDB()
    db = self.db.profile
end

-- Default Settings
RaidCluster.defaults = {
    profile = {
        enabled = true,
        update = 0.6,
        subGroup = true,
        x = 0,
        y = 0,
        classColor = false,
        color = {r = 1, g = 1, b = 1, a = 1},
        font = "Friz Quadrata TT",
        fontFlags = "OUTLINE",
        fontSize = 14,
        glowColorEnable = false,
        glowColor = {r = 0.95, g = 0.95, b = 0.32, a = 1},
        lines = 10,
        frequency = 0.25,
        length = 16,
        thickness = 1,
        xOffset = 0,
        yOffset = 0,
        paladinRaidFrameEnable = true,
        paladinPixelGlowEnable = true,
        paladinTalents = 53563,
        shamanRaidFrameEnable = true,
        shamanPixelGlowEnable = true,
        shamanTalents = 974,
        holyPriestRaidFrameEnable = true,
        holyPriesPixelGlowEnable = true,
        holyPriestTalents = 34861,
        discoPriestRaidFrameEnable = true,
        discoPriesPixelGlowEnable = true,
        discoPriestTalents = 10060,
        druidRaidFrameEnable = true,
        druidPixelGlowEnable = true,
        druidTalents = 48438,
    }
}

-- Options Table
RaidCluster.options = {
    type = "group",
    name = "Raid Cluster",
    args = {
        github = {
            type = "header",
            name = "Github: |c007289d9" .. GetAddOnMetadata(AddonName, "X-Website") .. "|r",
            order = 0
        },
        General = {
            type = "group",
            name = "General",
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
                    name = "Enable Addon",
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
                Seperator = {
                    type = "description",
                    name = " ",
                    fontSize = "small",
                    order = 2,
                },
                update = {
                    type = "range",
                    name = "Update Frequenzy",
                    order = 3,
                    min = 0.4,
                    softMax = 2,
                    step = 0.05,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
                desc = {
                    type = "description",
                    name = "The lower it is, the more performance it requires.",
                    order = 4,
                    fontSize = "small",
                },
                Seperator2 = {
                    type = "description",
                    name = " ",
                    fontSize = "small",
                    order = 5,
                },
                subGroup = {
                    name = "Only Groups 1-5",
                    type = "toggle",
                    width = "full",
                    order = 6,
                    confirm = true,
                    confirmText = "Requires UI reloading.",
                    set = function(i, val)
                        db[i[#i]] = val
                        ReloadUI()
                    end
                },
                desc2 = {
                    type = "description",
                    name = "Only saves a very small amount of performance.",
                    order = 7,
                    fontSize = "small",
                },
            },
        },
        Appearance = {
            type = "group",
            name = "Apperance",
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
                    name = "Raid Frames Apperance",
                    order = 1,
                    inline = true,
                    args = {
                        x = {
                            type = "range",
                            name = "X Position",
                            order = 1,
                            min = -100,
                            softMax = 100,
                            step = 0.25,
                            set = function(i, val)
                                db[i[#i]] = val
                                RaidCluster:ChangeApperance()
                            end
                        },
                        y = {
                            type = "range",
                            name = "Y Position",
                            order = 2,
                            min = -100,
                            softMax = 100,
                            step = 0.25,
                            set = function(i, val)
                                db[i[#i]] = val
                                RaidCluster:ChangeApperance()
                            end
                        },
                        classColor = {
                            type = "toggle",
                            name = "  ClassColor",
                            order = 3,
                            set = function(i, val)
                                db[i[#i]] = val
                                RaidCluster:ChangeApperance()
                            end
                        },
                        color = {
                            type = "color",
                            name = "Color",
                            order = 4,
                            hasAlpha = true,
                            get = function()
                                return db.color.r, db.color.g, db.color.b, db.color.a
                            end,
                            set = function(_, r, g, b, a)
                                db.color.r, db.color.g, db.color.b, db.color.a = r, g, b, a
                                RaidCluster:ChangeApperance()
                            end
                        },
                        font = {
                            type = "select",
                            name = "Font",
                            order = 5,
                            values = fonts,
                            dialogControl = "LSM30_Font",
                            set = function(i, val)
                                db[i[#i]] = val
                                RaidCluster:ChangeApperance()
                            end
                        },
                        fontFlags = {
                            type = "select",
                            name = "Font Outline",
                            order = 6,
                            values = {
                                [""] = NONE,
                                ["OUTLINE"] = "Outline",
                                ["THINOUTLINE"] = "Thin Outline",
                                ["THICKOUTLINE"] = "Thick Outline",
                                ["MONOCHROME"] = "Monochrome",
                                ["OUTLINEMONOCHROME"] = "Outlined Monochrome"
                            },
                            set = function(i, val)
                                db[i[#i]] = val
                                RaidCluster:ChangeApperance()
                            end
                        },
                        fontSize = {
                            type = "range",
                            name = "Font Size",
                            order = 7,
                            min = 6,
                            softMax = 72,
                            step = 1,
                            set = function(i, val)
                                db[i[#i]] = val
                                RaidCluster:ChangeApperance()
                            end
                        },
                    },
                },
                pixelglow = {
                    type = "group",
                    name = "Pixel Glow Apperance",
                    order = 2,
                    inline = true,
                    args = {
                        glowColorEnable = {
                            type = "toggle",
                            name = "Glow Color",
                            order = 1,
                            set = function(i, val)
                                db[i[#i]] = val
                                if not val then
                                    db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a = 0.95, 0.95, 0.32, 1
                                end
                            end
                        },
                        glowColor = {
                            type = "color",
                            name = "Color",
                            order = 2,
                            hasAlpha = true,
                            get = function()
                                return db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a
                            end,
                            set = function(_, r, g, b, a)
                                db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a = r, g, b, a
                            end
                        },
                        lines = {
                            type = "range",
                            name = "Lines & Particles",
                            order = 3,
                            min = 1,
                            softMax = 30,
                            step = 1,
                        },
                        frequency = {
                            type = "range",
                            name = "Frequenzy",
                            order = 4,
                            min = -2,
                            softMax = 2,
                            step = 0.05,
                        },
                        length = {
                            type = "range",
                            name = "Length",
                            order = 5,
                            min = 0.05,
                            softMax = 20,
                            step = 0.05,
                        },
                        thickness = {
                            type = "range",
                            name = "Thickness",
                            order = 6,
                            min = 0.05,
                            softMax = 20,
                            step = 0.05,
                        },
                        xOffset = {
                            type = "range",
                            name = "X-Offset",
                            order = 7,
                            min = -100,
                            softMax = 100,
                            step = 0.05,
                        },
                        yOffset = {
                            type = "range",
                            name = "Y-Offset",
                            order = 8,
                            min = -100,
                            softMax = 100,
                            step = 0.05,
                        },
                    },
                },
            },
        },
        Paladin = {
            type = "group",
            name = "Paladin",
            order = 3,
            get = function(i)
                return db[i[#i]]
            end,
            set = function(i, val)
                db[i[#i]] = val
            end,
            args = {
                paladinRaidFrameEnable = {
                    type = "toggle",
                    name = "Enable Raid Frame",
                    order = 1,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
                paladinDesc = {
                    type = "description",
                    name = "Displays the number of players in range for " .. RaidCluster:GetSpellLink(55121) .. ".",
                    order = 2,
                    fontSize = "medium",
                },
                paladinPixelGlowEnable = {
                    type = "toggle",
                    name = "Enable Pixel Glow",
                    order = 3,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
                paladinDesc2 = {
                    type = "description",
                    name = "Displays Pixel Glow Effect on players, that you healed with " .. RaidCluster:GetSpellLink(55121) .. ".",
                    order = 4,
                    fontSize = "medium",
                },
                paladinTalents = {
                    type = "select",
                    name = "Talent",
                    order = 5,
                    values = function()
                        return RaidCluster:genTalentDropdown("PALADIN")
                    end,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
            },
        },
        Shaman = {
            type = "group",
            name = "Shaman",
            order = 4,
            get = function(i)
                return db[i[#i]]
            end,
            set = function(i, val)
                db[i[#i]] = val
            end,
            args = {
                shamanRaidFrameEnable = {
                    type = "toggle",
                    name = "Enable Raid Frame",
                    order = 1,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
                shamanDesc = {
                    type = "description",
                    name = "Displays the number of players in range for " .. RaidCluster:GetSpellLink(55459) .. ".\nShows players with less than 100% health and chained together.",
                    order = 2,
                    fontSize = "medium",
                },
                shamanPixelGlowEnable = {
                    type = "toggle",
                    name = "Enable Pixel Glow",
                    order = 3,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
                shamanDesc2 = {
                    type = "description",
                    name = "Displays Pixel Glow Effect on players, that you healed with " .. RaidCluster:GetSpellLink(55459) .. ".",
                    order = 4,
                    fontSize = "medium",
                },
                shamanTalents = {
                    type = "select",
                    name = "Talent",
                    order = 5,
                    values = function()
                        return RaidCluster:genTalentDropdown("SHAMAN")
                    end,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                }
            }
        },
        Priest = {
            type = "group",
            name = "Priest",
            order = 5,
            get = function(i)
                return db[i[#i]]
            end,
            set = function(i, val)
                db[i[#i]] = val
            end,
            args = {
                discoPriestRaidFrameEnable = {
                    type = "toggle",
                    name = "Enable Raid Frame",
                    order = 1,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
                discoPriestDesc = {
                    type = "description",
                    name = "Displays the number of players in group in range for " .. RaidCluster:GetSpellLink(48072) .. ".",
                    order = 2,
                    fontSize = "medium",
                },
                discoPriestPixelGlowEnable = {
                    type = "toggle",
                    name = "Enable Pixel Glow",
                    order = 3,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
                discoPriestDesc2 = {
                    type = "description",
                    name = "Displays Pixel Glow Effect on players that you healed with " .. RaidCluster:GetSpellLink(48072) .. ".",
                    order = 4,
                    fontSize = "medium",
                },
                discoPriestTalents = {
                    type = "select",
                    name = "Talent",
                    order = 5,
                    values = function()
                        return RaidCluster:genTalentDropdown("PRIEST")
                    end,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
                Seperator4 = {
                    type = "header",
                    name = "",
                    order = 6,
                },
                holyPriestRaidFrameEnable = {
                    type = "toggle",
                    name = "Enable Raid Frame",
                    order = 7,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
                holyPriestDesc = {
                    type = "description",
                    name = "Displays the number of players in range for " .. RaidCluster:GetSpellLink(48089) .. ".",
                    order = 8,
                    fontSize = "medium",
                },
                holyPriestPixelGlowEnable = {
                    type = "toggle",
                    name = "Enable Pixel Glow",
                    order = 9,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
                holyPriestDesc2 = {
                    type = "description",
                    name = "Displays Pixel Glow Effect on players, that you healed with " .. RaidCluster:GetSpellLink(48089) .. ".",
                    order = 10,
                    fontSize = "medium",
                },
                holyPriestTalents = {
                    type = "select",
                    name = "Talent",
                    order = 11,
                    values = function()
                        return RaidCluster:genTalentDropdown("PRIEST")
                    end,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
            },
        },
        Druid = {
            type = "group",
            name = "Druid",
            order = 6,
            get = function(i)
                return db[i[#i]]
            end,
            set = function(i, val)
                db[i[#i]] = val
            end,
            args = {
                druidRaidFrameEnable = {
                    type = "toggle",
                    name = "Enable Raid Frame",
                    order = 1,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
                druidDesc = {
                    type = "description",
                    name = "Displays the number of players in range for " .. RaidCluster:GetSpellLink(53251) .. ".",
                    order = 2,
                    fontSize = "medium",
                },
                druidPixelGlowEnable = {
                    type = "toggle",
                    name = "Enable Pixel Glow",
                    order = 3,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
                druidDesc2 = {
                    type = "description",
                    name = "Displays Pixel Glow Effect on players, that you healed with " .. RaidCluster:GetSpellLink(53251) .. ".",
                    order = 4,
                    fontSize = "medium",
                },
                druidTalents = {
                    type = "select",
                    name = "Talent",
                    order = 5,
                    values = function()
                        return RaidCluster:genTalentDropdown("DRUID")
                    end,
                    set = function(i, val)
                        db[i[#i]] = val
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
                    end,
                },
            },
        },
    },
}
