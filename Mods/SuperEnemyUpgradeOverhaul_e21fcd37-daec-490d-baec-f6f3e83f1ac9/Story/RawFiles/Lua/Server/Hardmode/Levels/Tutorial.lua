--Magister Knight that dies from the Kraken on the top deck
local KrakenMagisterVictim = CharacterData:Create("b5e74192-498f-4eb3-844a-4a817f9802d3")
--Magister Knight near Captain Kalwyn
local TopDeckMagister = CharacterData:Create("de400bda-b14e-4cff-b5f5-737781437902")
local CaptainKalwyn = CharacterData:Create("e2d47d73-4f9d-4de2-8a3c-c774a0ea114a")
local MagisterRennart = CharacterData:Create("a06e61dd-58c6-4119-99be-716c3a4fc1ef")

local function Init()
	Osi.LLSENEMY_Upgrades_AddToIgnoreList(KrakenMagisterVictim.UUID)
	Hardmode:SetupNPC(TopDeckMagister.UUID, true)
	Hardmode:SetupNPC(CaptainKalwyn.UUID, true)
	MagisterRennart:FullRestore()
	MagisterRennart:EquipTemplate("47131328-5335-4349-999b-c0fa4ad0a806")
	MagisterRennart:EquipTemplate("ec4769e6-bcfc-44e0-9e9c-de62e0bdf407")
end

local function Enable()
	SetupRecruiter("TUT_Tutorial_A")
end

local function Disable()
	Osi.ProcSetInvulnerable(TopDeckMagister.UUID, 0)
	CharacterSetImmortal(TopDeckMagister.UUID, 0)
	Osi.ProcSetInvulnerable(CaptainKalwyn.UUID, 0)
	CharacterSetImmortal(CaptainKalwyn.UUID, 0)
	HideRecruiter()
end

return {
	Init = Init,
	Enable = Enable,
	Disable = Disable
}