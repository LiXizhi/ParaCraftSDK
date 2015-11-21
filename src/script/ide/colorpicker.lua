--[[
Title: color-picker control
Author(s): LiXizhi
Date: 2008/6/8
Desc: CommonCtrl.ColorPicker displays a color edit control with 3 sliderbars to adjust R,G,B value 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/colorpicker.lua");
local ctl = CommonCtrl.ColorPicker:new({
	name = "coloredit",
	r = 255,
	g = 255,
	b = 255,
	left = 0,
	top = 0,
	width = 182,
	height = 72,
	parent = nil,
	onchange = nil,
	background = nil,
});
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local ColorPicker = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 182,
	height = 72,
	r = 255,
	g = 255,
	b = 255,
	-- container background, default to nil.
	background = nil,
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- the top level control name
	name = "defaultcoloredit",
	-- text-color
	textcolor = nil, 
	-- onchange event, it can be nil, a string to be executed or a function of type void ()(sCtrlName, r,g,b)
	onchange= nil,
	-- whether the ui panel is new
	version = nil,
}
CommonCtrl.ColorPicker = ColorPicker;

-- constructor
function ColorPicker:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function ColorPicker:Destroy ()
	ParaUI.Destroy(self.name);
end

-- set/get the rgb of the control.
function ColorPicker:SetRGB(r,g,b)
	self:InternalUpdate(r,g,b);
end
function ColorPicker:GetRGB()
	return self.r,self.g,self.b;
end

-- set/get the rgb of the control. such as "255 255 255"
-- @param silent: if true, no onchange or UI update is called. 
function ColorPicker:SetRGBString(rgb, silent)
	local _,_, r,g,b = string.find(rgb, "([%d]+)[%D]+([%d]+)[%D]+([%d]+)");
	if(r and g and b) then
		r = tonumber(r)
		g = tonumber(g)
		b = tonumber(b)
		if(r and g and b) then
			if(not silent) then
				
				self:InternalUpdate(r,g,b);
			else
				self.r, self.g, self.b = r,g,b
			end	
		end
	end
end

-- @return color such as "255 255 255"
function ColorPicker:GetRGBString()
	return string.format("%d %d %d", self.r,self.g,self.b);
end

-- @param value: such as "255 255 255" or "#FFFFFF"
-- @param silent: if true, no onchange or UI update is called. 
function ColorPicker:SetValue(color, silent)
	
	if(not color) then return end
	-- converting "#FFFFFF" to "255 255 255"
	if(string.find(color, "#")~=nil) then
		color = string.gsub(string.gsub(color, "#", ""), "(%x%x)", function (h)
			return tonumber(h, 16).." "
		end);
	end
	self:SetRGBString(color, silent)
end

-- @return color such as "255 255 255"
function ColorPicker:GetValue()
	self:GetRGBString()
end

--[[ update the r,g,b, values from the control.
@param sCtrlName: if nil, the current control will be used. if not the given control is updated. ]]
function ColorPicker.Update(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting control %s
		]],sCtrlName));
		return;
	end
	
	
	local _this, value, bColorChanged;
	_this=ParaUI.GetUIObject(self.red_id);
	if(_this:IsValid())then 
		value = tonumber(_this.value);
		if(value~=self.r)then
			self.r=value
			bColorChanged = true
			
			_this=ParaUI.GetUIObject(self.redtext_id);
			if(_this:IsValid())then 
				_this.text=tostring(self.r);
			end	
		end	
	end	
	
	_this=ParaUI.GetUIObject(self.green_id);
	if(_this:IsValid())then 
		value = tonumber(_this.value);
		if(value~=self.g)then
			self.g=value
			bColorChanged = true
			
			_this=ParaUI.GetUIObject(self.greentext_id);
			if(_this:IsValid())then 
				_this.text=tostring(self.g);
			end	
		end
	end	
	
	_this=ParaUI.GetUIObject(self.blue_id);
	if(_this:IsValid())then 
		value = tonumber(_this.value);
		if(value~=self.b)then
			self.b=value
			bColorChanged = true
			
			_this=ParaUI.GetUIObject(self.bluetext_id);
			if(_this:IsValid())then 
				_this.text=tostring(self.b);
			end	
		end
	end	
	
	_this=ParaUI.GetUIObject(self.colorblock_id);
	if(_this:IsValid())then 
		_guihelper.SetUIColor(_this, self.r.." "..self.g.." "..self.b); 
	end;
	if(bColorChanged and self.onchange~=nil)then
		if(type(self.onchange) == "string") then
			NPL.DoString(self.onchange);
		else
			self.onchange(sCtrlName, self.r, self.g, self.b);
		end
	end
