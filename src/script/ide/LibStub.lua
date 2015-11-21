--[[
Title: LibStub is a simple versioning stub meant for use in Libraries
Author(s): LiXizhi, The code is based on  http://www.wowace.com/wiki/LibStub 
Date: 2008/5/9
Desc: LibStub is a simple versioning stub meant for use in Libraries
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/LibStub.lua");

local libName = "YOUR_LIB_NAME";
local libVersion = "1.0";
local YOUR_LIB_NAME = commonlib.LibStub:NewLibrary(libName, libVersion);

-- optionally expose via a global name
CommonCtrl.YOUR_LIB_NAME = YOUR_LIB_NAME; 
-------------------------------------------------------
]]

if(not commonlib) then commonlib={}; end

-- LibStub is a simple versioning stub meant for use in Libraries. 
commonlib.LibStub = commonlib.LibStub or {libs = {}, minors = {}};

-- commonlib.LibStub:NewLibrary(major, minor)
-- @param major (string) - the major version of the library
-- @param minor (number string or number) - the minor version of the library
-- @return nil if a newer or same version of the lib is already present
-- returns empty library object or old library object if upgrade is needed
function commonlib.LibStub:NewLibrary(major, minor)
	assert(type(major) == "string", "Bad argument #2 to `NewLibrary' (string expected)")
	minor = assert(tonumber(string.match(minor, "%d+")), "Minor version must either be a number or contain a number.")
	
	local oldminor = self.minors[major]
	if oldminor and oldminor >= minor then return nil end
	self.minors[major], self.libs[major] = minor, self.libs[major] or {}
	return self.libs[major], oldminor
end

-- commonlib.LibStub:GetLibrary(major, [silent])
-- @param major (string) - the major version of the library
-- @param silent (boolean) - if true, library is optional, silently return nil if its not found
-- throws an error if the library can not be found (except silent is set)
function commonlib.LibStub:GetLibrary(major, silent)
	if not self.libs[major] and not silent then
		error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
	end
	return self.libs[major], self.minors[major]
end

-- commonlib.LibStub:IterateLibraries()
-- @return an iterator for the currently registered libraries
function commonlib.LibStub:IterateLibraries() 
	return pairs(self.libs) 
end
setmetatable(commonlib.LibStub, { __call = commonlib.LibStub.GetLibrary })
