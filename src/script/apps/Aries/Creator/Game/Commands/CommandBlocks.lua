--[[
Title: Commands
Author(s): LiXizhi
Date: 2013/2/9
Desc: slash command 
use the lib:
------------------------------------------------------------
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/UndoManager.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/GameMarket/EnterGamePage.lua");
NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
NPL.load("(gl)script/apps/Aries/SlashCommand/SlashCommand.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Commands/CmdParser.lua");
NPL.load("(gl)script/ide/System/Core/Color.lua");
local Color = commonlib.gettable("System.Core.Color");
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");
local EntityManager = commonlib.gettable("MyCompany.Aries.Game.EntityManager");
local SlashCommand = commonlib.gettable("MyCompany.Aries.SlashCommand.SlashCommand");
	
local WorldManager = commonlib.gettable("MyCompany.Aries.WorldManager");
local EnterGamePage = commonlib.gettable("MyCompany.Aries.Creator.Game.Desktop.EnterGamePage");
local UndoManager = commonlib.gettable("MyCompany.Aries.Game.UndoManager");
local BlockEngine = commonlib.gettable("MyCompany.Aries.Game.BlockEngine")
local TaskManager = commonlib.gettable("MyCompany.Aries.Game.TaskManager")
local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
local block = commonlib.gettable("MyCompany.Aries.Game.block")
local GameLogic = commonlib.gettable("MyCompany.Aries.Game.GameLogic")
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");

local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");

--[[delete selected blocks
format: /del [-below] [radius]
delete all blocks below the current player's position in a radius of 256 (by default). 
e.g.  /del -below 256

format: /del -mode [real|block]
e.g. whether terrain blocks are auto generated when deleting blocks. 
]]
Commands["del"] = {
	name="del", 
	quick_ref="/del", 
	desc="delete selected blocks", 
	handler = function(cmd_name, cmd_text, cmd_params)
		if(not GameLogic.is_started) then
			return 
		end

		local options = {};
		local option;
		for option in cmd_text:gmatch("%s*%-(%w+)") do 
			options[option] = true;
		end

		local value = cmd_text:match("%s+(%S*)$");

		-- remove all terrain where the player stand
		if(options.below) then
			local cx, cy, cz = ParaScene.GetPlayer():GetPosition();
			if(value) then
				value = tonumber(value);
			end
			local radius = (value or 64);
			local bx, by, bz = BlockEngine:block(cx, cy+0.1, cz);

			local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
				local i;
				for i = 1, 4 do 
					if(by >= 0) then
						local x,z;
						for x = bx-radius, bx+radius do
							for z = bz-radius, bz+radius do
								BlockEngine:SetBlock(x,by,z, 0);
							end
						end
					end
					by = by - 1;
				end
				if(by > 0) then
					timer:Change(30);
				end
			end})
			mytimer:Change(30, nil);
		elseif(options.mode) then
			-- change delete mode
			block.auto_gen_terrain_block = (value == "real")
		else
			NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/SelectBlocksTask.lua");
			MyCompany.Aries.Game.Tasks.SelectBlocks.DeleteSelection(true);
		end
	end,
};

Commands["ring"] = {
	name="ring", 
	quick_ref="/ring [plane] radius [thickness]", 
	desc="ring", 
	handler = function(cmd_name, cmd_text, cmd_params)
		if(not GameLogic.is_started) then
			return 
		end
		NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/CreateSimpleShapeTask.lua");
		local plane, radius, thickness = cmd_text:match("(%a*)%s*(%d+)%s*(%d*)");
		radius = tonumber(radius or 10);
		if(thickness) then
			thickness = tonumber(thickness);
		end
		if(plane and plane == "") then
			plane = "y";
		end
		local task = MyCompany.Aries.Game.Tasks.CreateSimpleShape:new({shape="ring", radius=radius, thickness=thickness, plane = plane})
		task:Run();
	end,
};

