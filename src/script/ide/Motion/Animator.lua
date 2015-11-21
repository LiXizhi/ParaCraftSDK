--[[
Title: Animator
Author(s): Leio Zhang
Date: 2008/4/15
Desc: Based on Actionscript library 
/**
 * The Animator class applies an XML description of a motion tween to a display object.
 * The properties and methods of the Animator class control the playback of the motion,
 * and Flash Player broadcasts events in response to changes in the motion's status.
 * The Animator class is primarily used by the Copy Motion as ActionScript command in
 * Flash CS3. You can then edit the ActionScript using the application programming interface
 * (API) or construct your own custom animation.
 * <p>If you plan to call methods of the Animator class within a function, declare the Animator 
 * instance outside of the function so the scope of the object is not restricted to the 
 * function itself. If you declare the instance within a function, Flash Player deletes the 
 * Animator instance at the end of the function as part of Flash Player's routine "garbage collection"
 * and the target object will not animate.</p>
 * 
 * @internal <p><strong>Note:</strong> If you're not using Flash CS3 to compile your SWF file, you need the
 * fl.motion classes in your classpath at compile time to apply the motion to the display object.</p>
 *
 * @playerversion Flash 9.0.28.0
 * @langversion 3.0
 * @keyword Animator, Copy Motion as ActionScript
 * @see ../../motionXSD.html Motion XML Elements
 */
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/Animator.lua");
------------------------------------------------------------
--]]
local Animator = {
	name = "animator",
	_motion = nil,
	--Animator maybe added in LevelManager,so its parent is LevelManager
	parent = nil,
	_elapsedtime = 0,
	--[[
	/**
     * Sets the position of the display object along the motion path. If set to <code>true</code>
     * the baseline of the display object orients to the motion path; otherwise the registration
     * point orients to the motion path.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword orientToPath, orientation
     */
    --]]
	orientToPath = false,
	--[[
	/**
     * The point of reference for rotating or scaling a display object. The transformation point is 
     * relative to the display object's bounding box.
     * The point's coordinates must be scaled to a 1px x 1px box, where (1, 1) is the object's lower-right corner, 
     * and (0, 0) is the object's upper-left corner.  
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword transformationPoint
     */
    --]]
	transformationPoint = nil,
	--[[
	/**
     * Sets the animation to restart after it finishes.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword autoRewind, loop
     */
    --]]
	autoRewind = false,
	--[[
	/**
     * The Matrix object that applies an overall transformation to the motion path. 
     * This matrix allows the path to be shifted, scaled, skewed or rotated, 
     * without changing the appearance of the display object.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword positionMatrix     
     */
    --]]
	positionMatrix = nil,
	--[[
	 /**
     *  Number of times to repeat the animation.
     *  Possible values are any integer greater than or equal to <code>0</code>.
     *  A value of <code>1</code> means to play the animation once.
     *  A value of <code>0</code> means to play the animation indefinitely
     *  until explicitly stopped (by a call to the <code>end()</code> method, for example).
     *
     * @default 1
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword repeatCount, repetition, loop   
     * @see #end()
     */
    --]]
	repeatCount = 1,
	_isPlaying = false,
	_target = nil,
	_lastRenderedTime = -1,
	_time = 0,
	playCount = 0,
	targetState = nil,
	-- This code is run just once, during the class initialization.
	-- Create a MovieClip to generate enterFrame events.
 	enterFrameBeacon = nil,
 	
 	framerate = 12,
 	-- motion xml data path
 	dataPath = nil,
 	isValid = true,
 	--event
 	OnMotionEnd = nil,
 	OnMotionStart = nil,
 	OnMotionUpdate = nil,
 	OnTimeChange = nil,
 	OnFail = nil,
 	
}
commonlib.setfield("CommonCtrl.Motion.Animator",Animator);

--event
function Animator.OnMotionEnd(layerManager)

end	
function Animator.OnMotionStart()

end	
function Animator.OnMotionUpdate()

end	
function Animator.OnTimeChange()

end		
function Animator.OnFail()
	
end


function Animator:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end

