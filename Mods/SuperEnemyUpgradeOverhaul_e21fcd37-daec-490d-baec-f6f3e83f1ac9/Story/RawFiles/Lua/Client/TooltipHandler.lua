---@class TranslatedString
local TranslatedString = LeaderLib.Classes["TranslatedString"]

local maxSummonsText = TranslatedString:Create("hd248998fge250g4a7bg8dd3gc88f19fbe5f6", "Maximum Summons")
local ShadowItemFallbackDescription = "A <i>strange</i> item retrieved from a <font color='#9B30FF' face='Copperplate Gothic Bold'>Shadow Orb</font>.<br><font color='#BDA0CB'>Cold to the touch, when this item is held, your grip on reality may begin to slip.</font>"
local ShadowItemDescription = TranslatedString:Create("h179efab0g7e6cg441ag8083gb11964394dc4", ShadowItemFallbackDescription)
local ShadowItemNameColor = TranslatedString:Create("h0301fb1cg95a6g47e5gade7g8ccfc0ffef2f", "<font color='[1]'>[2]</font>")
local ShadowItemNameAffix = TranslatedString:Create("h1d44d1a4g804bg43fbg80dfgd3e3d07a897d", "<font color='#A020F0'>[1] of Shadows</font>")
local ShadowItemRarity = TranslatedString:Create("habff2fe9g031cg4c7cg85feg28a1fa25fb14", "<font color='[1]'>Shadow Treasure</font>")
local ShadowItemRarityDescription = TranslatedString:Create("h6d3ad5e8g6bf2g4c8dgb1b8gef0e3ead4982", "<font color='#33FF88' size='20'>Appraisers say this item used to be [1].</font>")

local rarityColor = {
	Common = "#AEA8FF",
	Uncommon = "#877FFF",
	Rare = "#6D50FF",
	Epic = "#8A2BE2",
	Legendary = "#7F00FF",
	Divine = "#AA00FF",
	Unique = "#BF5FFF"
}

local originalRarityColor = {
	Common = "#FFFFFF",
	Uncommon = "#00A900",
	Rare = "#33CCFF",
	Epic = "#A346E9",
	Legendary = "#D1007C",
	Divine = "#EBC808",
	Unique = "#C7A758"
}

local rarityName = {
	Common = TranslatedString:Create("h5c0f3da4g83a2g4f3fg9944gc80920bcb4df", "Common"),
	Uncommon = TranslatedString:Create("h7682e16bg7c69g4a72g8f1fg1b32519665f3", "Uncommon"),
	Rare = TranslatedString:Create("heb7ba0d5g7f4cg49e9g9ce2g86cf5e5bd277", "Rare"),
	Epic = TranslatedString:Create("hd75b2771g8abag49b5g9b8egb608d51b9ddf", "Epic"),
	Legendary = TranslatedString:Create("h97227897g1345g4046gbb62g842dcc292db1", "Legendary"),
	Divine = TranslatedString:Create("h09d00ab3g7edbg4569ga4d7gf37b9b7b04cb", "Divine"),
	Unique = TranslatedString:Create("h04685fd1g024ag4641gaed6g0ffb2d0ff103", "Unique"),
}

