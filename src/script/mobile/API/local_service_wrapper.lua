--[[
Title: NPL remote web service call wrapper with a pre function and post function. 
Author(s): LiXizhi, Andy @ParaEngine
Date: 2008/1/21
Desc: 

]]
NPL.load("(gl)script/mobile/API/local_service_constants.lua");
local LocalService = commonlib.gettable("LocalService");

if(not LocalService.HasRegisterHandleCallBacks) then LocalService.HasRegisterHandleCallBacks = {} end
local HasRegisterHandleCallBacks = LocalService.HasRegisterHandleCallBacks;

if(not LocalService.revision) then LocalService.revision = 1; end


----------------------------------------------
-- web service wrapper functions 
----------------------------------------------
--[[
Create an rpc wrapper function using closures. it will override existing one with identical name. 
@param fullName: by which name we name the RPC, it should contains at least one namespace. such as "LocalService.auth.AuthUser"
@param url: url of the RPC path, such as "http://auth.paraengine.com/AuthUser.asmx"
@param prepFunc: nil or an input message validation function (self, msg, id, callbackFunc, callbackParams, postMsgTranslator) end 
 the function is called before making the RPC call to validate the input msg and preconditions. e.g. If user is not logged in, it will open a login window for user authentication. 
 the function should return nil if should continue with web service call, otherwise either true or a LocalService.errorcode is returned. If there is an error in preprocessing, the user callback is not called. and the error code is returned immediately from the rpc wrapper function. 
 One can create custom preprocessorFunc for each RPC wrapper, or use one of the predefined processor. 
 Another usage of prepFunc is that it can secretly translate input message to whatever the remote format message is. 
@param postFunc: nil or an output message validation function (self, msg, id) end 
 the function is called after the RPC returns to validate the output msg and then send the result to the user callback. e.g. It may report and handle certain common error, such as sesssion key expirations, etc. 
 the function should return nil if successful, otherwise a LocalService.errorcode is returned.  whether there is error or not the user callback is always called. 
@param preMsgTranslator: preprocessing msg input when activate is called. 
@param postMsgTranslator: postprocessing msg output when callback is called. 
@param requestPoolName: each request is made with a connection pool. And if the connections exceeds the pool size, they will have to wait in a queue. 
	if nil, it is "r"(REST), which has maximum of 5 connections. "d"(download) has 2 connections, "w"(web) has 5, and any other other has 1 connection by default. 
@Note by LiXizhi: all resource of the rpc is kept in a closure and there is only one global table "fullname" created.  I overwrite the table's __call method to make it callable with ease. 
 -- For example: after calling 
	 LocalService.CreateRPCWrapper("LocalService.auth.AuthUser", "http://auth.paraengine.com/AuthUser.asmx");
 -- we can call the rpc via wrapper LocalService.auth.AuthUser like this
     LocalService.auth.AuthUser({username="", Password=""}, "test", function (msg, params)  log(commonlib.serialize(msg)) end, "ABC");
 -- The above call is identical to 
     LocalService.auth.AuthUser:activate(...);
 -- The url of the web service can be get/set via 
     local url = LocalService.auth.AuthUser.GetUrl() 
     LocalService.auth.AuthUser.SetUrl("anything here")
 -- tostring() can also be used like this
	 log(tostring(LocalService.auth.AuthUser).."\n")
	 
@example code: see "script/kids/3DMapSystemApp/API/test/LocalService.auth.test.lua"
]]
function LocalService.CreateRPCWrapper(fullname, proto, API_key, prepFunc, postFunc, preMsgTranslator, postMsgTranslator, requestPoolName)
	local api_key = API_key;
	local activateCount;
	-- closures: fullname, url, namespace, rpcName
	local namespace = string.gsub(fullname, "%.%w+$", "");
	local _,_, rpcName = string.find(fullname, "%.(%w+)$");
	-- a table of callback pool of {id, callback} pairs
	local pool = nil;
	
	local o = commonlib.getfield(fullname);
	if(o ~= nil) then 
		-- return if we already created it before.
		LOG.std(nil, "error", "RPC", "RPC "..fullname.." is overriden by LocalService.CreateRPCWrapper\n Remove duplicate calls with the same name.");
	end
	
	-- add a new call back for a given RPC
	-- @param id, callbackFunc, callbackParams: are the same as defined in each RPC wrapper. 
	-- @return: it will return true if succeed. or LocalService.errorcode.RepeatCall
	local function AddCallback(id, callbackFunc, callbackParams, inputMsg, originalMsg)
		if(pool == nil) then
			-- create the pool if not exist. 
			pool = {};
		end
		if(id == nil) then
			id = "nil";
		end
		local callback = pool[id];
		if(callback == nil) then
			-- create the callback entity if not exist. 
			callback = {callbackFunc = callbackFunc, callbackParams=callbackParams, inputMsg = inputMsg, originalMsg = originalMsg};
			pool[id] = callback;
			return true;
		else
			if(callback.IsRemoved or id=="nil") then
				callback.callbackFunc = callbackFunc;
				callback.callbackParams = callbackParams;
				callback.inputMsg = inputMsg;
				callback.originalMsg = originalMsg;
				callback.IsRemoved = false;
				return true;
			else
				return LocalService.errorcode.RepeatCall;
			end
		end
	end

	-- return the callback {callbackFunc, callbackParams}. Otherwise return nil. 
	local function GetCallback(id)
		if(pool~=nil) then
			local callback = pool[id or "nil"];
			return callback;
