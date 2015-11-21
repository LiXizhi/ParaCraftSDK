--[[
Title: popup-menu control
Author(s): Liuweili
Date: 2006/6/8
Desc: CommonCtrl.CCtrlPopupMenu displays popup-menu containing some specified buttons
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/popupmenu_control.lua");
local ctl = CommonCtrl.CCtrlPopupMenu:new ();
ctl:addItem("caption","x.text = \"dd\"");
ctl.name = "popmenu";
--show position x,y and if the menu is autodelete
ctl:Show(100,100,false);
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local CCtrlPopupMenu = {
	-- normal window size
	alignment = "_lt",
	itemwidth = 50,
	itemheight = 25,
	width=100,
	heigth=100,
	items = {},
	--the number of items
	size = 0,
	-- the top level control name
	name = "defaultpopupmenu",
	autodelete = false,
	--if the menu is deleted. do NOT modified this value
	deleted = false
}
CommonCtrl.CCtrlPopupMenu = CCtrlPopupMenu;

-- constructor
function CCtrlPopupMenu:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function CCtrlPopupMenu:Destroy ()
	ParaUI.Destroy(self.name);
end
--@param caption: the text you want to display on the button
--@param event: the button's onclick event;
function CCtrlPopupMenu:addItem(caption,event)
	local text,script;
	if(caption==nil)then
		text=tostring(self.size);
	else
		text=caption;
	end
	if(event==nil)then
		script="";
	else
		script=";"..event;
	end
	self.items[self.size]={};
	self.items[self.size].caption=text;
	self.items[self.size].script=script;
	self.size=self.size+1;
	
end

--@param x,y: the position where the popup menu is shown
--@param autodelete: if the control is autodelted. if true, remember that the UI object is physically deleted. So Show() the same control will not do anything.
function CCtrlPopupMenu:Show(x,y,autodelete)
	local _this,_parent;
	if(self.deleted)then
		return;
	end
	if(self.name==nil)then
		ParaGlobal.WriteToLogFile("err");	
	end	
	self.autodelete=autodelete;
	local UIObject = ParaUI.GetUIObject(self.name);
	if(UIObject:IsValid() == true) then
		UIObject.visible=true;
		UIObject.x=x;
		UIObject.y=y;
		UIObject:Focus();
		if(autodelete)then
			for i=0, self.size-1 do
				_this=ParaUI.GetUIObject(string.format([[%s_%d]],self.name,i));
				if(_this:IsValid())then
					_this.onclick=self.items[i].script..string.format([[local _this=ParaUI.GetUIObject("%s");if(_this:IsValid())then _this:LostFocus();end;_this=CommonCtrl.GetControl("%s");if(_this~=nil)then _this.deleted=true;end;]],self.name,self.name);
				end
			end
		end
	else
		local width=self.itemwidth+2;
		local height=self.itemheight*self.size+2;
		self.width=width;
		self.height=height;
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,x,y,width,height);
		UIObject = _this;
		_this:AttachToRoot();
		CommonCtrl.AddControl(self.name, self);
		local left,top;
		left=1;top=1;
		_parent=_this;
		for i=0, self.size-1 do
			_this=ParaUI.CreateUIObject("button",string.format([[%s_%d]],self.name,i),"_lt",left,top,self.itemwidth,self.itemheight);
			_parent:AddChild(_this);
			_this.text=self.items[i].caption;
			if(autodelete)then
				_this.onclick=self.items[i].script..string.format([[local _this=ParaUI.GetUIObject("%s");if(_this:IsValid())then _this:LostFocus();end;_this=CommonCtrl.GetControl("%s");if(_this~=nil)then _this.deleted=true;end;]],self.name,self.name);
			else
				_this.onclick=self.items[i].script..string.format([[local _this=ParaUI.GetUIObject("%s");if(_this:IsValid())then _this:LostFocus();end;]],self.name);
			
			end
			top=top+self.itemheight;
		end
	end
	if(autodelete)then
		UIObject.popup=2;
	else
		UIObject.popup=1;
	end
end


