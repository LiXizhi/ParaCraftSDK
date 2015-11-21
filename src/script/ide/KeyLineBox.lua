--[[
Title: 
Author(s): Leio
Date: 2009/6/26
Note: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/KeyLineBox.lua");
local ctl = CommonCtrl.KeyLineBox:new{
	alignment = "_lt",
	left=0, top=0,
	width = 300,
	height = 26,
	parent = nil,
};
ctl:Show();
ctl:Start();
--ctl:Stop();
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/common_control.lua");
local KeyLineBox = {
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 300,
	height = 26, 
}
CommonCtrl.KeyLineBox = KeyLineBox;

function KeyLineBox:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	o:Init();
	return o
end
function KeyLineBox:Init()
	self.name = ParaGlobal.GenerateUniqueID();
	CommonCtrl.AddControl(self.name, self);
end
function KeyLineBox:Start()
	local _this = ParaUI.GetUIObject(self.name.."timer");
	if(not _this:IsValid())then
		_this = ParaUI.CreateUIObject("container",self.name.."timer","_lt",0,0,0,0);
		_this.background="";
		_this.enabled = false;
		_this:AttachToRoot();
	end
	_this.onframemove = string.format([[;CommonCtrl.KeyLineBox.TimeHandle('%s');]],self.name);
end
function KeyLineBox:Stop()
	local _this = ParaUI.GetUIObject(self.name.."timer");
	if(_this:IsValid())then
		_this.onframemove = nil;
	end
end
function KeyLineBox.TimeHandle(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self)then
		local ctrl_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LCONTROL) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RCONTROL);
		local alt_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LMENU) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RMENU);
		local shift_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LSHIFT) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RSHIFT);
		if(ctrl_pressed or alt_pressed or shift_pressed)then	
			if(not self.checked)then
					local keys = {};
					local key,v;
					for key,v in pairs(DIK_SCANCODE) do
						if(ParaUI.IsKeyPressed(v))then
							keys[key] = v;	
						end
					end
					self.checked = self:ConversionKey(keys)
			end
		else
			if(not self.checked)then
				local k,len =1, 15;
				for k = 1,len do
					local s = "DIK_F"..k;
					if(ParaUI.IsKeyPressed(DIK_SCANCODE[s]))then
						local keys = {}
						keys[s] = DIK_SCANCODE[s];
						self:ConversionKey(keys)
						self.checked = true;
						break;
					end
				end
			end
		end
	end
end
function KeyLineBox:ConversionKey(keys)
	if(not keys)then return end
	local s = "";
	local ctrl_pressed;
	local alt_pressed;
	local shift_pressed;
	local char = "";
	local key,v;
	for key,v in pairs(keys) do
		if(v == DIK_SCANCODE.DIK_LCONTROL or v == DIK_SCANCODE.DIK_RCONTROL)then
			ctrl_pressed = true;
		elseif(v == DIK_SCANCODE.DIK_LMENU or v == DIK_SCANCODE.DIK_RMENU)then
			alt_pressed = true;
		elseif(v == DIK_SCANCODE.DIK_LSHIFT or v == DIK_SCANCODE.DIK_RSHIFT)then
			shift_pressed = true;
		else
			local __,__,__,_char = string.find(key,"(.+)_(.+)");
			char = _char;
		end
	end
	if(ctrl_pressed)then
		s = s.."Ctrl+";
	end
	if(alt_pressed)then
		s = s.."Alt+";
	end
	if(shift_pressed)then
		s = s.."Shift+";
	end
	if(char)then
		s = s..char;
	end
	self:SetText(s);
	local len = #keys;
	if(len > 1)then
		return true;
	end
end
function KeyLineBox:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("KeyLineBox instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false and bShow ~= false) then
	
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		if(self.container_bg~=nil) then
			_this.background=self.container_bg;
		else
			_this.background="Texture/whitedot.png;0 0 0 0";
		end	
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end

		-- create the editbox
		_this=ParaUI.CreateUIObject("imeeditbox",self.name.."input", "_fi",0,0,0,0);
		_parent:AddChild(_this);
		_this.onkeyup=string.format([[;CommonCtrl.KeyLineBox.OnKeyUp("%s");]], self.name);
		if(self.editbox_bg~=nil) then
			_this.background=self.editbox_bg;
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
	self:Start();
end

function KeyLineBox.OnKeyUp(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self)then
		-- 清空后,重新监听
		if(virtual_key == Event_Mapping.EM_KEY_BACKSPACE)then
			self:SetText("");
			self.checked = false;
		end
	end
end
function KeyLineBox:SetText(txt)
	local input = ParaUI.GetUIObject(self.name.."input");
	if(input)then
		input.text = txt;	
		local caretPos = input:GetTextSize();
		input:Focus();
		input:SetCaretPosition(caretPos);	
	end
end
function KeyLineBox:GetText()
	local input = ParaUI.GetUIObject(self.name.."input");
	if(input)then
		return input.text;
	end
end

