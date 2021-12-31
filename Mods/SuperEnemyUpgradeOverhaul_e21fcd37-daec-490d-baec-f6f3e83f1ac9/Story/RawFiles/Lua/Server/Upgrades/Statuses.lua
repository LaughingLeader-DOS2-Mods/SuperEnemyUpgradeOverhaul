StatusManager.Register.Removed("RESURRECT", function(target, status, source, statusType, statusEvent)
	if GameHelpers.ObjectHasFlag(target, "LLENEMY_AddedGrenadeStash") then
		GameHelpers.Status.Apply(target, "LLENEMY_GRANADA", -1.0, false, target)
	end
end)

local grenadeExplodeText = Classes.TranslatedString:CreateFromKey("LLENEMY_StatusText_GrenadeExploded", "<font color='#FF3333'>[1] Exploded!</font>")
local grenadeExplodeCombatLogText = Classes.TranslatedString:CreateFromKey("LLENEMY_CombatLog_GrenadeExploded", "[1] fell and exploded a grenade ([2]) as a result ([3]).")

---Explode a random grenade skill after falling down.
---@param target EsvCharacter|UUID
function Upgrade_GrenadeEnthusiast_ExplodeGrenade(target)
	target = GameHelpers.GetCharacter(target)
	local skill = Common.GetRandomTableEntry(UpgradeSystem.Settings.GrenadeSkills)
	GameHelpers.Skill.Explode(target, skill, target)
	local name = GameHelpers.GetStringKeyText(Ext.StatGetAttribute(skill, "DisplayName"), "Grenade")
	local text = grenadeExplodeText:ReplacePlaceholders(name)
	local statusName = GameHelpers.GetStringKeyText(Ext.StatGetAttribute("LLENEMY_GRANADA", "DisplayName"), "Grenade Enthusiast")
	CharacterStatusText(target.MyGuid, text)
	CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, grenadeExplodeCombatLogText:ReplacePlaceholders(target.DisplayName, name, statusName))
end

StatusManager.Register.Applied("KNOCKED_DOWN", function(target, status, source, statusType, statusEvent)
	if GameHelpers.Status.IsActive(target, "LLENEMY_GRANADA") then
		Upgrade_GrenadeEnthusiast_ExplodeGrenade(target)
	end
end)

