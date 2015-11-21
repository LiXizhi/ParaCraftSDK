--[[
Title:
Author: Clayman
Date:2011/9/26
------------------------------------------------------------
NPL.load("(gl)script/ide/CanvasCamConfig.lua");
local CanvasCamConfig = commonlib.gettable("MyCompany.Aries.CanvasCamConfig");
CanvasCamConfig.Init()
CanvasCamConfig.QueryCamInfo(assetFile,camName);
------------------------------------------------------------
]]

local CanvasCamConfig = commonlib.gettable("MyCompany.Aries.CanvasCamConfig");
CanvasCamConfig.camMap = nil;


--@param assetFile:assetFileName
--@param camName : camera name, if nil return default camera
--@return camInfo{lookAtX,lookAtY,lookAtZ,rotY,liftUp,dist} or nil if no camInfo found; element in camInfo can be nil,check before use.
function CanvasCamConfig.QueryCamInfo(assetFile,camName)
	if(assetFile == nil or assetFile =="")then
		return nil;
	end
	
	if(CanvasCamConfig.camMap == nil)then
		CanvasCamConfig.Init();
	end

	if(CanvasCamConfig.camMap)then
		local name = string.lower(assetFile);
		local camInfos = CanvasCamConfig.camMap[name];
		if(camInfos)then
			if(camName == nil or camName == "")then
				camName = "default";
			end
			return camInfos[camName];
		end
	end
end

local configFilePath = "config/Aries/Cameras/ModelCamConfig.xml";
function CanvasCamConfig.Init()
	local xmlRoot = ParaXML.LuaXML_ParseFile(configFilePath);
	if(xmlRoot == nil)then
		return;
	end

	CanvasCamConfig.camMap = {};
	local modelNode;
	for modelNode in commonlib.XPath.eachNode(xmlRoot,"//models/model")do
		if(modelNode.attr.name ~= nil or modelNode.attr.name ~= "")then
			local modelCams = {};
			CanvasCamConfig.camMap[string.lower(modelNode.attr.name)] = modelCams;

			local camNode;
			for camNode in commonlib.XPath.eachNode(modelNode,"//camInfo")do
				if(camNode.attr.name ~=nil and camNode.attr.name ~= "")then		
					local camInfo = {};
					modelCams[string.lower(camNode.attr.name)] = camInfo;
					camInfo.lookAtX = tonumber(camNode.attr.lookAtX);
					camInfo.lookAtY = tonumber(camNode.attr.lookAtY);
					camInfo.lookAtZ = tonumber(camNode.attr.lookAtZ);
					camInfo.rotY = tonumber(camNode.attr.rotY);
					camInfo.liftUp = tonumber(camNode.attr.liftUp);
					camInfo.dist = tonumber(camNode.attr.camDist);
				end
			end
		end
	end
end