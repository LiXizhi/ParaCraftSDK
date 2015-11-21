--[[
Title: 
Author(s): Leio
Date: 2009/11/12
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/SceneNodeHeadonSpeech.lua");
function speakOver(speechNode)
	commonlib.echo(speechNode.uid..":over");
end
local x,y,z = 250,-2,250
local str_MCML = string.format("<img style=\"margin-left:6px;width:256px;height:256px;\" src=%q />", "Texture/Aries/Homeland/anims/water/v1/water_32bits_fps30_a003.png");
--local str_MCML = string.format("<img style=\"margin-left:6px;width:256px;height:256px;\" src=%q />", "Texture/Aries/Homeland/anims/debug/v1/debug_32bits_fps24_a004.png");
--local str_MCML = string.format("<img style=\"margin-left:6px;width:256px;height:256px;\" src=%q />", "Texture/Aries/Homeland/anims/delete/v1/delete_32bits_fps24_a008.png");
--local str_MCML = string.format("<img style=\"margin-left:6px;width:256px;height:256px;\" src=%q />", "Texture/Aries/Homeland/anims/hand/v1/hand_32bits_fps30_a010.png");
local speechNode = CommonCtrl.Display3D.SceneNodeHeadonSpeech:new{
	x = x,
	y = y,
	z = z,
	text = str_MCML,
	nLifeTime = 20, 
	bAbove3D = true,
	speakOverFunc = speakOver,
}
speechNode:Speak();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
NPL.load("(gl)script/ide/headon_speech.lua");
local SceneNodeHeadonSpeech = {
	x = 0,
	y = 0,
	z = 0,
	text = "",
	nLifeTime = 2, 
	bAbove3D = true,
	isSpeaking = false,--是否正在说话
	node = nil,--说话的模型
	rootNode = nil,--说话的模型的父容器
	assetFile = "character/v5/01human/InvisibleMan/InvisibleMan.x",
	speakTimer = nil,
	--event
	speakOverFunc = nil,--说完话的事件
}
commonlib.setfield("CommonCtrl.Display3D.SceneNodeHeadonSpeech",SceneNodeHeadonSpeech);
function SceneNodeHeadonSpeech:new (o)
	o = o or {}   -- create object if user does not provide one
	o.Nodes = {};
	setmetatable(o, self)
	self.__index = self
	o:Init();
	return o
end
function SceneNodeHeadonSpeech:Init()
	local uid = ParaGlobal.GenerateUniqueID();
	self.uid = uid;
	
	self.speakTimer = commonlib.Timer:new{
		callbackFunc = SceneNodeHeadonSpeech.TimerUpdate,
	}
	self.speakTimer.holder = self;
	

	local scene = CommonCtrl.Display3D.SceneManager:new{
	};
	local rootNode = CommonCtrl.Display3D.SceneNode:new{
		root_scene = scene,
	}
	
	self.rootNode = rootNode;
end
function SceneNodeHeadonSpeech:RemoveNode()
	if(self.node)then
		self.node:Detach();
	end
end
function SceneNodeHeadonSpeech:BuildNode(x,y,z)
	self:RemoveNode();
	local node = CommonCtrl.Display3D.SceneNode:new{
		x = x,
		y = y,
		z = z,
		assetfile = self.assetFile,
		ischaracter = true,
	};
	self.rootNode:AddChild(node);
	return node;
end
function SceneNodeHeadonSpeech:Speak(args)
	if(self.isSpeaking)then return end
	self.isSpeaking = true;
	local x = self.x;
	local y = self.y;
	local z = self.z;
	local text = self.text;
	local nLifeTime = self.nLifeTime;
	local bAbove3D = self.bAbove3D;
	if(args)then
		x = args.x or x;
		y = args.y or y;
		z = args.z or z;
		text = args.text or text;
		nLifeTime = args.nLifeTime or nLifeTime;
		if(not args.bAbove3D)then
			bAbove3D = nil;
		else
			bAbove3D = true;
		end
		self.speakOverFunc = args.speakOverFunc;
	end
	self.node = self:BuildNode(x,y,z);
	if(self.node)then
		local duration = nLifeTime * 1000;
		self.speakTimer:Change();
		self.speakTimer:Change(duration,nil);
		local entity = self.node:GetEntity();
		if(entity)then
			local charName = entity.name;
			headon_speech.Speek(charName, text, nLifeTime, true,true)
		end
	end
end

function SceneNodeHeadonSpeech.TimerUpdate(timer)
	if(timer and timer.holder)then
		local self = timer.holder;
		if(self.speakOverFunc and type(self.speakOverFunc) == "function")then
			--speak over
			self.isSpeaking = false;
			self:RemoveNode();
			self.speakOverFunc(self);
		end
	end
end