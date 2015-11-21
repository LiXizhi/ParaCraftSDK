--[[
Title: Date time related functions
Author(s): LiXizhi, Leio
Date: 2012/11/28
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/DateTime.lua");
local dayofweek = commonlib.timehelp.get_day_of_week(2012, 12, 30);
echo(commonlib.timehelp.get_next_date(2012,11, 26, 2))

-- time range functions
-- e.g.:
-- "59 23 26 11" : precise time
-- "* * 26 11" : all day Nov. 26th.
-- "1 * * *": the first minite in every hour, every day. 
-- "(* 10 26 11)" : 10:00am-10:59am on Nov. 26th.
-- "* * * * 6" : every Saturday
-- "(* * * * 5)(* * * * 7)" : from every Friday to Sunday.
-- "(* 18 * *)(* 20 * *)": all time between 18:00-20:00
-- "(* 6 26 11)(* * 27 11)" : from Nov.26 6:00am to Nov.27th 24:00
-- "(30 10 * *)(30 11 * *)" : every day from 10:30 to 11:30
-- "(30 10 * * 5)(30 11 * * 5)" : every Friday from 10:30 to 11:30
NPL.load("(gl)script/ide/DateTime.lua");
echo(commonlib.timehelp.datetime_range:new("(30 10 * *)(30 11 * *)"):tostring())
echo(commonlib.timehelp.datetime_range:new("* * * *"):tostring())

assert(commonlib.timehelp.datetime_range:new("(30 10 * *)(30 11 * *)"):is_matched(11,11,27,4,2013) == true)
assert(commonlib.timehelp.datetime_range:new("(30 10 * *)(30 11 * *)"):is_matched(31,11,27,4,2013) == nil)
assert(commonlib.timehelp.datetime_range:new("(30 10 * * 5)(30 11 * * 5)"):is_matched(11,11,27,4,2013) == nil)
assert(commonlib.timehelp.datetime_range:new("(30 10 * * 5)(30 11 * * 5)"):is_matched(11,11,26,4,2013) == true)
assert(commonlib.timehelp.datetime_range:new("59 23 26 11"):is_matched(59,23,26,11,2013) == true)
assert(commonlib.timehelp.datetime_range:new("59 23 26 11"):is_matched(59,24,26,11,2013) == nil)
assert(commonlib.timehelp.datetime_range:new("* * * * 6"):is_matched(11,11,28,4,2013) == nil)
assert(commonlib.timehelp.datetime_range:new("* * * * 6"):is_matched(11,11,27,4,2013) == true)

-------------------------------------------------------
]]

if(not commonlib) then commonlib={}; end

local timehelp = commonlib.timehelp or {};
commonlib.timehelp = timehelp;

local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local error = error
local type = type

local math_abs = math.abs
local math_floor = math.floor;
local floor = math_floor
local mod = math.mod;

local table_insert = table.insert

local string_find = string.find;
local string_gfind = string.gfind;
local string_lower = string.lower;


--local month_days_nonleap = {31,28,31,30,31,30,31,31,30,31,30,31}; 
--local month_days_leap =    {31,29,31,30,31,30,31,31,30,31,30,31};
--
---- get day count from 1900-1-1, if input (1900, 1, 1) return 1
--function commonlib.GetDaysFrom_1900_1_1(year, month, day)
	--local count = 0;
	--if(year and month and day) then
		--local m = 1;
		--for m = 1, month - 1 do
			--if(mod(year, 4) == 0) then
				--count = count + month_days_leap[m]
			--else
				--count = count + month_days_nonleap[m]
			--end
		--end
		--local y = 1900;
		--for y = 1900, year - 1 do
			--if(mod(y, 4) == 0) then
				--count = count + 366;
			--else
				--count = count + 365;
			--end
		--end
		--count = count + day;
		--return count;
	--end
--end

function commonlib.GetDaysFrom_1900_1_1(year, month, day)
	return timehelp.makedaynum(year, month, day) - 693594; -- timehelp.makedaynum(1900, 0, 1) --> 693595;
end

--返回日期的毫秒数
--@param date:yyyy-MM-dd H:mm:ss
function commonlib.GetMillisecond_Date(date)
	local __,__,year,month,day,hour,min,sec = string_find(date,"(.+)-(.+)-(.+) (.+):(.+):(.+)");
	year = tonumber(year);
	month = tonumber(month);
	day = tonumber(day);
	hour = tonumber(hour);
	min = tonumber(min);
	sec = tonumber(sec);
	local days = commonlib.GetDaysFrom_1900_1_1(year, month, day)
	local total_secs = days * commonlib.timehelp.GetDaySeconds() + commonlib.timehelp.GetSeconds(hour,min,sec);
	return total_secs * 1000;
