--[[
Title: Viewport of rectangular or circular shape 
Author(s): LiXizhi
Date: 2011/3/2
Desc: a viewport is a rectangular or circular view into a large number of 2d objects on a large plane. 
Both the 2d object and the viewport itself may be moving.
The viewport will automatically show or hide the 2d objects when they are in or out of the view.  
The usage of a viewport is usually used for rendering game minimap where npc or player location are 2d objects. 
Internally, it will accelerate view port rendering by reusing the same UI objects when the view changes. 
Each viewport can be associated with a texture_grid for image background. 
| *property* | |
| flip_vertical | whether the point will be flipped vertically when displayed. | 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display2D/viewport2d.lua");
local viewport2d = commonlib.gettable("CommonCtrl.Display2D.viewport2d");
local my_view = viewport2d:new();
my_view:set_point_ui_radius(4);
my_view:clip_circle(0, 0, 100);
my_view:clear();
my_view:add("obj1", {x=0,y=0, tooltip="0,0"});
my_view:add("obj2", {x=60,y=60, tooltip="2"});
my_view:add("obj3", {x=-60,y=-60, tooltip="3"});

local _parent = ParaUI.GetUIObject("viewport2d_cont")
if(not _parent:IsValid()) then
	_parent = ParaUI.CreateUIObject("container","viewport2d_cont", "_lt", 70,70,160,160);
	_parent.candrag = true;
	ParaUI.GetUIObject("root"):AddChild(_parent);
end
my_view:draw(_parent, 0,0,160,160);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display2D/texture_grid.lua");
local texture_grid = commonlib.gettable("CommonCtrl.Display2D.texture_grid");

local tostring = tostring;
local math_floor = math.floor;
local viewport2d = commonlib.gettable("CommonCtrl.Display2D.viewport2d");

-- create a new object
-- @param o: {name="my_viewport", shape="circle", flip_vertical=true}
function viewport2d:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o.cached_points = {};
	o.objects = {};
	-- the max number of visible object on the scene.
	o.max_view_object = o.max_view_object or 40;
	-- the center of the viewpoint. 
	o.x = o.x or 0;
	o.y = o.y or 0;
	-- this should be either "rect" or "circle"
	o.shape = o.shape or "rect";
	if(o.shape == "circle") then
		o:clip_circle(0,0, o.radius or 100);
	else
		o:clip_rect(0,0,100,100);
	end
	o.point_ui_radius = 4;
	return o
end

-- set the ui rect in pixel
function viewport2d:set_rect(left, top, width, height)
	self.ui_left = left;
	self.ui_top = top;
	self.ui_width = width;
	self.ui_height = height;
end

-- the default ui object radius for cached buttons.
-- in pixel, default to raidus
function viewport2d:set_point_ui_radius(radius)
	self.point_ui_radius = radius;
end

-- set the max number of visible object on the scene.
function viewport2d:set_max_view_object_count(nCount)
	self.max_view_object = nCount;
end

-- clip the viewport using rectangular shape by center and size of the rect. This can create the zoom in/out effect.
-- @param center_x, center_y: they can be nil. the new center location
-- @param width, height: rect size
function viewport2d:clip_rect(center_x, center_y, width, height)
	self.shape = "rect";
	self.x, self.y = center_x or self.x, center_y or self.y;
	local half_width = width/2;
	local half_height = height/2;
	self.left = self.x - half_width;
	self.right = self.x + half_width;
	self.top = self.y - half_height;
	self.bottom = self.y + half_height;
	self.radius = (half_width + half_height)/2;
	self.radius_sq = self.radius*self.radius;

	if(self.tex_grid) then
		self.tex_grid:clip(self.left, self.right, self.top, self.bottom);
	end
end

-- clip the viewport using circular shape  by radius and center the viewport. the zoom in/out effect.
-- @param center_x, center_y: they can be nil. the new center location
-- @param radius: raidus of the circlar shape for clipping
function viewport2d:clip_circle(center_x, center_y, radius)
	self.shape = "circle";
	self.x, self.y = center_x or self.x, center_y or self.y;
	self.radius = radius;
	self.radius_sq = self.radius*self.radius;
	self.left = self.x - radius;
	self.right = self.x + radius;
	self.top = self.y - radius;
	self.bottom = self.y + radius;

	if(self.tex_grid) then
		self.tex_grid:clip(self.left, self.top, self.right, self.bottom);
	end
end

-- this is a special clipping function. 
-- it ensures that if the current clipping area is larger than the map_boundary, it is centered on the map_boundary. 
-- @param map_boundary: a table like {left=0, top=0, right=100, bottom=100}
function viewport2d:center_if_in_boundary(map_boundary)
	if(map_boundary) then
		if( (self.right-self.left) > (map_boundary.right-map_boundary.left) or 
			(self.bottom-self.top) > (map_boundary.bottom-map_boundary.top)) then
			self:clip_circle((map_boundary.right+map_boundary.left)*0.5, (map_boundary.bottom+map_boundary.top)*0.5, self.radius);
		end
	end
end

-- get object by name
function viewport2d:get(name)
	return self.objects[name];
end

-- add a point object
-- @param obj: it must be a table implemetation the DisplayObject2D interface {x,y,background,tooltip}
-- if obj.ui_type is "container" it will create a container instead of button for display.
-- if obj.draw function is provided, it will be called to render the node object obj.draw(obj, ui_obj).
function viewport2d:add(name, obj)
	if(not self:get(name)) then
		self.objects[name] = obj;
	end
end

-- create get the texture grid object associated with this viewport
-- one can use this function to create a static image background consist of one or multiple images. 
function viewport2d:get_texture_grid()
	if(not self.tex_grid) then
		self.tex_grid  = texture_grid:new({name = self.name})
	end
	return self.tex_grid;
end

-- remove an object
function viewport2d:remove(name)
	local obj = self:get(name);
	if(obj) then
		-- remove the objects
		self.objects[name] = nil;
	end
end

-- clear all objects
function viewport2d:clear()
	-- remove the objects
	-- local name, obj;
	-- for name, obj in pairs(self.objects) do
	-- end
	self.objects = {};
end

-- mark all object as deleted. this is usually used with remove_all_marked. 
-- Usage: mark_all, unmark some, and then remove_all_marked.
-- to unmark, simply set the node.marked to nil.
function viewport2d:mark_all()
	-- remove the objects
	local name, obj;
	for name, obj in pairs(self.objects) do
		obj.marked = true;
	end
end

-- mark all object as deleted
function viewport2d:remove_all_marked()
	-- remove the objects
	local remove_list;
	local name, obj;
	for name, obj in pairs(self.objects) do
		if(obj.marked) then
			remove_list = remove_list or {};
			remove_list[name] = true;
		end
	end
	if(remove_list) then
		for name, obj in pairs(remove_list) do
			self:remove(name);
		end
	end
end



-- whether an object is inside the view port
function viewport2d:is_point_in_view(x,y)
	if(x>self.left and x <self.right and y>self.top and y<self.bottom) then
		if(self.shape == "rect") then
			return true;
		else -- if(self.shape == "circle") then
			return (x - self.x)*(x - self.x)+(y-self.y)*(y-self.y) < self.radius_sq
		end
	end
end

-- get logical position by ui accordiate relative to a ui region. 
-- @param offset_x, offset_y:  offset in pixel
-- @param ui_width, ui_height: the region size
function viewport2d:GetPosByUIPoint(offset_x, offset_y, ui_width, ui_height)
	local left, top, right, bottom = self.left, self.top, self.right, self.bottom;
	if(self.flip_vertical) then
		return left + (right-left) / ui_width * offset_x, top + (bottom-top) / ui_height * (ui_height - offset_y);
	else
		return left + (right-left) / ui_width * offset_x, top + (bottom-top) / ui_height * offset_y;
	end
end

-- call this function to render the object
-- @param _parent: the parent ui object on to which to draw all internal objects. 
function viewport2d:draw(_parent, ui_left, ui_top, ui_right, ui_bottom)
	ui_left = ui_left or self.ui_left;
	ui_top = ui_top or self.ui_top;
	ui_right = ui_right or self.ui_right;
	ui_bottom = ui_bottom or self.ui_bottom;

	local nUIIndex = 0;
	local ui_obj;
	local ui_obj_name;
	if(not _parent) then
		_parent = ParaUI.GetUIObject("root");
	end
	
	if(self.tex_grid) then
		-- in case it is associated with a texture grid, draw it. 
		self.tex_grid:draw(_parent, ui_left, ui_top, ui_right, ui_bottom); -- self.flip_vertical: this is not necesary
	end

	local left, top, right, bottom = self.left, self.top, self.right, self.bottom;
	local name, obj;
	local scalingx = (ui_right - ui_left) / (right-left);
	local scalingy = (ui_bottom - ui_top) / (bottom-top);
	for name, obj in pairs(self.objects) do
		local x, y = obj.x, obj.y;
		local objwidth = obj.width or self.point_ui_radius*2;
		local objheight = obj.height or self.point_ui_radius*2;

		if(x>left and x <right and y>top and y<bottom and self:is_point_in_view(x,y)) then
			ui_obj_name = tostring(nUIIndex);
			ui_obj = _parent:GetChild(ui_obj_name);
			
			
			if(not ui_obj:IsValid()) then
				if(obj.ui_type == "container") then
					ui_obj = ParaUI.CreateUIObject("container",ui_obj_name, "_lt", 0, 0, objwidth, objheight);
					if(obj.click_through~=false) then
						ui_obj:GetAttributeObject():SetField("ClickThrough", true);
					end
				else
					ui_obj = ParaUI.CreateUIObject("button",ui_obj_name, "_lt", 0, 0, objwidth, objheight);
				end
				
				_parent:AddChild(ui_obj);
			else
				ui_obj.width, ui_obj.height = objwidth, objheight;
			end 
			
			
			ui_obj.x = math_floor(ui_left + (x - left)*scalingx-objwidth/2 + 0.5);
			if(self.flip_vertical) then
				ui_obj.y = math_floor(ui_bottom - (ui_top + (y - top)*scalingy)-objheight/2 + 0.5);
			else
				ui_obj.y = math_floor(ui_top + (y - top)*scalingy-objheight/2 + 0.5);
			end
			-- commonlib.echo({ui_obj.x, ui_obj.y})
			if(obj.draw) then
				obj:draw(ui_obj);
			else
				-- if the object does not have a draw function, we will draw it. 
				if(obj.background) then
					ui_obj.background = obj.background;
				end
				if(obj.text) then
					ui_obj.text = obj.text;
				end
				if(obj.tooltip) then
					ui_obj.tooltip = obj.tooltip;
					--ui_obj.text = obj.tooltip;
				end
				if(obj.rotation) then
					ui_obj.rotation = obj.rotation;
				end
			end
			ui_obj.visible = true;
			nUIIndex = nUIIndex + 1;
			if(self.max_view_object < nUIIndex) then
				break;
			end
		end
	end
	-- here we will remove all objects. 
	local bFinished = false;
	while(not bFinished) do
		ui_obj_name = tostring(nUIIndex);
		ui_obj = _parent:GetChild(ui_obj_name);
		if(ui_obj:IsValid() and ui_obj.visible) then
			ui_obj.visible = false;
			nUIIndex = nUIIndex + 1;
		else
			bFinished = true;
		end
	end
end