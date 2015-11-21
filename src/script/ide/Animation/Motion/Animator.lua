--[[
Title: Animator
Author(s): Leio Zhang
Date: 2008/10/15
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Animator.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/Motion/AnimationEditor/AnimationEditor.lua");
local AnimatorPool={};
commonlib.setfield("CommonCtrl.Animation.Motion.AnimatorPool",AnimatorPool);

local Animator = {
	_frame = -1,
    _repeatCount = 1,
    _isPlaying = false,
    _duration = 1,
    _playCount = 0,
    _autoRewind = false,
    _timer = nil,
    _framerate = CommonCtrl.Animation.Motion.AnimationEditor.AnimationEditor_Config.framerate,
    _elapsedtime = 0,
}
commonlib.setfield("CommonCtrl.Animation.Motion.Animator",Animator);
function Animator:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o.name = ParaGlobal.GenerateUniqueID();
	return o
end
---------------------------------------------------------
-- event
---------------------------------------------------------
function Animator.MotionStart(self)
	if(not self)then return; end
	self:Debug("MotionStart");
end
function Animator.MotionPause(self)
	if(not self)then return; end
	self:Debug("MotionPause");
end
function Animator.MotionResume(self)
	if(not self)then return; end
	self:Debug("MotionResume");
end
function Animator.MotionStop(self)
	if(not self)then return; end
	self:Debug("MotionStop");
end
function Animator.MotionEnd(self)
	if(not self)then return; end
	self:Debug("MotionEnd");
end
function Animator.MotionTimeChange(self)
	if(not self)then return; end
	self:Debug("MotionTimeChange");
end
function Animator:Debug(state)
	local s = string.format("%s,%s,%s",self:GetFrame(),self:GetDuration(),state);
	commonlib.echo(s);
end
---------------------------------------------------------
-- public  property
---------------------------------------------------------
-- it is a tag frame which record this animator updated by frame 
function Animator:GetLastFrame()
	return self._lastFrame;
end
function Animator:SetFrame(frame)
	if(not frame)then return; end
	--commonlib.echo({self.name,frame});
	self:UpdateFrame(frame);
	self._lastFrame = frame;
end
function Animator:GetFrame()
	return self._frame;
end
function Animator:SetDuration(d)
	self._duration = d;
end
function Animator:GetDuration()
	return self._duration;
end
function Animator:SetRepeatCount(d)
	self._repeatCount = d;
end
function Animator:GetRepeatCount()
	return self._repeatCount;
end
function Animator:SetIsPlaying(d)
	self._isPlaying = d;
end
function Animator:GetIsPlaying()
	return self._isPlaying;
end
function Animator:SetAutoRewind(d)
	self._autoRewind = d;
end
function Animator:GetAutoRewind()
	return self._autoRewind;
end
function Animator:SetTimer(d)
	self._timer = d;
end
function Animator:GetTimer()
	return self._timer;
end
function Animator:SetFramerate(d)
	self._framerate = d;
end
function Animator:GetFramerate()
	return self._framerate;
end
---------------------------------------------------------
-- private  method
---------------------------------------------------------
--[[
         * Sets Flash Player to the first frame of the animation. 
         * If the animation was playing, it continues playing from the first frame. 
         * If the animation was stopped, it remains stopped at the first frame.
--]]

function Animator:UpdateFrame(frame)
	if (frame == self:GetFrame()) then return; end
	if (frame > self:GetDuration() - 1) then
        frame = self:GetDuration() - 1;
	elseif (frame < 0) then
        frame = 0;
    end
    self._frame = frame;
    self.MotionTimeChange(self);
end
function Animator:HandleLastFrame()
	self._playCount = self._playCount + 1;
	if (self:GetRepeatCount() == 0 or self._playCount < self:GetRepeatCount()) then
       self:ReWind();
	else
       self:End();
	end                        
end                

---------------------------------------------------------
-- public  method
---------------------------------------------------------
function Animator:ReSet()
	self._playCount = 0;
	self._lastFrame = 0;
	self._frame = 0;
end
function Animator:ReWind()
	self._frame = -1;
end
-- Begins the animation. Call the <code>end()</code> method 
-- before you call the <code>play()</code> method to ensure that any previous 
-- instance of the animation has ended before you start a new one.
function Animator:Play()
	if (not self._isPlaying) then
			self._isPlaying = true;
			self:AddTimerListener();
	end
	self._playCount = 0;
	self._lastFrame = 0;
	self:ReWind()
	self.MotionStart(self);
end        
-- Pauses the animation until you call the <code>resume()</code> method.
function Animator:Pause()
	self:RemoveTimerListener();
	self._isPlaying = false;
	self.MotionPause(self);
end
-- Resumes the animation after it has been paused.
function Animator:Resume()
	self:AddTimerListener();
	self._isPlaying = true;
	self.MotionResume(self);
	
end
-- Stops the animation and Player goes back to the first frame in the animation sequence.
function Animator:Stop()
	self:RemoveTimerListener();
	self._isPlaying = false;
	self:ReSet()
	self.MotionStop(self);
end
-- Stops the animation and Player goes immediately to the last frame in the animation sequence. 
-- If the AutoRewind property is set to true, Player goes to the first
function Animator:End()
	self:RemoveTimerListener();
	self._isPlaying = false;
	self._playCount = 0;
	if(self:GetAutoRewind())then
		self:ReWind();
	elseif (self:GetFrame() ~= self:GetDuration()-1) then
		self:SetFrame(self:GetDuration()-1);
	end
	self.MotionEnd(self);	
end
function Animator:GotoAndPlay(frame)
	if (not self._isPlaying) then
		self._isPlaying = true;
		self:AddTimerListener();
	end
	self:SetFrame(frame);
end
function Animator:GotoAndStop(frame)
	self:RemoveTimerListener();
	self._isPlaying = false;
	self:SetFrame(frame);
end       
-- Advances Flash Player to the next frame in the animation sequence.
function Animator:NextFrame()
	if (self:GetFrame() >= self:GetDuration()-1) then
		self:HandleLastFrame();
	else
		local frame = self:GetFrame();
		frame = frame + 1;
		self:SetFrame(frame);	
	end
end    
function Animator:AddTimerListener()
	--local t = self:GetTimer()
	--if(t and t.EnterFrameHandler)then
		--t.EnterFrameHandler = self.EnterFrameHandler()
	--end
	AnimatorPool[self.name] = self;
	
	
end
function Animator:RemoveTimerListener()
	--local t = self:GetTimer()
	--if(t and t.EnterFrameHandler)then
		--t.EnterFrameHandler = nil;
	--end
	AnimatorPool[self.name] = nil;
end
function Animator:SetMovieClipBase(mc)
	self.mcBase = mc;
end
function Animator:GetMovieClipBase()
	return self.mcBase;
end