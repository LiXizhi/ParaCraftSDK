--[[
Title: Source
Author(s): Leio Zhang
Date: 2008/4/15
Desc: Based on Actionscript library 
/**
 * The Source class stores information about the context in which a Motion instance was generated.
 * Many of its properties do not affect animation created using ActionScript with the Animator class 
 * but are present to store data from the Motion XML.
 * The <code>transformationPoint</code> property is the most important for an ActionScript Motion instance.
 * @playerversion Flash 9.0.28.0
 * @langversion 3.0
 * @keyword Source, Copy Motion as ActionScript    
 * @see ../../motionXSD.html Motion XML Elements   
 */
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/Source.lua");
------------------------------------------------------------
--]]
local Source = {
	frameRate = nil,
	instanceName = nil,
	x = 0,
	y = 0,
	scaleX = 1,
	scaleY = 1,
	skewX = 0,
	skewY = 0,
	rotation = 0,
	--[[
     * Specifies the location of the transformation or "pivot" point of the original object, 
     * from which transformations are applied.
     * The coordinates of the transformation point are defined as a percentage of the visual object's dimensions (its bounding box). If the transformation point is at the upper-left
     * corner of the bounding box, the coordinates are (0, 0). The lower-right corner of the 
     * bounding box is (1, 1). This property allows the transformation point to be applied
     * consistently to objects of different proportions 
     * and registration points. The transformation point can lie outside of the bounding box, 
     * in which case the coordinates may be less than 0 or greater than 1.
     * This property has a strong effect on Motion instances created using ActionScript.
    --]]
	transformationPoint = nil,
    --Indicates the position and size of the bounding box of the object from which the Motion instance was generated.
    --This property stores data from Motion XML but does not affect Motion instances created using ActionScript.
	dimensions = nil
	}
commonlib.setfield("CommonCtrl.Motion.Source",Source);
			
function Source:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end
function Source:Init(data)
	self:parseTable(data);
end
--[[
{
					[1] = {
						[1] = {
							["attr"] = {
								["top"] = "5",
								["height"] = "125.5",
								["left"] = "13",
								["width"] = "125.5",
							},
							["name"] = "geom:Rectangle",
						},
						["name"] = "dimensions",
						["n"] = 1,
					},
					[2] = {
						[1] = {
							["attr"] = {
								["y"] = "0.5",
								["x"] = "0.5",
							},
							["name"] = "geom:Point",
						},
						["name"] = "transformationPoint",
						["n"] = 1,
					},
					["attr"] = {
						["frameRate"] = "12",
						["elementType"] = "movie clip",
						["rotation"] = "0",
						["x"] = "140.35",
						["y"] = "142.35",
						["instanceName"] = "moveShape",
						["symbolName"] = "myShape",
						["scaleX"] = "1",
						["scaleY"] = "1",
					},
					["name"] = "Source",
					["n"] = 2,
}
				
--]]
function Source:parseTable(data)
		if( type(data) ~="table" )then return end;
		--_guihelper.MessageBox(commonlib.serialize(self.rotation));
		local attr = data["attr"];
		
		local names = {'instanceName','frameRate','x', 'y', 'scaleX', 'scaleY', 'rotation', 'skewX', 'skewY'};
		for k ,name in ipairs(names) do		
			local result = attr[name];
			if (result) then
				if(name =="instanceName")then
					self[name] =tostring( result );
				else
					self[name] =tonumber( result );
				end
			end
		end
		len = table.getn(data);
		if(len>0)then
			local k , v;
			for k , v in ipairs(data) do
				local result = data[k];
				local name = result["name"];
				if(name =="dimensions") then
					local left = tonumber( result[1]["attr"]["left"] );
					local top = tonumber( result[1]["attr"]["top"] );
					local width = tonumber( result[1]["attr"]["width"] );
					local height = tonumber( result[1]["attr"]["height"] );
					self.dimensions = {left = left , top = top , width = width , height = height };
				elseif(name =="transformationPoint")then
					local x = tonumber( result[1]["attr"]["x"] );
					local y = tonumber( result[1]["attr"]["y"] );
					self.transformationPoint = CommonCtrl.Motion.Point:new{x = x,y = y};
				end
			end
		end
		--_guihelper.MessageBox(commonlib.serialize(self));
		--log(commonlib.serialize(self));	
		return self;
end