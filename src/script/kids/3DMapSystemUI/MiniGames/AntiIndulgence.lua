--[[
Title: 
Author(s): Leio
Date: 2009/11/24
Desc:
	用户连续在线45分钟，下发系统邮件给用户，提醒用户活动一下；
	用户当天累计在线3个小时，下发系统邮件给用户，提醒下线；
	当用户在线超过3小时，点击所有的NPC均提醒：你今天已经在哈奇小镇玩了太长时间，先休息一下，明天再来玩吧！
	当用户在线超过3小时，就不再下发随机心愿了；
	周末及节假日，3小时调整为6小时；
	以后新上架的NPC，如没有特殊说明，点击操作也需要同样的判断；

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/AntiIndulgence.lua");
Map3DSystem.App.MiniGames.AntiIndulgence.Start();

--防沉迷是否已经起效
Map3DSystem.App.MiniGames.AntiIndulgence.IsAntiSystemIsEnabled();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
local AntiIndulgence = {
	today = nil,--今天是周几
	series_onlineTime = 0,--连续在线时间
	total_onlineTime_today = 0,--今天累计在线时间
	
	antiSystemIsEnabled = false,--防沉迷系统是否生效	
	submit_timer = nil,
	duration = 60000,--提交周期 300000 = 5分钟
	file = "temp/cache/AntiIndulgence",--记录时间的文本
	hasReminded_series = false,--是否已经提醒过
	
}
commonlib.setfield("Map3DSystem.App.MiniGames.AntiIndulgence",AntiIndulgence);

function AntiIndulgence.Start()
	local self = AntiIndulgence;
	if(not self.submit_timer)then
		self.submit_timer = commonlib.Timer:new{
			callbackFunc = AntiIndulgence.UpdateTimer,
		}
	end
	LOG.std("", "system", "AntiIndulgence", "AntiIndulgence.Start");
	self.submit_timer:Change(self.duration,self.duration);
	self.hasReminded_series = false;
	self.series_onlineTime = 0;
	
	--local nid = Map3DSystem.User.nid;
	--local filepath = string.format("%s_%d.txt",self.file,nid or 0); 
	--local msg = commonlib.LoadTableFromFile(filepath)
	--if(msg)then
		--local date = ParaGlobal.GetDateFormat("yyyy/MM/dd");
		----如果是同一天
		--if(msg.date == date)then
			--self.earthquake_remind = msg.earthquake_remind;
		--else
			--self.earthquake_remind = false;
		--end
	--end
end
function AntiIndulgence.End()
	local self = AntiIndulgence;
	if(self.submit_timer)then
		self.submit_timer:Change();
	end
	self.GetTimerFromServer();
end
function AntiIndulgence.UpdateTimer(timer)
	local self = AntiIndulgence;
	local dur = math.floor(self.duration/1000);
	self.series_onlineTime = self.series_onlineTime + dur;
	
	local date = ParaGlobal.GetDateFormat("yyyy/MM/dd");

	--如果连续在线超过45分钟
	if(self.series_onlineTime >= self.GetSecondes(0,45,0))then
		--self.series_onlineTime = 0;
		if(not self.hasReminded_series)then
			self.hasReminded_series = true;
			----邮件通知
			--local date = ParaGlobal.GetDateFormat("yyyy/MM/dd");
			--Map3DSystem.App.PENote.PENote_Client:SendMessage({  to_nid = Map3DSystem.User.nid,
																--from_nid = nil,
																--note = "series_onlineTime_45",
																--date = date,
																--},Map3DSystem.User.jid);
			-- dump timer info
			commonlib.TimerManager.DumpTimerCount();
		end
	end
	self.GetTimerFromServer(function(msg)
		if(msg)then
			local sec = msg.sec;
			local today = msg.today;
			--如果累计时间超过6小时
			if(sec >= self.GetSecondes(6,0,0))then
				self.antiSystemIsEnabled = true;
				--if(not self.hasReminded_total)then
					--self.hasReminded_total = true;
					----邮件通知
					--local date = ParaGlobal.GetDateFormat("yyyy/MM/dd");
					--Map3DSystem.App.PENote.PENote_Client:SendMessage({  to_nid = Map3DSystem.User.nid,
																		--from_nid = nil,
																		--note = "total_onlineTime_today_6",
																		--date = date,
																		--},Map3DSystem.User.jid);
				--end
			end
				
		end
	end)
end
--是否有效
function AntiIndulgence.IsAntiSystemIsEnabled()
	local self = AntiIndulgence;
	--return self.antiSystemIsEnabled;
	return false;
end
--返回秒数
function AntiIndulgence.GetSecondes(hour,min,sec)
	local self = AntiIndulgence;
	local r = 0;
	if(hour and min and sec)then
		hour = hour * 60 * 60;
		min = min * 60;
		r = hour + min + sec;
	end
	return r;
end
--获取服务器时间
function AntiIndulgence.GetTimerFromServer(callbackFunc)
	local self = AntiIndulgence;
	local time;
	local nid = Map3DSystem.User.nid;
	local filepath = string.format("%s_%d.txt",self.file,nid or 0);
	--如果没有文件
	if(not ParaIO.DoesFileExist(filepath)) then
		--创建文件 初始化
		if(ParaIO.CreateNewFile(filepath))then
			local date = ParaGlobal.GetDateFormat("yyyy/MM/dd");
			local today = self.GetToday();
			local dur = math.floor(self.duration/1000);
			time = {
				sec = dur,--记录累计在线时间
				today = today,--记录星期几
				date = date,--记录日期
			}
			--保存记录
			commonlib.SaveTableToFile(time, filepath)
			ParaIO.CloseFile();
		end
	else
		time = commonlib.LoadTableFromFile(filepath)
		if(time)then
			local date = ParaGlobal.GetDateFormat("yyyy/MM/dd");
			time.sec = time.sec or 0;
			
			--如果是同一天
			if(time.date == date)then
				--累加时间
				local dur = math.floor(self.duration/1000);
				time.sec = time.sec + dur;
				time.earthquake_remind = self.earthquake_remind;--地震tag
			else
				time.sec = dur;
				time.earthquake_remind = false;--地震tag
				
			end
			time.date = date;
			time.today = self.GetToday();
			--保存记录
			commonlib.SaveTableToFile(time, filepath)
		end
	end
	if(callbackFunc and type(callbackFunc) == "function")then
		if(time)then
			
			local msg = {
				sec = time.sec or 0,--今天累计在线时间的秒数
				today = time.today, --今天是星期几
				date = time.date,--日期
				earthquake_remind = time.earthquake_remind,--地震
			}
			LOG.std("", "debug", "AntiIndulgence", {"total_onlineTime_today", msg});
			
			callbackFunc(msg);
		end
	end
end
--获取今天是星期几
function AntiIndulgence.GetToday()
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
	LOG.std("", "system", "AntiIndulgence", "date: %d, %s", s, date);
	return s;
end