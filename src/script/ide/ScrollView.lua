--[[
Title: ScrollView
Author(s): Leio Zhang
Date: 2008/10/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/ScrollView.lua");
-------------------------------------------------------
]]

local ScrollView = {
	name = nil,	
	left = 0,
	top = 0,
	width = 300,
	height = 26, 
	parent = nil,
	
	_list = nil,
	_maxWidth = nil,
	_maxHeight = nil,

}
commonlib.setfield("CommonCtrl.ScrollView",ScrollView);
function ScrollView:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	
	o:Initialization()	
	return o
end
function ScrollView:Initialization()
	self.alignment = "_lt";
	self.name = ParaGlobal.GenerateUniqueID();
	CommonCtrl.AddControl(self.name,self);
	
	self._list = {};
end
function ScrollView:AddChild(child)
	if(not child:IsValid())then return; end
	local name = child.name;
	local width,height = child.width,child.height;
	table.insert(self._list,{name = name,width = width,height = height});
end
function ScrollView:RemoveChild(child)
	if(not child:IsValid())then return; end
end
function ScrollView:Update()
	self.parent = ParaUI.GetUIObject(self.parentName);
	if(not self.parent:IsValid())then return; end
	local _this = ParaUI.GetUIObject(self.name.."container");
	if(_this:IsValid())then
		ParaUI.Destroy(self.name.."container");		
	end
	local _this = ParaUI.CreateUIObject("container", self.name.."container", self.alignment, self.left, self.top, self.width, self.height);
	_this.background= "";
	self.parent:AddChild(_this);
	local parent = _this;
	
	local k,v;
	local _w,_h = 0,0;
	for k,v in ipairs(self._list) do
		local width = v["width"];
		local height = v["height"];
		if(width>_w)then
			_w = width;
		end
		_h = _h + height;
	end
	self._maxWidth = _w;
	self._maxHeight = _h;
	
	local width,height = self.width,self.height;
	local bar_width,bar_height = 15,20;
	if(self._maxWidth > self.width)then		
		height = self.height - bar_height;
		_this=ParaUI.CreateUIObject("slider", self.name.."HScrollBar","_lb", 0, -bar_height, self.width,bar_height);
		parent:AddChild(_this);
		_this.onchange=string.format(";CommonCtrl.ScrollView.OnHScrollBarChanged(%q)", self.name);	
	end
	if(self._maxHeight > self.height)then
		width = self.width - bar_width;
		_this=ParaUI.CreateUIObject("scrollbar", self.name.."VScrollBar","_rt",-bar_width, 0, bar_width, height);
		parent:AddChild(_this);
		_this.onchange=string.format(";CommonCtrl.ScrollView.OnVScrollBarChanged(%q)", self.name);	
		_this:SetTrackRange(0,self._maxHeight);
		_this:SetPageSize(height);
		_this:SetStep(10);
	end
	_this = ParaUI.CreateUIObject("container", self.name.."container_left", "_lt", 0, 0,width, height);
	--_this.fastrender = false;
	parent:AddChild(_this);
	_h = 0;
	for k,v in ipairs(self._list) do		
		local height = v["height"];
		local name = v["name"]
		local obj = ParaUI.GetUIObject(name);	
		if(obj:IsValid())then
			obj.x = 0;
			obj.y = _h;
			_this:AddChild(obj);	
			_h = _h + height;
		end
	end
end
function ScrollView.OnHScrollBarChanged(sCtrlName)

end
function ScrollView.OnVScrollBarChanged(sCtrlName)

end