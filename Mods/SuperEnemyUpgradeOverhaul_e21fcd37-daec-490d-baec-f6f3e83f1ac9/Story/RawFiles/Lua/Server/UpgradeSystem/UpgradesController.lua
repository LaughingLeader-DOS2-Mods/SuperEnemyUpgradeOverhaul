UpgradeSystem = {}

function UpgradeSystem.OnRollFailed(target)

end

-- Store CP here before finally applying it to the variable.
local tempChallengePoints = {}

function UpgradeSystem.IncreaseChallengePoints(target, amount)
	if tempChallengePoints[target] == nil then
		tempChallengePoints[target] = 0
	end
	local current = GetVarInteger(target, "LLENEMY_ChallengePoints") or 0
	if current < 0 then
		current = 0
	end
	tempChallengePoints[target] = current + amount
end

function UpgradeSystem.SaveChallengePoints(target)
	local current = tempChallengePoints[target]
	if current ~= nil and current > 0 then
		SetVarInteger(target, "LLENEMY_ChallengePoints", current)
		SetChallengePointsTag(target)
	end
	tempChallengePoints[target] = nil
end

---@param target EsvCharacter
local function FinallyApplyStatus(target, status, duration)
	if status == "BLESSED" and target:HasTag("VOIDWOKEN") then
		ApplyStatus(target.MyGuid, "LLENEMY_VOID_EMPOWERED", duration, 1, target.MyGuid)
	else
		ApplyStatus(target.MyGuid, status, duration, 1, target.MyGuid)
	end
end

---@param target EsvCharacter
---@param entry UpgradeEntry
---@return boolean
function UpgradeSystem.ApplyStatus(target, entry)
	if Settings.Global.Flags.LLENEMY_HardModeEnabled.Enabled then
		if entry.FixedDuration then
			FinallyApplyStatus(target, entry.Value, entry.Duration)
		else
			local min = Settings.Global.Variables.Hardmode_StatusBonusTurnsMin.Value or 0
			local max = Settings.Global.Variables.Hardmode_StatusBonusTurnsMax.Value or 3
			local bonusDuration = entry.Duration + (Ext.Random(min,max) * 6.0)
			if HasActiveStatus(target, entry.Value) == 1 then
				local status = Ext.GetCharacter(target):GetStatus(entry.Value)
				status.CurrentLifeTime = math.max(bonusDuration, status.CurrentLifeTime)
				status.RequestClientSync = true
			else
				FinallyApplyStatus(target, entry.Value, bonusDuration)
			end
		end
	else
		FinallyApplyStatus(target, entry.Value, entry.Duration)
	end
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

---@type table<string, UpgradeGroup>
Upgrades = Ext.Require("Shared/Data/Upgrades/_Init.lua")

local function IgnoreCharacter(uuid)
	if Osi.LLENEMY_Upgrades_QRY_CanAddUpgrades(uuid) == true then
		return false
	end
	return true
end

function UpgradeSystem.RollForUpgrades(uuid)
	if not IgnoreCharacter(uuid) then
		local successes = 0
		local character = Ext.GetCharacter(uuid)
		for id,group in pairs(Upgrades) do
			if group:Apply(character) then
				successes = successes + 1
			end
		end

		if Osi.LLENEMY_QRY_CanAddBonusSkills(uuid) == true then
			UpgradeSystem.AddBonusSkills(character)
		end
		
		if successes > 0 then
			UpgradeSystem.SaveChallengePoints(uuid)
			UpgradeInfo_ApplyInfoStatus(uuid)
		end
	
		Duplication.StartDuplicating(character)
	end
end

function OnDoubleDipApplied(uuid)
	local character = Ext.GetCharacter(uuid)
	local successes = 0
	for id,group in pairs(Upgrades) do
		if group:Apply(character) then
			successes = successes + 1
		end
	end
	if successes > 0 then
		Ext.Print(string.format("[EUO] (Double Dip) Character (%s:%s) gained new upgrades! (%s)", character.DisplayName, uuid, successes))
	end
end

Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", function(object, id)
	local uuid = GetUUID(object)

end)

Ext.RegisterOsirisListener("CombatStarted", 1, "after", function(id)

end)