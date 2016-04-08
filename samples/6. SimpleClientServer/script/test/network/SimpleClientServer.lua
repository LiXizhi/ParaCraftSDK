--[[
Author: Li,Xizhi
Date: 2009-6-29
Desc: start one server, and at least one client. 
-----------------------------------------------
npl "script/test/network/SimpleClientServer.lua" server="true"
npl "script/test/network/SimpleClientServer.lua" client="true"
-----------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua"); -- many sub dependency included

local nServerThreadCount = 2;
local initialized;
local isServerInstance = ParaEngine.GetAppCommandLineByParam("server","false") == "true";

-- expose these files. client/server usually share the same public files
local function AddPublicFiles()
    NPL.AddPublicFile("script/test/network/SimpleClientServer.lua", 1);
end

-- NPL simple server
local function InitServer()
    AddPublicFiles();
    
    NPL.StartNetServer("127.0.0.1", "60001");
	
	for i=1, nServerThreadCount do
		local rts_name = "worker"..i;
		local worker = NPL.CreateRuntimeState(rts_name, 0);
		worker:Start();
	end
    
    LOG.std(nil, "info", "Server", "server is started with %d threads", nServerThreadCount);
end

-- NPL simple client
local function InitClient()
    AddPublicFiles();

    -- since this is a pure client, no need to listen to any port. 
	NPL.StartNetServer("0", "0");
    
	-- add the server address
	NPL.AddNPLRuntimeAddress({host="127.0.0.1", port="60001", nid="simpleserver"})
	
    LOG.std(nil, "info", "Client", "started");
    
	-- activate a remote neuron file on each thread on the server
	for i=1, nServerThreadCount do
		local rts_name = "worker"..i;
		while( NPL.activate(string.format("(%s)simpleserver:script/test/network/SimpleClientServer.lua", rts_name), 
            {TestCase = "TP", data="from client"}) ~=0 ) do
            -- if can not send message, try again.
            echo("failed to send message");
            ParaEngine.Sleep(1);
        end
	end
end

local function activate()
    if(not initialized) then
        initialized = true;
        if(isServerInstance) then
            InitServer();
        else
            InitClient();
        end
	elseif(msg and msg.TestCase) then
    	LOG.std(nil, "info", "test", "%s got a message", isServerInstance and "server" or "client");
		echo(msg);
	end
end
NPL.this(activate)