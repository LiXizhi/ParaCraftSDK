--[[
Title: default mcml style sheet
Author(s): LiXizhi
Date: 2015/5/4
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/StyleDefault.lua");
local StyleDefault = commonlib.gettable("System.Windows.mcml.StyleDefault");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/mcml/Style.lua");
local StyleDefault = commonlib.inherit(commonlib.gettable("System.Windows.mcml.Style"), commonlib.gettable("System.Windows.mcml.StyleDefault"));

local items = {
	["pe:button"] = {
		padding=5,
		color = "#ffffff",
		background="Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;456 396 16 16:4 4 4 4",
		background_down="Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;473 396 16 16:4 4 4 4",
		background_over="Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;496 400 1 1",
	},
}

function StyleDefault:ctor()
	self:LoadFromTable(items);
end
