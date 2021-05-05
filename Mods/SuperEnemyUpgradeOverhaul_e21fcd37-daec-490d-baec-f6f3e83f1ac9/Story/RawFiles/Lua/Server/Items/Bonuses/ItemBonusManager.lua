if ItemBonusManager == nil then
	ItemBonusManager = {}
end

---@type ItemBonus
local ItemBonus = Ext.Require("Server/Items/Bonuses/ItemBonus.lua")
ItemBonusManager.ItemBonusClass = ItemBonus

---@type table<string, ItemBonus>
ItemBonusManager.AllItemBonuses = {}

ItemBonusManager.EventsListeners = {}
---@type table<string,ItemBonus[]>
ItemBonusManager.EventItemBonuses = {}

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

---@param event string The osiris event to listen for.
---@param itemBonus ItemBonus
function ItemBonusManager.RegisterToOsirisEvent(event, itemBonus)
	if ItemBonusManager.EventsListeners[event] == nil then
		local arity = Data.OsirisEvents[event]
		if arity then
			ItemBonusManager.EventsListeners[event] = function(...)
				ItemBonusManager.OnEvent(event, ...)
			end
			Ext.RegisterOsirisListener(event, arity, "after", ItemBonusManager.EventsListeners[event])
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
	if ItemBonusManager.EventsListeners[event] == nil then
		ItemBonusManager.EventsListeners[event] = function(...)
			ItemBonusManager.OnEvent(event, ...)
		end
		LeaderLib.RegisterListener(event, ItemBonusManager.EventsListeners[event], extraParam)
	end
	if ItemBonusManager.EventItemBonuses[event] == nil then
		ItemBonusManager.EventItemBonuses[event] = {}
	end
	table.insert(ItemBonusManager.EventItemBonuses[event], itemBonus)
end

---@param event string
---@param canApplyCallback ItemBonusConditionCheckCallback
---@param actionCallback ItemBonusActionCallback
---@param params table<string,any>
---@return ItemBonus
function ItemBonusManager.CreateBonus(event, canApplyCallback, actionCallback, params)
	return ItemBonus:Create(event, canApplyCallback, actionCallback, params)
end