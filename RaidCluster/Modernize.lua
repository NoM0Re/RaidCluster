-- *********************************************************
-- **                     RaidCluster                     **
-- **        https://github.com/NoM0Re/RaidCluster        **
-- *********************************************************

local RaidCluster = select(2, ...)

RaidCluster.MODERNIZE_VERSION = 4

local function CopyDefault(value)
  if type(value) == "table" then
    return CopyTable(value)
  end
  return value
end

function RaidCluster:FixProfileDefaults(profile, defaults)
  for key, defaultValue in pairs(defaults) do
    local currentValue = profile[key]

    if type(defaultValue) == "table" then
      if type(currentValue) ~= "table" then
        profile[key] = CopyDefault(defaultValue)
      else
        self:FixProfileDefaults(currentValue, defaultValue)
      end
    elseif currentValue == nil then
      profile[key] = defaultValue
    end
  end
end

function RaidCluster:Modernize(profile)
  if not profile then
    return
  end

  if profile.holyPriesPixelGlowEnable ~= nil and profile.holyPriestGlowEnable == nil then
    profile.holyPriestGlowEnable = profile.holyPriesPixelGlowEnable
  end
  profile.holyPriesPixelGlowEnable = nil

  if profile.discoPriesPixelGlowEnable ~= nil and profile.discoPriestGlowEnable == nil then
    profile.discoPriestGlowEnable = profile.discoPriesPixelGlowEnable
  end
  profile.discoPriesPixelGlowEnable = nil

  local glowKeyMigrations = {
    paladinPixelGlowEnable = "paladinGlowEnable",
    shamanPixelGlowEnable = "shamanGlowEnable",
    holyPriestPixelGlowEnable = "holyPriestGlowEnable",
    discoPriestPixelGlowEnable = "discoPriestGlowEnable",
    druidPixelGlowEnable = "druidGlowEnable",
  }

  for oldKey, newKey in pairs(glowKeyMigrations) do
    if profile[oldKey] ~= nil and profile[newKey] == nil then
      profile[newKey] = profile[oldKey]
    end
    profile[oldKey] = nil
  end

  if profile.glowType == nil then
    profile.glowType = "Pixel Glow"
  end

  if profile.scale ~= nil and profile.glowScale == nil then
    profile.glowScale = profile.scale
  end
  profile.scale = nil

  if profile.glowScale == nil then
    profile.glowScale = 1
  end

  if profile.rangeChecksPerFrame == nil then
    profile.rangeChecksPerFrame = 220
  end

  local classDefaults = {
    { enabled = "paladinEnable", raid = "paladinEnableInRaid", party = "paladinEnableInParty" },
    { enabled = "shamanEnable", raid = "shamanEnableInRaid", party = "shamanEnableInParty" },
    { enabled = "holyPriestEnable", raid = "holyPriestEnableInRaid", party = "holyPriestEnableInParty" },
    { enabled = "discoPriestEnable", raid = "discoPriestEnableInRaid", party = "discoPriestEnableInParty" },
    { enabled = "druidEnable", raid = "druidEnableInRaid", party = "druidEnableInParty" },
  }

  for _, keys in ipairs(classDefaults) do
    if profile[keys.enabled] == nil then
      profile[keys.enabled] = true
    end
    if profile[keys.raid] == nil then
      profile[keys.raid] = profile.enableInRaid ~= nil and profile.enableInRaid or true
    end
    if profile[keys.party] == nil then
      profile[keys.party] = profile.enableInParty ~= nil and profile.enableInParty or true
    end
  end

  profile.enableInRaid = nil
  profile.enableInParty = nil

  if profile.procGlowDuration == nil then
    profile.procGlowDuration = 1
  end

  if profile.procGlowStartAnim == nil then
    profile.procGlowStartAnim = true
  end

  if profile.border == nil then
    profile.border = false
  end

  profile.modernizeVersion = self.MODERNIZE_VERSION
end
