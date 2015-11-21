--[[
Title: PacketEntityMobSpawn
Author(s): LiXizhi
Date: 2014/6/29
Desc: mob spawn and update
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Packets/PacketEntityMobSpawn.lua");
local Packets = commonlib.gettable("MyCompany.Aries.Game.Network.Packets");
local packet = Packets.PacketEntityMobSpawn:new():Init(reason);
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Network/Packets/Packet.lua");
local PacketEntityMobSpawn = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Network.Packets.Packet"), commonlib.gettable("MyCompany.Aries.Game.Network.Packets.PacketEntityMobSpawn"));

function PacketEntityMobSpawn:ctor()
end

function PacketEntityMobSpawn:Init(entity, entity_type)
	self.entityId = entity.entityId;
	self.x = math.floor(entity.x * 32);
    self.y = math.floor(entity.y * 32);
    self.z = math.floor(entity.z * 32);
	self.pitch = math.floor((entity.rotationPitch or 0)* 256.0 / 360.0);
	self.yaw = math.floor((entity.rotationYaw or 0)* 256.0 / 360.0);
	self.type = entity_type;

	return self;
end

-- Passes this Packet on to the NetHandler for processing.
function PacketEntityMobSpawn:ProcessPacket(net_handler)
	if(net_handler.handleMobSpawn) then
		net_handler:handleMobSpawn(self);
	end
end


