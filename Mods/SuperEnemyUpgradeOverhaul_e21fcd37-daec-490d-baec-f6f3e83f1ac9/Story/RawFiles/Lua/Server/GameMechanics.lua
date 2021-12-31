---Increases rage
---@param character string
---@param damage integer
---@param handle integer
function IncreaseRage(character, damage, handle, source)
	--local hp = NRD_CharacterGetStatInt(character, "CurrentVitality")
	local maxhp = NRD_CharacterGetStatInt(character, "MaxVitality")
	local damage_ratio = math.max((damage / maxhp) * 88.88, 1.0)
	local add_rage = math.ceil(damage_ratio)
	Osi.LeaderLib_Variables_DB_ModifyVariableInt(character, "LLENEMY_Rage", add_rage, 100, 0, source);
	local rage_entry = Osi.DB_LeaderLib_Variables_Integer:Get(character, "LLENEMY_Rage", nil, nil)
	--PrintDebug("[LLENEMY_GameMechanics.lua:IncreaseRage] Added ("..tostring(add_rage)..") Rage to ("..tostring(character).."). Total: ("..tostring(rage_entry[1][3])..")")
end

function RemoveInvisible(target, source)
	local detected = false
	for status,b in pairs(InvisibleStatuses) do
		if b == true and HasActiveStatus(target, status) == 1 then
			RemoveStatus(target, status)
			detected = true
		end
	end
	if detected then
		CharacterStatusText(target, "LLENEMY_StatusText_SeekerDiscoveredTarget")
		PlayEffect(source, "RS3_FX_GP_Status_Warning_Red_01", "Dummy_OverheadFX")
		Osi.CharacterSawSneakingCharacter(source, target)
	end
	return detected
end

function CharacterIsHidden(target)
	for status,b in pairs(InvisibleStatuses) do
		if b == true and HasActiveStatus(target, status) == 1 then
			return 1
		end
	end
	return 0
end

function ClearGain(char)
	--ScaleExperienceByPlayerLevel_d5e1b4bc-dc7b-43dc-8bd0-d9f2b5e3a418
	if Ext.IsModLoaded("d5e1b4bc-dc7b-43dc-8bd0-d9f2b5e3a418") then
		SetTag(char, "LLXPSCALE_DisableDeathExperience")
	end
	local gain = NRD_CharacterGetPermanentBoostInt(char, "Gain")
	if gain > 0 then
		NRD_CharacterSetPermanentBoostInt(char, "Gain", gain * -1)
		CharacterAddAttribute(char, "Dummy", 0)
	end
end

function SpawnTreasureGoblin(x,y,z,level,combatid)
	local host = CharacterGetHostCharacter()
	if level == nil then
		level = CharacterGetLevel(host)
	end
	if x == nil or y == nil or z == nil then
		x,y,z = GetPosition(host)
	end
	if combatid == nil then
		combatid = 0
	end
	local goblin = CharacterCreateAtPosition(x, y, z, "444e50a0-e59b-4866-b548-49a0197a0de1", 1)
	CharacterLevelUpTo(goblin, level)
	Osi.DB_LLSENEMY_TreasureGoblins_Temp_Active(goblin)
	--SetStoryEvent(goblin, "LeaderLib_Commands_EnterCombatWithPlayers")
	Osi.LLSENEMY_TreasureGoblins_Internal_OnGoblinSpawned(goblin, combatid, x, y, z)
	Osi.LLSENEMY_Rewards_TreasureGoblin_ToggleScript(1)
	Osi.LeaderLib_Helper_MakeHostileToPlayers(goblin)
	Osi.LeaderLib_Timers_StartObjectTimer(goblin, 1000, "Timers_LLENEMY_Goblin_EnterCombatWithPlayers", "LeaderLib_Commands_EnterCombatWithPlayers")
end