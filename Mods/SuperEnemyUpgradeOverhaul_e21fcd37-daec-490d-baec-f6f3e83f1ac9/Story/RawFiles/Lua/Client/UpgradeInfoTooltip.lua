---@class TranslatedString
local TranslatedString = LeaderLib.Classes["TranslatedString"]

local function sortupgrades(a,b)
	return a:upper() < b:upper()
end

local function sortUpgradeEntries(a,b)
	return a.SortOn < b.SortOn
end

local upgradeInfoEntryColorText = TranslatedString:Create("ha4587526ge140g42f9g9a98gc92b537d4209", "<font color='[2]' size='18'>[1]</font>")
local upgradeInfoEntryColorlessText = TranslatedString:Create("h869a7616gfbb7g4cc2ga233g7c22612af67b", "<font size='18'>[1]</font>")
local bulletImage = "<img src='Icon_BulletPoint'>"

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

---@class UpgradeTextEntry:table
---@field DisplayName string
---@field Description string
---@field Output string
---@field SortOn string

---@return UpgradeTextEntry[]
local function BuildUpgradeEntries(character, upgradeKeys, hardmodeStatuses, isControllerMode)
	local entries = {}
	for _,status in pairs(upgradeKeys) do
		local loreMin = UpgradeData.Statuses[status] or 0
		local nameText = GameHelpers.Tooltip.StripFont(Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute(status, "DisplayName")) or "")
		local description = ""
		local canShowDesc = StringHelpers.IsNullOrWhitespace(Ext.StatGetAttribute(status, "Icon"))
		if canShowDesc and (UpgradeData.Statuses[status] or string.find(status, "LLENEMY")) then
			description = Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute(status, "Description")) or ""
			if not StringHelpers.IsNullOrWhitespace(description) then
				description = GameHelpers.Tooltip.StripFont(GameHelpers.Tooltip.ReplacePlaceholders(description, character))
			end
		end

		local skills = Ext.StatGetAttribute(status, "Skills")
		if not StringHelpers.IsNullOrEmpty(skills) then
			skills = StringHelpers.Split(skills, ";")
			local skillNames = {}
			for i,v in pairs(skills) do
				local skillName = Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute(v, "DisplayName"))
				if not StringHelpers.IsNullOrEmpty(skillName) then
					local ability = Ext.StatGetAttribute(v, "Ability")
					if ability then
						local color = FormatColor[ability]
						if color then
							if isControllerMode ~= true then
								skillName = string.format("%s<font color='%s'>%s</font>", bulletImage, color, skillName)
							else
								skillName = string.format("<font color='%s'>%s</font>", color, skillName)
							end
						end
					end
					skillNames[#skillNames+1] = skillName
				end
			end
			if not StringHelpers.IsNullOrEmpty(description) then
				description = string.format("%s<br>Gained Skills:<br>%s", description, StringHelpers.Join("<br>", skillNames))
			else
				description = string.format("Gained Skills:<br>%s", StringHelpers.Join("<br>", skillNames))
			end
		end
		if nameText == "" then
			local potion = Ext.StatGetAttribute(status, "StatsId") or ""
			if potion ~= "" then
				nameText = Ext.GetTranslatedStringFromKey(potion) or ""
			end
		end
		if nameText ~= "" then
			---@type UpgradeTextEntry
			local entry = {}
			entry.SortOn = GameHelpers.Tooltip.StripFont(nameText):upper()
			local colorName = Ext.StatGetAttribute(status, "FormatColor") or "Special"
			local color = FormatColor[colorName] or "#C9AA58"
			if HighestLoremaster < loreMin then
				nameText = "???"
			end
			local text = string.gsub(upgradeInfoEntryColorText.Value, "%[1%]", nameText):gsub("%[2%]", color)
			local hardmodeText = ""
			if hardmodeStatuses[status] == true then
				hardmodeText = " <font color='#834DFF' size='18'>*H*</font>"
			end
			entry.DisplayName = string.format("%s%s", text, hardmodeText)
			if not StringHelpers.IsNullOrEmpty(description) and HighestLoremaster >= loreMin then
				entry.Description = string.format("<font size='16' color='#C3C3FF'>%s</font>", description)
				entry.Output = entry.DisplayName .. "<br>" .. entry.Description .. "<br>"
			else
				entry.Description = nil
				entry.Output = entry.DisplayName
			end
			table.insert(entries, entry)
			--table.insert(entries, entry.Output)
		end
	end
	return entries
end

local function FormatUpgrades(character, upgradeKeys, hardmodeStatuses, isControllerMode)
	local output = "<img src='Icon_Line' width='350%'><br>"
	local allUpgradeText = {}
	if isControllerMode == true then
		output = "" -- No Icon_Line
	end
	local i = 0
	for _,status in pairs(upgradeKeys) do
		local loreMin = UpgradeData.Statuses[status] or 0
		local nameText = Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute(status, "DisplayName")) or ""
		local description = Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute(status, "Description")) or ""
		if not StringHelpers.IsNullOrEmpty(description) then
			description = GameHelpers.Tooltip.ReplacePlaceholders(description, character)
		end
		local skills = Ext.StatGetAttribute(status, "Skills")
		if not StringHelpers.IsNullOrEmpty(skills) then
			skills = StringHelpers.Split(skills, ";")
			local skillNames = {}
			for i,v in pairs(skills) do
				local skillName = Ext.GetTranslatedStringFromKey(Ext.StatGetAttribute(v, "DisplayName"))
				if not StringHelpers.IsNullOrEmpty(skillName) then
					local ability = Ext.StatGetAttribute(v, "Ability")
					if ability then
						local color = FormatColor[ability]
						if color then
							skillName = string.format("<font color='%s'>%s</font>", color, skillName)
						end
					end
					skillNames[#skillNames+1] = skillName
				end
			end
			if not StringHelpers.IsNullOrEmpty(description) then
				description = string.format("%s<br>Gained Skills:<br>%s", description, StringHelpers.Join("<br>", skillNames))
			else
				description = string.format("Gained Skills:<br><font size='12'>%s</font>", StringHelpers.Join("<br>", skillNames))
			end
		end
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
			-- if isControllerMode ~= true then
			-- 	text = "<img src='Icon_BulletPoint'>"..text
			-- end
			local hardmodeText = ""
			if hardmodeStatuses[status] == true then
				hardmodeText = " <font color='#834DFF' size='18'>*H*</font>"
			end
			if not StringHelpers.IsNullOrEmpty(description) and HighestLoremaster >= loreMin then
				allUpgradeText[#allUpgradeText+1] = string.format("%s%s<br><font size='14'>%s</font>", text, hardmodeText, description)
			else
				allUpgradeText[#allUpgradeText+1] = string.format("%s%s", text, hardmodeText)
			end
			i = i + 1
		end
	end
	if #allUpgradeText > 0 then
		output = output .. StringHelpers.Join("<br>", allUpgradeText)
	end
	if isControllerMode == true then
		output = output:gsub("size='%d+'", "")
	end
	return output
end

---@param character EclCharacter
---@return UpgradeTextEntry[]|nil
local function GetUpgradeInfoText(character, isControllerMode)
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
		--table.sort(upgradeKeys, sortupgrades)
		local entries = BuildUpgradeEntries(character, upgradeKeys, hardmodeStatuses, isControllerMode)
		table.sort(entries, sortUpgradeEntries)
		return entries
	end
	return nil
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