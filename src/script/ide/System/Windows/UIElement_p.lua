--[[
Title: UIElement class to all UI objects
Author(s): LiXizhi
Date: 2015/5/7
Desc: because UIElement class is too big, we will move private functions to this file.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/UIElement.lua");
local UIElement = commonlib.gettable("System.Windows.UIElement")
------------------------------------------------------------
]]
local SizeEvent = commonlib.gettable("System.Windows.SizeEvent");
local Event = commonlib.gettable("System.Core.Event");
local Mouse = commonlib.gettable("System.Windows.Mouse");
local Application = commonlib.gettable("System.Windows.Application");
local Point = commonlib.gettable("mathlib.Point");
local Rect = commonlib.gettable("mathlib.Rect");
local KeyEvent = commonlib.gettable("System.Windows.KeyEvent");
local ShowEvent = commonlib.gettable("System.Windows.ShowEvent");
local HideEvent = commonlib.gettable("System.Windows.HideEvent");
local MouseEvent = commonlib.gettable("System.Windows.MouseEvent");
local UIElement = commonlib.gettable("System.Windows.UIElement");

function UIElement:showChildren(spontaneous)
	if(self.children and not self.children:empty()) then
		local children = self.children;
		local widget = children:first();
		while (widget) do
			if (not widget:isWindow() and not widget:testAttribute("WA_WState_Hidden")) then
				if (spontaneous) then
					widget:setAttribute("WA_Mapped");
					widget:showChildren(true);
					Application:sendSpontaneousEvent(widget, ShowEvent:new());
				else
					if (widget:testAttribute("WA_WState_ExplicitShowHide")) then
						widget:show_recursive();
					else
						widget:show();
					end
				end
			end
			widget = children:next(widget);
		end
	end
end

function UIElement:hide_helper()
    self:setAttribute("WA_Mapped", false);
    self:hide_sys();

    local wasVisible = self:testAttribute("WA_WState_Visible");

    if (wasVisible) then
        self:setAttribute("WA_WState_Visible", false);
    end

    Application:sendEvent(self, HideEvent:new());
    self:hideChildren(false);

    -- next bit tries to move the focus if the focus widget is now hidden.
    if (wasVisible) then
        Application:sendSyntheticEnterLeave(self);
        local fw = Application:focusWidget();
        while (fw and not fw:isWindow()) do
            if (fw == q) then
                self:focusNextPrevChild(true);
                break;
            end
            fw = fw:parentWidget();
        end
    end
end

function UIElement:hideChildren(spontaneous)
	if(self.children and not self.children:empty()) then
		local children = self.children;
		local widget = children:first();
		while (widget) do
			if (not widget:isWindow() and not widget:testAttribute("WA_WState_Hidden")) then
				if (spontaneous) then
					widget:setAttribute("WA_Mapped", false);
				else
					widget:setAttribute("WA_WState_Visible", false);
				end
			end
			widget:hideChildren(spontaneous);
			local e = HideEvent:new();
			if (spontaneous) then
				Application:sendSpontaneousEvent(widget, e);
			else
				Application:sendEvent(widget, e);
				if (widget:isWindow()) then
					widget:hide_sys();
				end
			end
			Application:sendSyntheticEnterLeave(widget);
			widget = children:next(widget);
		end
	end
end

function UIElement:setGeometry_sys(ax, ay, aw, ah)
	local old_x, old_y, old_w, old_h = self.crect:getRect();
	local isResize = old_w~=aw or old_h~=ah;
	local isMove = old_x~=ax or old_y~=ay;
	if(not isResize and not isMove) then
		-- We only care about stuff that changes the geometry
		return;
	end
	self.crect:setRect(ax, ay, aw, ah);

	if (self:isVisible()) then
		-- generate size event
		local event = SizeEvent:new():init(self.crect)
        Application:sendEvent(self, event);
	else
		-- not visible
		if(isResize or isMove) then
			self:setAttribute("WA_PendingSizeEvent");
		end
	end
end

function UIElement:updateWidgetTransform(event)
    if (self == Application:focusWidget() or event:GetType() == "focusInEvent") then
		self:updateCompositionPoint();
		-- local p = self:mapTo(window, Point:new_from_pool(0,0));
		-- Application:inputMethod():setInputItemTransform(p);
		-- Application:inputMethod():setInputItemRectangle(self:rect());
    end
end

-- update IME position point. 
function UIElement:updateCompositionPoint()
	local window = self:GetWindow();
	if(window) then
		local p = self:mapTo(window, Point:new_from_pool(0,0));
		p:add(self:width()/2, self:height());
		window:setCompositionPoint_sys(p);
	end
end