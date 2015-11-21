--[[
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/test/storyboardPlayer_test.lua");
CommonCtrl.Animation.storyboardPlayer_test.show();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/StoryBoardPlayer.lua");
local storyboardPlayer_test = {};
commonlib.setfield("CommonCtrl.Animation.storyboardPlayer_test",storyboardPlayer_test);
function CommonCtrl.Animation.storyboardPlayer_test.show()
	NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");
	local _app = CommonCtrl.os.CreateGetApp("storyboardPlayer_test");
	local _wnd = _app:FindWindow("storyboardPlayer_test") or _app:RegisterWindow("storyboardPlayer_test", nil, Map3DSystem.App.Debug.DebugWnd.MSGProc);
	
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
			
			ShowUICallback =CommonCtrl.Animation.storyboardPlayer_test.CreateDlg,
		};
		_appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	end
	Map3DSystem.UI.Windows.ShowWindow(true, _appName, _wndName);
	--_guihelper.ShowDialogBox("storyboardPlayer_test", 0,200, 400, 400, CommonCtrl.Animation.storyboardPlayer_test.CreateDlg, CommonCtrl.Animation.storyboardPlayer_test.OnDlgResult,3);
end
function CommonCtrl.Animation.storyboardPlayer_test.CreateDlg(bShow, _parent, parentWindow)
	local _this;
	_this = ParaUI.CreateUIObject("container", "storyboardPlayer_test", "_fi", 0,0,0,0)	
	--_this.background = "Texture/whitedot.png;";
	_parent:AddChild(_this);
	_parent = _this;
	local left,top,width,height=10,10,60,20;	
	
	-- open
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "output", "_lt", left,top,width,height)
	_this.text="打开";
	_this.onclick=";CommonCtrl.Animation.storyboardPlayer_test.Open();";
	_parent:AddChild(_this);
	
	-- btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "output", "_lt", left,top,width,height)
	_this.text="直接播放";
	_this.onclick=";CommonCtrl.Animation.storyboardPlayer_test.DirectlyPlay();";
	_this.background = "Texture/3DMapSystem/common/ThemeLightBlue/btn_bg_highlight.png: 4 4 4 4"
	_parent:AddChild(_this);
	
	--save btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "output", "_lt", left,top,width,height)
	_this.text="保存";
	_this.onclick=";CommonCtrl.Animation.storyboardPlayer_test.SaveMotionFile();";
	_parent:AddChild(_this);
	
	--onPlay btn
	left = 10
	left,top,width,height=left,top+30,width,height
	_this = ParaUI.CreateUIObject("button", "play_btn", "_lt", left,top,width,height)
	_this.text="播放";
	_this.onclick=";CommonCtrl.Animation.storyboardPlayer_test.onPlay();";
	_parent:AddChild(_this);
	
	--onPause btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "pause_btn", "_lt", left,top,width,height)
	_this.text="暂停";
	_this.onclick=";CommonCtrl.Animation.storyboardPlayer_test.onPause();";
	_parent:AddChild(_this);
	
	--onResume btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "pause_btn", "_lt", left,top,width,height)
	_this.text="继续";
	_this.onclick=";CommonCtrl.Animation.storyboardPlayer_test.onResume();";
	_parent:AddChild(_this);
	
	--onSpeedPre btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="快退2秒";
	_this.onclick=";CommonCtrl.Animation.storyboardPlayer_test.speedPreFrame();";
	_parent:AddChild(_this);
	
	--onSpeedNext btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="快进2秒";
	_this.onclick=";CommonCtrl.Animation.storyboardPlayer_test.speedNextFrame();";
	_parent:AddChild(_this);
	
	left = 10
	--gotoAndStopPreTime btn
	left,top,width,height=left,top+30,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="停在前一秒";
	_this.onclick=";CommonCtrl.Animation.storyboardPlayer_test.gotoAndStopPreTime();";
	_parent:AddChild(_this);
	
	--gotoAndStopNextTime btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="停在后一秒";
	_this.onclick=";CommonCtrl.Animation.storyboardPlayer_test.gotoAndStopNextTime();";
	_parent:AddChild(_this);
	
	--onStop btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="停止";
	_this.onclick=";CommonCtrl.Animation.storyboardPlayer_test.onStop();";
	_parent:AddChild(_this);
	
	--onEnd btn
	left,top,width,height=left+60,top,width,height
	_this = ParaUI.CreateUIObject("button", "stop", "_lt", left,top,width,height)
	_this.text="停止到最后";
	_this.onclick=";CommonCtrl.Animation.storyboardPlayer_test.onEnd();";
	_parent:AddChild(_this);
	
	--time
	left = 10
	left,top,width,height=left,top+30,width,height
	_this = ParaUI.CreateUIObject("text", "time_txt", "_lt", left,top,600,height)
	_this.text="";
	_parent:AddChild(_this);
	
end

-----------------
function CommonCtrl.Animation.storyboardPlayer_test.setTimeTxt(txt)
	local time_txt = ParaUI.GetUIObject("time_txt");
	time_txt.text = txt;
end
function CommonCtrl.Animation.storyboardPlayer_test.setTimeLineTxt(txt)
	local timeline = ParaUI.GetUIObject("timeline");
	timeline.text = txt;