--Creates an Animator object to apply the XML-based motion tween description to a display object.
-- @param dataPath: motion xml path
-- @param targetName: the name of ParaUIObject
function Animator:Init(dataPath,targetName)
 if(not dataPath or not targetName ) then return; end
 self.dataPath = dataPath;
 local motion = CommonCtrl.Motion.MotionResource[dataPath];
 if(not motion ) then
	local data = ParaXML.LuaXML_ParseFile(dataPath);	
	if(table.getn(data) == 0 or data==nil)then
		self.isValid = false;
		log("error: "..dataPath.." is not exist! \n");
		return;
	end
	motion = CommonCtrl.Motion.Motion:new();
	motion:Init(data[1]);
	CommonCtrl.Motion.MotionResource[dataPath] = motion;
 else
	motion = commonlib.deepcopy(motion)
 end	
	self:SetMotion( motion );
	self:SetDisplayObject(targetName);
end

-- creates an animator object
-- @param motionStr: motion xml string
-- @param targetName: the name of ParaUIObject
function Animator:InitFromMotion(motionStr,targetName)
	if(not motionStr or not targetName ) then return; end
	local data = ParaXML.LuaXML_ParseString(motionStr);
	if(table.getn(data) == 0 or data==nil)then
		self.isValid = false;
		log("error: ParaXML.LuaXML_ParseString(motionStr) is nil! \n");
		return;
	end
	local motion = CommonCtrl.Motion.Motion:new();
	--commonlib.echo(data);
	motion:Init(data[1]);
	self:SetMotion( motion );
	self:SetDisplayObject(targetName);
end
function Animator:SetDisplayObject(targetName)
	 local target = CommonCtrl.Motion.DisplayObject:new();
	   target.name = targetName;
	   -- By LiXizhi 2008.5.8 do not init object since UI object may not be existent yet.
	   -- target:InitObjectProperty()
	   self:SetTarget(target);  
	
	   self.name = ParaGlobal.GenerateUniqueID();
end

--The object that contains the motion tween properties for the animation. 
function Animator:GetMotion()
        return self._motion;
end

function Animator:SetMotion(value)
		self._motion = value;
		if (value.source and value.source.transformationPoint) then
			self.transformationPoint = value.source.transformationPoint:clone();
		end
end

--Indicates whether the animation is currently playing.
function Animator:isPlaying()
		return self._isPlaying;
end

--The display object being animated. 
--Any subclass of flash.display.DisplayObject can be used, such as a <code>MovieClip</code>, <code>Sprite</code>, or <code>Bitmap</code>.
function Animator:GetTarget()
        return self._target;
end
--@param:value DisplayObject
function Animator:SetTarget(value)
	
	if (not value) then log("DisplayObject is nil \n") return; end
		self._target = value;

		self.targetState = {};
		self.targetState.x = self._target.x;
		self.targetState.y = self._target.y;
		self.targetState.scaleX = self._target.scaleX;
		self.targetState.scaleY = self._target.scaleY;
		self.targetState.skewX = self._target.skewX;
		self.targetState.skewY = self._target.skewY;
 		
end

--A zero-based integer that indicates and controls the time in the current animation. 
-- At the animation's first frame <code>time</code> is <code>0</code>. 
--If the animation has a duration of 10 frames, at the last frame <code>time</code> is <code>9</code>. 
function Animator:GetTime()
        return self._time;
end

