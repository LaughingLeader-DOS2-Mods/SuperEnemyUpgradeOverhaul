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
	MaxRoll = 999,
	OnApplied = nil,
	DisabledFlag = "",
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
			if v.EndRange > self.MaxRoll then
				self.MaxRoll = v.EndRange
			end
		end
	else
		self.Upgrades[#self.Upgrades+1] = upgrades
		if upgrades.EndRange > self.MaxRoll then
			self.MaxRoll = upgrades.EndRange
		end
	end
end

---@param upgrades UpgradeEntry[]
function UpgradeSubGroup:SetRanges(upgrades)
	local finalTable = {}
	local rangeStart = 1
	local rangeEnd = 1
	for i=1,#upgrades do
		local entry = upgrades[i]
		if entry.Chance > 0 and entry.DropCount > 0 then
			entry.StartRange = rangeStart
			entry.EndRange = rangeStart + entry.Chance
			rangeStart = entry.EndRange + 1
			rangeEnd = entry.EndRange
			finalTable[#finalTable+1] = entry
		end	
	end
	self.MaxRoll = rangeEnd
	return finalTable
end

function UpgradeSubGroup:BuildDropList()
	local upgrades = {}
	for i=1,#self.Upgrades do
		local entry = self.Upgrades[i]
		if entry.DropCount > 0 then
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
	upgrades = self:SetRanges(Common.ShuffleTable(upgrades))
	return upgrades
end

---@param target string
---@return UpgradeSubGroup
function UpgradeSubGroup:Apply(target)
	if self.DisabledFlag == "" or GlobalGetFlag(self.DisabledFlag) == 0 then
		local roll = Ext.Random(0,self.MaxRoll)
		if roll > 0 then
			local successes = 0
			local upgrades = self:BuildDropList()
			for i,v in pairs(upgrades) do
				if v.StartRange >= roll and v.EndRange <= roll then
					Ext.Print(string.format("[EUO] Roll success (%i/%i)! SubGroup(%s:%s) Range(%i-%i)", roll, self.MaxRoll, self.ID, v.Value, v.StartRange, v.EndRange))
					v:Apply(target)
					successes = successes + 1
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
			end
		else
			UpgradeSystem.OnRollFailed(target, self.ID)
		end
	end
end

---@type UpgradeSubGroup
Classes.UpgradeSubGroup = UpgradeSubGroup