Commands["circle"] = {
	name="circle", 
	quick_ref="/circle [plane] radius", 
	desc="circle", 
	handler = function(cmd_name, cmd_text, cmd_params)
		if(not GameLogic.is_started) then
			return 
		end
		NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/CreateSimpleShapeTask.lua");
		local plane, radius = cmd_text:match("(%a*)%s*(%d+)");
		radius = tonumber(radius or 10);
		if(plane and plane == "") then
			plane = "y";
		end
		local task = MyCompany.Aries.Game.Tasks.CreateSimpleShape:new({shape="circle", radius=radius, plane = plane})
		task:Run();
	end,
};

Commands["sphere"] = {
	name="sphere", 
	quick_ref="/sphere radius [beSolid]", 
	desc="sphere", 
	handler = function(cmd_name, cmd_text, cmd_params)
		if(not GameLogic.is_started) then
			return 
		end
		NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/CreateSimpleShapeTask.lua");
		local radius, beSolid = cmd_text:match("(%d+)%s*(%a*)");
		radius = tonumber(radius or 10);
		if(beSolid and beSolid == "true") then
			beSolid = true;
		else
			beSolid = false;
		end
		local task = MyCompany.Aries.Game.Tasks.CreateSimpleShape:new({shape="sphere", radius=radius, beSolid=beSolid})
		task:Run();
	end,
};

Commands["ellipsoid"] = {
	name="ellipsoid", 
	quick_ref="/ellipsoid radiusX radiusY radiusZ [beSolid]", 
	desc="ellipsoid", 
	handler = function(cmd_name, cmd_text, cmd_params)
		if(not GameLogic.is_started) then
			return 
		end
		NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/CreateSimpleShapeTask.lua");
		local radiusX, radiusY, radiusZ, beSolid = cmd_text:match("(%d+)%s*(%d+)%s*(%d+)%s*(%a*)");
		radiusX = tonumber(radiusX or 10);
		radiusY = tonumber(radiusY or 10);
		radiusZ = tonumber(radiusZ or 10);
		if(beSolid and beSolid == "true") then
			beSolid = true;
		else
			beSolid = false;
		end
		local task = MyCompany.Aries.Game.Tasks.CreateSimpleShape:new({shape="ellipsoid", radiusX=radiusX, radiusY=radiusY, radiusZ=radiusZ, beSolid=beSolid})
		task:Run();
	end,
};

--[[ flood a given place with a certain radius
e.g. flood with water in a radius of 5 blocks
/flood 5
]]
Commands["flood"] = {
	name="flood", 
	quick_ref="/flood [radius or 10] [block_id or water] [x or playerPosX] [y] [z] ", 
	desc="flood", 
	handler = function(cmd_name, cmd_text, cmd_params)
		local blockid, radius, x, y, z;
		radius, cmd_text = CmdParser.ParseInt(cmd_text)
		if(radius) then
			blockid, cmd_text = CmdParser.ParseBlockId(cmd_text);	
			if(blockid) then
				x, y, z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
			end
		end

		if(not x) then
			x,y,z = EntityManager.GetFocus():GetBlockPos();	
		end

		NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/WaterFloodTask.lua");
		local task = MyCompany.Aries.Game.Tasks.WaterFlood:new({blockX = x,blockY = y, blockZ = z, 
			fill_id = blockid, radius = radius or 10, })
		task:Run();
	end,
};

Commands["unflood"] = {
	name="unflood", 
	quick_ref="/unflood [radius or 10] [x or playerPosX] [y] [z] ", 
	desc="unflood", 
	handler = function(cmd_name, cmd_text, cmd_params)
		local blockid, radius, x, y, z;
		radius, cmd_text = CmdParser.ParseInt(cmd_text)
		if(radius) then
			x, y, z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
		end

		if(not x) then
			x,y,z = EntityManager.GetFocus():GetBlockPos();	
		end

		NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/WaterFloodTask.lua");
		local task = MyCompany.Aries.Game.Tasks.WaterFlood:new({blockX = x,blockY = y, blockZ = z, 
			fill_id = 0, radius = radius or 10, })
		task:Run();
	end,
};
-- fill the selected aabb area with the current block in hand
-- format: /fill [block_id]
-- if block_id is omitted, it will be the current block in hand. 
Commands["fill"] = {
	name="fill", 
	quick_ref="/fill [block_id]", 
	desc="fill the selected aabb area with the current block in hand" , 
	handler = function(cmd_name, cmd_text, cmd_params)
		local options = {};
		local option;
		for option in cmd_text:gmatch("%s*%-(%w+)") do 
			options[option] = true;
		end

		local value = cmd_text:match("%s*(%S*)$");

		local fill_block_id;
		-- remove all terrain where the player stand
		if(value) then
			fill_block_id = tonumber(value);
		end

		NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/SelectBlocksTask.lua");
		MyCompany.Aries.Game.Tasks.SelectBlocks.FillSelection(fill_block_id);
	end,
};

