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
						Ext.Utils.PrintWarning("[SEUO:TimeHaste] Failed to find target character in combat turn order.")
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
	return state ~= SKILL_STATE.PREPARE and ObjectGetFlag(char, "LLENEMY_ShadowBonus_BloodyWinter_Enabled") == 1
end,
function(self, skill, char, state, skillData)
	local stat = Ext.GetStat(skill)
	local radius = math.max(stat.ExplodeRadius or 3.0, stat.AreaRadius or 3.0)
	if stat.SkillType == "Shout" then
		local x,y,z = GetPosition(char)
		if state == SKILL_STATE.USED then
			TransformSurfaceAtPosition(x, y, z, "Bloodify", "Ground", radius, -1.0, char)
			--PlayScaledEffectAtPosition("RS3_FX_Skills_Voodoo_Cast_Aoe_Voodoo_Blood_Root_01", Ext.Round(radius/2), x, y, z)
		elseif state == SKILL_STATE.CAST then
			PlayEffectAtPosition("RS3_FX_Skills_Voodoo_Cast_Aoe_Voodoo_Blood_Root_01", x, y, z)
		end
	elseif state == SKILL_STATE.PROJECTILEHIT then
		---@type ProjectileHitData
		local data = skillData
		if PersistentVars.BloodyWinterTargets[char] == nil then
			PersistentVars.BloodyWinterTargets[char] = {}
		end
		table.insert(PersistentVars.BloodyWinterTargets[char], {Pos=data.Position,Radius=radius})
		StartTimer("LLENEMY_BloodyWinter_CreateSurfaces", 1000, char)
	elseif (state == SKILL_STATE.CAST and stat.SkillType ~= "Projectile") then
		---@type SkillEventData
		local data = skillData
		local hasPositions = data.TotalTargetObjects > 0 or data.TotalTargetPositions > 0
		if hasPositions then
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
			StartTimer("LLENEMY_BloodyWinter_CreateSurfaces", 1000, char)
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
			if string.find(character.CustomBloodSurface or "", "BloodFrozen") then
				CharacterSetCustomBloodSurface(char, "")
			end
		end
	end
})

Timer.Subscribe("LLENEMY_BloodyWinter_CreateSurfaces", function (e)
	local positions = PersistentVars.BloodyWinterTargets[e.Data.UUID]
	--print("NamedTimerFinished", timerName, uuid, #positions)
	if positions then
		local source = e.Data.Object --[[@as EsvCharacter]]
		if source then
			local charHandle = source.Handle
			local grid = Ext.Entity.GetAiGrid()
			for _,data in pairs(positions) do
				local pos = data.Pos
				local radius = data.Radius
				local surfaces = GameHelpers.Grid.GetSurfaces(pos[1], pos[3], grid, radius, 18)
				for _,v in pairs(surfaces.Ground) do
					if StringHelpers.IsMatch(v.Surface.SurfaceType, waterSurfaces, true) then
						--CreatePuddle(CharacterGetHostCharacter(), "SurfaceBloodFrozen", 4, 4, 4, 4, 1.0)
						--CreateSurfaceAtPosition(v.Position[1], v.Position[2], v.Position[3], "SurfaceBloodFrozen", createdSurfaceSize, duration)
						GameHelpers.Surface.CreateSurface(v.Position, "BloodFrozen", 0.8, v.Surface.LifeTime, charHandle, true)
						EffectManager.PlayEffectAt("RS3_FX_Skills_Voodoo_Cast_Aoe_Voodoo_Blood_Root_01", pos)
						--PlayScaledEffectAtPosition("RS3_FX_Skills_Voodoo_Cast_Aoe_Voodoo_Blood_Root_01", Ext.Round(radius/2), pos[1], pos[2], pos[3])
					end
				end
			end
		end
		PersistentVars.BloodyWinterTargets[e>Data.UUID] = nil
	end
end)