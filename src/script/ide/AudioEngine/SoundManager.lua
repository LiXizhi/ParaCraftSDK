
NPL.load("(gl)script/ide/timer.lua");

NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");

-----------------------------------------------
local SoundEmitterType = {};
SoundEmitterType.Global = 0;
SoundEmitterType.Static = 1;
SoundEmitterType.Dynamic = 2;

-------------------------------------------------
local SoundManager = commonlib.gettable("AudioEngine.SoundManager");

SoundManager.globalEmitterCount = 0;
  
SoundManager.globalEmitter = {};
SoundManager.emitters = {};
SoundManager.lowestPriority = 3;
SoundManager.maxEmitterCount = 10;
SoundManager.spatialManager = nil;
SoundManager.playingList = {};
SoundManager.lastWorldName = nil;
SoundManager.stopped = false;
SoundManager.active = true;
SoundManager.enableEffectSound = true;
SoundManager.bgMusicEmitter = nil;
SoundManager.ambMusicEmitter = nil;
SoundManager.updateInterval = 100;

function SoundManager.Init()
	for i=1,SoundManager.lowestPriority do
		SoundManager.playingList[i] = {};
		SoundManager.globalEmitter[i] = {};
	end

	if(not SoundManager.timer)then
		SoundManager.timer = commonlib.Timer:new({callbackFunc = SoundManager.OnTimer});
	end

	SoundManager.timer:Change(0, SoundManager.updateInterval);
end

function SoundManager.AddEmitter(soundEmitter)
	if(soundEmitter == nil)then
		return false;
	end

	local emitterItem =  {}
	emitterItem.emitter = soundEmitter;

	if(soundEmitter.isGlobal)then
		local priority = soundEmitter.priority;
		if(priority < 1)then
			priority = 1;
		elseif(priority > SoundManager.lowestPriority)then
			priority = SoundManager.lowestPriority;
		end
		if(SoundManager.globalEmitter[priority] == nil)then
			SoundManager.globalEmitter[priority] = {};
		end

		SoundManager.globalEmitter[priority][soundEmitter.name] = emitterItem;
		return true;
	elseif(soundEmitter.isStatic)then
		if(SoundManager.emitters[soundEmitter.name] == nil)then
			SoundManager.emitters[soundEmitter.name] = emitterItem;
			if(SoundManager.spatialManager ~= nil)then
				SoundManager.spatialManager:AddEmitter(emitterItem);
			end
			return true;
		end
	else
		commonlib.log("method not imp yet~~~~~~ -.-");
	end

	return false;
end

function SoundManager.RemoveEmitter(emitterName)
	if(emitterName == nil)then
		return;
	end

	local item = SoundManager.findEmitterItem(emitterName);
	if(item == nil)then
		return;
	end

	if(item.emitter.isGlobal)then
		item.emitter:stop();
		local index = item.emitter.priority;
		if(index < 1)then
			index = 1;
		elseif(index > SoundManager.lowestPriority)then
			index = SoundManager.lowestPriority;
		end
		SoundManager.globalEmitter[index][emitterName] = nil;
	else
		if(item.emitter.isStatic)then
			item.emitter:stop();
			SoundManager.emitters[emitterName] = nil;
			if(item.inPlaylist)then
				if(item.previous ~= nil)then
					item.previous.next = item.next;
				end

				if(item.next ~= nil)then
					item.next.previous = item.previous;
				else
					SoundManager.playingList[item.playlistID].tail = item.previous;
				end
			end

			if(SoundManager.spatialManager ~= nil)then
				SoundManager.spatialManager:RemoveEmitter(item);
			end
		end
	end
end

function SoundManager.OnTimer()
	if(SoundManager.active == false)then
		if(SoundManager.stopped == false)then
			SoundManager.stopAll();
		end
		return
	end
	
	
	local location = {};
	location.x,location.y,location.z = ParaScene.GetPlayer():GetPosition();
	location.worldName = WorldManager:GetCurrentWorld().name;
	
	if(SoundManager.lastWorldName ~= location.worldName)then
		for i=1,SoundManager.lowestPriority do
			if(SoundManager.playingList[i])then
				local current = SoundManager.playingList[i].tail;
				while(current)do
					current.emitter:stop();
					current = current.next;
				end
				SoundManager.playingList[i] = {}
			end
		end

		SoundManager.emitters = {};

		--todo:~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		if(SoundManager.spatialManager ~= nil)then
			--SoundManager.spatialManager:reset(50,50,2000,2000,0,0);
		end

		SoundManager.lastWorldName = location.worldName;
	end
	SoundManager.Update(location);