Commands["replace"] = {
	name="replace", 
	quick_ref="/replace [-all] [from_id] [to_id] [radius]", 
	desc=[[replace all blocks in selected area(aabb) from from_id to to_id, or replace in region specified by radius around current player
format: /replace [-all] [from_id] [to_id] [radius]
if block_id is omitted, it will be the current block in hand. 
-all: if nothing is selected, one need to specify -all and a radius value. 
]], 
	handler = function(cmd_name, cmd_text, cmd_params)
		local options = {};
		local option;
		for option in cmd_text:gmatch("%s*%-(%w+)") do 
			options[option] = true;
		end

		local from_id, to_id;
		from_id, to_id, radius = cmd_text:match("%s*(%d+)%s+(%d+)%s+(%d+)$");
		if(not radius) then
			from_id, to_id = cmd_text:match("%s*(%d*)%s+(%d*)$");
		end
		

		-- remove all terrain where the player stand
		if(from_id and to_id) then
			from_id = tonumber(from_id);
			to_id = tonumber(to_id);
			
			if(options.all) then
				radius = tonumber(radius);

				NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/ReplaceBlockTask.lua");
				local x, y, z = EntityManager.GetPlayer():GetBlockPos();
				local task = MyCompany.Aries.Game.Tasks.ReplaceBlock:new({mode="all", from_id = from_id, to_id=to_id, blockX = x, blockZ = z, radius = radius or 256});
				task:Run();
			else
				NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/SelectBlocksTask.lua");
				MyCompany.Aries.Game.Tasks.SelectBlocks.ReplaceBlocks(from_id, to_id);
			end
		end
	end,
};


