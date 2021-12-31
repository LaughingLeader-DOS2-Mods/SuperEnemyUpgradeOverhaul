--Natural Conductor
StatusManager.Register.Applied("SurfaceEnter", function(target, status, source, statusType, event)
	if target:GetStatus("LLENEMY_TALENT_NATURALCONDUCTOR") then
		local x,y,z = table.unpack(target.WorldPos)
		if GameHelpers.Surface.HasSurface(x, z, "Electrified", 6.0, true, 0) then
			GameHelpers.Status.Apply(target, "HASTED", 6.0, false, target)
		end
	end
end)

--Lone Wolf
StatusManager.Register.Applied("LLENEMY_TALENT_LONEWOLF", function(target, status, source, statusType, event)
	ApplyLoneWolfBonuses(target)
end)

UpgradeSystem.Settings.BullyStatuses = {"KNOCKED_DOWN", "CRIPPLED", "SLOWED"}

--Bully
---@param target EsvCharacter
---@param source EsvCharacter
---@param data HitData
---@param hitStatus EsvStatusHit
RegisterListener("StatusHitEnter", function(target, source, data, hitStatus)
	if data.Success 
	and source and source:GetStatus("LLENEMY_TALENT_BULLY") 
	and source.MyGuid ~= target.MyGuid
	and data:IsDirect() -- Not a surface, DoT etc
	and GameHelpers.Status.IsActive(target, UpgradeSystem.Settings.BullyStatuses)
	then
		local damageMult = GameHelpers.GetExtraData("LLENEMY_Bully_DamageMultiplier", 0.5)
		if damageMult > 0 then
			data:MultiplyDamage(1 + (damageMult * 0.01))
		end
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