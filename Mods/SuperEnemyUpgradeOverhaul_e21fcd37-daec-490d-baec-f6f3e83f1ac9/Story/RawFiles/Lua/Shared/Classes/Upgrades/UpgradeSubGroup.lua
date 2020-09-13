---A wrapper around a table of boosts, to be used with NRD_ItemSetPermanentBoost, or through applied tags (TagBoost).
---@class UpgradeSubGroup
local UpgradeSubGroup = {
	Type = "UpgradeSubGroup",
	ID = "",
	---@type UpgradeGroup
	Parent = nil,
	---@type UpgradeEntry[]
	Upgrades = {},
	OnApplied = nil,
	DisabledFlag = "",
	Frequency = 1,
	StartRange = 0,
	EndRange = 0,
	CP = 1,
	---@type fun(target:EsvCharacter, entry:UpgradeSubGroup):boolean
	CanApply = nil
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
			v.Parent = self
		end
	else
		self.Upgrades[#self.Upgrades+1] = upgrades
		upgrades.Parent = self
	end
end

---@param upgrade UpgradeEntry
---@return boolean
local function CanAddUpgradeToList(entry)
	if entry.DropCount <= 0 then
		return false
	end
	if entry.HardmodeOnly and GlobalGetFlag("LLENEMY_HardModeEnabled") == 0 then
		return false
	end
	if entry.ModRequirement ~= nil and not Ext.IsModLoaded(entry.ModRequirement) then
		return false
	end
	return true
end

---@return UpgradeEntry[]
function UpgradeSubGroup:BuildDropList()
	local upgrades = {}
	for i=1,#self.Upgrades do
		local entry = self.Upgrades[i]
		if CanAddUpgradeToList(entry) then
			upgrades[#upgrades+1] = entry
		end
	end
	if #upgrades == 0 and #self.Upgrades > 0 then
		for i=1,#self.Upgrades do
			local entry = self.Upgrades[i]
			entry.DropCount = entry.DefaultDropCount
			if CanAddUpgradeToList(entry) then
				upgrades[#upgrades+1] = entry
			end
		end
	end
	upgrades = UpgradeSystem.SetRanges(Common.ShuffleTable(upgrades))
	return upgrades
end

function UpgradeSubGroup:CanApplyUpgradeToTarget(target, upgrade)
	if self.CanApply ~= nil then
		return self.CanApply(target, upgrade, self)
	end
	return true
end

---@param target EsvCharacter
---@param applyImmediately boolean
---@return boolean
function UpgradeSubGroup:Apply(target, applyImmediately)
	if self.DisabledFlag == "" or GlobalGetFlag(self.DisabledFlag) == 0 then
		local roll = Ext.Random(0, Vars.UPGRADE_MAX_ROLL)
		if roll > 0 then
			local successes = 0
			local upgrades = self:BuildDropList()
			for i,v in pairs(upgrades) do
				if v.StartRange >= roll and v.EndRange <= roll and self:CanApplyUpgradeToTarget(target, v) then
					Ext.Print(string.format("[EUO] Roll success (%i/%i)! SubGroup(%s:%s) Range(%i-%i)", roll, Vars.UPGRADE_MAX_ROLL, self.ID, v.Value, v.StartRange, v.EndRange))
					if v:Apply(target, applyImmediately) then
						successes = successes + 1
						UpgradeSystem.IncreaseChallengePoints(target.MyGuid, self.CP)
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