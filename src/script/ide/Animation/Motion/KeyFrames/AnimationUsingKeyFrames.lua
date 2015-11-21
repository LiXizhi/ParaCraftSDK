--[[
Title: AnimationUsingKeyFrames
Author(s): Leio Zhang
Date: 2008/7/21
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/AnimationUsingKeyFrames.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/TimeSpan.lua");
NPL.load("(gl)script/ide/Motion/SimpleEase.lua");
local AnimationUsingKeyFrames = commonlib.inherit(CommonCtrl.Animation.Motion.MovieClipBase,{
	property = "AnimationUsingKeyFrames",
	name = "AnimationUsingKeyFrames_instance",
	TargetName = nil,
	TargetProperty = nil,
	Duration = nil,
	keyframes = nil,
	mcmlTitle = "pe:animationUsingKeyFrames",
	--keyframes = {},
});  
commonlib.setfield("CommonCtrl.Animation.Motion.AnimationUsingKeyFrames",AnimationUsingKeyFrames);
-------------------------------------------------------------------------
-- override parent method
-------------------------------------------------------------------------
function AnimationUsingKeyFrames:UpdateTime(frame)	
	if(not frame)then return; end	
end
---------------------------------------------------------------------------
function AnimationUsingKeyFrames:UpdateSelected(keyframe)
	local k,v;
	for k,v in ipairs(self.keyframes) do
		if(v == keyframe)then
			if(keyframe)then
				keyframe.IsSelected = true;
			end
		else
			v.IsSelected = false;
		end
		--local target = v:GetValue();
				--if(target and target.Property)then
					--local targetType = target.Property;
					--if(targetType == "ActorTarget" or targetType == "BuildingTarget" or targetType == "PlantTarget")then
						--local curObj = CommonCtrl.Animation.Motion.TargetResourceManager[target.Name];
						--if(curObj and curObj:IsValid())then
							----curObj:GetAttributeObject():SetField("showboundingbox", v.IsSelected);
							----if(v.IsSelected)then
								----Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_SelectObject, obj=curObj, group=-1, effect = "boundingbox"});
							----else
								----Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeselectObject, obj = nil});
							----end
						--end
					--end
				--end
	end
	self:Draw();
end
function AnimationUsingKeyFrames:Draw()
	local _this=ParaUI.CreateUIObject("container","main","_fi",0,0,0,0);
	_this.background = "";
	if(self._uiParent==nil) then
			_this:AttachToRoot();
	else
		self._uiParent:AddChild(_this);
	end
	local _parent = _this;
	local left,top,width,height = 0,
								0,
								CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.FrameWidth,
								CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.FrameHeight;
	for kk,vv in ipairs(self.keyframes) do
				local keyframe = vv;
				local frame = keyframe:GetFrames();
				local min_step = Map3DSystem.Movie.MovieTimeLine.MinStep or 1;
				left,top,width,height = frame*width/min_step,top,width,height;
				_this=ParaUI.CreateUIObject("button",self.name.."frame"..frame,"_lt",left,top,width,height);
				_this.text = "";
				local _parentName = self._parentName;
				_this.onclick = string.format(";Map3DSystem.Movie.MovieClipEditor.OnSelectedKeyFrame(%q, %q, %q, %q)",self.MovieClipEditorName, keyframe.name, keyframe:GetKeyTime(), _parentName);				
				if(keyframe.IsSelected)then
					_this.background = "Texture/3DMapSystem/common/user.png";
					_this.color="0 0 0"
				else
					_this.background = "Texture/3DMapSystem/common/user.png";
				end
				local value = keyframe:GetKeyTime();
				local info = string.format("%s",value);				
				_this.tooltip = info;
				_parent:AddChild(_this);
	end		
end
function AnimationUsingKeyFrames:SetMaxFrameNum()
	local frame = self:GetMaxFrameNum();
	if(frame)then
		self:SetDuration(frame);
	end
end
function AnimationUsingKeyFrames:GetMaxFrameNum()
	local frame = 0;
	local k,v;
	for k,v in ipairs(self.keyframes) do
		local keyframe = v;
		if(keyframe)then
			local len = CommonCtrl.Animation.Motion.TimeSpan.GetFrames(keyframe.KeyTime);
			if(len>frame)then
				frame = len;
			end
		end
	end  
	if(frame < self:GetDuration())then
		frame = self:GetDuration();
	end   
	return frame;       
end
function AnimationUsingKeyFrames:clear()
	self.keyframes = {};
end
function AnimationUsingKeyFrames:addKeyframe(keyframe)
	if(not keyframe)then return; end
	if(not self.keyframes)then
		self.keyframes = {};
	end
	table.insert(self.keyframes,keyframe);
	keyframe:SetParent(self);
	keyframe.index = table.getn(self.keyframes);	
	self:SortChildren()
	local d = self:GetMaxFrameNum()+1;
	if(d)then
		self:SetDuration(d);
	end
