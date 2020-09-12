
function ShadowItem_OnEquipped(char, item)
	for tag,entry in pairs(ItemCorruption.TagBoosts) do
		if not StringHelpers.IsNullOrEmpty(entry.Flag) and IsTagged(item, tag) == 1 then
			if entry.HasToggleScript == true then
				Osi.LeaderLib_ToggleScripts_EnableScriptForObject(char, entry.Flag, "SuperEnemyUpgradeOverhaul", 1)
			else
				ObjectSetFlag(char, entry.Flag, 0)
			end
		end
	end
end

function ShadowItem_OnUnEquipped(char, item)
	---@type TagBoost[]
	local removedTags = {}
	for tag,entry in pairs(ItemCorruption.TagBoosts) do
		if not StringHelpers.IsNullOrEmpty(entry.Flag) and IsTagged(item, tag) == 1 then
			--LeaderLib_ToggleScripts_DisableScriptForObject(char, flag, "SuperEnemyUpgradeOverhaul", 1)
			table.insert(removedTags, entry)
		end
	end
	for i,entry in pairs(removedTags) do
		local hasTaggedItem = false
		for i,slot in LeaderLib.Data.VisibleEquipmentSlots:Get() do
			local slotItem = CharacterGetEquippedItem(char, slot)
			if slotItem ~= nil and IsTagged(slotItem, entry.Tag) == 1 then
				hasTaggedItem = true
				break
			end
		end
		if not hasTaggedItem then
			if entry.HasToggleScript == true then
				Osi.LeaderLib_ToggleScripts_DisableScriptForObject(char, entry.Flag, "SuperEnemyUpgradeOverhaul", 1)
			else
				ObjectClearFlag(char, entry.Flag, 0)
			end
		end
	end
end

-- From the LLENEMY_ShadowBonus_Madness tag boost
function RollForMadness(char)
	local chance = math.tointeger(Ext.ExtraData["LLENEMY_ShadowBonus_Madness_ChanceOnTurn"] or 20)
	if chance > 0 then
		local rollCooldown = math.tointeger(Ext.ExtraData["LLENEMY_ShadowBonus_Madness_RollTurnCooldown"] or 2)
		local turnDuration = (Ext.ExtraData["LLENEMY_ShadowBonus_Madness_TurnDuration"] or 2) * 6.0
		if chance >= 100 then
			ApplyStatus(char, "LLENEMY_SHADOWBONUS_MADNESS", turnDuration, 0, char)
			Osi.DB_LLENEMY_ItemBonuses_Temp_MadnessCooldown(char, rollCooldown)
		elseif Ext.Random(0, 100) <= chance then
			ApplyStatus(char, "LLENEMY_SHADOWBONUS_MADNESS", turnDuration, 0, char)
			Osi.DB_LLENEMY_ItemBonuses_Temp_MadnessCooldown(char, rollCooldown)
		end
	end
end

local function MadnessBonus_FindTargets(source)
	local x,y,z = GetPosition(source)
	local radius = Ext.ExtraData["LLENEMY_ShadowBonus_Madness_DamageRadius"] or 6.0
	for i,v in pairs(Ext.GetCharactersAroundPosition(x,y,z, radius)) do
		if v ~= source and (CharacterIsDead(v) == 0 and CharacterIsEnemy(v, source) == 1 or IsTagged(v, "LeaderLib_FriendlyFireEnabled") == 1) then
			PlayBeamEffect(source, v, "LLENEMY_FX_Status_TentacleLash_Beam_01", "Dummy_BodyFX", "Dummy_BodyFX")
			Osi.LeaderLib_Timers_StartCharacterCharacterTimer(source, v, 500, "Timers_LLENEMY_Madness_TentacleDamage", "LLENEMY_Madness_TentacleDamage")
		end
	end
end

function ShadowItem_OnMadnessTick(char)
	if CharacterIsInCombat(char) == 0 then
		MadnessBonus_FindTargets(char)
	end
end

function ShadowItem_ApplyMadnessTentacleDamage(source, char)
	GameHelpers.ExplodeProjectile(source, char, "Projectile_LLENEMY_ShadowBonus_Madness_Damage")
end

--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
local function OnPrepareHit(target,source,damage,handle)
	if ObjectGetFlag(target, "LLENEMY_ShadowBonus_StunDefense_Enabled") == 1 and GameHelpers.Status.IsDisabled(target) then
		local damageReduction = Ext.ExtraData["LLENEMY_ShadowBonus_StunDefense_DamageReduction"] or 0.5
		if damageReduction > 0 then
			GameHelpers.ReduceDamage(target, source, handle, damageReduction, true)
		end
	end
end
LeaderLib.RegisterListener("OnPrepareHit", OnPrepareHit)

local skipHitCheck = {}

