--[[
Title: Filters
Author(s): LiXizhi, 
Date: 2015/6/14
Desc: 
Hook a function or method to a specific filter action. Filters offers filter hooks to allow plugins to modify
various types of internal data at runtime.

A plugin can modify data by binding a callback to a filter hook. When the filter
is later applied, each bound callback is run in order of priority, and given
the opportunity to modify a value by returning a new value.

references: plugin.php in Wordpress.org framework

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/Filters.lua");
local Filters = commonlib.gettable("System.Core.Filters");
local filter = Filters:new();

-- Our filter callback function
function example_callback( str, arg1, arg2 )
	--(maybe) modify string
	return str..tostring(arg1)..tostring(arg2);
end
filter:add_filter( 'example_filter', example_callback, 10);

-- Apply the filters by calling the 'example_callback' function we
-- "hooked" to 'example_filter' using the add_filter() function above.
-- - 'example_filter' is the filter hook tag
-- - 'filter me' is the value being filtered
-- - arg1 and arg2 are the additional arguments passed to the callback.
local value = filter:apply_filters( 'example_filter', 'filter me:', "arg1", "arg2");
assert(value == "filter me:arg1arg2");

filter:add_filter( 'example_filter', function(value) return "unset" end, 11);
local value = filter:apply_filters( 'example_filter', 'filter me:', "arg1", "arg2");
assert(value == "unset");

filter:add_filter( 'example_filter', function(value) return "unset" end, 11);
local value = filter:remove_all_filters( 'example_filter');
local value = filter:apply_filters( 'example_filter', 'filter me:', "arg1", "arg2");
assert(value == "filter me:");

------------------------------------------------------------
]]

local Filters = commonlib.inherit(nil, commonlib.gettable("System.Core.Filters"));

function Filters:ctor()
	self.wp_filter = {};
	self.merged_filters = {};
	self.wp_current_filter = commonlib.Stack:Create();
end


-- Hooks a function on to a specific action.
-- 
-- Actions are the hooks that the framework core launches at specific points
-- during execution, or when specific events occur. Plugins can specify that
-- one or more of its NPL functions are executed at these points, using the action API.
-- 
-- @param tag:  The name of the action to which the function_to_add is hooked.
-- @param function_to_add: The name of the function you wish to be called.
-- @param priority: Used to specify the order in which the functions associated with a particular action are executed. Default 10.
--		Lower numbers correspond with earlier execution, and functions with the same priority are executed in the order in which they were added to the action.
-- @return bool Will always return true.
function Filters:add_action(tag, function_to_add, priority)
	return self:add_filter(tag, function_to_add, priority);
end

-- Hook a function or method to a specific filter action.
-- A plugin can modify data by binding a callback to a filter hook. When the filter
-- is later applied, each bound callback is run in order of priority, and given
-- the opportunity to modify a value by returning a new value.
function Filters:add_filter( tag, function_to_add, priority)
	if(not function_to_add) then
		LOG.std(nil, "warn", "Filters", "add_filter function not found for filter %s", tag);
		return;
	end
	priority = priority or 10;
	if(not self.wp_filter[tag]) then
		self.wp_filter[tag] = commonlib.ArrayMap:new();
	end
	if(not self.wp_filter[tag][priority]) then
		self.wp_filter[tag][priority] = {};
	end
	self.wp_filter[tag][priority][function_to_add] = function_to_add;
	self.merged_filters[tag] = nil;
	return true;
end

function Filters:current_action()
	return self:current_filter();
end

function Filters:current_filter()
	return self.wp_current_filter;
end

-- Remove all of the hooks from a filter.
-- @param priority: int|bool  Optional. The priority number to remove. Default nil.
function Filters:remove_all_filters(tag, priority)
	if ( self.wp_filter[tag] ) then
		if ( priority and self.wp_filter[tag][priority]) then
			self.wp_filter[tag][priority] = nil;
		else 
			self.wp_filter[tag] = nil;
		end
	end
	if (self.merged_filters[tag]) then
		self.merged_filters[tag] = nil;
	end
	return true;
end

function Filters:remove_filter( tag, function_to_remove, priority)
	priority = priority or 10;
	
	if(self.wp_filter[tag] and self.wp_filter[tag][priority]) then
		local r = self.wp_filter[tag][priority][function_to_remove];

		if ( r ) then
			self.wp_filter[tag][priority][function_to_remove] = nil;
			if ( not next( self.wp_filter[tag][priority] ) ) then
				self.wp_filter[tag][priority] = nil;
			end
			if ( self.wp_filter[tag]:empty() ) then
				self.wp_filter[tag] = nil;
			end
			self.merged_filters[tag] = nil;
		end
		return r;
	end
end

local function call_user_func(func, ...)
	local func_type = type(func);
	if(func_type == "function") then
		return func(...);
	elseif(func_type == "string") then
		func = commonlib.getfield(func);
		if(type(func) == "function") then
			return func(...);
		end
	elseif(func_type == "table") then
		if(type(func[1]) == "table" and func[2]) then
			local func_body;
			if(type(func[2]) == "string") then
				func_body = func[1][func[2]];
			elseif(type(func[2]) == "function") then
				func_body = func[2];
			end
			
			if(type(func_body) == "function") then
				return call_user_func(func_body, func[1], ...);
			else
				log("call_user_func with unknown function:"..tostring(func[2]));
			end
		end
	end
end

function Filters:_wp_call_all_hook(...)
	if ( self.wp_filter['all'] ) then
		for func in ipairs(self.wp_filter['all']) do
			call_user_func(func, ...);
		end
	end
end


-- Call the functions added to a filter hook.
-- The callback functions attached to filter hook tag are invoked by calling
-- this function. This function can be used to create a new filter hook by
-- simply calling this function with the name of the new hook specified using
-- the tag parameter.
-- @param tag   The name of the filter hook.
-- @param value The value on which the filters hooked to <tt>tag</tt> are applied on.
-- @return mixed The filtered value after all hooked functions are applied to it.
function Filters:apply_filters( tag, value, ... ) 
	
	-- Do 'all' actions first.
	self:_wp_call_all_hook(...);
	
	if ( not self.wp_filter[tag] ) then
		if ( self.wp_filter['all'] ) then
			self.wp_current_filter:pop();
		end
		return value;
	end

	if ( not self.wp_filter['all'] ) then
		self.wp_current_filter:push(tag);
	end

	-- Sort.
	if ( not self.merged_filters[tag] ) then
		self.wp_filter[tag]:ksort();
		self.merged_filters[tag] = true;
	end

	for priority, funcs in self.wp_filter[tag]:pairs() do
		for _, func in pairs(funcs) do
			value = call_user_func(func, value, ...);	
		end
	end

	self.wp_current_filter:pop();

	return value;
end
