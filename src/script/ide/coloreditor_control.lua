--[[
Title: color-editor control
Author(s): Liuweili,LiXizhi
Date: 2006/6/8
Desc: CommonCtrl.CCtrlColorEditor displays a color edit control with 3 sliderbars to adjust R,G,B value 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/coloreditor_control.lua");
local ctl = CommonCtrl.CCtrlColorEditor:new({
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
});
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local CCtrlColorEditor = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 182,
	height = 72,
	r = 255,
	g = 255,
	b = 255,
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- the top level control name
	name = "defaultcoloredit",
	-- onchange event, it can be nil, a string to be executed or a function of type void ()(sCtrlName)
	onchange= nil
}
CommonCtrl.CCtrlColorEditor = CCtrlColorEditor;

-- constructor
function CCtrlColorEditor:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function CCtrlColorEditor:Destroy ()
	ParaUI.Destroy(self.name);
end

-- set/get the rgb of the control.
function CCtrlColorEditor:SetRGB(r,g,b)
	CCtrlColorEditor.InternalUpdate(self.name, r,g,b);
end
function CCtrlColorEditor:GetRGB()
	return self.r,self.g,self.b;
end

-- set/get the rgb of the control. such as "255 255 255"
function CCtrlColorEditor:SetRGBString(rgb)
	local _,_, r,g,b = string.find(rgb, "([%d]+)[%D]+([%d]+)[%D]+([%d]+)");
	if(r and g and b) then
		r = tonumber(r)
		g = tonumber(g)
		b = tonumber(b)
		if(r and g and b) then
			CCtrlColorEditor.InternalUpdate(self.name, r,g,b);
		end
	end
end
function CCtrlColorEditor:GetRGBString()
	return string.format("%d %d %d", self.r,self.g,self.b);
end

--[[ update the r,g,b, values from the control.
@param sCtrlName: if nil, the current control will be used. if not the given control is updated. ]]
function CCtrlColorEditor.Update(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting control %s
		]],sCtrlName));
		return;
	end
	local rname=self.name.."_red";
	local gname=self.name.."_green";
	local bname=self.name.."_blue";
	local sname=self.name.."_show";
	local _this;
	_this=ParaUI.GetUIObject(rname);
	if(_this:IsValid())then 
		self.r=tonumber(_this.value);
	end	
	_this=ParaUI.GetUIObject(rname.."_text");
	if(_this:IsValid())then 
		_this.text=tostring(self.r);
	end	
	_this=ParaUI.GetUIObject(gname);
	if(_this:IsValid())then 
		self.g=tonumber(_this.value);
	end	
	_this=ParaUI.GetUIObject(gname.."_text");
	if(_this:IsValid())then 
		_this.text=tostring(self.g);
	end	
	_this=ParaUI.GetUIObject(bname);
	if(_this:IsValid())then 
		self.b=tonumber(_this.value);
	end	
	_this=ParaUI.GetUIObject(bname.."_text");
	if(_this:IsValid())then 
		_this.text=tostring(self.b);
	end	
	_this=ParaUI.GetUIObject(sname);
	if(_this:IsValid())then 
		local res=_this:GetTexture("background");
		if (res:IsValid())then 
			res.color=self.r.." "..self.g.." "..self.b;
		end;
	end;
	if(self.onchange~=nil)then
		if(type(self.onchange) == "string") then
			NPL.DoString(self.onchange);
		else
			self.onchange(sCtrlName);
		end
	end
