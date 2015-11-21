--[[
Title: Action
Author(s): LiXizhi, Referenced part of QAction interface in QT. 
Date: 2014/11/28
Desc: 
The Action class provides an abstract user interface action that can be inserted into tools.
In applications many common commands can be invoked via menus, toolbar buttons, and keyboard shortcuts. 
Since the user expects each command to be performed in the same way, regardless of the user interface used, 
it is useful to represent each command as an action.

Once a QAction has been created it should be added to the relevant menu and toolbar, 
then connected to the slot which will perform the action. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/Action.lua");
local Action = commonlib.gettable("System.Core.Action");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/ToolBase.lua");

local Action = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Core.Action"));

Action:Property("Name", "Action");
-- any data object this action is binded to. 
Action:Property("Data", nil);
-- This property holds whether the action is a checkable action.
-- A checkable action is one which has an on/off state. 
Action:Property("Checkable", false, "IsCheckable");
-- This property holds whether the action is checked.
-- Only checkable actions can be checked. 
Action:Property("Checked", false, "IsChecked", nil, "Changed");
-- This property holds whether the action is enabled.
-- Disabled actions cannot be chosen by the user. 
Action:Property("Enabled", true, "IsEnabled", nil, "Changed");
-- icon path
Action:Property("Icon", nil, nil, nil, "Changed");
-- text
Action:Property("Text", "", nil, nil, "Changed");
-- if no tooltip is specified, the action's text is used.
Action:Property("ToolTip", "", nil, nil, "Changed");
-- The status tip is displayed on all status bars provided by the action's top-level parent.
Action:Property("StatusTip", "", nil, nil, "Changed");
-- This property holds the action's primary shortcut key sequence.
Action:Property("Shortcut", nil, nil, nil, "Changed");
-- The default value is WindowShortcut.
Action:Property("ShortcutContext", nil, nil, nil, "Changed");
-- In some applications, it may make sense to have actions with icons in the toolbar, but not in menus. 
Action:Property("VisibleInMenu", true, nil, nil, "Changed");
-- This property can be set to indicate how the action should be prioritized in the user interface. 
Action:Property("Priority", 0);
-- This property holds whether the action can be seen (e.g. in menus and toolbars).
Action:Property("Visible", true, "IsVisible", nil, "Changed");
-- the containing action group will not change this action's enabled status;
Action:Property("forceDisabled", nil);
-- the containing action group will not change this action's visible status;
Action:Property("forceInvisible", nil);

Action:Signal("hovered");
Action:Signal("triggered");

function Action:ctor()
end

function Action:IsSeperator()
	return self.isSeperator;
end

function Action:SetSeperator(bIsSeperator)
	self.isSeperator = bIsSeperator;
end

-- Returns the menu contained by this action. Actions that contain menus can be used to 
-- create menu items with submenus, or inserted into toolbars to create buttons with popup menus.
function Action:GetMenu()
	return self.menu;
end

-- set submenu object. 
function Action:SetMenu(menu)
	self.menu = menu;
end

function Action:GetParent()
end

-- Sets this action group to group. The action will be automatically added to the group's list of actions.
function Action:SetActionGroup(group)
	if(group == self.group) then
        return;
	end

    if(self.group) then
        self.group:RemoveAction(self);
	end
    self.group = group;
    if(group) then
        group:AddAction(self);
	end
end

function Action:SetDisabled(b)
	self:SetEnabled(not b); 
end

function Action:Toggle()
	self:SetChecked(not self:IsChecked());
end

function Action:trigger()
	if(self:IsCheckable()) then
        -- the checked action of an exclusive group cannot be unchecked
        if (self:IsChecked() and (self.group and self.group:IsExclusive() and self.group:CheckedAction() == self)) then
            self:triggered(true);
            return;
        end
        self:SetChecked(not self:IsChecked());
    end
	self:triggered(self:IsChecked());
end
