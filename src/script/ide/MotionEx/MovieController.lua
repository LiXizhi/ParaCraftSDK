--[[
Title: MovieController
Author(s): Leio
Date: 2011/03/08
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MovieController.lua");
local MovieController = commonlib.gettable("MotionEx.MovieController")
if(not MovieController.controller)then
	MovieController.controller = MovieController:new({
		movie_xml_file = "script/ide/MotionEx/Movie.xml",
	});
end

MovieController.controller:Play();
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
NPL.load("(gl)script/ide/MotionEx/MotionLine.lua");
NPL.load("(gl)script/ide/MotionEx/MotionPlayer.lua");
local MotionLine = commonlib.gettable("MotionEx.MotionLine");
local MotionPlayer = commonlib.gettable("MotionEx.MotionPlayer");

local LOG = LOG;
local MovieController = commonlib.inherit({
	movie_xml_file = nil,--电影文件路径
	movie_xmlnodes = nil,--电影文件xml
	scene_list = {},--场景列表
	motion_list = {},--动画列表
	motion_player = nil,--动画播放器

	updatenode_id_entityid_map = {},
}, commonlib.gettable("MotionEx.MovieController"));
function MovieController:ctor()
	local scene = CommonCtrl.Display3D.SceneManager:new{
		--type = "miniscene" --"scene" or "miniscene"
	}	;
	self.scene = scene;
	local rootNode = CommonCtrl.Display3D.SceneNode:new{
		root_scene = scene,
	}
	self.rootNode = rootNode;
	--执行顺序不能变
	self:LoadMovieXml();
	self:BuildAssets();
	self:BuildScenes();
	self:BuildMotions();
	self.motion_player = MotionPlayer:new();
end
--加载电影文件
function MovieController:LoadMovieXml()
	if(self.movie_xml_file)then
		self.movie_xmlnodes = ParaXML.LuaXML_ParseFile(self.movie_xml_file);
	end
end
--创建所有的资源
function MovieController:BuildAssets()
	if(self.movie_xmlnodes)then
		local node;
		for node in commonlib.XPath.eachNode(self.movie_xmlnodes, "/Movie/Assets/Model") do
			local id = node.attr.id;
			local x = tonumber(node.attr.x) or 250;
			local y = tonumber(node.attr.y) or 0;
			local z = tonumber(node.attr.z) or 250;
			local facing = tonumber(node.attr.facing) or 0;
			local scaling = tonumber(node.attr.scaling) or 1;
			local visible = true;
			local ischaracter = false;
			local assetfile = node.attr.assetfile;
			if(not assetfile or assetfile == "")then
				assetfile = "model/06props/v5/01stone/EvngrayRock/EvngrayRock01.x";
			end
			local node_1 = CommonCtrl.Display3D.SceneNode:new{
				uid = id,
				x = x,
				y = y,
				z = z,
				facing = facing,
				scaling = sacling,
				visible = visible,
				ischaracter = ischaracter,
				assetfile = assetfile,
			};
			self.rootNode:AddChild(node_1);
			MovieController.updatenode_id_entityid_map[id] = node_1:GetEntityID();
			commonlib.echo(MovieController.updatenode_id_entityid_map);
		end
	end
end
--生成所有的电影场景
function MovieController:BuildScenes()
	if(self.movie_xmlnodes)then
		local node;
		for node in commonlib.XPath.eachNode(self.movie_xmlnodes, "/Movie/Scenes/Scene") do
			local motionid = node.attr.motionid;
			table.insert(self.scene_list,motionid);
		end
	end
end
--生成所有的电影动画
function MovieController:BuildMotions()
	if(self.movie_xmlnodes)then
		local node;
		for node in commonlib.XPath.eachNode(self.movie_xmlnodes, "/Movie/Motions/Motion") do
			local id = node.attr.id;
			local line_node;
			local lines = {};
			for line_node in commonlib.XPath.eachNode(node, "/MotionLine") do
				local motionLine = MotionLine.CreateByXmlNode(line_node);
				if(motionLine)then
					table.insert(lines,motionLine);
				end
			end
			table.insert(self.motion_list,{id = id, lines = lines,});
		end
	end
end

function MovieController:GetMotionByID(id)
	if(not id)then return end
	local k,v;
	for k,v in ipairs(self.motion_list) do
		if(id == v.id)then
			return v.lines;
		end
	end
end
function MovieController:Play(index,continueNext)
	local len = #self.scene_list;
	self.cur_play_scene_index = index or 1;
	if(self.cur_play_scene_index > len)then
		return
	end
	local motionid = self.scene_list[self.cur_play_scene_index];
	local lines = self:GetMotionByID(motionid);
	self.motion_player:Clear();
	self.motion_player:AddMotionLines(lines);
	self.motion_player:Play();

	if(continueNext)then
		self.motion_player:AddEventListener("end",function()
			self.cur_play_scene_index = self.cur_play_scene_index + 1;
			self:Play(self.cur_play_scene_index,continueNext)
		end,{});
	end
end
function MovieController:Stop()
	self.motion_player:Stop();
end