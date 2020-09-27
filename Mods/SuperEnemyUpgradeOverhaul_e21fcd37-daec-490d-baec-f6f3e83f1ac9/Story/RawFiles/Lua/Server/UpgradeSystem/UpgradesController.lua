local printd = LeaderLib.PrintDebug

UpgradeSystem = {}

---@param group UpgradeGroup
---@param subgroup UpgradeSubGroup
---@param entry UpgradeEntry
local function SaveDropCount(group, subgroup, entry)
	if PersistentVars.Upgrades.DropCounts[group.ID] == nil then
		PersistentVars.Upgrades.DropCounts[group.ID] = {}
	end
	if PersistentVars.Upgrades.DropCounts[group.ID][subgroup.ID] == nil then
		PersistentVars.Upgrades.DropCounts[group.ID][subgroup.ID] = {}
	end
	PersistentVars.Upgrades.DropCounts[group.ID][subgroup.ID][entry.ID] = entry.DropCount
end

function UpgradeSystem.SaveDropCounts()
	for _,group in pairs(Upgrades) do
		for _,subgroup in pairs(group.SubGroups) do
			for _,entry in pairs(subgroup.Upgrades) do
				SaveDropCount(group, subgroup, entry)
			end
		end
	end
end

---@param group UpgradeGroup
---@param subgroup UpgradeSubGroup
---@param entry UpgradeEntry
---@return integer
local function GetDropCount(group, subgroup, entry)
	if PersistentVars.Upgrades.DropCounts[group.ID] ~= nil then
		if PersistentVars.Upgrades.DropCounts[group.ID][subgroup.ID] ~= nil then
			return PersistentVars.Upgrades.DropCounts[group.ID][subgroup.ID][entry.ID]
		end
	end
	return nil
end

function UpgradeSystem.LoadDropCounts()
	for _,group in pairs(Upgrades) do
		for _,subgroup in pairs(group.SubGroups) do
			for _,entry in pairs(subgroup.Upgrades) do
				local count = GetDropCount(group, subgroup, entry)
				if count ~= nil then
					entry.DropCount = count
				end
			end
		end
	end
end

function UpgradeSystem.Init()
	for id,group in pairs(Upgrades) do
		UpgradeSystem.SetRanges(group.SubGroups)
		for _,sub in pairs(group.SubGroups) do
			UpgradeSystem.SetRanges(sub.Upgrades)
		end
	end
end

LeaderLib.RegisterListener("Initialized", function()
	UpgradeSystem.Init()
	UpgradeSystem.LoadDropCounts()
end)

-- Ext.RegisterConsoleCommand("luareset", function(command)
-- 	local b,err = xpcall(function()
-- 		UpgradeSystem.Init()
-- 		UpgradeSystem.LoadDropCounts()
-- 	end, debug.traceback)
-- 	if not b then
-- 		printd(err)
-- 	end
-- end)

function UpgradeSystem.OnRollFailed(target)

end

-- Store CP here before finally applying it to the variable.
local tempChallengePoints = {}

function UpgradeSystem.IncreaseChallengePoints(uuid, amount)
	if tempChallengePoints[uuid] == nil then
		tempChallengePoints[uuid] = 0
	end
	local current = GetVarInteger(uuid, "LLENEMY_ChallengePoints") or 0
	if current < 0 then
		current = 0
	end
	tempChallengePoints[uuid] = current + amount
end

function UpgradeSystem.SaveChallengePoints(uuid)
	local current = tempChallengePoints[uuid]
	if current ~= nil and current > 0 then
		SetVarInteger(uuid, "LLENEMY_ChallengePoints", current)
		SetChallengePointsTag(uuid)
	end
	tempChallengePoints[uuid] = nil
end

