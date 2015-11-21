--[[
Title: DisplayObject
Author(s): Leio Zhang
Date: 2008/4/15
Desc: Based on Actionscript library 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/DisplayObject.lua");
------------------------------------------------------------
--]]
local string_find = string.find;
local math_floor = math.floor;

local DisplayObject  = {
	name = "instanceName",
	x = 0,
	y = 0,
	scaleX = 1,
	scaleY = 1,
	rotation = 0,
	transform = {colorTransform = nil , matrix = nil},
	visible = true,
	defaultColor = "255 255 255 255";
	skewX = 0,
	skewY = 0,
	width = 0,
	height = 0,
	updateAllProperty = true,
	-- those propertys can be supported in AnimatorEngine
	updateProperty = {x=false,y=false,scaleX=false,scaleY=false,rotation=false,color=false,alpha=false}
}
commonlib.setfield("CommonCtrl.Motion.DisplayObject",DisplayObject);

function DisplayObject:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o.transform = {colorTransform = nil , matrix = nil};
	o.updateProperty = {x=false,y=false,scaleX=false,scaleY=false,rotation=false,color=false,alpha=false};
	return o
end

--function DisplayObject:InitObjectProperty()
	--local display = self:GetDisplayObj();
	--if(display)then
		--self.translationx = display.x;
		--self.translationy = display.y;
		--self.rotation = display.rotation;
		--self.defaultColor = display.color;
		--
		--self.scaleX = display.scalingx;
		--self.scaleY = display.scalingy;
	--end
	--
--end
function DisplayObject:Init()
	local display = self:GetDisplayObj();
	if(display)then
		self.translationx = display.x;
		self.translationy = display.y;
		self.rotation = display.rotation;
		self.defaultColor = self:GetColor();
		
		self.scaleX = display.scalingx;
		self.scaleY = display.scalingy;
	end
end
function DisplayObject:Update()
	local display = self:GetDisplayObj();
	if(display)then
		if(self.updateAllProperty)then
			if(self.x) then	display.translationx = self.x; end
			if(self.y) then	display.translationy = self.y; end
			if(self.visible~=nil) then	display.visible = self.visible; end
			
			local colorTransform = self.transform.colorTransform;
			self:UpdateColor(colorTransform,display);

			display.rotation = self.rotation * (math.pi/180);
			display.scalingx = self.scaleX;
			display.scalingy = self.scaleY; 
		else
			if(self.updateProperty.x) then 
				if(self.x) then	display.translationx = self.x; end
			end
			if(self.updateProperty.y) then 
				if(self.y) then	display.translationy = self.y; end
			end
			if(self.updateProperty.scaleX) then 
				display.scalingx = self.scaleX;
			end
			if(self.updateProperty.scaleY) then 
				display.scalingy = self.scaleY; 
			end
			if(self.updateProperty.rotation) then 
				display.rotation = self.rotation * (math.pi/180);
			end
			if(self.updateProperty.color or self.updateProperty.alpha) then 
				local colorTransform = self.transform.colorTransform;
				self:UpdateColor(colorTransform,display);
			end
		end
		
		--log(string.format("%s,%s,%s,%s,%s\n",self.x,self.y,self.scaleX,self.scaleY,self.rotation));
		--log(color.."\n")
		--log(colorTransform:toString().."\n")
		--log("!!!:"..commonlib.serialize(self.transform.colorTransform).."\n");
	end
end

function DisplayObject:UpdateColor(colorTransform,display)
    --*  New red value = (old red value * redMultiplier) + redOffset
    --* New green value = (old green value * greenMultiplier) + greenOffset
    --* New blue value = (old blue value * blueMultiplier) + blueOffset
    --* New alpha value = (old alpha value * alphaMultiplier) + alphaOffset
    --log(name.."\n");
	--local display = ParaUI.GetUIObject(name);
	
	local color = self:GetColor();
    local _,_,r,g,b,a = string_find(color,"%s-(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s-");
    --if(uiType == "text")then log(string.format("%s,%s,%s,%s\n",r,g,b,a)) end
    r = self:CheckNum(r)
    g = self:CheckNum(g)
    b = self:CheckNum(b)
    a = self:CheckNum(a)
   
    --log(string.format("%s,%s,%s,%s\n",r,g,b,a));
    local new_r = (r * colorTransform.redMultiplier) + colorTransform.redOffset;
    local new_g = (g * colorTransform.greenMultiplier) + colorTransform.greenOffset;
    local new_b = (b * colorTransform.blueMultiplier) + colorTransform.blueOffset;
    local new_a = (a * colorTransform.alphaMultiplier) + colorTransform.alphaOffset;
     if(uiType == "text")then log(string.format("%s,%s,%s,%s,\n",new_r,new_g,new_b,new_a)) end
    --log(string.format("%s,%s,%s,%s,\n",new_r,new_g,new_b,new_a));
    new_r = math_floor(new_r);
    new_g = math_floor(new_g);
    new_b = math_floor(new_b);
    new_a = math_floor(new_a);
    
    new_r = self:CheckNum(new_r);
    new_g = self:CheckNum(new_g);
    new_b = self:CheckNum(new_b);
    new_a = self:CheckNum(new_a);
    
    --color = new_r.." "..new_g.." "..new_b.." "..new_a;
    if(self.updateAllProperty)then
		color = new_r.." "..new_g.." "..new_b.." "..new_a;
	else
		if(self.updateProperty.color)then
			color = new_r.." "..new_g.." "..new_b.." "..a;
		end
		if(self.updateProperty.alpha)then
			color = r.." "..g.." "..b.." "..new_a;
		end
	end
	self:SetColor(color)
	--log("color updated: "..color.."\n")
end

function DisplayObject:CheckNum(n)
	if(not n ) then n = 255; end
	n = tonumber(n);
	if( n<0)then
		n = 0;
	 elseif( n>255)then
		n=255;
	end
	return n;
end

function DisplayObject:GetDisplayObj()
	local display = ParaUI.GetUIObject(self.name);
	if(display:IsValid()==false)then
		--log("warning: animator binding control:"..self.name.." is not found\n");
		display = nil;
	end
	return display;
end
function DisplayObject:SetColor(color)
	local display = ParaUI.GetUIObject(self.name);
	local uiType = display.type;
	if(uiType == "text")then
		display:GetFont("text").color = color ;
	else
		display.color = color;
	end
end
function DisplayObject:GetColor()
	local display = ParaUI.GetUIObject(self.name);
	local color;
	local uiType = display.type;
	if(uiType == "text")then
		color = display:GetFont("text").color.." 255";		
	else
		color = display.color;
	end
	return color;
end
