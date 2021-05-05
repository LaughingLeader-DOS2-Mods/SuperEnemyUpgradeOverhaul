---@class ItemBonus
local ItemBonus = {
	Type = "ItemBonus",
	---@type ItemBonusConditionCheckCallback
	CanApplyCallback = nil,
	---@type ItemBonusActionCallback
	ApplyCallback = nil,
	Event = "",
}
ItemBonus.__index = ItemBonus

---@alias ItemBonusConditionCheckCallback fun(self:ItemBonus, event:string, ...):boolean
---@alias ItemBonusActionCallback fun(self:ItemBonus, event:string, ...):void

---@param event string
---@param canApplyCallback ItemBonusConditionCheckCallback
---@param actionCallback ItemBonusActionCallback
---@param params table<string,any>
---@return ItemBonus
function ItemBonus:Create(event, canApplyCallback, actionCallback, params)
	local this =
	{
		CanApplyCallback = canApplyCallback,
		ApplyCallback = actionCallback,
		Event = event,
	}
	if params then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, self)
	if type(event) == "table" then
		for i,v in pairs(event) do
			if LeaderLib.Listeners[v] then
				ItemBonusManager.RegisterToLeaderLibEvent(v, this)
			elseif Data.OsirisEvents[v] then
				ItemBonusManager.RegisterToOsirisEvent(v, this)
			else
				Ext.PrintError(string.format("[SEUO:ItemBonus:Create] Event %s does not exist.", v))
			end
		end
	elseif type(event) == "string" then
		if LeaderLib.Listeners[event] then
			ItemBonusManager.RegisterToLeaderLibEvent(event, this)
		elseif Data.OsirisEvents[event] then
			ItemBonusManager.RegisterToOsirisEvent(event, this)
		else
			Ext.PrintError(string.format("[SEUO:ItemBonus:Create] Event %s does not exist.", event))
		end
	end
	return this
end

function ItemBonus:CanApply(event, ...)
	if self.CanApplyCallback then
		local b,canApply = xpcall(self.CanApplyCallback, debug.traceback, self, event, ...)
		if b then
			return canApply
		else
			Ext.PrintError(canApply)
		end
		return false
	end
	return true
end

function ItemBonus:Apply(event, ...)
	if self.ApplyCallback then
		local b,err = xpcall(self.ApplyCallback, debug.traceback, self, event, ...)
		if not b then
			Ext.PrintError(err)
		end
	end
end