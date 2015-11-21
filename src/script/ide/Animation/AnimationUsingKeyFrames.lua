--[[
Title: AnimationUsingKeyFrames
Author(s): Leio Zhang
Date: 2008/7/21
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/AnimationUsingKeyFrames.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/TimeSpan.lua");
NPL.load("(gl)script/ide/Motion/SimpleEase.lua");
local AnimationUsingKeyFrames = {
	property = "AnimationUsingKeyFrames",
	name = "AnimationUsingKeyFrames_instance",
	TargetName = nil,
	TargetProperty = nil,
	Duration = nil,
	keyframes = nil,
	mcmlTitle = "pe:animationUsingKeyFrames",
}
commonlib.setfield("CommonCtrl.Animation.AnimationUsingKeyFrames",AnimationUsingKeyFrames);
function AnimationUsingKeyFrames:new(o)
	
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o.keyframes = {};
	
	return o
end

function AnimationUsingKeyFrames:clear()
	self.keyframes = {};
end
function AnimationUsingKeyFrames:addKeyframe(keyframe)
	if(not keyframe)then return; end
	if(not self.keyframes)then
		self.keyframes = {};
	end
	local isInsert = self:IsInsertIntoFirstKeyFrame(keyframe);
	if(isInsert)then
		self:InsertFirstKeyFrame();
	end
	table.insert(self.keyframes,keyframe);
	keyframe.index = table.getn(self.keyframes);
end
function AnimationUsingKeyFrames:removeKeyframeByIndex(index)
	if(not index or not self.keyframes)then return; end
	local len = table.getn(self.keyframes);
	if(index>len)then return ; end
	table.remove(self.keyframes,index);
end
function AnimationUsingKeyFrames:getValue(time)
	local result = self:getValue_result(time)
	return result;
end
function AnimationUsingKeyFrames:getValue_result(time,index)
	local result = nil;
	local curKeyframe = self:getCurrentKeyframe(time);
	if(not curKeyframe)then return; end
	local begin = curKeyframe:GetValue();
	if(index)then
		begin = begin[index];
	end
	if(not begin)then return; end
	local timeFromKeyframe = time - curKeyframe:GetFrames()-1;
	
	local nextKeyframe = self:getNextKeyframe(time);
	
	if (not nextKeyframe or nextKeyframe.parentProperty =="DiscreteKeyFrame") then	
			
		return begin;
	end
	local nextValue = nextKeyframe:GetValue();
	if(index)then
		nextValue = nextValue[index];
	end
	
	if(not nextValue)then 
		nextValue = begin; 
	end
	local change = nextValue - begin; 
	
	local keyframeDuration = nextKeyframe:GetFrames() - curKeyframe:GetFrames();
	
	local simpleEase = nextKeyframe.SimpleEase;
	if(not simpleEase)then simpleEase = 0; end
	if(nextKeyframe.parentProperty =="LinearKeyFrame")then
		result = CommonCtrl.Motion.SimpleEase.easeQuadPercent(timeFromKeyframe, begin, change, keyframeDuration, simpleEase)
	elseif(nextKeyframe.parentProperty =="SplineKeyFrame")then
		--TODO:曲线缓动
	end
	return result;
end
function AnimationUsingKeyFrames:getCurrentKeyframe(time)
	if(self:indexOutOfRange(time) or not self.keyframes)then return  end;
	
	--local len = table.getn(self.keyframes);
	local i = time;
	while(i >= 1) do	
		local kf = self.keyframes[i];
		if(kf)then
			local frames = kf:GetFrames();
			if (time >= frames) then
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
			local frames = kf:GetFrames();
			if (time < frames) then
				return kf;
			end
	end
end

function AnimationUsingKeyFrames:indexOutOfRange(time)
		--return (not time or time < 1/1000 or not self.Duration or time > TimeSpan.GetFrames(self.Duration));
		return (not time or time < 1/1000);
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
-- it must be override by son of itself
-- because first keyframe(KeyTime = "00:00:00") maybe not record the value of default property
-- if it is not be recorded,insert the value of default property into first keyframe
function AnimationUsingKeyFrames:InsertFirstKeyFrame()

end
function AnimationUsingKeyFrames:IsInsertIntoFirstKeyFrame(keyframe)
	if(keyframe)then 
		local KeyTime = keyframe.KeyTime;
		local milliseconds = CommonCtrl.Animation.TimeSpan.GetMilliseconds(KeyTime);
		if(milliseconds ~= 0)then
			local firstkeyframe = self.keyframes[1];
			if(not firstkeyframe)then
				return true;
			else
				local firstKeyTime = firstkeyframe.KeyTime;
				local firstMilliseconds = CommonCtrl.Animation.TimeSpan.GetMilliseconds(firstKeyTime);
				if(firstMilliseconds ~= 0)then
					return true;
				end
			end
		end
	end
end
function AnimationUsingKeyFrames:hasKeyFrame(keytime)
	if(not keytime or not self.keyframes)then return; end
	local k,keyframe;
	for k,keyframe in ipairs(self.keyframes) do
		if(keyframe.KeyTime == keytime)then
			return keyframe;
		end
	end
end
-- reverse a keyframes class to mcml
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
function AnimationUsingKeyFrames:ClearTempValue()
	self.lastResult = nil;
end
