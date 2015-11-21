--[[
Title: mini scene graph manager.which allows a miniscenegraph to load an onload script the same way as the main scene
Author(s): LiXizhi
Date: 2007/10/7
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/MinisceneManager.lua");
CommonCtrl.MinisceneManager.LoadFromOnLoadScript(scene, "worlds/login_world/script/login_world_0_0.onload.lua", 255, 0, 255)
CommonCtrl.MinisceneManager.LoadFromOnNPCdb(scene, "worlds/login_world/login_world.NPC.db", 255, 0, 255)
local worldinfo = CommonCtrl.MinisceneManager.GetWorldAttribute("worlds/login_world/login_world.attribute.db");
CommonCtrl.MinisceneManager.LoadWorldAttribute(scene, worldInfo, worldinfo.PlayerX,worldinfo.PlayerY, worldinfo.PlayerZ)
-------------------------------------------------------
]]
-- common library
NPL.load("(gl)script/ide/common_control.lua");

local MinisceneManager = commonlib.gettable("CommonCtrl.MinisceneManager");
local LOG = LOG;

-- get all mini scenegraphs child count in the world
-- @return a table containing name, value pairs. 
function CommonCtrl.MinisceneManager.GetStats()
	local names = ParaScene.GetAttributeObject():GetField("AllMiniSceneGraphNames", "");
	local name;
	local stats = {};
	for name in string.gmatch(names, "[^,]+") do
		local scene = ParaScene.GetMiniSceneGraph(name);
		local nCount = scene:GetAttributeObject():GetField("ChildCount", 0)
		stats[name] = nCount;
	end
	return stats;
end

local stat_timer;
local bLastShowStatsOnUI;
-- show miniscene graph counts on UI for debugging purposes only 
-- @param bEnabled: enable or disable it. 
-- @param nRefreshRate: if nil it will be default 3000 milliseconds
function CommonCtrl.MinisceneManager.ShowStatsOnUI(bEnabled, nRefreshRate)
	if(bEnabled == nil) then
		bLastShowStatsOnUI = not bLastShowStatsOnUI;
		bEnabled = bLastShowStatsOnUI;
	end
	if(bEnabled) then
		NPL.load("(gl)script/ide/timer.lua");
		stat_timer = stat_timer or commonlib.Timer:new({callbackFunc = function(timer)
			local stats = MinisceneManager.GetStats()
			local name, count;
			for name, count in pairs(stats) do
				LOG.show(name, count);
			end
		end})
		
		stat_timer:Change(0, nRefreshRate or 3000);
	else
		if(stat_timer) then
			stat_timer:Change();
		end
	end
end



--[[ Load a miniscene graph with all mesh objects contained in on load script. 
@param scene: the miniscenegraph object. 
@param filename: An on load script is usually save at worlds/[name]/script/[name]_0_0.onload.lua during scene saving
@param originX, originY, originZ: we can use a new scene origin when loading the scene. if nil, 0 is used
]]
function CommonCtrl.MinisceneManager.LoadFromOnLoadScript(scene, filename, originX, originY, originZ)
	local line
	local file = ParaIO.OpenAssetFile(filename);
	if(file:IsValid()) then
		originX = originX or 0
		originY = originY or 0
		originZ = originZ or 0
		
		line=file:readline();
		while line~=nil do 
			CommonCtrl.MinisceneManager.scene = scene;

			if(string.find(line, "ParaAsset.LoadStaticMesh")~=nil) then
			elseif(string.find(line, "ParaScene.CreateMeshPhysicsObject")~=nil) then
			elseif(string.find(line, "player:SetPosition")~=nil) then
				line = string.gsub(line, "player:SetPosition%(([%.%d%s]+),([%.%d%s]+),([%.%d%s]+)%);", 
					"player:SetPosition(%1-"..originX..",%2-"..originY..",%3-"..originZ..");");
				line = string.gsub(line, "(sceneLoader:AddChild)", "CommonCtrl.MinisceneManager.scene:AddChild");
			else
				line = nil;	
			end

			if(line~=nil) then
				--log(line.."\n")
				NPL.DoString(line);
			end

			line=file:readline();
		end
		file:close();
	end	
end

--[[ load character from NPL database 
@param scene: the miniscenegraph object. 
@param filename: NPC database file which is usually save at worlds/[name]/[name].NPC.db during scene saving
@param originX, originY, originZ: we can use a new scene origin when loading the scene. if nil, 0 is used
]]
function CommonCtrl.MinisceneManager.LoadFromOnNPCdb(scene, filename, originX, originY, originZ)
	originX = originX or 0
	originY = originY or 0
	originZ = originZ or 0
	
	NPL.load("(gl)script/sqlite/sqlite3.lua");
	
	if(ParaIO.DoesAssetFileExist(filename, true)) then
		local db = sqlite3.open(filename);
		local obj,player, asset;
		local row;
		for row in db:rows("SELECT Name, AssetName, Radius, Facing, Scaling,posX,posY,posZ,CharacterType FROM NPC") do
			asset = ParaAsset.LoadParaX("",row.AssetName);
			obj = ParaScene.CreateCharacter(row.Name, asset, "", true, row.Radius, 0, 1);
			obj:SetPosition(row.posX-originX, row.posY-originY, row.posZ-originZ);
			obj:SetFacing(row.Facing);
			obj:SetScale(row.Scaling);
			scene:AddChild(obj);
		end
		db:close();
	else
		commonlib.applog("warning: file not found %s", filename)
	end	
end

--[[ world attribute is returned via a table.
@param filename: world attribute database file is usually at worlds/[name]/[name].attribute.db during scene saving
]]
function CommonCtrl.MinisceneManager.GetWorldAttribute(filename)
	NPL.load("(gl)script/sqlite/sqlite3.lua");
	local worldinfo = {};
	if(ParaIO.DoesAssetFileExist(filename, true)) then
		local db = sqlite3.open(filename);
		local row;
		for row in db:rows("SELECT Name, Value FROM WorldInfo") do
			worldinfo[row.Name] = row.Value;
		end
		db:close();
	else
		commonlib.applog("warning: file not found %s", filename)
	end	
	return worldinfo;
end

--[[ load world info, such as sky box, fog, main player. Currently it only loads main player
@param scene: the miniscenegraph object. 
@param worldinfo: this is what is returned by CommonCtrl.MinisceneManager.GetWorldAttribute()
]]
function CommonCtrl.MinisceneManager.LoadWorldAttribute(scene, worldinfo, originX, originY, originZ)
	originX = originX or 0
	originY = originY or 0
	originZ = originZ or 0
	
	local obj,player, asset;
	if(worldinfo.PlayerAsset~=nil) then
		asset = ParaAsset.LoadParaX("player",worldinfo.PlayerAsset);
		obj = ParaScene.CreateCharacter("player", asset, "", true, 0.35, 0.5, 1);
		obj:SetPosition(worldinfo.PlayerX-originX, worldinfo.PlayerY-originY, worldinfo.PlayerZ-originZ);
		scene:AddChild(obj);
	end
end