--- @param target string
--- @param source string
--- @param damage integer
--- @param handle integer
--- @param skill string
local function OnHit(target,source,damage,handle,skill)
	if skill ~= nil and source ~= nil and damage > 0 and not skipHitCheck[target..source] then
		local ability = Ext.StatGetAttribute(skill, "Ability")
		if ability == "Fire" and ObjectGetFlag(source, "LLENEMY_ShadowBonus_CursedFire_Enabled") == 1 then
			local chance = Ext.ExtraData["LLENEMY_ShadowBonus_CursedFire_Chance"] or 40
			if Ext.Random(0,100) <= chance then
				ApplyStatus(target, "NECROFIRE", 6.0, 0, source)
				local x,y,z = GetPosition(target)
				TransformSurfaceAtPosition(x, y, z, "Curse", "Ground", 1.0, 6.0, source)
				if ObjectIsCharacter(target) == 1 then
					local text = GameHelpers.GetStringKeyText("LLENEMY_ShadowBonus_CursedFire", "<font color='#B823FF'>Cursed Fire</font>")
					CharacterStatusText(target, text)
				end
				skipHitCheck[target..source] = true
				local timerName = string.format("Timers_LLENEMY_ResetSkipHitCheck_%s%s", target, source)
				LeaderLib.StartOneshotTimer(timerName, 50, function()
					skipHitCheck[target..source] = nil
				end)
			end
		end
	end
end
LeaderLib.RegisterListener("OnHit", OnHit)

local function OnTurnEndedOrLeftCombat(object, combatId)
	if ObjectGetFlag(object, "LLENEMY_ShadowBonus_DotCleanser_Enabled") == 1 then
		if ObjectIsCharacter(object) == 1 then
			local cleansed = {}
			local character = Ext.GetCharacter(object)
			for i,status in pairs(character:GetStatuses()) do
				if type(status) ~= "string" and status.StatusId ~= nil then
					status = status.StatusId
				end
				if Ext.StatGetAttribute(status, "StatusType") == "DAMAGE" then
					local weaponStat = Ext.StatGetAttribute(status, "DamageStats")
					if weaponStat ~= nil and Ext.StatGetAttribute(weaponStat, "DamageFromBase") > 0 then
						table.insert(cleansed, GameHelpers.GetStringKeyText(Ext.StatGetAttribute(status, "DisplayName"), status))
						RemoveStatus(object, status)
					end
				end
			end
			if #cleansed > 0 then
				local statusText = GameHelpers.GetStringKeyText("LLENEMY_StatusText_Cleansed", "<font color='#73F6FF'>[1] Cleansed [2]</font>")
				local itemResponsible = CharacterFindTaggedItem(object, "LLENEMY_ShadowBonus_DotCleanser")
				local cleanseSource = GameHelpers.GetStringKeyText("LLENEMY_ShadowBonus_DotCleanser", "Immune Boost")
				-- if itemResponsible ~= nil then
				-- 	cleanseSource = Ext.GetItem(itemResponsible).DisplayName
				-- else
				-- 	cleanseSource = GameHelpers.GetStringKeyText("LLENEMY_ShadowBonus_DotCleanser", "Immune Boost")
				-- end
				statusText = statusText:gsub("%[1%]", cleanseSource):gsub("%[2%]", StringHelpers.Join(", ", cleansed))
				CharacterStatusText(object, statusText)

				local health = CharacterGetHitpointsPercentage(object)
				if health < 100.0 then
					for i=#cleansed,1,-1 do
						health = health + ((Ext.ExtraData["LLENEMY_ShadowBonus_ImmuneBoost_HealPercentage"] or 0.1) * 100)
					end
					CharacterSetHitpointsPercentage(object, math.min(100.0, health))
				end
			end
		end
	end
	if HasActiveStatus(object, "LLENEMY_SHADOWBONUS_MADNESS") == 1 then
		MadnessBonus_FindTargets(object)
	end
end

Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", function(object, combatid)
	if ObjectGetFlag(object, "LLENEMY_ShadowBonus_SlipperyRogue_Enabled") == 1 then
		ApplyStatus(object, "INVISIBLE", 6.0, 0, object)
	end
	if ObjectGetFlag(object, "LLENEMY_ShadowBonus_DefensiveStart_Enabled") == 1 then
		ApplyStatus(object, "FORTIFIED", 12.0, 0, object)
		ApplyStatus(object, "MAGIC_SHELL", 12.0, 0, object)
	end
end)

Ext.RegisterOsirisListener("ObjectTurnEnded", 1, "after", function(object)
	OnTurnEndedOrLeftCombat(object)
end)

Ext.RegisterOsirisListener("ObjectLeftCombat", 2, "after", OnTurnEndedOrLeftCombat)