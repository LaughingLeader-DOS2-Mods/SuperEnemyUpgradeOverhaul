---A wrapper around a table of boosts, to be used with NRD_ItemSetPermanentBoost, or through applied tags (TagBoost).
---@class UpgradeGroup
local UpgradeGroup = {
	Type = "UpgradeGroup",
	ID = "",
	---@type UpgradeSubGroup[]
	SubGroups = {},
	Enabled = true,
}
UpgradeGroup.__index = UpgradeGroup

---@param id string
---@param params table
---@return UpgradeGroup
function UpgradeGroup:Create(id, params)
    local this =
    {
		ID = id,
		SubGroups = {},
	}
	setmetatable(this, self)
	if params ~= nil then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
    return this
end

---@param subgroups UpgradeEntry|UpgradeEntry[]
function UpgradeGroup:Add(subgroups)
	if type(subgroups) == "table" then
		for i,v in pairs(subgroups) do
			self.SubGroups[#self.SubGroups+1] = v
		end
	else
		self.SubGroups[#self.SubGroups+1] = subgroups
	end
end

---@param target string
---@return UpgradeGroup
function UpgradeGroup:Apply(target)
	if self.OnApplied ~= nil then
		if type(self.OnApplied) == "table" then
			for i,callback in pairs(self.OnApplied) do
				pcall(callback, target, self)
			end
		elseif type(self.OnApplied) == "function" then
			local b,err = xpcall(self.OnApplied, debug.traceback, target, self)
			if not b then
				Ext.PrintError("[EUO] Error invoking OnApplied for:", self.Value)
				Ext.PrintError(err)
			end
		end
	end
end

---@type UpgradeGroup
Classes.UpgradeGroup = UpgradeGroup