---@param target EsvCharacter
function UpgradeSystem.CalculateChallengePoints(target)
	local cp = 0
	local hardmodeEnabled = Settings.Global:FlagEquals("LLENEMY_HardmodeEnabled", true)
	local saved = UpgradeSystem.GetCurrentRegionData(target.CurrentLevel, target.MyGuid)
	if saved ~= nil then
		for _,group in pairs(Upgrades) do
			for _,subgroup in pairs(group.SubGroups) do
				local hasSubgroup = false
				for _,upgrade in pairs(subgroup.Upgrades) do
					for i,v in pairs(saved) do
						if v.ID == upgrade.ID and v.HardmodeOnly ~= true or hardmodeEnabled then
							cp = cp + upgrade.CP
							hasSubgroup = true
						end
					end
				end
				if hasSubgroup then
					cp = cp + subgroup.CP
				end
			end
		end
	end
	SetVarInteger(target.MyGuid, "LLENEMY_ChallengePoints", cp)
	SetChallengePointsTag(target.MyGuid)
end

function UpgradeSystem.HasUpgrade(uuid, id)
	local data = UpgradeSystem.GetCurrentRegionData(nil, uuid, false)
	if data ~= nil then
		for i,v in pairs(data) do
			if v.ID == id then
				return true
			end
		end
	end
	return false
end

---@class SavedUpgradeData
---@field ID string
---@field Duration number
---@field HardmodeDuration number
---@field HardmodeOnly boolean

---@param region string
---@param uuid string
---@param createCharacterData boolean|nil
---@return SavedUpgradeData[]|table<string, SavedUpgradeData[]>
function UpgradeSystem.GetCurrentRegionData(region, uuid, createCharacterData)
	if region == nil then
		region = GetRegion(uuid or CharacterGetHostCharacter()) or ""
		if region == "" then
			region = Osi.DB_CurrentLevel:Get(nil)[1][1]
		end
	end

	local regionData = PersistentVars.Upgrades.Results[region]
	if regionData == nil then
		regionData = {}
		PersistentVars.Upgrades.Results[region] = regionData
	end
	if uuid == nil then
		return regionData
	else
		if createCharacterData == true and regionData[uuid] == nil then
			regionData[uuid] = {}
		end
		return regionData[uuid]
	end
end

---@param target EsvCharacter
function UpgradeSystem.ApplySavedUpgrades(target)
	local hardmodeEnabled = Settings.Global.Flags.LLENEMY_HardmodeEnabled.Enabled and not Settings.Global.Flags.LLENEMY_HardmodeRollingDisabled.Enabled
	local saved = UpgradeSystem.GetCurrentRegionData(target.CurrentLevel, target.MyGuid)
	if saved ~= nil then
		for i,v in pairs(saved) do
			if v.Duration ~= nil then
				if v.HardmodeOnly ~= true or hardmodeEnabled then
					ApplyStatus(target.MyGuid, v.ID, v.Duration, 1, target.MyGuid)
				end
			end
		end
	end
end

---@param target EsvCharacter
---@param status string
---@param duration number
---@param hardmodeDuration number
---@param applyImmediately boolean
---@param hardmodeOnly boolean
local function FinallyApplyStatus(target, status, duration, hardmodeDuration, applyImmediately, hardmodeOnly)
	if status == "BLESSED" and target:HasTag("VOIDWOKEN") then
		status = "LLENEMY_VOID_EMPOWERED"
	end
	if applyImmediately == true then
		if Settings.Global.Flags.LLENEMY_HardmodeEnabled.Enabled then
			duration = hardmodeDuration
		end
		if HasActiveStatus(target.MyGuid, status) == 1 then
			local status = target:GetStatus(status)
			status.CurrentLifeTime = math.max(duration, status.CurrentLifeTime)
			status.RequestClientSync = true
		else
			ApplyStatus(target.MyGuid, status, duration, 1, target.MyGuid)
		end
	else
		local data = UpgradeSystem.GetCurrentRegionData(target.CurrentLevel, target.MyGuid, true)
		table.insert(data, {ID=status, Duration=duration, HardmodeOnly = hardmodeOnly or false, HardmodeDuration=hardmodeDuration})
	end
