--[[
Title: 3D objects rendered after UI is rendered. 
Author(s): LiXizhi
Date: 2009/10/16
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Canvas3DUI.lua");
local ctl = CommonCtrl.GetControl("Canvas_Profile_OPC_Preview");
if(not ctl) then
	ctl = CommonCtrl.Canvas3DUI:new{
		name = "DefaultCanvas3DUI",
		alignment = "_lt",
		left = 6, top = 6,
		width = 128,
		height = 128,
		miniscenegraphname = "DefaultCanvas3DUI",
	};
end
ctl:Show(true);

-- showing a single model
ctl:ShowModel({ ["IsCharacter"] = true,
				["y"] = 0,
				["x"] = 0,
				["facing"] = -1.57,
				["name"] = "pe:avatar:11",
				["z"] = 0,
				["AssetFile"] = "character/v1/01human/baru/baru.x",
			});
-- showing from a scene
ctl:LoadFromOnLoadScript("worlds/myworlds/arieslogin/script/arieslogin_0_0.onload.lua", 255, 0, 255)
ctl:LoadFromOnNPCdb("worlds/myworlds/arieslogin/arieslogin.npc.db", 255, 0, 255)
ctl:CameraSetLookAtPos(0, 2, 0)
ctl:CameraSetEyePosByAngle(0, 0.3, 7)
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/MinisceneManager.lua");

-- default member attributes
local Canvas3DUI = {
	-- the top level control name
	name = "DefaultCanvas3DUI",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 0,
	height = 0, 
	parent = nil,
	-- if true, we will create an unenabled and invisible UI control using above params, whever the UI control is deleted, the miniscenegraph will also be deleted. 
	-- self:Show() must be called in order for AutoDelete to take effect. 
	AutoDelete = true,
	-- the miniscenegraph name to use if no one is specified. self.name is used. 
	miniscenegraphname = "DefaultCanvas3DUI",
	
	-- the default came object distance, if nil, we will automatically calculate according to the bounding box. 
	DefaultCameraObjectDist = nil,
	DefaultLiftupAngle = nil,
	DefaultRotY = nil, 
	-- camera look at height. if nil, the bounding box of the asset will be used for height calculation. 
	LookAtHeight = nil,
	-- camera lift up angle range in 3D mode. 
	maxLiftupAngle = 1.3,
	minLiftupAngle = 0.1,
	-- how many meters to zoom in and out in 3D mode. 
	maxZoomDist = 20,
	minZoomDist = 0.01,
}
CommonCtrl.Canvas3DUI = Canvas3DUI;

-- constructor
function Canvas3DUI:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	CommonCtrl.AddControl(o.name, o);
	return o
end

-- Destroy the UI control
function Canvas3DUI:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function Canvas3DUI:Show(bShow)
	if(self.AutoDelete == false) then
		return;
	end
	
	local _this,_parent;
	if(self.name==nil)then
		log("Canvas3D instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
	
		_this=ParaUI.CreateUIObject("button",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.ondestroy = string.format(";CommonCtrl.Canvas3DUI.OnDestroy(%q);", self.name);
		_this.background = "";
		_this.enabled = false;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end	
end

-- close the given control
function Canvas3DUI.OnDestroy(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting Canvas3DUI instance "..sCtrlName.."\r\n");
		return;
	end
	
	local obj = ParaUI.GetUIObject(self.name);
	if(not obj:IsValid() and self.AutoDelete) then
		ParaScene.DeleteMiniSceneGraph(self.miniscenegraphname);
	end
end

-- get the miniscene object. and create it if not created before. 
function Canvas3DUI:GetScene()
	local scene = ParaScene.GetMiniSceneGraph(self.miniscenegraphname or "DefaultCanvas3DUI");
	
	if(scene and (not scene:IsCameraEnabled() or scene:IsActiveRenderingEnabled() ~= true)) then	
		------------------------------------
		-- init render target
		------------------------------------
		-- reset scene, in case this is called multiple times
		scene:Reset();
		
		local att = scene:GetAttributeObject();
		-- this needs to be set before EnableCamera() in order for aspect ratio to be set to that of the main scene
		att:SetField("RenderPipelineOrder", 51); 
		
		-- enable camera and create render target
		scene:EnableCamera(true);
		-- render it each frame automatically. 
		scene:EnableActiveRendering(true);
		
		att:SetField("ShowSky", false);
		att:SetField("EnableFog", false)
		att:SetField("EnableLight", false)
		att:SetField("EnableSunLight", false)
	end
	return scene;
end

-- get scene object name. 
function Canvas3DUI:GetSceneName()
	return self.miniscenegraphname;
end

--[[ Load a miniscene graph with all mesh objects contained in on load script. 
@param filename: An on load script is usually save at worlds/[name]/script/[name]_0_0.onload.lua during scene saving
@param originX, originY, originZ: we can use a new scene origin when loading the scene. if nil, 0 is used
]]
function Canvas3DUI:LoadFromOnLoadScript(filename, originX, originY, originZ)
	local scene = self:GetScene();
	if(scene) then
		CommonCtrl.MinisceneManager.LoadFromOnLoadScript(scene, filename, originX, originY, originZ);
	end	
end

--[[ load character from NPL database 
@param filename: NPC database file which is usually save at worlds/[name]/[name].NPC.db during scene saving
@param originX, originY, originZ: we can use a new scene origin when loading the scene. if nil, 0 is used
]]
function Canvas3DUI:LoadFromOnNPCdb(filename, originX, originY, originZ)
	local scene = self:GetScene();
	if(scene) then
		CommonCtrl.MinisceneManager.LoadFromOnNPCdb(scene, filename, originX, originY, originZ);
	end	
end

-- clear all scene objects but retain camera settings. 
function Canvas3DUI:ClearScene()
	local scene = self:GetScene();
	if(scene) then
		scene:DestroyChildren();
	end
end

-- public: bind the canvas to a given 3d model or character. it will reset the scene before adding the new model.
-- it will use the currently bind miniscene graph to display it. if no miniscene graph is bind, it will create a default one named "Canvas3DUI", which is 128*128 in size. 
-- @param obj: a newly created ParaObject or it can be objParams. Note: it can NOT be an object from the main scene or an attached object. 
function Canvas3DUI:ShowModel(obj)
	if(type(obj) == "table") then
		obj = ObjEditor.CreateObjectByParams(obj);
	end
	if(obj == nil or not obj:IsValid()) then
		-- if no model specified, remove all objects in the mini scene, otherwise the miniscene shows the last shown object
		return 
	end
	
	local scene = self:GetScene();
	
	if(scene and (not scene:IsCameraEnabled() or scene:IsActiveRenderingEnabled() ~= true)) then	
		------------------------------------
		-- init render target
		------------------------------------
		-- reset scene, in case this is called multiple times
		scene:Reset();
		
		local att = scene:GetAttributeObject();
		att:SetField("RenderPipelineOrder", 51); 
		
		-- enable camera and create render target
		scene:EnableCamera(true);
		-- render it each frame automatically. 
		scene:EnableActiveRendering(true);
		
		att:SetField("ShowSky", false);
		att:SetField("EnableFog", false)
		att:SetField("EnableLight", false)
		att:SetField("EnableSunLight", false)
		
		------------------------------------
		-- init camera
		------------------------------------
		scene:CameraSetLookAtPos(0,0.7,0);
		scene:CameraSetEyePosByAngle(0, 0.3, 5);
	end
	
	if(scene:IsValid()) then
		-- clear all. 
		scene:DestroyChildren();
		-- set the object to center. 
		obj:SetPosition(0,0,0);	
		scene:AddChild(obj);
		-- TODO: set camera
		local asset = obj:GetPrimaryAsset();
		if(asset:IsValid())then
			local bb = {min_x = -0.5, max_x=0.5, min_y = -0.5, max_y=0.5,min_z = -0.5, max_z=0.5,};
			if(asset:IsLoaded() or (self.LookAtHeight and self.DefaultCameraObjectDist))then
				bb = asset:GetBoundingBox(bb);
			else
				-- we shall start a timer, to refresh the bounding box once the asset is loaded. 	
				NPL.load("(gl)script/ide/AssetPreloader.lua");
				self.loader = self.loader or commonlib.AssetPreloader:new({
					callbackFunc = function(nItemsLeft)
						if(nItemsLeft == 0) then
							-- NOTE: since asset object are never garbage collected, we will assume asset is still valid at this time. 
							-- However, this can not be easily assumed if I modified the game engine asset logics.
							if(asset:IsLoaded()) then
								bb = asset:GetBoundingBox(bb);
								self:AutoAdjustCameraByBoundingBox(bb);
							end	
						end
					end
				});
				self.loader:clear();
				self.loader:AddAssets(asset);
				self.loader:Start();
			end	
			self:AutoAdjustCameraByBoundingBox(bb);
		end
	end
end

-- adjust the bounding box so that the camera can best view a given bounding box. 
-- @param bb: the bounding box {min_x = -0.5, max_x=0.5, min_y = -0.5, max_y=0.5,min_z = -0.5, max_z=0.5,} to be contained in the view. 
function Canvas3DUI:AutoAdjustCameraByBoundingBox(bb)
	if(ParaUI.GetUIObject(self.name):IsValid() == false) then
		return
	end
	local scene = self:GetScene();
	if(scene) then
		local x,y,z = (bb.max_x - bb.min_x), (bb.max_y - bb.min_y), (bb.max_z - bb.min_z)
		local dist = math.max(x,y,z)
		scene:CameraSetLookAtPos(0,self.LookAtHeight or (bb.max_y + bb.min_y)/2,0);
		scene:CameraSetEyePosByAngle(self.DefaultRotY or 2.7, self.DefaultLiftupAngle or 0.3, self.DefaultCameraObjectDist or (dist+2));
		self.maxZoomDist = dist*3+self.minZoomDist;
	end	
end

-- directly set the camera look at position with engine api calls
function Canvas3DUI:CameraSetLookAtPos(fLookAtX, fLookAtY, fLookAtZ)
	local scene = self:GetScene();
	if(scene) then
		scene:CameraSetLookAtPos(fLookAtX, fLookAtY, fLookAtZ);
	end
end

-- directly set the camera angle with engine api calls
function Canvas3DUI:CameraSetEyePosByAngle(fRotY, fLiftupAngle, fCameraObjectDist)
	local scene = self:GetScene();
	if(scene) then
		scene:CameraSetEyePosByAngle(fRotY, fLiftupAngle, fCameraObjectDist);
	end
end
