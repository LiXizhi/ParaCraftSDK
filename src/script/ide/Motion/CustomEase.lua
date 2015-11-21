--[[
Title: CustomEase
Author(s): Leio Zhang
Date: 2008/4/14
Desc: Based on Actionscript library 
/**
 * The CustomEase class is used to modify specific properties of the easing behavior of a motion tween as
 * the tween progresses over time. 
 * A custom easing curve is composed of one or more cubic Bezier curves.
 * You can apply the custom easing curve to all properties at once, 
 * or you can define different curves for different properties.
 * <p>The implementation of this class parallels the Flash CS3 Custom Ease In/Ease Out dialog box. Flash CS3
 * displays a graph in the Custom Ease In/Ease Out dialog box representing the degree of motion over time. 
 * The horizontal axis represents frames, and the vertical axis represents the percent of change of a property
 * through the progression of the tween. The first keyframe is represented as 0%, and the last keyframe is 
 * represented as 100%. The slope of the graph's curve represents the rate of change of the object. When the 
 * curve is <code>horizontal</code> (no slope), the velocity is zero; when the curve is <code>vertical</code>, an instantaneous rate of 
 * change occurs.</p>
 * @playerversion Flash 9.0.28.0
 * @langversion 3.0
 * @keyword Ease, Copy Motion as ActionScript    
 * @see ../../motionXSD.html Motion XML Elements 
 */
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/CustomEase.lua");
------------------------------------------------------------
--]]
local CustomEase = commonlib.inherit(CommonCtrl.Motion.ITween, {
	--[[
	/**
      * An ordered collection of points in the custom easing curve.
      * Each item in the array is a <code>flash.geom.Point</code> instance.
      * The x and y properties of each point are normalized to fall between <code>0</code> and <code>1</code>,
      * where <code>0</code> is the value of the animation property at the beginning of the tween,
      * and <code>1</code> is the value at the end of the tween.
      * The first and last points of the curve are not included in the array
      * because the first point is locked to the starting value defined by the current keyframe,
      * and the last point is locked to the ending value defined by the next keyframe. 
      * On the custom easing curve, these points correspond to values of (0, 0) and (1, 1), respectively.
      * @playerversion Flash 9.0.28.0
      * @langversion 3.0
      * @keyword Ease, points, Copy Motion as ActionScript      
      * @see flash.geom.Point
      *  
      */
     --]]
	points = nil,
	firstNode = nil,
	lastNode = nil,
	_target = nil,
});

commonlib.setfield("CommonCtrl.Motion.CustomEase",CustomEase);



--[[
/**
     * The name of the animation property to target.
     * @default ""
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Animation, target, Copy Motion as ActionScript      
     * @see fl.motion.ITween#target     
     */
--]]
function CustomEase:GetTarget()
	return self._target;
end

function CustomEase:SetTarget(v)
	self._target = v;
end

function CustomEase:Init(data)
	self.points = {};
	self:parseTable(data);
	self.firstNode = CommonCtrl.Motion.Point:new{x = 0, y = 0};
	self.lastNode = CommonCtrl.Motion.Point:new{x = 1, y = 1};
end

function CustomEase:parseTable(data)
	if( type(data) ~="table" )then return end;
	if(data["attr"]) then
		local targ = data["attr"]["target"]
		self:SetTarget(targ);	
	end
	local len = table.getn(data);
	if(len>0)then
		local k , v;
		for k , v in ipairs(data) do	
			local child = data[k];		
			local x,y = tonumber( child["attr"]["x"] ),tonumber( child["attr"]["y"] );
			local point = CommonCtrl.Motion.Point:new{x = x, y = y};
			table.insert(self.points,point);
		end
	end	  	
end
--[[
/**
     * Calculates an interpolated value for a numerical property of animation,
     * using a custom easing curve. 
     * The percent value is read from the CustomEase instance's <code>points</code> property,
     * rather than being passed into the method.
     * Using the property value allows the function signature to match the ITween interface.
     *
     * @param time The time value, which must lie between <code>0</code> and <code>duration</code>, inclusive.
     * You can choose any unit (for example. frames, seconds, milliseconds), 
     * but your choice must match the <code>duration</code> unit.
	 *
     * @param begin The value of the animation property at the start of the tween, when time is 0.
     *
     * @param change The change in the value of the animation property over the course of the tween. 
     * The value can be positive or negative. For example, if an object rotates from 90 to 60 degrees, the <code>change</code> is <code>-30</code>.
     *
     * @param duration The length of time for the tween. This value must be greater than zero.
     * You can choose any unit (for example, frames, seconds, milliseconds), 
     * but your choice must match the <code>time</code> unit.
     *
     * @return The interpolated value at the specified time.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword CustomEase, Copy Motion as ActionScript  
     * @see #points
     */
 --]]
function CustomEase:getValue( time, begin, change, duration )
	if (duration <=0) then return nil ; end
	local percent = time / duration ;
	if(percent <=0) then return begin; end
	if(percent >=1) then return begin + change ; end
	
	local pts = self._super:TableConcat({self.firstNode},self.points);
	table.insert(pts,self.lastNode);
	
	local easedPercent = self:getYForPercent(percent,pts);

	local result = begin + easedPercent * change;
	--if(self:GetTarget()=="color")then
	--log(string.format("%s,%s,%s\n",begin, easedPercent, change));
	--end
	
	return result;	
end

function CustomEase:getYForPercent(percent,pts)
	local bez0 = CommonCtrl.Motion.BezierSegment:new{a = pts[1], b = pts[2], c = pts[3],d = pts[4]};
	local beziers  = {bez0};
	local i , len = 4 , table.getn(pts)-3 ;
	
	while(i<=len) do
		
		
		table.insert(beziers , CommonCtrl.Motion.BezierSegment:new{a = pts[i],b = pts[i+1],c = pts[i+2],d = pts[i+3]})
		i = i + 3;
	end
	local theRightBez = bez0;
	--log("-----------\n");
	--log(table.getn(beziers).."\n");
	--log(commonlib.serialize(beziers).."\n");
	len = table.getn(pts);
	
	if (len >=5) then
		for bi = 1,table.getn(beziers) do
			local bez = beziers[bi];
			if(bez.a and bez.d)then
				if (bez.a.x <=percent and percent <=bez.d.x) then
					theRightBez = bez;
					break
				end
			end
		end
	end
	--log(commonlib.serialize(self:GetTarget()).."\n");
	
	local easedPercent = theRightBez:getYForX(percent);
	--if(self:GetTarget()=="color")then
	
		
	--end
	return  easedPercent;
end