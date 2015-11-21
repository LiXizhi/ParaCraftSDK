--[[
Title: Unit Test sample file
Author(s): LiXizhi
Date: 2008/3/5
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/UnitTest/sample_test_file1.lua");
test.Example_Test_Function()

-- result at temp/test_result.txt
%TESTCASE{"Another Test", func="test.Example_Test_Function", input={varInt = 1, varString = "this is a string", subTable={f1=10, f2=true}}, output="temp/test_result.txt"}%
-- result at script/ide/UnitTest/sample_test_file.lua.result
%TESTCASE{"Another Test 2", func="test.Example_Test_Function", input={varInt2 = 2, varString2 = "Another input", subTable={f1=10, f2=true}}}%
-------------------------------------------------------
]]

if(not test) then test ={} end

-- passed by LiXizhi 2008.3.5
function test.Example_Test_Function(input)
	log(commonlib.serialize(input).." Test Succeed\n")
end
