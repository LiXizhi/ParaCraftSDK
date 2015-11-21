--[[
Title: rules
Author: LiXizhi
Date: 2015/6/8
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/rules.lua");
local Rules = commonlib.gettable("WebServer.Rules");
local rules = Rules:new():init(rules);
-----------------------------------------------
]]

local Rules = commonlib.inherit(nil, commonlib.gettable("WebServer.Rules"));

function Rules:ctor()
end

--[[
@paran rules: table like:
{

    { -- URI remapping example
      match = "^[^%./]*/$",
      with = WebServer.redirecthandler,
      params = {"index.lp"}
    }, 

    { -- cgiluahandler example
      match = {"%.lp$", "%.lp/.*$", "%.lua$", "%.lua/.*$" },
      with = WebServer.cgiluahandler.makeHandler (webDir)
    },
    
    { -- filehandler example
      match = ".",
      with = WebServer.filehandler,
      params = {baseDir = webDir}
    },
} 
]]
function Rules:init(rules)
	local rules_table = self;
    for rule_n, rule in ipairs(rules) do
		local handler
		if(type(rule.with) == "string") then
			rule.with = commonlib.getfield(rule.with) or rule.with;
		end
					
        if type (rule.with) == "function" then
			if rule.params then
			  handler = rule.with(rule.params)
			else
			  handler = rule.with
			end
        elseif type (rule.with) == "table" then
            handler = rule.with.makeHandler(rule.params)
        else
            LOG.std(nil, "warn", "web rule", "The rule has an invalid 'with'=%s field.", tostring(rule.with));
        end
        local match = rule.match
        if type(match) == "string" then
            match = {rule.match}
        end
		if(match) then
			rules_table[rule_n] = { pattern = {}, handler = handler }
			for pat_n, pat in ipairs(match) do
				rules_table[rule_n].pattern[pat_n] = pat
			end
		end
    end
    return rules_table;
end