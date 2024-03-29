if Duplication == nil then
	Duplication = {}
end

local printd = PrintDebug

---@param source EsvCharacter
---@param dupe EsvCharacter
function Duplication.CopyCP(source,dupe)
	local cp = GetVarInteger(source.MyGuid, "LLENEMY_ChallengePoints") or 0
	SetVarInteger(dupe.MyGuid, "LLENEMY_ChallengePoints", cp)
	SetChallengePointsTag(dupe.MyGuid)
end

local CopyBoosts = {
	"Movement",
	"MovementSpeedBoost",
	"FireResistance",
	"EarthResistance",
	"WaterResistance",
	"AirResistance",
	"PoisonResistance",
	--"ShadowResistance",
	"PiercingResistance",
	"PhysicalResistance",
	--"CorrosiveResistance",
	--"MagicResistance",
	--"CustomResistance",
	"MaxResistance",
	"Sight",
	--"Hearing",
	"APMaximum",
	"APStart",
	"APRecovery",
	"CriticalChance",
	"Initiative",
	"Vitality",
	--"VitalityBoost",
	"MagicPoints",
	--"Armor",
	--"MagicArmor",
	"ArmorBoost",
	"MagicArmorBoost",
	"ArmorBoostGrowthPerLevel",
	"MagicArmorBoostGrowthPerLevel",
	"DamageBoost",
	"DamageBoostGrowthPerLevel",
	"Accuracy",
	"Dodge",
	--"LifeSteal",
	"Weight",
	--"ChanceToHitBoost",
	--"RangeBoost",
	--"APCostBoost",
	--"SPCostBoost",
	"MaxSummons",
	--"BonusWeaponDamageMultiplier",
}

local function GetArmorScale(base, level)
	local vitalityBoost = Game.Math.GetVitalityBoostByLevel(level)
	local armorScaling = (vitalityBoost * ((Ext.ExtraData.AttributeBaseValue + level * Ext.ExtraData.ExpectedConGrowthForArmorCalculation - Ext.ExtraData.AttributeBaseValue) *  Ext.ExtraData.VitalityBoostFromAttribute) + 1.0) * Ext.ExtraData.ArmorToVitalityRatio
	local scaledArmor = armorScaling * base / 100;
	return scaledArmor
end

local ArmorStats = {
	MaxArmor = "Armor",
	MaxMagicArmor = "MagicArmor"
}

---@param source EsvCharacter
---@param dupe EsvCharacter
local function CopyStats(source,dupe,baseStat)
	for stat,boost in pairs(ArmorStats) do
		local sourceVal = source.Stats[stat]
		local dupeVal = dupe.Stats[stat]
		if sourceVal ~= dupeVal then
			local next = sourceVal - dupeVal
			NRD_CharacterSetPermanentBoostInt(dupe.MyGuid, boost, next)
			printd("Added", boost, "to", next, "for", dupe, "from", dupeVal,sourceVal)
		end
	end
	for i,stat in Data.Attribute:Get() do
		local baseSource = CharacterGetBaseAttribute(source.MyGuid, stat)
		--NRD_PlayerSetBaseAttribute(dupe, stat, baseSource)
		local baseDupe = CharacterGetBaseAttribute(dupe.MyGuid, stat)
		if baseDupe ~= nil and baseSource ~= nil and baseDupe ~= baseSource then
			local next = baseSource - baseDupe
			CharacterAddAttribute(dupe.MyGuid, stat, next)
			printd("Added", stat, "to", next, "for", dupe.MyGuid, "from", baseDupe, baseSource)
		end
	end
	for i,stat in Data.Ability:Get() do
		local baseSource = CharacterGetBaseAbility(source.MyGuid, stat)
		--NRD_PlayerSetBaseAbility(dupe, stat, baseSource)
		local baseDupe = CharacterGetBaseAbility(dupe.MyGuid, stat)
		if baseDupe ~= nil and baseSource ~= nil and baseDupe ~= baseSource then
			local next = baseSource - baseDupe
			CharacterAddAbility(dupe.MyGuid, stat, next)
			printd("Added", stat, "to", next, "for", dupe.MyGuid, "from", baseDupe, baseSource)
		end
	end
	for i,boost in ipairs(CopyBoosts) do
		--local baseSource = source.Stats[boost] or 0
		--local baseDupe = dupe.Stats[boost] or 0
		local baseSource = NRD_CharacterGetPermanentBoostInt(source.MyGuid, boost) or 0
		local baseDupe = NRD_CharacterGetPermanentBoostInt(dupe.MyGuid, boost) or 0
		if baseSource ~= nil and baseDupe ~= nil and baseDupe ~= baseSource then
			local next = baseSource - baseDupe
			NRD_CharacterSetPermanentBoostInt(dupe.MyGuid, boost, next)
			printd("Added", boost, "to", next, "for", dupe.MyGuid, "from", baseDupe, baseSource)
		end
	end
	if ObjectGetFlag(source.MyGuid, "LLENEMY_LoneWolfBonusesApplied") == 1 then
		ObjectSetFlag(dupe.MyGuid, "LLENEMY_LoneWolfBonusesApplied", 0)
	end
	CharacterAddAttribute(dupe.MyGuid, "Dummy", 0)

	CharacterLevelUpTo(dupe.MyGuid, source.Stats.Level)
