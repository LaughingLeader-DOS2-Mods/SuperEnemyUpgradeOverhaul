
local function ItemCorruptionTest(level,delay)
	local host = CharacterGetHostCharacter()
	local x,y,z = GetPosition(host)
	if level ~= nil then
		level = math.tointeger(tonumber(level))
	else
		level = CharacterGetLevel(host)
	end
	local backpack = CreateItemTemplateAtPosition("LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
	GenerateTreasure(backpack, "LLENEMY_ShadowOrbRewards", level, host)
	--GenerateTreasure(backpack, "ST_QuestReward_RG_3", level, host)
	--GenerateTreasure(backpack, "ST_LLENEMY_JustGloves", level, host)
	--GenerateTreasure(backpack, "ST_LLENEMY_ShadowTreasureWeaponsTest", level, host)
	--GenerateTreasure(backpack, "CheatHeavyArmor", level, host)
	--ShadowCorruptContainerItems(backpack, "Random")
	ShadowCorruptContainerItems(backpack)
	MoveAllItemsTo(backpack, host, 0, 0, 1)
	ItemRemove(backpack)
end

Ext.RegisterConsoleCommand("shadowitemtest", function(command,level,delaystr)
	local status,err = xpcall(function() 
		if delaystr ~= nil then
			local delay = tonumber(delaystr)
			if delay > 0 then
				LeaderLib.StartOneshotTimer("Timers_LLENEMY_Debug_ShadowItemTest", delay, function()
					ItemCorruptionTest(level, delay)
				end)
			else
				ItemCorruptionTest(level, delay)
			end
		else
			ItemCorruptionTest(level)
		end
	end, debug.traceback)
	if not status then
		print("[EUO:shadowitemtest] Error:")
		print(err)
	end
end)

Ext.RegisterConsoleCommand("goblintest", function(command)
	local combat = Osi.DB_CombatCharacters:Get(nil,nil)
	Ext.Print("[LLENEMY:Debug.lua] DB_CombatCharacters:\n[".. Common.Dump(combat))
	local host = CharacterGetHostCharacter()
	local x,y,z = GetPosition(host)
	if combat ~= nil and #combat > 0 then
		local combatid = combat[1][2]
		if combatid ~= nil then
			--Osi.LLSENEMY_TreasureGoblins_Spawn(combatid)
			--local x,y,z = GetPosition(combat[1][1])
			--Osi.LLSENEMY_TreasureGoblins_Internal_Spawn(x, y, z, combatid)
			SpawnTreasureGoblin(x,y,z,CharacterGetLevel(host),combatid)
			LeaderLib.PrintDebug("Spawning treasure goblin at ", x, y, z)
		end
	else
		SpawnTreasureGoblin(x,y,z,CharacterGetLevel(host),0)
		LeaderLib.PrintDebug("Spawning treasure goblin at ", x, y, z)
	end
end)

Ext.RegisterConsoleCommand("shadoworb", function(command,movie)
	local host = CharacterGetHostCharacter()
	Osi.DB_LLSENEMY_Rewards_Temp_TreasureToGenerate(host, "LLENEMY_ShadowOrbRewards")
	Osi.LLSENEMY_Rewards_SpawnShadowOrb(host)
end)

Ext.RegisterConsoleCommand("transformtest", function(command)
	local host = CharacterGetHostCharacter()
	local x,y,z = GetPosition(host)
	local dupe = CharacterCreateAtPosition(x, y, z, "Humans_Hero_Male_25611432-e5e4-482a-8f5d-196c9e90001e", 0)
	CharacterTransformFromCharacter(dupe, host, 1, 1, 1, 1, 1, 0, 0)
	local level = CharacterGetLevel(host)
	CharacterLevelUpTo(dupe, level)
end)

Ext.RegisterConsoleCommand("transformtest2", function(command)
	local host = CharacterGetHostCharacter()
	local x,y,z = GetPosition(host)
	local dupe = CharacterCreateAtPosition(x, y, z, "LLENEMY_Dupe_A_54ad4e06-b57f-46d0-90fc-5da1208250e0", 0)
	local dupe2 = CharacterCreateAtPosition(x, y, z, "LLENEMY_Dupe_A_54ad4e06-b57f-46d0-90fc-5da1208250e0", 0)
	local level = CharacterGetLevel(host)
	CharacterLevelUpTo(dupe, level)
	
	--Osi.LLSENEMY_OnCharacterJoinedCombat(dupe, 0)
	CharacterTransformFromCharacter(dupe2, host, 1, 1, 1, 1, 1, 1, 1)
	LeaderLib.StartOneshotTimer("Timers_LLENEMY_Debug_TransformTest", 1250, function(...)
		CharacterTransformFromCharacter(dupe, host, 1, 1, 1, 1, 1, 1, 1)
		Osi.LLSENEMY_OnCharacterJoinedCombat(dupe2, 0)
	end)
end)

Ext.RegisterConsoleCommand("euo_printrespentags", function(command)
	for damageType,_ in pairs(LeaderLib.Data.DamageTypeToResistance) do
		for i,entry in ipairs(LeaderLib.Data.ResistancePenetrationTags[damageType]) do
			print(string.format("%s = Classes.TagBoost:Create(\"%s\", \"\", false),", entry.Tag, entry.Tag))
		end
	end
end)

Ext.RegisterConsoleCommand("euo_tagtest", function(command,reset)
	local host = CharacterGetHostCharacter()
	for i,entry in pairs(ItemCorruption.TagBoosts) do
		if reset == nil then
			ObjectSetFlag(host, entry.Flag, 0)
			CharacterStatusText(host, entry.Flag .. " Set")
		else
			ObjectClearFlag(host, entry.Flag, 0)
			CharacterStatusText(host, entry.Flag .. " Cleared")
		end
	end
end)

Ext.RegisterConsoleCommand("euo_ringtest", function(command)
	local host = CharacterGetHostCharacter()
	local ring = GameHelpers.Item.CreateItemByStat("ARM_Ring", 12, "Epic", true, 1)
	SetTag(ring, "LLENEMY_ShadowItem")
	SetTag(ring, ItemCorruption.TagBoosts.LLENEMY_ShadowBonus_CursedFire.Tag)
	SetTag(ring, ItemCorruption.TagBoosts.LLENEMY_ShadowBonus_ShockingRain.Tag)
	-- SetTag(ring, ItemCorruption.TagBoosts.LLENEMY_ShadowBonus_SlipperyRogue.Tag)
	-- SetTag(ring, ItemCorruption.TagBoosts.LLENEMY_ShadowBonus_DefensiveStart.Tag)
	ItemToInventory(ring, host)
	CharacterAddSkill(host, "Projectile_EnemyFireball", 0)
	CharacterAddAbilityPoint(host, 2)
	CharacterAddSkill(host, "Rain_Water", 0)
end)

Ext.RegisterConsoleCommand("enemytest1", function(cmd)
	print("[enemytest1] Spawning enemy")
	local status,err = xpcall(function()
		local host = CharacterGetHostCharacter()
		local x,y,z = GetPosition(host)
		local tx,ty,tz = FindValidPosition(x,y,z, 12.0, host)
		local template = GetTemplate(host)
		local enemy = TemporaryCharacterCreateAtPosition(tx,ty,tz, template, 0)
		CharacterAddSkill(enemy, "Projectile_EnemyFireball", 0)
		CharacterAddSkill(enemy, "Projectile_EnemyFlamingDaggers", 0)
		CharacterAddSkill(enemy, "Projectile_EnemyPyroclasticRock", 0)
		CharacterAddSkill(enemy, "Projectile_EnemyLightningBolt", 0)
		CharacterAddSkill(enemy, "Target_FirstAidEnemy", 0)
		CharacterAddSkill(enemy, "Target_EnemyElementalArrowheads", 0)
		CharacterAddSkill(enemy, "Target_EnemyMosquitoSwarm", 0)
		CharacterAddSkill(enemy, "Target_EnemyDecayingTouch", 0)
		CharacterAddSkill(enemy, "Target_EnemyFortify", 0)
		CharacterAddSkill(enemy, "Target_EnemyFrostyShell", 0)
		CharacterAddSkill(enemy, "Target_EnemyRestoration", 0)
		CharacterAddSkill(enemy, "Target_EnemyHaste", 0)
		CharacterAddSkill(enemy, "Target_EnemyTentacleLash", 0)
		CharacterAddSkill(enemy, "Shout_EnemyBullHorns", 0)
		SetFaction(enemy, "Evil NPC")
	end, debug.traceback)
	if not status then
		print(err)
	end
end)

local presets = {
	"Knight_Act2",
	"Rogue_Act2",
	"Wizard_Act2",
	"Battlemage_Act2",
	"Witch_Act2",
	"Enchanter_Act2",
}

Ext.RegisterConsoleCommand("enemytest2", function(cmd)
	local host = CharacterGetHostCharacter()
	local x,y,z = GetPosition(host)
	local tx,ty,tz = FindValidPosition(x,y,z, 20.0, host)
	local template = GetTemplate(host)
	local enemy = TemporaryCharacterCreateAtPosition(tx or x,ty or y,tz or z, template, 0)
	SetFaction(enemy, "Evil NPC")

	local preset = Common.GetRandomTableEntry(presets)
	CharacterApplyPreset(enemy, preset)

	AddBonusSkills(enemy, "25", "5")
end)

Ext.RegisterConsoleCommand("euo_removedupes", function(command)
	local db = Osi.DB_LLSENEMY_Duplication_Temp_Active:Get(nil,nil,nil)
	if db ~= nil and #db > 0 then
		for i,v in pairs(db) do
			Osi.LeaderLib_Tags_ClearAllPreservedTagData(v[2])
			SetOnStage(v[2], 0)
		end
	end
	Osi.DB_LLSENEMY_Duplication_Temp_Active:Delete(nil,nil,nil)
end)

Ext.RegisterConsoleCommand("euo_dupe", function(command)
	for i,db in pairs(Osi.DB_CombatCharacters:Get(nil,nil)) do
		local character = Ext.GetCharacter(db[1])
		Duplication.StartDuplicating(character)
	end
	
end)

local function GetTempTestEnemy(x, y, z, template)
	local enemy = StringHelpers.GetUUID(TemporaryCharacterCreateAtPosition(x, y, z, template, 0))
	if StringHelpers.IsNullOrEmpty(enemy) then
		return nil
	end
	SetTag(enemy, "LLENEMY_UpgradesDisabled")
	SetTag(enemy, "LLENEMY_AutoLevelingDisabled")
	SetCanJoinCombat(enemy, 0)
	SetCanFight(enemy, 0)
	SetFaction(enemy, "Evil NPC")
	return enemy
end

---@type table<string,LuaTest>
local AllTests = {
---@param self LuaTest
Testing.CreateTest("EUOUpgradeSystem", function(self, ...)
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(host.WorldPos, 12.0)
	--"LLENEMY_Creatures_Voidwoken_Drillworm_A_Hatchling_ABC_c1a13a24-8b5c-408c-b2bf-18d965c166d0"
	print(string.format('TemporaryCharacterCreateAtPosition(%s, %s, %s, "%s", %s)', x, y, z, "c1a13a24-8b5c-408c-b2bf-18d965c166d0", 0))
	local enemy = GetTempTestEnemy(x, y, z, "c1a13a24-8b5c-408c-b2bf-18d965c166d0")
	self:AssertEquals(StringHelpers.IsNullOrEmpty(enemy), false, "Enemy does not exist.")
	self.Cleanup = function(self)
		RemoveTemporaryCharacter(enemy)
		UpgradeSystem.ClearCharacterData(enemy)
	end

	self:Wait(1000)
	
	self:AssertEquals(ObjectExists(enemy), 1, "Enemy does not exist.")
	UpgradeSystem.RollForUpgrades(enemy, true, true, true)
	local data = UpgradeSystem.GetCurrentRegionData(nil, enemy, false)
	self:AssertEquals((data ~= nil and #data > 0) or false, true, "Enemy does not have upgrade data.")
	self.SuccessMessage = string.format("Enemy upgrade results:\n%s", Ext.JsonStringify(data))
	print(self.SuccessMessage)
end),
---@param self LuaTest
Testing.CreateTest("EUOLevelSystem", function(self, ...)
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(host.WorldPos, 12.0)
	local template = "LLENEMY_Creatures_Voidwoken_Drillworm_A_Hatchling_ABC_c1a13a24-8b5c-408c-b2bf-18d965c166d0"
	local enemy = GetTempTestEnemy(x, y, z, template)
	self:AssertEquals(StringHelpers.IsNullOrEmpty(enemy), false, "Enemy does not exist.")
	--self:AssertEquals(ObjectExists(enemy), 1, "Enemy does not exist.")

	self.Cleanup = function(self)
		RemoveTemporaryCharacter(enemy)
	end

	local level = CharacterGetLevel(enemy)
	LevelUpCharacter(enemy, true, true)
	local nextLevel = CharacterGetLevel(enemy)

	self:AssertEquals(nextLevel > level, true, "Enemy did not level up.")
	self.SuccessMessage = string.format("Enemy level increased %s -> %s", level, nextLevel)
	
end),
---@param self LuaTest
Testing.CreateTest("EUODupeTest", function(self, ...)
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	local dupes = Duplication.StartDuplicating(host, true, true, true)
	local dupesCreated = dupes ~= nil and #dupes > 0 or false	
	self:AssertEquals(dupesCreated, true, "No duplicants created.")
	self.Cleanup = function(self)
		for _,v in pairs(dupes) do
			RemoveTemporaryCharacter(v)
		end
	end
	self.SuccessMessage = string.format("Duped created: %s\n%s", #dupes, StringHelpers.Join("\n\t", dupes))
	
end),
---@param self LuaTest
Testing.CreateTest("EUOShadowTreasureTest", function(self, ...)
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(host.WorldPos, 12.0)
	local level = host.Stats.Level
	local backpack = CreateItemTemplateAtPosition("LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
	self:AssertEquals(StringHelpers.IsNullOrEmpty(backpack), false, "Failed to create backpack.")
	self.Cleanup = function(self)
		ItemRemove(backpack)
	end
	GenerateTreasure(backpack, "LLENEMY_ShadowOrbRewards", level, host.MyGuid)
	GenerateTreasure(backpack, "CheatHeavyArmor", level, host.MyGuid)
	GenerateTreasure(backpack, "ST_LLENEMY_JustGloves", level, host.MyGuid)
	--GenerateTreasure(backpack, "ST_QuestReward_RG_3", level, host.MyGuid)
	--GenerateTreasure(backpack, "ST_LLENEMY_ShadowTreasureWeaponsTest", level, host.MyGuid)
	--ShadowCorruptContainerItems(backpack, "Random")

	ShadowCorruptContainerItems(backpack, nil, true)
	local backpackItem = Ext.GetItem(backpack)
	local inventory = backpackItem:GetInventoryItems()

	self:AssertNotEquals(#inventory, 0, "No items were generated")
	local hasShadowItem = false
	local itemData = {}
	for i,v in pairs(inventory) do
		local item = Ext.GetItem(v)
		local name = item.DisplayName
		if not StringHelpers.IsNullOrEmpty(item.CustomDisplayName) then
			name = item.CustomDisplayName
		end
		if item:HasTag("LLENEMY_ShadowItem") then
			hasShadowItem = true
		end
		table.insert(itemData, string.format("\t[%s] %s (%s)%s", item.StatsId, name, item.Stats and item.Stats.ItemTypeReal or item.ItemType, item:HasTag("LLENEMY_ShadowItem") and " *" or ""))
	end
	self:AssertEquals(hasShadowItem, true, "No shadow items were created.")
	self.SuccessMessage = string.format("Items generated:\n%s", StringHelpers.Join("\n", itemData))
	print(self.SuccessMessage)
	
end),
---@param self LuaTest
Testing.CreateTest("EUOVoidwokenSourceTest", function(self, ...)
	local host = Ext.GetCharacter(CharacterGetHostCharacter())
	local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(host.WorldPos, 12.0)
	local totalPointsUsed = Ext.Random(20,99)
	local results = VoidWokenSpawning.Spawn(host.MyGuid, totalPointsUsed, false, true)
	self.Cleanup = function(self)
		for i,v in pairs(results) do
			if not StringHelpers.IsNullOrEmpty(v) then
				RemoveTemporaryCharacter(v)
			end
		end
	end
	print("Spawned voidwoken:")
	self:AssertEquals(results and #results > 0, true, "No voidwoken were spawned.")
	for i,v in pairs(results) do
		if not StringHelpers.IsNullOrEmpty(v) then
			SetCanFight(v, 0)
			SetCanJoinCombat(v, 0)
		end
	end
	self:Wait(500)
	local spawnData = {}
	for i,v in pairs(results) do
		if not StringHelpers.IsNullOrEmpty(v) and ObjectExists(v) == 1 then
			local enemy = Ext.GetCharacter(v)
			table.insert(spawnData, string.format("\tTemplate(%s) Stats(%s) x(%s) y(%s) z(%s)", enemy.RootTemplate.Id, enemy.Stats.Name, table.unpack(enemy.WorldPos)))
			--print(string.format("[%s] Template(%s) Stats(%s) x(%s) y(%s) z(%s)", i, enemy.RootTemplate.Id, enemy.Stats.Name, table.unpack(enemy.WorldPos)))
		end
	end
	self.SuccessMessage = string.format("Voidwoken spawned:\n%s", StringHelpers.Join("\n", spawnData))
	print(self.SuccessMessage)
	
end),
}

Ext.RegisterConsoleCommand("euo_runtests", function(cmd)
	Testing.RunTests(AllTests, 5000, "SuperEnemyUpgradeOverhaul")
end)