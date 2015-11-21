--[[
Title:
Author(s): 
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/KeyboardShortcut/KeyboardShortcut.lua");
-------------------------------------------------------
]]

local KeyboardShortcut = {
	name = "KeyboardShortcut_Page",
	page = nil,
	autoList = nil,
	keyLineBox = nil,
	commandFile = "config/commands.xml",
	-- 快捷键列表
	commands = nil,
	
	selectedItem = nil,
	-- 是否被打开
	isOpened = false,
};
CommonCtrl.KeyboardShortcut = KeyboardShortcut;

-- a singleton page
local page;

-- load default values.
function KeyboardShortcut.OnInit()
	page = document:GetPageCtrl();
	KeyboardShortcut.page = page;
	
	KeyboardShortcut.commands = KeyboardShortcut.DoParseFile();
	page.OnClose = KeyboardShortcut.DoClose;
end

function KeyboardShortcut.DoParseFile()
	local self = KeyboardShortcut;
	--if(System.options.version and System.options.version == "teen")then
		--self.commandFile = "config/commands.teen.xml";
	--end
	if(not ParaIO.DoesFileExist(self.commandFile,false)) then
		return {}
	end
	local xmlRoot = ParaXML.LuaXML_ParseFile(self.commandFile);
	if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
		xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
		NPL.load("(gl)script/ide/XPath.lua");	
		local result = {};
		for rootNode in commonlib.XPath.eachNode(xmlRoot, "//Items") do
			if(rootNode) then
				local child;
				for child in rootNode:next() do
					local key = child:GetString("key");
					local commandName = child:GetString("commandname");
					local params = child:GetString("params");
					local d = {Text = commandName, ShortcutKey = key, params = params};
					table.insert(result,d);
				end	
			end
		end	
		return result;
	end
end
function KeyboardShortcut.DoSaveFile()
	local self = KeyboardShortcut;
	if(self.commands)then
		local result = "\r\n";
		local k,item;
		for k,item in ipairs(self.commands) do
			local s = string.format([[<Item commandname="%s" key="%s" params='%s'/>]],item.Text,item.ShortcutKey or '',item.params or '');
			result = result..s.."\r\n";
		end
		result = "<Items>"..result.."</Items>"
		local file = ParaIO.open(self.commandFile, "w");
		if(file:IsValid()) then
			file:WriteString(result);
			file:close();
			
			-- reload
			NPL.load("(gl)script/kids/3DMapSystemApp/DebugApp/app_main.lua");
			Map3DSystem.App.Debug.DoLoadConfigFile();
			_guihelper.MessageBox("保存成功！");
		end
	end
end
function KeyboardShortcut.Show(params) 
	local _this = ParaUI.GetUIObject("container"..KeyboardShortcut.name);
	if(not _this:IsValid()) then
		_this = ParaUI.CreateUIObject("container", "container"..KeyboardShortcut.name, params.alignment, params.left, params.top, params.width, params.height);
		params.parent:AddChild(_this);	
		
		local parent = _this;
		NPL.load("(gl)script/ide/AutoCompleteList.lua");
		local ctl = CommonCtrl.AutoCompleteList:new{
			alignment = "_lt",
			left=0, top=0,
			width = params.width,
			height = 26,
			dropdownheight = params.height-26,
			parent = parent,
			--items = {
				--{Text = "d"},
				--{Text = "abc"},
				--{Text = "ad"},
				--{Text = "a"},
				--{Text = "a"},
			--},
			onselect = KeyboardShortcut.AutoCompleteList_Selected;
			DrawNodeHandler = CommonCtrl.KeyboardShortcut.DrawSingleSelectionNodeHandler,
		};
		ctl:SetDataSource(KeyboardShortcut.commands)
		ctl:Show();
		KeyboardShortcut.autoList = ctl;	
	end
end
function KeyboardShortcut.AutoCompleteList_Selected(item)
	local self = KeyboardShortcut;
	if(item)then
		local isCommand_txt = self.page:FindControl("isCommand_txt");
		if(isCommand_txt) then 
			local commandName = item.Text;
			local key = item.ShortcutKey;
			if(not key or key == "")then
				key = "无";
			end
			isCommand_txt:SetText(key);
			
		end
	end
	self.selectedItem = item;
end
function KeyboardShortcut.ShowKeyLineBox(params) 
	local self = KeyboardShortcut;
	local _this = ParaUI.GetUIObject("container"..KeyboardShortcut.name.."KeyLineBox");
	if(not _this:IsValid()) then
		_this = ParaUI.CreateUIObject("container", "container"..KeyboardShortcut.name.."KeyLineBox", params.alignment, params.left, params.top, params.width, params.height);
		params.parent:AddChild(_this);	
		
		local parent = _this;
		NPL.load("(gl)script/ide/KeyLineBox.lua");
		local ctl = CommonCtrl.KeyLineBox:new{
			alignment = "_lt",
			left=0, top=0,
			width = params.width,
			height = 26,
			parent = parent,
		};
		ctl:Show();
		KeyboardShortcut.keyLineBox = ctl;
	end
	self.isOpened = true;
end

function KeyboardShortcut.OnCancel()
	page:CloseWindow();	
end

-- call back function 
function KeyboardShortcut.DoClose()
	local self = KeyboardShortcut;
	self.isOpened = false;
end

