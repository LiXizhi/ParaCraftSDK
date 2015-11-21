--[[
Title: Save File Dialog
Author(s): LiXizhi
Date: 2015/9/29
Desc: Display a dialog with text that let user to enter filename. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/SaveFileDialog.lua");
local SaveFileDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.SaveFileDialog");
SaveFileDialog.ShowPage("Please enter text", function(result)
	echo(result);
end)
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/OpenFileDialog.lua");
local SaveFileDialog = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.GUI.OpenFileDialog"), commonlib.gettable("MyCompany.Aries.Game.GUI.SaveFileDialog"));

-- overwrite the save mode from base class
SaveFileDialog.IsSaveMode = true;
