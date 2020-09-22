local NPC = {
	Kniles = "1d1c0ba0-a91e-4927-af79-6d8d27e0646b"
}

local ENEMY = {
	--CHARACTERGUID_S_LLSENEMY_FTJ_FleshGolem_C_Super_82a1c335-d5b6-4046-9286-400faf67e08e
	SuperFleshGolem = "82a1c335-d5b6-4046-9286-400faf67e08e",
}

function HM_FTJ_Enabled()
	SetOnStage(ENEMY.SuperFleshGolem, 1)
	if CharacterIsInCombat(ENEMY.SuperFleshGolem) == 0 and CharacterIsDead(ENEMY.SuperFleshGolem) == 0 and HasActiveStatus(ENEMY.SuperFleshGolem, "SLEEPING") == 0 then
		CharacterAddAttitudeTowardsPlayer(ENEMY.SuperFleshGolem, NPC.Kniles, 100)
		CharacterAddAttitudeTowardsPlayer(NPC.Kniles, ENEMY.SuperFleshGolem, 100)
		ApplyStatus(ENEMY.SuperFleshGolem, "SLEEPING", -1.0, 1, ENEMY.SuperFleshGolem)
	end
end

function HM_FTJ_Disabled()
	if CharacterIsInCombat(ENEMY.SuperFleshGolem) == 0 and CharacterIsDead(ENEMY.SuperFleshGolem) == 0 then
		SetOnStage(ENEMY.SuperFleshGolem, 0)
	end
end

function HM_FTJ_RunEvent(event)
	if event == "WakeSuperGolem" then
		--local x,y,z = GetPosition(NPC.Kniles)
		--SetOnStage(ENEMY.SuperFleshGolem, 1)
		--TeleportTo(ENEMY.SuperFleshGolem, NPC.Kniles, "", 0, 1, 0)
		--CharacterAppearOutOfSightToObject(ENEMY.SuperFleshGolem, player, ENEMY.Kniles, 1, "LLSENEMY_SuperGolemSpawned")
		RemoveStatus(ENEMY.SuperFleshGolem, "SLEEPING")
		GlobalSetFlag("LLSENEMY_HM_FTJ_SuperGolemReady")
	end
end