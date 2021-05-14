ItemBonusManager.AllItemBonuses.ShockingRain = ItemBonusManager.CreateSkillBonus({"Rain_Water", "Rain_EnemyWater"}, 
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

ItemBonusManager.AllItemBonuses.TimeHaste = ItemBonusManager.CreateSkillBonus({"Target_Haste", "Target_EnemyHaste"}, 
function(skill, char, state, skillData)
	return state == SKILL_STATE.CAST and (ObjectGetFlag(char, "LLENEMY_ShadowBonus_TimeHaste_Enabled") == 1 and ObjectGetFlag(char, "LLENEMY_TimeHastedUsed") == 0)
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
					local casterIndex = 1
					local targetEntry = nil
					local nextOrder = {}
					for i,v in ipairs(order) do
						if v.Character.MyGuid == target then
							targetEntry = v
						else
							if v.Character.MyGuid == char then
								casterIndex = i
							end
							nextOrder[#nextOrder+1] = v
						end
					end
					--Turn ended after casting Haste?
					if casterIndex > 1 then
						casterIndex = 1
					end
					if targetEntry then
						table.insert(nextOrder, casterIndex+1, targetEntry)
						combat:UpdateCurrentTurnOrder(nextOrder)
						local text = GameHelpers.GetStringKeyText("LLENEMY_StatusText_TimeHasted", "<font color='#88CCFF'>Time Skip!</font>")
						CharacterStatusText(target, text)
						SetTag(char, "LLENEMY_TimeHasteUsed")
						PlayEffectAtPosition("RS3_FX_Skills_Void_Divine_Impact_Root_01", GetPosition(target))
						Combat.WaitForEnd(id, char)
					else
						Ext.PrintWarning("[SEUO:TimeHaste] Failed to find target character in combat turn order.")
					end
				end
			end
		end
	end, data.TargetMode.Objects)
end)

Combat.ClearFlagOrTag.TimeHaste = CLEARTYPE.Tag

ItemBonusManager.AllItemBonuses.BloodyWinter = ItemBonusManager.CreateUnregisteredBonus(
function(skill, char, state, skillData)
	return state == SKILL_STATE.CAST and ObjectGetFlag(char, "LLENEMY_ShadowBonus_BloodyWinter_Enabled") == 1
end,
function(skill, char, state, skillData)
	local grid = Ext.GetAiGrid()
	---@type SkillEventData
	local data = skillData
	data:ForEach(function(target, t, self)
		local x,y,z = nil,nil,nil
		if t == "table" then
			x,y,z = table.unpack(target)
		else
			x,y,z = GetPosition(target)
		end
		if x and z then
			local surfaceData = GameHelpers.Grid.GetSurfaces(x, z, grid, 2.0)
			if surfaceData then
				for _,v in pairs(surfaceData.Ground) do
					local surface = v.Surface
					if string.find(string.lower(surface.SurfaceType), "water") then
						GameHelpers.Surface.Transform(v.Position, "Bloodify", 0, surface.LifeTime, surface.OwnerHandle, surface.SurfaceType, surface.StatusChance)
						GameHelpers.Surface.Transform(v.Position, "Freeze", 0, surface.LifeTime, surface.OwnerHandle, surface.SurfaceType, surface.StatusChance)
					end
				end
			end

			--Ground water surfaces
			-- if surfaceData and surfaceData.HasSurface("water", true, 0) then
				
			-- end
		end
	end, data.TargetMode.All)
end)