--[[
Title: ConnectionTCP
Author(s): LiXizhi
Date: 2014/6/25
Desc: TCP connection
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Network/ConnectionTCP.lua");
local ConnectionTCP = commonlib.gettable("MyCompany.Aries.Game.Network.ConnectionTCP");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Network/ConnectionBase.lua");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");

local ConnectionTCP = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Network.ConnectionBase"), commonlib.gettable("MyCompany.Aries.Game.Network.ConnectionTCP"));

function ConnectionTCP:ctor()
end

-- @param thread: NPL state name, default to "gl"
function ConnectionTCP:Init(nid, thread, net_handler)
	self.thread = thread;
	self:SetNid(nid);
	self:SetNetHandler(net_handler);
	return self;
end

-- called when connection is lost
function ConnectionTCP:OnConnectionLost(reason)
	ConnectionTCP._super.OnConnectionLost(self, reason);
end

function ConnectionTCP:AddToSendQueue(msg, neuronfile)
	return self._super.AddToSendQueue(self, msg, neuronfile);
end

function ConnectionTCP:OnNetReceive(msg)
	ConnectionTCP._super.OnNetReceive(self, msg);
end