--Natural Conductor
StatusManager.Register.Applied("SurfaceEnter", function(target, status, source, statusType, event)
	if target:GetStatus("LLENEMY_TALENT_NATURALCONDUCTOR") and GameHelpers.Character.IsInSurface(target, "Electrified") then
		GameHelpers.Status.Apply(target, "HASTED", 6.0, false, target)
	end
end)

--Lone Wolf
StatusManager.Register.Applied("LLENEMY_TALENT_LONEWOLF", function(target, status, source, statusType, event)
	ApplyLoneWolfBonuses(target)
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

--Bully
---@param target EsvCharacter
---@param source EsvCharacter
---@param data HitData
---@param hitStatus EsvStatusHit
RegisterListener("StatusHitEnter", function(target, source, data, hitStatus)
	if data.Success and source and source.MyGuid ~= target.MyGuid then
		if source:GetStatus("LLENEMY_TALENT_BULLY")
		and data:IsDirect() -- Not a surface, DoT etc
		and GameHelpers.Status.IsActive(target, UpgradeSystem.Settings.BullyStatuses)
		then
			local damageMult = GameHelpers.GetExtraData("LLENEMY_Bully_DamageMultiplier", 0.5)
			if damageMult > 0 then
				data:MultiplyDamage(1 + (damageMult * 0.01))
			end
		end

		if target:GetStatus("LLENEMY_TALENT_COUNTER")
		and UpgradeSystem.Settings.CounterHitType[data.HitContext.HitType] == true
		then
			if ObjectGetFlag(target.MyGuid, "LLENEMY_IsCountering") == 0
			and GameHelpers.Character.IsWithinWeaponRange(target, source)
			and RollForCounterAttack(target)
			then
				ObjectSetFlag(target.MyGuid, "LLENEMY_IsCountering", 0)
				Timer.StartObjectTimer("LLENEMY_Counter_RollForCounterAttack", target.MyGuid, 1000, source.MyGuid)
			end
		end
	end
end)

Timer.RegisterListener("LLENEMY_Counter_RollForCounterAttack", function(timerName, enemy, target)
	ObjectSetFlag(enemy, "LLENEMY_IsCountering", 0)
	if CharacterIsDead(enemy) == 0 
	and CharacterIsDead(target) == 0
	then
		CharacterAttack(enemy, target)
		CharacterStatusText(enemy, "LLENEMY_StatusText_CounterAttack")
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