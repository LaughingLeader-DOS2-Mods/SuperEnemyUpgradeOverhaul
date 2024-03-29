local printd = PrintDebug

UpgradeSystem = {
	Settings = {
		ActiveDefenseStatuses = {
			LLENEMY_ACTIVATE_FLAMING_TONGUES = "FLAMING_TONGUES",
			LLENEMY_ACTIVATE_HEALING_TEARS = "HEALING_TEARS",
		},
		AddTalentStatuses = {
			LLENEMY_TALENT_TORTURER = "Torturer",
			LLENEMY_TALENT_WHATARUSH = "WhatARush",
			LLENEMY_TALENT_LEECH = "Leech",
			LLENEMY_TALENT_QUICKSTEP = "QuickStep",
			LLENEMY_TALENT_SADIST = "Sadist",
			LLENEMY_TALENT_GLADIATOR = "Gladiator",
			LLENEMY_TALENT_HAYMAKER = "Haymaker",
			LLENEMY_TALENT_INDOMITABLE = "Indomitable",
			LLENEMY_TALENT_SOULCATCHER = "Soulcatcher",
			LLENEMY_TALENT_MAGICCYCLES = "MagicCycles",
			LLENEMY_TALENT_GREEDYVESSEL = "GreedyVessel",
			LLENEMY_TALENT_BACKSTAB = "RogueLoreDaggerBackStab",
		},
		GrenadeSkills = {},
		Rage = {
			Max = 999,
			Statuses = {
				{Status = "LLENEMY_RAGE", Min = 0, Max = 20},
				{Status = "LLENEMY_RAGE2", Min = 20, Max = 40},
				{Status = "LLENEMY_RAGE3", Min = 40, Max = 60},
				{Status = "LLENEMY_RAGE4", Min = 60, Max = 90},
				{Status = "LLENEMY_RAGE5", Min = 90, Max = 999},
			}
		},
	},
}

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

