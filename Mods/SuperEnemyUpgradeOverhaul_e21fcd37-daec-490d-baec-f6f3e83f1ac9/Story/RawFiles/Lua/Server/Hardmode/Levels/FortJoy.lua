local Kniles = "1d1c0ba0-a91e-4927-af79-6d8d27e0646b"
local SuperFleshGolem = CharacterData:Create("82a1c335-d5b6-4046-9286-400faf67e08e")

local function Init()

end

local function Enable()
	if SuperFleshGolem:SetOnStage() then
		if not SuperFleshGolem:IsInCombat() and not SuperFleshGolem:IsDead() then
			CharacterAddAttitudeTowardsPlayer(SuperFleshGolem.UUID, Kniles, 100)
			CharacterAddAttitudeTowardsPlayer(Kniles, SuperFleshGolem.UUID, 100)
			SuperFleshGolem:ApplyOrSetStatus("SLEEPING", -1.0, true)
		end
	end
end

local function Disable()
	if not SuperFleshGolem:IsInCombat() and not SuperFleshGolem.IsDead() then
		SuperFleshGolem:SetOffStage()
	end
end

local function OnEvent(event)
	if event == "WakeSuperGolem" then
		RemoveStatus(SuperFleshGolem.UUID, "SLEEPING")
		GlobalSetFlag("LLSENEMY_HM_FTJ_SuperGolemReady")
	end
end

return {
	Init = Init,
	Enable = Enable,
	Disable = Disable,
	OnEvent = OnEvent
}