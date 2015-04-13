--[[
Title: the window manager
Author(s): LiXizhi
Date: 2010.10.23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/WindowManager/wm.lua");
local wmWindowManager = commonlib.gettable("PETools.WindowManager.wmWindowManager");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_context.lua");
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_keymap.lua");
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_window.lua");
local wmWindow = commonlib.gettable("PETools.WindowManager.wmWindow");
local wmKeyConfig = commonlib.gettable("PETools.WindowManager.wmKeyConfig");

-- global singleton class
local wm_main = commonlib.gettable("PETools.WindowManager.wm_main");

local wmWindowManager = commonlib.inherit(nil, commonlib.gettable("PETools.WindowManager.wmWindowManager"));

-- window manager class: currently there is a single window manager and a single screen. 
-- however, the code will assume there can be multiple of them.
function wmWindowManager:ctor()
	-- array of windows
	self.windows = commonlib.List:new();
	-- set on file read 
	self.initialized_window = nil;
	self.initialized_keymap = nil;
	
	-- indicator whether data was saved 
	self.file_saved = false; 
	
	-- operator stack depth to avoid nested undo pushes 
	self.op_undo_depth = 0;	

	-- operator registry(list)
	self.operators = commonlib.List:new(); 
	
	-- refresh/redraw wmNotifier structs
	self.queue = {};
	
	-- information and error reports.
	self.reports = {};	
	
	-- threaded jobs manager
	self.jobs = {};
	
	-- extra overlay cursors to draw, like circles 
	self.paintcursors = {};
	
	-- active dragged items
	self.drags = {};
	
	-- known key configurations
	self.keyconfigs = commonlib.List:new();
	
	-- default configuration, not saved
	self.defaultconf = {};
	
	-- active timers 
	self.timers = {};

	-- timer for auto save
	self.autosavetimer = commonlib.Timer:new({callbackFunc = function(timer)
		self:OnAutoSaveTimer();
	end});
end

-- load from xml node
function wmWindowManager:load(wmNode)
	local windowsNode = commonlib.XPath.selectNode(wmNode, "/windows");
	if(windowsNode)  then
		local node;
		for node in commonlib.XPath.eachNode(windowsNode, "/window") do
			local win = wmWindow:new();
			local attr = node.attr;
			win.winid = tonumber(attr.winid);
			win.screenname = attr.screenname;
			win.posx = tonumber(attr.posx);
			win.posy = tonumber(attr.posy);
			win.sizex = tonumber(attr.sizex);
			win.sizey = tonumber(attr.sizey);
			win.windowstate = attr.windowstate;
			self.windows:addtail(win);
		end
	end
end

-- save to file
function wmWindowManager:save(node)
end

--  on startup, it adds all data, for matching
function wmWindowManager.add_default(C)
	local wm = wmWindowManager:new();
	-- pre-fetch screen
	local screen= C:get_screen(); 
	C:set_manager(wm);

	local win = wmWindow.wm_window_new(C);
	win.screen = screen;
	screen.winid= win.winid;
	win.screenname = screen.id.name;
	
	wm.winactive= win;
	wm.file_saved= 1;
	return wm;
end

function wmWindowManager:OnAutoSaveTimer()
end

-- create and add a new key map with the given name
-- @return the keymap object
function wmWindowManager:keyconfig_add(idname)
	local keyconf = wmKeyConfig:new();
	self.keyconfigs:addtail(keyconf);
	return keyconf;
end

-- load global user key map configuration and overwrite the default one. 
function wmWindowManager:keyconfig_userdef()
	-- TODO: 
end

function wmWindowManager:find_free_winid()
	local id;
	local win = self.windows:first();
	while (win) do
		if(id <= win.winid) then
			id = win.winid+1;
		end
		win= self.windows:next();
	end
	return id;
end

