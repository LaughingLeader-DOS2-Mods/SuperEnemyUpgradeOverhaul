local function GetTargetLevel(uuid)
	local cap = 35
	if Settings.Global:FlagEquals("LLENEMY_Debug_LevelCapDisabled", true) then
		cap = -1
	end
	local modifier = Settings.Global:GetVariable("AutoLeveling_Modifier", 0)
	if Settings.Global:FlagEquals("LLENEMY_LevelEnemiesToPartyLevelDisabled", true) then
		local level = CharacterGetLevel(uuid) + modifier
		return cap > -1 and math.min(cap, level) or level
	else
		local level = GameHelpers.Character.GetHighestPlayerLevel() + modifier
		return cap > -1 and math.min(cap, level) or level
	end
end

local function CanLevelCharacter(uuid)
	if GameHelpers.Character.IsOrigin(uuid) or GameHelpers.Character.IsPlayer(uuid) then
		return false
	end
	if not GameHelpers.Character.IsEnemyOfParty(uuid) and not GameHelpers.Character.IsInCombat(uuid) then
		return false
	end
	return true
end

function LevelUpCharacter(uuid)
	if CanLevelCharacter(uuid) then
		local targetLevel = GetTargetLevel(uuid)
		local character = Ext.GetCharacter(uuid)
		local vit = character.Stats.CurrentVitality / character.Stats.MaxVitality
		local pArmor = character.Stats.CurrentArmor / character.Stats.MaxArmor
		local mArmor = character.Stats.CurrentMagicArmor / character.Stats.MaxMagicArmor
		CharacterLevelUpTo(uuid, targetLevel)
		CharacterSetHitpointsPercentage(uuid, vit)
		CharacterSetArmorPercentage(uuid, pArmor)
		CharacterSetMagicArmorPercentage(uuid, mArmor)
	end
end

function LevelUpRegion(region)
	if not PersistentVars.LeveledRegions[region] then
		PersistentVars.LeveledRegions[region] = 0
		for i,v in pairs(Ext.GetAllCharacters(region)) do
			if LevelUpCharacter(v) then
				PersistentVars.LeveledRegions[region] = PersistentVars.LeveledRegions[region] + 1
			end
		end
	end
end

---@param region string
---@return integer
function GetTotalLeveledCharactersForRegion(region)
	if PersistentVars.LeveledRegions[region] then
		return PersistentVars.LeveledRegions[region]
	end
	return 0
end