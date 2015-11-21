--[[
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/test/StoryboardRecorder_test.lua");
CommonCtrl.Animation.StoryboardRecorder_test.show();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/StoryboardRecorder.lua");
local StoryboardRecorder_test = {};
commonlib.setfield("CommonCtrl.Animation.StoryboardRecorder_test",StoryboardRecorder_test);
function CommonCtrl.Animation.StoryboardRecorder_test.show()
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _app = CommonCtrl.os.CreateGetApp("StoryboardRecorder_test_MyAPP");
	local _wnd = _app:FindWindow("StoryboardRecorder_test") or _app:RegisterWindow("StoryboardRecorder_test", nil, Map3DSystem.App.Debug.DebugWnd.MSGProc);
	
	local _appName, _wndName, _document, _frame;
	_frame = Map3DSystem.UI.Windows.GetWindowFrame(_wnd.app.name, _wnd.name);
	if(_frame) then
		_appName = _frame.wnd.app.name;
		_wndName = _frame.wnd.name;
		_document = ParaUI.GetUIObject(_appName.."_".._wndName.."_window_document");
	else
		local param = {
			wnd = _wnd,
			--isUseUI = true,
			icon = "Texture/3DMapSystem/MainBarIcon/Modify.png",
			iconSize = 48,
			text = "电影",
			style = Map3DSystem.UI.Windows.Style[1],
			maximumSizeX = 900,
			maximumSizeY = 1000,
			minimumSizeX = 200,
			minimumSizeY = 200,
			isShowIcon = true,
			--opacity = 100, -- [0, 100]
			isShowMaximizeBox = false,
			isShowMinimizeBox = false,
			isShowAutoHideBox = false,
			allowDrag = true,
			allowResize = true,
			initialPosX = 300,
			initialPosY = 200,
			initialWidth = 600,
			initialHeight = 200,
			
			ShowUICallback =CommonCtrl.Animation.StoryboardRecorder_test.CreateDlg,
		};
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
	--_guihelper.ShowDialogBox("StoryboardRecorder_test", 0,200, 400, 400, CommonCtrl.Animation.StoryboardRecorder_test.CreateDlg, CommonCtrl.Animation.StoryboardRecorder_test.OnDlgResult,3);
end
function CommonCtrl.Animation.StoryboardRecorder_test.CreateDlg(bShow, _parent, parentWindow)
	local _this;
	_this = ParaUI.CreateUIObject("container", "StoryboardRecorder_test", "_fi", 0,0,0,0)	
	--_this.background = "Texture/whitedot.png;";
	_parent:AddChild(_this);
	_parent = _this;
	local left,top,width,height=10,10,60,20;	
	
	--create a new recorder
	_this = ParaUI.CreateUIObject("button", "start", "_lt", left,top,width,height)
	_this.text="新建";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.onNew();";
	_parent:AddChild(_this);
	
	--open btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "output", "_lt", left,top,width,height)
	_this.text="打开";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.OpenMotionFile();";
	_parent:AddChild(_this);
	
	--save btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "output", "_lt", left,top,width,height)
	_this.text="保存";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.SaveMotionFile();";
	_parent:AddChild(_this);
	
	-- btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "output", "_lt", left,top,width,height)
	_this.text="直接播放";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.DirectlyPlay();";
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4"
	_parent:AddChild(_this);
	
	left = 10;
	--start record btn
	left,top,width,height=left,top+30,width,height
	_this = ParaUI.CreateUIObject("button", "start", "_lt", left,top,width,height)
	_this.text="开始记录";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.onStartRE();";
	_parent:AddChild(_this);
	
	--stop record btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="暂停记录";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.onStopRE();";
	_parent:AddChild(_this);
	
	-- onPreSecond btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "resume", "_lt", left,top,width,height)
	_this.text="向前一秒";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.onPreSecond();";
	_parent:AddChild(_this);
	
	--onNextSecond btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="向后一秒";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.onNextSecond();";
	_parent:AddChild(_this);
	
	--timeline btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("text", "timeline", "_lt", left,top,500,height)
	_this.text="时间轴在：";
	_parent:AddChild(_this);
	
	--onPlay btn
	left = 10
	left,top,width,height=left,top+30,width,height
	_this = ParaUI.CreateUIObject("button", "play_btn", "_lt", left,top,width,height)
	_this.text="播放";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.onPlay();";
	_parent:AddChild(_this);
	
	--onPause btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "pause_btn", "_lt", left,top,width,height)
	_this.text="暂停";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.onPause();";
	_parent:AddChild(_this);
	
	--onSpeedPre btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="快退2秒";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.speedPreFrame();";
	_parent:AddChild(_this);
	
	--onSpeedNext btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="快进2秒";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.speedNextFrame();";
	_parent:AddChild(_this);
	
	left = 10
	--gotoAndStopPreTime btn
	left,top,width,height=left,top+30,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="停在前一秒";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.gotoAndStopPreTime();";
	_parent:AddChild(_this);
	
	--gotoAndStopNextTime btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="停在后一秒";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.gotoAndStopNextTime();";
	_parent:AddChild(_this);
	
	--onStop btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="停止";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.onStop();";
	_parent:AddChild(_this);
	
	--onEnd btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="停止到最后";
	_this.onclick=";CommonCtrl.Animation.StoryboardRecorder_test.onEnd();";
	_parent:AddChild(_this);
	
	--time
	left = 10
	left,top,width,height=left,top+30,width,height
	_this = ParaUI.CreateUIObject("text", "time_txt", "_lt", left,top,600,height)
	_this.text="";
	_parent:AddChild(_this);
	
