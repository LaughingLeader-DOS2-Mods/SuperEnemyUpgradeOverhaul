--Natural Conductor
StatusManager.Register.Applied("SurfaceEnter", function(target, status, source, statusType, event)
	if GameHelpers.Status.IsActive(target, "LLENEMY_TALENT_NATURALCONDUCTOR") and GameHelpers.Character.IsInSurface(target, "Electrified") then
		GameHelpers.Status.Apply(target, "HASTED", 6.0, false, target)
	end
end)

UpgradeSystem.Settings.LoneWolfAbilities = {
	"WarriorLore",
	"RangerLore",
	"RogueLore",
	--"SingleHanded",
	--"TwoHanded",
	--"Reflection",
	--"Ranged",
	--"Shield",
	--"Reflexes",
	--"PhysicalArmorMastery",
	--"Sourcery",
	--"Telekinesis",
	"FireSpecialist",
	"WaterSpecialist",
	"AirSpecialist",
	"EarthSpecialist",
	"Necromancy",
	"Summoning",
	--"Polymorph",
	--"Repair",
	--"Sneaking",
	--"Pickpocket",
	--"Thievery",
	--"Loremaster",
	--"Crafting",
	--"Barter",
	--"Charm",
	--"Intimidate",
	--"Reason",
	--"Persuasion",
	--"Leadership",
	--"Luck",
	--"DualWielding",
	--"Wand",
	--"MagicArmorMastery",
	--"VitalityMastery",
	--"Perseverance",
	--"Runecrafting",
	--"Brewmaster",
}

---@param character EsvCharacter|UUID
function Upgrade_LoneWolf_ApplyBonuses(character, test)
	if GameHelpers.ObjectHasFlag(character, "LLENEMY_LoneWolfBonusesApplied") then
		return
	end
	character = GameHelpers.GetCharacter(character)
	if character then
		for _,stat in LeaderLib.Data.Attribute:Get() do
			local baseVal = math.max(0, character.Stats["Base"..stat] - Ext.ExtraData.AttributeBaseValue)
			local currentVal = character.Stats[stat]
			if baseVal > 0 and currentVal < Ext.ExtraData.AttributeSoftCap then
				local addAmount = math.min(Ext.ExtraData.AttributeSoftCap, baseVal * 2) -- Capped at 40
				addAmount = addAmount - baseVal
				if addAmount > 0 then
					if test == nil then
						local currentBoost = NRD_CharacterGetPermanentBoostInt(character.MyGuid, stat) or 0
						NRD_CharacterSetPermanentBoostInt(character.MyGuid, addAmount + currentBoost)
					end
					fprint(LOGLEVEL.TRACE, "[SEUO:Upgrade_LoneWolf_ApplyBonuses] character(%s) [%s] Current(%s=>%s) Bonus(%s)", character.DisplayName, stat, currentVal, currentVal + addAmount, addAmount)
				end
			end
			--Sync client
			CharacterAddAttribute(character.MyGuid, "Dummy", 0)
		end
		for _,stat in pairs(UpgradeSystem.Settings.LoneWolfAbilities) do
			local baseVal = character.Stats["Base"..stat]
			local currentVal = character.Stats[stat]
			if currentVal < Ext.ExtraData.CombatAbilityCap then
				local addAmount = math.min(Ext.ExtraData.CombatAbilityCap, baseVal * 2) -- Capped at 10
				addAmount = addAmount - baseVal
				if addAmount > 0 then
					if test == nil then
						CharacterAddAbility(character.MyGuid, stat, addAmount)
					end
					fprint(LOGLEVEL.TRACE, "[SEUO:Upgrade_LoneWolf_ApplyBonuses] character(%s) [%s] Current(%s=>%s) Bonus(%s)", character.DisplayName, stat, currentVal, currentVal + addAmount, addAmount)
				end
			end
		end
		if test ~= true then
			ObjectSetFlag(character.MyGuid, "LLENEMY_LoneWolfBonusesApplied", 0)
		end
	end