---@param item EsvItem
---@param tooltip TooltipData
local function OnItemTooltip(item, tooltip)
	--print(item.Stats.ItemTypeReal, item:HasTag("LLENEMY_ShadowItem"), Ext.JsonStringify(tooltip.Data))
	--print(item.StatsId, item.RootTemplate, item.MyGuid, item:HasTag("LLENEMY_ShadowItem"))
	--Ext.PostMessageToServer("LLENEMY_Debug_PrintComboCategory", item.MyGuid)
	--print(string.format("%s ComboCategory:\n%s", item.Stats.Name, Ext.JsonStringify(item.Stats.ComboCategory)))
	if item ~= nil and item:HasTag("LLENEMY_ShadowItem") then
		--print(item.ItemType, item.Stats.ItemType, item.Stats.ItemTypeReal)
		local maxSummons = item.Stats.MaxSummons
		for i,stat in pairs(item.Stats.DynamicStats) do
			if stat ~= nil then
				maxSummons = maxSummons + stat.MaxSummons
			end
		end
		if maxSummons > 0 then
			local element = {
				Type = "AbilityBoost",
				Label = maxSummonsText.Value,
				Value = maxSummons,
			}
			tooltip:AppendElement(element)
		end
		local rarity = item.Stats.ItemTypeReal
		if rarity == nil then
			rarity = "Common"
		end
		local color = rarityColor[rarity]
		local element = tooltip:GetElement("ItemRarity") or {Type = "ItemRarity", Label = "", New = true}
		if element ~= nil then
			--element.Label = ShadowItemRarity.Value:gsub("%[1%]", element.Label)
			element.Label = ShadowItemRarity.Value:gsub("%[1%]", color)
			if element.New == true then
				element.New = nil
				tooltip:AppendElement(element)
			end
		end
		element = tooltip:GetElement("ItemDescription") or {Type = "ItemDescription", Label = "", New = true}
		if element ~= nil then
			local fontTag = "<font size='16'>"
			if tooltip.ControllerEnabled == true then
				fontTag = "<font size='24'>"
			end
			if not LeaderLib.StringHelpers.IsNullOrEmpty(element.Label) then
				element.Label = element.Label .. "<br>"..fontTag .. ShadowItemDescription.Value .. "</font>"
			else
				element.Label = fontTag .. ShadowItemDescription.Value .. "</font>"
			end
			local rarityName = string.format("<font color='%s'>%s</font>", originalRarityColor[rarity], rarityName[rarity].Value)
			element.Label = element.Label .. "<br>" .. ShadowItemRarityDescription:ReplacePlaceholders(rarityName)
			if element.New == true then
				element.New = nil
				tooltip:AppendElement(element)
			end
		end
		element = tooltip:GetElement("ItemName")
		if element ~= nil then
			-- Shadow Treasure has custom name colors, so we remove the default rarity color here.
			element.Label = element.Label:gsub("<font.->", "<font color='"..color.."'>")
		end
	end
end

local upgradeInfoHelpers = Ext.Require("Client/UpgradeInfoTooltip.lua")

---@param character EsvCharacter
---@param status EsvStatus
---@param tooltip TooltipData
local function OnUpgradeInfoTooltip(character, status, tooltip)
	local element = tooltip:GetElement("StatusDescription")
	if element ~= nil then
		local upgradeInfoText = upgradeInfoHelpers.GetUpgradeInfoText(character)
		if not character:HasTag("LLENEMY_RewardsDisabled") then
			local challengePointsText = upgradeInfoHelpers.GetChallengePointsText(character)
			element.Label = string.format("%s<br>%s<br>%s", element.Label, upgradeInfoText, challengePointsText)
		else
			element.Label = string.format("%s<br>%s", element.Label, upgradeInfoText)
		end
	end
end

