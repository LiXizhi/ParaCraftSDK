--[[
Title: Color
Author(s): Leio Zhang
Date: 2008/4/22
Desc: Based on Actionscript library 
/**
 * The Color class extends the Flash Player ColorTransform class,
 * adding the ability to control brightness and tint.
 * It also contains static methods for interpolating between two ColorTransform objects
 * or between two color numbers. 
 * @playerversion Flash 9.0.28.0
 * @langversion 3.0
 * @keyword Color, Copy Motion as ActionScript    
 * @see flash.geom.ColorTransform ColorTransform class
 * @see ../../motionXSD.html Motion XML Elements
 */
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/Color.lua");
------------------------------------------------------------
--]]
local Color = commonlib.inherit(CommonCtrl.Motion.ColorTransform, {
	_tintColor = "000000",
	_tintMultiplier = 0,
});

commonlib.setfield("CommonCtrl.Motion.Color",Color);
--[[
/**
     * The percentage of brightness, as a decimal between <code>-1</code> and <code>1</code>. 
     * Positive values lighten the object, and a value of <code>1</code> turns the object completely white.
     * Negative values darken the object, and a value of <code>-1</code> turns the object completely black. 
     * 
     * @default 0
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword brightness, Copy Motion as ActionScript        
     */
--]]
function Color:GetBrightness()
        return (self.redOffset and (1-self.redMultiplier) ) or (self.redMultiplier-1);
end

function Color:SetBrightness(value)
		
		if (value > 1) then 
			value = 1; 
		elseif (value < -1)then
			value = -1;
		end
		local percent = 1 - math.abs(value);
		local offset = 0;
		if (value > 0) then offset = value * 255; end;
		self.redMultiplier = percent
		self.greenMultiplier = percent
		self.blueMultiplier = percent;
		self.redOffset     = offset;
		self.greenOffset   = offset;
		self.blueOffset    = offset;
end

--[[
 /**
     * Sets the tint color and amount at the same time.
     *
     * @param tintColor The tinting color value in the 0xRRGGBB format.
     *
     * @param tintMultiplier The percentage to apply the tint color, as a decimal value between <code>0</code> and <code>1</code>.
     * When <code>tintMultiplier = 0</code>, the target object is its original color and no tint color is visible.
     * When <code>tintMultiplier = 1</code>, the target object is completely tinted and none of its original color is visible.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword brightness, Copy Motion as ActionScript         
     */
--]]
function Color:setTint(tintColor, tintMultiplier)
		self._tintMultiplier = tintMultiplier;
		self.redMultiplier = 1 - tintMultiplier;
		self.greenMultiplier = 1 - tintMultiplier;
		self.blueMultiplier = 1 - tintMultiplier;
		tintColor = tonumber(tintColor,16);
		local r = mathlib.bit.band ( mathlib.bit.rshift(tintColor,16) , 255 );
		local g = mathlib.bit.band ( mathlib.bit.rshift(tintColor,8)  , 255 );
		local b = mathlib.bit.band (                         tintColor  , 255 );
		
		--r = mathlib.bit.Hex2Dec( r );
		--g = mathlib.bit.Hex2Dec( g );
		--b = mathlib.bit.Hex2Dec( b );
		
		self.redOffset   = math.floor(r * tintMultiplier);
		self.greenOffset = math.floor(g * tintMultiplier);
		self.blueOffset  = math.floor(b * tintMultiplier);
		--log(r.."\n");
		--log("!!!:"..commonlib.serialize(self).."\n");
		--var r:uint = (tintColor >> 16) & 0xFF;
		--var g:uint = (tintColor >>  8) & 0xFF;
		--var b:uint =  tintColor        & 0xFF;
		--self.redOffset   = Math.round(r * tintMultiplier);
		--self.greenOffset = Math.round(g * tintMultiplier);
		--self.blueOffset  = Math.round(b * tintMultiplier);
end	


--[[
/**
     * The tinting color value in the 0xRRGGBB format.
     * 
     * 
     * @default 0x000000 (black)
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword tint, Copy Motion as ActionScript        
     */
--]]
function Color:GetTintColor()
        return self._tintColor;
end