end

function Duplication.CopyStats(source,dupe,baseStat)
	local status,err = xpcall(CopyStats, debug.traceback, source, dupe, baseStat)
	if not status then
		Ext.Utils.PrintError(err)
	end
end

---@param source EsvCharacter
---@param dupe EsvCharacter
function Duplication.CopyTalents(source,dupe)
	for i,talent in Data.Talents:Get() do
		if CharacterHasTalent(source.MyGuid,talent) == 1 then
			NRD_CharacterSetPermanentBoostTalent(dupe.MyGuid, talent, 1)
		end
	end
end

---@param source EsvCharacter
---@param dupe EsvCharacter
function Duplication.CopyName(source,dupe)
	local characterName = source.DisplayName
	if StringHelpers.IsNullOrEmpty(characterName) then
		local handle,refStr = CharacterGetDisplayName(source.MyGuid)
		characterName = Ext.GetTranslatedString(handle, refStr)
	end
	local dupeNameBase = Ext.GetTranslatedString("h02023d82gc736g447fgaea3g327be0956688", "<font color='#BF5FFF'>[1] (Shadow)</font>")
	local dupeName = dupeNameBase:gsub("%[1%]", characterName)
	CharacterSetCustomName(dupe.MyGuid, dupeName)
end

local function StatusHasAura(status)
	local auraRadius = Ext.StatGetAttribute(status, "AuraRadius")
	return auraRadius ~= nil and auraRadius > 0
end

local IgnoredDuplicantStatuses = {
	LLENEMY_TALENT_RESISTDEAD = true,
	LLENEMY_TALENT_RESISTDEAD2 = true,
	LLENEMY_UPGRADE_INFO = true,
	LLENEMY_DOUBLE_DIP = true,
}

---@param dupe EsvCharacter
local function IgnoreStatus(dupe, status)
	if Data.EngineStatus[status] == true then
		return true
	end
	if IgnoredDuplicantStatuses[status] == true then
		return true
	end
	if string.find(status, "LLENEMY_DUPE") or string.find(status, "QUEST") then
		return true
	end
	if not Osi.LLSENEMY_Duplication_QRY_CanCopyStatus(dupe.MyGuid, status) then
		return true
	end
	return false
end

---@param source EsvCharacter
---@param dupe EsvCharacter
function Duplication.CopyStatus(source,dupe,status,handlestr)
	if not StatusHasAura(status) and not IgnoreStatus(status) and HasActiveStatus(dupe, status) == 0 then
		local handle = math.tointeger(handlestr)
		local duration = NRD_StatusGetReal(source, handle, "CurrentLifeTime")
		if duration ~= 0.0 then
			local statusSourceHandle = NRD_StatusGetGuidString(source, handle, "StatusSourceHandle")
			if statusSourceHandle == nil or statusSourceHandle == source then 
				statusSourceHandle = dupe
			end
			Osi.LLSENEMY_Duplication_CopyStatus(source, dupe, status, duration, statusSourceHandle)
		end
	end
