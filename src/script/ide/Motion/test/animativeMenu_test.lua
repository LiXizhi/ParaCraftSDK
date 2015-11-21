--[[
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/test/animativeMenu_test.lua");
CommonCtrl.Motion.animativeMenu_test.show();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Motion/AnimativeMenu/AnimativeMenu.lua");
local animativeMenu_test = {};
	commonlib.setfield("CommonCtrl.Motion.animativeMenu_test",animativeMenu_test);
function CommonCtrl.Motion.animativeMenu_test.show()
	_guihelper.ShowDialogBox("animativeMenu_test", nil, nil, 800, 600, CommonCtrl.Motion.animativeMenu_test.CreateDlg, CommonCtrl.Motion.animativeMenu_test.OnDlgResult);
end
function CommonCtrl.Motion.animativeMenu_test.CreateDlg(_parent)
	local _this;
	_this = ParaUI.CreateUIObject("container", "animativeMenu_test", "_fi", 0,0,0,0)	
	--_this.background = "Texture/whitedot.png;";
	_parent:AddChild(_this);
	_parent = _this;
	local left,top,width,height=10,500,80,50;	
	--add btn
	_this = ParaUI.CreateUIObject("button", "start", "_lt", left,top,width,height)
	_this.text="add";
	_this.onclick=";CommonCtrl.Motion.animativeMenu_test.onAdd();";
	_parent:AddChild(_this);
	
	--remove(1) btn
	left,top,width,height=left+100,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="remove(1)";
	_this.onclick=";CommonCtrl.Motion.animativeMenu_test.onRemove(1);";
	_parent:AddChild(_this);
	
	-- remove(2) btn
	left,top,width,height=left+100,top,width,height
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,height)
	_this.text="remove(2)";
	_this.onclick=";CommonCtrl.Motion.animativeMenu_test.onRemove(2);";
	_parent:AddChild(_this);
	
	--remove(3) btn
	left,top,width,height=left+100,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="remove(3)";
	_this.onclick=";CommonCtrl.Motion.animativeMenu_test.onRemove(3);";
	_parent:AddChild(_this);
	--GetNodeAt(2) btn
	left,top,width,height=left+100,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="GetNodeAt(2)";
	_this.onclick=";CommonCtrl.Motion.animativeMenu_test.GetNodeAt(2);";
	_parent:AddChild(_this);
	
	_parent = ParaUI.GetUIObject("animativeMenu_test");
	_this = ParaUI.CreateUIObject("container", "TipAEMenu_animativeMenu_test", "_lt", 0,0,550,400)	
	_this.background = "";
	_parent:AddChild(_this);
	_parent = _this;
	
	NPL.load("(gl)script/ide/Motion/AnimativeMenu/TipAEMenu.lua");
	local tipAEMenu = CommonCtrl.Motion.AnimativeMenu.TipAEMenu:new{
		alignment = "_lt",
		left = 0,
		top = 0,
		width = 550,
		height = 400, 
		parent = _parent,
	}
	tipAEMenu:Show();
	CommonCtrl.Motion.animativeMenu_test.animativeMenu = tipAEMenu;
	
end

-----------------
function CommonCtrl.Motion.animativeMenu_test.onAdd()
	local tipAEMenu = CommonCtrl.Motion.animativeMenu_test.animativeMenu;
	local rootnode = tipAEMenu.RootNode;
	local node = CommonCtrl.TreeNode:new({Text = "NodeTest"});
	rootnode:AddChild(node);
	tipAEMenu:BoundMotion(node);

end
function CommonCtrl.Motion.animativeMenu_test.onRemove(v)
	local tipAEMenu = CommonCtrl.Motion.animativeMenu_test.animativeMenu;
	local nodePath = string.format([[0/%s]],v);
	tipAEMenu:UnBoundMotionByNodePath(nodePath);
	
end
function CommonCtrl.Motion.animativeMenu_test.GetNodeAt(v)
	local tipAEMenu = CommonCtrl.Motion.animativeMenu_test.animativeMenu;
	local nodePath = string.format([[0/%s]],v);
	tipAEMenu:RebornMotionByNodePath(nodePath);
	
end

-- called when dialog returns. 
function CommonCtrl.Motion.animativeMenu_test.OnDlgResult(dialogResult)
	if(dialogResult == _guihelper.DialogResult.OK) then	

		return true;
	end
	
	
end

