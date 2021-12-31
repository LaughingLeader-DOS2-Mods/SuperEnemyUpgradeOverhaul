local tb = Classes.TagBoost

local DefaultParams = {DisplayInTooltip = true}
local function Params(params)
	for k,v in pairs(DefaultParams) do
		if params[k] == nil then
			params[k] = v
		end
	end
	return params
end

local entries = {
	LLENEMY_ShadowBonus_Madness = tb:Create("LLENEMY_ShadowBonus_Madness","LLENEMY_ShadowBonus_Madness_Enabled", {HasToggleScript = true, DisplayInTooltip = true}),
	LLENEMY_ShadowBonus_StunDefense = tb:Create("LLENEMY_ShadowBonus_StunDefense","LLENEMY_ShadowBonus_StunDefense_Enabled", DefaultParams),
	LLENEMY_ShadowBonus_DotCleanser = tb:Create("LLENEMY_ShadowBonus_DotCleanser","LLENEMY_ShadowBonus_DotCleanser_Enabled", DefaultParams),
	LLENEMY_ShadowBonus_CursedFire = tb:Create("LLENEMY_ShadowBonus_CursedFire","LLENEMY_ShadowBonus_CursedFire_Enabled", DefaultParams),
	LLENEMY_ShadowBonus_ShockingRain = tb:Create("LLENEMY_ShadowBonus_ShockingRain","LLENEMY_ShadowBonus_ShockingRain_Enabled", DefaultParams),
	LLENEMY_ShadowBonus_SlipperyRogue = tb:Create("LLENEMY_ShadowBonus_SlipperyRogue","LLENEMY_ShadowBonus_SlipperyRogue_Enabled", DefaultParams),
	LLENEMY_ShadowBonus_DefensiveStart = tb:Create("LLENEMY_ShadowBonus_DefensiveStart","LLENEMY_ShadowBonus_DefensiveStart_Enabled", DefaultParams),
	LLENEMY_ShadowBonus_TimeHaste = tb:Create("LLENEMY_ShadowBonus_TimeHaste","LLENEMY_ShadowBonus_TimeHaste_Enabled", DefaultParams),
	LLENEMY_ShadowBonus_BloodyWinter = tb:Create("LLENEMY_ShadowBonus_BloodyWinter","LLENEMY_ShadowBonus_BloodyWinter_Enabled", DefaultParams),
}

if Ext.IsClient() then
	Ext.RegisterListener("SessionLoaded", function()
		for tag,entry in pairs(entries) do
			TooltipHandler.RegisterItemTooltipTag(tag)
		end
	end)
end

return entries
