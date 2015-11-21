--[[
Title: Layout manager base
Author(s): LiXizhi
Date: 2015/4/27
Desc: The Layout class is the base class of geometry managers.
You need to subclass this class to provide your own lay out manager. 
Any UIElement derived classes can be associated with a layout manager for positioning its children. 

This is an abstract base class inherited by the concrete classes mcml.PageLayout, etc.

References: QLayout in qt framework

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/Layout.lua");
local Layout = commonlib.gettable("System.Windows.Layout");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/LayoutItem.lua");
local Event = commonlib.gettable("System.Core.Event");
local Application = commonlib.gettable("System.Windows.Application");
local Layout = commonlib.inherit(commonlib.gettable("System.Windows.LayoutItem"), commonlib.gettable("System.Windows.Layout"));

function Layout:ctor()
end

function Layout:layout()
    return self;
end

-- virtual: return the mcml page object if it is mcml PageLayout object. 
function Layout:GetPage()
end

-- virtual: redo the layout of top level layout manager. 
-- It returns true if the layout was redone.
function Layout:activate()
	if (not self.enabled or not self.parent) then
        return false;
	end
    if (not self.topLevel) then
        return self.parent:activate();
	end
    if (self.activated) then
        return false;
	end
	-- this could be top level widget or top level mcml Page object. 
	local topLevelWidget = self.parent;
	self:activateRecursiveHelper(self);
end

function Layout:activateRecursiveHelper(item)
	item:invalidate();
    local layout = item:layout();
    if (layout) then
        local i=0;
        while (true) do
			i = i + 1;
			local child = layout:itemAt(i);
            self:activateRecursiveHelper(child); 
		end
        layout.activated = true;
    end
end


function Layout:invalidate()
    self:update();
end

-- get parent widget
function Layout:GetParent()
	return self.parent;
end

-- Updates the layout for GetParent().
function Layout:update()
    local layout = self;
    while (layout and layout.activated) do
        layout.activated = false;
        if (layout.topLevel) then
            Application:postEvent(layout:GetParent(), Event:new_static("LayoutRequestEvent"));
            break;
        end
        layout = layout:GetParent();
    end
end

-- virtual function: widget event sent to the UI element. 
function Layout:widgetEvent(event)
	local type = event:GetType();
	if(type == "sizeEvent") then
		if (self.activated) then
			self:doResize(event:width(), event:height());
		else
			self:activate();
		end
	elseif(type == "LayoutRequestEvent") then
        if (self:GetParent() and self:GetParent():isVisible()) then
            self:activate();
		end
	end
end

-- virtual function: update layout according to the size
function Layout:doResize(width, height)
	
end

-- virtual: recursively update geometry
function Layout:setGeometry(left, top, width, height)
end

function Layout:itemAt(index)
end

function Layout:takeAt(index)
end

function Layout:indexOf(widget)
end

function Layout:count()
	return 0;
end
