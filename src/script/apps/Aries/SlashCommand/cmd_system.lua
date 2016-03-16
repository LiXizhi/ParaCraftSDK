--[[
Title: system's slash commands
Author(s): LiXizhi
Date: 2011/4/7
Desc: these commands can be called by the game user
Usually we can enter in the chat window
---+++ help, man or ?
show help of a given command 
<verbatim>
/help
   * listing all commands and their shortcut
/help [cmd_name]
   * show command maunal of a given command
</verbatim>

---+++ follow
Always move to the last position that the being followed character moved
<verbatim>
/follow
   * follow the selected player
/follow nil
   * cancel following
/follow 1234567
   * follow a player whose nid is 1234567
</verbatim>
---+++ spy
This is similar to spy except that it will hover 30 meters above the target player's head. 
<verbatim>
/spy
   * follow the selected player
</verbatim>
---+++ transform or trans
transform the current player base model to anything or a given gsid. 
Some predefined words: major,whitebear,pangxie,serpant, flower, dog, robot, eagle, panguin, destroyer, shark, wizard, bear, oldman
<verbatim>
/trans bear
   * transform to a predefined bear player
/trans character/v3/Npc/beijixiong/beijixiong.x
/trans 10150
   * transform current player to a given asset path. Arbitrary asset path is only possible with AB_SDK version. 
</verbatim>
---+++ scale
Set scaling to current player
<verbatim>
/scale 1
   * scale the current player
</verbatim>
---+++ bbs
sending a bbs message to all users. 
<verbatim>
/bbs some text here
</verbatim>
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/SlashCommand/cmd_system.lua");
local SystemCmds = commonlib.gettable("MyCompany.Aries.SlashCommand.SystemCmds");
SystemCmds:Register(slash_command)
-------------------------------------------------------
]]
local SlashCommand = commonlib.gettable("MyCompany.Aries.SlashCommand.SlashCommand");
local SystemCmds = commonlib.gettable("MyCompany.Aries.SlashCommand.SystemCmds");

local Player = commonlib.gettable("MyCompany.Aries.Player");

