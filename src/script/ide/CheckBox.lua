--[[
Title: a CheckBox control using a button and a text;
Author(s):SunLingfeng, LiXizhi
Date : 2007.4.2
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/CheckBox.lua");
local ctl = CommonCtrl.checkbox:new{
	name = "checkbox1",
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 150,
	height = 26,
	parent = nil,
	isChecked = false,
	text = "check box",
};
ctl:Show();
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/common_control.lua");

local checkbox = {
	-- name 
	name = "checkbox1",
	-- layout
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 150,
	height = 26,
	parent = nil,
	-- properties
	isChecked = false,
	text = "check box",
	tooltip = nil, -- string, tooltip to be displayed when mouse over
	-- appearance
	checked_bg = "Texture/checkbox2.png",
	unchecked_bg = "Texture/uncheckbox2.png",
	unchecked_over_bg = "Texture/uncheckbox2.png",
	-- oncheck event, it can be nil, a string to be executed or a function of type void ()(sCtrlName, checked)
	oncheck = nil,
}
CommonCtrl.checkbox = checkbox;


function checkbox:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function checkbox:Destroy ()
	ParaUI.Destroy(self.name);
end

function checkbox:Show(bShow)
	local _this,_parent;
	if(self.name == nil)then
		log("checkbox instance name can not be nil -_-b \r\n");
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		_this = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background = "";
		_parent = _this;
		
		if(self.parent == nil)then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		
		CommonCtrl.AddControl(self.name,self);
		
		_this = ParaUI.CreateUIObject("button",self.name.."btnCheck","_lt",0,0,self.height,self.height);
		_this.onclick = string.format([[;CommonCtrl.checkbox.OnCheck("%s");]],self.name);
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button",self.name.."txtCheck","_mt",self.height+3,0, 0, self.height);
		_this.text = self.text;
		if(self.tooltip~=nil)then
			_this.tooltip = self.tooltip;
		end
		_this.background="";
		if(self.textcolor == nil) then
			self.textcolor = "0 0 0";
		end
		_guihelper.SetFontColor(_this, self.textcolor);
		_guihelper.SetUIFontFormat(_this, 0+4);-- make text align to left and vertically centered. 
		_this.onclick = string.format([[;CommonCtrl.checkbox.OnCheck("%s");]],self.name);
		_parent:AddChild(_this);
		
		-- update the control
		self:SetCheck(self.isChecked);
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end		
	end
end

-- get the isChecked property
function checkbox:GetCheck()
	return self.isChecked;
end

-- set the check property
function checkbox:SetCheck(bChecked)
	self.isChecked = bChecked;
	
	-- update appearance.
	local _this = ParaUI.GetUIObject(self.name.."btnCheck");
	if(_this:IsValid() == false)then
		log("err getting checkbox instance"..self.name.."\r\n");
		return;
	end;
	
	if(self.isChecked)then
		_this.background = self.checked_bg;
	else
		if(self.unchecked_over_bg == nil) then
			self.unchecked_over_bg = self.unchecked_bg;
		end
		_guihelper.SetVistaStyleButton3(_this, 
				self.unchecked_bg, 
				self.unchecked_over_bg, 
				self.unchecked_bg, 
				self.unchecked_over_bg);
	end;
end

-- set the text property
function checkbox:SetText(text)
	self.text = text;
	-- update appearance.
	local _this = ParaUI.GetUIObject(self.name.."txtCheck");
	if(_this:IsValid() == false)then
		log("err getting checkbox instance"..self.name.."\r\n");
		return;
	end;
	_this.text = self.text;
end

-- called when the check button is pressed.
function checkbox.OnCheck(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("err getting checkbox instance"..ctrName.." -_-b \r\n");
		return;
	end

	self:SetCheck(not self.isChecked);
	
	-- call the event handler if any
	if(self.oncheck~=nil)then
		if(type(self.oncheck) == "string") then
			NPL.DoString(self.oncheck);
		else
			self.oncheck(self.name, self.isChecked);
		end
	end
end	
	
		
		