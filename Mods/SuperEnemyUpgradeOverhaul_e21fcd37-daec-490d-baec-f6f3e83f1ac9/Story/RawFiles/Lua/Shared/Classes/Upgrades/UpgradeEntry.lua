---A wrapper around a table of boosts, to be used with NRD_ItemSetPermanentBoost, or through applied tags (TagBoost).
---@class UpgradeEntry
local UpgradeEntry = {
	Type = "UpgradeEntry",
	UpgradeType = "Status",
	Value = "",
	Duration = -1.0,
	FixedDuration = false,
	Frequency = 1,
	StartRange = 0,
	EndRange = 0,
	DropCount = -1,
	DefaultDropCount = 4,
	OnApplied = nil,
	HardmodeOnly = false,
	CP = 1
}
UpgradeEntry.__index = UpgradeEntry

---@param value string
---@param frequency integer
---@param cp integer
---@param upgradeType string
---@return UpgradeEntry
function UpgradeEntry:Create(value, frequency, cp, params)
    local this =
    {
		Value = value,
		UpgradeType = "Status"
	}
	if type(frequency) == "table" then
		params = frequency
	elseif type(cp) == "table" then
		params = cp
	else
		this.Frequency = frequency or 1
		this.CP = cp or 1
	end
	setmetatable(this, self)
	if params ~= nil then
		for k,v in pairs(params) do
			this[k] = v
			if k == "DropCount" then
				this.DefaultDropCount = v
			elseif k == "DefaultDropCount" then
				this.DropCount = v
			end
		end
	end
	if this.DropCount == -1 then
		this.DropCount = this.DefaultDropCount or Vars.DefaultDropCount
	end
    return this
end

---@param target string
---@return UpgradeEntry
function UpgradeEntry:Apply(target)
	if self.UpgradeType == "Status" then
		if UpgradeSystem.ApplyStatus(target, self) then
			self.DropCount = self.DropCount - 1
		end
	end
	if self.OnApplied ~= nil then
		if type(self.OnApplied) == "table" then
			local success = false
			for i,callback in pairs(self.OnApplied) do
				if pcall(callback, target, self) then
					success = true
				end
			end
			if success then
				self.DropCount = self.DropCount - 1
			end
		elseif type(self.OnApplied) == "function" then
			local b,err = xpcall(self.OnApplied, debug.traceback, target, self)
			if not b then
				Ext.PrintError("[EUO] Error invoking OnApplied for:", self.Value)
				Ext.PrintError(err)
			else
				self.DropCount = self.DropCount - 1
			end
		end
	end
end

---@type UpgradeEntry
Classes.UpgradeEntry = UpgradeEntry