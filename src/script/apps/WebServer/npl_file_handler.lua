--[[
Title: file handler
Author: LiXizhi
Date: 2015/6/8
Desc: disk file is served first, then files in zip/pkg. 
Please note: it may be inefficient to serve chunks of file in zip archives, since the whole file 
is read/unzipped into memory each time a request is processed.
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/npl_file_handler.lua");
-- WebServer.filehandler
-----------------------------------------------
]]
NPL.load("(gl)script/ide/Files.lua");
NPL.load("(gl)script/ide/socket/url.lua");
NPL.load("(gl)script/apps/WebServer/minetypes.lua");
local minetypes = commonlib.gettable("WebServer.minetypes");
local url = commonlib.gettable("commonlib.socket.url")
local lfs = commonlib.Files.GetLuaFileSystem();

if(not WebServer) then  WebServer = {} end

-----------------------------------------------------------------------------
-- NPL File handler
----------------------------------------------------------------------------

WebServer.encodings = WebServer.encodings or {}



-- gets the encoding from the filename's extension
local function encodingfrompath (path)
	local _,_,exten = string.find (path, "%.([^.]*)$")
	if exten then
		return WebServer.encodings [exten]
	else
		return nil
	end
end

-- on partial requests seeks the file to
-- the start of the requested range and returns
-- the number of bytes requested.
-- on full requests returns nil
local function getrange (req, f)
	local range = req.headers["range"]
	if not range then return nil end
	
	local s,e, r_A, r_B = string.find (range, "(%d*)%s*-%s*(%d*)")
	if s and e then
		r_A = tonumber (r_A)
		r_B = tonumber (r_B)
		
		if r_A then
			f:seek ("set", r_A)
			if r_B then return r_B + 1 - r_A end
		else
			if r_B then f:seek ("end", - r_B) end
		end
	end
	
	return nil
end


-- sends data from the open file f
-- to the response object res
-- sends only numbytes, or until the end of f
-- if numbytes is nil
local function sendfile (f, res, numbytes)
	local block
	local whole = not numbytes
	local left = numbytes
	local blocksize = 8192
	
	if not whole then blocksize = math.min (blocksize, left) end
	
	while whole or left > 0 do
		block = f:read (blocksize)
		if not block then return end
		if not whole then
			left = left - string.len (block)
			blocksize = math.min (blocksize, left)
		end
		res:send_data (block)
	end
end

local function in_base(path)
  local l = 0
  if path:sub(1, 1) ~= "/" then path = "/" .. path end
  for dir in path:gmatch("/([^/]+)") do
    if dir == ".." then
      l = l - 1
    elseif dir ~= "." then
      l = l + 1
    end
    if l < 0 then return false end
  end
  return true
end

-- serve data from zip file. it may be inefficient to serve chunks of data, since the whole file 
-- is read into memory each time a request processed.
-- return true if served
local function filehandler_in_zip (path, req, res, baseDir)
	local file = ParaIO.open(path, "r");
	if(file:IsValid()) then
		local fileSize = file:GetFileSize();
		res.headers["Content-Length"] = fileSize;

		if req.cmd_mth == "GET" then
			local from = 0;
			local range_len;

			-- check if only range of data is requested.
			local range = req.headers["range"]
			if range then 
				local s,e, r_A, r_B = string.find (range, "(%d*)%s*-%s*(%d*)")
				if s and e then
					r_A = tonumber (r_A)
					r_B = tonumber (r_B)
					if r_A then
						from = r_A;
						if r_B then 
							range_len = r_B + 1 - r_A
						end
					else
						if r_B then 
							from = fileSize - r_B;
						end
					end
				end	
			end
			
			if range_len then
				res.statusline = "HTTP/1.1 206 Partial Content"
				res.headers["Content-Length"] = range_len
			end
			local data = file:GetText(from, range_len or -1);
			res:send_data (data);
		else
			res.content = ""
			res:send_headers();
		end

		file:close();
		return res;
	else
		LOG.std(nil, "warn", "npl_file_handler", "no file found: %s", path or "");
	end
end

-- main handler
local function filehandler (req, res, baseDir)
	if req.cmd_mth ~= "GET" and req.cmd_mth ~= "HEAD" then
		return WebServer.common_handlers.err_405 (req, res)
	end

	if not in_base(req.relpath) then
		return WebServer.common_handlers.err_403 (req, res)
	end

	local path;
	if(baseDir == "") then
		path = req.relpath:gsub("^/", "");
	else
		path = baseDir..req.relpath;
	end

	res.headers ["Content-Type"] = minetypes:guess_type(path);
	res.headers ["Content-Encoding"] = encodingfrompath (path)
    
	local attr = lfs.attributes (path)
	if not attr then
		if(not filehandler_in_zip(path, req, res, baseDir)) then
			return WebServer.common_handlers.err_404 (req, res)
		end
		return;
	end
	assert (type(attr) == "table")

	if attr.mode == "directory" then
		req.parsed_url.path = req.parsed_url.path .. "/"
		res.statusline = "HTTP/1.1 301 Moved Permanently"
		res.headers["Location"] = url.build (req.parsed_url)
		res.content = "redirect"
		return res
	end

	res.headers["Content-Length"] = attr.size
	
	local f = io.open (path, "rb")
	if not f then
		return WebServer.common_handlers.err_404 (req, res)
	end
	
	res.headers["last-modified"] = os.date ("!%a, %d %b %Y %H:%M:%S GMT",
					attr.modification)

	local lms = req.headers["if-modified-since"] or 0
	local lm = res.headers["last-modified"] or 1
	if lms == lm then
		res.headers["Content-Length"] = 0
		res.statusline = "HTTP/1.1 304 Not Modified"
		res.content = ""
        res.chunked = false
        res:send_headers()
        f:close()
		return res
	end

	
	if req.cmd_mth == "GET" then
		local range_len = getrange (req, f)
		if range_len then
			res.statusline = "HTTP/1.1 206 Partial Content"
			res.headers["Content-Length"] = range_len
		end
		
		sendfile (f, res, range_len)
	else
		res.content = ""
		res:send_headers ()
    end
    f:close ()
	return res
end

-- public: file handler maker. it returns a handler that serves files in the baseDir dir
-- @param baseDir: the directory from which to serve files. "%world%" is current world directory
-- @return the actual handler function(request, response) end
function WebServer.filehandler (baseDir)
	if type(baseDir) == "table" then 
		baseDir = baseDir.baseDir;
	end

	local bReplaceWorldDir;
	if(type(baseDir) == "string" and baseDir:match("^%%world%%")) then
		bReplaceWorldDir = true;
	end
	return function (req, res)
		local baseDir_ = baseDir;
		if(bReplaceWorldDir) then
			baseDir_ = baseDir_:gsub("^%%world%%", ParaWorld.GetWorldDirectory());
		end
		return filehandler (req, res, baseDir_)	
	end
end