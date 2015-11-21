--[[
Title: a slider bar control using a button and a container: both vertical and horizontal slider is provided
Author:LiXizhi
Date : 2007.10.17
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/SliderBar.lua");
local ctl = CommonCtrl.SliderBar:new{
	name = "SliderBar1",
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 150,
	height = 20,
	parent = nil,
	value = 50, -- current value
	min = 0,
	max = 100,
};
ctl:Show();
-- one can also call UpdateUI manually after setting the value property. 
-- ctl:UpdateUI();
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/common_control.lua");

local SliderBar = {
	-- name 
	name = "SliderBar1",
	-- layout
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 150,
	height = 26,
	parent = nil,
	-- nil, "vertical" or "horizontal". If nil it will deduce from the width and height. 
	direction = nil,
	-- properties
	value = nil, -- current value
	min = 0,
	max = 100,
	-- boolean, whether we will ensure value is within [min, max] and integral times of min_step.
	no_value_check = nil,
	-- minimum step of value. if this is nil, it has screen pixel resolution, otherwise one can specify a value, such as (max-min)/10.  
	min_step = nil, 
	-- string, tooltip to be displayed when mouse over
	tooltip = nil, 
	-- appearance
	background_margin_top = 0,
	background_margin_bottom = 0,
	background = "Texture/3DMapSystem/common/ThemeLightBlue/slider_background_16.png: 4 8 4 7",
	button_bg = "Texture/3DMapSystem/common/ThemeLightBlue/slider_button_16.png",
	-- default to button_bg
	step_left_button_bg = nil,
	-- default to button_bg
	step_right_button_bg = nil,
	button_width = 16,
	button_height = 16,
	-- whether to display a textbox next to the editor
	IsShowEditor = nil,
	-- whether to show the step button at the both end of the slider button
	show_step_button = false,
	editor_width = 40,
	editor_format = "%.1f",
	-- button text to be displayed on the draggable button. 
	-- buttontext_format = "%d / %d",
	-- buttontext_color = nil,
	-- tooltip when mouse over
	tooltip = nil,
	-- onchange event, it can be nil, a string to be executed or a function of type void ()(value)
	onchange = nil,
	onMouseDownEvent = nil,
	-- function(isDragging) end
	onMouseUpEvent = nil,
	canDrag = true,
}
CommonCtrl.SliderBar = SliderBar;

local g_CurrentMouseDownControl;

function SliderBar:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function SliderBar:Destroy ()
	ParaUI.Destroy(self.name);
end

function SliderBar:Show(bShow)
	local _this,_parent;
	if(self.name == nil)then
		log("SliderBar instance name can not be nil\r\n");
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		_this = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background = "";
		_this:SetScript("onmousedown", function() self:OnMouseDown(); end);
		_this:SetScript("onmouseup", function() self:OnMouseUp(); end);
		_this:SetScript("onmousewheel", function() self:OnMouseWheel(); end);
		_this:SetScript("ontouch", function() self:OnTouch(); end);

		if(self.tooltip) then
			_this.tooltip = self.tooltip
		end	
		_parent = _this;
		self.id = _parent.id;
		
		
		if(self.parent == nil)then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		
		-- create the background. 
		_this = ParaUI.CreateUIObject("container","bg","_fi",0,self.background_margin_top or 0, if_else(self.IsShowEditor, self.editor_width, 0), self.background_margin_bottom or 0);
		_this.background = self.background;
		_this.enabled = false;
		_parent:AddChild(_this);
		
		if(self.IsShowEditor) then
			_this = ParaUI.CreateUIObject("editbox","editor","_rt",-self.editor_width,0,self.editor_width,self.height);
			_this:SetScript("onchange", function() self:OnTextValue(); end);
			_parent:AddChild(_this);
		end
		
		local icon_size = math.min(self.button_width,self.button_height);
		if(not self.show_step_button) then
			icon_size = 0;
		end
		self.step_btn_size = icon_size;

		_this = ParaUI.CreateUIObject("button","b","_lt",0,0,self.button_width,self.button_height);
		_this.background = self.button_bg;
		_guihelper.SetUIColor(_this, "255 255 255"); 
		_this.enabled = false;
		if(self.buttontext_color) then
			_guihelper.SetFontColor(_this, self.buttontext_color);
		end
		_parent:AddChild(_this);
		
		if(self.step_btn_size>0) then
			_this = ParaUI.CreateUIObject("button","left","_lt",-icon_size,0,icon_size,icon_size);
			_this.background = self.step_left_button_bg or self.button_bg;
			_this:SetScript("onclick", function()
				self:OnStepLeft();
			end);
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("button","right","_lt",self.button_width,0,icon_size,icon_size);
			_this.background = self.step_right_button_bg or self.button_bg;
			_this:SetScript("onclick", function()
				self:OnStepRight();
			end);
			_parent:AddChild(_this);
		end

		CommonCtrl.AddControl(self.name,self);

		if(not self.value)	then
			self.value = self.min;
		end
		
		-- update the control
		self:UpdateUI();
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end		
	end
end

-- Update UI according to the current value, min, and max. But it does not fire onchage event
function SliderBar:UpdateUI()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == true) then
		local btn = _this:GetChild("b");
		if(btn:IsValid())then
			local _,_, width, height = _this:GetAbsPosition();
			
			if(self.direction=="horizontal" or width>height) then
				if(self.IsShowEditor) then
					width = width - self.editor_width;
				end
				-- horizontal slider bar
				btn.x = (self.value-self.min)/(self.max-self.min)*(width-self.button_width);
				btn.y = (height-self.button_height)/2
			else
				-- vertical slider bar
				btn.x = (width-self.button_width)/2
				btn.y = (self.value-self.min)/(self.max-self.min)*(height-self.button_height);
			end
			if(self.IsShowEditor) then
				local editor = _this:GetChild("editor");
				if(editor:IsValid())then
					editor.text = string.format(self.editor_format, self.value or 0);
				end
			end
			if(self.buttontext_format) then
				btn.text = string.format(self.buttontext_format, self.value, self.max);
			end
			if(self.show_step_button) then
				local left_btn = _this:GetChild("left");	
				left_btn.x = btn.x - self.step_btn_size;
				left_btn.y = btn.y;
				local right_btn = _this:GetChild("right");	
				right_btn.x = btn.x + self.button_width;
				right_btn.y = btn.y;
			end
		end	
	end
end


-- ensure value is in proper range and steps
function SliderBar:ValidateData()
	if(self.no_value_check) then
		return;
	end
	-- ensure value is interger times of min_step
	if(self.min_step~=nil) then
		local nStep = math.floor((self.value-self.min)/self.min_step);
		local reminder = (self.value-self.min-self.min_step*nStep);
		if(reminder>=self.min_step/2) then
			nStep = nStep+1;
		end
		self.value = self.min+self.min_step*nStep;
	end
	if(self.value>self.max) then
		self.value = self.max;
	end
	if(self.value<self.min) then
		self.value = self.min;
	end
end

-- set value, validate it and update UI
function SliderBar:SetValue(value)
	if(not self.is_dragging) then
		if(self.value~=value) then
			self.value = value;
		end
		self:ValidateData();
		self:UpdateUI();
	end
end

-- return the correct value 
function SliderBar:GetValue(value)
	return self.value;
end

function SliderBar:IsMouseDownAndNotDragging(mouse_x, mouse_y)
	if(self.IsMouseDown and not self.is_dragging and self.last_mouse_x and self.last_mouse_y) then
		local delta_value = math.abs(self.last_mouse_x - mouse_x) + math.abs(self.last_mouse_y - mouse_y);
		if(delta_value > 2) then
			self.is_dragging = true;
			-- do not change the value if mouse doe not move. 
		else
			return true;
		end	
	end
end

-- update date according to a given mouse position.
function SliderBar:UpdateData(mouse_x, mouse_y)
	if(g_CurrentMouseDownControl ~= self) then
		return
	end
	if(not mouse_x or not mouse_y) then
		mouse_x, mouse_y = ParaUI.GetMousePosition();
	end
	

	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == true) then
		local btn = _this:GetChild("b");
		if(btn:IsValid())then
			local x,y, width, height = _this:GetAbsPosition();
			if(self.IsShowEditor) then
				width = width - self.editor_width;
			end
			x = mouse_x - x;
			y = mouse_y - y;

			if(self:IsMouseDownAndNotDragging(mouse_x, mouse_y)) then
				--tricky: do nothing, unless really dragging. 
				return;
			end

			if(self.last_mouse_x_offset) then
				x = x + self.last_mouse_x_offset;
			end
			if(self.last_mouse_y_offset) then
				y = y + self.last_mouse_y_offset;
			end
			local oldvalue = self.value;
			
			if(self.direction=="horizontal" or width>height) then
				-- horizontal slider bar
				if(x<=self.button_width/2) then
					self.value = self.min;
				elseif(x>=(width-self.button_width/2))then
					self.value = self.max;
				else
					self.value = self.min+(x - self.button_width/2)/(width-self.button_width)*(self.max-self.min);
				end
			else
				-- vertical slider bar
				if(y<=self.button_height/2) then
					self.value = self.min;
				elseif(y>=(height-self.button_height/2))then
					self.value = self.max;
				else
					self.value = self.min+(y - self.button_height/2)/(height-self.button_height)*(self.max-self.min);
				end
			end
			
			--if(self.IsMouseDown) then
				---- locking the mouse cursor at one axis. 
				--local root_ = ParaUI.GetUIObject("root");
				--root_:GetAttributeObject():SetField("MousePosition", {mouse_x, mouse_y});
			--end

			 -- ensure value is interger times of min_step
			self:ValidateData();
			
			-- only update and call onchange if value changed. 
			if(oldvalue~=self.value) then
				self:UpdateUI();
				self:OnChange()
				--btn.text = tostring(self.value); -- for testing
			end	
		end	
	end