end

---@param target EsvCharacter
---@param entry UpgradeEntry
---@param applyImmediately boolean
---@param hardmodeOnly boolean
---@return boolean
function UpgradeSystem.ApplyStatus(target, entry, applyImmediately, hardmodeOnly)
	local hardmodeDuration = entry.Duration
	if not entry.FixedDuration then
		local min = Settings.Global.Variables.Hardmode_StatusBonusTurnsMin.Value or 0
		local max = Settings.Global.Variables.Hardmode_StatusBonusTurnsMax.Value or 3
		hardmodeDuration = entry.Duration + (Ext.Random(min,max) * 6.0)
	end
	FinallyApplyStatus(target, entry.ID, entry.Duration, hardmodeDuration, applyImmediately, hardmodeOnly)
	return true
end

---@param target string
---@param entry UpgradeEntry
---@return boolean
function UpgradeSystem.CanApplyUpgrade(target, entry)
	return true
end

---@param tbl table
function UpgradeSystem.SetRanges(tbl)
	local rangeStart = 1
	local maxRoll = (Vars.UPGRADE_MAX_ROLL - (#tbl*2))
	local totalFrequency = 0
	for i=1,#tbl do
		local entry = tbl[i]
		if entry.Frequency > 0 then
			totalFrequency = totalFrequency + entry.Frequency
		end	
	end
	if totalFrequency > 0 then
		for i=1,#tbl do
			local entry = tbl[i]
			if entry.Frequency > 0 then
				entry.StartRange = rangeStart
				if i == #tbl then
					entry.EndRange = Vars.UPGRADE_MAX_ROLL
				else
					entry.EndRange = math.min(Vars.UPGRADE_MAX_ROLL, rangeStart + math.ceil((entry.Frequency/totalFrequency) * maxRoll))
				end
				--entry.EndRange = rangeStart + math.ceil((entry.Frequency/totalFrequency) * maxRoll)
				rangeStart = entry.EndRange+1
				-- if entry.EndRange > Vars.UPGRADE_MAX_ROLL then
				-- 	printd(string.format("[%s] Start(%s)/End(%s)/(%s) Frequency(%s) totalFrequency(%s)", entry.ID, entry.StartRange, entry.EndRange, maxRoll, entry.Frequency, totalFrequency))
				-- 	printd((entry.Frequency/totalFrequency))
				-- end
			else
				entry.StartRange = -1
				entry.EndRange = -1
			end
		end
	end
	--printd(Ext.JsonStringify(tbl))
	return tbl
end

---@type table<string, UpgradeGroup>
Upgrades = Ext.Require("Shared/Data/Upgrades/_Init.lua")

---@param id string
---@return UpgradeEntry
function UpgradeSystem.GetUpgrade(id)
	for _,group in pairs(Upgrades) do
		for _,subgroup in pairs(group.SubGroups) do
			for _,upgrade in pairs(subgroup.Upgrades) do
				if upgrade.ID == id then
					return upgrade
				end
			end
		end
	end
	return nil
end

---@param character EsvCharacter
---@param region string
function UpgradeSystem.ApplyEliteBonuses(character, region)
	local uuid = character.MyGuid
	local regionData = EliteData[region]
	if regionData ~= nil then
		local eliteRank = regionData.Elites[uuid]
		if eliteRank ~= nil and eliteRank > 0 then
			local mult = 1
			if Settings.Global.Flags.LLENEMY_HardmodeEnabled.Enabled then
				mult = Settings.Global.Variables.Hardmode_EliteMultiplier.Value or 2
			end
			local armorBoostMult = (Settings.Global.Variables.Elites_ArmorBoostPerRank.Value or 2.5) * mult
			local magicArmorBoostMult = (Settings.Global.Variables.Elites_MagicArmorBoostPerRank.Value or 2.5) or mult
			local vitalityBoostMult = (Settings.Global.Variables.Elites_VitalityBoostPerRank.Value or 2.5) or mult
			local damageBoostMult = (Settings.Global.Variables.Elites_DamageBoostPerRank.Value or 1) * mult

			local boosts = character.Stats.DynamicStats[2] -- Permanent Boosts

			-- local armorBoost = (NRD_CharacterGetPermanentBoostInt(uuid, "ArmorBoost") or 0) + (armorBoostMult * eliteRank)
			-- local magicArmorBoost = (NRD_CharacterGetPermanentBoostInt(uuid, "MagicArmorBoost") or 0) + (armorBoostMult * eliteRank)
			-- local vitalityBoost = (NRD_CharacterGetPermanentBoostInt(uuid, "VitalityBoost") or 0) + (vitalityBoostMult * eliteRank)
			-- local damageBoost = (NRD_CharacterGetPermanentBoostInt(uuid, "DamageBoost") or 0) + (damageBoostMult * eliteRank)

			local armorBoost = (boosts.ArmorBoost or 0) + (armorBoostMult * eliteRank)
			local magicArmorBoost = (boosts.MagicArmorBoost or 0) + (armorBoostMult * eliteRank)
			local vitalityBoost = (boosts.VitalityBoost or 0) + (vitalityBoostMult * eliteRank)
			local damageBoost = (boosts.DamageBoost or 0) + (damageBoostMult * eliteRank)

			NRD_CharacterSetPermanentBoostInt(uuid, "ArmorBoost", math.ceil(armorBoost))
			NRD_CharacterSetPermanentBoostInt(uuid, "MagicArmorBoost", math.ceil(magicArmorBoost))
			NRD_CharacterSetPermanentBoostInt(uuid, "VitalityBoost", math.ceil(vitalityBoost))
			NRD_CharacterSetPermanentBoostInt(uuid, "DamageBoost", math.ceil(damageBoost))
			CharacterAddAttribute(uuid, "Dummy", 0)

			ApplyStatus(uuid, "LEADERLIB_RECALC", 0.0, 1, uuid)

			CharacterSetHitpointsPercentage(uuid, math.min(100.0, (character.Stats.CurrentVitality/character.Stats.MaxVitality)*100))
			CharacterSetArmorPercentage(uuid, 100.0)
			CharacterSetMagicArmorPercentage(uuid, 100.0)
		end

		local applyImmediately = CharacterIsInCombat(character.MyGuid) == 1

		local upgrades = regionData.Upgrades[uuid]
		if upgrades ~= nil then
			local t = type(upgrades)
			if t == "string" then
				local upgrade = UpgradeSystem.GetUpgrade(upgrades)
				if upgrade ~= nil then
					upgrade:Apply(character, applyImmediately, false)
				end
			elseif t == "table" then
				for _,v in pairs(upgrades) do
					local upgrade = UpgradeSystem.GetUpgrade(v)
					if upgrade ~= nil then
						upgrade:Apply(character, applyImmediately, false)
					end
				end
			end
		end
	end
end

local function IgnoreCharacter(uuid)
	if Osi.LLSENEMY_Upgrades_QRY_CanAddUpgrades(uuid) == true then
		return false
	end
	return true
end

function UpgradeSystem.RollForUpgrades(uuid, region, applyImmediately, skipIgnoreCheck)
	if skipIgnoreCheck == true or not IgnoreCharacter(uuid) then
		local successes = 0
		local character = Ext.GetCharacter(uuid)
		for id,group in pairs(Upgrades) do
			if group:Apply(character, applyImmediately) then
				successes = successes + 1
			end
		end
		
		if ObjectGetFlag(uuid, "LLSENEMY_HasUpgrades") == 0 then
			local vars = Settings.Global.Variables
			local min = vars.Hardmode_MinBonusRolls.Value or Ext.ExtraData["LLENEMY_Hardmode_DefaultBonusRolls_Min"] or 1
			local max = vars.Hardmode_MaxBonusRolls.Value or Ext.ExtraData["LLENEMY_Hardmode_DefaultBonusRolls_Max"] or 4
			local bonusRolls = Ext.Random(min, max)
			if bonusRolls > 0 then
				for i=bonusRolls,1,-1 do
					for id,group in pairs(Upgrades) do
						if group:Apply(character, applyImmediately, true) then
							successes = successes + 1
						end
					end
				end
			end
		end

		if successes > 0 then
			if applyImmediately then
				UpgradeInfo_ApplyInfoStatus(character.MyGuid, true)
			end
			UpgradeSystem.SaveChallengePoints(uuid)
			ObjectSetFlag(uuid, "LLSENEMY_HasUpgrades", 0)
		end
	end
end

function OnDoubleDipApplied(uuid)
	local character = Ext.GetCharacter(uuid)
	local successes = 0
	for id,group in pairs(Upgrades) do
		if group:Apply(character) then
			successes = successes + 1
		end
	end
	if successes > 0 then
		Ext.Print(string.format("[EUO] (Double Dip) Character (%s:%s) gained new upgrades! (%s)", character.DisplayName, uuid, successes))
	end
end

function UpgradeSystem.RollRegion(region, force)
	if PersistentVars.Upgrades.Results[region] == nil or force == true then
		PersistentVars.Upgrades.Results[region] = {}
		for i,uuid in pairs(Ext.GetAllCharacters(region)) do
			if force then
				ObjectClearFlag(uuid, "LLSENEMY_HasUpgrades", 0)
			end
			if not IgnoreCharacter(uuid) then
				UpgradeSystem.RollForUpgrades(uuid, region, CharacterIsInCombat(uuid) == 1, true)
				UpgradeSystem.ApplyEliteBonuses(Ext.GetCharacter(uuid), region)
			end
		end
	end
	SyncVars()
	if Ext.IsDeveloperMode() then
		local printUpgrades = {}
		for c,d in pairs(PersistentVars.Upgrades.Results[region]) do
			for i,v in pairs(d) do
				if printUpgrades[v.ID] == nil then
					printUpgrades[v.ID] = 0
				end
				printUpgrades[v.ID] = printUpgrades[v.ID] + 1
			end
		end
	end
end

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, isEditorMode)
	if IsGameLevel(region) == 1 then
		UpgradeSystem.RollRegion(region)
	end
end)

Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", function(object, id)
	if Osi.LLSENEMY_QRY_SkipCombat(id) ~= true and ObjectIsCharacter(object) == 1 then
		local character = Ext.GetCharacter(object)
		if Osi.LLSENEMY_QRY_IsEnemyOfParty(object) then
			if ObjectGetFlag(character.MyGuid, "LLSENEMY_HasUpgrades") == 1 then
				UpgradeSystem.ApplySavedUpgrades(character)
				UpgradeSystem.CalculateChallengePoints(character)
				UpgradeInfo_ApplyInfoStatus(character.MyGuid, true)
			else
				UpgradeSystem.RollForUpgrades(character.MyGuid, character.CurrentLevel, true)
			end
		end
	end
end)

Ext.RegisterOsirisListener("ProcMakeNPCHostile", 2, "after", function(char, player)
	if CharacterIsInCombat(char) == 1 and Osi.LLSENEMY_QRY_IsEnemyOfParty(char) then
		if ObjectGetFlag(char, "LLSENEMY_HasUpgrades") == 1 then
			local character = Ext.GetCharacter(char)
			UpgradeSystem.ApplySavedUpgrades(character)
			UpgradeSystem.CalculateChallengePoints(character)
			UpgradeInfo_ApplyInfoStatus(character.MyGuid, true)
		else
			UpgradeSystem.RollForUpgrades(GetUUID(char), GetRegion(char), true)
		end
	end
end)

Ext.RegisterOsirisListener("CombatStarted", 1, "after", function(id)

end)