local PotionStats = {
	--["ModifierType"] = "ModifierType",
	["VitalityBoost"] = "ConstantInt",
	["Strength"] = "Penalty PreciseQualifier",
	["Finesse"] = "Penalty PreciseQualifier",
	["Intelligence"] = "Penalty PreciseQualifier",
	["Constitution"] = "Penalty PreciseQualifier",
	["Memory"] = "Penalty PreciseQualifier",
	["Wits"] = "Penalty PreciseQualifier",
	["SingleHanded"] = "ConstantInt",
	["TwoHanded"] = "ConstantInt",
	["Ranged"] = "ConstantInt",
	["DualWielding"] = "ConstantInt",
	["RogueLore"] = "ConstantInt",
	["WarriorLore"] = "ConstantInt",
	["RangerLore"] = "ConstantInt",
	["FireSpecialist"] = "ConstantInt",
	["WaterSpecialist"] = "ConstantInt",
	["AirSpecialist"] = "ConstantInt",
	["EarthSpecialist"] = "ConstantInt",
	["Sourcery"] = "ConstantInt",
	["Necromancy"] = "ConstantInt",
	["Polymorph"] = "ConstantInt",
	["Summoning"] = "ConstantInt",
	["PainReflection"] = "ConstantInt",
	["Perseverance"] = "ConstantInt",
	["Leadership"] = "ConstantInt",
	["Telekinesis"] = "ConstantInt",
	["Sneaking"] = "ConstantInt",
	["Thievery"] = "ConstantInt",
	["Loremaster"] = "ConstantInt",
	["Repair"] = "ConstantInt",
	["Barter"] = "ConstantInt",
	["Persuasion"] = "ConstantInt",
	["Luck"] = "ConstantInt",
	["FireResistance"] = "ConstantInt",
	["EarthResistance"] = "ConstantInt",
	["WaterResistance"] = "ConstantInt",
	["AirResistance"] = "ConstantInt",
	["PoisonResistance"] = "ConstantInt",
	["PhysicalResistance"] = "ConstantInt",
	["PiercingResistance"] = "ConstantInt",
	["Sight"] = "ConstantInt",
	--["Hearing"] = "Penalty Qualifier",
	["Initiative"] = "ConstantInt",
	["Vitality"] = "ConstantInt",
	["VitalityPercentage"] = "ConstantInt",
	["MagicPoints"] = "ConstantInt",
	["ActionPoints"] = "ConstantInt",
	["ChanceToHitBoost"] = "ConstantInt",
	["AccuracyBoost"] = "ConstantInt",
	["DodgeBoost"] = "ConstantInt",
	["DamageBoost"] = "ConstantInt",
	["APCostBoost"] = "ConstantInt",
	["SPCostBoost"] = "ConstantInt",
	["APMaximum"] = "ConstantInt",
	["APStart"] = "ConstantInt",
	["APRecovery"] = "ConstantInt",
	["Movement"] = "ConstantInt",
	["MovementSpeedBoost"] = "ConstantInt",
	--["Gain"] = "BigQualifier",
	["Armor"] = "ConstantInt",
	["MagicArmor"] = "ConstantInt",
	["ArmorBoost"] = "ConstantInt",
	["MagicArmorBoost"] = "ConstantInt",
	["CriticalChance"] = "ConstantInt",
	--["Act"] = "Act",
	--["Act part"] = "ActPart",
	--["Duration"] = "ConstantInt",
	--["UseAPCost"] = "ConstantInt",
	--["ComboCategory"] = "FixedString",
	--["StackId"] = "FixedString",
	--["BoostConditions"] = "FixedString",
	["Flags"] = "AttributeFlags",
	--["StatusMaterial"] = "FixedString",
	--["StatusEffect"] = "FixedString",
	--["StatusIcon"] = "FixedString",
	--["SavingThrow"] = "SavingThrow",
	--["Weight"] = "ConstantInt",
	--["Value"] = "ConstantInt",
	--["InventoryTab"] = "InventoryTabs",
	--["UnknownBeforeConsume"] = "YesNo",
	--["Reflection"] = "FixedString",
	--["Damage"] = "Qualifier",
	--["Damage Multiplier"] = "ConstantInt",
	--["Damage Range"] = "ConstantInt",
	--["DamageType"] = "Damage Type",
	--["AuraRadius"] = "ConstantInt",
	--["AuraSelf"] = "FixedString",
	--["AuraAllies"] = "FixedString",
	--["AuraEnemies"] = "FixedString",
	--["AuraNeutrals"] = "FixedString",
	--["AuraItems"] = "FixedString",
	--["AuraFX"] = "FixedString",
	--["RootTemplate"] = "FixedString",
	--["ObjectCategory"] = "FixedString",
	--["MinAmount"] = "ConstantInt",
	--["MaxAmount"] = "ConstantInt",
	--["Priority"] = "ConstantInt",
	--["Unique"] = "ConstantInt",
	--["MinLevel"] = "ConstantInt",
	--["MaxLevel"] = "ConstantInt",
	--["BloodSurfaceType"] = "FixedString",
	["MaxSummons"] = "ConstantInt",
	--["AddToBottomBar"] = "YesNo",
	--["SummonLifelinkModifier"] = "ConstantInt",
	--["IgnoredByAI"] = "YesNo",
	["RangeBoost"] = "ConstantInt",
	--["BonusWeapon"] = "FixedString",
	--["AiCalculationStatsOverride"] = "FixedString",
	--["RuneEffectWeapon"] = "FixedString",
	--["RuneEffectUpperbody"] = "FixedString",
	--["RuneEffectAmulet"] = "FixedString",
	--["RuneLevel"] = "ConstantInt",
	["LifeSteal"] = "ConstantInt",
	--["IsFood"] = "YesNo",
	--["IsConsumable"] = "YesNo",
}

---@type TranslatedString
local ts = LeaderLib.Classes.TranslatedString

