--[[
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/test/autotips_test.lua");
CommonCtrl.Motion.autotips_test.show();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Motion/AnimativeMenu/AnimativeMenu.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/autotips.lua");

local autotips_test = {index = 0,idleIndex = 0,tipIndex = 0};
	commonlib.setfield("CommonCtrl.Motion.autotips_test",autotips_test);
function CommonCtrl.Motion.autotips_test.show()
	_guihelper.ShowDialogBox("autotips_test", 0,200, 400, 400, CommonCtrl.Motion.autotips_test.CreateDlg, CommonCtrl.Motion.autotips_test.OnDlgResult);
end
function CommonCtrl.Motion.autotips_test.CreateDlg(_parent)
	local _this;
	_this = ParaUI.CreateUIObject("container", "autotips_test", "_fi", 0,0,0,0)	
	--_this.background = "Texture/whitedot.png;";
	_parent:AddChild(_this);
	_parent = _this;
	local left,top,width,height=10,10,200,30;	
	--add a message btn
	_this = ParaUI.CreateUIObject("button", "start", "_lt", left,top,width,height)
	_this.text="add a message";
	_this.onclick=";CommonCtrl.Motion.autotips_test.onAdd();";
	_parent:AddChild(_this);
	
	--add a same message btn
	left,top,width,height=left,top+50,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="add a same message(1)";
	_this.onclick=";CommonCtrl.Motion.autotips_test.onAdd(1);";
	_parent:AddChild(_this);
	
	-- add a idle massage btn
	left,top,width,height=left,top+50,width,height
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,height)
	_this.text="add a idle massage";
	_this.onclick=";CommonCtrl.Motion.autotips_test.onAddIdle();";
	_parent:AddChild(_this);
	
	-- add a tip massage btn
	left,top,width,height=left,top+50,width,height
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,height)
	_this.text="add a tip massage priority = 40";
	_this.onclick=";CommonCtrl.Motion.autotips_test.onAddTip(40);";
	_parent:AddChild(_this);
	-- add a tip massage btn
	left,top,width,height=left,top+50,width,height
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,height)
	_this.text="add a tip massage priority = 50";
	_this.onclick=";CommonCtrl.Motion.autotips_test.onAddTip(50);";
	_parent:AddChild(_this);
	-- add a tip massage btn
	left,top,width,height=left,top+50,width,height
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,height)
	_this.text="add a tip massage priority = 30";
	_this.onclick=";CommonCtrl.Motion.autotips_test.onAddTip(30);";
	_parent:AddChild(_this);
	
	-- reset a tip massage btn
	left,top,width,height=left,top+50,width,height
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,height)
	_this.text="reset a tip massage(1)";
	_this.onclick=";CommonCtrl.Motion.autotips_test.onResetTip(1);";
	_parent:AddChild(_this);
	
	
	-- remove a tip massage btn
	left,top,width,height=left,top+50,width,height
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,height)
	_this.text="remove a tip massage(1)";
	_this.onclick=";CommonCtrl.Motion.autotips_test.onRemoveTip(1);";
	_parent:AddChild(_this);
	
		
	autotips.Show(true);
end

-----------------
function CommonCtrl.Motion.autotips_test.onAdd(v)
	local text;
	if(not v)then
		CommonCtrl.Motion.autotips_test.index = CommonCtrl.Motion.autotips_test.index + 1;
		text = "text"..CommonCtrl.Motion.autotips_test.index; 
	else
		text = "text1"; 
	end
	autotips.AddMessageTips(text)
end
function CommonCtrl.Motion.autotips_test.onAddIdle()
	local text;
	CommonCtrl.Motion.autotips_test.idleIndex = CommonCtrl.Motion.autotips_test.idleIndex + 1;
	text = "idle_text"..CommonCtrl.Motion.autotips_test.idleIndex; 
	autotips.AddIdleTips(text)	
end

function CommonCtrl.Motion.autotips_test.onAddTip(priority)
	local category,text;
	CommonCtrl.Motion.autotips_test.tipIndex = CommonCtrl.Motion.autotips_test.tipIndex + 1;
	category = "category_text"..CommonCtrl.Motion.autotips_test.tipIndex;
	text = "tip_text"..priority; 	
	autotips.AddTips(category,text,priority)
end
function CommonCtrl.Motion.autotips_test.onResetTip(v)
	local category,text;
	category = "category_text"..v;
	text = "tip_text"..v.."---reset"; 
	autotips.AddTips(category,text)
end
function CommonCtrl.Motion.autotips_test.onRemoveTip(v)
	local category,text;
	category = "category_text"..v
	text = nil
	autotips.AddTips(category, text)
end

-- called when dialog returns. 
function CommonCtrl.Motion.autotips_test.OnDlgResult(dialogResult)
	if(dialogResult == _guihelper.DialogResult.OK) then	

		return true;
	end	
end