end

---@param source EsvCharacter
---@param dupe EsvCharacter
local function CopyStatuses(source, dupe)
	for i,status in pairs(source:GetStatusObjects()) do
		if status.CurrentLifeTime ~= 0
		and not IgnoreStatus(dupe, status.StatusId) 
		and not StatusHasAura(status.StatusId)
		and HasActiveStatus(dupe.MyGuid, status.StatusId) == 0
		and Osi.LLSENEMY_Duplication_QRY_CanCopyStatus(dupe.MyGuid, status.StatusId) == true
		then
			local statusSource = dupe.MyGuid
			if status.StatusSourceHandle ~= nil then
				local statusSourceObj = Ext.GetGameObject(status.StatusSourceHandle)
				if statusSourceObj ~= nil then
					statusSource = statusSourceObj.MyGuid
				end
			end
			ApplyStatus(dupe.MyGuid, status.StatusId, status.CurrentLifeTime, 1, statusSource)
		end
	end
end

function Duplication.CopySkills(source, dupe)
	---@type string[]
	local skills = source:GetSkills()
	if skills ~= nil and #skills > 0 then
		for i,skill in pairs(skills) do
			CharacterAddSkill(dupe.MyGuid, skill, 0)
		end
	end
end

function Duplication.CopyTags(source, dupe)
	for i,tag in pairs(source:GetTags()) do
		SetTag(dupe.MyGuid, tag)
	end
end

---If a dupe is created in the arena, this sets them up.
---@param source EsvCharacter
---@param dupe EsvCharacter
local function AddToArena(source, dupe)
	--DB_ArenaPresets_Mobs(_Arena, _Source, _Trigger)
	--DB_Arena_MobParticipants(_Inst, _Source, _Trig, _Team)
	for i,db in pairs(Osi.DB_Arena_MobParticipants:Get(nil,nil,nil,nil)) do
		local inst,uuid,trig,team = table.unpack(db)
		if GetUUID(uuid) == source.MyGuid then
			Osi.DB_Arena_MobParticipants(inst, dupe.MyGuid, trig, team)
			SetInArena(dupe.MyGuid, 1)
			SetFaction(dupe.MyGuid, team)
			return true
		end
	end
	return false
end