end

function SoundManager.Update(location)
	--mark all active emitter dirty
	for i = 1,SoundManager.lowestPriority do
		if(SoundManager.playingList[i] ~= nil)then
			local item = SoundManager.playingList[i].tail;
			while(item)do
				item.removable = true;
				item = item.previous;
			end
		end
	end
	 
	if(SoundManager.enableEffectSound)then
		local grid = nil;
		if(SoundManager.spatialManager ~= nil)then
			--grid = SoundManager.spatialManager:GetGridByPosition(loc tion.x,location.y,location.z);
		end

		if(grid ~= nil)then
			--build new playlist
			for __,item in pairs(grid)do
				local emitter = item.emitter;
				if(emitter ~= nil)then
					local dx = emitter.position.x - location.x;
					local dz = emitter.position.z - location.z;
					local dist2 = dx*dx + dz * dz;
					local radius2 = emitter.radius * emitter.radius;
					if(dist2 <= radius2)then
						item.removable = false;
						local index = emitter.priority;
						if(index < 1)then
							index = 1;
						elseif(index > SoundManager.lowestPriority)then
							index = SoundManager.lowestPriority;
						end

						if(item.inPlaylist)then
							if(item.playlistID ~= index)then							
								SoundManager.remove(SoundManager.playingList[item.playlistID],item);
								SoundManager.add(SoundManager.playingList[index],item);
							end
						else
							SoundManager.add(SoundManager.playingList[index],item);
							item.removable = false;
							item.inPlaylist = true;
						end
						item.playlistID = index;
					end
				end
			end
		end
	end

	--process playlist
	local emitterCount = 0;
	for i = 1,SoundManager.lowestPriority do
		--porcess global sound
		for __,item in pairs(SoundManager.globalEmitter[i]) do		
			local emitter = item.emitter;
			if(SoundManager.enableEffectSound)then
				if(emitter ~= nil)then
					if(emitter.enable)then
						if(emitter:isActived() == false)then
							if(emitterCount < SoundManager.maxEmitterCount)then
								emitter:play(location);
								emitterCount = emitterCount + 1;
							else
								emitter:bypass();
							end
						else
							emitter:update(location);
							emitterCount = emitterCount + 1;
						end
					else
						emitter:stop();
					end
				end
			end
		end
		
		--non global sound
		if(SoundManager.playingList[i])then
			local item = SoundManager.playingList[i].tail;
			while(item)do
				if(item.removable)then
					item.emitter:stop();
					local temp = item.previous;
					SoundManager.remove(SoundManager.playingList[i],item);
					item.inPlaylist = false;
					item = temp;
				else
					local emitter = item.emitter;
					if(emitter.enable)then
						if(emitter:isActived())then
							emitter:update(location,20);
							emitterCount = emitterCount + 1;
						else
							if(emitterCount < SoundManager.maxEmitterCount)then
								emitter:play(location);
								emitterCount = emitterCount + 1;
							else
								emitter:bypassSound();
							end
						end
					else
						emitter:stop();
					end
					item = item.previous;
				end
			end
		end
	end
end

function SoundManager.findEmitterItem(emitterName)
	if(emitterName == nil)then
		return nil;
	end

	for i = 0, SoundManager.lowestPriority do
		if(SoundManager.globalEmitter[i] ~= nil and SoundManager.globalEmitter[i][emitterName] ~= nil)then
			return SoundManager.globalEmitter[i][emitterName];
		end
	end

	return SoundManager.emitters[emitterName];
end

function SoundManager.stopAll()
	for i = 1,SoundManager.lowestPriority do
		for __,item in pairs(SoundManager.globalEmitter[i]) do		
			item.emitter:stop();
		end

		if(SoundManager.playingList[i] ~= nil)then
			local item = SoundManager.playingList[i].tail;
			while(item)do
				item.emitter:stop();

				local temp = item.previous;
				item.previous = nil;
				item.next = nil;
				item = temp;
			end
			SoundManager.playingList[i].tail = nil;
		end
	end
	SoundManager.stopped = true;
end

function SoundManager.remove(linklist,node)
	local previous = node.previous;
	if(node.previous ~= nil)then
		previous.next = node.next;
	end
	
	local next = node.next;
	if(next ~= nil)then
		next.previous = node.previous
	else
		linklist.tail = node.previous;
	end
	node.next = nil;
	node.previous = nil;