end
--[[ update the r,g,b, values from the control.
@param r,g,b: if nil, the corresponding component will not be updated.]]
function ColorPicker:InternalUpdate(r,g,b)

	r = math.floor(r);
	g = math.floor(g);
	b = math.floor(b);
	local _this;
	_this=ParaUI.GetUIObject(self.red_id);

	if(_this:IsValid() and r)then 
		if(r>255) then
			r=255;
		end
		if(r<0) then
			r=0;
		end
		self.r=r;
		--_this.value = (r/255)*(self.width-30);
		_this.value = r;
		
	end	
	_this=ParaUI.GetUIObject(self.redtext_id);
	if(_this:IsValid())then 
		_this.text=tostring(self.r);
	end	
	_this=ParaUI.GetUIObject(self.green_id);
	if(_this:IsValid()and g)then 
		if(g>255) then
			g=255;
		end
		if(g<0) then
			g=0;
		end
		self.g=g;
		--_this.value = (g/255)*(self.width-30);
		_this.value = g;
	end	
	_this=ParaUI.GetUIObject(self.greentext_id);
	if(_this:IsValid())then 
		_this.text=tostring(self.g);
	end	
	_this=ParaUI.GetUIObject(self.blue_id);
	if(_this:IsValid()and b)then 
		if(b>255) then
			b=255;
		end
		if(b<0) then
			b=0;
		end
		self.b=b;
		--_this.value = (b/255)*(self.width-30);
		_this.value = b;
	end	
	_this=ParaUI.GetUIObject(self.bluetext_id);
	if(_this:IsValid())then 
		_this.text=tostring(self.b);
	end	
	_this=ParaUI.GetUIObject(self.colorblock_id);
	if(_this:IsValid())then 
		_guihelper.SetUIColor(_this, self.r.." "..self.g.." "..self.b); 
	end;
	return true;
end
function ColorPicker:Show()
	if(self.version and self.version == 1) then
		self:ShowNew();
		return;
	end
	local _this,_parent;
	if(self.name==nil)then
		log("err showing ColorPicker\r\n");
	end
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid()==false)then
		if(self.width<100)then
			self.width=100;
		end
		local yratio=self.height/72;
		local xratio=(self.width-30)/182;
		_this=ParaUI.CreateUIObject("container",self.name, self.alignment,self.left,self.top,212*xratio,72*yratio);
		_this.background=self.background or "";	
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		local left,top;
		local str;
		left=1;top=1;
		_parent=_this;
		_this=ParaUI.CreateUIObject("slider","s","_lt",left,top,150*xratio,20*yratio);
		_parent:AddChild(_this);
		_this:SetTrackRange(0,255);
		_this.value=tonumber(self.r);
		_this.button="Texture/3DMapSystem/common/ThemeLightBlue/slider_button_red.png"
		_this.onchange=string.format([[;CommonCtrl.ColorPicker.Update("%s");]], self.name);
		self.red_id = _this.id;
		
		_this=ParaUI.CreateUIObject("text","s","_lt",left+150*xratio,top,30,20*yratio);
		_this.autosize=false;
		_guihelper.SetUIFontFormat(_this, 37);
		if(self.textcolor) then
			_guihelper.SetFontColor(_this, self.textcolor);
		end
		_parent:AddChild(_this);
		_this.text=tostring(self.r);
		top=top+25*yratio;
		self.redtext_id = _this.id;
		
		_this=ParaUI.CreateUIObject("slider","s","_lt",left,top,150*xratio,20*yratio);
		_parent:AddChild(_this);
		_this:SetTrackRange(0,255);
		_this.value=tonumber(self.g);
		_this.button="Texture/3DMapSystem/common/ThemeLightBlue/slider_button_green.png"
		_this.onchange=string.format([[;CommonCtrl.ColorPicker.Update("%s");]], self.name);
		self.green_id = _this.id;
		
		_this=ParaUI.CreateUIObject("text","s","_lt",left+150*xratio,top,30,20*yratio);
		_this.autosize=false;
		_guihelper.SetUIFontFormat(_this, 37);
		if(self.textcolor) then
			_guihelper.SetFontColor(_this, self.textcolor);
		end
		_parent:AddChild(_this);
		_this.text=tostring(self.g);
		top=top+25*yratio;
		self.greentext_id = _this.id;
		
		_this=ParaUI.CreateUIObject("slider","s","_lt",left,top,150*xratio,20*yratio);
		_parent:AddChild(_this);
		_this:SetTrackRange(0,255);
		_this.button="Texture/3DMapSystem/common/ThemeLightBlue/slider_button_blue.png"
		_this.value=tonumber(self.b);
		_this.onchange=string.format([[;CommonCtrl.ColorPicker.Update("%s");]], self.name);
		self.blue_id = _this.id;
		
		_this=ParaUI.CreateUIObject("text","s","_lt",left+150*xratio,top,30,20*yratio);
		_this.autosize=false;
		_guihelper.SetUIFontFormat(_this, 37);
		if(self.textcolor) then
			_guihelper.SetFontColor(_this, self.textcolor);
		end
		_parent:AddChild(_this);
		_this.text=tostring(self.b);
		self.bluetext_id = _this.id;
		
		_this=ParaUI.CreateUIObject("button","s","_lt",left+150*xratio+30,1,30*xratio,70*yratio);
		_parent:AddChild(_this);
		_this.background="Texture/3DMapSystem/common/ThemeLightBlue/colorbox.png:5 5 5 5";
		_guihelper.SetUIColor(_this, self.r.." "..self.g.." "..self.b); 
		self.colorblock_id = _this.id;
	end	
