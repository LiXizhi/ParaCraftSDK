--[[
Title: CaptionTarget
Author(s): Leio Zhang
Date: 2008/10/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/CaptionTarget.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/Target/BaseTarget.lua");
local CaptionTarget = commonlib.inherit(CommonCtrl.Animation.Motion.BaseTarget, {
	Property = "CaptionTarget",
	ID = nil,
	Text = nil,
});
commonlib.setfield("CommonCtrl.Animation.Motion.CaptionTarget",CaptionTarget);

function CaptionTarget:GetDifference(curTarget,nextTarget)
	return nil;
end
function CaptionTarget:GetDefaultProperty()
	self.Text = "";
end
function CaptionTarget:Update()
	local s = self.Text;
	CommonCtrl.Animation.MovieCaption.setText(s)
end
function CaptionTarget:ReverseToMcml()
	local mcmlTitle = self.Property;
	local Text = self.Text or "";
	Text = "<![CDATA["..Text.."]]>"
	local str = string.format([[<%s>%s</%s>]],mcmlTitle,Text,mcmlTitle);
	return str;
end