--[[
Title: TargetAnimationUsingKeyFrames
Author(s): Leio Zhang
Date: 2008/10/20
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/TargetAnimationUsingKeyFrames.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/TimeSpan.lua");
NPL.load("(gl)script/ide/Animation/Motion/KeyFrames/KeyFrame.lua");
local TargetAnimationUsingKeyFrames = commonlib.inherit(CommonCtrl.Animation.Motion.AnimationUsingKeyFrames, {
	property = "TargetAnimationUsingKeyFrames",
	name = "TargetAnimationUsingKeyFrames_instance",
	mcmlTitle = "pe:targetAnimationUsingKeyFrames",
	-- SurpportProperty : BaseTarget
});
commonlib.setfield("CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames",TargetAnimationUsingKeyFrames);
function TargetAnimationUsingKeyFrames:UpdateTime(frame)
	if(not frame)then return; end
	local result = nil;
	local curKeyframe = self:getCurrentKeyframe(frame);
	if(not curKeyframe)then 
		--commonlib.echo("curKeyframe is nil~~~");
		return; 
	end
	local begin = curKeyframe:GetValue();
	local isActivate = curKeyframe:GetActivate();
	local lastFrame = self:GetLastFrame();
	--commonlib.echo({isActivate,curKeyframe.name,frame});
	if(not begin)then 
		--commonlib.echo("begin is nil~~~"); 
		return;
	end	
	if(isActivate)then
		-- update discrete property
		begin:Update(curKeyframe,lastFrame,frame);
		curKeyframe:SetActivate(false);	
	end
	local nextKeyframe = self:getNextKeyframe(frame);	
	if (not nextKeyframe or nextKeyframe.parentProperty =="DiscreteKeyFrame") then	
		--commonlib.echo("nextKeyframe is nil~~~");	
		return;
	end
	self:UpdatePropertyValue(isActivate,lastFrame,frame,curKeyframe,nextKeyframe)
end
function TargetAnimationUsingKeyFrames:UpdatePropertyValue(isActivate,lastFrame,frame,curKeyframe,nextKeyframe)
	if(not frame or not curKeyframe or not nextKeyframe)then return; end
	local timeFromKeyframe = frame - curKeyframe:GetFrames();
	local keyframeDuration = nextKeyframe:GetFrames() - curKeyframe:GetFrames();	
	local simpleEase = curKeyframe.SimpleEase;
	if(not simpleEase)then simpleEase = 0; end
	local curTarget = curKeyframe:GetValue();
	local nextTarget = nextKeyframe:GetValue();
	if(not curTarget or not nextTarget)then return; end
	
	local changesTarget = curTarget:GetDifference(curTarget,nextTarget)
	
	if(not changesTarget)then return end
	local key,difference;
	for key,difference in pairs(changesTarget) do	
		if(difference and type(difference) == "table")then
			local begin = difference["begin"];
			local change = difference["change"];
			if(begin and change)then
				if(nextKeyframe.parentProperty =="LinearKeyFrame")then
					local result= CommonCtrl.Motion.SimpleEase.easeQuadPercent(timeFromKeyframe, begin, change, keyframeDuration, simpleEase);
					changesTarget[key] = result;
				elseif(nextKeyframe.parentProperty =="SplineKeyFrame")then
					--TODO:曲线缓动
				end
			end
		end
	end
	if(changesTarget)then
		changesTarget:Update(curKeyframe,lastFrame,frame);
	end
end
--------------------------------------------------------------------------
-- LinearTargetKeyFrame
local LinearTargetKeyFrame  = commonlib.inherit(CommonCtrl.Animation.Motion.KeyFrame, {
	parentProperty = "LinearKeyFrame",
	property = "LinearTargetKeyFrame",
	name = "LinearTargetKeyFrame_instance",
	mcmlTitle = "pe:linearTargetKeyFrame",
	SimpleEase = 0,
});
commonlib.setfield("CommonCtrl.Animation.Motion.LinearTargetKeyFrame",LinearTargetKeyFrame );
function LinearTargetKeyFrame:SetValue(v)
	self.Value = v;
	if(type(v) == "table")then
		v.Owner = self;
	end
end
function LinearTargetKeyFrame:ReverseToMcml()
	if(not self.Value or not self.KeyTime)then return "" end
	local targetObject = self:GetValue();
	local node_value = targetObject:ReverseToMcml();
	local p_node = "\r\n";
	local SimpleEase = "";
	local node;
	if(self.SimpleEase and tonumber(self.SimpleEase)~=0)then
		SimpleEase = string.format([[SimpleEase="%s"]],self.SimpleEase);
		node = string.format([[<%s KeyTime="%s" %s>%s</%s>%s]],self.mcmlTitle,self.KeyTime,SimpleEase,node_value,self.mcmlTitle,p_node);
	else
		node = string.format([[<%s KeyTime="%s">%s</%s>%s]],self.mcmlTitle,self.KeyTime,node_value,self.mcmlTitle,p_node);
	end
	return node;
end
-- DiscreteTargetKeyFrame
local DiscreteTargetKeyFrame  = commonlib.inherit(CommonCtrl.Animation.Motion.KeyFrame, {
	parentProperty = "DiscreteKeyFrame",
	property = "DiscreteTargetKeyFrame",
	name = "DiscreteTargetKeyFrame_instance",
	mcmlTitle = "pe:discreteTargetKeyFrame",
});
commonlib.setfield("CommonCtrl.Animation.Motion.DiscreteTargetKeyFrame",DiscreteTargetKeyFrame);
function DiscreteTargetKeyFrame:SetValue(v)
	self.Value = v;
	if(type(v) == "table")then
		v.Owner = self;
	end
end
function DiscreteTargetKeyFrame:ReverseToMcml()
	if(not self.Value or not self.KeyTime)then return "" end
	local targetObject = self:GetValue();
	local node_value = targetObject:ReverseToMcml();
	local p_node = "\r\n";
	
	local node = string.format([[<%s KeyTime="%s">%s</%s>%s]],self.mcmlTitle,self.KeyTime,node_value,self.mcmlTitle,p_node);
	return node;
end