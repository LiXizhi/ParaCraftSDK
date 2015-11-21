--[[ 
Title: a xUnit test framework 
Author: ported and improved by LiXizhi, work is based on http://phil.freehackers.org/luaunit/ 
Date : 2010.3.22
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/UnitTest/luaunit.lua");

TestToto = {} --class

    function TestToto:setUp()
        -- set up tests
		self.a = 1
		self.s = 'hop' 
    end

    function TestToto:test1_withFailure()
		print( "some stuff test 1" )
        assertEquals( self.a , 1 )
        -- will fail
        assertEquals( self.a , 2 )
        assertEquals( self.a , 2 )
    end

    function TestToto:test2_withFailure()
		print( "some stuff test 2" )
        assertEquals( self.a , 1 )
        assertEquals( self.s , 'hop' )
        -- will fail
        assertEquals( self.s , 'bof' )
        assertEquals( self.s , 'bof' )
    end

    function TestToto:test3()
		print( "some stuff test 3" )
        assertEquals( self.a , 1 )
        assertEquals( self.s , 'hop' )
        assertEquals( type(self.a), 'number' )
    end
-- class TestToto

TestTiti = {} --class
    function TestTiti:setUp()
        -- set up tests
		self.a = 1
		self.s = 'hop' 
        print( 'TestTiti:setUp' )
    end

	function TestTiti:tearDown()
		-- some tearDown() code if necessary
        print( 'TestTiti:tearDown' )
	end

    function TestTiti:test1_withFailure()
		print( "some stuff test 1" )
        assertEquals( self.a , 1 )
        -- will fail
        assertEquals( self.a , 2 )
        assertEquals( self.a , 2 )
    end

    function TestTiti:test2_withFailure()
		print( "some stuff test 2" )
        assertEquals( self.a , 1 )
        assertEquals( self.s , 'hop' )
        -- will fail
        assertEquals( self.s , 'bof' )
        assertEquals( self.s , 'bof' )
    end

    function TestTiti:test3()
		print( "some stuff test 3" )
        assertEquals( self.a , 1 )
        assertEquals( self.s , 'hop' )
    end
-- class TestTiti

-- simple test functions that were written previously can be integrated
-- in luaunit too
function test1_withFailure()
    assert( 1 == 1)
    -- will fail
    assert( 1 == 2)
end

function test2_withFailure()
    assert( 'a' == 'a')
    -- will fail
    assert( 'a' == 'b')
end

function test3()
    assert( 1 == 1)
    assert( 'a' == 'a')
end

TestFunctions = wrapFunctions( 'test1', 'test2', 'test3' )

-- LuaUnit:run( 'test2_withFailure' )  -- run only one test function
-- LuaUnit:run( 'test1_withFailure' )
-- LuaUnit:run( 'TestToto' ) -- run only on test class
-- LuaUnit:run( 'TestTiti:test3') -- run only one test method of a test class
local nFailCount = LuaUnit:run() -- run all tests
ParaGlobal.Exit(nFailCount); -- optionally exit app. if all succeed, it should return 0.
-------------------------------------------------------
]]

--[[ Some people like assertEquals( actual, expected ) and some people prefer 
assertEquals( expected, actual ).
]]--
USE_EXPECTED_ACTUAL_IN_ASSERT_EQUALS = true

function assertError(f, ...)
	-- assert that calling f with the arguments will raise an error
	-- example: assertError( f, 1, 2 ) => f(1,2) should generate an error
	local has_error, error_msg = not pcall( f, ... )
	if has_error then return end 
	error( "No error generated", 2 )
end

function assertEquals(actual, expected)
	-- assert that two values are equal and calls error else
	if  actual ~= expected  then
		local function wrapValue( v )
			if type(v) == 'string' then return "'"..v.."'" end
			return tostring(v)
		end
		if not USE_EXPECTED_ACTUAL_IN_ASSERT_EQUALS then
			expected, actual = actual, expected
		end

		local errorMsg
		if type(expected) == 'string' then
			errorMsg = "\nexpected: "..wrapValue(expected).."\n"..
                             "actual  : "..wrapValue(actual).."\n"
		else
			errorMsg = "expected: "..wrapValue(expected)..", actual: "..wrapValue(actual)
		end
		print (errorMsg)
		error( errorMsg, 2 )
	end
