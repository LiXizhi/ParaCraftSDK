--[[
Title: UI Animation
Author(s): WangTian
Date: 2007/9/30
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/UIAnim/UIAnimSeq.lua");

local ctl = UIAnimSeq:new{
	name = "UIAnimSeq1",
	text = "blarrrr",
	... = 0,
	*** = 300,
	};
ctl:getValue(1, 400);
-------------------------------------------------------
]]


if(not UIAnimSeq) then UIAnimSeq = {}; end
if(not UIAnimSeq.AllObjects) then UIAnimSeq.AllObjects = {}; end
UIAnimSeq.AutoCounter = 1;


function UIAnimSeq:new(o)
	o = o or {};
	
	setmetatable(o, self);
	self.__index = self;
	
	if(o.name ~= nil and type(o.name) == "string") then
		UIAnimSeq.AddObject(o.name, o);
	else
		UIAnimSeq.AddObject("AutoObj_"..UIAnimSeq.AutoCounter, o);
		o.name = "AutoObj_"..UIAnimSeq.AutoCounter;
		UIAnimSeq.AutoCounter = UIAnimSeq.AutoCounter + 1;
	end
	
	o.tableType = "UIAnimSeq";
	
	
	return o;
end

function UIAnimSeq:Destroy()
	UIAnimSeq.DeleteObject(self.name);
	self = nil; -- TODO: still not nil
end

function UIAnimSeq.AddObject(ObjName, obj)
	UIAnimSeq.AllObjects[ObjName] = obj;
end

function UIAnimSeq.DeleteObject(ObjName)
	local obj = UIAnimSeq.AllObjects[ObjName];
	if(obj~=nil) then
		UIAnimSeq.AllObjects[ObjName] = nil;
	end
end


--function UIAnimSeq:GetTranslationXValue(currentFrame)
	--local animID = file.UIAnimSeq[ID].AnimID;
	--local seq = file.UIAnimSeq[ID].Seq;
	--
	--
	--file.UIAnimation[animID]:GetTranslationXValue(SeqID, frame);
	--
	--local valSX = file.UIAnimation[animID].TranslationX:getValue(seq[currentSeqID], currentFrame);
--end
--
--
--function UIAnimSeq:GetCurrentSeqID(currentFrame)
--
	--file.UIAnimation[animID]:GetTranslationXTimeInterval(SeqID);
--end