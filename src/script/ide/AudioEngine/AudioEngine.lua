--[[
Title: Audio Engine Extension
Author(s): LiXizhi
Date: 2010/6/28
Desc: it wraps the low level Audio Engine API and provide an easy to use Audio architecture and XML based data persistency layer
The audio engine uses a simple garbage collection routine to unload out of range and stopped audio sources. 

---++ Sound Bank File
Sound bank file is an xml file that specify the default play back property of a given sound resource. 
For example, whether the sound is streamed, whether it will remain in memory after stopped, etc.
They also gives shortcut name to sound resources and organize them in categories. 

See SampleSoundBank.xml for example. 

---++ Sound Instance File
We can instantiate a large number of (2d, 3d) sound from a sound instance file. They usually represent all the sounds in the entire(or part of) the game world.
One must call instance:Update() in order to simulate them properly. Inside the update function, 
it will load and unload sound automatically from memory according to the listener position and sounce resource definitions in the sound bank file. 

See SampleSoundInstance.xml for example. 

---++ using low level API
The low level API exposed by ParaAudio table does not automatically stop and unload audio sources for you. 
If you keeps playing many 3d sounds without unloading them, it may consume lots of CPU time.  
For dynamic sound that is generate by game events (such as casting of a magic in 3d, or clicking on a button), it is good to use the sound bank API to play audio files. 
In that case, you can control which audio resource will be unloaded from memory after finished, and which will remain in memory. 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/AudioEngine/AudioEngine.lua");
local AudioEngine = commonlib.gettable("AudioEngine");

-- call this on start
AudioEngine.Init()

-- set max concurrent sounds
AudioEngine.SetGarbageCollectThreshold(5)

-- load wave description resources
AudioEngine.LoadSoundWaveBank("script/ide/AudioEngine/SampleSoundBank.xml");

-- play 2d sound
AudioEngine.CreateGet("bg_theme_alien"):play2d();

-- play 3d sound
local audio_src = AudioEngine.CreateGet("ThrowBall")
audio_src:play3d(x,y,z, true)

-- or programmatically create code driven audio resource
local audio_src = AudioEngine.CreateGet("CodeDriven1")
audio_src.file = "Audio/Example.wav"
audio_src:play(); -- then play with default. 
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/XPath.lua");
NPL.load("(gl)script/ide/AudioEngine/AudioSource.lua");

local AudioEngine = commonlib.gettable("AudioEngine");
local AudioSource = commonlib.gettable("AudioEngine.AudioSource");
local LOG = LOG;
-- true for debug audio engine by writing more logs
local enable_log = true;

------------------------------
-- audio engine
------------------------------

-- mapping from audio source name to audio source. 
local instance_map = {};

-- active 2d or 3d sound sources are in this play list for garbage collection
local active_playlist = {};
-- current number of active audio source
local active_playcount = 0;
-- we will perform garbage collection immediately if there are those many active sounds.
local garbagecollect_threshold = 10;

-- last time that garbage collection is performed. 
AudioEngine.lastGarbageCollectTick = 0;
-- only force garbage collection every 10 seconds
AudioEngine.garbagecollect_interval = 10000;
AudioEngine.framemove_timer_interval = 200;

-- this function should be called when application start. It is OK 
-- internally it will start a timer to garbage collect unused active resources. 
function AudioEngine.Init()
	AudioEngine.gc_timer = AudioEngine.gc_timer or commonlib.Timer:new({callbackFunc = function()
		AudioEngine.GarbageCollect(false);
	end})
	AudioEngine.gc_timer:Change(AudioEngine.garbagecollect_interval, AudioEngine.garbagecollect_interval);
end

-- add to play list, and perform a garbage collection immediately afterwards. 
-- @param source: an AudioSource table object
function AudioEngine.AddToPlayList(source)
	-- first do a auto garbage collect. 
	AudioEngine.GarbageCollect();
	source.last_play_tick = commonlib.TimerManager.GetCurrentTime();

	-- add to list
	if(not active_playlist[source.name]) then
		if(enable_log) then
			LOG.std("", "debug", "audio", "Audio source: %s added to play list", source.name);
		end
		active_playlist[source.name] = source;
		active_playcount = active_playcount + 1;
	end
end

-- remove from play list
-- @param source: an AudioSource table object
function AudioEngine.RemoveFromPlayList(source)
	if(enable_log) then
		LOG.std("", "debug", "audio", "Audio source: %s removed from play list. tick %d", source.name, source.last_play_tick);
	end
	if(active_playlist[source.name]) then
		active_playlist[source.name] = nil;
		active_playcount = active_playcount - 1;
	end
end

-- stop all sounds
function AudioEngine.StopAllSounds()
	if(enable_log) then
		LOG.std("", "debug", "audio", "remove all sounds");
	end
	
	local name, audio_src
	for name, audio_src in pairs(active_playlist) do
		audio_src:stop();
	end
end

-- NOT USED: called at fixed interval such as 1 second. 
function AudioEngine.OnTimer(timer)
	if((timer.lastTick - AudioEngine.lastGarbageCollectTick) > AudioEngine.garbagecollect_interval) then
		AudioEngine.lastGarbageCollectTick = timer.lastTick;
		AudioEngine.GarbageCollect(true);
	end
end

-- when there are those many active sound, we will always performances garbage collection when higher than this. 
-- @param nThreshold: we will force garbage collection when a new music is added. 
function AudioEngine.SetGarbageCollectThreshold(nThreshold)
	garbagecollect_threshold = nThreshold;
end

-- compare age for garbage collection. 
local function AudioSourceAgeCompareFunc(a1, a2)
	return a1.last_play_tick < a2.last_play_tick;
end

-- check if there is any audio resources that should be unloaded from memory. 
-- @param bForceImmediate: if true, it will force get all active resources. Otherwise it will only do it if some threshold value is reached. 
function AudioEngine.GarbageCollect(bForceImmediate)
	if(bForceImmediate or active_playcount>garbagecollect_threshold) then
		local remove_list;
		local name, audio_src
		local nCount = 0;
		local x,y,z = ParaCamera.GetPosition();
		for name, audio_src in pairs(active_playlist) do
			if (not audio_src:IsInRange(x,y,z) or not audio_src:isPlaying()) then
				remove_list = remove_list or {};
				table.insert(remove_list, audio_src)
			end
			nCount = nCount + 1;
		end
		if(remove_list) then
			table.sort(remove_list, AudioSourceAgeCompareFunc);
			for i=1, math.min(#remove_list, active_playcount-garbagecollect_threshold+2) do
				local audio_src = remove_list[i];
				AudioEngine.RemoveFromPlayList(audio_src);
				if(not audio_src.inmemory) then
					if(enable_log) then
						LOG.std("", "debug", "audio", "audio resource: %s is unloaded. tick %d", audio_src.name, audio_src.last_play_tick);
					end
					audio_src:release();
				end
				nCount = nCount - 1;
			end
		end
		-- update active count
		active_playcount = nCount;
	end
end

-- Load a wave bank 
-- @param filename: the xml sound bank file. 
-- @param xpath: the xpath 
-- @return: S_OK if loaded. E_PENDING if we are downloading. E_FAIL if cannot load. 
function AudioEngine.LoadSoundWaveBank(filename)
	local xmlDocIP = ParaXML.LuaXML_ParseFile(filename);
	local xpath = "/pe_mcml/SoundBank"

	local function GetBooleanFromStr_(prop_name, dest, src1, src2, default_value)
		local str = src1[prop_name] or src2[prop_name] or default_value;
		dest[prop_name] = (str == "true");
	end
	local function GetNumberFromStr_(prop_name, dest, src1, src2, default_value)
		dest[prop_name] = tonumber(src1[prop_name]) or tonumber(src2[prop_name]) or default_value;
	end

	if(xmlDocIP) then
		local bankNode;
		for bankNode in commonlib.XPath.eachNode(xmlDocIP, xpath) do
			local bank_attr = bankNode.attr or {};
			local _, audioNode
			for _, audioNode in ipairs(bankNode) do
				if(audioNode.name == "AudioSource") then
					local attr = audioNode.attr or {};
					local audio_src = AudioEngine.CreateGet(attr.name or "");
					audio_src.file = attr.file;
					GetBooleanFromStr_("stream", audio_src, attr, bank_attr);
					GetBooleanFromStr_("loop", audio_src, attr, bank_attr);
					GetBooleanFromStr_("inmemory", audio_src, attr, bank_attr);
					GetBooleanFromStr_("delayload", audio_src, attr, bank_attr);
					GetNumberFromStr_("mindistance", audio_src, attr, bank_attr);
					GetNumberFromStr_("maxdistance", audio_src, attr, bank_attr);
				end
			end
		end
	end
end

-- get the sound source by name. One can inspect its attribute and change its locations, etc. afterwards. 
-- @return NPL AudioSource table. 
function AudioEngine.Get(sound_name)
	return instance_map[sound_name];
end

-- whether we are playing a given sound
function AudioEngine.IsPlaying(sound_name)
	local sound = AudioEngine.Get(sound_name);
	if(sound) then
		return sound:isPlaying();
	end
end

-- stop and release the sound by name
function AudioEngine.Stop(sound_name)
	local sound = AudioEngine.Get(sound_name);
	if(sound) then
		sound:stop();
		sound:release();
		instance_map[sound_name] = nil;
	end
end

-- stop and release the sound by name
function AudioEngine.SetPitch(sound_name, pitch)
	local sound = AudioEngine.Get(sound_name);
	if(sound) then
		sound:SetPitch(pitch);
	end
end

-- stop and release the sound by name
function AudioEngine.SetVolume(sound_name, volume)
	local sound = AudioEngine.Get(sound_name);
	if(sound) then
		sound:SetVolume(volume);
	end
end

-- create one if no audio source with the name exist. 
-- use CreateGet() instead of Get(), so that we can all audio source functions without validations. 
-- such as AudioEngine.CreateGet("bg_theme_alien"):play();
function AudioEngine.CreateGet(sound_name)
	local audio_src = instance_map[sound_name];
	if(not audio_src) then
		audio_src = AudioSource:new({name = sound_name});
		instance_map[sound_name] = audio_src;
	end
	return audio_src;
end

-- play a sound by a given name from loaded wave banks using the default parameter.  
function AudioEngine.PlayUISound(sound_name)
	local audio_src = AudioEngine.Get(sound_name)
	if(audio_src) then
		audio_src:play();
	else
		LOG.warn("audio %s is not found", sound_name);
	end
end
if(ParaAudio) then
	ParaAudio.PlayUISound = AudioEngine.PlayUISound; -- for backward compatible
end

-- play a 3d sound. 
function AudioEngine.Play3DSound(sound_name, x,y,z, bLoop)
	local audio_src = AudioEngine.Get(sound_name)
	if(audio_src) then
		audio_src:play3d(x,y,z, bLoop);
	end
end