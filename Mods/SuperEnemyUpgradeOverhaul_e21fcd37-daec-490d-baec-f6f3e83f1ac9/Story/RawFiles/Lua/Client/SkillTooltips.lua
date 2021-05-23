if SkillTagBonuses == nil then
	SkillTagBonuses = {}
end

SkillTagBonuses.Skill = {
	Rain_Water = {"LLENEMY_ShadowBonus_ShockingRain"},
	Rain_EnemyWater = {"LLENEMY_ShadowBonus_ShockingRain"},
	Target_Haste = {"LLENEMY_ShadowBonus_TimeHaste"},
	Target_EnemyHaste = {"LLENEMY_ShadowBonus_TimeHaste"},
	--Shout_GlobalCooling = {"LLENEMY_ShadowBonus_BloodyWinter"},
}
SkillTagBonuses.Ability = {
	--Fire = {"LLENEMY_ShadowBonus_CursedFire"}
}
SkillTagBonuses.Custom = {
	function(character, skill, stat)
		if (stat.Ability == "Fire" or stat.DamageType == "Fire") and stat["Damage Multiplier"] > 0 then
			return "LLENEMY_ShadowBonus_CursedFire"
		end
	end
}

local BonusConditionalText = {
	LLENEMY_ShadowBonus_TimeHaste = "LLENEMY_TimeHasteUsed"
}

local function GetBonuses(character, skill)
	local bonuses = {}
	local hasBonuses = false
	local stat = not Data.ActionSkills[skill] and Ext.GetStat(skill) or {}
	if SkillTagBonuses.Skill[skill] then
		for i,v in pairs(SkillTagBonuses.Skill[skill]) do
			bonuses[v] = true
		end
		hasBonuses = true
	end
	if Data.ActionSkills[skill] ~= true then
		local ability = Ext.StatGetAttribute(skill, "Ability")
		if SkillTagBonuses.Ability[ability] then
			for i,v in pairs(SkillTagBonuses.Ability[ability]) do
				local t = type(v)
				if t == "string "then
					bonuses[v] = true
					hasBonuses = true
				elseif t == "function" then
					local b,result = xpcall(v, debug.traceback, character, skill, ability, stat)
					if b and result then
						bonuses[result] = true
						hasBonuses = true
					elseif not b then
						Ext.PrintError(result)
					end
				end
			end
		end
	end
	for i,v in pairs(SkillTagBonuses.Custom) do
		local b,result = xpcall(v, debug.traceback, character, skill, stat)
		if b and result then
			local t = type(result)
			if t == "string" then
				bonuses[result] = true
				hasBonuses = true
			elseif t == "table" then
				for _,v2 in pairs(result) do
					bonuses[v2] = true
					hasBonuses = true
				end
			end
		elseif not b then
			Ext.PrintError(result)
		end
	end
	return bonuses,hasBonuses
end

---@param items EclItem[]
---@param tag string
---@return boolean
local function HasTaggedItemEquipped(items, tag)
	for i,v in pairs(items) do
		if v:HasTag(tag) then
			local name = v.DisplayName
			if v:HasTag("LLENEMY_ShadowItem") and name ~= nil then
				local color = ShadowItemTooltipData.RarityColor[v.Stats.ItemTypeReal]
				name = string.format("<font color='%s' size='16'>%s</font>", color, name)
			end
			return string.format("<font size='16'>%s</font>", name),v.Stats.Slot
		end
	end
	return false
end

local function ApplyBonusText(character, skill, tooltip, bonuses, items)
	for tag,b in pairs(bonuses) do
		local itemName,slot = HasTaggedItemEquipped(items, tag)
		if itemName ~= false or Vars.DebugMode then
			local name = Ext.GetTranslatedStringFromKey(tag)
			local description = Ext.GetTranslatedStringFromKey(tag .. "_Description")
			if not StringHelpers.IsNullOrWhitespace(name) and not StringHelpers.IsNullOrWhitespace(description) then
				name = GameHelpers.Tooltip.ReplacePlaceholders(name, character)
				description = GameHelpers.Tooltip.ReplacePlaceholders(description, character)
				local descriptionElement = tooltip:GetElement("SkillDescription")
				if descriptionElement == nil then
					descriptionElement = {
						Type = "SkillDescription",
						Label = ""
					}
					tooltip:AppendElement(descriptionElement)
				end
				if not StringHelpers.IsNullOrWhitespace(itemName) then
					descriptionElement.Label = string.format("%s<br>%s<br>%s<br>(%s)", descriptionElement.Label, name, description, itemName)
				else
					descriptionElement.Label = string.format("%s<br>%s<br>%s", descriptionElement.Label, name, description)
				end
				local bonusConditionalTag = BonusConditionalText[tag]
				if bonusConditionalTag and character:HasTag(bonusConditionalTag) then
					local bonusText = GameHelpers.Tooltip.ReplacePlaceholders(Ext.GetTranslatedStringFromKey(bonusConditionalTag), character)
					if not StringHelpers.IsNullOrWhitespace(bonusText) then
						descriptionElement.Label = descriptionElement.Label .. "<br>" .. bonusText
					end
				end
			elseif Vars.DebugMode then
				local descriptionElement = tooltip:GetElement("SkillDescription")
				if descriptionElement == nil then
					descriptionElement = {
						Type = "SkillDescription",
						Label = ""
					}
					tooltip:AppendElement(descriptionElement)
				end
				descriptionElement.Label = string.format("%s<br>%s", descriptionElement.Label, tag)
			end
		end
	end
end

---@param character EclCharacter
---@param skill string
---@param tooltip TooltipData
local function OnSkillTooltip(character, skill, tooltip)
	local bonuses,b = GetBonuses(character, skill)
	if b then
		local items = {}
		for i,slot in Data.VisibleEquipmentSlots:Get() do
			local item = character:GetItemBySlot(slot)
			if item then
				items[#items+1] = Ext.GetItem(item)
			end
		end
		ApplyBonusText(character, skill, tooltip, bonuses, items)
	end
end

return OnSkillTooltip