--[[
Title: NPL runtime states monitor
Author(s): LiXizhi
Date: 2009/12/12
Desc: Monitors the messages queue of any number of NPL runtime states. A slow timer is used to collect data. It can be used for reporting stats.
The most important function of monitoring is get the runtime states with the smallest pending message queue and restart states that are suspended due to unreturned calls.
More information, please see the input of start() function. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/NPLStatesMonitor.lua");

local monitor = commonlib.NPLStatesMonitor:new()
monitor:start({npl_states={"main", "r1", "r2"}, update_interval = 1000, load_sample_interval=5000, enable_log = true, log_interval = 2000, candidate_percentage = 0.8})

monitor:PrintAll();
commonlib.echo(monitor:GetNextActiveState(1))
commonlib.echo(monitor:GetNextActiveState(2))
commonlib.echo(monitor:GetNextActiveState(3))
monitor:InactivateState("main");
monitor:PrintAll();
commonlib.echo(monitor:GetNextCandidateState(1))
commonlib.echo(monitor:GetNextCandidateState(2))
commonlib.echo(monitor:GetNextCandidateState(3))
monitor:ActivateState("main");
commonlib.echo(monitor:GetNextCandidateState(1))
commonlib.echo(monitor:GetNextCandidateState(2))
commonlib.echo(monitor:GetNextCandidateState(3))

local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
	log("most free states:\n")
	commonlib.echo(monitor:GetNextFreeState())
	commonlib.echo(monitor:GetNextFreeState())
	commonlib.echo(monitor:GetNextFreeState())
end})
mytimer:Change(0,2000)
------------------------------------------------------------
]]

local NPLStatesMonitor = commonlib.gettable("commonlib.NPLStatesMonitor");

-- create
function NPLStatesMonitor:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- start monitoring runtime states
-- @note: this function can be called multiple times with new npl states to add to the monitor. 
-- @param input: it is table of {npl_states={"name1", "name2"}, update_interval = 1000, load_sample_interval = 60000,enable_log = true, log_interval = 60000, candidate_percentage = 0.8}
--	input.npl_states is an array of npl_states to monitor. 
--	input.update_interval is the default time period(ms) to collect basic stats. default to 1000(or 1 secs)
--	input.load_sample_interval is the interval to calculate the average load. i.e the number of messages processed in the last input.load_sample_interval. default to 120000 (120 secs).
--	input.enable_log, if true we will dump stats of all monitored stats to log every log_interval
--	input.log_interval is the default time period(ms) to print all stats to log. default to 60000(or 60 secs)
--	input.candidate_percentage is a value in range (0,1], where monitor:GetNextCandidateState() will only select from the first (input.candidate_percentage*total state). 
--		a candidate is must be active state(msg_per_sec>0) and must have low load in its message queue. The default value is 0.8, where the ideal value is application specific. 
function NPLStatesMonitor:start(input)
	NPL.load("(gl)script/ide/timer.lua");
	
	commonlib.applog("NPLStatesMonitor is started")
	commonlib.echo(input)
	
	self.enable_log = input.enable_log;
	-- mapping from name to stat table
	self.npl_states = self.npl_states or {};
	-- stat table array sorted from low to high load according to message queue
	self.npl_states_rank = self.npl_states_rank or {};
	self.update_interval = input.update_interval or self.update_interval or 1000;
	self.load_sample_interval = input.load_sample_interval or self.load_sample_interval or 120000;
	self.log_interval = input.log_interval or self.log_interval or 60000;
	self.candidate_percentage = input.candidate_percentage or self.candidate_percentage or 0.8;
	self.next_try_index = 1;

	if(input.npl_states) then
		local i, state_name
		for i, state_name in ipairs(input.npl_states) do
			local stat = self:GetStats(state_name);
		end
	end
	
	self.timer = self.timer or commonlib.Timer:new({callbackFunc = function(timer)
		self:UpdateStats();
	end})
	
	-- total npl states monitored
	self.npl_states_count = #(self.active_npl_states);
	-- ideal candicate count
	self.candicate_count = math.max(1, math.floor(self.npl_states_count * self.candidate_percentage));
	-- the candicate count used in picking next candidate
	self.active_candicate_count = self.candicate_count;
	self:UpdateStats();
	self.timer:Change(0, self.update_interval)
