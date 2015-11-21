--[[
Title: ITween
Author(s): Leio Zhang
Date: 2008/4/14
Desc: Based on Actionscript library 
/**
 * The ITween interface defines the application programming interface (API) that interpolation
 * classes implement in order to work with the fl.motion classes.
 * The SimpleEase, CustomEase, BezierEase, and FunctionEase classes implement the ITween interface. 
 * @playerversion Flash 9.0.28.0
 * @langversion 3.0
 * @keyword Ease, Copy Motion as ActionScript    
 * @see ../../motionXSD.html Motion XML Elements  
 */
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/ITween.lua");
------------------------------------------------------------
--]]
commonlib.setfield("CommonCtrl.Motion", {});

local ITween = {
				_target = nil,
				};				
CommonCtrl.Motion.ITween = ITween;
function ITween:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end
--[[
/**
     * The name of the animation property to target.
     * <p>The default value is <code>""</code> (empty quotes), which targets all properties.
     * The other acceptable values are <code>"x"</code>, <code>"y"</code>, <code>"position"</code> (which targets both x and y),
     * <code>"scaleX"</code>, <code>"scaleY"</code>, <code>"scale"</code> (which targets both scaleX and scaleY),
     * <code>"skewX"</code>, <code>"skewY"</code>, <code>"rotation"</code>  (which targets both scaleX and scaleY), <code>"color"</code>, and <code>"filters"</code>.</p>
     * 
     * @default ""
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword ITween, Copy Motion as ActionScript      
     */
	function get target():String

    /**
     * @private (setter)
     */
	function set target(value:String):void
--]]

function ITween:GetTarget()
end
function ITween:SetTarget()
end
function ITween:TableConcat(firstTable,secondTable)
	if type(firstTable) =="table"  and type(secondTable) =="table"  then
		local result = {}
		local i;
		for i = 1,table.getn(firstTable) do
			table.insert(result,firstTable[i])
		end
		for i = 1,table.getn(secondTable) do
			table.insert(result,secondTable[i])
		end
		return result;
	end
end
