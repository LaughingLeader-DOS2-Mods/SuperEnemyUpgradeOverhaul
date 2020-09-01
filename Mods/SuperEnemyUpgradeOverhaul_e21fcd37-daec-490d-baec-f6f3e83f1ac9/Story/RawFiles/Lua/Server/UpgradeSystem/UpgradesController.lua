UpgradeSystem = {}

function UpgradeSystem.OnRollFailed(target)

end

---@param target string
---@param entry UpgradeEntry
---@return boolean
function UpgradeSystem.ApplyStatus(target, entry)
	ApplyStatus(target, entry.Value, 1, entry.Duration, target)
	return true
end

---@param target string
---@param entry UpgradeEntry
---@return boolean
function UpgradeSystem.CanApplyUpgrade(target, entry)
	return true
end

---@param tbl table
function UpgradeSystem.SetRanges(tbl)
	local rangeStart = 1
	local maxRoll = Vars.UPGRADE_MAX_ROLL
	local totalFrequency = 0
	for i=1,#tbl do
		local entry = tbl[i]
		if entry.Frequency > 0 then
			totalFrequency = totalFrequency + 1
		end	
	end
	if totalFrequency > 0 then
		for i=1,#tbl do
			local entry = tbl[i]
			if entry.Frequency > 0 then
				entry.StartRange = rangeStart
				entry.EndRange = (entry.Frequency / totalFrequency) * Vars.UPGRADE_MAX_ROLL
				rangeStart = entry.EndRange + 1
			else
				entry.StartRange = -1
				entry.EndRange = -1
			end
		end
	end
end