StatusManager.Register.Applied("LLENEMY_GRANADA", function(target, status, source, statusType, statusEvent)
	if not GameHelpers.ObjectHasFlag(target, "LLENEMY_AddedGrenadeStash") then
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

---@param target EsvCharacter|EsvItem
---@param status EsvStatus
---@param source EsvCharacter|EsvItem|nil
---@param statusType string
---@param statusEvent StatusEventID
local function CheckSurfaces(target, status, source, statusType, statusEvent)
	if GameHelpers.Status.IsActive(target, "LLENEMY_DEMONIC_HASTED")
	and not GameHelpers.Status.IsDisabled(target)
	and not target.Stats.SlippingImmunity
	and not target.Stats.KnockdownImmunity
	and GameHelpers.Character.IsInSurface(target, "Frozen")
	then
		Timer.ClearObjectData("LLENEMY_DemonicHasted_CheckForMovement", target)
		Timer.StartObjectTimer("LLENEMY_DemonicHasted_CheckForMovement", target, 750, GameHelpers.Math.GetPosition(target))
	end

	if GameHelpers.Status.IsActive(target, "LLENEMY_TALENT_NATURALCONDUCTOR") 
	and GameHelpers.Character.IsInSurface(target, "Electrified")
	then
		GameHelpers.Status.Apply(target, "HASTED", 6.0, false, target)
	end
end

--Demonic Hasted slipping weakness
Timer.RegisterListener("LLENEMY_DemonicHasted_CheckForMovement", function(timerName, target, startPosition)
	if not GameHelpers.Status.IsDisabled(target)
	and GameHelpers.Character.IsInSurface(target, "Frozen")
	then
		local startTimer = true
		if GameHelpers.Math.GetDistance(target, startPosition) >= 0.5 then
			local success,roll = GameHelpers.Roll(GameHelpers.GetExtraData("LLENEMY_DemonicHasted_SlipSaveChance", 20))
			if not success then
				startTimer = false
				GameHelpers.Status.Apply(target, "KNOCKED_DOWN", 6.0, true, target)
				if roll == 0 then
					--Deal 20% of vitality as damage, but non-lethally
					local character = GameHelpers.GetCharacter(target)
					if character.Stats.CurrentVitality > 1 then
						local damageMult = GameHelpers.GetExtraData("LLENEMY_DemonicHasted_SlipDamagePercentage", 20) * 0.01
						if damageMult > 0 then
							local damage = math.max(character.Stats.MaxVitality * damageMult, character.Stats.CurrentVitality - 1)
							ApplyDamage(target, damage, "Physical", target)
						end
					end
				end
			end
		end
		if startTimer and GameHelpers.Status.IsActive(target, "LLENEMY_DEMONIC_HASTED") then
			Timer.ClearObjectData("LLENEMY_DemonicHasted_CheckForMovement", target)
			Timer.StartObjectTimer("LLENEMY_DemonicHasted_CheckForMovement", target, 750, GameHelpers.Math.GetPosition(target))
		end
	end
end)

StatusManager.Register.Applied({"INSURFACE", "LLENEMY_DEMONIC_HASTED", "LLENEMY_TALENT_NATURALCONDUCTOR"}, CheckSurfaces)

--region Rage

---Increases rage
---@param character EsvCharacter
---@param damage integer
function Upgrade_Rage_ApplyRage(character)
	character = GameHelpers.GetCharacter(character)
	if character then
		local rage = PersistentVars.Rage[character.MyGuid]
		if rage then
			local maxRage = UpgradeSystem.Settings.Rage.Max
			if rage >= maxRage then
				local status = UpgradeSystem.Settings.Rage.Statuses[#UpgradeSystem.Settings.Rage.Statuses].Status
				GameHelpers.Status.Apply(character, status, -1.0, false, character)
			else
				for i,v in pairs(UpgradeSystem.Settings.Rage.Statuses) do
					if rage >= v.Min and rage < v.Max then
						GameHelpers.Status.Apply(character, v.Status, -1.0, false, character)
						if GameHelpers.Character.IsHumanoid(character) then
							PlayEffect(character.MyGuid, "LLENEMY_FX_Status_Rage_Applied_01", "Dummy_BodyFX")
						else
							PlayEffect(character.MyGuid, "LLENEMY_FX_Status_Rage_Applied_01", "Dummy_OverheadFX")
						end
						return
					end
				end
			end
		end
	end
end

---Increases rage
---@param character EsvCharacter
---@param damage integer
function Upgrade_Rage_IncreaseRage(character, damage)
	character = GameHelpers.GetCharacter(character)
	if character then
		--The closer the damage is to the total HP, the more rage is gained.
		local addRage = math.ceil(math.max((damage / character.Stats.MaxVitality) * 88.88, 1.0))
		if not PersistentVars.Rage[character.MyGuid] then
			PersistentVars.Rage[character.MyGuid] = 0
		end
		PersistentVars.Rage[character.MyGuid] = math.min(UpgradeSystem.Settings.Rage.Max, PersistentVars.Rage[character.MyGuid] + addRage)
		Upgrade_Rage_ApplyRage(character)
	end
end

---Increases rage
---@param character EsvCharacter
---@param byLevels integer Lower rage by this many tiers (default 1).
function Upgrade_Rage_LowerRage(character, byLevels)
	character = GameHelpers.GetCharacter(character)
	if character then
		byLevels = byLevels or 1
		local rage = PersistentVars.Rage[character.MyGuid]
		if rage then
			local rageIndex = 0
			local setRage = 0
			for i,v in pairs(UpgradeSystem.Settings.Rage.Statuses) do
				if rage >= v.Min and rage < v.Max then
					setRage = v.Min + 1
					rageIndex = i
					break
				end
			end
			if rageIndex > 0 then
				rageIndex = math.max(0, rageIndex - byLevels)
				local entry = UpgradeSystem.Settings.Rage.Statuses[rageIndex]
				PersistentVars.Rage[character.MyGuid] = setRage
				GameHelpers.Status.Apply(character, entry.Status, -1.0, false, character)
				CharacterStatusText(character.MyGuid, "LLENEMY_StatusText_RageReduced")
			end
		end
	end
end

--Safeguard for if a rage status is applied without a backing variable set.
StatusManager.Register.Applied({"LLENEMY_RAGE","LLENEMY_RAGE2","LLENEMY_RAGE3","LLENEMY_RAGE4","LLENEMY_RAGE5"}, function(target, status, source, statusType, statusEvent)
	local currentRage = PersistentVars.Rage[target.MyGuid]
	for i,v in pairs(UpgradeSystem.Settings.Rage.Statuses) do
		if v.Status == status then
			if currentRage == nil or currentRage < v.Min then
				PersistentVars.Rage[target.MyGuid] = v.Min
			end
			return
		end
	end
end)

StatusManager.Register.Applied("SLEEPING", function(target, status, source, statusType, statusEvent)
	if GameHelpers.Character.HasFlag(target, "LLENEMY_Rage_Active") then
		Upgrade_Rage_LowerRage(target, 1)
	end
end)
--endregion

---@param target EsvCharacter
---@param source EsvCharacter
---@param data HitData
---@param hitStatus EsvStatusHit
RegisterListener("StatusHitEnter", function(target, source, data, hitStatus)
	if data.Success 
	and source 
	and source.MyGuid ~= target.MyGuid
	and data.Damage > 0
	and data.Success
	then
		if GameHelpers.Character.HasFlag(target, "LLENEMY_Rage_Active")
		and not target.Dead
		and not GameHelpers.Status.IsActive(target, "SLEEPING")
		then
			Upgrade_Rage_IncreaseRage(target, data.Damage)
		end
	end
end)