--[[
Title: mcml based tooltip
Author(s): Leio, LiXizhi
Date: 2010/11/08
Desc: Whenever a mouse enters a given control (usually button or container), a given mcml page will be displayed. 
If the mouse hovers on the orginal control, the page will always be displayed;
By LiXizhi: implementation is changed from polling timer to onmouseenter event. new property enable_tooltip_hover and click_through added. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/TooltipHelper.lua");
local TooltipHelper = commonlib.gettable("CommonCtrl.TooltipHelper");
TooltipHelper.BindObjTooltip(id,page,force_offset_x,force_offset_y,show_width,show_height,show_duration, enable_tooltip_hover, click_through)

------------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
-- create class
local TooltipHelper = commonlib.gettable("CommonCtrl.TooltipHelper");

-- the parent container. 
local container_name = "_tooltiphelper_container_";

-- mapping from ui id to tooltip params, when ui is deleted, it will be removed from the map automatically. 
TooltipHelper.tooltip_page_pairs = {};

 -- (the width of a mouse cursor)
local default_offset_y = 24;
local default_offset_x = 24;

--bind a tooltip to a UI object
--@param id: object id
--@param page: a html url which show tooltip content, it can also be a function that return the page url. NOTE: The page must NOT contain other tooltip page recursively. 
--@param force_offset_x(optional): default value is 24
--@param force_offset_y(optional): default value is 24
--@param show_width(optional): opitional. if nil, it will be the mcml page's used width
--@param show_height(optional): opitional. if nil, it will be the mcml page's used height
--@param show_duration(optional): default value is 5000 milliseconds
--@param enable_tooltip_hover(optional): true if we allow mouse to hover over the tooltip page. Only set to true if tooltips contains interactive controls.
--@param click_through(optional):true to enable mouse click through, so that mouse events will leak to 3d scene. 
--@param is_enabled(optional): whether the tooltip itself is interactive(may contain buttons, etc)
--@param is_lock_position(optional): is_lock_position, if true, it will lock the tooltip position on first creation. otherwise it will change with the mouse location. 
--@param use_mouse_offset(optional): if nil or true, it will offset relative to the current mouse position, otherwise it is relative to input id. 
--@param screen_padding_bottom(optional): specially alignment for hp_slots_lower tooltip, test against screen bottom when reposition tooltip page
function TooltipHelper.BindObjTooltip(id,page,force_offset_x,force_offset_y,show_width,show_height,show_duration, enable_tooltip_hover, click_through, is_enabled, is_lock_position, use_mouse_offset, screen_padding_bottom, absolute_x, absolute_y, target_parent_name)
	local self = TooltipHelper;
	local uiobj = ParaUI.GetUIObject(id);
	if(not uiobj:IsValid()) then
		return 
	end
	if(use_mouse_offset == nil) then
		use_mouse_offset = true;
	end

	if(page and type(page) == "string") then
		if(System.options.version == "kids") then
			page = string.gsub(page, "ApparelTooltip.html", "GenericTooltip_InOne.html", 1);
		end
	end

	-- add to params map
	self.tooltip_page_pairs[id] = {
		page = page,
		enable_tooltip_hover = enable_tooltip_hover,
		click_through = click_through,
		force_offset_x = tonumber(force_offset_x) or default_offset_x,
		force_offset_y = tonumber(force_offset_y) or default_offset_y,
		absolute_x = absolute_x,
		absolute_y = absolute_y,
		target_parent_name = target_parent_name,
		show_duration = tonumber(show_duration) or 300,
		show_width = show_width,
		show_height = show_height,
		is_lock_position = is_lock_position,
		isopened = false,
		isdestroy = false,	
		is_enabled = is_enabled,
		use_mouse_offset = use_mouse_offset,
		screen_padding_bottom = screen_padding_bottom,
	};

	-- trigger on mouse enter
	uiobj:SetScript("onmouseenter", function()
		local params = self.tooltip_page_pairs[id];
		if(params) then
			if(self.last_id ~= id) then
				-- close previously opened 
				TooltipHelper.HideObjTooltip(self.last_id)
				self.last_id = id;
			end
			if(params.is_lock_position) then
				TooltipHelper.ChangeCloseTimer(10);
			else
				TooltipHelper.ChangeCloseTimer(params.show_duration);
			end
		end
	end);
	-- auto remove on destroy. 
	uiobj:SetScript("ondestroy", function()
		self.UnBindObjTooltip(id);
	end);
end


-- only hide tooltip directly
function TooltipHelper.HideObjTooltip(id)
	if(id)then
		local self = TooltipHelper;
		local params = self.GetParams(id);
		if(params)then
			params.isopened = false;
			params.isdestroy = true;
			self.UpdateObjTooltip(id);
		end
		if(self.last_id == id) then
			self.last_id = nil;
		end
	end
end

-- call this function to hide the last popup
function TooltipHelper.HideLast()
	local self = TooltipHelper;
	if(self.last_id) then
		local id = self.last_id;
		local params = self.GetParams(id);
		if(params)then
			params.isopened = false;
			params.isdestroy = true;
			self.UpdateObjTooltip(id);
		end
		self.last_id = nil;
	end
end

--unbind tooltip and destroy ui object
function TooltipHelper.UnBindObjTooltip(id)
	local self = TooltipHelper;
	if(id)then
		self.tooltip_page_pairs[id] = nil;
		
		if(self.last_id == id) then
			self.last_id = nil;
			local _cont = ParaUI.GetUIObject(container_name);
			_cont:RemoveAll();
			_cont.visible = false;
		end
	end
end

-- call this function to hide the last popup
function TooltipHelper.UnBindLast()
	local self = TooltipHelper;
	if(self.last_id) then
		self.last_id = nil;
		self.tooltip_page_pairs[id] = nil;

		local _cont = ParaUI.GetUIObject(container_name);
		_cont:RemoveAll();
		_cont.visible = false;
		self.tooltip_timer:Change(nil,nil);
	end
end

-- get by params
function TooltipHelper.GetParams(id)
	return TooltipHelper.tooltip_page_pairs[id]
end

-- close the last opened tooltip page after show_duration milliseconds
function TooltipHelper.ChangeCloseTimer(show_duration)
	local self = TooltipHelper;
	self.tooltip_timer = self.tooltip_timer or commonlib.Timer:new({callbackFunc = function(timer)
		local params = TooltipHelper.GetParams(self.last_id);
		if(params) then
			local x, y = ParaUI.GetMousePosition();
			local temp = ParaUI.GetUIObjectAtPoint(x, y);
			local bIsOverSrc = (temp.id == self.last_id);
			if( bIsOverSrc or 
			    ( params.enable_tooltip_hover and params.position_x and params.position_x < x and params.position_y < y and x < (params.position_x+params.width) and y < (params.position_y+params.height) )) then
				if(not params.isopened) then
					params.isopened = true;
					params.isdestroy = false;
					if(not params.use_mouse_offset) then
						x, y = ParaUI.GetUIObject(self.last_id):GetAbsPosition();
					end
					self.UpdateObjTooltip(self.last_id, x + params.force_offset_x, y + params.force_offset_y, params.show_width, params.show_height, params.screen_padding_bottom);
				elseif(bIsOverSrc and not params.is_lock_position) then
					if(params.use_mouse_offset) then
						TooltipHelper.Reposition(nil, params, x + params.force_offset_x, y + params.force_offset_y, nil, nil, params.screen_padding_bottom);
					end
				end
				-- prolong for another duration if mouse still hover on the orignal control, or hover over the tooltip.
				timer:Change(params.show_duration or 300,nil);
			else
				TooltipHelper.HideObjTooltip(self.last_id);
			end
		end
	end});
	self.tooltip_timer:Change(show_duration or 200,nil);
end

-- reposition and put control within screen
-- @param container: can be nil
-- @param params: 
-- @param x,y: desired location. if nil, params are used.
-- @param used_width,used_height: can be nil where params is used. 
-- @param screen_padding_bottom: can be nil
function TooltipHelper.Reposition(container, params, x, y, used_width, used_height, screen_padding_bottom)
	if(not container) then
		container = ParaUI.GetUIObject(container_name);
	end
	-- ensure that the tip container is always in window screen.
	x, y = x or params.position_x, y or params.position_y;
	used_width = used_width or params.width;
	used_height = used_height or params.height;
	screen_padding_bottom = screen_padding_bottom or params.screen_padding_bottom

	local _, _, resWidth, resHeight = ParaUI.GetUIObject("root"):GetAbsPosition();

	resHeight = resHeight - (screen_padding_bottom or 0);

	if((x + used_width) > resWidth) then
		x = resWidth - used_width;
	end
	if(x<0) then x = 0 end
			
	if((y + used_height) > resHeight) then
		y = resHeight - used_height;
	end
	if(y<0) then y = 0 end
	if(params.absolute_x and params.absolute_y) then
		local wnd = ParaUI.GetUIObject(params.target_parent_name);
		local _x, _y = wnd:GetAbsPosition();
		x, y = _x + params.absolute_x, _y + params.absolute_y;
	end
	params.position_x, params.position_y = x, y;
	container:Reposition("_lt", x, y, used_width, used_width);
end

-- private:
function TooltipHelper.UpdateObjTooltip(id, position_x, position_y, width, height, screen_padding_bottom)
	if(not id)then return end
	local self = TooltipHelper;
	local params = self.GetParams(id);
	
	if(params)then
		params.position_x = position_x or 0;
		params.position_y = position_y or 0;
		params.width = width or 1;
		params.height = height or 1;
		
		local isopened = params.isopened;
		
		
		local container = ParaUI.GetUIObject(container_name);
		if(params.isdestroy)then
			container:RemoveAll();
			container.visible = false;

		elseif(params.isopened)then
			if(container:IsValid() == false) then
				if(params.absolute_x and params.absolute_y) then
					local wnd = ParaUI.GetUIObject(params.target_parent_name);
					local x, y = wnd:GetAbsPosition();
					params.position_x, params.position_y = x + params.absolute_x, y + params.absolute_y;
				end
				container = ParaUI.CreateUIObject("container", container_name, "_lt", params.position_x, params.position_y, 1000, 1000);
				container.background = "";
				container.zorder = 50000;
				container:AttachToRoot();
			else
				container:RemoveAll();
				-- make sure that the size is big enough 
				container.width = 1000;
				container.height = 1000;
			end
			container:GetAttributeObject():SetField("ClickThrough", (params.click_through == true));
			container.enabled = (params.is_enabled == true);
			
			local page = params.page;
			if(type(page) == "function") then
				page = page(id);
			end
			local used_width, used_height;
			if(page) then
				container.visible = true;
				local page_tooltip = System.mcml.PageCtrl:new({url = page});
				page_tooltip.click_through = params.click_through;
				page_tooltip:Create("_TooltipHelperMCMLPage_", container, "_fi", 0, 0, 0, 0);
				
				local used_width, used_height = page_tooltip:GetUsedSize();
				params.width, params.height = used_width, used_height;
				
				TooltipHelper.Reposition(container, params);
			else
				container.visible = false;
			end
		else
			container.visible = false;
		end
	end
end

-----------------------
--[[ BroadcastHelper class
use TipsStack instead. this is only for backward compatibility
--]]
-----------------------
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");

local tips_stack_;
local function GetSingletonTipsStack()
	if(tips_stack_) then
		return tips_stack_;
	else
		NPL.load("(gl)script/ide/TipsStack.lua");
		if(System.options.IsMobilePlatform) then
			tips_stack_ = CommonCtrl.TipsStack:new{
				name = "MyTipsStack",
				alignment = "_ctt",
				left = 0,
				top = 80,
				width = 600,
				height = 400,
				LineHeight = 48,
				font = "System;20;norm",
				font_size = 20,
				spacing = 4,
			};
		else
			tips_stack_ = CommonCtrl.TipsStack:new{
				name = "MyTipsStack",
				alignment = "_ctt",
				left = 0,
				top = 80,
				width = 600,
				height = 400,
				font = "System;14",
				spacing = 4,
			};
		end
		return tips_stack_;
	end
end
BroadcastHelper.GetSingletonTipsStack = GetSingletonTipsStack;

-- call this function once after UI or game scene is reset.
function BroadcastHelper.Reset()
	GetSingletonTipsStack():Reset();
end

function BroadcastHelper.Show(bShow)
	GetSingletonTipsStack():Show(bShow);
end

-- clear all current labels. 
-- @param id: if nil, it will clear all. otherwise it will clear only those with same id. 
function BroadcastHelper.Clear(id)
	GetSingletonTipsStack():Clear(id);
end

function BroadcastHelper.PushLabel(args, bPushToFront)
	GetSingletonTipsStack():PushLabel(args, bPushToFront);
end

-----------------------
--[[ BubbleHelper class
NPL.load("(gl)script/ide/TooltipHelper.lua");
local BubbleHelper = commonlib.gettable("CommonCtrl.BubbleHelper");
local container = ParaUI.CreateUIObject("container", "", "_lt", 0, 80, 600, 400);
container:GetAttributeObject():SetField("ClickThrough", true);
container.background="";
container:AttachToRoot();
local id = container.id;
local page = "script/apps/Aries/Team/TeamChatPage.html?chat=가가가가가가가가가가가가가가가가가가가가가가가가가가가가가가가가가가가가";
BubbleHelper.Show(id,page,100,100,230,80,10000,true)
--]]
-----------------------
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/ide/timer.lua");
local BubbleHelper = commonlib.gettable("CommonCtrl.BubbleHelper");
BubbleHelper.tooltip_timer = nil;
BubbleHelper.timer_interval = 100;
BubbleHelper.tooltip_page_pairs = {};

function BubbleHelper.Show(id,page,force_offset_x,force_offset_y,show_width,show_height,show_duration,click_through)
	local self = BubbleHelper;
	local uiobj = ParaUI.GetUIObject(id);
	if(not uiobj:IsValid()) then
		return 
	end
	local params = self.tooltip_page_pairs[id];
	if(params and params.pagectrl)then
		params.cur_duration = 0;
		params.visible = true;
		params.pagectrl.url = page;
		params.pagectrl:Refresh(0);
	else
		-- add to params map
		self.tooltip_page_pairs[id] = {
			id = id,
			page = page,
			click_through = click_through,
			force_offset_x = tonumber(force_offset_x) or 0,
			force_offset_y = tonumber(force_offset_y) or 0,
			show_duration = tonumber(show_duration) or 3000,
			cur_duration = 0,
			show_width = show_width,
			show_height = show_height,
			visible = true,
		};
		self.CreatePageCtrl(id);
	end
	
	-- auto remove on destroy. 
	uiobj:SetScript("ondestroy", function()
		self.UnBindObjTooltip(id);
	end);
	if(not self.is_start)then
		self.is_start = true;
		self.DoStart();
	end
end
function BubbleHelper.CreatePageCtrl(id)
	local self = BubbleHelper;
	local params = self.tooltip_page_pairs[id];
	if(params)then
		local pagectrl = params.pagectrl;
		if(not pagectrl)then
			local container = ParaUI.GetUIObject(id);
			local name = "BubbleHelper"..id;
			local parent = ParaUI.CreateUIObject("container",name,"_lt",params.force_offset_x,params.force_offset_y,params.show_width,params.show_height);
			parent.background="";
			parent:GetAttributeObject():SetField("ClickThrough", params.click_through);
			container:AddChild(parent);
			--parent:AttachToRoot();
			parent.zorder=500;
			pagectrl= System.mcml.PageCtrl:new({url = params.page});
			pagectrl.click_through = params.click_through;
			local name= "BubbleHelper_MCMLPage"..id;
			pagectrl:Create(name, parent, "_fi", 0, 0, 0, 0);
			params.pagectrl = pagectrl;
		end
	end
end
function BubbleHelper.DoStart()
	local self = BubbleHelper;
	self.tooltip_timer = self.tooltip_timer or commonlib.Timer:new({callbackFunc = function(timer)
		local k,node;
		for k,node in pairs(self.tooltip_page_pairs) do
			local id = node.id;
			local container = ParaUI.GetUIObject(id);
			if(container and container:IsValid())then
				node.cur_duration = node.cur_duration + self.timer_interval;
				if(node.cur_duration >= node.show_duration and node.visible)then
					node.visible = false
					self.Update(id);
				else
					self.Update(id);
				end
			end
		end
		
	end});
	self.tooltip_timer:Change(0,self.timer_interval);
end
function BubbleHelper.Update(id)
	local self = BubbleHelper;
	local name = "BubbleHelper"..id;
	local container = ParaUI.GetUIObject(name);
	local args = self.tooltip_page_pairs[id];
	if(args and container and container:IsValid())then

		if(not args.visible)then
			container.visible = false;
			return
		end
		container.visible = true;
		if(not args.fade_in_time) then
			args.fade_in_time = args.show_duration*0.3;
			if(args.fade_in_time>1000) then
				args.fade_in_time = 1000;
			end
		end
		if(not args.fade_out_time) then
			args.fade_out_time = args.show_duration*0.3;
			if(args.fade_out_time>1000) then
				args.fade_out_time = 1000;
			end
		end
		local percent = 1;
		if(args.fade_in_time) then
			percent = args.cur_duration / args.fade_in_time;
			if(percent>1) then
				percent = 1
			end
		end
		if(percent>=1 and args.fade_out_time) then
			percent = (args.show_duration - args.cur_duration) / args.fade_out_time;
			if(percent>1) then
				percent = 1
			end
		end
		if(percent<0) then
			percent = 0;
		end
		local alpha = math.floor(percent * 255);
		local color = string.format("255 255 255 %d",alpha);
		container.colormask = color;
		container:ApplyAnim();
	end
end
--unbind tooltip and destroy ui object
function BubbleHelper.UnBindObjTooltip(id)
	local self = BubbleHelper;
	if(id)then
		self.tooltip_page_pairs[id] = nil;
		local name = "BubbleHelper"..id;
		local _cont = ParaUI.GetUIObject(name);
		if(_cont and _cont:IsValid())then
			_cont:RemoveAll();
		end
	end
end
-----------------------
--[[ BubbleHelper class
NPL.load("(gl)script/ide/TooltipHelper.lua");
local HolidayHelper = commonlib.gettable("CommonCtrl.HolidayHelper");
local b = HolidayHelper.IsHoliday(date)
commonlib.echo(b);
--]]
-----------------------
local HolidayHelper = commonlib.gettable("CommonCtrl.HolidayHelper");
HolidayHelper.year_map = {};
HolidayHelper.isloaded = false;
local function get_day_of_week(dd, mm, yy) 
		local days = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }

		local mmx = mm

		if (mm == 1) then  mmx = 13; yy = yy-1  end
		if (mm == 2) then  mmx = 14; yy = yy-1  end

		local val8 = dd + (mmx*2) +  math.floor(((mmx+1)*3)/5)   + yy + math.floor(yy/4)  - math.floor(yy/100)  + math.floor(yy/400) + 2
		local val9 = math.floor(val8/7)
		local dw = val8-(val9*7) 

		if (dw == 0) then
			dw = 7
		end

		return dw, days[dw];
	end
--check holiday date
--return true
--			if it was found in holiday.xml(kids version)/holiday.teen.xml(teen version) 
--			if it is weekend(kids):friday,saturday,sunday
--			if it is weekend(teen):saturday,sunday
--@param date:be checked date,default value is current day that format is like this:"2011-03-31"
--@param is_teen:true is teen version,otherwise is kids version
--return: true if today is holiday
function HolidayHelper.IsHoliday(date,is_teen)
	local self = HolidayHelper;
	--행쾨경迦老훰槨角솝휑
	--if(is_teen or System.options.version == "teen")then
		--return true;
	--end
	if(not self.isloaded)then
		local path = "config/Aries/Others/holiday.xml";
		if(is_teen)then
			path = "config/Aries/Others/holiday.teen.xml";
		end
		local xmlRoot = ParaXML.LuaXML_ParseFile(path);
		xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
		NPL.load("(gl)script/ide/XPath.lua");
		local childnode;
		for childnode in commonlib.XPath.eachNode(xmlRoot, "//items/year") do
			local value= childnode:GetString("value");
			if(value)then
				local year_table = {
					month_map = {},
					day_map = {},
				};
				self.year_map[value] = year_table;
				for childnode in commonlib.XPath.eachNode(childnode, "//month") do
					local value= childnode:GetString("value");
					if(value)then
						year_table.month_map[value] = true;
					end
				end
				for childnode in commonlib.XPath.eachNode(childnode, "//day") do
					local value= childnode:GetString("value");
					if(value)then
						year_table.day_map[value] = true;
					end
				end
			end
		end
		self.isloaded = true;
	end
	local date = date or ParaGlobal.GetDateFormat("yyyy-MM-dd");
	local year, month, day = string.match(date, "^(%d+)%-(%d+)%-(%d+)$");
	local week = get_day_of_week(day, month, year);
	if(year and month and day) then

		local year_table = self.year_map[year];
		if(year_table)then
			local month_map = year_table.month_map;
			local day_map = year_table.day_map;
			if(month_map and month_map[month])then
				return true;
			end
			local temp_day = month.."-"..day;
			if(day_map and day_map[temp_day])then
				return true;
			end
		end

		year = tonumber(year);
		month = tonumber(month);
		day = tonumber(day);
		if(not is_teen)then
			if(week == 1 or  week == 6 or  week == 7)then
				return true;
			end
		else
			if(week == 1 or week == 7)then
				return true;
			end
		end
	end
	return false;
end