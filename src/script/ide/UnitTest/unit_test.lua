--[[
Title: a unit test framework 
Author: LiXizhi
Date : 2008.3.5
Desc: It parses a test file (see sample_test_file), optionally replace test case input with user supplied ones, and finally output the test result to file and log. 
Test file markup: 
A test file may contain a group of test cases. Test cases can be declared in NPL comment block with the following format: 
	%TESTCASE{"<test_case_name>", func = "<test_function>", input = <default_input>, output="<result_file>"}%
The content inside %TESTCASE is actually an NPL table, where 
	test_case_name is test case name, test_function is the name of the function to be called for the test case. 
	The test function is usually defined in the test file itself and should use global name. 
	default_input is input to the test case function. 
	result_file is where to save the test result. if this is nil, it will be saved to testfile.result
For an example test file, please see script/ide/UnitTest/sample_test_file.lua. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/UnitTest/unit_test.lua");
local test = commonlib.UnitTest:new();
if(test:ParseFile("script/ide/UnitTest/sample_test_file.lua")) then
	test:Run();
end
-- or one can call individually with user input. 
local test = commonlib.UnitTest:new();
if(test:ParseFile("script/ide/UnitTest/sample_test_file.lua")) then
	test:ClearResult();
	local i, count = 1, test:GetTestCaseCount()
	for i = 1, count do
		test:RunTestCase(i, {"any user input"});
	end
end
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/common_control.lua");

local UnitTest = {
	-- unit test name 
	name = "untitled", 
	-- test file name
	testfilename = nil,
	-- array of test cases
	cases = {},
}
commonlib.UnitTest = UnitTest;

function UnitTest:new (o)
	o = o or {}   -- create object if user does not provide one
	o.cases = o.cases or {};
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Parse the test case file so that we can extract all test case info in the file, 
-- such as the number of test cases in the file, and the description and input of each test cases. 
function UnitTest:ParseFile(testfilename)
	NPL.load("(gl)script/ide/UnitTest/unit_test_case.lua");

	local file = ParaIO.open(testfilename, "r");
	if(file:IsValid()) then
		local fileText = file:GetText();
		file:close();
		self.testfilename = testfilename;
		
		-- load the test file so that test functions are loaded to runtime. 
		NPL.load("(gl)"..testfilename);
		
		-- extract all test case info from that file %TESTCASE{...}%
		local testcaseText;
		for testcaseText in string.gfind(fileText, "%%TESTCASE(%{.-%})%%") do
			local testcase = commonlib.TestCase:new({testfilename = testfilename});
			testcase:Init(testcaseText);
			table.insert(self.cases, testcase);
		end
		return true;
	else
		log("warning: test file not found at "..tostring(testfilename).."\n")	
		return
	end	
end

-- @return: the number test cases in the parsed test file. Always call ParseFile before calling this. 
function UnitTest:GetTestCaseCount()
	return table.getn(self.cases)
end

-- get test case at index 
function UnitTest:GetTestCase(index)
	return self.cases[index];
end

-- run a given test case with optionally user specified input 
-- @param i: the test case index. 1 based index. 
-- @param input: optionally user specified input to be be passed to the test function. if it is nil, the default input will be used. 
function UnitTest:RunTestCase(i, input)
	local case = self.cases[i];
	if(not case) then
		log(string.format("warning: test cases %d does not exist\n", i))
		return
	end
	local outputfile = case:GetOutputFileName();
	if(outputfile) then
		log(string.format("test result is being saved to: %s \n", outputfile))
		self.fromLogPos = commonlib.log.GetLogPos();
	end	
	
	log(string.format("---+++ case %d\n", i))
	case:Run(input,outputfile);
	
	-- append result to file. 
	if(outputfile) then
		local file = ParaIO.open(outputfile, "a");
		if(file:IsValid()) then
			file:WriteString(ParaGlobal.GetLog(self.fromLogPos, -1));
			file:close();
		end	
	end	
end

-- run all test cases with default input for each test cases. 
function UnitTest:Run()
	self:ClearResult();
	local i, count = 1, self:GetTestCaseCount()
	for i = 1, count do
		self:RunTestCase(i);
	end
end

-- clear all output result from previous test
function UnitTest:ClearResult()
	local i, count = 1, self:GetTestCaseCount()
	for i = 1, count do
		local case = self.cases[i];
		if(case and case:GetOutputFileName()) then
			ParaIO.DeleteFile(case:GetOutputFileName());
		end
	end
end

