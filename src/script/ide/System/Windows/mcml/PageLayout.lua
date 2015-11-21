--[[
Title: PageLayout
Author(s): LiXizhi
Date: 2015/4/27
Desc: the layout manager used by mcml Page.
Each mcml page has only one page layout manager attached to the root UIElement that the page is associated with. 
Unlike other Layout manager, the mcml page layout manager will use the PageElement as LayoutItem directly. 
Hence there is no need to create addition layoutitem object. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/PageLayout.lua");
local PageLayout = commonlib.gettable("System.Windows.mcml.PageLayout");
local layout = PageLayout:new();
local parentLayout = PageLayout:new():init(0,0,200,100);

-- clone child object
parentLayout:NewLine();
local myLayout = parentLayout:clone();
myLayout:SetUsedSize(0,0);

-- update parent
myLayout:NewLine();
local left, top = parentLayout:GetAvailablePos();
local width, height = myLayout:GetUsedSize();
width, height = width-left, height -top;
parentLayout:AddObject(width, height);
parentLayout:NewLine();
	
-- add full size
parentLayout:NewLine();
local left, top, width, height = parentLayout:GetPreferredRect();
parentLayout:AddObject(width-left, height-top);
parentLayout:NewLine();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/Layout.lua");
local PageLayout = commonlib.inherit(commonlib.gettable("System.Windows.Layout"), commonlib.createtable("System.Windows.mcml.PageLayout", {
	-- the next available renderable position 
	availableX = 0,
	availableY = 0,
	-- the next new line position
	newlineX = 0,
	newlineY = 0,
	-- the current preferred size of the container control. It may be enlarged by child controls. 
	width = 0,
	height = 0,
	-- the min region in the container control which is occupied by its child controls
	usedWidth = 0,
	usedHeight = 0,
}));

function PageLayout:ctor()
end

-- return a clone of this PageLayout object. 
-- in most cases, one also calls SetUsedSize(0,0) to make the copy useful for a child PageLayout. 
function PageLayout:clone()
	return self:new({
		availableX = self.availableX,
		availableY = self.availableY,
		newlineX = self.newlineX,
		newlineY = self.newlineY,
		width = self.width,
		height = self.height,
		usedWidth = self.usedWidth,
		usedHeight = self.usedHeight,
	});
end

-- initialize a top level layout manager for a given page object(parent).
function PageLayout:SetPage(page, uiElement)
	self.parent = uiElement;
	self.page = page;
	self.topLevel = true;
end

-- recalculate the layout according to current uiElement (Window)'s size
function PageLayout:activate()
	if (self.activated) then
        return false;
	end
	if(self.page and self.parent) then
		local pageElem = self.page:GetRoot();
		if(pageElem) then
			self:doResize(self.parent:width(), self.parent:height());
			self.activated = true;
		end
	end
end

function PageLayout:invalidate()
	self:reset(0,0,0,0);
    PageLayout._super.invalidate(self);
end

-- virtual function: 
function PageLayout:doResize(width, height)
	if(self.page) then
		local pageElem = self.page:GetRoot();
		if(pageElem) then
			if(width == 0 and height == 0) then
				-- skip layout, if size is not known yet. This can happen when we show a widow without specifying its size.  
			else
				if(self.width ~= width or self.height~=height) then
					self:reset(0, 0, width, height);
					pageElem:UpdateLayout(self, nil);
				end
			end
		end
	end
end

function PageLayout:init(left, top, width, height)
	self:reset(left, top, width, height);
	return self;
end

-- return the top level mcml page object. 
function PageLayout:GetPage()
	if(self.topLevel) then
		return self.page;
	elseif(self.parent) then
		return self.parent:GetPage();
	end
end

-- If this item is a UI element, it is returned as a UI element; otherwise nil is returned. 
function PageLayout:widget()
	return self.parent;
end

-- create a new PageLayout, that is the same size of the preferred size but left, top is 0,0;
function PageLayout:new_child()
	local o = PageLayout:new(o)
	local width, height = self:GetPreferredSize();
	o:reset(0, 0, width, height);
	return o;
end

-- reset with newline position (left, top) and container size (width and height). 
function PageLayout:reset(left, top, width, height)
	self.newlineX = left;
	self.newlineY = top;
	if(left<width) then
		self.width = width;
	else
		self.width = left;
	end	
	if(top<height) then
		self.height = height;
	else
		self.height = top;
	end	
	self:NewLine();
end

-- a control may call this function to check its preferred size. 
-- if the preferred size is big enough, it can use this size when calling AddObject,
-- otherwise, it can either call NewLine() or AddObject with a bigger size. 
-- return preferred width, height
function PageLayout:GetPreferredSize()
	return self.width-self.availableX, self.height - self.availableY;
end

function PageLayout:GetPreferredRect()
	return self.availableX, self.availableY, self.width, self.height;
end

function PageLayout:GetPreferredPos()
	return self.availableX, self.availableY;
end

function PageLayout:SetPreferredPos(x, y)
	self.availableX, self.availableY = x, y; 
end

-- get the max available size
function PageLayout:GetMaxSize()
	return self.width-self.newlineX, self.height - self.newlineY;
end

-- get the size
function PageLayout:GetSize()
	return self.width, self.height;
end
-- set the size
function PageLayout:SetSize(width, height)
	self.width, self.height = width, height;
end

-- get used size
function PageLayout:GetUsedSize()
	return self.usedWidth, self.usedHeight;
end

-- set used size
function PageLayout:SetUsedSize(width, height)
	self.usedWidth, self.usedHeight = width, height;
end

-- clear the used size to currently available pos. 
function PageLayout:ResetUsedSize()
	self.usedWidth, self.usedHeight = self.availableX, self.availableY;
end

-- get the available rect by left, top, right, bottom. 
function PageLayout:GetAvailableRect()
	return self.availableX, self.availableY, self.width, self.height;
end

-- get the available rect by left, top
function PageLayout:GetAvailablePos()
	return self.availableX, self.availableY;
end

-- get the newline position (left, top)
function PageLayout:GetNewlinePos()
	return self.newlineX, self.newlineY;
end

-- offset the new line and available position of this PageLayout. 
function PageLayout:OffsetPos(dx, dy)
	if(dx) then
		self.newlineX = self.newlineX+dx;
		self.availableX = self.availableX+dx;
	end
	if(dy) then
		self.newlineY = self.newlineY+dy;
		self.availableY = self.availableY+dy;
	end
end
-- Set the new line and available absolute position of this PageLayout. 
function PageLayout:SetPos(x,y)
	if(x) then
		self.newlineX = x;
		self.availableX = x;
	end
	if(y) then
		self.newlineY = y;
		self.availableY = y;
	end
end

-- childLayout is usually cloned from this PageLayout and this PageLayout will expand to accommandate childLayout. 
function PageLayout:AddChildLayout(childLayout)
	local left, top = self:GetAvailablePos();
	local width, height = childLayout:GetUsedSize();
	self:AddObject(width-left, height-top);
end

-- add object at the current available position. if available position is not big enough, it will start a new line. 
-- object still can not fit in a newline, it will increase its container size. 
-- THIS IS A TRICKY FUNCTION
-- return the left, top position of the added object. 
function PageLayout:AddObject(width, height)
	local left, top;
	if((self.availableX+width)>self.width) then
		-- start a new line. 
		self:NewLine();
	end
	left, top = self.availableX, self.availableY;
	self.availableX = left+width;
	if((top+height)>self.newlineY) then
		self.newlineY = top+height
		if(self.newlineY>self.height) then
			-- increase height to best contain the child object
			self.height = self.newlineY;
		end
	end
	if(self.availableX>self.width) then
		-- increase width to best contain the child object
		self.width = self.availableX;
		-- start new line since it used up all horizontal spaces after object is added. 
		self:NewLine(); 
	end
	if(self.usedWidth<(left+width)) then
		self.usedWidth = left+width;
	end	
	if(self.usedHeight<(top+height)) then
		self.usedHeight = top+height;
	end
	return left, top;
end

-- make a new line in the PageLayout
function PageLayout:NewLine()
	self.availableX = self.newlineX
	self.availableY = self.newlineY
	--log("newline:"..self.newlineX.." "..self.newlineY.."\n")
end

-- increase preferred height of this PageLayout
function PageLayout:IncHeight(dHeight)
	self.height = self.height + dHeight;
end

-- increase preferred width of this PageLayout
function PageLayout:IncWidth(dWidth)
	self.width = self.width + dWidth;
end