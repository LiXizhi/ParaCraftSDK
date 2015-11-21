--[[
Title: Object Path
Author(s): LiXizhi, 
Date: 2015/6/27
Desc: Every object either in the local level C++ engine, or created by NPL script 
can have a global unique path and a unified and type safe data interface. 

Like the document object model (DOM) of html, we can create any hierachy of object nodes. 
i.e. an object may be child of one node in DOM1, and child of another node in DOM2. 

Object Path is a class to assign and represent a unique object in a DOM of arbitrary situtations. 

Path syntax:
	/[DOM path]/[ index | rows,cols | @name=field_name ]/[ child_index | @index=index_value ]/...

Buildin DOM path:
	/scene				DOM of the C++ scene object. 
	/all				DOM of the C++ paraengine object (contains everything). 
	/gui				DOM of the C++ gui root object. 
	/asset				DOM of the C++ asset object. 
	/viewport			DOM of the C++ viewport object. 
	/player				DOM of the C++ current focused player object. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/ObjectPath.lua");
local ObjectPath = commonlib.gettable("System.Core.ObjectPath")
local path = ObjectPath:new():init("/scene");
local data = path:data();
echo(path:GetChildPathStrings());
path:SetFieldStr(name, value);
echo(path:GetFieldStr(name));
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/DOM.lua");
NPL.load("(gl)script/ide/System/Util/CmdParser.lua");
local CmdParser = commonlib.gettable("System.Util.CmdParser");
local DOM = commonlib.gettable("System.Core.DOM")
local type = type;

local ObjectPath = commonlib.inherit(nil, commonlib.gettable("System.Core.ObjectPath"));

function ObjectPath:ctor()
end

-- @param path: string. 
-- @param parentPath: the parent path object or nil. 
-- parent path can be automatically computed, however explicitly specify parentPath will make GetData() faster. 
-- thus especially useful when dealing with large number of child paths.
function ObjectPath:init(path, parentPath)
	self.path = path;
	self.is_root = path:match("^(/[^/]+)$") ~= nil;
	self.parent = parentPath;
	return self;
end

-- fetch the data model according to current path
-- calling this multiple times will return the cached result. 
-- @note: the returned data may be NPL script object or C++ AttributeObject interface. 
-- @return attribute data object or false if not found
function ObjectPath:data()
	local data = self.m_data;
	if(data~=nil) then
		return data;
	end
	if(self:IsRoot()) then
		data = DOM.GetDOMByPath(self);
	else
		local parent = self:GetParent();
		if(parent) then
			local parent_data = parent:GetData();
			if(parent_data) then
				local rel_path = self:GetLocalPathString();
				if(rel_path:match("^%d+")) then
					local rows, cols = rel_path:match("^(%d+)%D+(%d+)")
					if(rows and cols) then
						rows, cols = tonumber(rows), tonumber(cols);
						if(parent_data.GetChildAt) then
							data = parent_data:GetChildAt(rows, cols);
						end
					else
						local index = tonumber(rel_path);
						if(index) then
							-- by index
							if(parent_data.GetChildAt) then
								data = parent_data:GetChildAt(index);
							end
						end
					end
				else
					local field_name, value = rel_path:match("^(%w+)=(.+)$");
					if(field_name == "name") then
						-- by name
						if(parent_data.GetChild) then
							data = parent_data:GetChild(value);
						end
					elseif(field_name == "id" or field_name == "index") then	
						-- by index
						local index = tonumber(value);
						if(parent_data.GetChildAt) then
							data = parent_data:GetChildAt(index);
						end
					end
				end
			end
		end
	end
	if(not data) then
		data = false;
	end
	self.m_data = data;
	return data;
end
-- shortcut alias: obsoleted
ObjectPath.GetData = ObjectPath.data;

-- return class name of the underlying object. 
function ObjectPath:className()
	local data = self:data();
	if(data) then
		return data:GetField("ClassName", "");
	end
end

-- get the relative to parent path
function ObjectPath:GetLocalPathString()
	return self.path:match("([^/]+)$");
end

-- Return a string representing the full path from the root of the dag to this object. 
function ObjectPath:fullPathName()
	return self.path;
end

function ObjectPath:GetPath()
	return self.path;
end

function ObjectPath:IsRoot()
	return self.is_root;
end

-- get the parent path object or false if already root.
-- it will cache previous result. 
-- return false, if already root. 
function ObjectPath:GetParent()
	if(self.parent==nil) then
		local parent_path = self.path:match("^(.+)/[^/]+$");
		if(not parent_path or parent_path == "" or parent_path == "/") then
			self.parent = false;
		else
			self.parent = ObjectPath:new():init(parent_path);
		end
	end
	return self.parent;
end

-- get the root path
function ObjectPath:GetRoot()
	if(self:IsRoot()) then
		return self;
	else
		local root_path = self.path:match("^(/[^/]+)");
		if(root_path) then
			return ObjectPath:new():init(root_path);
		else
			return self;
		end
	end
end

-- private:
function ObjectPath:append_allrows(data, cols, output)
	output = output or {};
	local nRowCount = data:GetChildCount(cols);
	if(nRowCount > 0) then
		for rows = 0, nRowCount-1  do
			local child = data:GetChildAt(rows, cols);
			if(child and child.IsValid and child:IsValid()) then
				local local_path;
				if(cols>=1) then
					local_path = format("%d_%d", rows, cols);
				else
					local_path = tostring(rows);
				end
				output[#output+1] = self.path.."/"..local_path;
			else
				LOG.std(nil, "warn", "ObjectPath", "invalid child at: %s/%d_%d", self.path, rows, cols);
			end
		end
	end
	return output;
end

-- get all child path strings in a array
-- @param output: if nil, a new table is created. 
-- @param bAccendingOrder: if true for accending column order. default to false.
-- @return array or nil, 
function ObjectPath:GetChildPathStrings(output, bAccendingOrder)
	local data = self:GetData();
	if(data) then
		local nColCount = data:GetColumnCount();
		if(bAccendingOrder) then
			for cols=0, nColCount-1 do
				output = self:append_allrows(data, cols, output);
			end
		else
			for cols=nColCount-1, 0,-1 do
				output = self:append_allrows(data, cols, output);
			end
		end
		return output;
	end
end

-- get child count on first column
-- @param nColumnIndex: default to 0.
function ObjectPath:GetChildCount(nColumnIndex)
	local data = self:GetData();
	if(data) then
		return data:GetChildCount(nColumnIndex or 0);
	end
	return 0;
end

-- if the represented object has any child nodes. 
function ObjectPath:HasChild()
	local data = self:GetData();
	if(data) then
		for i=0, data:GetColumnCount() do
			if(data:GetChildCount(i) > 0) then
				return true;
			end
		end
	end
end

-- get field as string
function ObjectPath:GetFieldStr(name)
	local data = self:GetData();
	if(data) then
		local nFieldIndex = data:GetFieldIndex(name);
		if(nFieldIndex>=0) then
			local value;
			local sType = data:GetFieldType(nFieldIndex);  
			local sSchematics = data:GetSchematicsType(nFieldIndex);
			if(sSchematics == ":dialog") then
				value = sSchematics;
			else
				value = commonlib.serialize_compact(data:GetField(name, {}));
			end
			return value;
		end
	end
end

local isNumberMap = {
	["int"] = true, ["float"] = true, ["double"] = true, ["DWORD"] = true, ["enum"] = true, 
}

-- @param value: string value, such as "10", "{1,2,3}"
function ObjectPath:SetFieldStr(name, value)
	local data = self:GetData();
	if(data) then
		local nFieldIndex = data:GetFieldIndex(name);
		if(nFieldIndex>=0) then
			local sType = data:GetFieldType(nFieldIndex);  
			local sSchematics = data:GetSchematicsType(nFieldIndex);
			if(isNumberMap[sType]) then
				value = tonumber(value);
				data:SetField(name, value);
			elseif(sType == "string") then
				if(type(value) == "string") then
					data:SetField(name, value);
				end
			elseif(sType == "vector3") then
				value = CmdParser.ParseNumberList(value);
				if(value and #value == 3) then
					data:SetField(name, value);
				end
			elseif(sType == "vector2") then
				value = CmdParser.ParseNumberList(value);
				if(value and #value == 2) then
					data:SetField(name, value);
				end
			elseif(sType == "bool") then
				data:SetField(name, value=="true" or value=="on" or value==true);
			elseif(sType == "void") then
				data:CallField(name);
			end
			return true
		end
	end
end