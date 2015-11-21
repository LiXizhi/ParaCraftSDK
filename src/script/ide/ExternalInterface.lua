--[[
Title: IPCBinding with external shell
Author(s): Leio
Date: 2010/03/23
Desc: 
支持 lua <---> c# 数据类型相互转换
lua										 c#
string					<--->			 string
boolean					<--->			 bool
number					<--->			 Single or Double or int or uint
table (index,value)		<--->			 ArrayList
table (key,value)		<--->			 Hashtable
支持 lua <---> actionscript	数据类型相互转换
lua										 actionscript
string					<--->			 String
boolean					<--->			 Boolean
number					<--->			 Number
table (index,value)		<--->			 Array
table (key,value)		<--->			 Object
Use Lib:
-------------------------------------------------------
注意：
call 参数默认最多支持20个
如果table以数组形式传递，值不能为nil
--call c#
NPL.load("(gl)script/ide/ExternalInterface.lua");
ExternalInterface.Call("test","string",0,false,{ x = 0, y = 0, z = 0, name = "hello",show = false,},{1,false,"aa",{ x = 0, y = 0, z = 0, name = "hello",show = false,}});
--call flash
script/ide/NPLFlashTest/FlashDataTransitionTestPage.html
-------------------------------------------------------
--]]
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/ide/IPCBinding/Framework.lua");

local toolState = ParaEngine.GetAppCommandLineByParam("tools", "");
local cmdParams = ParaEngine.GetAppCommandLine();
LOG.std("", "system", "ExternalInterface", {"cmdParams",cmdParams,"toolState",toolState});

local ExternalInterface=commonlib.gettable("ExternalInterface");

function ExternalInterface.DoStart()
	local self = ExternalInterface;
	if(toolState ~= "true")then
		log("warning: there is no tool State\n")
		return;
	end
	
	local appID = ParaEngine.GetAppCommandLineByParam("toolsid", "toolsid");
	
	self.input_queue_name = "NPLTools"..appID;
	self.output_queue_name = "VsTools"..appID;
	
	self.input_queue = ParaIPC.CreateGetQueue(self.input_queue_name, 2);
	self.output_queue = ParaIPC.CreateGetQueue(self.output_queue_name, 2);
	
	LOG.std("", "system", "ExternalInterface", "IPC tools started in NPL state %s: queue name %s", __rts__:GetName() or "nil", self.input_queue_name);
	-- start timer to process the asynchrounous messages. 
	self.input_timer = self.input_timer or commonlib.Timer:new({callbackFunc = function(timer)
		local out_msg = {};
		if(self.input_queue)then
			while(self.input_queue:try_receive(out_msg) == 0) do
				local func_args = commonlib.deserialize_tonpl_function(out_msg.code);
				-- LOG.std("", "debug", "ExternalInterface", {"out_msg", out_msg, func_args})
				if(not func_args)then
					return
				end
				local funcName = func_args.funcName;--函数名称
				local args_result = func_args.args;--参数列表
				--判断funcName域是否存在
				if(not commonlib.getfield(funcName))then return end
				--转换成npl参数列表
				local args = "";
				if(args_result)then
					local k,arg;
					for k,arg in ipairs(args_result) do
						if(k == 1)then
							args = commonlib.serialize(arg)
						else
							args = args..","..commonlib.serialize(arg)
						end
					end
				end
				local sFunc = format("%s(%s)",funcName,args)
				-- LOG.std("", "debug", "ExternalInterface", "================sFunc: "..sFunc);
				
				-- do NPL function
				NPL.DoString(sFunc);
		
			end
		end
	end})
	self.input_timer:Change(0, 100);
end
--call c# function
function ExternalInterface.Call(functionName,...)
	local self = ExternalInterface;
	if(not functionName)then return end
	local args = {...};
	args.n = select('#', ...);
	
	local func_args = {
		funcName = functionName,
		args = args,
	};
	local toflash_function = commonlib.serialize_toflash_function(func_args);
	if(toflash_function)then
		if(self.output_queue)then
			-- LOG.std("", "debug", "ExternalInterface", {"========toflash_function", toflash_function});
			-- send a message to the queue
			self.output_queue:try_send({
				method = "ExternalInterface", -- string [optional] default to "NPL"
				from = "writer", 
				type = 11, -- number [optional] default to 0. 
				param1 = 12, -- number [optional] default to 0. 
				param2 = 13, -- number [optional] default to 0. 
				filename = "", -- string [optional] the file name 
				code = toflash_function, -- string or table [optional], if method is "NPL", code should be a pure table or nil.
				priority = 1, -- number [optional] default to 0. Message priority
			})
		end
	end
end
--call flash function
function ExternalInterface.CallFlash(flashControlIndex,functionName,...)
	local self = ExternalInterface;
	if(not flashControlIndex or not functionName)then return end
	local args = {...};
	args.n = select('#', ...);
	local func_args = {
		funcName = functionName,
		args = args,
	};
	commonlib.CallFlashFunction(flashControlIndex, func_args)
end
function ExternalInterface.TestDoFunction(...)
	commonlib.echo("=========ExternalInterface.TestDoFunction");
	commonlib.echo(arg);
end
function ExternalInterface.DoString(s)
	if(not s or type(s)~= "string")then return end
	NPL.DoString(s);
end