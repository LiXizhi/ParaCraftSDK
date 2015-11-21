--[[
Title: the object editor for ParaEngine 3D environment development library
Dest: it can change an object's position, orientation and scale, etc. 
It assumes CommonCtrl.GetControl("propertyDlg") to be the default object property modifier. It will create it if it does not exist.
Author(s): LiXizhi
Date: 2005/11
Revised: 2007/10 code is never used.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/object_editor_v1.lua");
------------------------------------------------------------
]]
local L = CommonCtrl.Locale("IDE");

-- requires:
NPL.load("(gl)script/ide/gui_helper.lua");
NPL.load("(gl)script/ide/FileDialog.lua");
NPL.load("(gl)script/ide/terrain_editor.lua");
NPL.load("(gl)script/ide/property_control.lua");
--NPL.load("(gl)script/ide/user_action.lua");
-- CommonCtrl.user_action:AddAction({id = CommonCtrl.user_action.action_id.Player_Create_Mesh, name="noName", FilePath="XXX", x=10,y=10,z=10});

--[[ObjEditor library]]
local ObjEditor = commonlib.gettable("ObjEditor");

-- list of ParaObjects that can be edited in the current scene.
ObjEditor.objects = {};
-- The current ParaObject that is being selected.
--ObjEditor.currentObj = nil;
-- assets in categories
ObjEditor.assets={};

ObjEditor.RandomStaticMeshFacing = false; -- whether to randomize the mesh facing when created.
ObjEditor.CurrentDir = "model/";
ObjEditor.CurrentAssetIndex = 0; -- category index of the ObjEditor.assets table
ObjEditor.SelectedGroupIndex = 0;
ObjEditor.LastCreatedModelName = "";
ObjEditor.LastCreatedModelPath = "";
ObjEditor.LastCreatePos = {x=0,y=0,z=0};
ObjEditor.objectCounter = 0;
ObjEditor.MIN_OBJ_DIST = 0.15; -- smallest distance between two identical objects

function ObjEditor.LoadDevAsset()
	ObjEditor.assets ={
	 {name="建筑", rootpath = "model/01建筑/"},
	 {name="家具", rootpath = "model/02家具/"},
	 {name="生活", rootpath = "model/03生活/"},
	 
	 {name="装饰", rootpath = "model/04装饰/"},
	 {name="植物", rootpath = "model/05植物/"},
	 {name="矿石", rootpath = "model/06矿石/"},
	 {name="杂物", rootpath = "model/pops/"},
	 
	 {name="其它", rootpath = "model/others/"}, -- for script and height files
	 {name="人物", rootpath = "character/"},
	 {name="MODEL", rootpath = "model/"},
	 {name="测试", rootpath = "model/test/"}
	};
	log("demo asset loaded\r\n");
end

-- load development asset by default.
-- ObjEditor.LoadDevAsset();

--[[ Get a named object in the scene
@param sName: string: the name of the object.
@return: nil if not found; a ParaObject if found.
]]
function ObjEditor.GetObject(sName)
	return ObjEditor.objects[tostring(sName)];
end

--[[ get the current object ]]
function ObjEditor.GetCurrentObj()
	return ParaSelection.GetObject(0,0);
end

--[[ Set the current object ]]
function ObjEditor.SetCurrentObj(o)
	if(o~=nil) then
		ParaSelection.AddObject(o, 0); -- add object to selection group 0
		if( ObjEditor.SelectedGroupIndex >0) then
			ParaSelection.AddObject(o, ObjEditor.SelectedGroupIndex);
		end
	else
		ParaSelection.ClearGroup(0); -- clear any selection	in group 0
	end
end

--[get the number of active objects in the scene]
function ObjEditor.GetObjectNum()
	return table.getn(ObjEditor.objects);
end
--[[ select an object by its name. if the object does not exists, 
The current selection is not changed.
@param sName: string: the name of the object.
@return: the current selected object is returned.
]]
function ObjEditor.SelectObj(sName)
	local obj = ObjEditor.GetObject(sName);
	if(obj~=nil) then
		ObjEditor.SetCurrentObj(obj);
	end
	return obj;
