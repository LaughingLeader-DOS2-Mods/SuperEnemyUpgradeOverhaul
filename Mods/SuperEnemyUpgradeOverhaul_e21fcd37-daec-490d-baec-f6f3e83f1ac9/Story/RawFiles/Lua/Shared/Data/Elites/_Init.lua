---@class EliteData
---@field Elites table<string,integer>
---@field Upgrades table<string,string>

---@type table<string, EliteData>
local data = {
	TUT_Tutorial_A = Ext.Require("Shared/Data/Elites/Tutorial.lua"),
	FJ_FortJoy_Main = Ext.Require("Shared/Data/Elites/FortJoy.lua"),
	LV_HoE_Main = Ext.Require("Shared/Data/Elites/TheHighSeas.lua"),
	RC_Main = Ext.Require("Shared/Data/Elites/ReapersCoast.lua"),
	CoS_Main = Ext.Require("Shared/Data/Elites/NamelessIsles.lua"),
	Arx_Main = Ext.Require("Shared/Data/Elites/Arx.lua"),
}

return data