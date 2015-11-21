

NPL.load("(gl)script/ide/AudioEngine/SoundEmitter.lua");

NPL.load("(gl)script/ide/AudioEngine/AudioEngine.lua");
local AudioEngine = commonlib.gettable("AudioEngine");
AudioEngine.Init()
AudioEngine.SetGarbageCollectThreshold(10)
AudioEngine.LoadSoundWaveBank("script/ide/AudioEngine/SampleSoundBank.xml");


local AriesSoundManager = commonlib.gettable("AduioEngine.AriesSoundManager");
AriesSoundManager.soundManager = nil;
AriesSoundManager.bgEmitter = nil;
AriesSoundManager.ambEmitter = nil;
AriesSoundManager.isInited = false;

function AriesSoundManager.Init()
	if(AriesSoundManager.isInited)then
		return;
	end

	local BackgroundEmitter = commonlib.gettable("AudioEngine.BackgroundEmitter");
	local bgEmitter = BackgroundEmitter:new();
	bgEmitter.name = "bgEmitter";	

	local EnviromentEmitter = commonlib.gettable("AudioEngine.EnviromentEmitter");
	local ambEmitter = EnviromentEmitter:new();
	ambEmitter.name = "envEmitter";

	local FootstepEmitter = commonlib.gettable("AudioEngine.FootstepEmitter");
	local footstepEmitter = FootstepEmitter:new();
	footstepEmitter.name = "fsEmitter";

	local SoundGrid2D = commonlib.gettable("AudioEngine.SoundGrid2D");
	local grid = SoundGrid2D:new();
	grid:Reset(400,400,19188,18655,20700,20700);
	 
	AriesSoundManager.soundManager = commonlib.gettable("AudioEngine.SoundManager");
	local soundManager = AriesSoundManager.soundManager;
	soundManager.Init();
	soundManager.spatialManager = grid;
	soundManager.bgMusicEmitter = bgEmitter;
	soundManager.ambMusicEmitter = ambEmitter;
	--soundManager.AddEmitter(bgEmitter);
	--soundManager.AddEmitter(envEmitter);
	soundManager.AddEmitter(footstepEmitter);
	--soundManager.LoadStaticEmitters("worlds/MyWorlds/61HaqiTown_teen");

	AriesSoundManager.isInited = true;
end

function AriesSoundManager.EnableBgMusic(enable)
	if(AriesSoundManager.bgEmitter ~= nil)then
		AriesSoundManager.bgEmitter.enable = enable;
	end
end

function AriesSoundManager.EnableAmbientMusic(enable)
	if(AriesSoundManager.ambEmitter ~= nil)then
		AriesSoundManager.ambEmitter.enable = enable;
	end
end

function AriesSoundManager.EnableEffectSound(enable)
	soundManager.enableEffectSound = enable;
end

function AriesSoundManager.Active(enable)
	soundManager.active = enable;
end










