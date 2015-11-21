--[[
Title: CameraMotionPage
Author(s): Leio
Date: 2010/06/12
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/CameraMotions/CameraMotionPage.lua");
MotionEx.CameraMotionPage.ShowPage()
------------------------------------------------------------
--]]
local CameraMotionPage = commonlib.gettable("MotionEx.CameraMotionPage");
NPL.load("(gl)script/ide/MotionEx/MotionFactory.lua");
local player_name = "test";
local MotionFactory = commonlib.gettable("MotionEx.MotionFactory");
local player = MotionFactory.GetPlayer(player_name)
CameraMotionPage.isShow = false;
CameraMotionPage.avatar_name = nil;
function CameraMotionPage.OnInit()
	local self = CameraMotionPage;
	self.page = document:GetPageCtrl();
end
function CameraMotionPage.CreateSliderbar(params)
	local self = CameraMotionPage;
	local align,left,top,width,height = params.alignment, params.left, params.top, params.width, params.height;
	local _this = ParaUI.CreateUIObject("container", "container_bar", align,left,top,width,height);
	params.parent:AddChild(_this);
	_this.background = "";
	_this.fastrender = false;

	local max_value = player:GetSpace();
	commonlib.echo(max_value);
	NPL.load("(gl)script/ide/SliderBar.lua");
		local ctl = CommonCtrl.SliderBar:new{
			name = "CameraMotionPage.SliderBar",
			alignment = "_lt",
			left = 0,
			top = 0,
			width = width,
			height = height,
			parent = _this,
			value = 0 , -- current value
			min = 0,
			max = max_value,
			min_step = 10,
			canDrag = true,
			onchange = CameraMotionPage.OnSliderBarChanged,
		};
		ctl:Show(true);
	self.sliderbar = ctl;
end
function CameraMotionPage.Update(v)
	local self = CameraMotionPage;
	if(self.sliderbar and v)then
		self.sliderbar:SetValue(v)
	end
end
function CameraMotionPage.DoPlayFromFile()
	local self = CameraMotionPage;
	if(self.page)then
		local filepath = self.page:GetValue("_path");
		MotionFactory.CreateCameraMotionFromFile(player_name,filepath,nil,true,true)
	end
end

function CameraMotionPage.AddTime(v)
	if(not v)then return end
	local self = CameraMotionPage;
	local runtime = player:GetRuntime();
	runtime = runtime + v;
	player:GoToTime(runtime);
end
function CameraMotionPage.OnSliderBarChanged()
	local self = CameraMotionPage;
	if(self.sliderbar)then
		local time = self.sliderbar:GetValue();
		player:GoToTime(time);
	end
end
function CameraMotionPage.ShowPage()
	local self = CameraMotionPage;
	local app_key;
	if(MyCompany.Aries.app)then
		app_key=MyCompany.Aries.app.app_key;
	elseif(MyCompany.Taurus.app)then
		app_key=MyCompany.Taurus.app.app_key;
		if(not self.avatar_name)then
			local avatar = ParaScene.GetPlayer();
			if(avatar and avatar:IsValid())then
				self.avatar_name = avatar:GetID();
			end
		end
	end
	if(not app_key)then return end

	if(self.page)then
		if(self.isShow)then
			self.isShow = false;
		else
			self.isShow = true;
		end
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="CameraMotionPage.ShowPage", 
			app_key=app_key, 
			bShow = self.isShow,bDestroy = false,});
	else
		System.App.Commands.Call("File.MCMLWindowFrame", {
				url = "script/ide/MotionEx/CameraMotions/CameraMotionPage.html", 
				name = "CameraMotionPage.ShowPage", 
				app_key = app_key, 
				isShowTitleBar = true,
				DestroyOnClose = false, -- prevent many ViewProfile pages staying in memory
				style = CommonCtrl.WindowFrame.ContainerStyle,
				zorder = 1,
				allowDrag = true,
				directPosition = true,
					align = "_ct",
					x = -300,
					y = -200,
					width = 600,
					height = 400,
			});
	end
end
function CameraMotionPage.HidePage()
	local self = CameraMotionPage;
	local app_key;
	if(MyCompany.Aries.app)then
		app_key=MyCompany.Aries.app.app_key;
	elseif(MyCompany.Taurus.app)then
		app_key=MyCompany.Taurus.app.app_key;
	end
	if(not app_key)then return end
	self.isShow = false;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="CameraMotionPage.ShowPage", 
			app_key=app_key, 
			bShow = false,bDestroy = false,});
end
function CameraMotionPage.DoPlay()
	local self = CameraMotionPage;
	if(self.sliderbar)then
		local max_value = player:GetSpace();
		self.sliderbar.max = max_value;
	end
end
function CameraMotionPage.DoPause()
	if(player.ispause)then
	    player:Resume();
	else
	    player:Pause();
	end
end
function CameraMotionPage.DoResume()
	
    player:Resume();
end
function CameraMotionPage.DoStop()
    player:Stop();
end
function CameraMotionPage.DoEnd()
    player:End();
	
end
function CameraMotionPage.DoPre(t)
	t = t or -50;
    CameraMotionPage.AddTime(-50);
end
function CameraMotionPage.DoNext(t)
	t = t or 50;
    CameraMotionPage.AddTime(t);
end
function CameraMotionPage.DoFindAvatar()
	local self = CameraMotionPage;
	local avatar;
	if(MyCompany.Aries.app)then
		avatar = MyCompany.Aries.Pet.GetRealPlayer();
	elseif(MyCompany.Taurus.app)then
		if(self.avatar_name)then
			avatar = ParaScene.GetObject(self.avatar_name);
		end
	end
	if(avatar and avatar:IsValid())then
		avatar:ToCharacter():SetFocus();
	end
end