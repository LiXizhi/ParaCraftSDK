--[[
Title: the global main function and default configurations
Author(s): LiXizhi
Date: 2010.10.23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_main.lua");
local wm_main = commonlib.gettable("PETools.WindowManager.wm_main");
local Main = commonlib.gettable("PETools.WindowManager.Main");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Taurus/DataAPI/rna_access.lua");
NPL.load("(gl)script/apps/Taurus/WindowManager/wm.lua");
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_files.lua");
local wm_files = commonlib.gettable("PETools.WindowManager.wm_files");
local wmWindowManager = commonlib.gettable("PETools.WindowManager.wmWindowManager");

local MAX_OP_REGISTERED	= 32;

-- global singleton class
local wm_main = commonlib.gettable("PETools.WindowManager.wm_main");

---------------------------
-- singleton
---------------------------
-- all finished operations get registered in the windowmanager here 
-- called on event handling by event_system.lua
-- @param context: the context object 
-- @param op: the operator object
function wm_main.operator_register(context, op)
	local wm = context:get_manager();
	wm.operators:addtail(op);
	local total = wm.operators:size();

	while(tot > MAX_OP_REGISTERED) do
		local opt = wm.operators:first();
		wm.operators:remove(opt);
		opt:free();
		total = total - 1;
	end
end

function wm_main.operator_stack_clear(context)
	local wm = context:get_manager();
	local op;
	for op in wm.operators:each() do
		op:free();
	end
	wm.operators:clear();
end

-- default keymap for windows and screens, only call once per window manager
function wm_main.wm_window_keymap(keyconf)
	-- TODO
end

-- called in wm_main.lua
-- default editor keymap definitions are registered only once per WM initialize, usually on file read,
-- using the keymap the actual areas/regions add the handlers 
function wm_main.ED_spacetypes_keymap(keyconf)
	-- TODO
end

function wm_main.keymap_init(context)
	local wm = context:get_manager();

	if(not wm.defaultconf) then
		wm.defaultconf = wm:keyconfig_add("taurus");
	end
	
	if(wm and not wm.initialized_keymap) then
		-- /* create default key config */
		wm_main.wm_window_keymap(wm.defaultconf);
		wm_main.ED_spacetypes_keymap(wm.defaultconf);
		wm:keyconfig_userdef();
		wm.initialized_keymap = true;
	end
end

-- get home directory
function wm_main.gethome_dir()
	return "temp/petools/";
end

-- load all default operator type here
function wm_main.wm_operatortype_init()
	-- TODO:
end

-- load all default space editor type here
function wm_main.ED_spacetypes_init()
	-- TODO:
end

-- @param context:
-- @param params: the command line parameters. 
function wm_main.wm_init(context, params)
	wm_main.wm_operatortype_init();
	wm_main.ED_spacetypes_init();

	-- get the default home file, plus a wm
	wm_files.WM_read_homefile(context, nil);

end


function wm_main.main(context)
	-- the main loop
end

-----------------------------------
-- the main data structure
-----------------------------------
local Main = commonlib.inherit(nil, commonlib.gettable("PETools.WindowManager.Main"));

function Main:ctor()
	self.name = "default_main";
	self.versionfile = 0;
	self.subversionfile = 1;
	self.minversionfile = 0;
	self.minsubversionfile = 1;

	self.scene = commonlib.List:new();
	-- window manager
	self.wm = commonlib.List:new();
	self.screen = commonlib.List:new();
	self.object = commonlib.List:new();
	self.camera = commonlib.List:new();
	self.world = commonlib.List:new();
end

-- return the list object by type_name
-- @param type_name: supported typename is "wm", "screen", "camera", "object", etc.
function Main:get_listbase(type_name)
	return self[type_name];
end
