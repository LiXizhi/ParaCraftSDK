--[[
Title: for editing a collection of instance positions. 
Author(s): LiXizhi
Date: 2010/9/18
Desc: used by NPC.entity and GameObject.entity, for there instance collections.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/PETools/Aries/ObjectInstancesEditor.lua");
local ds = {
	{position="0,0,0", facing=0, scaling=10},
	{position="1,0,0", facing="2", scaling="1"},
	{position="2,0,0", facing="2", scaling="1"},
	{position="3,0,0", facing="2", scaling="1"},
}
MyCompany.PETools.Editors.ObjectInstancesEditor.ShowPage(ds);
-- or it can be called from PETools entity like below, where the entity must define some of the following propertes:
--  "copies:number, positions:pos array, facings(optional):number array, scalings(optional):number array"
MyCompany.PETools.Editors.ObjectInstancesEditor.ShowForEditorInstance(instance)
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display3D/SceneCanvas.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");

local ObjectInstancesEditor = commonlib.gettable("MyCompany.PETools.Editors.ObjectInstancesEditor");

-- the current data source
local instance_ds = {};

-- the mini_scene to display instances
local mini_scene = nil;
local mini_scene_name = "ObjectInstancesEditor"
local page;
function ObjectInstancesEditor.Init()
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
function ObjectInstancesEditor.ShowPage(data_source)
	local params = {
			url = "script/PETools/Aries/ObjectInstancesEditor.html", 
			text = "Object Instances Editor",
			name = "PETools.ObjectInstancesEditor", 
			isShowTitleBar = true,
			DestroyOnClose = false, 
			--style = CommonCtrl.WindowFrame.ContainerStyle,
			allowDrag = true,
			directPosition = true,
				align = "_lt",
				x = 5,
				y = 50,
				width = 260,
				height = 410,
	};
	System.App.Commands.Call("File.MCMLWindowFrame", params);
	params._page.OnClose = function()
		-- delete mini scene graph when page is closed. 
		ObjectInstancesEditor.editor_instance = nil;
		ObjectInstancesEditor.name = nil;
		ObjectInstancesEditor.SetDataSource({}, false);	
		ObjectInstancesEditor.RefreshMiniScene();
	end

	ObjectInstancesEditor.SetDataSource(data_source, false);
	ObjectInstancesEditor.RefreshPage()
end

-- @param instance:  this is special data source type from NPC.entity.xml used by NPCList in Aries. 
function ObjectInstancesEditor.ShowForEditorInstance(instance)
	if(instance.copies) then
		local ds = {}; 
		local i;
		for i=1, instance.copies do
			local position, facing, scaling
			if(instance.positions and instance.positions[i]) then
				position = table.concat(instance.positions[i], ",")
			end
			if(instance.facings) then
				facing = tonumber(instance.facings[i])
			end
			if(instance.scalings) then
				scaling = tonumber(instance.scalings[i])
			end
			ds[#ds+1] = {position = position, facing=facing, scaling=scaling}
		end
		ObjectInstancesEditor.name = instance.name;
		ObjectInstancesEditor.editor_instance = instance;
		ObjectInstancesEditor.ShowPage(ds);
	end
end

-- this function is called whenever the user modified the data source via our editor,
-- we can inform the data source here.
function ObjectInstancesEditor.OnDataChanged()
	if(ObjectInstancesEditor.editor_instance) then
		local positions = {};
		local facings = {};
		local scalings = {};

		local copy_count = #instance_ds;
		local index, instance
		for index, instance in ipairs(instance_ds) do
			local x,y,z = instance.attr.position:match("([^,]+),([^,]+),([^,]+)");
			x = tonumber(x);
			y = tonumber(y);
			z = tonumber(z);
			local facing = tonumber(instance.attr.facing);
			local scaling = tonumber(instance.attr.scaling);
			positions[#positions+1] = {x,y,z};
			facings[#facings+1] = facing;
			scalings[#scalings+1] = scaling;
		end
		ObjectInstancesEditor.editor_instance:SetValue("copies", copy_count);
		ObjectInstancesEditor.editor_instance:SetValue("positions", positions);
		ObjectInstancesEditor.editor_instance:SetValue("facings", facings);
		if(ObjectInstancesEditor.editor_instance.scalings) then
			ObjectInstancesEditor.editor_instance:SetValue("scalings", scalings);
		end
	end
end


function ObjectInstancesEditor.GetDataSource()
	return instance_ds;
end

function ObjectInstancesEditor.RefreshPage()
	if(page) then
		page:Refresh(0);
		ObjectInstancesEditor.RefreshMiniScene();
	end
end

local gotoCmd = {name="goto"}
local useCurPosCmd = {name="set_current"}

-- append a node to the data source 
-- @param position: string "0,0,0"
-- @param facing: number or string
-- @param scaling: number or string
function ObjectInstancesEditor.AppendNode(position, facing, scaling)
	local index = #instance_ds+1;
	local attr = {
		index=index, position=tostring(position or ""), 
		facing=tostring(facing or 0), 
		scaling=tostring(scaling or 1),
	};
	instance_ds[index] = {name="instance", attr=attr, gotoCmd, useCurPosCmd, {name="view", attr=attr}};
end

function ObjectInstancesEditor.OnClickInstance(treenode)
	local index = treenode.mcmlNode:GetPreValue("this").index;
	if(index) then
		if(ObjectInstancesEditor.selected_index ~= index) then
			ObjectInstancesEditor.selected_index = index;
			-- ObjectInstancesEditor.RefreshMiniScene();
		end
	end
end

-- rebuild all miniscene graph
function ObjectInstancesEditor.RefreshMiniScene()
	local miniscene = GetMiniScene();
	miniscene.rootNode:ClearAllChildren();
	local index, instance
	for index, instance in ipairs(instance_ds) do
		local x,y,z = instance.attr.position:match("([^,]+),([^,]+),([^,]+)");
		x = tonumber(x);
		y = tonumber(y);
		z = tonumber(z);
		local facing = tonumber(instance.attr.facing);
		if(x and y and z) then
			if(ObjectInstancesEditor.selected_index == index) then
				-- current selected 
				-- TODO: shall we display something differently?
			end
			local node = CommonCtrl.Display3D.SceneNode:new{
				x = x,
				y = y,
				z = z,
				headontext = format("%s_%d", ObjectInstancesEditor.name or "instance", index),
				headontextcolor = "0 255 0",
				facing = facing, 
				ischaracter = true,
				-- assetfile = "character/v5/06quest/DisorderRobot/DisorderRobot.x",
				assetfile = "character/common/tutorial_pointer/tutorial_pointer.x",
			};
			miniscene.rootNode:AddChild(node);
		end
	end
end

-- Internally it will make a copy of the input data source. 
-- @param data_source: it should be a table array, where each item is {position="0,0,0", facing=0, scaling=10}
-- @param bRefreshUI: true to refresh UI. 
function ObjectInstancesEditor.SetDataSource(data_source, bRefreshUI)
	if(data_source) then
		instance_ds = {};
		local _, instance;
		for _, instance in ipairs(data_source) do
			if(instance.position) then
				ObjectInstancesEditor.AppendNode(instance.position, instance.facing, instance.scaling);
			end
		end
		ObjectInstancesEditor.selected_index = nil;
	end
	if(bRefreshUI and page) then
		ObjectInstancesEditor.RefreshPage()
	end
end

-- goto the selected node
function ObjectInstancesEditor.GotoNode(treenode)
	local index = treenode.mcmlNode:GetParent():GetPreValue("this").index;
	if(index and instance_ds[index]) then
		local instance = instance_ds[index];
		if(instance and instance.attr.position) then
			local x,y,z = instance.attr.position:match("([^,]+),([^,]+),([^,]+)");
			x = tonumber(x);
			y = tonumber(y);
			z = tonumber(z);
			local facing = tonumber(instance.attr.facing);
			if(x and y and z) then
				local player = ParaScene.GetPlayer();
				player:SetPosition(x,y,z);
				if(facing) then
					player:SetFacing(facing);
				end
			end
		end
	end
end

-- assign current player position to the selected node. 
function ObjectInstancesEditor.UserCurrentPosition(treenode)
	local index = treenode.mcmlNode:GetParent():GetPreValue("this").index;
	if(index and instance_ds[index]) then
		local instance = instance_ds[index];
		local player = ParaScene.GetPlayer();
		local x,y,z = player:GetPosition();
		local facing = player:GetFacing();
		instance.attr.position = string.format("%.3f,%.3f,%.3f", x,y,z)
		instance.attr.facing = string.format("%.2f", facing)
		ObjectInstancesEditor.RefreshPage()
		ObjectInstancesEditor.OnDataChanged();
	else
		_guihelper.MessageBox("Please select a node first")
	end
end

function ObjectInstancesEditor.AddInstance()
	local player = ParaScene.GetPlayer();
    local x,y,z = player:GetPosition();
    local facing = player:GetFacing();
	ObjectInstancesEditor.AppendNode(string.format("%.3f,%.3f,%.3f", x,y,z), string.format("%.2f", facing), 1);
	ObjectInstancesEditor.RefreshPage()
	ObjectInstancesEditor.OnDataChanged();
end

function ObjectInstancesEditor.RemoveInstance()
	local treeViewCtrl = page:FindControl("tvwObjInstances");
	if(treeViewCtrl and treeViewCtrl.SelectedNode and treeViewCtrl.SelectedNode.mcmlNode) then	
		local mcmlNode = treeViewCtrl.SelectedNode.mcmlNode;
		local index = mcmlNode:GetPreValue("this").index;
		if(index) then
			local k;
			local t = instance_ds;
			local nSize = #(t);
			for k=index, nSize do
				t[k] = t[k+1];
				if(t[k]) then
					t[k].attr.index = k;
				end
			end
		end
		-- _guihelper.MessageBox({mcmlNode:GetPreValue("this"), mcmlNode.attr});
		ObjectInstancesEditor.RefreshPage()
		ObjectInstancesEditor.OnDataChanged()
	else
		_guihelper.MessageBox("Please select a node first")
	end
end