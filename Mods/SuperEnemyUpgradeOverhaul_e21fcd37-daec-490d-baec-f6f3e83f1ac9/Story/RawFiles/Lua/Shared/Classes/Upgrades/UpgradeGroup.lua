---A wrapper around a table of boosts, to be used with NRD_ItemSetPermanentBoost, or through applied tags (TagBoost).
---@class UpgradeGroup
local UpgradeGroup = {
	Type = "UpgradeGroup",
	ID = "",
	---@type UpgradeSubGroup[]
	SubGroups = {},
	DisabledFlag = "",
	MaxRoll = 999,
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
		DisabledFlag = "",
		MaxRoll = 999,
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
			if v.EndRange > self.MaxRoll then
				self.MaxRoll = v.EndRange
			end
		end
	else
		self.SubGroups[#self.SubGroups+1] = subgroups
		if subgroups.EndRange > self.MaxRoll then
			self.MaxRoll = subgroups.EndRange
		end
	end
end

---@param target string
---@return UpgradeGroup
function UpgradeGroup:Apply(target)
	if self.DisabledFlag == "" or GlobalGetFlag(self.DisabledFlag) == 0 then
		local roll = Ext.Random(0,self.MaxRoll)
		if roll > 0 then
			for i,v in pairs(self.SubGroups) do
				if v.StartRange >= roll and v.EndRange <= roll then
					Ext.Print(string.format("[EUO] Roll success (%i/%i)! Group(%s:%s) Range(%i-%i)", roll, self.MaxRoll, self.ID, v.ID, v.StartRange, v.EndRange))
					v:Apply(target)
				end
			end
		else
			UpgradeSystem.OnRollFailed(target, self.ID)
		end
	end
end

---@type UpgradeGroup
Classes.UpgradeGroup = UpgradeGroup