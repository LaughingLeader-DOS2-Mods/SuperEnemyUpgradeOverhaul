if ItemBonusManager == nil then
	ItemBonusManager = {}
end

---@type ItemBonus
local ItemBonus = Ext.Require("Server/Items/Bonuses/ItemBonus.lua")
ItemBonusManager.ItemBonusClass = ItemBonus

ItemBonusManager.OsirisEventsListeners = {}
---@type table<string,ItemBonus[]>
ItemBonusManager.OsirisItemBonuses = {}

function ItemBonusManager.InvokeOsirisListeners(event, ...)
	local bonuses = ItemBonusManager.OsirisItemBonuses[event]
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
	if ItemBonusManager.OsirisEventsListeners[event] == nil then
		local arity = Data.OsirisEvents[event]
		if arity then
			ItemBonusManager.OsirisEventsListeners[event] = function(...)
				ItemBonusManager.InvokeOsirisListeners(event, ...)
			end
			Ext.RegisterOsirisListener(event, arity, "after", ItemBonusManager.OsirisEventsListeners[event])
		end
	end
	if ItemBonusManager.OsirisItemBonuses[event] == nil then
		ItemBonusManager.OsirisItemBonuses[event] = {}
	end
	table.insert(ItemBonusManager.OsirisItemBonuses[event], itemBonus)
end

---@param event string
---@param canApplyCallback ItemBonusConditionCheckCallback
---@param actionCallback ItemBonusActionCallback
---@param params table<string,any>
---@return ItemBonus
function ItemBonusManager.CreateBonus(event, canApplyCallback, actionCallback, params)
	return ItemBonus:Create(event, canApplyCallback, actionCallback, params)
end