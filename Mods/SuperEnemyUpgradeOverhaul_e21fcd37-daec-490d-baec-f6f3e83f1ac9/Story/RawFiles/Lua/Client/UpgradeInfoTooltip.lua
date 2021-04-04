---@class TranslatedString
local TranslatedString = LeaderLib.Classes["TranslatedString"]

local function sortupgrades(a,b)
	return a:upper() < b:upper()
end

local upgradeInfoEntryColorText = TranslatedString:Create("ha4587526ge140g42f9g9a98gc92b537d4209", "<font color='[2]' size='18'>[1]</font>")
local upgradeInfoEntryColorlessText = TranslatedString:Create("h869a7616gfbb7g4cc2ga233g7c22612af67b", "<font size='18'>[1]</font>")

local FormatColor = {
	White = "#FFFFFF",
	DarkGray = "#454545",
	Gray = "#A8A8A8",
	LightGray = "#DBDBDB",
	--Red = "#C80030",
	Red = "#FF0030",
	Blue = "#188EDE",
	DarkBlue = "#004672",
	LightBlue = "#CFECFF",
	Green = "#40B606",
	PoisonGreen = "#00AA00",
	Yellow = "#FCD203",
	Orange = "#FF9600",
	Pink = "#FFC3C3",
	Purple = "#7F00FF",
	Brown = "#B97A57",
	Gold = "#C7A758",
	Black = "#000000",
	Normal = "#FFFFFF",
	StoryItem = "#D040D0",
	Blackrock = "#797980",
	Poison = "#65C900",
	Earth = "#7F3D00",
	Air = "#7D71D9",
	Water = "#4197E2",
	Fire = "#FE6E27",
	Source = "#46B195",
	Decay = "#B823CB",
	Polymorph = "#F7BA14",
	Ranger = "#81AB00",
	Rogue = "#639594",
	Summoner = "#7F25D4",
	Void = "#73F6FF",
	Warrior = "#DA2512",
	Special = "#C9AA58",
	Healing = "#97FBFF",
	Charm = "#FFB8B8",
}

local function GetCharacterData(netid, uuid)
	local upgrades = UpgradeResultData[netid]
	if upgrades == nil then
		upgrades = UpgradeResultData[uuid]
	end
	return upgrades
end

local function HasUpgrade(character, id, upgradeData)
	if character:GetStatus(id) ~= nil then
		return true
	elseif upgradeData ~= nil then
		local hardmodeOnly = upgradeData[id]
		if hardmodeOnly ~= nil and (not hardmodeOnly or Settings.Global:FlagEquals("LLENEMY_HardmodeEnabled", true)) then
			return true
		end
	end
	return false
end

---@param character EclCharacter
local function GetUpgradeInfoText(character, isControllerMode)
	if character.MyGuid == nil then
		return ""
	end
	if Ext.IsDeveloperMode() then
		HighestLoremaster = 10
	end
	if HighestLoremaster == nil or HighestLoremaster == 0 then
		pcall(function()
			if LeaderLib.UI.ClientCharacter ~= nil then
				local clientChar = Ext.GetCharacter(LeaderLib.UI.ClientCharacter)
				if clientChar ~= nil and clientChar.Stats.Loremaster > 0 then
					HighestLoremaster = clientChar.Stats.Loremaster
				end
			end
		end)
	end
	local upgradeKeys = {}
	local hardmodeStatuses = {}
	local savedUpgradeData = GetCharacterData(character.NetID, character.MyGuid)
	if savedUpgradeData ~= nil then
		for id,hardmodeOnly in pairs(savedUpgradeData) do
			table.insert(upgradeKeys, id)
			if hardmodeOnly then
				hardmodeStatuses[id] = true
			end
		end
	else
		for status,loreMin in pairs(UpgradeData.Statuses) do
			if HasUpgrade(character, status, savedUpgradeData) then
				table.insert(upgradeKeys, status)
			end
		end
	end

	local count = #upgradeKeys
	if count > 0 then
		table.sort(upgradeKeys, sortupgrades)
		local output = "<img src='Icon_Line' width='350%'><br>"
		if isControllerMode == true then
			output = "" -- No Icon_Line
		end
		local i = 0
		for _,status in pairs(upgradeKeys) do
			local loreMin = UpgradeData.Statuses[status] or 0
			local nameText = Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute(status, "DisplayName")) or ""
			if nameText == "" then
				local potion = Ext.StatGetAttribute(status, "StatsId") or ""
				if potion ~= "" then
					nameText = Ext.GetTranslatedStringFromKey(potion) or ""
				end
			end
			if nameText ~= "" then
				local colorName = Ext.StatGetAttribute(status, "FormatColor") or "Special"
				local color = FormatColor[colorName] or "#C9AA58"
				if HighestLoremaster < loreMin then
					nameText = "???"
				end
				local text = string.gsub(upgradeInfoEntryColorText.Value, "%[1%]", nameText):gsub("%[2%]", color)
				if isControllerMode ~= true then
					text = "<img src='Icon_BulletPoint'>"..text
				end
				output = output..text
				if hardmodeStatuses[status] == true then
					output = output .. " <font color='#834DFF' size='18'>*H*</font>"
				end
				if i < count - 1 then
					output = output.."<br>"
				end
				i = i + 1
			end
		end
		if isControllerMode == true then
			output = output:gsub("size='%d+'", "")
		end
		return output
	end
	return ""
end

---@param character EsvCharacter
local function GetChallengePointsText(character, isControllerMode)
	local output = "<img src='Icon_Line' width='350%'><br>"
	if isControllerMode == true then
		output = "" -- No Icon_Line
	end
	local isTagged = false
	for k,tbl in pairs(ChallengePointsText) do
		if character:HasTag(tbl.Tag) then
			if HighestLoremaster >= 2 then
				if character:GetStatus("LLENEMY_DUPLICANT") == nil then
					output = output .. string.gsub(DropText.Value, "%[1%]", tbl.Text.Value)
				else
					output = output .. string.gsub(ShadowDropText.Value, "%[1%]", tbl.Text.Value)
				end
			else
				if character:GetStatus("LLENEMY_DUPLICANT") == nil then
					output = output .. HiddenDropText.Value
				else
					output = output .. HiddenShadowDropText.Value
				end
			end
			if isControllerMode == true then
				output = output:gsub("size='%d+'", "")
			end
			isTagged = true
		end
	end
	--LeaderLib.PrintDebug("CP Tooltip | Name("..tostring(character.Name)..") NetID(".. tostring(character.NetID)..") character.Stats.NetID("..tostring(Ext.GetCharacter(character.NetID).Stats.NetID)..")")
	--LeaderLib.PrintDebug("Tags: " .. Common.Dump(character:GetTags()))
	-- if statusSource ~= nil then
	-- 	LeaderLib.PrintDebug("CP Tooltip | Source Name("..tostring(statusSource.Name)..") NetID(".. tostring(statusSource.NetID)..") character.Stats.NetID("..tostring(Ext.GetCharacter(statusSource.NetID).Stats.NetID)..")")
	-- 	LeaderLib.PrintDebug("Tags: " .. Common.Dump(statusSource:GetTags()))
	-- end
	-- if data.isDuplicant == true then
	-- 	output = output .. "<br><font color='#65C900' size='14'>Grants no experience, but drops guaranteed loot.</font>"
	-- end
	if isTagged then
		return output
	end
	return ""
end

return {
	GetUpgradeInfoText = GetUpgradeInfoText,
	GetChallengePointsText = GetChallengePointsText
}