end
--返回两个日期之间相差的毫秒数
--@param date1:yyyy-MM-dd H:mm:ss
--@param date2:yyyy-MM-dd H:mm:ss
function commonlib.GetMillisecond_BetweenToDate(date1,date2)
	if(not date1 or not date2)then return end
	local a_1 = commonlib.GetMillisecond_Date(date1);
	local a_2 = commonlib.GetMillisecond_Date(date2);
	local max_mill = math.max(a_1,a_2);
	local min_mill = math.min(a_1,a_2);
	return max_mill - min_mill;
end
--返回两个日期之间相差的天数
--return day,hours,minutes,seconds,time_str,total_mill    e.g: day,hours,minutes,seconds,H:mm:ss,total_mill
function commonlib.GetTimeStr_BetweenToDate(date1,date2)
	local total_mill = commonlib.GetMillisecond_BetweenToDate(date1,date2);
	local one_day_mill = 1000* commonlib.timehelp.GetDaySeconds();
	local day = floor(total_mill/one_day_mill);
	local last_mill = total_mill - one_day_mill * day;
	local time_str,hours,minutes,seconds = commonlib.timehelp.MillToTimeStr(last_mill,"h-m-s");

	return day,hours,minutes,seconds,time_str,total_mill
end

------------------------------------------------------------------------
--timer
------------------------------------------------------------------------
--[[commonlib.timer is a simpler timer ID generator. Use GetNewTimerID() to create
new timer id to avoid timer id collide.
--]]
local timer = {};
timer.id = 0;
timer.count = 0;

commonlib.timer = timer;

function timer.GetNewTimerID()
	timer.id = timer.id + 1;
	timer.count = timer.count + 1;
end

function timer.GetIDCount()
	return timer.timerCount;
end

function timer.ResetTimer(minID)
	if(minID == nil)then
		timer.id = 0;
	else
		timer.id = minID;
	end
	timer.count = 0;
end
------------------------------------------------------------------------
--timehelp
------------------------------------------------------------------------

function timehelp.GetLocalTime()
	local today = ParaGlobal.GetDateFormat("yyyy-MM-dd")
	local hour = ParaGlobal.GetTimeFormat("H-mm-ss");
	return today,hour;
end
--是否是同一天

local function isEqual(a,b)
	if(a and b and a == b)then
		return true;
	end
end

--[[
local date_1 = "2010-03-02"
local date_2 = "2010-03-02"
local r = commonlib.timehelp.IsSameDate(date_1,date_2);
commonlib.echo(r);
--]]
function timehelp.IsSameDate(date_1,date_2)
	if(not date_1 or not date_2)then return end
	
	local __,__,year_1,month_1,day_1 = string_find(date_1,"(.+)-(.+)-(.+)");
	year_1 = tonumber(year_1);
	month_1 = tonumber(month_1);
	day_1 = tonumber(day_1);
	
	local __,__,year_2,month_2,day_2 = string_find(date_2,"(.+)-(.+)-(.+)");
	year_2 = tonumber(year_2);
	month_2 = tonumber(month_2);
	day_2 = tonumber(day_2);
	
	local year_is_equal = isEqual(year_1,year_2);
	local month_is_equal = isEqual(month_1,month_2);
	local day_is_equal = isEqual(day_1,day_2);
	if(year_is_equal and month_is_equal and day_is_equal)then
		return true;
	end
end
function timehelp.GetSecondsFromStr(time)
	if(not time)then return end
	local _,_,hour,min,sec = string_find(time,"(%d+)%D(%d+)%D(%d+)");
	return timehelp.GetSeconds(hour,min,sec);
end
-- return total seconds
function timehelp.GetSeconds(hour,min,sec)
	local r = 0;
	if(hour and min and sec)then
		r = 3600*hour + 60*min + sec;
	end
	return r;
end
-- return total seconds in a day. 
function timehelp.GetDaySeconds()
	return 86400;
end
function timehelp.SecondsToHMS(v)
	if(v >= 0)then
		local hours,minutes,seconds;
		local t = 3600;
		hours = math_floor(v/t);
		v = v - hours*t;
		
		t = 60;
		minutes = math_floor(v/t);
		v = v - minutes*t;
		
		seconds = v;
		return hours,minutes,seconds
	end
