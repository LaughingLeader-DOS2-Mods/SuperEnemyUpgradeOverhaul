---A wrapper around a table of boosts, to be used with NRD_ItemSetPermanentBoost, or through applied tags (TagBoost).
---@class UpgradeGroup
local UpgradeGroup = {
	Type = "UpgradeGroup",
	ID = "",
	---@type UpgradeSubGroup[]
	SubGroups = {},
	DisabledFlag = "",
	---@type fun(target:EsvCharacter, entry:UpgradeGroup):boolean
	CanApply = nil
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
		DisabledFlag = ""
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
			v.Parent = self
		end
	else
		self.SubGroups[#self.SubGroups+1] = subgroups
		subgroups.Parent = self
	end
end

function UpgradeGroup:CanApplySubGroupToTarget(target, subGroup)
	if self.CanApply ~= nil then
		return self.CanApply(target, subGroup, self)
	end
	return true
end

---@param target EsvCharacter
---@return boolean
function UpgradeGroup:Apply(target)
	if self.DisabledFlag == "" or GlobalGetFlag(self.DisabledFlag) == 0 then
		local roll = Ext.Random(0, Vars.UPGRADE_MAX_ROLL)
		if roll > 0 then
			local successes = 0
			for i,v in pairs(self.SubGroups) do
				if v.StartRange >= roll and v.EndRange <= roll and self:CanApplySubGroupToTarget(target, v) then
					if v:Apply(target) then
						Ext.Print(string.format("[EUO] Roll success (%i/%i)! Group(%s:%s) Range(%i-%i)", roll, Vars.UPGRADE_MAX_ROLL, self.ID, v.ID, v.StartRange, v.EndRange))
						successes = successes + 1
					end
				end
			end
			if successes > 0 then
				Ext.Print(string.format("[EUO] Applied (%i) subgroups for group(%s) to target(%s)", successes, self.ID, target))
				return true
			end
		else
			UpgradeSystem.OnRollFailed(target, self.ID)
		end
	end
	return false
end

---@type UpgradeGroup
Classes.UpgradeGroup = UpgradeGroup