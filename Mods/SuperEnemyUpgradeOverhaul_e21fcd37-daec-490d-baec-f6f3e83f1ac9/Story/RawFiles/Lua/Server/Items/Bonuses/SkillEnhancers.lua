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

ItemBonusManager.AllItemBonuses.TimeHaste = ItemBonusManager.RegisterToSkillListener({"Target_Haste", "Target_EnemyHaste"}, 
function(skill, char, state, skillData)
	return state == SKILL_STATE.CAST and ObjectGetFlag(char, "LLENEMY_ShadowBonus_TimeHaste_Enabled") == 1 and ObjectGetFlag(char, "LLENEMY_TimeHastedUsed") == 0
end,
function(skill, char, state, skillData)
	---@type SkillEventData
	local data = skillData
	data:ForEach(function(target, t, self)
		if target ~= char and CharacterIsAlly(target, char) == 1 then
			local id = CombatGetIDForCharacter(target)
			if id then
				local combat = Ext.GetCombat(id)
				if combat then
					local order = combat:GetCurrentTurnOrder()
					local casterIndex = -1
					local targetEntry = nil
					for i,v in ipairs(order) do
						if v.Character then
							if v.Character.MyGuid == char then
								casterIndex = i
							elseif v.Character.MyGuid == target then
								targetEntry = v
								table.remove(order, i)
							end
						end
					end
					if casterIndex > -1 and targetEntry then
						table.insert(order, casterIndex+1, targetEntry)
						combat:UpdateCurrentTurnOrder(order)
						local text = GameHelpers.GetStringKeyText("LLENEMY_StatusText_TimeHasted", "<font color='#88CCFF'>Time Hasted!</font>")
						CharacterStatusText(target, text)
						SetTag(char, "LLENEMY_TimeHasteUsed", 0)
						WaitForCombatToEnd(id, char)
					end
				end
			end
		end
	end, data.TargetMode.Objects)
end)

CombatEndedClearFlags.TimeHaste = CLEARTYPE.Tag