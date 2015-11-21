--[[
Title: KeyFrames
Author(s): Leio Zhang
Date: 2009/3/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Storyboard/KeyFrames.lua");
------------------------------------------------------------
--]]
local KeyFrames={
	TargetName = "",
};
commonlib.setfield("CommonCtrl.Storyboard.KeyFrames",KeyFrames);
NPL.load("(gl)script/ide/Transitions/TweenEquations.lua");
function KeyFrames:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	
	return o
end
function KeyFrames:Init()
	self.name = ParaGlobal.GenerateUniqueID();
	self.childrenList = {};
end	
function KeyFrames:GetBindParams()
	return self.initBindParams;
end
-- 记录对象的初始属性
function KeyFrames:BindObjectParams(bindObj)
	bindObj = bindObj or CommonCtrl.Storyboard.Storyboard.GetHookObj(self.TargetName);
	if(bindObj)then
		local params = bindObj:GetEntityParams();
		self.initBindParams = params;
	end
end
function KeyFrames:DoPrePlay()
	local bindObj = CommonCtrl.Storyboard.Storyboard.GetHookObj(self.TargetName);
	if(bindObj and self.initBindParams)then
		bindObj:SetEntityParams(self.initBindParams);
		bindObj:UpdateEntity();
		
		local keyFrame = self.childrenList[1];
		if(keyFrame)then
			local toFrame = keyFrame:ToFrame();
			if(toFrame ~= 0)then
				local firstKeyFrame = CommonCtrl.Storyboard.KeyFrame:new();
				firstKeyFrame:SetKeyTime("00:00:00");
				local target = CommonCtrl.Storyboard.Target:new{
					params = {
						X = self.initBindParams.x,
						Y = self.initBindParams.y,
						Z = self.initBindParams.z,
						Facing = self.initBindParams.facing,
						Scaling = self.initBindParams.scaling,
						Alpha = self.initBindParams.alpha,
						Visible = self.initBindParams.visible,
						Animation = self.initBindParams.animation,
						Dialog = self.initBindParams.dialog,
					},
				}
				firstKeyFrame:SetTarget(target);
				self:AddChild(firstKeyFrame);
			end
		end
	end
end
function KeyFrames:AddChild(child)
	if(not child)then return; end
	table.insert(self.childrenList,child);
	child.index = table.getn(self.childrenList);
	child.__frame = child:ToFrame();	
	child:SetParent(self);
	self:SortChildren();
    self:UpdateDuration()
end
function KeyFrames:UpdateDuration()
	local d = self:GetMaxFrameNum();
	self:SetDuration(d);
end
function KeyFrames:SetTargetName(d)
	self.TargetName = d;
	self:BindObjectParams()
end
function KeyFrames:GetTargetName()
	return self.TargetName;
end
function KeyFrames:SetDuration(d)
	self._duration = d;
end
function KeyFrames:GetDuration()
	return self._duration;
end
function KeyFrames:Update(frame)
	self:DO_UpdateTime(frame)
end
function KeyFrames:SortChildren()
	local compareFunc = CommonCtrl.TreeNode.GenerateLessCFByField("__frame");
	-- quick sort
	table.sort(self.childrenList, compareFunc)
	-- rebuild index. 
	local i, node
	for i,node in ipairs(self.childrenList) do
		node.index = i;
	end
end
function KeyFrames:GetMaxFrameNum()
	local frame = 0;
	local k,v;
	for k,v in ipairs(self.childrenList) do
		local keyframe = v;
		if(keyframe)then
			local len =keyframe:ToFrame();
			if(len>frame)then
				frame = len;
			end
		end
	end  
	return frame;       
end
function KeyFrames:getCurrentKeyframe(time)
	local len = table.getn(self.childrenList);
	local i = len;
	
	while(i >= 1) do	
		local kf = self.childrenList[i];
		if(kf)then
			local frames = kf:ToFrame();
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
function KeyFrames:getNextKeyframe(time)
	local i = 1;
	local len = table.getn(self.childrenList);
	for i = 1,len do
		local kf = self.childrenList[i];
		if(kf)then
			local frames = kf:ToFrame();
			if (time < frames) then
				return kf;
			end
		end
	end
end

function KeyFrames:DO_UpdateTime(frame)
	if(not frame)then return; end
	local result = nil;
	local curKeyframe = self:getCurrentKeyframe(frame);
	if(not curKeyframe)then 
		--commonlib.echo("curKeyframe is nil~~~");
		return; 
	end
	local begin = curKeyframe:GetTarget();
	local isActivate = curKeyframe:GetActivate();
	---------------------local lastFrame = self:GetLastFrame();
	--commonlib.echo({isActivate,curKeyframe.name,frame});
	if(not begin)then 
		--commonlib.echo("begin is nil~~~"); 
		return;
	end	
	if(isActivate)then
		-- update discrete property
		local params = begin:GetParams();
		if(frame == 0)then
			params.delta_X = params.X;
			params.delta_Y = params.Y;
			params.delta_Z = params.Z;
		end
		CommonCtrl.Storyboard.Target.Update(params,curKeyframe);
		curKeyframe:SetActivate(false);	
		return;
	end
	local nextKeyframe = self:getNextKeyframe(frame);	
	if (not nextKeyframe or nextKeyframe.parentProperty =="DiscreteKeyFrame") then	
		--commonlib.echo("nextKeyframe is nil~~~");	
		return;
	end
	self:UpdatePropertyValue(isActivate,lastFrame,frame,curKeyframe,nextKeyframe)
end
function KeyFrames:UpdatePropertyValue(isActivate,lastFrame,frame,curKeyframe,nextKeyframe)
	if(not frame or not curKeyframe or not nextKeyframe)then return; end
	local timeFromKeyframe = frame - curKeyframe:ToFrame();
	local keyframeDuration = nextKeyframe:ToFrame() - curKeyframe:ToFrame();	
	local simpleEase = curKeyframe.SimpleEase;
	if(not simpleEase)then simpleEase = 0; end
	local curTarget = curKeyframe:GetTarget();
	local nextTarget = nextKeyframe:GetTarget();
	if(not curTarget or not nextTarget)then return; end
	
	local result = curTarget:GetDifference(curTarget,nextTarget)
	
	if(not result)then return end
	local key,difference;
	local params = {
		bindObjName = curTarget:GetBindObjName(),
		Visible = curTarget.params.Visible,
	};
	local initObjParams = self:GetBindParams();
	for key,difference in pairs(result) do	
		if(difference and type(difference) == "table")then
			local begin = difference["begin"];
			local change = difference["change"];
			if(begin and change)then
				local p = CommonCtrl.Motion.SimpleEase.easeQuadPercent(timeFromKeyframe, begin, change, keyframeDuration, simpleEase);				
				if(key == "X" or key == "Y" or key == "Z")then
					local pre = CommonCtrl.Motion.SimpleEase.easeQuadPercent(timeFromKeyframe-1, begin, change, keyframeDuration, simpleEase);
					--local pre = CommonCtrl.TweenEquations.easeOutQuint(timeFromKeyframe-1, begin, change, keyframeDuration);
					params["delta_"..key] = p - pre;					
				end			
				params[key] = p;
			end
		end
	end	
	CommonCtrl.Storyboard.Target.Update(params);
end
function KeyFrames:GetRoot()
	local result = self;
	local parent = self._parent;
	while(parent)do
		result = parent;
		parent = parent._parent;
	end
	return result;
end
function KeyFrames:ReplaceTargetName(oldName,newName)
	if(not oldName or not newName)then return end
	if(oldName == self.TargetName)then
		self:SetTargetName(newName);
	end		
end