--[[
Title: NPL script handler 
Author: LiXizhi
Date: 2011-6-24
Desc: uses NPL scripts to generate dynamic response to http response. 
Disk files or files in main.pkg are supported. 
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/npl_script_handler.lua");
local my_handler = WebServer.npl_script_handler({root_dir="web/web_root"})
-----------------------------------------------
]]
if(not WebServer) then  WebServer = {} end

-- script handler
local function npl_script_handler(req, res, root_dir)
	
end

-- public: file handler maker. it returns a handler that serves files in the baseDir dir
-- @param params: string or {docroot, }the directory from which to serve files. 
function WebServer.npl_script_handler(params)
	local docroot="";
	if type(params) == "string" then 
		docroot = params;
	elseif type(params) == "table" then 
		docroot = params.docroot;
	end
	return WebServer.makeGenericHandler(docroot, {}, {})
end
