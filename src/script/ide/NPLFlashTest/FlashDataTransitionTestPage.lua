--[[
Title: 
Author(s): Leio
Date: 2009/9/15
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/NPLFlashTest/FlashDataTransitionTestPage.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/ExternalInterface.lua");
-- default member attributes
local FlashDataTransitionTestPage = {
	
}
commonlib.setfield("NPLFlashTest.FlashDataTransitionTestPage",FlashDataTransitionTestPage);
function FlashDataTransitionTestPage.OnInit()
	local self = FlashDataTransitionTestPage;
	self.page = document:GetPageCtrl();
end

function FlashDataTransitionTestPage.ClosePage()
	local self = FlashDataTransitionTestPage;
	if(self.page)then
		local ctl = self.page:FindControl("flashctl");
		if(ctl)then
			ctl:Destroy();
		end
		self.page:CloseWindow();
	end	
end
function FlashDataTransitionTestPage.CallFlash()
	local self = FlashDataTransitionTestPage;
	if(self.page)then
		local ctl = self.page:FindControl("flashctl");
		if(ctl)then
			local index = ctl.FlashPlayerIndex;
			ExternalInterface.CallFlash(index,"CallFlash","string",0,false,{ x = 0, y = 0, z = 0, name = "hello",show = false,},{1,false,"aa",{ x = 0, y = 0, z = 0, name = "hello",show = false,}});
		end
	end
end
function FlashDataTransitionTestPage.CallNPLFromAs(...)
	local self = FlashDataTransitionTestPage;
	commonlib.echo("=========FlashDataTransitionTestPage.CallNPLFromAs");
	commonlib.echo(arg);
end
