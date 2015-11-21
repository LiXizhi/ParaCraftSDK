--[[
Title: DirectorToolPage
Author(s): Leio
Date: 2012/11/29
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/DirectorToolPage.lua");
local DirectorToolPage = commonlib.gettable("Director.DirectorToolPage");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Director/SpellCameraHelper.lua");
local SpellCameraHelper = commonlib.gettable("Director.SpellCameraHelper");
NPL.load("(gl)script/ide/Director/MovieClip.lua");
local MovieClip = commonlib.gettable("Director.MovieClip");
NPL.load("(gl)script/ide/ExternalInterface.lua");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
local DirectorToolPage = commonlib.gettable("Director.DirectorToolPage");
local player_name= "DirectorToolPage.player";
DirectorToolPage.line_index = nil;
DirectorToolPage.edit_line_node = nil;
DirectorToolPage.avatar_player = nil;
function DirectorToolPage.OnInit()
	if(DirectorToolPage.is_init)then
		return
	end
	DirectorToolPage.avatar_player = ParaScene.GetPlayer();
	DirectorToolPage.is_init = true;
	local player = Movie.CreateOrGetPlayer(player_name);
	player:AddEventListener("movie_start",function(holder,event)
		ExternalInterface.Call("Director.movie_start",{
				motion_index = event.motion_index,
				run_time = event.run_time,
			});
	end,nil,"DirectorToolPage_movie_start");
	player:AddEventListener("movie_update",function(holder,event)
		ExternalInterface.Call("Director.movie_update",{
				motion_index = event.motion_index,
				run_time = event.run_time,
			});
	end,nil,"DirectorToolPage_movie_update");
	player:AddEventListener("movie_end",function(holder,event)
		ExternalInterface.Call("Director.movie_end",{
				motion_index = event.motion_index,
				run_time = event.run_time,
			});
	end,nil,"DirectorToolPage_movie_end");
end
function DirectorToolPage.Stop()
	Movie.Clear(player_name)
end
function DirectorToolPage.GoToTime(movie_str,motion_index,run_time,is_pause)
	if(not movie_str or not motion_index or not run_time)then
		return
	end
	DirectorToolPage.OnInit();
	local player = Movie.CreateOrGetPlayer(player_name);
	Movie.is_edit_mode = true;
	Movie.DoPlay_ByString(player_name,movie_str,motion_index,run_time);
	Movie.GotoFrame(player_name,motion_index,run_time);
	if(is_pause)then
		Movie.DoPause(player_name);
	end
end
--[[
	local lines = {index,index,index}
--]]
function DirectorToolPage.OnSelected(movie_str,motion_index,run_time,lines)
	if(DirectorToolPage.page)then
		DirectorToolPage.page:CloseWindow();
		DirectorToolPage.page = nil;
	end
	ParaSelection.ClearGroup(10);
	DirectorToolPage.line_index = nil;
	DirectorToolPage.edit_line_node = nil;
	if(not lines or #lines > 1)then 
		return 
	end
	local player = Movie.CreateOrGetPlayer(player_name);
	DirectorToolPage.GoToTime(movie_str,motion_index,run_time,true);
	DirectorToolPage.line_index = lines[1];
	if(not DirectorToolPage.line_index)then
		return
	end
	DirectorToolPage.edit_line_node = player:GetMotionLineNode(motion_index,DirectorToolPage.line_index + 1)
	if(DirectorToolPage.edit_line_node)then
		local type = DirectorToolPage.edit_line_node.attr.TargetType or "";
		if(type == "Model" or type == "Character" or type == "Camera")then
			DirectorToolPage.ShowPage();
			DirectorToolPage.HighlightNode();
		end
	end
end
function DirectorToolPage.OnInitPage()
	DirectorToolPage.page = document:GetPageCtrl();
end
function DirectorToolPage.ShowPage()
	--local params = {
				--url = "script/ide/Director/DirectorToolPage.html", 
				--name = "DirectorToolPage.ShowPage()", 
				--app_key=MyCompany.Taurus.app.app_key, 
				--isShowTitleBar = false,
				--DestroyOnClose = true, -- prevent many ViewProfile pages staying in memory
				--style = CommonCtrl.WindowFrame.ContainerStyle,
				--allowDrag = true,
				--directPosition = true,
					--align = "_rt",
					--x = -260,
					--y = 0,
					--width = 260,
					--height = 600,
		--}
	--System.App.Commands.Call("File.MCMLWindowFrame", params);	
end
function DirectorToolPage.SetPosition(dx,dy,dz)
	if(DirectorToolPage.edit_line_node)then
		dx = dx or 0;
		dy = dy or 0;
		dz = dz or 0;
		if(dx == 0 and dx == dy and dy == dz)then
			return
		end
		local type = DirectorToolPage.edit_line_node.attr.TargetType or "";
		if(type == "Model" or type == "Character" or type == "Camera")then
			ExternalInterface.Call("Director.SetPosition",{
				dx = dx,
				dy = dy,
				dz = dz,
				line_index = DirectorToolPage.line_index,
			});
		end
	end
end
function DirectorToolPage.SetFacing(delta)
	if(DirectorToolPage.edit_line_node)then
		delta = delta or 0;
		if(delta == 0)then
			return
		end
		local type = DirectorToolPage.edit_line_node.attr.TargetType or "";
		if(type == "Model" or type == "Character")then
			ExternalInterface.Call("Director.SetFacing",{
				delta = delta,
				line_index = DirectorToolPage.line_index,
			});
		end
	end
end
function DirectorToolPage.HighlightNode()
	if(DirectorToolPage.edit_line_node)then
		local player = Movie.CreateOrGetPlayer(player_name);
		local TargetType = DirectorToolPage.edit_line_node.attr.TargetType or "";
		local render = MovieClip.render_maps[TargetType];
		local obj_name = player:GetInstanceName(1,DirectorToolPage.line_index+1);
		if(render and render.GetEntity)then
			local obj = render.GetEntity(obj_name);
			if(obj and obj:IsValid())then
				obj:GetAttributeObject():SetField("showboundingbox", true);
			end
		end
	end
end
function DirectorToolPage.GetCameraParams()
	local X,Y,Z = ParaCamera.GetLookAtPos(); 
	local att = ParaCamera.GetAttributeObject();
	local CameraObjectDistance = att:GetField("CameraObjectDistance", 5);
	local CameraLiftupAngle = att:GetField("CameraLiftupAngle", 0.4);
	local CameraRotY = att:GetField("CameraRotY", 0);
	X = string.format("%.2f",X);
	Y = string.format("%.2f",Y);
	Z = string.format("%.2f",Z);
	CameraObjectDistance = string.format("%.2f",CameraObjectDistance);
	CameraLiftupAngle = string.format("%.2f",CameraLiftupAngle);
	CameraRotY = string.format("%.2f",CameraRotY);
	local p = {
		X = X,
		Y = Y,
		Z = Z,
		CameraObjectDistance = CameraObjectDistance,
		CameraLiftupAngle = CameraLiftupAngle,
		CameraRotY = CameraRotY,
		line_index = DirectorToolPage.line_index,
	}
	return p;
end
function DirectorToolPage.GotAvatarFocus()
	if(DirectorToolPage.avatar_player)then
		local avatar = DirectorToolPage.avatar_player;
		if(avatar and avatar:IsValid())then
			local params = DirectorToolPage.GetCameraParams();
			avatar:SetPosition(tonumber(params.X),tonumber(params.Y),tonumber(params.Z));
			avatar:ToCharacter():SetFocus();
		end
	end
end
function DirectorToolPage.SetAvatarParams()
	if(DirectorToolPage.avatar_player)then
		local avatar = DirectorToolPage.avatar_player;
		if(avatar and avatar:IsValid())then
			local X,Y,Z = avatar:GetPosition();
			X = string.format("%.2f",X);
			Y = string.format("%.2f",Y);
			Z = string.format("%.2f",Z);
			local p = {
				X = X,
				Y = Y,
				Z = Z,
				line_index = DirectorToolPage.line_index,
			}
			ExternalInterface.Call("Director.SetAvatarParams",p);
		end
	end
end
function DirectorToolPage.SetCameraParams()
	local params = DirectorToolPage.GetCameraParams();
	ExternalInterface.Call("Director.SetCameraParams",params);
end
function DirectorToolPage.SetCameraParams_SpellCamera(RefID,arena_index)
	local params = SpellCameraHelper.GetCameraParams(RefID,arena_index);
	params.line_index = DirectorToolPage.line_index;
	params.X = string.format("%.2f",params.X);
	params.Y = string.format("%.2f",params.Y);
	params.Z = string.format("%.2f",params.Z);
	params.CameraObjectDistance = string.format("%.2f",params.CameraObjectDistance);
	params.CameraLiftupAngle = string.format("%.2f",params.CameraLiftupAngle);
	params.CameraRotY = string.format("%.2f",params.CameraRotY);
	echo("=============params");
	echo(params);
	ExternalInterface.Call("Director.SetCameraParams",params);
end