end

function SoundManager.add(linklist,node)
	local tail = linklist.tail;
	if(tail ~= nil)then
		tail.next = node;
	end
	node.previous = tail;
	linklist.tail = node;
end

NPL.load("(gl)script/ide/AudioEngine/SoundEmitter.lua");
local StaticEmitter = commonlib.gettable("AudioEngine.StaticEmitter");
function SoundManager.LoadStaticEmitters(worldPath)
	local file = worldPath.."/soundEmitters.xml";
	local xmlRoot = ParaXML.LuaXML_ParseFile(file);
	if(xmlRoot == nil)then
		return;
	end

	for xmlNode in commonlib.XPath.eachNode(xmlRoot,"//soundEmitters/emitter") do
		if(xmlNode.attr.name~=nil and xmlNode.attr.name ~= "")then
			local emitter = StaticEmitter:new();
			local data = xmlNode.attr;
			emitter.name = data.name;
			--emitter.soundName = data.soundSource;
			if(data.soundSource == "" or data.soundSource == nil)then
				emitter.soundName = "river";
			else
				emitter.soundName = data.soundSource;
			end
			emitter.radius = tonumber(data.radius);
			local x,y,z = string.match(data.position,"(.+),(.+),(.+)");
			emitter.position.x = tonumber(x);
			emitter.position.y = tonumber(y);
			emitter.position.z = tonumber(z);
			emitter.freq = tonumber(data.freq);
			emitter.priority = tonumber(data.priority);
			SoundManager.AddEmitter(emitter);
		end
	end
end
 

---------------------------------------------------------
local SoundGrid2D = commonlib.gettable("AudioEngine.SoundGrid2D");
function SoundGrid2D:new()
	o = o or {};
	setmetatable(o, self);
	self.__index = self;

	o.gridWidth = 1;
	o.gridHeight = 1;
	o.minX = 0;
	o.minY = 0;
	return o;
end

--delete all data in sound grid and build new one
function SoundGrid2D:Reset(gridWidth,gridHeight,minX,minY,maxX,maxY)
	local dx;
	local dy;
	local worldWidth = maxX - minX;
	local worldHeight = maxY - minY;
	if(gridWidth <= 0 or gridHeight <= 0)then
		dx = 1;
		dy = 1;
	else
		dx = math.ceil(worldWidth / gridWidth);
		dy = math.ceil(worldHeight / gridHeight);
	end

	self.gridWidth = gridWidth;
	self.gridHeight = gridHeight;
	self.gridXCount = dx;
	self.gridYCount = dy;
	self.minX = minX;
	self.minY = minY;

	self.grids = {};
	for i=1,dx do
		self.grids[i] = {};
		for j=1,dy do
			self.grids[i][j] = {};
		end
	end
end

local maxGridCount = 10000;
function SoundGrid2D:AddEmitter(emitterItem)
	local emitter = emitterItem.emitter;
	local emitterX = emitter.position.x - emitter.radius;
	local emitterY = emitter.position.z - emitter.radius;
	local emitterWidth = emitter.radius * 2;

	local startGridX = math.ceil((emitterX - self.minX) / self.gridWidth);
	local startGridY = math.ceil((emitterY - self.minY) / self.gridHeight);
	local endGridX = math.ceil((emitterX + emitterWidth - self.minX) / self.gridWidth);
	local endGridY = math.ceil((emitterY + emitterWidth - self.minY) / self.gridHeight);

	for i = startGridX,endGridX do
		for j = startGridY,endGridY do
			if(emitterItem.touchedGrid == nil)then
				emitterItem.touchedGrid = {};
			end
			--assume no more than 10000 element in one dimension
			emitterItem.touchedGrid[i*maxGridCount + j] = true;		
			self.grids[i][j][emitter.name] = emitterItem;
		end
	end
end

function SoundGrid2D:RemoveEmitter(emitterItem)
	if(emitterItem == nil or emitterItem.touchedGrid == nil)then
		return;
	end

	for gridIndex in pairs(emitterItem.touchedGrid)do	
		local gridX = math.floor(gridIndex / maxGridCount);
		local gridY = gridIndex - gridX * maxGridCount;
		if(self.grids ~= nil and self.grids[gridX] ~= nil and self.grids[gridX][gridY] ~= nil)then
			self.grids[gridX][gridY][emitterItem.emitter.name] = nil;
		end
	end
	emitterItem.touchedGrid = nil;
