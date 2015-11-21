--[[
Title: rule mapping functions
Author(s):  LiXizhi
Date: 2008/5/21
Desc: It is used to query a mapping from *.rules.lua files
A general rule file or table may contain two kinds of rules: general and special. See the code below.
Firstly, the special rules are searched and then general rules. Special rules are strict mapping from input to output. 
general rules are regular expressions that are evaluated in the given order to map from an input to an output. 
The value parts of both general and special rules table may contain replaceables. 

*Examples:*
<verbatim>
{
	-- an optional regular expression. If this is present, the value must match this test string, in order for any output replaceables to be applied. 
	replaceables_test = "%%",

	-- [optional], replaceable used in self.replaceables, they are replaced in the given order. 
	replaceables_replace = {
		{name="%%AnimPath%%", value="character/Animation/"},
		{name="%%AnimPathV3%%", value="character/Animation/v3/"},
	},
	-- output path replaceables, multiples replaceables may appear in the same output. they are replaced in arbitrary order
	replaceables = {
		["%%pet%%"] = "%%AnimPath%%pet",
		["%%npc%%"] = "%%AnimPath%%npc",
		
		["%%v3%%"] = "character/Animation/v3/",
		["%%common%%"] = "character/Animation/v3/",
	},
	
	-- an optional regular expression. If this is present, the input must match this test string, in order for any general rules to be applied. 
	general_test = nil,
	
	-- general rules are evaluated in the order given below
	general = {
		[".*car$"] = "%common%开车.x",
		[".*motorbike$"] = "%common%骑机车.x",
		[".*bike$"] = "%common%骑自行车.x",
		[".*ship$"] = "%common%开车.x",
		[".*F1$"] = "%common%开F1.x",
	},
	
	-- special rules are strict mapping using hash find. the value field must be string or a table containing multiple strings. 
	special = {
		["coolmotobike"] = "%common%开F1.x",
		["huaban"] = "%common%欢迎.x",
		["huabanche"] = "%common%欢迎.x",
		["bicycle"] = {"%common%骑自行车.x", [4] = "%common%骑自行车_run.x", [13] = "%common%骑自行车_back.x"}
	},
}
</verbatim>

Currently, this is used in MCML url mapping rules, and mount.rules.table file for the auto character mount animation.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/rulemapping.lua");

local testRules = CommonCtrl.rulemapping:new({
	general={["abc.*"]="general"}, 
	special={["abc"]="special",},
})
assert(testRules("abc")=="special")
assert(testRules("abc any word")=="general")
assert(testRules("no mapping")==nil)
------------------------------------------------------------
]]

local libName = "rulemapping";
local libVersion = "1.0";
local rulemapping = commonlib.LibStub:NewLibrary(libName, libVersion);

-- optionally expose via a global name
CommonCtrl.rulemapping = rulemapping; 

-- create from a table or a file. 
-- @param o: it can be the rule table or the filename of the file serialized from a rule table
function rulemapping:new (o)
	if(type(o) == "string") then
		local filename = o;
		o = commonlib.LoadTableFromFile(o);
		if(not o) then
			LOG.warn("unable to load rule mapping from rule file %s", filename);
		end
	end
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- mapping from an input to an output. 
-- @param input: a string
-- @param bPassThrough: if true, the input will be output if no mapping is found. 
--	Otherwise it will return nil if no mapping is found. Default to nil.
-- @return output 
function rulemapping:__call(input, bPassThrough)
	if(not input) then return end
	local output;
	-- search in special rule 
	if(self.special) then
		output = self.special[input];
	end
	-- search in general rule
	if(not output and self.general) then
		-- needs to pass general_test for general rule to apply
		if(not self.general_test or string.match(input, self.general_test)) then
			local n, v;
			for n, v in pairs(self.general) do
				if(string.match(input, n)) then
					output = v;
					break;
				end	
			end
		end
	end
	
	-- if no rule mapping is found, we will passthrough 
	if(not output and bPassThrough) then
		output = input;
	end
	
	-- apply output replaceables
	if(output and self.replaceables) then
	
		local function ApplyReplaceables_(value)
			if(not self.replaceables_test or string.match(value, self.replaceables_test)) then
				local n, v;
				for n, v in pairs(self.replaceables) do
					value = string.gsub(value, n, v);
				end
				if(self.replaceables_replace) then
					for n, v in ipairs(self.replaceables_replace) do
						value = string.gsub(value, v.name, v.value);
					end
				end
			end
			return value;
		end
		
		if(type(output) == "string") then
			-- needs to pass replaceables_test for replaceables rule to apply
			output = ApplyReplaceables_(output);
		elseif(type(output) == "table") then
			local name, value 
			for name, value in pairs(output) do
				if(type(value) == "string") then
					output[name] = ApplyReplaceables_(value);
				end	
			end	
		end	
	end
	return output;
end