end
--[[ change an object's name from sOld to sNew
@param sOld, sNew: string
]]
function ObjEditor.ReName(sOld, sNew)
	local objOld = ObjEditor.objects[sOld];
	if(objOld~=nil) then
		objOld.name = sNew;
		ObjEditor.objects[sOld] = nil;
		ObjEditor.objects[sNew] = objOld;
		log(sOld.." is renamed to "..sNew.."\n");
	end
end

--[[Remove the object from the active object list
@param object_name: string value: actor name
@return: return the object that is removed. if nil, there is no such object.
]]
function ObjEditor.RemoveObject(object_name)
	local obj = ObjEditor.objects[object_name];
	if(obj~=nil) then
		ParaSelection.RemoveObject(obj);
		ObjEditor.objects[object_name] = nil;
	end
	return obj;
end

--[[
create a physics object at the specifed position using a Model asset.
The newly created object will be further editable. 
@param sName: the name of the physics objects, if there is already an object
	with the same name, an error message will be returned.if it If the file name ends with _a,  such as "xxx_a.x", then 
	the mesh will by default be created without physics.
@param Model: [string|ParaAssetObject] if this is a string, then it will be treated 
as the file name of the model asset; otherwise, it will be treated like a ParaAssetObject. 
@param x,y,z: where the model will be positioned in the world coordinate system.
@return: return the object created if succeeded, otherwise return nil.
]]
function ObjEditor.CreatePhysicsObject(sName, Model, x,y,z,bSilentMode, reserved)
	local obj = ObjEditor.GetObject(sName);
	if(obj~=nil) then
		_guihelper.MessageBox(L"Object"..sName..L" already exists. Please use a different name or leave it blank.");
		return nil;
	end
	local obj;
	local asset;
	if(Model ~= nil) then
		if(type(Model) == "string") then
			asset = ParaAsset.LoadStaticMesh("", Model);
		else
			asset = Model;
		end
		if(asset:IsValid()==true) then
			local bUsePhysics = true;
			-- decide whether to use physics from the file name
			local sFileName = asset:GetKeyName();
			local nLen = string.len(sFileName);
			if(nLen>4 and string.sub(sFileName, nLen-3, nLen-2)=="_a") then
				bUsePhysics = false;
			end
			
			if(reserved == nil) then
				obj = ParaScene.CreateMeshPhysicsObject(sName, asset, 1,1,1, bUsePhysics, "1,0,0,0,1,0,0,0,1,0,0,0");
			else
				if(reserved.localMatrix ~= nil) then
					obj = ParaScene.CreateMeshPhysicsObject(sName, asset, 1,1,1, bUsePhysics, reserved.localMatrix);
				else					
					obj = ParaScene.CreateMeshPhysicsObject(sName, asset, 1,1,1, bUsePhysics, "1,0,0,0,1,0,0,0,1,0,0,0");
				end
			end
			
			if(obj:IsValid()==true) then
				obj:SetPosition(x,y,z);
				if(ObjEditor.RandomStaticMeshFacing == true) then
					obj:SetFacing(math.random(0,3.14));
				end
				ParaScene.Attach(obj);
				-- Add object to list and select it as the current object.
				if(bSilentMode~=true) then
					ObjEditor.objects[sName] = obj;
					ObjEditor.SetCurrentObj(obj);
					log("physics object: "..sName.." created\n");
				end	
				return obj;
			else
				_guihelper.MessageBox("unable to create mesh physics object\n");
			end
		else
			if(type(Model) == "string") then
				_guihelper.MessageBox("unable to create mesh physics object\nBecause mesh file: "..Model.." not found.");
			else
				_guihelper.MessageBox("unable to create mesh physics object\nBecause mesh file is invalid");
			end
		end
	end
	return nil;
end

--[[ create mesh objects, such as grass, that does not contain physics.]]
function ObjEditor.CreateMesh(sName, Model, x,y,z)
	--TODO:
