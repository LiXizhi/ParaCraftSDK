--[[
Title: 
Author(s): Leio
Date: 2009/8/20
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/NPLFlashTest/CallbackTest.lua");
local ctl = NPLFlashTest.CallbackTest:new{
	name = "FlashPlayerControl1",
	alignment = "_lt",
	left=0, top=0,
	width = 512,
	height = 700,
	swf_width = 512,
	swf_height = 300, 
	parent = nil,
};
ctl:Show();
ctl:LoadMovie("z:/script/ide/NPLFlashTest/Callback.swf");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/FlashPlayerControl.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
-- default member attributes
local CallbackTest = {
	-- the top level control name
	name = "FlashPlayerControl1",
	background = "", -- current background, it can be a swf file or image file.
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 700, 
	swf_width = 512,
	swf_height = 300, 
	parent = nil,
}
commonlib.setfield("NPLFlashTest.CallbackTest",CallbackTest);
-- constructor
function CallbackTest:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function CallbackTest:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function CallbackTest:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("CallbackTest instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
	
		_this=ParaUI.CreateUIObject("container",self.name.."container",self.alignment,self.left,self.top,self.width,self.height);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent = _this;
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		local name = self.name.."FlashPlayerControl1";
		NPL.load("(gl)script/ide/FlashPlayerControl.lua");
		local ctl = CommonCtrl.FlashPlayerControl:new{
			name = name,
			
			alignment = "_lt",
			left = self.left, top = self.top,
			width = self.swf_width,
			height = self.swf_height,
			parent = _parent,
		};
		ctl:Show();
		CommonCtrl.AddControl(name, ctl);

		local name = self.name.."text";
		NPL.load("(gl)script/ide/MultiLineEditbox.lua");
		local ctl = CommonCtrl.MultiLineEditbox:new{
			name = name,
			alignment = "_lt",
			left = 0, 
			top = self.swf_height,
			width = self.swf_width,
			height = 100, 
			parent = _parent,
		};
		ctl:Show(true);
		CommonCtrl.AddControl(name, ctl);
		--InvokeAsFunction
		local left,top,width,height = 0,self.swf_height + 120,100,50
		_this = ParaUI.CreateUIObject("button",self.name.."InvokeAsFunction","_lt",left,top,width,height);
		_this.onclick = string.format(";NPLFlashTest.CallbackTest.InvokeAsFunction('%s');",self.name);
		_this.text = "InvokeAsFunction";
		_parent:AddChild(_this);
		--ClearText
		local left,top,width,height = 120,self.swf_height + 120,100,50
		_this = ParaUI.CreateUIObject("button",self.name.."ClearText","_lt",left,top,width,height);
		_this.onclick = string.format(";NPLFlashTest.CallbackTest.ClearText('%s');",self.name);
		_this.text = "ClearText";
		_parent:AddChild(_this);
		
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
function CallbackTest.ClearText(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self)then
		local name = self.name.."text";
		local ctl = CommonCtrl.GetControl(name);
		if(ctl)then
			ctl:SetText("");
		end
	end
end
function CallbackTest.InvokeAsFunction(sCtrlName)
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
function CallbackTest.CallNPLFromAs(arg1,arg2)
	local self = CallbackTest;
	local args = commonlib.serialize(arg1)..",\r\n"..commonlib.serialize(arg2);
	local name = self.name.."text";
	local ctl = CommonCtrl.GetControl(name);
	if(ctl)then
		ctl:SetText(args);
	end
end
-- close the given control
function CallbackTest.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting CallbackTest instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end

-- load a movie by name
function CallbackTest:LoadMovie(sFileName)
	local name = self.name.."FlashPlayerControl1";
	local ctl =  CommonCtrl.GetControl(name);
	if(ctl)then
		ctl:LoadMovie(sFileName);
		--hook FlashPlayerIndex after load swf file
		self.FlashPlayerIndex = ctl.FlashPlayerIndex;
	end
end