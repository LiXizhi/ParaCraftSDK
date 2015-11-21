--[[
Title: Motion
Author(s): Leio Zhang
Date: 2008/4/15
Desc: Based on Actionscript library 
/**
 * The Motion class stores a keyframe animation sequence that can be applied to a visual object.
 * The animation data includes position, scale, rotation, skew, color, filters, and easing.
 * The Motion class has methods for retrieving data at specific points in time, and
 * interpolating values between keyframes automatically. 
 * @playerversion Flash 9.0.28.0
 * @langversion 3.0
 * @keyword Motion, Copy Motion as ActionScript    
 * @see ../../motionXSD.html Motion XML Elements   
 */
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/Motion.lua");
------------------------------------------------------------
--]]
local Motion = {
	--An object that stores information about the context in which the motion was created,
	--such as framerate, dimensions, transformation point, and initial position, scale, rotation and skew.
	source = nil,
	--[[
	/**
     * An array of keyframes that define the motion's behavior over time.
     * This property is a sparse array, where a keyframe is placed at an index in the array
     * that matches its own index. A motion object with keyframes at 0 and 5 has 
     * a keyframes array with a length of 6.  
     * Indices 0 and 5 in the array each contain a keyframe, 
     * and indices 1 through 4 have null values.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript      
     */
    --]]
	keyframes = nil,
	_duration = 0,
	}
commonlib.setfield("CommonCtrl.Motion.Motion",Motion);
			
function Motion:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end

function Motion:Init(data)
		self.keyframes = {};		
		self:parseTable(data);
		if (not self.source) then
			self.source = CommonCtrl.Motion.Source:new()
		end	
		-- ensure there is at least one keyframe
		if (self:GetDuration() == 0) then
			local kf = CommonCtrl.Motion.Keyframe:new();
			kf:SetIndex(0);
			self:addKeyframe(kf);
		end
end

--Controls the Motion instance's length of time, measured in frames.
--The duration cannot be less than the time occupied by the Motion instance's keyframes.
function Motion:GetDuration()
		--check again on the getter because the keyframes array may have changed after the setter was called
		local length = self:GetTableLen(self.keyframes);
		if (self._duration < length) then
			self._duration = length;
		end
		return self._duration;
end

function Motion:SetDuration(value)
		value = tonumber(value);
		local length = self:GetTableLen(self.keyframes);
		if (value < length) then
			value = length;
		end
		self._duration = value;
end
function Motion:indexOutOfRange(index)
		--return (isNaN(index) || index < 0 || index > self.duration-1);
		return (not index or index < 1 or index > self:GetDuration());
end

--[[
/**
	 * Retrieves the keyframe that is currently active at a specific frame in the Motion instance.
	 * A frame that is not a keyframe derives its values from the keyframe that preceded it.  
	 * 
	 * <p>This method can also filter values by the name of a specific tweenables property.
	 * You can find the currently active keyframe for <code>x</code>, which may not be
	 * the same as the currently active keyframe in general.</p>
	 * 
	 * @param index The index of a frame in the Motion instance, as an integer greater than or equal to zero.
	 * 
     * @param tweenableName Optional name of a tweenable's property (like <code>"x"</code> or <code>"rotation"</code>).
	 * 
	 * @return The closest matching keyframe at or before the supplied frame index.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript      
     * @see fl.motion.Tweenables
	 */
--]]
function Motion:getCurrentKeyframe(index, tweenableName)
		-- catch out-of-range frame values
		if(self:indexOutOfRange(index))then return null end;
		-- start at the given time and go backward until we hit a keyframe that matches
		local i = index;
		while(i > 1) do
			local kf = self.keyframes[i];
			-- if a keyframe exists, return it if the name matches or no name was given, 
			-- or if it's tweening all properties
			if (kf and kf:affectsTweenable(tweenableName)) then
				return kf;
			end
			i = i-1;
		end
		
		-- return the first keyframe if no other match
		return self.keyframes[1];
end

--[[
	/**
	 * Retrieves the next keyframe after a specific frame in the Motion instance.
	 * If a frame is not a keyframe, and is in the middle of a tween, 
	 * self method derives its values from both the preceding keyframe and the following keyframe.
	 * 
	 * <p>This method can also filter by the name of a specific tweenables property.
     * This allows you to find the next keyframe for <code>x</code>, which may not be
	 * the same as the next keyframe in general.</p>
	 * 
	 * @param index The index of a frame in the Motion instance, as an integer greater than or equal to zero.
	 * 
     * @param tweenableName Optional name of a tweenable's property (like <code>"x"</code> or <code>"rotation"</code>).
	 * 
	 * @return The closest matching keyframe after the supplied frame index.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript      
     * @see fl.motion.Tweenables     
	 */
--]]	 
function Motion:getNextKeyframe(index, tweenableName)
		-- catch out-of-range frame values 
		if(self:indexOutOfRange(index))then return nil end;
		
		-- start just after the given time and go forward until we hit a keyframe that matches
		
		local i , len = index+1,self:GetTableLen(self.keyframes);
		--log(commonlib.serialize(tweenableName).."\n");
		for i =index+1,len do
			local kf = self.keyframes[i];
			--if a keyframe exists, return it if no name was given or the name matches or there's a keyframe tween
			
			if (kf and kf:affectsTweenable(tweenableName)) then
				return kf;
			end
		end
		
		return nil;
