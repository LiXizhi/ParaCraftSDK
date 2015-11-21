--[[
Title: 
Author(s): Leio
Date: 2009/6/26
Note: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/AutoCompleteBox.lua");
local ctl = CommonCtrl.AutoCompleteBox:new{
	name = "AutoCompleteBox1",
	alignment = "_lt",
	left=0, top=0,
	width = 300,
	height = 26,
	parent = nil,
	items = {
		{Text = "d"},
		{Text = "abc"},
		{Text = "ad"},
		{Text = "a"},
		{Text = "a"},
	},
};
ctl:Show();
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local AutoCompleteBox = {
	-- the top level control name
	name = "AutoCompleteBox1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 26, 
	dropdownheight = 150, -- the drop down list box height.
	parent = nil,
	-- appearance
	container_bg = nil, -- the background of container that contains the editbox and the dropdown button.
	editbox_bg = nil, -- edit box background texture
	dropdownbutton_bg = "Texture/DropDownBox.png:4 5 4 5",-- drop down button background texture
	listbox_bg = nil, -- list box background texture
	
	selectedIndex = 0,
	items = {}, 
	pre_txt = nil,

	onselect= nil,
	DrawNodeHandler = nil,
}
CommonCtrl.AutoCompleteBox = AutoCompleteBox;

-- constructor
function AutoCompleteBox:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o:Init();
	return o
end
function AutoCompleteBox:Init()
	self.name = ParaGlobal.GenerateUniqueID();
	CommonCtrl.AddControl(self.name, self);
	self:SortItems();
end
function AutoCompleteBox:GetRect()
	local w = self.width;
	local h = self.height + self.dropdownheight;
	return {w = w, h = h};
end
function AutoCompleteBox:Show(bShow)
	self:__Show(bShow);
end
function AutoCompleteBox:__Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("AutoCompleteBox instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false and bShow ~= false) then
		local rect = self:GetRect();
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,rect.w or self.width,rect.h or self.height);
		if(self.container_bg~=nil) then
			_this.background=self.container_bg;
		else
			_this.background="Texture/whitedot.png;0 0 0 0";
		end	
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		_parent = _this;
		-- create the editbox
		_this=ParaUI.CreateUIObject("imeeditbox",self.name.."input", "_lt",0,0,self.width,self.height);
		_parent:AddChild(_this);
		_this.onchange=string.format([[;CommonCtrl.AutoCompleteBox.OnLostFocus("%s");]], self.name);
		_this.onkeyup=string.format([[;CommonCtrl.AutoCompleteBox.OnKeyUp("%s");]], self.name);
		if(self.editbox_bg~=nil) then
			_this.background=self.editbox_bg;
		end	
		
		_this=ParaUI.CreateUIObject("container",self.name.."listContainer","_lt",0,self.height,self.width,self.dropdownheight);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
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
-------------------------------------------- control list
function AutoCompleteBox:ShowList()
	self.selectedIndex = 0;
	self:InitList();
	self:Update();
end
function AutoCompleteBox:Update()
	local tree = CommonCtrl.GetControl(self.name.."TreeView1");
	if(tree)then
		local result = self:FilterItems();
		local len = 0;
		if(result)then
			len = #result;
		end
		local root_node = tree.RootNode;
		root_node:ClearAllChildren();
		if(len > 0)then
			self:SetLineCount(#result);		
			local k,item;
			for k,item in ipairs(result) do
				local item_clone = commonlib.deepcopy(item);
				local node = CommonCtrl.TreeNode:new(item_clone);
				node.onclick = AutoCompleteBox.DoSelectedItem;
				node.autoCompleteBox = self;
				root_node:AddChild(node);
			end		
		end
		tree:Update();
		tree:Show(true);
	end
end
function AutoCompleteBox:InitList()
	local name = self.name.."list";
	local _this = ParaUI.GetUIObject(name);
	if(_this:IsValid() == false) then
		local _parent = ParaUI.GetUIObject(self.name.."listContainer");
		_this=ParaUI.CreateUIObject("container",name,"_fi",0,0,0,0);
		_this.background="Texture/whitedot.png;0 0 0 0";
		if(_parent:IsValid())then
			_parent:AddChild(_this);
		else
			_this:AttachToRoot();
		end
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = self.name.."TreeView1",
			alignment = "_fi",
			left=0, top=0,
			width = 0,
			height = 0,
			parent = _this,
			ShowIcon = false,
			DrawNodeHandler = self.DrawNodeHandler or CommonCtrl.TreeView.DrawSingleSelectionNodeHandler,
		};
		CommonCtrl.AddControl(self.name.."TreeView1", ctl);
	end
end
function AutoCompleteBox:CloseList()
	local tree = CommonCtrl.GetControl(self.name.."TreeView1");
	if(tree)then
		local root_node = tree.RootNode;
		root_node:ClearAllChildren();
		tree:Update();
		tree:Show(false);
	end
	self:Reset();
end
function AutoCompleteBox:SortItems()
	local compareFunc = CommonCtrl.TreeNode.GenerateLessCFByField("Text");
	-- quick sort
	table.sort(self.items, compareFunc)
end
function AutoCompleteBox:SetDataSource(v)
	if(not v)then return end
	self.items = v;
	self:SortItems();
end
function AutoCompleteBox:SetText(txt)
	local input = ParaUI.GetUIObject(self.name.."input");
	if(input)then
		local last_caret = self:GetCaretPosition();
		input.text = txt;
		local caretPos = input:GetTextSize();
		if(last_caret > caretPos)then
			last_caret = caretPos;
		end
		self:SetCaretPosition(last_caret);		
	end
end
function AutoCompleteBox:GetText()
	local input = ParaUI.GetUIObject(self.name.."input");
	if(input)then
		return input.text;
	end
end
function AutoCompleteBox:FilterItems()
	local txt = self:GetText();
	txt = tostring(txt);
	if(not txt or txt == "")then
			return nil;
	else
			local result = {};
			local low_txt = string.lower(txt);
			local k,item;
			for k,item in ipairs(self.items) do
				local label = item["Text"];
				local low_label = string.lower(label);
				if(string.find(low_label,low_txt))then
					table.insert(result,item);
				end
			end
			return result;
	end
end
function AutoCompleteBox.OnLostFocus(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	--_guihelper.MessageBox("!!");
end
function AutoCompleteBox.OnKeyUp(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self)then
			local line_count = self:GetLineCount(); 
			if(virtual_key == Event_Mapping.EM_KEY_DOWN)then
				if(self.selectedIndex < line_count)then
					self.selectedIndex = self.selectedIndex + 1;
					self:SelectedNode();
				end
			elseif(virtual_key == Event_Mapping.EM_KEY_UP)then
				if(self.selectedIndex > 1)then
					self.selectedIndex = self.selectedIndex - 1;
					self:SelectedNode();
				end
			elseif(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER)then
				local tree, lineNode = self:GetCtrlAndLineNode(self.selectedIndex);
				if(lineNode)then
					AutoCompleteBox.DoSelectedItem(lineNode)
				end
			elseif(virtual_key == Event_Mapping.EM_KEY_LEFT or virtual_key == Event_Mapping.EM_KEY_RIGHT)then
				-- do nothing
			else
				local txt = self:GetText();
				if(self.pre_txt ~= txt)then
					self.pre_txt = txt;
					self:ShowList();	
				end
			end
			
	end
end
function AutoCompleteBox:SetLineCount(n)
	self.lineCount = n;
end
function AutoCompleteBox:GetLineCount()
	return self.lineCount or 0;
end
function AutoCompleteBox:SetCaretPosition(caretPosition)
	local thisLine = ParaUI.GetUIObject(self.name.."input");
	if(thisLine:IsValid())then
		thisLine:Focus();
		thisLine:SetCaretPosition(caretPosition);
	end
end
function AutoCompleteBox:GetCaretPosition()
	local thisLine = ParaUI.GetUIObject(self.name.."input");
	if(thisLine:IsValid())then
		return thisLine:GetCaretPosition();
	end
end
function AutoCompleteBox.DoSelectedItem(node)
	if(node and node.autoCompleteBox)then
		local self = node.autoCompleteBox;
		local txt = node["Text"];
		self:SetText(txt);
		if(self.onselect)then
			self.onselect(node);
		end
		self:CloseList();
	end
end
function AutoCompleteBox:SelectedNode()
	local tree, lineNode = self:GetCtrlAndLineNode(self.selectedIndex);
	if(lineNode) then
		lineNode:SelectMe();
		-- update and auto scroll to position. 
		tree:Update(nil, lineNode);
		local txt = lineNode["Text"];
		self:SetText(txt);
		if(self.onselect)then
			self.onselect(lineNode);
		end
	end
end
function AutoCompleteBox:GetCtrlAndLineNode(nLineIndex)
	local tree = CommonCtrl.GetControl(self.name.."TreeView1");
	if(tree)then
		local lineNode = tree.RootNode:GetChild(nLineIndex);
		return tree, lineNode;
	end
end	
function AutoCompleteBox:Reset()
	self.selectedIndex = 0;
	self.pre_txt = nil;
	self.lineCount = 0;
end
-------------------
