--[[
Title: LayoutItem base
Author(s): LiXizhi
Date: 2015/4/27
Desc: LayoutItem class provides an abstract item that a Layout manipulates.
Pure virtual functions are provided to return information about the layout including, 
	sizeHint(), minimumSize(), maximumSize() and expanding().

The layout's geometry can be set and retrieved with setGeometry() and geometry(), and 
its alignment with setAlignment() and alignment().

References: QLayoutItem in qt framework

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/LayoutItem.lua");
local LayoutItem = commonlib.gettable("System.Windows.LayoutItem");
------------------------------------------------------------
]]
local LayoutItem = commonlib.inherit(nil, commonlib.gettable("System.Windows.LayoutItem"));

LayoutItem.align = "_lt";

function LayoutItem:ctor()
end

function LayoutItem:sizeHint()
end

function LayoutItem:minimumSize()
end

function LayoutItem:maximumSize()
end

function LayoutItem:expandingDirections()
end

function LayoutItem:setGeometry(l, t, w, h)
end

function LayoutItem:geometry()
end

function LayoutItem:isEmpty()
	return true;
end

-- Invalidates any cached information in this layout item.
function LayoutItem:invalidate()
end

-- If this item is a UI element, it is returned as a UI element; otherwise nil is returned. 
function LayoutItem:widget()
end

--  If this item is a Layout, it is returned as a Layout; otherwise nil is returned. 
function LayoutItem:layout()
end

function LayoutItem:spacerItem()
end

function LayoutItem:alignment()
	return self.align;
end

function LayoutItem:setAlignment(alignment)
	self.align = alignment;
end