end

-----------------
function CommonCtrl.Animation.StoryboardRecorder_test.setTimeTxt(txt)
	local time_txt = ParaUI.GetUIObject("time_txt");
	time_txt.text = txt;
end
function CommonCtrl.Animation.StoryboardRecorder_test.setTimeLineTxt(txt)
	local timeline = ParaUI.GetUIObject("timeline");
	timeline.text = txt;
end
function CommonCtrl.Animation.StoryboardRecorder_test.setTimeIndex(v)
	CommonCtrl.Animation.StoryboardRecorder_test.index = v;
	local time = CommonCtrl.Animation.TimeSpan.GetMillisecondsToTimeStr(v*1000)
	CommonCtrl.Animation.StoryboardRecorder_test.setTimeLineTxt("时间轴在："..time)
end
function CommonCtrl.Animation.StoryboardRecorder_test.onNew()
	
	CommonCtrl.Animation.StoryboardRecorder_test.setTimeIndex(0)
	CommonCtrl.Animation.StoryboardRecorder.init()
	
	
	CommonCtrl.Animation.StoryboardRecorder_test.addEvent()
end
function CommonCtrl.Animation.StoryboardRecorder_test.addEvent()
	CommonCtrl.Animation.StoryboardRecorder.storyboard.OnMotionStart = CommonCtrl.Animation.StoryboardRecorder_test.OnMotionStart;
	CommonCtrl.Animation.StoryboardRecorder.storyboard.OnMotionPause = CommonCtrl.Animation.StoryboardRecorder_test.OnMotionPause;
	CommonCtrl.Animation.StoryboardRecorder.storyboard.OnMotionStop = CommonCtrl.Animation.StoryboardRecorder_test.OnMotionStop;
	CommonCtrl.Animation.StoryboardRecorder.storyboard.OnMotionEnd = CommonCtrl.Animation.StoryboardRecorder_test.OnMotionEnd;
	CommonCtrl.Animation.StoryboardRecorder.storyboard.OnTimeChange =CommonCtrl.Animation.StoryboardRecorder_test.OnTimeChange;
end
function CommonCtrl.Animation.StoryboardRecorder_test.onStartRE()
	CommonCtrl.Animation.StoryboardRecorder.doRecorder()
end
function CommonCtrl.Animation.StoryboardRecorder_test.onStopRE()
	CommonCtrl.Animation.StoryboardRecorder.unRecorder()
end
function CommonCtrl.Animation.StoryboardRecorder_test.onPreSecond()
	if(CommonCtrl.Animation.StoryboardRecorder.isRecording == false)then return; end
	if(CommonCtrl.Animation.StoryboardRecorder_test.index>0)then
		CommonCtrl.Animation.StoryboardRecorder_test.index = CommonCtrl.Animation.StoryboardRecorder_test.index - 1;
		local index = CommonCtrl.Animation.StoryboardRecorder_test.index;
		CommonCtrl.Animation.StoryboardRecorder_test.setTimeIndex(index)
		CommonCtrl.Animation.StoryboardRecorder.setCurKeyTime("00:00:"..index)
	end