end

assert_equals = assertEquals
assert_error = assertError

function wrapFunctions(...)
	-- Use me to wrap a set of functions into a Runnable test class:
	-- TestToto = wrapFunctions( f1, f2, f3, f3, f5 )
	-- Now, TestToto will be picked up by LuaUnit:run()
	local testClass, testFunction
	testClass = {}
	local function storeAsMethod(idx, testName)
		testFunction = _G[testName]
		testClass[testName] = testFunction
	end
	local nCount = select("#", ...);
	local i;
	for  i=1, nCount do 
		storeAsMethod(i, select(i, ...));
	end
	
	return testClass
end

function __genOrderedIndex( t )
    local orderedIndex = {}
    for key,_ in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function orderedNext(t, state)
	-- Equivalent of the next() function of table iteration, but returns the
	-- keys in the alphabetic order. We use a temporary ordered key table that
	-- is stored in the table being iterated.

    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
        return key, t[key]
    end
    -- fetch the next value
    key = nil
    for i = 1,table.getn(t.__orderedIndex) do
        if t.__orderedIndex[i] == state then
            key = t.__orderedIndex[i+1]
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

-------------------------------------------------------------------------------
UnitResult = { -- class
	failureCount = 0,
	testCount = 0,
	errorList = {},
	currentClassName = "",
	currentTestName = "",
	testHasFailure = false,
	verbosity = 1
}
	function UnitResult:displayClassName()
		print( '>>>>>>>>> '.. self.currentClassName )
	end

	function UnitResult:displayTestName()
		if self.verbosity > 0 then
			print( ">>> ".. self.currentTestName )
		end
	end

	function UnitResult:displayFailure( errorMsg )
		if self.verbosity == 0 then
			print("F")
		else
			print( errorMsg )
			print( 'Failed' )
		end
	end

	function UnitResult:displaySuccess()
		if self.verbosity > 0 then
			--print ("Ok" )
		else 
			print(".")
		end
	end

	function UnitResult:displayOneFailedTest( failure )
		testName, errorMsg = unpack( failure )
		print(">>> "..testName.." failed")
		print( errorMsg )
	end

	function UnitResult:displayFailedTests()
		if table.getn( self.errorList ) == 0 then return end
		print("Failed tests:")
		print("-------------")
		table.foreachi( self.errorList, self.displayOneFailedTest )
		print()
	end

	function UnitResult:displayFinalResult()
		print("=========================================================")
		self:displayFailedTests()
		local failurePercent, successCount
		if self.testCount == 0 then
			failurePercent = 0
		else
			failurePercent = 100 * self.failureCount / self.testCount
		end
		successCount = self.testCount - self.failureCount
		print( string.format("Success : %d%% - %d / %d",
			100-math.ceil(failurePercent), successCount, self.testCount) )
		return self.failureCount
    end

	function UnitResult:startClass(className)
		self.currentClassName = className
		self:displayClassName()
	end

	function UnitResult:startTest(testName)
		self.currentTestName = testName
		self:displayTestName()
        self.testCount = self.testCount + 1
		self.testHasFailure = false
	end

	function UnitResult:addFailure( errorMsg )
		self.failureCount = self.failureCount + 1
		self.testHasFailure = true
		table.insert( self.errorList, { self.currentTestName, errorMsg } )
		self:displayFailure( errorMsg )
	end

	function UnitResult:endTest()
		if not self.testHasFailure then
			self:displaySuccess()
		end
	end

-- class UnitResult end


