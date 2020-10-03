

Ext.RegisterConsoleCommand("euo_printdata", function(cmd)
	print(Ext.JsonStringify(PersistentVars))
end)

local function GetLength(v)
	local totalCharacters = 0
	local totalUpgradeEntries = 0
	for region,data in pairs(PersistentVars.Upgrades.Results) do
		for uuid,cdata in pairs(data) do
			totalCharacters = totalCharacters + 1
			totalUpgradeEntries = totalUpgradeEntries + #cdata
		end
	end
	return totalCharacters,totalUpgradeEntries
end

local function ResetCharacter(uuid)
	RemoveStatus(uuid, "LLENEMY_UPGRADE_INFO")
	--RemoveHarmfulStatuses(uuid)
	for i,v in pairs(Ext.GetCharacter(uuid):GetStatuses()) do
		RemoveStatus(uuid, v)
	end
	NRD_CharacterSetPermanentBoostInt(uuid, "ArmorBoost", 0)
	NRD_CharacterSetPermanentBoostInt(uuid, "MagicArmorBoost", 0)
	NRD_CharacterSetPermanentBoostInt(uuid, "VitalityBoost", 0)
	NRD_CharacterSetPermanentBoostInt(uuid, "DamageBoost", 0)
	CharacterAddAttribute(uuid, "Dummy", 0)

	ApplyStatus(uuid, "LEADERLIB_RECALC", 0.0, 1, uuid)

	CharacterSetHitpointsPercentage(uuid, 100.0)
	CharacterSetArmorPercentage(uuid, 100.0)
	CharacterSetMagicArmorPercentage(uuid, 100.0)
end

local function ResetData()
	for i,db in pairs(Osi.DB_CombatCharacters:Get(nil, nil)) do
		ResetCharacter(db[1])
	end
	local region = Ext.GetCharacter(CharacterGetHostCharacter()).CurrentLevel
	for i,uuid in pairs(Ext.GetAllCharacters(region)) do
		RemoveStatus(uuid, "LLENEMY_UPGRADE_INFO")
		SetVarInteger(uuid, "LLENEMY_ChallengePoints", 0)
	end
	--for region,characters in pairs(PersistentVars.Upgrades.Results) do
		--for uuid,data in pairs(characters) do

	-- 	end
	-- end
	PersistentVars.Upgrades.Results = {}
	PersistentVars.Upgrades.DropCounts = {}
	local region = Osi.DB_CurrentLevel:Get(nil)[1][1]
	local time = Ext.MonotonicTime()
	print(string.format("Rolling Start(%s)", time))
	UpgradeSystem.RollRegion(region, true)
	local nextTime = Ext.MonotonicTime()
	local totalCharacter,totalUpgrades = GetLength()
	print(string.format("Rolling End(%s) | Took %s second(s) | Total Entries (%s characters, %s upgrades)", nextTime, (nextTime-time) / 1000, totalCharacter,totalUpgrades))
end

Ext.RegisterConsoleCommand("euo_resetdata", function(cmd)
	ResetData()
end)

Ext.RegisterConsoleCommand("euo_resetdatadelayed", function(cmd, delay)
	delay = tonumber(delay) or 2000
	LeaderLib.StartOneshotTimer("LLENEMY_Debug_ResetData", delay, function()
		ResetData()
	end)
end)

Ext.RegisterConsoleCommand("euo_refreshupgradeinfo", function(command)
	UpgradeInfo_SetHighestPartyLoremaster()
	UpgradeInfo_RefreshInfoStatuses()
end)

Ext.RegisterConsoleCommand("euo_printcp", function(command, all)
	if all == nil then
		for i,db in pairs(Osi.DB_CombatCharacters:Get(nil,nil)) do
			local cp = GetVarInteger(db[1], "LLENEMY_ChallengePoints") or 0
			local character = Ext.GetCharacter(db[1])
			print(string.format("[%s](%s) CP: %i", character.DisplayName, character.MyGuid, cp))
		end
	else
		for region,data in pairs(PersistentVars.Upgrades.Results) do
			for uuid,upgrades in pairs(data) do
				local cp = GetVarInteger(uuid, "LLENEMY_ChallengePoints") or 0
				local character = Ext.GetCharacter(uuid)
				print(string.format("[%s](%s) CP: %i", character.DisplayName, character.MyGuid, cp))
			end
		end
	end
end)