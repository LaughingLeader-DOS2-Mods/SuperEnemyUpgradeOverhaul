local printd = PrintDebug

local ATTEMPTS_MAX = 40

local ignored_skills = Ext.Require("Server/BonusSkills/IgnoredSkills.lua")
local ignored_skillwords = Ext.Require("Server/BonusSkills/IgnoredSkillWords.lua")

local ignored_parents = {
	Target_SourceVampirism = true
}

local redirected_skills = {
	Rain_Oil = "Rain_LLENEMY_EnemyOil"
}

-- Has a mod already added to IgnoredSkills?
if IgnoredSkills ~= nil then
	for skill,b in pairs(IgnoredSkills) do
		ignored_skills[skill] = b
	end
end
IgnoredSkills = ignored_skills

if IgnoredWords ~= nil then
	for i,word in pairs(IgnoredWords) do
		table.insert(ignored_skillwords, word)
	end
end
IgnoredWords = ignored_skillwords

---@type SkillEntry
local SkillEntry = Classes.SkillEntry
---@type SkillGroup
local SkillGroup = Classes.SkillGroup

---@param ability string
---@return SkillGroup
local function GetSkillGroup(self, ability)
	for _,v in pairs(self) do
		if v.ability == ability then return v end
	end
	return nil
end

local function IsSummmonSkill(skill)
	if Ext.StatGetAttribute(skill, "SkillType") == "Summon" then
		return true
	else
		---@type StatProperty[]
		local props = GameHelpers.Stats.GetSkillProperties(skill)
		if props ~= nil and #props > 0 then
			for i,v in pairs(props) do
				if v.Type == "Summon" then
					return true
				end
			end
		end
	end
end

function IgnoreSkill(skill)
	if IgnoredSkills[skill] == false then return false end
	if IgnoredSkills[skill] == true then return true end
	if string.sub(skill,1,1) == "_" then
		return true
	end
	if IsSummmonSkill(skill) then
		return true
	end
	local parent = Ext.StatGetAttribute(skill, "Using")
	if parent ~= nil and ignored_parents[parent] == true then
		return true
	end
	for _,word in pairs(ignored_skillwords) do
		if string.find(skill, word) then return true end
	end
	return false
end

local function IgnoreSkill_QRY(skill)
	if IgnoreSkill(skill) then
		return 1
	end
	return 0
end
Ext.NewQuery(IgnoreSkill_QRY, "LLENEMY_Ext_QRY_IgnoreSkill", "[in](STRING)_Skill, [out](INTEGER)_Ignored")

local function TotalSkills_QRY(uuid)
	local char = Ext.GetCharacter(uuid)
	if char ~= nil then
		return #char:GetSkills()
	end
end
Ext.NewQuery(TotalSkills_QRY, "LLENEMY_Ext_QRY_GetTotalSkills", "[in](CHARACTERGUID)_Character, [out](INTEGER)_TotalSkills")

local AIFLAG_CANNOT_USE = 140689826905584

local function LLENEMY_ParentSkillIsInvalid(skill)
	local parent = Ext.StatGetAttribute(skill, "Using")
	if parent ~= nil then
		if Ext.StatGetAttribute(parent, "SkillType") == nil then
			Ext.Print("[EUO:BonusSkills] [*ERROR*] Parent skill for '" .. tostring(skill) .. "' does not exist! Skipping!")
			return true
		end
	end
	return false
end

---@param requirementsTable StatRequirement[]
---@return boolean
local function HasTagRequirement(requirementsTable)
	for i,v in pairs(requirementsTable) do
		if v.Requirement == "Tag" then
			return true
		end
	end
	return false
end

