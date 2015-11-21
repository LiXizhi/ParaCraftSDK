--[[
Title: TextField2D
Author(s): Leio
Date: 2009/7/28
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display2D/TextField2D.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display2D/DisplayObject2D.lua");
local TextField2D = commonlib.inherit(CommonCtrl.Display2D.DisplayObject2D,{
	type = CommonCtrl.Display2D.DisplayObject2DEnums.TextField2D,
	text = nil,
});  
commonlib.setfield("CommonCtrl.Display2D.TextField2D",TextField2D);

function TextField2D:SetText(text)
	self.text = text;
	self:UpdateNode();
end
function TextField2D:GetText()
	return self.text;
end
-- 返回所有可以被更新的属性,在渲染的时候使用
function TextField2D:GetUpdateablePropertys()
	local rect = self:GetRect();
	local params = {
		x = rect.x,
		y = rect.y,
		width = rect.width,
		height = rect.height,	
		text = self.text,
	}
	local scalex,scaley,alpha,color,rotation,visible = self.scalex,self.scaley,self.alpha,self.color,self.rotation,self.visible
	local parent = self:GetParent();
	while(parent) do
		scalex = scalex * parent.scalex;
		scaley = scaley * parent.scaley;
		alpha = alpha * parent.alpha;
		--color = color * parent.color;没有处理
		rotation = rotation + parent.rotation;
		visible = parent.visible;
		parent = parent:GetParent()
	end
	params.scalex = scalex;
	params.scaley = scaley;
	params.alpha = alpha;
	params.color = color;
	params.rotation = rotation;
	params.visible = visible;
	return params;
end