--[[
Title: displaying chat messages in a control
Author(s): LiXizhi
Date: 2006/10/27
Desc: 
Use Lib: 
-------------------------------------------------------
NPL.load("(gl)script/ide/chat_display.lua");

local ctl = CommonCtrl.chat_display:new{
	name = "chat_display1",
	alignment = "_lt",
	left=0, top=0,
	width = 300,height = 50,
	max_lines = 5,
	parent = nil,
};
ctl:Show();
-- at any time, one can call. 
CommonCtrl.chat_display.AddText("chat_display1", "Hi, there!");
-------------------------------------------------------
]]
-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local chat_display = {
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 70,
	-- max number of line
	max_lines = 50,
	-- log file
	logfile = "chat.txt",
	-- parent UI object, nil will attach to root.
	parent = nil,
	-- whether the most recent messages are displayed on top. 
	RecentOnTop = true,
	-- the top level control name
	name = "chat_display1",
}
CommonCtrl.chat_display = chat_display;

-- constructor
function chat_display:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function chat_display:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param sCtrlName: the control name 
--@param text: text to be appended.
function chat_display.AddText(sCtrlName, text)
	if(not text) then return end
	local self = CommonCtrl.GetControl(sCtrlName);
	local _this;
	
	if(self~=nil) then
		_this = ParaUI.GetUIObject(self.name.."_text");	
	end
	if(not _this or  not _this:IsValid())then
		if(KidsUI_ShowChatWindow ~= nil) then
			KidsUI_ShowChatWindow(true);
			self = CommonCtrl.GetControl(sCtrlName);
			if(self==nil)then
				log(string.format([[err getting chat control %s]],sCtrlName));
				return;
			end
		else
			log(string.format([[err getting chat control %s]],sCtrlName));
			return;
		end
		
		_this = ParaUI.GetUIObject(self.name.."_text");	
	end

	if(_this:IsValid() == true)then 
		if(self.RecentOnTop ==true) then
			_this.text = text.."\r\n".._this.text;
		else
			_this.text = _this.text..text.."\r\n";
		end
		-- TODO: write to chat log file.
		-- discard old text, if the total text is longer than 1000
		if(string.len(_this.text)>1000) then
			_this.text = string.sub(_this.text, 0, 1000);
		end
		_this:DoAutoSize();
		_this.parent:InvalidateRect();
	end	
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function chat_display:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("chat_display instance name can not be nil\r\n");
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
	
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		--_this.background="Texture/msg_box.png";
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "255 255 255 20")
		
		_this.scrollable=true;
		
		_parent = _this;
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		_this=ParaUI.CreateUIObject("text", self.name.."_text", "_lt",0,0,self.width-1,self.height-1);
		_parent:AddChild(_this);
		_this.autosize=true;
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end
	end	
end