---@param source EsvCharacter
---@param makeTemporary boolean|nil
---@param skipTracking boolean|nil
---@return UUID
local function Duplicate(source, makeTemporary, skipTracking)
	local uuid = source.MyGuid
	local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(source.WorldPos, 12.0)
	local dupeId = nil
	if makeTemporary ~= true then
		dupeId = StringHelpers.GetUUID(CharacterCreateAtPosition(x,y,z, "LLENEMY_Dupe_A_54ad4e06-b57f-46d0-90fc-5da1208250e0", 0))
	else
		dupeId = StringHelpers.GetUUID(TemporaryCharacterCreateAtPosition(x,y,z, "LLENEMY_Dupe_A_54ad4e06-b57f-46d0-90fc-5da1208250e0", 0))
		SetTag(dupeId, "LeaderLib_TemporaryCharacter")
	end
	
	if dupeId == nil then
		Ext.Utils.PrintError("[SEUO:Duplicate] Failed to create duplicant at", x, y, z, "for", source.MyGuid)
		return nil
	end
	SetOnStage(dupeId, 0)
	CharacterSetDetached(dupeId, 1)
	SetVarObject(dupeId, "LLENEMY_Duplicant_Owner", uuid)
	CharacterTransformAppearanceTo(dupeId, uuid, 1, 1)

	SetFaction(dupeId, GetFaction(uuid))
	SetTag(dupeId, "LLENEMY_Duplicant")
	SetTag(dupeId, "LLFULOOT_LootDisabled")

	local dupe = Ext.GetCharacter(dupeId)
	
	Duplication.CopyStats(source, dupe, source.Stats.Name)
	Duplication.CopyTalents(source, dupe)
	Duplication.CopyName(source, dupe)
	Duplication.CopyCP(source, dupe)
	CopyStatuses(source, dupe)
	ApplyStatus(dupeId, "LEADERLIB_RECALC", 0.0, 1, dupeId)

	local scale = source.Scale
	GameHelpers.SetScale(dupe, scale)

	ApplyStatus(dupeId, "LLENEMY_DUPLICANT", -1.0, 0, dupeId)
	NRD_CharacterSetStatInt(dupeId, "CurrentArmor", source.Stats.CurrentArmor)
	NRD_CharacterSetStatInt(dupeId, "CurrentMagicArmor", source.Stats.CurrentMagicArmor)
	NRD_CharacterSetStatInt(dupeId, "CurrentVitality", source.Stats.CurrentVitality)
	CharacterSetHitpointsPercentage(dupeId, math.min(100.0, (source.Stats.CurrentVitality/source.Stats.MaxVitality)*100))

	if makeTemporary ~= true then
		local arenaDB = Osi.DB_Arena_MobParticipants:Get(nil, source.MyGuid, nil, nil)
		if arenaDB and #arenaDB > 0 then
			local inst,_,trigger,team = table.unpack(arenaDB[1])
			Osi.DB_Arena_MobParticipants(inst, dupe.MyGuid, trigger, team)
			SetInArena(dupe.MyGuid, 1)
			SetFaction(dupe.MyGuid, team)
		end
	end

	TeleportToRandomPosition(dupeId, 6.0, "LLENEMY_DupeCharacterTeleported")
	CharacterSetDetached(dupeId, 0)
	CharacterSetFollowCharacter(dupeId, source.MyGuid)
	PlayEffect(dupeId, "RS3_FX_GP_ScriptedEvent_Teleport_GenericSmoke_01")

	return dupeId
end

---@param enemy EsvCharacter
local function IgnoreCharacter(enemy)
	if enemy:HasTag("LLENEMY_Duplicant") then
		return true
	end
	if CharacterIsPartyMember(enemy.MyGuid) == 1
		or CharacterIsPlayer(enemy.MyGuid) == 1 
		or CharacterIsSummon(enemy.MyGuid) == 1
		or CharacterIsPartyFollower(enemy.MyGuid) == 1 then
		return true
	end
	for i,db in pairs(Osi.DB_LLSENEMY_Duplication_Blacklist:Get(nil)) do
		if StringHelpers.GetUUID(db[1]) == enemy.MyGuid then
			return true
		end
	end
	if IsBoss(enemy.MyGuid) == 1 and Settings.Global:FlagEquals("LLENEMY_BossDuplicationEnabled", true) then
		return true
	end
	if ObjectGetFlag(enemy.MyGuid, "LLENEMY_HasDuplicant") == 1 or enemy:HasTag("LLENEMY_DuplicationBlocked") then
		return true
	end
	return false
end