Commands["setblock"] = {
	name="setblock", 
	quick_ref="/setblock x y z (dx dy dz) [block] [data] [entityDataTable] [where sameblock]", 
	desc=[[ set block at given absolute or relative position. 
/setblock x y z [block] [data]
/setblock ~ ~1 ~ [block] [data]
/setblock ~-1 ~1 ~ (-1 2 ~) [block] [data] where sameblock
@param xyz are the coordinates of the block. relative position begins with ~
@param block is the BlockID of the block (includes id:0)
@param data is the block data
@param entityDataTable is xml table
@param where sameblock can be used to only modify block data of a given block in the region. 
Examples:
/setblock ~-1 ~0 ~-2 254 0 {attr={filename="blocktemplates/demo.bmax"}}
]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		local blockid, data, method, dataTag, dx, dy, dz;
		local x, y, z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
		if(x) then
			dx, dy, dz, cmd_text = CmdParser.ParsePosInBrackets(cmd_text);
			blockid, cmd_text = CmdParser.ParseBlockId(cmd_text);
			if(blockid) then
				data, cmd_text = CmdParser.ParseInt(cmd_text)
			end

			local sameblock;
			local where, cmd_text = CmdParser.ParseText(cmd_text, "where");
			if(where) then
				sameblock, cmd_text = CmdParser.ParseText(cmd_text, "sameblock");
			end

			local entityData;
			entityData, cmd_text = CmdParser.ParseTable(cmd_text);
			
			if(not dx) then
				BlockEngine:SetBlock(x,y,z, blockid or 0, data or 0, 3, entityData);
			else
				if(not sameblock) then
					for i=0, math.abs(dx) do
						for j=0, math.abs(dy) do
							for k=0, math.abs(dz) do
								BlockEngine:SetBlock(x+if_else(dx>0, i, -i),
									y+if_else(dy>0, j, -j),
									z+if_else(dz>0, k, -k), 
									blockid or 0, data or 0, 3, entityData);
							end
						end
					end
				else
					for i=0, math.abs(dx) do
						for j=0, math.abs(dy) do
							for k=0, math.abs(dz) do
								local xx,yy,zz = x+if_else(dx>0, i, -i),y+if_else(dy>0, j, -j),z+if_else(dz>0, k, -k);
								if(BlockEngine:GetBlockId(xx,yy,zz) == blockid) then
									BlockEngine:SetBlock(xx,yy,zz, blockid or 0, data or 0, 3, entityData);
								end
							end
						end
					end
				end
			end
		end
	end,
};

--[[ clone a region of blocks to another region
/clone [-update] from_x from_y from_z (dx dy dz) to to_x to_y to_z (dx dy dz) [where sameblock]
/clone ~ ~-1 ~ (2 2 2) to ~5 ~ ~
/clone ~ ~-1 ~ to ~5 ~ ~
/clone ~ ~-1 ~ to ~-5 ~ ~ (3 0 3)
/clone ~ ~-1 ~ to ~-5 ~-1 ~ (3 0 3) where sameblock
if sameblock is specied, we will only copy if dest and src id are the same.
dx,dy,dz can now be negative
]]
Commands["clone"] = {
	name="clone", 
	quick_ref="/clone [-update] from_x from_y from_z (dx dy dz) to to_x to_y to_z (dx dy dz)", 
	desc="set block at given position. " , 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		local from_x, from_y, from_z, from_dx, from_dy, from_dz;
		local to_x, to_y, to_z, to_dx, to_dy, to_dz;

		local options;
		options, cmd_text = CmdParser.ParseOptions(cmd_text);
		local flag;
		if(options.update) then
			flag = 3;
		end

		from_x, from_y, from_z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);

		if(from_x) then
			from_dx, from_dy, from_dz, cmd_text = CmdParser.ParsePosInBrackets(cmd_text);
			local to, cmd_text = CmdParser.ParseText(cmd_text, "to");
			if(to) then
				to_x, to_y, to_z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
				if(to_x) then
					NPL.load("(gl)script/ide/math/vector.lua");
					local vector3d = commonlib.gettable("mathlib.vector3d");
					NPL.load("(gl)script/ide/math/ShapeAABB.lua");
					local ShapeAABB = commonlib.gettable("mathlib.ShapeAABB");

					to_dx, to_dy, to_dz, cmd_text = CmdParser.ParsePosInBrackets(cmd_text);

					local sameblock;
					local where, cmd_text = CmdParser.ParseText(cmd_text, "where");
					if(where) then
						sameblock, cmd_text = CmdParser.ParseText(cmd_text, "sameblock");
					end

					local params = {
						flag = flag,
						only_sameblock = sameblock == "sameblock",
					}
					if(not to_dx) then
						params.to_x, params.to_y, params.to_z = to_x, to_y, to_z;
					else
						params.to_aabb = ShapeAABB:new();
						params.to_aabb:SetPointAABB(vector3d:new({to_x, to_y, to_z}));
						params.to_aabb:Extend(vector3d:new({to_x+to_dx, to_y+to_dy, to_z+to_dz}));
					end

					params.from_aabb = ShapeAABB:new();
					if(not from_dx) then
						from_dx, from_dy, from_dz = 0, 0, 0;
					end
					
					params.from_aabb:SetPointAABB(vector3d:new({from_x, from_y, from_z}));
					params.from_aabb:Extend(vector3d:new({from_x+from_dx, from_y+from_dy, from_z+from_dz}));
					NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/CloneBlocksTask.lua");
					local task = MyCompany.Aries.Game.Tasks.CloneBlocks:new(params);
					task:Run();
				end
			end
		end
	end,
};


