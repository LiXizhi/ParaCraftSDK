--[[
Title: EventDispatcher
Author(s): Leio
Date: 2008/12/24
Desc: 
EventDispatcher --> Object
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/EventDispatcher.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Object.lua");
local EventDispatcher = commonlib.inherit(CommonCtrl.Display.Object,{
});  
commonlib.setfield("CommonCtrl.Display.EventDispatcher",EventDispatcher);
function EventDispatcher:RemoveEventListener(type)
	if(not type)then return end
	if(self.event_pools)then
		self.event_pools[type] = nil;
	end
end
function EventDispatcher:HasEventListener(type)
	if(not type)then return end
	if(self.event_pools)then
		if(self.event_pools[type])then 
			return true;
		end
	end
end
function EventDispatcher:DispatchEvent(event)
	if(not event)then return end
	if(self.event_pools)then
		local type = event.type;
		local listener = self.event_pools[type]
		if(listener)then
			local func = listener.func;
			local funcHolder = listener.funcHolder;
			func(funcHolder,event)
		end
	end
end
function EventDispatcher:AddEventListener(type,func,funcHolder)
	if(not type or not func or not funcHolder)then return end		
	if(self.event_pools)then
		self.event_pools[type] = {func = func,funcHolder = funcHolder};
	end
end
function EventDispatcher:ClearEventPools()
	self.event_pools = {};
end