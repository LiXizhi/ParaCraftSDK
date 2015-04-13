--[[
Title: the global main function and default configurations
Author(s): LiXizhi
Date: 2010.10.23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_global.lua");
local G = commonlib.gettable("PETools.Global");
------------------------------------------------------------
]]
local Global = commonlib.gettable("PETools.Global", {
	-- /* strings: lastsaved */
	ima, -- image path
	sce, -- scene path
	lib, -- lib path
	-- /* flag: if != 0 G.sce contains valid relative base path */
	relbase_valid,
});

