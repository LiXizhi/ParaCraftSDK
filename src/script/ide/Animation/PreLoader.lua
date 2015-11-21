--[[
Title: preload a movie
Author(s): Leio Zhang
Date: 2008/9/24
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/PreLoader.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
local PreLoader = {
	name = "PerLoader_instance",
	_storyBoardPlayer = nil,
	--events
	StartEvent = nil,
	ProgressEvent = nil,
	EndEvent = nil,
	CompleteEvent = nil,
	ErrorEvent = nil,
}
commonlib.setfield("CommonCtrl.Animation.PreLoader",PreLoader );
function PreLoader:new(storyBoardPlayer)
	local o = {
		_storyBoardPlayer = storyBoardPlayer,
	};
	setmetatable(o, self)
	self.__index = self
	o:Init();
	return o
end
-- start to download
function PreLoader.StartEvent()

end
-- progressive download
function PreLoader.ProgressEvent()

end
-- before complete download
function PreLoader.EndEvent()

end
-- complete download
function PreLoader.CompleteEvent()

end
function PreLoader.ErrorEvent()

end
function PreLoader:Init()
	self._createObjects = nil;
	self._discreteObjectKeyFrames = {};
end
function PreLoader:StartDownLoadAllAssets()

end
function PreLoader:CreateAllObjects()
	local allObjects = self:_GetAllObjects()
	if(not allObjects)then return; end
		local k,param;	
		for k,param in ipairs(allObjects) do
			local name = param["name"];		
			local character = ParaScene.GetCharacter(name);
			if(not character:IsValid())then
				Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=param});
			end		
		end
end
-- show or hide all objects
function PreLoader:ShowOrHideAllObjects(show)
	local allObjects = self:_GetAllObjects()
	if(not allObjects)then return; end
		if(not show)then show = false; end;
		local k,param;
		for k,param in ipairs(allObjects) do
			local name = param["name"];
			local IsCharacter = param["IsCharacter"];
			--if(IsCharacter)then
				local character = ParaScene.GetCharacter(name);
				if(character:IsValid())then
					character:SetVisible(show);
					character:SetScale(0)
				end
			--end
		end
end
function PreLoader:DestoryAllObjects()
	local allObjects = self:_GetAllObjects()
	if(not allObjects)then return; end
		local k,param;
		for k,param in ipairs(allObjects) do
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj_params=param});
		end
		self:Init();
end
function PreLoader:_GetAllObjects()
	if(not self._storyBoardPlayer)then return; end
	if(self._createObjects)then return self._createObjects; end
	
	local str = self._storyBoardPlayer:ReverseToMcml();	
	local xmlRoot = ParaXML.LuaXML_ParseString(str); 
	if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
		local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
		
		self:_SearchNodes(xmlRoot)
	end
	local len = table.getn(self._discreteObjectKeyFrames);
	if(len==0)then return; end
	local node;
	local result = {};
	for __,node in pairs(self._discreteObjectKeyFrames) do
		local discreteObjectKeyFrame = Map3DSystem.Movie.mcml_controls.create(node);
		if(discreteObjectKeyFrame)then
		local value = discreteObjectKeyFrame:GetValue();
			local child_value;
			for __,child_value in ipairs(value) do
				if(child_value)then
					table.insert(result,child_value);
				end
			end
		end
	end
	self._createObjects = result;
	return self._createObjects;
end
function PreLoader:_SearchNodes(nodes)
	if(not nodes)then return; end
	local node;
	local parentName = nodes.name;
	local parentTargetProperty = nodes:GetString("TargetProperty");
	for node in nodes:next()do
		local name = node.name;
		if(parentName == "pe:objectAnimationUsingKeyFrames" and parentTargetProperty == "CreateMeshPhysicsObject" and name== "pe:discreteObjectKeyFrame")then
			local name = node.name;
			table.insert(self._discreteObjectKeyFrames,node);
		else
			self:_SearchNodes(node)
		end		
	end
end
function PreLoader:PlayerStart()
	self:CreateAllObjects()
	self:ShowOrHideAllObjects(false)
end
function PreLoader:PlayerEnd()
	self:ShowOrHideAllObjects(false)
end
function PreLoader:PlayerDestroy()
	self:DestoryAllObjects()
end