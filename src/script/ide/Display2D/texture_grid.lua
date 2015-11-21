--[[
Title: a grid of textures
Author(s): LiXizhi
Date: 2011/3/2
Desc: The content of the texture can be rendered into a ui container or a miniscenegraph' render target. 
One can associate a viewport to the grid_texture, so that only a portion of the grid texture is drawn.
This class is useful to construct dynamic rectangular or masked textures showing only a portion of a large grids of bimaps. 
About coordinate system: 
   ^
   |
------->
   |
 left, top should always be smaller than right, bottom. The UI system and 3D system may be different. Sometimes, we may need to set flip_vertical to true
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display2D/texture_grid.lua");
local texture_grid = commonlib.gettable("CommonCtrl.Display2D.texture_grid");
local my_tex = texture_grid:new({name="my_tex", width=128, height=128, render_target_type="container"})
my_tex:clear();
my_tex:set_mask_texture("Texture/Aries/Common/circular_mask.png")
my_tex:set_active_rendering(true)
my_tex:add("obj1", {left=-100,top=-100, right=0, bottom=0, background="Texture/16number.png"});
my_tex:add("obj2", {left=0,top=-100, right=100, bottom=0, background="Texture/16number.png"});
my_tex:add("obj3", {left=0,top=0, right=100, bottom=100, background="Texture/16number.png"});
my_tex:add("obj4", {left=-100,top=0, right=0, bottom=100, background="Texture/16number.png"});
my_tex:clip(-100,-100,100,100);

local _parent = ParaUI.GetUIObject("my_tex_cont")
if(not _parent:IsValid()) then
	_parent = ParaUI.CreateUIObject("container","my_tex_cont", "_lt", 70,70,160,160);
	_parent.candrag = true;
	_parent.fastrender = false;
	ParaUI.GetUIObject("root"):AddChild(_parent);
end
my_tex:draw(_parent, 0,0,160,160);
------------------------------------------------------------
]]
local tostring = tostring;
local math_floor = math.floor;
local texture_grid = commonlib.gettable("CommonCtrl.Display2D.texture_grid");

-- the camera to object distance. this value never changes. 
local unit_dist = 10;

-- shared 3d models.
local g_models = {
	["ground"] = "model/common/map3D/map3D.x", -- for ground texture
};

-- create a new object
-- @param o: {name="my_texture_grid"}
function texture_grid:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o.cached_points = {};
	-- name, obj pairs
	o.objects = {}; 
	-- the center of the viewpoint. 
	o.x = o.x or 0;
	o.y = o.y or 0;
	-- this should be either "container" or "texture"
	o.render_target_type = o.render_target_type or "texture";
	-- this must be a globally unique name, this is also the name of the container or miniscene graph.
	o.name = o.name or "my_texture_grid";
	o.width = o.width or 256;
	o.height = o.height or 256;
	return o
end

-- get object by name
function texture_grid:get(name)
	return self.objects[name];
end


-- add object 
-- @param obj: it must be a table implemetation the DisplayObject2D interface {left,top,right,bottom,background}
function texture_grid:add(name, obj)
	if(not self:get(name)) then
		self.objects[name] = obj;
	end
end

-- remove an object
function texture_grid:remove(name)
	local obj = self:get(name);
	if(obj) then
		-- remove the objects
		self.objects[name] = nil;
	end
end

-- A mask texture applied on top of the texture grid.
-- only used when when render_target_type is "texture"
-- @param texture_path: such as "Texture/Aries/Common/circular_mask.png"
function texture_grid:set_mask_texture(texture_path)
	self.mask_texture_path = texture_path;
end

-- use texture as render target type
-- @param sType: "texture" or "container"
function texture_grid:set_render_target_type(sType)
	render_target_type = sType;
end

-- set whether to enable active rendering
-- default to enable rendering. one can disable active rendering if the texture rarely changes over time.
-- @note this function does not take effect until the first Draw() call. 
-- @param bActiveRendering: if true, the render loop will refresh on each frame. this is the default setting. and useful for texture with some 3d animations. 
function texture_grid:set_active_rendering(bActiveRendering)
	self.is_active_rendering = bActiveRendering;
end

-- clear all objects
function texture_grid:clear()
	self.objects = {};
end

-- whether an object is inside the view port
function texture_grid:intersect_rect(obj)
    return not ( obj.left > self.right or obj.right < self.left or obj.top > self.bottom or obj.bottom < self.top);
end

-- clip the texture using a rectangular shape
-- this is the single most important function to clip and draw to the render target
-- @param left, top, right, bottom: or in logics units
function texture_grid:clip(left, top, right, bottom)
	self.left, self.top, self.right, self.bottom = left, top, right, bottom;
end

