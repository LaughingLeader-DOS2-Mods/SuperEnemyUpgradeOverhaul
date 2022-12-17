---Basically a wrapper around a function to see if a bonus can be applied, and a function to call if it can.
---Requires the ItemBonusManager to register this bonus to the related event or skill.
---@class ItemBonus
local ItemBonus = {
	Type = "ItemBonus",
	---@type ItemBonusConditionCheckCallback
	CanApplyCallback = nil,
	---@type ItemBonusActionCallback
	ApplyCallback = nil,
	---@type fun(self:ItemBonus, char:string, item:string):void
	EquipCallback = nil,
	---@type fun(self:ItemBonus, char:string, item:string):void
	UnEquipCallback = nil
}
ItemBonus.__index = ItemBonus

---@alias ItemBonusConditionCheckCallback fun(self:ItemBonus, event:string, ...):boolean
---@alias ItemBonusActionCallback fun(self:ItemBonus, event:string, ...):void

---@param canApplyCallback ItemBonusConditionCheckCallback
---@param actionCallback ItemBonusActionCallback
---@param params table<string,any>
---@return ItemBonus
function ItemBonus:Create(canApplyCallback, actionCallback, params)
	local this =
	{
		CanApplyCallback = canApplyCallback or nil,
		ApplyCallback = actionCallback or nil,
		EquipCallback = nil,
		UnEquipCallback = nil,
	}
	if params then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, self)
	return this
end

function ItemBonus:CanApply(...)
	if self.CanApplyCallback then
		local b,canApply = xpcall(self.CanApplyCallback, debug.traceback, self, ...)
		if b then
			return canApply
		else
			Ext.Utils.PrintError(canApply)
		end
		return false
	end
	return true
end

function ItemBonus:Apply(...)
	if self.ApplyCallback then
		local b,err = xpcall(self.ApplyCallback, debug.traceback, self, ...)
		if not b then
			Ext.Utils.PrintError(err)
		end
	end
end

function ItemBonus:OnEquipped(char, item)
	if self.EquipCallback then
		local b,err = xpcall(self.EquipCallback, debug.traceback, self, char, item)
		if not b then
			Ext.Utils.PrintError(err)
		end
	end
end

function ItemBonus:OnUnEquipped(char, item)
	if self.UnEquipCallback then
		local b,err = xpcall(self.UnEquipCallback, debug.traceback, self, char, item)
		if not b then
			Ext.Utils.PrintError(err)
		end
	end
end

return ItemBonus