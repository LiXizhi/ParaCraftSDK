--[[
Title: ActionGroup
Author(s): LiXizhi, Referenced part of QActionGroup interface in QT. 
Date: 2014/11/28
Desc: In some situations it is useful to group Action objects together, so that they are mutually exclusive. 
A QActionGroup emits an triggered() signal when one of its actions is chosen. 
Each action in an action group emits its triggered() signal as usual.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/ActionGroup.lua");
local ActionGroup = commonlib.gettable("System.Core.ActionGroup");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/ToolBase.lua");

local ActionGroup = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Core.ActionGroup"));

ActionGroup:Property("Name", "ActionGroup");
-- If exclusive is true, only one checkable action in the action group
-- can ever be active at any time. If the user chooses another
-- checkable action in the group, the one they chose becomes active and
-- the one that was active becomes inactive.
ActionGroup:Property("Exclusive", true, "IsExclusive");

ActionGroup:Signal("hovered", function(Action) end)
ActionGroup:Signal("triggered", function(Action) end)

function ActionGroup:ctor()
	self.actions = commonlib.OrderedArraySet:new();
end

function ActionGroup:SetDisabled(b)
	self:SetEnabled(not b);
end

function ActionGroup:SetEnabled(bEnabled)
	self.enabled = bEnabled;
	for i=1, self.actions:size() do
		local action = self.actions[i];
        if(not action.forceDisabled) then
            action.SetEnabled(bEnabled);
            action.forceDisabled = false;
        end
    end
end

function ActionGroup:SetVisible(bVisible)
	self.visible = bVisible;
	for i=1, self.actions:size() do
		local action = self.actions[i];
        if(not action.forceInvisible) then
            action.SetVisible(bVisible);
            action.forceInvisible = false;
        end
    end
end

-- Returns the currently checked action in the group, or nil if none  are checked.
function ActionGroup:CheckedAction()
    return self.current;
end

-- Adds the action to this group, and returns it.
-- Normally an action is added to a group by creating it with the
-- group as its parent, so this function is not usually used.
-- @param a: the Action object. 
function ActionGroup:AddAction(a)
    if(not self.actions:contains(a)) then
        self.actions:add(a);
        self.Connect(a, "triggered", self, self._actionTriggered);
        self.Connect(a, "changed", self, self._actionChanged);
        self.Connect(a, "hovered", self, self._actionHovered);
    end
	if(not a.forceDisabled) then
        a:SetEnabled(self.enabled);
        a.forceDisabled = false;
    end
    if(not a.forceInvisible) then
        a:SetVisible(self.visible);
        a.forceInvisible = false;
    end

    if(a:IsChecked()) then
        self.current = a;
	end
    local oldGroup = a.group;
    if(oldGroup ~= self) then
        if (oldGroup) then
            oldGroup:RemoveAction(a);
		end
        a.group = self;
    end
    return a;
end

-- Removes the action from this group. The action will have no parent as a result.
-- @sa: Action::SetActionGroup()
function ActionGroup:RemoveAction(action)
    if (self.actions:removeByValue(action)) then
        if (action == self.current) then
            self.current = nil;
		end
        self.Disconnect(action, "triggered", self, self._actionTriggered);
        self.Disconnect(action, "changed", self, self._actionChanged);
        self.Disconnect(action, "hovered", self, self._actionHovered);
        action.group = nil;
    end
end

-- Returns the list of this groups's actions. This may be empty.
function ActionGroup:actions()
    return self.actions;
end

function ActionGroup:_actionTriggered()
	local action = self:sender();
	if(action) then
		self:triggered(action);
	end
end

function ActionGroup:_actionHovered()
	local action = self:sender();
	if(action) then
		self:hovered(action);
	end
end

function ActionGroup:_actionChanged()
	local action = self:sender();
	if(action) then
		if(self:IsExclusive())  then
			if (action:IsChecked()) then
				if (action ~= self.current) then
					if(self.current) then
						self.current:SetChecked(false);
					end
					self.current = action;
				end
			elseif (action == self.current) then
				self.current = nil;
			end
		end
	end
end