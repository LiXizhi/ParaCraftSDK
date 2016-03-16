--[[
Title: NPL extension
Author(s): LiXizhi
Date: 2006/11/11
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/NPLExtension.lua");
local url = "http://paraengine.com/getfriends.asmx"
NPL.AddCookieVariable(url, "session_key", "ABCDEFG")
NPL.AddCookieVariable(url, "user_id", "1234")
NPL.CallWebservice(url, {op="get"})
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
NPL.load("(gl)script/ide/Debugger/NPLCompiler.lua");

if(not NPL) then NPL={}; end

-- @param returnCode: default to 0
function exit(returnCode)
	ParaGlobal.Exit(returnCode or 0);
end

if(luaopen_cURL) then
	-- open cURL();
	luaopen_cURL();
	NPL.curl= cURL;
end

-- return the content of a given url. 
-- e.g.  echo(NPL.GetURL("www.paraengine.com"))
-- @param url: a REST like url. 
-- @param callbackFunc: a function(msg:{headers, code, rcode==200}) end, 
--  if nil, the function will not return until result is returned(sync call).
-- @return: return nil if callbackFunc is a function. or the string content in sync call. 
function NPL.GetURL(url, callbackFunc, option)
	NPL.load("(gl)script/ide/System/os/GetUrl.lua");
	return System.os.GetUrl(url, callbackFunc, option);
end

-- this function just repeatedly calls NPL.activate() until either the message is successfully sent out or timeout_seconds is reached. 
-- Internally, it will wait 0.1, 0.2, 0.4, 0.8, ... between unsuccessfull activation.
-- @param timeout_seconds: the number of seconds to wait. if 0, it will only try once.
-- @return the last NPL.activate call result
function NPL.activate_with_timeout(timeout_seconds, ...)
	local time_left = timeout_seconds;
	local time_interval = 0.1;
	local res;
	while ( true ) do
		res = NPL.activate(...);
		
		if(res ~= 0 and time_left > 0) then
			ParaEngine.Sleep(time_interval);
		else
			break;	
		end
		time_left = time_left - time_interval;
		time_interval = time_interval * 2;
	end
	return res;
end

-- This function is same as NPL.activate() except that if it failed. It will start a timer and send the message again and again until timeout_seconds passed. 
-- this function just repeatedly calls NPL.activate() until either the message is successfully sent out or timeout_seconds is reached. 
-- Internally, it will wait 0.1, 0.2, 0.4, 0.8, ... between unsuccessfull activation.
-- @param timeout_seconds: the number of seconds to wait. if 0, it will only try once.
-- @return the last NPL.activate call result
function NPL.activate_async_with_timeout(timeout_seconds, filename, msg)
	local res = NPL.activate(filename, msg);
	if(res ~= 0 and timeout_seconds > 0) then
		local time_left = timeout_seconds;
		local time_interval = 100;
		local timer = commonlib.Timer:new({callbackFunc = function(timer)
			local res = NPL.activate(filename, msg);
			if(res ~= 0) then
				if(time_left > 0) then
					time_left = time_left - time_interval*0.001;
					time_interval = time_interval * 2;
					timer:Change(time_interval, nil);
				else
					LOG.std(nil, "warn", "NPL", "NPL.activate_async_with_timeout unable to send message to %s, res is %d", filename, res);
				end
			end
		end})
		timer:Change(time_interval, nil);
	end
	return res;
end


-- it is mapping from domain URL to cookie table. 
--NPL.Domains={};

-- it is mapping from cookie name to cookie data. 
NPL.Cookies={};

NPL.Cookie={
	-- name, value pairs or tables. 
	Data = {},
	-- nil means never expires. 
	ExpireTime = nil,
};
-- reset all cookies for all urls to empty.
function NPL.ResetAllCookies()
	NPL.Cookies={};
end

-- set cookies for a given url. 
-- @param url: it is usually a web service or web page url string. 
-- @param cookies: it should be nil or a cookie table. Usually it is a table with 
--  {Data={user_id="GUID", session_key="GUID", app_key="GUID", counter=functor}, ExpireTime=nil }
--   counter will be supported later on, which will automatically increase by one or use the current system time in milliseconds. 
function NPL.SetCookie(url, cookie)
	NPL.Cookies[url] = cookie;
end

-- add a cookie variable to a given URL. 
-- @param url: it is usually a web service or web page url string. 
-- @param name: string such as "session_key", "user_id"
-- @param value: string or value
-- @param ExpireTime: can be nil or a value. It will only be set if ExpireTime is smaller than the current cookie's expire time. 
function NPL.AddCookieVariable(url, name, value, ExpireTime)
	local Cookie = NPL.Cookies[url];
	if(Cookie==nil) then
		-- new cookie
		Cookie = {
			ExpireTime = nil,
			Data = {},
		};
	end
	Cookie.Data[name] = value;
	if(ExpireTime~=nil and Cookie.ExpireTime>ExpireTime) then
		Cookie.ExpireTime = ExpireTime;
	end
end

-- get the cookies table by url. it may return nil if the cookie does not exist. 
function NPL.GetCookie(url)
	return NPL.Cookies[url];
end

-- if msg={user_id="GUID1", somefields="XXX"} and cookies={user_id="GUID2", session_key="GUID", app_key="GUID",}, the msg will become
-- {user_id="GUID1", somefields="XXX", session_key="GUID", app_key="GUID",} after this function returns. 
-- @param msg: in/out msg table. 
-- @param cookie: it can be nil, it is usually the cookies table returned from NPL.GetCookie(url)
function NPL.MergeCookieWithMsg(msg, cookie)
	if(msg~=nil and cookie~=nil and cookie.Data~=nil) then
		commonlib.mincopy(msg, cookie.Data);
	end	
end

--function NPL.ConvertCookieToHTTPPost(cookie)
--end

-- call a web service with data cookie support. One can bind a cookie object with a given URL. The cookie object will to copied to the msg data before sending
-- @param URL: url of the web service
-- @param msg: an NPL table to be sent. If there is a cookie object, it will be copied to data before sending. such as the user_id, session_id, app_key, counter, etc. 
function NPL.CallWebservice(URL, msg)
	NPL.MergeCookieWithMsg(msg, NPL.GetCookie(URL))
	NPL.activate(URL, msg);
end

-- retrieve the user name from the current packet's source name. return "" if no username is found.
function NPL.GetSrcUserName()
	local src = NPL.GetSourceName();
	local from, to = string.find(src, "@");
	if(from ~=nil and from>1) then
		local username = string.sub(src, 1, from-1);
		return username;
	end
	return "";
end

-- sync a file with a remote server
-- This function is very similar to NPL.AsyncDownload() except that FileUrl may contain CRC code
-- and that if will not perform the actual download if the DestFolder is a file with the right CRC
-- e.g.
-- NPL.SyncFile("http://www.kids3dmovie.com/uploads/LiXizhi/auto2.jpg?CRC32=507094163", "temp\\renamed.jpg", "DownloadCallback()", "test1");
-- @param FileUrl: it may be a URL that ends with ?CRC32=number, such as http://www.kids3dmovie.com/test.jpg?CRC32=1234
-- @param ScriptCallBack: a gobal variable called 
--        msg = {DownloadState=""|"complete"|"terminated", totalFileSize=number, currentFileSize=number, PercentDone=number} is the input. msg may be nil if any error occurs.
-- @return:  1 it is downloading; 2 downloading is done because a file already exist with the currect CRC32 code
function NPL.SyncFile(FileUrl, DestFolder, ScriptCallBack, DownloaderName)
	-- check if there is a CRC32
	local _,_, uri,crc= string.find(FileUrl, "(.*)%?CRC32=(%d+)");
	
	if(uri==nil) then uri = FileUrl end
	if(crc~=nil) then
		-- the FileURL contains a CRC32 code.
		local diskCRC = ParaIO.CRC32(DestFolder);
		if(tonumber(crc) == diskCRC) then
			-- CRC matches, we will simulate a complete event and quit
			msg = {
				DownloadState="complete", totalFileSize=-1, currentFileSize=0, PercentDone = 100
			};
			NPL.DoString(ScriptCallBack);
			return 2;
		else
			-- we will first download to the temp folder.It may resume from last download
			local filename = ParaIO.GetFileName(uri);
			if(filename~=nil and filename~="") then
				ParaIO.CreateDirectory("temp/tempdownloads/");
				filename = string.format("temp/tempdownloads/%s.%s.dat", filename, crc);
				NPL.AsyncDownload(uri, filename, string.format("NPL.SyncFileCallBack(%q, %q);%s", DestFolder, filename, ScriptCallBack), DownloaderName);
				return 1;
			end
		end
	else
		-- if FileUrl does not have crc code, we will download it again to a temp folder without resuming a previous download
		crc = 0;
		local filename = ParaIO.GetFileName(uri);
		if(filename~=nil and filename~="") then
			ParaIO.CreateDirectory("temp/tempdownloads/");
			filename = string.format("temp/tempdownloads/%s.%s.dat", filename, crc);
			-- delete any existing temp file to prevent resuming previous download
			ParaIO.DeleteFile(filename);
			NPL.AsyncDownload(uri, filename, string.format("NPL.SyncFileCallBack(%q, %q);%s", DestFolder, filename, ScriptCallBack), DownloaderName);
			return 1;
		end
	end
	NPL.AsyncDownload(uri, DestFolder, ScriptCallBack, DownloaderName);
	return 1;
end

-- all temp file due to NPL.SyncFile() is deleted. Perhaps, this function should be called once several weeks
function NPL.DeleteAllDownloadTempFiles()
	ParaIO.DeleteFile("temp/tempdownloads/*.*");
end

function NPL.SyncFileCallBack(DestFolder, tempfile)
	if(msg~=nil and msg.DownloadState=="complete") then
		ParaIO.CopyFile(tempfile, DestFolder, true);
		local alltempfiles = string.gsub(tempfile, "%.%d+%.dat$", ".*");
		ParaIO.DeleteFile(alltempfiles);
	end
end

-- HTTP post, 
--function NPL.CallHTTP(URL, msg)
--end

-- this is same as NPL.load, except that it only load local script file without the "(gl)" prefix. 
-- and it will check the file existence in both source folder and bin folder before loading the file. 
-- if file is not found in the first place, NPL.load() is not called at all. and the function will return nil. 
-- @return : true if loaded. 
function NPL.CheckLoad(filename)
	if(NPL.DoesScriptFileExist(filename)) then
		NPL.load("(gl)"..filename);
		return true;
	end
end

-- if a given script or other file exist. it will also check precompiled file
function NPL.DoesFileExist(filename)
	return (ParaIO.DoesFileExist(filename, true) or ParaIO.DoesFileExist("bin/"..string.gsub(filename, "lua$", "o"), true) )
end


-- load public NPL file to id map from XML file. 
-- @param filename: if nil, it defaults to config/NPLPublicFiles.xml
function NPL.LoadPublicFilesFromXML(filename)
	filename = filename or "config/NPLPublicFiles.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		commonlib.log("warning: failed loading NPL public files %s\n", filename);
		return;
	end	
	
	-- add all NPL public files
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "/NPL/PublicFiles/file") do
		if(node.attr and node.attr.path and node.attr.id) then
			NPL.AddPublicFile(node.attr.path, tonumber(node.attr.id));
--			commonlib.log("warning: path = %s, id=%s\n", node.attr.path, node.attr.id);
		end	
	end
end
