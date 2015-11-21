--[[
Title: PostEventList
Author(s): LiXizhi
Date: 2015/4/24
Desc: For posted events in widget system. 
PostEventList keeps a sorted list of PostEvent by priority

Reference: QPostEventList in QT framework

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/PostEventList.lua");
local PostEvent = commonlib.gettable("System.Core.PostEvent");
local PostEventList = commonlib.gettable("System.Core.PostEventList");
local list = PostEventList:new();
list:addEvent(PostEvent:new():init({}, {"1"}, 1));
list:addEvent(PostEvent:new_from_pool({}, {"2"}, 1));
list:addEvent(PostEvent:new_from_pool({}, {"3"}, 2));
echo(list:tostring())
------------------------------------------------------------
]]
------------------------------------------------
-- PostEvent
------------------------------------------------
NPL.load("(gl)script/ide/STL/RingBuffer.lua");
local temp_pool = commonlib.RingBuffer:new(); 

local PostEvent = commonlib.inherit(nil, commonlib.gettable("System.Core.PostEvent"));

PostEvent.priority = 0;

function PostEvent:init(receiver, event, priority)
    self.receiver, self.event, self.priority = receiver, event, priority or 0;
	return self;
end

function PostEvent:new_from_pool(receiver, event, priority)
	if(temp_pool:size() >= 200) then
		local pool_item = temp_pool:next();
		if(pool_item:IsAttached()) then
			LOG.std(nil, "debug", "PostEvent:new_from_pool", "warning: max pool size reached \n");
			return PostEvent:new():init(receiver, event, priority);
		else
			return pool_item:init(receiver, event, priority);
		end
	else
		return temp_pool:add(PostEvent:new():init(receiver, event, priority));
	end
end

function PostEvent:IsAttached()
	return (self.prev and self.next);
end

------------------------------------------------
-- PostEventList
------------------------------------------------
local PostEventList = commonlib.inherit(commonlib.gettable("commonlib.List"), commonlib.gettable("System.Core.PostEventList"));

-- recursion count for sendPostedEvents()
PostEventList.recursion = 0;

-- the current event to start sending
PostEventList.startOffset = 0;

-- set by sendPostedEvents to tell postEvent() where to start insertions
PostEventList.insertionOffset = 0;

-- events are sorted by priority on insertion. 
-- @param ev: PostEvent object. 
function PostEventList:addEvent(ev)
	if(not ev) then
		log("warning: nil event for PostEventList:addEvent\n");
		return;
	end
    local priority = ev.priority;
    if (self:empty() or
        self:last().priority >= priority or
        self.insertionOffset >= self:size()) then
        -- optimization: we can simply append if the last event in the queue has higher or equal priority
        self:addtail(ev);
    else
        -- insert event in descending priority order, using upper bound for a given priority 
		-- (to ensure proper ordering of events with the same priority)
		local i = 0;
		local item = self:first();
		while (item) do
			if(i>=self.insertionOffset and item.priority < priority) then
				self:insert_before(ev, item);
				return
			end
			item = self:next(item);
			i = i + 1;
		end
        self:addtail(ev);
    end
end

function PostEventList:tostring()
	local o = "";
	local item = self:first();
	while (item) do
		o = o..string.format("{priority: %d, %s}\n", item.priority, commonlib.serialize_compact(item.event));
		item = self:next(item);
	end
	return o;
end