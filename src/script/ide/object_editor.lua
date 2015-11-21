--[[
Title: the object editor for ParaEngine 3D environment development library
Dest: object editing API between NPL and ParaEngine
Author(s): LiXizhi
Date: 2007/10/12
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/object_editor.lua");
------------------------------------------------------------
]]
-- requires:
NPL.load("(gl)script/ide/object_editor_v1.lua"); -- all v1 functions are included
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/ccs.lua"); --TODO: lixizhi 2008.6.12 we shall remove dependency?
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/Main.lua");

local CCS = commonlib.gettable("Map3DSystem.UI.CCS");

--[[ObjEditor library]]
local ObjEditor = commonlib.gettable("ObjEditor");

ObjEditor.objectCounter = 0;

-- get the ParaObject by its params. 
-- @return: it may return nil or invalid object().
function ObjEditor.GetObjectByParams(param)
	if(not param) then return end
	local obj;
	if(param.IsCharacter) then
		if(param.IsGlobal~=false) then
			if(param.name~=nil) then
				obj = ParaScene.GetObject(param.name)
				if(not obj:IsValid()) then
					obj = nil;	
				end
			end	
		else
			-- TODO: how to get local character?
		end
	else
		if(param.ViewBox~=nil) then
			obj = ParaScene.GetObjectByViewBox(param.ViewBox);
			if(not obj:IsValid()) then
				obj = nil;	
			end
		end
	end
	return obj;
end

-- save all parameters of a object to a table. So that we can create a new object with similar or modifed parameters. 
-- @param obj: para object of which the parameters are extracted. 
-- @param o: nil or a table to write the data
-- @return: o or a new table containing the parameter
function ObjEditor.GetObjectParams(obj,param)
	local param = param or {};
	if(obj ~= nil and obj:IsValid()==true) then 
		param.IsCharacter = obj:IsCharacter();
		param.x, param.y, param.z = obj:GetPosition();
		param.name = obj.name;
		param.AssetFile = obj:GetPrimaryAsset():GetKeyName();
		if(param.IsCharacter) then
			param.facing = obj:GetFacing();	
			param.IsGlobal = obj:IsGlobal();
			param.Density = obj:GetDensity();
			param.scaling = obj:GetScale();
			
			local char = obj:ToCharacter();
			param.SkinIndex = char:GetSkin();
			if(param.SkinIndex == 0) then
				param.SkinIndex = nil;
			end
			
			if(char:IsCustomModel()) then
				param.CCSInfoStr = CCS.GetCCSInfoString(obj);
			end
		else
			param.rotation = obj:GetRotation(param.rotation or {})
			param.scaling = obj:GetScale();
			param.facing = obj:GetFacing();	
			param.ViewBox = obj:GetViewBox(param.ViewBox or {});
			if(obj:GetNumReplaceableTextures()>0) then
				param.ReplaceableTextures = param.ReplaceableTextures or {};
				table.resize(param.ReplaceableTextures, obj:GetNumReplaceableTextures()) ;
				local i;
				for i=1, obj:GetNumReplaceableTextures() do
					param.ReplaceableTextures[i] = obj:GetReplaceableTexture(i-1):GetFileName();
				end
			end
			param.EnablePhysics = obj:IsPhysicsEnabled();
		end
	end
	
	return param;
end