---@param source EsvCharacter
---@param force boolean|nil
---@param makeTemporary boolean|nil
---@param skipTracking boolean|nil
---@return string[]
function Duplication.StartDuplicating(source, force, makeTemporary, skipTracking)
	if force == true or Settings.Global:FlagEquals("LLENEMY_DuplicationEnabled", true) then
		if force ~= true and IgnoreCharacter(source) then
			return nil
		end
		if force == true then
			local dupes = {}
			local max = math.max(1, Settings.Global.Variables.Duplication_MaxDupesPerEnemy.Value or 1)
			for i=Ext.Random(1, max),1,-1 do
				local dupe = Duplicate(source, makeTemporary, skipTracking)
				if dupe ~= nil then
					table.insert(dupes, dupe)
					if skipTracking ~= true then
						ObjectSetFlag(source.MyGuid, "LLENEMY_HasDuplicant", 0)
						PersistentVars.ActiveDuplicants[dupe] = source.MyGuid
					end
				end
			end
			return dupes
		else
			local currentTotal = Common.TableLength(PersistentVars.ActiveDuplicants, true)
			local maxTotal = Settings.Global.Variables.Duplication_MaxTotal.Value or -1
			if maxTotal < 0 or (maxTotal > 0 and currentTotal < maxTotal) then
				local min = Settings.Global.Variables.Duplication_MinDupesPerEnemy.Value or 0
				local max = Settings.Global.Variables.Duplication_MaxDupesPerEnemy.Value or 1
				local chance = Settings.Global.Variables.Duplication_Chance.Value or 30
				if (chance >= 100 or Ext.Random(1,100) <= chance) then
					local amount = Ext.Random(min, max)
					if amount > 0 then
						local dupes = {}
						for i=amount,1,-1 do
							local dupe = Duplicate(source, makeTemporary, skipTracking)
							if dupe ~= nil then
								table.insert(dupes, dupe)
								if skipTracking ~= true then
									ObjectSetFlag(source.MyGuid, "LLENEMY_HasDuplicant", 0)
									PersistentVars.ActiveDuplicants[dupe] = source.MyGuid
								end
							end
						end
						return dupes
					end
				end
			end
		end
	end
	return nil
end

local function CleanupDupe(uuid)
	if ObjectExists(uuid) == 1 then
		Osi.LeaderLib_Tags_ClearAllPreservedTagData(uuid)
		SetOnStage(uuid, 0)
	end
	PersistentVars.ActiveDuplicants[uuid] = nil
end

--region Ported Osiris Rules
RegisterProtectedOsirisListener("CharacterWentOnStage", 1, "after", function(char)
	if IsTagged(char, "LLENEMY_Duplicant") == 1 and CharacterIsDead(char) == 1 then
		SetOnStage(char, 0)
	end
end)

RegisterProtectedOsirisListener("CharacterDied", 1, "after", function(char)
	if IsTagged(char, "LLENEMY_Duplicant") == 1 then
		char = StringHelpers.GetUUID(char)
		CleanupDupe(char)
	end
end)

RegisterProtectedOsirisListener("CharacterRelationChangedTo", 3, "after", function(character, target, attitude)
	character = StringHelpers.GetUUID(character)
	if ObjectGetFlag(character, "LLENEMY_HasDuplicant") == 1 then
		for uuid,source in pairs(PersistentVars.ActiveDuplicants) do
			if source == character then
				ChangeAttitude(uuid, target, attitude)
			end
		end
	end
end)

Ext.RegisterOsirisListener("RegionEnded", 1, "after", function(region)
	for uuid,source in pairs(PersistentVars.ActiveDuplicants) do
		CleanupDupe(uuid)
	end
end)

RegisterProtectedOsirisListener("ObjectEnteredCombat", 2, "after", function(character, combatID)
	character = StringHelpers.GetUUID(character)
	if ObjectGetFlag(character, "LLENEMY_HasDuplicant") == 1 then
		for uuid,source in pairs(PersistentVars.ActiveDuplicants) do
			if source == character and ObjectIsOnStage(uuid) == 0 then
				TeleportTo(uuid, character, "", 0, 1)
				CharacterSetDetached(uuid, 0)
				SetOnStage(uuid, 1)
			end
		end
	end
end)

RegisterProtectedOsirisListener("ObjectLeftCombat", 2, "after", function(character, combatID)
	character = StringHelpers.GetUUID(character)
	if ObjectGetFlag(character, "LLENEMY_HasDuplicant") == 1 then
		for uuid,source in pairs(PersistentVars.ActiveDuplicants) do
			if source == character and CharacterIsDead(character) == 0 then
				LeaveCombat(uuid)
				SetOnStage(uuid, 0)
			end
		end
	end
end)
--endregion