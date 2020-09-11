---A wrapper around a table of boosts, to be used with NRD_ItemSetPermanentBoost, or through applied tags (TagBoost).
---@class UpgradeSubGroup
local UpgradeSubGroup = {
	Type = "UpgradeSubGroup",
	ID = "",
	---@type UpgradeEntry[]
	Upgrades = {},
	OnApplied = nil,
	DisabledFlag = "",
	Frequency = 1,
	StartRange = 0,
	EndRange = 0,
	CP = 1
}
UpgradeSubGroup.__index = UpgradeSubGroup

---@param value string
---@param frequency integer
---@param cp integer
---@param params table
---@return UpgradeSubGroup
function UpgradeSubGroup:Create(id, frequency, cp, params)
    local this =
    {
		ID = id,
		Upgrades = {},
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

---@return UpgradeEntry[]
function UpgradeSubGroup:BuildDropList()
	local upgrades = {}
	for i=1,#self.Upgrades do
		local entry = self.Upgrades[i]
		if entry.DropCount > 0 and (not entry.HardmodeOnly or GlobalGetFlag("LLENEMY_HardModeEnabled") == 1) then
			upgrades[#upgrades+1] = entry
		end
	end
	if #upgrades == 0 and #self.Upgrades > 0 then
		for i=1,#self.Upgrades do
			local entry = self.Upgrades[i]
			entry.DropCount = entry.DefaultDropCount
			upgrades[#upgrades+1] = entry
		end
	end
	upgrades = UpgradeSystem.SetRanges(Common.ShuffleTable(upgrades))
	return upgrades
end

---@param target string
---@return boolean
function UpgradeSubGroup:Apply(target)
	if self.DisabledFlag == "" or GlobalGetFlag(self.DisabledFlag) == 0 then
		local roll = Ext.Random(0, Vars.UPGRADE_MAX_ROLL)
		if roll > 0 then
			local successes = 0
			local upgrades = self:BuildDropList()
			for i,v in pairs(upgrades) do
				if v.StartRange >= roll and v.EndRange <= roll then
					Ext.Print(string.format("[EUO] Roll success (%i/%i)! SubGroup(%s:%s) Range(%i-%i)", roll, Vars.UPGRADE_MAX_ROLL, self.ID, v.Value, v.StartRange, v.EndRange))
					if v:Apply(target) then
						successes = successes + 1
						UpgradeSystem.IncreaseChallengePoints(target, self.CP)
					end
				end
			end
			if successes > 0 and self.OnApplied ~= nil then
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
				return true
			end
		else
			UpgradeSystem.OnRollFailed(target, self.ID)
		end
	end
	return false
end

---@type UpgradeSubGroup
Classes.UpgradeSubGroup = UpgradeSubGroup