--[[
Title: AnimatorManager
Author(s): Leio Zhang
Date: 2008/4/28
Desc: 

AnimatorManager 包含任意层 levelManager
levelManager 包含任意个 animator

--timeline |1 2 3 4 5 6 7 8 ---------------------------------------------------------------------------max|
--level 1  |-----animator-----|-----animator-----|-----animator-----|-----animator-----|-----animator-----|
--level 2  |-----animator----------------|-----animator-----|-----animator-----|-----animator-----|

------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/AnimatorManager.lua");
------------------------------------------------------------
--]]

local MotionResource = {};
commonlib.setfield("CommonCtrl.Motion.MotionResource",MotionResource);

local AnimatorManager = {
	name = "AnimatorManager.instance",
	-- his parent is a AnimatorEngine
	parent = nil,
	-- all of animators is in AnimatorPool
	levelList = {},
	
	--event
	OnFail = nil,
}

commonlib.setfield("CommonCtrl.Motion.AnimatorManager",AnimatorManager);

function AnimatorManager:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o.levelList = {};
	o.name = ParaGlobal.GenerateUniqueID();
	return o
end

function AnimatorManager.DoFail(animatorManager)
	if(not animatorManager)then return; end
	animatorManager.OnFail(animatorManager.parent);
end
function AnimatorManager.OnFail(parent)
	
end
function AnimatorManager:GetChildLen()
	return table.getn(self.levelList);
end
function AnimatorManager:AddChild(levelManager)
	if(not levelManager) then return end;
	levelManager.parent = self;
	levelManager.OnFail = self.DoFail;
	table.insert(self.levelList,levelManager);
end

function AnimatorManager:RemoveChildAt(index)
end

function AnimatorManager:RemoveChildByName(name)
end

-- return the max length in whole levels
function AnimatorManager:GetFrameLength()
	local duration = 0;
	local k , v;
	for k,v in ipairs(self.levelList) do
		local levelManager = v;
		local len =levelManager:GetFrameLength();
		if(not len)then 
			return duration;
		end
		if(len > duration) then
			duration = len;
		end
	end
	return duration;
end

--DoPlay
function AnimatorManager:DoPlay()
	local k , v;
	for k,v in ipairs(self.levelList) do
		local levelManager = v;
		levelManager:DoPlay();
	end
end
--DoPause
function AnimatorManager:DoPause()
	local k , v;
	for k,v in ipairs(self.levelList) do
		local levelManager = v;
		levelManager:DoPause();
	end
end
--DoResume
function AnimatorManager:DoResume()
	local k , v;
	for k,v in ipairs(self.levelList) do
		local levelManager = v;
		levelManager:DoResume();
	end
end
--DoStop
function AnimatorManager:DoStop()
	local k , v;
	for k,v in ipairs(self.levelList) do
		local levelManager = v;
		levelManager:DoStop();
	end
end
--DoEnd
function AnimatorManager:DoEnd()
	local k , v;
	for k,v in ipairs(self.levelList) do
		local levelManager = v;
		levelManager:DoEnd();
	end
end
--OnTimeChange
function AnimatorManager:OnTimeChange()
	local k , v;
	for k,v in ipairs(self.levelList) do
		local levelManager = v;
		levelManager:OnTimeChange();
	end
end

function AnimatorManager:Destroy()
	local k , v;
	for k,v in ipairs(self.levelList) do
		local levelManager = v;
		levelManager:Destroy();
	end
	
end

function AnimatorManager:gotoAndPlay(frame)
	local k , v;
	for k,v in ipairs(self.levelList) do
		local levelManager = v;
		levelManager:gotoAndPlay(frame);
	end
end



