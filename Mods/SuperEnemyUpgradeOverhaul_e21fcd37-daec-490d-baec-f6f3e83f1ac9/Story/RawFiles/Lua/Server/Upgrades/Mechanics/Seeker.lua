---@param character EsvCharacter
local function CanPulse(character)
	return not GameHelpers.Status.IsActive(character, "LLENEMY_SEEKER_DISABLED")
	and (GameHelpers.Character.IsInCombat(character)
	or character.CharacterControl
	or Vars.DebugMode)
end

---@param character EsvCharacter
function Upgrade_Seeker_PulseNow(character)
	character = GameHelpers.GetCharacter(character)
	if character and CanPulse(character) then
		GameHelpers.Skill.Explode(character, "Projectile_LLENEMY_Status_Seeker_Pulse", character)
	end
end

Timer.RegisterListener("LLENEMY_Statuses_Seeker_PulseNow", function(timerName, uuid)
	Upgrade_Seeker_PulseNow(uuid)
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
end)

StatusManager.Register.Removed("LLENEMY_SEEKER", function(target, status, source, statusType, statusEvent)
	NRD_CharacterSetPermanentBoostInt(target.MyGuid, "FOV", 0)
	NRD_CharacterSetPermanentBoostInt(target.MyGuid, "Sight", 0)
	CharacterAddAttribute(target.MyGuid, "Dummy", 0)
	Timer.Cancel("LLENEMY_Statuses_Seeker_PulseNow", target.MyGuid)
	PersistentVars.Seekers[target.MyGuid] = nil
end)

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

StatusManager.Register.Applied("LLENEMY_SEEKER_CLEANSE_INVISIBLE", function(target, status, source, statusType, statusEvent)
	Upgrade_Seeker_RemoveInvisible(target, source)
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

local function AnyPlayerIsHidden()
	for player in GameHelpers.Character.GetPlayers(true) do
		if GameHelpers.Character.IsSneakingOrInvisible(player) then
			return true
		end
	end
	return false
end

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

local function ToggleSeekerEffect(on)
	if on then
		for uuid,b in pairs(PersistentVars.Seekers) do
			if CharacterCanSee(target.MyGuid, uuid) == 1 then
				GameHelpers.Status.Apply(uuid, "LLENEMY_SEEKER_FX", -1.0, false, uuid)
			end
		end
	else
		if not AnyPlayerIsHidden() then
			for uuid,b in pairs(PersistentVars.Seekers) do
				GameHelpers.Status.Remove(uuid, "LLENEMY_SEEKER_FX")
			end
		end
	end
end

StatusManager.Register.Applied("SNEAKING", function(target, status, source, statusType, statusEvent)
	if target.CharacterControl then
		ToggleSeekerEffect(true)
	end
end)

RegisterStatusTypeListener("Applied", "INVISIBLE", function(target, status, source, statusType, statusEvent)
	if CharacterIsControlled(target) == 1 then
		ToggleSeekerEffect(true)
	end
end)

RegisterStatusTypeListener("Removed", "INVISIBLE", function(target, status, source, statusType, statusEvent)
	ToggleSeekerEffect(false)
end)