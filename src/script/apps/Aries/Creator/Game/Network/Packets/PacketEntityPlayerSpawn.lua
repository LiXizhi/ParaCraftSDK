--[[
Title: PacketEntityPlayerSpawn
Author(s): LiXizhi
Date: 2014/6/29
Desc: entity player MP update and spawn. Handle this on client to spawn a client MP.
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Packets/PacketEntityPlayerSpawn.lua");
local Packets = commonlib.gettable("MyCompany.Aries.Game.Network.Packets");
local packet = Packets.PacketEntityPlayerSpawn:new():Init(reason);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Packets/Packet.lua");
local PacketEntityPlayerSpawn = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Network.Packets.Packet"), commonlib.gettable("MyCompany.Aries.Game.Network.Packets.PacketEntityPlayerSpawn"));

function PacketEntityPlayerSpawn:ctor()
end

function PacketEntityPlayerSpawn:Init(entity)
	self.entityId = entity.entityId;
    self.name = entity:GetUserName();
    self.x = math.floor(entity.x * 32);
    self.y = math.floor(entity.y * 32);
    self.z = math.floor(entity.z * 32);
    self.facing = math.floor(entity.facing * 32);
    self.pitch = math.floor(entity.rotationPitch * 32);
    local curItem = entity.inventory:GetCurrentItem();
	if(self.curItem) then
		self.curItem = curItem.id;
	else
		self.curItem = 0;
	end
    self.metadata = entity:GetDataWatcher();
	return self;
end

-- Passes this Packet on to the NetHandler for processing.
function PacketEntityPlayerSpawn:ProcessPacket(net_handler)
	if(net_handler.handleEntityPlayerSpawn) then
		net_handler:handleEntityPlayerSpawn(self);
	end
end


