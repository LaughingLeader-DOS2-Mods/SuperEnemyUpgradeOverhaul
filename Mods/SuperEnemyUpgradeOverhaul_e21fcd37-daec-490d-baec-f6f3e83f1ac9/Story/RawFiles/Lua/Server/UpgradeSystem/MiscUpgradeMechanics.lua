local GrenadeSkills = {}

function ExplodeGrenade(enemy)
	local skill = Common.GetRandomTableEntry(GrenadeSkills)
	local x,y,z = GetPosition(enemy)
	GameHelpers.ExplodeProjectile(enemy, {x,y,z}, skill, CharacterGetLevel(enemy))
	local name = Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute(skill, "DisplayName"))
	if name ~= nil and name ~= "" then
		local text = Ext.GetTranslatedStringFromKey("LLENEMY_StatusText_GrenadeExploded") or "<font color='#FF3333'>[1] Exploded!</font>"
		text = string.gsub(text, "%[1%]", name)
		CharacterStatusText(enemy, text)
	end
end

Ext.RegisterListener("SessionLoaded", function()
	for i,v in pairs(Ext.GetStatEntries("SkillData")) do
		if string.find(v, "Projectile_Grenade") and not StringHelpers.IsNullOrEmpty(Ext.StatGetAttribute(v, "MovingObject")) then
			GrenadeSkills[#GrenadeSkills+1] = v
		end
	end
end)