end

--Lone Wolf
StatusManager.Register.Applied("LLENEMY_TALENT_LONEWOLF", function(target, status, source, statusType, event)
	Upgrade_LoneWolf_ApplyBonuses(target)
end)

UpgradeSystem.Settings.BullyStatuses = {"KNOCKED_DOWN", "CRIPPLED", "SLOWED"}
UpgradeSystem.Settings.CounterHitType = {Melee = true, Magic = true, Ranged = true, WeaponDamage = true}

function RollForCounterAttack(character)
	character = GameHelpers.GetCharacter(character)
	if character then
		local initiative = character.Stats.Initiative
		local counterMax = GameHelpers.GetExtraData("LLENEMY_Counter_MaxChance", 75)
		if counterMax > 0 then
			local chance = (math.log(1 + initiative) / math.log(1 + counterMax))
			chance = math.floor(chance * counterMax) * 10
			local roll = Ext.Random(0,999)
			if roll >= chance then
				return true
			end
		end
	end

	return false
end

---@param target EsvCharacter
---@param source EsvCharacter
---@param data HitData
---@param hitStatus EsvStatusHit
RegisterListener("StatusHitEnter", function(target, source, data, hitStatus)
	if data.Success and source and source.MyGuid ~= target.MyGuid then
		if GameHelpers.Status.IsActive(source, "LLENEMY_TALENT_BULLY")
		and data:IsDirect() -- Not a surface, DoT etc
		and GameHelpers.Status.IsActive(target, UpgradeSystem.Settings.BullyStatuses)
		then
			local damageMult = GameHelpers.GetExtraData("LLENEMY_Bully_DamageMultiplier", 0.5)
			if damageMult > 0 then
				data:MultiplyDamage(1 + (damageMult * 0.01))
			end
		end

		if GameHelpers.Status.IsActive(target, "LLENEMY_TALENT_COUNTER")
		and UpgradeSystem.Settings.CounterHitType[data.HitContext.HitType] == true
		then
			if ObjectGetFlag(target.MyGuid, "LLENEMY_IsCountering") == 0
			and GameHelpers.Character.IsWithinWeaponRange(target, source)
			and RollForCounterAttack(target)
			then
				ObjectSetFlag(target.MyGuid, "LLENEMY_IsCountering", 0)
				Timer.StartObjectTimer("LLENEMY_Counter_CounterAttack", target.MyGuid, 1000, source.MyGuid)
			end
		end
	end
end)

Timer.RegisterListener("LLENEMY_Counter_CounterAttack", function(timerName, enemy, target)
	ObjectClearFlag(enemy, "LLENEMY_IsCountering", 0)
	if CharacterIsDead(enemy) == 0 
	and CharacterIsDead(target) == 0
	then
		CharacterAttack(enemy, target)
		CharacterStatusText(enemy, "LLENEMY_StatusText_CounterAttack")
	end
end)


UpgradeSystem.Settings.MasterThiefItemTags = {
	"GRENADES",
	"LLWEAPONEX_Throwing",
	"Consumable",
	"Potion",
}

local muggedAttackerText = Classes.TranslatedString:CreateFromKey("LLENEMY_StatusText_MasterThief_Attacker", "<font color='#33FF33' size='23'>*Stole [1]!*</font>")
local muggedVictimText = Classes.TranslatedString:CreateFromKey("LLENEMY_StatusText_MasterThief_Victim", "<font color='#FF3333' size='23'>*Lost [1]!*</font>")
local muggedCombatLogText = Classes.TranslatedString:CreateFromKey("LLENEMY_CombatLog_MasterThief", "[1] stole <font color='#FF3333'>[2]</font> from [3] ([4]).")
local goldAmountText = Classes.TranslatedString:CreateFromKey("LLENEMY_GoldWithAmount", "[1] [Handle:h55e5ec72g331dg4dc9g9532g4a68ba0bc2a3:Gold]"):WithFormat("<font color='#C7A758'>%s</font>")

