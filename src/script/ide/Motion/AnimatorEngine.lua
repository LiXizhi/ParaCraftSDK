--[[
Title: AnimatorEngine
Author(s): Leio Zhang
Date: 2008/4/28
Desc: 
AnimatorEngine 是控制动画播放的引擎，引擎可以是任意个
每个引擎只包含一个 AnimatorManager

AnimatorManager 包含任意层 levelManager
levelManager 包含任意个 animator

--timeline |1 2 3 4 5 6 7 8 ------------------------------------------------------------------------------------max|
--level 1  |-----animator-----|-----animator-----|-----animator-----|-----animator-----|-----animator-----|
--level 2  |-----animator----------------|-----animator-----|-----animator-----|-----animator-----|
--level 3  |-----animator----------------|-----animator-----|-----animator-----|----------------------animator-----|

例子见：
	1 两个引擎：
	--------------------------------------------------------
	NPL.load("(gl)script/ide/Motion/test/motion_test.lua");
	CommonCtrl.Motion.motion_test.show();
	--------------------------------------------------------
	engine 1 : 包含3个 levelManager，每个levelManager 包含1个 animator
	engine 2 : 包含1个 levelManager，每个levelManager 包含3个 animator

	2 一个引擎：
	--------------------------------------------------------
	NPL.load("(gl)script/ide/Motion/test/motion_test_2.lua");
	CommonCtrl.Motion.motion_test_2.show();
	--------------------------------------------------------
	engine: 包含4个 levelManager，前3个levelManager 每个包含1个 animator，最后1个levelManager 包含3个 animator

------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
------------------------------------------------------------
--]]

NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/math/bit.lua");
NPL.load("(gl)script/ide/LuaXML.lua");
NPL.load("(gl)script/ide/Motion/ITween.lua");
NPL.load("(gl)script/ide/Motion/AnimatorManager.lua"); 
NPL.load("(gl)script/ide/Motion/LayerManager.lua");
NPL.load("(gl)script/ide/Motion/RotateDirection.lua");
NPL.load("(gl)script/ide/Motion/Point.lua");
NPL.load("(gl)script/ide/Motion/Source.lua");
NPL.load("(gl)script/ide/Motion/CustomEase.lua");
NPL.load("(gl)script/ide/Motion/Keyframe.lua");
NPL.load("(gl)script/ide/Motion/Motion.lua");
-- Leio: contact LiXizhi. This could randomly generate an error when loading an empty file. 
NPL.load("(gl)script/ide/Motion/BezierEase.lua");
NPL.load("(gl)script/ide/Motion/BezierSegment.lua");
NPL.load("(gl)script/ide/Motion/Animator.lua");
NPL.load("(gl)script/ide/Motion/DisplayObject.lua");
NPL.load("(gl)script/ide/Motion/Tweenables.lua");
NPL.load("(gl)script/ide/Motion/SimpleEase.lua");
NPL.load("(gl)script/ide/Motion/ColorTransform.lua");
NPL.load("(gl)script/ide/Motion/Color.lua");

local AnimatorEngine = {
	name = "",
	totalFrame = 1,
	_elapsedtime = 0,
	autoRewind = false,
	-- if this is 0, it will repeat infinitly. 
	repeatCount = 1,
	_isPlaying = false,
	_target = nil,
	_lastRenderedTime = -1,
	_time = 0,
	playCount = 0,
	framerate = 12,
	firstFrame = 0,
 	--event
 	--动画停止，并返回到第一帧
 	OnMotionStop = nil,
 	--动画停止，停止在最后一帧
 	OnMotionEnd = nil,
 	OnMotionStart = nil,
 	OnTimeChange = nil,
 	OnMotionRewind = nil,
 	OnMotionPause = nil,
 	OnMotionResume = nil,
 	
 	OnFail = nil,
 	--
 	animatorManager = nil,	
}
commonlib.setfield("CommonCtrl.Motion.AnimatorEngine",AnimatorEngine);
local AnimatorPool={};
commonlib.setfield("CommonCtrl.Motion.AnimatorPool",AnimatorPool);
function AnimatorEngine:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o.name = ParaGlobal.GenerateUniqueID();
	return o
