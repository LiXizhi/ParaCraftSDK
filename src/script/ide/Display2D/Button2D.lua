--[[
Title: Button2D
Author(s): Leio
Date: 2009/7/28
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display2D/Button2D.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display2D/Sprite2D.lua");
local Button2D = commonlib.inherit(CommonCtrl.Display2D.Sprite2D,{
	type = CommonCtrl.Display2D.DisplayObject2DEnums.Button2D,
	text = "button",
	defaultwidth = 50,
	defaultheight = 50,
	mouse_eabled_skin = "Texture/Aries/Inventory/MountAttr.png;0 0 32 18:12 8 12 8",
	mouse_diseabled_skin = nil,
	mouse_over_skin = "Texture/Aries/Inventory/MountAttrSlot.png;0 0 32 18:12 8 12 8",
	mouse_out_skin = nil,
	mouse_up_skin = nil,
	mouse_down_skin = nil,
	
	default_text_width = 50,
	default_text_height = 50,
	
	bitmap = nil,
	textField = nil,
	sprite = nil,
});  
commonlib.setfield("CommonCtrl.Display2D.Button2D",Button2D);

function Button2D:OnAppendInit()
	local sprite = CommonCtrl.Display2D.Sprite2D:new();
	sprite:OnInit()
	local bitmap = CommonCtrl.Display2D.Bitmap2D:new{
		x = 0,
		y = 0,
		width = self.defaultwidth,
		height = self.defaultheight,
		alpha = 1,
		rotation = 0,
		bg = self.mouse_eabled_skin,
	}
	self.bitmap = bitmap;
	sprite:AddChild(bitmap);

	local text = CommonCtrl.Display2D.TextField2D:new{
		x = 0,
		y = 0,
		width = self.default_text_width,
		height = self.default_text_height,
		text = self.text,
	}
	self.textField = text;
	sprite:AddChild(text);
	
	self.sprite = sprite;
	self:AddChild(sprite);
	
	self.sprite:AddEventListener("MouseOver",nil,function(holder,args)
		local skin = self.mouse_over_skin or self.mouse_eabled_skin or "";
		--self.bitmap:SetBG(skin);
		self.bitmap:SetAlpha(0.5);
	end);
	self.sprite:AddEventListener("MouseOut",nil,function(holder,args)
		local skin = self.mouse_out_skin or self.mouse_eabled_skin or "";
		--self.bitmap:SetBG(skin);
		self.bitmap:SetAlpha(1);
	end);

	self.sprite:AddEventListener("MouseDown",nil,function(holder,args)
		local skin = self.mouse_down_skin or self.mouse_eabled_skin or "";
		--self.bitmap:SetBG(skin);
	end);
	self.sprite:AddEventListener("MouseUp",nil,function(holder,args)
		local skin = self.mouse_up_skin or self.mouse_eabled_skin or "";
		--self.bitmap:SetBG(skin);
	end);
	self.sprite:AddEventListener("MouseMove",nil,function(holder,args)
		--commonlib.echo(self:GetRect():ToTable());
	end);
end