Events.Initialized:Subscribe(function (e)
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
		tempChallengePoints[uuid] = math.max(GetVarInteger(uuid, "LLENEMY_ChallengePoints") or 0, 0)
	end
	local current = tempChallengePoints[uuid]
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
	SetVarInteger(target.MyGuid, "LLENEMY_ChallengePoints", 0)
	local cp = 0
	local hardmodeEnabled = Settings.Global:FlagEquals("LLENEMY_HardmodeEnabled", true)
	local saved = UpgradeSystem.GetCurrentRegionData(target.CurrentLevel, target.MyGuid)
	if saved ~= nil then
		for _,group in pairs(Upgrades) do
			for _,subgroup in pairs(group.SubGroups) do
				local hasSubgroup = false
				for _,upgrade in pairs(subgroup.Upgrades) do
					for i,v in pairs(saved) do
						if v.ID == upgrade.ID and (v.HardmodeOnly ~= true or hardmodeEnabled) then
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
---@field RemoveAfterApply boolean

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

function UpgradeSystem.GetCharacterData(uuid)
	local region = GetRegion(uuid) or SharedData.RegionData.Current
	local regionData = PersistentVars.Upgrades.Results[region]
	if regionData ~= nil then
		return regionData[uuid]
	end
	return nil
end

function UpgradeSystem.ClearCharacterData(uuid)
	local region = GetRegion(uuid) or SharedData.RegionData.Current
	local regionData = PersistentVars.Upgrades.Results[region]
	if regionData and regionData[uuid] then
		regionData[uuid] = nil
		return true
	end
	return false
end

Ext.RegisterConsoleCommand("euo_printupgraderesult", function(cmd, uuid)
	local data = UpgradeSystem.GetCurrentRegionData(nil, uuid, false)
	if data ~= nil then
		print(Ext.JsonStringify(data))
	else
		Ext.Utils.PrintError("No data for", uuid)
		local name = Ext.GetCharacter(uuid).DisplayName
		for i,v in pairs(Ext.GetAllCharacters(GetRegion(uuid))) do
			if Ext.GetCharacter(v).DisplayName == name then
				print("UUID mismatch?")
				print(v, uuid)
				print(name)
				TeleportTo(CharacterGetHostCharacter(), v, "", 0, 0, 0)
			end
		end
	end
end)

---@param target EsvCharacter
---@param status string
---@param duration number
---@param hardmodeDuration number
---@param applyImmediately boolean
---@param hardmodeOnly boolean
local function FinallyApplyStatus(target, status, duration, hardmodeDuration)
	if status == "BLESSED" and target:HasTag("VOIDWOKEN") then
		status = "LLENEMY_VOID_EMPOWERED"
	end
	if Settings.Global:FlagEquals("LLENEMY_HardmodeEnabled", true) and duration > 0 and hardmodeDuration ~= nil then
		duration = hardmodeDuration
	end
	if HasActiveStatus(target.MyGuid, status) == 1 then
		local status = target:GetStatus(status)
		if status.CurrentLifeTime > -1 then
			status.CurrentLifeTime = math.max(duration, status.CurrentLifeTime)
			status.RequestClientSync = true
		end
	else
		if status == "LLENEMY_SUMMON_AUTOMATON" then
			local turns = Ext.Random(2,4)
			duration = turns * 6.0
		end
		ApplyStatus(target.MyGuid, status, duration, 1, target.MyGuid)
	end
end

---@param target EsvCharacter
function UpgradeSystem.ApplySavedUpgrades(target)
	local hardmodeEnabled = Settings.Global:FlagEquals("LLENEMY_HardmodeEnabled", true) and Settings.Global:FlagEquals("LLENEMY_HardmodeRollingDisabled", false)
	local saved = UpgradeSystem.GetCurrentRegionData(target.CurrentLevel, target.MyGuid)
	if saved ~= nil then
		for i,v in pairs(saved) do
			if v.Duration ~= nil then
				if v.HardmodeOnly ~= true or hardmodeEnabled then
					FinallyApplyStatus(target, v.ID, v.Duration, v.HardmodeDuration)
					if v.RemoveAfterApply == true then
						saved[i] = nil
					end
				end
			end
		end
	end
end

---@class SavedUpgradeData
---@field ID string
---@field Duration number
---@field HardmodeOnly boolean
---@field HardmodeDuration number
---@field RemoveAfterApply boolean

---@param target EsvCharacter
---@param entry UpgradeEntry
---@param applyImmediately boolean
---@param hardmodeOnly boolean
---@return boolean
function UpgradeSystem.ApplyStatus(target, entry, applyImmediately, hardmodeOnly)
	local hardmodeDuration = entry.Duration
	if not entry.FixedDuration and entry.Duration > 0 then
		local min = Settings.Global.Variables.Hardmode_StatusBonusTurnsMin.Value or 0
		local max = Settings.Global.Variables.Hardmode_StatusBonusTurnsMax.Value or 3
		hardmodeDuration = entry.Duration + (Ext.Random(min,max) * 6.0)
	end

	if applyImmediately then
		FinallyApplyStatus(target, entry.ID, entry.Duration, hardmodeDuration)
	end

	if entry.RemoveAfterApply ~= true or applyImmediately ~= true then
		local data = UpgradeSystem.GetCurrentRegionData(target.CurrentLevel, target.MyGuid, true)
		local saveData = {
			ID=entry.ID, 
			Duration=entry.Duration, 
			HardmodeOnly = hardmodeOnly or false, 
			RemoveAfterApply = entry.RemoveAfterApply}
		if entry.Duration > 0 then
			saveData.HardmodeDuration = hardmodeDuration
		end
		table.insert(data, saveData)
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

			SetTag(uuid, "LLENEMY_Elite")
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

local displayInfoForTags = {
	GUARD = true,
	MAGISTER = true,
}

local function ShouldApplyInfoStatus(uuid)
	if CharacterIsInCombat(uuid) == 1 or Osi.LLSENEMY_QRY_IsEnemyOfParty(uuid) then
		return true
	end
	for tag,b in pairs(displayInfoForTags) do
		if IsTagged(uuid, tag) == 1 then
			return true
		end
	end
end

local function IgnoreCharacter(object)
	if ObjectIsCharacter(object) == 0
	or IsTagged(object, "LLENEMY_Duplicant") == 1
	or Osi.LLSENEMY_Upgrades_QRY_CanAddUpgrades(object) ~= true
	then
		return true
	end
	return false
end

---@param uuid string
---@param applyImmediately boolean|nil
---@param skipIgnoreCheck boolean|nil
---@param skipHasUpgradesCheck boolean|nil
function UpgradeSystem.RollForUpgrades(uuid, applyImmediately, skipIgnoreCheck, skipHasUpgradesCheck)
	if skipIgnoreCheck == true or not IgnoreCharacter(uuid) then
		local successes = 0
		local character = Ext.GetCharacter(uuid)
		for id,group in pairs(Upgrades) do
			if group:Apply(character, applyImmediately) then
				successes = successes + 1
			end
		end
		
		if skipHasUpgradesCheck == true or ObjectGetFlag(uuid, "LLSENEMY_HasUpgrades") == 0 then
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
			UpgradeSystem.SaveChallengePoints(uuid)
			if applyImmediately or ShouldApplyInfoStatus(character.MyGuid) then
				UpgradeInfo_ApplyInfoStatus(character.MyGuid, true)
			end
			ObjectSetFlag(uuid, "LLSENEMY_HasUpgrades", 0)
		end
	end
end

function OnDoubleDipApplied(uuid)
	local character = Ext.GetCharacter(uuid)
	local successes = 0
	for id,group in pairs(Upgrades) do
		if group:Apply(character, true, false) then
			successes = successes + 1
		end
	end
	if successes > 0 then
		Ext.Utils.Print(string.format("[EUO] (Double Dip) Character (%s:%s) gained new upgrades! (%s)", character.DisplayName, uuid, successes))
	end
end

function UpgradeSystem.RollRegion(region, force)
	if PersistentVars.Upgrades.Results[region] == nil or force == true then
		PersistentVars.Upgrades.Results[region] = {}
		for i,uuid in pairs(Ext.GetAllCharacters(region)) do
			if force then
				ObjectClearFlag(uuid, "LLSENEMY_HasUpgrades", 0)
				SetVarInteger(uuid, "LLENEMY_ChallengePoints", 0)
			end
			if not IgnoreCharacter(uuid) then
				UpgradeSystem.RollForUpgrades(uuid, CharacterIsInCombat(uuid) == 1, true)
				UpgradeSystem.ApplyEliteBonuses(Ext.GetCharacter(uuid), region)
			end
		end
		UpgradeSystem.SaveDropCounts()
		GameHelpers.Data.StartSyncTimer(250, true)
	end
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
	object = StringHelpers.GetUUID(object)
	if ObjectIsCharacter(object) == 1 then
		--Osi.LLSENEMY_Scaling_LevelUpCharacter(object)
		LevelUpCharacter(object)
		if not IgnoreCharacter(object) then
			if Osi.LLSENEMY_QRY_SkipCombat(id) ~= true and Osi.LLSENEMY_QRY_IsEnemyOfParty(object) == true then
				local character = Ext.GetCharacter(object)
				if ObjectGetFlag(object, "LLSENEMY_HasUpgrades") == 1 then
					UpgradeSystem.ApplySavedUpgrades(character)
					UpgradeSystem.CalculateChallengePoints(character)
					UpgradeInfo_ApplyInfoStatus(character.MyGuid, true)
				else
					UpgradeSystem.RollForUpgrades(character.MyGuid, true)
				end
				Duplication.StartDuplicating(character)
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
			UpgradeSystem.RollForUpgrades(GetUUID(char), true)
		end
	end
end)

-- Ext.RegisterOsirisListener("CombatStarted", 1, "after", function(id)

-- end)

Ext.Require("Server/Upgrades/Mechanics/Seeker.lua")