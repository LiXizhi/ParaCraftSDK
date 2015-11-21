--[[
Title: AI funcions
Author(s): LiXizhi
Date: 2006/9/5
Desc: global AI related functions.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/AI.lua");
-------------------------------------------------------
]]

if(not _AI) then _AI={}; end
if(not gamestate) then gamestate={}; end

-- a table holding temporary memory of NPC characters. e.g. _AI.temp_memory["PlayeName"] = {sequence_number = 1,Task1 = "Done"};
_AI.temp_memory = {}; 

-- get temperary memory of a given character. By its name.
function _AI.GetMemory(name)
	local mem = _AI.temp_memory[name];
	if(mem==nil) then
		mem = {};
		_AI.temp_memory[name] = mem;
	end
	return mem;
end

-- clear all memory.
function _AI.ClearAll()
	_AI.temp_memory = {}; 
end	