--[[
Title: LayerManager
Author(s): Leio Zhang
Date: 2008/4/28
Desc: 

------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/LayerManager.lua");
------------------------------------------------------------
--]]

local LayerManager = {
	name = "LayerManager_instance",
	parent = nil,
	movieClipList = {},
	index = 1,
	
	OnFail = nil,
}

commonlib.setfield("CommonCtrl.Motion.LayerManager",LayerManager);

function LayerManager:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o.movieClipList = {};
	o.name = ParaGlobal.GenerateUniqueID();
	return o
end
function LayerManager.DoFail(layerManager)
	if(not layerManager)then return; end
	layerManager.OnFail(layerManager.parent);
end
function LayerManager.OnFail(parent)
end
function LayerManager:AddChild(animator)
	if(not animator.isValid) then return end;
	animator.parent = self;
	animator.OnFail = self.DoFail;
	table.insert(self.movieClipList,animator);
end

function LayerManager:RemoveChildAt(index)
end

function LayerManager:RemoveChildByName(name)
end

function LayerManager:GetLength()
	return table.getn(self.movieClipList);
end
function LayerManager:GetFrameLength()
	local k , v;
	local duration = 0;
	--log("-----------\n");
	for k,v in ipairs(self.movieClipList) do
		local movieClip = v;
		local motion = movieClip:GetMotion();
		--log(motion:GetDuration().."\n");
		duration =duration + motion:GetDuration();
	end
	return duration;
end
--DoPlay
function LayerManager:DoPlay()
	local movieClip = self:GetCurMovieClip();
	
	if(movieClip)then
		if(movieClip and movieClip.OnMotionEnd ~=CommonCtrl.Motion.LayerManager.OnMotionEnd )then
			
			movieClip.OnMotionEnd = CommonCtrl.Motion.LayerManager.OnMotionEnd;
		end
		movieClip:play();
	end
end
--DoPause
function LayerManager:DoPause()
	local movieClip = self:GetCurMovieClip();
	if(movieClip)then
		movieClip:pause();
	end
end
--DoResume
function LayerManager:DoResume()
	local movieClip = self:GetCurMovieClip();
	if(movieClip)then
		movieClip:resume();
	end
end
--DoStop
function LayerManager:DoStop()
	
	local movieClip = self:GetCurMovieClip();
	if(movieClip)then
		movieClip:stop();
	end
	--停止在最前面
	self.index = 1;
end
--DoEnd 最后一个mc停止到最后一帧
function LayerManager:DoEnd()
	
	local movieClip = self:GetLastMovieClip();
	if(movieClip)then
		movieClip:doEnd();
	end
end

-- @param frame: the current frame in its layer 
function LayerManager:gotoAndPlay(frame)
	if(frame >=self:GetFrameLength())then
		self:DoEnd();
		return;
	end
	local last = 0;
	local len = self:GetLength();
	for k = 1,len do
		local mc = self.movieClipList[k];
		last = last + mc:getTotalFrame();
		if(last >= frame)then
			last = last - mc:getTotalFrame();
			last = frame - last;
			self.index = k;
			break;
		end
	end
	local mc = self:GetCurMovieClip();
	if(mc)then
		mc:gotoAndPlay(last);
	end
end
-- OnTimeChange
function LayerManager:OnTimeChange()
		local movieClip = self:GetCurMovieClip();
		if(movieClip)then
			movieClip:EnterFrame();
		end
end
-- get the current playing animator in its layer 
function LayerManager:GetCurMovieClip()
	
	local mc = self.movieClipList[self.index];
	
	
	return mc;
end
-- GetLastMovieClip
function LayerManager:GetLastMovieClip()
	local index = table.getn(self.movieClipList);
	local mc = self.movieClipList[index];
	
	
	return mc;
end

function LayerManager:Destroy()
	
end
function LayerManager.OnMotionEnd(layerManager)
	
	local self = layerManager;
	
	if(self)then
		
		local len = self:GetLength()
		local index = self.index;
		local mc = self.movieClipList[self.index];
			if(mc)then
				mc.OnMotionEnd = nil;
			end
			
		if(index < len ) then
			
			self.index = index + 1 ;
			self:DoPlay();
		else
			
			self.index = 1;
			mc = self.movieClipList[self.index];
			--当前层只有一个 动画元素 ，而且它是重复播放
			if(len ==1 and mc.repeatCount==0) then
				self:DoPlay();
			end
		end
		--log(self.index..":"..self.name.."\n");
	end
end



