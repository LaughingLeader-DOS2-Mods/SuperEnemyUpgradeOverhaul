---A wrapper around a table of boosts, to be used with NRD_ItemSetPermanentBoost, or through applied tags (TagBoost).
---@class UpgradeSubGroup
local UpgradeSubGroup = {
	Type = "UpgradeSubGroup",
	ID = "",
	---@type UpgradeEntry[]
	Upgrades = {},
	Chance = 100,
	StartRange = 0,
	EndRange = 0,
	OnApplied = nil,
}
UpgradeSubGroup.__index = UpgradeSubGroup

---@param value string
---@param params table
---@return UpgradeSubGroup
function UpgradeSubGroup:Create(id, params)
    local this =
    {
		ID = id,
		Upgrades = {},
	}
	setmetatable(this, self)
	if params ~= nil then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
    return this
end

---@param upgrades UpgradeEntry|UpgradeEntry[]
function UpgradeSubGroup:Add(upgrades)
	if type(upgrades) == "table" then
		for i,v in pairs(upgrades) do
			self.Upgrades[#self.Upgrades+1] = v
		end
	else
		self.Upgrades[#self.Upgrades+1] = upgrades
	end
end

---@param target string
---@return UpgradeSubGroup
function UpgradeSubGroup:Apply(target)
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

---@type UpgradeSubGroup
Classes.UpgradeSubGroup = UpgradeSubGroup