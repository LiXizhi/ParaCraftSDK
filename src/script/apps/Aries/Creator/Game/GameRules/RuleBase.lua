--[[
Title: Base class for all Rules
Author(s): LiXizhi
Date: 2014/1/27
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/GameRules/RuleBase.lua");
-------------------------------------------------------
]]
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")

local RuleBase = commonlib.inherit(nil, commonlib.gettable("MyCompany.Aries.Game.Rules.RuleBase"));

function RuleBase:ctor()
end

function RuleBase:Init(rule_name, rule_value)
end

-- helper function
function RuleBase:GetBool(isEnabled)
	return isEnabled == true or isEnabled=="true" or isEnabled=="on";
end

-- helper function parse number
function RuleBase:GetNumber(value)
	if(type(value) == "string") then
		value = value:match("%-?[%d%.]*");
		if(value) then
			return tonumber(value);
		end
	elseif(type(value) == "number") then
		return value;
	end
end

function RuleBase:OnRemove()
end