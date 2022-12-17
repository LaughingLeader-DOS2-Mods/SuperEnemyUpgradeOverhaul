function SetChallengePointsTag(uuid)
	local cp = GetVarInteger(uuid, "LLENEMY_ChallengePoints") or 0
	if cp == nil or cp < 0 then cp = 0 end
	for k,tbl in pairs(ChallengePointsText) do
		if cp >= tbl.Min and (cp <= tbl.Max or tbl.Tag == "LLENEMY_CP_05") then
			SetTag(uuid, tbl.Tag)
		else
			ClearTag(uuid, tbl.Tag)
		end
	end
	if cp >= 5 then
		--local data = UpgradeSystem.GetCurrentRegionData(nil, uuid, false)
		--PrintDebug(string.format("[EUO:SetChallengePointsTag] (%s) CP(%i) Upgrades(%s)", uuid, cp, Ext.JsonStringify(data)))
	end
end

local function HasSavedUpgrade(uuid, id)
	---@type SavedUpgradeData[]
	local data = UpgradeSystem.GetCurrentRegionData(GetRegion(uuid), uuid, false)
	if data ~= nil then
		for i,v in pairs(data) do
			if v.ID == id then
				return true
			end
		end
	end
	return false
end

local function HasUpgrades(uuid)
	for key,group in pairs(UpgradeData) do
		for status,infoText in pairs(group) do
			if HasActiveStatus(uuid, status) == 1 or HasSavedUpgrade(uuid, status) then
				return true
			end
		end
	end
	return false
end

function UpgradeInfo_ApplyInfoStatus(uuid,force)
	if force == true or HasUpgrades(uuid) then
		ApplyStatus(uuid, "LLENEMY_UPGRADE_INFO", -1.0, 1, uuid)
	else
		RemoveStatus(uuid, "LLENEMY_UPGRADE_INFO")
	end
end

function UpgradeInfo_RefreshInfoStatuses()
	local combatCharacters = Osi.DB_CombatCharacters:Get(nil,nil)
	if #combatCharacters > 0 then
		for i,entry in pairs(combatCharacters) do
			local uuid = entry[1]
			if HasActiveStatus(uuid, "LLENEMY_UPGRADE_INFO") == 1 then
				--local handle = NRD_StatusGetHandle(uuid, "LLENEMY_UPGRADE_INFO")
				--NRD_StatusSetReal(uuid, handle, "LifeTime", 24.0)
				--NRD_StatusSetReal(uuid, handle, "CurrentLifeTime", 24.0)
				--NRD_StatusSetReal(uuid, handle, "LifeTime", -1.0)
				--NRD_StatusSetReal(uuid, handle, "CurrentLifeTime", -1.0)
				ApplyStatus(uuid, "LLENEMY_UPGRADE_INFO", -1.0, 1, uuid)
			else
			
			end
		end
		PrintDebug("[EUO:UpgradeInfo.lua:RefreshInfoStatuses] Refreshed upgrade info on characters in combat.")
	end
end

local function GetHighestPartyLoremaster()
	local nextHighest = 0
	local players = Osi.DB_IsPlayer:Get(nil)
	for _,entry in pairs(players) do
		local uuid = entry[1]
		local character = Ext.GetCharacter(uuid)
		if character ~= nil then
			if character.Stats.Loremaster > nextHighest then
				nextHighest = character.Stats.Loremaster
			end
		end
	end
	return nextHighest
end

function SetHighestPartyLoremaster()
	HighestLoremaster = GetHighestPartyLoremaster()
	if Ext.GetGameState() == "Running" then
		Ext.BroadcastMessage("LLENEMY_SetHighestLoremaster", tostring(HighestLoremaster), nil)
		PrintDebug("[EUO:SetHighestPartyLoremaster] Synced highest party loremaster.",HighestLoremaster)
	else
		TimerCancel("Timers_LLENEMY_SyncHighestLoremaster")
		TimerLaunch("Timers_LLENEMY_SyncHighestLoremaster", 500)
	end
end

-- Loremaster
local function SaveHighestLoremaster(player, stat, lastVal, nextVal)
	local nextHighest = HighestLoremaster
	if player ~= nil then
		if nextVal >= nextHighest then
			local lore = CharacterGetAbility(player, "Loremaster")
			if lore >= HighestLoremaster then
				nextHighest = lore
			end
		elseif nextVal < lastVal then
			nextHighest = GetHighestPartyLoremaster()
		end
	else
		nextHighest = GetHighestPartyLoremaster()
	end

	if HighestLoremaster ~= nextHighest then
		HighestLoremaster = nextHighest
		if Ext.GetGameState() == "Running" then
			Ext.BroadcastMessage("LLENEMY_SetHighestLoremaster", tostring(HighestLoremaster), nil)
		else
			TimerCancel("Timers_LLENEMY_SyncHighestLoremaster")
			TimerLaunch("Timers_LLENEMY_SyncHighestLoremaster", 500)
		end
	end
end

Events.CharacterBasePointsChanged:Subscribe(function (e)
	SaveHighestLoremaster(e.CharacterGUID, e.Stat, e.Last, e.Current)
end, {MatchArgs={Stat="Loremaster"}})

-- event CharacterBaseAbilityChanged((CHARACTERGUID)_Character, (STRING)_Ability, (INTEGER)_OldBaseValue, (INTEGER)_NewBaseValue)
---@param character string
---@param ability string
---@param old integer
---@param new integer
local function OnCharacterBaseAbilityChanged(character, ability, old, new)
	if ability == "Loremaster" and CharacterIsPlayer(character) == 1 and CharacterIsSummon(character) == 0 and CharacterIsPartyFollower(character) == 0 then
		SaveHighestLoremaster(character, ability, old, new)
	end
end

RegisterProtectedOsirisListener("CharacterBaseAbilityChanged", 4, "after", OnCharacterBaseAbilityChanged)