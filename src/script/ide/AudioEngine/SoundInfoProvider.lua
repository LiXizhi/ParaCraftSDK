
--[[
Title: 
Author(s): Clayman
Date: 2010/6/29
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/AudioEngine/AudioSource.lua");
-------------------------------------------------------
]]


local SoundInfoProvider = commonlib.gettable("AudioEngine.SoundInfoProvider");

SoundInfoProvider.ID = "sound";
SoundInfoProvider.currentWorld = nil;
SoundInfoProvider.currentPos = {};
SoundInfoProvider.infoValue = 0;
SoundInfoProvider.bgSoundMap = nil;
SoundInfoProvider.envSoundMap = nil;
SoundInfoProvider.footstepMap = nil;
SoundInfoProvider.defaultBgMusic = nil;

--location = {x,y}
function SoundInfoProvider.GetTerrainInfo(location)
	if(location.x ~= SoundInfoProvider.currentPos.x or location.y ~= SoundInfoProvider.currentPos.y)then
		SoundInfoProvider.infoValue = ParaTerrain.GetRegionValue("sound",location.x,location.y);
		SoundInfoProvider.currentPos.x = location.x;
		SoundInfoProvider.currentPos.y = location.y;
	end
end

local GroundType =  commonlib.gettable("AudioEngine.SoundInfoProvider.GroundType");
GroundType.Dirt = 10;
GroundType.Sand = 20;
GroundType.Grass = 30;
GroundType.Rock = 40;
GroundType.Wood = 50;
GroundType.Water= 60;
GroundType.Snow = 70;


--location = {x,y}
function SoundInfoProvider.GetGroundMaterial(location)
	SoundInfoProvider.GetTerrainInfo(location);
	local r,g,b,a = _guihelper.DWORD_TO_RGBA(SoundInfoProvider.infoValue);

	if(r == GroundType.Dirt)then
		return GroundType.Dirt;
	elseif(r == GroundType.Sand)then
		return GroundType.Sand;
	elseif(r == GroundType.Grass)then
		return GroundType.Grass;
	elseif(r == GroundType.Rock)then
		return GroundType.Rock;
	elseif(r == GroundType.Wood)then
		return GroundType.Wood;
	elseif(r == GroundType.Water)then
		return GroundType.Water;
	elseif(r == GroundType.Snow)then
		return GroundType.Snow;
	else
		return GroundType.Dirt;
	end
end