end

function ColorPicker:ShowNew()
	local _this,_parent;
	if(self.name==nil)then
		log("err showing ColorPicker\r\n");
	end
	_this=ParaUI.GetUIObject(self.name);
	self.width = 172;
	self.height = 55;
	if(_this:IsValid()==false)then
		if(self.width<100)then
			self.width=100;
		end
		local yratio=self.height/55;
		local xratio=(self.width-30)/142;
		
		_this=ParaUI.CreateUIObject("container",self.name, self.alignment,self.left,self.top,205*xratio,55*yratio);
		_this.background=self.background or "";	
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		local left,top;
		local str;
		left=0;top=2;
		_parent=_this;
		_this=ParaUI.CreateUIObject("slider","s","_lt",left,top,142*xratio,14*yratio);
		_parent:AddChild(_this);
		_this:SetTrackRange(0,255);
		_this.value=tonumber(self.r);
		--_this.button="Texture/Aries/Creator/Theme/colorpicker_button_32bits.png;0 0 14 14;"
		_this.button="Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;369 238 14 14"
		--_this.background = "Texture/Aries/Creator/Theme/colorpicker_red_bg_32bits.png;0 0 142 13;"
		_this.background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;220 236 142 13"
		_this.onchange=string.format([[;CommonCtrl.ColorPicker.Update("%s");]], self.name);
		self.red_id = _this.id;
		
		
		_this=ParaUI.CreateUIObject("text","s","_lt",left+142*xratio,top,30,14*yratio);
		_this.autosize=false;
		_guihelper.SetUIFontFormat(_this, 37);
		if(self.textcolor) then
			_guihelper.SetFontColor(_this, self.textcolor);
		end
		_parent:AddChild(_this);
		_this.text=tostring(self.r);
		top=top+18*yratio;
		self.redtext_id = _this.id;
		
		_this=ParaUI.CreateUIObject("slider","s","_lt",left,top,142*xratio,14*yratio);
		_parent:AddChild(_this);
		_this:SetTrackRange(0,255);
		_this.value=tonumber(self.g);
		--_this.button="Texture/Aries/Creator/Theme/colorpicker_button_32bits.png;0 0 14 14;"
		_this.button="Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;369 238 14 14"
		--_this.background = "Texture/Aries/Creator/Theme/colorpicker_green_bg_32bits.png;0 0 142 13;"
		_this.background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;220 248 142 13"
		_this.onchange=string.format([[;CommonCtrl.ColorPicker.Update("%s");]], self.name);
		self.green_id = _this.id;
		
		_this=ParaUI.CreateUIObject("text","s","_lt",left+142*xratio,top,30,14*yratio);
		_this.autosize=false;
		_guihelper.SetUIFontFormat(_this, 37);
		if(self.textcolor) then
			_guihelper.SetFontColor(_this, self.textcolor);
		end
		_parent:AddChild(_this);
		_this.text=tostring(self.g);
		top=top+18*yratio;
		self.greentext_id = _this.id;
		
		_this=ParaUI.CreateUIObject("slider","s","_lt",left,top,142*xratio,14*yratio);
		_parent:AddChild(_this);
		_this:SetTrackRange(0,255);
		--_this.button="Texture/Aries/Creator/Theme/colorpicker_button_32bits.png;0 0 14 14;"
		_this.button="Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;369 238 14 14"
		--_this.background = "Texture/Aries/Creator/Theme/colorpicker_blue_bg_32bits.png;0 0 142 13;"
		_this.background = "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;220 260 142 13"
		_this.value=tonumber(self.b);
		_this.onchange=string.format([[;CommonCtrl.ColorPicker.Update("%s");]], self.name);
		self.blue_id = _this.id;
		
		_this=ParaUI.CreateUIObject("text","s","_lt",left+142*xratio,top,30,14*yratio);
		_this.autosize=false;
		_guihelper.SetUIFontFormat(_this, 37);
		if(self.textcolor) then
			_guihelper.SetFontColor(_this, self.textcolor);
		end
		_parent:AddChild(_this);
		_this.text=tostring(self.b);
		self.bluetext_id = _this.id;
		
		_this=ParaUI.CreateUIObject("button","s","_lt",left+142*xratio+30,8,34*xratio,34*yratio);
		_parent:AddChild(_this);
		_this.background="Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;408 256 13 13:6 6 6 6";
		_guihelper.SetUIColor(_this, self.r.." "..self.g.." "..self.b); 
		self.colorblock_id = _this.id;
	end	
end