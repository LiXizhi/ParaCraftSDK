--[[
Title: ColorTransform
Author(s): Leio Zhang
Date: 2008/4/22
Desc: Based on Actionscript library 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/ColorTransform.lua");
------------------------------------------------------------
--]]
--[[
/**
     
     * @param redMultiplier The percentage to apply the color, as a decimal value between 0 and 1.
     * @param greenMultiplier The percentage to apply the color, as a decimal value between 0 and 1.
     * @param blueMultiplier The percentage to apply the color, as a decimal value between 0 and 1.
     * @param alphaMultiplier A decimal value that is multiplied with the alpha transparency channel value, as a decimal value between 0 and 1.
     * @param redOffset A number from -255 to 255 that is added to the red channel value after it has been multiplied by the <code>redMultiplier</code> value. 
     * @param greenOffset A number from -255 to 255 that is added to the green channel value after it has been multiplied by the <code>greenMultiplier</code> value. 
     * @param blueOffset A number from -255 to 255 that is added to the blue channel value after it has been multiplied by the <code>blueMultiplier</code> value. 
     * @param alphaOffset A number from -255 to 255 that is added to the alpha channel value after it has been multiplied by the <code>alphaMultiplier</code> value.
     *
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword Color       
     */
--]]
local ColorTransform = {
				redMultiplier = 1,
				greenMultiplier = 1,
				blueMultiplier = 1,
				alphaMultiplier = 1,
				redOffset = 0,
				greenOffset = 0,
				blueOffset = 0,
				alphaOffset = 0,
				
				};			
commonlib.setfield("CommonCtrl.Motion.ColorTransform",ColorTransform);	
function ColorTransform:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end

function ColorTransform:toString()
	local colorTransform = self;
	local s = string.format("%s,%s,%s,%s,%s,%s,%s,%s\n",colorTransform.redMultiplier,
											 colorTransform.greenMultiplier,
											 colorTransform.blueMultiplier,
											 colorTransform.alphaMultiplier,
											 colorTransform.redOffset,
											 colorTransform.greenOffset,
											 colorTransform.blueOffset,
											 colorTransform.alphaOffset);
	return s;											 
end
