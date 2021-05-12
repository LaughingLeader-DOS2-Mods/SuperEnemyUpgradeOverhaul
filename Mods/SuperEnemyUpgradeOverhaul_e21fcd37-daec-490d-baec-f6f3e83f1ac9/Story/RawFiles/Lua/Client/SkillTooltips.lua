local SkillBonuses = {
	Skill = {
		Rain_Water = {"LLENEMY_ShadowBonus_ShockingRain"},
		Rain_EnemyWater = {"LLENEMY_ShadowBonus_ShockingRain"},
		Target_Haste = {"LLENEMY_ShadowBonus_TimeHaste"},
		Target_EnemyHaste = {"LLENEMY_ShadowBonus_TimeHaste"},
	},
	Ability = {
		Fire = {"LLENEMY_ShadowBonus_CursedFire"}
	}
}

local BonusConditionalText = {
	LLENEMY_ShadowBonus_TimeHaste = "LLENEMY_TimeHasteUsed"
}

local function GetBonuses(character, skill)
	local bonuses = {}
	local hasBonuses = false
	if SkillBonuses.Skill[skill] then
		for i,v in pairs(SkillBonuses.Skill[skill]) do
			bonuses[v] = true
		end
		hasBonuses = true
	end
	if Data.ActionSkills[skill] ~= true then
		local ability = Ext.StatGetAttribute(skill, "Ability")
		if SkillBonuses.Ability[ability] then
			for i,v in pairs(SkillBonuses.Ability[ability]) do
				bonuses[v] = true
			end
			hasBonuses = true
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
			local name = ItemDisplayNames[v.NetID]
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
		if itemName ~= false then
			local name = Ext.GetTranslatedStringFromKey(tag)
			local description = Ext.GetTranslatedStringFromKey(tag .. "_Description")
			if name and description then
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