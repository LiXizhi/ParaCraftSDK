--[[
Title: SandBox functions
Author(s): LiXizhi
Date: 2007/8/16
Desc: more information, please see: http://lua-users.org/wiki/SandBoxes
Each 3D world can be told to execute in the given sandbox. 
   * ParaWorld namespace supports a sandbox mode, which can be turned on and off on demand. Once turned on, all scripts from the current game world will be executed in a separate and newly created script runtime environment. 
   * Sandbox mode is an isolated mode that does not have any link with the glia file environment.
   * The world scripts protected by the sandbox runtime environment includes: terrain tile onload script, biped event handler scripts, such as character onload, onclick events. 
   * The sandbox environment includes the following functions that could be used: ParaScene, ParaUI namespace functions. It also explicitly disabled the following functions:
      * Dofile()
      * Io, ParaIO, Exec
      * Require(),NPL.load, NPL.activate, NPL.download: cut off any way to manually load a file. It adds
      * Log
      * Download some file to replace local file.
      * Changing the Enter sand box function or almost any function to some fake function.
   * The following attack methods are prevented by the sandbox environment
      * Execute or load any external application
      * Write to any file, including log file
      * Compromise data or functions in the glia file environment. Such as, changing and hooking the string method
      * Compromise the sandbox itself and then affect in the next sandbox entity.
   * glia file environment does not have a sandbox mode. Because I found that any global sandbox mode implementation has a way to hack in, and I give up any measure of protecting the glia file environment. Sandbox protection for the world file is enough because that is the only source file that may not be provided by ParaEngine. In order to run any other code not provided by the ParaEngine, the user should have been well informed of the danger. But so far, there is no need to have a world that should inform the user. Because most world functions are supported in the world sandbox.

2013/8/20:
	refactored sandbox to use white list instead of black list. 

Use Lib:
-------------------------------------------------------
-- obsoleted usage:
-- NPL.load("(gl)script/ide/sandbox.lua");
-- local sandbox = ParaSandBox:GetSandBox("script/kids/km_sandbox_file.lua");
-- sandbox:Reset();
-- ParaSandBox.ApplyToWorld(sandbox);

-- new usage:
NPL.load("(gl)script/ide/sandbox.lua");
ParaSandBox.Reset();
ParaSandBox.load(filename, reload);
ParaSandBox.DoString(sCode);
-------------------------------------------------------
]]

if(not ParaSandBox) then ParaSandBox={}; end
-- version number
ParaSandBox.ver = 1; 

ParaSandBox.pool = {}

local sandbox;

-- default sandbox environment. 
local env;

-- create get sandbox meta table env
function ParaSandBox.CreateGetSandboxEnv()
	if(not env) then
		env = ParaSandBox.CreateSandboxEnv()
	end
	return env;
end

-- create sandbox meta table env
function ParaSandBox.CreateSandboxEnv()
	local env = {
	  ipairs = ipairs,
	  next = next,
	  pairs = pairs,
	  pcall = pcall,
	  tonumber = tonumber,
	  tostring = tostring,
	  type = type,
	  unpack = unpack,
	  coroutine = { create = coroutine.create, resume = coroutine.resume, 
		  running = coroutine.running, status = coroutine.status, 
		  wrap = coroutine.wrap },
	  string = { byte = string.byte, char = string.char, find = string.find, 
		  format = string.format, gmatch = string.gmatch, gsub = string.gsub, 
		  len = string.len, lower = string.lower, match = string.match, 
		  rep = string.rep, reverse = string.reverse, sub = string.sub, 
		  upper = string.upper },
	  table = { insert = table.insert, maxn = table.maxn, remove = table.remove, 
		  sort = table.sort },
	  math = { abs = math.abs, acos = math.acos, asin = math.asin, 
		  atan = math.atan, atan2 = math.atan2, ceil = math.ceil, cos = math.cos, 
		  cosh = math.cosh, deg = math.deg, exp = math.exp, floor = math.floor, 
		  fmod = math.fmod, frexp = math.frexp, huge = math.huge, 
		  ldexp = math.ldexp, log = math.log, log10 = math.log10, max = math.max, 
		  min = math.min, modf = math.modf, pi = math.pi, pow = math.pow, 
		  rad = math.rad, random = math.random, sin = math.sin, sinh = math.sinh, 
		  sqrt = math.sqrt, tan = math.tan, tanh = math.tanh },
	  os = { clock = os.clock, difftime = os.difftime, time = os.time },
	  ParaScene = ParaScene,
	  ParaAsset = ParaAsset,
	  ParaUI = ParaUI,
	  ParaCamera = ParaCamera,
	};

	local meta = getmetatable (env)
	if not meta then
		meta = {}
		setmetatable (env, meta)
	end
	-- Note: do not expose the _G
	-- SECURITY NOTE: 
	-- expose global environment to the inline script via meta table
	-- meta.__index = _G;

	--------------------------------
	-- common functions
	--------------------------------
	--env.echo = echo;
	env.log = log;
	env.__index = env;
	return env;
