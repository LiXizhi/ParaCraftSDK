--[[
Title: CommandOpen
Author(s): LiXizhi
Date: 2014/3/18
Desc: open url, folder etc
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CommandOpen.lua");
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


local OpenCommand = {};

Commands["open"] = {
	name="open", 
	quick_ref="/open [-p] url", 
	desc=[[open url in external browser
/open http://www.paraengine.com
/open -p http://www.paraengine.com
/open npl://learn	open NPL code wiki pages
if -p is used, it will ask user for permission. 
]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		local options;
		options, cmd_text = CmdParser.ParseOptions(cmd_text);

		local url = GameLogic.GetFilters():apply_filters("cmd_open_url", cmd_text);
		if(url and url:match("^http:")) then
			if(options.p) then
				_guihelper.MessageBox(L"你确定要打开:"..url, function()
					ParaGlobal.ShellExecute("open", url, "", "", 1);
				end)
			else
				ParaGlobal.ShellExecute("open", url, "", "", 1);
			end
		elseif(url and url~="")then
			_guihelper.MessageBox(L"只能打开http://开头的URL地址");
		end
	end,
};
