--[[
Title: 
Author(s): LiXizhi
Date: 2010.10.23
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_window.lua");
local wmWindow = commonlib.gettable("PETools.WindowManager.wmWindow");
wmWindow.wm_window_new(context);
------------------------------------------------------------
]]
local wmWindow = commonlib.inherit(nil, commonlib.gettable("PETools.WindowManager.wmWindow"));


function wmWindow:ctor()
	--	winid also in screens, is for retrieving this window after read 
	self.winid = nil;	
	--	active screen
	self.screen = nil;	
	-- for matching window with active screen after file read 
	self.screenname = "default"; 
	
	--	window coords
	self.posx, self.posy, self.sizex, self.sizey = 0,0,0,0; 
	--	borderless, full
	self.windowstate = "borderless"; 
	
	-- set to 1 if an active window, for quick rejects 
	self.active = 0; 
	-- current mouse cursor type
	self.cursor = nil; 
	--	for temp waitcursor
	self.lastcursor = nil; 
	--	internal: tag this for extra mousemove event, makes cursors/buttons active on UI switching 
	self.addmousemove = nil; 
	
	-- wmEvent list: storage for event system 
	self.eventstate = {};
	
	-- internal for wm_draw.lua only
	self.drawmethod = 0;
	self.drawfail = nil;
	self.drawdata = nil;
	
	-- all events (ghost level events were handled)
	self.queue = {};
	-- window+screen handlers, handled last
	self.handlers = {};	
	-- priority handlers, handled first 
	self.modalhandlers = {};
end

-- create a new window at the given context
function wmWindow.wm_window_new(context)
	local win = wmWindow:new();
	if(context) then
		local wm = context:get_manager();
		wm.windows:addtail(win);
		win.winid = wm:find_free_winid();
	end
	return win;
end