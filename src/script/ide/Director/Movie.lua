--[[
Title: Movie
Author(s): Leio
Date: 2012/05/10
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
local player = Movie.CreateOrGetPlayer("test");
player:AddEventListener("before_play",function(holder,event)
	commonlib.echo("===========before_play");
	local movie_mcmlNode = event.movie_mcmlNode;--数据源 可以动态替换数据
end)
player:AddEventListener("movie_start",function(holder,event)
	commonlib.echo("===========start");
end)
player:AddEventListener("movie_update",function(holder,event)
	commonlib.echo("===========update");
	commonlib.echo(event);
end)
player:AddEventListener("movie_end",function(holder,event)
	commonlib.echo("===========end");
end)
Movie.DoPlay_File("test","config/Aries/StaticMovies/61HaqiTown_teen_Show2.xml");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/ExternalInterface.lua");
NPL.load("(gl)script/ide/Director/MovieClip.lua");
local MovieClip = commonlib.gettable("Director.MovieClip");
local Movie = commonlib.gettable("Director.Movie");
Movie.mini_scene_motion_name = "Movie_mini_scene_motion_name"
Movie.is_edit_mode = false

Movie.player_map= {};
function Movie.ClearGraph()
	local effectGraph = ParaScene.GetMiniSceneGraph(Movie.mini_scene_motion_name);
	if(effectGraph)then
		effectGraph:Reset();
	end
end

function Movie.CreateOrGetPlayer(player_name)
	local self = Movie;
	if(not player_name)then
		return;
	end
	local player = self.player_map[player_name];
	if(not player)then
		player = MovieClip:new();
		player.uid = player_name;
		self.player_map[player_name] = player;
	end

	return player;
end
--播放电影
--@param player_name:播放器名称
--@param movie_file: 文件路径
--@param force_load:是否重新加载源文件
function Movie.DoPlay_File(player_name,movie_file,force_load)
	if(not player_name or not movie_file)then return end
	local player = Movie.CreateOrGetPlayer(player_name);
	if(player)then
		player:DoPlay_File(movie_file,force_load);
	end
end
--播放电影
function Movie.DoPlay_ByMcmlNode(player_name,movie_mcmlNode,motion_index,run_time)
	if(not player_name or not movie_mcmlNode)then return end
	local player = Movie.CreateOrGetPlayer(player_name);
	if(player)then
		player:DoPlay_ByMcmlNode(movie_mcmlNode,motion_index,run_time);
	end
end
function Movie.DoPlay_ByString(player_name,movie_mcmlNode_str,motion_index,run_time)
	if(not player_name or not movie_mcmlNode_str)then return end
	local player = Movie.CreateOrGetPlayer(player_name);
	if(player)then
		player:DoPlay_ByString(movie_mcmlNode_str,motion_index,run_time);
	end
end
function Movie.PrePlay_ByString(player_name,movie_mcmlNode_str)
	local player = Movie.CreateOrGetPlayer(player_name);
	if(player)then
		player:PrePlay_ByString(movie_mcmlNode_str)
	end
end
--播放指定帧
function Movie.GotoFrame(player_name,motion_index,root_frame)
	if(not player_name)then return end
	local player = Movie.CreateOrGetPlayer(player_name);
	if(player)then
		player:GotoFrame(motion_index,root_frame);
	end
end
function Movie.DoPause(player_name)
	local player = Movie.CreateOrGetPlayer(player_name);
	if(player)then
		player:DoPause();
	end
end
function Movie.DoResume(player_name)
	local player = Movie.CreateOrGetPlayer(player_name);
	if(player)then
		player:DoResume();
	end
end
function Movie.Clear(player_name)
	local player = Movie.CreateOrGetPlayer(player_name);
	if(player)then
		player:Clear();
	end
end
function Movie.GetPropertyValue(mcmlNode,p)
	local self = Movie;
	if(mcmlNode and p)then
		if(mcmlNode.attr)then
			local v = mcmlNode.attr[p];
			return v;
		end
	end
end
function Movie.GetNumber(mcmlNode,p)
	local self = Movie;
	local v = self.GetPropertyValue(mcmlNode,p)
	v = tonumber(v);
	return v;
end
function Movie.GetString(mcmlNode,p)
	local self = Movie;
	local v = self.GetPropertyValue(mcmlNode,p)
	return v;
end
function Movie.GetBoolean(mcmlNode,p)
	local self = Movie;
	local v = self.GetPropertyValue(mcmlNode,p)
	local b;
	if(v == nil)then
		return false;
	end
	if(type(v) == "boolean")then
		return v;
	end
	if(v == "" or v == "False" or v == "false")then
		b = false;
	elseif(v == "True" or v == "true")then
		b = true;
	end
	return b;
end
function Movie.GetMotionValue(motion_handler,time,duration,start_value,end_value)
	if(motion_handler and start_value and end_value)then
		return motion_handler( time , start_value , end_value - start_value, duration );	
	end
end
-------------------------------------------------------------编辑工具使用
function Movie.HoldPlayer()
	local self = Movie;
	self.edit_player = ParaScene.GetPlayer();	
end
function Movie.Find_Player()
	local self = Movie;
	if(self.edit_player and self.edit_player:IsValid())then
		local params = self.GetCameraParamsByEdit();
		self.edit_player:SetPosition(params.x,params.y,params.z);
		self.edit_player:ToCharacter():SetFocus();
	end
end
function Movie.Find_Avatar_Pos()
	local self = Movie;
	if(self.edit_player and self.edit_player:IsValid())then
		local x,y,z = self.edit_player:GetPosition();
		ExternalInterface.Call("Movie.Find_Avatar_Pos_Handle",{
			x = x,
			y = y,
			z = z,
		});
	end	
end
function Movie.Find_Camera_Pos()
	local self = Movie;
	local params = self.GetCameraParamsByEdit();
	ExternalInterface.Call("Movie.Find_Camera_Pos_Handle",params);
end
function Movie.SetEditMode(b)
	local self = Movie;
	NPL.load("(gl)script/apps/Aries/Scene/AutoCameraController.lua");
	local AutoCameraController = commonlib.gettable("MyCompany.Aries.AutoCameraController");
	AutoCameraController:ApplyStyle("2d");

	self.is_edit_mode = b;
	self.HoldPlayer();
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	local o = {hookType = hookType, 		 
		hookName = "Movie_edit_mouse_down_hook", appName = "input", wndName = "mouse_down"}
			o.callback = Movie.OnMouseDown;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "Movie_edit_mouse_move_hook", appName = "input", wndName = "mouse_move"}
			o.callback = Movie.OnMouseMove;
	CommonCtrl.os.hook.SetWindowsHook(o);
	o = {hookType = hookType, 		 
		hookName = "Movie_edit_mouse_up_hook", appName = "input", wndName = "mouse_up"}
			o.callback = Movie.OnMouseUp;
	CommonCtrl.os.hook.SetWindowsHook({hookType = hookType, 		 
		hookName = "Movie_edit_key_down_hook", appName = "input", wndName = "key_down",
		callback = Movie.OnKeyDown});
	CommonCtrl.os.hook.SetWindowsHook(o);
end

function Movie.OnMouseUp(nCode, appName, msg)
	local self = Movie;
    if(mouse_button == "left")then
		if(self.eidt_press)then
			self.Object_UpdatePosition();
			local effectGraph = ParaScene.GetMiniSceneGraph(Movie.mini_scene_motion_name);
			local obj = effectGraph:GetObject(self.last_hold_name);
			if(obj and obj:IsValid())then
				local x,y,z = obj:GetPosition();
				if(self.press_pos)then
					local start_x,start_y,start_z = self.press_pos[1],self.press_pos[2],self.press_pos[3];
					if(start_x ~= x or start_y ~= y or start_z ~= z)then
						local __,__,motion_index,line_index = string.match(self.last_hold_name,"(.+)_(.+)_(.+)_(.+)");
						motion_index = tonumber(motion_index);
						line_index = tonumber(line_index);
						--position is changed
						ExternalInterface.Call("movie_edit_position_changed",{
							motion_index = motion_index-1,
							line_index = line_index-1,
							x = x,
							y = y,
							z = z,
						});
					end
				end
			end
			--self.Object_Release(self.last_hold_name);
			--self.last_hold_name = nil;
			self.press_pos = nil;
			self.eidt_press = false;
		end
		return
	end
	return nCode;
end
function Movie.OnMouseMove(nCode, appName, msg)
	local self = Movie;
    if(mouse_button == "left" and self.eidt_press)then
		self.Object_UpdatePosition();
		return
	end
	return nCode;
end
function Movie.OnMouseDown(nCode, appName, msg)
	local self = Movie;
    if(mouse_button == "left")then
		local x, y = ParaUI.GetMousePosition();
		local effectGraph = ParaScene.GetMiniSceneGraph(Movie.mini_scene_motion_name);
		local obj = effectGraph:MousePick(x,y,100, filter or "4294967295");	
		if(obj and obj:IsValid()) then
			local name = obj.name;
			if(name)then
				--if(not self.last_hold_name or self.last_hold_name ~= name)then
					self.Object_Release(self.last_hold_name);
					self.last_hold_name = name;
					self.Object_Selected(self.last_hold_name);

					local x,y,z = obj:GetPosition();
					self.press_pos = {x,y,z};
					self.eidt_press= true;
				--end
			end
		else
			self.Object_Release(self.last_hold_name);
			self.last_hold_name = nil;
			self.press_pos = nil;
		end
		return;
	end
	return nCode;
end
function Movie.Object_UpdatePosition()
	local self = Movie;
	if(self.last_hold_name)then
		local effectGraph = ParaScene.GetMiniSceneGraph(Movie.mini_scene_motion_name);
		local obj = effectGraph:GetObject(self.last_hold_name);
		if(obj and obj:IsValid())then
			local pt = ParaScene.MousePick(100, "walkpoint");	
			if(pt:IsValid())then
				local x,y,z = pt:GetPosition();
				obj:SetPosition(x,y,z);	
			end
		end
	end
end
function Movie.Object_Selected(name)
	local self = Movie;
	if(not name)then return end
	local effectGraph = ParaScene.GetMiniSceneGraph(Movie.mini_scene_motion_name);
	local obj = effectGraph:GetObject(name);
	if(obj and obj:IsValid())then
		ParaSelection.AddObject(obj,1);
	end
end
function Movie.Object_Release(name)
	local self = Movie;
	if(not name)then return end
	local effectGraph = ParaScene.GetMiniSceneGraph(Movie.mini_scene_motion_name);
	local obj = effectGraph:GetObject(name);
	if(obj and obj:IsValid())then
		ParaSelection.AddObject(obj,-1);
	end
end
function Movie.OnKeyDown(nCode, appName, msg)
	local self = Movie;
	if(nCode==nil) then return end
	if(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_MINUS))then
		Movie.OnUpdateScaling(self.last_hold_name,-0.1);
		return
	elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_EQUALS))then
		Movie.OnUpdateScaling(self.last_hold_name,0.1);
		return
	elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LBRACKET))then
		Movie.OnUpdateFacing(self.last_hold_name,-0.1);
		return
	elseif(ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RBRACKET))then
		Movie.OnUpdateFacing(self.last_hold_name,0.1);
	end	
	return nCode; 
