--[[
Title: flash player window
Author(s): LiXizhi
Date: 2009/8/29
Desc: The difference between FlashPlayerControl and FlashPlayerWindow is that the latter is a real win32 window on top of the main rendering window.
The latter also support all mouse events natively by the windows message framework. 

An invisible ui object is created in its place. We track its onsize and ondestroy event, so that the inner win32 flash windows moves with the ui object. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/FlashPlayerWindow.lua");
local ctl = CommonCtrl.FlashPlayerWindow:new{
	name = "FlashPlayerWindow1",
	flash_wnd_name = "MyFlashWindow",
	FlashPlayerIndex = -1,
	alignment = "_lt",
	left=0, top=0,
	width = 960,
	height = 560,
	parent = nil,
};
ctl:Show();
ctl:LoadMovie("Texture/flash_externalinterface_sample.swf");
-- UnloadMovie is automatically called when ui object is gone. 
ctl:UnloadMovie();
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/FlashExternalInterface.lua");

-- define a new control in the common control libary

-- default member attributes
local FlashPlayerWindow = {
	-- the top level control name
	name = "FlashPlayerWindow1",
	-- ParaFlashPlayer's name
	flash_wnd_name = "MyFlashWindow",
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
	-- if true, we will disable window closing during the lifetime of the flash window and restore it to its initial state when the window is created. 
	bDisableWindowClosing=true, 
	IsWindowClosingAllowed = nil,
	-- we will disable 3D scene rendering during the lifetime of the flash window. this is mostly used by full screen flash game. 
	DisableScene = true,
}
CommonCtrl.FlashPlayerWindow = FlashPlayerWindow;

-- constructor
function FlashPlayerWindow:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function FlashPlayerWindow:Destroy ()
	ParaUI.Destroy(self.name);
end


--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function FlashPlayerWindow:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("FlashPlayerWindow instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
	
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background="";
		_this.onsize = string.format([[;CommonCtrl.FlashPlayerWindow.OnSize("%s");]],self.name);
		_this.ondestroy = string.format([[;CommonCtrl.FlashPlayerWindow.OnDestroy("%s");]],self.name);
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		if (self.bDisableWindowClosing) then
			if(self.IsWindowClosingAllowed == nil) then
				self.IsWindowClosingAllowed = ParaEngine.GetAttributeObject():GetField("IsWindowClosingAllowed", true);
			end
			ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", true);
		end
		if(self.DisableScene) then
			self.IsSceneEnabled = ParaScene.IsSceneEnabled();
			ParaScene.EnableScene(true);
		end
		
		local flashplayer = ParaUI.CreateFlashPlayer(self.flash_wnd_name);
		if(flashplayer:IsValid()) then
			self.FlashPlayerIndex = flashplayer:GetIndex();
			flashplayer:SetWindowMode(true);
			--ParaEngine.GetAttributeObject():SetField("Enable3DRendering", false);
		end	
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
function FlashPlayerWindow.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting FlashPlayerWindow instance "..sCtrlName.."\r\n");
		return;
	end
	self:UnloadMovie();
	ParaUI.Destroy(self.name);
end

function FlashPlayerWindow.OnDestroy(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	commonlib.applog("============before FlashPlayerWindow.OnDestroy");
	if(self)then
		-- make sure the movie is unloaded when ui object is gone. 
		self:UnloadMovie();

		if (self.bDisableWindowClosing) then
			ParaEngine.GetAttributeObject():SetField("IsWindowClosingAllowed", self.IsWindowClosingAllowed);
		end
		
		if(self.DisableScene and self.IsSceneEnabled) then
			ParaScene.EnableScene(true);
		end
	end
	commonlib.applog("============after FlashPlayerWindow.OnDestroy");
end

-- automatically match size. Please note the size is always in screen pixels. If d3d surface is strenched, there may be mismatch. 
function FlashPlayerWindow.OnSize(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting FlashPlayerWindow instance "..sCtrlName.."\r\n");
		return;
	end

	local temp = ParaUI.GetUIObject(self.name);
	if(temp:IsValid()) then
		local flashplayer = ParaUI.GetFlashPlayer(self.FlashPlayerIndex);
		if(flashplayer:IsValid()) then
			local x, y, width, height = temp:GetAbsPosition();
			flashplayer:MoveWindow(x, y, width, height);
		end
	end
end

-- call a flash function
-- @param params: such as "<invoke name=\"CallMeFromApplication\" returntype=\"xml\"><arguments><string>Some text for FlashPlayerWindow</string></arguments></invoke>"
function FlashPlayerWindow:CallFlashFunction(params)
	commonlib.CallFlashFunction(self.FlashPlayerIndex, params)
end

-- load a movie by name
function FlashPlayerWindow:LoadMovie(sFileName)
	if(sFileName == nil or sFileName=="") then
		return
	end	
	local temp = ParaUI.GetUIObject(self.name);
	if(temp:IsValid()) then
		local flashplayer;
		if(self.FlashPlayerIndex ~= -1) then
			flashplayer = ParaUI.GetFlashPlayer(self.FlashPlayerIndex);
			flashplayer:LoadMovie(sFileName);
		end
		if(flashplayer:IsValid() == false) then
			flashplayer = ParaUI.CreateFlashPlayer(sFileName);
		end
		if(flashplayer:IsValid()) then
			self.FlashPlayerIndex = flashplayer:GetIndex();
			local x, y, width, height = temp:GetAbsPosition();
			flashplayer:MoveWindow(x, y, width, height);
			flashplayer:SetWindowMode(true);
			
			--ParaEngine.GetAttributeObject():SetField("Enable3DRendering", false);
		end	
	end
end

function FlashPlayerWindow:UnloadMovie()
	if(not self.FlashPlayerIndex)then return end
	local flashplayer = ParaUI.GetFlashPlayer(self.FlashPlayerIndex);
	if(flashplayer)then
		commonlib.applog("============before FlashPlayerWindow:UnloadMovie");
		flashplayer:UnloadMovie();
		flashplayer:SetWindowMode(false);
		commonlib.applog("============after FlashPlayerWindow:UnloadMovie");
		--ParaEngine.GetAttributeObject():SetField("Enable3DRendering", true);
	end
end