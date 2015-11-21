--[[
Title: Test tween
Author(s): Leio Zhang
Date: 2008/3/19
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Transitions/Tween_test.lua");
Tween_test.show();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Transitions/Tween.lua");
if(not Tween_test) then Tween_test={}; end

Tween_test.isYoYo=false;
Tween_test.TWEEN=nil;
Tween_test.EaseType=nil;


function Tween_test.show()
	_guihelper.ShowDialogBox("Tween", nil, nil, 800, 600, Tween_test.CreateDlg, Tween_test.OnDlgResult);
end
function Tween_test.CreateDlg(_parent)
	local _this;
	_this = ParaUI.CreateUIObject("container", "container", "_fi", 0,0,0,0)
	_this.background = "";
	_parent:AddChild(_this);
	_parent = _this;
	
	local left,top,width,hight=10,0,100,50;
	_this = ParaUI.CreateUIObject("button", "Tween_test.button", "_lt", left,top,width,hight)
	_parent:AddChild(_this);
	
	--start btn
	 left,top,width,hight=10,500,80,50;
	_this = ParaUI.CreateUIObject("button", "start", "_lt", left,top,width,hight)
	_this.text="start";
	_this.onclick=";Tween_test.onStart();";
	_parent:AddChild(_this);
	
	--stop btn
	left,top,width,hight=left+100,top,width,hight
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,hight)
	_this.text="stop";
	_this.onclick=";Tween_test.onStop();";
	_parent:AddChild(_this);
	
	-- resume btn
	left,top,width,hight=left+100,top,width,hight
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,hight)
	_this.text="resume";
	_this.onclick=";Tween_test.onResume();";
	_parent:AddChild(_this);
	
	--FForward btn
	left,top,width,hight=left+100,top,width,hight
	_this = ParaUI.CreateUIObject("button", "FForward", "_lt", left,top,width,hight)
	_this.text="FForward";
	_this.onclick=";Tween_test.OnFForward();";
	_parent:AddChild(_this);
	--PrevFrame btn
	left,top,width,hight=left+100,top,width,hight
	_this = ParaUI.CreateUIObject("button", "PrevFrame", "_lt", left,top,width,hight)
	_this.text="PrevFrame";
	_this.onclick=";Tween_test.OnPrevFrame();";
	_parent:AddChild(_this);
	--NextFrame btn
	left,top,width,hight=left+100,top,width,hight
	_this = ParaUI.CreateUIObject("button", "NextFrame", "_lt", left,top,width,hight)
	_this.text="NextFrame";
	_this.onclick=";Tween_test.OnNextFrame();";
	_parent:AddChild(_this);
	
	-- isYoYo
	NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "yoyo_CheckBox",
			alignment = "_lt",
			left = 10,
			top = 550,
			width = 227,
			height = 20,
			parent = _parent,
			isChecked = Tween_test.isYoYo,
			text = "isYoYo",
			oncheck = Tween_test.YoYoChecked,
		};
		ctl:Show();
		
	NPL.load("(gl)script/ide/dropdownlistbox.lua");
	local ctl = CommonCtrl.dropdownlistbox:new{
		name = "Tween_test.OperationTypes",
		alignment = "_lt",
		left = 550,
		top = 11,
		width = 200,
		height = 20,
		dropdownheight = 500,
 		parent = _parent,
		text = "",
		items = CommonCtrl.TweenEquations.TransitionType,
		onselect =Tween_test.OnSelection,
	};
	ctl:Show();
	--duration
	left,top,width,hight=550,30,200,380
	_this = ParaUI.CreateUIObject("text", "show_txt", "_lt", left,top,width,hight)
	_parent:AddChild(_this);
	
	
	
end
function Tween_test.Init()
	local txt=ParaUI.GetUIObject("show_txt");
	txt.text="";
	local tween=CommonCtrl.Tween:new{
				
					}
		tween.looping=false;
		tween.obj=ParaUI.GetUIObject("Tween_test.button");
		tween.prop="x";
		tween.begin=10;
		tween.change=300;
		tween.duration=0.5;
		tween.MotionChange=Tween_test.MotionChange;
		tween.MotionFinish=Tween_test.MotionFinish;	
		tween.MotionStop=Tween_test.MotionStop;	
		Tween_test.TWEEN=tween;
		if(Tween_test.EaseType)then 
			local str="CommonCtrl.TweenEquations."..tostring(Tween_test.EaseType);
			local f=loadstring("Tween_test.TWEEN.func="..str);
			--like this:Tween_test.TWEEN.func=TweenEquations.easeOutCubic;
			f();
			
		end
end

function Tween_test.onStart()
		Tween_test.Init();
		Tween_test.TWEEN:Start();
end

function Tween_test.onResume()
	Tween_test.TWEEN:Resume();
end
function Tween_test.onStop()
	
	Tween_test.TWEEN:Stop();
end
function Tween_test.OnFForward()
	Tween_test.TWEEN:FForward();
end
function Tween_test.OnPrevFrame()
	Tween_test.TWEEN:PrevFrame();
end
function Tween_test.OnNextFrame()
	Tween_test.TWEEN:NextFrame();
end

function Tween_test.MotionChange(time,position)
	--log(string.format("MotionChange:%s,%s\n",time,position));
	local txt=ParaUI.GetUIObject("show_txt");
	txt.text=txt.text..string.format("time:%s,position:%s\n",time,position)
end
function Tween_test.MotionFinish(time,position)
	if(Tween_test.isYoYo)then
		Tween_test.TWEEN:YoYo();
	end
end
function Tween_test.MotionStop(time,position)

end
-- called when dialog returns. 
function Tween_test.OnDlgResult(dialogResult)
	--if(dialogResult == _guihelper.DialogResult.OK) then	
	--end
	Tween_test.Destroy();
	return true;
end

function Tween_test.OnSelection(sCtrlName, item)
	Tween_test.EaseType=item;	
end

function Tween_test.YoYoChecked()
	if(Tween_test.isYoYo)then
		Tween_test.isYoYo=false;
	else
		Tween_test.isYoYo=true;
	end
end

function Tween_test.Destroy()
	local tween=CommonCtrl.GetControl(Tween_test.TWEEN.name)
	if(tween)then
		CommonCtrl.DeleteControl(Tween_test.TWEEN.name);
	end
end