

NPL.load("(gl)script/ide/AudioEngine/AudioEngine.lua");
local AudioEngine = commonlib.gettable("AudioEngine");

NPL.load("(gl)script/ide/AudioEngine/SoundManager.lua");
local SoundEmitter = commonlib.gettable("AudioEngine.SoundEmitter");
local SoundManager = commonlib.gettable("AudionEngine.SoundManger");

NPL.load("(gl)script/apps/Aries/Scene/AriesSoundEffectConfig.lua");
local AriesSoundEffectConfig = commonlib.gettable("AudioEngine.AriesSoundEffectConfig");


--emitter for background music
local BackgroundEmitter = commonlib.gettable("AudioEngine.BackgroundEmitter");
function BackgroundEmitter:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;

	o.name = "emitter0";
	o.isGlobal = true;
	o.isStatic = true;
	o.radius = 1;
	o.isEnable = true;
	o.loop = true;
	o.priority = 1;
	o.isActive = false;
	return o;
end

function BackgroundEmitter:play(location)
	if(self.isEnable)then
		self.actived = true;
		self:update();
	end
end

function BackgroundEmitter:stop()
	if(self.audioObj ~= nil)then
		self.audioObj:stop();
		self.audioObj = nil;
	end
	self.actived = false;
end

function BackgroundEmitter:update(location)
	if(self.isEnable)then
		local sound = AriesSoundEffectConfig.QueryWorldSoundInfo(1,location);
		if(sound ~= self.soundName)then
			if(self.audioObj ~= nil)then
				self.audioObj:stop();
				self.audioObj = nil;
			end
			self.soundName = sound;
			if(self.soundName ~= nil)then
				self.audioObj = AudioEngine.CreateGet(self.soundName);
				if(self.audioObj ~= nil)then
					self.audioObj.loop = self.loop;
					self.audioObj:play2d();
				end
			else
				self.audioObj = nil;
			end
		end
	end
end

function BackgroundEmitter:isActived()
	return self.actived;
end

function BackgroundEmitter:enable(enable)
	if(self.isEnable == enable)then
		return;
	end

	self.isEnable = enable;
	if(self.isEnable == false)then
		if(self.audioObj ~= nil)then
			self.audioObj:stop();
			self.audioObj = nil;
		end
		self.actived = false;
	end
end

function BackgroundEmitter:bypass()
end


--emitter for background enviroment sound
local EnviromentEmitter = commonlib.gettable("AudioEngine.EnviromentEmitter");

function EnviromentEmitter:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;

	o.name = "emitter0";
	o.isGlobal = true;
	o.isStatic = true;
	o.isEnable = true;
	o.loop = true;
	o.priority = 1;
	o.isActive = false;
	return o;
end

function EnviromentEmitter:play(location)
	if(self.isEnable)then
		self.actived = true;
		self:update();
	end
end

function EnviromentEmitter:stop()
	if(self.audioObj1 ~= nil)then
		self.audioObj1:stop();
		self.audioObj1 = nil;
	end
	if(self.audioObj2 ~= nil)then
		self.audioObj2:stop();
		self.audioObj2 = nil;
	end
	self.actived = false;
end

function EnviromentEmitter:update(location)
	if(self.isEnable==false)then
		return
	end

	local sound1,sound2 = AriesSoundEffectConfig.QueryWorldSoundInfo(2,location);
	if(sound1 ~= self.soundName1)then
		if(self.audioObj1 ~= nil)then
			self.audioObj1:stop();
			self.audioObj1 = nil;
		end
		self.soundName1 = sound1;
		if(self.soundName1 ~= nil)then
			self.audioObj1 = AudioEngine.CreateGet(self.soundName1);
			if(self.audioObj1~=nil)then
				self.audioObj1.loop = self.loop;
				self.audioObj1:play2d();
			end
		end
	end

	if(sound2 ~= self.soundName2)then
		if(self.audioObj2 ~= nil)then
			self.audioObj2:stop();
			self.audioObj2 = nil;
		end
		self.soundName2 = sound2;
		if(self.soundName2 ~= nil)then
			self.audioObj2 = AudioEngine.CreateGet(self.soundName2);
			if(self.audioObj2 ~= nil)then
				self.audioObj2.loop = self.loop;
				self.audioObj2:play2d();
			end
		end
	end
end

function EnviromentEmitter:isActived()
	return self.actived;
end

function EnviromentEmitter:enable(enable)
	if(self.isEnable == enable)then
		return;
	end

	self.isEnable = enable;
	if(self.isEnable == false)then
		if(self.audioObj1 ~= nil)then
			self.audioObj1:stop();
			self.audioObj1 = nil;
		end
		if(self.audioObj2 ~= nil)then
			self.audioObj2:stop();
			self.audioObj2 = nil;
		end
		self.actived = false;
	end
end

function EnviromentEmitter:bypass()
end


--------------------------------------------
local FootstepEmitter = commonlib.gettable("AudioEngine.FootstepEmitter");

function FootstepEmitter:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;

	o.name = "emitter0";
	o.isGlobal = true;
	o.isStatic = true;
	o.isEnable = true;
	o.loop = true;
	o.priority = 1;
	o.isActive = false;

	o.hasFootstepSound = false;
	o.elapsedTime = 0;
	o.isMount = false;
	return o;
end

function FootstepEmitter:play(location)
	if(self.isEnable)then
		self.actived = true;
		self.lastX = location.x;
		self.lastY = location.z;
	end
