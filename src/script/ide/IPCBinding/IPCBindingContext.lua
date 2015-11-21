--[[
Title: 
Author(s): Leio
Date: 2010/5/12
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/IPCBindingContext.lua");
------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/ExternalInterface.lua");

local IPCBindingContext = commonlib.gettable("IPCBindingContext");
IPCBindingContext.objectList = {};

-- add a npl object to binding list and call csharp to create a object the same as npl
-- @param bForceRebind: if true, we will need to force rebind the object with the IDE, possibly because its values have changed since the last IDE binding. 
function IPCBindingContext.AddBinding(bindableObject, bForceRebind)
	local self = IPCBindingContext;
	if(not bForceRebind or not self.HasBound(bindableObject)) then
		local uid = bindableObject.uid;
		self.objectList[uid] = bindableObject;
		--add a evnent listener to monitor when object's property is change
		bindableObject:AddEventListener("propertychanged",IPCBindingContext.OnPropertyChanged,{});
		bindableObject:AddEventListener("receive_prop_changed",IPCBindingContext.OnReceivePropertyChanged,{});
		IPCBindingContext.Call(bindableObject,"addbinding");
	elseif(self.HasBound(bindableObject)) then
		-- TODO: update params
		IPCBindingContext.Call(bindableObject,"propertychanged");
	end
end

function IPCBindingContext.RemoveBindingByUID(uid)
	local self = IPCBindingContext;
	if(not uid)then return end
	local obj = self.objectList[uid];
	self.RemoveBinding(obj);
end

-- This function is called by the NPL to select object by uid in the IDE side. 
function IPCBindingContext.SelectObject(uid)
	if(type(uid) == "string") then
		ExternalInterface.Call("selectobject",uid);
	end
end

function IPCBindingContext.RemoveBinding(bindableObject)
	local self = IPCBindingContext;
	if(not self.HasBound(bindableObject))then return end
	local uid = bindableObject.uid;
	self.objectList[uid] = nil;
	bindableObject:RemoveEventListener("propertychanged");
	bindableObject:RemoveEventListener("receive_prop_changed");
	ExternalInterface.Call("removebinding",uid);
end
function IPCBindingContext.Call(bindableObject,type)
	if(not bindableObject or not type)then return end
	local xml = bindableObject:ToXML();
	local classTitle,props = bindableObject:GetClassDescriptor();
	local namespace;
	local className;
	if(classTitle)then
		namespace = classTitle.namespace;
		className = classTitle.label;
	end
	-- LOG.debug("", "debug", "IPCBindingContext", {type, namespace, className, xml})
	
	ExternalInterface.Call(type,namespace,className,xml);
end
function IPCBindingContext.HasBound(bindableObject)
	local self = IPCBindingContext;
	if(not bindableObject)then return end
	if(bindableObject.uid)then
		local uid = bindableObject.uid;
		if(self.objectList[uid])then
			return true;
		end
	end
end
function IPCBindingContext.GetBindingObject(uid)
	local self = IPCBindingContext;
	if(not uid)then return end
	local obj = self.objectList[uid];
	return obj;
end

--[[
	msg = {
		uid = "",
		key = "name",
		value = "",
		type = "string",
	}
--]]
function IPCBindingContext.HandleMsg(msg)
	local self = IPCBindingContext;
	msg = commonlib.LoadTableFromString(msg);
	-- LOG.debug("", "debug", "IPCBindingContext", {"HandleMsg", msg});

	if(not msg)then return end
	local uid = msg.uid;
	local key = msg.key;
	local value = msg.value;
	local type = msg.type;
	if(uid)then
		local bindableObject = self.objectList[uid];
		if(bindableObject)then
			IPCBinding.BindableObject.SetPropertyFromMsg(bindableObject,msg)
		end
	end
end

--通知c#端，npl属性有改变
function IPCBindingContext.OnPropertyChanged(holder,event)
	local self = IPCBindingContext;
	if(not event)then return end
	local bindableObject = event.sender;
	IPCBindingContext.Call(bindableObject,"propertychanged");
end
--c#端属性改变，通知npl端
function IPCBindingContext.OnReceivePropertyChanged(holder,event)
	local self = IPCBindingContext;
	if(not event)then return end
	local bindableObject = event.sender;
	if(bindableObject)then
		local msg = event.msg;
		-- LOG.debug("", "debug", "IPCBindingContext", {"OnReceivePropertyChanged", msg});
		_guihelper.MessageBox(msg);
	end
end