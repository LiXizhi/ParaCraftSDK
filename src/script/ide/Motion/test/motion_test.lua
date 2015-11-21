--[[
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/test/motion_test.lua");
CommonCtrl.Motion.motion_test.show();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
local motion_test = {points = {}, DisplayObject=nil ,engine =nil,engine_2 = nil };
	commonlib.setfield("CommonCtrl.Motion.motion_test",motion_test);
function CommonCtrl.Motion.motion_test.show()
	_guihelper.ShowDialogBox("two engine", nil, nil, 800, 600, CommonCtrl.Motion.motion_test.CreateDlg, CommonCtrl.Motion.motion_test.OnDlgResult);
end
function CommonCtrl.Motion.motion_test.CreateDlg(_parent)
	local _this;
	_this = ParaUI.CreateUIObject("container", "container", "_fi", 0,0,0,0)	
	_this.background = "Texture/whitedot.png;";
	_parent:AddChild(_this);
	_parent = _this;
	
	local left,top,width,height=0,0,256,128;
	--test button_1
	_this = ParaUI.CreateUIObject("container", "CommonCtrl.Motion.motion_test.button_1", "_lt", left,top,width,height)
	_this.background = "Texture/3DMapSystem/brand/paraworld_text_256X128.png";
	_parent:AddChild(_this);
	--test button_2
	left,top,width,height=left,top+150,width,height
	_this = ParaUI.CreateUIObject("container", "CommonCtrl.Motion.motion_test.button_2", "_lt", left,top,width,height)
	_this.background = "Texture/3DMapSystem/brand/paraworld_text_256X128.png";
	_parent:AddChild(_this);
	--test button_3
	left,top,width,height=left,top+150,width,height
	_this = ParaUI.CreateUIObject("container", "CommonCtrl.Motion.motion_test.button_3", "_lt", left,top,width,height)
	_this.background = "Texture/3DMapSystem/brand/paraworld_text_256X128.png";
	_parent:AddChild(_this);
	--test button_4
	left,top,width,height=300,0,width,height
	_this = ParaUI.CreateUIObject("container", "CommonCtrl.Motion.motion_test.button_4", "_lt", left,top,width,height)
	_this.background = "Texture/3DMapSystem/brand/paraworld_text_256X128.png";
	_parent:AddChild(_this);
	
	--start btn
	 left,top,width,height=10,500,80,50;
	_this = ParaUI.CreateUIObject("button", "start", "_lt", left,top,width,height)
	_this.text="start";
	_this.onclick=";CommonCtrl.Motion.motion_test.onStart();";
	_parent:AddChild(_this);
	
	--pause btn
	left,top,width,height=left+100,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="pause";
	_this.onclick=";CommonCtrl.Motion.motion_test.onPause();";
	_parent:AddChild(_this);
	
	-- resume btn
	left,top,width,height=left+100,top,width,height
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,height)
	_this.text="resume";
	_this.onclick=";CommonCtrl.Motion.motion_test.onResume();";
	_parent:AddChild(_this);
	
	--stop btn
	left,top,width,height=left+100,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="stop";
	_this.onclick=";CommonCtrl.Motion.motion_test.onStop();";
	_parent:AddChild(_this);
	----------------------
	--start btn
	 left,top,width,height=400,550,80,50;
	_this = ParaUI.CreateUIObject("button", "start", "_lt", left,top,width,height)
	_this.text="start";
	_this.onclick=";CommonCtrl.Motion.motion_test.onStart_2();";
	_parent:AddChild(_this);
	
	--pause btn
	left,top,width,height=left+100,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="pause";
	_this.onclick=";CommonCtrl.Motion.motion_test.onPause_2();";
	_parent:AddChild(_this);
	
	-- resume btn
	left,top,width,height=left+100,top,width,height
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,height)
	_this.text="resume";
	_this.onclick=";CommonCtrl.Motion.motion_test.onResume_2();";
	_parent:AddChild(_this);
	
	--stop btn
	left,top,width,height=left+100,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="stop";
	_this.onclick=";CommonCtrl.Motion.motion_test.onStop_2();";
	_parent:AddChild(_this);
	
	
	CommonCtrl.Motion.motion_test.Init()
	
	
