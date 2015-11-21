--[[
Title: MotionRender_Mcml
Author(s): Leio
Date: 2011/05/19
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionRender_Mcml.lua");
local MotionRender_Mcml = commonlib.gettable("MotionEx.MotionRender_Mcml");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local MotionRender_Mcml = commonlib.gettable("MotionEx.MotionRender_Mcml");
local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;
function MotionRender_Mcml.GetParamsByNode(mcmlNode,stage_params)
	local self = MotionRender_Mcml;
	if(mcmlNode)then
		
		local params = {
			x = MotionXmlToTable.GetNumber(mcmlNode,"X"),
			y = MotionXmlToTable.GetNumber(mcmlNode,"Y"),
			w = MotionXmlToTable.GetNumber(mcmlNode,"Width"),
			h = MotionXmlToTable.GetNumber(mcmlNode,"Height"),
			align = MotionXmlToTable.GetString(mcmlNode,"Align") or "_lt",
			alpha = MotionXmlToTable.GetNumber(mcmlNode,"Alpha") or 1,
			assetfile = MotionXmlToTable.GetString(mcmlNode,"AssetFile"),
			visible = MotionXmlToTable.GetBoolean(mcmlNode,"Visible"),
		};
		return params;
	end
end
function MotionRender_Mcml.GetRunTimeParams(motion_handler,run_time,cur_play_node,next_play_node,stage_params)
	local self = MotionRender_Mcml;
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
			alpha = get_value_number("Alpha"),
			align = MotionXmlToTable.GetString(mcmlNode,"Align"),
			assetfile = MotionXmlToTable.GetString(mcmlNode,"AssetFile"),
			visible = MotionXmlToTable.GetBoolean(cur_play_node,"Visible"),
		};
		return params;
	end
end
function MotionRender_Mcml.DoUpdate(filename,instance_name,stage_params,run_time,pre_frame_node,frame_node,next_frame_node,state)
	local self = MotionRender_Mcml;
	--if(state == "jumpframe")then
			--local old_props_param = {};
			--if(pre_frame_node)then
				--old_props_param = MotionRender_Mcml.GetParamsByNode(pre_frame_node,stage_params);
			--end
			--local props_param = MotionRender_Mcml.GetParamsByNode(frame_node,stage_params);
			--if(props_param.assetfile ~= old_props_param.assetfile)then
				--self.DestroyEntity(instance_name);
				--self.CreateEntity(instance_name,props_param);
			--else
				--local bUpdateAnimation;
				--if(not props_param.ismodel)then
					--bUpdateAnimation = true;
				--end
				--self.UpdateEntity(instance_name,props_param,bUpdateAnimation)
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
			--local props_param = MotionRender_Mcml.GetParamsByNode(frame_node,stage_params);
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
function MotionRender_Mcml.CreateEntity(effect_name,props_param)
	local self = MotionRender_Mcml;
	if(not effect_name or not props_param)then return end
	local asset_file =  props_param.assetfile;
	local align = props_param.align;
	local x,y,w,h = props_param.x,props_param.y,props_param.w,props_param.h;
	local visible = props_param.visible;
	if(not asset_file)then
		return
	end
	local container = ParaUI.CreateUIObject("container", effect_name, align,x,y,w,h);
	if(container and container:IsValid())then
		container.background = "";
		container.visible = visible;
		container:AttachToRoot();
		container:GetAttributeObject():SetField("ClickThrough", true);
		local page_tooltip = System.mcml.PageCtrl:new({url = asset_file});
		page_tooltip.click_through = true;
		page_tooltip:Create("_TooltipHelperMCMLPage_", container, "_fi", 0, 0, 0, 0);
	end
	if(MotionXmlToTable.mcmlContainerMap)then
		MotionXmlToTable.mcmlContainerMap[effect_name] = effect_name;
	end
end
function MotionRender_Mcml.DestroyEntity(effect_name)
	local self = MotionRender_Mcml;
	if(not effect_name)then return end
	ParaUI.Destroy(effect_name);
end
function MotionRender_Mcml.UpdateEntity(effect_name,props_param,bUpdateAnimation)
	local self = MotionRender_Mcml;
	if(not effect_name or not props_param)then return end
	local x,y,z = props_param.x,props_param.y,props_param.z;
	local alpha = props_param.alpha;
	local scale = props_param.scale;
	local visible = props_param.visible;
	local ismodel = props_param.ismodel;
	local animation = props_param.animation;
	local _this = ParaUI.GetUIObject(effect_name);
	if(_this and _this:IsValid())then
		_this.visible = visible;	
		if(not visible)then
			return
		end
		local _color = _this.color;
		local color = string.format("255 255 255 %d",math.floor(alpha * 255));
		_this.color = color;
		local _x = _this.x;
		local _y = _this.y;
		_this.x = x or _x;
		_this.y = y or _y;
	end
end
function MotionRender_Mcml.HasEntity(effect_name)
	local _this = ParaUI.GetUIObject(effect_name);
	if(_this and _this:IsValid())then
		return true;
	end
end
