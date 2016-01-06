--[[
Title: Tool Base
Author(s): LiXizhi
Date: 2014/11/25
Desc: base class for a tool. I have referenced the qobject class in QT framework. I remodeled it with NPL terms:
   * object is modeled as a neuron
   * a object can define any number signal functions. A signal function is an output axon connection. 
   * with Connect method, a signal(axon) can be dynamically connected to one or more objects' slot functions, like multiple synapses. 
   * object knows Nothing about which other objects are connected to it. 
   * object fire signals via axon connections to other objects. 

Signals and slots:	
	Slots can be used for receiving signals, but they are also normal member functions. 
	An object does not know if anything receives its signals, and a slot does not know if it has any signals connected to it. 
	This ensures truly independent components.
	You can connect as many signals as you want to a single slot, and a signal can be connected to as many slots as you need. 
	It is even possible to connect a signal directly to another signal. (This will emit the second signal immediately whenever the first is emitted.)
	If several slots are connected to one signal, the slots will be executed one after the other, in the order they have been connected, when the signal is emitted.

Coding style and internals: 
	Unlike QT, signals do not need to be defined explicitly. Any function on object can be used as a signal or a slot. 
	There is no meta class for class object, instead the object itself is used as the meta object and axon connections are instantiated on first use.  
	This allows more dynamic connection programming.
 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/ToolBase.lua");
local MyTool = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Core.MyTool"));
-- define property
MyTool:Property({"Enabled", true, "isEnabled", auto=true});
MyTool:Property("Value", nil, nil, nil, "ValueChanged");
MyTool:Property("Tag");
MyTool:Property({"Visible"});
MyTool:Property({"BackgroundColor", "#cccccc", auto=true});
MyTool:Property({"down", nil, "isDown", "setDown"});
MyTool:Property({"size", type="double"});

-- define signal
MyTool:Signal("XXXChanged", function(only_for_doc)  end);
-- create instance
local tool1 = MyTool:new();
local tool2 = MyTool:new();
tool1:Connect("ValueChanged", tool2, "SetValue", "UniqueConnection");
-- disconnect 
tool1:Disconnect("ValueChanged", tool2, "SetTag");
-- invoke signals
tool1:Connect("XXXChanged", tool2, "SetTag");
tool1:XXXChanged("XXXChanged");
assert(tool2:GetTag() == "XXXChanged");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/ToolBase_p.lua");
local EventTickFunc = commonlib.gettable("System.Core.EventTickFunc");
local ConnectionSynapse = commonlib.gettable("System.Core.ConnectionSynapse");
local SignalConnections = commonlib.gettable("System.Core.SignalConnections");
local type = type;
local ToolBase = commonlib.inherit(nil, commonlib.gettable("System.Core.ToolBase"));

ToolBase:Property({"Name", "ToolBase", auto=true});

-- all outgoing signals 
ToolBase.signal_connections = nil;
-- all incoming connections to this receiver. mapping from ConnectionSynapse to true. 
ToolBase.senders = nil;

function ToolBase:ctor()
	
end

function ToolBase:Destroy()
	self.wasDeleted = true;
	-- disconnect all receivers
	self:Disconnect();
	-- disconnect from all senders
	self:DisconnectSenders();

	self.currentSender = nil;

	self:deleteChildren();

	-- remove it from parent object
	if (self.parent) then
        self:setParent_helper(nil);
	end
end

-- call constructure recursively, however without assigning metatable. This is only for singleton init with self. 
-- so that new function is no longer called. 
local function ctor_recursive(o, current_class)
	current_class = current_class or o;
	if(current_class._super) then
		ctor_recursive(o, current_class._super);
	end
	local ctor = rawget(current_class, "ctor");
	if(type(ctor) == "function") then
		ctor(o);
	end
end

-- Returns true if this object is a parent, (or grandparent and so on
-- to any level), of the given child; otherwise returns false.
function ToolBase:isAncestorOf(child)
    while (child) do
        if (child == self) then
            return true;
        elseif (not child.parent) then
            return false;
		end
        child = child.parent;
    end
    return false;
end

-- static function: to use the class itself as a singleton object. 
-- this function can be called many times, only the first time succeed. 
-- Once called, it will disable new() method for object instantiation.  
function ToolBase:InitSingleton()
	if(not rawget(self, "singletonInited")) then
		self.singletonInited = true;
		ctor_recursive(self);
		-- disable new function. 
		self.new = function()
			LOG.std(nil, "error", "ToolBase", "class %s is InitSingleton, can not be instantiated.", self:GetName());
		end;
	end
end

-- get event system. 
function ToolBase:GetEvents()
	if(not self.events) then
		self.events = commonlib.EventSystem:new();
	end
	return self.events;
end

-- change the timer
-- @param dueTime The amount of time to delay before the invoking the callback method specified in milliseconds
--	Specify zero (0) to restart the timer immediately. Specify nil to prevent the timer from restarting. 
-- @param period The time interval between invocations of the callback method in milliseconds. 
--	Specify nil to disable periodic signaling. 
function ToolBase:ChangeTimer(dueTime, period)
	self.timer = self.timer or commonlib.Timer:new({callbackFunc = function(timer)
		self:OnTick();	
	end});
	self.timer:Change(dueTime, period);
end

function ToolBase:KillTimer()
	if(self.timer) then
		self.timer:Change();
	end
end

-- get event list. 
function ToolBase:GetEventList()
	if(self.eventCache) then
		return self.eventCache;
	else
		self.eventCache = commonlib.List:new();
		return self.eventCache;
	end
end

-- @param ms_delay_time: in ms seconds.
-- @param sender: nil or a class object or anonymous function. 
-- @param slot: the slot function. if nil, the sender can be an anonymous function. 
function ToolBase:ScheduleFunctionCall(ms_delay_time, sender, slot)
	if(slot) then
		self:GetEventList():add(EventTickFunc:new():init(ms_delay_time, sender, slot))
	elseif(type(sender) == "function") then
		self:GetEventList():add(EventTickFunc:new():init(ms_delay_time, nil, sender))
	else
		return;
	end

	self.event_timer = self.event_timer or commonlib.Timer:new({callbackFunc = function(timer)
		self:OnTickEvents(timer:GetDelta());
	end});
	if(not self.event_timer:IsEnabled()) then
		self.event_timer:Change(100,100);
	end
end

-- private function:
function ToolBase:OnTickEvents(deltaTime_ms)
	if(self.eventCache) then
		local eventCache = self.eventCache;
		local event = eventCache:first();
		while (event) do
			if(event:OnTick(deltaTime_ms)) then
				event = eventCache:remove(event);
			else
				event = eventCache:next(event);
			end
		end
		if(eventCache:size() == 0 and self.event_timer) then
			self.event_timer:Change(nil);
		end
	end
end

-- timer function callback:
function ToolBase:OnTick()
	
end

-- getting connection list of a signal function. 
-- this is like axon in human brain. 
-- @param signal: function or string of function name. 
-- @param bCreateIfNotExist: default to nil. 
-- @return a list of synapses on the signal(axon).
function ToolBase:GetConnection(signal, bCreateIfNotExist)
	if(type(signal) ~= "function") then
		local signal_func = self[signal];
		if(not signal_func)  then
			if(bCreateIfNotExist) then
				-- dynamically create the signal function and install to its meta table. 
				signal_func = function(self, ...)
					self:Activate(signal_func, ...);
				end
				local metatable = getmetatable(self) or self;
				metatable.__index[signal] = signal_func;
			else
				return;
			end
		end
		signal = signal_func;
	end
	if(not self.signal_connections) then
		self.signal_connections = SignalConnections:new();
	end
	local axon_connection = self.signal_connections:Get(signal);
	if(not axon_connection and bCreateIfNotExist) then
		axon_connection = commonlib.List:new();
		axon_connection.signal = signal;
		self.signal_connections:Set(signal, axon_connection);
	end
	return axon_connection;
end

-- static function: make automatic connection. If the sender is self pointer, it can be used as member function. 
-- @param connection_type: such as "UniqueConnection", if nil, default to "AutoConnection"
-- @param sender: the sender class object. 
-- @param signal: a member function (or name) on the sender. 
-- @param receiver:the receiver class object. it can also be anonymous function in which case this should be the last parameter. 
-- @param slot: a member function (or name) on the receiver to connect to. 
function ToolBase.Connect(sender, signal, receiver, slot, connection_type)
	if(not slot and type(receiver) == "function") then
		slot = receiver;
		receiver = nil;
		connection_type = nil;
	end
	if(not signal) then
		LOG.std(nil, "warn", "ToolBase:Connect", "invalid null parameter");
		return;
	end
	
	if(type(slot) == "string") then
		slot = receiver[slot];
	end
	if(type(slot)~="function") then
		LOG.std(nil, "warn", "ToolBase:Connect", "slot not found in %s", commonlib.debugstack());
		return;
	end
	return ToolBase.ConnectImp(sender, signal, receiver, slot, connection_type);
end

-- implementation without parameter validation. 
function ToolBase.ConnectImp(sender, signal, receiver, slot, connection_type)
	if(not sender or not signal or (not receiver and not slot)) then
		LOG.std(nil, "warn", "ToolBase:Connect", "invalid null parameter");
		return;
	end
	local connection = sender:GetConnection(signal, true);
	if(connection) then
		if(connection_type == "UniqueConnection") then
			local synapse = connection:first();
			while (synapse) do
				if(synapse:IsConnectedTo(receiver, slot)) then
					-- connection already exist
					return;
				end
				synapse = connection:next(synapse);
			end
		end
		local signal = connection.signal;
		local synapse = ConnectionSynapse:new({
			sender = sender,
			signal = signal,
			receiver = receiver,
			slot = slot,
			connection_type = connection_type, 
		});
		connection:add(synapse);
		if(receiver) then
			receiver.senders = receiver.senders or {};
			receiver.senders[synapse] = true;
		end

		sender:ConnectNotify(signal);
	end
end

-- remove synapse from connection. 
function ToolBase:DisconnectHelper(connection, receiver, slot, disconnectType)
	local success;
	local synapse = connection:first();
	while (synapse) do
		if(not receiver or (synapse.receiver == receiver and (not slot or synapse.slot == slot))) then
			if(synapse.receiver and synapse.receiver.senders) then
				synapse.receiver.senders[synapse] = nil;
			end
			synapse = connection:remove(synapse);
			success = true;
			if(disconnectType == "DisconnectOne") then
				return success;
			end
		else
			synapse = connection:next(synapse);
		end
	end
	return success;
end

-- @param signal: if nil, it will remove all signal connections.
-- @param disconnectType: "DisconnectOne" or "DisconnectAll", default to all. 
function ToolBase.Disconnect(sender, signal, receiver, slot, disconnectType)
	if(not sender) then
		LOG.std(nil, "warn", "ToolBase:Connect", "invalid null parameter");
		return;
	end
	if(type(slot) == "string") then
		slot = receiver[slot];
	end
	local success; 
	if(not signal) then
		if(sender.signal_connections) then
			for signal, connection in sender.signal_connections:pairs() do
				if(sender:DisconnectHelper(connection, receiver, slot, disconnectType)) then
					success = true;
				end
			end
		end
	else
		local connection = sender:GetConnection(signal);
		if(connection) then
			if(sender:DisconnectHelper(connection, receiver, slot, disconnectType)) then
				success = true;
			end
		end
	end

	if (success) then
		sender:DisconnectNotify(signal);
	end
	return success;
end

-- disconnect from all senders
-- this function is mostly used in destructor to automatically break incoming connections.
function ToolBase:DisconnectSenders()
	if(self.senders) then
		for synapse, _ in pairs(self.senders) do
			local sender = synapse.sender;
			if(sender) then
				local connection = sender:GetConnection(synapse.signal);
				if(connection) then
					connection:remove(synapse);	
					sender:DisconnectNotify(synapse.signal);
				end
			end
		end
		self.senders = nil;
	end
end

-- disconnect all connections from a given sender
function ToolBase:DisconnectSender(srcSender)
	if(self.senders) then
		for synapse, _ in pairs(self.senders) do
			local sender = synapse.sender;
			if(sender == srcSender) then
				local connection = sender:GetConnection(synapse.signal);
				if(connection) then
					connection:remove(synapse);	
					sender:DisconnectNotify(synapse.signal);
				end
			end
		end
	end
end

-- Returns a pointer to the object that sent the signal, if called in
-- a slot activated by a signal; otherwise it returns 0. The pointer
-- is valid only during the execution of the slot that calls this
-- function from this object's thread context.
-- 
-- The pointer returned by this function becomes invalid if the
-- sender is destroyed, or if the slot is disconnected from the
-- sender's signal.
-- @warning This function violates the object-oriented principle of
-- modularity. However, getting access to the sender might be useful
-- when many signals are connected to a single slot.
function ToolBase:sender()
	--if (not self.currentSender) then
        --return;
	--end
	return self.currentSender;
end

-- static or member function: activate a given signal, all connected slots will be called. 
-- @param sender: usually self. if used as a member function. 
function ToolBase.Activate(sender, signal, ...)
	local connection = sender:GetConnection(signal);
	if(connection) then
		local synapse = connection:first();
		while (synapse) do
			synapse:Activate(...);
			synapse = connection:next(synapse);
		end
	end
end

-- This virtual function is called when something has been connected
-- to a signal in this object. 
-- warning This function violates the object-oriented principle of
-- modularity. However, it might be useful for optimizing access to expensive resources.
function ToolBase:ConnectNotify(signal)
end

-- This virtual function is called when something has been disconnected from a signal in this object.
-- warning This function violates the object-oriented principle of
-- modularity. However, it might be useful for optimizing access to expensive resources.
function ToolBase:DisconnectNotify(signal)
end

function ToolBase:GetChildren()
	if(not self.children) then
		self.children = commonlib.List:new();
	end
	return self.children;
end

function ToolBase:SetParent(parent)
	self:setParent_helper(parent);
end

function ToolBase:setParent_helper(parent)
	local oldParent = self.parent;
	if (parent == oldParent) then
        return;
	end
	if (oldParent) then
		if(oldParent.isDeletingChildren) then
			-- don't do anything since deleteChildren() already cleared our entry in self.children.
		else
			oldParent.children:remove(self);
		end
	end
	self.parent = parent;
    if (parent) then
		local children = parent:GetChildren();
		children:add(self);
	end
end

function ToolBase:deleteChildren()
	local children = self.children;
	if(children) then
		self.isDeletingChildren = true;
		
		local child = children:first();
		while (child) do
			child:Destroy();
			child = children:remove(child)
		end
		children:clear();

		self.isDeletingChildren = false;
	end
end

-- search function name by func object, in all class hierachy and meta table index.
-- only used for debugging. 
local function FindFunctionName(obj, func)
	if(type(func) == "function" and obj) then
		for name, value in pairs(obj) do
			if(func == value) then
				return tostring(name);
			end
		end
		local meta = getmetatable(obj);
		if(type(meta) == "table" and meta.__index) then
			if(meta.__index ~= obj._super) then
				for name, value in pairs(meta.__index) do
					if(func == value) then
						return tostring(name);
					end
				end
			end
		end

		if(obj._super) then
			return FindFunctionName(obj._super, func);
		end
	end
	return tostring(func);
end

 -- Dumps information about signal connections, etc. for this object to the log.
function ToolBase:dumpObjectInfo()
    log(format("OBJECT %s\n", self:GetName()));
    -- first, look for connections where this object is the sender
    log("  SIGNALS OUT\n");

    if (self.signal_connections) then
        for signal, connections in self.signal_connections:pairs() do 
            log(format("        signal: %s\n", FindFunctionName(self, signal)));

            -- receivers
            local c = connections:first();
			while (c) do
				
			    if (not c.receiver) then
                    log("          <Disconnected receiver>\n");
                else
					log(format("          --> %s %s\n", c.receiver:GetName(), FindFunctionName(c.receiver, c.slot)));
                end
				c= connections:next(c);
            end
        end
    else
        log( "        <None>\n");
    end

    -- now look for connections where this object is the receiver
    log("  SIGNALS IN\n");
    if (self.senders) then
		for s, _ in pairs(self.senders) do
            log(format("          <-- %s  %s\n", s.sender:GetName(), FindFunctionName(s.sender, s.signal)));
        end
    else
        log("        <None>\n");
	end
end


-- Installs an event filter obj on this object. filter is like the hook chain
-- An event filter is an object that receives all events that are
-- sent to this object. The filter can either stop the event or
-- forward it to this object. The event filter obj receives
-- events via its eventFilter() function. The eventFilter() function
-- must return true if the event should be filtered, (i.e. stopped);
-- otherwise it must return false.
-- If multiple event filters are installed on a single object, the
-- filter that was installed last is activated first.
function ToolBase:installEventFilter(obj)
    if (not obj) then
        return;
	end
    if (not self.eventFilters) then
		self.eventFilters = commonlib.Array:new();
	end
    -- clean up unused items in the list
	self:removeEventFilter(obj);
    self.eventFilters:push_front(obj);
end

-- Removes an event filter object obj from this object. The
-- request is ignored if such an event filter has not been installed.
-- All event filters for this object are automatically removed when
-- this object is destroyed.
-- It is always safe to remove an event filter, even during event
-- filter activation (i.e. from the eventFilter() function).
function ToolBase:removeEventFilter(obj)
    if (self.eventFilters) then
        local finished = false;
		while (not finished) do
			finished = true;
			for i, filterObj in ipairs(self.eventFilters) do
				-- also clean up unused items in the list
				if(filterObj.wasDeleted or obj == filterObj) then
					self.eventFilters:remove(i);
					finished = false;
					break;
				end
			end
		end
    end
end

-- filter the event
-- @return true if event is stopped by one of the filtered objects. 
function ToolBase:filterEvent(object, event)
	if (self.eventFilters) then
		local filters = self.eventFilters;
		for i = 1, #filters do
			local filterObj = filters[i];
			if(not filterObj.wasDeleted) then
				if(filterObj:eventFilter(obj, event)) then
					return true;
				end
			end
		end
	end
end

-- virtual function: 
-- Filters events if this object has been installed as an event
-- filter for the watched object.
-- In your reimplementation of this function, if you want to filter
-- the event out, i.e. stop it being handled further, return
-- true; otherwise return false.
-- @sa installEventFilter()
function ToolBase:eventFilter(object, event)
	-- return true; -- return true to stop the event
end