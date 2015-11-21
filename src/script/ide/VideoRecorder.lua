--[[
Title: Video recorder
Author(s): LiXizhi
Date: 2007/8/27
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/VideoRecorder.lua");
VideoRecorder.Show();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/gui_helper.lua");

local L = CommonCtrl.Locale("IDE");

if(not VideoRecorder) then VideoRecorder={}; end

VideoRecorder.EyeSeperationMaxvalue = 0.3;
VideoRecorder.EyeSeperationMinvalue = 0;

function VideoRecorder.OnPauseCapture()
	ParaMovie.PauseCapture();
end

function VideoRecorder.OnResumeCapture()
	ParaMovie.ResumeCapture();
end

function VideoRecorder.OnEndCapture()
	ParaMovie.EndCapture();
	ParaUI.Destroy("recorder_bar");
	local msg = string.format(L"==exited recording mode==\nOutput video file: %s", ParaMovie.GetMovieFileName());
	_guihelper.MessageBox(msg);
	log(ParaMovie.GetMovieFileName().." is recorded\r\n");
end

function VideoRecorder.ShowRecorderBar(bIsRecording, bHide)
	local _this,_parent,__font,__texture;
	
	local temp = ParaUI.GetUIObject("recorder_bar");
	if (temp:IsValid() == true) then
		temp.visible = not bHide;
	else

	_this=ParaUI.CreateUIObject("container","recorder_bar", "_lt",0,0,100,40);
	_this:AttachToRoot();
	_this.scrollable=false;
	_this.background="";
	_this.candrag=true;
	
	_this=ParaUI.CreateUIObject("button","static", "_lt",0,0,30,30);
	_parent=ParaUI.GetUIObject("recorder_bar");_parent:AddChild(_this);
	_this.text="";
	_this.background="Texture/player/stop.png;";
	_this.onclick=";VideoRecorder.OnEndCapture();";
	
	
	_this=ParaUI.CreateUIObject("button","static", "_lt",30,0,30,30);
	_parent=ParaUI.GetUIObject("recorder_bar");_parent:AddChild(_this);
	_this.text="";
	_this.background="Texture/player/pause.png;";
	_this.onclick=";VideoRecorder.OnPauseCapture();";
	
	
	_this=ParaUI.CreateUIObject("button","static", "_lt",60,0,30,30);
	_parent=ParaUI.GetUIObject("recorder_bar");_parent:AddChild(_this);
	_this.text="";
	_this.background="Texture/player/rec.png;";
	_this.onclick=";VideoRecorder.OnResumeCapture();";
	
	end
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function VideoRecorder.Show(bShow)
	local _this,_parent;
	
	_this=ParaUI.GetUIObject("VideoRecorder_cont");
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		local width, height = 396, 400;
		
		-- VideoRecorder_cont
		_this = ParaUI.CreateUIObject("container", "VideoRecorder_cont", "_ct",-width/2,-height/2-50,width, height);
		_guihelper.SetUIColor(_this, "255 255 255 150");
		_this:AttachToRoot();
		_parent = _this;

		_this = ParaUI.CreateUIObject("button", "b", "_lt", 13, 10, 48, 48)
		_this.background="Texture/kidui/common/movie.png";
		_this.tooltip = L"Tips: Record video to any video file format";
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "l", "_lt", 80, 26, 136, 16)
		_this.text = L"Video Recorder";
		_this:GetFont("text").color = "65 105 225";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("text", "l", "_lt", 22, 61, 112, 16)
		_this.text=L"save to";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("imeeditbox", "savetopath", "_lt", 140, 58, 168, 26)
		_this.text="screenshot/";
		_parent:AddChild(_this);
		
		_this = ParaUI.CreateUIObject("button", "button1", "_lt", 314, 58, 48, 26)
		_this.text=L"file";
		_this.onclick="";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("text", "l", "_lt", 22, 93, 96, 16)
		_this.text=L"resolution";
		_parent:AddChild(_this);
		
		local MovieWidth, MovieHeight = ParaMovie.GetMovieScreenSize();
		
		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "VideoRecorder_comboBoxResolution",
			alignment = "_lt",
			left = 140,
			top = 90,
			width = 136,
			height = 24,
			dropdownheight = 106,
 			parent = _parent,
 			AllowUserEdit = false,
			text = string.format("%d*%d", MovieWidth, MovieHeight),
			items = {"320*240", "640*480", "800*600", "1024*768", },
			onselect = "VideoRecorder.OnResolutionSelection();",
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("text", "l", "_lt", 22, 167, 64, 16)
		_this.text=L"codec";
		_parent:AddChild(_this);
		
		-- Codec selection panel
		_this = ParaUI.CreateUIObject("container", "Codec panel", "_lt", 125, 150, 237, 75)
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		_parent = _this;

		local nCodec = ParaMovie.GetEncodeMethod();

		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "VideoRecorder_RadioCurrentCodec",
			alignment = "_lt",
			left = 14,
			top = 15,
			width = 130,
			height = 20,
			parent = _parent,
			isChecked = (nCodec==0),
			text = L"current codec",
			oncheck = VideoRecorder.OnCheckUseCurrentCodec,
		};
		ctl:Show();

		NPL.load("(gl)script/ide/RadioBox.lua");
		local ctl = CommonCtrl.radiobox:new{
			name = "VideoRecorder_RadioSelectNewCodec",
			alignment = "_lt",
			left = 14,
			top = 41,
			width = 154,
			height = 20,
			parent = _parent,
			isChecked = (nCodec~=0),
			text = L"select another",
			oncheck = VideoRecorder.OnCheckUseNewCodec,
		};
		ctl:Show();

		_parent = ParaUI.GetUIObject("VideoRecorder_cont");
		
		_this = ParaUI.CreateUIObject("text", "l", "_lt", 22, 123, 104, 16)
		_this.text = L"FPS:";
		_parent:AddChild(_this);


		NPL.load("(gl)script/ide/dropdownlistbox.lua");
		local ctl = CommonCtrl.dropdownlistbox:new{
			name = "VideoRecorder_comboBoxFPS",
			alignment = "_lt",
			left = 140,
			top = 120,
			width = 136,
			height = 24,
			dropdownheight = 106,
			parent = _parent,
			text = tostring(ParaMovie.GetRecordingFPS()),
			AllowUserEdit = false,
			items = {"10", "15", "20", "25", "30", "60", },
			onselect = "VideoRecorder.OnFPSSelection();",
		};
		ctl:Show();


		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "VideoRecorder_checkBoxRecordUI",
			alignment = "_lt",
			left = 25,
			top = 231,
			width = 370,
			height = 20,
			parent = _parent,
			isChecked = ParaMovie.CaptureGUI(),
			text = L"whether to include user interface in the video",
			oncheck = VideoRecorder.OnCheckRecordUI,
		};
		ctl:Show();

		-- Stereo video panel
		_this = ParaUI.CreateUIObject("container", "StereoVideoPanel", "_lt", 25, 257, 337, 83)
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "255 255 255 64");
		_parent:AddChild(_this);
		_parent = _this;

		NPL.load("(gl)script/ide/CheckBox.lua");
		local ctl = CommonCtrl.checkbox:new{
			name = "VideoRecorder_checkBoxUserStereoVideo",
			alignment = "_lt",
			left = 9,
			top = 12,
			width = 283,
			height = 20,
			parent = _parent,
			isChecked = (ParaMovie.GetStereoCaptureMode()~=0),
			text = L"Whether to use stereo video mode",
			oncheck = VideoRecorder.OnCheckUseStereoMode,
		};
		ctl:Show();

		_this = ParaUI.CreateUIObject("text", "label6", "_lt", 6, 45, 152, 16)
		_this.text = L"Stereo Separation:";
		_parent:AddChild(_this);
	
		
		NPL.load("(gl)script/ide/integereditor_control.lua");
		local ctl = CommonCtrl.CCtrlIntegerEditor:new{
			name = "VideoRecorder_separationDist",
			left=150, top=42,width = 160,
			maxvalue=VideoRecorder.EyeSeperationMaxvalue, minvalue=VideoRecorder.EyeSeperationMinvalue,
			value = ParaMovie.GetStereoEyeSeparation(),
			valueformat = "%.3f",
			parent = _parent,
			UseSlider = true,
			onchange = VideoRecorder.OnChangeStereoSeparationDistance,
		};
		ctl:Show();

		_parent = ParaUI.GetUIObject("VideoRecorder_cont");
		
		_this = ParaUI.CreateUIObject("button", "button2", "_lb", 25, -47, 127, 26)
		_this.text=L"Begin recording";
		_this.onclick=";VideoRecorder.OnBeginCapture();";
		_parent:AddChild(_this);

		_this = ParaUI.CreateUIObject("button", "button3", "_lb", 281, -47, 81, 26)
		_this.text=L"Cancel";
		_this.onclick=";VideoRecorder.OnDestory();";
		_parent:AddChild(_this);
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
end