--[[ Used to test whether blocks in the x, y and z coordinates or cube region specified is block_id. 
relative position begins with ~
/testblock x y z blockid data
/testblock ~ ~1 ~ blockid data
/testblock ~-1 ~1 ~ (-1 2 ~) blockid data
xyz are the coordinates of the blockid
blockid is the BlockID of the blockid (includes id:0)
data is the blockid data
]]
Commands["testblock"] = {
	name="testblock", 
	quick_ref="/testblock x y z [(dx dy dz)] blockid [data]", 
	desc="return true if all blocks match a given one" , 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		local blockid, data, method, dataTag, dx, dy, dz;
		local x, y, z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
		if(x) then
			dx, dy, dz, cmd_text = CmdParser.ParsePosInBrackets(cmd_text);
			blockid, cmd_text = CmdParser.ParseBlockId(cmd_text);
			if(blockid) then
				data, cmd_text = CmdParser.ParseInt(cmd_text)
				if(not dx) then
					if(blockid == BlockEngine:GetBlockId(x,y,z) and (not data or data == BlockEngine:GetBlockData(x,y,z))) then	
						return true;
					end	
				else
					for i=0, math.abs(dx), if_else(dx>=0, 1, -1) do
						for j=0, math.abs(dy), if_else(dy>=0, 1, -1) do
							for k=0, math.abs(dz), if_else(dz>=0, 1, -1) do
								local bx, by, bz = x+i, y+j, z+k;
								if(blockid == BlockEngine:GetBlockId(bx,by,bz) and (not data or data == BlockEngine:GetBlockData(bx,by,bz))) then	
								else
									return false;
								end	
							end
						end
					end
					return true;
				end
			end
		end
		return false;
	end,
};


--[[ Compare the blocks at two locations in cuboid regions. return true if equal
/compareblocks ~ ~-1 ~ (2 2 2) to ~5 ~ ~
]]
Commands["compareblocks"] = {
	name="compareblocks", 
	quick_ref="/testblocks from_x from_y from_z (dx dy dz) to to_x to_y to_z", 
	desc="Compare the blocks at two locations in cuboid regions. " , 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		local from_x, from_y, from_z, dx, dy, dz;
		local to_x, to_y, to_z;

		local options;
		options, cmd_text = CmdParser.ParseOptions(cmd_text);
		local flag;
		if(options.update) then
			flag = 3;
		end

		from_x, from_y, from_z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);

		if(from_x) then
			dx, dy, dz, cmd_text = CmdParser.ParsePosInBrackets(cmd_text);
			local to, cmd_text = CmdParser.ParseText(cmd_text, "to");
			if(to and dx) then
				to_x, to_y, to_z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
				if(to_x) then
					for i=0, math.abs(dx), if_else(dx>=0, 1, -1) do
						for j=0, math.abs(dy), if_else(dy>=0, 1, -1) do
							for k=0, math.abs(dz), if_else(dz>=0, 1, -1) do
								local src_x, src_y, src_z = from_x+i, from_y+j, from_z+k;
								local dest_x, dest_y, dest_z = to_x+i, to_y+j, to_z+k;
								if(	BlockEngine:GetBlockId(src_x, src_y, src_z) ~= BlockEngine:GetBlockId(dest_x, dest_y, dest_z) or
									BlockEngine:GetBlockData(src_x, src_y, src_z) ~= BlockEngine:GetBlockData(dest_x, dest_y, dest_z) ) then
									return false;
								end	
							end
						end
					end
					return true;
				end
			end
		end
		return false;
	end,
};