end

function FootstepEmitter:stop()
	if(self.audioObj ~= nil)then
		self.audioObj:stop();
		self.audioObj = nil;
	end
	self.actived = false;
end

NPL.load("(gl)script/apps/Aries/Player/main.lua");

FootstepEmitter.exceptionList = {};
FootstepEmitter.exceptionList["character/v6/02animals/MagicBesom/MagicBesom.x"] = true;


function FootstepEmitter:checkFootstep(location)
	--not moving

	local Player = MyCompany.Aries.Player;

	if(Player.IsMounted())then
		local mount = ParaScene.GetPlayer():GetPrimaryAsset():GetKeyName();
		if(FootstepEmitter.exceptionList[mount])then
			self.hasFootstepSound = false;
			return;
		end
	end
	  
	if(self.lastX == location.x and self.lastY == location.z)then
		self.hasFootstepSound = false;
	else
		self.lastX = location.x;
		self.lastY = location.z;

		if(Player.IsFlying() or Player.IsInAir()) then
			self.hasFootstepSound = false;
		else
			self.hasFootstepSound = true;		
		end
	end
end

function FootstepEmitter:update(location)
	if(self.isEnable and location)then
		--self.elapsedTime = self.elapsedTime + SoundManager.updateInterval;
		self:checkFootstep(location);

		if(not self.hasFootstepSound)then
			if(self.audioObj ~= nil)then
				self.audioObj:stop();
				self.audioObj = nil;
			end
		else
			local pos = {x = location.x,y = location.z};
			local GroudType = AriesSoundEffectConfig.GetGroundMaterial(pos);

			--local sound = AriesSoundEffectConfig.QueryWorldSoundInfo(3,location);

			local sound = "Dirt";
			if(sound ~= self.soundName)then
				if(self.audioObj ~= nil)then
					self.audioObj:stop();
				end
				self.soundName = sound;
				if(self.soundName ~= nil)then
					self.audioObj = AudioEngine.CreateGet(self.soundName);
					if(self.audioObj ~= nil)then
						self.audioObj.loop = true;
						self.audioObj:play2d();
					end
				end
			else
				self.audioObj = AudioEngine.CreateGet(self.soundName);
				if(not self.audioObj:isPlaying())then
					self.audioObj.loop = true;
					self.audioObj:play2d();
				end
			end
		end
	else
		if(self.audioObj ~= nil)then
			self.audioObj:stop();
			self.audioObj = nil;
		end
	end
end

function FootstepEmitter:enable()
	if(self.isEnable == enable)then
		return;
	end
	self.isEnable = enable;
	if(self.isEnable == false)then
		if(self.audioObj ~= nil)then
			self.audioObj:stop();
			self.audioObj = nil;
		end
		self.actived = false;
	end
end

function FootstepEmitter:bypass()
end

function FootstepEmitter:isActived()
	return self.actived;
end

---------------------------------------------------------
--StaticEmitter never move and sound source never change
--It is useful for static game ojbect enviroment sound
--e.g birds singing,thunder,hammer sound in smithy ,door noise
--emitter.freq usage: <0 sound only play once; =1 loop;>1 played every freq time;
local StaticEmitter = commonlib.gettable("AudioEngine.StaticEmitter");

function StaticEmitter:new(o)
o = o or {};
	setmetatable(o, self);
	self.__index = self;

	o.name = "staticEmitter";
	o.isGlobal = false;
	o.isStatic = true;
	o.isEnable = true;
	o.freq = -1;
	o.radius = 10;
	o.priority = 1;
	o.position = {x=0,y=0,z=0};
	o.isActive = false;
	return o;
end

function StaticEmitter:play(location)
	if(self.isEnable)then
		if(self.soundName ~= nil)then
			self.audioObj = AudioEngine.CreateGet(self.soundName);
			if(self.audioObj ~= nil)then
				local loop = (self.freq == 0); 
				self.audioObj:play3d(location.x,location.y,location.z,loop);
				self.timeElapsed = 0;
			end
		end
		self.actived = true;
	end
end

function StaticEmitter:stop()
	if(self.audioObj ~= nil)then
		self.audioObj:stop();
		self.audioObj = nil;
	end
	self.actived = false;
end

function StaticEmitter:update(location,deltaTime)
	if(self.freq < 0)then
		return;
	elseif(self.freq == 0)then
		if(self.audioObj ~= nil and location ~= nil)then
			self.audioObj:move(location.x,location.y,location.z);
		end
	else
		if(self.audioObj ~= nil and location ~= nil)then
			if(self.audioObj:isPlaying())then
				self.audioObj:move(location.x,location.y,location.z);
				self.timeElapsed = 0;
			else
				local time = deltaTime or 0;
				self.timeElapsed = self.timeElapsed + deltaTime;
				if(self.timeElapsed > self.freq)then
					self.audioObj:play3d(location.x,location.y,location.z,false);
				end
			end
		end
	end
end
  
function StaticEmitter:isActived()
	return self.actived;
end

function StaticEmitter:enable(enable)
	if(self.isEnable == enable)then
		return;
	end

	self.isEnable = enable;
	if(self.isEnable == false)then
		if(self.audioObj ~= nil)then
			self.audioObj:stop();
			self.audioObj = nil;
			self.timeElapsed = 0;
		end
		self.actived = false;
	end
end

function StaticEmitter:bypass()
end



