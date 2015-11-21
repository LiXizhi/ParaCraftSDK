--[[
Title: DisplayObject2D
Author(s): Leio
Date: 2009/7/28
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display2D/DisplayObject2D.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display2D/Scene2DManager.lua");
NPL.load("(gl)script/ide/Display2D/Rectangle2D.lua");
local Events = {
	MouseOver = "MouseOver",
	MouseOut = "MouseOut",
	MouseMove = "MouseMove",
	MouseDown = "MouseDown",
	MouseUp = "MouseUp",
	EnterFrame = "EnterFrame",
}
commonlib.setfield("CommonCtrl.Display2D.Events",Events);
local DisplayObject2DEnums = {
	DisplayObject2D = "DisplayObject2D",
	Bitmap2D = "Bitmap2D",
	Sprite2D = "Sprite2D",
	TextField2D = "TextField2D",
	Button2D = "Button2D",
}
commonlib.setfield("CommonCtrl.Display2D.DisplayObject2DEnums",DisplayObject2DEnums);
local DisplayObject2D ={
	parent = nil,
	type = CommonCtrl.Display2D.DisplayObject2DEnums.DisplayObject2D,
	uid = "",
	index = 0,
	x = 0,
	y = 0,
	scalex = 1,
	scaley = 1,
	width = 0,
	height = 0,
	alpha = 1,
	color = "255 255 255",
	rotation = 0,
	visible = true,
	
}  
commonlib.setfield("CommonCtrl.Display2D.DisplayObject2D",DisplayObject2D);
function DisplayObject2D:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o:OnInit_Internal();
	return o
end
function DisplayObject2D:OnInit_Internal()
	local uid = ParaGlobal.GenerateUniqueID();
	self.uid = uid;
	self.events = {};	
end

function DisplayObject2D:OnInit()
	
end
function DisplayObject2D:SetUID(uid)
	self.uid = uid;
end
function DisplayObject2D:GetUID()
	return tostring(self.uid);
end
function DisplayObject2D:GetRenderType()
	return self.type;
end
function DisplayObject2D:SetIndex(value)
	self.index = value;
end
function DisplayObject2D:GetIndex()
	return self.index;
end
--值从0-1
function DisplayObject2D:SetAlpha(value)
	if(not value)then return end
	if(value < 0)then
		value = 0;
	elseif(value > 1)then
		value = 1;
	end
	self.alpha = value;
	self:UpdateNode();
end
function DisplayObject2D:GetAlpha()
	return self.alpha;
end

--value = "255 255 255"
function DisplayObject2D:SetColor(value)
	if(not value)then return end
	self.color = value;
	self:UpdateNode();
end
function DisplayObject2D:GetColor()
	return self.color;
end
function DisplayObject2D:GetColorAndAlpha()
	if(self.color)then
		local result = string.format("%s %d",self.color,math.floor(self.alpha * 255));
		return result;
	end
end
-- position
function DisplayObject2D:GetPosition()
	return self.x,self.y,self.z;
end
-- relative to the local coordinates of the parent DisplayObjectContainer.
function DisplayObject2D:SetPosition(x,y)
	if(not x or not y)then return end
	self.x,self.y = x,y;	
	self:UpdateNode();
end
function DisplayObject2D:GetScaleX()
	return self.scalex;
end
function DisplayObject2D:SetScaleX(value)
	self.scalex = value;
	self:UpdateNode();
end
function DisplayObject2D:GetScaleY()
	return self.scaley;
end
function DisplayObject2D:SetScaleY(value)
	self.scaley = value;
	self:UpdateNode();
end
function DisplayObject2D:GetRotation()
	return self.rotation;
end
function DisplayObject2D:SetRotation(value)
	self.rotation = value;
	self:UpdateNode();
end
function DisplayObject2D:GetVisible()
	return self.visible;
end
function DisplayObject2D:SetVisible(value)
	self.visible = value;
	self:UpdateNode();
end
-- 返回所有可以被更新的属性,在渲染的时候使用
function DisplayObject2D:GetUpdateablePropertys()
	local rect = self:GetRect();
	local params = {
		x = rect.x,
		y = rect.y,
		width = rect.width,
		height = rect.height,	
	}
	local scalex,scaley,alpha,color,rotation,visible = self.scalex,self.scaley,self.alpha,self.color,self.rotation,self.visible
	local parent = self:GetParent();
	while(parent) do
		scalex = scalex * parent.scalex;
		scaley = scaley * parent.scaley;
		alpha = alpha * parent.alpha;
		--color = color * parent.color;没有处理
		rotation = rotation + parent.rotation;
		visible = parent.visible;
		parent = parent:GetParent()
	end
	params.scalex = scalex;
	params.scaley = scaley;
	params.alpha = alpha;
	params.color = color;
	params.rotation = rotation;
	params.visible = visible;
	return params;
end
-- parent
function DisplayObject2D:GetParent()
	return self.parent;
end
function DisplayObject2D:SetParent(parent)
	self.parent = parent;
end
function DisplayObject2D:HasParent()
	if(self.parent)then
		return true;
	else
		return false;
	end
end

function DisplayObject2D:GlobalToLocal(point)
	if(not point)then 
		point = {x = 0, y = 0};
	end
	local x,y = 0,0;	
	local parent = self;
	while(parent) do
		local px,py = parent:GetPosition();
		x = x - px;
		y = y - py;
		parent = parent:GetParent()
	end
	x = x - point.x;
	y = y - point.y;
	return {x = x,y = y};
end
-- local to global
function DisplayObject2D:LocalToGlobal(point)
	if(not point)then 
		point = {x = 0, y = 0};
	end
	local x,y = 0,0;
	local parent = self;
	while(parent) do
		local px,py = parent:GetPosition();
		x = x + px;
		y = y + py;
		parent = parent:GetParent()
	end
	x = x + point.x;
	y = y + point.y;
	
	return {x = x,y = y};
end
--返回一个区域，它的参照坐标是targetCoordinateSpace = {x = x,y = y}
function DisplayObject2D:GetRect(targetCoordinateSpace)
	local pt;
	if(targetCoordinateSpace)then
		pt = targetCoordinateSpace;
	else
		pt = {x = 0,y = 0};
	end
	local point = self:LocalToGlobal(pt);
	local rect = CommonCtrl.Display2D.Rectangle2D:new{
		x = point.x,
		y = point.y,
		width = self.width,
		height = self.height,
	}
	return rect;
end
function DisplayObject2D:BeBuilded()
	CommonCtrl.Display2D.Scene2DManager.BuildNode(self);
end
function DisplayObject2D:BeDestroy()
	CommonCtrl.Display2D.Scene2DManager.DestroyNode(self);
end
function DisplayObject2D:UpdateNode()
	CommonCtrl.Display2D.Scene2DManager.UpdateNode(self);
end
function DisplayObject2D:GetRoot()
	local result = self;
	local parent = self:GetParent();
	while(parent)do
		result = parent;
		parent = parent:GetParent();		
	end
	return result;
end
function DisplayObject2D:AddEventListener(event_type,event_holder,func)
	if(not self.events)then
		self.events = {};
	end
	if(not self.events[event_type])then
		self.events[event_type] = {};
	end
	self.events[event_type][func] = {event_holder = event_holder,func = func};
end
function DisplayObject2D:DispatchEvent(event_type,args)
	if(not self.events)then return end
	local func_table = self.events[event_type];
	if(func_table)then
		local k,v;
		for k,v in pairs(func_table) do
			if(v)then
				local event_holder = v.event_holder;
				local func = v.func;
				if(func and type(func) == "function")then
					func(event_holder,args);
				end
			end
		end
	end
end
function DisplayObject2D:OnMouseOver(args)
	self:DispatchEvent("MouseOver",args);
end
function DisplayObject2D:OnMouseOut(args)
	self:DispatchEvent("MouseOut",args);
end
function DisplayObject2D:OnMouseDown(args)
	self:DispatchEvent("MouseDown",args);
end
function DisplayObject2D:OnMouseUp(args)
	self:DispatchEvent("MouseUp",args);
end
function DisplayObject2D:OnMouseMove(args)
	self:DispatchEvent("MouseMove",args);
end
function DisplayObject2D:OnEnterFrame(args)
	self:DispatchEvent("EnterFrame",args);
end