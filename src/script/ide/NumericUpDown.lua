--[[
Title: Represents a Windows spin box (also known as an up-down control) that displays numeric values. 
Author:LiXizhi
Date : 2008.9.23
Desc: A NumericUpDown control contains a single numeric value that can be incremented or decremented by 
clicking the up or down buttons of the control. The user can also enter in a value, unless the ReadOnly property is set to true. 
The numeric display can be formatted by setting valueformat properties.
To specify the allowable range of values for the control, set the Minimum and Maximum properties. 
Set the Increment value to specify the value to be incremented or decremented to the Value property when the user clicks the up or down arrow buttons. 
You can increase the speed and Acceleration that the control moves through numbers when the user mouse wheels over the spin box. 

When the UpButton or DownButton methods are called, either in code or by the click of the up or down buttons, 
the new value is validated and the control is updated with the new value in the appropriate format. 
Specifically, if the UserEdit property is set to true, the ParseEditText method is called prior to validating or updating the value. 
The value is then verified to be between the Minimum and Maximum values, and the UpdateEditText method is called. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/NumericUpDown.lua");
local ctl = CommonCtrl.NumericUpDown:new{
	name = "NumericUpDown1",
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 150,
	height = 20,
	parent = nil,
	value = 50, -- current value
	valueformat = "%.1f",
	min = 0,
	max = 100,
	min_step = 1, 
};
ctl:Show();
-- one can also call UpdateUI manually after setting the value property. 
-- ctl:UpdateUI();
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/common_control.lua");

local NumericUpDown = {
	-- name 
	name = "NumericUpDown1",
	-- layout
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 120,
	height = 20,
	parent = nil,
	
	-- properties
	value = nil, -- current value
	valueformat= nil, -- "%.1f",
	min = 0,
	max = 100,
	-- whether it is readonly
	readonly = nil,
	-- Gets or sets the value to increment or decrement the spin box (also known as an up-down control) when the up or down buttons are clicked
	-- minimum step of value. if this is nil, it has screen pixel resolution, otherwise one can specify a value, such as (max-min)/10.  
	min_step = nil, 
	-- string, tooltip to be displayed when mouse over
	tooltip = nil, 
	-- appearance
	background = "Texture/3DMapSystem/common/ThemeLightBlue/numeric_bg.png:4 4 23 4",
	-- spin button width
	button_width = 16,
	-- onchange event, it can be nil, a string to be executed or a function of type void ()(value)
	onchange = nil,
	canDrag = true,
}
CommonCtrl.NumericUpDown = NumericUpDown;

-- mouse down position
NumericUpDown.lastMouseDown = {x = 0, y=0}
NumericUpDown.lastMousePos = {x = 0, y=0}
-- whether any mouse button is down
NumericUpDown.IsMouseDown = false;

function NumericUpDown:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function NumericUpDown:Destroy ()
	ParaUI.Destroy(self.name);
end

function NumericUpDown:Show(bShow)
	local _this,_parent;
	if(self.name == nil)then
		log("NumericUpDown instance name can not be nil\r\n");
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		_this = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background = self.background;
		if(not self.readonly) then
			_this.onmousedown = string.format(";CommonCtrl.NumericUpDown.OnMouseDown(%q);", self.name);
			_this.onmouseup = string.format(";CommonCtrl.NumericUpDown.OnMouseUp(%q);", self.name);
			_this.onmousemove = string.format(";CommonCtrl.NumericUpDown.OnMouseMove(%q);", self.name);
			_this.onmousewheel = string.format(";CommonCtrl.NumericUpDown.OnMouseWheel(%q);", self.name);
		end	
		_parent = _this;
		
		if(self.parent == nil)then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		
		_this = ParaUI.CreateUIObject("editbox","text","_fi",0,0,self.button_width,0);
		_this.background = "";
		if(self.readonly) then
			_this.enabled = false;
		else
			_this.onchange = string.format(";CommonCtrl.NumericUpDown.OnTextChange(%q);", self.name)
		end
		_parent:AddChild(_this);
				
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
function NumericUpDown:UpdateUI()
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == true) then
		local textCtrl = _this:GetChild("text");
		if(textCtrl:IsValid())then
			local _,_, width, height = _this:GetAbsPosition();
			
			local value;
			if(self.valueformat) then	
				textCtrl.text = string.format(self.valueformat, self.value);
			else
				textCtrl.text = tostring(self.value)
			end
		end	
	end
end

-- ensure value is in proper range and steps
function NumericUpDown:ValidateData()
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
-- @param bFireEvent: if true, onchange is event is fired if value is changed. 
function NumericUpDown:SetValue(value, bFireEvent)
	if(not bFireEvent) then
		self.value = value;
		self:ValidateData();
		self:UpdateUI();
	elseif(self.value~=value) then
		self.value = value;
		self:ValidateData();
		self:UpdateUI(); 
		self:OnChange();
	end	
end

-- return the correct value 
function NumericUpDown:GetValue(value)
	return self.value;
end

-- update date according to a given mouse position.
-- @param mouse_dy: pixel relative to the mouse down position
function NumericUpDown:UpdateData(mouse_dx, mouse_dy)
	-- ignore move within 5 pixels. 
	if(mouse_dy > 5) then
		mouse_dy = mouse_dy - 5
	elseif(mouse_dy < -5)then
		mouse_dy = mouse_dy + 5
	else
		mouse_dy = 0
		if(self.BeforeMoveValue~=self.value and self.BeforeMoveValue) then
			self:SetValue(self.BeforeMoveValue, true);
			return;
		end
	end
		
	if( mouse_dy ~= 0 and self.BeforeMoveValue ) then
		if(self.min_step)then
			self:SetValue(self.BeforeMoveValue - mouse_dy*self.min_step, true)
		else
			self:SetValue(self.BeforeMoveValue - mouse_dy*(self.max-self.min)/100, true);
		end	
	end	
end

function NumericUpDown.OnMouseDown(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("err getting NumericUpDown instance"..ctrName.."\r\n");
		return;
	end
	self.BeforeMoveValue = self.value;
	NumericUpDown.lastMouseDown.x = mouse_x;
	NumericUpDown.lastMouseDown.y = mouse_y;
	NumericUpDown.IsMouseDown = true;
	NumericUpDown.lastMousePos.x = mouse_x;
	NumericUpDown.lastMousePos.y = mouse_y;
end

function NumericUpDown.OnMouseUp(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("err getting NumericUpDown instance"..ctrName.."\r\n");
		return;
	end
	if(not self.canDrag)then return; end
	NumericUpDown.IsMouseDown = false;
	
	local dragDist = (math.abs(NumericUpDown.lastMousePos.x-NumericUpDown.lastMouseDown.x) + math.abs(NumericUpDown.lastMousePos.y-NumericUpDown.lastMouseDown.y));
	if(dragDist<=2) then
		-- this is mouse click event if mouse down and mouse up distance is very small.
		local _this = ParaUI.GetUIObject(self.name);
		if(_this:IsValid() == true) then
			local x,y, width, height = _this:GetAbsPosition();
			if( mouse_x>(x+width-self.button_width) ) then
				local step = self.min_step or (self.max-self.min)/100;
				if( mouse_y>(y+height/2) ) then
					step = - step;
				end
				self:SetValue(self.value + step, true);
			end	
		end	
	end
end

function NumericUpDown.OnMouseMove(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("err getting NumericUpDown instance"..ctrName.."\r\n");
		return;
	end
	if(not self.canDrag)then return; end
	if(NumericUpDown.IsMouseDown) then
		-- this is a drag operation
		local mouse_dx, mouse_dy = mouse_x-NumericUpDown.lastMousePos.x, mouse_y-NumericUpDown.lastMousePos.y;
		if(mouse_dx~=0 or mouse_dy~=0) then
			self:UpdateData(mouse_x-NumericUpDown.lastMouseDown.x, mouse_y-NumericUpDown.lastMouseDown.y);
		end	
	end
	NumericUpDown.lastMousePos.x = mouse_x;
	NumericUpDown.lastMousePos.y = mouse_y;
end

function NumericUpDown.OnMouseWheel(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("err getting NumericUpDown instance"..ctrName.."\r\n");
		return;
	end
	if(not self.canDrag)then return; end
	if(not NumericUpDown.IsMouseDown) then
		local step = mouse_wheel*(self.min_step or (self.max-self.min)/100);
		self:SetValue(self.value+step, true);
	end
end

function NumericUpDown.OnTextChange(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("err getting NumericUpDown instance"..ctrName.."\r\n");
		return;
	end
	local _this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid()) then
		local textCtrl = _this:GetChild("text");
		if(textCtrl:IsValid())then
			local value = tonumber(textCtrl.text);
			if(value==nil)then
				textCtrl.text = tostring(self.value);
			else
				self:SetValue(value, true);
			end
		end
	end
end

-- called when the check button is pressed.
function NumericUpDown:OnChange()
	-- call the event handler if any
	if(self.onchange~=nil)then
		if(type(self.onchange) == "string") then
			NPL.DoString(self.onchange);
		else
			self.onchange(self.value);
		end
	end
end	

	
		
		