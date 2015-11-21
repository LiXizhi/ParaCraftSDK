--[[
Title: CommandSay
Author(s): LiXizhi
Date: 2015/7/22
Desc: entity walk action
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandSay.lua");
-------------------------------------------------------
]]
local SlashCommand = commonlib.gettable("MyCompany.Aries.SlashCommand.SlashCommand");
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");	
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local block = commonlib.gettable("MyCompany.Aries.Game.block")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");


Commands["say"] = {
	name="say", 
	quick_ref="/say [@entityname] [-duration 10] [any text here]", 
	desc=[[let the given entity say something on top of its head. 
@param entityname: name of the entity, if nil, it means the calling entity, such as inside the entity's inventory.  
@param duration: how many seconds the head dialog last.
e.g.
/say hello there! 
/say -duration 10 hello
]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		local playerEntity;
		playerEntity, cmd_text = CmdParser.ParsePlayer(cmd_text);
		playerEntity = playerEntity or fromEntity;

		local duration;
		local option = "";
		while (option) do
			option, cmd_text = CmdParser.ParseOption(cmd_text);
			if(option == "duration") then
				duration, cmd_text = CmdParser.ParseNumber(cmd_text);
			end
		end
		if(cmd_text and cmd_text~="") then
			local bSucceed;
			if(playerEntity and playerEntity.Say) then
				-- show head on display
				bSucceed = playerEntity:Say(cmd_text, duration);
			end
			if(not bSucceed) then
				-- report error to chat
				GameLogic.AppendChat(cmd_text);
			end
		end
	end,
};