end
function CommonCtrl.Animation.StoryboardRecorder_test.onNextSecond()
	if(CommonCtrl.Animation.StoryboardRecorder.isRecording == false)then return; end
	CommonCtrl.Animation.StoryboardRecorder_test.index = CommonCtrl.Animation.StoryboardRecorder_test.index + 1;
	local index = CommonCtrl.Animation.StoryboardRecorder_test.index;
	CommonCtrl.Animation.StoryboardRecorder_test.setTimeIndex(index)
	CommonCtrl.Animation.StoryboardRecorder.setCurKeyTime("00:00:"..index)
end
function CommonCtrl.Animation.StoryboardRecorder_test.onPlay()
	CommonCtrl.Animation.StoryboardRecorder.doPlay();	
end
function CommonCtrl.Animation.StoryboardRecorder_test.onStop()
	CommonCtrl.Animation.StoryboardRecorder.doStop();
end
function CommonCtrl.Animation.StoryboardRecorder_test.onPause()
	CommonCtrl.Animation.StoryboardRecorder.doPause();
end
function CommonCtrl.Animation.StoryboardRecorder_test.onEnd()
	CommonCtrl.Animation.StoryboardRecorder.doEnd();
end
function CommonCtrl.Animation.StoryboardRecorder_test.speedNextFrame()
	CommonCtrl.Animation.StoryboardRecorder.speedNextTime("00:00:02");
end
function CommonCtrl.Animation.StoryboardRecorder_test.speedPreFrame()
	CommonCtrl.Animation.StoryboardRecorder.speedPreTime("00:00:02");
end
function CommonCtrl.Animation.StoryboardRecorder_test.gotoAndStopPreTime()
	CommonCtrl.Animation.StoryboardRecorder.gotoAndStopPreTime("00:00:01");
end
function CommonCtrl.Animation.StoryboardRecorder_test.gotoAndStopNextTime()
	CommonCtrl.Animation.StoryboardRecorder.gotoAndStopNextTime("00:00:01");
end

function CommonCtrl.Animation.StoryboardRecorder_test.OnMotionStart(sControlName,frame)
	--commonlib.echo("OnPlay");
	CommonCtrl.Animation.StoryboardRecorder_test.ProgressTime(frame,"开始")
end
function CommonCtrl.Animation.StoryboardRecorder_test.OnMotionStop(sControlName,frame)
	--commonlib.echo("OnStop");
	CommonCtrl.Animation.StoryboardRecorder_test.ProgressTime(frame,"停止到最前")
end
function CommonCtrl.Animation.StoryboardRecorder_test.OnMotionEnd(sControlName,frame)
	--commonlib.echo("OnStop");
	CommonCtrl.Animation.StoryboardRecorder_test.ProgressTime(frame,"停止到最后")
end
function CommonCtrl.Animation.StoryboardRecorder_test.OnMotionPause()
	--commonlib.echo("OnStop");
end
function CommonCtrl.Animation.StoryboardRecorder_test.OnTimeChange(sControlName,frame)
	CommonCtrl.Animation.StoryboardRecorder_test.ProgressTime(frame,"")
end
function CommonCtrl.Animation.StoryboardRecorder_test.ProgressTime(frame,state)
	--commonlib.echo("OnTimeChange");
	if(not state)then state = ""; end
        --frame = frame - 1
        local time = CommonCtrl.Animation.TimeSpan.GetTime(frame);
        if(not time)then
            time = "wrong time";
        end
        local milliseconds = CommonCtrl.Animation.TimeSpan.GetMilliseconds(time,state)
        CommonCtrl.Animation.StoryboardRecorder_test.setTimeIndex(milliseconds/1000)
        
        CommonCtrl.Animation.StoryboardRecorder_test.setTimeTxt(state.." 目前为第："..frame.."帧"..",时间："..time)
end
function CommonCtrl.Animation.StoryboardRecorder_test.SaveMotionFile()
	CommonCtrl.Animation.StoryboardRecorder.SaveMotionFile()
end
function CommonCtrl.Animation.StoryboardRecorder_test.OpenMotionFile(path)
	CommonCtrl.Animation.StoryboardRecorder.OpenMotionFile(path)
	local storyboard = CommonCtrl.Animation.StoryboardRecorder.storyboard
	if(storyboard)then
		CommonCtrl.Animation.StoryboardRecorder_test.index = 0;
		CommonCtrl.Animation.StoryboardRecorder_test.addEvent()
	end
end	
function CommonCtrl.Animation.StoryboardRecorder_test.DirectlyPlay()
	CommonCtrl.Animation.StoryboardRecorder_test.OpenMotionFile("script/ide/Animation/test/movieScript.xml")
	CommonCtrl.Animation.StoryboardRecorder_test.onPlay()
end	



