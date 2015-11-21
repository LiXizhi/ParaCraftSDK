--[[
Title: 
Author(s): Leio
Date: 2009/8/20
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/NPLFlashTest/FlashGameTest.lua");
NPLFlashTest.FlashGameTest.Show();
NPLFlashTest.FlashGameTest.LoadMovie("Games/Beats/Beats.swf");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
NPL.load("(gl)script/ide/FlashPlayerControl.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
-- default member attributes
local FlashGameTest = {
	-- the top level control name
	name = "FlashGameTest1",
	background = "", -- current background, it can be a swf file or image file.
	-- normal window size
	alignment = "_fi",
	left = 0,
	top = 0,
	width = 0,
	height = 0, 
	swf_width = 960,
	swf_height = 560, 
	parent = nil,
	swf_file = nil,
}
commonlib.setfield("NPLFlashTest.FlashGameTest",FlashGameTest);


-- Destroy the UI control
function FlashGameTest.Destroy ()
	local self = FlashGameTest;
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function FlashGameTest.Show(bShow)
	local self = FlashGameTest;
	local _this,_parent;
	if(self.name==nil)then
		log("FlashGameTest instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name.."container");
	if(_this:IsValid() == false) then
	
		local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
		
		_this=ParaUI.CreateUIObject("container",self.name.."container",self.alignment,self.left,self.top,self.width,self.height);
		_this.background="Texture/bg_black.png";
		_parent = _this;
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		local left,top,width,height = (screenWidth - self.swf_width)/2,(screenHeight - self.swf_height)/2,self.swf_width,self.swf_height
		_this=ParaUI.CreateUIObject("container",self.name.."container_swf","_lt",left,top,width,height);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent:AddChild(_this);
		
		local name = self.name.."FlashPlayerControl1";
		NPL.load("(gl)script/ide/FlashPlayerControl.lua");
		local ctl = CommonCtrl.FlashPlayerWindow:new{
			name = name,
			alignment = "_fi",
			left = 0, 
			top = 0,
			width = 0,
			height = 0,
			parent = _this,
			
		};
		ctl:Show();
		CommonCtrl.AddControl(name, ctl);

	else
		if(bShow == nil) then
			if(_this.visible == true) then
				_this.visible = false;
			else
				_this.visible = true;
			end
		else
			_this.visible = bShow;
		end
	end	
end
function FlashGameTest.InvokeAsFunction(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self)then
		local name = self.name.."text";
		local ctl = CommonCtrl.GetControl(name);
		if(ctl)then
			local txt = ctl:GetText();
			local input = {
				funcName = "CallMeFromApplication",
				args = {txt}
			} 
			commonlib.CallFlashFunction(self.FlashPlayerIndex, input)
		end
	end
end
function FlashGameTest.CallNPLFromAs(param)
	if(not param)then return end
	local self = FlashGameTest;
	
	local s = string.format("得分是：%s",tostring(param));
	FlashGameTest.OnClose(self.name)
	_guihelper.MessageBox(s);
	
end
-- close the given control
function FlashGameTest.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting FlashGameTest instance "..sCtrlName.."\r\n");
		return;
	end
	self.UnloadMovie(self.swf_file)
	local name = self.name.."container" ;
	ParaUI.Destroy(name);
end

-- load a movie by name
function FlashGameTest.LoadMovie(sFileName)
	local self = FlashGameTest;
	local name = self.name.."FlashPlayerControl1";
	local ctl =  CommonCtrl.GetControl(name);
	if(ctl)then
		self.swf_file = sFileName;
		ctl:LoadMovie(sFileName);
		--hook FlashPlayerIndex after load swf file
		self.FlashPlayerIndex = ctl.FlashPlayerIndex;
	end
end
function FlashGameTest.UnloadMovie(sFileName)
	local self = FlashGameTest;
	local name = self.name.."FlashPlayerControl1";
	local ctl =  CommonCtrl.GetControl(name);
	if(ctl)then
		ctl:UnloadMovie(sFileName);
	end
end