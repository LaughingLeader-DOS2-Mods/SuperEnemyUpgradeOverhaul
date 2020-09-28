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
	CanApply = nil,
	ModRequirement = nil,
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
	if GlobalGetFlag("LLENEMY_PureRNGMode") == 1 then
		return true
	end
	if entry.DropCount <= 0 then
		return false
	end
	if entry.HardmodeOnly and GlobalGetFlag("LLENEMY_HardmodeEnabled") == 0 then
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

function UpgradeSubGroup:TryApplyUpgrades(target, applyImmediately, hardmodeOnly, roll, totalAttempts, successes)
	local upgrades = self:BuildDropList()
	if upgrades ~= nil then
		local total = #upgrades
		local rollAgain = false
		for i,v in pairs(upgrades) do
			--print(string.format("[%s] Start(%s)/End(%s)/(%s)", self.ID, self.StartRange, self.EndRange, roll))
			if roll >= v.StartRange and roll <= v.EndRange and self:CanApplyUpgradeToTarget(target, v) then
				if v.Unique and UpgradeSystem.HasUpgrade(target.MyGuid, v.ID) then
					if total > 2 and totalAttempts < 3 then
						roll = Ext.Random(1, Vars.UPGRADE_MAX_ROLL)
						totalAttempts = totalAttempts + 1
						v.DropCount = math.max(0, v.DropCount - 1)
						--print(string.format("DUPLICATE!|(%s) Upgrade(%s) Roll(%i) Rerolls(%i) DropCount(%i)", target.DisplayName, v.ID, roll, totalAttempts, v.DropCount))
						rollAgain = true
						break
					end
				else
					if v:Apply(target, applyImmediately, hardmodeOnly) then
						v.DropCount = math.max(0, v.DropCount - 1)
						if not hardmodeOnly or (hardmodeOnly and Settings.Global:FlagEquals("LLENEMY_HardmodeEnabled", true)) then
							UpgradeSystem.IncreaseChallengePoints(target.MyGuid, v.CP)
						end
						successes = successes + 1
					end
				end
			end
		end
		if rollAgain then
			return self:TryApplyUpgrades(target, applyImmediately, hardmodeOnly, Ext.Random(1, Vars.UPGRADE_MAX_ROLL), totalAttempts, successes)
		end
	else
		Ext.PrintError("[SEUO] Failed to build droplist", upgrades)
	end
	return successes
end

---@param target EsvCharacter
---@param applyImmediately boolean
---@param hardmodeOnly boolean
---@return boolean
function UpgradeSubGroup:Apply(target, applyImmediately, hardmodeOnly)
	if self.DisabledFlag == "" or GlobalGetFlag(self.DisabledFlag) == 0 then
		local reRolls = 0
		local roll = Ext.Random(0, Vars.UPGRADE_MAX_ROLL)
		if roll > 0 then
			local successes = self:TryApplyUpgrades(target, applyImmediately, hardmodeOnly, roll, 0, 0)
			if successes > 0 then
				UpgradeSystem.IncreaseChallengePoints(target.MyGuid, self.CP)
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
			return successes > 0
		else
			UpgradeSystem.OnRollFailed(target, self.ID)
		end
	end
	return false
end

---@type UpgradeSubGroup
Classes.UpgradeSubGroup = UpgradeSubGroup