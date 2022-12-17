---@class TranslatedString
local ts = Classes.TranslatedString

local counterParamText = ts:Create("h662390f7gfd9eg4a56g95e5g658283cc548a", "<font color='#D416FF'>[1]%</font>")

local function StatDescription_Counter(status, target, param, statusSource)
	--local initiative = NRD_CharacterGetComputedStat(character, "Initiative", 0)
	--Ext.Utils.Print("Char: " .. tostring(character) .. " | " .. Common.Dump(character))
	local initiative = target.Initiative
	local counterMax = (Ext.ExtraData.LLENEMY_Counter_MaxChance or 75)
	--local percent = (initiative - COUNTER_MIN) / (COUNTER_MAX - COUNTER_MIN)
	local chance = (math.log(1 + initiative) / math.log(1 + counterMax))
	--Ext.Utils.Print("Chance: " .. tostring(chance))
	--local chance = (math.log(initiative/COUNTER_MIN) / math.log(COUNTER_MAX/COUNTER_MIN)) * COUNTER_MAX
	return string.gsub(counterParamText.Value, "%[1%]", tostring(math.floor(chance * counterMax)))
end

StatusDescriptionParams["LLENEMY_Talent_CounterChance"] = StatDescription_Counter

Ext.Events.StatusGetDescriptionParam:Subscribe(function (e)
	local func = StatusDescriptionParams[e.Params[1]]
	if func ~= nil then
		if GameHelpers.Ext.ObjectIsStatCharacter(e.Owner) then
			local b,result = xpcall(func, debug.traceback, e.Status, e.Owner, e.Params[1], e.StatusSource)
			if not b then
				Ext.Utils.PrintError(result)
			elseif result ~= nil then
				e.Description = result
			end
		else
			e.Description = ""
		end
	end
end)