end

-- create get the stats table for a given NPL runtime state_name. This function will create a new stats table for the NPL states, if states not exist. 
-- @return a table of {name, current_msg_count, processed_msg_count, msg_processed_per_sec, start_time, last_update_time, }
function NPLStatesMonitor:GetStats(state_name)
	local stats = self.npl_states[state_name];
	if(stats) then
		return stats;
	else
		stats = {name = state_name, runtime_state = NPL.GetRuntimeState(state_name)};
		self.npl_states[state_name] = stats;
		self.npl_states_rank[#(self.npl_states_rank) + 1] = stats;
		-- index based states table
		self.active_npl_states = self.active_npl_states or {};
		self.active_npl_states[#(self.active_npl_states) + 1] = state_name;
		self.npl_states_count = #(self.active_npl_states);
		return stats;
	end
end

-- sorting the NPL state table from low load to high load. 
local function SortNPLState(left, right)
	return (left.current_msg_count  < right.current_msg_count and not left.is_inactive)
end


-- called periodically to collect stats,and save the most free run time states in self.most_free_state_name
-- @note bForceLog: default to nil. if true, we will dump stats to log. if nil, it will only dump if log_interval has passed. 
function NPLStatesMonitor:UpdateStats(bForceLog)
	local cur_time = ParaGlobal.timeGetTime();
	
	local smallest_msg_count = 999999;
	
	local index, stat
	for index, stat in ipairs(self.npl_states_rank) do
		stat.current_msg_count = stat.runtime_state:GetCurrentQueueSize();
		stat.processed_msg_count = stat.runtime_state:GetProcessedMsgCount();
		
		stat.start_time = stat.start_time or cur_time;
		stat.last_update_time = cur_time;
		
		stat.last_load_sample_time = stat.last_load_sample_time or cur_time;
		stat.last_processed_msg_count = stat.last_processed_msg_count or stat.processed_msg_count;
		stat.last_current_msg_count = stat.last_current_msg_count or stat.current_msg_count;
		stat.msg_per_sec = stat.msg_per_sec or 0;
		if((cur_time - stat.last_load_sample_time) > self.load_sample_interval) then
			stat.last_load_sample_time = cur_time;
			stat.msg_per_sec = (stat.processed_msg_count - stat.last_processed_msg_count) / self.load_sample_interval * 1000;
			stat.last_processed_msg_count = stat.processed_msg_count;
			
			if(stat.msg_per_sec == 0 and stat.current_msg_count>0 and stat.last_current_msg_count==stat.current_msg_count) then
				-- this should be an inactive state, since message queue does not change during the load_sample_interval and no message is processed. 
				if(not stat.is_inactive) then
					self:InactivateState(stat.name)
				end	
			elseif(stat.is_inactive) then
				self:ActivateState(stat.name)
			end
		end
		
		if(not stat.is_inactive and stat.current_msg_count < smallest_msg_count) then
			smallest_msg_count = stat.current_msg_count;
			self.most_free_state_name = stat.name;
		end
	end
	
	-- sort by message queue size for candidate selection
	table.sort(self.npl_states_rank, SortNPLState);
	
	if(self.enable_log or bForceLog) then
		self.last_log_time = self.last_log_time or 0;
		if(bForceLog or (cur_time - self.last_log_time) > self.log_interval or 
			-- fix time wrapping
			cur_time < self.last_log_time) then
			self.last_log_time = cur_time;
			self:PrintAll();
		end
	end
end

-- NOT tested:this is similar to UpdateStats, but it only update current message
-- @return the total number of empty states. In most cases, the message queue should be empty. 
function NPLStatesMonitor:UpdateCurrentMessage()
	local nCount;
	local nEmptyCount = 0;
	local index, stat;
	for index, stat in ipairs(self.npl_states_rank) do
		nCount = stat.runtime_state:GetCurrentQueueSize();
		stat.current_msg_count = nCount;
		if(nCount == 0) then
			nEmptyCount = nEmptyCount + 1;
		end
	end
	return nEmptyCount;
end

-- make a state inactive. Inactive state will not be returned when called GetNextActiveState();
function NPLStatesMonitor:InactivateState(state_name)
	local stat = self:GetStats(state_name);
	stat.is_inactive = true;
	
	local index, name
	local old_index;
	for index,name in ipairs(self.active_npl_states) do
		if(name == state_name) then
			old_index = index;
			break;
		end
	end
	if(old_index) then
		commonlib.removeArrayItem(self.active_npl_states,old_index);
		commonlib.applog("NPL state %s is inactivated. active state count is %d\n", state_name, #(self.active_npl_states));
	end
	self.npl_states_count = #(self.active_npl_states);
	
	self.active_candicate_count = math.min(self.npl_states_count, self.candicate_count)
end

-- make a state active. 
function NPLStatesMonitor:ActivateState(state_name)
	local stat = self:GetStats(state_name);
	stat.is_inactive = nil;
	
	local index, name
	for index,name in ipairs(self.active_npl_states) do
		if(name == state_name) then
			return;
		end
	end
	self.active_npl_states[#(self.active_npl_states) + 1] = state_name;
	commonlib.applog("NPL state %s is activated. active state count is %d\n", state_name, #(self.active_npl_states));
	self.npl_states_count = #(self.active_npl_states);
	
	self.active_candicate_count = math.min(self.npl_states_count, self.candicate_count)
end

-- print to log
function NPLStatesMonitor:PrintAll()
	commonlib.applog("NPLStatesMonitor:PrintAll")
	commonlib.log("|name|cur_msg_count|msg_count|msg_per_sec|most_free:%s\n", self:GetMostFreeState() or "_no free state_");
	local index, stat
	for index, stat in ipairs(self.npl_states_rank) do
		stat.start_time = stat.start_time or cur_time;
		stat.last_update_time = cur_time;
		local tail;
		if(stat.is_inactive) then
			tail = "inactive"
		else
			tail = ""
		end
		commonlib.log("|%s|%d|%d|%.2f|%s\n", stat.name, stat.current_msg_count or 0, stat.processed_msg_count or 0, stat.msg_per_sec  or 0, tail);
	end
end

-- get the npl runtime state name whose message queue is shortest
function NPLStatesMonitor:GetMostFreeState()
	return self.most_free_state_name;
end

-- get the next npl runtime state name whose message queue is active
-- @param req_no: this should be integer that is increased by 1 each time. 
function NPLStatesMonitor:GetNextActiveState(req_no)
	return self.active_npl_states[req_no % (self.npl_states_count) + 1];
end

-- get the next npl runtime state name whose message queue is active and whose message queue is relatively low. 
-- @param req_no: this should be integer that is increased by 1 each time. 
function NPLStatesMonitor:GetNextCandidateState(req_no)
	return self.npl_states_rank[req_no % (self.active_candicate_count) + 1].name;
end

-- instead of getting a candidate state based on req_no, we will get one that is mostly free
-- internally it just looks linearly until find a queue with 0 queue size or wraps around all states and returns the one with minimum queue size. 
function NPLStatesMonitor:GetNextFreeState()
	local nMaxTryCount = self.npl_states_count;
	if(nMaxTryCount <= 0) then
		nMaxTryCount = #(self.npl_states_rank);
	end
	
	local best_free_index = self.next_try_index;
	if(best_free_index>nMaxTryCount) then
		best_free_index = best_free_index - nMaxTryCount;
	end
	local best_free_queue_size = 999999;
	local nIndex;
	for nIndex = 0, nMaxTryCount-1 do
		local try_index = self.next_try_index + nIndex;
		if(try_index > nMaxTryCount) then
			try_index = try_index - nMaxTryCount;
		end
		local stat = self.npl_states_rank[try_index];
		if(not stat.is_inactive) then
			local queue_size = stat.runtime_state:GetCurrentQueueSize();
			if (queue_size < best_free_queue_size) then
				best_free_queue_size = queue_size;
				best_free_index = try_index;
				if(queue_size == 0) then
					break;
				end
			end
		end
	end
	
	self.next_try_index = best_free_index + 1;
	return self.npl_states_rank[best_free_index].name;
end