--[[
Title: TweenUtil
Author(s): Leio Zhang
Date: 2008/3/20
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Transitions/TweenUtil.lua");
------------------------------------------------------------
--]]

if(not CommonCtrl)then CommonCtrl={}; end
local TweenUtil={};
TweenUtil.IntervalID=0;

CommonCtrl.TweenUtil = TweenUtil;

function TweenUtil.GetIntervalID()
	TweenUtil.IntervalID=TweenUtil.IntervalID+1;
	return TweenUtil.IntervalID;
end