---@param attacker EsvCharacter
---@param target EsvCharacter
function Upgrade_MasterThief_MugTarget(attacker, target)
	GameHelpers.Status.Apply(attacker, "LLENEMY_TALENT_MASTERTHIEF_COOLDOWN", 6.0, false, attacker)
	local potentialLoot = {}
	for i,v in pairs(target:GetInventoryItems()) do
		if GameHelpers.ItemHasTag(v, UpgradeSystem.Settings.MasterThiefItemTags)
		and ItemIsStoryItem(v) == 0
		and not GameHelpers.Item.ItemIsEquipped(target, v)
		then
			potentialLoot[#potentialLoot+1] = v
		end
	end
	local item = Common.GetRandomTableEntry(potentialLoot)
	if item then
		local item = GameHelpers.GetItem(item)
		CharacterStatusText(attacker.MyGuid, muggedAttackerText:ReplacePlaceholders(item.DisplayName))
		CharacterStatusText(target.MyGuid, muggedVictimText:ReplacePlaceholders(item.DisplayName))
		ItemToInventory(item.MyGuid, attacker.MyGuid, 1, attacker.IsPlayer, 0)
		local masterThiefName = GameHelpers.GetStringKeyText(Ext.StatGetAttribute("LLENEMY_TALENT_MASTERTHIEF", "DisplayName"), "Talent: Master Thief")
		CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, muggedCombatLogText:ReplacePlaceholders(attacker.DisplayName, item.DisplayName, target.DisplayName, masterThiefName))
	else
		local gold = CharacterGetGold(target)
		local goldMult = GameHelpers.GetExtraData("LLENEMY_MasterThief_GoldStealPercentage", 20)
		if gold > 0 and goldMult > 0 then
			goldMult = goldMult * 0.01
			local addGold = math.max(math.ceil(gold * goldMult), 1)
			CharacterAddGold(target.MyGuid, addGold * -1)
			CharacterAddGold(attacker.MyGuid, addGold)

			local goldName = goldAmountText:ReplacePlaceholders(addGold)
			CharacterStatusText(attacker.MyGuid, muggedAttackerText:ReplacePlaceholders(goldName))
			CharacterStatusText(target.MyGuid, muggedVictimText:ReplacePlaceholders(goldName))

			local masterThiefName = GameHelpers.GetStringKeyText(Ext.StatGetAttribute("LLENEMY_TALENT_MASTERTHIEF", "DisplayName"), "Talent: Master Thief")
			CombatLog.AddTextToAllPlayers(CombatLog.Filters.Combat, muggedCombatLogText:ReplacePlaceholders(attacker.DisplayName, goldName, target.DisplayName, masterThiefName))
		end
	end
end

AttackManager.OnHit.Register(function(attacker, target, data, targetIsObject, skill)
	if GameHelpers.Status.IsActive(attacker, "LLENEMY_TALENT_MASTERTHIEF") 
	and not GameHelpers.Status.IsActive(attacker, "LLENEMY_TALENT_MASTERTHIEF_COOLDOWN")
	and data.Success
	and not attacker.Dead
	and GameHelpers.Ext.ObjectIsCharacter(target)
	and target.Dead
	then
		Upgrade_MasterThief_MugTarget(attacker, target, data)
	end
end)

local function AddTalentFromStatus(target, status, source, statusType, statusEvent)
	local talent = UpgradeSystem.Settings.AddTalentStatuses[status]
	if talent then
		local talentStat = string.format("TALENT_%s", talent)
		local character = GameHelpers.GetCharacter(target)
		if character and character[talentStat] == false then
			NRD_CharacterSetPermanentBoostTalent(target, talent, 1)
			CharacterAddAttribute(target, "Dummy", 0)
		end
	end
end

for status,talent in pairs(UpgradeSystem.Settings.AddTalentStatuses) do
	StatusManager.Register.Applied(status, AddTalentFromStatus)
end