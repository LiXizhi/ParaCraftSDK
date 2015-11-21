--[[
Title: a unit test case in unit test framework
Author: LiXizhi
Date : 2008.3.5
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/UnitTest/unit_test_case.lua");
local testcase = commonlib.TestCase:new();
testcase:Init("{\"Example Test\", func=\"test.Example_Test_Function\", input={varInt = 1, varString = \"this is a string\"}, output=\"temp/test_result.txt\"}");
testcase:Run();
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/common_control.lua");

---------------------------------------------
-- unit test case class 
---------------------------------------------
local TestCase = {
	-- unit test case name 
	name = "untitled", 
	-- test file name
	testfilename = nil,
	-- function pointer of the test function
	func = nil,
	-- default input to test function 
	input = nil,
	-- test result output file, if nil it will default to <testfilename>.result
	output = nil,
}
commonlib.TestCase = TestCase;

function TestCase:new (o)
	o = o or {}   -- create object if user does not provide one
	o.cases = o.cases or {};
	setmetatable(o, self)
	self.__index = self
	return o
end

-- init test from string. 
function TestCase:Init(textString)
	--TODO: shall we ensure that textString is secure? 
	-- if(textString and NPL.IsSCodePureData(textString)) then
	if(textString) then
		local params = commonlib.LoadTableFromString(textString);
		if(params) then
			self.name = params[1] or params.name or self.name;
			self.output = params.output;
			self.func = params.func;
			if(type(self.func) == "string") then
				self.func = commonlib.getfield(self.func);
			end
			self.input = params.input;
		else	
			commonlib.log("warning: invalid params in TESTCASE"..textString.."\n")	
		end
	else
		commonlib.log("warning: invalid params in TESTCASE"..textString.."\n")	
	end
end

-- run test
-- @param input: input table to test case function or nil to use the default. 
function TestCase:Run(input,output)
	input = input or self.input
	output = output or self.output
	if(type(self.func) == "function") then
		-- output: title
		log(string.format("_case_: %s\n\n", self.name))
		
		-- output input
		log("Input:\n<verbatim>\n")
		commonlib.log(commonlib.serialize(input))
		log("</verbatim>\n\n")
		
		-- run and output result
		log("_Result_:\n<verbatim>\n")
		self.func(input,output);
		log("</verbatim>\n\n")
	else
		log("error: invalid test case function. \n")	
	end
end

function TestCase:GetOutputFileName()
	if(self.output) then
		return self.output
	elseif(self.testfilename) then
		return self.testfilename..".result"
	end
end