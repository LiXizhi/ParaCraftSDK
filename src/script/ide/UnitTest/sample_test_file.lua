--[[
Title: Unit Test sample file
Author(s): LiXizhi
Date: 2008/3/5
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/UnitTest/sample_test_file.lua");
test.Example_Test_Function()

-- result at temp/test_result.txt
%TESTCASE{"Example Test", func="test.Example_Test_Function", input={varInt = 1, varString = "this is a string"}, output="temp/test_result.txt"}%
-- result at script/ide/UnitTest/sample_test_file.lua.result
%TESTCASE{"Example Test 2", func="test.Example_Test_Function", input={varInt2 = 2, varString2 = "Another input"}}%
-------------------------------------------------------
]]

if(not test) then test ={} end

-- passed by LiXizhi 2008.3.5
function test.Example_Test_Function(input)
	log(commonlib.serialize(input).." Test Succeed\n")
end