end
function Movie.OnUpdateFacing(name,delta)
	local self = Movie;
	if(not name)then return end
	local effectGraph = ParaScene.GetMiniSceneGraph(Movie.mini_scene_motion_name);
	local obj = effectGraph:GetObject(name);
	if(obj and obj:IsValid())then
		local facing = obj:GetFacing();
		facing = facing + delta;
		obj:SetFacing(facing);
	end
end
function Movie.OnUpdateScaling(name,delta)
	local self = Movie;
	if(not name)then return end
	local effectGraph = ParaScene.GetMiniSceneGraph(Movie.mini_scene_motion_name);
	local obj = effectGraph:GetObject(name);
	if(obj and obj:IsValid())then
		local scaling = obj:GetScale();
		scaling = scaling + delta;
		obj:SetScale(scaling);
	end
end
function Movie.ParseTag(tag)
	if(not tag)then return {} end
	local body_list = {};
	local s;
	for s in string.gfind(tag, "([^_]+)") do
		table.insert(body_list,s);
	end
	return body_list;
end
----------------camera edit
function Movie.OnUpdateCameraPosition(x,y,z)
	if(not x or not z)then return end
	y = y or 80;
	local props_param = {
		X = x,Y = y,Z = z
	}
	Movie.UpdateCameraParams(props_param);