end
function CommonCtrl.Animation.storyboardPlayer_test.setTimeIndex(v)
	CommonCtrl.Animation.storyboardPlayer_test.index = v;
	local time = CommonCtrl.Animation.TimeSpan.GetMillisecondsToTimeStr(v*1000)
	CommonCtrl.Animation.storyboardPlayer_test.setTimeLineTxt("时间轴在："..time)
end

function CommonCtrl.Animation.storyboardPlayer_test.addEvent()
	CommonCtrl.Animation.storyboardPlayer_test.player.OnMotionStart = CommonCtrl.Animation.storyboardPlayer_test.OnMotionStart;
	CommonCtrl.Animation.storyboardPlayer_test.player.OnMotionPause = CommonCtrl.Animation.storyboardPlayer_test.OnMotionPause;
	CommonCtrl.Animation.storyboardPlayer_test.player.OnMotionStop = CommonCtrl.Animation.storyboardPlayer_test.OnMotionStop;
	CommonCtrl.Animation.storyboardPlayer_test.player.OnMotionEnd = CommonCtrl.Animation.storyboardPlayer_test.OnMotionEnd;
	CommonCtrl.Animation.storyboardPlayer_test.player.OnTimeChange =CommonCtrl.Animation.storyboardPlayer_test.OnTimeChange;
end

function CommonCtrl.Animation.storyboardPlayer_test.onPlay()
	CommonCtrl.Animation.storyboardPlayer_test.player:doPlay();	
end
function CommonCtrl.Animation.storyboardPlayer_test.onStop()
	CommonCtrl.Animation.storyboardPlayer_test.player:doStop();
end
function CommonCtrl.Animation.storyboardPlayer_test.onPause()
	CommonCtrl.Animation.storyboardPlayer_test.player:doPause();
end
function CommonCtrl.Animation.storyboardPlayer_test.onResume()
	CommonCtrl.Animation.storyboardPlayer_test.player:doResume();
end
function CommonCtrl.Animation.storyboardPlayer_test.onEnd()
	CommonCtrl.Animation.storyboardPlayer_test.player:doEnd();
end
function CommonCtrl.Animation.storyboardPlayer_test.speedNextFrame()
	CommonCtrl.Animation.storyboardPlayer_test.player:speedNextTime("00:00:02");
end
function CommonCtrl.Animation.storyboardPlayer_test.speedPreFrame()
	CommonCtrl.Animation.storyboardPlayer_test.player:speedPreTime("00:00:02");
end
function CommonCtrl.Animation.storyboardPlayer_test.gotoAndStopPreTime()
	CommonCtrl.Animation.storyboardPlayer_test.player:gotoAndStopPreTime("00:00:01");
end
function CommonCtrl.Animation.storyboardPlayer_test.gotoAndStopNextTime()
	CommonCtrl.Animation.storyboardPlayer_test.player:gotoAndStopNextTime("00:00:01");
end

function CommonCtrl.Animation.storyboardPlayer_test.OnMotionStart(sControlName,frame)
	--commonlib.echo("OnPlay");
	CommonCtrl.Animation.storyboardPlayer_test.ProgressTime(frame,"开始")
end
function CommonCtrl.Animation.storyboardPlayer_test.OnMotionStop(sControlName,frame)
	--commonlib.echo("OnStop");
	CommonCtrl.Animation.storyboardPlayer_test.ProgressTime(frame,"停止到最前")
end
function CommonCtrl.Animation.storyboardPlayer_test.OnMotionEnd(sControlName,frame)
	--commonlib.echo("OnStop");
	CommonCtrl.Animation.storyboardPlayer_test.ProgressTime(frame,"停止到最后")
end
function CommonCtrl.Animation.storyboardPlayer_test.OnMotionPause()
	--commonlib.echo("OnStop");
end
function CommonCtrl.Animation.storyboardPlayer_test.OnTimeChange(sControlName,frame)
	CommonCtrl.Animation.storyboardPlayer_test.ProgressTime(frame,"")
end
function CommonCtrl.Animation.storyboardPlayer_test.ProgressTime(frame,state)
	--commonlib.echo("OnTimeChange");
	if(not state)then state = ""; end
        --frame = frame - 1
        local time = CommonCtrl.Animation.TimeSpan.GetTime(frame);
        if(not time)then
            time = "wrong time";
        end
        local milliseconds = CommonCtrl.Animation.TimeSpan.GetMilliseconds(time,state)
        CommonCtrl.Animation.storyboardPlayer_test.setTimeIndex(milliseconds/1000)
        
        CommonCtrl.Animation.storyboardPlayer_test.setTimeTxt(state.." 目前为第："..frame.."帧"..",时间："..time)
end
function CommonCtrl.Animation.storyboardPlayer_test.Open()
	CommonCtrl.Animation.storyboardPlayer_test.player = CommonCtrl.Animation.StoryBoardPlayer:new("script/ide/Animation/test/storyboardPlayer_test.xml")
	CommonCtrl.Animation.storyboardPlayer_test.addEvent()
end	
function CommonCtrl.Animation.storyboardPlayer_test.DirectlyPlay()
	CommonCtrl.Animation.storyboardPlayer_test.Open()
	CommonCtrl.Animation.storyboardPlayer_test.onPlay()
end	
function CommonCtrl.Animation.storyboardPlayer_test.SaveMotionFile()
	CommonCtrl.Animation.storyboardPlayer_test.player:SaveMotionFile()
end



