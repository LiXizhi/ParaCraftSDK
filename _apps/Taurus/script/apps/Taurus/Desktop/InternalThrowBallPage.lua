--[[
Title: code behind for page InternalThrowBallPage.html
Author(s): Leio
Date: 2009/8/25
Desc:  script/apps/Aries/Inventory/InternalThrowBallPage.html
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/Desktop/InternalThrowBallPage.lua");
MyCompany.Taurus.Desktop.InternalThrowBallPage.Show()
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/ThrowBall.lua");
local InternalThrowBallPage = {
	page = nil,
	show = false,
	default_throwModel = "model/07effect/v5/Firecracker/Firecracker.x",
	default_hitModel = "model/07effect/v5/Firecracker/Firecracker1.x",
	default_throwAnim = "character/Animation/v5/Throw.x",
};
commonlib.setfield("MyCompany.Taurus.Desktop.InternalThrowBallPage", InternalThrowBallPage);

function InternalThrowBallPage.Show()
	local self = InternalThrowBallPage;
	if(self.show)then
		self.ClosePage();
	else
		self.ShowPage();
	end
end
function InternalThrowBallPage.ShowPage()
	local self = InternalThrowBallPage;
	System.App.Commands.Call("File.MCMLWindowFrame", {
			url = "script/apps/Taurus/Desktop/InternalThrowBallPage.html", 
			name = "InternalThrowBallPage.ShowPage", 
			app_key = MyCompany.Taurus.app.app_key, 
			isShowTitleBar = true,
			DestroyOnClose = false, -- prevent many ViewProfile pages staying in memory
			--style = CommonCtrl.WindowFrame.ContainerStyle,
			zorder = 1,
			directPosition = true,
				align = "_lt",
				x = 100,
				y = 100,
				width = 500,
				height = 250,
				text = "投掷测试",
		});
	self.show = true;
end
function InternalThrowBallPage.Init()
	local self = InternalThrowBallPage;
	if(self.page)then
		self.page:SetValue("throwModel",self.default_throwModel);
		self.page:SetValue("hitModel",self.default_hitModel);
		self.page:SetValue("throwAnim",self.default_throwAnim);
	end
end
function InternalThrowBallPage.ClosePage()
	local self = InternalThrowBallPage;
	self.show = false;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="InternalThrowBallPage.ShowPage", 
		app_key=MyCompany.Taurus.app.app_key, 
		bShow = false,});
end
function InternalThrowBallPage.OnClick()
	local self = InternalThrowBallPage;
	if(not self.page)then return end
	
	local throwModel = self.page:GetValue("throwModel");
	local hitModel = self.page:GetValue("hitModel");
	local throwAnim = self.page:GetValue("throwAnim");
	local effect_time = self.page:GetValue("effect_time");
	local fly_time = self.page:GetValue("fly_time");
	
	local player = ParaScene.GetPlayer();
	if(not player or not player:IsValid())then return end
	local x,y,z = player:GetPosition();
	local playerName = player.name;
	local startPoint = {x = x,y = y,z = z};
	local endPoint = {x = x,y = y,z = z + 5};
	local nid = 0;
	local throwItem={
		gsid=0,
		hitstyle = hitModel or self.default_hitModel,
		style = throwModel or self.default_throwModel, 
		effect_time = effect_time,
	  };
   local throwerLevel=0;
   local throwerState="follow"; 
   local defaultAnimationFile = throwAnim or self.default_throwAnim;
	local throwBall = CommonCtrl.ThrowBall:new{
					startPoint = startPoint,
					endPoint = endPoint,
					ballStyle =  throwModel,
					playerName = playerName,
					nid = nid,
					throwItem = throwItem,
					throwerState = throwerState,
					throwerLevel = throwerLevel,
					throwType = "self",
					
				}
	throwBall.defaultAnimationFile = defaultAnimationFile;
	throwBall.totalTime = fly_time;
	throwBall:Play();
end