LuaUnit = {
	result = UnitResult
}
	-- Split text into a list consisting of the strings in text,
	-- separated by strings matching delimiter (which may be a pattern). 
	-- example: strsplit(",%s*", "Anna, Bob, Charlie,Dolores")
	function LuaUnit.strsplit(delimiter, text)
		local list = {}
		local pos = 1
		if string.find("", delimiter, 1) then -- this would result in endless loops
			error("delimiter matches empty string!")
		end
		while 1 do
			local first, last = string.find(text, delimiter, pos)
			if first then -- found?
				table.insert(list, string.sub(text, pos, first-1))
				pos = last+1
			else
				table.insert(list, string.sub(text, pos))
				break
			end
		end
		return list
	end

	function LuaUnit.isFunction(aObject) 
		return 'function' == type(aObject)
	end

	function LuaUnit.strip_luaunit_stack(stack_trace)
		stack_list = LuaUnit.strsplit( "\n", stack_trace )
		strip_end = nil
		for i = #(stack_list),1,-1 do
			-- a bit rude but it works !
			if string.find(stack_list[i],"[C]: in function `xpcall'",0,true) then
				strip_end = i - 2
			end
		end
		if strip_end then
			table.resize( stack_list, strip_end )
		end
		stack_trace = table.concat( stack_list, "\n" )
		return stack_trace
	end

    function LuaUnit:runTestMethod(aName, aClassInstance, aMethod)
		local ok, errorMsg
		-- example: runTestMethod( 'TestToto:test1', TestToto, TestToto.testToto(self) )
		LuaUnit.result:startTest(aName)

		-- run setUp first(if any)
		if self.isFunction( aClassInstance.setUp) then
				aClassInstance:setUp()
		end

		local function err_handler(e)
			return e..'\n'..debug.traceback()
		end

		-- run testMethod()
        ok, errorMsg = xpcall( aMethod, err_handler )
		if not ok then
			errorMsg  = self.strip_luaunit_stack(errorMsg)
			LuaUnit.result:addFailure( errorMsg )
        end

		-- lastly, run tearDown(if any)
		if self.isFunction(aClassInstance.tearDown) then
			 aClassInstance:tearDown()
		end

		self.result:endTest()
    end

	function LuaUnit:runTestMethodName( methodName, classInstance )
		-- example: runTestMethodName( 'TestToto:testToto', TestToto )
		local methodInstance = loadstring(methodName .. '()')
		LuaUnit:runTestMethod(methodName, classInstance, methodInstance)
	end

    function LuaUnit:runTestClassByName( aClassName )
		-- example: runTestMethodName( 'TestToto' )
		local hasMethod, methodName, classInstance
		hasMethod = string.find(aClassName, ':' )
		if hasMethod then
			methodName = string.sub(aClassName, hasMethod+1)
			aClassName = string.sub(aClassName,1,hasMethod-1)
		end
        classInstance = _G[aClassName]
		if not classInstance then
			error( "No such class: "..aClassName )
		end

		LuaUnit.result:startClass( aClassName )

		if hasMethod then
			if not classInstance[ methodName ] then
				error( "No such method: "..methodName )
			end
			LuaUnit:runTestMethodName( aClassName..':'.. methodName, classInstance )
		else
			-- run all test methods of the class
			for methodName, method in orderedPairs(classInstance) do
			--for methodName, method in classInstance do
				if LuaUnit.isFunction(method) and string.sub(methodName, 1, 4) == "test" then
					LuaUnit:runTestMethodName( aClassName..':'.. methodName, classInstance )
				end
			end
		end
		print()
	end

	-- Run some specific test classes.
	-- If no arguments are passed, run the class names specified on the
	-- command line. If no class name is specified on the command line
	-- run all classes whose name starts with 'Test'
	--
	-- If arguments are passed, they must be strings of the class names 
	-- that you want to run
	function LuaUnit:run(...)
		local nCount = select("#", ...);
		if (nCount > 0) then
			local i;
			for i=1, nCount do 
				local className = select(i, ...);
				if(className) then
					LuaUnit:runTestClassByName(className);
				end
			end
		else 
			-- create the list before. If you do not do it now, you
			-- get undefined result because you modify _G while iterating
			-- over it.
			testClassList = {}
			for key, val in pairs(_G) do 
				if string.sub(key,1,4) == 'Test' then 
					table.insert( testClassList, key )
				end
			end
			for i, val in orderedPairs(testClassList) do 
				if(type(val) == "string") then
					LuaUnit:runTestClassByName(val)
				end
			end
		end
		return LuaUnit.result:displayFinalResult()
	end
-- class LuaUnit