end
function timehelp.IsLessTime(time1,time2)
	if(not time1 or not time2)then return end
	local a = timehelp.GetSecondsFromStr(time1);
	local b = timehelp.GetSecondsFromStr(time2);
	if(a <= b)then
		return true
	end
end
function timehelp.TimeStrToMill(time_str)
	if(not time_str)then return end
	local t;
	local temp = {}
	for t in string.gfind(time_str, "([^%s:]+)") do
		t = tonumber(t);
		if(t)then
			table.insert(temp,t)
		end
	end
	local len = #(temp);
	local k,v;
	local seconds = 0;
	for k,v in ipairs(temp) do
		local n = len - k;
		seconds = seconds + (60^n)*v
	end
	local millseconds = seconds * 1000;
	return millseconds;
end
--[[
local time_str = "00:00:01.5";
local millsec = commonlib.timehelp.TimeStrToMill(time_str)
commonlib.echo(millsec);
local s = commonlib.timehelp.MillToTimeStr(millsec);
commonlib.echo(s);

return h:m:s,hours,minutes,seconds
--]]
function timehelp.MillToTimeStr(totalMillseconds,timefmt)
	if(not totalMillseconds or type(totalMillseconds)~="number")then return end
	
	local hours,minutes,seconds ;
	local t = 3600*1000;
	hours = floor(totalMillseconds/t);
	totalMillseconds = totalMillseconds - hours*t;
	
	t = 60*1000;
	minutes = floor(totalMillseconds/t);
	totalMillseconds = totalMillseconds - minutes*t;
	
	t = 1000;
	seconds = totalMillseconds/t;
	
	if(timefmt)then
		if(timefmt == "h-m")then
			local s = string.format("%.2d:%.2d",hours,minutes);
			return s,hours,minutes,seconds;
		end
		if(timefmt == "h-m-s")then
			local s = string.format("%.2d:%.2d:%.2d",hours,minutes,seconds);
			return s,hours,minutes,seconds;
		end
	end
	seconds = string.format("%.3f",seconds);
	return hours..":"..minutes..":"..seconds,hours,minutes,seconds;
end
--day1和day2之间相差的毫秒数
--@param day1: a number value
--@param day2: a number value
--@param time1: a string value "20:05:05"
--@param time2: a string value "22:05:05"
--note:只能是一个月内的两天
--[[
NPL.load("(gl)script/ide/commonlib.lua");
local day1 = 10;
local day2 = 11;
local time1 = "20:05:05";
local time2 = "20:05:15";
local sec = commonlib.timehelp.GetMilliseconds_Between_Day1AndDay2(day1,day2,time1,time2);
commonlib.echo(sec);

local str = commonlib.timehelp.MillToTimeStr(sec,"h-m-s")
commonlib.echo(str);

local day = ParaGlobal.GetDateFormat("yyyy-M-d")
local time = ParaGlobal.GetTimeFormat("H:mm:ss");
commonlib.echo(day);
commonlib.echo(time);
--]]
function timehelp.GetMilliseconds_Between_Day1AndDay2(day1,day2,time1,time2)
	day1 = tonumber(day1) or 0;
	day2 = tonumber(day2) or 0;

	local day = day2 - day1;
	
	local sec = timehelp.GetDaySeconds() * day * 1000;
	local time1_sec = timehelp.TimeStrToMill(time1) or 0;
	local time2_sec = timehelp.TimeStrToMill(time2) or 0;
	local time_sec = time2_sec - time1_sec;
	
	sec = sec + time_sec;
	return sec;
end

local days = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun", }
-- http://lua-users.org/wiki/DayOfWeekAndDaysInMonthExample
-- returns the day of week integer and the name of the week
-- Compatible with Lua 5.0 and 5.1.
-- from sam_lie 
function timehelp.get_day_of_week(yy, mm, dd) 
	local mmx = mm
	if (mm == 1) then  mmx = 13; yy = yy-1  end
	if (mm == 2) then  mmx = 14; yy = yy-1  end

	local val8 = dd + (mmx*2) +  floor(((mmx+1)*3)/5)   + yy + floor(yy/4)  - floor(yy/100)  + floor(yy/400) + 2
	local val9 = floor(val8/7)
	local dw = val8-(val9*7) 

	if (dw == 0) then
		dw = 7
	end

	if (dw==1) then 
		dw=7;
	else
		dw=dw-1;
	end
	return dw, days[dw];
end

-- is year y leap year?
local function isleapyear(y) -- y must be int!
	return (mod(y, 4) == 0 and (mod(y, 100) ~= 0 or mod(y, 400) == 0))
