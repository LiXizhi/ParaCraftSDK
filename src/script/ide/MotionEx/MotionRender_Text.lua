--[[
Title: MotionRender_Text
Author(s): Leio
Date: 2011/05/19
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionRender_Text.lua");
local MotionRender_Text = commonlib.gettable("MotionEx.MotionRender_Text");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local MotionRender_Text = commonlib.gettable("MotionEx.MotionRender_Text");
local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;
MotionRender_Text.instance_name = "MotionRender_Text.instance_name";
function MotionRender_Text.GetParamsByNode(mcmlNode,stage_params)
	local self = MotionRender_Text;
	if(mcmlNode)then
		local Text = MotionXmlToTable.GetString(mcmlNode,"Text");
		if(mcmlNode[1])then
			Text = mcmlNode[1];
		end
		local params = {
			Text = Text,
		};
		return params;
	end
end
function MotionRender_Text.DoUpdate(filename,instance_name,stage_params,run_time,pre_frame_node,frame_node,next_frame_node,state,motion_node,motion_line_node,delta)
	local self = MotionRender_Text;
	if(state == "jumpframe")then
		if(not self.HasEntity())then
			local style = "1";
			if(motion_line_node)then
				style = MotionXmlToTable.GetString(motion_line_node,"Style") or "1";
			end
			self.DoEnd();
			local s = string.format("MotionEx.MotionRender_Text.DoPlay_%s",style);
			if(commonlib.getfield(s))then
				local func = commonlib.getfield(s);
				func();
			else
				self.DoPlay_1();
			end
		end
		local props_param = MotionRender_Text.GetParamsByNode(frame_node,stage_params);
		self.Update(instance_name,props_param)
	end
end
function MotionRender_Text.DoPlay_1()
	local self = MotionRender_Text;
	local _parent=ParaUI.GetUIObject(self.instance_name.."container");
	if(_parent:IsValid() == false)then
		local _this = ParaUI.CreateUIObject("container",self.instance_name.."container", "_mb", 0, 0, 0, 80)
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "0 0 0");
		_this:AttachToRoot();
		_this.zorder = 1000;
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", self.instance_name.."text", "_fi", 0,15,0,15)
		_this.text = "";
		_this.font="System;16;bold";
		--_this.scalingx = 1.2;
		--_this.scalingy = 1.2;
		_guihelper.SetFontColor(_this, "255 255 255");
		_this.shadow = false;
		_guihelper.SetUIFontFormat(_this,5);
		_parent:AddChild(_this);
	else
		_parent.visible = true;
	end

	local _parent=ParaUI.GetUIObject(self.instance_name.."top");
	if(_parent:IsValid() == false)then
		local _this = ParaUI.CreateUIObject("container",self.instance_name.."top", "_mt", 0, 0, 0, 80)
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "0 0 0"); -- _guihelper.SetUIColor(_this, "37 16 5");
		_this.zorder = 1000;
		_this:AttachToRoot();
	else
		_parent.visible = true;
	end
end

function MotionRender_Text.DoEnd()
	local self = MotionRender_Text;
	ParaUI.Destroy(self.instance_name.."text");
	ParaUI.Destroy(self.instance_name.."container");
	ParaUI.Destroy(self.instance_name.."top");
end
function MotionRender_Text.Update(instance_name,props_param)
	local self = MotionRender_Text;
	if(not props_param)then return end
	local txt = props_param.Text or "";
	local _this = ParaUI.GetUIObject(self.instance_name.."text");
	if(_this:IsValid())then
		_this.text = txt;	
	end
	
end
function MotionRender_Text.HasEntity()
	local self = MotionRender_Text;
	local _this = ParaUI.GetUIObject(self.instance_name.."container");
	if(_this and _this:IsValid())then
		return true;
	end
end