-- destory the control
function VideoRecorder.OnDestory()
	ParaUI.Destroy("VideoRecorder_cont");
end

function VideoRecorder.OnResolutionSelection()
	local filenameCtl = CommonCtrl.GetControl("VideoRecorder_comboBoxResolution");
	if(filenameCtl~=nil)then
		local text = filenameCtl:GetText();
		-- get the width and height from string, the format is width*height
		local from, to, width, height = string.find(text, "(%d+)%D+(%d+)");
		if(width~=nil and height~=nil) then
			--log("video recoder resolution changed: "..width.." "..height.."\n");	
			ParaMovie.SetMovieScreenSize(tonumber(width), tonumber(height));
		end
	else
		log("warning: error getting control VideoRecorder_comboBoxResolution \n");	
	end
end

function VideoRecorder.OnCheckUseNewCodec(ctrlName, checked)
	if(checked) then
		ParaMovie.SetEncodeMethod(-1);
	end	
end

function VideoRecorder.OnCheckUseCurrentCodec(ctrlName, checked)
	if(checked) then
		ParaMovie.SetEncodeMethod(0);
	end	
end

function VideoRecorder.OnCheckRecordUI(ctrlName, checked)
	if(checked) then
		ParaMovie.SetCaptureGUI(true);
	else
		ParaMovie.SetCaptureGUI(false);
	end