end


-- load a file in the sandbox. Similar to NPL.load(). 
function ParaSandBox.load(filename, reload)
	sandbox.scripts = sandbox.scripts or {};

	if(not sandbox.scripts[filename] or reload) then
		sandbox.scripts[filename] = true;

		local file = ParaIO.open(filename, "r");
		if(file:IsValid()) then
			local text = file:GetText();
			if(text and text~="") then
				local code_func, errormsg = loadstring(text);
				if(not code_func) then
					if(LOG and LOG.std) then
						LOG.std(nil, "error", "ParaSandBox.load", "<Runtime error> syntax error while loading code in file:%s\n%s", filename, tostring(errormsg));
					end
				else
					-- LOG.std(nil, "debug", "ParaSandBox.load", "%s", filename);
					setfenv(code_func, ParaSandBox.GetCurSandbox());
					code_func();
				end
			end
			file:close();
		end	
	end
end

-- Do a string in the sandbox. Similar to NPL.DoString().
function ParaSandBox.DoString(sCode)
	local code_func, errormsg = loadstring(sCode);
	if(not code_func) then
		if(LOG and LOG.std) then
			LOG.std(nil, "error", "ParaSandBox.load", "<Runtime error> syntax error while loading code:%s\n%s", sCode, tostring(errormsg));
		end
	else
		setfenv(code_func, ParaSandBox.GetCurSandbox());
		code_func();
	end
end

function ParaSandBox.GetCurSandbox()
	if(not sandbox) then
		ParaSandBox.Reset()
	end
	return sandbox;
end

-- reset (create) sandbox
function ParaSandBox.Reset()
	sandbox = {};
	setmetatable (sandbox, ParaSandBox.CreateGetSandboxEnv())
	if(LOG and LOG.std) then
		LOG.std(nil, "info", "ParaSandBox.reset", "new sandbox created.");
	end
	return sandbox;
end

function ParaSandBox.SandboxFunction()
	log("warning: the function you are calling is not in the sandbox.\n");
end


---------------------------------
-- Obsoleted functions
---------------------------------

-- Obsoleted: create or get a sand box of the given name.
-- @param filename: in most cases it is a neuron file. or it can be an non existing file.
-- @param protectionLevel: what kind of protection level does the sandbox have. it can be nil. which is the default setting.
function ParaSandBox:GetSandBox(filename, protectionLevel)
	local o = ParaSandBox.pool[filename];
	if(not o) then
		-- create object if it does not exist
		o = {name = filename, level = protectionLevel}
		setmetatable(o, self)
		self.__index = self
		-- add to pool
		ParaSandBox.pool[filename] = o;
	end
	return o;
end

-- Obsoleted: 
-- apply the sandbox to current world
-- @param sandbox: if nil, no sandbox will be used. 
function ParaSandBox.ApplyToWorld(sandbox)
	if(not sandbox) then
		ParaWorld.SetScriptSandBox(nil);
	else
		ParaWorld.SetScriptSandBox(sandbox.name);
	end
end

-- Obsoleted: 
-- destory a given sandbox
function ParaSandBox:DestorySandBox()
	NPL.DeleteNeuronFile(self.name);
	ParaSandBox.pool[self.name] = nil;
end