end
--event
function AnimatorEngine.OnMotionStop(sControl,time)
	
end	
function AnimatorEngine.OnMotionEnd(sControl,time)
	
end	
function AnimatorEngine.OnMotionStart(sControl,time)
	
end	
function AnimatorEngine.OnTimeChange(sControl,time)
	
end	
function AnimatorEngine.OnMotionRewind(sControl)
	
end	
function AnimatorEngine.OnMotionPause(sControl)
	
end	
function AnimatorEngine.OnMotionResume(sControl)
	
end	
function AnimatorEngine.OnFail(engine)
	if(engine)then
		--log("warning: AnimatorEngine:"..engine.name.." is closed\n");
		engine:Destroy()
	end
end	
--Indicates whether the animation is currently playing.
function AnimatorEngine:isPlaying()
		return self._isPlaying;
end
--The display object being animated. 
--Any subclass of flash.display.DisplayObject can be used, such as a <code>MovieClip</code>, <code>Sprite</code>, or <code>Bitmap</code>.
function AnimatorEngine:GetTarget()
        return self._target;
end
--@param:value DisplayObject
function AnimatorEngine:SetTarget(value)
	if (not value) then log("DisplayObject is nil \n") return; end
	self._target = value;		
end
--A zero-based integer that indicates and controls the time in the current animation. 
-- At the animation's first frame <code>time</code> is <code>0</code>. 
--If the animation has a duration of 10 frames, at the last frame <code>time</code> is <code>9</code>. 
function AnimatorEngine:GetTime()
        return self._time;
end
function AnimatorEngine:SetTime(newTime)
   if (newTime == self._time) then return; end		
	self._time = newTime;	
	self.animatorManager:OnTimeChange();	
	self.OnTimeChange(self,self._time);	
end
function AnimatorEngine:preFrame()
		local time = self:GetTime();
		--log(self._time..":"..self.totalFrame.."\n");
		time = time - 1;
		if (time < self.firstFrame)then
			time = self.firstFrame;		
		end
		self:SetTime(time);
end
--Advances Flash Player to the next frame in the animation sequence.
function AnimatorEngine:nextFrame()
		local time = self:GetTime();
		--log(self._time..":"..self.totalFrame.."\n");
		if (time >= self.totalFrame)then
			self:handleLastFrame();
		else
			self:SetTime(time + 1);
		end
end
-- go to and play a frame
function AnimatorEngine:gotoAndPlay(frame)
	if(not self.animatorManager)then return; end
	self:_doPause();
	
	local total = self.totalFrame;
	if(frame<self.firstFrame)then
		frame = self.firstFrame;
	end
	if(frame>total or frame==nil)then
		frame = total;
	end	
	self._time = frame;	
	self.animatorManager:gotoAndPlay(frame);	
	self.OnTimeChange(self,self._time);
	
	self:_doResume();
end
-- go to and stop at a frame
function AnimatorEngine:gotoAndStop(frame)
	
	self:gotoAndPlay(frame);
	self:_doPause();
end
-- play from the beginning. 
-- @param bDelayStart: if nil, it will immediately render the first frame. 
-- if true, it will not render first frame until 1/framerate second is passed. 
function AnimatorEngine:doPlay(bDelayStart)
	if(not self.animatorManager)then return; end
	if (not self._isPlaying) then
		self:addEnterFrameEventListener()
		self._isPlaying = true;
	end
	self.playCount = 0;
	--enterFrame event will fire on the following frame, 
	--so call the time setter to update the position immediately
	self:rewind();
		
	self.OnMotionStart(self,self._time);
	
	-- Added by LiXizhi 2008.5.8: force render the first frame immediately. 
	if(not bDelayStart) then
		self:nextFrame();
	end	
