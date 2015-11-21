--[[
Title: MovieRender_Image
Author(s): Leio
Date: 2012/05/10
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/MovieRender_Image.lua");
local MovieRender_Image = commonlib.gettable("Director.MovieRender_Image");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
local MovieRender_Image = commonlib.gettable("Director.MovieRender_Image");
local format = format;
local math_floor = math.floor;

local props_param = {};
function MovieRender_Image.Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created)
	local obj_name = movieclip:GetInstanceName(motion_index,line_index);
	local frame_node = frames[frame_index];
	local next_frame_node = frames[next_frame_index];

	local LinkedObject = MovieRender_Image.GetAttachedName(movieclip,motion_index,line_index);
	if(frame_node)then
		local GetNumber = Movie.GetNumber;
		local GetString = Movie.GetString;
		local GetMotionValue = Movie.GetMotionValue;

		local x = GetNumber(frame_node,"X");
		local y = GetNumber(frame_node,"Y");
		local w = GetNumber(frame_node,"Width");
		local h = GetNumber(frame_node,"Height");
		local zorder = GetNumber(frame_node,"ZOrder") or 0;
		local scale_x = GetNumber(frame_node,"ScaleX");
		local scale_y = GetNumber(frame_node,"ScaleY");
		local align = GetString(frame_node,"Align") or "_lt";

		if(align ~= "_lt") then
			x,y,w,h = _guihelper.NormalizeAlignment(align, x,y,w,h);
			align = "_lt"
		end

		local alpha = GetNumber(frame_node,"Alpha") or 1;
		local rotation = GetNumber(frame_node,"Rotation") or 0;
		local assetfile = GetString(frame_node,"AssetFile");
		local visible = Movie.GetBoolean(frame_node,"Visible");
		
		props_param.x, props_param.y, props_param.w, props_param.h, props_param.zorder, props_param.scale_x, props_param.scale_y = x,y,w,h,zorder,scale_x, scale_y;
		props_param.align, props_param.alpha, props_param.rotation, props_param.assetfile, props_param.visible = align, alpha, rotation, assetfile, visible;
		if(need_created)then
			if(LinkedObject and LinkedObject ~= "")then
				MovieRender_Image.UpdateEntity(LinkedObject,props_param);
			else
				MovieRender_Image.CreateEntity(obj_name,props_param);
			end
		end
		if(next_frame_node)then
			local FrameType = GetString(next_frame_node,"FrameType");
			local motion_handler = MotionTypes[FrameType];
			if(motion_handler and frame_node ~= next_frame_node)then
			
				local _x = GetNumber(next_frame_node,"X");
				local _y = GetNumber(next_frame_node,"Y");
				local _w = GetNumber(next_frame_node,"Width");
				local _h = GetNumber(next_frame_node,"Height");
				local _scale_x = GetNumber(next_frame_node,"ScaleX");
				local _scale_y = GetNumber(next_frame_node,"ScaleY");
				local _alpha = GetNumber(next_frame_node,"Alpha") or 1;
				local _rotation = GetNumber(next_frame_node,"Rotation") or 0;
				local _align = GetString(next_frame_node,"Align") or "_lt";
				if(_align ~= "_lt") then
					_x,_y,_w,_h = _guihelper.NormalizeAlignment(_align, _x,_y,_w,_h);
					_align = "_lt";
				end
				local time = root_frame - frame;
				local duration = next_frame - frame;

				x = GetMotionValue(motion_handler,time,duration,x,_x);
				y = GetMotionValue(motion_handler,time,duration,y,_y);
				w = GetMotionValue(motion_handler,time,duration,w,_w);
				h = GetMotionValue(motion_handler,time,duration,h,_h);
				scale_x = GetMotionValue(motion_handler,time,duration,scale_x,_scale_x);
				scale_y = GetMotionValue(motion_handler,time,duration,scale_y,_scale_y);
				alpha = GetMotionValue(motion_handler,time,duration,alpha,_alpha);
				rotation = GetMotionValue(motion_handler,time,duration,rotation,_rotation);

				props_param.x, props_param.y, props_param.w, props_param.h, props_param.zorder, props_param.scale_x, props_param.scale_y = x,y,w,h,zorder,scale_x, scale_y;
				props_param.align, props_param.alpha, props_param.rotation, props_param.assetfile, props_param.visible = align, alpha, rotation, assetfile, visible;

			end
			if(LinkedObject and LinkedObject ~= "")then
				MovieRender_Image.UpdateEntity(LinkedObject,props_param);
			else
				MovieRender_Image.UpdateEntity(obj_name,props_param);
			end
		end
	end
end
function MovieRender_Image.CreateEntity(obj_name,props_param)
	local self = MovieRender_Image;
	if(not props_param)then 
		return
	end
	if(not obj_name or not ParaUI.GetUIObject(obj_name):IsValid())then
		local container = ParaUI.CreateUIObject("container", obj_name, props_param.align or "_lt", props_param.x,props_param.y,props_param.w,props_param.h);
		if(container and container:IsValid())then
			container.background = props_param.asset_file;
			container.visible = props_param.visible;
			container.rotation = (props_param.rotation or 0) * (math.pi/180);
			--_guihelper.SetFontColor(container, "255 255 255 255");
			-- container:GetAttributeObject():SetField("ClickThrough", true);
			--container.enabled = false;
			container.zorder = props_param.zorder or 0;
			container:AttachToRoot();
		end
		self.UpdateEntity(obj_name,props_param);
	end
end

function MovieRender_Image.GetAttachedName(movieclip,motion_index,line_index)
	local line_node = movieclip:GetMotionLineNode(motion_index,line_index);
	if(line_node)then
		local LinkedObject = Movie.GetString(line_node,"LinkedObject");
		return LinkedObject;
	end
end
function MovieRender_Image.ReplaceDynamicNode(frame_node,_this)
	if(not frame_node)then return end
	local attr = frame_node.attr;
	if(_this and _this:IsValid() and attr)then
		attr.X = _this.x;
		attr.Y = _this.y;
		--attr.Width = _this.width;
		--attr.Height = _this.height;
		--attr.ZOrder = _this.zorder;
		--attr.ScaleX = _this.scalingx;
		--attr.ScaleY = _this.scalingy;
		--attr.Align = _this.alignment;
		--local colormask = _this.colormask;
		--if(colormask)then
			--local __,__,__,alpha = string.match(colormask,"(.+) (.+) (.+) (.+)");
			--if(alpha)then
				--alpha = tonumber(alpha) or 255;
				--alpha = alpha / 255;
				--attr.Alpha = alpha;
			--end
		--end
		--local rotation = _this.rotation;
		--if(rotation)then
			--rotation  = rotation/(math.pi/180);
			--attr.Rotation = rotation;
		--end
		--attr.AssetFile = _this.background;
		--attr.Visible = _this.visible;
	end
end
function MovieRender_Image.DestroyEntity(movieclip,motion_index,line_index)
	local LinkedObject = MovieRender_Image.GetAttachedName(movieclip,motion_index,line_index);
	if(not LinkedObject)then
		local obj_name = movieclip:GetInstanceName(motion_index,line_index);
		ParaUI.Destroy(obj_name);
	end
end
function MovieRender_Image.UpdateEntity(obj_name,props_param)
	local self = MovieRender_Image;
	if(not obj_name or not props_param)then return end
	local _this = ParaUI.GetUIObject(obj_name);
	if(_this and _this:IsValid())then
		if(not props_param.visible) then
			_this.visible = false;
			return;
		else
			_this.visible = props_param.visible;
		end
		if(props_param.alpha) then
			_this.colormask = format("255 255 255 %d",math_floor(props_param.alpha * 255));
		end
		if(props_param.x) then
			_this.x = props_param.x;
		end
		if(props_param.y) then
			_this.y = props_param.y;
		end
		if(props_param.w) then
			_this.width = props_param.w;
		end
		if(props_param.h) then
			_this.height =props_param.h;
		end
		if(props_param.scale_x) then
			_this.scalingx = props_param.scale_x;
		end
		if(props_param.scale_y) then
			_this.scalingy = props_param.scale_y;
		end
		if(props_param.rotation) then
			_this.rotation = props_param.rotation * (math.pi/180)
		end
		if(props_param.assetfile) then
			_this.background = props_param.assetfile;
		end
	end
	
end