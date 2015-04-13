--[[
Title: context object
Author(s): LiXizhi
Date: 2010.10.23
Desc: provides handy function to retrieve data on context object. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/WindowManager/wm_context.lua");
local wmContext = commonlib.gettable("PETools.WindowManager.wmContext");
------------------------------------------------------------
]]
local wmContext = commonlib.inherit(nil, commonlib.gettable("PETools.WindowManager.wmContext"));

function wmContext:ctor()
	-- /* windowmanager context */
	self.wm_manager = nil;
	self.wm_window = nil;
	self.wm_screen = nil;
	self.wm_area = nil;
	self.wm_region = nil;
	self.wm_menu = nil;
	self.wm_store = nil;

	-- the main scene
	self.main = nil;
	self.scene = nil;
	self.recursion = nil;
	self.render = nil;
end

function wmContext:get_manager()
	return self.wm_manager;
end

function wmContext:set_manager(winManager)
	self.wm_manager = winManager;
	self.wm_window = nil;
	self.wm_screen = nil;
	self.wm_area = nil;
	self.wm_region = nil;
end

function wmContext:get_window()
	return self.wm_window;
end

function wmContext:set_window(win)
	self.wm_window = win;
	if(win) then
		self.wm_screen = win.screen;
	else
		self.wm_screen = nil;
	end
	if(self.wm_screen) then
		self.scene = self.wm_screen.scene;
	else
		self.scene = nil;
	end
	self.wm_area = nil;
	self.wm_region = nil;
end

function wmContext:get_screen()
	return self.wm_screen;
end

function wmContext:set_screen(screen)
	self.wm_screen = screen;
	if(self.wm_screen) then
		self.scene = self.wm_screen.scene;
	else
		self.scene = nil;
	end
	self.wm_area = nil;
	self.wm_region = nil;
end

function wmContext:get_area()
	return self.wm_area;
end

function wmContext:set_area(area)
	self.wm_area = area;
	self.wm_region = nil;
end

function wmContext:get_region()
	return self.wm_region;
end

function wmContext:set_region(region)
	self.wm_region = region;
end

function wmContext:get_menu()
	return self.wm_menu;
end

function wmContext:get_store()
	return self.wm_store;
end

function wmContext:get_mainscene()
	return self.wm_store;
end

function wmContext:get_view3d()
	if(self.wm_area and self.wm_area.spacetype == "SPACE_VIEW3D") then
		return self.wm_area.spacedata.first;
	end
end

function wmContext:get_region_view3d()
	if(self.wm_area and self.wm_area.spacetype == "SPACE_VIEW3D") then
		if(self.wm_region) then
			return self.wm_region.regiondata;
		end
	end
end

function wmContext:set_main(main)
	self.main= main;
end

function wmContext:get_main()
	return self.main;
end

function wmContext:set_scene(scene)
	self.scene= scene;
end

function wmContext:get_scene()
	return self.scene;
end
