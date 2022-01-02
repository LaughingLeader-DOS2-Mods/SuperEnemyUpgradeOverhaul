---@param character EsvCharacter
local function CanPulse(character)
	return not GameHelpers.Status.IsActive(character, "LLENEMY_SEEKER_DISABLED")
	and GameHelpers.Status.IsActive(character, "LLENEMY_SEEKER")
	and (GameHelpers.Character.IsInCombat(character)
	or character.CharacterControl
	or Vars.DebugMode)
end

local function AnyPlayerIsHidden()
	for player in GameHelpers.Character.GetPlayers(true) do
		if GameHelpers.Character.IsSneakingOrInvisible(player) then
			return true
		end
	end
	return false
end

---@param target UUID
---@param source UUID
function Upgrade_Seeker_RemoveInvisible(target, source)
	target = GameHelpers.GetUUID(target)
	source = GameHelpers.GetUUID(target)
	local detected = false
	if target then
		for status,b in pairs(InvisibleStatuses) do
			if b == true and GameHelpers.Status.IsActive(target, status) == 1 then
				RemoveStatus(target, status)
				detected = true
			end
		end
		if detected then
			CharacterStatusText(target, "LLENEMY_StatusText_SeekerDiscoveredTarget")
			if source then
				PlayEffect(source, "RS3_FX_GP_Status_Warning_Red_01", "Dummy_OverheadFX")
				Osi.CharacterSawSneakingCharacter(source, target)
			end
		end
	end
	return detected
end

---@param character EsvCharacter
function Upgrade_Seeker_PulseNow(character)
	character = GameHelpers.GetCharacter(character)
	if character and CanPulse(character) then
		local range = GameHelpers.GetExtraData("LLENEMY_Seeker_PulseRange", 4)
		if range > 0 then
			for _,v in pairs(character:GetNearbyCharacters(range)) do
				if v ~= character.MyGuid 
				and GameHelpers.Character.IsSneakingOrInvisible(v)
				and GameHelpers.Character.IsEnemy(character.MyGuid, v)
				then
					Upgrade_Seeker_RemoveInvisible(v, character.MyGuid)
				end
			end
		end
	end
end

RegisterProtectedOsirisListener("ObjectTurnStarted", 1, "after", Upgrade_Seeker_PulseNow)
RegisterProtectedOsirisListener("ObjectTurnEnded", 1, "after", function(obj)
	Upgrade_Seeker_TakeAction(obj)
end)

local function ToggleSeekerEffect(on)
	if on then
		for uuid,b in pairs(PersistentVars.Seekers) do
			local character = GameHelpers.GetCharacter(uuid)
			if character and not character.Dead and character.Activated then
				GameHelpers.Status.Apply(uuid, "LLENEMY_SEEKER_FX", -1.0, false, uuid)
				Timer.StartObjectTimer("LLENEMY_Seeker_PulseNow", uuid, 6000)
			end
		end
	else
		if not AnyPlayerIsHidden() then
			for uuid,b in pairs(PersistentVars.Seekers) do
				GameHelpers.Status.Remove(uuid, "LLENEMY_SEEKER_FX")
				Timer.Cancel("LLENEMY_Seeker_PulseNow", uuid)
			end
		end
	end
end

Timer.RegisterListener("LLENEMY_Seeker_PulseNow", function(timerName, uuid)
	Upgrade_Seeker_PulseNow(uuid)
	local character = GameHelpers.GetCharacter(uuid)
	if character.Activated and CharacterIsInCombat(uuid) == 0 and AnyPlayerIsHidden() then
		Timer.StartObjectTimer("LLENEMY_Seeker_PulseNow", uuid, 10000)
	end
end)

StatusManager.Register.Applied("LLENEMY_SEEKER", function(target, status, source, statusType, statusEvent)
	local fov = NRD_CharacterGetPermanentBoostInt(target.MyGuid, "FOV")
	if fov < 360 then
		NRD_CharacterSetPermanentBoostInt(target.MyGuid, "FOV", 360)
	end
	local sight = NRD_CharacterGetPermanentBoostInt(target.MyGuid, "Sight")
	if sight ~= 2 then
		NRD_CharacterSetPermanentBoostInt(target.MyGuid, "Sight", 2)
	end
	NRD_CharacterSetPermanentBoostInt(target.MyGuid, "Sight", 2)
	CharacterAddAttribute(target.MyGuid, "Dummy", 0)
	PersistentVars.Seekers[target.MyGuid] = true
	ToggleSeekerEffect(AnyPlayerIsHidden())
end)