end

--[[ load file
@param filename:string: name of the file from which objects are loaded. In this version.	
	the name is always appended with "temp/" and so it is with the managed loader name in the file.
]]
function ObjEditor.load(filename_)
	local filename = "(gl)temp/"..filename_;
	NPL.load(filename);
end
--[[save scene to disk. Once saved, the object list will be emptied.
@param filename:string: name of the file to which objects are saved. In this version.	
	the name is always appended with "temp/" and so it is with the managed loader name
]]
function ObjEditor.save(filename_)
	-- "only save to temp directory to prevent overriden useful data"
	local filename = "temp/"..filename_;
	local bFileBackuped = false;
	if (ParaIO.BackupFile(filename) == true) then
		bFileBackuped = true;
	end
	if (ParaIO.CreateNewFile(filename) == false) then
		local err = "Failed creating managed loader file: "..filename.."\n";
		log(err);
		_guihelper.MessageBox(err);
		return;
	end
	-- manager loader header 
	local sScript = string.format([[local sceneLoader = ParaScene.GetObject("<managed_loader>%s");
if (sceneLoader:IsValid() == true) then 
	ParaScene.Attach(sceneLoader);
else 
   sceneLoader = ParaScene.CreateManagedLoader("%s");
   local asset,player;
]], filename, filename);
	ParaIO.WriteString(sScript);

	-- add objects
	local key, obj;
	for key, obj in pairs(ObjEditor.objects) do
		if(obj:IsValid()==true) then
			ParaIO.WriteString("--"..obj.name.."\n");
			-- create in managed Loader
			ParaIO.WriteString(obj:ToString("loader"));
		end
	end
	
	-- manager loader ending
	ParaIO.WriteString([[
	ParaScene.Attach(sceneLoader);
end]]);

	ParaIO.CloseFile();
	sScript = L"Scene file: \n"..filename..L"successfully saved.\n";
	if(bFileBackuped==true) then
		sScript = sScript..L"file has been overwritten after back up";
	end
	_guihelper.MessageBox(sScript);
	log(sScript);
end


--[[ offset a specified object by a specifed amount.
@param obj: the ParaObject to move, if this is nil, the current selected object will be moved.
]]
function ObjEditor.OffsetObj(obj,dx,dy,dz)
	if(obj == nil) then 
		obj = ObjEditor.GetCurrentObj();
	end
	if(obj ~= nil and obj:IsValid()==true) then 
		if(obj:IsGlobal()==false) then -- we only allow non-global objects to be moved by function. Global objects should be moved by taking control of it or giving movement commands.
			local x,y,z = obj:GetPosition();
			obj:SetPosition(x+dx,y+dy,z+dz);
			ParaScene.Attach(obj);
		end
	end
end

--[[ rotate a specified object by a specifed amount.
@param obj: the ParaObject to rotate, if this is nil, the current selected object will be moved.
@param dx,dy,dz: rotation around the x,y,z axis in rads.
]]
function ObjEditor.RotateObj(obj,dx,dy,dz)
	if(obj == nil) then 
		obj = ObjEditor.GetCurrentObj();
	end
	if(obj ~= nil and obj:IsValid()==true) then 
		obj:Rotate(dx,dy,dz);
		if(obj:IsCharacter()==false) then -- character does not have physics, so does not reattach it to the scene.
			ParaScene.Attach(obj);
		end
	end
end

--[[ Scale a specified object by a specifed amount.
@param obj: the ParaObject to rotate, if this is nil, the current selected object will be moved.
@param dx,dy,dz: rotation around the x,y,z axis in rads.
]]
function ObjEditor.ScaleObj(obj,s)
	if(obj == nil) then
		obj = ObjEditor.GetCurrentObj();
	end
	if(obj ~= nil and obj:IsValid()==true) then 
		obj:SetScaling(s);
		if(obj:IsCharacter() == false) then -- character does not have physics, so does not reattach it to the scene.
			ParaScene.Attach(obj);
		end
	end
end

