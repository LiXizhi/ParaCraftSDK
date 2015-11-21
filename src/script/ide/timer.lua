--[[
Title: timer functions
Author(s):  LiXizhi
Date: 2009/1/17, refactored to use virtual timers 2009/9/25
Desc: Provides a mechanism for executing a method at specified intervals.
It just wraps the raw NPL timer function. One can create any number of timers as one like, 
only one high resolution real timer is used to dispatch all instances of timer object. 
TODO: currently a single timer pool is used, in future we may sort timers to different pool according to their periods. 
This will allow large number of virtual timers to coexist with lower performance penalty. 
Note: virtual timers are not cleared during scene reset. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/timer.lua");

local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
	commonlib.log({"ontimer", timer.id, timer.delta, timer.lastTick})
end})

-- start the timer after 0 milliseconds, and signal every 1000 millisecond
mytimer:Change(0, 1000)

-- start the timer after 1000 milliseconds, and stop it immediately.
mytimer:Change(1000, nil)

-- now kill the timer. 
mytimer:Change()

-- kill all timers in the pool
commonlib.TimerManager.Clear()

-- dump timer info
commonlib.TimerManager.DumpTimerCount()

-- get the current time in millisecond. This may be faster than ParaGlobal_timeGetTime() since it is updated only at rendering frame rate. 
commonlib.TimerManager.GetCurrentTime();
------------------------------------------------------------
]]

local Timer = {
	-- must be unique
	id = nil,
	-- call back function (timer) end
	callbackFunc = nil,
	-- The amount of time to delay before the invoking the callback method specified in milliseconds
	-- Specify zero (0) to restart the timer immediately. Specify nil to prevent the timer from restarting. 
	dueTime = nil,
	-- The time interval between invocations of the callback method in milliseconds. 
	-- Specify nil to disable periodic signaling. 
	period = nil,
	-- whether the timer is enabled or not.
	enabled = nil,
	-- value returned from last activation call of ParaGlobal.timeGetTime()
	lastTick = 0,
}
commonlib.Timer = Timer;

local TimerManager = {timer_id = 1025}
commonlib.TimerManager = TimerManager

local pairs = pairs;
local ipairs = ipairs;
local type = type;
local ParaGlobal_timeGetTime = ParaGlobal.timeGetTime
	
-- max allowed timer due time
local MAX_TIMER_DUE_TIME = 10000000

-- mapping from id to the timer object. 
local timer_pool_ = {};

-- a new timer class with infinite time. 
function Timer:new(o)
	o = o or {};
	o.id = o.id or Timer.GetNextTimerID();
	setmetatable(o, self)
	self.__index = self
	timer_pool_[o.id] = o;
	o:Change(o.dueTime, o.period);
	return o
end

local next_id = 1025;
-- get the next timer id
function Timer.GetNextTimerID()
	next_id = next_id+1;
	return next_id;
end

-- change the timer
-- @param dueTime The amount of time to delay before the invoking the callback method specified in milliseconds
--	Specify zero (0) to restart the timer immediately. Specify nil to prevent the timer from restarting. 
-- @param period The time interval between invocations of the callback method in milliseconds. 
--	Specify nil to disable periodic signaling. 
function Timer:Change(dueTime,period)
	self.dueTime = dueTime;
	self.period = period;
	
	if(not dueTime) then
		TimerManager.RemoveTimer(self);
	else
		self.lastTick = ParaGlobal_timeGetTime() + dueTime - (period or 0);
		TimerManager.AddTimer(self);
	end
end

-- call this function to enable the timer if not 
function Timer:Enable()
	TimerManager.AddTimer(self);
end

-- this function is called by the timer manager to process the time. 
-- set the tick count. it will return true, if the timer is activated. 
-- call this function regularly with new tick count. 
-- @param nTickCount: it should be ::GetTickCount() in millisecond. if nil, we will call the system ::GetTickCount() to get the current tick count. 
-- @return true if timer is activated. 
function Timer:Tick(nTickCount)
	if(not nTickCount) then
		nTickCount = ParaGlobal_timeGetTime();
	end
	local lastTick = self.lastTick;
	if( (nTickCount-lastTick)>=(self.period or 0) or ((nTickCount<lastTick) and ((nTickCount+MAX_TIMER_DUE_TIME)<lastTick))) then
		self.delta = nTickCount - lastTick;
		self.lastTick = nTickCount;
		if(self.period == nil) then
			TimerManager.RemoveTimer(self);
		end
		-- do activation
		self:Activate();
		return true;
	end
end

-- get the delta in time since last tick. 
-- @param max_delta: if the delta is bigger than this value we will return max_delta rather than the big value. 
--  if this is nil, it will be 2 times of self.period
function Timer:GetDelta(max_delta)
	max_delta = max_delta or (self.period or 10000) * 2;
	if(self.delta) then
		if(max_delta > self.delta) then
			return self.delta;
		else
			return max_delta;
		end
	else
		return 0;
	end
end

-- activate the call back. 
function Timer:Activate()
	if(self.callbackFunc) then	
		self:callbackFunc();
	end
end

-- whether the timer is going to be called at least once in the future. 
-- NOTE: this may not be accurate if scene is reset. 
function Timer:IsEnabled()
	return self.enabled;
