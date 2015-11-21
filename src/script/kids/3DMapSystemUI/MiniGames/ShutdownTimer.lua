--[[
Title: 
Author(s): Leio
Date: 2009/11/12
use the lib:
1 获取服务器时间
如果0--6 服务器关闭
如果6--24 开启
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/ShutdownTimer.lua");
function OnClosedFunc(shutdown_timer)
	if(shutdown_timer)then
		local h,m,s = shutdown_timer:OpenLeft();
		if(h and m and s)then
			local s = string.format("距离开放时间还剩：%d:%d:%d",h,m,s);
			commonlib.echo(s);
		end
	end
end
function OnOpenedFunc(shutdown_timer)
	if(shutdown_timer)then
		local h,m,s = shutdown_timer:GetRuntime();
		if(h and m and s)then
			local s = string.format("游戏现在运行时间：%d:%d:%d",h,m,s);
			commonlib.echo(s);
		end
	end
end
local shutdown_timer = Map3DSystem.App.MiniGames.ShutdownTimer:new{
	OnClosedFunc = OnClosedFunc,
	OnOpenedFunc = OnOpenedFunc,
}
shutdown_timer:Start();

--local time_string = ParaGlobal.GetTimeFormat("H:mm:ss");
--commonlib.echo(time_string);
--local __,__,h,m,s = string.find(time_string,"(.+):(.+):(.+)");
--local sec = tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s);
--local h,m,s = shutdown_timer:SecondesToHMS(sec);
--commonlib.echo({h,m,s});
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
local ShutdownTimer = {
	uid = nil,
	timer = nil,
	start_secondes = 0,
	time_index = 0,
	isThursday = false,--是否只周四
	--event
	OnClosedFunc = nil,
	OnOpenedFunc = nil,
}
commonlib.setfield("Map3DSystem.App.MiniGames.ShutdownTimer",ShutdownTimer);
function ShutdownTimer:new (o)
	o = o or {}   -- create object if user does not provide one
	o.Nodes = {};
	setmetatable(o, self)
	self.__index = self
	o:Init();
	return o
end
function ShutdownTimer:Init()
	local uid = ParaGlobal.GenerateUniqueID();
	self.uid = uid;
	
	self.timer = commonlib.Timer:new{
		callbackFunc = ShutdownTimer.UpdateTimer,
	}
	self.timer.holder = self;
end
function ShutdownTimer:Stop()
	if(self.timer)then
		self.timer:Change();
	end
end
function ShutdownTimer:Start()
	self:GetTimerFromServer(function(msg)
		if(msg and msg.now)then
			--开始计时
			self.start_secondes = msg.now;
			self.time_index = 0;
			if(msg.today == 4)then
				self.isThursday = true;
			else
				self.isThursday = false;
			end
			-- start the timer after 0 milliseconds, and signal every 1000 millisecond
			self.timer:Change(0, 1000)
			commonlib.echo("===============shutdown timer is start now!");
			commonlib.echo(msg);
		end
	end);
end
function ShutdownTimer:ReStart()
	if(self.timer)then
		self.timer:Change(0, 1000);
	end
end
--获取服务器时间
function ShutdownTimer:GetTimerFromServer(callbackFunc)
	if(callbackFunc and type(callbackFunc) == "function")then
		local time_string = ParaGlobal.GetTimeFormat("H:mm:ss");
		commonlib.echo("=============get server time:");
		commonlib.echo(time_string);
		local __,__,h,m,s = string.find(time_string,"(.+):(.+):(.+)");
		local sec = tonumber(h) * 3600 + tonumber(m) * 60 + tonumber(s);
		
		
		function GetToday()
			local date = ParaGlobal.GetDateFormat("ddd");
			local s = 1;
			date = commonlib.Encoding.DefaultToUtf8(date);
			if(not date)then return s end
			if(date == "星期一")then
				s = 1;
			elseif(date == "星期二")then
				s = 2;
			elseif(date == "星期三")then
				s = 3;
			elseif(date == "星期四")then
				s = 4;
			elseif(date == "星期五")then
				s = 5;
			elseif(date == "星期六")then
				s = 6;
			elseif(date == "星期日")then
				s = 7;
			end
			commonlib.echo(s);
			return s;
		end

		local msg = {
			now = sec,
			today = GetToday(), --今天是星期几
		}
		callbackFunc(msg);
	end
end
function ShutdownTimer:IsClosedTime()
	local closedTime;
	if(self.isThursday)then
		--closedTime = self:Is_0_To_6() or self:Is_22_To_24();
		closedTime = self:Is_0_To_6();
	else
		closedTime = self:Is_0_To_6();
	end
	return closedTime;
end
function ShutdownTimer:Update()
	self.time_index = self.time_index + 1;
	local closedTime = self:IsClosedTime();
	-- 0-6点
	if(closedTime)then
		if(self.OnClosedFunc)then
			self.OnClosedFunc(self);
		end
	else
		if(self.OnOpenedFunc)then
			self.OnOpenedFunc(self);
		end
	end
end
-- 22-24点
function ShutdownTimer:Is_22_To_24()
	local s_start = self:GetSecondes(22,0,0)
	local s_end = self:GetSecondes(23,59,59);
	local v = self:GetRuntimeSecondes();
	if(v >= s_start and v <= s_end)then
		return true;
	end
end
-- 0-6点
function ShutdownTimer:Is_0_To_6()
	local s_start = self:GetSecondes(0,0,0)
	local s_end = self:GetSecondes(6,0,0);
	local v = self:GetRuntimeSecondes();
	if(v >= s_start and v <= s_end)then
		return true;
	end
end
-- 21点
function ShutdownTimer:Is_21()
	local start = self:GetSecondes(21,0,0)
	local v = self:GetRuntimeSecondes();
	if(v == start)then 
		return true;
	end
end
-- 23:45
function ShutdownTimer:Is_23_45()
	local start = self:GetSecondes(23,45,0)
	local v =self:GetRuntimeSecondes();
	if(v == start)then 
		return true;
	end
end
-- 23:55
function ShutdownTimer:Is_23_55()
	local start = self:GetSecondes(23,55,0)
	local v =self:GetRuntimeSecondes();
	if(v == start)then 
		return true;
	end
end
--距离开放时间
--返回 hours,minutes,seconds
function ShutdownTimer:OpenLeft()
	local v = self:OpenLeftSecondes();
	return self:SecondesToHMS(v);
end

--距离开放时间还有多少
--返回secondes
function ShutdownTimer:OpenLeftSecondes()
	local v =self:GetRuntimeSecondes();
	local start;
	if(self.isThursday)then
		if( v > self:GetSecondes(22,0,0) and v < self:GetSecondes(24,0,0))then
			start = self:GetSecondes(6,0,0) + self:GetSecondes(24,0,0);
		else
			start = self:GetSecondes(6,0,0)
		end
	else
		start = self:GetSecondes(6,0,0);
	end
	v = start - v;
	return v;
end
--返回现在运行的时间
--返回 hours,minutes,seconds
function ShutdownTimer:GetRuntime()
	local r = self:GetRuntimeSecondes();
	return self:SecondesToHMS(r);
end
--返回现在时间的秒数
function ShutdownTimer:GetRuntimeSecondes()
	local r = self.start_secondes + self.time_index;
	local v = math.mod(r,self:GetDaySecondes());
	return v;
end
--返回秒数
function ShutdownTimer:GetSecondes(hour,min,sec)
	local r = 0;
	if(hour and min and sec)then
		hour = hour * 60 * 60;
		min = min * 60;
		r = hour + min + sec;
	end
	return r;
end
--返回一天的秒数
function ShutdownTimer:GetDaySecondes()
	return 86400;
end
function ShutdownTimer.UpdateTimer(timer)
	if(timer and timer.holder)then
		local self = timer.holder;
		self:Update();
	end
end
function ShutdownTimer:SecondesToHMS(v)
	if(v >= 0)then
		local hours,minutes,seconds;
		local t = 3600;
		hours = math.floor(v/t);
		v = v - hours*t;
		
		t = 60;
		minutes = math.floor(v/t);
		v = v - minutes*t;
		
		seconds = v;
		return hours,minutes,seconds
	end
end
---------------------------------------------------------
--[[
ShutdownTimer instance
根据游戏时间 发送提醒
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/ShutdownTimer.lua");
Map3DSystem.App.MiniGames.ShutdownTimer_Instance.Start();
--]]
---------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/OpenGameRemindPage.lua");
NPL.load("(gl)script/apps/Aries/Login/UserLoginPage.lua");
local ShutdownTimer_Instance = {
	isShowCloseTip = false,--是否已经弹出 关闭服务器面板
	isInGame = false,
	debugFile = "shutdown.txt",
	isKick = false, --是否已经把用户踢掉
	isStart = false,--是否已经启动
}
commonlib.setfield("Map3DSystem.App.MiniGames.ShutdownTimer_Instance",ShutdownTimer_Instance);
function ShutdownTimer_Instance.Start()

	local self = ShutdownTimer_Instance;
	if(self.isStart)then return end
	self.isStart = true;
	local t = commonlib.LoadTableFromFile(self.debugFile)
	if(t ~= nil and t.enabled == false) then 
		return 
	end
	if(not self.shutdown_timer)then
		local shutdown_timer = Map3DSystem.App.MiniGames.ShutdownTimer:new{
			OnClosedFunc = ShutdownTimer_Instance.OnClosedFunc,
			OnOpenedFunc = ShutdownTimer_Instance.OnOpenedFunc,
		}
		self.shutdown_timer = shutdown_timer;
	end
	commonlib.echo("=============shutdown timer is start!");
	self.shutdown_timer:Start();
	self.isKick = false;
end
function ShutdownTimer_Instance.ReStart()
	local self = ShutdownTimer_Instance;
	if(self.shutdown_timer and self.isStart)then
		self.shutdown_timer:ReStart();
	end
end
--是否是关闭时间
function ShutdownTimer_Instance.IsClosedTime()
	local self = ShutdownTimer_Instance;
	if(not self.shutdown_timer_noneFunc)then
		local shutdown_timer_noneFunc = Map3DSystem.App.MiniGames.ShutdownTimer:new{
			
		}
		self.shutdown_timer_noneFunc = shutdown_timer_noneFunc;
	end
	self.shutdown_timer_noneFunc:Start();
	
	local isClosed = self.shutdown_timer_noneFunc:IsClosedTime();
	self.shutdown_timer_noneFunc:Stop();
	return isClosed;
end
function ShutdownTimer_Instance.OnClosedFunc(shutdown_timer)
	local self = ShutdownTimer_Instance;
	if(shutdown_timer)then
		local h,m,s = shutdown_timer:OpenLeft();
		if(h and m and s)then
			local str = string.format("距离开放时间还剩：%d:%d:%d",h,m,s);
			commonlib.echo(str);
			--如果还没有启动游戏
			if(not self.isInGame)then
				--如果没有尝试剔除用户
				if(not self.isKick)then
					self.isKick = true;
					--隐藏login页面
					MyCompany.Aries.UserLoginPage.isClosedTime = true;
					--跳转到重启状态
                    paraworld.PostLog({action="user_restart", reason="shutdown_timer_1"}, "logout_log", function(msg)
                    end);
					--MyCompany.Aries.Desktop.Dock.PostLogoutTime(function()
						--Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft"});
					--end);
					--MyCompany.Aries.MainLogin:next_step({
							--IsLocalUserSelected = true,
							--IsCoreClientUpdated = true,
							--Loaded3DSceneRequested = true,
						--
					--});
					--重新启动timer
					--self.ReStart()
				end
				--显示关闭服务器提醒页面
				Map3DSystem.App.PENote.OpenGameRemindPage.ShowPage()
				Map3DSystem.App.PENote.OpenGameRemindPage.Update(h,m,s)
			else
				--如果没有弹出窗口
				if(not self.isShowCloseTip)then
					_guihelper.MessageBox("哈奇小镇进入休息时间，你也赶快去休息吧！",function(result)
						if(_guihelper.DialogResult.OK == result) then
							self.isShowCloseTip = true;
						end
					end, _guihelper.MessageBoxButtons.OK)
				else
					--如果没有尝试剔除用户
					if(not self.isKick)then
						self.isKick = true;
						MyCompany.Aries.UserLoginPage.isClosedTime = true;
						paraworld.PostLog({action="user_restart", reason="shutdown_timer_2"}, "logout_log", function(msg)
						end);
						MyCompany.Aries.Desktop.Dock.PostLogoutTime(function()
							Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft"});
						end);
						--MyCompany.Aries.MainLogin:next_step({
								--IsLocalUserSelected = true,
								--IsCoreClientUpdated = true,
								--Loaded3DSceneRequested = true,
						--});
						--self.ReStart()
					end
					--显示关闭服务器提醒页面
					--Map3DSystem.App.PENote.OpenGameRemindPage.ShowPage()
					--Map3DSystem.App.PENote.OpenGameRemindPage.Update(h,m,s)
				end
			end
		end
	end
end
function ShutdownTimer_Instance.OnOpenedFunc(shutdown_timer)
	local self = ShutdownTimer_Instance;
	if(shutdown_timer)then
		local h,m,s = shutdown_timer:GetRuntime();
		if(h and m and s)then
			local s = string.format("游戏现在运行时间：%d:%d:%d",h,m,s);
			--commonlib.echo(s);
			
			NPL.load("(gl)script/kids/3DMapSystemUI/PENote/Pages/OpenGameRemindPage.lua");
			Map3DSystem.App.PENote.OpenGameRemindPage.ClosePage()
			
			self.isInGame = true;	
			--如果是从关闭到开启
			if(MyCompany.Aries.UserLoginPage.isClosedTime)then
				MyCompany.Aries.UserLoginPage.isClosedTime = false;
				paraworld.PostLog({action="user_restart", reason="shutdown_timer_3"}, "logout_log", function(msg)
				end);
				MyCompany.Aries.Desktop.Dock.PostLogoutTime(function()
					Map3DSystem.App.Commands.Call("Profile.Aries.Restart", {method="soft"});
					self.ReStart()
				end);
			end	
		end
	end
end