local ImmuneToText = ts:Create("hac7cca96gd0dfg4391gb188gc53fd12cb6a5", "Immune to [1]")
local ImmunityStatuses = {
	["FreezeImmunity"] = {},--ts:Create("h712e9a08g723eg48dbg9724ga28af68f0e87", "Immune To Freezing"),
	["BurnImmunity"] = {},--ts:Create("hb04fc33bgbba3g4d90g9c54gf98b2ebe3da0", "Immune To Burning"),
	["StunImmunity"] = {},--ts:Create("h052a0699g5abdg4674g9b5cg7d44a9972fbe", "Immune To Electrifying"),
	["PoisonImmunity"] = {},--ts:Create("h309c91c9gdb97g4fd9g9395g3f793e8e93a3", "Immune To Poisoning"),
	["CharmImmunity"] = {},--ts:Create("h30fc0122g6378g408cgac6fg6e3bcb3c852b", "Charmed"),
	["FearImmunity"] = {},--ts:Create("h6f38a9b4gc4deg4318g9f6cg4d073b48bde2", "Fear"),
	["KnockdownImmunity"] = {},--ts:Create("h4a390c48ga640g4f98ga491g7b92bb9f7ba8", "Knocked Down"),
	["MuteImmunity"] = {},
	["ChilledImmunity"] = {},
	["WarmImmunity"] = {},
	["WetImmunity"] = {},
	["BleedingImmunity"] = {},
	["CrippledImmunity"] = {},
	["BlindImmunity"] = {},
	["CursedImmunity"] = {},
	["WeakImmunity"] = {},
	["SlowedImmunity"] = {},
	["DiseasedImmunity"] = {},
	["InfectiousDiseasedImmunity"] = {},
	["PetrifiedImmunity"] = {},
	["DrunkImmunity"] = {},
	["SlippingImmunity"] = {},
	--["FreezeContact"] = {},
	--["BurnContact"] = {},
	--["StunContact"] = {},
	--["PoisonContact"] = {},
	--["ChillContact"] = {},
	--["Grounded"] = {},
	["HastedImmunity"] = {},
	["TauntedImmunity"] = {},
	["SleepingImmunity"] = {},
	["AcidImmunity"] = {},
	["SuffocatingImmunity"] = {},
	["RegeneratingImmunity"] = {},
	["DisarmedImmunity"] = {},
	["DecayingImmunity"] = {},
	["ClairvoyantImmunity"] = {},
	["EnragedImmunity"] = {},
	["BlessedImmunity"] = {},
	--["ProtectFromSummon"] = {},
	--["Floating"] = {},
	--["DeflectProjectiles"] = {},
	--["IgnoreClouds"] = {},
	["MadnessImmunity"] = {},
	["ChickenImmunity"] = {},
	--["IgnoreCursedOil"] = {},
	["ShockedImmunity"] = {},
	["WebImmunity"] = {},
	--["EntangledContact"] = {},
	["ShacklesOfPainImmunity"] = {},
	--["MagicalSulfur"] = {},
	--["ThrownImmunity"] = {},
	["InvisibilityImmunity"] = {},
}

local PercentageValueText = ts:Create("ha020d932g69e4g4957g998dg9204aa232200", "[1]:[2]")

local Resistances = {
	AirResistance = true,
	EarthResistance = true,
	FireResistance = true,
	PhysicalResistance = true,
	PiercingResistance = true,
	PoisonResistance = true,
	WaterResistance = true,
}

local function DisplayNameIsInTable(tbl, name)
	for i,v in pairs(tbl) do
		if v ~= "" then
			local displayName = Ext.StatGetAttribute(v, "DisplayName") or ""
			if name == displayName then
				return true
			end
		end
	end
	return false
end

Ext.RegisterListener("SessionLoaded", function()
	for i,status in pairs(Ext.GetStatEntries("StatusData")) do
		if not string.find(status, "QUEST_") then
			local immuneFlag = Ext.StatGetAttribute(status, "ImmuneFlag") or ""
			local displayName = Ext.StatGetAttribute(status, "DisplayName") or ""
			local tbl = ImmunityStatuses[immuneFlag]
			if tbl ~= nil and displayName ~= "" and not DisplayNameIsInTable(tbl, Ext.GetTranslatedStringFromKey(displayName)) then
				table.insert(ImmunityStatuses[immuneFlag], status)
			end
		end
	end
end)
--print(Ext.StatGetAttribute("Stats_LLENEMY_Infusion_Blood", "Flags"))
---@param character EsvCharacter
---@param status EsvStatus
---@param tooltip TooltipData
local function OnInfusionInfoTooltip(character, status, tooltip)
	local resistances = {}
	local immunities = {}
	for i,v in pairs(character:GetStatuses()) do
		if v ~= "LLENEMY_INFUSION_INFO" and string.find(v, "LLENEMY_INF") then
			local potion = Ext.StatGetAttribute(v, "StatsId") or ""
			if potion ~= "" then
				local immuneFlags = Ext.StatGetAttribute(potion, "Flags") or ""
				if immuneFlags ~= "" then
					local flags = StringHelpers.Split(immuneFlags, ";")
					for _,f in pairs(flags) do
						immunities[f] = true
					end
				end
				for res,_ in pairs(Resistances) do
					local val = Ext.StatGetAttribute(potion, res) or 0
					if val ~= 0 then
						if resistances[res] == nil then
							resistances[res] = 0
						end
						resistances[res] = resistances[res] + val
					end
				end
			end
		end
	end
	for flag,b in pairs(immunities) do
		local statuses = ImmunityStatuses[flag]
		if statuses ~= nil then
			local statusNames = {}
			local text = ""
			for _,v in pairs(statuses) do
				local displayName = Ext.StatGetAttribute(v, "DisplayName") or ""
				if displayName ~= "" then
					displayName = Ext.GetTranslatedStringFromKey(displayName) or ""
					if displayName ~= "" then
						table.insert(statusNames, displayName)
					end
				end
			end
			if #statusNames > 0 then
				table.sort(statusNames)
				text = ImmuneToText:ReplacePlaceholders(StringHelpers.Join(", ", statusNames, true))
				tooltip:AppendElement({
					Type="StatusImmunity",
					Label=text
				})
			end
		end
	end
	for res,value in pairs(resistances) do
		local data = LeaderLib.LocalizedText.ResistanceNames[res]
		if data ~= nil then
			if value > 0 then
				local text = PercentageValueText:ReplacePlaceholders(data.Text.Value, string.format(" +%i", value)).."%"
				tooltip:AppendElement({
					Type="StatusBonus",
					Label=text
				})
			elseif value < 0 then
				local text = PercentageValueText:ReplacePlaceholders(data.Text.Value, string.format(" %i", value)).."%"
				tooltip:AppendElement({
					Type="StatusMalus",
					Label=text
				})
			end
		end
	end