end

--------------------------------------
-- timer manager: it groups timers with their intervals and check if any of them needs to be activated. 
--------------------------------------

-- TODO: this is for high resolution timer whose interval is smaller than 60 milli-seconds
local timer_pool_60 = {};
-- TODO: this is for medium resolution timer whose interval is between (60-600) milli-seconds
local timer_pool_600 = {};
-- TODO: this is for low resolution timer whose interval is between (600-1500) milli-seconds
local timer_pool_1500 = {};
-- TODO: this is for very low resolution timer whose interval is less than 10 seconds
local timer_pool_10sec = {};
-- TODO: this is for most low resolution timer whose interval is above 10 seconds
local timer_pool_slow = {};

-- a table of newly added timers. 
local new_timers;

-- a table of to-be removed timers
local remove_timers;

-- if timer is started. 
local IsStarted = false;
local npl_profiler;

-- create a global timer for all sub timers. 
function TimerManager.Start()
	-- clear all timers
	NPL.SetTimer(TimerManager.timer_id, 0.01, ";commonlib.TimerManager.OnTimer();");
	--log("TimerManager started\n")
	
	NPL.load("(gl)script/ide/Debugger/NPLProfiler.lua");
	npl_profiler = npl_profiler or commonlib.gettable("commonlib.npl_profiler");
end

function TimerManager.Stop()
	NPL.KillTimer(TimerManager.timer_id);
end

-- clear all timers
function TimerManager.Clear()
	new_timers = {};
	timer_pool_ = {};
	TimerManager.Stop()
	IsStarted = false;
end

-- call this function to either add a timer to the pool or change the timer settings. 
-- it will automatically set timer.enabled to true. 
-- @param timer: the timer object
function TimerManager.AddTimer(timer)
	timer.enabled = true;
	-- start immediately on load
	if(not IsStarted) then
		IsStarted = true;
		TimerManager.Start();
	end	

	--commonlib.echo({"timer added", timer.id, tick=timer.lastTick});

	-- add to active timer pool if not added before
	if(not timer_pool_[timer.id]) then
		-- note: we should never modify the timer pool directly, since this function may be inside the timer loop.
		new_timers = new_timers or {};
		new_timers[timer.id] = timer;
	elseif(remove_timers and remove_timers[timer.id]) then
		remove_timers[timer.id] = nil;
	end
end

-- remove the given timer by id
function TimerManager.RemoveTimer(timer)
	timer.enabled = nil;
	-- note: we should never modify the timer pool directly, since this function may be inside the timer loop.
end

-- dump timer info. 
function TimerManager.DumpTimerCount()
	local activeCount, totalCount = 0,0;
	for id,timer in pairs(timer_pool_) do
		totalCount = totalCount + 1
		if(timer.enabled) then
			activeCount = activeCount + 1
		end	
	end
	commonlib.applog("Current Timer Info: Active Timers: %d, Total Timers: %d", activeCount, totalCount)
	return activeCount, totalCount;
end

TimerManager.last_tick = 0;

-- the global ParaEngine high resolution timer. 
function TimerManager.OnTimer()
	npl_profiler.perf_begin("TimerManager.OnTimer");
	local last_tick = ParaGlobal_timeGetTime();
	TimerManager.last_tick = last_tick;
	
	-- add new timers from the pool
	if(new_timers) then
		local id, timer
		for id, timer in pairs(new_timers) do
			timer_pool_[id] = timer;
		end
		new_timers = nil;
	end

	-- frame move all timers (Tick timers)
	local id, timer
	for id,timer in pairs(timer_pool_) do
		if(timer.enabled) then
			timer:Tick(last_tick);
		else
			remove_timers = remove_timers or {};
			remove_timers[id] = true;
		end	
	end
	
	-- remove expired or disabled timers. 
	if(remove_timers) then
		local _, id
		for id, _ in pairs(remove_timers) do
			timer_pool_[id] = nil;
		end
		remove_timers = nil;
	end
	npl_profiler.perf_end("TimerManager.OnTimer");
end

-- get the current time in millisecond. This may be faster than ParaGlobal_timeGetTime() since it is updated only at rendering frame rate. 
-- @note the resolution of the timer is same as the scripting frame move rate.
function TimerManager.GetCurrentTime()
	return TimerManager.last_tick;
end

-- wait a specified number of milliseconds, and then execute a specified function, 
-- and it will continue to execute the function, once at every given time-interval.
-- @return the timer object which can be used to call ClearInterval
function TimerManager.SetInterval(func, milliSecond)
	local timer = Timer:new({callbackFunc = func});
	timer:Change(milliSecond, milliSecond);
	return timer;
end

function TimerManager.ClearInterval(timer)
	timer:Change();
end

-- create a timer object that will timeout once and call func. 
-- @param milliSecond: default to 1000ms (1 second)
-- @return the timer object. 
function TimerManager.SetTimeout(func, milliSecond)
	local timer = Timer:new({callbackFunc = func});
	timer:Change(milliSecond);
	return timer;
end

function TimerManager.ClearTimeout(timeoutVariable)
	timeoutVariable:Change();
end