end

function SliderBar:StepDeltaValue(delta)
	local oldvalue = self.value;
	self.value = self.value + (delta or 0);
	self:ValidateData();
	if(oldvalue ~= self.value) then
		self:UpdateUI();
		self:OnChange();
	end	
end

function SliderBar:OnStepLeft()
	self:StepDeltaValue(-(self.min_step or 1))
end

function SliderBar:OnStepRight()
	self:StepDeltaValue(self.min_step or 1)
end

function SliderBar:OnTouch()
	local touch = msg;
	if(touch.type == "WM_POINTERDOWN") then
		self:OnMouseDown(touch.x, touch.y);
	elseif(touch.type == "WM_POINTERUPDATE") then
		self:OnFrameMove(touch.x, touch.y, true);
	elseif(touch.type == "WM_POINTERUP") then
		self:OnMouseUp(touch.x, touch.y);
	end
end

function SliderBar:OnMouseDown(x, y)
	if(not self.canDrag)then return; end
	self.IsMouseDown = true;
	g_CurrentMouseDownControl = self;

	self.last_mouse_x_offset, self.last_mouse_y_offset = nil,nil;
	self.is_dragging = false;

	local mouse_x = x or mouse_x;
	local mouse_y = y or mouse_y;
	-- check if mouse is on button
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid()) then
		if(not x and not y) then
			_this:SetScript("onframemove", function() self:OnFrameMove(); end);
		end
		local btn = _this:GetChild("b");
		if(btn:IsValid())then
			local x,y = _this:GetAbsPosition();
			x = x+btn.x;
			y = y+btn.y;
			
			if(x<=mouse_x and mouse_x<=(x+self.button_width) and y<=mouse_y and mouse_y<=(y+self.button_height)) then
				-- we will not update data if mouse cursor is on button
				self.last_mouse_x_offset = math.floor((x + self.button_width/2) - mouse_x);
				self.last_mouse_y_offset = math.floor((y + self.button_height/2) - mouse_y);
				self.last_mouse_x, self.last_mouse_y = mouse_x,mouse_y;
				return;
			end	
		end
	end	
	self:UpdateData(mouse_x, mouse_y);
	
	if(self.onMouseDownEvent) then
		self.onMouseDownEvent();
	end	
