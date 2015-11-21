--[[
Title: SimpleEase
Author(s): Leio Zhang
Date: 2008/4/18
Desc: Based on Actionscript library 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/SimpleEase.lua");
------------------------------------------------------------
--]]
local SimpleEase = commonlib.inherit(CommonCtrl.Motion.ITween, {
	_ease = nil,
	_target = nil,
});

commonlib.setfield("CommonCtrl.Motion.SimpleEase",SimpleEase);

function SimpleEase:GetTarget()
	return self._target;
end

function SimpleEase:SetTarget(v)
	self._target = v;
end
--[[
/**
     * A percentage between <code>-1</code> (100% ease in or acceleration) and <code>1</code> (100% ease out or deceleration). 
     * Defaults to <code>0</code>, which means that the tween animates at a constant speed, without acceleration or deceleration.
     * @default 0
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword SimpleEase, Copy Motion as ActionScript    
     */
--]]
function SimpleEase:GetEase()
		return self._ease;
end
function SimpleEase:SetEase(value)	
		if ( value ==nil  ) then
			value = 0;
		end
		value = tonumber(value);
		if ( value <-1 ) then
			value = -1;
		end
		if ( value >1 ) then
			value = 1;
		end
		self._ease = value;
end
function SimpleEase:Init(data)	
	self:parseTable(data);
end

function SimpleEase:parseTable(data)
	if( type(data) ~="table" )then return end;
	self:SetEase(data["attr"]["ease"]);		
end

--[[
/**
     * Calculates an interpolated value for a numerical property of animation, 
     * using a percentage of quadratic easing.
     * The function signature matches that of the easing functions in the fl.motion.easing package.
     *
     * @param time This value is between <code>0</code> and <code>duration</code>, inclusive.
     * You can choose any unit (for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>duration</code> unit.
	 *
     * @param begin The value of the animation property at the start of the tween, when time is <code>0</code>.
     *
     * @param change The change in the value of the animation property over the course of the tween. 
     * This value can be positive or negative. For example, if an object rotates from 90 to 60 degrees, the <code>change</code> is <code>-30</code>.
     *
     * @param duration The length of time for the tween. This value must be greater than zero.
     * You can choose any unit (for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>time</code> unit.
     *
     * @param percent A percentage between <code>-1</code> (100% ease in or acceleration) and <code>1</code> (100% ease out or deceleration). 
     * 
     * @return The interpolated value at the specified time.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword SimpleEase, Copy Motion as ActionScript     
     * @see fl.motion.easing     
     */
--]]
function CommonCtrl.Motion.SimpleEase.easeQuadPercent(time, begin, change, duration, percent) 
		if(not time or not begin or not change or not duration or not percent)then return end
		if (duration <= 0) then return nil; end
		if (time <= 0 ) then return begin; end
		time = time / duration
		if (time >= 1) then return begin+change;  end
		
		-- linear tween if percent is 0
		if (not percent) then return change*time + begin; end
		if (percent > 1) then 
			percent = 1; 
		elseif (percent < -1) then
			 percent = -1;
		end
		
		-- ease in if percent is negative
		if (percent < 0) then return change*time*(time*(-percent) + (1+percent)) + begin; end
		
		-- ease out if percent is positive
		return change*time*((2-time)*percent + (1-percent)) + begin; 
end

--[[
/**
     * Calculates an interpolated value for a numerical property of animation, 
     * using a linear tween of constant velocity.
     * The function signature matches that of the easing functions in the fl.motion.easing package.
     *
     * @param time This value is between <code>0</code> and <code>duration</code>, inclusive.
     * You can choose any unit(for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>duration</code> unit.
	 *
     * @param begin The value of the animation property at the start of the tween, when time is <code>0</code>.
     *
     * @param change The change in the value of the animation property over the course of the tween. 
     * This value can be positive or negative. For example, if an object rotates from 90 to 60 degrees, the <code>change</code> is <code>-30</code>.
     *
     * @param duration The length of time for the tween. This value must be greater than zero.
     * You can choose any unit (for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>time</code> unit.
     *
     * @return The interpolated value at the specified time.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword SimpleEase, Copy Motion as ActionScript
     * @see fl.motion.easing    
     */
--]]
function CommonCtrl.Motion.SimpleEase.easeNone(time, begin, change, duration) 
		if (duration <= 0) then return nil; end
		if (time <= 0) then return begin; end
		if (time >= duration) then return begin+change; end
		return change*time/duration + begin;
end

--[[
/**
     * Calculates an interpolated value for a numerical property of animation,
     * using a percentage of quadratic easing. 
     * The percent value is read from the SimpleEase instance's <code>ease</code> property
     * rather than being passed into the method.
     * Using this property allows the function signature to match the ITween interface.
     *
     * @param time This value is between <code>0</code> and <code>duration</code>, inclusive.
     * You can choose any unit (for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>duration</code> unit.
	 *
     * @param begin The value of the animation property at the start of the tween, when time is <code>0</code>.
     *
     * @param change The change in the value of the animation property over the course of the tween. 
     * This value can be positive or negative. For example, if an object rotates from 90 to 60 degrees, the <code>change</code> is <code>-30</code>.
     *
     * @param duration The length of time for the tween. This value must be greater than zero.
     * You can choose any unit (for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>time</code> unit.
     *
     * @return The interpolated value at the specified time.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword SimpleEase, Copy Motion as ActionScript
     * @see #ease      
     */
--]]
function SimpleEase:getValue(time, begin, change, duration)
		return CommonCtrl.Motion.SimpleEase.easeQuadPercent(time, begin, change, duration, self:GetEase());
end
