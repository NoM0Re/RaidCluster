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

-- WoW Api
local GetMapInfo = GetMapInfo
local GetCurrentMapDungeonLevel = GetCurrentMapDungeonLevel
local DungeonUsesTerrainMap = DungeonUsesTerrainMap

--  Map Sizes
RaidCluster.MapSizes = {}

-- Helper Functions
function RaidCluster:GetMapSize()
	local mapName = GetMapInfo()
	local level = GetCurrentMapDungeonLevel()
	local usesTerrainMap = DungeonUsesTerrainMap()
	level = usesTerrainMap and level - 1 or level
	local dims = self.MapSizes[mapName] and self.MapSizes[mapName][level] or { 1, 1 }
	return dims[1] , dims[2]
end

function RaidCluster:MapZoneChanged()
    self.mapX, self.mapY = self:GetMapSize()
end

function RaidCluster:GetUnitRange(x1, y1, x2, y2)
    local rangeX, rangeY = (x2 - x1) * self.mapX, (y2 - y1) * self.mapY
    local range = (rangeX * rangeX + rangeY * rangeY) ^ 0.5
    return range
end

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