end
timehelp.isleapyear = isleapyear;

-- get the number of days since year 0
local function dayfromyear(y) -- y must be int!
	return 365*y + floor(y/4) - floor(y/100) + floor(y/400)
end
timehelp.dayfromyear = dayfromyear;

-- get the numer of days since year 0 from y, m, d. 
local function makedaynum(y, m, d)
	m = m - 1;
	local mm = mod(mod(m,12) + 10, 12)
	return dayfromyear(y + floor(m/12) - floor(mm/10)) + floor((mm*306 + 5)/10) + d - 307
end
timehelp.makedaynum = makedaynum;

-- date from day number
-- @return year, month, day
local function breakdaynum(g)
	local g = g + 306
	local y = floor((10000*g + 14780)/3652425)
	local d = g - dayfromyear(y)
	if d < 0 then y = y - 1; d = g - dayfromyear(y) end
	local mi = floor((100*d + 52)/3060)
	return (floor((mi + 2)/12) + y), mod(mi + 2,12)+1, (d - floor((mi*306 + 5)/10) + 1)
end
timehelp.breakdaynum = breakdaynum;

-- @param shift_days: any positive or negative number. default to 1
-- @return yy, mm, dd: offset by shift_days:
function timehelp.get_next_date(yy, mm, dd, shift_days)
	local days = makedaynum(yy, mm, dd);
	days = days + (shift_days or 1)
	return breakdaynum(days);
end

-- @param shift_days: any positive or negative number. default to 1
-- @param yyyy_mm_dd: a string of made of yyyy_mm_dd
-- @param output_format: default to "%04d%02d%02d", such as "%04d-%02d-%02d"
-- @return : offset by shift_days:
function timehelp.get_next_date_str(yyyy_mm_dd, shift_days, output_format)
	local year, mm, dd = yyyy_mm_dd:match("^(%d%d%d%d)%D*(%d%d)%D*(%d%d)");
	if(year and mm and dd)then
		year = tonumber(year);
		mm = tonumber(mm);
		dd = tonumber(dd);
		year, mm, dd = timehelp.get_next_date(year, mm, dd, shift_days)
		return string.format(output_format or "%04d%02d%02d", year, mm, dd);
	end
end

-- days between 2000.1.1 and input date
function timehelp.days_since2000(year, month, day)
	return timehelp.makedaynum(year, month, day) - 730119;
end

-- days between 2050.1.1 and input date
function timehelp.days_to2050(year, month, day)
	return 748382 - timehelp.makedaynum(year, month, day);
end

local month_days = {
	[1] = 31;
	[2] = 30;
	[3] = 31;
	[4] = 30;
	[5] = 31;
	[6] = 30;
	[7] = 31;
	[8] = 31;
	[9] = 30;
	[10] = 31;
	[11] = 30;
	[12] = 31;
};

-- get the number of the days in the month with the given year
function timehelp.get_days_number_in_month(year, month)
	local _year = tonumber(year);
	local _month = tonumber(month);
	local num;
	if(_year and _month) then
		num = month_days[_month];
		if(_month == 2 and timehelp.isleapyear(_year)) then
			num = 28;
		end
	end
	return num;
end

----------------------------------------
-- date time range
----------------------------------------
if(not timehelp.datetime_range) then
	timehelp.datetime_range = {}
end

function timehelp.datetime_range:new(o)
	local value;
	if(type(o) == "string") then
		value = o;
		o = nil;
	end
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self

	if(value) then
		o:LoadFromString(value);
	end
	return o
end

