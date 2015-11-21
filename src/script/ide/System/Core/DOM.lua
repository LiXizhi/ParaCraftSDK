--[[
Title: Document object model
Author(s): LiXizhi, 
Date: 2015/6/27
Desc: 
Buildin DOM path:
	/scene				DOM of the C++ scene object. 
	/all				DOM of the C++ paraengine object (contains everything). 
	/gui				DOM of the C++ gui root object. 
	/asset				DOM of the C++ asset object. 
	/viewport			DOM of the C++ viewport object. 
	/player				DOM of the C++ current focused player object. 

See also: ObjectPath.lua

Static functions: 
	DOM.GetDOM(name)
	DOM.GetDOMByPath(objectPath)
	DOM.AddDOM(name, dom)
	DOM.RemoveDOM(name)
	DOM.GetAllDOMNames()

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/DOM.lua");
local DOM = commonlib.gettable("System.Core.DOM")
------------------------------------------------------------
]]

local DOM = commonlib.inherit(nil, commonlib.gettable("System.Core.DOM"));

-- all registered global document object models.
local registered_doms = {};

function DOM:ctor()
end

-- static function.
-- get the root dom object 
function DOM.GetDOM(name)
	local dom = registered_doms[name];
	if(dom) then
		if(type(dom) == "function") then
			dom = dom();
		end
		return dom;
	end
	-- for dynamic doms in C++ game engine. 
	if(not name or name == "all") then
		dom = ParaEngine.GetAttributeObject();
	elseif(name == "scene") then
		dom = ParaScene.GetAttributeObject();
	elseif(name == "gui") then
		dom = ParaEngine.GetAttributeObject():GetChild("GUI");
	elseif(name == "asset") then	
		dom = ParaEngine.GetAttributeObject():GetChild("AssetManager");
	elseif(name == "viewport") then
		dom = ParaEngine.GetAttributeObject():GetChild("ViewportManager");
	elseif(name == "player") then
		dom = ParaScene.GetPlayer():GetAttributeObject();
	elseif(name == "npl") then
		dom = NPL.GetAttributeObject();
	elseif(name == "GLOBALS") then
		-- this could be slow and memory consuming.
		NPL.load("(gl)script/ide/System/Core/TableAttribute.lua");
		local TableAttribute = commonlib.gettable("System.Core.TableAttribute");
		dom = TableAttribute:create(_G);
	end
	return dom;
end

-- get the root dom object in the given path
-- @param objectPath: type of "System.Core.ObjectPath"
function DOM.GetDOMByPath(objectPath)
	if(objectPath) then
		local root = objectPath:GetRoot();
		if(root) then
			local name = root:fullPathName():gsub("^/", "")
			return DOM.GetDOM(name);
		end
	end
end

-- @param value: either the AttributeObject or a function that will return the attribute object. 
function DOM.AddDOM(name, value)
	registered_doms[name] = value;
end

function DOM.RemoveDOM(name)
	registered_doms[name] = nil;
end


-- get all builtin and registed doms names in a newly created table array. 
-- @return table array, such as {"scene", "gui", ...}
function DOM.GetAllDOMNames()
	local doms = {"all", "scene", "gui", "asset", "viewport", "player", "npl", "GLOBALS"};
	for name, _ in pairs(registered_doms) do
		doms[#doms+1] = name;
	end
	return doms;
end