--[[ create an object by parameter. But it does NOT attach it to the scene. One need to call ParaScene.Attach(obj); with the returned object.
The error code is in ObjEditor.LastErrorMessage
@param param: paramter of the object. known paramters are given below
param = {
	name,
	AssetFile, -- primary asset file: either string or para asset object.
	x,
	y,
	z,
	IsCharacter, -- can be nil
	CCSInfoStr,	-- can be nil -- added by Andy
	scaling,	-- can be nil
	rotation,   -- can be nil or {x=0,y=0,z=0,w=1} which is rotational quaternion.
	facing,  -- can be nil
	IsGlobal,	-- can be nil
	ViewBox, -- can be nil
	Density,	-- can be nil
	PhysicsRadius, -- can be nil
	
	IsPersistent, -- can be nil
	ReplaceableTextures = {[1] = "filepath"}, -- can be nil
	SkinIndex,  -- can be nil
	localMatrix, -- can be nil
	
	EnablePhysics, -- can be nil, whether physics is enabled for the mesh
	
	-- TODO: Customizable character properties here?
	-- TODO: dynamic properties?
}
@return: the object is returned or nil
]]
function ObjEditor.CreateObjectByParams(param)

	local obj=nil;
	if(param.IsCharacter) then
		-- create a global character model for testing only
		local asset;
		if(type(param.AssetFile) == "string") then
			asset = ParaAsset.LoadParaX("", param.AssetFile);
		else
			asset = param.AssetFile
		end	
		if((asset == nil) or (asset:IsValid()==false))then
			ObjEditor.LastErrorMessage = "Model does not exist:\r\n"; 
			return;
		end
		obj = ParaScene.CreateCharacter(param.name or "", asset, "", true, param.PhysicsRadius or 0.35, param.facing or 0, 1);
		
		-- NOTE by andy: if global object with the name already exists, create a new object with a new name
		-- change the object param.name, otherwise it will refer to the old object
		param.name = obj.name;
		
		obj:SetPersistent((param.IsPersistent==nil or param.IsPersistent==true));
		obj:SetPosition(param.x, param.y, param.z);
		
		if(param.CCSInfoStr ~= nil) then
			-- NOTE by Andy: mount the default CCS information if provided
			CCS.ApplyCCSInfoString(obj, param.CCSInfoStr);
		else
			if(obj:ToCharacter():IsCustomModel() == true) then
				CCS.DefaultAppearance.MountDefaultAppearance(obj);
			end
		end
		
		if(param.ReplaceableTextures) then
			local i, filename;
			for i, filename in pairs(param.ReplaceableTextures) do
				obj:SetReplaceableTexture(i, ParaAsset.LoadTexture("",filename,1));
			end
		end
		
		if(param.Density~=nil) then
			obj:SetDensity(param.Density);
		end
		if(param.facing~=nil) then
			obj:SetFacing(param.facing);
		end
		if(param.scaling~=nil) then
			obj:SetScale(param.scaling);
		end
		if(param.IsGlobal~=nil) then
			obj:MakeGlobal(param.IsGlobal);
		end
		if(param.SkinIndex) then
			obj:ToCharacter():SetSkin(param.SkinIndex);
		end
		if(param.Attribute) then
			obj:SetAttribute(param.Attribute, true);
		end
	else
		-- create static model 
		local asset;
		
		local asset;
		if(type(param.AssetFile) == "string") then
			asset = ParaAsset.LoadStaticMesh("", param.AssetFile);
		else
			asset = param.AssetFile
		end	
		
		if((asset == nil) or (asset:IsValid()==false))then
			ObjEditor.LastErrorMessage = "Model does not exist:\r\n"; 
			return;
		end
		
		local EnablePhysics = true;
		-- decide whether to use physics from the file name
		if(param.EnablePhysics == nil) then
			local sFileName = asset:GetKeyName();
			local nLen = string.len(sFileName);
			if(nLen>4 and string.sub(sFileName, nLen-3, nLen-2)=="_a") then
				EnablePhysics = false;
			end
		else
			EnablePhysics = param.EnablePhysics
		end	
		
		if(not param.localMatrix) then
			obj = ParaScene.CreateMeshPhysicsObject(param.name or "", asset, (param.PhysicsRadius or 1), (param.PhysicsRadius or 1), (param.PhysicsRadius or 1), EnablePhysics, "1,0,0,0,1,0,0,0,1,0,0,0");
		else
			obj = ParaScene.CreateMeshPhysicsObject(param.name or "", asset, (param.PhysicsRadius or 1), (param.PhysicsRadius or 1), (param.PhysicsRadius or 1), EnablePhysics, param.localMatrix);
		end
		
		if(obj:IsValid()) then
			if(param.ReplaceableTextures and obj:GetNumReplaceableTextures()>0) then
				local i;
				for i=1, obj:GetNumReplaceableTextures() do
					local filename = param.ReplaceableTextures[i];
					if(filename and filename~="") then
						obj:SetReplaceableTexture(i-1, ParaAsset.LoadTexture("",filename,1));
					end	
				end
			end
			
			obj:SetPosition(param.x,param.y,param.z);
			if(param.facing~=nil) then
				obj:SetFacing(param.facing);
			end
			if(param.scaling ~= nil) then
				obj:SetScale(param.scaling);
			end
			if(param.rotation ~= nil) then
				obj:SetRotation(param.rotation);
			end
			if(param.Attribute) then
				obj:SetAttribute(param.Attribute, true);
			end
			if(param.IsPersistent == false) then
				obj:SetField("persistent", false); 
			end
		else
			ObjEditor.LastErrorMessage ="unable to create mesh physics object\n";
			return
		end
	end
	return obj;
end