function Color:SetTintColor(value)
		self:setTint(value, self:GetTintMultiplier());
end

--[[
// Capable of deriving a tint color from the color offsets,
	// but the accuracy decreases as the tint multiplier decreases (rounding issues).
    /**
     * @private 
     */
--]]
function Color:deriveTintColor()
		local ratio = 1 / (self:GetTintMultiplier()); 
		-- TODO:math.round?
		local r = math.floor(self.redOffset * ratio);
		local g = math.floor(self.greenOffset * ratio);
		local b = math.floor(self.blueOffset * ratio);
		local colorNum ;
		colorNum = mathlib.bit.bor ( mathlib.bit.lshift(r,16) , mathlib.bit.lshift(g,8) )
		colorNum = mathlib.bit.bor (                 colorNum ,  b )
		--local colorNum = r<<16 | g<<8 | b;
		
		--colorNum = mathlib.bit.Hex2Dec( colorNum );
		
		return colorNum; 
end

--[[
/**
     * The percentage to apply the tint color, as a decimal value between <code>0</code> and <code>1</code>.
     * When <code>tintMultiplier = 0</code>, the target object is its original color and no tint color is visible.
     * When <code>tintMultiplier = 1</code>, the target object is completely tinted and none of its original color is visible.
     * @default 0
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword tint, Copy Motion as ActionScript        
     */
--]]
function Color:GetTintMultiplier()
        return self._tintMultiplier;
end

function Color:SetTintMultiplier(value)
		self:setTint(self:GetTintColor(), value);
end

function Color:Init(data)
	self:SetTintColor(self._tintColor);
	self:SetBrightness(0);
	self:SetTintMultiplier(self._tintMultiplier);
	self:parseTable(data);
end
--[[
{

["name"]="Color",

["attr"]={

["tintColor"]="0xFF7FFF",

["tintMultiplier"]="1",

}
--]]
function Color:parseTable(data)
	
	if( type(data) ~="table" )then return end;
	local attr = data["attr"];
	if(data["name"]=="Color" and attr~= nil)then	
	local name,result;
		for name ,result in pairs(attr) do
			    
					if(name =="tintColor"  ) then	
						local _,_,result = string.find(result,"0x(.+)")
						--log(result.."\n");
						--log("------\n");
						self:SetTintColor(result);
					elseif(name =="brightness") then
						self:SetBrightness( tonumber(result) );
					elseif(name =="tintMultiplier") then
						self:SetTintMultiplier(tonumber(result));
					else
						self[name] = tonumber(result);
					end
				
		end
		--log("!!!:"..commonlib.serialize(self).."\n");
	end
end

--[[
/**
     * Blends smoothly from one ColorTransform object to another.
     *
     * @param fromColor The starting ColorTransform object.
     *
     * @param toColor The ending ColorTransform object.
     *
     * @param progress The percent of the transition as a decimal, where <code>0</code> is the start and <code>1</code> is the end.
     *
     * @return The interpolated ColorTransform object.
     * @playerversion Flash 9.0.28.0
     * @langversion 3.0
     * @keyword blend, Copy Motion as ActionScript         
     */
--]]
function CommonCtrl.Motion.Color.interpolateTransform(fromColor, toColor, progress)
		local q = 1-progress;
		local resultColor = CommonCtrl.Motion.ColorTransform:new{
			  redMultiplier        = fromColor.redMultiplier*q   + toColor.redMultiplier*progress
			, greenMultiplier      = fromColor.greenMultiplier*q + toColor.greenMultiplier*progress
			, blueMultiplier       = fromColor.blueMultiplier*q  + toColor.blueMultiplier*progress
			, alphaMultiplier      = fromColor.alphaMultiplier*q + toColor.alphaMultiplier*progress
			, redOffset            = fromColor.redOffset*q       + toColor.redOffset*progress
			, greenOffset          = fromColor.greenOffset*q     + toColor.greenOffset*progress
			, blueOffset           = fromColor.blueOffset*q      + toColor.blueOffset*progress
			, alphaOffset          = fromColor.alphaOffset*q     + toColor.alphaOffset*progress
		}
		
		return resultColor;		
end
	
