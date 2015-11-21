--[[
Title: LayerManager
Author(s): Leio Zhang
Date: 2009/3/26
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Storyboard/LayerManager.lua");
------------------------------------------------------------
--]]
local LayerManager={};
commonlib.setfield("CommonCtrl.Storyboard.LayerManager",LayerManager);
function LayerManager:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o:Init();
	
	return o
end
function LayerManager:Init()
	self.name = ParaGlobal.GenerateUniqueID();
	self.childrenList = {};
end	
function LayerManager:AddChild(child)
	if(not child)then return; end
	table.insert(self.childrenList,child);
	child._parent = self;
    self:UpdateDuration()
end
function LayerManager:UpdateDuration()
	local k,v;
	local dur = 0;
	for k,v in ipairs(self.childrenList) do
		local child = v;
		if(child)then
			child:UpdateDuration();
			dur = dur + child:GetDuration();
			self:SetDuration(dur);
		end
	end
end
function LayerManager:SetDuration(d)
	self._duration = d;
end
function LayerManager:GetDuration()
	return self._duration;
end
function LayerManager:Update(frame)
	local child,frame = self:GetPlayingChild(frame);
	if(child and frame)then
		child:Update(frame);
	end
end
function LayerManager:GetPlayingChild(frame)
	if(not frame)then return end
	local dur = 0;
	local pre_dur = 0;
	local len = #self.childrenList;
	local k,v
	for k = 1,len  do
		local pre_child = self.childrenList[k-1];
		local child = self.childrenList[k];	
		if(pre_child)then
			pre_dur = pre_dur + pre_child:GetDuration();
		end
		if(child)then
			dur = dur +  child:GetDuration();
		end
		if(frame <= dur)then
				return child,frame - pre_dur;
		end	
	end
end
function LayerManager:ReplaceTargetName(oldName,newName)
	if(not oldName or not newName)then return end
	local k,v;
	for k,v in ipairs(self.childrenList) do
		v:ReplaceTargetName(oldName,newName)
	end
end
function LayerManager:DoPrePlay()
	local k,v;
	for k,v in ipairs(self.childrenList) do
		local child = v;
		child:DoPrePlay();
	end	
end