--			if(callback ~= nil and not (callback.IsRemoved)) then
--				return callback;
--			end
		end
	end

	-- remove a rpc call back. when an RPC returns it should call this to remove from the waiting pool so that the same function can be called again. 
	local function RemoveCallback(id)
		if(pool~=nil) then
			local callback = pool[id or "nil"];
			if(callback ~= nil) then
				callback.IsRemoved = true;
				callback.inputMsg = nil;
				callback.originalMsg = nil;
			end	
		end
	end

	local function ParseRawDataFromProtoMsg(msg)
		local ret = {};
		local field, value;
		for field, value in msg:ListFields() do
			if(type(value) == "table") then
				if(#value > 0) then
					-- repeated fields
					if(field.type == 11) then
						local list = {};
						local _, node;
						for _, node in ipairs(value) do
							table.insert(list, ParseRawDataFromProtoMsg(node));
						end
						ret[field.name] = list;
					else
						local list = {};
						local _, node;
						for _, node in ipairs(value) do
							table.insert(list, node);
						end
						ret[field.name] = list;
					end
				else
					-- field block
					local block = {};
					local f2, v2;
					for f2, v2 in value:ListFields() do
						if(type(v2) ~= "table") then
							block[f2.name] = v2;
						end
					end
					ret[field.name] = block;
				end
			else
				ret[field.name] = value;
			end
		end
		return ret;
	end
	
	-- handle callback
	--@param API_key: format is "***_Response"
	local function HandleCallback(id, API_key, data)
		local rsp = proto[API_key]();
		rsp:ParseFromString(data)
		-- create a raw data table as returned message
		local raw_rsp = ParseRawDataFromProtoMsg(rsp);
		local callback = GetCallback(id);
		if(callback ~= nil) then
			callback.IsRemoved = true;
			if(callback.callbackFunc ~= nil) then
				local raw_msg = raw_rsp;
				if(postMsgTranslator) then
					raw_rsp = postMsgTranslator(raw_rsp, url);
				end
				if(postFunc ~= nil) then
					local newMsg = postFunc(o, raw_rsp, id, callback.callbackFunc, callback.callbackParams, postMsgTranslator, raw_msg, callback.inputMsg, callback.originalMsg);
					if(newMsg) then
						raw_rsp = newMsg;
					end
				end
				
				callback.callbackFunc(raw_rsp, callback.callbackParams);
			end
		end

	end
	
	---------------------------------------
	-- the callback function after the RPC returns. 
	---------------------------------------
	local function callbackFunc(id)
		local callback = GetCallback(id);
		if(callback ~= nil) then
			callback.IsRemoved = true;
			if(callback.callbackFunc~=nil) then
				if(msg == nil or msg.code~=0 or msg.rcode~=200) then
					LOG.std(nil, "error","RPC", fullname.." returns an error CURLCode\n"..LOG.tostring(msg));
				end
				
				local raw_msg = msg;
				if(postMsgTranslator) then
					msg = postMsgTranslator(msg, url);
				end
				if(postFunc~=nil) then
					local newMsg = postFunc(o, msg, id, callback.callbackFunc, callback.callbackParams, postMsgTranslator, raw_msg, callback.inputMsg, callback.originalMsg);
					if(newMsg) then
						msg = newMsg;
					end
				end
				
				callback.callbackFunc(msg, callback.callbackParams);
			end
		end
	end
	
	---------------------------------------
	-- the activation function that calls the remote RPC
	---------------------------------------
	local function activate(self, msg, id, callbackFunc, callbackParams)
		msg = msg or {};
		local originalMsg = commonlib.deepcopy(msg);
		if(preMsgTranslator) then
			msg = preMsgTranslator(msg);
		end
		if(not activateCount) then
			activateCount = 0;
			-- this allows use to parse url replaceables only when it is used. 
			url = LocalService.TranslateURL(url);
		end
		activateCount = activateCount + 1;
		local res;
		if(prepFunc~=nil) then
			res = prepFunc(self, msg, id, callbackFunc, callbackParams, postMsgTranslator);
		end
		if(res == nil) then
			if(type(id) == "function") then
				LOG.std(nil, "error","RPC", url.." should be called with a string id. Have you missed it?");
			end
			res = AddCallback(id, callbackFunc, callbackParams, msg, originalMsg);
			if(res==true) then

				local basic_pb = proto
				local api_Req = basic_pb[API_key.."_Request"]();
				local msg_k, msg_v;
				for msg_k, msg_v in pairs(msg) do
					if(type(msg_v) == "table") then
						local _, v;
						for _, v in ipairs(msg_v) do
							api_Req[msg_k]:append(v);
						end
					else
						api_Req[msg_k] = msg_v;
					end
				end

				local iostring = pb.new_iostring()
				api_Req:SerializeToIOString(iostring)
				local cmdname = getmetatable(api_Req)._descriptor["name"]
				if(LocalBridge and LocalBridge.call) then
					LocalBridge.call(API_key, iostring)
				end

				if(not HasRegisterHandleCallBacks[API_key.."_Response"]) then
					HasRegisterHandleCallBacks[API_key.."_Response"] = function(key,value)
						HandleCallback(id,key,value);
					end
				end
			end
		end
		return res;
	end
	
	-- expose RPC class via global environment.   	
	o = setmetatable({
		GetUrl = function() return url end,
		SetUrl = function(new_url) 
				url = LocalService.TranslateURL(new_url)
			end,
		activate = activate,
		callbackFunc = callbackFunc,
	}, {
		__call = activate,
		__tostring = function(self)
			return fullname..": (" ..url..")";
		end
	});
	commonlib.setfield(fullname, o);
end


---------------------------------------------------------
-- helper functions
---------------------------------------------------------

-- translate url
function LocalService.TranslateURL(url)
	return url;
end
local function activate()
	local msg = msg;
	
	if(not msg)then
		return
	end
	local key = msg.key;
	local size = msg.size;
	local value = msg.value;
	if(key == "deviceOnKeyDown")then
		commonlib.echo("===========deviceOnKeyDown");
		commonlib.echo(msg);
	end
	if(HasRegisterHandleCallBacks[key])then
		local callback = HasRegisterHandleCallBacks[key];
		callback(key,value);
	end
end
NPL.this(activate);
