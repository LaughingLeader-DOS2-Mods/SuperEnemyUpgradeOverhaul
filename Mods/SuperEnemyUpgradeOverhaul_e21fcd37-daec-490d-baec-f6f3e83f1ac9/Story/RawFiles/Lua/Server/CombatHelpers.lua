if not Combat then
	Combat = {}
end

CLEARTYPE = {
	Flag = false,
	Tag = true
}

if not Combat.ClearFlagOrTag then
	---Tags or flags to clear when an object leaves combat.
	---True for tag, false for flag.
	---@type table<string,boolean>
	Combat.ClearFlagOrTag = {}
end

function Combat.WaitForEnd(id, uuid)
	if not PersistentVars.WaitForCombatEnd[id] then
		PersistentVars.WaitForCombatEnd[id] = {}
	end
	PersistentVars.WaitForCombatEnd[id][uuid] = true
end

function Combat.OnEnded(id)
	local waitForCombatEndObjects = PersistentVars.WaitForCombatEnd[id]
	if waitForCombatEndObjects then
		for name,t in pairs(Combat.ClearFlagOrTag) do
			for uuid,b2 in pairs(waitForCombatEndObjects) do
				if b2 then
					if t then
						ClearTag(uuid, name)
					else
						ObjectClearFlag(uuid, name, 0)
					end
				end
			end
		end
		PersistentVars.WaitForCombatEnd[id] = nil
	end
end

function Combat.CheckSaved()
	for id,data in pairs(PersistentVars.WaitForCombatEnd) do
		local db = Osi.DB_LeaderLib_Combat_ActiveCombat[id]
		if not db or #db == 0 then
			Combat.OnEnded(id)
		end
	end
end