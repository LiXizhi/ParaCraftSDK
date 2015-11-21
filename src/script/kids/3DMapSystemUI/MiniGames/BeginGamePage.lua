--[[
Title: 
Author(s): Leio
Date: 2009/9/15
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemUI/MiniGames/BeginGamePage.lua");
-------------------------------------------------------
]]

-- default member attributes
local BeginGamePage = {

}
commonlib.setfield("Map3DSystem.App.MiniGames.BeginGamePage",BeginGamePage);
function BeginGamePage.Show(message,func)
	if(not func)then return end
	if(not message)then
		message = "你要开始游戏么？";
	end
	_guihelper.MessageBox(message, function(result) 
			if(_guihelper.DialogResult.Yes == result) then
				if(type(func) == "string") then
					NPL.DoString(func);
				else
					func();
				end
			elseif(_guihelper.DialogResult.No == result) then
			end
		end, _guihelper.MessageBoxButtons.YesNo);
end