end

function SliderBar.IsDragging()
	return g_CurrentMouseDownControl~=nil;
end

function SliderBar:OnMouseUp(mouse_x, mouse_y)
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid()) then
		_this:SetScript("onframemove", nil);
	end
	if(not self.canDrag)then return; end
	self.IsMouseDown = false;
	if(self.is_dragging) then
		self:UpdateData(mouse_x, mouse_y);
	end
	
	if(self.onMouseUpEvent) then
		self.onMouseUpEvent(self.is_dragging);
	end	
	if(g_CurrentMouseDownControl == self) then
		g_CurrentMouseDownControl = nil;
	end
	self.last_mouse_x_offset = nil;
	self.last_mouse_y_offset = nil;
	self.last_mouse_x, self.last_mouse_y = nil,nil;
	self.is_dragging = nil;
end

function SliderBar:OnFrameMove(mouse_x, mouse_y, isFromTouch)
	if(not self.canDrag)then return; end
	
	if(isFromTouch) then
		self:UpdateData(mouse_x, mouse_y);
	else
		if(self.IsMouseDown) then
			if(not ParaUI.IsMousePressed(0)) then
				self:OnMouseUp(mouse_x, mouse_y);
			else	
				-- this is a drag operation
				self:UpdateData(mouse_x, mouse_y);
			end
		else
			if(ParaUI.IsMousePressed(0)) then
				self:UpdateData(mouse_x, mouse_y);
			else
				self:OnMouseUp(mouse_x, mouse_y);
			end
		end
	end
end

function SliderBar:OnMouseWheel()
	if(not self.canDrag)then return; end
	if(not self.IsMouseDown) then
		local oldvalue = self.value;
		
		if(self.min_step)then
			self.value = self.value - mouse_wheel*self.min_step
		else
			self.value = self.value - mouse_wheel*(self.max-self.min)/24;
		end	
			
		self:ValidateData();
		
		-- only update and call onchange if value changed. 
		if(oldvalue~=self.value) then
			self:UpdateUI();
			self:OnChange()
		end	
	end
end

-- user input edit box value
function SliderBar:OnTextValue()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid()) then
		local editor = _this:GetChild("editor");
		if(editor:IsValid())then
			local value = tonumber(editor.text);
			local oldvalue = self.value;
			if(value) then
				self.value = value;
				-- ensure value is interger times of min_step
				self:ValidateData();
				
				-- only update and call onchange if value changed. 
				if(oldvalue~=self.value) then
					self:UpdateUI();
					self:OnChange()
				end	
			else
				-- _guihelper.MessageBox("Please enter a numeric number")	
			end
		end
	end	
end

-- called when the check button is pressed.
function SliderBar:OnChange()
	-- call the event handler if any
	if(self.onchange~=nil)then
		if(type(self.onchange) == "string") then
			NPL.DoString(self.onchange);
		else
			self.onchange(self.value);
		end
	end
end	

	
		
		