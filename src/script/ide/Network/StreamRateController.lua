--[[
Title: stream rate controller
Author(s):  LiXizhi
Date: 2011/9/2
Desc: stream rate controller can be used to limit traffic like chat messages, etc. 
We can limit by average message per second, etc. Internally, it will use two message queue for measuring. 
The most important feature is that it provide a history_length parameter, which allows message rate to reach a temporary higher peak value.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Network/StreamRateController.lua");
local StreamRateController = commonlib.gettable("commonlib.Network.StreamRateController");
local srcTest = StreamRateController:new({name="queuename", history_length = 10, max_msg_rate=1})
srcTest:AddMessage(1, function() log("message of size 1 is added\n") end)
local i;
for i=1, 20 do 
	if(srcTest:AddMessage()) then
		log("msg "..i.." sent\n"); -- only i=[1,10] will be printed
	end
end
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/ide/timer.lua");

local TimerManager = commonlib.gettable("commonlib.TimerManager");

local StreamRateController = commonlib.createtable("commonlib.Network.StreamRateController", {
	-- name string, only used when writing log when queue is full.
	name = "",
	-- max number of messages in history queue. 
	-- if nil, it will be computed as math.ceil(history_length*max_msg_rate + 1) at construction time. 
	max_messages_in_queue = nil,
	-- in seconds, we will keep track of all history messages of this length. 
	-- and compute the current message rate by averaging the history. 
	history_length = 10,
	-- the max number of message per second allowed. This value is computed against history_length.
	-- so it will allow at most max_msg_rate * history_length messages to be sent concurrently. 
	-- nil means not limited
	max_msg_rate = nil,
	-- the max number of message size per second allowed. This value is computed against history_length.
	-- so it will allow at most max_data_rate * history_length to be sent concurrently. 
	-- nil means not limited
	max_data_rate = nil,
});
	
-- a new timer class with infinite time. 
function StreamRateController:new(o)
	o = o or {};
	setmetatable(o, self)
	self.__index = self
	o.queue = commonlib.List:new();
	o.unused_queue = commonlib.List:new();

	o:Reset();
	return o
end

-- clear all statistics
function StreamRateController:Reset()
	self.start_time = nil;
	self.total_msg_count = 0;
	self.total_msg_size = 0;
	self.max_messages_in_queue = self.max_messages_in_queue or math.ceil(self.history_length*(self.max_msg_rate or 0) + 1)
	self.queue:clear();
end

-- TODO: since we support one filter, we will hard code it in AddMessage for performance. 
function StreamRateController:msg_rate_filter()
end

function StreamRateController:GetLastMessageTime()
	local item = self.queue:last();
	if(item) then
		return item.time;
	end
	return 0;
end

-- add a message to the data size. 
-- @param nSize: data size of the message. default to 1. 
-- @param handler_callback: function to be called when message is allowed to be processed. 
-- this can be nil, if one is only interested in statistics or whether message is allowed to be processed. 
-- @return res, reason: res is true if message can be processed immediately. otherwise it is false. and the second parameter contains the error message.  
--	reason is "pending"(NOT implemented yet) if message can not be processed now but in a pending queue 
--  reason is "full", if message is not allowed to be processed. 
function StreamRateController:AddMessage(nSize, handler_callback)
	nSize = nSize or 1;
	local cur_time = TimerManager.GetCurrentTime();
	if(not self.start_time) then
		self.start_time = cur_time;
	end
	
	-- filtering. checking history.
	local history_length = self.history_length;
	local history_length_ms = history_length*1000;
	local total_history_data_size = 0;
	local item = self.queue:first();
	local max_queue_size = self.max_messages_in_queue;
	while (item) do
		if((cur_time - item.time) > history_length_ms ) then
			local old_item =  item;
			item = self.queue:remove(item);
			self.unused_queue:push_back(old_item);
		else
			total_history_data_size = total_history_data_size + item.size;
			item = self.queue:next(item)
		end
	end
	local res, reason;
	local total_history_msg_count = self.queue:size();
	if ( (not self.max_data_rate or total_history_data_size/history_length <= self.max_data_rate) and
		 (not self.max_msg_rate or total_history_msg_count/history_length <= self.max_msg_rate) )then
		res = true;
	else
		reason = "full";
		-- LOG.std(nil, "debug", "StreamRateController", "name:%s sending too fast, message will be dropped", self.name or "")
	end

	if(res) then
		if(self.queue:size() >= max_queue_size) then
			local old_item = self.queue:first();
			self.queue:remove(old_item);
			self.unused_queue:push_back(old_item);
		end

		local new_item = self.unused_queue:first();
		if(not new_item) then
			new_item = {};
		else
			self.unused_queue:remove(new_item);
		end
		new_item.size = nSize;
		new_item.time = cur_time;
		
		self.queue:push_back(new_item)
		
		self.total_msg_count = self.total_msg_count + 1; 
		self.total_msg_size = self.total_msg_size + nSize; 

		if(handler_callback) then
			handler_callback();
		end
	end
	
	--[[local res;
	-- now apply filter
	res = self:msg_rate_filter();
	if(res = true) then
		-- TODO: apply next filter here
		if(res = true) then
			-- TODO: apply next filter here
		end
	end]]
	return res, reason;
end
