---A wrapper around a table of boosts, to be used with NRD_ItemSetPermanentBoost, or through applied tags (TagBoost).
---@class UpgradeEntry
local UpgradeEntry = {
	Type = "UpgradeEntry",
	UpgradeType = "Status",
	---@type UpgradeSubGroup
	Parent = nil,
	ID = "",
	Duration = -1.0,
	FixedDuration = false,
	Frequency = 1,
	StartRange = 0,
	EndRange = 0,
	DropCount = -1,
	DefaultDropCount = -1,
	OnApplied = nil,
	HardmodeOnly = false,
	ModRequirement = nil,
	CP = 1,
	---@type fun(target:EsvCharacter, entry:UpgradeEntry):boolean
	CanApply = nil,
	Unique = true,
}
UpgradeEntry.__index = UpgradeEntry

---@param id string
---@param frequency integer
---@param cp integer
---@param upgradeType string
---@return UpgradeEntry
function UpgradeEntry:Create(id, frequency, cp, params)
    local this =
    {
		ID = id,
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
		local s,err = xpcall(function()
		for k,v in pairs(params) do
			this[k] = v
			if k == "DropCount" then
				this.DefaultDropCount = v
			elseif k == "DefaultDropCount" then
				this.DropCount = v
			end
		end
		end, debug.traceback)
		if not s then print(id, err) end
	end

	if this.DefaultDropCount == -1 then
		this.DefaultDropCount = this.Frequency * 10
	end
	
	if this.DropCount == -1 then
		this.DropCount = this.DefaultDropCount or Vars.DefaultDropCount
	end
	if this.UpgradeType == "Status" then
		if this.ModRequirement == nil or Ext.IsModLoaded(this.ModRequirement) then
			this.StatusType = Ext.StatGetAttribute(this.ID, "StatusType") or "CONSUME"
		else
			this.StatusType = "CONSUME"
		end
	end
    return this
end

---@param target EsvCharacter
---@param applyImmediately boolean
---@param hardmodeOnly boolean
---@return boolean
function UpgradeEntry:Apply(target, applyImmediately, hardmodeOnly)
	if self.ID == "None" or self.ID == "" then
		-- "Fail" upgrades
		return true
	end
	if self.CanApply ~= nil then
		if not self.CanApply(target, self) then
			return false
		end
	end

	local applied = false
	if self.UpgradeType == "Status" then
		if UpgradeSystem.ApplyStatus(target, self, applyImmediately, hardmodeOnly) then
			applied = true
		end
	end
	if applied and self.OnApplied ~= nil then
		if type(self.OnApplied) == "table" then
			local success = false
			for i,callback in pairs(self.OnApplied) do
				local b,err = xpcall(callback, debug.traceback, target, self)
				if not b then
					Ext.PrintError("[EUO] Error invoking OnApplied callback for:", self.ID)
					Ext.PrintError(err)
				else
					success = true
				end
			end
		elseif type(self.OnApplied) == "function" then
			local b,err = xpcall(self.OnApplied, debug.traceback, target, self)
			if not b then
				Ext.PrintError("[EUO] Error invoking OnApplied for:", self.ID)
				Ext.PrintError(err)
			end
		end
	end
	return applied
end

---@type UpgradeEntry
Classes.UpgradeEntry = UpgradeEntry