function Animator:SetTime(newTime)
   if (newTime == self._time) then return; end
		
		local thisMotion = self:GetMotion();
		
		if (newTime > thisMotion:GetDuration()) then
			newTime = thisMotion:GetDuration();
		elseif (newTime < 0) then
			newTime = 0;
		end
		self._time = newTime;
		
		self.OnTimeChange();
		
		local diaplayObj = self._target:GetDisplayObj();
		if(not diaplayObj) then
			--log("warning: animator group is stopped since no binding control found\n");
			self.OnFail(self.parent);
			return;
		end
		local curKeyframe = thisMotion:getCurrentKeyframe(newTime);
		if(not curKeyframe)then
			log("curKeyframe is nil:"..self.dataPath.."\n");
		end
		-- optimization to detect when a keyframe is "holding" for several frames and not tweening
		local isHoldKeyframe = ( (curKeyframe:GetIndex() == self._lastRenderedTime) 
									 and ( table.getn(curKeyframe.tweens) < 1  ) ); 
		if (isHoldKeyframe) then
			return;
		end
		
		
		self._target.visible = false;
		
		if (not curKeyframe.blank) then
			local positionX = thisMotion:getValue(newTime, CommonCtrl.Motion.Tweenables.X);
			local positionY = thisMotion:getValue(newTime, CommonCtrl.Motion.Tweenables.Y);
			if(not positionX or not positionY) then return ; end 
			local position = CommonCtrl.Motion.Point:new{x = positionX, y =positionY};
			--log(position.x.."---------"..position.y.."\n");
	   		
			position.x =position.x + self.targetState.x;
			position.y =position.y + self.targetState.y;
			
			local scaleX = thisMotion:getValue(newTime, CommonCtrl.Motion.Tweenables.SCALE_X) * self.targetState.scaleX; 
			local scaleY = thisMotion:getValue(newTime, CommonCtrl.Motion.Tweenables.SCALE_Y) * self.targetState.scaleY; 	
			local skewX = 0
			local skewY = 0; 
		
			-- override the rotation and skew in the XML if orienting to path
			if (self.orientToPath)then
				local positionX2 = thisMotion:getValue(newTime+1, CommonCtrl.Motion.Tweenables.X);
				local positionY2 = thisMotion:getValue(newTime+1, CommonCtrl.Motion.Tweenables.Y);
				local pathAngle = math.atan2(positionY2-positionY, positionX2-positionX) * (180 / math.pi);
				if (pathAngle) then
					skewX = pathAngle + self.targetState.skewX;
					skewY = pathAngle + self.targetState.skewY;
				end
			else
				skewX = thisMotion:getValue(newTime, CommonCtrl.Motion.Tweenables.SKEW_X) + self.targetState.skewX; 
				skewY = thisMotion:getValue(newTime, CommonCtrl.Motion.Tweenables.SKEW_Y) + self.targetState.skewY; 
				
			end
			self._target.rotation = skewY;
			
			self._target.scaleX = scaleX;
			self._target.scaleY = scaleY; 
			
			self._target.x = position.x;
			self._target.y = position.y;
			
			local colorTransform = thisMotion:getColorTransform(newTime);
			if (colorTransform)then
				self._target.transform.colorTransform = colorTransform;
			end
			
			self._target.visible = true;
		end
		self._target:Update();
		self._lastRenderedTime = self._time;
		
		self.OnMotionUpdate();    
end

--
function Animator:getTotalFrame()
	local motion = self:GetMotion();
	local total = motion:GetDuration();
	return total;
end
-- go to and play a frame
function Animator:gotoAndPlay(frame)
	local total = self:getTotalFrame();
	if(frame>total or frame==nil)then
		frame = total;
	end
	self:SetTime(frame)
end

--Advances Flash Player to the next frame in the animation sequence.
function Animator:nextFrame()
		local time = self:GetTime();
		local motion = self:GetMotion();
		if (time >= motion:GetDuration())then
			self:handleLastFrame();
		else
			self:SetTime(time + 1);
		end
end

--[[
    /**
     *  Begins the animation. Call the <code>end()</code> method 
     *  before you call the <code>play()</code> method to ensure that any previous 
     *  instance of the animation has ended before you start a new one.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword play, begin
     * @see #end()
     */
--]]
function Animator:play()
		if (not self._isPlaying) then
			self._isPlaying = true;
		end
		self.playCount = 0;
		--enterFrame event will fire on the following frame, 
		--so call the time setter to update the position immediately
		self:rewind();
		self.OnMotionStart();
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
function Animator:doEnd()
		self._isPlaying = false;
		self.playCount = 0;
		local motion = self:GetMotion();
		if (self.autoRewind)  then
			self:rewind();
		elseif (self:GetTime() ~= motion:GetDuration()) then
			self:SetTime(motion:GetDuration());
		end
		self.OnMotionEnd(self.parent);	
end

    
--Stops the animation and Flash Player goes back to the first frame in the animation sequence.
function Animator:stop()
		self._isPlaying = false;
		self.playCount = 0;
		self:rewind();
		self.OnMotionEnd(self.parent);	
end

--Pauses the animation until you call the <code>resume()</code> method.
function Animator:pause()
		self._isPlaying = false;
end

--Resumes the animation after it has been paused by the <code>pause()</code> method.
function Animator:resume()
		self._isPlaying = true;
end

--Sets Flash Player to the first frame of the animation. 
--If the animation was playing, it continues playing from the first frame. 
--If the animation was stopped, it remains stopped at the first frame.
function Animator:rewind()
		--TODO:
		self._target:Init();
		
		self:SetTime(1);
end

function Animator:handleLastFrame() 
		self.playCount = self.playCount + 1;
		if (self.repeatCount == 0 or self.playCount < self.repeatCount) then
			self:rewind();
		else
			self:doEnd();
		end
end

function Animator:EnterFrame() 
		self:nextFrame();
end




