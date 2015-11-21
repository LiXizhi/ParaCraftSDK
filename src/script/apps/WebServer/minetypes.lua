--[[
Title: minetypes
Author: LiXizhi
Date: 2015/6/12
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/minetypes.lua");
local minetypes = commonlib.gettable("WebServer.minetypes");
minetypes:guess_type("*.html");
-----------------------------------------------
]]

local minetypes = commonlib.gettable("WebServer.minetypes");

minetypes.types_map = {
	["html"] = "text/html",
	["htm"] = "text/html",
	["page"] = "text/html",
	["lua"] = "text/html",
};

-- gets the mimetype from the filename's extension
-- @param path: filepath 
function minetypes:guess_type(path, bStrict)
	local extension = string.match (path, "%.([^.]*)$")
	if extension then
		return self.types_map[extension];
	else
		return nil
	end
end
