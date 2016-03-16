--[[
Title: Base class for all Rules
Author(s): LiXizhi
Date: 2014/1/27
Desc: 
rule is an abstract virtual base object that can be loaded or activated. 
Unlike items, rules can be created at runtime by the editor in any way they like. 
We can use command to `/addrule` or activate a `/rule`. A rule can also be instantiated via 
a ItemRule object, and placed inside entity's inventory. When the entity is activated, 
the rule object will also be activated. 

* Some rules are simply attributes of the system: see `RulePlayer.lua`
* Some rules like `Quest.lua` have preconditions, exchange rules and even dialog interface when activated. 

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

-- virtual function: rule is loaded. 
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

-- virtual function: when rule is removed from the system. 
function RuleBase:OnRemove()
end


-- try activate this rule by a triggering entity, usually by user clicking or a signal. 
function RuleBase:Activate(triggerEntity)
	if(self:CheckPrecondition(triggerEntity)) then
		self:OnActivated(triggerEntity);
	end
end

-- virtual function: return true, if the rule can be activated.
function RuleBase:CheckPrecondition(triggerEntity)
	return false;
end


-- virtual function: rule is being activated by a triggering entity, usually by user clicking or a signal. 
function RuleBase:OnActivated(triggerEntity)
end
