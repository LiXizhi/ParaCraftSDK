--[[
Title: utility functions
Author: LiXizhi
Date: 2015/6/9
Desc: 
reference: some code from wsapi_util.lua in Xavante
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/npl_util.lua");
local util = commonlib.gettable("WebServer.util");
-----------------------------------------------
]]

local util = commonlib.gettable("WebServer.util");

-- Decode an URL-encoded string (see RFC 2396)
function util.url_decode(str)
	if not str then return nil end
	str = string.gsub (str, "+", " ")
	str = string.gsub (str, "%%(%x%x)", function(h) return string.char(tonumber(h,16)) end)
	str = string.gsub (str, "\r\n", "\n")
	return str
end

-- URL-encode a string (see RFC 2396)
function util.url_encode(str)
	if not str then return nil end
	str = string.gsub (str, "\n", "\r\n")
	str = string.gsub (str, "([^%w ])",
		function (c) return string.format ("%%%02X", string.byte(c)) end)
	str = string.gsub (str, " ", "+")
	return str
end

-- Sanitizes all HTML tags
function util.sanitize(text)
	return text:gsub(">", "&gt;"):gsub("<", "&lt;")
end

-- Checks whether s is not nil or the empty string
function util.not_empty(s)
	if s and s ~= "" then return s else return nil end
end


-- Merge user defined arguments into defaults array.
-- @param args : string or array.  Value to merge with $defaults
-- @param defaults: Optional. Array that serves as the defaults. Default empty.
-- @return array Merged user defined values with defaults.
function util.parse_args( args, defaults)
	local r;
	if ( type(args) == "table" ) then
		r = args;
	elseif ( type(args) == "string" ) then
		r = util.parse_str( args, r );
	end
	if (type(defaults) == "table") then
		commonlib.partialcopy(r, defaults);
	end
	return r;
end

-- Encodes a string into its escaped hexadecimal representation
-- @param s:  binary string to be encoded
-- @return escaped representation of string binary
function util.escape(s)
    return string.gsub(s, "([^A-Za-z0-9_])", function(c)
        return string.format("%%%02x", string.byte(c))
    end)
end

-- Encodes a string into its escaped hexadecimal representation
-- @param s: binary string to be encoded
-- @return escaped representation of string binary
function util.unescape(s)
    return string.gsub(s, "%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end

-- Parses a string into variables to be stored in an array.
-- @param str: as if url query string such as "a=1&b&c=3"
-- @return the url params table returned. 
function util.parse_str(str, params)
	params = params or {};
	for param in string.gmatch (str, "([^&]+)") do
		local k,v = string.match (param, "(.*)=(.*)")
		if(k) then
			k = util.url_decode (k)
			v = util.url_decode (v)
		else
			k, v = param, "";
		end
		if k ~= nil then
			if params[k] == nil then
				params[k] = v
			elseif type (params[k]) == "table" then
				table.insert (params[k], v)
			else
				params[k] = {params[k], v}
			end
		end
	end
	return params;
end