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

LeaderLib.RegisterListener("Initialized", function()
	UpgradeSystem.LoadDropCounts()
end)

function UpgradeSystem.OnRollFailed(target)

end

-- Store CP here before finally applying it to the variable.
local tempChallengePoints = {}

function UpgradeSystem.IncreaseChallengePoints(target, amount)
	if tempChallengePoints[target] == nil then
		tempChallengePoints[target] = 0
	end
	local current = GetVarInteger(target, "LLENEMY_ChallengePoints") or 0
	if current < 0 then
		current = 0
	end
	tempChallengePoints[target] = current + amount
end

function UpgradeSystem.SaveChallengePoints(target)
	local current = tempChallengePoints[target]
	if current ~= nil and current > 0 then
		SetVarInteger(target, "LLENEMY_ChallengePoints", current)
		SetChallengePointsTag(target)
	end
	tempChallengePoints[target] = nil
end

---@param region string
---@param uuid string
---@param createCharacterData boolean|nil
function UpgradeSystem.GetCurrentRegionData(region, uuid, createCharacterData)
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
	local saved = UpgradeSystem.GetCurrentRegionData(target.CurrentLevel, target.MyGuid)
	if saved ~= nil then
		for i,v in pairs(saved) do
			if v.Duration ~= nil then
				ApplyStatus(target.MyGuid, v.ID, v.Duration, 1, target.MyGuid)
			end
		end
	end
end

---@param target EsvCharacter
---@param status string
---@param duration number
---@param applyImmediately boolean
local function FinallyApplyStatus(target, status, duration, applyImmediately)
	if status == "BLESSED" and target:HasTag("VOIDWOKEN") then
		status = "LLENEMY_VOID_EMPOWERED"
	end
	if applyImmediately == true then
		ApplyStatus(target.MyGuid, status, duration, 1, target.MyGuid)
	else
		local data = UpgradeSystem.GetCurrentRegionData(target.CurrentLevel, target.MyGuid, true)
		table.insert(data, {ID=status.ID, Duration={duration}})
	end
end

---@param target EsvCharacter
---@param entry UpgradeEntry
---@param applyImmediately boolean
---@return boolean
function UpgradeSystem.ApplyStatus(target, entry, applyImmediately)
	if Settings.Global.Flags.LLENEMY_HardModeEnabled.Enabled then
		if entry.FixedDuration then
			FinallyApplyStatus(target, entry.ID, entry.Duration)
		else
			local min = Settings.Global.Variables.Hardmode_StatusBonusTurnsMin.Value or 0
			local max = Settings.Global.Variables.Hardmode_StatusBonusTurnsMax.Value or 3
			local bonusDuration = entry.Duration + (Ext.Random(min,max) * 6.0)
			if HasActiveStatus(target, entry.ID) == 1 then
				local status = target:GetStatus(entry.ID)
				status.CurrentLifeTime = math.max(bonusDuration, status.CurrentLifeTime)
				status.RequestClientSync = true
			else
				FinallyApplyStatus(target, entry.ID, bonusDuration, applyImmediately)
			end
		end
	else
		FinallyApplyStatus(target, entry.ID, entry.Duration, applyImmediately)
	end
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
	local maxRoll = Vars.UPGRADE_MAX_ROLL
	local totalFrequency = 0
	for i=1,#tbl do
		local entry = tbl[i]
		if entry.Frequency > 0 then
			totalFrequency = totalFrequency + 1
		end	
	end
	if totalFrequency > 0 then
		for i=1,#tbl do
			local entry = tbl[i]
			if entry.Frequency > 0 then
				entry.StartRange = rangeStart
				entry.EndRange = (entry.Frequency / totalFrequency) * Vars.UPGRADE_MAX_ROLL
				rangeStart = entry.EndRange + 1
			else
				entry.StartRange = -1
				entry.EndRange = -1
			end
		end
	end
end

---@type table<string, UpgradeGroup>
Upgrades = Ext.Require("Shared/Data/Upgrades/_Init.lua")

---@param id string
---@return UpgradeEntry
function UpgradeSystem.GetUpgrade(id)
	for _,group in pairs(Upgrades) do
		for _,subgroup in pairs(group.SubGroups) do
			for _,upgrade in pairs(subgroup.Upgrades) do
				if upgrade.Value == id then
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

		if eliteRank > 0 then
			local mult = 1
			if Settings.Global.Flags.LLENEMY_HardModeEnabled.Enabled then
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

		local upgrades = regionData.Upgrades[uuid]
		if upgrades ~= nil then
			local t = type(upgrades)
			if t == "string" then
				local upgrade = UpgradeSystem.GetUpgrade(upgrades)
				if upgrade ~= nil then
					upgrade:Apply(character)
				end
			elseif t == "table" then
				for _,v in pairs(upgrades) do
					local upgrade = UpgradeSystem.GetUpgrade(v)
					if upgrade ~= nil then
						upgrade:Apply(character)
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

function UpgradeSystem.RollForUpgrades(uuid, region, applyImmediately)
	if not IgnoreCharacter(uuid) then
		local successes = 0
		local character = Ext.GetCharacter(uuid)
		for id,group in pairs(Upgrades) do
			if group:Apply(character, applyImmediately) then
				successes = successes + 1
			end
		end

		if successes > 0 then
			UpgradeSystem.SaveChallengePoints(uuid)
			ObjectSetFlag(uuid, "LLENEMY_HasUpgrades", 0)
		end

		UpgradeSystem.ApplyEliteBonuses(character, region)
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

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, isEditorMode)
	if IsGameLevel(region) == 1 then
		if PersistentVars.Upgrades.Results[region] == nil then
			PersistentVars.Upgrades.Results[region] = {}
			for i,uuid in pairs(Ext.GetAllCharacters(region)) do
				if not IgnoreCharacter(uuid) then
					UpgradeSystem.RollForUpgrades(uuid, region, false)
				end
			end
		end
	end
end)

Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", function(object, id)
	if Osi.LLSENEMY_QRY_SkipCombat(id) ~= true and ObjectIsCharacter(object) == 1 then
		local character = Ext.GetCharacter(object)
		if ObjectGetFlag(character.MyGuid, "LLENEMY_HasUpgrades") == 1 then
			UpgradeSystem.ApplySavedUpgrades(character.MyGuid)
			UpgradeInfo_ApplyInfoStatus(character.MyGuid)
		elseif Osi.LLSENEMY_QRY_IsEnemyOfParty(object) == true then
			UpgradeSystem.RollForUpgrades(character.MyGuid, character.CurrentLevel, true)
		end
	end
end)

Ext.RegisterOsirisListener("CombatStarted", 1, "after", function(id)

end)