end

local function FormatTagElements(tooltip_mc, group, ...)
	group.iconId = 16
	--group.setupHeader()
	for i=0,#group.list.content_array,1 do
		local element = group.list.content_array[i]
		if element ~= nil then
			local b,result = xpcall(function()
				-- local icon = element.getChildAt(3) or element.getChildByName("tt_groupIcon")
				-- if icon ~= nil then
				-- 	icon.gotoAndStop(17)
				-- else
				-- 	element.removeChildAt(3)
				-- end
				element.removeChildAt(3) -- Removes the tag icon

				element.label_txt.x = 0
				element.value_txt.x = 0
				element.warning_txt.x = 0

				local tag = element.label_txt.htmlText
				local tagEntry = ItemCorruption.TagBoosts[tag]

				if tagEntry ~= nil then
					local tagName,nameHandle = Ext.GetTranslatedStringFromKey(tag)
					local tagDesc,descHandle = Ext.GetTranslatedStringFromKey(tag.."_Description")
					tagDesc = GameHelpers.Tooltip.ReplacePlaceholders(tagDesc)
					element.label_txt.htmlText = tagName
					element.warning_txt.htmlText = tagDesc
					element.warning_txt.y = element.label_txt.y + element.label_txt.textHeight
				end
			end, debug.traceback)
			if not b then
				Ext.PrintError("[EUO:FormatTagElements] Error:")
				Ext.PrintError(result)
			end
		end
	end
	--tooltip_mc.resetBackground()
	--[[
	CASEINSENSITIVE : uint = 1
	  Specifies case-insensitive sorting for the Array class sorting methods.
	DESCENDING : uint = 2
	  Specifies descending sorting for the Array class sorting methods.
	NUMERIC : uint = 16
	  Specifies numeric (instead of character-string) sorting for the Array class sorting methods.
	RETURNINDEXEDARRAY : uint = 8
	  Specifies that a sort returns an array that consists of array indices.
	UNIQUESORT : uint = 4
	  Specifies the unique sorting requirement for the Array class sorting methods.
	]]
	--tooltip_mc.list.TOP_SPACING = 0
	--tooltip_mc.list.m_SortOnFieldName = "label_txt"
	--tooltip_mc.list.m_SortOnOptions = 1
	--print(string.format("m_SortOnFieldName(%s) m_SortOnOptions(%s)", tooltip_mc.list.m_SortOnFieldName, tooltip_mc.list.m_SortOnOptions))
	--tooltip_mc.repositionElements()
end

local function FormatTagTooltip(ui, tooltip_mc, ...)
	if #tooltip_mc.list.content_array > 0 then
		for i=0,#tooltip_mc.list.content_array,1 do
			local group = tooltip_mc.list.content_array[i]
			if group ~= nil then
				if group.groupID == 13 and group.list ~= nil then
					FormatTagElements(tooltip_mc, group, ...)
				end
			end
		end
	end
end

local function Init()
	Game.Tooltip.RegisterListener("Item", nil, OnItemTooltip)
	Game.Tooltip.RegisterListener("Status", "LLENEMY_UPGRADE_INFO", OnUpgradeInfoTooltip)
	Game.Tooltip.RegisterListener("Status", "LLENEMY_INFUSION_INFO", OnInfusionInfoTooltip)
	--LeaderLib.UI.RegisterListener("OnTooltipPositioned", FormatTagTooltip)
end
return {
	Init = Init
}