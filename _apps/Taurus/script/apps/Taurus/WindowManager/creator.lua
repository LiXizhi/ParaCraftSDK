--[[
Title: the taurus creator main
Author(s): LiXizhi
Date: 2010.10.23
Desc: This is the entry class
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/WindowManager/creator.lua");
PETools.creator.main();
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_main.lua");
local wm_main = commonlib.gettable("PETools.WindowManager.wm_main");

local wmContext = commonlib.gettable("PETools.WindowManager.wmContext");
local wm_main = commonlib.gettable("PETools.WindowManager.wm_main");

-- global main class
local creator = commonlib.gettable("PETools.creator");

-- create and show the creator
function creator.main(params)
	LOG.std("", "system", "creator", "PETools creator starting...");
	-- create the context object
	local context = wmContext:new();

	-- init window manager, load all data from default or specified file
	wm_main.wm_init(context, params);
	-- init key map
	wm_main.keymap_init(context);

	-- start main loop
	wm_main.main(context, params);
end