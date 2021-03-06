local goblinScatteredItems = {}

---Makes the goblin always go last.
function TreasureGoblins_OnJoinedCombat(char, id)
	id = tonumber(id)
	local combat = Ext.GetCombat(id)
	if combat then
		--Make the goblin always go last
		local order = combat:GetCurrentTurnOrder()
		local indexMap = {}
		for i=1,#order do
			indexMap[order[i].Character.MyGuid] = i
		end
		table.sort(order, function(a,b)
			if b.Character.MyGuid == char then
				return true
			elseif a.Character.MyGuid == char then
				return false
			end
			return indexMap[a.Character.MyGuid] < indexMap[b.Character.MyGuid]
		end)
		combat:UpdateCurrentTurnOrder(order)
	end
end

local function SaveScatteredItem(item, uuid)
	if goblinScatteredItems[uuid] == nil then
		goblinScatteredItems[uuid] = {}
	end
	local tbl = goblinScatteredItems[uuid]
	tbl[#tbl+1] = item
	PrintDebug("[LLENEMY_TreasureGoblins.lua:SaveScatteredItem] Saved ("..tostring(item)..") for character ("..tostring(uuid).."). Count: ("..tostring(#tbl)..")")
end

local function TreasureGoblins_MoveItemsToSack(uuid,x,y,z,lootSack)
	local goblin = Ext.GetCharacter(uuid).MyGuid
	local tbl = goblinScatteredItems[goblin]
	if tbl ~= nil then
		if #tbl > 0 then
			if lootSack == nil then
				lootSack = CreateItemTemplateAtPosition("CONT_LLENEMY_Bag_TreasureGoblinSack_A_2b7888b9-833c-4443-b4b5-cc372b95b459", x, y, z)
				NRD_ItemSetPermanentBoostInt(lootSack, "Value", 0)
				NRD_ItemSetPermanentBoostInt(lootSack, "Weight", 0)
				PlayEffect(lootSack,"RS3_FX_Skills_Void_Netherswap_Reappear_01")
			end
			if lootSack ~= nil then
				for i,v in pairs(tbl) do
					if ItemIsInInventory(v) ~= 1 then
						Osi.LLSENEMY_TreasureGoblins_AddToSack(lootSack, v)
						ItemMoveToPosition(v, x, y, z, 1.0, 8.0, "LLENEMY_TreasureGoblins_AddItemToSack", 0)
						PlayBeamEffect(lootSack, v, "RS3_FX_GP_Beams_Telekinesis_01", "", "")
					else
						PrintDebug("[LLENEMY_TreasureGoblins.lua:TreasureGoblins_MoveItemsToSack] Item ("..v..") is in an inventory already?")
					end
				end
			else
				PrintDebug("[LLENEMY_TreasureGoblins.lua:TreasureGoblins_MoveItemsToSack] No loot sack for ("..goblin..").")
			end
		else
			PrintDebug("[LLENEMY_TreasureGoblins.lua:TreasureGoblins_MoveItemsToSack] No saved scattered items for ("..goblin..") (length <= 0).")
		end
		goblinScatteredItems[goblin] = nil
	else
		PrintDebug("[LLENEMY_TreasureGoblins.lua:TreasureGoblins_MoveItemsToSack] No saved scattered items for ("..goblin..") (table is nil).")
	end
end

local function TryScatterInventory(uuid)
	local x,y,z = GetPosition(uuid)
	local character = Ext.GetCharacter(uuid)
	if character ~= nil then
		local inventory = character:GetInventoryItems()
		if inventory ~= nil or #inventory <= 0 then
			for k,v in pairs(inventory) do
				if ObjectExists(v) == 1 then
					--LLENEMY_Ext_Debug_PrintItemProperties(v)
					--LLENEMY_Ext_Debug_PrintFlags(v)
					--local equipped = Mods.LeaderLib.ItemIsEquipped(char,v)
					local item = Ext.GetItem(v)
					local stat = item.StatsId
					local equipped = item.Slot <= 13
					-- Stats that start with an underscore aren't meant for players
					if equipped ~= true and string.sub(stat, 1, 1) ~= "_" then
						ItemScatterAt(v, x,y,z)
						ItemClearOwner(v)
						SaveScatteredItem(v,uuid)
						
						fprint(LOGLEVEL.TRACE2, "[LLENEMY_TreasureGoblins.lua:ScatterInventory] Scattering item (%s)[%s]", stat, v)
						if not string.find(stat, "Gold") and (LLENEMY_ItemIsRare(v, item.ItemType)) then
							PlayEffect(v, "LLENEMY_FX_TreasureGoblin_Loot_Dropped_01");
						end
					else
						fprint(LOGLEVEL.TRACE2, "[LLENEMY_TreasureGoblins.lua:ScatterInventory] Item (%s)[%s] is equipped (%s) or an NPC item. Skipping.", stat, v, equipped)
					end
				end
			end
		else
			error(string.format("Inventory from (%s) is empty or null!", uuid))
		end
	else
		error(string.format("Character from (%s) is null!", uuid))
	end
end

function TreasureGoblins_ScatterInventory(char)
	local b,result = xpcall(TryScatterInventory, debug.traceback, char)
	if not b then
		fprint(LOGLEVEL.ERROR, "[SEUO:TreasureGoblins_ScatterInventory] Error scattering inventory:\n%s", result)
	end
end

local function LLENEMY_TreasureGoblinDefeated_TrySpawnLoot(goblin)
	if GetVarInteger(goblin, "LLENEMY_TreasureGoblin_PlayingAnim") ~= 1 then
		SetVarInteger(goblin, "LLENEMY_TreasureGoblin_PlayingAnim", 1)
		PlaySound(goblin, "LLENEMY_VO_Goblin_Death_Random_01")
		PlayAnimation(goblin, "knockdown_fall", "LLENEMY_TreasureGoblins_Left")
	end

	local character = Ext.GetCharacter(goblin)
	local lootSack = nil
	local x,y,z = GetPosition(goblin)

	local current = GetVarInteger(goblin, "LLENEMY_TreasureGoblin_TotalHits")
	local max = GetVarInteger(goblin, "LLENEMY_TreasureGoblin_MaxTotalHits")
	if current < max then
		lootSack = CreateItemTemplateAtPosition("CONT_LLENEMY_Bag_TreasureGoblinSack_A_2b7888b9-833c-4443-b4b5-cc372b95b459", x, y, z)
		PlayEffect(lootSack,"RS3_FX_Skills_Void_Netherswap_Reappear_01")
		PrintDebug("[LLENEMY_TreasureGoblins.lua:TreasureGoblinDefeated] Dropping remaining items ("..tostring(current).."/"..tostring(max)..") for goblin ("..tostring(goblin)..")")
		for i=current,max,1 do
			CharacterGiveReward(goblin, "LLENEMY_TreasureGoblin_A", 1)
		end
		local inventory = character:GetInventoryItems()
		if inventory ~= nil then
			for k,v in pairs(inventory) do
				--LLENEMY_Ext_Debug_PrintItemProperties(v)
				--LLENEMY_Ext_Debug_PrintFlags(v)
				--local equipped = Mods.LeaderLib.ItemIsEquipped(char,v)
				local item = Ext.GetItem(v)
				local stat = item.StatsId
				local equipped = item.Slot <= 13
				-- Stats that start with an underscore aren't meant for players
				if equipped ~= true and string.sub(stat, 1, 1) ~= "_" then
					ItemToInventory(v,lootSack,item.Amount,0,1)
					PrintDebug("[LLENEMY_TreasureGoblins.lua:TreasureGoblinDefeated] Added item ("..tostring(stat)..")["..v.."] to loot sack.")
				end
			end
		else
			PrintDebug("[LLENEMY_TreasureGoblins.lua:TreasureGoblinDefeated] [*ERROR*] GetInventoryItems returned nil for ("..tostring(goblin)..").")
			MoveAllItemsTo(goblin, lootSack, 0, 0, 1)
		end
	else
		PrintDebug("[LLENEMY_TreasureGoblins.lua:TreasureGoblinDefeated] Skipping loot sack spawning for ("..tostring(goblin)..") since it already dropped the max amount ["..tostring(current).."/"..tostring(max).."]")
	end

	TreasureGoblins_MoveItemsToSack(character.MyGuid,x,y,z,lootSack)
end

function TreasureGoblinDefeated(goblin)
	--SetInvulnerable_UseProcSetInvulnerable(goblin, 1)
	local b = pcall(LLENEMY_TreasureGoblinDefeated_TrySpawnLoot, goblin)
end