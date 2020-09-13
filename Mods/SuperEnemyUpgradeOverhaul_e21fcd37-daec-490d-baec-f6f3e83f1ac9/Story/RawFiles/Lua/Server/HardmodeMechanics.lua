if Hardmode == nil then
	Hardmode = {}
end

function Hardmode.RollAdditionalUpgrades(uuid)
	local vars = Settings.Global.Variables
	local min = vars.Hardmode_MinBonusRolls.Value or Ext.ExtraData["LLENEMY_Hardmode_DefaultBonusRolls_Min"] or 1
	local max = vars.Hardmode_MaxBonusRolls.Value or Ext.ExtraData["LLENEMY_Hardmode_DefaultBonusRolls_Max"] or 4
	local bonusRolls = Ext.Random(min, max)
	if bonusRolls > 0 then
		for i=bonusRolls,1,-1 do
			UpgradeSystem.RollForUpgrades(uuid, nil, false, true)
		end
	end
end

function HardmodeDisabled()

end

function HardmodeEnabled()

end