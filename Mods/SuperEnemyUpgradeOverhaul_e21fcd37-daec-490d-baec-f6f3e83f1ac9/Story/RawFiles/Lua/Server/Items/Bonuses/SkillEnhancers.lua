ItemBonusManager.AllItemBonuses.ShockingRain = ItemBonusManager.RegisterToSkillListener({"Rain_Water", "Rain_EnemyWater"}, 
function(skill, char, state, skillData)
	return state == SKILL_STATE.CAST and ObjectGetFlag(char, "LLENEMY_ShadowBonus_ShockingRain_Enabled") == 1
end,
function(skill, char, state, skillData)
	local target = skillData.TargetPositions[1] or skillData.TargetObjects[1]
	local x,y,z = 0
	if type(target) == "string" then
		x,y,z = GetPosition(target)
	else
		x,y,z = table.unpack(target)
	end
	local handle = NRD_CreateStorm(char, "Storm_LLENEMY_ShadowBonus_LightningStorm", x, y, z)
	NRD_GameActionSetLifeTime(handle, 12.0)
end)