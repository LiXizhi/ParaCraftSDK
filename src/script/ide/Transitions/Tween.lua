--[[
Title: Tween
Author(s): Leio Zhang
Date: 2008/3/19
Desc: Based on Flash Tweener Actionscript library 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Transitions/Tween.lua");
local testobj={x=nil};
local tween=CommonCtrl.Tween:new{
				obj=testobj,
				prop="x",
				begin=0,
				change=300,
				duration=3,
					}
tween.func=CommonCtrl.TweenEquations.easeInQuad;
tween:Start();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/Transitions/TweenEquations.lua");
NPL.load("(gl)script/ide/Transitions/TweenUtil.lua");
if(not CommonCtrl )then CommonCtrl={};end
local	Tween = {
	name="Tween",
	--Indicates whether the tween is currently playing.
	isPlaying = false,
	--The target object that is being tweened.
	obj = nil,
	--The name of the property affected by the tween of the target object.
	prop = "",
	--The initial value of the target object's designated property before the tween starts
	begin = 0,
	--The changed value 
	change = 0,
	--Indicates whether the tween will loop. 
	looping = false,
	 --The duration of the tweened animation in  seconds. 
	duration = nil,
	
	--The easing function which is used with the tween.
	func = function ( t , b , c , d ) return c*t/d+b; end,
	
	-- private
	
	prevTime = nil,
	prevPos = nil,
	_time = 0,
	_position = nil,
	startTime = nil,
	_intervalID = nil,
	
	-- 1/20 seconds
	timerInterval=0.05, 
	
	--event
	MotionChange=nil,
	MotionFinish=nil,
	MotionLoop=nil,
	MotionResume=nil,
	MotionStart=nil,
	MotionStop=nil,
	}
CommonCtrl.Tween = Tween;
function Tween.MotionChange(time,position,self)
	--log(string.format("MotionChange:%s,%s\n",time,position));
end
function Tween.MotionFinish(time,position,self)
	--log(string.format("MotionFinish:%s,%s\n",time,position));
end
function Tween.MotionLoop(time,position,self)	
end
function Tween.MotionResume(time,position,self)
end
function Tween.MotionStart(time,position,self)
end
function Tween.MotionStop(time,position,self)
end

function Tween:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end

--The current time within the duration of the animation.
function Tween:GetTime()
	return self._time;
end

function Tween:SetTime(t)
	self.prevTime = self._time;
	if(t>self:GetDuration())then
		if(self.looping)then
			self:Rewind(t-self.duration);
			self:Update();
			self.MotionLoop(self._time,self._position,self);
		else
			self._time=self:GetDuration();
			self:Update();
			self:Stop();
			self.MotionFinish(self._time,self._position,self);
		end
	elseif(t < 0 )then
		self:ReWind();
		self:Update();
	else
		self._time=t;
		self:Update();
	end
end

--
function Tween:GetDuration()
	return self.duration;
end

--The duration of the tweened animation in seconds.
-- @param d: A number indicating the duration of the tweened animation in  seconds.
function Tween:SetDuration(d)
	if( d<= 0 )then d = 10000;end
	self.duration = d;
end


function Tween:GetPosition(t)
	if(t==nil)then t = self._time; end

	return self.func ( t , self.begin , self.change , self.duration );
end

--The current value of the target object property being tweened. This value updates 
--with each drawn frame of the tweened animation.
--@param p: The current value of the target object property being tweened.
function Tween:SetPosition(p)
	self.prevPos = self._position;
	if(self.prop)then
		self.obj[self.prop] = p;
		self._position = p;
		self.MotionChange(self._time,self._position,self);
	end
end

function Tween:GetFinish()
	return self.begin + self.change;
end

--A number indicating the ending value of the target object property that is to be tweened. 
function Tween:SetFinish(value)
	self.change = value - self.begin;
end

--Instructs the tweened animation to continue tweening from its current animation point to
--a new finish and duration point.
-- @param finish:A number indicating the ending value of the target object property that is to be tweened.
-- @param duration: A number indicating the length of time or number of frames for the tween motion
function Tween:ContinueTo(finish,duration)
	self.begin = self:GetPosition(self._time);
	self:SetFinish(finish);
	if(duration)then
		self:SetDuration(duration);
	end
	
end

--
function Tween:YoYo()
	self:ContinueTo(self.begin,self:GetTime())
	self:Start();
end
function Tween:SetYoYo()
	self:ContinueTo(self.begin,self:GetTime())
end

function Tween:StartEnterFrame()
	if(self._intervalID)then 
		NPL.SetTimer(self._intervalID,self.timerInterval, string.format([[;CommonCtrl.Tween.OnEnterFrame("%s","%s");]],self.name,self._intervalID));
	end
	self.isPlaying = true;
end

function Tween:StopEnterFrame()
	if(self._intervalID)then 
		NPL.KillTimer(self._intervalID); 
	end	
	self.isPlaying = false;
end
--Starts the play of a tweened animation from its starting point. This method is used for 
--restarting a Tween from the beginning of its animation after it stops or has completed 
--its animation.
function Tween:Start()
	if(self._intervalID==nil) then	
		local id=CommonCtrl.TweenUtil.GetIntervalID();
		self._intervalID=id;
	end
		self.name="Tween_instance_"..self._intervalID;
		local this=CommonCtrl.GetControl(self.name)
		if(this==nil)then			
			CommonCtrl.AddControl(self.name,self); 
		end	
				
	self:Rewind();
	self:StartEnterFrame();
	self.MotionStart(self._time,self._position,self);
end
--Stops the play of a tweened animation at its current value.
function Tween:Stop()
	self:StopEnterFrame();
	self.MotionStop(self._time,self._position,self);
end
--  Resumes the play of a tweened animation that has been stopped. Use this method to continue
--a tweened animation after you have stopped it by using the Tween:stop() method.
function Tween:Resume()
	self:StartEnterFrame();
	self.MotionResume(self._time,self._position,self);
end
--Moves the play of a tweened animation back to its starting value. If 
--Tween:rewind() is called while the tweened animation is still playing, the 
--animation rewinds to its starting value and continues playing. If 
--ween:rewind() is called while the tweened animation has been stopped or has
--finished its animation, the tweened animation rewinds to its starting value and remains 
--stopped. Use this method to rewind a tweened animation to its starting point after you have
--stopped it by using the Tween:stop() method or to rewind a tweened animation 
--during its play.
function Tween:Rewind()
	self._time = 0;
	self:Update();
end
-- stop at the last frame
function Tween:End()
	self:SetTime(self.duration + 1);
end
--Forwards the tweened animation directly to the final value of the tweened animation.
function Tween:FForward()
	self:SetTime(self.duration);
end
-- Forwards the tweened animation to the next frame of an animation that was stopped. Use this
--method to forward a frame at a time of a tweened animation after you use the 
--Tween:stop() method to stop it.
function Tween:NextFrame()
	self:SetTime( self._time + self.timerInterval );
end
--lays the previous frame of the tweened animation from the current stopping point of an 
--animation that was stopped. Use this method to play a tweened animation backwards one frame 
--at a time after you use the Tween:stop() method to stop it.
function Tween:PrevFrame()
	self:SetTime( self._time - self.timerInterval );
end

function Tween.OnEnterFrame(name,_intervalID)
	local self=CommonCtrl.GetControl(name);
	if(self==nil) then
		log(string.format("%s is nil \r\n",name));
		NPL.KillTimer(tonumber(_intervalID)); 
	end
	self:NextFrame();
end

function Tween:Update()
	self:SetPosition(self:GetPosition(self._time));
end

