--[[
Title: convert Chinese Simplified to Chinese traditional encoding
Author: LiXizhi
Date: 2011/8/30
Desc: Please note that simple to traditional is a one to many mapping. So it is not perfect to use this method. 
But we use it anyway to create a quick localised version of a game. 
The translation table is "locale/c_simpl_to_trad.txt", which can be included in pkg or asset manifest file. 
-----------------------------------------------
NPL.load("(gl)script/ide/Codec/ChineseSimpleToTrad.lua");
local ChineseSimpleToTrad = commonlib.gettable("commonlib.ChineseSimpleToTrad");
-- call this function to auto translate 
ChineseSimpleToTrad:ReplaceParaUIObject()
-----------------------------------------------
]]

local ChineseSimpleToTrad = commonlib.gettable("commonlib.ChineseSimpleToTrad");
local type = type;

-- mapping from simplified character to traditional char. 
local simpl_to_trad = {["国"]="國"};

function ChineseSimpleToTrad:init(filename)
	if(type(filename) == "string") then
		-- TODO: load simpl_to_trad
	end
end

-- replace the text property of all ParaUIObject. 
function ChineseSimpleToTrad:ReplaceParaUIObject()
	-- Example: this allows us to add or override an existing luabind property
	ParaUI.ParaUIObject.text = property(
		function(self)  -- get attribute
			return self:GetText();
		end, 
		function(self, value) -- set attribute
			-- TODO: first filter via simpl_to_trad[value] and then pass to game engine. 
			-- self:SetText(simpl_to_trad[value] or value);
			-- "c_S2T": tell ParaEngine to use char_translation file at "locale/c_simpl_to_trad.txt"
			self:SetTextAutoTranslate(value, "c_S2T");  
		end);
end