end

	
--[[
    /**
     * Sets the value of a specific tweenables property at a given time index in the Motion instance.
     * If a keyframe doesn't exist at the index, one is created automatically.
     *
	 * @param index The time index of a frame in the Motion instance, as an integer greater than zero.
	 * If the index is zero, no change is made. 
	 * Because the transform properties are relative to the starting transform of the target object,
	 * the first frame's values are always default values and should not be changed.
     *
     * @param tweenableName The name of a tweenable's property (like <code>"x"</code> or <code>"rotation"</code>).
     *
     * @param value The new value of the tweenable property.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript      
     * @see fl.motion.Tweenables         
     */
--]]     
function Motion:setValue(index, tweenableName, value)
		if (index==0)then return; end
		
		local kf = self.keyframes[index];
		if (not kf) then
			kf = CommonCtrl.Motion.Keyframe:new();
			kf:SetIndex(index);
			self:addKeyframe(kf);
		end
 		
		kf:setValue(tweenableName, value);
end
--[[
/**
     * Retrieves the value for an animation property at a point in time.
     *
	 * @param index The time index of a frame in the Motion instance, as an integer greater than or equal to zero.
     *
     * @param tweenableName The name of a tweenable's property (like <code>"x"</code> or <code>"rotation"</code>).
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript  
     * @see fl.motion.Tweenables     
     */
--]]     
function Motion:getValue(index, tweenableName)
		local result = nil;
		
		-- range checking is done in getCurrentKeyindex()
		local curKeyframe = self:getCurrentKeyframe(index, tweenableName);
		if (not curKeyframe or curKeyframe.blank) then return nil; end
		
		local begin = curKeyframe:getValue(tweenableName);
		
		-- If the property isn't defined at self keyframe, 
		-- we have to figure out what it should be at self time, 
		-- so grab the value from the previous keyframe--works recursively.
		if (not (begin) and curKeyframe:GetIndex() > 1) then
			begin = self:getValue(curKeyframe:GetIndex()-1, tweenableName);
		end
		
		if (not (begin)) then return nil; end
		
		local timeFromKeyframe = index - curKeyframe:GetIndex();
		-- if we're right on the first keyframe, use the value defined on it 
		if (timeFromKeyframe == 0) then
			return begin;
		end
		
		-- Search for a possible tween targeted to an individual property. 
		-- If the property doesn't have a tween, check for a tween targeting all properties.
		local tween = curKeyframe:getTween(tweenableName) 
			or curKeyframe:getTween();
		
		-- if there is no interpolation, use the value at the current keyframe 
		if (not tween  
	   		or (not curKeyframe.tweenScale 
	   			and (tweenableName == CommonCtrl.Motion.Tweenables.SCALE_X or tweenableName == CommonCtrl.Motion.Tweenables.SCALE_Y)) 
 
 	   		or (curKeyframe.rotateDirection == CommonCtrl.Motion.RotateDirection.NONE 
	   			and (tweenableName == CommonCtrl.Motion.Tweenables.ROTATION or tweenableName == CommonCtrl.Motion.Tweenables.SKEW_X or tweenableName == CommonCtrl.Motion.Tweenables.SKEW_Y)) 		   		
			) 
		then

			return begin;
		end
		
		-- Now we know we have a tween, so find the next keyframe and interpolate
		local nextKeyframeTweenableName = tweenableName;
		-- If the tween is targeting all properties, the next keyframe will terminate the tween, 
		-- even if it doesn't directly affect the tweenable.
		-- This check is necessary for the case where the object doesn't change x, y, etc. in the XML at all 
		-- during the tween, but rotates using the rotateTimes property.
		if (tween:GetTarget() == nil) then
			nextKeyframeTweenableName = nil;
			
		end
		
		local nextKeyframe = self:getNextKeyframe(index, nextKeyframeTweenableName);
		
		if (not nextKeyframe or nextKeyframe.blank) then
			
			return begin;
		else
			local nextValue = nextKeyframe:getValue(tweenableName);
			
			--log(tweenableName..":".."nextKeyframe:.."..(nextKeyframe.x).."\n");
			if ( not (nextValue)) then
				nextValue = begin;
			end
				
			local change = nextValue - begin; 
				
			if ((tweenableName == CommonCtrl.Motion.Tweenables.SKEW_X 
				or tweenableName == CommonCtrl.Motion.Tweenables.SKEW_Y)
				or tweenableName == CommonCtrl.Motion.Tweenables.ROTATION) then
				
				-- At self point, we've already eliminated RotateDirection.NONE as a possibility.
				-- The remaining options are AUTO, CW and CCW
				if (curKeyframe.rotateDirection == CommonCtrl.Motion.RotateDirection.AUTO) then
					change = math.mod(change,360);
					-- detect the shortest direction around the circle 
					-- i.e. keep the amount of rotation less than 180 degrees 
					if (change > 180) then
						change =change - 360;
					elseif (change < -180) then
						change = change + 360;
					end
				elseif (curKeyframe.rotateDirection == CommonCtrl.Motion.RotateDirection.CW) then
					-- force the rotation to be positive and clockwise
					if (change < 0) then
						change = math.mod(change,360) + 360;
					end
					change =change + curKeyframe.rotateTimes * 360;
				else	-- CCW
					-- force the rotation to be negative and counter-clockwise
					if (change > 0) then
						change = math.mod(change,360) - 360;
					end
					change=change - curKeyframe.rotateTimes * 360;
				end
				
			end
			
			local keyframeDuration = nextKeyframe:GetIndex() - curKeyframe:GetIndex();
			
			result = tween:getValue(timeFromKeyframe, begin, change, keyframeDuration);
			
		end
			
		return result;
