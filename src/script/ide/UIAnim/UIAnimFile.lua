--[[
Title: UI Animation
Author(s): WangTian
Date: 2007/9/30
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/UIAnim/UIAnimFile.lua");

local ctl = UIAnimFile:new{
	name = "UIAnimFile1",
	text = "blarrrr",
	... = 0,
	*** = 300,
	};
ctl:getValue(1, 400);
-------------------------------------------------------
]]


if(not UIAnimFile) then UIAnimFile = {}; end
if(not UIAnimFile.AllObjects) then UIAnimFile.AllObjects = {}; end
UIAnimFile.AutoCounter = 1;


function UIAnimFile:new(o)
	o = o or {};
	
	if(not o.UIAnimation) then
		log("error: UIAnimFile contains no UIAnimation table\r\n");
		return;
	end
	
	if(not o.UIAnimSeq) then
		log("error: UIAnimFile contains no UIAnimSeq table\r\n");
		return;
	end
	
	local nCount = table.getn(o.UIAnimation);
	if(nCount > 0) then
		local k, v;
		for k, v in pairs(o.UIAnimation) do
			NPL.load("(gl)script/ide/UIAnim/UIAnimation.lua");
			o.UIAnimation[k] = UIAnimation:new(v);
		end
	else
		log("error: UIAnimFile's UIAnimation table is empty\r\n");
	end
	
	local k, v;
	for k, v in pairs(o.UIAnimSeq) do
		NPL.load("(gl)script/ide/UIAnim/UIAnimSeq.lua");
		o.UIAnimSeq[k] = UIAnimSeq:new(v);
	end
	
	
	setmetatable(o, self);
	self.__index = self;
	
	if(o.name ~= nil and type(o.name) == "string") then
		UIAnimFile.AddObject(o.name, o);
	else
		UIAnimFile.AddObject("AutoObj_"..UIAnimFile.AutoCounter, o);
		o.name = "AutoObj_"..UIAnimFile.AutoCounter;
		UIAnimFile.AutoCounter = UIAnimFile.AutoCounter + 1;
	end
	
	o.tableType = "UIAnimFile";
	
	
	return o;
end

function UIAnimFile:Destroy()

	local k, v;
	for k, v in pairs(o.UIAnimation) do
		NPL.load("(gl)script/ide/UIAnim/UIAnimation.lua");
		v:Destroy();
	end
	
	for k, v in pairs(o.UIAnimSeq) do
		NPL.load("(gl)script/ide/UIAnim/UIAnimSeq.lua");
		v:Destroy();
	end
		
	UIAnimFile.DeleteObject(self.name);
	self = nil; -- TODO: still not nil
end

function UIAnimFile.AddObject(ObjName, obj)
	UIAnimFile.AllObjects[ObjName] = obj;
end

function UIAnimFile.DeleteObject(ObjName)
	local obj = UIAnimFile.AllObjects[ObjName];
	if(obj~=nil) then
		UIAnimFile.AllObjects[ObjName] = nil;
	end
end
