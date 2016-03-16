--[[
Title: fetch url
Author(s): LiXizhi
Date: 2016/1/25
Desc: helper class to get url content. It offers no progress function. 
For large files with progress, please use NPL.AsyncDownload. 
However, this function can be useful to get URL headers only for large HTTP files. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/os/GetUrl.lua");
-- get headers only with "-I" option. 
System.os.GetUrl("https://github.com/LiXizhi/HourOfCode/archive/master.zip", function(msg)  echo(msg) end, "-I");
System.os.GetUrl("https://github.com/LiXizhi/HourOfCode/archive/master.zip", echo);
------------------------------------------------------------
]]
local os = commonlib.gettable("System.os");

local npl_thread_name = __rts__:GetName();
if(npl_thread_name == "main") then
	npl_thread_name = "";
end

local function GetUrlSync(url)
	local c = cURL.easy_init()
	local result;
	-- setup url
	c:setopt_url(url)
	-- perform, invokes callbacks
	c:perform({writefunction = function(str) 
			if(result) then
				result = result..str;
			else
				result = str;
			end	
			end})
	return result;
end

----------------------------------------
-- url request 
----------------------------------------
local requests = {};
local Request = commonlib.inherit(nil, {});

local id = 0;

function Request:init(url, callbackFunc)
	id = (id + 1)%100;
	self.id = id;
	self.url = url;
	self.callbackFunc = callbackFunc;
	requests[self.id] = self;
	return self;
end

function Request:SetResponse(msg)
	self.response = msg;
end

function Request:InvokeCallback()
	if(self.response and self.callbackFunc) then
		self.callbackFunc(self.response);
	end
end

----------------------------------
-- os function
----------------------------------
function CallbackURLRequest__(id)
	local request = requests[id];
	if(request) then
		if(request.id == id) then
			request:SetResponse(msg);
			request:InvokeCallback();
		end
		requests[id] = nil;
	end
end

-- return the content of a given url. 
-- e.g.  echo(NPL.GetURL("www.paraengine.com"))
-- @param url: a REST like url. 
-- @param callbackFunc: a function(msg:{header, code, rcode==200}) end, 
--  if nil, the function will not return until result is returned(sync call).
-- @param option: mostly nil. "-I" for headers only
-- @return: return nil if callbackFunc is a function. or the string content in sync call. 
function os.GetUrl(url, callbackFunc, option)
	if(not callbackFunc) then
		-- NOT recommended
		return GetUrlSync(url);
	end
	if(option) then
		url = option.." "..url;
	end

	local req = Request:new():init(url, callbackFunc);

	-- async call. 
	NPL.AppendURLRequest(url, format("(%s)CallbackURLRequest__(%d)", npl_thread_name, req.id), nil, "r");
end