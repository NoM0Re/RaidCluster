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

-- Libs
local RaidCluster = LibStub("AceAddon-3.0"):NewAddon("RaidCluster", "AceConsole-3.0", "AceTimer-3.0")
local LGF = LibStub("LibGetFrame-1.0")
local LCG = LibStub("LibCustomGlow-1.0")
local AceGUI = LibStub("AceGUI-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ADB = LibStub("AceDB-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local LibDualSpec = LibStub("LibDualSpec-1.0")
local fonts = LSM:HashTable("font")
local GetFrame = LGF.GetUnitFrame
local PixelGlow_Start = LCG.PixelGlow_Start
local PixelGlow_Stop = LCG.PixelGlow_Stop

RaidCluster.version = "Raid Cluster v"..GetAddOnMetadata("RaidCluster", "Version")

-- WoW Api
local UnitName = UnitName
local UnitIsConnected = UnitIsConnected
local UnitIsVisible = UnitIsVisible
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local GetRaidRosterInfo = GetRaidRosterInfo
local GetNumRaidMembers = GetNumRaidMembers
local GetPlayerMapPosition = GetPlayerMapPosition
local UnitClass = UnitClass
local GetMapInfo = GetMapInfo
local GetCurrentMapDungeonLevel = GetCurrentMapDungeonLevel
local DungeonUsesTerrainMap = DungeonUsesTerrainMap
local GetTalentInfo = GetTalentInfo
local GetSpellInfo = GetSpellInfo
local GetSpellLink = GetSpellLink
local UnitInRaid = UnitInRaid

-- Variables
local db = {}
RaidCluster.IsInit = false
RaidCluster.cleuIsInit = false
RaidCluster.eventLock = false
RaidCluster.frames = {}
RaidCluster.currentframes = {}
RaidCluster.frameCount = {25, 40}
RaidCluster.Range = 0
RaidCluster.ClassRanges = {
    ["PALADIN"] = 9.5,
    ["SHAMAN"] = 12.5,
    ["PRIEST"] = { 16.5, 30 },
    ["DRUID"] = 16.5
}
RaidCluster.Action = {
    ["PALADIN"] = false,
    ["SHAMAN"] = false,
    ["HPRIEST"] = false,
    ["DPRIEST"] = false,
    ["DRUID"] = false
}
-- Pixel Glow CLEU Functions
local cleuFunctions = {
    ["PALADIN"] = function(self, ...)
        local _, _, subEvent, _, sourceName, _, _, destName,_ , spellID = ...
        if subEvent == "SPELL_HEAL" and sourceName == RaidCluster.playerName and spellID == 54968 and destName then
            local f = GetFrame(destName)
            if f and db then
                PixelGlow_Start(f, {db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a}, db.lines, db.frequency, db.length, db.thickness, db.xOffset, db.yOffset)
                RaidCluster:ScheduleTimer(function() PixelGlow_Stop(f) end, 1)
            end
        end
    end,
    ["SHAMAN"] = function(self, ...)
        local _, _, subEvent, _, sourceName, _, _, destName,_ , spellID = ...
        if subEvent == "SPELL_HEAL" and sourceName == RaidCluster.playerName and spellID == 55459 and destName then
            local f = GetFrame(destName)
            if f and db then
                PixelGlow_Start(f, {db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a}, db.lines, db.frequency, db.length, db.thickness, db.xOffset, db.yOffset)
                RaidCluster:ScheduleTimer(function() PixelGlow_Stop(f) end, 1)
            end
        end
    end,
    ["HPRIEST"] = function(self, ...)
        local _, _, subEvent, _, sourceName, _, _, destName,_ , spellID = ...
        if subEvent == "SPELL_HEAL" and sourceName == RaidCluster.playerName and spellID == 48089 and destName then
            local f = GetFrame(destName)
            if f and db then
                PixelGlow_Start(f, {db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a}, db.lines, db.frequency, db.length, db.thickness, db.xOffset, db.yOffset)
                RaidCluster:ScheduleTimer(function() PixelGlow_Stop(f) end, 1)
            end
        end
    end,
    ["DPRIEST"] = function(self, ...)
        local _, _, subEvent, _, sourceName, _, _, destName,_ , spellID = ...
        if subEvent == "SPELL_HEAL" and sourceName == RaidCluster.playerName and spellID == 48072 and destName then
            local f = GetFrame(destName)
            if f and db then
                PixelGlow_Start(f, {db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a}, db.lines, db.frequency, db.length, db.thickness, db.xOffset, db.yOffset)
                RaidCluster:ScheduleTimer(function() PixelGlow_Stop(f) end, 1)
            end
        end
    end,
    ["DRUID"] = function(self, ...)
        local _, _, subEvent, _, sourceName, _, _, destName,_ , spellID = ...
        if (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH") and sourceName == RaidCluster.playerName and spellID == 53251 and destName then
            local f = GetFrame(destName)
            if f and db then
                PixelGlow_Start(f, {db.glowColor.r, db.glowColor.g, db.glowColor.b, db.glowColor.a}, db.lines, db.frequency, db.length, db.thickness, db.xOffset, db.yOffset)
                RaidCluster:ScheduleTimer(function() PixelGlow_Stop(f) end, 1)
            end
        end
    end
}

RaidCluster.talents_ids = {
    DEATHKNIGHT = {{48979,48997,49182,48978,49004,55107,48982,48987,49467,48985,49145,49015,48977,49006,49005,48988,53137,49027,49016,50365,62905,49018,55233,49189,55050,49023,61154,49028}, {49175,49455,49042,55061,49140,49226,50880,49039,51468,51123,49149,49137,49186,49471,49796,55610,49024,49188,50040,49203,50384,65661,54639,51271,49200,49143,50187,49202,49184}, {51745,48962,55129,49036,48963,49588,48965,49013,51459,49158,49146,49219,55620,49194,49220,49223,55666,49224,49208,52143,66799,51052,50391,63560,49032,49222,49217,51099,55090,50117,49206}},
    DRUID = {{16814,57810,16845,35363,16821,16836,16880,57865,16819,16909,16850,33589,5570,57849,33597,16896,33592,24858,48384,33600,48389,33603,48516,50516,33831,48488,48506,48505}, {16934,16858,16947,16998,16929,17002,61336,16942,16966,16972,37116,48409,16940,49377,33872,57878,17003,33853,17007,34297,33851,57873,33859,48483,48492,33917,48532,48432,63503,50334}, {17050,17063,17056,17069,17118,16833,17106,16864,48411,24968,17111,17116,17104,17123,33879,17074,34151,18562,33881,33886,48496,48539,65139,48535,63410,51179,48438}},
    HUNTER = {{19552,19583,35029,19549,19609,24443,19559,53265,19616,19572,19598,19578,19577,19590,34453,19621,34455,19574,34462,53252,34466,53262,34692,53256,56314,53270}, {19407,53620,19426,34482,19421,19485,34950,19454,19434,34948,19464,19416,35100,23989,19461,34475,19507,53234,19506,35104,34485,53228,53215,34490,53221,53241,53209}, {52783,19498,19159,19290,19184,19376,34494,19255,19503,19295,19286,56333,56342,56339,19370,19306,19168,34491,34500,19386,34497,34506,53295,53298,3674,53302,53290,53301}},
    MAGE = {{11210,11222,11237,28574,29441,11213,11247,11242,44397,54646,11252,11255,18462,29447,31569,12043,11232,31574,15058,31571,31579,12042,44394,44378,31584,31589,44404,44400,35578,44425}, {11078,18459,11069,11119,54747,11108,11100,11103,11366,11083,11095,11094,29074,31638,11115,11113,31641,11124,34293,11129,31679,64353,31656,44442,31661,44445,44449,44457}, {11071,11070,31670,11207,11189,29438,11175,11151,12472,11185,16757,11160,11170,11958,11190,31667,55091,11180,44745,11426,31674,31682,44543,44546,31687,44557,44566,44572}},
    PALADIN = {{20205,20224,20237,20257,9453,31821,20210,20234,20254,20244,53660,31822,20216,20359,31825,5923,31833,20473,31828,53551,31837,31842,53671,53569,53556,53563}, {63646,20262,31844,20174,20096,64205,20468,20143,53527,20487,20138,20911,20177,31848,20196,31785,20925,31850,20127,31858,53590,31935,53583,53709,53695,53595}, {20060,20101,25956,20335,20042,9452,20117,20375,26022,9799,32043,31866,20111,31869,20049,31871,53486,20066,31876,31879,53375,53379,35395,53501,53380,53385}},
    PRIEST = {{14522,47586,14523,14747,14749,14531,14521,14751,14748,33167,14520,14750,33201,18551,63574,33186,34908,45234,10060,63504,57470,47535,47507,47509,33206,47516,52795,47540}, {14913,14908,14889,27900,18530,19236,27811,14892,27789,14912,14909,14911,20711,14901,33150,14898,34753,724,33142,64127,33158,63730,63534,34861,47558,47562,47788}, {15270,15337,15259,15318,15275,15260,15392,15273,15407,15274,17322,15257,15487,15286,27839,33213,14910,63625,15473,33221,47569,33191,64044,34914,47580,47573,47585}},
    ROGUE = {{14162,14144,14138,14156,51632,13733,14983,14168,14128,16513,14113,31208,14177,14174,31244,14186,14158,51625,58426,31380,51634,31234,31226,1329,51627,51664,51662}, {13741,13732,13715,14165,13713,13705,13742,14251,13706,13754,13743,13712,18427,13709,13877,13960,30919,31124,31122,13750,31130,5952,35541,51672,32601,51682,51685,51690}, {14179,13958,14057,30892,14076,13975,13981,14278,14171,13983,13976,14079,30894,14185,14082,16511,31221,30902,31211,14183,31228,31216,51692,51698,36554,58414,51708,51713}},
    SHAMAN = {{16039,16035,16038,28996,30160,16040,16164,16089,16086,29062,28999,16041,30664,30672,16578,16166,51483,63370,51466,30675,51474,30706,51480,62097,51490}, {16259,16043,17485,16258,16255,16262,16261,16266,43338,16254,16256,16252,29192,16268,51883,30802,29082,63373,30816,30798,17364,51525,60103,51521,30812,30823,51523,51528,51533}, {16182,16173,16184,29187,16179,16180,16181,55198,16176,16187,16194,29206,16188,30864,16178,30881,16190,51886,51554,30872,30867,51556,974,51560,51562,61295}},
    WARLOCK = {{18827,18174,17810,18179,18213,18182,17804,53754,17783,18288,18218,18094,32381,32385,63108,18223,54037,18271,47195,30060,18220,30054,32477,47198,30108,58435,47201,48181}, {18692,18694,18697,47230,18703,18705,18731,18754,19028,18708,30143,18769,18709,30326,18767,23785,47245,30319,47193,35691,30242,63156,54347,30146,63117,47236,59672}, {17793,17788,18119,63349,17778,18126,17877,17959,18135,17917,17927,34935,17815,18130,30299,17954,17962,30293,18096,30288,54117,47258,30283,47220,47266,50796}},
    WARRIOR = {{12282,16462,12286,12285,12300,12295,12290,12296,16493,12834,12163,56636,12700,12328,12284,12281,20504,12289,46854,29834,12294,46865,12862,64976,35446,46859,29723,29623,29836,46867,46924}, {61216,12321,12320,12324,12322,12329,12323,16487,12318,23584,20502,12317,29590,12292,29888,20500,12319,46908,23881,29721,46910,29759,60970,29801,46913,56927,46917}, {12301,12298,12287,50685,12297,12975,12797,29598,12299,59088,12313,12308,12312,12809,12311,16538,29593,50720,29787,29140,46945,57499,20243,47294,46951,58872,46968}}
}

function RaidCluster:genTalentDropdown(single_class)
    local talent_types_specific = {}
    if single_class and self.talents_ids[single_class] then
        for tab = 1, #self.talents_ids[single_class] do
            for _, talentId in ipairs(self.talents_ids[single_class][tab]) do
                local spellName, _, spellIcon = GetSpellInfo(talentId)
                if spellName and spellIcon then
                    talent_types_specific[talentId] = ("|T%s:24|t %s"):format(spellIcon, spellName)
                end
            end
        end
    end
    return talent_types_specific
end

function RaidCluster:FindTalentPosition(className, talentID)
    for specIndex, specTalents in ipairs(self.talents_ids[className]) do
        for talentIndex, currentTalentID in ipairs(specTalents) do
            if currentTalentID == talentID then
                local _, _, _, _, rank = GetTalentInfo(specIndex, talentIndex)
                return rank > 0
            end
        end
    end
    return false
end

function RaidCluster:GetClassColor(classFilename)
    local defaultColor = 1
    local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[classFilename]
    if color and color.r and color.g and color.b then
        return color.r, color.g, color.b, defaultColor
    end
    -- Fallback CustomColor
    local dbColor = db and db.color
    if dbColor and dbColor.r and dbColor.g and dbColor.b then
        return dbColor.r, dbColor.g, dbColor.b, defaultColor
    end
    -- Fallback WhiteColor
    return defaultColor, defaultColor, defaultColor, defaultColor
end

function RaidCluster:GetSpellLink(id)
    return (GetSpellLink(id) or ""):gsub("[%[%]]", "")
end

function RaidCluster:ResetActions()
    for key, _ in pairs(self.Action) do
        self.Action[key] = false
    end
end

function RaidCluster:tableFind(tbl, item)
    for index, value in ipairs(tbl) do
        if value == item then
            return index
        end
    end
    return nil
end

--  Map Sizes
RaidCluster.MapSizes = {}

-- RegisterMaps
function RaidCluster:RegisterMapSize(zone, ...)
	if not self.MapSizes[zone] then
		self.MapSizes[zone] = {}
	end
	for i = 1, select("#", ...), 3 do
		local level, width, height = select(i, ...)
		self.MapSizes[zone][level] = {width, height}
	end
end

function RaidCluster:RegisterMaps()
    --  MapSizes
    self:RegisterMapSize("AhnQiraj",				-- Ahn'Qiraj 40 (Raid-Classic)
        1, 2777.544113162, 1851.6962890599989,
        2, 977.55993651999984, 651.70654296999965,
        3, 577.5600585899997, 385.04003906999969
    )
    self:RegisterMapSize("Ahnkahet",				1, 972.417968747, 648.27902221699992) -- Ahn'Kahet (Party-WotLK)
    self:RegisterMapSize("Alterac",				0, 2799.9999389679997, 1866.666656494)
    self:RegisterMapSize("AlteracValley",		0, 4237.49987793, 2824.99987793)
    self:RegisterMapSize("Arathi",				0, 3599.999877933, 2399.999923703)
    self:RegisterMapSize("ArathiBasin",			0, 1756.249923703, 1170.83325195)
    self:RegisterMapSize("Ashenvale",			0, 5766.6663818399993, 3843.749877933)
    self:RegisterMapSize("Aszhara",				0, 5070.83276368, 3381.24987793)
    self:RegisterMapSize("AuchenaiCrypts",		-- Auchenai Crypts (Party-BC)
        1, 742.54043579099994, 495.026992798,
        2, 817.540466309, 545.026992798
    )
    self:RegisterMapSize("Azeroth",				0, 40741.1816406, 27149.6875)
    self:RegisterMapSize("AzjolNerub",				-- Azjol-Nerub (Party-WotLK)
        1, 752.973999023, 501.983001709,			-- The Brood Pit
        2, 292.97399902300003, 195.31597900399998,	-- Hadronox's Lair
        3, 367.5, 245								-- The Gilded Gate
    )
    self:RegisterMapSize("AzuremystIsle",		0, 4070.8330078, 2714.58300781)
    self:RegisterMapSize("Badlands",				0, 2487.5, 1658.3334961)
    self:RegisterMapSize("Barrens",				0, 10133.33300782, 6756.24987793)
    self:RegisterMapSize("BlackTemple",			-- Black Temple (Raid-BC). Has DungeonUsesTerrainMap()
        0, 783.333343506, 522.916625977,
        1, 1252.2495784784999, 834.833007813,
        2, 975, 650,
        3, 1005, 670,
        4, 440.000976562, 293.333984375,
        5, 670, 446.66668701599986,
        6, 705, 470,
        7, 355, 236.66662597599998
    )
    self:RegisterMapSize("BlackfathomDeeps",		-- Blackfathom Deeps (Party-Classic)
        1, 884.22000122000009, 589.4799728391,
        2, 884.220031738, 589.480010986,
        3, 284.22400426826, 189.48266601600005
    )
    self:RegisterMapSize("BlackrockDepths",		-- Blackrock Depths (Party-Classic)
        1, 1407.060974121, 938.040756224,
        2, 1507.060974121, 1004.7074279820001
    )
    self:RegisterMapSize("BlackrockSpire",		-- Blackrock Spire (Party-Classic)
        1, 886.8390140532, 591.22601318400007,
        2, 886.8390140532, 591.22601318400007,
        3, 886.8390140532, 591.22601318400007,
        4, 886.8390140532, 591.22601318400007,
        5, 886.8390140532, 591.22601318400007,
        6, 886.8390140532, 591.22601318400007,
        7, 886.8390140532, 591.22601318400007
    )
    self:RegisterMapSize("BlackwingLair",		-- Blackwing Lair (Raid-Classic)
        1, 499.42803955299996, 332.94970702999944,
        2, 649.42706299, 432.94970702999944,
        3, 649.42706299, 432.94970702999944,
        4, 649.42706299, 432.94970702999944
    )
    self:RegisterMapSize("BladesEdgeMountains",	0, 5424.9997558600007, 3616.666381833)
    self:RegisterMapSize("BlastedLands",			0, 3349.99987793, 2233.3339844)
    self:RegisterMapSize("BloodmystIsle",		0, 3262.4990233999997, 2174.9999389619998)
    self:RegisterMapSize("BoreanTundra",			0, 5764.5830078100007, 3843.74987793)
    self:RegisterMapSize("BurningSteppes",		0, 2929.166595456, 1952.0834960900011)
    self:RegisterMapSize("CoTHillsbradFoothills", -- Caverns of Time: Old Hillsbrad Foothils (Party-BC)
        0, 2331.2499389679997, 1554.16662597
    )
    self:RegisterMapSize("CoTMountHyjal",		0, 2499.99975586, 1666.6665039)
    self:RegisterMapSize("CoTStratholme",		-- The Culling of Stratholme (Party-WotLK) ; API returns levels 1 and 2 - this is corrected with DungeonUsesTerrainMap()
        0, 1824.999938962, 1216.6665039099998,	-- DUNGEON_FLOOR_COTSTRATHOLME0 = "The Road to Stratholme"
        1, 1125.2999877910001, 750.1999511700003-- DUNGEON_FLOOR_COTSTRATHOLME1 = "Stratholme City"
    )
    self:RegisterMapSize("CoTTheBlackMorass",	-- Caverns of Time: The Black Morass (Party-BC)
        0, 1087.5, 725
    )
    self:RegisterMapSize("CoilfangReservoir",	-- Coilfang: Serpentshrine Cavern (Raid-BC)
        1, 1575.002975463, 1050.00201416
    )
    self:RegisterMapSize("CrystalsongForest",	0, 2722.91662598, 1814.5830078099998)
    self:RegisterMapSize("Dalaran",
        1, 830.01501465299987, 553.33984375,
        2, 563.223999023, 375.48974609000015
    )
    self:RegisterMapSize("Darkshore",			0, 6549.99975586, 4366.6665039000009)
    self:RegisterMapSize("Darnassis",			0, 1058.3332519500002, 705.72949223999967)
    self:RegisterMapSize("DeadwindPass",			0, 2499.9999389619998, 1666.6669921699995)
    self:RegisterMapSize("DeeprunTram",
        1, 312, 208,
        2, 309, 208
    )
    self:RegisterMapSize("Desolace",				0, 4495.83300781, 2997.916564938)
    self:RegisterMapSize("DireMaul",				-- Dire Maul (Party-Classic)
        1, 1275, 850,
        2, 525, 350,
        3, 487.5, 325,
        4, 750, 500,
        5, 800.0008010864, 533.33399963400007,
        6, 975, 650
    )
    self:RegisterMapSize("Dragonblight",			0, 5608.33312988, 3739.58337402)
    self:RegisterMapSize("DrakTharonKeep",		-- Drak'Tharon Keep (Party-WotLK)
        1, 619.94100952200006, 413.293991089,	-- The Vestibules of Drak'Tharon
        2, 619.941009526, 413.293991089			-- Drak'Tharon Overlook
    )
    self:RegisterMapSize("DunMorogh",			0, 4924.99975586, 3283.33325196)
    self:RegisterMapSize("Durotar",				0, 5287.4996337899993, 3524.99987793)
    self:RegisterMapSize("Duskwood",				0, 2699.9999389679997, 1799.9999999699994)
    self:RegisterMapSize("Dustwallow",			0, 5250.000061035, 3499.99975586)
    self:RegisterMapSize("EasternPlaguelands",	0, 4031.25, 2687.49987793)
    self:RegisterMapSize("Elwynn",				0, 3470.83325196, 2314.58300779)
    self:RegisterMapSize("EversongWoods" ,		0, 4925, 3283.33300779)
    self:RegisterMapSize("Expansion01",			0, 17464.078125, 11642.71875) -- Old client Zangarmarsh BC dungeons. HD client fixes mapInfo
    self:RegisterMapSize("Felwood",				0, 5749.9996337899993, 3833.33325195)
    self:RegisterMapSize("Feralas",				0, 6949.99975586, 4633.33300781)
    self:RegisterMapSize("Ghostlands",			0, 3300.0000000000009, 2199.9995117200006)
    self:RegisterMapSize("Gnomeregan",			-- Gnomeregan (Party-Classic)
        1, 769.667999268, 513.111999512,
        2, 769.6679992678, 513.111999512,
        3, 869.667999268, 579.778015137,
        4, 869.6697082523001, 579.77999877899992
    )
    self:RegisterMapSize("GrizzlyHills",			0, 5249.99987793, 3499.99987793)
    self:RegisterMapSize("GruulsLair",			-- Gruul's Lair (Raid-BC)
        1, 525, 350
    )
    self:RegisterMapSize("Gundrak",				-- Gundrak (Party-WotLK)
        1, 905.033050542, 603.3500976600003
    )
    self:RegisterMapSize("HallsofLightning",			-- Halls of Lightning (Party-WotLK)
        1, 566.235015869, 377.4899902300001,		-- Unyielding Garrison
        2, 708.23701477000009, 472.16003417699994	-- Walk of the Makers
    )
    self:RegisterMapSize("HallsofReflection",	-- Halls of Reflection (Party-WotLK)
        1, 879.02001954, 586.0195312399992
    )
    self:RegisterMapSize("Hellfire",				0, 5164.58300781, 3443.74987793)
    self:RegisterMapSize("HellfireRamparts",		-- Hellfire Citadel: Ramparts (Party-BC)
        1, 694.5600586, 463.04003906
    )
    self:RegisterMapSize("Hilsbrad",				0, 3199.99987793, 2133.33325195)
    self:RegisterMapSize("Hinterlands",			0, 3850, 2566.66662598)
    self:RegisterMapSize("HowlingFjord",			0, 6045.8328857399993, 4031.249816898)
    self:RegisterMapSize("HrothgarsLanding",		0, 3677.083129887, 2452.0839843699996)
    self:RegisterMapSize("IcecrownCitadel",			-- Icecrown Citadel (Raid-WotLK)
        1, 1355.47009278, 903.647033691,			-- The Lower Citadel
        2, 1067, 711.3336906438,					-- The Rampart of Skulls
        3, 195.46997069999998, 130.315002441,		-- Deathbringer's Rise
        4, 773.71008301000006, 515.81030273000033,	-- The Frost Queen's Lair
        5, 1148.7399902399998, 765.82006835999982,	-- The Upper Reaches
        6, 373.7099609400002, 249.1298828099998,	-- Royal Quarters
        7, 293.2600097699999, 195.50701904200002,	-- The Frozen Throne
        8, 247.92993164000018, 165.287994385		-- Frostmourne
    )
    self:RegisterMapSize("IcecrownGlacier",		0, 6270.833312988, 4181.2500000000009)
    self:RegisterMapSize("Ironforge",			0, 790.625061031, 527.6044921900002)
    self:RegisterMapSize("IsleofConquest",		0, 2650, 1766.6665840118)
    self:RegisterMapSize("Kalimdor",				0, 36799.8105469, 24533.2001953)
    self:RegisterMapSize("Karazhan",				-- Karazhan (Raid-BC)
        1, 550.04882811999983, 366.69921880000038,
        2, 257.85986329, 171.90625,
        3, 345.1494140599998, 230.09960940000019,
        4, 520.04882811999983, 346.69921880000038,
        5, 234.14990233999993, 156.09960940000019,
        6, 581.54882811999983, 387.69921880000038,
        7, 191.54882811999983, 127.69921880000038,
        8, 139.35058593999997, 92.90039059999981,
        9, 760.04882811999983, 506.69921880000038,
        10, 450.25, 300.16601559999981,
        11, 271.05004882999992, 180.69921880000038,
        12, 595.04882811999983, 396.69921880000038,
        13, 529.04882812, 352.69921880000038,
        14, 245.25, 163.5,
        15, 211.14990233999993, 140.765625,
        16, 101.25, 67.5,
        17, 341.24999999999977, 227.5
    )
    self:RegisterMapSize("LakeWintergrasp",		0, 2974.99987793, 1983.3332519599999)
    self:RegisterMapSize("LochModan",			0, 2758.33312988, 1839.5830078099998)
    self:RegisterMapSize("MagistersTerrace",	-- Magister's Terrace (Party-BC)
        1, 530.334014893, 353.5559692383,
        2, 530.334014893, 353.5559921261
    )
    self:RegisterMapSize("MagtheridonsLair",	-- Magtheridon's Lair (Raid-BC)
        1, 556, 370.666694641
    )
    self:RegisterMapSize("Mana-Tombs",		-- Mana-Tombs (Party-BC)
        1, 823.28515625, 548.85681152329994
    )
    self:RegisterMapSize("Maraudon",			-- Maraudon (Party-Classic)
        1, 975, 650,
        2, 1637.5, 1091.666000367
    )
    self:RegisterMapSize("MoltenCore",		-- Molten Core (Raid-Classic)
        1, 1264.800064083, 843.19906615799994
    )
    self:RegisterMapSize("Moonglade",			0, 2308.33325195, 1539.5830078200006)
    self:RegisterMapSize("Mulgore",				0, 5137.49987793, 3424.9998474159997)
    self:RegisterMapSize("Nagrand",				0, 5524.99999999, 3683.3331680335)
    self:RegisterMapSize("Naxxramas",			-- Naxxramas (Raid-WotLK)
        1, 1093.83007813, 729.21997070999987,	-- The Construct Quarter
        2, 1093.83007813, 729.21997070999987,	-- The Arachnid Quarter
        3, 1200, 800,							-- The Military Quarter
        4, 1200.33007813, 800.21997070999987,	-- The Plague Quarter
        5, 2069.80981445, 1379.8798828099998,	-- The Lower Necropolis
        6, 655.9399414, 437.2900390599998		-- The Upper Necropolis
    )
    self:RegisterMapSize("Netherstorm",			0, 5574.9996719334995, 3716.66674805)
    self:RegisterMapSize("NetherstormArena",		0, 2270.8331909219996, 1514.58337402)
    self:RegisterMapSize("Nexus80",					-- The Oculus (Party-WotLK)
        1, 514.70697021699993, 343.13897705299996,	-- Band of Variance
        2, 664.70697021699993, 443.13897705299996,	-- Band of Acceleration
        3, 514.70697021699993, 343.13897705299996,	-- Band of Transmutation
        4, 294.70098877199996, 196.46398926100017	-- Band of Alignment
    )
    self:RegisterMapSize("Northrend",			0, 17751.3984375, 11834.26501465)
    self:RegisterMapSize("Ogrimmar",				0, 1402.6044921899997, 935.41662598000016)
    self:RegisterMapSize("OnyxiasLair",			-- Onyxia's Lair (Raid-WotLK)
        1, 483.117988587, 322.07878875759997
    )
    self:RegisterMapSize("PitofSaron",			0, 1533.333312988, 1022.916671753) -- Pit of Saron (Party-WotLK)
    self:RegisterMapSize("Ragefire",				-- Ragefire Chasm (Party-Classic)
        1, 738.864013672, 492.57620239290003
    )
    self:RegisterMapSize("RazorfenDowns",		-- Razorfen Downs (Party-Classic)
        1, 709.048950199, 472.69995117000008
    )
    self:RegisterMapSize("RazorfenKraul",		-- Razorfen Kraul (Party-Classic)
        1, 736.44995118, 490.95983886999988
    )
    self:RegisterMapSize("Redridge",				0, 2170.83325196, 1447.9160155999998)
    self:RegisterMapSize("RuinsofAhnQiraj",		0, 2512.499877933, 1675) -- Ahn'Qiraj 20 (Raid-Classic)

    self:RegisterMapSize("ScarletEnclave",		0, 3162.5, 2108.333374023)
    self:RegisterMapSize("ScarletMonastery",		-- Scarlet Monastery (Party-Classic)
        1, 619.983947751, 413.32275390000018,
        2, 320.190994263, 213.4604949947,
        3, 612.6966094966, 408.45996094,
        4, 703.30004882, 468.86669921500004
    )
    self:RegisterMapSize("Scholomance",			-- Scholomance (Party-Classic)
        1, 320.0489044188, 213.364997864,
        2, 440.04901123, 293.3664054871,
        3, 410.0779953, 273.3857994075,
        4, 531.04200744700006, 354.0281982418
    )
    self:RegisterMapSize("SearingGorge",			0, 2231.2498474159997, 1487.4995117199996)
    self:RegisterMapSize("SethekkHalls",			-- Auchindoun: Sethekk Halls (Party-BC)
        1, 703.495483399, 468.996994019,
        2, 703.495483399, 468.996994019
    )
    self:RegisterMapSize("ShadowLabyrinth",		-- Shadow Labyrinth (Party-BC)
        1, 841.522354126, 561.0148887639
    )
    self:RegisterMapSize("ShadowfangKeep",		-- Shadowfang Keep (Party-Classic)
        1, 352.43005371000004, 234.95339202830002,
        2, 212.42675781000025, 141.617996216,
        3, 152.42993164000018, 101.6199646001,
        4, 152.42993164000018, 101.6246948243,
        5, 152.42993164000018, 101.6246948243,
        6, 198.42993164000018, 132.2866287233,
        7, 272.42993164000018, 181.6199646001
    )
    self:RegisterMapSize("ShadowmoonValley",		0, 5500, 3666.66638183)
    self:RegisterMapSize("ShattrathCity",		0, 1306.25, 870.83337403)
    self:RegisterMapSize("SholazarBasin",		0, 4356.25, 2904.16650391)
    self:RegisterMapSize("Silithus",				0, 3483.333984375, 2322.9160156199996)
    self:RegisterMapSize("SilvermoonCity",		0, 1211.4584960900002, 806.77050783999948)
    self:RegisterMapSize("Silverpine",			0, 4199.99975586, 2799.99987793)
    self:RegisterMapSize("StonetalonMountains",	0, 4883.33312988, 3256.249816898)
    self:RegisterMapSize("Stormwind",			0, 1737.4999589954, 1158.3330078200006)
    self:RegisterMapSize("StrandoftheAncients",	0, 1743.749938965, 1162.499938962)
    self:RegisterMapSize("Stranglethorn",		0, 6381.24975586, 4254.1660156)
    self:RegisterMapSize("Stratholme",			-- Stratholme (Party-Classic)
        1, 705.7199707, 470.4799804700001,
        2, 1005.7204589799999, 670.48022460999982
    )
    self:RegisterMapSize("Sunwell",				0, 3327.0830078200006, 2218.7490233999997)
    self:RegisterMapSize("SunwellPlateau",		-- The Sunwell (Raid-BC)
        0, 906.25, 604.16662597999994,
        1, 465, 310
    )
    self:RegisterMapSize("SwampOfSorrows",		0, 2293.75, 1529.1669921899993)
    self:RegisterMapSize("Tanaris",				0, 6899.999526979, 4600)
    self:RegisterMapSize("Teldrassil",			0, 5091.6665039, 3393.75)
    self:RegisterMapSize("TempestKeep",			-- Tempest Keep (Raid-BC)
        1, 1575, 1050
    )
    self:RegisterMapSize("TerokkarForest",		0, 5399.99975586, 3600.000061035)
    self:RegisterMapSize("TheArcatraz",			-- Tempest Keep: The Arcatraz (Party-BC)
        1, 689.68402099600007, 459.78935241700003,
        2, 546.048049927, 364.032012939,
        3, 636.684005737, 424.45602417
    )
    self:RegisterMapSize("TheArgentColiseum",	-- Trial of the Crusader (Raid-WotLK)
        1, 369.9861869814, 246.657989502,		-- The Argent Coliseum
        2, 739.996017456, 493.33001709			-- The Icy Depths
    )
    self:RegisterMapSize("TheBloodFurnace",		-- Hellfire Citadel: The Blood Furnace (Party-BC)
        1, 1003.519012451, 669.012687683
    )
    self:RegisterMapSize("TheBotanica",			-- Tempest Keep: The Botanica (Party-BC)
        1, 757.40248107899993, 504.934997558
    )
    self:RegisterMapSize("TheDeadmines",			-- Deadmines (Party-Classic)
        1, 559.2640075679999, 372.8425025944,
        2, 499.26300049099996, 332.84230041549995
    )
    self:RegisterMapSize("TheExodar",			0, 1056.7705078, 704.68774414000018)
    self:RegisterMapSize("TheEyeofEternity",		-- The Eye of Eternity (Raid-WotLK)
        1, 430.07006836000005, 286.713012695
    )
    self:RegisterMapSize("TheForgeofSouls",		-- The Forge of Souls (Party-WotLK)
        1, 1448.0998535099998, 965.40039062000051
    )
    self:RegisterMapSize("TheMechanar",			-- Tempest Keep: The Mechanar (Party-BC)
        1, 676.23800659199992, 450.825401306,
        2, 676.23800659199992, 450.8253669737
    )
    self:RegisterMapSize("TheNexus",				1, 1101.280975342, 734.1874999997) -- The Nexus (Party-WotLK)
    self:RegisterMapSize("TheObsidianSanctum",	0, 1162.4999179809, 775) -- The Obsidian Sanctum (Raid-WotLK)
    self:RegisterMapSize("TheRubySanctum",		0, 752.083312988, 502.08325195999987) -- The Ruby Sanctum (Raid-WotLK)
    self:RegisterMapSize("TheShatteredHalls",	1, 1063.747467041, 709.1649932866) -- Hellfire Citadel: The Shattered Hall (Party-BC)
    self:RegisterMapSize("TheSlavePens",			1, 890.05812454269994, 593.372070312) -- Coilfang: The Slave Pens (Party-BC)
    self:RegisterMapSize("TheSteamvault",		-- Coilfang: The Steamvault (Party-BC)
        1, 876.764007569, 584.509414673,
        2, 876.764007569, 584.509414673
    )
    self:RegisterMapSize("TheStockade",			1, 378.152999878, 252.10249519299998) -- Stormwind Stockade (Party-Classic)
    self:RegisterMapSize("TheStormPeaks",		0, 7112.4996337899993, 4741.6660156)
    self:RegisterMapSize("TheTempleOfAtalHakkar",	-- Sunken Temple (Party-Classic)
        1, 695.028991699, 463.35298156799996,
        2, 248.1767673494, 166.03546142599998,
        3, 556.16923522999991, 370.38801574700005
    )
    self:RegisterMapSize("TheUnderbog",			1, 894.919998169, 596.613357544) -- Coilfang: The Underbog (Party-BC)
    self:RegisterMapSize("ThousandNeedles",		0, 4399.999694822, 2933.33300781)
    self:RegisterMapSize("ThunderBluff",			0, 1043.749938965, 695.833312985)
    self:RegisterMapSize("Tirisfal",				0, 4518.74987793, 3012.4998168949996)
    self:RegisterMapSize("Uldaman",				-- Uldaman (Party-Classic)
        1, 893.668014527, 595.778991699,
        2, 492.57041931180004, 328.3804931642
    )
    self:RegisterMapSize("Ulduar",				-- Ulduar (Raid-WotLK). Has DungeonUsesTerrainMap()
        0, 3287.49987793, 2191.66662598,			-- DUNGEON_FLOOR_ULDUAR0 = "The Grand Approach"
        1, 669.45098877000009, 446.30004882999992,	-- DUNGEON_FLOOR_ULDUAR1 = "The Antechamber of Ulduar"
        2, 1328.4609985349998, 885.63989258000015,	-- DUNGEON_FLOOR_ULDUAR2 = "The Inner Sanctum of Ulduar"
        3, 910.5, 607,								-- DUNGEON_FLOOR_ULDUAR3 = "The Prison of Yogg-Saron"
        4, 1569.45996094, 1046.30004883,			-- DUNGEON_FLOOR_ULDUAR4 = "The Spark of Imagination"
        5, 619.46899414, 412.9799804700001			-- DUNGEON_FLOOR_ULDUAR5 = "The Mind's Eye"
    )
    self:RegisterMapSize("Ulduar77",				1, 920.19601440299994, 613.466064453) -- Halls of Stone (Party-WotLK)
    self:RegisterMapSize("Undercity",			0, 959.37503051749991, 640.10412597999994)
    self:RegisterMapSize("UngoroCrater",			0, 33699.999816898, 2466.6665039000009)
    self:RegisterMapSize("UtgardeKeep",		-- Utgarde Keep (Party-WotLK)
        1, 734.580993652, 489.72150039639996,	-- Norndir Preperation
        2, 481.081008911, 320.72029304480003,	-- Dragonflayer Ascent
        3, 736.581008911, 491.05451202409995	-- Tyr's Terrace
    )
    self:RegisterMapSize("UtgardePinnacle",		-- Utgarde Pinnacle (Party-WotLK)
        1, 548.93601989699994, 365.95701599100005,	-- Lower Pinnacle
        2, 756.17994308428, 504.11900329599996		-- Upper Pinnacle
    )
    self:RegisterMapSize("VaultofArchavon",		1, 1398.2550048829999, 932.170013428) -- Vault of Archavon (Raid-WotLK)
    self:RegisterMapSize("VioletHold",			1, 256.229003907, 170.82006836000005) -- The Violet Hold (Raid-WotLK)
    self:RegisterMapSize("WailingCaverns",		1, 936.47500610299994, 624.315994263) -- Wailing Caverns (Party-Classic)
    self:RegisterMapSize("WarsongGulch",			0, 1145.833312992, 764.583312985)
    self:RegisterMapSize("WesternPlaguelands",	0, 4299.999908444, 2866.666534428)
    self:RegisterMapSize("Westfall",				0, 3499.999816898, 2333.3330078)
    self:RegisterMapSize("Wetlands",				0, 4135.416687012, 2756.25)
    self:RegisterMapSize("Winterspring",			0, 7099.999847416, 4733.3332519500009)
    self:RegisterMapSize("Zangarmarsh",			0, 5027.08349609, 3352.08325196)
    self:RegisterMapSize("ZulAman",				0, 1268.749938962, 845.833312988) -- Zul'Aman (Raid-BC)
    self:RegisterMapSize("ZulDrak",				0, 4993.75, 3329.16650391)
    self:RegisterMapSize("ZulFarrak",			0, 1383.3332214359998, 922.91662597) -- Zul'Farrak (Party-Classic)
    self:RegisterMapSize("ZulGurub",				0, 2120.83325195, 1414.5830078) -- Zul'Gurub (Raid-Classic)
end

function RaidCluster:GetMapSize()
	local mapName = GetMapInfo()
	local level = GetCurrentMapDungeonLevel()
	local usesTerrainMap = DungeonUsesTerrainMap()
	level = usesTerrainMap and level - 1 or level
	local dims = self.MapSizes[mapName] and self.MapSizes[mapName][level]
	return dims[1], dims[2]
end

function RaidCluster:MapZoneChanged()
    self.mapX, self.mapY = self:GetMapSize()
end

function RaidCluster:GetUnitRange(x1, y1, x2, y2)
    local rangeX, rangeY = (x2 - x1) * self.mapX, (y2 - y1) * self.mapY
    local range = (rangeX * rangeX + rangeY * rangeY) ^ 0.5
    return range
end

function RaidCluster:CreateAnchorFrame()
    local f = CreateFrame("Frame", "RaidCluster Anchor")
    f:SetWidth(0)
    f:SetHeight(0)
    f:SetPoint("BOTTOMLEFT", -200, -200)
    f:SetFrameStrata("MEDIUM")
    f:SetFrameLevel(20)
    f:EnableMouse(false)
    f:EnableKeyboard(false)
    f:EnableMouseWheel(false)
    f:EnableJoystick(false)
    f:Show()
    self.parent = f
    return f
end

function RaidCluster:CreateCounterTextString(f, i)
    local frameName = "RaidClusterCounter" .. i
    f.text = f:CreateFontString(frameName, "OVERLAY", "GameFontWhite")
    f.text:SetFont(LSM:Fetch("font", db.font), db.fontSize, db.fontFlags)
    f.text:SetText("")
    f.text:SetTextColor(db.color.r, db.color.g, db.color.b, db.color.a)
    f.text:SetPoint("CENTER", db.x, db.y)

    self.frames[frameName] = {
        frame = f.text,
        inUse = false
    }
end

function RaidCluster:GetUnusedString() -- Get next Free Text
    for frameName, data in pairs(self.frames) do
        if not data.inUse then
            return self.frames[frameName].frame, frameName
        end
    end
    return nil
end

function RaidCluster:FrameReseter() -- Frame reseter
    if next(self.frames) ~= nil then
        for _, data in pairs(self.frames) do
            data.frame:Hide()
            data.frame:SetText("")
            data.frame:SetTextColor(db.color.r, db.color.g, db.color.b, db.color.a)
            data.frame:SetParent(self.parent)
            data.frame:SetPoint("CENTER", self.parent, "CENTER", 0, 0)
            data.inUse = false
        end
    end
end

function RaidCluster:UpdateFrames(results, bool)
    if next(self.currentframes) == nil then return end
    local subGroupBool = db.subGroup
    for unit, count in pairs(results) do
        local frame, subGroup = self.currentframes[unit] and self.currentframes[unit].frame, self.currentframes[unit] and self.currentframes[unit].subGroup
        if subGroupBool and subGroup and subGroup > 5 then
            --immitate continue
        else
            if frame then
                count = bool and tostring(#count - 1) or tostring(count)
                frame:SetText(count)
                frame:Show()
            end
        end
    end
end

function RaidCluster:HidePlayerText(PlayerName) -- Hide Text for a single Player
    if self.currentframes and next(self.currentframes) ~= nil then
        local frameData = self.currentframes[PlayerName] and self.currentframes[PlayerName].frame
        if frameData and frameData:IsShown() then
            frameData:Hide()
            frameData:SetText("")
        end
    end
end

function RaidCluster:GetPlayerPositions(Members)
    local playerPositions = {}
    for i = 1, Members do
        local unit = "raid" .. i
        local unitName = UnitName(unit)
        if unitName then
            if UnitIsConnected(unit) and UnitIsVisible(unit) and (not UnitIsDeadOrGhost(unit)) then
                local x, y = GetPlayerMapPosition(unit)
                if x and y then
                    playerPositions[unitName] = { x = x, y = y }
                else
                    self:HidePlayerText(unitName)
                end
            else
                self:HidePlayerText(unitName)
            end
        end
    end
    return playerPositions
end

function RaidCluster:GetPlayerPositionsLowHealth(Members)
    local playerPositions = {}
    for i = 1, Members do
        local unit = "raid" .. i
        local unitName = UnitName(unit)
        if unitName then
            if UnitIsConnected(unit) and UnitIsVisible(unit) and (not UnitIsDeadOrGhost(unit)) and UnitHealth(unit) < UnitHealthMax(unit) then
                local x, y = GetPlayerMapPosition(unit)
                if x and y then
                    playerPositions[unitName] = { x = x, y = y }
                else
                    self:HidePlayerText(unitName)
                end
            else
                self:HidePlayerText(unitName)
            end
        end
    end
    return playerPositions
end

function RaidCluster:GetPlayersChainedInRangeCount(playerPositions)
    local playersInRange = {}
    for unitA, positionA in pairs(playerPositions) do
        local playersInUnitARange = {}
        for unitB, positionB in pairs(playerPositions) do
            local distance = self:GetUnitRange(positionA.x, positionA.y, positionB.x, positionB.y)
            if distance <= self.Range then
                table.insert(playersInUnitARange, unitB)
            end
        end
        playersInRange[unitA] = playersInUnitARange
    end
    for unitA, unitsInRangeA in pairs(playersInRange) do
        for _, unitB in ipairs(unitsInRangeA) do
            for _, unitC in ipairs(playersInRange[unitB]) do
                if unitC ~= unitA and not self:tableFind(playersInRange[unitA], unitC) then
                    table.insert(playersInRange[unitA], unitC)
                end
            end
        end
    end
    return playersInRange
end

function RaidCluster:CalculateChainedPlayers()
    local Members = GetNumRaidMembers()
    if not Members or Members < 1 then return end
    local playerPositions = self:GetPlayerPositionsLowHealth(Members)
    local playersInRangeCount = self:GetPlayersChainedInRangeCount(playerPositions)
    self:UpdateFrames(playersInRangeCount, true)
end

function RaidCluster:GetPlayersInRangeCount(playerPositions)
    local playersInRangeCount = {}
    for unitA, positionA in pairs(playerPositions) do
        local playersInUnitARange = 0
        for unitB, positionB in pairs(playerPositions) do
            if unitA ~= unitB then
                local distance = self:GetUnitRange(positionA.x, positionA.y, positionB.x, positionB.y)
                if distance <= self.Range then
                    playersInUnitARange = playersInUnitARange + 1
                end
            end
        end
        playersInRangeCount[unitA] = playersInUnitARange
    end
    return playersInRangeCount
end

function RaidCluster:CalculatePlayersToPlayers()
    local Members = GetNumRaidMembers()
    if not Members or Members < 0 then return end
    local playerPositions = self:GetPlayerPositions(Members)
    local playersInRangeCount = self:GetPlayersInRangeCount(playerPositions)
    self:UpdateFrames(playersInRangeCount, false)
end

function RaidCluster:GetPlayersInGroupRangeCount(playerPositions)
    local groups = {}
    for playerName, position in pairs(playerPositions) do
        local group = self.currentframes[playerName] and self.currentframes[playerName].subGroup
        if group then
            groups[group] = groups[group] or {}
            table.insert(groups[group], { unitName = playerName, x = position.x, y = position.y })
        end
    end
    local playersInRangeCount = {}
    for _, players in pairs(groups) do
        for _, playerA in ipairs(players) do
            local playerName = playerA.unitName
            local playersInUnitARange = 0
            for _, playerB in ipairs(players) do
                local distance = self:GetUnitRange(playerA.x, playerA.y, playerB.x, playerB.y)
                if distance <= self.Range then
                    playersInUnitARange = playersInUnitARange + 1
                end
            end
            playersInRangeCount[playerName] = playersInUnitARange
        end
    end
    return playersInRangeCount
end

function RaidCluster:CalculateGroupPlayersToGroupPlayers()
    local Members = GetNumRaidMembers()
    if not Members or Members < 0 then return end
    local playerPositions = self:GetPlayerPositions(Members)
    local playersInRangeCount = self:GetPlayersInGroupRangeCount(playerPositions)
    self:UpdateFrames(playersInRangeCount, false)
end

function RaidCluster:ProcessPlayerFrame(playerName, subGroup, playerClass)
    local unusedString, frameName = self:GetUnusedString()
    if unusedString and frameName then
        local playerFrame = GetFrame(playerName) -- Get the Raidframe
        if playerFrame then
            unusedString:SetPoint("CENTER", playerFrame, "CENTER", db.x, db.y)
            if db.classColor then
                unusedString:SetTextColor(self:GetClassColor(playerClass))
            end
            self.frames[frameName].inUse = true
            self.currentframes[playerName] = {
                frame = unusedString,
                parent = playerFrame,
                subGroup = subGroup,
                class = playerClass
            }
        end
    end
end

function RaidCluster:ParentPlayerRaidFrames()
    self.currentframes = {}
    local Members = GetNumRaidMembers()
    if not Members or Members < 1 then return end

    for i = 1, Members do
        local playerName, _, subGroup, _, _, playerClass = GetRaidRosterInfo(i)
        if db.subGroup then
            if subGroup and subGroup <= 5 then
                self:ProcessPlayerFrame(playerName, subGroup, playerClass)
            end
        else
            self:ProcessPlayerFrame(playerName, subGroup, playerClass)
        end
    end
end

function RaidCluster:EventLock()
    self.eventLock = false
    self:MapZoneChanged()
    self:specDetection()
end

function RaidCluster:OnRosterUpdate()
    if RaidCluster.eventLock then return end
    self.eventLock = true
    self:StopAddon()
    self:ScheduleTimer("EventLock", 2)
end

function RaidCluster:OnFPSrefresh()
    if self.IsInit then
        if self.Action.PALADIN then
            self:CalculatePlayersToPlayers()
        elseif self.Action.SHAMAN then
            self:CalculateChainedPlayers()
        elseif self.Action.HPRIEST then
            self:CalculatePlayersToPlayers()
        elseif self.Action.DPRIEST then
            self:CalculateGroupPlayersToGroupPlayers()
        elseif self.Action.DRUID then
            self:CalculatePlayersToPlayers()
        end
    end
end

-- Prints Addon messages
function RaidCluster:ChatPrint(str)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(tostring(str)) end
end

function RaidCluster:ChangeApperance()
    if not db then return end
    -- Font, FontSize, FontFlags, FontColor
    if self.frames and next(self.frames) ~= nil then
        for _, data in pairs(self.frames) do
            if data.frame then
                data.frame:SetFont(LSM:Fetch("font", db.font), db.fontSize, db.fontFlags)
                if not db.classColor then
                    data.frame:SetTextColor(db.color.r, db.color.g, db.color.b, db.color.a)
                end
            end
        end
    end
    -- Postion and ClassColor
    if self.currentframes and next(self.currentframes) ~= nil then
        for _, data in pairs(self.currentframes) do
            if db.classColor then
                data.frame:SetTextColor(self:GetClassColor(data.class))
            end
            data.frame:SetPoint("CENTER", data.parent, "CENTER", db.x, db.y)
        end
    end
end

function RaidCluster:StartCLEU(Class)
    self.cleuIsInit = true
    self.CLEU:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.CLEU:SetScript("OnEvent", cleuFunctions[Class])
end

function RaidCluster:StopCLEU()
    self.cleuIsInit = false
    self.CLEU:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.CLEU:SetScript("OnEvent", nil)
end

function RaidCluster:StopAddon()
    self.IsInit = false
    self:CancelTimer(self.FPSTimer)
    self.EventHandler:UnregisterEvent("RAID_ROSTER_UPDATE")
    self.EventHandler:UnregisterEvent("ZONE_CHANGED")
    self.EventHandler:UnregisterEvent("ZONE_CHANGED_INDOORS")
    self.EventHandler:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
    self:StopCLEU()
    self:FrameReseter()
    self:ResetActions()
end

function RaidCluster:StartAddon(Class)
    self.IsInit = true
    if Class == "PALADIN" then
        self.Range = self.ClassRanges.PALADIN
        self.Action.PALADIN = true
    elseif Class  == "SHAMAN" then
        self.Range = self.ClassRanges.SHAMAN
        self.Action.SHAMAN = true
    elseif Class == "HPRIEST" then
        self.Range = self.ClassRanges.PRIEST[1]
        self.Action.HPRIEST = true
    elseif Class == "DPRIEST" then
        self.Range = self.ClassRanges.PRIEST[2]
        self.Action.DPRIEST = true
    elseif Class == "DRUID" then
        self.Range = self.ClassRanges.DRUID
        self.Action.DRUID = true
    end
    if next(self.frames) == nil then
        local f = RaidCluster:CreateAnchorFrame()
        local count = db.subGroup and self.frameCount[1] or self.frameCount[2]
        for i = 1, count do
            self:CreateCounterTextString(f, i)
        end
    end
    self:MapZoneChanged()
    self.EventHandler:RegisterEvent("ZONE_CHANGED")
    self.EventHandler:RegisterEvent("ZONE_CHANGED_INDOORS")
    self.EventHandler:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.EventHandler:RegisterEvent("RAID_ROSTER_UPDATE")
    self:ParentPlayerRaidFrames()
    self.FPSTimer = self:ScheduleRepeatingTimer("OnFPSrefresh", db.update or 1)
end

function RaidCluster:specDetection()
    if not (db or db.enabled or UnitInRaid("player")) then return end
    local Class = select(2, UnitClass("player"))
    if Class == "PALADIN" then
        local RaidFrame, PixelGlow = db.paladinRaidFrameEnable, db.paladinPixelGlowEnable
        if not (RaidFrame or PixelGlow) then return end
        local talents = self:FindTalentPosition(Class, db.paladinTalents)
        if talents then
            if (not self.cleuIsInit) and PixelGlow then
                self:StartCLEU(Class)
            end
            if (not self.IsInit) and RaidFrame then
                self:StartAddon(Class)
            end
        else
            if self.IsInit then
                self:StopAddon()
            end
            if self.cleuIsInit then
                self:StopCLEU()
            end
        end
    elseif Class == "SHAMAN" then
        local RaidFrame, PixelGlow = db.shamanRaidFrameEnable, db.shamanPixelGlowEnable
        if not (RaidFrame or PixelGlow) then return end
        local talents = self:FindTalentPosition(Class, db.shamanTalents)
        if talents then
            if (not self.cleuIsInit) and PixelGlow then
                self:StartCLEU(Class)
            end
            if (not self.IsInit) and RaidFrame then
                self:StartAddon(Class)
            end
        else
            if self.IsInit then
                self:StopAddon()
            end
            if self.cleuIsInit then
                self:StopCLEU()
            end
        end
    elseif Class == "PRIEST" then
        local hRaidFrame, hPixelGlow, dRaidFrame, dPixelGlow = db.holyPriestRaidFrameEnable, db.discoPriestRaidFrameEnable,db.holyPriestPixelGlowEnable, db.discoPriestPixelGlowEnable
        if not (hRaidFrame or hPixelGlow) and not (dRaidFrame or dPixelGlow) then return end
        local htalents = self:FindTalentPosition(Class, db.holyPriestTalents)
        local dtalents = self:FindTalentPosition(Class, db.discoPriestTalents)
        if htalents then
            if (not self.cleuIsInit) and hPixelGlow then
                self:StartCLEU("HPRIEST")
            end
            if (not self.IsInit) and hRaidFrame then
                self:StartAddon("HPRIEST")
            end
        elseif dtalents then
            if (not self.cleuIsInit) and dPixelGlow then
                self:StartCLEU("DPRIEST")
            end
            if (not self.IsInit) and dRaidFrame then
                self:StartAddon("DPRIEST")
            end
        else
            if self.IsInit then
                self:StopAddon()
            end
            if self.cleuIsInit then
                self:StopCLEU()
            end
        end
    elseif Class == "DRUID" then
        local RaidFrame, PixelGlow = db.druidRaidFrameEnable, db.druidPixelGlowEnable
        if not (RaidFrame or PixelGlow) then return end
        local talents = self:FindTalentPosition(Class, db.druidTalents)
        if talents then
            if (not self.cleuIsInit) and PixelGlow then
                self:StartCLEU(Class)
            end
            if (not self.IsInit) and RaidFrame then
                self:StartAddon(Class)
            end
        else
            if self.IsInit then
                self:StopAddon()
            end
            if self.cleuIsInit then
                self:StopCLEU()
            end
        end
    end
end

function RaidCluster:OnProfileChanged()
    self:StopAddon()
    db = self.db.profile
    self:ChangeApperance()
    self:specDetection()
end

local defaults = {
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

local options = {
    type = "group",
    name = "Raid Cluster",
    args = {
        github = {
            type = "header",
            name = "Github: |c007289d9https://github.com/NoM0Re/RaidCluster|r",
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
                        RaidCluster:StopAddon()
                        RaidCluster:specDetection()
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

-- Event Handler
local function EventHandler(self, event, ...)
    if (event == "RAID_ROSTER_UPDATE") or (event == "PARTY_MEMBERS_CHANGED") then
        RaidCluster:OnRosterUpdate()
    elseif (event == "ZONE_CHANGED") or (event == "ZONE_CHANGED_INDOORS") or (event == "ZONE_CHANGED_NEW_AREA") then
        RaidCluster:MapZoneChanged()
    elseif (event == "PLAYER_TALENT_UPDATE") then
        RaidCluster:specDetection()
    elseif (event == "PLAYER_ENTERING_WORLD") then
        RaidCluster:ScheduleTimer(function() RaidCluster:OnPlayerLogin() end, 5)
    end
end

-- Init Addon
function RaidCluster:OnInitialize()
    -- DB
    self.db = ADB:New("RaidCluster_DB", defaults, "Default")

    -- BlizzOpt
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
    LibDualSpec:EnhanceDatabase(self.db, "RaidCluster");

    AC:RegisterOptionsTable("RaidCluster", options)
    ACR:RegisterOptionsTable("RaidCluster_Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
    LibDualSpec:EnhanceOptions(LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db), self.db)

    ACD:AddToBlizOptions("RaidCluster")
    ACD:AddToBlizOptions("RaidCluster_Profiles", "Profiles", "RaidCluster")

    --SlashCmds
	self:RegisterChatCommand("rac", "SlashCommand")
	self:RegisterChatCommand("raidcluster", "SlashCommand")

    self.OnInitialize = nil
end

function RaidCluster:OnEnable()
    db = self.db.profile

    self:RegisterMaps()

    self.EventHandler = CreateFrame("Frame")
    self.EventHandler:RegisterEvent("PLAYER_TALENT_UPDATE")
    self.EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.EventHandler:SetScript("OnEvent", EventHandler)

    self.playerName = UnitName("player")
    self.CLEU = CreateFrame("Frame")

    self.OnEnable = nil
end

function RaidCluster:OnPlayerLogin()
    self.EventHandler:UnregisterEvent("PLAYER_ENTERING_WORLD")

    self:MapZoneChanged()
    self:specDetection()

    self.OnPlayerLogin = nil
end
