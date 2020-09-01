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