StatusManager.Register.Removed("LLENEMY_SEEKER", function(target, status, source, statusType, statusEvent)
	NRD_CharacterSetPermanentBoostInt(target.MyGuid, "FOV", 0)
	NRD_CharacterSetPermanentBoostInt(target.MyGuid, "Sight", 0)
	CharacterAddAttribute(target.MyGuid, "Dummy", 0)
	Timer.Cancel("LLENEMY_Seeker_PulseNow", target.MyGuid)
	PersistentVars.Seekers[target.MyGuid] = nil
end)

StatusManager.Register.Applied("DRUNK", function(target, status, source, statusType, statusEvent)
	if GameHelpers.Status.IsActive(target, "LLENEMY_SEEKER") then
		GameHelpers.Status.Apply(target, "LLENEMY_SEEKER_DISABLED", -1.0, true, target)
	end
end)

StatusManager.Register.Removed("DRUNK", function(target, status, source, statusType, statusEvent)
	if GameHelpers.Status.IsActive(target, "LLENEMY_SEEKER_DISABLED") then
		GameHelpers.Status.Remove(target, "LLENEMY_SEEKER_DISABLED")
		GameHelpers.Status.Apply(target, "LLENEMY_SEEKER", -1.0, true, target)
	end
end)

UpgradeSystem.Settings.Seeker = {
	DetectionSkills = {
		"Rain_Water",
		"Rain_EnemyWater",
	}
}

---@param character EsvCharacter
function Upgrade_Seeker_TakeAction(character)
	character = GameHelpers.GetCharacter(character)
	if character and AnyPlayerIsHidden() then
		for _,skill in pairs(UpgradeSystem.Settings.Seeker) do
			if CharacterHasSkill(character.MyGuid, skill) == 1 
			and NRD_SkillGetCooldown(character.MyGuid, skill) == 0.0 then
				CharacterUseSkill(character.MyGuid, skill, character.MyGuid, 1, 0, 0)
				return true
			end
		end
	end
end

StatusManager.Register.Applied("SNEAKING", function(target, status, source, statusType, statusEvent)
	if target.CharacterControl then
		ToggleSeekerEffect(true)
	end
end)

StatusManager.Register.Type.Applied("INVISIBLE", function(target, status, source, statusType, statusEvent)
	if CharacterIsControlled(target) == 1 then
		ToggleSeekerEffect(true)
	end
end)

StatusManager.Register.Type.Removed("INVISIBLE", function(target, status, source, statusType, statusEvent)
	ToggleSeekerEffect(false)
end)

StatusManager.Register.DisablingStatus.Applied(function(target, status, source, statusType, statusEvent, loseControl)
	if GameHelpers.Status.IsActive(target, "LLENEMY_SEEKER") then
		GameHelpers.Status.Apply(target, "LLENEMY_SEEKER_DISABLED", -1.0, true, target)
	end
end)

StatusManager.Register.DisablingStatus.Removed(function(target, status, source, statusType, statusEvent, loseControl)
	if GameHelpers.Status.IsActive(target, "LLENEMY_SEEKER_DISABLED") then
		GameHelpers.Status.Remove(target, "LLENEMY_SEEKER_DISABLED")
		GameHelpers.Status.Apply(target, "LLENEMY_SEEKER", -1.0, true, target)
	end
end)

RegisterProtectedOsirisListener("ObjectEnteredCombat", 2, "after", function(obj, combatid)
	if GameHelpers.Status.IsActive(obj, "LLENEMY_SEEKER") then
		Timer.Cancel("LLENEMY_Seeker_PulseNow", StringHelpers.GetUUID(obj))
	end
end)

RegisterProtectedOsirisListener("ObjectLeftCombat", 2, "after", function(obj, combatid)
	if GameHelpers.Status.IsActive(obj, "LLENEMY_SEEKER") then
		Timer.StartObjectTimer("LLENEMY_Seeker_PulseNow", StringHelpers.GetUUID(obj), 1000)
	end
end)