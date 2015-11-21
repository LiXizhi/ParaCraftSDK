--[[
Title: drop-down-listbox control
Author(s): Liuweili
Date: 2006/6/8
Desc: CommonCtrl.CCtrlDropdownListBox displays popup-menu containing some specified buttons.
IMPORTANT: Please beware that this control does not appear correctly when some other containers overlap it.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/dropdownlistbox_control.lua");
local ctl = CommonCtrl.CCtrlDropdownListBox:new ();
ctl.name = "dropdownlistbox";
ctl.defaulttext="select something";
--show position x,y and if the menu is autodelete
ctl:Show();
list={"1","2","3"};
ctl:UpdateItemlist(list);
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local CCtrlDropdownListBox = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 170,
	height = 25,
	lbheight = 170,
	items = {},
	size = 0,
	defaulttext = "",
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- the top level control name
	name = "defaultdropdownlistbox",
	-- onchange event, it can be nil, a string to be executed or a function of type void ()(sCtrlName)
	onselect= nil
}
CommonCtrl.CCtrlDropdownListBox = CCtrlDropdownListBox;

-- constructor
function CCtrlDropdownListBox:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function CCtrlDropdownListBox:Destroy ()
	ParaUI.Destroy(self.name);
end

--[[ update the value displayed in 
@param sCtrlName: if nil, the current control will be used. if not the given control is updated. ]]
function CCtrlDropdownListBox.Update(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(sCtrlName.." err getting CCtrlDropdownListBox control in update \n");
		return;
	end
	local lname=self.name.."_listbox";
	local tname=self.name.."_text";
	local _this,_that;
	_this=ParaUI.GetUIObject(lname);
	_that=ParaUI.GetUIObject(tname);
	if(_this:IsValid() and _that:IsValid())then 
		_that.text=_this.text;
	end	
	if(self.onselect~=nil)then
		if(type(self.onselect) == "string") then
			NPL.DoString(self.onselect);
		else
			self.onselect(sCtrlName);
		end
	end
end

--[[only call this function when the show() method is called. ]]
function CCtrlDropdownListBox:UpdateItemlist(list)
	self.items=list;
	size=table.getn(list);
	local lname=self.name.."_listbox";
	local _this;
	_this=ParaUI.GetUIObject(lname);
	if(_this:IsValid())then 
		_this:RemoveAll();
		local index,value=next(self.items);
		while(index~=nil)do
			_this:AddTextItem(tostring(value));
			index,value=next(self.items,index);
		end
	end
	--CCtrlDropdownListBox:Update(self.name);
end

--returns the text of the selected item, return "" if nothing is selected.
function CCtrlDropdownListBox:getSelection()
	local tname=self.name.."_text";
	local _this;
	_this=ParaUI.GetUIObject(tname);
	if(_this:IsValid())then 
		return _this.text;
	end
	return "";
end

--show or hide the given control
function CCtrlDropdownListBox:ShowHideListbox(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log(sCtrlName.." err getting ShowHideListbox control in ShowHideListbox\n");
		return;
	end
	local lname=self.name.."_listbox";
	local _this=ParaUI.GetUIObject(lname);
	if(_this:IsValid())then 
		_this.visible=not _this.visible;
	end		
end

function CCtrlDropdownListBox:Show()
	local _this,_parent;
	if(self.name==nil)then
		log("err showing CCtrlDropdownListBox\r\n");
	end
	local ctname=self.name;
	local lname=self.name.."_listbox";
	local tname=self.name.."_text";
	local bname=self.name.."_button";
	_this=ParaUI.CreateUIObject("container",ctname,self.alignment,self.left,self.top,self.width,self.height);
	_this.background="Texture/dxutcontrols.dds;0 0 0 0";
	
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
	_this=ParaUI.CreateUIObject("text",tname,"_lt",left,top,self.width-25,self.height);
	_parent:AddChild(_this);
	_this.text=self.defaulttext;
	_this.background="Texture/box.png;";
	_this.autosize=false;
	_this=ParaUI.CreateUIObject("button",bname,"_lt",left+self.width-25,top,25,self.height);
	_parent:AddChild(_this);
	_this.background="Texture/skill/arr_down.png;";
	_this.onclick=string.format([[;CommonCtrl.CCtrlDropdownListBox:ShowHideListbox("%s");]], self.name);
	_this=ParaUI.CreateUIObject("listbox",lname,"_lt",left,top+self.height,self.width,self.lbheight);
	_this:AttachToRoot();
	_this.visible=false;
	_this.onselect=string.format([[;CommonCtrl.CCtrlDropdownListBox.Update("%s");CommonCtrl.CCtrlDropdownListBox:ShowHideListbox("%s");]], self.name, self.name);
end