end
function Movie.GetCameraParamsByEdit()
	local self = Movie;
	if(not self.is_edit_mode)then
		return
	end
	local x,y,z = ParaCamera.GetLookAtPos()
	local att = ParaCamera.GetAttributeObject();
	local CameraObjectDistance = att:GetField("CameraObjectDistance", 10);
	local CameraLiftupAngle = att:GetField("CameraLiftupAngle", 0);
	local CameraRotY = att:GetField("CameraRotY", 0);

	local params = {
		CameraObjectDistance = CameraObjectDistance,
		CameraLiftupAngle = CameraLiftupAngle,
		CameraRotY = CameraRotY,
		x = x,
		y = y,
		z = z,
	}
	ExternalInterface.Call("movie_edit_update_camera",params);
	return params;
end
function Movie.UpdateCameraParams(props_param)
	local self = Movie;
	if(not self.is_edit_mode)then
		return
	end
	if(not props_param)then
		return
	end
	local x,y,z = ParaCamera.GetLookAtPos()
	ParaCamera.SetLookAtPos(props_param.X or x, props_param.Y or y, props_param.Z or z);
	local att = ParaCamera.GetAttributeObject();

	local CameraObjectDistance = props_param.CameraObjectDistance;
	local CameraLiftupAngle = props_param.CameraLiftupAngle;
	local CameraRotY = props_param.CameraRotY;
	
	if(CameraObjectDistance)then
		att:SetField("CameraObjectDistance", CameraObjectDistance);
	end
	if(CameraLiftupAngle)then
		att:SetField("CameraLiftupAngle", CameraLiftupAngle);
	end
	if(CameraRotY)then
		att:SetField("CameraRotY", CameraRotY);
	end
