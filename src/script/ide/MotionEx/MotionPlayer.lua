--[[
Title: MotionPlayer
Author(s): Leio
Date: 2010/06/11
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionPlayer.lua");
NPL.load("(gl)script/ide/MotionEx/MotionLineBase.lua");
local motionPlayer = MotionEx.MotionPlayer:new{
	space = 200,
};
motionPlayer:AddEventListener("play",function()
	commonlib.echo("play");
end,{});
motionPlayer:AddEventListener("stop",function()
	commonlib.echo("stop");
end,{});
motionPlayer:AddEventListener("end",function()
	commonlib.echo("end");
end,{});
motionPlayer:AddEventListener("update",function(funcHolder,event)
	commonlib.echo("update");
	commonlib.echo(event.time);
end,{});

local motionLine = MotionEx.MotionLineBase:new{
	name = "a",
	space = 30,
	repeatCnt = 1,
}
motionPlayer:AddMotionLine(motionLine);
--local motionLine = MotionEx.MotionLineBase:new{
	--name = "b",
	--space = 1000,
--}
--motionPlayer:AddMotionLine(motionLine);
--local motionLine = MotionEx.MotionLineBase:new{
	--name = "c",
	--space = 800,
--}
--motionPlayer:AddMotionLine(motionLine);
motionPlayer.space = 200;
motionPlayer:Play();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/EventDispatcher.lua");
local LOG = LOG;
local MotionPlayer = commonlib.inherit({
	at_endpoint = true,--自动播放完毕默认 是停止到最后， false：停止到最前
	duration = 10,--刷新频率 毫秒
	space = 0,--播放的总时间 毫秒，这个值建议不要直接更改，它会根据children自动生成
	esc_key = false,--esc键停止动画播放
}, commonlib.gettable("MotionEx.MotionPlayer"));
function MotionPlayer:ctor()
	self.play_timer = commonlib.Timer:new({callbackFunc = function(timer)
		self:TimeUpdate(timer);
	end})
	self.ispause = false;
	self.elapsed_time = 0;--毫秒
	self.motion_lines = {};
	self.events = commonlib.EventDispatcher:new();
end
--从第一帧开始播放
function MotionPlayer:Play()
	local k,line;
	for k,line in ipairs(self.motion_lines) do
		line:Reset();
	end
	self:Reset();
	self:DispatchEvent({
		type="play",
		sender = self,
	});
end
--重新开始
function MotionPlayer:Reset()
	self.ispause = false;
	self.elapsed_time = 0;--毫秒
	self.play_timer:Change(0,self.duration);	
end
--停止到最前
function MotionPlayer:Stop()
	self:Reset();
	self.play_timer:Change();	
	self:GoToTime(0);
	self:DispatchEvent({
		type="stop",
		sender = self,
	});
end
--停止到最后
function MotionPlayer:End()
	self:Reset();
	self.play_timer:Change();
	self:GoToTime(self.space);
	self:DispatchEvent({
		type="end",
		sender = self,
	});
end
--暂停
function MotionPlayer:Pause()
	self.ispause = true;
end
--从暂停位置继续播放
function MotionPlayer:Resume()
	self.ispause = false;
end
--更新
function MotionPlayer:TimeUpdate(timer)
	if(self.ispause)then return end
	local duration = self.duration;
	if(timer)then
		duration = timer:GetDelta(200);
	end
	if(self.elapsed_time < self.space)then
		self:GoToTime(self.elapsed_time,duration);
		self.elapsed_time = self.elapsed_time + duration;
	else
		if(self.at_endpoint)then
			self:End();
		else
			self:GoToTime(self.space);
			self:Stop();
		end
	end
	if(self.esc_key)then
		local esc_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_ESCAPE) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_SPACE);
		if(esc_pressed)then
			self:Stop();
		end	
	end
end
--获取运行的时间
function MotionPlayer:GetRuntime()
	return self.elapsed_time;
end
function MotionPlayer:GoToByTimeStr(time_str)
	if(not time_str)then return end
	local time = commonlib.timehelp.TimeStrToMill(time_str);
	self:GoToTime(time);
end
--跳转到制定时间 毫秒 继续播放/定位到这个时间点
local update_msg_template = {
	type="update",
}
function MotionPlayer:GoToTime(time,delta)
	if(not time or time > self.space or time < 0)then return end
	self.elapsed_time = time;
	local k,line;
	for k,line in ipairs(self.motion_lines) do
		line:GoToTime(time,delta);
	end
	update_msg_template.sender = self;
	update_msg_template.time = time;
	self:DispatchEvent(update_msg_template);
end
--获取播放最长时间
function MotionPlayer:GetSpace(bForce)
	if(bForce)then
		local line,space = self:GetMaxMotionLineSpace();
		self.space = space;
	end
	return self.space;
end
--获取播放最长时间的motionline
function MotionPlayer:GetMaxMotionLineSpace()
	local k,line;
	local space = 0;
	local find_line;
	for k,line in ipairs(self.motion_lines) do
		local line_space = line:GetSpace();
		if(line_space > space)then
			space = line_space;
			find_line = line;
		end
	end
	return find_line,space;
end
--清空所有
function MotionPlayer:Clear()
	self.motion_lines = {};
	self:Reset();
	self.play_timer:Change();
end
--增加一组MotionLine
function MotionPlayer:AddMotionLines(motionlines)
	if(not motionlines)then return end
	local k,line;
	for k,line in ipairs(motionlines) do
		self:AddMotionLine(line,true);
	end
	local line,space = self:GetMaxMotionLineSpace();
	self.space = space;
end
--增加一个MotionLine
function MotionPlayer:AddMotionLine(motionline,bNotUpdate)
	if(not motionline)then return end
	motionline:SetParent(self);
	table.insert(self.motion_lines,motionline);
	if(not bNotUpdate)then
		local line,space = self:GetMaxMotionLineSpace();
		self.space = space;
	end
end
function MotionPlayer:AddEventListener(type,func,funcHolder)
	self.events:AddEventListener(type,func,funcHolder);
end
function MotionPlayer:RemoveEventListener(type)
	self.events:RemoveEventListener(type);
end
function MotionPlayer:DispatchEvent(event, ...)
	self.events:DispatchEvent(event, ...);
end

function MotionPlayer:HasEventListener(type)
	return self.events:HasEventListener(type);
end