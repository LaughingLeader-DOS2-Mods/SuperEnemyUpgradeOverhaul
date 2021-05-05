if ItemBonusManager == nil then
	ItemBonusManager = {}
end

---@type ItemBonus
local ItemBonus = Ext.Require("Server/Items/Bonuses/ItemBonus.lua")
ItemBonusManager.ItemBonusClass = ItemBonus

---@type table<string, ItemBonus>
ItemBonusManager.AllItemBonuses = {}
ItemBonusManager.EventListeners = {}
ItemBonusManager.SkillListeners = {}
---@type table<string,ItemBonus[]>
ItemBonusManager.EventItemBonuses = {}
---@type table<string,ItemBonus[]>
ItemBonusManager.SkillItemBonuses = {}

function ItemBonusManager.OnEvent(event, ...)
	local bonuses = ItemBonusManager.EventItemBonuses[event]
	if bonuses then
		local length = #bonuses
		if length > 0 then
			for i=1,length do
				local bonus = bonuses[i]
				if bonus:CanApply(event, ...) then
					bonus:Apply(event, ...)
				end
			end
		end
	end
end
function ItemBonusManager.OnSkill(skill, ...)
	local bonuses = ItemBonusManager.SkillItemBonuses[skill]
	if bonuses then
		local length = #bonuses
		if length > 0 then
			for i=1,length do
				local bonus = bonuses[i]
				if bonus:CanApply(...) then
					bonus:Apply(...)
				end
			end
		end
	end
end

---@param event string The osiris event to listen for.
---@param itemBonus ItemBonus
function ItemBonusManager.RegisterToOsirisEvent(event, itemBonus)
	if ItemBonusManager.EventListeners[event] == nil then
		local arity = Data.OsirisEvents[event]
		if arity then
			ItemBonusManager.EventListeners[event] = function(...)
				ItemBonusManager.OnEvent(event, ...)
			end
			Ext.RegisterOsirisListener(event, arity, "after", ItemBonusManager.EventListeners[event])
		end
	end
	if ItemBonusManager.EventItemBonuses[event] == nil then
		ItemBonusManager.EventItemBonuses[event] = {}
	end
	table.insert(ItemBonusManager.EventItemBonuses[event], itemBonus)
end

---@param event string The LeaderLib event to listen for.
---@param itemBonus ItemBonus
function ItemBonusManager.RegisterToLeaderLibEvent(event, itemBonus, extraParam)
	if ItemBonusManager.EventListeners[event] == nil then
		ItemBonusManager.EventListeners[event] = function(...)
			ItemBonusManager.OnEvent(event, ...)
		end
		LeaderLib.RegisterListener(event, ItemBonusManager.EventListeners[event], extraParam)
	end
	if ItemBonusManager.EventItemBonuses[event] == nil then
		ItemBonusManager.EventItemBonuses[event] = {}
	end
	table.insert(ItemBonusManager.EventItemBonuses[event], itemBonus)
end

---@param skill string|string[]
---@param itemBonus ItemBonus
function ItemBonusManager.RegisterToSkillListener(skill, itemBonus)
	if type(skill) == "table" then
		for i,v in pairs(skill) do
			ItemBonusManager.RegisterToSkillListener(v, itemBonus)
		end
	else
		if ItemBonusManager.SkillListeners[skill] == nil then
			ItemBonusManager.SkillListeners[skill] = function(usedSkill, ...)
				ItemBonusManager.OnSkill(usedSkill, ...)
			end
			LeaderLib.RegisterSkillListener(skill, ItemBonusManager.SkillListeners[skill])
		end
		if ItemBonusManager.SkillItemBonuses[skill] == nil then
			ItemBonusManager.SkillItemBonuses[skill] = {}
		end
		table.insert(ItemBonusManager.SkillItemBonuses[skill], itemBonus)
	end
end

---@param event string
---@param canApplyCallback ItemBonusConditionCheckCallback
---@param actionCallback ItemBonusActionCallback
---@param params table<string,any>
---@return ItemBonus
function ItemBonusManager.CreateEventBonus(event, canApplyCallback, actionCallback, params)
	local bonus = ItemBonus:Create(canApplyCallback, actionCallback, params)
	if type(event) == "table" then
		for i,v in pairs(event) do
			if LeaderLib.Listeners[v] then
				ItemBonusManager.RegisterToLeaderLibEvent(v, bonus)
			elseif Data.OsirisEvents[v] then
				ItemBonusManager.RegisterToOsirisEvent(v, bonus)
			else
				Ext.PrintError(string.format("[SEUO:ItemBonus:Create] Event %s does not exist.", v))
			end
		end
	elseif type(event) == "string" then
		if LeaderLib.Listeners[event] then
			ItemBonusManager.RegisterToLeaderLibEvent(event, bonus)
		elseif Data.OsirisEvents[event] then
			ItemBonusManager.RegisterToOsirisEvent(event, bonus)
		else
			Ext.PrintError(string.format("[SEUO:ItemBonus:Create] Event %s does not exist.", event))
		end
	end
	return bonus
end

---@param skill string|string[]
---@param canApplyCallback ItemBonusConditionCheckCallback
---@param actionCallback ItemBonusActionCallback
---@param params table<string,any>
---@return ItemBonus
function ItemBonusManager.CreateSkillBonus(skill, canApplyCallback, actionCallback, params)
	local bonus = ItemBonus:Create(canApplyCallback, actionCallback, params)
	ItemBonusManager.RegisterToSkillListener(skill, bonus)
	return bonus
end