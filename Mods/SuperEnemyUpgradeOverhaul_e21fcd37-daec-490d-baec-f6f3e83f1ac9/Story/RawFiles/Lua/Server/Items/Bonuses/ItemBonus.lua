---@class ItemBonus
local ItemBonus = {
	Type = "ItemBonus",
	---@type ItemBonusConditionCheckCallback
	CanApplyCallback = nil,
	---@type ItemBonusActionCallback
	ApplyCallback = nil
}
ItemBonus.__index = ItemBonus

---@alias ItemBonusConditionCheckCallback fun(self:ItemBonus, ...):boolean
---@alias ItemBonusActionCallback fun(self:ItemBonus, ...):void

---@param event string
---@param canApplyCallback ItemBonusConditionCheckCallback
---@param actionCallback ItemBonusActionCallback
---@param params table<string,any>
---@return ItemBonus
function ItemBonus:Create(event, canApplyCallback, actionCallback, params)
	local this =
	{
		CanApplyCallback = canApplyCallback,
		ApplyCallback = actionCallback
	}
	if params then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, self)
	ItemBonusManager.RegisterToOsirisEvent(event, this)
	return this
end

function ItemBonus:CanApply(...)
	if self.CanApplyCallback then
		local b,canApply = xpcall(self.CanApplyCallback, debug.traceback, self, ...)
		if b then
			return canApply
		else
			Ext.PrintError(canApply)
		end
		return false
	end
	return true
end

function ItemBonus:Apply(...)
	if self.ApplyCallback then
		local b,err = xpcall(self.ApplyCallback, debug.traceback, self, ...)
		if not b then
			Ext.PrintError(err)
		end
	end
end