end
function AnimationUsingKeyFrames:SortChildren(compareFunc)
	compareFunc = compareFunc or CommonCtrl.TreeNode.GenerateLessCFByField("ToFrame");
	-- quick sort
	table.sort(self.keyframes, compareFunc)
	-- rebuild index. 
	local i, node
	for i,node in ipairs(self.keyframes) do
		node.index = i;
	end
end
function AnimationUsingKeyFrames:removeKeyframe(keyframe)
	if(not keyframe or not self.keyframes)then return; end
	local i, node
	for i,node in ipairs(self.keyframes) do
		if(node == keyframe)then
			self:removeKeyframeByIndex(i);
		end
	end
end
function AnimationUsingKeyFrames:removeKeyframeByIndex(index)
	if(not index or not self.keyframes)then return; end
	local len = table.getn(self.keyframes);
	if(index>len)then return ; end
	table.remove(self.keyframes,index);
	self:SortChildren();
end
function AnimationUsingKeyFrames:getCurrentKeyframe(time)
	if(self:indexOutOfRange(time) or not self.keyframes)then return  end;
	local len = table.getn(self.keyframes);
	local i = len;
	
	while(i >= 1) do	
		local kf = self.keyframes[i];
		if(kf)then
			local frames = kf:GetFrames();
			if ( frames <=time ) then
				if(frames == time)then
					if(not kf:GetActivate())then
						kf:SetActivate(true);
					end
				end				
				return kf;
			end
		end
			i = i-1;
	end
end
function AnimationUsingKeyFrames:getNextKeyframe(time)
	if(self:indexOutOfRange(time) or not self.keyframes)then return  end;
	local i = 1;
	local len = table.getn(self.keyframes);
	for i = 1,len do
		local kf = self.keyframes[i];
		if(kf)then
			local frames = kf:GetFrames();
			if (time < frames) then
				return kf;
			end
		end
	end
end

function AnimationUsingKeyFrames:indexOutOfRange(time)
		return (not time or time < 0);
end
function AnimationUsingKeyFrames:GetFrameLength()
	local frames;
	if(not self.keyframes)then
		return ;
	end
	local len = table.getn(self.keyframes);
	if(not self.Duration)then
		local keyframe = self.keyframes[len];
		if(not keyframe) then return 0; end
		frames = keyframe:GetFrames();
		return frames;
	end	
	frames = CommonCtrl.Animation.TimeSpan.GetFrames(self.Duration);
	return frames;
end
function AnimationUsingKeyFrames:GetLength()
	if(not self.keyframes)then return; end
	return table.getn(self.keyframes);
end
function AnimationUsingKeyFrames:hasKeyFrame(keytime)
	if(not keytime or not self.keyframes)then return; end
	local k,keyframe;
	local frame = CommonCtrl.Animation.Motion.TimeSpan.GetFrames(keytime);
	for k,keyframe in ipairs(self.keyframes) do
		if(keyframe:GetFrames() == frame)then
			return keyframe;
		end
	end
end
-- reverse a keyframes class to mcml string
function AnimationUsingKeyFrames:ReverseToMcml()
	if(not self.TargetName or not self.TargetProperty)then return "" end
	local node_value = "";
	local k,frame;
	for k,frame in ipairs(self.keyframes) do
		node_value = node_value..frame:ReverseToMcml();
	end
	local p_node = "\r\n";
	local str = string.format([[<%s TargetName="%s" TargetProperty="%s">%s</%s>%s]],self.mcmlTitle,self.TargetName,self.TargetProperty,"\r\n"..node_value,self.mcmlTitle,p_node);
	return str;
end
-- reverse a keyframes class to mcml node
function AnimationUsingKeyFrames:ReverseToMcmlNode()
	local frames = self:ReverseToMcml();
	if(frames)then
		--frames = ParaMisc.EncodingConvert("", "utf-8", frames);
		local frames = ParaXML.LuaXML_ParseString(frames);
		if(frames)then
			frames = Map3DSystem.mcml.buildclass(frames);
			frames = frames[1];
			return frames;
		end	
	end
end
function AnimationUsingKeyFrames:GetMaxTimeFrame()
	local k,keyframe;
	local num = 0;
	local targetKyeFrame = self.keyframes[1];
	for k,keyframe in ipairs(self.keyframes) do
		local temp_num = keyframe:GetFrames();
		if(temp_num>num)then
			num = temp_num;
			targetKyeFrame = keyframe;
		end
	end
	return targetKyeFrame;
end
function AnimationUsingKeyFrames:ReplaceTargetName(oldName,newName)
	if(not oldName or not newName)then return end
	if(oldName == self.TargetName or oldName == self.TargetProperty)then
		self.TargetName = newName;
		self.TargetProperty = newName;
	end		
end
