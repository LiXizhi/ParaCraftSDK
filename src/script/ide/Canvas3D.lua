--[[
Title: A 3D canvas container for displaying picture, 3D scene
Author(s): LiXizhi
Date: 2007/3/27
Revision: 2009.9.25: ctl:ShowModel(param) now supports async loading models to view it at best camera angle.
Desc: A 3D canvas container for displaying picture, 3D scene, etc. Basic picture and scene manipulation is implemented, such as zooming, panning pictures, and mouse control of 3d scenes. 
__Note__ one can create as many instances of this class as they like, but one must create as few miniscene graph name as possible, as each new mini scene graph will consume some memory and processing time. 
use the lib:
It just uses one inner container with the same name as the control. 
------------------------------------------------------------
NPL.load("(gl)script/ide/Canvas3D.lua");
local ctl = CommonCtrl.GetControl("Canvas_Profile_OPC_Preview");
if(not ctl) then
	ctl = CommonCtrl.Canvas3D:new{
		name = "Canvas_Profile_OPC_Preview",
		alignment = "_lt",
		left = 6, top = 6,
		width = 128,
		height = 128,
		parent = _parent,
		autoRotateSpeed = 0.3,
		IsActiveRendering = true,
		miniscenegraphname = "Canvas_CCS_Preview",
		RenderTargetSize = 128,
	};
else
	ctl.parent = _parent;
end	
ctl:Show(true);
ctl:ShowModel(param, false);
ctl:CameraSetEyePosByAngle(-1.5, 0, 1.2);

-- call following 
ctl:ShowModel(obj or objParams, false) 
ctl:Draw(); -- call this to force drawing, in case self.IsActiveRendering is false. 

ctl:ShowMiniscene("my mini scene graph name");
ctl:ShowImage("Texture/imagefilepath.jpg");

-- ctl:SaveToFile(filename, imageSize)
-- the following static member can be accessed from outside in case one needs to do some rotation in timer
CommonCtrl.Canvas3D.IsMouseDown
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

NPL.load("(gl)script/ide/CanvasCamConfig.lua");
local CanvasCamConfig = commonlib.gettable("MyCompany.Aries.CanvasCamConfig");



-- define a new control in the common control libary

-- default member attributes
local Canvas3D = {
	-- the top level control name
	name = "Canvas3D1",
	-- default background image path. 
	background = nil, 
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 290, 
	parent = nil,
	-- attributes
	--how many degrees per pixel movement
	rotSpeed = 0.004,
	-- how many degrees (in radian) to rotate around the Y axis per second. if nil or 0 it will not rotate. common values are 0.12
	autoRotateSpeed = nil,
	-- how many percentage of maxZoomDist to pan for each mouse pixel movement
	panSpeed = 0.001,
	--model config camera name
	cameraName = nil,
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
	-- must be power of 2, like 128, 256. This is only used in ShowModel. 
	-- However, one can use the set size function miniscenegraph to specify both height and width.
	RenderTargetSize=256,
	-- the camera's field of view when a render target is used. 
	-- FieldOfView = 1.57,
	-- whether it will receive and responds to mouse event
	IsInteractive = true,
	
	-- if not nil, it will render into miniscenegraphname; if not nil, object will be rendered into an external mini scene graph with this name. 
	-- please refer to mcml tag pe:canvas3dui for example of using external scenes. 
	ExternalSceneName = nil,
	-- in case ExternalSceneName is provided, this is the offset used for displaying the object. 
	ExternalOffsetX = 0,
	ExternalOffsetY = 0,
	ExternalOffsetZ = 0,
	-- if not provided, it means "false". if true and ExternalSceneName is provided, we will set the external mini scene's camera according to this node's settings. 
	IgnoreExternalCamera = nil,
	
	-- private: 
	-- 1. resourceType==nil means miniscenegraph, 
	-- 2. resource == 0 means image or swf or avi
	resourceType = nil,
	resourceName = nil,
	-- the miniscenegraph name to use if no one is specified. In case self.ExternalSceneName is provided, this is the object name in the external scene. 
	miniscenegraphname,
	-- whether miniscene graph uses active rendering. default to false.
	IsActiveRendering = false,
	-- the render target's background color. alpha is allowed. defaults to "255 255 255 0". 
	background_color = nil,
}
CommonCtrl.Canvas3D = Canvas3D;


-- constructor
function Canvas3D:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	
	CommonCtrl.AddControl(o.name, o);
	return o
end

-- Destroy the UI control
function Canvas3D:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function Canvas3D:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("Canvas3D instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
	
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		if(self.background == nil) then
			_this.background="";
		else
			_this.background=self.background;
		end	
		
		if(self.ExternalSceneName) then
			self.miniscenegraphname = self.miniscenegraphname or self.ExternalSceneName;
			-- with external scene, we should delete 3d object on close. 
			_this.ondestroy = string.format(";CommonCtrl.Canvas3D.OnDestroy(%q);", self.name);
		elseif(self.IsInteractive) then
			_this.onmousedown = string.format(";CommonCtrl.Canvas3D.OnMouseDown(%q);", self.name);
			_this.onmouseup = string.format(";CommonCtrl.Canvas3D.OnMouseUp(%q);", self.name);
			_this.onmousemove = string.format(";CommonCtrl.Canvas3D.OnMouseMove(%q);", self.name);
			_this.onmousewheel = string.format(";CommonCtrl.Canvas3D.OnMouseWheel(%q);", self.name);
			_this.onmouseenter = string.format(";CommonCtrl.Canvas3D.OnMouseEnter(%q);", self.name); 
			_this.onmouseleave = string.format(";CommonCtrl.Canvas3D.OnMouseLeave(%q);", self.name);
			_this.onframemove = string.format(";CommonCtrl.Canvas3D.OnFrameMove(%q);", self.name);
		else
			_this:GetAttributeObject():SetField("ClickThrough", true)
			if(self.FrameMoveCallback) then
				_this:SetScript("onframemove", function()
					self:FrameMoveCallback();
				end);
			end
		end	

		if(self.zorder) then
			_this.zorder = self.zorder;
		end
		
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
function Canvas3D.OnDestroy(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting Canvas3D instance "..sCtrlName.."\r\n");
		return;
	end
	
	if(self.ExternalSceneName) then
		local obj = ParaUI.GetUIObject(self.name);
		if(not obj:IsValid()) then
			local scene = ParaScene.GetMiniSceneGraph(self.ExternalSceneName);
			if(scene:IsValid()) then
				scene:DestroyObject(self.miniscenegraphname);
			end
		end
	end	
end

--@return: if the ui object is valid
function Canvas3D:IsUIValid()
	if(self.name)then
		local _this = ParaUI.GetUIObject(self.name);
		if(_this and _this:IsValid() == true) then
			return true;
		end
	end
	return false;
end

----------------------------------------------------
-- public methods
----------------------------------------------------

-- public: bind the canvas to an image. 
-- @param filename: the image file path or the image asset object. 
function Canvas3D:ShowImage(filename)
	if(not filename) then
		return
	end
	self.resourceType = 0;
	self.resourceName = filename;
	local _this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid()) then
		if(type(filename) == "string") then
			_this.background = filename;
		else
			_this:SetBGImage(filename);
		end
	end
end

-- set enabled
function Canvas3D:SetEnabled(bEnabled)
	ParaUI.GetUIObject(self.name).enabled = bEnabled;
end

-- auto set render target size,input are rounded to power of 2. 
-- it is only used in ShowModel();
function Canvas3D:SetRenderTargetSize(width, height)
	-- determine the render texture size. 
	local maxSize = math.max(width, height);
	local renderSize = 0;
	if(maxSize <= 32) then
		renderSize = 32;
	elseif(maxSize <= 64) then
		renderSize = 64;
	elseif(maxSize <= 128) then
		renderSize = 128;
	elseif(maxSize <= 256) then
		renderSize = 256;
	elseif(maxSize <= 512) then
		renderSize = 512;
	else
		renderSize = 1024;
	end
	self.RenderTargetSize = renderSize;
end

-- scale the bounding box
local function ScaleBoundingBox(bb, scale)
	if(bb and scale and scale~=1) then
		bb.min_x = bb.min_x*scale;
		bb.max_x = bb.max_x*scale;
		bb.min_y = bb.min_y*scale;
		bb.max_y = bb.max_y*scale;
		bb.min_z = bb.min_z*scale;
		bb.max_z = bb.max_z*scale;
	end
	return bb;
end

function Canvas3D:GetScene()
	return ParaScene.GetMiniSceneGraph(self.resourceName);
end
function Canvas3D:GetObject()
	local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
	if(self.obj_name and scene and scene:IsValid())then
		return scene:GetObject(self.obj_name);
	end
end
function Canvas3D:GetContainer()
	return ParaUI.GetUIObject(self.name);
end
-- public: bind the canvas to a given 3d model or character. it will reset the scene before adding the new model.
-- it will use the currently bind miniscene graph to display it. if no miniscene graph is bind, it will create a default one named "Canvas3D", which is 128*128 in size. 
-- @param obj: a newly created ParaObject or it can be objParams. Note: it can NOT be an object from the main scene or an attached object. 
-- @param bAutoAdjustCamera: true to automatically adjust camera to best view the obj. if nil, it means true. 
function Canvas3D:ShowModel(obj, bAutoAdjustCamera)
	if(ParaUI.GetUIObject(self.name):IsValid() == false) then
		return
	end
	
	if(bAutoAdjustCamera==nil) then
		bAutoAdjustCamera = true;
	end

	if(type(obj) == "table") then
		obj = ObjEditor.CreateObjectByParams(obj);
	end
	if(obj == nil or not obj:IsValid()) then
		-- if no model specified, remove all objects in the mini scene, otherwise the miniscene shows the last shown object
		if(self.resourceType == nil and self.resourceName~=nil and not self.ExternalSceneName) then
			local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
			if(scene:IsValid()) then
				scene:DestroyChildren();
			end
		else
			-- self:ShowImage("")
		end
		return 
	end
	
	local scene;
	
	if(self.ExternalSceneName) then
		self.resourceName = self.ExternalSceneName;
		scene = ParaScene.GetMiniSceneGraph(self.resourceName);
	else
		if(self.resourceType == nil and self.resourceName~=nil) then
			scene = ParaScene.GetMiniSceneGraph(self.resourceName);
		else	
			-- create a default scene
			-------------------------
			-- a simple 3d scene using mini scene graph
			-------------------------
			local sceneName = self.miniscenegraphname or "DefaultCanvas3D"	
			self.resourceName = sceneName;
			scene = ParaScene.GetMiniSceneGraph(sceneName);
		end	
	end	
	
	if(not self.ExternalSceneName and scene and (not scene:IsCameraEnabled() or scene:IsActiveRenderingEnabled() ~= self.IsActiveRendering)) then	
		------------------------------------
		-- init render target
		------------------------------------
		-- set size
		if(self.RenderTargetSize == nil) then
			scene:SetRenderTargetSize(128, 128);
		else
			scene:SetRenderTargetSize(self.RenderTargetSize, self.RenderTargetSize);
		end
		-- reset scene, in case this is called multiple times
		scene:Reset();
		-- enable camera and create render target
		scene:EnableCamera(true);
		-- render it each frame automatically. 
		scene:EnableActiveRendering(self.IsActiveRendering);
		
		local att = scene:GetAttributeObject();
		att:SetField("BackgroundColor", {1, 1, 1}); 
		att:SetField("ShowSky", false);
		att:SetField("EnableFog", false)
		att:SetField("EnableLight", false)
		att:SetField("EnableSunLight", false)
		-- set the transparent background color
		scene:SetBackGroundColor(self.background_color or "127 127 127 0");
		att = scene:GetAttributeObjectCamera();
		if(self.FieldOfView) then
			att:SetField("FieldOfView", self.FieldOfView);
		end
		
		------------------------------------
		-- init camera
		------------------------------------
		scene:CameraSetLookAtPos(0,0.7,0);
		scene:CameraSetEyePosByAngle(0, 0.3, 5);
		
		if(self.mask_texture) then
			scene:SetMaskTexture(ParaAsset.LoadTexture("", self.mask_texture, 1));
		end
	end
	
	if(not self.ExternalSceneName and scene) then
		-- bind to the mini scene graph
		self:ShowMiniscene(scene:GetName())	
	end
	
	if(scene:IsValid()) then
		if(not self.ExternalSceneName) then
			-- clear all. 
			scene:DestroyChildren();
		else
			-- clear just the object in the external scene.
			scene:DestroyObject(self.miniscenegraphname);
			obj:SetName(self.miniscenegraphname);
			if(scene:IsCameraEnabled()) then
				obj:SetFacing(self.DefaultRotY or 0);
			end
		end	
		-- set the object to center. 
		obj:SetPosition(0 + self.ExternalOffsetX,0 + self.ExternalOffsetY,0 + self.ExternalOffsetZ);
		self.obj_name = obj:GetName();
		scene:AddChild(obj);
		-- set camera
		if(not self.ExternalSceneName) then
			local asset = obj:GetPrimaryAsset();
			if(asset:IsValid())then
				local bb = {min_x = -0.5, max_x=0.5, min_y = -0.5, max_y=0.5,min_z = -0.5, max_z=0.5,};
				local scale = obj:GetScale();
				if(asset:IsLoaded() or (self.LookAtHeight and self.DefaultCameraObjectDist))then
					bb = asset:GetBoundingBox(bb);
					bb = ScaleBoundingBox(bb, scale);
				elseif(bAutoAdjustCamera) then
					-- we shall start a timer, to refresh the bounding box once the asset is loaded. 	
					NPL.load("(gl)script/ide/AssetPreloader.lua");
					self.loader = self.loader or commonlib.AssetPreloader:new({
						callbackFunc = function(nItemsLeft)
							if(nItemsLeft == 0) then
								-- NOTE: since asset object are never garbage collected, we will assume asset is still valid at this time. 
								-- However, this can not be easily assumed if I modified the game engine asset logics.
								if(self.asset_ and self.asset_:IsLoaded()) then
									local bb = self.asset_:GetBoundingBox(bb);
									bb = ScaleBoundingBox(bb, self.scale_ or 1);

									--todo:add camera name parameter 
									local camInfo = CanvasCamConfig.QueryCamInfo(self.asset_:GetKeyName(),self.cameraName);
									if(camInfo~=nil)then
										self:AdjustCamera(camInfo,bb,self.scale_ or 1);
									else
										self:AutoAdjustCameraByBoundingBox(bb);
									end
									self.asset_ = nil;
								end	
							end
						end
					});
					self.loader:clear();
					self.loader:AddAssets(asset);
					self.asset_ = asset
					self.scale_ = scale;
					self.loader:Start();
				end	

				if(bAutoAdjustCamera and not self.ExternalSceneName) then
					local key_filename = asset:GetKeyName();
					local camInfo = CanvasCamConfig.QueryCamInfo(key_filename,self.cameraName);
					if(camInfo~=nil)then
						self:AdjustCamera(camInfo,bb,scale);
					else					
						self:AutoAdjustCameraByBoundingBox(bb);
					end
				end	
			end
		else
			if(self.IgnoreExternalCamera and not scene:IsCameraEnabled()) then
				self:CameraSetEyePosByAngle(self.DefaultRotY, self.DefaultLiftupAngle, self.DefaultCameraObjectDist);
			end
		end	
	else
		commonlib.applog("warning: Canvas3D can not find a miniscene to render to \n")	;
	end
end

-- change background color, alpha channel is supported. 
-- @param color: such as "255 255 255 0".
function Canvas3D:SetBackGroundColor(color)
	if(self.resourceName and not self.ExternalSceneName) then
		local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
		-- set the transparent background color
		scene:SetBackGroundColor(color or "255 255 255 0");
	end
end
-- set the facing of the current model if any. This function can be used to rotate the model. 
-- @param facing: facing value in rad. 
-- @param bIsDelta: if true, facing will be addictive. 
function Canvas3D:SetModelFacing(facing, bIsDelta)
	if(facing and self.resourceName) then
		local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
		local obj = scene:GetObject(self.miniscenegraphname);
		if(obj:IsValid()) then
			if(bIsDelta) then
				obj:SetFacing(obj:GetFacing()+facing);
			else
				obj:SetFacing(facing);
			end
		end
	end	
end

-- adjust the bounding box so that the camera can best view a given bounding box. 
-- @param bb: the bounding box {min_x = -0.5, max_x=0.5, min_y = -0.5, max_y=0.5,min_z = -0.5, max_z=0.5,} to be contained in the view. 
function Canvas3D:AutoAdjustCameraByBoundingBox(bb)
	if(ParaUI.GetUIObject(self.name):IsValid() == false) then
		return
	end
	if(self.resourceName and not self.ExternalSceneName) then
		local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
		
		if(scene:IsValid()) then
			local x,y,z = (bb.max_x - bb.min_x), (bb.max_y - bb.min_y), (bb.max_z - bb.min_z)
			local dist = math.max(x,y,z)
			if(dist == 0) then
				dist = 3;
			end
			scene:CameraSetLookAtPos(0,self.LookAtHeight or (bb.max_y + bb.min_y)*0.618,0);
			--[[ 
			local cameradist = (dist+2);
			if(dist < 0.5) then
				cameradist = dist * 4;
			elseif(dist > 5 and dist <=10) then
				cameradist = dist*2 + math.max(x,z,2);
			elseif(dist > 10) then
				cameradist = dist*2;
			end]]
			local cameradist = math.max(z,y,0.5)*1.2 + math.max(x,z) * 0.5 + 0.5; -- x or z is the depth
			if(cameradist < self.minZoomDist) then
				cameradist = self.minZoomDist;
			end
			scene:CameraSetEyePosByAngle(self.DefaultRotY or 2.7, self.DefaultLiftupAngle or 0.3, self.DefaultCameraObjectDist or cameradist);
			self.maxZoomDist = math.max(cameradist*3+self.minZoomDist, self.maxZoomDist or 0);
		end	
	end
end

-- adjust camera by camInfo and bounding box
function Canvas3D:AdjustCamera(camInfo,bb,scale)
	if(ParaUI.GetUIObject(self.name):IsValid() == false) then
		return
	end
	
	if(self.resourceName and not self.ExternalSceneName) then
		local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
			
		if(scene:IsValid()) then
			local lookAtY;
			if(camInfo.lookAtY)then
				lookAtY = camInfo.lookAtY * scale;
			else
				lookAtY = self.LookAtHeight or (bb.max_y + bb.min_y)*0.618;
			end
			scene:CameraSetLookAtPos(0,lookAtY,0);			

			local cameradist;
			if(camInfo.dist)then
				cameradist = camInfo.dist * scale;
			else
				local x,y,z = (bb.max_x - bb.min_x), (bb.max_y - bb.min_y), (bb.max_z - bb.min_z)
				cameradist = math.max(z,y,0.5)*1.2 + math.max(x,z) * 0.5 + 0.5; -- x or z is the depth
			end
			if(cameradist < self.minZoomDist) then
				cameradist = self.minZoomDist;
			end


			local camRotY;
			if(camInfo.rotY)then
				camRotY = camInfo.rotY;
			else
				camRotY = self.DefaultRotY or 2.7;
			end

			local camLiftUp;
			if(camInfo.liftUp)then
				camLiftUp = camInfo.liftUp;
			else
				camLiftUp = self.DefaultLiftupAngle or 0.3;
			end
											
			scene:CameraSetEyePosByAngle(camRotY, camLiftUp, self.DefaultCameraObjectDist or cameradist);
			self.maxZoomDist = math.max(cameradist*3+self.minZoomDist, self.maxZoomDist or 0);
		end	
	end
end

-- manually draw the miniscene graph, in case active rendering is disabled. 
function Canvas3D:Draw(deltaTime)
	if(self.resourceType == nil and self.resourceName ~= nil and not self.ExternalSceneName) then
		local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
		if(scene:IsValid()) then
			if(not scene:IsActiveRenderingEnabled()) then
				scene:Draw(deltaTime or 0);
			end
		end	
	else
		commonlib.log("warning: one can not call with Canvas3D:Draw() while resourceName is nil.canvasName is %s\n", tostring(self.name));
	end	
end

-- whether to turn on active rendering. 
function Canvas3D:EnableActiveRendering(bEnable)
	if(self.resourceType == nil and self.resourceName ~= nil and not self.ExternalSceneName) then
		local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
		if(scene:IsValid()) then
			if(bEnable ~= nil) then
				scene:EnableActiveRendering(bEnable);
			else
				LOG.std(nil, "warn", "Canvas3D", "bEnable must be boolean for EnableActiveRendering");
			end
		end	
	else
		commonlib.log("warning: one can not call with Canvas3D:Draw() while resourceName is nil.canvasName is %s\n", tostring(self.name));
	end	
end

-- public: bind the canvas to a miniscenegraph. 
-- @param name: mini scene graph name.
function Canvas3D:ShowMiniscene(name)
	self.resourceType = nil;
	self.resourceName = name;
	if(self.resourceName ~= nil and not self.ExternalSceneName) then
		local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
		if(scene:IsValid()) then
			local _this=ParaUI.GetUIObject(self.name);
			if(_this:IsValid()) then
				_this:SetBGImage(scene:GetTexture());
			end	
		end
	end	
end

-- public: save the canvas content to file
-- @param filename: sFileName a texture file path to save the file to. 
--  we support ".dds", ".jpg", ".png" files. If the file extension is not recognized, ".png" file is used. 
-- @param nImageSize: if this is zero, the original size is used. If it is dds, all mip map levels are saved.
function Canvas3D:SaveToFile(filename, imageSize)
	commonlib.echo({filename, imageSize});
	if(self.resourceType == nil and not self.ExternalSceneName) then
		local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
		if(scene:IsValid()) then
			imageSize = imageSize or 0;
			ParaIO.CreateDirectory(filename);
			return scene:SaveToFile(filename, imageSize);
		end	
	end	
end

-- adopt the mini scene graph position. 
function Canvas3D.AdoptMiniSceneCamera(scene)
	if(scene) then
		local fRotY, fLiftupAngle, fCameraObjectDist = scene:CameraGetEyePosByAngle();
		local att = ParaCamera.GetAttributeObject();
		att:SetField("CameraObjectDistance", fCameraObjectDist);
		att:SetField("CameraLiftupAngle", fLiftupAngle);
		att:SetField("CameraRotY", fRotY);
	end
end

-- directly set the camera look at position with engine api calls
function Canvas3D:CameraSetLookAtPos(fLookAtX, fLookAtY, fLookAtZ)
	if(self.resourceType == nil and not self.ExternalSceneName) then
		local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
		if(scene:IsValid()) then
			scene:CameraSetLookAtPos(fLookAtX, fLookAtY, fLookAtZ);
		end
	end
end

-- backward compatible
Canvas3D.CameraSetLootAtPos = Canvas3D.CameraSetLookAtPos;

-- directly set the camera angle with engine api calls
function Canvas3D:CameraSetEyePosByAngle(fRotY, fLiftupAngle, fCameraObjectDist)
	if(self.resourceType == nil) then
		local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
		if(scene:IsValid()) then
			scene:CameraSetEyePosByAngle(fRotY, fLiftupAngle, fCameraObjectDist);
			
			if(self.ExternalSceneName and self.IgnoreExternalCamera and not scene:IsCameraEnabled()) then
				Canvas3D.AdoptMiniSceneCamera(scene);
			end
		end
	end
end

-- set the canvas mask texture
function Canvas3D:SetMaskTexture(textureFile)
	if(self.resourceType == nil and not self.ExternalSceneName) then
		local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
		if(scene:IsValid()) then
			scene:SetMaskTexture(ParaAsset.LoadTexture("", textureFile, 1));
		end
	end
end

----------------------------------------------------
-- window events 
----------------------------------------------------

-- mouse down position
Canvas3D.lastMouseDown = {x = 0, y=0}
Canvas3D.lastMousePos = {x = 0, y=0}
-- whether any mouse button is down
Canvas3D.IsMouseDown = false;
-- whether middle mouse button is down
Canvas3D.IsMidMouseDown = false;

function Canvas3D.OnMouseDown(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting Canvas3D instance "..sCtrlName.."\r\n");
		return;
	end
	
	Canvas3D.lastMouseDown.x = mouse_x;
	Canvas3D.lastMouseDown.y = mouse_y;
	Canvas3D.IsMouseDown = true;
	Canvas3D.lastMousePos.x = mouse_x;
	Canvas3D.lastMousePos.y = mouse_y;
	if(mouse_button == "middle") then
		Canvas3D.IsMidMouseDown = true;
		
		--if(self.resourceType == nil) then
			--local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
			--if(scene:IsValid()) then
				--log("+++++++++++++++++++++++++++++++++++++++\n")
				--commonlib.echo({scene:CameraGetLookAtPos()});
				--commonlib.echo({scene:CameraGetEyePosByAngle()});
				--log("+++++++++++++++++++++++++++++++++++++++\n")
			--end
		--end
	end
end

function Canvas3D.OnMouseMove(sCtrlName)
	if(Canvas3D.IsMouseDown) then
		local mouse_dx, mouse_dy = mouse_x-Canvas3D.lastMousePos.x, mouse_y-Canvas3D.lastMousePos.y;
		if(mouse_dx~=0 or mouse_dy~=0) then
			local self = CommonCtrl.GetControl(sCtrlName);
			if(self~=nil and self.resourceName~=nil)then
				if(self.resourceType == nil) then
					--
					-- 3D scene
					--
					local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
					if(scene:IsValid()) then
						if(not self.ExternalSceneName) then
							-- rotate camera for local scene
							if(Canvas3D.IsMidMouseDown) then
								-- if middle button is down, it is panning along the vertical position. 
								if(mouse_dy~=0) then
									local at_x, at_y, at_z = scene:CameraGetLookAtPos();
									local eye_x, eye_y, eye_z = scene:CameraGetEyePos();
									local fRotY, fLiftupAngle, fCameraObjectDist = scene:CameraGetEyePosByAngle();
									local deltaY = self.panSpeed*math.max(fCameraObjectDist,0.1)*mouse_dy;
									at_y = at_y + deltaY;
									eye_y = eye_y + deltaY;
									scene:CameraSetLookAtPos(at_x, at_y, at_z);
									scene:CameraSetEyePos(eye_x, eye_y, eye_z);
								end	
							else
								-- left or right button is down, it is rotation around the current position
								
								local fRotY, fLiftupAngle, fCameraObjectDist = scene:CameraGetEyePosByAngle();
								fRotY = fRotY+mouse_dx*self.rotSpeed; --how many degrees per pixel movement
								fLiftupAngle = fLiftupAngle + mouse_dy*self.rotSpeed; --how many degrees per pixel movement
								if(fLiftupAngle>self.maxLiftupAngle) then
									fLiftupAngle = self.maxLiftupAngle;
								end
								if(fLiftupAngle<self.minLiftupAngle) then
									fLiftupAngle = self.minLiftupAngle;
								end
								scene:CameraSetEyePosByAngle(fRotY, fLiftupAngle, fCameraObjectDist);
							end	
						else
							-- TODO: rotate object for external scene. 
						end	
					end
				elseif(self.resourceType == 0)then	
					--
					-- 2D image
					--
				end		
			end
		end	
	end
	Canvas3D.lastMousePos.x = mouse_x;
	Canvas3D.lastMousePos.y = mouse_y;
end

function Canvas3D.OnMouseUp(sCtrlName)
	if(not Canvas3D.IsMouseDown) then
		return 
	end
	Canvas3D.IsMouseDown = false;
	Canvas3D.IsMidMouseDown = false;
	local dragDist = (math.abs(Canvas3D.lastMousePos.x-Canvas3D.lastMouseDown.x) + math.abs(Canvas3D.lastMousePos.y-Canvas3D.lastMouseDown.y));
	if(dragDist<=2) then
		-- this is mouse click event if mouse down and mouse up distance is very small.
	end
	Canvas3D.lastMousePos.x = mouse_x;
	Canvas3D.lastMousePos.y = mouse_y;
end

function Canvas3D.OnMouseWheel(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil or self.resourceName==nil)then
		log("error getting Canvas3D instance "..sCtrlName.."\r\n");
		return;
	end
	if(self.resourceType == nil) then
		--
		-- 3D scene
		--
		local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
		if(scene:IsValid()) then
			if(not self.ExternalSceneName) then
				-- zoom camera for local scene
				local fRotY, fLiftupAngle, fCameraObjectDist = scene:CameraGetEyePosByAngle();
				fCameraObjectDist = fCameraObjectDist*math.pow(1.1, -mouse_wheel); --how many scales per wheel delta movement
				if(fCameraObjectDist>self.maxZoomDist) then
					fCameraObjectDist = self.maxZoomDist;
				end
				if(fCameraObjectDist<self.minZoomDist) then
					fCameraObjectDist = self.minZoomDist;
				end
				scene:CameraSetEyePosByAngle(fRotY, fLiftupAngle, fCameraObjectDist);
			else
				-- TODO: scale character for external scene
			end	
		end
	elseif(self.resourceType == 0)then	
		--
		-- 2D image
		--
	end	
end

function Canvas3D.OnMouseEnter(sCtrlName)

end

function Canvas3D.OnMouseLeave(sCtrlName)
end

function Canvas3D.OnFrameMove(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil or self.resourceName==nil)then
		return;
	end
	if(self.resourceType == nil) then
		--
		-- 3D scene
		--
		if(not Canvas3D.IsMouseDown and self.autoRotateSpeed and self.autoRotateSpeed~=0) then
			local scene = ParaScene.GetMiniSceneGraph(self.resourceName);
			if(scene:IsValid()) then
				if(not self.ExternalSceneName) then
					-- rotate camera for local scene
					local fRotY, fLiftupAngle, fCameraObjectDist = scene:CameraGetEyePosByAngle();
					fRotY = fRotY+self.autoRotateSpeed*deltatime; --how many degrees per frame move
					scene:CameraSetEyePosByAngle(fRotY, fLiftupAngle, fCameraObjectDist);
				else
					-- rotate object for external scene
					local obj = scene:GetObject(self.miniscenegraphname);
					if(obj:IsValid()) then
						local fRotY = obj:GetFacing();
						fRotY = fRotY+self.autoRotateSpeed*deltatime; --how many degrees per frame move
						if(fRotY > 6.28) then
							fRotY = fRotY - 6.28;
						end
						obj:SetFacing(fRotY);
					end	
				end
			end	
		end
	end

	if(self.FrameMoveCallback) then
		self:FrameMoveCallback();
	end
end