function BuildEnemySkills()
	EnemySkills = {
		SkillGroup:Create("None", "None"),
		SkillGroup:Create("WarriorLore", "Warrior"),
		SkillGroup:Create("RangerLore", "Ranger"),
		SkillGroup:Create("RogueLore", "Rogue"),
		SkillGroup:Create("AirSpecialist", "Air"),
		SkillGroup:Create("EarthSpecialist", "Earth"),
		SkillGroup:Create("FireSpecialist", "Fire"),
		SkillGroup:Create("WaterSpecialist", "Water"),
		SkillGroup:Create("Necromancy", "Death"),
		SkillGroup:Create("Polymorph", "Polymorph"),
		SkillGroup:Create("Summoning", "Summoning"),
		SkillGroup:Create("Sourcery", "Source"),
	}
	local skills = Ext.GetStatEntries("SkillData")
	for k,skill in pairs(skills) do
		if redirected_skills[skill] ~= nil then
			local swapped_skill = redirected_skills[skill]
			printd("[EUO:BonusSkills] Swapping skill '" .. tostring(skill) .. "' for '"..swapped_skill .. "'")
			skill = swapped_skill
		end
		local isenemy = Ext.StatGetAttribute(skill, "IsEnemySkill")
		local aiflags = Ext.StatGetAttribute(skill, "AIFlags")
		local ap = Ext.StatGetAttribute(skill, "ActionPoints")
		local cd = Ext.StatGetAttribute(skill, "Cooldown")

		if not IgnoreSkill(skill) then
			if aiflags ~= AIFLAG_CANNOT_USE and (isenemy == "Yes" and string.find(skill, "Enemy")) then
				if ap > 0 or cd > 0 then
					local b,invalidSkill = pcall(LLENEMY_ParentSkillIsInvalid, skill)
					if not b then invalidSkill = true end
					if not invalidSkill then
						local ability = Ext.StatGetAttribute(skill, "Ability")
						local requirement = Ext.StatGetAttribute(skill, "Requirement")
						local sp = Ext.StatGetAttribute(skill, "Magic Cost")
						if sp == nil then sp = 0 end
						local tier = Ext.StatGetAttribute(skill, "Tier")
						if IsSummmonSkill(skill) then
							EnemySummonSkills[skill] = SkillEntry:Create(skill, requirement, sp, tier)
						else
							local skillgroup = GetSkillGroup(EnemySkills, ability)
							if skillgroup ~= nil then
								skillgroup:Add(SkillEntry:Create(skill, requirement, sp, tier))
							end
						end
					else
						printd("[EUO:BonusSkills] Skill '" .. tostring(skill) .. "' is invalid? pcall (".. tostring(b) ..") invalidSkill(".. tostring(invalidSkill)..")")
					end
				end
			else
				if Ext.StatGetAttribute(skill, "ForGameMaster") == "Yes" and isenemy ~= "Yes" and Ext.StatGetAttribute(skill, "Memory Cost") > 0 then
					local tier = Ext.StatGetAttribute(skill, "Tier")
					if LeaderLib.Data.OriginalSkillTiers ~= nil and LeaderLib.Data.OriginalSkillTiers[skill] ~= nil then
						tier = LeaderLib.Data.OriginalSkillTiers[skill]
					end
					if tier ~= nil and tier ~= "" and tier ~= "None" then
						---@type StatRequirement[]
						local requirements = Ext.StatGetAttribute(skill, "Requirements")
						---@type StatRequirement[]
						local memorizationRequirements = Ext.StatGetAttribute(skill, "MemorizationRequirements")

						-- Skills with tag requirements tend to be special and shouldn't be randomly added
						if not HasTagRequirement(requirements) and not HasTagRequirement(memorizationRequirements) then
							local ability = Ext.StatGetAttribute(skill, "Ability")
							if ability ~= "" and ability ~= "None" then
								-- Poison skills being under the Earth Ability
								if ability == "Earth" then
									if string.find(skill, "Poison") or Ext.StatGetAttribute(skill, "DamageType") == "Poison" then
										ability = "Poison"
									end
								end
								if ItemCorruption.Boosts.BonusSkills[ability] == nil then
									ItemCorruption.Boosts.BonusSkills[ability] = {}
								end
								table.insert(ItemCorruption.Boosts.BonusSkills[ability], skill)
							end
						end
					end
				end
			end
		end
	end
end

local function GetHighestAbility(enemy)
	local last_highest_ability = "None"
	local last_highest_val = 0
	for _,skillgroup in pairs(EnemySkills) do
		if skillgroup.id ~= "None" then
			local ability_val = CharacterGetAbility(enemy, tostring(skillgroup.id))
			---printd("[EUO:BonusSkills:GetHighestAbility] ---- Ability (" .. tostring(skillgroup.id) .. ") = ("..tostring(ability_val)..")")
			if ability_val ~= nil and ability_val > 0 and ability_val > last_highest_val then
				last_highest_ability = skillgroup.id
				last_highest_val = ability_val
			end
		end
	end
	return last_highest_ability