end
function Movie.PreviewMcml(path,version)
	if(not path)then return end
	if(version == "teen")then
		NPL.load("(gl)script/apps/Aries/DefaultTheme.teen.lua");
		MyCompany.Aries.Theme.Default:Load();
	end
	local pairs = pairs
	local ipairs = ipairs
	local tostring = tostring
	local tonumber = tonumber
	local type = type
	local string_find = string.find;
	local string_format = string.format;
	local string_gsub = string.gsub;
	local string_lower = string.lower
	local string_match = string.match;
	local table_getn = table.getn;

	local xmlRoot = ParaXML.LuaXML_ParseFile(path);
	NPL.load("(gl)script/ide/XPath.lua");
	local node = commonlib.XPath.selectNode(xmlRoot, "/pe:mcml/pe:div");
	if(not node)then
		return
	end
	local style_code = node.attr.style;
	local style = {};
	if(style_code) then
		local name, value;
		for name, value in string.gfind(style_code, "([%w%-]+)%s*:%s*([^;]*)[;]?") do
			name = string_lower(name);
			value = string_gsub(value, "%s*$", "");
			if(name == "height" or name == "left" or name == "top" or name == "width" or name == "font-size" or 
				string_find(name,"^margin") or string_find(name,"^padding")) then
				local _, _, cssvalue = string_find(value, "([%+%-]?%d+)");
				if(cssvalue~=nil) then
					value = tonumber(cssvalue);
				else
					value = nil;
				end
			elseif(string_match(name, "^background[2]?$") or name == "background-image") then
				value = string_gsub(value, "url%((.*)%)", "%1");
				value = string_gsub(value, "#", ";");
			end
			style[name] = value;
		end
	end
	local width = style["width"];
	local height = style["height"];
	if(not width or not height or width <= 0 or height <= 0)then
		_guihelper.MessageBox("请先设置面板长度和宽度！");
		return
	end
	local x = -width/2;
	local y = -height/2;
	Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {name="Movie.PreviewMcml", 
			app_key=MyCompany.Taurus.app.app_key, 
			bShow = false,bDestroy = true,});
	local params = {
				url = path, 
				name = "Movie.PreviewMcml", 
				app_key=MyCompany.Taurus.app.app_key, 
				isShowTitleBar = false,
				DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				enable_esc_key = true,
				style = CommonCtrl.WindowFrame.ContainerStyle,
				allowDrag = true,
				zorder = zorder,
				directPosition = true,
					align = "_lt",
					x = 0,
					y = 0,
					width = width,
					height = height,
		}
	System.App.Commands.Call("File.MCMLWindowFrame", params);	
end