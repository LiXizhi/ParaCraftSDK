--[[
Title: EffectTarget
Author(s): Leio Zhang
Date: 2008/10/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/EffectTarget.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/Target/BaseTarget.lua"); 
NPL.load("(gl)script/ide/commonlib.lua");
local EffectTarget = commonlib.inherit(CommonCtrl.Animation.Motion.BaseTarget, {
	Property = "EffectTarget",
	ID = nil,
	Path = nil
});
commonlib.setfield("CommonCtrl.Animation.Motion.EffectTarget",EffectTarget);
function EffectTarget:GetDifference(curTarget,nextTarget)
	return nil;
end
function EffectTarget:GetDefaultProperty(path)
	self.Path = path or "";
end
function EffectTarget:Update(curKeyframe,lastFrame,frame)
	if(not self.Path)then return; end
	-- update special value
	if(not curKeyframe or not lastFrame or not frame)then return; end
	local isActivate = curKeyframe:GetActivate();	
	if(isActivate)then
	end
end