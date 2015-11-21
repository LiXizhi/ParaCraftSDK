--[[
Title: visibility group 
Author(s): LiXizhi
Date: 2006/5/29
Desc: There are two types of visibility groups.
	(1) VizGroup: objects in the group share the same visibility. 
	(2) MutexVizGroup: objects in the group are mutually exclusive. only one UI object in the group can be shown at a time. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/visibilityGroup.lua");
CommonCtrl.VizGroup.AddToGroup("group1", "UIObjectName");
CommonCtrl.VizGroup.Show("group1", true, "UIObjectName");
-------------------------------------------------------
]]
--[[common control library]]
if(not CommonCtrl) then CommonCtrl={}; end

-- default member attributes
local VizGroup = { groups={} }
CommonCtrl.VizGroup = VizGroup;

--[[
@param sGroupName: group name
@param sUIObjectName: name of the ui object, which will be added to the group.
]]
function VizGroup.AddToGroup(sGroupName, sUIObjectName)
	local group = VizGroup.groups[sGroupName];
	if(not group) then
		group = {};
		VizGroup.groups[sGroupName] = group;
	end
	group[sUIObjectName] = sUIObjectName;
end

--[[
@param sGroupName: group name
@param sUIObjectName: the ui object will be removed.
]]
function VizGroup.RemoveFromGroup(sGroupName, sUIObjectName)
	local group = VizGroup.groups[sGroupName];
	if(group~=nil) then
		groupp[sUIObjectName] = nil;
	end
end

--clear a given group
function VizGroup.ClearGroup(sGroupName)
	VizGroup.groups[sGroupName] = nil;
end

--[[
@param sGroupName: group name
@param bVisible: boolean: show or hide
@param sUIObjectName: the object to set. if this is nil, set the visibility of all objects in the group.
	if this is not nil, all other objects in the group will be set to invisible,except for this one.
]]
function VizGroup.Show(sGroupName, bVisible, sUIObjectName)
	local group = VizGroup.groups[sGroupName];
	if(not group) then	return	end
	if(not sUIObjectName) then
		-- set all objects
		for sUIObjectName in pairs(group) do
			local temp = ParaUI.GetUIObject(sUIObjectName);
			if (temp:IsValid() == true) then
				temp.visible = bVisible;
			end
		end
	else
		local name;
		for name in pairs(group) do
			local temp = ParaUI.GetUIObject(name);
			if (temp:IsValid() == true) then
				temp.visible = false;
			end
		end
		local temp = ParaUI.GetUIObject(sUIObjectName);
		if (temp:IsValid() == true) then
			temp.visible = bVisible;
		end
	end
end