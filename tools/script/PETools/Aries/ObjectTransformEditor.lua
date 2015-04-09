--[[
Title: for editing position, facing, rotation,scaling using ingame gizmo. 
Author(s): LiXizhi
Date: 2010/9/23
Desc: In future, we should support mini-scenegraph based in-game gizmo with accurate physics picking. 
Right now, we will just a mcml ui for manual input. This is mostly only used for quotanion based rotation, 
since other data types can be easily entered in the ide. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/PETools/Aries/ObjectTransformEditor.lua");
local ds = {
	position={1,2,3}, 
	rotation={x=0,y=0,z=0,w=1}
};
MyCompany.PETools.Editors.ObjectTransformEditor.ShowPage(ds);

-- or it can be called from PETools entity like below, where the entity must define property for position and rotation using the same data type. 
MyCompany.PETools.Editors.ObjectTransformEditor.ShowForEditorInstance(instance)
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/mathlib.lua");
NPL.load("(gl)script/ide/Display3D/SceneCanvas.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");

local ObjectTransformEditor = commonlib.gettable("MyCompany.PETools.Editors.ObjectTransformEditor");

-- the current data source
local instance_ds = {
	{name="position", attr={x="0",y="0",z="0", is_enabled=true}},
	{name="rotation", attr={x="0",y="0",z="0", w="1", rot_x="0", rot_y="0",rot_z="0",is_enabled=true}},
};

-- the mini_scene to display instances
local mini_scene = nil;
local mini_scene_name = "ObjectTransformEditor"
local page;
function ObjectTransformEditor.Init()
	page = document:GetPageCtrl();
end

-- create/get the mini scene
local function GetMiniScene()
	if(mini_scene) then
		return mini_scene;
	else
		mini_scene = {};
		mini_scene.scene = CommonCtrl.Display3D.SceneManager:new({uid=mini_scene_name, type = "miniscene"});
		mini_scene.rootNode = CommonCtrl.Display3D.SceneNode:new{
				root_scene = mini_scene.scene,
				visible = true,
			};
		return mini_scene;
	end
end


-- @param data_source: it should be a table array, where each item is {position="0,0,0", facing=0, scaling=10}
-- if nil, it will just show up the window
function ObjectTransformEditor.ShowPage(data_source)
	local params = {
			url = "script/PETools/Aries/ObjectTransformEditor.html", 
			text = "Transforms Editor",
			name = "PETools.ObjectTransformEditor", 
			isShowTitleBar = true,
			DestroyOnClose = false, 
			--style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
				align = "_rt",
				x = -180-5,
				y = 50,
				width = 180,
				height = 370,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	params._page.OnClose = function()
		-- delete mini scene graph when page is closed. 
		ObjectTransformEditor.editor_instance = nil;
		ObjectTransformEditor.name = nil;
		ObjectTransformEditor.SetDataSource({}, false);	
		ObjectTransformEditor.RefreshMiniScene();
	end
	ObjectTransformEditor.SetDataSource(data_source, false);
	ObjectTransformEditor.RefreshPage()
end

-- @param instance:  this is special data source type from NPC.entity.xml used by NPCList in Aries. 
function ObjectTransformEditor.ShowForEditorInstance(instance)
	if(type(instance.position) == "table" and instance.position[1]) then
		local ds = {}; 
		ds.position = {instance.position[1], instance.position[2], instance.position[3]}
		if(type(instance.rotation) == "table" and instance.rotation.w) then
			ds.rotation = {x = instance.rotation.x, y = instance.rotation.y, z = instance.rotation.z, w = instance.rotation.w, }
		end
		ObjectTransformEditor.name = instance.name;
		ObjectTransformEditor.editor_instance = instance;
		ObjectTransformEditor.ShowPage(ds);
	end
end

-- this function is called whenever the user modified the data source via our editor,
-- we can inform the data source here.
function ObjectTransformEditor.OnDataChanged()
	if(ObjectTransformEditor.editor_instance) then
		if(instance_ds[1].attr.is_enabled) then
			local pos = instance_ds[1].attr;
			local x,y,z = tonumber(pos.x), tonumber(pos.y), tonumber(pos.z);
			ObjectTransformEditor.editor_instance:SetValue("position", {x, y, z});
		end
		if(instance_ds[2].attr.is_enabled) then
			local rot = instance_ds[2].attr;
			local x,y,z,w = tonumber(rot.x), tonumber(rot.y), tonumber(rot.z), tonumber(rot.w);
			ObjectTransformEditor.editor_instance:SetValue("rotation", {x=x, y=y, z=z, w=w});
		else
			ObjectTransformEditor.editor_instance:SetValue("rotation", nil);
		end
	else
		-- TODO: update the original data source?
	end
end

function ObjectTransformEditor.GetDataSource()
	return instance_ds;
end

function ObjectTransformEditor.RefreshPage(delay_time)
	if(page) then
		page:Refresh(delay_time or 0);
		ObjectTransformEditor.RefreshMiniScene();
	end
end

-- TODO: we may display some 3D helper objects in future. 
-- rebuild all miniscene graph
function ObjectTransformEditor.RefreshMiniScene()
end

-- Internally it will make a copy of the input data source. 
-- @param data_source: it should be a table array, where each item is {position="0,0,0", facing=0, scaling=10}
-- @param bRefreshUI: true to refresh UI. 
function ObjectTransformEditor.SetDataSource(data_source, bRefreshUI)
	if(data_source) then
		local attr = instance_ds[1].attr;
		if(data_source.position and data_source.position[1]) then
			attr.is_enabled = true;
			attr.x = tostring(data_source.position[1]);
			attr.y = tostring(data_source.position[2]);
			attr.z = tostring(data_source.position[3]);
		else
			attr.is_enabled = false;
		end

		local attr = instance_ds[2].attr;
		if(data_source.rotation and data_source.rotation.w) then
			attr.is_enabled = true;
			attr.x = tostring(data_source.rotation.x);
			attr.y = tostring(data_source.rotation.y);
			attr.z = tostring(data_source.rotation.z);
			attr.w = tostring(data_source.rotation.w);
			local rot_x, rot_y, rot_z = mathlib.QuatToEuler(data_source.rotation) 
			attr.rot_x = tostring(rot_x);
			attr.rot_y = tostring(rot_y);
			attr.rot_z = tostring(rot_z);
		else
			attr.is_enabled = false;
		end
	end
	if(bRefreshUI and page) then
		ObjectTransformEditor.RefreshPage()
	end
end

function ObjectTransformEditor.OnClickUsePosition(bChecked)
	_guihelper.MessageBox("position must always be specified.");
end

-- whether we will use rotation instead of facing. 
function ObjectTransformEditor.OnClickUseRotation(bChecked)
	if(ObjectTransformEditor.editor_instance) then
		if(instance_ds[2].attr.is_enabled ~= bChecked) then
			instance_ds[2].attr.is_enabled = bChecked;
			-- update data source. 
			ObjectTransformEditor.OnDataChanged();
		end
	end
end

-- assign current player position to the position
function ObjectTransformEditor.UseCurrentPosition()
	local attr = instance_ds[1].attr;
	local x,y,z = ParaScene.GetPlayer():GetPosition();
	attr.x,attr.y,attr.z = tostring(x), tostring(y), tostring(z);
	ObjectTransformEditor.RefreshPage();
	ObjectTransformEditor.OnDataChanged();
end

function ObjectTransformEditor.UpdateQuatFromRot()
	local attr = instance_ds[2].attr;
	local x,y,z,w = mathlib.EulerToQuat(tonumber(attr.rot_x), tonumber(attr.rot_y), tonumber(attr.rot_z));
	attr.x = tostring(x);
	attr.y = tostring(y);
	attr.z = tostring(z);
	attr.w = tostring(w);
end

function ObjectTransformEditor.OnChangeRotX(value)
	local attr = instance_ds[2].attr;
	attr.rot_x = tostring(value);
	ObjectTransformEditor.UpdateQuatFromRot();
	
	-- update data source. 
	ObjectTransformEditor.OnDataChanged();
end
function ObjectTransformEditor.OnChangeRotY(value)
	local attr = instance_ds[2].attr;
	attr.rot_y = tostring(value);
	ObjectTransformEditor.UpdateQuatFromRot();
	
	-- update data source. 
	ObjectTransformEditor.OnDataChanged();
end
function ObjectTransformEditor.OnChangeRotZ(value)
	local attr = instance_ds[2].attr;
	attr.rot_z = tostring(value);
	ObjectTransformEditor.UpdateQuatFromRot();

	-- update data source. 
	ObjectTransformEditor.OnDataChanged();
end

-- reset rotation to nil
function ObjectTransformEditor.ResetRotation()
	local attr = instance_ds[2].attr;
	attr.x,attr.y,attr.z,attr.w = "0", "0", "0", "1";
	attr.rot_x, attr.rot_y, attr.rot_z = "0", "0", "0";
	
	ObjectTransformEditor.OnDataChanged();
	ObjectTransformEditor.RefreshPage();
end