--[[ mirror a region of blocks to another region alone agiven axis
/mirror [-clone|-no_clone] [-update] [x|y|z] from_x from_y from_z (dx dy dz) to pivot_x pivot_y pivot_z
/mirror x ~ ~ ~ (3 2 3) to ~4 ~ ~
/mirror -no_clone y ~ ~ ~ (3 2 3) to ~ ~1 ~
dx,dy,dz can now be negative
]]
Commands["mirror"] = {
	name="mirror", 
	quick_ref="/mirror [clone|no_clone] [x|y|z] from_x from_y from_z (dx dy dz) to pivot_x pivot_y pivot_z", 
	desc="mirror a region of blocks to another region alone agiven axis" , 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		local from_x, from_y, from_z, from_dx, from_dy, from_dz;
		local pivot_x, pivot_y, pivot_z, mirror_axis;

		local options;
		options, cmd_text = CmdParser.ParseOptions(cmd_text);
		local flag;
		if(options.update) then
			flag = 3;
		end
		local method = "clone";
		if(options.no_clone) then
			method = "no_clone";
		end

		mirror_axis, cmd_text = CmdParser.ParseString(cmd_text);

		from_x, from_y, from_z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);

		if(from_x) then
			from_dx, from_dy, from_dz, cmd_text = CmdParser.ParsePosInBrackets(cmd_text);
			local to, cmd_text = CmdParser.ParseText(cmd_text, "to");
			if(to) then
				pivot_x, pivot_y, pivot_z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
				if(pivot_x ) then
					NPL.load("(gl)script/ide/math/vector.lua");
					local vector3d = commonlib.gettable("mathlib.vector3d");
					NPL.load("(gl)script/ide/math/ShapeAABB.lua");
					local ShapeAABB = commonlib.gettable("mathlib.ShapeAABB");

					
					local params = {
						flag = flag,
						method = method,
						mirror_axis = mirror_axis,
						pivot_x = pivot_x, pivot_y = pivot_y, pivot_z = pivot_z,
					}
					
					params.from_aabb = ShapeAABB:new();
					if(not from_dx) then
						from_dx, from_dy, from_dz = 0, 0, 0;
					end
					params.from_aabb:SetPointAABB(vector3d:new({from_x, from_y, from_z}));
					params.from_aabb:Extend(vector3d:new({from_x+from_dx, from_y+from_dy, from_z+from_dz}));

					NPL.load("(gl)script/apps/Aries/Creator/Game/Tasks/MirrorBlocksTask.lua");
					local task = MyCompany.Aries.Game.Tasks.MirrorBlocks:new(params);
					task:Run();
				end
			end
		end
	end,
};


Commands["setcolor"] = {
	name="setcolor", 
	quick_ref="/setcolor [x y z] [#rgb]", 
	desc=[[set block color. Only certain color block can be painted this way.
@param x y z: block position, if not provided, it is the block where the player is standing
@param rgb: #rgb value default to "#ffffff" white color
Example:
	/setcolor #ff0000    paint block at player position Red.
	/setcolor 10 10 10 #ff0000    paint block at world pos to red color
	/setcolor ~ ~1 ~ #ff0000	paint with relative to player position. 
	]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		local x, y, z, color;
		x, y, z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
		if(not x) then
			x, y, z = EntityManager.GetPlayer():GetBlockPos();
			y = y - 1;
		end
		if(x) then
			local block_template = BlockEngine:GetBlockTemplateByIdx(x, y, z);
			if(block_template and block_template.color_data) then
				color, cmd_text = CmdParser.ParseColor(cmd_text, "#ffffff");
				if(color) then
					local item = block_types.GetItemClass("ItemColorBlock");
					if(item and item.PaintBlock) then
						color = Color.ToValue(color);
						item:PaintBlock(x,y,z, color);
					end
				end
			else
				GameLogic.AddBBS(nil, L"只能给特殊的ColorBlock上色");
			end
		end
		return false;
	end,
};

Commands["editblock"] = {
	name="editblock", 
	quick_ref="/editblock [x y z] [editorname]", 
	desc=[[open editor for the given blocks
@param x y z: block position, if not provided, it is the block where the player is standing
@param editorname: default to "entity" editor.
Example:
/editblock		:block at player position
/editblock ~ ~1 ~      :relative to player position. 
	]], 
	handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
		local x, y, z, editorname;
		x, y, z, cmd_text = CmdParser.ParsePos(cmd_text, fromEntity);
		if(not x) then
			x, y, z = EntityManager.GetPlayer():GetBlockPos();
			y = y - 1;
		end
		editorname, cmd_text = CmdParser.ParseString(cmd_text);
		if(x) then
			local entity = EntityManager.GetBlockEntity(x, y, z);
			if(entity) then
				entity:OpenEditor(editor_name, fromEntity);
			end
		end
	end,
};