end
--[[
 /**
     * Retrieves an interpolated ColorTransform object at a specific time index in the Motion instance.
     *
	 * @param index The time index of a frame in the Motion instance, as an integer greater than or equal to zero.
     *
     * @return The interpolated ColorTransform object.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript  
     * @see flash.geom.ColorTransform
     */
--]]
function Motion:getColorTransform(index)
		local result = nil;
		local curKeyframe = self:getCurrentKeyframe(index, 'color');	
		if (not curKeyframe or not curKeyframe.color) then
			return nil;
		end
		
		local begin = curKeyframe.color;
		local timeFromKeyframe = index - curKeyframe:GetIndex();
		local tween = curKeyframe:getTween('color') or curKeyframe:getTween('alpha') or curKeyframe:getTween();

		if (timeFromKeyframe == 0 or not tween)then
			result = begin;	
		elseif (tween) then
			local nextKeyframe = self:getNextKeyframe(index, 'color');
			if (not nextKeyframe or not nextKeyframe.color) then
				result = begin;
			else
				local nextColor = nextKeyframe.color;
				local keyframeDuration = nextKeyframe:GetIndex() - curKeyframe:GetIndex();
				local easedTime = tween:getValue(timeFromKeyframe, 0, 1, keyframeDuration);
				--log("!!!:"..commonlib.serialize(tween:GetTarget()).."\n");
				result =CommonCtrl.Motion.Color.interpolateTransform(begin, nextColor, easedTime);
			end
		end

		return result;
end 
	
--[[
/**
     * Adds a keyframe object to the Motion instance. 
     *
     * @param newKeyframe A keyframe object with an index property already set.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Motion, Copy Motion as ActionScript  
     * @see fl.motion.Keyframe       
     */
--]]     
function Motion:addKeyframe(newKeyframe)
		self.keyframes[newKeyframe:GetIndex()] = newKeyframe;
		local length =self:GetTableLen(self.keyframes);
		if (self:GetDuration() < length) then
			self:SetDuration (length);
		end
end

function Motion:parseTable(data)
		if( type(data) ~="table" )then return end;
		--NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
		--Map3DSystem.Misc.SaveTableToFile(data, "test/test.ini");
		local attr = data["attr"];
		local duration = tonumber ( attr["duration"] );
		if(duration)then self:SetDuration (duration);  end;
		
		len = table.getn(data);
		if(len>0)then
			local k , v;
			for k , v in ipairs(data) do
				local result = data[k];
				local name = result["name"];
				
				if(name =="source") then
					local source = CommonCtrl.Motion.Source:new();
					      source:Init(result[1]);
					      self.source = source;
				elseif(name =="Keyframe")then					  
					local keyframe = CommonCtrl.Motion.Keyframe:new();
						  keyframe:Init(result);						  
						  self:addKeyframe(keyframe);
				end
			end
		end
	--	NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
	--	Map3DSystem.Misc.SaveTableToFile(self.keyframes, "test/test2.ini");
	--_guihelper.MessageBox(commonlib.serialize(data));
end

-- because some table set value like this way
-- local t = {}; t[3] = 3; t[9] = 9;
-- so the method of table.getn( t ) can't get the lenght of the table
function Motion:GetTableLen(t)
 if ( not t) then return end;
 local len = 1 ;
 local k ,v ;
 for k , v in pairs( t ) do
	if(k > len and type(k)== "number")then
		len = k;
	end
 end
 return len;
end