end
function CommonCtrl.Motion.motion_test.Init()
	-----engine
	local engine = CommonCtrl.Motion.AnimatorEngine:new();
	CommonCtrl.Motion.motion_test.engine = engine;
	local animatorManager = CommonCtrl.Motion.AnimatorManager:new();
	
	local animator,layerManager;
		  --level 1 : animator 1
		  animator = CommonCtrl.Motion.Animator:new();
		  animator:Init("script/ide/Motion/test/motionData111111111.xml", "CommonCtrl.Motion.motion_test.button_1");
		  --level 1
		  layerManager = CommonCtrl.Motion.LayerManager:new();	 
		  
		  layerManager:AddChild(animator);
		  animatorManager:AddChild(layerManager);
		  
		  ----level 2 : animator 1
		  --animator = CommonCtrl.Motion.Animator:new();
		  --animator:Init("script/ide/Motion/test/motionData_2.xml", "CommonCtrl.Motion.motion_test.button_2");
		  ----level 2
		  --layerManager = CommonCtrl.Motion.LayerManager:new();
		  --
		  --layerManager:AddChild(animator);
		  --animatorManager:AddChild(layerManager);
		  --
		  ----level 3 : animator 1
		  --animator = CommonCtrl.Motion.Animator:new();
		  --animator:Init("script/ide/Motion/test/motionData_3.xml", "CommonCtrl.Motion.motion_test.button_3");
		  ----animator.repeatCount = 0;
		  ----level 3
		  --layerManager = CommonCtrl.Motion.LayerManager:new();
		 --
		  --layerManager:AddChild(animator);
		  --animatorManager:AddChild(layerManager);
		 
		  
		  --set AnimatorManager value must be at last 
		  engine:SetAnimatorManager(animatorManager);
		  
		   ---------------------------engine_2
		  engine = CommonCtrl.Motion.AnimatorEngine:new();
		  CommonCtrl.Motion.motion_test.engine_2 = engine;
		  animatorManager = CommonCtrl.Motion.AnimatorManager:new();
		  --level 1
		  layerManager = CommonCtrl.Motion.LayerManager:new();
		  -- animator 1
		  animator = CommonCtrl.Motion.Animator:new();
		  animator:Init("script/ide/Motion/test/motionData.xml", "CommonCtrl.Motion.motion_test.button_4");
		  layerManager:AddChild(animator);
		  
		  -- animator 2
		  animator = CommonCtrl.Motion.Animator:new();
		  animator:Init("script/ide/Motion/test/motionData_2.xml", "CommonCtrl.Motion.motion_test.button_4");
		  layerManager:AddChild(animator);
		  
		  -- animator 3
		  animator = CommonCtrl.Motion.Animator:new();
		  animator:Init("script/ide/Motion/test/motionData_3.xml", "CommonCtrl.Motion.motion_test.button_4");
		  layerManager:AddChild(animator);
		  
		  animatorManager:AddChild(layerManager);
		  
		  
		   --set AnimatorManager value must be at last 
		  engine:SetAnimatorManager(animatorManager);
end

-----------------
function CommonCtrl.Motion.motion_test.onStart()

	CommonCtrl.Motion.motion_test.engine:doPlay();

end
function CommonCtrl.Motion.motion_test.onPause()
	CommonCtrl.Motion.motion_test.engine:doPause();

end
function CommonCtrl.Motion.motion_test.onResume()
	CommonCtrl.Motion.motion_test.engine:doResume();

end
function CommonCtrl.Motion.motion_test.onStop()
	CommonCtrl.Motion.motion_test.engine:doStop();

	
end
-----------------
function CommonCtrl.Motion.motion_test.onStart_2()

	CommonCtrl.Motion.motion_test.engine_2:doStop();
	CommonCtrl.Motion.motion_test.engine_2:doPlay();
end
function CommonCtrl.Motion.motion_test.onPause_2()

	CommonCtrl.Motion.motion_test.engine_2:doPause();
end
function CommonCtrl.Motion.motion_test.onResume_2()

	CommonCtrl.Motion.motion_test.engine_2:doResume();
end
function CommonCtrl.Motion.motion_test.onStop_2()

	CommonCtrl.Motion.motion_test.engine_2:doStop();
	
end

-- called when dialog returns. 
function CommonCtrl.Motion.motion_test.OnDlgResult(dialogResult)
	if(dialogResult == _guihelper.DialogResult.OK) then	
		CommonCtrl.Motion.motion_test.engine:Destroy();
		CommonCtrl.Motion.motion_test.engine_2:Destroy();
		return true;
	end
	
	
end

