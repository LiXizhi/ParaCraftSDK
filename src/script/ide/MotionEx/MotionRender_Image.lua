--[[
Title: MotionRender_Image
Author(s): Leio
Date: 2011/05/21
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionRender_Image.lua");
local MotionRender_Image = commonlib.gettable("MotionEx.MotionRender_Image");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local MotionRender_Image = commonlib.gettable("MotionEx.MotionRender_Image");
local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;
function MotionRender_Image.GetParamsByNode(mcmlNode,stage_params)
	local self = MotionRender_Image;
	if(mcmlNode)then
		
		local params = {
			x = MotionXmlToTable.GetNumber(mcmlNode,"X"),
			y = MotionXmlToTable.GetNumber(mcmlNode,"Y"),
			w = MotionXmlToTable.GetNumber(mcmlNode,"Width"),
			h = MotionXmlToTable.GetNumber(mcmlNode,"Height"),
			zorder = MotionXmlToTable.GetNumber(mcmlNode,"ZOrder") or 0,
			scale_x = MotionXmlToTable.GetNumber(mcmlNode,"ScaleX"),
			scale_y = MotionXmlToTable.GetNumber(mcmlNode,"ScaleY"),
			align = MotionXmlToTable.GetString(mcmlNode,"Align") or "_lt",
			alpha = MotionXmlToTable.GetNumber(mcmlNode,"Alpha") or 1,
			rotation = MotionXmlToTable.GetNumber(mcmlNode,"Rotation") or 0,
			assetfile = MotionXmlToTable.GetString(mcmlNode,"AssetFile"),
			visible = MotionXmlToTable.GetBoolean(mcmlNode,"Visible"),
		};
		return params;
	end
end
function MotionRender_Image.GetRunTimeParams(motion_handler,run_time,cur_play_node,next_play_node,stage_params)
	local self = MotionRender_Image;
	if(motion_handler and cur_play_node and next_play_node)then
		
		local start_time = MotionXmlToTable.GetNumber(cur_play_node,"Time");
		local end_time = MotionXmlToTable.GetNumber(next_play_node,"Time");
		local duration = end_time - start_time;
		local time = run_time - start_time;

		local function get_value_number(p)
			local from = MotionXmlToTable.GetNumber(cur_play_node,p);
			local to = MotionXmlToTable.GetNumber(next_play_node,p);
			local begin = from;
			local change = to - from;
			local value = motion_handler( time , begin , change , duration );	
			return value;
		end
		local params = {
			x = get_value_number("X") ,
			y = get_value_number("Y") ,
			w = get_value_number("Width") ,
			h = get_value_number("Height") ,
			scale_x = get_value_number("ScaleX") ,
			scale_y = get_value_number("ScaleY") ,
			rotation = get_value_number("Rotation"),
			alpha = get_value_number("Alpha"),
			align = MotionXmlToTable.GetString(cur_play_node,"Align"),
			assetfile = MotionXmlToTable.GetString(cur_play_node,"AssetFile"),
			visible = MotionXmlToTable.GetBoolean(cur_play_node,"Visible"),
		};
		return params;
	end
end
function MotionRender_Image.DoUpdate(filename,instance_name,stage_params,run_time,pre_frame_node,frame_node,next_frame_node,state)
	local self = MotionRender_Image;
	--if(state == "jumpframe")then
			--local old_props_param = {};
			--if(pre_frame_node)then
				--old_props_param = MotionRender_Image.GetParamsByNode(pre_frame_node,stage_params);
			--end
			--local props_param = MotionRender_Image.GetParamsByNode(frame_node,stage_params);
			--if(props_param.assetfile ~= old_props_param.assetfile)then
				--self.DestroyEntity(instance_name);
				--self.CreateEntity(instance_name,props_param);
			--else
				--self.UpdateEntity(instance_name,props_param)
			--end
			--
	--elseif(state == "update")then
		--if(frame_node and next_frame_node)then
			--local cur_time = MotionXmlToTable.GetNumber(frame_node,"Time");
			--local frame_type = MotionXmlToTable.GetString(next_frame_node,"FrameType");
			--local motion_handler = MotionTypes[frame_type];
			--if(motion_handler)then
				--local props_param = self.GetRunTimeParams(motion_handler,run_time,frame_node,next_frame_node,stage_params);
				--self.UpdateEntity(instance_name,props_param)
			--end
--
		--elseif(frame_node and not next_frame_node)then
			----last frame
			--local props_param = MotionRender_Image.GetParamsByNode(frame_node,stage_params);
			--self.CreateEntity(instance_name,props_param);
		--end
	--end
	if(frame_node)then
		local props_param = self.GetParamsByNode(frame_node,stage_params);
		if(state == "jumpframe")then
			self.DestroyEntity(instance_name);
			self.CreateEntity(instance_name,props_param);
		elseif(state == "update")then
			if(not self.HasEntity(instance_name))then
				self.CreateEntity(instance_name,props_param);
				return;
			end
			local cur_time = MotionXmlToTable.GetNumber(frame_node,"Time");
			local frame_type = MotionXmlToTable.GetString(next_frame_node,"FrameType");
			local motion_handler = MotionTypes[frame_type];
			if(motion_handler)then
				local props_param = self.GetRunTimeParams(motion_handler,run_time,frame_node,next_frame_node,stage_params);
				self.UpdateEntity(instance_name,props_param)
			end
		end
	end
end
function MotionRender_Image.CreateEntity(effect_name,props_param)
	local self = MotionRender_Image;
	if(not effect_name or not props_param)then return end
	local asset_file =  props_param.assetfile;
	local align = props_param.align;
	local x,y,w,h = props_param.x,props_param.y,props_param.w,props_param.h;
	local zorder = props_param.zorder;
	local alpha = props_param.alpha;
	local scale_x = props_param.scale_x;
	local scale_y = props_param.scale_y;
	local rotation = props_param.rotation;
	local visible = props_param.visible;
	asset_file = asset_file or "";
	if(not align or align == "")then
		align = "_lt";
	end
	rotation = rotation or 0;
	rotation = rotation * (math.pi/180);
	local container = ParaUI.CreateUIObject("container", effect_name, align,x,y,w,h);
	if(container and container:IsValid())then
		container.background = asset_file;
		container.visible = visible;
		container.rotation = rotation;
		container:AttachToRoot();
		container.zorder = zorder;
		container:GetAttributeObject():SetField("ClickThrough", true);
	end
	self.UpdateEntity(effect_name,props_param);
	if(MotionXmlToTable.mcmlContainerMap)then
		MotionXmlToTable.mcmlContainerMap[effect_name] = effect_name;
	end
end
function MotionRender_Image.DestroyEntity(effect_name)
	local self = MotionRender_Image;
	if(not effect_name)then return end
	ParaUI.Destroy(effect_name);
end
function MotionRender_Image.UpdateEntity(effect_name,props_param)
	local self = MotionRender_Image;
	if(not effect_name or not props_param)then return end
	local align = props_param.align;
	local x,y,w,h = props_param.x,props_param.y,props_param.w,props_param.h;
	local alpha = props_param.alpha;
	local scale_x = props_param.scale_x;
	local scale_y = props_param.scale_y;
	local rotation = props_param.rotation;
	local visible = props_param.visible;
	local asset_file =  props_param.assetfile;
	local _this = ParaUI.GetUIObject(effect_name);
	if(_this and _this:IsValid())then
		rotation = rotation or 0;
		rotation = rotation * (math.pi/180);
		_this.visible = visible;	
		if(not visible)then
			return
		end
		local _color = _this.color;
		local color = string.format("255 255 255 %d",math.floor(alpha * 255));
		_this.color = color;
		local _x = _this.x;
		local _y = _this.y;
		local _width = _this.width;
		local _height = _this.height;
		local _scalingx = _this.scalingx;
		local _scalingy = _this.scalingy;
		local _rotation = _this.rotation;
		local _background = _this.background;
		_this.x = x or _x;
		_this.y = y or _y;
		_this.width = w or _width;
		_this.height = h or _height;
		_this.scalingx = scale_x or _scalingx;
		_this.scalingy = scale_y or _scalingy;
		_this.rotation = rotation or _rotation;
		_this.background = asset_file or background;
	end
end
function MotionRender_Image.HasEntity(effect_name)
	local _this = ParaUI.GetUIObject(effect_name);
	if(_this and _this:IsValid())then
		return true;
	end
end
