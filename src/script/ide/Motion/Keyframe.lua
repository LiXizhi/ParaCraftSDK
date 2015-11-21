--[[
Title: Keyframe
Author(s): Leio Zhang
Date: 2008/4/15
Desc: Based on Actionscript library 
/**
 * The Keyframe class defines the visual state at a specific time in a motion tween.
 * The primary animation properties are <code>position</code>, <code>scale</code>, <code>rotation</code>, <code>skew</code>, and <code>color</code>.
 * A keyframe can, optionally, define one or more of these properties.
 * For instance, one keyframe may affect only position, 
 * while another keyframe at a different point in time may affect only scale.
 * Yet another keyframe may affect all properties at the same time.
 * Within a motion tween, each time index can have only one keyframe. 
 * A keyframe also has other properties like <code>blend mode</code>, <code>filters</code>, and <code>cacheAsBitmap</code>,
 * which are always available. For example, a keyframe always has a blend mode.   
 * @playerversion Flash 9.0.28.0
 * @langversion 3.0
 * @keyword Keyframe, Copy Motion as ActionScript    
 * @see ../../motionXSD.html Motion XML Elements  
 */
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/Keyframe.lua");
------------------------------------------------------------
--]]
local Keyframe = {
	_index = -1,
	x = nil,
	y = nil,
	scaleX = nil,
	scaleY = nil,
	skewX = nil,
	skewY = nil,
	--[[
	 /**
     * An array that contains each tween object to be applied to the target object at a particular keyframe.
     * One tween can target all animation properties (as with standard tweens on the Flash authoring tool's timeline),
     * or multiple tweens can target individual properties (as with separate custom easing curves).
     */
     --]]
	tweens = nil,
	color = nil,
	--A string used to describe the keyframe.
	label = nil,
	-- A flag that controls whether scale will be interpolated during a tween.
	--If <code>false</code>, the display object will stay the same size during the tween, until the next keyframe.
	tweenScale = true,
	--[[
	/**
     * Stores the value of the Snap checkbox for motion tweens, which snaps the object to a motion guide. 
     * This property is used in the Copy and Paste Motion feature in Flash CS3 
     * but does not affect motion tweens defined using ActionScript. 
     * It is included here for compatibility with the Flex 2 compiler.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript       
     */
    --]]
	tweenSnap = false,
	--[[
	 /**
     * Stores the value of the Sync checkbox for motion tweens, which affects graphic symbols only. 
     * This property is used in the Copy and Paste Motion feature in Flash CS3 
     * but does not affect motion tweens defined using ActionScript. 
     * It is included here for compatibility with the Flex 2 compiler.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript      
     */
    --]]
	tweenSync = false,
	--[[
	/**
     * Stores the value of the Loop checkbox for motion tweens, which affects graphic symbols only. 
     * This property is used in the Copy and Paste Motion feature in Flash CS3 
     * but does not affect motion tweens defined using ActionScript. 
     * It is included here for compatibility with the Flex 2 compiler.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript         
     */
    --]]
	loop = nil,
	--[[
	/**
     * Stores the name of the first frame for motion tweens, which affects graphic symbols only. 
     * This property is used in the Copy and Paste Motion feature in Flash CS3 
     * but does not affect motion tweens defined using ActionScript. 
     * It is included here for compatibility with the Flex 2 compiler.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript        
     */
    --]]
	firstFrame = nil,
	--[[
	/**
     * Controls how the target object rotates during a motion tween,
     * with a value from the RotateDirection class.
	 *
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript         
     * @see fl.motion.RotateDirection
     */
    --]]
	rotateDirection = CommonCtrl.Motion.RotateDirection.AUTO,
	--[[
	 /**
     * Adds rotation to the target object during a motion tween, in addition to any existing rotation.
     * This rotation is dependent on the value of the <code>rotateDirection</code> property,
     * which must be set to <code>RotateDirection.CW</code> or <code>RotateDirection.CCW</code>. 
     * The <code>rotateTimes</code> value must be an integer that is equal to or greater than zero.
     * 
     * <p>For example, if the object would normally rotate from 0 to 40 degrees,
     * setting <code>rotateTimes</code> to <code>1</code> and <code>rotateDirection</code> to <code>RotateDirection.CW</code>
     * will add a full turn, for a total rotation of 400 degrees.</p>
     * 
     * If <code>rotateDirection</code> is set to <code>RotateDirection.CCW</code>,
     * 360 degrees will be <i>subtracted</i> from the normal rotation,
     * resulting in a counterclockwise turn of 320 degrees.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript         
     * @see #rotateDirection    
     */
    --]]
	rotateTimes = 0,
	--[[
	 /**
     * If set to <code>true</code>, this property causes the target object to rotate automatically 
     * to follow the angle of its path. 
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Keyframe, Copy Motion as ActionScript         
     */
    --]]
	orientToPath = false,
	--Indicates that the target object should not be displayed on this keyframe.
	blank = false,
	}
commonlib.setfield("CommonCtrl.Motion.Keyframe",Keyframe);
			
function Keyframe:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end	
function Keyframe:Init(data)
	self.tweens = {};
	self:parseTable(data);
end	

--The keyframe's unique time value in the motion tween. The first frame in a motion tween has an index of <code>0</code>.
function Keyframe:GetIndex()
		return tonumber(self._index);
end

function Keyframe:SetIndex(value)
	if(value <1) then 
		self._index = 1;
	else
		self._index = value;
	end
	
	if (self._index == 1) then
		self:setDefaults();
	end
	
	--when flash IDE convert motion to xml,sometime lose <color><Color/></color>
	--but the Color class is necessarily
	if (not self.color) then
			self.color = CommonCtrl.Motion.Color:new();
			-- set deafult property,it is necessarily
			self.color:Init();
	end