end
--[[ update the r,g,b, values from the control.
@param sCtrlName: if nil, the current control will be used. if not the given control is updated. 
@param r,g,b: if nil, the corresponding component will not be updated.]]
function CCtrlColorEditor.InternalUpdate(sCtrlName,r,g,b)
	r = math.floor(r);
	g = math.floor(g);
	b = math.floor(b);
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(string.format([[err getting control %s
		]],sCtrlName));
		return;
	end
	local rname=self.name.."_red";
	local gname=self.name.."_green";
	local bname=self.name.."_blue";
	local sname=self.name.."_show";
	local _this;
	_this=ParaUI.GetUIObject(rname);
	if(_this:IsValid() and r)then 
		if(r>250) then
			r=250;
		end
		if(r<0) then
			r=0;
		end
		self.r=r;
		_this.value = r;
	end	
	_this=ParaUI.GetUIObject(rname.."_text");
	if(_this:IsValid())then 
		_this.text=tostring(self.r);
	end	
	_this=ParaUI.GetUIObject(gname);
	if(_this:IsValid()and g)then 
		if(g>250) then
			g=250;
		end
		if(g<0) then
			g=0;
		end
		self.g=g;
		_this.value = g;
	end	
	_this=ParaUI.GetUIObject(gname.."_text");
	if(_this:IsValid())then 
		_this.text=tostring(self.g);
	end	
	_this=ParaUI.GetUIObject(bname);
	if(_this:IsValid()and b)then 
		if(b>250) then
			b=250;
		end
		if(b<0) then
			b=0;
		end
		self.b=b;
		_this.value = b;
	end	
	_this=ParaUI.GetUIObject(bname.."_text");
	if(_this:IsValid())then 
		_this.text=tostring(self.b);
	end	
	_this=ParaUI.GetUIObject(sname);
	if(_this:IsValid())then 
		local res=_this:GetTexture("background");
		if (res:IsValid())then 
			res.color=self.r.." "..self.g.." "..self.b;
		end;
	end;
	return true;
end
function CCtrlColorEditor:Show()
	local _this,_parent;
	if(self.name==nil)then
		log("err showing CCtrlColorEditor\r\n");
	end
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid()==false)then
		if(self.width<100)then
			self.width=100;
		end
		local ctname=self.name;
		local rname=self.name.."_red";
		local gname=self.name.."_green";
		local bname=self.name.."_blue";
		local sname=self.name.."_show";
		local yratio=self.height/72;
		local xratio=(self.width-30)/182;
		_this=ParaUI.CreateUIObject("container",ctname,self.alignment,self.left,self.top,212*xratio,72*yratio);
		_this.background="Texture/whitedot.png;0 0 0 0";	
		
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
		_this=ParaUI.CreateUIObject("slider",rname,"_lt",left,top,150*xratio,20*yratio);
		_parent:AddChild(_this);
		_this:SetTrackRange(0,255);
		_this.value=tonumber(self.r);
		_this.onchange=string.format([[;CommonCtrl.CCtrlColorEditor.Update("%s");]], self.name);
		_this=ParaUI.CreateUIObject("text",rname.."_text","_lt",left+150*xratio,top,30,20*yratio);
		_this.autosize=false;
		_parent:AddChild(_this);
		_this.text=tostring(self.r);
		top=top+25*yratio;
		_this=ParaUI.CreateUIObject("slider",gname,"_lt",left,top,150*xratio,20*yratio);
		_parent:AddChild(_this);
		_this:SetTrackRange(0,255);
		_this.value=tonumber(self.g);
		_this.onchange=string.format([[;CommonCtrl.CCtrlColorEditor.Update("%s");]], self.name);
		_this=ParaUI.CreateUIObject("text",gname.."_text","_lt",left+150*xratio,top,30,20*yratio);
		_this.autosize=false;
		_parent:AddChild(_this);
		_this.text=tostring(self.g);
		top=top+25*yratio;
		_this=ParaUI.CreateUIObject("slider",bname,"_lt",left,top,150*xratio,20*yratio);
		_parent:AddChild(_this);
		_this:SetTrackRange(0,255);
		_this.value=tonumber(self.b);
		_this.onchange=string.format([[;CommonCtrl.CCtrlColorEditor.Update("%s");]], self.name);
		_this=ParaUI.CreateUIObject("text",bname.."_text","_lt",left+150*xratio,top,30,20*yratio);
		_this.autosize=false;
		_parent:AddChild(_this);
		_this.text=tostring(self.b);
		_this=ParaUI.CreateUIObject("text",sname,"_lt",left+150*xratio+30,1,30*xratio,70*yratio);
		_this.autosize=false;
		_parent:AddChild(_this);
		_this.background="Texture/whitedot.png;0 0 1 1";	
		res=_this:GetTexture("background");
		if(res:IsValid()==true)then
			res.color=self.r.." "..self.g.." "..self.b;
		end
	end	
end
