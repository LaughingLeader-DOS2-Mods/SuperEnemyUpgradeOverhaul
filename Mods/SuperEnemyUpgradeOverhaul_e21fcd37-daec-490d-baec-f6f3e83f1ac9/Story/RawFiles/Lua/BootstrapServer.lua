Ext.Require("Shared/Init.lua")
Ext.Require("Server/_InitServer.lua")

PersistentVars = {
	NewCorruptionStats = {},
	TotalDuplicants = {},
}

if PersistentVars.Upgrades == nil then
	PersistentVars.Upgrades = {}
end
if PersistentVars.Upgrades.DropCounts == nil then
	PersistentVars.Upgrades.DropCounts = {}
end
if PersistentVars.Upgrades.Results == nil then
	PersistentVars.Upgrades.Results = {}
end

local function LLENEMY_Server_ModuleLoading()
	LLENEMY_Shared_InitModuleLoading()
end
Ext.RegisterListener("ModuleLoading", LLENEMY_Server_ModuleLoading)

local function LLENEMY_Server_SessionLoaded()
	-- Odinblade's Necromancy Overhaul
	if Ext.IsModLoaded("8700ba4e-7d4b-40ca-a23f-b43816794957") then
		-- This is a skill that applies DOS1's Oath of Desecration potion for +40% damage
		IgnoredSkills["Target_EnemyTargetedDamageBoost"] = true
	end
	-- Odinblade's Aerotheurge Class Overhaul
	if Ext.IsModLoaded("961ae59d-2964-46dd-9762-073697915dc2") then
		-- Pretty brutal apparently
		IgnoredSkills["Target_OdinAERO_Enemy_InsulationShield"] = true
	end
	-- Divinity Conflux by Xorn
	if Ext.IsModLoaded("723ad06b-0241-4a2e-a9f3-4d2b419e0fe3") then
		-- Super damage
		IgnoredSkills["ProjectileStrike_Enemy_Xorn_Comdor_Smash"] = true
	end
	BuildEnemySkills()

	-- Defaults
	Settings.Global.Variables.Hardmode_MinBonusRolls.Value = math.tointeger(Ext.ExtraData["LLENEMY_Hardmode_DefaultBonusRolls_Min"] or 1)
	Settings.Global.Variables.Hardmode_MaxBonusRolls.Value = math.tointeger(Ext.ExtraData["LLENEMY_Hardmode_DefaultBonusRolls_Max"] or 4)

	LeaderLib.SettingsManager.AddSettings(Settings)
end
Ext.RegisterListener("SessionLoaded", LLENEMY_Server_SessionLoaded)

LeaderLib.RegisterListener("ModSettingsLoaded", function()
	Osi.DB_LLSENEMY_LevelModifier:Delete(nil)
	Osi.DB_LLSENEMY_LevelModifier(Settings.Global.Variables.LLENEMY_Scaling_LevelModifier.Value or 0)
end)

-- Retroactively remove blacklisted skills if they were modified
LeaderLib.RegisterListener("Initialized", function()
	local status,err = xpcall(function()
		if EnemySkills ~= nil and #EnemySkills > 0 then
			for _,skillgroup in pairs(EnemySkills) do
				if skillgroup.Entries ~= nil then
					for i,skill in pairs(skillgroup.Entries) do
						if IgnoreSkill(skill) then
							skillgroup.Entries[i] = nil
						end
					end
				end
			end
		end
	end, debug.traceback)
	if not status then
		Ext.PrintError("[EUO] Error adjusting EnemySkills:")
		Ext.PrintError(err)
	end

	SetHighestPartyLoremaster()
end)