end

--Indicates the rotation of the target object in degrees 
--from its original orientation as applied from the transformation point.
--A value of <code>NaN</code> means that the keyframe does not affect self property.
function Keyframe:GetRotation()
		return self.skewY;
end

function Keyframe:SetRotation(value)
    	-- Use Flash Player behavior: set skewY to rotation and increase skewX by the difference.
   		if (not (self.skewX) or not(self.skewY)) then
			self.skewX = value;
		else
			self.skewX =self.skewX + (value - self.skewY);
			
		end
		self.skewY = value;
end
	
function Keyframe:setDefaults()
		if (not (self.x))  then self.x = 0; end
		if (not (self.y))   then self.y = 0; end
		if (not (self.scaleX))  then  self.scaleX = 1; end
		if (not (self.scaleY))  then  self.scaleY = 1; end
		if (not (self.skewX))  then  self.skewX = 0; end
		if (not (self.skewY))  then  self.skewY = 0; end
	
		
end

--Retrieves the value of a specific tweenable property on the keyframe.
--@param:tweenableName The name of a tweenable property, such as <code>"x"</code>
function Keyframe:getValue(tweenableName)
		return tonumber(self[tweenableName]);
end
      
--Changes the value of a specific tweenable property on the keyframe.
--@param:tweenableName The name of a tweenable property, such as <code>"x"</code>
function Keyframe:setValue(tweenableName, newValue)
		self[tweenableName] = newValue;
end

function Keyframe:parseTable(data)
		if( type(data) ~="table" )then return end;
		--log("-------------------------------\n");
		--log(commonlib.serialize(data).."\n");
		local attr = data["attr"];
		local index = attr["index"];
		--index
		if(not index) then 
			log('<Keyframe> is missing the required attribute "index".\n');
		else
			-- beacuse start index is 0 in flash,so (index  + 1) in lua
			self:SetIndex(tonumber( index + 1 ));
		end
		--need to set rotation first in the order because skewX and skewY override it
		local k ;
		local tweenableNames = {"rotateDirection","rotateTimes","blank","x", "y", "scaleX", "scaleY", "rotation", "skewX", "skewY"};
		for k ,tweenableName in ipairs(tweenableNames) do
			local result = attr[tweenableName];
			if (result) then
				if(tweenableName =="rotateDirection"  ) then
				 self[tweenableName] = tostring( result );
				elseif(tweenableName =="blank") then
					if(result=="true")then
						self[tweenableName] = true;
					else
						self[tweenableName] = false;
					end
				elseif(tweenableName =="rotation") then
						self:SetRotation( tonumber( result ) );
				else
					self[tweenableName] = tonumber( result );
					
				end
			end
		end
		--log("!!!:"..commonlib.serialize(self).."\n");
		len = table.getn(data);
		if(len>0)then
			local k , v;
			for k , v in ipairs(data) do
				local result = data[k];
				local name = result["name"];
				if(name =="tweens") then
					local tweensTables = result;
					for j,vv in ipairs(tweensTables) do
						local tween = tweensTables[j];
						local tweenName = tween["name"];
						if(tweenName == "CustomEase")then
							local customEase = CommonCtrl.Motion.CustomEase:new();
								  customEase:Init(tween);
								  table.insert(self.tweens,customEase);
								  --log(commonlib.serialize(customEase).."\n");
						elseif(tweenName == "SimpleEase") then
							local simpleEase = CommonCtrl.Motion.SimpleEase:new();
								  simpleEase:Init(tween);
								  table.insert(self.tweens,simpleEase);							  
						end
					end
				elseif(name =="color")then
							local color = CommonCtrl.Motion.Color:new();
							--log("!!!:"..commonlib.serialize(result).."\n");
								  color:Init(result[1]);				  
								  self.color = color;
				end
				
			end
		end
	
end


--Retrieves an ITween object for a specific animation property.
--@param:target The name of the property being tweened.
function Keyframe:getTween(target)
		for k,tween in ipairs(self.tweens) do
			
			if (tween:GetTarget() == target
				-- If we're looking for a skew tween and there isn't one, use rotation if available.
				or (tween:GetTarget() == 'rotation' 
					and (target == 'skewX' or target == 'skewY'))

				or (tween:GetTarget() == 'position' 
					and (target == 'x' or target == 'y'))

				or (tween:GetTarget() == 'scale' 
					and (target == 'scaleX' or target == 'scaleY'))
				) then
				return tween;
			end
		end
		
		return nil;
end

--Indicates whether the keyframe has an influence on a specific animation property.
-- @param:tweenableName The name of a tweenable property, such as  <code>"x"</code> or <code>"rotation"</code>.
function Keyframe:affectsTweenable(tweenableName)
		--log(tweenableName..":"..self[tweenableName].."\n");
		return	(
			 (tweenableName == nil )                                       
			or (self[tweenableName]~=nil)                         -- a valid numerical value exists for the property
			or (tweenableName == 'color' and (self.color ~= nil ))	           
			or self.blank				                            -- keyframe is empty
			or (self:getTween() ~= nil )                                      -- all properties are being tweened
		);
		--[[
		return	(
			!tweenableName                                       
			|| !isNaN(self[tweenableName])                           // a valid numerical value exists for the property
			|| (tweenableName == 'color' && self.color)	           
			|| (tweenableName == 'filters' && self.filters.length)
			|| self.blank				                             // keyframe is empty
			|| self.getTween()                                       // all properties are being tweened
		);
		--]]
end	
