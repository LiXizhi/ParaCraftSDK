--[[
Title: All registered attribute classes
Author(s): LiXizhi, 
Date: 2015/8/22
Desc: All toolbase derived class are automatically registered. 
To view all registered classes: see System.Core.Classes in object browser in NPL code wiki.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/Classes.lua");
local Classes = commonlib.gettable("System.Core.Classes");
Classes:Add(class_def);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/ide/System/Core/AttributeObject.lua");
local Classes = commonlib.gettable("System.Core.Classes");
commonlib.add_interface(Classes, commonlib.gettable("System.Core.AttributeObject"))

local all_classes = commonlib.UnorderedArraySet:new();

function Classes:GetChildCount(nColumnIndex)
	return #all_classes;
end

function Classes:GetChildAt(nRowIndex, nColumnIndex)
	local class = all_classes[nRowIndex+1];
	if(class) then
		return class:GetAttributeObject();
	end
end

function Classes:Add(class_def)
	all_classes:add(class_def);
end