-- return x,y,z: transform from camera space to world space, only for x,z.
function ObjEditor.CameraToWorldSpace(dx,dy,dz)
	local camx,camy,camz = ParaCamera.GetPosition();
	local x,y,z = ParaCamera.GetLookAtPosition();
	local cz = z-camz;
	local cx = x - camx;
	local cr = math.sqrt(cx*cx+cz*cz);
	local ds = math.sqrt(dx*dx+dz*dz);
	if(dr~=0 and ds~=0) then
		local sinC = -(cx/cr);
		local cosC = (cz/cr);
		local sinR = (dz/ds);
		local cosR = (dx/ds);
		dx = (cosR*cosC-sinR*sinC)*ds;
		dz = (sinR*cosC+cosR*sinC)*ds;
	end
	return dx,dy,dz;
end

--[[ offset object relative to the current camera position and orientation
@param obj: the ParaObject to move, if this is nil, the current selected object will be moved.
]]
function ObjEditor.offsetByCamera(obj,dx,dy,dz)
	if(obj == nil) then 
		obj = ObjEditor.GetCurrentObj();
	end
	if(obj ~= nil and obj:IsValid()==true) then 
		ObjEditor.OffsetObj(obj,ObjEditor.CameraToWorldSpace(dx,dy,dz));
	end
end

-- offset the current object 
function ObjEditor.MoveCurrentObj(dx,dy,dz)
	local obj = ObjEditor.GetCurrentObj();
	if(obj~=nil) then
		ObjEditor.offsetByCamera(obj, dx,dy,dz);
	end
end

--[[ rotate the current object by a specified degrees around an axis. 
@param dx,dy,dz: rotation in rads around x,y,z axis]]
function ObjEditor.RotateCurrentObj(dx,dy,dz)
	local obj = ObjEditor.GetCurrentObj();
	if(obj~=nil) then
		ObjEditor.RotateObj(obj, dx,dy,dz);
	end
end

--[[ scale the current object ]]
function ObjEditor.ScaleCurrentObj(dS)
	local obj = ObjEditor.GetCurrentObj();
	if(obj~=nil) then
		ObjEditor.ScaleObj(obj, dS);
	end
end

-- turn on/off physics object
function ObjEditor.EnablePhysics(bEnable)
	local obj = ObjEditor.GetCurrentObj();
	if(obj ~= nil and obj:IsValid()==true) then 
		obj:EnablePhysics(bEnable);
	end
end

-- reset object
function ObjEditor.ResetCurrentObj()
	local obj = ObjEditor.GetCurrentObj();
	if(obj ~= nil and obj:IsValid()==true) then 
		obj:Reset();
		if(obj:IsCharacter()==false) then -- character does not have physics, so does not reattach it to the scene.
			ParaScene.Attach(obj);
		end
	end
end

--[[ show and update the property of the current object
@param obj: if nil, the current object is used 
@param bShow: true to hide property window
]]
function ObjEditor.ShowObjProperty(obj, bShow)
	if(not obj) then
		obj = ObjEditor.GetCurrentObj();
	end
	
	if(obj ~= nil and obj:IsValid()==true) then 
		local ctlProperty = CommonCtrl.GetControl("propertyDlg");
		if(ctlProperty == nil) then
			ctlProperty = CommonCtrl.CCtrlProperty:new();--{binding = obj, name = "propertyDlg"};
			ctlProperty.name = "propertyDlg";
			ctlProperty.binding = obj;
		else
			ctlProperty:DataBind(obj);
		end
		if(bShow~=nil) then
			ctlProperty:Show(bShow);
		end
	end
end

--[[ unbind the current object from the object property control]]
function ObjEditor.UnbindObjProperty()
	local ctlProperty = CommonCtrl.GetControl("propertyDlg");
	if(ctlProperty ~= nil) then
		ctlProperty:DeleteBinding();
	end
end

function ObjEditor.GetCurrentCategoryName()
	return ObjEditor.assets[ObjEditor.CurrentAssetIndex].name;	
end