-- draw to a given parent window
-- for ui container based texture grid it will create a child container of self.name inside _parent. 
-- @param _parent: on to which container to draw the object, if nil, it will user self.name to get or create on root object 
-- @param ui_left, ui_top, ui_right, ui_bottom: the ui rect, if nil it is 0,0,width,height
-- @param flip_vertical: flip the image vertically. this is usually true 3D minimap. because the y coordiate is different from that of ui.
function texture_grid:draw(_parent, ui_left, ui_top, ui_right, ui_bottom, flip_vertical)
	-- child bug
	local width, height = self.width, self.height;
	if(not ui_left or not ui_top) then
		ui_left,ui_top = 0,0;
	end
	if(not ui_right or not ui_bottom) then
		ui_right,ui_bottom = ui_left+width,ui_top+height;
	end
	width, height = ui_right - ui_left, ui_bottom - ui_top;

	local left, top, right, bottom = self.left, self.top, self.right, self.bottom;

	if(not left) then 
		return 
	end
	if(not _parent) then
		_parent = ParaIO.GetUIObject("root");
	end
	if(_parent) then
		local tex_cont = _parent:GetChild(self.name)
		if(not tex_cont:IsValid()) then
			tex_cont = ParaUI.CreateUIObject("container",self.name, "_lt", 0, 0, width, height);
			tex_cont.background = "";
			tex_cont:GetAttributeObject():SetField("ClickThrough", true);
			if(self.render_target_type == "container") then
				tex_cont.fastrender = false;
			end
			_parent:AddChild(tex_cont);
		end
		tex_cont.x = ui_left;
		tex_cont.y = ui_top;
		tex_cont.width = width;
		tex_cont.height = height;
		_parent = tex_cont;
	end

	if(self.render_target_type == "texture") then
		local scene = ParaScene.GetMiniSceneGraph(self.miniscenegraph_name or self.name);
		local scaling = unit_dist*2/(right - left);
		local nUIIndex = 0;
		local ui_obj;
		local ui_obj_name;
		for name, obj in pairs(self.objects) do
			if( self:intersect_rect(obj) ) then
				ui_obj_name = tostring(nUIIndex);
				ui_obj = scene:GetObject(ui_obj_name);
				if(not ui_obj:IsValid()) then
					if(nUIIndex == 0) then
						-- this is the first time, so intialize the scene
						scene:Reset();
						scene:EnableCamera(true);
						local att = scene:GetAttributeObject();
						att:SetField("ShowSky", false);
						att:SetField("EnableFog", false);
						att:SetField("EnableLight", false);
						att:SetField("EnableSunLight", false);
						scene:SetTimeOfDaySTD(0);
						if(self.mask_texture_path) then
							scene:SetMaskTexture(ParaAsset.LoadTexture("", self.mask_texture_path, 1));
						end
						att = scene:GetAttributeObjectCamera();
						att:SetField("FieldOfView", 1.57);
						scene:CameraSetLookAtPos(0,0,0);
						scene:CameraSetEyePosByAngle(0, 1.57, unit_dist);
					end
					
					local _asset = ParaAsset.LoadStaticMesh("", g_models["ground"]);
					ui_obj = ParaScene.CreateMeshPhysicsObject(ui_obj_name, _asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
					ui_obj:GetAttributeObject():SetField("progress", 1);
					scene:AddChild(ui_obj);
				end
				if( ui_obj:IsValid())then
					local half_size = (obj.right-obj.left) * scaling * 0.5;
					local x,y = (obj.left - left)*scaling - unit_dist + half_size, (obj.top - top)*scaling - unit_dist + half_size;
					-- since y in UI system is -z in 3D coordi system, so we will sometimes need to secretly negate the sign here. 
					if(not flip_vertical) then
						ui_obj:SetPosition(x,0,y);
					else
						ui_obj:SetPosition(x,0,-y);
					end
					

					ui_obj:SetScale(half_size*2);
					ui_obj:SetReplaceableTexture(1,ParaAsset.LoadTexture("",obj.background,1));
					ui_obj:SetVisible(true);
				end
				nUIIndex = nUIIndex + 1;
			end
		end
		-- here we will remove all objects. 
		local bFinished = false;
		while(not bFinished) do
			ui_obj_name = tostring(nUIIndex);
			ui_obj = scene:GetObject(ui_obj_name);
			if(ui_obj:IsValid() and ui_obj:IsVisible()) then
				ui_obj:SetVisible(false);
				nUIIndex = nUIIndex + 1;
			else
				bFinished = true;
			end
		end

		-- in case it is not active rendering, we will start an immediate draw.
		local bActiveRendering = (self.is_active_rendering~=false);
		scene:EnableActiveRendering(bActiveRendering);
		if(not bActiveRendering) then
			scene:Draw(0);
		end

		_parent:SetBGImage(scene:GetTexture());

	else -- if(self.render_target_type == "container") then
		local nUIIndex = 0;
		local ui_obj;
		local ui_obj_name;
	
		local name, obj;
		
		local scalingx = (width) / (right-left);
		local scalingy = (height) / (bottom-top);
		
		for name, obj in pairs(self.objects) do
			if( self:intersect_rect(obj) ) then
				ui_obj_name = tostring(nUIIndex);
				ui_obj = _parent:GetChild(ui_obj_name);
				if(not ui_obj:IsValid()) then
					ui_obj = ParaUI.CreateUIObject("button",ui_obj_name, "_lt", 0, 0, 1,1);
					_guihelper.SetUIColor(ui_obj, "255 255 255");
					_parent:AddChild(ui_obj);
				end
				ui_obj.x = math_floor((obj.left - left)*scalingx+0.5);
				ui_obj.y = math_floor((obj.top - top)*scalingy+0.5);
				ui_obj.width = math_floor((obj.right - obj.left)*scalingx+0.5);
				ui_obj.height = math_floor((obj.bottom - obj.top)*scalingy+0.5);
				if(obj.background) then
					ui_obj.background = obj.background;
				end
				ui_obj.visible = true;
				nUIIndex = nUIIndex + 1;
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
end