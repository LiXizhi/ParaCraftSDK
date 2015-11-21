--[[
Title: MovieRender_Text
Author(s): Leio
Date: 2012/05/10
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/MovieRender_Text.lua");
local MovieRender_Text = commonlib.gettable("Director.MovieRender_Text");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
local MovieRender_Text = commonlib.gettable("Director.MovieRender_Text");
function MovieRender_Text.Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created)
	local obj_name = movieclip:GetInstanceName(motion_index,line_index);
	local frame_node = frames[frame_index];
	local next_frame_node = frames[next_frame_index];
	if(frame_node)then
		local Text = Movie.GetString(frame_node,"Text");
		if(frame_node[1])then
			Text = frame_node[1];
		end
		local props_param = {
			Text = Text,
		};
		if(need_created)then
			MovieRender_Text.CreateEntity(obj_name);
			MovieRender_Text.UpdateEntity(obj_name,props_param);
		end
	end
end
function MovieRender_Text.CreateEntity(obj_name)
	local _parent=ParaUI.GetUIObject(obj_name);
	if(_parent:IsValid() == false)then
		local _this = ParaUI.CreateUIObject("container",obj_name, "_mb", 0, 0, 0, 80)
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "0 0 0");
		_this:AttachToRoot();
		_this.zorder = 1000;
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", obj_name.."text", "_fi", 0,15,0,15)
		_this.text = "";
		_this.font="System;16";
		_guihelper.SetFontColor(_this, "255 255 255");
		_this.shadow = false;
		_guihelper.SetUIFontFormat(_this,5);
		_parent:AddChild(_this);
	else
		_parent.visible = true;
	end

	local _parent=ParaUI.GetUIObject(obj_name.."top");
	if(_parent:IsValid() == false)then
		local _this = ParaUI.CreateUIObject("container",obj_name.."top", "_mt", 0, 0, 0, 80)
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "0 0 0"); -- _guihelper.SetUIColor(_this, "37 16 5");
		_this.zorder = 1000;
		_this:AttachToRoot();
	else
		_parent.visible = true;
	end
end
function MovieRender_Text.DestroyEntity(movieclip,motion_index,line_index)
	local obj_name = movieclip:GetInstanceName(motion_index,line_index);
	ParaUI.Destroy(obj_name);
	ParaUI.Destroy(obj_name.."top");
end
function MovieRender_Text.UpdateEntity(obj_name,props_param)
	if(not props_param)then
		return
	end
	if(not props_param)then return end
	local txt = props_param.Text or "";
	local _this = ParaUI.GetUIObject(obj_name.."text");
	if(_this:IsValid())then
		_this.text = txt;	
	end
end