-- @obsoleted: use CreateObjectByParam
--automatically create a new object by a file path name
-- pos: {x,y,z} position, if nil, the current player position is used. 
-- sCategoryName: this can be nil, where the current name is used. Otherwise it could be "人物", "地形","脚本","灯光" or anything else.
-- bSlientMode: if this is nil or false, no effect will be used and the created object is not selected. 
-- If true, there is missle firing to the target and that it is automatically selected as the target.
function ObjEditor.AutoCreateObject(ObjName, FilePath, pos, sCategoryName, bSilentMode, reserved)
	ObjEditor.objectCounter = ObjEditor.objectCounter + 1;
	-- create a specified object
	local player = ParaScene.GetObject("<player>");
	local x,y,z = player:GetPosition();
	if(pos ~= nil) then
		x,y,z = pos[1], pos[2], pos[3];
	end
	
	local bCanCreate = true;
	if(bSilentMode~=true and ObjEditor.LastCreatedModelPath == FilePath) then
		if((math.abs(ObjEditor.LastCreatePos.x - x)+math.abs(ObjEditor.LastCreatePos.y - y)+math.abs(ObjEditor.LastCreatePos.z - z))<ObjEditor.MIN_OBJ_DIST) then
			bCanCreate =false;
			_guihelper.MessageBox(L"==distance too close==\nYou can not create the same object at the same location twice");
		end
	end
	
	if(bCanCreate == true) then
		local obj=nil;
		if(sCategoryName == nil) then
			sCategoryName = ObjEditor.GetCurrentCategoryName();
		end
		if(sCategoryName == "人物") then
			-- create a global character model for testing only
			local asset = ParaAsset.LoadParaX("", FilePath);
			if((asset == nil) or (asset:IsValid()==false))then
				_guihelper.MessageBox(L"Model does not exist:\r\n"..FilePath); 
				return;
			end
			obj = ParaScene.CreateCharacter(ObjName..ObjEditor.objectCounter, asset, "", true, 0.35, player:GetFacing(), 1);
			obj:SetPersistent(true);
			obj:SetPosition(x, y, z);
			ParaScene.Attach(obj);
		elseif(sCategoryName == "地形" or sCategoryName == "脚本" or sCategoryName == "灯光") then
			local nLen = string.len(FilePath);
			local fileExtension = string.sub(FilePath, nLen-2);
			if(fileExtension == "lua") then
				-- for script objects: activate it
				NPL.activate("(gl)"..FilePath, string.format("sensor_name=%s",ObjName..ObjEditor.objectCounter));
			elseif(fileExtension == "raw") then
				-- for raw elevation file: apply height field
				TerrainEditorUI.AddHeightField(FilePath);
			end
			
			if(bSilentMode~=true) then
				ObjEditor.LastCreatedModelPath = FilePath;
				ObjEditor.LastCreatedModelName = ObjName;
				ObjEditor.LastCreatePos.x = x;
				ObjEditor.LastCreatePos.y = y;
				ObjEditor.LastCreatePos.z = z;
			end	
		else
			-- create static model 
			if(reserved ~= nil) then
				if(reserved.localMatrix ~= nil) then
					-- use local matrix
					obj = ObjEditor.CreatePhysicsObject(ObjName..ObjEditor.objectCounter, FilePath, x,y,z,bSilentMode, reserved);
				end
			else
				obj = ObjEditor.CreatePhysicsObject(ObjName..ObjEditor.objectCounter, FilePath, x,y,z,bSilentMode);
			end
		end
		
		if(obj~=nil and obj:IsValid()==true) then
			if(bSilentMode~=true) then
				-- Fire a missile to indicate the creation of the object
				-- using missile type 2, with a speed of 1.5
				ParaScene.FireMissile(2, 1.5, x,y+1,z, x,y,z);
				ObjEditor.LastCreatedModelPath = FilePath;
				ObjEditor.LastCreatedModelName = ObjName;
				ObjEditor.LastCreatePos.x = x;
				ObjEditor.LastCreatePos.y = y;
				ObjEditor.LastCreatePos.z = z;
			end	
			return obj;
		end
	end