end

local weapontype_requirements = {
	Sword = "MeleeWeapon",
	Club = "MeleeWeapon",
	Axe = "MeleeWeapon",
	Knife = {"DaggerWeapon", "MeleeWeapon"},
	Spear = "MeleeWeapon",
	Staff = {"StaffWeapon", "MeleeWeapon"},
	Bow = "RangedWeapon",
	Crossbow = "RangedWeapon",
	Rifle = {"RifleWeapon", "RangedWeapon"},
	--Wand = {"MeleeWeapon"},
}

---@class WeaponRequirementFlag
local WeaponRequirementFlag = {
	flag = "",
	requirements = "None",
}

WeaponRequirementFlag.__index = WeaponRequirementFlag

function WeaponRequirementFlag:Create(flag, requirements)
    local this =
    {
		flag = flag,
		requirements = requirements
	}
	setmetatable(this, self)
    return this
end

local weapontype_requirements_flags = {}
weapontype_requirements_flags[#weapontype_requirements_flags+1] = WeaponRequirementFlag:Create("LeaderLib_SkillRequirement_DaggerWeapon", {"DaggerWeapon", "MeleeWeapon"})
weapontype_requirements_flags[#weapontype_requirements_flags+1] = WeaponRequirementFlag:Create("LeaderLib_SkillRequirement_StaffWeapon", {"StaffWeapon", "MeleeWeapon"})
weapontype_requirements_flags[#weapontype_requirements_flags+1] = WeaponRequirementFlag:Create("LeaderLib_SkillRequirement_MeleeWeapon", "MeleeWeapon")
weapontype_requirements_flags[#weapontype_requirements_flags+1] = WeaponRequirementFlag:Create("LeaderLib_SkillRequirement_RangedWeapon", "RangedWeapon")
--weapontype_requirements_flags[#weapontype_requirements_flags+1] = WeaponRequirementFlag:Create("LeaderLib_SkillRequirement_WandWeapon", "WandWeapon")


local function GetWeaponRequirement(enemy)
	for i,v in pairs(weapontype_requirements_flags) do
		if ObjectGetFlag(enemy, v.flag) == 1 then
			return v.requirements
		end
	end
	--[[ local weapon = CharacterGetEquippedWeapon(enemy)
	if weapon ~= nil then
		local stat = NRD_ItemGetStatsId(weapon)
		local weapontype = NRD_StatGetString(stat, "WeaponType")
		local req_entry = weapontype_requirements[weapontype]
		if req_entry ~= nil then
			return req_entry
		end
	end ]]
	return "None"
end

local function GetPreferredSkillGroup(ability,requirement,lastgroup)
	--printd("EnemySkills count: " .. tostring(#EnemySkills) .. " | Looking for " .. ability)
	if ability ~= "None" and (lastgroup == nil or lastgroup ~= nil and lastgroup.id ~= ability) then
		for k,v in pairs(EnemySkills) do
			if v.id == ability or v.ability == ability then return v end
		end
	else
		local attempts = 0
		while attempts < 20 do
			local rantable = Common.GetRandomTableEntry(EnemySkills)
			if rantable ~= nil then
				local ranskill = Common.GetRandomTableEntry(rantable.skills)
				if ranskill ~= nil then
					if ranskill.requirement == "None" then
						return rantable
					end
					if type(requirement) == "string" and ranskill.requirement == requirement then
						--printd("[EUO:BonusSkills:GetPreferredSkillGroup] ---- Matched skill (" .. tostring(ranskill.id) .. ") to requirement ("..requirement..") for group ("..rantable.id..")")
						return rantable
					elseif type(requirement) == "table" then
						for k,v in pairs(requirement) do
							if v == ranskill.requirement then
								--printd("[EUO:BonusSkills:GetPreferredSkillGroup] ---- Matched skill (" .. tostring(ranskill.id) .. ") to requirement ("..v..") for group ("..rantable.id..")")
								return rantable
							end
						end
					end
				else
					print("Failed to get random skill:")
					print(Ext.JsonStringify(rantable))
				end
			end
			attempts = attempts + 1
		end
	end
	return nil
end

local function SkillIsBlockedByUser(skill)
	local userList = Settings.Global.Variables.EnemySkillIgnoreList
	if userList ~= nil and #userList > 0 then
		for i,v in pairs(userList) do
			if v == skill or string.find(skill, v) then
				return true
			end
		end
	end
	return false
end

---@param enemy EsvCharacter
local function TryAddBonusSkills(enemy,remaining,remainingSourceSkills)
	local preferred_ability = GetHighestAbility(enemy)
	local preferred_requirement = GetWeaponRequirement(enemy)
	--local sp_max = CharacterGetMaxSourcePoints(enemy)
	local level = enemy.Stats.Level

	printd(string.format("[EUO:BonusSkills] Enemy(%s:%s) Ability(%s) Requirement(%s) Remaining(%s)", enemy.DisplayName, enemy.MyGuid, preferred_ability, Common.Dump(preferred_requirement), remaining))

	local skillgroup = GetPreferredSkillGroup(preferred_ability, preferred_requirement, nil)
	if skillgroup == nil then
		printd("[EUO:BonusSkills] -- Can't get a skillgroup for Enemy. Skipping.")
		return false
	end
	local attempts = 0
	while remaining > 0 and attempts < ATTEMPTS_MAX do
		local success = false
		local skill = skillgroup:GetRandomSkill(enemy, preferred_requirement, level, remainingSourceSkills)
		if skill ~= nil and not SkillIsBlockedByUser(skill) then
			if skill.sp > 0 then
				remainingSourceSkills = remainingSourceSkills - 1
			end
			printd(string.format("[EUO:BonusSkills] Enemy(%s:%s) gained skill (%s)", enemy.DisplayName, enemy.MyGuid, skill.id))
			CharacterAddSkill(enemy, skill.id, 0)
			success = true
		end

		if success == true then
			remaining = remaining - 1
		--- Get another random skillgroup when no preference is set
			if remaining > 0 and preferred_ability == "None" then
				local nextskillgroup = GetPreferredSkillGroup(preferred_ability, preferred_requirement, skillgroup)
				if nextskillgroup ~= nil then
					skillgroup = nextskillgroup
				end
			end
		end

		attempts = attempts + 1
	end
	if attempts >= ATTEMPTS_MAX then
		printd(string.format("[EUO:BonusSkills] Enemy(%s:%s) hit the maximum amount of random attempts when getting a skill from group (%s)", enemy.DisplayName, enemy.MyGuid, skillgroup.id))
	end
end

---@param target EsvCharacter
function UpgradeSystem.AddBonusSkills(target)
	if Osi.LLSENEMY_QRY_CanAddBonusSkills(target.MyGuid) == true then
		local min = Settings.Global.Variables.BonusSkills_Min.Value or 0
		local max = Settings.Global.Variables.BonusSkills_Min.Value or 3

		local totalBonusSkills = Ext.Random(min, max)

		local totalSourceSkills = 0
		local canUseSource = not Settings.Global.Flags.LLENEMY_SourceBonusSkillsDisabled.Enabled and (target:HasTag("MAGISTER") == false or IsBoss(target.MyGuid) == 1)
		if canUseSource and CharacterGetMaxSourcePoints(target.MyGuid) > 0 then
			totalSourceSkills = Ext.Random(0,1)
		end

		if totalBonusSkills > 0 then
			for i=totalBonusSkills,0,1 do
				if TryAddBonusSkills(target, i, totalSourceSkills) then
					SetTag(target.MyGuid, "LLENEMY_HasBonusSkill")
				end
			end
		end
	end
end

function AddSummonSkill(enemy, amountStr)
	local skills = {}
	for skill,v in pairs(EnemySummonSkills) do
		table.insert(skills, skill)
	end
	skills = Common.ShuffleTable(skills)
	local addSkill = Common.GetRandomTableEntry(skills)
	if not StringHelpers.IsNullOrEmpty(addSkill) then
		CharacterAddSkill(enemy, addSkill, 0)
	end
end