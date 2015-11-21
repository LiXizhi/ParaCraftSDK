--[[
Title: TimeSpan
Author(s): Leio Zhang
Date: 2009/3/26
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Storyboard/TimeSpan.lua");
------------------------------------------------------------
--]]

local TimeSpan = {
	name = "TimeSpan_instance",
	framerate = CommonCtrl.Storyboard.Storyboard._framerate,
}
commonlib.setfield("CommonCtrl.Storyboard.TimeSpan",TimeSpan);
function TimeSpan.GetMillisecondsToTimeStr(time)
	time = tonumber(time);
	if(not time)then return end
	local frame = time/TimeSpan.framerate;
	local s = TimeSpan.GetTime(frame);
	return s;
end
function TimeSpan.CheckTimeFormat(time_str)
	if(not time_str)then return end
	local t;
	local temp = {}
	for t in string.gfind(time_str, "([^%s:]+)") do
		t = tonumber(t);
		if(t)then
			table.insert(temp,t)
		end
	end
	local len = table.getn(temp);
	local k,v;
	local seconds = 0;
	for k,v in ipairs(temp) do
		local n = len - k;
		seconds = seconds + (60^n)*v
	end
	local millseconds = seconds * 1000;
	return TimeSpan.GetMillisecondsToTimeStr(millseconds);
end
function TimeSpan.GetMilliseconds(time_str)
	if(not time_str)then return end
	time_str = tostring(time_str);
	time_str = TimeSpan.CheckTimeFormat(time_str)
	local __,__,hours,minutes,seconds = string.find(time_str,"(.+):(.+):(.+)");
	hours,minutes,seconds = tonumber(hours),tonumber(minutes),tonumber(seconds)
	totalSeconds = hours * 3600 + minutes*60 + seconds;
	local totalMillseconds = totalSeconds * 1000;
	return totalMillseconds	
end
function TimeSpan.GetFrames(time_str)
	if(not time_str)then return end
	time_str = tostring(time_str);
	local totalMillseconds = TimeSpan.GetMilliseconds(time_str)
	if(not totalMillseconds)then 
		return 
	end
	local frame = totalMillseconds /TimeSpan.framerate;
	frame = math.floor(frame);
	return frame;
end

function TimeSpan.GetTime(frame)
	if(not frame or type(frame)~="number")then return end
	if(frame<0)then frame = 0;end
	local totalMillseconds = frame * TimeSpan.framerate
	
	local hours,minutes,seconds ;
	local t = 3600*1000;
	hours = math.floor(totalMillseconds/t);
	totalMillseconds = totalMillseconds - hours*t;
	
	t = 60*1000;
	minutes = math.floor(totalMillseconds/t);
	totalMillseconds = totalMillseconds - minutes*t;
	
	t = 1000;
	seconds = totalMillseconds/t;
	
	seconds = string.format("%.3f",seconds);
	return hours..":"..minutes..":"..seconds;
end