-- set the time range
-- @param value: (min hour day month [weekday])(min hour day month [weekday])  
-- e.g.:
-- "59 23 26 11" : precise time
-- "* * 26 11" : all day Nov. 26th.
-- "(* 10 26 11)" : 10:00am-11:59am on Nov. 26th.
-- "* * * * 6" : every Saturday
-- "(* * * * 5)(* * * * 7)" : from every Friday to Sunday.
-- "(* 6 26 11)(* * 27 11)" : from Nov.26 6:00am to Nov.27th 24:00
-- "(30 10 * *)(30 11 * *)" : every day from 10:30 to 11:30
-- "(30 10 * * 5)(30 11 * * 5)" : every Friday from 10:30 to 11:30
function timehelp.datetime_range:LoadFromString(value)
	if(not value) then
		return;
	end

	local from_min, from_hour, from_day, from_month, from_weekday, trail_str = value:match("^%(?(%S*) (%S*) (%S*) ([%d%*]*)%s*([^%(%)]*)(.*)$");
	local to_min, to_hour, to_day, to_month, to_weekday;
	if(trail_str and trail_str~="") then
		to_min, to_hour, to_day, to_month, to_weekday = trail_str:match("^[%(%)]*(%S*) (%S*) (%S*) ([%d%*]*)%s*([^%(%)]*)");
	end
	if(from_min) then
		self.from_min = tonumber(from_min);
		self.from_hour = tonumber(from_hour);
		self.from_day = tonumber(from_day);
		self.from_month = tonumber(from_month);
		self.from_weekday = tonumber(from_weekday);
	end
	if(to_min) then
		self.from_min = self.from_min or 0;
		self.from_hour = self.from_hour or 0;
		self.from_day = self.from_day or 0;
		self.from_month = self.from_month or 0;

		self.has_to = true;
		self.to_min = tonumber(to_min);
		self.to_hour = tonumber(to_hour);
		self.to_day = tonumber(to_day);
		self.to_month = tonumber(to_month);
		self.to_weekday = tonumber(to_weekday);
	end
end

-- whether the time is in range
-- @param min, hour, day, month, year: number or string, all values can be nil. which means match anything. 
function timehelp.datetime_range:is_matched(min, hour, day, month, year)
	min = tonumber(min);
	hour = tonumber(hour);
	day = tonumber(day);
	month = tonumber(month);
	year = tonumber(year);

	if(not self.has_to) then
		if(self.from_min and min and self.from_min~=min) then
			return;
		end
		if(self.from_hour and hour and self.from_hour~=hour) then
			return;
		end
		if(self.from_day and day and self.from_day~=day) then
			return;
		end
		if(self.from_month and month and self.from_month~=month) then
			return;
		end
		if(self.from_weekday and timehelp.get_day_of_week(year or 0, month or 1, day or 1) ~= self.from_weekday) then
			return;
		end
		return true;
	else
		if(self.from_weekday and self.to_weekday) then
			local weekday = timehelp.get_day_of_week(year or 0, month or 1, day or 1);
			if(weekday and (weekday<self.from_weekday or weekday >self.to_weekday)) then
				return;
			end
		end

		local to_month = self.to_month or month;
		if(month) then
			if((month<self.from_month or (month >to_month ))) then
				return;
			elseif(month<to_month) then
				return true;
			end
		end

		local to_day = self.to_day or day;
		if(day) then
			if(((not self.to_month or self.from_month == to_month) and day<self.from_day) or day >to_day) then
				return;
			elseif(day<to_day) then
				return true;
			end
		end

		local to_hour = self.to_hour or hour;
		if(hour) then
			if(((not self.to_day or self.from_day == to_day) and hour<self.from_hour) or hour >to_hour) then
				return;
			elseif(hour<to_hour) then
				return true;
			end
		end

		local to_min = self.to_min or min;
		if(min) then
			if(((not self.to_hour or self.from_hour == to_hour) and min<self.from_min) or min>to_min) then
				return;
			end
		end
		return true;
	end
end


local function time_format(value)
	if(type(value) == "number") then
		return string.format("%02d", value);
	end
end
-- @param strFormat: if nil, it default to "@month/@day @hour:@min", ""
-- @param strRangeFormat: if nil, it default to "@from - @to"
-- @param strAnyString: if nil, it default to "*"
function timehelp.datetime_range:tostring(strFormat, strRangeFormat, strAnyString)
	strFormat = strFormat or "@month/@day @hour:@min";
	strRangeFormat = strRangeFormat or "@from - @to";
	strAnyString = strAnyString or "*";

	local from = strFormat;

	from = string.gsub(from, "@month", time_format(self.from_month) or strAnyString)
	from = string.gsub(from, "@day", time_format(self.from_day) or strAnyString)
	from = string.gsub(from, "@hour", time_format(self.from_hour) or strAnyString)
	from = string.gsub(from, "@min", time_format(self.from_min) or strAnyString)
	
	
	if(not self.has_to) then
		return from;
	else
		local to = strFormat;
		to = string.gsub(to, "@month", time_format(self.to_month) or strAnyString)
		to = string.gsub(to, "@day", time_format(self.to_day) or strAnyString)
		to = string.gsub(to, "@hour", time_format(self.to_hour) or strAnyString)
		to = string.gsub(to, "@min", time_format(self.to_min) or strAnyString)
		
		local range_text = strRangeFormat;
		range_text = string.gsub(range_text, "@from", from)
		range_text = string.gsub(range_text, "@to", to)
		return range_text;
	end
end