end

function VideoRecorder.OnCheckUseStereoMode(ctrlName, checked)
	if(checked) then
		ParaMovie.SetStereoCaptureMode(1);
	else
		ParaMovie.SetStereoCaptureMode(0);
	end
end

function VideoRecorder.OnFPSSelection()
	local filenameCtl = CommonCtrl.GetControl("VideoRecorder_comboBoxFPS");
	if(filenameCtl~=nil)then
		local FPS = tonumber(filenameCtl:GetText());
		if(FPS~=nil) then
			ParaMovie.SetRecordingFPS(FPS);
		end
	else
		log("warning: error getting control VideoRecorder_comboBoxFPS \n");	
	end
end

function VideoRecorder.OnChangeStereoSeparationDistance(ctrlName)
	local ctrl = CommonCtrl.GetControl(ctrlName);
	if(ctrl~=nil)then
		ParaMovie.SetStereoEyeSeparation(ctrl.value);	
	end	
end

function VideoRecorder.OnBeginCapture()
	VideoRecorder.ShowRecorderBar();
	
	ParaMovie.BeginCapture("");
	VideoRecorder.OnPauseCapture();
	
	-- close dialog
	VideoRecorder.OnDestory();
	
	local codecname=L"Custom";
	local x,y = ParaMovie.GetMovieScreenSize();
	
	local captureGUI;
	if(ParaMovie.CaptureGUI() == true) then
		captureGUI = L"No";
	else
		captureGUI = L"Yes";
	end
	
	local EnableStereo;
	if(ParaMovie.GetStereoCaptureMode() == 0) then
		EnableStereo = L"No";
	else
		EnableStereo = L"Yes";
	end
	
	local msg = string.format(L"==Successfully in recording mode==", 
		x, y,codecname, captureGUI, ParaMovie.GetMovieFileName(),
		ParaMovie.GetRecordingFPS(), EnableStereo, ParaMovie.GetStereoEyeSeparation());
	_guihelper.MessageBox(msg);
end