

NPL.load("(gl)script/ide/AudioEngine/SoundEmitter.lua");

NPL.load("(gl)script/ide/AudioEngine/AudioEngine.lua");
local AudioEngine = commonlib.gettable("AudioEngine");
AudioEngine.Init()
AudioEngine.SetGarbageCollectThreshold(10)
AudioEngine.LoadSoundWaveBank("script/ide/AudioEngine/SampleSoundBank.xml");



local SoundManager = commonlib.gettable("AudioEngine.SoundManager");

local BackgroundEmitter = commonlib.gettable("AudioEngine.BackgroundEmitter");
local bgEmitter = BackgroundEmitter:new();
bgEmitter.name = "bgEmitter";

local EnviromentEmitter = commonlib.gettable("AudioEngine.EnviromentEmitter");
local envEmitter = EnviromentEmitter:new();
envEmitter.name = "envEmitter";

local FootstepEmitter = commonlib.gettable("AudioEngine.FootstepEmitter");
local footstepEmitter = FootstepEmitter:new();
footstepEmitter.name = "fsEmitter";

local SoundGrid2D = commonlib.gettable("AudioEngine.SoundGrid2D");
local grid = SoundGrid2D:new();
grid:Reset(400,400,19188,18655,20700,20700);


SoundManager.Init();
SoundManager.spatialManager = grid;
--SoundManager.AddEmitter(bgEmitter);
SoundManager.AddEmitter(envEmitter);
SoundManager.AddEmitter(footstepEmitter);


SoundManager.LoadStaticEmitters("worlds/MyWorlds/61HaqiTown_teen")

