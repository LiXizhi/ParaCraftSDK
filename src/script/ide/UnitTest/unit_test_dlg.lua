--[[
Title: a UI for running test case file
Author: LiXizhi
Date : 2008.3.5
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/UnitTest/unit_test_dlg.lua");
local ctl = CommonCtrl.UnitTestDlg:new{
	name = "UnitTestDlg",
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 600,
	height = 450,
	parent = nil,
};
ctl:Show();
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/UnitTest/unit_test.lua");
NPL.load("(gl)script/ide/common_control.lua");

local UnitTestDlg = {
	-- name 
	name = "UnitTestDlg",
	-- layout
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 600,
	height = 450,
	parent = nil,
	historyFileName = "temp/HistoryTestFiles.txt",
	-- properties
	-- current test object
	curTest = nil,
	
	-- max history test files saved.
	max_history_items = 30,
}
CommonCtrl.UnitTestDlg = UnitTestDlg;


function UnitTestDlg:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function UnitTestDlg:Destroy ()
	ParaUI.Destroy(self.name);
end

function UnitTestDlg:Show(bShow)
	local _this,_parent;
	if(self.name == nil)then
		log("warning: UnitTestDlg instance name can not be nilr\n");
		return;
	end
	
	_this = ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false)then
		_this = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background = "";
		_parent = _this;
		
		if(self.parent == nil)then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		
		CommonCtrl.AddControl(self.name,self);
		
		_this = ParaUI.CreateUIObject("button", "btnOpenFile", "_rt", -147, 4, 69, 23)
		_this.text = "file...";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnLoadFile", "_rt", -72, 4, 64, 23)
		_this.text = "Load";
		_this.onclick=string.format([[;CommonCtrl.UnitTestDlg.OnClickLoadTestFile("%s");]], self.name);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label3", "_lt", 6, 7, 87, 15)
		_this.text = "Test file:";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "comboBoxUnitTestFile",
			alignment = "_mt",
			left = 99,
			top = 4,
			width = 153,
			height = 23,
			dropdownheight = 106,
 			parent = _parent,
			text = "",
			onselect = string.format([[CommonCtrl.UnitTestDlg.OnClickLoadTestFile("%s");]], self.name);
			items = {"script/ide/UnitTest/sample_test_file.lua", },
		};
		ctl:Show();

		-- panel1
		_this = ParaUI.CreateUIObject("container", "panel1", "_fi", 6, 33, 8, 8)
		_parent:AddChild(_this);
		_parent = _this;

		_this = ParaUI.CreateUIObject("text", "label1", "_lt", 3, 193, 199, 15)
		_this.text = "Edit current case input:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "btnRunTest", "_lb", 6, -47, 88, 33)
		_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4";
		_this.text = "Run Test";
		_this.onclick=string.format([[;CommonCtrl.UnitTestDlg.OnClickRun("%s");]], self.name);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "label2", "_lt", 3, 6, 183, 15)
		_this.text = "Select case(s) to run:";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button8", "_rb", -91, -47, 88, 23)
		_this.text = "Clear";
		_this.onclick=string.format([[;CommonCtrl.UnitTestDlg.OnClickClearLog("%s");]], self.name);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button2", "_rb", -185, -47, 88, 23)
		_this.text = "Refresh";
		_this.onclick=string.format([[;CommonCtrl.UnitTestDlg.OnClickRefreshLog("%s");]], self.name);
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button4", "_rb", -279, -47, 88, 23)
		_this.text = "Copy";
		_parent:AddChild(_this);

		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "treeViewUnitTestCases",
			alignment = "_mt",
			left = 3,
			top = 29,
			width = 340,
			height = 152,
			parent = _parent,
			DefaultIndentation = 5,
			DefaultNodeHeight = 22,
			container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
			DrawNodeHandler = CommonCtrl.TreeView.DrawSingleSelectionNodeHandler,
			onclick = CommonCtrl.UnitTestDlg.OnSelectTestCase, 
		};
		local node = ctl.RootNode;
		ctl:Show();

		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = "treeViewUnitTestInput",
			alignment = "_fi",
			left = 3,
			top = 211,
			width = 340,
			height = 56,
			parent = _parent,
			DefaultIndentation = 5,
			DefaultNodeHeight = 25,
			container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
			DrawNodeHandler = CommonCtrl.TreeView.DrawPropertyNodeHandler,
		};
		local node = ctl.RootNode;
		ctl:Show();

		-- tab views
		NPL.load("(gl)script/ide/MainMenu.lua");
		local ctl = CommonCtrl.MainMenu:new{
			name = "UnitTestCtrlTabs",
			alignment = "_rt",
			left = -333,
			top = 4,
			width = 329,
			height = 25,
			parent = _parent,
		};
		local node = ctl.RootNode;
		local childNode = node:AddChild(CommonCtrl.TreeNode:new({Text = "Result", Name = "result_tab", onclick = CommonCtrl.UnitTestDlg.OnClickTab_ShowResult, parentName = self.name}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Preview", Name = "result_tab", onclick = CommonCtrl.UnitTestDlg.OnClickTab_ShowLastResult, parentName = self.name}));
		node:AddChild(CommonCtrl.TreeNode:new({Text = "Source", Name = "result_tab", onclick = CommonCtrl.UnitTestDlg.OnClickTab_ShowSource, parentName = self.name}));
		ctl:Show(true);
		self.LastLogPos = commonlib.log.GetLogPos()
		-- switch to the first tab page. 
		-- CommonCtrl.MainMenu.OnClickTopLevelMenuItem("UnitTestCtrlTabs", 1);

		NPL.load("(gl)script/ide/MultiLineEditbox.lua");
		local ctl = CommonCtrl.MultiLineEditbox:new{
			name = "textBoxUnitTestResult",
			alignment = "_mr",
			left = 3,
			top = 29,
			width = 331,
			height = 56,
			parent = _parent,
			WordWrap = false,
			ShowLineNumber = true,
			syntax_map = CommonCtrl.MultiLineEditbox.syntax_map_NPL,
		};
		ctl:Show();

		-- update all
		self:UpdateHistoryTestFiles()
		
		-- select the first test file in history
		local ctl = CommonCtrl.GetControl("comboBoxUnitTestFile");
		if(ctl and ctl.items[1])then
			ctl:SetText(ctl.items[1]);
			self:OpenTestFile(ctl.items[1]);
		end
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end		
	end
end

-- load history test files
function UnitTestDlg:UpdateHistoryTestFiles()
	local ctl = CommonCtrl.GetControl("comboBoxUnitTestFile");
	if(ctl==nil)then
		log("error getting instance "..sCtrlName.."\r\n");
		return;
	end
	
	if(ParaIO.DoesFileExist(self.historyFileName)) then
		ctl.items = commonlib.LoadTableFromFile(self.historyFileName) or {};
		ctl:RefreshListBox();
	end
end

function UnitTestDlg:OpenTestFile(testfilename)
	local succeed;
	local test = commonlib.UnitTest:new();
	if(test:ParseFile(testfilename)) then
		succeed = true;
		-- TODO: bind UI objects. 
		self.curTest = test;

		-- update test cases. 
		local ctl = CommonCtrl.GetControl("treeViewUnitTestCases");
		ctl.RootNode:ClearAllChildren();
		
		local i, count = 1, self.curTest:GetTestCaseCount()
		local nodeSelected;
		for i = 1, count do
			local testcase = self.curTest:GetTestCase(i);
			if(testcase) then
				local node = ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({Text = testcase.name, Name = "", Icon = "Texture/3DMapSystem/common/light.png",
					caseIndex = i, testcase = testcase}));
				if(not nodeSelected) then
					nodeSelected = node;
				end
			end	
		end
		if(nodeSelected) then
			nodeSelected:SelectMe(false)
		end	
		ctl:Update();
		
		-- select the first test case, if any, in test file
		CommonCtrl.UnitTestDlg.OnSelectTestCase(nodeSelected)
	else
		_guihelper.MessageBox("Unable to open test file "..testfilename.."\n")
	end
	
	--
	-- save recently opened file to history
	-- 
	if(succeed) then
		local ctl = CommonCtrl.GetControl("comboBoxUnitTestFile");
		if(ctl~=nil)then
			local index = ctl:InsertItem(testfilename)
			if(index) then
				-- save to file
				if(index>1) then
					-- swap selected to front
					commonlib.moveArrayItem(ctl.items, index, 1)
				end	
				if(table.getn(ctl.items)>self.max_history_items) then
					commonlib.resize(ctl.items, self.max_history_items);
				end	
				commonlib.SaveTableToFile(ctl.items, self.historyFileName);
			end
		end
	end
end

-- load the given test file and databind all test cases. 
function UnitTestDlg.OnClickLoadTestFile(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting dropdownlistbox instance "..sCtrlName.."\r\n");
		return;
	end
	local ctl = CommonCtrl.GetControl("comboBoxUnitTestFile");
	if(ctl~=nil)then
		self:OpenTestFile(ctl:GetText())
	end
end

-- run the current test. 
function CommonCtrl.UnitTestDlg.OnClickRun(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting dropdownlistbox instance "..sCtrlName.."\r\n");
		return;
	end
	
	if(not self.curTest) then
		_guihelper.MessageBox("Please first open a valid test file");
		return 
	end
	self.LastLogPos = commonlib.log.GetLogPos()
	
	self.curTest:ClearResult();
	-- run the selected test. 
	local ctl = CommonCtrl.GetControl("treeViewUnitTestCases");
	if(ctl and ctl.SelectedNode and ctl.SelectedNode.testcase) then
		
		if(ctl.SelectedNode.testcase.bindingContext) then
			-- grab user input if any
			ctl.SelectedNode.testcase.bindingContext:UpdateControlsToData();
		end
		self.curTest:RunTestCase(ctl.SelectedNode.caseIndex, nil);
	end
	
	--[[ run all test cases
	local i, count = 1, self.curTest:GetTestCaseCount()
	for i = 1, count do
		self.curTest:RunTestCase(i, nil);
	end]]
	
	CommonCtrl.UnitTestDlg.OnClickRefreshLog(sCtrlName)
end

-- open the last test run result for the selected test case. 
function CommonCtrl.UnitTestDlg.OnClickShowLastResult(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting dropdownlistbox instance "..sCtrlName.."\r\n");
		return;
	end
	
	if(not self.curTest) then
		_guihelper.MessageBox("Please first open a valid test file");
		return 
	end
	
	-- run the selected test. 
	local ctl = CommonCtrl.GetControl("treeViewUnitTestCases");
	if(ctl and ctl.SelectedNode and ctl.SelectedNode.testcase) then
		local filename = ctl.SelectedNode.testcase:GetOutputFileName();
		if(ParaIO.DoesFileExist(filename)) then
			local file = ParaIO.open(filename,"r");
			if(file:IsValid()) then
				self.LastLogPos = commonlib.log.GetLogPos()
				log(file:GetText());
				file:close();
				CommonCtrl.UnitTestDlg.OnClickRefreshLog(sCtrlName)
			end	
		else
			_guihelper.MessageBox("There is no last test result. Please Run Test instead.");	
		end
	end
end

-- clear log result box
function CommonCtrl.UnitTestDlg.OnClickClearLog(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting dropdownlistbox instance "..sCtrlName.."\r\n");
		return;
	end
	local ctl = CommonCtrl.GetControl("textBoxUnitTestResult");
	if(ctl~=nil)then
		-- clear result text box
		ctl:SetText("");
	end
end

-- refresh log result box
function CommonCtrl.UnitTestDlg.OnClickRefreshLog(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting dropdownlistbox instance "..sCtrlName.."\r\n");
		return;
	end
	
	local newPos = commonlib.log.GetLogPos();
	if(self.LastLogPos ~= newPos) then
		local result = commonlib.log.GetLog(self.LastLogPos)
		self.LastLogPos = newPos;
		
		local ctl = CommonCtrl.GetControl("textBoxUnitTestResult");
		if(ctl~=nil)then
			-- append to it
			ctl:SetText(ctl:GetText()..result);
		end
	end
end

function CommonCtrl.UnitTestDlg.OnClickTab_ShowSource(treenode)
	local sCtrlName = treenode.parentName;
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting instance "..sCtrlName.."\r\n");
		return;
	end
	
	if(not self.curTest) then
		_guihelper.MessageBox("Please first open a valid test file");
		return 
	end
	-- open source file
	if(self.curTest.testfilename and ParaIO.DoesFileExist(self.curTest.testfilename)) then
		local ctl = CommonCtrl.GetControl("textBoxUnitTestResult");
		if(ctl~=nil)then
			local file = ParaIO.open(self.curTest.testfilename, "r");
			if(file:IsValid()) then
				-- append to it
				ctl:SetText(ctl:GetText()..file:GetText());
				file:close();
			end
		end
	end
end

function CommonCtrl.UnitTestDlg.OnClickTab_ShowLastResult(treenode)
	CommonCtrl.UnitTestDlg.OnClickShowLastResult(treenode.parentName);
end

function CommonCtrl.UnitTestDlg.OnClickTab_ShowResult(treenode)
	CommonCtrl.UnitTestDlg.OnClickRefreshLog(treenode.parentName);
end

-- user selected a test case. 
function CommonCtrl.UnitTestDlg.OnSelectTestCase(treenode)
	local ctl = CommonCtrl.GetControl("treeViewUnitTestInput");
	if(ctl~=nil)then
		if(treenode) then
			treenode.testcase.bindingContext = commonlib.BindingContext:new();
			ctl.RootNode:BindNPLTable(treenode.testcase.bindingContext, treenode.testcase.input)
		else
			ctl:ClearAllChildren();
		end	
		ctl:Update();
	end
end