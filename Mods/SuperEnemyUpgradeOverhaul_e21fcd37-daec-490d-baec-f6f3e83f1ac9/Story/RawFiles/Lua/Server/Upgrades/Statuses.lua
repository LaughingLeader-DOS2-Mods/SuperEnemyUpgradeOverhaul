StatusManager.Register.Removed("RESURRECT", function(target, status, source, statusType, statusEvent)
	if ObjectGetFlag(target, "LLENEMY_AddedGrenadeStash") == 1 then
		ApplyStatus(target, "LLENEMY_GRANADA", -1.0, 0, target)
	end
end)

StatusManager.Register.Applied("KNOCKED_DOWN", function(target, status, source, statusType, statusEvent)
	if HasActiveStatus(target, "LLENEMY_GRANADA") == 1 then
		ExplodeGrenade(target)
	end
end)

StatusManager.Register.Applied("LLENEMY_GRANADA", function(target, status, source, statusType, statusEvent)
	if ObjectGetFlag(target, "LLENEMY_AddedGrenadeStash") == 0 then
		CharacterGiveReward(target, "LLENEMY_GranadaStatus_GrenadeStash", 1)
		ObjectSetFlag(target, "LLENEMY_AddedGrenadeStash", 0)
	end
end)

StatusManager.Register.Applied("LLENEMY_DOUBLE_DIP", function(target, status, source, statusType, statusEvent)
	PlayEffect(target, "LLENEMY_FX_Status_DoubleDip_Overlay_01", "")
	OnDoubleDipApplied(target)
end)

local function ApplyActiveDefense(target, status, source, statusType, statusEvent)
	local activeDefenseStatus = UpgradeSystem.Settings.ActiveDefenseStatuses[status]
	if activeDefenseStatus then
		NRD_ApplyActiveDefense(target, activeDefenseStatus, -1.0)
	end
end

StatusManager.Register.Applied("LLENEMY_ACTIVATE_FLAMING_TONGUES", function(target, status, source, statusType, statusEvent)
	ApplyActiveDefense(target, status, source, statusType, statusEvent)
end)

StatusManager.Register.Applied("LLENEMY_ACTIVATE_HEALING_TEARS", function(target, status, source, statusType, statusEvent)
	ApplyActiveDefense(target, status, source, statusType, statusEvent)
end)

StatusManager.Register.Applied("LLENEMY_INF_SET_ELEMENT", function(target, status, source, statusType, statusEvent)
	SetIncarnateSurfaceBuff(target, source)
end)

StatusManager.Register.Applied("LLENEMY_CLASS_INCARNATEKING", function(target, status, source, statusType, statusEvent)
	ModifySummoningAbility(target)
end)

local function OnAutomatonSummon(target, status, source, statusType, statusEvent)
	if statusEvent == "Applied" then
		if PersistentVars.WaitForStatusRemoval[target] == nil then
			PersistentVars.WaitForStatusRemoval[target] = {}
		end
		PersistentVars.WaitForStatusRemoval[target][status] = true
	elseif statusEvent == "Removed" then
		if CharacterIsDead(target) == 0 then
			Timer.StartObjectTimer("LLENEMY_Statuses_SummonAutomaton", target, 250)
		end
	end
end

Timer.RegisterListener("LLENEMY_Statuses_SummonAutomaton", function(timerName, uuid)
	SummonAutomaton(uuid)
end)

RegisterListener("ObjectEvent", "LLENEMY_Automaton_PlayActivateAnimation", function(uuid, event)
	PlayAnimation(uuid, "Custom_Activate_01", "LLENEMY_Automaton_ClearInactive")
	SummonSetFaction(uuid)
end)

StatusManager.Register.Removed("LLENEMY_AUTOMATON_INACTIVE", function(target, status, source, statusType, statusEvent)
	local summon = GameHelpers.GetCharacter(target)
	if summon.HasOwner then
		local owner = GameHelpers.GetCharacter(summon.OwnerHandle)
		if owner then
			ApplyStatus(summon.MyGuid, "SUMMONING_ABILITY", summon.LifeTime, 1, owner.MyGuid)
		end
	end
end)