function KeyboardShortcut.DoRemoveKey()
	local self = KeyboardShortcut;
	if(self.selectedItem)then
		local name = self.selectedItem["Text"];
		local key = self.selectedItem["ShortcutKey"];
		if(not key or key == "")then
			local s = string.format("命令[%s]没有快捷键！",name);
			_guihelper.MessageBox(s);
		else
			self.selectedItem["ShortcutKey"] = "";
			self.UpdateKey(self.selectedItem);
			local isCommand_txt = self.page:FindControl("isCommand_txt");
			if(isCommand_txt) then 
				isCommand_txt:SetText("无");
			end
			local s = string.format("命令[%s]快捷键移除成功！",name);
			_guihelper.MessageBox(s);
		end
	else
		_guihelper.MessageBox("请选中一条命令！");
	end
end
function KeyboardShortcut.DoReplaceKey()
	local self = KeyboardShortcut;
	if(self.selectedItem)then
		local name = self.selectedItem["Text"];
		local key = self.selectedItem["ShortcutKey"];
		if(self.keyLineBox)then
			local new_key = self.keyLineBox:GetText();
			if(not new_key or new_key == "")then
				_guihelper.MessageBox("请选择快捷键！");
			else
				self.selectedItem["ShortcutKey"] = new_key;
				self.UpdateKey(self.selectedItem);
				local s = string.format("命令[%s]的快捷键是[%s]！",name,new_key);
				_guihelper.MessageBox(s);
			end
		end
	else
		_guihelper.MessageBox("请选中一条命令！");
	end
end
function KeyboardShortcut.DoFindItemByKey()
	local self = KeyboardShortcut;
	if(self.keyLineBox)then
		local key = self.keyLineBox:GetText();
		local item = self.FindPrimitiveItemByKey(key);
		local usedBy_txt = self.page:FindControl("usedBy_txt");
		if(usedBy_txt)then
			if(item)then
				local t = item.Text or "无";
				usedBy_txt:SetText(t);
			else
				local t = "无";
				usedBy_txt:SetText(t);
			end
		end
	end
end
-- 更新快捷键
function KeyboardShortcut.UpdateKey(mirrorItem)
	local self = KeyboardShortcut;
	if(not mirrorItem)then return end;
	local item = self.FindPrimitiveItem(mirrorItem)
	if(item)then
		item["ShortcutKey"] = mirrorItem["ShortcutKey"];
	end
end
-- 查找真实的数据
function KeyboardShortcut.FindPrimitiveItem(mirrorItem)
	local self = KeyboardShortcut;
	if(not mirrorItem)then return end;
	local k,item;
	for k,item in ipairs(self.commands) do
		if(mirrorItem.Text == item.Text)then
			return item;
		end
	end
end
-- 查找快捷键是否被使用
function KeyboardShortcut.FindPrimitiveItemByKey(key)
	local self = KeyboardShortcut;
	if(not key or key == "")then return end;
	local k,item;
	for k,item in ipairs(self.commands) do
		if(key == item.ShortcutKey)then
			return item;
		end
	end
end
---------------------------------
function KeyboardShortcut.DrawSingleSelectionNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode:GetWidth() or treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.ShowIcon) then
		local IconSize = treeNode.TreeView.DefaultIconSize;
		if(treeNode.Icon~=nil and IconSize>0) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, (height-IconSize)/2 , IconSize, IconSize);
			_this.background = treeNode.Icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
		end	
		if(not treeNode.bSkipIconSpace) then
			left = left + IconSize;
		end	
	end	
	if(treeNode.TreeView.RootNode:GetHeight() > 0) then
		left = left + treeNode.TreeView.DefaultIndentation*treeNode.Level + 2;
	else
		left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-1) + 2;
	end	
	
	if(treeNode.Type=="Title") then
		_this=ParaUI.CreateUIObject("text","b","_lt", left, top , nodeWidth - left-2, height - 1);
		_parent:AddChild(_this);
		_this.background = "";
		_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
		_this.text = treeNode.Text;
	elseif(treeNode.Type=="separator") then
		_this=ParaUI.CreateUIObject("button","b","_mt", left, 2, 1, 1);
		_this.background = "Texture/whitedot.png";
		_this.enabled = false;
		_guihelper.SetUIColor(_this, "150 150 150 255");
		_parent:AddChild(_this);
	else
		if(treeNode:GetChildCount() > 0) then
			-- node that contains children. We shall display some
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top+6, 10, 10);
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
			if(treeNode.Expanded) then
				_this.background = "Texture/3DMapSystem/common/itemopen.png";
			else
				_this.background = "Texture/3DMapSystem/common/itemclosed.png";
			end
			_guihelper.SetUIColor(_this, "255 255 255");
			left = left + 16;
			
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top , nodeWidth - left-2, height - 1);
			_parent:AddChild(_this);
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
			
		elseif(treeNode.Text ~= nil) then
			-- node that text. We shall display text
			_this=ParaUI.CreateUIObject("button","b","_lt", left, 0 , nodeWidth - left-2, height - 1);
			_parent:AddChild(_this);
			if(treeNode.Selected) then
				_this.background = "Texture/alphadot.png";
			else
				_this.background = "";
				_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			end
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";CommonCtrl.TreeView.OnSelectNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			local txt = string.format("%s(%s)",treeNode.Text,treeNode.ShortcutKey);
			_this.text = txt;
		end
	end	
end