end
--[[
/**
     *  Stops the animation and Flash Player goes immediately to the last frame in the animation sequence. 
     *  If the <code>autoRewind</code> property is set to <code>true</code>, Flash Player goes to the first
     * frame in the animation sequence. 
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword end, stop
     * @see #autoRewind     
     */
--]]
function AnimatorEngine:doEnd()
		if(not self.animatorManager)then return; end
		self._isPlaying = false;
		self.playCount = 0;
		if (self.autoRewind)  then
			self:rewind();
		elseif (self:GetTime() ~= self.totalFrame) then
			self:SetTime(self.totalFrame);
		end		
		self.animatorManager:DoEnd();
		-- By LiXizhi 2008.5.8. why is this? We can never end an animation with last frame. So i removed it. 
		-- To Leio, if you want to reset something, please use self.animatorManager:DoEnd();
		-- self.animatorManager:DoStop();
		self.OnMotionEnd(self,self._time);
		self:removeEnterFrameEventListener()
end 
--Stops the animation and Flash Player goes back to the first frame in the animation sequence.
function AnimatorEngine:doStop()
		if(not self.animatorManager)then return; end
		self._isPlaying = false;
		self.playCount = 0;
		self:rewind();
		self.animatorManager:DoStop();
				
		self.OnMotionStop(self,self._time);	
		self:removeEnterFrameEventListener();
end

--Pauses the animation until you call the <code>resume()</code> method.
function AnimatorEngine:doPause()
		if(not self.animatorManager)then return; end
		self:_doPause();
		self.OnMotionPause(self);
end
function AnimatorEngine:_doPause()
		if(not self.animatorManager)then return; end
		self._isPlaying = false;
		
		self.animatorManager:DoPause();
		self:removeEnterFrameEventListener();
end
--Resumes the animation after it has been paused by the <code>pause()</code> method.
function AnimatorEngine:doResume()
		if(not self.animatorManager)then return; end
		self:_doResume();
		self.OnMotionResume(self);
end
function AnimatorEngine:_doResume()
		if(not self.animatorManager)then return; end
		self:addEnterFrameEventListener();
		self._isPlaying = true;
		
		self.animatorManager:DoResume();
end

--Sets Flash Player to the first frame of the animation. 
--If the animation was playing, it continues playing from the first frame. 
--If the animation was stopped, it remains stopped at the first frame.
function AnimatorEngine:rewind()
		if(not self.animatorManager)then return; end
		self.animatorManager:DoPlay();
		self.OnMotionRewind(self);
		self:SetTime(self.firstFrame);
end
function AnimatorEngine:handleLastFrame() 
		self.playCount = self.playCount + 1;
		if (self.repeatCount == 0 or self.playCount < self.repeatCount) then
			self:rewind();
		else
			self:doEnd();
		end
end
function AnimatorEngine:addEnterFrameEventListener()
	if(not self.animatorManager)then return; end
	AnimatorPool[self.name] = self;
	
	local enterFrameBeacon = ParaUI.GetUIObject("__enterFrameBeacon__");
	if(not enterFrameBeacon:IsValid()) then 
		enterFrameBeacon = ParaUI.CreateUIObject("container","__enterFrameBeacon__","_lt",0,0,0,0);	
		enterFrameBeacon.background="";
		enterFrameBeacon.enabled = false;
		enterFrameBeacon.onframemove = ";CommonCtrl.Motion.AnimatorEngine.enterFrameHandler();";
		enterFrameBeacon:AttachToRoot();
	end	
end
function AnimatorEngine:removeEnterFrameEventListener()
	AnimatorPool[self.name] = nil;
end
function CommonCtrl.Motion.AnimatorEngine.enterFrameHandler()
	local name, anim
	for name,anim in pairs(AnimatorPool) do
		if(anim)then
			anim._elapsedtime = anim._elapsedtime + deltatime;
			if(anim._elapsedtime >= 1/anim.framerate ) then
				anim._elapsedtime = anim._elapsedtime - (1/anim.framerate);
				anim:nextFrame();
			end	
		end
	end		
end
function AnimatorEngine:Destroy()
	self:removeEnterFrameEventListener()
end
function AnimatorEngine:SetAnimatorManager(animatorManager)
	if(not animatorManager or animatorManager:GetChildLen() == 0)then 
		return 
	end
	self.animatorManager = animatorManager;
	animatorManager.parent = self;
	animatorManager.OnFail = self.OnFail;
	self.totalFrame = animatorManager:GetFrameLength();
end