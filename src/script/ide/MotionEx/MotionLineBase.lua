--[[
Title: MotionLineBase
Author(s): Leio
Date: 2010/06/11
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionLineBase.lua");
------------------------------------------------------------
--]]
local MotionLineBase = commonlib.inherit({
	name = nil,
	space = 0,--默认时间总长度为0
	repeatCnt = 0,-- -1:循环播放 0:播放1次 1:重复播放1次（共播放2次） note:只有motionplayer的播放时间大于motionline的时间 才会有效
}, commonlib.gettable("MotionEx.MotionLineBase"));
function MotionLineBase:ctor()
	self.playCnt = 0;
	self.last_time = 0;
end
--function MotionLineBase:Play()
	--self:Reset();
	--self:__Play();
--
--end
--function MotionLineBase:Stop()
	--self:__Stop();
--end
--function MotionLineBase:End()
	--self:__End();
--end
function MotionLineBase:Reset()
	self.playCnt = 0;
	self.last_time = 0;
	self:__Reset();
end
function MotionLineBase:SetParent(parent)
	if(not parent)then return end
	self.parent = parent;
	self.duration = parent.duration or 10;
end
function MotionLineBase:GetDuration()
	return self.duration;
end
function MotionLineBase:SetSpace(space)
	if(not space)then return end
	self.space = space;
end
function MotionLineBase:GetSpace()
	return self.space;
end
function MotionLineBase:GoToTime(time,delta)
	if(not time)then return end
	local space = self:GetSpace();
	if(space > 0 and time >=0 )then
		local duration = self:GetDuration();
		local localtime = math.mod(time,space + duration);
		if(localtime == 0)then
			if(self.last_time ~= time and time > 0)then
				self.playCnt = self.playCnt + 1;
				self.last_time = time;
			end
		end
		if(self.playCnt > self.repeatCnt and self.repeatCnt > -1)then
			return;
		end

		self:__GoToTime(time,localtime,space,delta);
	end
end
--可以重写的方法
--@param root_time:毫秒，MotionPlayer运行的总时间
--@param local_time:毫秒，MotionLineBase当前运行的时间
--@param root_max_time:毫秒，MotionLineBase运行的总时间
function MotionLineBase:__GoToTime(root_time,local_time,local_max_time)
	local s = string.format("%s:runtime is:%d, %d,%d",self.name or "",root_time,local_time,local_max_time);
	commonlib.echo(s);
end
function MotionLineBase:__Reset()
end