end

--pos: can be {x,y,z} or nil
function ObjEditor.CreateLastObject(pos)
	if(ObjEditor.LastCreatedModelPath ~= "") then
		ObjEditor.AutoCreateObject(ObjEditor.LastCreatedModelName, ObjEditor.LastCreatedModelPath,pos);
	end
end

-- save all scene objects as well as the scene itself in the current player's terrain location.
function ObjEditor.SaveNearPlayer()
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid()==true) then
		local x,y,z = player:GetPosition();
		local OnloadScript = ParaTerrain.GetTerrainOnloadScript(x,z);
		if(OnloadScript ~= "") then
			ObjEditor.save(OnloadScript);	
		else
			ObjEditor.save("DefaultManagedLoader.lua");
		end
	end
end

-- load from disk file.
function ObjEditor.LoadNearPlayer()
	local player = ParaScene.GetObject("<player>");
	if(player:IsValid()==true) then
		local x,y,z = player:GetPosition();
		local OnloadScript = ParaTerrain.GetTerrainOnloadScript(x,z);
		if(OnloadScript ~= "") then
			ObjEditor.load(OnloadScript);	
			_guihelper.MessageBox("temp/"..OnloadScript..L" \nhas already been loaded.");
		else
			_guihelper.MessageBox(L"OnLoadScript is not found");
		end
	end
end

-- select an existing object by name, and fire a missle to it.
function ObjEditor.SelObjectByName(objectname)
	local obj = ObjEditor.SelectObj(objectname);
	-- Fire a missile from the current player to the selected object.
	local player = ParaScene.GetObject("<player>");
	if(obj~=nil and player:IsValid()==true) then
		local fromX, fromY, fromZ = player:GetPosition();
		fromY = fromY+1.0;
		local toX, toY, toZ = obj:GetViewCenter();
		-- using missile type 2, with a speed of 5.0
		ParaScene.FireMissile(2, 5, fromX, fromY, fromZ, toX, toY, toZ);
		return true;
	end
end

-- Remove an current object from the list, but not from the scene.
function ObjEditor.RemoveSelectedObject()
	local obj = ObjEditor.GetCurrentObj();
	if(obj~=nil) then 
		-- remove from object
		if(ObjEditor.RemoveObject(obj.name) ~= nil) then 
			ObjEditor.SetCurrentObj(nil);
			_guihelper.MessageBox(L"Object has been removed from the list, but is not deleted");
			return true;
		else
			_guihelper.MessageBox(L"Object is not in the list");
		end
	end
end

-- safe delete the given object 
-- return true if succeeded.
function ObjEditor.DelObject(obj)
	if(obj~=nil) then
		-- TODO: we should only unbind, if the deleted object is the current object
		local curObj = ObjEditor.GetCurrentObj();
		if(curObj~=nil and curObj:equals(obj) == true) then
			ObjEditor.SetCurrentObj(nil);
		end
		ObjEditor.RemoveObject(obj.name);
		ObjEditor.UnbindObjProperty();
		if(obj:IsCharacter() ==true and obj:IsGlobal() == true) then
			local NextPlayer = ParaScene.GetNextObject(obj);
			if(NextPlayer:IsValid() == true) then
				if(_movie~=nil) then
					_movie.DeleteActor(obj.name);
				end	
				ParaScene.Delete(obj);
				--_guihelper.MessageBox(L"character has been removed from the scene");
				return true;
			else
				_guihelper.MessageBox(L"There is only one character left in the scene; you can not delete it.");
			end
		else
			ParaScene.Delete(obj);
			--_guihelper.MessageBox(L"object has been removed from the scene");
			return true;
		end
	else
		_guihelper.MessageBox(L"Object does not exist");
	end
end

-- delete an object from the scene
-- return true if succeeded.
function ObjEditor.DelSeletedObject()
	local obj = ObjEditor.GetCurrentObj();
	return ObjEditor.DelObject(obj);
end