-------------------------------------
-- help command
-------------------------------------
local all_command_text;
-- help cmd handler 
local function cmd_help_handler(cmd_name, cmd_text, cmd_params)
	local self = SlashCommand.GetSingleton();
	if(cmd_text == "") then
		if(not all_command_text) then
			local cmd_table = {};
			local _, cmd;
			for _, cmd in ipairs(self.slash_command_list) do
					
				local cmd_name;
				if(type(cmd.name) == "string") then
					cmd_name = cmd.name;
				elseif(type(cmd.name) == "table") then
					local i, name;
					for i, name in ipairs(cmd.name) do
						if(i == 1) then
							cmd_name = name;
						elseif(i == 2) then
							cmd_name = cmd_name.."("..name
						else
							cmd_name = cmd_name..","..name
						end
					end
					if(#(cmd.name) >= 2) then
						cmd_name = cmd_name..")"
					end
				end
				if(cmd_name) then
					cmd_table[#cmd_table+1] = cmd_name;
				end
			end
			all_command_text = table.concat(cmd_table, ",");
		end
		self:ShowTextDialog(all_command_text);
	else
		local cmd = self:GetSlashCommand(cmd_text);
		if(cmd) then
			self:ShowTextDialog(cmd.quick_ref or cmd.desc);
		else
			self:ShowTextDialog("No such command, type /help to view all commands");
		end
	end
end

------------------------------------
-- the secret command
------------------------------------
local function cmd_secret_handler(cmd_name, cmd_text, cmd_params)
	local facts = {
		["魔法哈奇"] = true,
		["魔法哈奇青年版"] = true,
		["哈奇杯动漫创作大赛"] = true,
		["ParaEngine"] = true,
		["创作大赛"] = true,
		["冬日里的四叶草"] = true,
		["西咪gogogo"] = true,
	}
	if(facts[cmd_text]) then
		return "it is true. "..(cmd_text or "");
	end
	return "GM module not installed";
end

-------------------------------------
-- destroy_item command
-------------------------------------
local cmd_client_destroy_item = {};
function cmd_client_destroy_item.handler(cmd_name, cmd_text, cmd_params)
	if(not cmd_text or not System.options.isAB_SDK)then
		return
	end
	local gsid = tonumber(cmd_text);
	local num;
	if(gsid)then
		num = 1;
	else
		gsid,num = string.match(cmd_text,"(.+) (.+)");
	end
	gsid = tonumber(gsid);
	num = tonumber(num) or 1;
	if(gsid and num)then
		NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
		local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
		local bHas,guid,__,copies = ItemManager.IfOwnGSItem(gsid);
		copies = copies or 0;
		num = math.min(copies,num);
		if(guid)then
			ItemManager.DestroyItem(guid,num, function(msg)
				_guihelper.MessageBox(format("delete gsid %d returns: %s", gsid, tostring(msg.issuccess)));
			end);
		end
	end
end


-------------------------------------
-- destroy_item command on server side
-- e.g. 
--  intranet: /destroy gsid
--  internet: /destroy gsid {password="XXXX"}
--  internet: /destroy gsid {password="XXXX", nid="aaaa"}
-------------------------------------
local cmd_destroy_item = {};
function cmd_destroy_item.handler(cmd_name, cmd_text, cmd_params)
	if(not cmd_text or not System.options.isAB_SDK)then
		return
	end
	local gsid = tonumber(cmd_text);
	local num;
	if(gsid)then
		num = 1;
	else
		gsid,num = string.match(cmd_text,"(.+) (.+)");
	end
	gsid = tonumber(gsid);
	num = tonumber(num) or 1;
	if(gsid and num)then
		NPL.load("(gl)script/kids/3DMapSystemItem/ItemManager.lua");
		local ItemManager = commonlib.gettable("Map3DSystem.Item.ItemManager");
		local bHas,guid,__,copies = ItemManager.IfOwnGSItem(gsid);
		copies = copies or 0;
		num = math.min(copies,num);
		if(guid)then
			NPL.load("(gl)script/apps/Aries/Debug/GMCmd_Client.lua");
			local GMCmd_Client = commonlib.gettable("MyCompany.Aries.GM.GMCmd_Client");
			local gm_client = GMCmd_Client.GetSingleton();
			local password;
			local target_nid;
			if(cmd_params and cmd_params.password) then
				password = cmd_params.password;
			end
			if(cmd_params and cmd_params.nid) then
				target_nid = cmd_params.nid;
			end
			gm_client:Run(format("%sdel %s %d %d", password or "", tostring(target_nid or "self"),guid, num));
		end
	end
end

-------------------------------------
-- hide avatar command on server side
-- e.g. 
--  intranet: /hide 1
--  intranet: /hide 0
-------------------------------------
local cmd_hideavatar = {};
function cmd_hideavatar.handler(cmd_name, cmd_text, cmd_params)
	if(not cmd_text or not System.options.isAB_SDK)then
		return
	end
	local hide_or_show = tonumber(cmd_text);
	if(hide_or_show == 1) then -- show
		Map3DSystem.GSL.HideSelfFromScene(false);
	elseif(hide_or_show == 0) then -- hide
		Map3DSystem.GSL.HideSelfFromScene(true);
	end
end

-------------------------------------
-- speed up command on server side
-- e.g. 
--  intranet: /speedup 4
--  intranet: /speedup 10
-------------------------------------
local cmd_speedup = {};
function cmd_speedup.handler(cmd_name, cmd_text, cmd_params)
	if(not cmd_text or not System.options.isAB_SDK)then
		return
	end
	local speed = tonumber(cmd_text);
	if(speed) then
		ParaScene.GetPlayer():SetField("Speed Scale", speed);
	end
end

-------------------------------------
-- bbs command
-------------------------------------
local cmd_bbs = {};
function cmd_bbs.handler(cmd_name, cmd_text, cmd_params)
	if(not cmd_text or not System.options.isAB_SDK)then
		return
	end
	NPL.load("(gl)script/apps/Aries/BBSChat/ChatSystem/ChatMessage.lua");
	local ChatMessage = commonlib.gettable("MyCompany.Aries.ChatSystem.ChatMessage");

	local msg_str = ChatMessage.CompressMsg({ChannelIndex=10, words=cmd_text})
	local password = "paraengine";
	Map3DSystem.GSL_client:SendChat(msg_str, true, function() end, password);
end

-----------------------------------
-- transform command
-----------------------------------
local known_assets = {
	["major"] = "character/v5/01human/TownChiefRodd/TownChiefRodd.x",
	["whitebear"] = "character/v3/Npc/beijixiong/beijixiong.x",
	["pangxie"] = "character/v3/Npc/dapangxie/dapangxie.x",
	["serpant"] = "character/v3/Npc/hongpidijing/hongpidijing.x",
	["flower"] = "character/v3/Npc/huaxianzi/huaxianzi.x",
	["dog"] = "character/v3/Npc/jingquan/jingquan.x",
	["robot"] = "character/v3/Npc/jiqiren/jiqiren.x",
	["eagle"] = "character/v3/Npc/laoying/laoying.x",
	["panguin"] = "character/v3/Npc/qie/qie.x",
	["destroyer"] = "character/v3/Npc/Robot01/Robot.x",
	["shark"] = "character/v3/Npc/shayu/shayu.x",
	["wizard"] = "character/v3/Npc/xiaonvwu/xiaonvwu.x",
	["bear"] = "character/v3/Npc/xiongguai/xiongguai.x",
	["oldman"] = "character/v5/01human/Ambassador/Ambassador.x",
}
local cmd_trans = {};
function cmd_trans.handler(cmd_name, cmd_text, cmd_params)
	if( not System.options.isAB_SDK) then
		return;
	end
	-- transform the player to a given object
	local asset = cmd_params.value;
	local gsid;
	if(asset) then
		if(asset:match("^%d+$")) then
			gsid = tonumber(asset);
			local gsItem = Map3DSystem.Item.ItemManager.GetGlobalStoreItemInMemory(gsid);
			if(gsItem and gsItem.assetfile and gsItem.assetfile:match("^[cC]haracter")) then
				asset = gsItem.assetfile;
			end
		else
			asset = known_assets[asset];
			if(not asset) then
				asset = cmd_params.value;
			end
		end
	end
	if(asset and asset~="" and asset:match("^[cC]haracter") and ParaIO.DoesAssetFileExist(asset, true)) then
		echo({"/transform to ", gsid, asset})
		Player.asset_gsid = gsid;
		Player.base_model_str = asset;
	else
		Player.asset_gsid = nil;
		Player.base_model_str = nil;
	end

	local CCS = commonlib.gettable("Map3DSystem.UI.CCS");
	local Pet = commonlib.gettable("MyCompany.Aries.Pet");
	local equip_string = CCS.GetCCSInfoString();
	local char_player = Player.GetPlayer();
	if(char_player) then
		CCS.ApplyCCSInfoString(char_player, equip_string);
		Map3DSystem.mcml_controls.GetClassByTagName("pe:slot").RefreshContainingPageCtrls();
	end
end

-------------------------
-- the register function
-------------------------
-- register/create system wide command. install predefined system-wide commands like help, gm, cmd
function SystemCmds:Register(slash_command)
	LOG.std(nil, "system", "SlashCommand", "all system commands registered");
	if(System.options.mc) then
		return;
	end
	-- help command
	slash_command:RegisterSlashCommand({name={"help","man", "?"}, quick_ref="/help your_command_name", desc="display help page of a given command", handler = cmd_help_handler});
	
	-- secret command: just for secret and fun
	slash_command:RegisterSlashCommand({name={"secret", "gm"}, quick_ref="/gm cmd_name cmd_params", desc="game master commands", handler = cmd_secret_handler});

	-- gm command: game master command, only callable with special client build. 
	NPL.load("(gl)script/apps/Aries/Debug/GMCmd_Client.lua");
	local GMCmd_Client = commonlib.gettable("MyCompany.Aries.GM.GMCmd_Client");
	if(GMCmd_Client.GetSingleton) then
		local gm_client = GMCmd_Client.GetSingleton();
		gm_client:Register(slash_command);
	end

	-- cmd command: local commands
	slash_command:RegisterSlashCommand({name="cmd", quick_ref="/cmd cmd_name cmd_params", desc="local commands", handler = function(cmd_name, cmd_text, cmd_params)
		local cmd_name, cmd_text = string.match(cmd_text, "^(%S+)%s*(.*)$");
		if(cmd_name) then
			return slash_command:RunCommand(cmd_name, cmd_text);
		end
	end});

	-- scale the current player
	slash_command:RegisterSlashCommand({name="scale", quick_ref="/scale [number]", desc="scale the current character", handler = function(cmd_name, cmd_text, cmd_params)
		local scaling = tonumber(cmd_params.value);
		if(scaling) then
			ParaScene.GetPlayer():SetScale(scaling)
		end
	end});
	
	-- follow command
	NPL.load("(gl)script/apps/Aries/Scene/AutoFollowAI.lua");
	local AutoFollowAI = commonlib.gettable("MyCompany.Aries.AI.AutoFollowAI");
	AutoFollowAI:Register(slash_command);
	
	-- transform command: local coammands
	slash_command:RegisterSlashCommand({name={"transform", "trans"}, quick_ref="/trans [name|gsid|asset path]", desc="transform the player to something else", handler = cmd_trans.handler});
	
	-- destroy item on server side
	slash_command:RegisterSlashCommand({name="destroy", quick_ref="/destroy gsid num", desc="destroy on server side", handler = cmd_destroy_item.handler});

	-- destroy item on client side
	slash_command:RegisterSlashCommand({name="clientdestroy", quick_ref="/clientdestroy gsid num", desc="destroy on client side", handler = cmd_client_destroy_item.handler});

	-- bbs command
	slash_command:RegisterSlashCommand({name="bbsparaengine", quick_ref="/bbsparaengine textstring", desc="local commands", handler = cmd_bbs.handler});

	-- hide avatar for other player
	slash_command:RegisterSlashCommand({name="hide", quick_ref="/hide 1or0", desc="hide avatar from other players", handler = cmd_hideavatar.handler});
	
	-- speed up
	slash_command:RegisterSlashCommand({name="speedup", quick_ref="/speedup 10", desc="speed up", handler = cmd_speedup.handler});
	
end