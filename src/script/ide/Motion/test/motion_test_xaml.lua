--[[
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/test/motion_test_xaml.lua");
CommonCtrl.Motion.motion_test_xaml.show();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
local motion_test_xaml = {points = {}, DisplayObject=nil ,engine =nil };
	commonlib.setfield("CommonCtrl.Motion.motion_test_xaml",motion_test_xaml);
function CommonCtrl.Motion.motion_test_xaml.show()
	_guihelper.ShowDialogBox("one engine", nil, nil, 800, 600, CommonCtrl.Motion.motion_test_xaml.CreateDlg, CommonCtrl.Motion.motion_test_xaml.OnDlgResult);
end
function CommonCtrl.Motion.motion_test_xaml.CreateDlg(_parent)
	local _this;
	_this = ParaUI.CreateUIObject("container", "container", "_fi", 0,0,0,0)	
	_this.background = "Texture/whitedot.png;";
	_parent:AddChild(_this);
	_parent = _this;
	
	local left,top,width,hight=98,208,64,64;
	--test button_1
	_this = ParaUI.CreateUIObject("container", "CommonCtrl_Motion_motion_test_xaml_button_0", "_lt", left,top,width,hight)
	_this.background = "Texture/3DMapSystem/brand/paraworld.png";
	_parent:AddChild(_this);
	--test button_2
	left,top,width,hight=231,54,width,hight
	_this = ParaUI.CreateUIObject("container", "CommonCtrl_Motion_motion_test_xaml_button_1", "_lt", left,top,width,hight)
	_this.background = "Texture/3DMapSystem/brand/paraworld.png";
	_parent:AddChild(_this);
	--test button_3
	left,top,width,hight=631,363,width,hight
	_this = ParaUI.CreateUIObject("container", "CommonCtrl_Motion_motion_test_xaml_button_2", "_lt", left,top,width,hight)
	_this.background = "Texture/3DMapSystem/brand/paraworld.png";
	_parent:AddChild(_this);
	--test button_4
	left,top,width,hight=71,363,width,hight
	_this = ParaUI.CreateUIObject("container", "CommonCtrl_Motion_motion_test_xaml_button_3", "_lt", left,top,width,hight)
	_this.background = "Texture/3DMapSystem/brand/paraworld.png";
	_parent:AddChild(_this);
	
	--start btn
	 left,top,width,hight=10,500,80,50;
	_this = ParaUI.CreateUIObject("button", "start", "_lt", left,top,width,hight)
	_this.text="start";
	_this.onclick=";CommonCtrl.Motion.motion_test_xaml.onStart();";
	_parent:AddChild(_this);
	
	--pause btn
	left,top,width,hight=left+100,top,width,hight
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,hight)
	_this.text="pause";
	_this.onclick=";CommonCtrl.Motion.motion_test_xaml.onPause();";
	_parent:AddChild(_this);
	
	-- resume btn
	left,top,width,hight=left+100,top,width,hight
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,hight)
	_this.text="resume";
	_this.onclick=";CommonCtrl.Motion.motion_test_xaml.onResume();";
	_parent:AddChild(_this);
	
	--stop btn
	left,top,width,hight=left+100,top,width,hight
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,hight)
	_this.text="stop";
	_this.onclick=";CommonCtrl.Motion.motion_test_xaml.onStop();";
	_parent:AddChild(_this);
	
	
	
	CommonCtrl.Motion.motion_test_xaml.Init()
	
	
end
function CommonCtrl.Motion.motion_test_xaml.Init()
	NPL.load("(gl)script/ide/Motion/AEManager.lua");
	local path = "script/ide/Motion/test/Page.xaml"
	local aeManager = CommonCtrl.Motion.AEManager.GetResourceFromXaml(path)
	CommonCtrl.Motion.motion_test_xaml.engine = aeManager:FindChildByName("Storyboard1");
	--CommonCtrl.Motion.motion_test_xaml.engine = aeManager:FindChildByName("Storyboard2");
	--CommonCtrl.Motion.motion_test_xaml.engine = aeManager:FindChildByName("Storyboard3");
	CommonCtrl.Motion.motion_test_xaml.engine.repeatCount = 0;
end


-----------------
function CommonCtrl.Motion.motion_test_xaml.onStart()

	CommonCtrl.Motion.motion_test_xaml.engine:doPlay();
end
function CommonCtrl.Motion.motion_test_xaml.onPause()
	CommonCtrl.Motion.motion_test_xaml.engine:doPause();
	
end
function CommonCtrl.Motion.motion_test_xaml.onResume()
	CommonCtrl.Motion.motion_test_xaml.engine:doResume();
end
function CommonCtrl.Motion.motion_test_xaml.onStop()
	CommonCtrl.Motion.motion_test_xaml.engine:doStop();
end


-- called when dialog returns. 
function CommonCtrl.Motion.motion_test_xaml.OnDlgResult(dialogResult)
	if(dialogResult == _guihelper.DialogResult.OK) then	
		CommonCtrl.Motion.motion_test_xaml.engine:Destroy();
	end
	
	return true;
end

