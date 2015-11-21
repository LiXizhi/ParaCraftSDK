--[[
Title: MotionFactory
Author(s): Leio
Date: 2010/06/12
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionFactory.lua");
local MotionFactory = commonlib.gettable("MotionEx.MotionFactory");
local filepath = "script/ide/MotionEx/Motion.xml";
MotionFactory.PlayMotionFile("test_player",filepath,true)

NPL.load("(gl)script/ide/MotionEx/MotionRender.lua");
local MotionRender = commonlib.gettable("MotionEx.MotionRender");
NPL.load("(gl)script/ide/MotionEx/MotionFactory.lua");
local MotionFactory = commonlib.gettable("MotionEx.MotionFactory");
local name = "test_player_name"
local motionPlayer = MotionFactory.GetPlayer(name);
motionPlayer.esc_key = true;
local player = ParaScene.GetPlayer();
motionPlayer:AddEventListener("stop",function()
	commonlib.echo("stop");
	player:ToCharacter():SetFocus();
	MotionRender.ForceEnd();
end,{});
motionPlayer:AddEventListener("end",function()
	commonlib.echo("end");
	player:ToCharacter():SetFocus();
	MotionRender.ForceEnd();
end,{});
MotionFactory.PlayMotionFile(name,"config/Aries/Cameras/SceneLoading2.xml",bReload);
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionLine.lua");
NPL.load("(gl)script/ide/MotionEx/MotionPlayer.lua");
local MotionLine = commonlib.gettable("MotionEx.MotionLine");
local MotionPlayer = commonlib.gettable("MotionEx.MotionPlayer");

local MotionFactory = commonlib.gettable("MotionEx.MotionFactory");
MotionFactory.players ={

}
MotionFactory.files ={

}
function MotionFactory.ParseFile(filepath)
	local xmlDocRoot = ParaXML.LuaXML_ParseFile(filepath);
	local lines = {};
	local line_node;
	for line_node in commonlib.XPath.eachNode(xmlDocRoot, "/Motion/MotionLine") do
		local motionLine = MotionLine.CreateByXmlNode(line_node);
		if(motionLine)then
			table.insert(lines,motionLine);
		end
	end
	return lines;
end
--把xml转变成MotionLine list
function MotionFactory.LoadMotionFile(filepath,bReload)
	local self = MotionFactory;
	if(not filepath)then return end
	if(not bReload)then
		local lines = self.files[filepath];
		if(lines)then
			return lines;
		else
			self.files[filepath] = self.ParseFile(filepath);
		end
	else
		self.files[filepath] = self.ParseFile(filepath);
	end
	return self.files[filepath];
end
--获取/创建一个播放器 name 唯一
function MotionFactory.GetPlayer(name)
	local self = MotionFactory;
	if(not name)then return end
	if(not self.players[name])then
		self.players[name] = MotionPlayer:new();
	end
	return self.players[name];
end
function MotionFactory.PlayMotionFile(player_name,filepath,bReload)
	local self = MotionFactory;
	local player = self.GetPlayer(player_name);
	local lines = self.LoadMotionFile(filepath,bReload);
	if(player and lines)then
		player:Clear();
		player:AddMotionLines(lines);
		player:Play();
	end
end
--
function MotionFactory.CreateCameraMotionFromFile(player_name,filepath,origin,bAutoPlay,bReload)
	local self = MotionFactory;
	local player = self.GetPlayer(player_name);
	local lines = self.LoadMotionFile(filepath,bReload);
	if(player and lines)then
		local line = lines[1];
		if(line)then
			line:SetOrigin(origin);
		end

		player:Clear();
		player:AddMotionLines(lines);
		if(bAutoPlay)then
			player:Play();
		end
		return player;
	end
end