end

function SoundGrid2D:GetGridByPosition(x,y,z)
	y = z;
	local gridX = math.ceil((x - self.minX) / self.gridWidth);
	local gridY = math.ceil((y - self.minY) / self.gridHeight);
	if(gridX < 1 or gridX > self.gridXCount or gridY < 1 or gridY > self.gridYCount)then
		return nil;
	end

	return self.grids[gridX][gridY];
end

---------------------------------------------------------
local AriesSoundEffectConfig = commonlib.gettable("AudioEngine.AriesSoundEffectConfig");
AriesSoundEffectConfig.ID = "sound";
AriesSoundEffectConfig.currentWorld = nil;
AriesSoundEffectConfig.bgSoundMap = nil;
AriesSoundEffectConfig.envSoundMap = nil;
AriesSoundEffectConfig.footstepMap = nil;
AriesSoundEffectConfig.defaultBgMusic = nil;

--@param soundtype:1 background music;2,environment sound;3,footstep sound
--@param location: {worldName,x,y,z},this value can be nil if you want to get the default background music
--@return: soundName or nil. if sountType=2,it may return 2 soundName at most
function AriesSoundEffectConfig.QueryWorldSoundInfo(soundType,location)
	local argb = ParaTerrain.GetRegionValue("sound",location.x,location.z);
	local r,g,b,a = _guihelper.DWORD_TO_RGBA(argb);

	if(soundType == 1)then
		return "bg_theme_alien";
	elseif(soundType == 2)then
		local result1 = "none";
		local result2 = "none";
		if(g > 128)then
			g = g - 128;
		end
		if(g == 1)then
			result1 = "grassland";
		elseif(g == 2)then
			result1 = "forest";
		end
		
		if(b == 1)then
			result2 = "grassland";
		elseif(b == 2)then
			result2 = "forest";
		end
		return result1,result2;
		--return "bg_theme_short";
	elseif(soundType == 3)then
		if(a == 20)then
			return "Grass";
		elseif(a == 60)then
			return "Dirt";
		elseif(a == 40)then
			return "Stone";
		else
			return "Stone";
		end
	else
		return nil;
	end

	  
	--[[
	if(location == nil)then
		if(soundType == 1)then
			return AriesSoundEffectConfig.defaultBgMusic;
		else
			return nil;
		end
	end
		
	if(location.worldName == AriesSoundEffectConfig.currentWorld)then
		local argb = ParaTerrain.GetRegionValue(AriesSoundEffectConfig.ID);
		local r,g,b,a = _guihelper.DWORD_TO_RGBA(argb);
		if(soundType == 1)then
			local soundName = AriesSoundEffectConfig.bgSoundMap[r];
			if(soundName == nil)then
				return AriesSoundEffectConfig.defaultBgMusic;
			else
				return soundName;
			end
		elseif(soundType == 2)then
			local soundName1 = AriesSoundEffectConfig.envSoundMap[g];
			local soundName2 = AriesSoundEffectConfig.envSoundMap[b];
			if(soundName1 == nil)then
				soundName1 = AriesSoundEffectConfig.envSoundMap.defaultSound;
			end
			return soundName1,soundName2;
		elseif(soundType == 3)then
			local soundName = AriesSoundEffectConfig.envSoundMap[a];
			if(soundName == nil)then
				soundName = AriesSoundEffectConfig.footstepMap.defaultSound;
			end
			return soundName;
		end
	end
	--]]
end

--load sound database;
--@param filePath
function AriesSoundEffectConfig.LoadSoundMap(filePath)
	local xmlRoot = ParaXML.LuaXML_ParseFile(filePath);
	if(xmlRoot == nil)then
		return;
	end

	AriesSoundEffectConfig.soundMap = {};
	for soundCategory in commonlib.XPath.eachNode(xmlRoot,"//soundMap/category")do		
		local soundType = -1;
		if(modelName.attr.name == "background")then
			soundType = 1;
		elseif(modelName.attr.name == "ground")then
			soundType = 2;
		elseif(modelName.attr.name == "environment1")then
			soundType = 3;
		end

		if(type ~= -1)then
			AriesSoundEffectConfig.soundMap[type] = {};
			for soundEntry in commonlib.XPath.eachNode(soundCategory,"//soundEntry")do
			
			end
		end
	end
end



 