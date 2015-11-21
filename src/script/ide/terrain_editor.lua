--[[ 
Title: Terrain editing UI ( Editor Function Only) for ParaEngine
Author(s): LiXizhi
Date: 2005/12
Desc: a collection of overridable terrain (ocean) editing functions. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/terrain_editor.lua");
------------------------------------------------------------
]]
--Require:
NPL.load("(gl)script/ide/gui_helper.lua");
local L = CommonCtrl.Locale("IDE");

--[[TerrainEditorUI library]]
if(not TerrainEditorUI) then TerrainEditorUI={}; end

-- texture brush property
TerrainEditorUI.brush = {
	radius = 2,
	factor = 0.5,
	bErase = false,
};

--[[load the texture list
@param texList: this can be nil, where the default list is loaded.
]]
function TerrainEditorUI.LoadTextureList(texList)
	if(texList~=nil)  then
		TerrainEditorUI.textures = texList;
	else
		TerrainEditorUI.textures = {
			[1]={filename = "Texture/tileset/generic/StoneRoad.dds"},
			[2]={filename = "Texture/tileset/generic/sandRock.dds"},
			[3]={filename = "Texture/tileset/generic/sandSmallRock.dds"},
			[4]={filename = "Texture/tileset/generic/greengrass.dds"},
			[5]={filename = "Texture/tileset/generic/stonegrass.dds"},
			[6]={filename = "Texture/tileset/generic/GridMarker.dds"},
		};
	end	
end

if(not TerrainEditorUI.textures)then
	TerrainEditorUI.LoadTextureList();
end

-- height map or elevation modifier
TerrainEditorUI.elevModifier = {
	radius = 20,
	radius_factor = 0.5,
	smooth_factor = 0.5,
	heightScale = 3.0,
	sq_filter_size = 4,
	sq_filter_weight = 0.5,
	gaussian_deviation = 0.1,
};

-- return the current player position
function TerrainEditorUI.GetPosition()
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid() == true) then
		return player:GetPosition();
	end
end

-- need to be called when terrain height field is modified. It will ask all characters to fall down or snap to the new terrain surface.
function TerrainEditorUI.TerrainModified(x,z,radius)
	ParaTerrain.UpdateTerrain();
	--[[ 	for all bipeds, let them fall.
	local player = ParaScene.GetObject("<player>");
	local playerCur = player;
	while(playerCur:IsValid() == true) do
		
		local x,y,z = playerCur:GetPosition();
		local fElev = ParaTerrain.GetElevation(x,z);
		if(fElev<y) then 
			-- let the biped fall to the ground
			playerCur:ToCharacter():FallDown();
		else
			-- terrain is above character, we need to bring the biped up
			-- TODO: this will go wrong for underground bipeds.
			playerCur:SnapToTerrainSurface(0);
		end
		
		playerCur = ParaScene.GetNextObject(playerCur);
		if(playerCur:equals(player) == true) then
			break; -- cycled to the beginning again.
		end
	end]]
	if(x==nil) then
		x,y,z = TerrainEditorUI.GetPosition();
	end
	if(radius == nil) then
		radius = TerrainEditorUI.brush.radius;
	end
	ParaScene.OnTerrainChanged(x,z,radius); -- this will do the above code in C++
end

--there maybe a UI object called "elev_radius" which has text attribute. It will attempt to get the radius from that control if exists.
function TerrainEditorUI.GetElevRadius()
	local fValue = _guihelper.SafeGetNumber("elev_radius");
	if(fValue~=nil) then
		TerrainEditorUI.elevModifier.radius = fValue;
	end
	return TerrainEditorUI.elevModifier.radius;
end

--there maybe a UI object called "brush_radius" which has text attribute. It will attempt to get the radius from that control if exists.
function TerrainEditorUI.GetBrushRadius()
	local fValue = _guihelper.SafeGetNumber("brush_radius");
	if(fValue~=nil) then
		TerrainEditorUI.brush.radius = fValue;
	end
	return TerrainEditorUI.brush.radius;
end

function TerrainEditorUI.Flatten(x,y,z)
	if(x==nil) then
		x,y,z = TerrainEditorUI.GetPosition();
	end	
	if(not x)then return end
	local radius = TerrainEditorUI.GetElevRadius();
	if(not radius)then return end
	ParaTerrain.DigCircleFlat(x,z,radius, 0.3, 1--[[TerrainEditorUI.elevModifier.smooth_factor]]);
	TerrainEditorUI.TerrainModified();
end

-- apply height field from a raw elevation file
function TerrainEditorUI.AddHeightField(sFileName, x,y,z)
	if(x==nil) then
		x,y,z = TerrainEditorUI.GetPosition();
	end	
	if(not x)then return end
	ParaTerrain.AddHeightField(x,z, sFileName, 10);
	TerrainEditorUI.TerrainModified();
end

-- get default parameter
--@return: same as input of TerrainEditorUI.Paint()
function TerrainEditorUI.PaintParam(texIDorName)
	local x,y,z = TerrainEditorUI.GetPosition();
	local filename;
	if(type(texIDorName) == "string") then
		filename = texIDorName;
	elseif(texIDorName == nil or texIDorName<=0) then
		filename = "";
	elseif(TerrainEditorUI.textures[texIDorName]~=nil and TerrainEditorUI.textures[texIDorName].filename~=nil) then
		filename = TerrainEditorUI.textures[texIDorName].filename;
	end
	local radius = TerrainEditorUI.GetBrushRadius();
	local bErase;
	if(bErase == nil) then
		if(mouse_button == "left") then
			bErase = false;
		elseif(mouse_button == "right") then
			bErase = true;
		end
	end
	return filename,x,y,z,radius, bErase;
