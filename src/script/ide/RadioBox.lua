--[[
Title: a RadioBox control using a button and a text; automatically group radio buttons by parent.
Author(s):LiXizhi
Date : 2007.4.2
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/RadioBox.lua");
local ctl = CommonCtrl.radiobox:new{
	name = "radiobox1",
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
-- call later on
ctl:GetCheck();
ctl:SetCheck(true);
-- alternatively call following by any radiobox in a group
ctl:SetSelectedIndex(index);
ctl:GetSelectedIndex();
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/common_control.lua");

local radiobox = {
	-- name 
	name = "radiobox1",
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
	-- appearance
	checked_bg = "Texture/radiobox.png",
	unchecked_bg = "Texture/unradiobox.png",
	-- group which contains a list of <radiobutton_name, true>, automatically assigned upon creation.
	buttongroup = nil;
	-- private: automatically assigned from 1 according to the order radio boxes are added to a parent control.
	IndexInGroup = nil,
	-- oncheck event, it can be nil, a string to be executed or a function of type void ()(sCtrlName, checked)
	oncheck = nil,
}
CommonCtrl.radiobox = radiobox;


-----------------------------
-- for group management
-----------------------------
-- groupinfo, contains the {<parentName, {<radioboxname>, true}>}
CommonCtrl.radiobuttonGroups = {};

-- return the group object and the index of this radio starting from 1. 
function CommonCtrl.radiobuttonGroups.AddRadioboxToGroup(radioboxname, groupname)
	local group = CommonCtrl.radiobuttonGroups[groupname];
	if(group == nil) then
		group = {};
		CommonCtrl.radiobuttonGroups[groupname] = group;
	end
	local i, v
	for i,v in ipairs(group) do
		if(v == radioboxname) then
			return group, i;
		end
	end
	local nSize = table.getn(group)+1;
	group[nSize] = radioboxname;
	return group, nSize;
end

function CommonCtrl.radiobuttonGroups.RemoveRadioboxGroup(groupname)
	CommonCtrl.radiobuttonGroups[groupname]  = nil;
end

-----------------------------
-- for radiobox group
-----------------------------
function radiobox:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function radiobox:Destroy ()
	ParaUI.Destroy(self.name);
end

function radiobox:Show(bShow)
	local _this,_parent;
	if(self.name == nil)then
		log("radiobox instance name can not be nil -_-b \r\n");
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		_this = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background = "";
		_parent = _this;
		
		if(self.parent == nil)then
			_this:AttachToRoot();
			self.buttongroup, self.IndexInGroup = CommonCtrl.radiobuttonGroups.AddRadioboxToGroup(self.name, "root");
		else
			self.parent:AddChild(_this);
			self.buttongroup, self.IndexInGroup = CommonCtrl.radiobuttonGroups.AddRadioboxToGroup(self.name, self.parent.name);
		end
		
		CommonCtrl.AddControl(self.name,self);
		
		_this = ParaUI.CreateUIObject("button",self.name.."btnCheck","_lt",0,0,self.height,self.height);
		_this.onclick = string.format([[;CommonCtrl.radiobox.OnCheck("%s");]],self.name);
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button",self.name.."txtCheck","_mt",self.height+3,0, 0, self.height);
		_this.background = "";
		_guihelper.SetUIFontFormat(_this, 0);-- make text align to left
		_this.onclick = string.format([[;CommonCtrl.radiobox.OnCheck("%s");]],self.name);
		_this.text = self.text;
		_parent:AddChild(_this);
		
		-- update the control
		self:SetCheck(self.isChecked);
	else
		if(bShow == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bShow;
		end		
	end
end

-- get the isChecked property
function radiobox:GetCheck()
	return self.isChecked;
end

-- set the check property
function radiobox:SetCheck(bChecked)
	self.isChecked = bChecked;
	
	-- update appearance.
	local _this = ParaUI.GetUIObject(self.name.."btnCheck");
	if(_this:IsValid() == false)then
		log("err getting radiobox instance "..self.name.."\r\n");
		return;
	end;
	
	if(self.isChecked)then
		_this.background = self.checked_bg;
		
		-- uncheck all other buttons in the same group.
		if(self.buttongroup~=nil) then
			local i,v;
			for i,v in ipairs(self.buttongroup) do
				if(v~=self.name) then
					local otherRadiobox= CommonCtrl.GetControl(v);
					if(otherRadiobox ~= nil)then
						otherRadiobox:SetCheck(false);
					end
				else
					self.buttongroup.SelectedIndex = i;	
				end
			end
		end	
	else
		_this.background = self.unchecked_bg;
		if(self.buttongroup~=nil) then
			if(self.buttongroup.SelectedIndex == self.IndexInGroup) then
				self.buttongroup.SelectedIndex = nil;
			end
		end
	end;
end

-- set the text property
function radiobox:SetText(text)
	self.text = text;
	-- update appearance.
	local _this = ParaUI.GetUIObject(self.name.."txtCheck");
	if(_this:IsValid() == false)then
		log("err getting radiobox instance"..self.name.."\r\n");
		return;
	end;
	_this.text = self.text;
end

-- called when the check button is pressed.
function radiobox.OnCheck(ctrName)
	local self = CommonCtrl.GetControl(ctrName);
	if(self == nil)then
		log("err getting radiobox instance"..ctrName.." -_-b \r\n");
		return;
	end

	self:SetCheck(true);
	
	-- call the event handler if any
	if(self.oncheck~=nil)then
		if(type(self.oncheck) == "string") then
			NPL.DoString(self.oncheck);
		else
			self.oncheck(self.name, true);
		end
	end
end	

-- return the index of the current selected radio box in the group. 
function radiobox:GetSelectedIndex()
	if(self.buttongroup~=nil) then
		return self.buttongroup.SelectedIndex;
	end
end

-- set a radio button by its index. 
function radiobox:SetSelectedIndex(index)
	-- uncheck all other buttons in the same group.
	if(self.buttongroup~=nil) then
		local name = self.buttongroup[index];
		if(name~=nil) then
			local otherRadiobox = CommonCtrl.GetControl(name);
			if(otherRadiobox ~= nil)then
				otherRadiobox:SetCheck(true);
			end
		else
			-- deselect all. 
			local i,v;
			for i,v in ipairs(self.buttongroup) do
				local otherRadiobox= CommonCtrl.GetControl(v);
				if(otherRadiobox ~= nil)then
					otherRadiobox:SetCheck(false);
				end
			end
		end	
		self.buttongroup.SelectedIndex = index;
	end	
end
		
		