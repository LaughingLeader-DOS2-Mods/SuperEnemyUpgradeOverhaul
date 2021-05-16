ItemBonusManager.AllItemBonuses.ShockingRain = ItemBonusManager.CreateSkillBonus({"Rain_Water", "Rain_EnemyWater"}, 
function(self, skill, char, state, skillData)
	return state == SKILL_STATE.CAST and ObjectGetFlag(char, "LLENEMY_ShadowBonus_ShockingRain_Enabled") == 1
end,
function(self, skill, char, state, skillData)
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
function(self, skill, char, state, skillData)
	return state == SKILL_STATE.CAST and (ObjectGetFlag(char, "LLENEMY_ShadowBonus_TimeHaste_Enabled") == 1 and ObjectGetFlag(char, "LLENEMY_TimeHastedUsed") == 0)
end,
function(self, skill, char, state, skillData)
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

local waterSurfaces = {
	"Water",
	"WaterElectrified",
	"WaterFrozen",
	--"WaterBlessed",
	--"WaterElectrifiedBlessed",
	--"WaterFrozenBlessed",
	--"WaterCursed",
	--"WaterElectrifiedCursed",
	--"WaterFrozenCursed",
	--"WaterPurified",
	--"WaterElectrifiedPurified",
	--"WaterFrozenPurified",
}

ItemBonusManager.AllItemBonuses.BloodyWinter = ItemBonusManager.CreateUnregisteredBonus(
function(self, skill, char, state)
	return (state == SKILL_STATE.USED or state == SKILL_STATE.CAST) and (Vars.DebugMode or ObjectGetFlag(char, "LLENEMY_ShadowBonus_BloodyWinter_Enabled") == 1)
end,
function(self, skill, char, state, skillData)
	local stat = Ext.GetStat(skill)
	local radius = math.max(stat.ExplodeRadius or 3.0, stat.AreaRadius or 3.0)
	if stat.SkillType == "Shout" then
		if state == SKILL_STATE.USED then
			local x,y,z = GetPosition(char)
			TransformSurfaceAtPosition(x, y, z, "Bloodify", "Ground", radius, -1.0, char)
		end
	elseif state == SKILL_STATE.CAST then
		local hasPositions = false
		---@type SkillEventData
		local data = Common.CloneTable(skillData)
		data:ForEach(function(target, t, self)
			local x,y,z = nil,nil,nil
			if t == "table" then
				x,y,z = table.unpack(target)
			else
				x,y,z = GetPosition(target)
			end
			if x and z then
				if PersistentVars.BloodyWinterTargets[char] == nil then
					PersistentVars.BloodyWinterTargets[char] = {}
				end
				table.insert(PersistentVars.BloodyWinterTargets[char], {Pos={x,y,z},Radius=radius})
				hasPositions = true
				--TransformSurfaceAtPosition(x, y, z, "Bloodify", "Ground", radius, -1.0, char)
			end
		end, data.TargetMode.All)
		if hasPositions then
			StartTimer("LLENEMY_BloodyWinter_CreateSurfaces", 500, char)
		end
	end
end, {
	EquipCallback = function(self, char, item)
		if not GameHelpers.Character.IsUndead(char) then
			local character = Ext.GetCharacter(char)
			if StringHelpers.IsNullOrEmpty(character.CustomBloodSurface) then
				CharacterSetCustomBloodSurface(char, "SurfaceBloodFrozen")
			end
		end
	end,
	UnEquipCallback = function(self, char, item)
		if not GameHelpers.Character.IsUndead(char) then
			local character = Ext.GetCharacter(char)
			if not StringHelpers.IsNullOrEmpty(character.CustomBloodSurface) and string.find(character.CustomBloodSurface, "BloodFrozen") then
				CharacterSetCustomBloodSurface(char, "")
			end
		end
	end
})

RegisterListener("NamedTimerFinished", "LLENEMY_BloodyWinter_CreateSurfaces", function(timerName, uuid)
	local positions = PersistentVars.BloodyWinterTargets[uuid]
	if positions then
		local charHandle = Ext.GetCharacter(uuid).Handle
		local grid = Ext.GetAiGrid()
		for i,data in pairs(positions) do
			local pos = data.Pos
			local radius = data.Radius
			GameHelpers.Surface.TransformSurfaces("BloodFrozen", waterSurfaces, pos[1], pos[3], radius, 0, 18.0, charHandle, 1.0, true, grid, true, 0.8)
		end
		PersistentVars.BloodyWinterTargets[uuid] = nil
	end
end)