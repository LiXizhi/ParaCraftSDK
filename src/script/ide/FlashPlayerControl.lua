--[[
Title: flash player control: it can play swf or flv movie files. 
it handles mouse and key events for the swf movie. 
Author(s): LiXizhi
Date: 2007/3/27
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/FlashPlayerControl.lua");
local ctl = CommonCtrl.FlashPlayerControl:new{
	name = "FlashPlayerControl1",
	FlashPlayerIndex = 0,
	alignment = "_lt",
	left=0, top=0,
	width = 512,
	height = 512,
	parent = nil,
};
ctl:Show();
ctl:LoadMovie("Texture/flash_externalinterface_sample.swf");
_guihelper.MessageBox(ctl:CallFlashFunction("<invoke name=\"CallMeFromApplication\" returntype=\"xml\"><arguments><string>Some text for FlashPlayerControl</string></arguments></invoke>"));
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");

-- define a new control in the common control libary

-- default member attributes
local FlashPlayerControl = {
	-- the top level control name
	name = "FlashPlayerControl1",
	-- flash index
	FlashPlayerIndex = -1,
	background = "", -- current background, it can be a swf file or image file.
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 290, 
	parent = nil,
}
CommonCtrl.FlashPlayerControl = FlashPlayerControl;

-- constructor
function FlashPlayerControl:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function FlashPlayerControl:Destroy()
	ParaUI.Destroy(self.name);
end


--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function FlashPlayerControl:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("FlashPlayerControl instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
	
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background="Texture/whitedot.png;0 0 0 0";
		_this.onmousemove = string.format([[;CommonCtrl.FlashPlayerControl.OnMouseMove("%s");]],self.name);
		_this.onmouseup = string.format([[;CommonCtrl.FlashPlayerControl.OnMouseClick("%s");]],self.name);
		_this.onmousedown = string.format([[;CommonCtrl.FlashPlayerControl.OnMouseClick("%s");]],self.name);
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
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

-- close the given control
function FlashPlayerControl.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting FlashPlayerControl instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end

-- call a flash function
-- @param params: such as "<invoke name=\"CallMeFromApplication\" returntype=\"xml\"><arguments><string>Some text for FlashPlayerControl</string></arguments></invoke>"
function FlashPlayerControl:CallFlashFunction(params)
	commonlib.CallFlashFunction(self.FlashPlayerIndex, params)
end

-- get the flash mouse cursor position by screen coordinate
-- @param UIObjectName: UI object name, such as a container object name
-- @param FlashPlayerIndex: usually 0
-- @param screen_x, screen_y : usually mouse_x, mouse_y from the "onmouseup" event handler
function FlashPlayerControl.GetFlashCursorPosition(UIObjectName, FlashPlayerIndex, screen_x, screen_y)
	local temp = ParaUI.GetUIObject(UIObjectName);
	if(temp:IsValid()==true) then
		-- get relative click position in control
		local x,y, temp_width, temp_height = temp:GetAbsPosition();
		x,y = screen_x - x, screen_y - y;
		local width, height = 128,128;
		width, height = ParaUI.GetFlashPlayer(FlashPlayerIndex):GetTextureInfo(width, height);
		x=x/temp_width*width;
		y=y/temp_height*height;
		return x,y;
	end	
	return 0,0;
end

-- event handler
function FlashPlayerControl.OnMouseClick(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting FlashPlayerControl instance "..sCtrlName.."\r\n");
		return;
	end
	if(self.FlashPlayerIndex>=0) then
		local x,y = CommonCtrl.FlashPlayerControl.GetFlashCursorPosition(self.name, self.FlashPlayerIndex, mouse_x, mouse_y);
		ParaUI.GetFlashPlayer(self.FlashPlayerIndex):SendMessage(0, x,y);
	end	
end
function FlashPlayerControl.OnMouseMove(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting FlashPlayerControl instance "..sCtrlName.."\r\n");
		return;
	end
	if(self.FlashPlayerIndex>=0) then
		local x,y = CommonCtrl.FlashPlayerControl.GetFlashCursorPosition(self.name, self.FlashPlayerIndex, mouse_x, mouse_y);
		ParaUI.GetFlashPlayer(self.FlashPlayerIndex):SendMessage(1, x,y);
	end	
end

-- load a movie by name
function FlashPlayerControl:LoadMovie(sFileName)
	local temp = ParaUI.GetUIObject(self.name);
	if(temp:IsValid()==true) then
		if(sFileName == nil or sFileName == "") then
			temp.visible = false;
			temp.background = "Texture/whitedot.png;0 0 0 0";
		else
			temp.visible = true;
			temp.background = sFileName;
			local flashplayer = ParaUI.GetFlashPlayer(sFileName);
			self.FlashPlayerIndex = flashplayer:GetIndex();
		end
	end
end
function FlashPlayerControl:UnloadMovie(sFileName)
	if(not sFileName or sFileName == "")then return end
	local flashplayer = ParaUI.GetFlashPlayer(sFileName);
	if(flashplayer)then
		flashplayer:UnloadMovie();
	end
end