end
--[[paint texture on terrain
@param texIDorName: the texture id, such as 1,2,3,4,5,6, or it could be the filename
]]
function TerrainEditorUI.Paint(texIDorName,x,y,z, radius, bErase)
	if(x==nil) then
		x,y,z = TerrainEditorUI.GetPosition();
	end	
	if(not x)then return end
	if(not radius)then 
		radius = TerrainEditorUI.GetBrushRadius();
	end
	
	local filename;
	if(type(texIDorName) == "string") then
		filename = texIDorName;
	elseif(texIDorName == nil or texIDorName<=0) then
		filename = "";
	elseif(TerrainEditorUI.textures[texIDorName]~=nil and TerrainEditorUI.textures[texIDorName].filename~=nil) then
		filename = TerrainEditorUI.textures[texIDorName].filename;
	end
	
	if(bErase == nil) then
		if(mouse_button == "left") then
			bErase = false;
		elseif(mouse_button == "right") then
			bErase = true;
		end
	end
	
	if(filename~=nil) then
		if(bErase == false) then
			local brushIntensity = 0.7;
			ParaTerrain.Paint(filename,radius, brushIntensity, 1.0, false, x,z);
		elseif(bErase == true) then
			local brushIntensity = 1.0;
			if(filename == "") then
				brushIntensity = 0.2;
			end
			ParaTerrain.Paint(filename,radius, brushIntensity, 0, true, x,z);
		end
	end
end

--[[raise or lower the terrain using gaussian edge
@param heightScale: height of the hill, it can be negative.
]]
function TerrainEditorUI.GaussianHill(heightScale,x,y,z)
	if(x==nil) then
		x,y,z = TerrainEditorUI.GetPosition();
	end	
	if(not x)then return end
	local radius = TerrainEditorUI.GetElevRadius();
	if(not radius)then return end
	ParaTerrain.GaussianHill(x,z,radius, heightScale, 0.1, TerrainEditorUI.elevModifier.smooth_factor);
	TerrainEditorUI.TerrainModified();
end

--[[smooth filtering with square filter. 
@param bRoughen:true for sharpening, false for smoothing.
]]
function TerrainEditorUI.Roughen_Smooth(bRoughen,x,y,z)
	if(x==nil) then
		x,y,z = TerrainEditorUI.GetPosition();
	end	
	if(not x)then return end
	local radius = TerrainEditorUI.GetElevRadius();
	if(not radius)then return end
	ParaTerrain.Roughen_Smooth(x,z,radius, bRoughen, false, 0.5);
	TerrainEditorUI.TerrainModified();
end

--[[raise or lower the terrain in radial circles
@param heightScale: height of the hill, it can be negative.
]]
function TerrainEditorUI.RadialScale(heightScale)
end

--[[ save terrain to disk]]
function TerrainEditorUI.SaveToDisk()
	if( ParaTerrain.IsModified() == true) then
		ParaTerrain.SaveTerrain(true,true);
		_guihelper.MessageBox(L"terrain and surface textures have been saved");
	end
end

--[[ set the current water level by the current player's position plus the offset.
@param fOffset: offset
@param bEnable: true to enable water, false to disable. 
]]
function TerrainEditorUI.WaterLevel(fOffset, bEnable)
	local height;
	local player = ParaScene.GetObject("<player>");
	if (player:IsValid() == true) then
		local x,y,z = player:GetPosition();
		if(fOffset ~= 0) then
			y = ParaScene.GetGlobalWaterLevel();
		end
		height = y+fOffset;
		local tmp = ParaUI.GetUIObject("waterlevel__text");
		if (tmp:IsValid()==true)then
			tmp.text = string.format(L"%.1fm", ParaScene.GetGlobalWaterLevel());
		end
	end
	local nServerState = ParaWorld.GetServerState();
	if(nServerState == 0) then
		-- this is a standalone computer
		TerrainEditorUI.UpdateOcean(height, bEnable);
	elseif(nServerState == 1) then
		-- this is a server. 
		server.BroadcastOceanModify(height, bEnable);
	elseif(nServerState == 2) then
		-- this is a client. 
		client.RequestOceanModify(height, bEnable);
	end
end

--@param height: if nil, nothing happens, if it is a double value, it is the height
--@param bEnable: if nil, nothing happens.
--@param r,g,b: ocean color in the range [0,1]. they can be nil.
function TerrainEditorUI.UpdateOcean(height, bEnable, r,g,b)
	if(height~=nil or bEnable~=nil) then
		if(height==nil) then
			height = ParaScene.GetGlobalWaterLevel();
		end
		if(bEnable == nil) then
			bEnable = ParaScene.IsGlobalWaterEnabled();
		end
		ParaScene.SetGlobalWater(bEnable, height);
		if(bEnable==true) then
			ParaScene.UpdateOcean();
		end
	end	
	if(r~=nil) then
		local att = ParaScene.GetAttributeObjectOcean();
		if(att~=nil) then
			att:SetField("OceanColor", {r, g, b});
		end
	end
end
--@param skybox: mesh file name. it can be nil.
--@param r,g,b: sky color in the range [0,1]. they can be nil.
function TerrainEditorUI.UpdateSky(skybox, r,g,b)
	if(type(skybox) == "string") then
		ParaScene.CreateSkyBox ("", ParaAsset.LoadStaticMesh ("", skybox), 160,160,160, 0);
	end
	if(r~=nil) then
		local att = ParaScene.GetAttributeObjectSky();
		if(att~=nil) then
			att:SetField("SkyColor", {r, g, b});
		end
	end
end