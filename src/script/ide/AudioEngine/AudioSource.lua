--[[
Title: Audio Source
Author(s): LiXizhi
Date: 2010/6/29
Desc: It represents an instance of an audio source, either 2d or 3d. 
Please note that it is only an logical instance, it does not mean that the low level audio engine has such an instance. 
The audio source is automatically loaded and unloaded when in or out of range according to the attribute set in the wave bank. 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/AudioEngine/AudioSource.lua");
-------------------------------------------------------
]]
------------------------------
-- audio source with default parameters
------------------------------
local AudioSource = commonlib.inherit(nil, commonlib.gettable("AudioEngine.AudioSource"));
local AudioEngine = commonlib.gettable("AudioEngine");
local math_abs = math.abs
-- last time the audio source is added to play list. 
AudioSource.last_play_tick= 0;

function AudioSource:ctor()
	self.stream = false;
	self.loop = false;
	self.file = "";
	--[[ supported properties:
	{
		stream = false, 
		loop = false, 
		inmemory = false,
		delayload = true, 
		mindistance = number,
		maxdistance = number,
		strength = number, 
	}
	]]
end

-- get the low level API audio source object. It will try to create one if not before. 
function AudioSource:GetSource()
	if(self.file ~= "" and (not self.source or not self.source:IsValid())) then
		local source = ParaAudio.CreateGet(self.name, self.file, self.stream);
		self.source = source;
		if(self.mindistance) then
			source.MinDistance = self.mindistance;
		end
		if(self.maxdistance) then
			source.MaxDistance = self.maxdistance;
		end
	end
	return self.source;
end

-- play 2d sound with default parameter
function AudioSource:play2d(volume, pitch)
	local source = self:GetSource()
	if(source) then
		self.is3D = false;
		if(volume) then
			source.Volume = volume;
		end
		if(pitch) then
			source.Pitch = pitch;
		end
		source:play2d(self.loop);
		AudioEngine.AddToPlayList(self);
	end
end

function AudioSource:SetPitch(pitch)
	local source = self:GetSource()
	if(source and pitch) then
		source.Pitch = pitch;
	end
end

function AudioSource:SetVolume(volume)
	local source = self:GetSource()
	if(source and volume) then
		source.Volume = volume;
	end
end

-- play sound at a static global 3d location. It will perform 3d range check
-- if sound source is out of range, this function takes no effect but moves the sound source to a given location. 
-- @param loop: true to loop. nil to use default setting
-- @param strength: sound strength, nil to use default settings(usually 1)
-- @param pitch
function AudioSource:play3d(x,y,z, loop, strength, pitch)
	local source = self:GetSource()
	if(source) then
		if(loop ~= nil) then
			self.loop = loop;
		end
		self.x = x or self.x;
		self.y = y or self.y;
		self.z = z or self.z;
		self.is3D = true;
		self.strength = strength or self.strength or 1;

		if(volume) then
			source.Volume = volume;
		end

		if(pitch) then
			source.Pitch = pitch;
		end

		--  check if in range. 
		if(self:IsInRange()) then

			self:play(source);
		end
	end
end

-- whether the sound source is within range of the given point.
-- 2d sound is always in range. 
-- @param listener_x, listener_y, listener_z: world location of the listener. if nil, they will be the current camera's eye position. 
function AudioSource:IsInRange(listener_x, listener_y, listener_z)
	if(not self.is3D) then
		return true;
	elseif(self.x) then
		if(not listener_x) then
			listener_x, listener_y, listener_z = ParaCamera.GetPosition();
		end

		local dist = self.maxdistance or 50;
		return  (math_abs(self.x-listener_x) < dist) and 
				(math_abs(self.y-listener_y) < dist) and 
				(math_abs(self.z-listener_z) < dist);
	end
end

-- play 2d or 3d using default parameter without range check
-- @param source: if nil, it will be the local source. If you already know the low level audio source, just provide it to increase speed. 
function AudioSource:play(source)
	source = source or self:GetSource()
	if(source) then
		if(self.is3D) then
			source:play3d(self.x, self.y, self.z, self.strength or 1, self.loop);
		else
			source:play2d(self.loop);
		end
		AudioEngine.AddToPlayList(self);
	end
end

-- move the sound source to a new location in 3D. 
function AudioSource:move(x,y,z)
	self.x = x or self.x;
	self.y = y or self.y;
	self.z = z or self.z;
	local source = self:GetSource()
	if(source) then
		-- TODO: automatically start playing if close enough to eye. 
		source:move(self.x, self.y, self.z);
	end
end

-- stop playing
function AudioSource:stop()
	if(self.source) then
		self.source:stop();
	end
end

-- pause playing
function AudioSource:pause()
	if(self.source) then
		self.source:pause();
	end
end

--[[
Seeks through the audio stream to a specific spot.
Note: May not be supported by all codecs.
@param seconds: Number of seconds to seek.
@param relative: Whether to seek from the current position or the start of the stream.
@return True on success, False if the codec does not support seeking.
]]
function AudioSource:seek(seconds, relative)
	local source = self:GetSource()
	if(source) then
		source:seek(seconds, relative == true);
	end
end

-- whether it is still playing. 
function AudioSource:isPlaying()
	if(self.source) then
		return self.source:isPlaying();
	end
end

-- change the inner filename, by releasing the old source object.  
function AudioSource:SetFileName(filename)
	if(self.file ~= filename) then
		if(self.source) then
			self:release();
		end
		self.file = filename;
	end
end

-- stop and unload this audio from memory. 
function AudioSource:release()
	if(self.source) then
		self.source:release();
		self.source = nil;
	end
end
