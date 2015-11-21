-- #!/usr/bin/env wsapi.cgi
-- DEPRECATED IN NPL_HTTP. SEE HELLOWORLD.LUA INSTEAD. 
-- file name is the module name, so make it distinct
module(..., package.seeall)

-- the function to be called when request arrives
-- @param wsapi_env: 
-- {DOCUMENT_ROOT="script/apps/WebServer/test",
--  CONTENT_LENGTH="",
--  SCRIPT_NAME="/helloworld.lua",
--  SCRIPT_FILENAME="script/apps/WebServer/test/helloworld.lua",
--  PATH_INFO="/",
--  PATH_TRANSLATED="script/apps/WebServer/test/helloworld.lua",
--  error="",
--  input={length=0,},
--  }
function run(wsapi_env)
	local headers = { ["Content-type"] = "text/html" }

	local function hello_text()
		coroutine.yield("<html><body>")
		coroutine.yield("<p>Hello from NPL/ParaEngine!</p>")
		coroutine.yield("<p>PATH_INFO: " .. wsapi_env.PATH_INFO .. "</p>")
		coroutine.yield("<p>SCRIPT_NAME: " .. wsapi_env.SCRIPT_NAME .. "</p>")

		coroutine.yield("<p>begin async call: for 1 seconds</p>")
		local bHasAsyncCallFinished;
		
		NPL.load("(gl)script/ide/timer.lua");
		local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
			-- One can not call coroutine.yield outside the external function. 
			-- coroutine.yield("<p>tick: " ..nCount.. "</p>") -- this is invalid
			
			-- async call finished
			bHasAsyncCallFinished = true;
			timer:Change();
		end})
		-- use timer to emulate an async call for 1 seconds
		mytimer:Change(1000, nil);
		
		local nCount = 0;
		repeat
			nCount = nCount + 1
			--coroutine.yield(nCount.."<br/>");
			coroutine.yield("",1); -- wait 1 seconds, if nil it will poll at the same rate as its parent thread, 
		until bHasAsyncCallFinished

		coroutine.yield(format("<p>async call finished with %d empty Ticks</p>", nCount)) 

		coroutine.yield("</body></html>")
	end

	return 200, headers, coroutine.wrap(hello_text)
end