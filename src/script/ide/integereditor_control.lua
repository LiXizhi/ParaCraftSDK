--[[
Title: integer-editor control
Author(s): Liuweili, Li,Xizhi
Date: 2006/6/8
Revised: 2006/6/30 Slider UI added - LXZ. 2006/12/5 add value update method
Desc: CommonCtrl.CCtrlIntegerEditor allows user to modify an integer value or increase/decrease by certain amount. Can have range constrain.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/integereditor_control.lua");
local ctl = CommonCtrl.CCtrlIntegerEditor:new{
	name = "integereditor",
	left=100, top=100,
	maxvalue=5, minvalue=0, step = 1,
};
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local CCtrlIntegerEditor = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 72,
	height = 22,
	value = 0,
	valueformat = "%.1f",
	step =1,
	--the maxvalue and minvalue of the control
	minvalue = -2147483647, 
	maxvalue = 2147483647,
	
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- the top level control name
	name = "defaultintegeredit",
	-- onchange event, it can be nil, a string to be executed or a function of type void ()(sCtrlName)
	onchange= nil,
	-- if true, a slider bar will be used. if not buttons are used.
	UseSlider = nil,
}
CommonCtrl.CCtrlIntegerEditor = CCtrlIntegerEditor;

-- constructor
function CCtrlIntegerEditor:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function CCtrlIntegerEditor:Destroy ()
	ParaUI.Destroy(self.name);
end

--  change the value of the control
function CCtrlIntegerEditor:ChangeValue(value)
	self.value = value;
	if(self.value>self.maxvalue)then
		self.value=self.maxvalue;
	end
	if(self.value<self.minvalue)then
		self.value=self.minvalue;
	end
		
	local _this;
	_this=ParaUI.GetUIObject(self.name.."_edit");
	if(_this:IsValid())then 
		_this.text=tostring(self.value);
	end
	_this=ParaUI.GetUIObject(self.name.."slider");
	if(_this:IsValid() == true)then 
		_this.value=(self.value-self.minvalue)/(self.maxvalue - self.minvalue)*255;
	end
	
	--[[ inform handler
	if(self.onchange~=nil)then
		if(type(self.onchange) == "string") then
			NPL.DoString(self.onchange);
		else
			self.onchange(sCtrlName);
		end
	end]]
end

--@param sCtrlName: the integer-editor's name 
--@param delta: the delta of the integer-editor's value
function CCtrlIntegerEditor.Update(sCtrlName, delta)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting control %s
		]],sCtrlName));
		return;
	end
	local name=self.name.."_edit";
	local _this;
	
	_this=ParaUI.GetUIObject(name);
	if(_this:IsValid()and delta)then 
		self.value=tonumber(_this.text);
		if(delta~=nil)then
			self.value=self.value+delta;
		end
		if(self.value>self.maxvalue)then
			self.value=self.maxvalue;
		end
		if(self.value<self.minvalue)then
			self.value=self.minvalue;
		end
		_this.text=tostring(self.value);
	end	
	if(self.onchange~=nil)then
		if(type(self.onchange) == "string") then
			NPL.DoString(self.onchange);
		else
			self.onchange(sCtrlName);
		end
	end
end

--[static]
function CCtrlIntegerEditor.OnChangeSlider(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting control %s]],sCtrlName));
		return;
	end
	local _this=ParaUI.GetUIObject(self.name.."slider");
	if(_this:IsValid() == true)then 
		self.value = _this.value/255*(self.maxvalue-self.minvalue)+self.minvalue;
		
		_this=ParaUI.GetUIObject(self.name.."value");
		if(_this:IsValid() == true)then 
			_this.text=string.format(self.valueformat,self.value);
		end
		
		if(self.onchange~=nil)then
			if(type(self.onchange) == "string") then
				NPL.DoString(self.onchange);
			else
				self.onchange(sCtrlName);
			end
		end
	end
end

--@param sCtrlName: the integer-editor's name 
--@param value: the new value of the integer-editor
function CCtrlIntegerEditor.InternalUpdate(sCtrlName,value)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting control %s
		]],sCtrlName));
		return;
	end
	local name=self.name.."_edit";
	local _this;
	
	_this=ParaUI.GetUIObject(name);
	if(_this:IsValid()and value)then 
		self.value=value
		if(self.value>self.maxvalue)then
			self.value=self.maxvalue;
		end
		if(self.value<self.minvalue)then
			self.value=self.minvalue;
		end
		_this.text=tostring(self.value);
	end	
	return true;
end

function CCtrlIntegerEditor:Show()
	local _this,_parent;

	if(self.name==nil)then
		ParaGlobal.WriteToLogFile("err");	
	end
	
	local name=self.name.."_edit";
	local lname=self.name.."_larrow";
	local rname=self.name.."_rarrow";
		
	local xratio=(self.width-22)/50;
	_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
	_this.background="Texture/dxutcontrols.dds;0 0 0 0";
	
	
	if(self.parent==nil) then
		_this:AttachToRoot();
	else
		self.parent:AddChild(_this);
	end
	CommonCtrl.AddControl(self.name, self);
	local left,top;
	left=1;top=1;
	_parent=_this;
	if(not self.UseSlider) then
		_this=ParaUI.CreateUIObject("button",lname,"_lt",left,top,10,self.height-2);
		_parent:AddChild(_this);
		_this.text="<";
		--_this.background="Texture/box.png;";
		_this.onclick=string.format([[;local _this=CommonCtrl.GetControl("%s");if(_this~=nil)then CommonCtrl.CCtrlIntegerEditor.Update("%s",-_this.step);end;]],self.name,self.name);
		left=left+10;
		_this=ParaUI.CreateUIObject("editbox",name,"_lt",left,top,50*xratio,self.height-2);
		_parent:AddChild(_this);
		_this.text=string.format(self.valueformat,self.value);
		--_this.background="Texture/box.png;";
		_this.onchange=string.format([[;CommonCtrl.CCtrlIntegerEditor.Update("%s",0);]], self.name);
		left=left+50*xratio;
		_this=ParaUI.CreateUIObject("button",rname,"_lt",left,top,10,self.height-2);
		_parent:AddChild(_this);
		_this.text=">";
		--_this.background="Texture/box.png;";
		_this.onclick=string.format([[;local _this=CommonCtrl.GetControl("%s");if(_this~=nil)then CommonCtrl.CCtrlIntegerEditor.Update("%s",_this.step);end;]],self.name,self.name);
	else
		_this=ParaUI.CreateUIObject("slider",self.name.."slider","_lt",left,top,self.width*0.7,self.height);
		_parent:AddChild(_this);
		_this:SetTrackRange(0,255);
		_this.value= (self.value-self.minvalue)/(self.maxvalue - self.minvalue)*255;
		_this.onchange=string.format([[;CommonCtrl.CCtrlIntegerEditor.OnChangeSlider("%s");]], self.name);
		_this=ParaUI.CreateUIObject("text",self.name.."value","_lt",left+self.width*0.7,top+3,self.width*0.3,self.height);
		_this.text=string.format(self.valueformat,self.value);
		_this.autosize=false;
		_parent:AddChild(_this);
		--_this.background="Texture/box.png;";
	end
end
