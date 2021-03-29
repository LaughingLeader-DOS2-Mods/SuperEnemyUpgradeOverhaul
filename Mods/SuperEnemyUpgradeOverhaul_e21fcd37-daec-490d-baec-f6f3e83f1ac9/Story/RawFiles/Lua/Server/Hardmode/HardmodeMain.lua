---@class HardmodeLevelScript
---@field Enable function
---@field Disable function
---@field Init function
---@field OnEvent fun(event:string, varargs:any):void

Hardmode = {
	---@type table<string,HardmodeLevelScript>
	Levels = {
		TUT_Tutorial_A = Ext.Require("Server/Hardmode/Levels/Tutorial.lua"),
		FJ_FortJoy_Main = Ext.Require("Server/Hardmode/Levels/FortJoy.lua"),
	}
}
Hardmode.__index = Hardmode

function Hardmode:RollAdditionalUpgrades(uuid)
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

function Hardmode:Enable()
	local currentLevel = SharedData.RegionData.Current
	local currentLevelScript = self.Levels[currentLevel]
	if currentLevelScript and currentLevelScript.Enable then
		local b,err = xpcall(currentLevelScript.Enable, debug.traceback)
		if not b then
			Ext.PrintError(err)
		else
			fprint(LOGLEVEL.DEFAULT, "[SEUO:Hardmode:Enable] Enabled hardmode script for region (%s)", currentLevel)
		end
	else
		fprint(LOGLEVEL.DEFAULT, "[SEUO:Hardmode:Enable] No hardmode script for region (%s). Skipping.", currentLevel)
	end
end

function Hardmode:Disable()
	local currentLevel = SharedData.RegionData.Current
	local currentLevelScript = self.Levels[currentLevel]
	if currentLevelScript and currentLevelScript.Disable then
		local b,err = xpcall(currentLevelScript.Disable, debug.traceback)
		if not b then
			Ext.PrintError(err)
		else
			fprint(LOGLEVEL.DEFAULT, "[SEUO:Hardmode:Disable] Disabled hardmode script for region (%s)", currentLevel)
		end
	else
		fprint(LOGLEVEL.DEFAULT, "[SEUO:Hardmode:Disable] No hardmode script for region (%s). Skipping.", currentLevel)
	end
end

function Hardmode:Init(region)
	local currentLevel = region or SharedData.RegionData.Current
	local currentLevelScript = self.Levels[currentLevel]
	if currentLevelScript and currentLevelScript.Init then
		local b,err = xpcall(currentLevelScript.Init, debug.traceback)
		if not b then
			Ext.PrintError(err)
		end
	end
end

function Hardmode:SetupNPC(uuid, makeImmortal)
	SetFaction(uuid, "Evil NPC")
	SetVarInteger(uuid, "FleeFromDangerousSurface", 0)
	if makeImmortal == true and not GameHelpers.IsInCombat(uuid) then
		Osi.ProcSetInvulnerable(uuid, 1)
		CharacterSetImmortal(uuid, 1)
	end
end

-- LeaderLib.RegisterListener("GlobalFlagChanged", "LLENEMY_HardmodeEnabled", function(flag, enabled)
-- 	print("GlobalFlagChanged", flag, enabled)
-- 	if enabled then
-- 		Hardmode:Enable()
-- 	else
-- 		Hardmode:Disable()
-- 	end
-- end)

LeaderLib.RegisterListener("LuaReset", function()
	local enabled = Settings.Global:FlagEquals("LLENEMY_HardmodeEnabled", true)
	if enabled then
		Hardmode:Init()
		Hardmode:Enable()
	else
		Hardmode:Disable()
	end
end)

function Hardmode_InitLevel(region)
	Hardmode:Init(region)
end

function Hardmode_Enabled()
	Hardmode:Enable()
end

function Hardmode_Disabled()
	Hardmode:Disable()
end

function Hardmode_RunEvent(event, ...)
	local currentLevel = SharedData.RegionData.Current
	local currentLevelScript = self.Levels[currentLevel]
	if currentLevelScript and currentLevelScript.OnEvent then
		local b,err = xpcall(currentLevelScript.OnEvent, debug.traceback, event, ...)
		if not b then
			Ext.PrintError(err)
		end
	end
end