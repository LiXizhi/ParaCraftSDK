--[[
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/test/motion_test_2.lua");
CommonCtrl.Motion.motion_test_2.show();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
local motion_test_2 = {points = {}, DisplayObject=nil ,engine =nil };
	commonlib.setfield("CommonCtrl.Motion.motion_test_2",motion_test_2);
function CommonCtrl.Motion.motion_test_2.show()
	_guihelper.ShowDialogBox("one engine", nil, nil, 800, 600, CommonCtrl.Motion.motion_test_2.CreateDlg, CommonCtrl.Motion.motion_test_2.OnDlgResult);
end
function CommonCtrl.Motion.motion_test_2.CreateDlg(_parent)
	local _this;
	_this = ParaUI.CreateUIObject("container", "container", "_fi", 0,0,0,0)	
	_this.background = "Texture/whitedot.png;";
	_parent:AddChild(_this);
	_parent = _this;
	
	local left,top,width,hight=0,0,256,128;
	--test button_1
	_this = ParaUI.CreateUIObject("container", "CommonCtrl.Motion.motion_test_2.button_1", "_lt", left,top,width,hight)
	_this.background = "Texture/3DMapSystem/brand/paraworld_text_256X128.png";
	_parent:AddChild(_this);
	--test button_2
	left,top,width,hight=left,top+150,width,hight
	_this = ParaUI.CreateUIObject("container", "CommonCtrl.Motion.motion_test_2.button_2", "_lt", left,top,width,hight)
	_this.background = "Texture/3DMapSystem/brand/paraworld_text_256X128.png";
	_parent:AddChild(_this);
	--test button_3
	left,top,width,hight=left,top+150,width,hight
	_this = ParaUI.CreateUIObject("container", "CommonCtrl.Motion.motion_test_2.button_3", "_lt", left,top,width,hight)
	_this.background = "Texture/3DMapSystem/brand/paraworld_text_256X128.png";
	_parent:AddChild(_this);
	--test button_4
	left,top,width,hight=300,0,width,hight
	_this = ParaUI.CreateUIObject("container", "CommonCtrl.Motion.motion_test_2.button_4", "_lt", left,top,width,hight)
	_this.background = "Texture/3DMapSystem/brand/paraworld_text_256X128.png";
	_parent:AddChild(_this);
	
	--start btn
	 left,top,width,hight=10,500,80,50;
	_this = ParaUI.CreateUIObject("button", "start", "_lt", left,top,width,hight)
	_this.text="start";
	_this.onclick=";CommonCtrl.Motion.motion_test_2.onStart();";
	_parent:AddChild(_this);
	
	--pause btn
	left,top,width,hight=left+100,top,width,hight
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,hight)
	_this.text="pause";
	_this.onclick=";CommonCtrl.Motion.motion_test_2.onPause();";
	_parent:AddChild(_this);
	
	-- resume btn
	left,top,width,hight=left+100,top,width,hight
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,hight)
	_this.text="resume";
	_this.onclick=";CommonCtrl.Motion.motion_test_2.onResume();";
	_parent:AddChild(_this);
	
	--stop btn
	left,top,width,hight=left+100,top,width,hight
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,hight)
	_this.text="stop";
	_this.onclick=";CommonCtrl.Motion.motion_test_2.onStop();";
	_parent:AddChild(_this);
	
	
	
	CommonCtrl.Motion.motion_test_2.Init()
	
	
end
function CommonCtrl.Motion.motion_test_2.Init()
	
	local engine = CommonCtrl.Motion.AnimatorEngine:new();
	CommonCtrl.Motion.motion_test_2.engine = engine;
	local animatorManager = CommonCtrl.Motion.AnimatorManager:new();
	
	local animator,layerManager;
		  animator = CommonCtrl.Motion.Animator:new();
		  animator:Init("script/ide/Motion/test/motionData.xml", "CommonCtrl.Motion.motion_test_2.button_1");
		  layerManager = CommonCtrl.Motion.LayerManager:new();	 
		  
		  layerManager:AddChild(animator);
		  animatorManager:AddChild(layerManager);
		  
		  animator = CommonCtrl.Motion.Animator:new();
		  animator:Init("script/ide/Motion/test/motionData_2.xml", "CommonCtrl.Motion.motion_test_2.button_2");
		  layerManager = CommonCtrl.Motion.LayerManager:new();
		  
		  layerManager:AddChild(animator);
		  animatorManager:AddChild(layerManager);
		  
		  animator = CommonCtrl.Motion.Animator:new();
		  animator:Init("script/ide/Motion/test/motionData_3.xml", "CommonCtrl.Motion.motion_test_2.button_3");
		  --animator.repeatCount = 0;
		  layerManager = CommonCtrl.Motion.LayerManager:new();
		 
		  layerManager:AddChild(animator);
		  animatorManager:AddChild(layerManager);
		  -----
		  
		  layerManager = CommonCtrl.Motion.LayerManager:new();
		 
		  animator = CommonCtrl.Motion.Animator:new();
		  animator:Init("script/ide/Motion/test/motionData.xml", "CommonCtrl.Motion.motion_test_2.button_4");
		  layerManager:AddChild(animator);
		  
		  
		  animator = CommonCtrl.Motion.Animator:new();
		  animator:Init("script/ide/Motion/test/motionData_2.xml", "CommonCtrl.Motion.motion_test_2.button_4");
		  layerManager:AddChild(animator);
		  
		  
		  animator = CommonCtrl.Motion.Animator:new();
		  animator:Init("script/ide/Motion/test/motionData_3.xml", "CommonCtrl.Motion.motion_test_2.button_4");
		  layerManager:AddChild(animator);
		  
		  animatorManager:AddChild(layerManager);
		 
		   --set AnimatorManager value must be at last  
		  engine:SetAnimatorManager(animatorManager);
end


-----------------
function CommonCtrl.Motion.motion_test_2.onStart()

	CommonCtrl.Motion.motion_test_2.engine:doPlay();
end
function CommonCtrl.Motion.motion_test_2.onPause()
	CommonCtrl.Motion.motion_test_2.engine:doPause();
	
end
function CommonCtrl.Motion.motion_test_2.onResume()
	CommonCtrl.Motion.motion_test_2.engine:doResume();
end
function CommonCtrl.Motion.motion_test_2.onStop()
	CommonCtrl.Motion.motion_test_2.engine:doStop();
end


-- called when dialog returns. 
function CommonCtrl.Motion.motion_test_2.OnDlgResult(dialogResult)
	if(dialogResult == _guihelper.DialogResult.OK) then	
		CommonCtrl.Motion.motion_test_2.engine:Destroy();
	end
	
	return true;
end

