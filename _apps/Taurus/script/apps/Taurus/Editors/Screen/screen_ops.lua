--[[
Title: the screen manages the layout of sub areas
Author(s): LiXizhi
Date: 2010.10.25
Desc: each window can have one screen layout at most, and the screen manages the layout of sub areas
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/Editors/Screen/screen_ops.lua");
local wmScreen = commonlib.gettable("PETools.WindowManager.wmScreen");
------------------------------------------------------------
]]
NPL.load("(gl)script/apps/Taurus/Editors/Screen/area.lua");
local wmArea = commonlib.gettable("PETools.WindowManager.wmArea");

local wmScreen = commonlib.inherit(nil, commonlib.gettable("PETools.WindowManager.wmScreen"));

-- constructor
function wmScreen:ctor()
	self.id = nil;
	self.left, self.top, self.right, self.bottom = 0,0,0,0;
	-- all sub areas inside this screen
	self.areabase = commonlib.List:new();

	self.scene = nil;
	-- temporary when switching
	self.newscene = nil;

	-- winid from WM, starts with 1 
	self.winid = nil;
	-- notifier for drawing edges
	self.do_draw = nil;
	-- notifier for scale screen, changed screen, etc 
	self.do_refresh = nil;
	-- notifier for gesture draw. 
	self.do_draw_gesture = nil;
	-- notifier for paint cursor draw. 
	self.do_draw_paintcursor = nil;
	-- notifier for dragging draw.
	self.do_draw_drag = nil;
	
	-- screensize subwindow index, for screenedges and global menus
	self.mainwin = 0;
	-- active subwindow index
	self.subwinactive = 0;
	-- if set, screen has timer handler added in window 
	self.animtimer = nil;
	-- context callback
	self.context = nil;

	-- similar to space handler
	self.handler = {};
end

-- global function to create a new screen inside a given window. 
-- @param win: the parent wmWindow.
-- @param scene: the scene object. 
-- @param name: the screen name. 
function wmScreen.ED_screen_add(win, scene, name)
	local sc = wmScreen:new();
	sc.scene = scene;
	sc.do_refresh = 1;
	sc.winid = win.winid;

	-- dummy type, no spacedata 
	sc:screen_addarea(left, top, right, bottom, "HEADERDOWN", "SPACE_EMPTY");
	return sc;
end

-- load from xml node
function wmScreen:load(node)
	local attr = node.attr;
	self.left, self.top, self.right, self.bottom = tonumber(attr.left), tonumber(attr.top), tonumber(attr.right), tonumber(attr.bottom);

end

-- save to xml node
function wmScreen:save(node)
end

-- add a screen area in the current screen. 
-- it is screen to manage the bound region of the area so that it is always non-overlapping with other sibbling screen areas. 
function wmScreen:screen_addarea(left, top, right, bottom, headertype, spacetype)
	local screen_area =  wmArea:new();
	screen_area.left = left;
	screen_area.top = top;
	screen_area.right = right;
	screen_area.bottom = bottom;

	screen_area.headertype = headertype;
	screen_area.spacetype = spacetype;

	self.areabase:addtail(sa);
end

