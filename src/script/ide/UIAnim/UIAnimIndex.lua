--[[
Title: UI Object Animation Index
Author(s): WangTian
Date: 2007/11/1
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/UIAnim/UIAnimIndex.lua");
-------------------------------------------------------

--NOTE: currently NOT used

]]

--NPL.load("(gl)script/ide/UIAnim/UIAnimBlock.lua");

if(not UIAnimIndex) then UIAnimIndex = {}; end

if(not UIAnimIndex.AllObjects) then UIAnimIndex.AllObjects = {}; end

UIAnimIndex.AutoCounter = 1;


function UIAnimIndex:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	
	-- is animation looping
	o.isLooping = false;
	-- current index, -1 if invalid
	o.nIndex = -1;
	-- the animation ID as seen by outsiders
	o.nAnimID = 0;
	-- current frame
	o.nCurrentFrame = 0;
	-- start frame
	o.nStartFrame = 0;
	-- end frame
	o.nEndFrame = 0;
end

function UIAnimIndex:Destroy()
	UIAnimIndex.DeleteObject(self.name);
	self = nil; -- TODO: still not nil
end

function UIAnimIndex.AddObject(ObjName, obj)
	UIAnimIndex.AllObjects[ObjName] = obj;
end

function UIAnimIndex.DeleteObject(ObjName)
	local obj = UIAnimIndex.AllObjects[ObjName];
	if(obj ~= nil) then
		UIAnimIndex.AllObjects[ObjName] = nil;
	end
end