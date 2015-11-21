--[[
Title: NPL page handler 
Author: LiXizhi
Date: 2015/6/9
Desc: server side hyper text preprocessor with embedded NPL script, very similar to what PHP does. 

<verbatim>
	<html>
		<head>
			<title>Example</title>
		</head>
		<body>

			<?npl
				echo "Hi, I'm a NPL script!";
			?>

		</body>
	</html>
</verbatim>

Instead of lots of commands to output HTML (as seen in C or Perl), NPL pages contain HTML with embedded code 
that does "something" (in this case, output "Hi, I'm a NPL script!"). The NPL code is enclosed 
in special start and end processing instructions <?npl and ?> that allow you to jump into and out of "NPL script mode." 

Reference: 
	php.net/manual/en/language.basic-syntax.phpmode.php

-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/npl_page_handler.lua");
local my_handler = WebServer.npl_page_handler({root_dir="web/web_root"})
-----------------------------------------------
]]
NPL.load("(gl)script/apps/WebServer/npl_common_handlers.lua");
NPL.load("(gl)script/apps/WebServer/npl_page_env.lua");
local npl_page_env = commonlib.gettable("WebServer.npl_page_env");
local common_handlers = commonlib.gettable("WebServer.common_handlers");

if(not WebServer) then  WebServer = {} end

-- server page handler
local function npl_page_handler(req, res, root_dir, page_manager)
	local filename = common_handlers.GetValidFileName(root_dir, req.relpath);
	if(filename) then
		local page = page_manager:get(filename);
		if(page) then
			if(not page:get_error_msg()) then
				-- uncomment to show merged script
				-- res:send(page.script);  
				res:add_header()
				page:run(npl_page_env:new(req, res));
			else
				res:send(format("error parse file %s: %s", req.cmd_url, page:get_error_msg() or ""));	
			end
		else
			res:send(format("can not parse file %s", req.cmd_url));
		end
	else
		common_handlers.err_404(req, res);	
	end
end

-- public: file handler maker. it returns a handler that serves files in the baseDir dir
-- @param params: string or {docroot, }the directory from which to serve files. 
function WebServer.npl_page_handler(params)
	local docroot="";
	if type(params) == "string" then 
		docroot = params;
	elseif type(params) == "table" then 
		docroot = params.docroot;
	end
	NPL.load("(gl)script/apps/WebServer/npl_page_manager.lua");
	local npl_page_manager = commonlib.gettable("WebServer.npl_page_manager");
	local page_manager = npl_page_manager:new();
	page_manager:monitor_directory(docroot);
	
	return function(req, res)
		return npl_page_handler(req, res, docroot, page_manager)
	end
end
