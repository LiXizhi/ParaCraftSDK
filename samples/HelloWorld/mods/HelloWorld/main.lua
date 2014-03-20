--[[
Title: Main loop
Author(s): LiXizhi
Company: ParaEnging Co.
Date: 2014/3/21
Desc: Entry point and game loop
use the lib:
------------------------------------------------------------
NPL.activate("mods/HelloWorld/main.lua");
Or run application with command line: bootstrapper="mods/HelloWorld/main.lua"
------------------------------------------------------------
]]
-- ParaWorld platform includes
NPL.load("(gl)script/kids/ParaWorldCore.lua"); 

local function activate()
	echo("hello world\n")
end

NPL.this(activate);