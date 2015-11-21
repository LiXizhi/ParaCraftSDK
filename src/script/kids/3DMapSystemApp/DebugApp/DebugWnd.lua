--[[
Title: Debug window of a given user
Author(s): LiXizhi
Date: 2008/1/21
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/DebugApp/DebugWnd.lua");
Map3DSystem.App.Debug.ShowDebugWnd(app);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

commonlib.setfield("Map3DSystem.App.Debug.DebugWnd", {});

-- display the main Debug window for the current user.
function Map3DSystem.App.Debug.ShowDebugWnd(_app)
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _wnd = _app:FindWindow("DebugWnd") or _app:RegisterWindow("DebugWnd", nil, Map3DSystem.App.Debug.DebugWnd.MSGProc);
	
	local _wndFrame = _wnd:GetWindowFrame();
	if(not _wndFrame) then
		_wndFrame = _wnd:CreateWindowFrame{
			icon = "Texture/3DMapSystem/common/script_gear.png",
			text = "调试工具",
			initialPosX = 200,
			initialPosY = 150,
			initialWidth = 640,
			initialHeight = 370,
			allowDrag = true,
			zorder = 1005,
			ShowUICallback =Map3DSystem.App.Debug.DebugWnd.Show,
		};
	end
	_wnd:ShowWindowFrame(true);
end



--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
-- @param _parent: parent window inside which the content is displayed. it can be nil.
function Map3DSystem.App.Debug.DebugWnd.Show(bShow, _parent, parentWindow)
	local _this;
	Map3DSystem.App.Debug.DebugWnd.parentWindow = parentWindow;
	
	_this=ParaUI.GetUIObject("DebugWnd_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		if(_parent==nil) then
			_this=ParaUI.CreateUIObject("container","DebugWnd_cont","_lt",0,50, 150, 300);
			_this:AttachToRoot();
		else
			_this = ParaUI.CreateUIObject("container", "DebugWnd_cont", "_fi",0,0,0,0);
			_this.background = ""
			_parent:AddChild(_this);
		end	
		_parent = _this;

		-- TODO: implement each one. 
		_this = ParaUI.CreateUIObject("button", "button1", "_rt", -147, 4, 69, 23)
		_this.text = "file...";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button6", "_rt", -72, 4, 69, 23)
		_this.text = "Load";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "RunCode", "_lt", 145, 31, 88, 23)
		_this.text = "Run Code";
		_this.onclick = ";Map3DSystem.App.Debug.DebugWnd.OnClickRunCode();"
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button7", "_lt", 239, 31, 88, 23)
		_this.text = "Clear";
		_this.onclick = ";Map3DSystem.App.Debug.DebugWnd.OnClickClearCode();"
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button7", "_lt", 333, 31, 88, 23)
		_this.text = "Save ...";
		_this.onclick = ";Map3DSystem.App.Debug.DebugWnd.OnClickSaveCode();"
		_parent:AddChild(_this);
		

		_this = ParaUI.CreateUIObject("button", "button3", "_rt", -147, 258, 69, 23)
		_this.text = "view";
		_this.onclick = ";Map3DSystem.App.Debug.DebugWnd.OnClickViewVariable();"
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button5", "_rt", -72, 258, 69, 23)
		_this.text = "add";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label8", "_lt", 3, 7, 79, 15)
		_this.text = "NPL.load:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label10", "_lt", 3, 35, 111, 15)
		_this.text = "NPL.Dostring:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label7", "_lt", 3, 260, 71, 15)
		_this.text = "Watcher:";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "comboBoxDebugLoadFile",
			alignment = "_mt",
			left = 145,
			top = 4,
			width = 153,
			height = 23,
			dropdownheight = 106,
 			parent = _parent,
			text = "",
			items = {"",},
		};
		ctl:Show();

		-- history files. 
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "treeViewDebugDostringHistory",
			alignment = "_lt",
			left = 6,
			top = 60,
			width = 130,
			height = 186,
			parent = _parent,
			DefaultNodeHeight = 18,
			ShowIcon = false,
			container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
			onclick = Map3DSystem.App.Debug.DebugWnd.OnClickDoCodeHistoryTreeNode,
			DrawNodeHandler = Map3DSystem.App.Debug.DebugWnd.DrawDoCodeFilesNodeHandler,
		};
		local node = ctl.RootNode;
		
		ctl:Show();

		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "treeViewWatcher",
			alignment = "_ml",
			left = 6,
			top = 287,
			width = 130,
			height = 3,
			parent = _parent,
			DefaultIndentation = 19,
			DefaultNodeHeight = 18,
			container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
		};
		local node = ctl.RootNode;
		ctl:Show();

		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "treeViewVariableDetailView",
			alignment = "_fi",
			left = 145,
			top = 287,
			width = 3,
			height = 3,
			parent = _parent,
			DefaultIndentation = 19,
			DefaultNodeHeight = 18,
			container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
		};
		local node = ctl.RootNode;
		ctl:Show();

		NPL.load("(gl)script/ide/MultiLineEditbox.lua");
		local ctl = CommonCtrl.MultiLineEditbox:new{
			name = "Debug.DebugWnd.textBoxDebugCode",
			alignment = "_mt",
			left = 145,
			top = 60,
			width = 3,
			height = 186,
			WordWrap = false,
			parent = _parent,
			ShowLineNumber = true,
			syntax_map = CommonCtrl.MultiLineEditbox.syntax_map_NPL,
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("editbox", "VariableName", "_mt", 145, 257, 153, 24)
		_parent:AddChild(_this);
		
		-- update all
		Map3DSystem.App.Debug.DebugWnd.UpdateHistoryDoCodeFiles()
		-- open last run code in code view
		Map3DSystem.App.Debug.DebugWnd.OnOpenCodeFile("lastcode.txt", true);
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		
		_parent = _this;
	end	
	if(bShow) then
	else	
	end
end

----------------------------------------------------------
-- do code related
----------------------------------------------------------

-- load all history do code files under the current file
function Map3DSystem.App.Debug.DebugWnd.UpdateHistoryDoCodeFiles()
	local ctl = CommonCtrl.GetControl("treeViewDebugDostringHistory");
	if(ctl==nil)then
		log("error getting TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local node = ctl.RootNode;
	node:ClearAllChildren();
	node = node:AddChild(CommonCtrl.TreeNode:new({Name = "History", Text = "History code", }))
	local files = {};
	commonlib.SearchFiles(files, Map3DSystem.App.Debug.app:GetAppDirectory(), "*.txt", 0, 150, true)
	
	local i, file
	for i, file in ipairs(files) do
		local _,_, filename = string.find(file, "(%w+)%.txt$");
		node:AddChild(CommonCtrl.TreeNode:new({Name = filename, Text = filename, filepath = file, type = "CodeFile"}))
	end
	ctl:Update();
end

-- save code to file. 
-- @param filename: nil or file name to save as. If nil, the first 20 letters from the code is used as file name
function Map3DSystem.App.Debug.DebugWnd.OnClickSaveCode(filename)
	local _parent=ParaUI.GetUIObject("DebugWnd_cont");
	if(_parent:IsValid()==true) then
		local ctl = CommonCtrl.GetControl("Debug.DebugWnd.textBoxDebugCode");
		if(ctl~=nil)then
			local text = ctl:GetText();
			
			local filename = filename or string.sub(text, 1, 50);
			filename = string.gsub(filename, "%A", "");
			filename = string.sub(filename, 1, 20);
			if(filename~="") then
				local fileObj = Map3DSystem.App.Debug.app:openfile(filename..".txt", "w");
				if(fileObj:IsValid()) then
					fileObj:WriteString(text);
				end	
				fileObj:close();
				Map3DSystem.App.Debug.DebugWnd.UpdateHistoryDoCodeFiles()
			else
				_guihelper.MessageBox("Can not save empty code.\n")	
			end	
		end
	end
end

-- click the file node to open the file in the do code text window
function Map3DSystem.App.Debug.DebugWnd.OnClickDoCodeHistoryTreeNode(treeNode)
	if(treeNode.type == "CodeFile") then
		-- open treeNode.filepath
		Map3DSystem.App.Debug.DebugWnd.OnOpenCodeFile(treeNode.filepath)
	end
end

-- open file in code view. 
-- @param NoMessage: usually nil. if true, no message is displayed for failed open file.
function Map3DSystem.App.Debug.DebugWnd.OnOpenCodeFile(filepath, NoMessage)
	local fileObj = Map3DSystem.App.Debug.app:openfile(filepath, "r");
	if(fileObj:IsValid()) then
		local ctl = CommonCtrl.GetControl("Debug.DebugWnd.textBoxDebugCode");
		if(ctl~=nil)then
			ctl:SetText(fileObj:GetText());
		end
		fileObj:close();
	elseif(not NoMessage) then
		_guihelper.MessageBox("Unable to open file "..filepath);
	end	
end

-- execute the code in the code window
function Map3DSystem.App.Debug.DebugWnd.OnClickRunCode()
	local _parent=ParaUI.GetUIObject("DebugWnd_cont");
	if(_parent:IsValid()==true) then
		local ctl = CommonCtrl.GetControl("Debug.DebugWnd.textBoxDebugCode");
		if(ctl~=nil)then
			Map3DSystem.App.Debug.DebugWnd.OnClickSaveCode("lastcode");
			NPL.DoString(ctl:GetText());
		end
	end
end
-- clear all the code in the code window.
function Map3DSystem.App.Debug.DebugWnd.OnClickClearCode()
	local _parent=ParaUI.GetUIObject("DebugWnd_cont");
	if(_parent:IsValid()==true) then
		local ctl = CommonCtrl.GetControl("Debug.DebugWnd.textBoxDebugCode");
		if(ctl~=nil)then
			ctl:SetText("");
		end
	end
end

-- delete the do code file node as well as its file. 
function Map3DSystem.App.Debug.DebugWnd.OnDeleteDoCodeFileNode(sCtrlName, nodePath)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's TreeView instance "..sCtrlName.."\r\n");
		return;
	end
	local node = self:GetNodeByPath(nodePath);
	if(node ~= nil) then
		-- call the event handler if any
		_guihelper.MessageBox("Are you sure you want to delete the file: "..node.filepath.."?",  function ()
			ParaIO.DeleteFile(Map3DSystem.App.Debug.app:GetAppDirectory()..node.filepath);
			Map3DSystem.App.Debug.DebugWnd.UpdateHistoryDoCodeFiles();
		end)
	end
end

-- default node renderer: it display a clickable check box for expandable node, followed by node text
function Map3DSystem.App.Debug.DebugWnd.DrawDoCodeFilesNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2; -- indentation of this node. 
	local top = 2;
	local height = treeNode:GetHeight();
	local nodeWidth = treeNode.TreeView.ClientWidth;
	
	if(treeNode.TreeView.ShowIcon) then
		local IconSize = treeNode.TreeView.DefaultIconSize;
		if(treeNode.Icon~=nil and IconSize>0) then
			_this=ParaUI.CreateUIObject("button","b","_lt", left, top , IconSize, IconSize);
			_this.background = treeNode.Icon;
			_guihelper.SetUIColor(_this, "255 255 255");
			_parent:AddChild(_this);
		end	
		left = left + IconSize;
	end	
	
	-- left = left + treeNode.TreeView.DefaultIndentation*(treeNode.Level-2) + 2;
	
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
			_this=ParaUI.CreateUIObject("button","b","_lt", left, 0, 16, 16);
			_this.onclick = string.format(";CommonCtrl.TreeView.OnToggleNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_parent:AddChild(_this);
			if(treeNode.Expanded) then
				_this.background = "Texture/3DMapSystem/common/Folder_open.png";
			else
				_this.background = "Texture/3DMapSystem/common/Folder.png";
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
			if(treeNode.type == "CodeFile") then
				-- delete file mark
				_this=ParaUI.CreateUIObject("button","b","_lt", left, 0 , 16, 16);
				_parent:AddChild(_this);
				_this.background = "Texture/3DMapSystem/common/delete.png";
				_this.tooltip = "delete script";
				_this.onclick = string.format(";Map3DSystem.App.Debug.DebugWnd.OnDeleteDoCodeFileNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
				left = left + 16;
			end	
			
			_this=ParaUI.CreateUIObject("button","b","_fi", left, 0, 0, 0);
			_parent:AddChild(_this);
			_this.background = "";
			_guihelper.SetVistaStyleButton(_this, nil, "Texture/alphadot.png");
			
			_guihelper.SetUIFontFormat(_this, 36); -- single line and vertical align
			_this.onclick = string.format(";CommonCtrl.TreeView.OnClickNode(%q, %q)", treeNode.TreeView.name, treeNode:GetNodePath());
			_this.text = treeNode.Text;
			_this.tooltip = treeNode.Text;
		end
	end	
end

----------------------------------------------------------
-- watcher related
----------------------------------------------------------

function Map3DSystem.App.Debug.DebugWnd.OnClickViewVariable()
	local _parent=ParaUI.GetUIObject("DebugWnd_cont");
	if(_parent:IsValid() == true) then
		local _this = _parent:GetChild("VariableName");
		local sV = _this.text;
		
		Map3DSystem.App.Debug.DebugWnd.tmpVar = nil;
		NPL.DoString("Map3DSystem.App.Debug.DebugWnd.tmpVar="..sV);
		local VariableName = Map3DSystem.App.Debug.DebugWnd.tmpVar;
		if(VariableName~=nil) then
			_guihelper.MessageBox(sV.." = \n"..commonlib.serialize(VariableName));
			-- TODO: display in a tree view with auto expand in future. 
		end
	end
end


function Map3DSystem.App.Debug.DebugWnd.MSGProc(window, msg)
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		window:ShowWindowFrame(false);
	end
end