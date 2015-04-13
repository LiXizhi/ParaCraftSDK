--[[
Title: import 3d model 
Author(s): LiXizhi
Date: 2012.3.15
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/DataAPI/model_import.lua");
local model_import = commonlib.gettable("PETools.model_import");
model_import.load_from_file();
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/autotips.lua");
local model_import = commonlib.gettable("PETools.model_import");

-- convert absolute file to file relative to ParaEngine directory. 
-- @return relative_path, io_path
function model_import.normalize_filename(filename)
	if(not filename) then 
		return 
	end
	filename = filename:gsub("\\+", "/");
	if(filename:match(":")) then
		filename = ParaIO.GetRelativePath(filename, ParaIO.GetCurDirectory(0));
		
		if(filename:match(":")) then
			local root_directory = ParaIO.AutoFindParaEngineRootPath(filename);
			local relative_filename = ParaIO.GetRelativePath(filename, root_directory);
			return relative_filename, filename;
		end
	end
	return filename, filename;
end

-- load any supported file types to the current scene. 
-- @param filename: absolute or relative filepath
function model_import.load_from_file(filename)
	commonlib.log("enter load from file...............\n");
	local filename, io_filename = model_import.normalize_filename(filename);
	if(not filename) then
		return
	end
	-- _guihelper.MessageBox({filename, io_filename});

	local ext = string.match(io_filename, "%.(%w+)$");
	if(ext ~= nil) then
		ext = string.lower(ext);
	end
	-- change file extension.
	if(ext == "max") then
		filename = filename:gsub("max$", "x");
		io_filename = io_filename:gsub("max$", "x");
		ext = "x";
	end

	if(filename ~= io_filename) then
		autotips.AddMessageTips(format("warning: 文件是绝对路径", io_filename));
	else
		autotips.AddMessageTips(format("%s", io_filename));
	end

	if(not ParaIO.DoesFileExist(io_filename)) then
		_guihelper.MessageBox(format("%s not found", io_filename));
	elseif(ext == "x" or ext == "xml") then
		-- refresh the file. 
		local asset = Map3DSystem.App.Assets.asset:new({filename = io_filename})
		
		local objParams = asset:getModelParams()
		if(objParams~=nil) then
			-- create object by sending a message
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, progress=1, obj_params=objParams});
		end
	elseif(ext == "iges" or ext == "step")then
		local asset = ParaAsset.LoadStaticMesh("",filename);
		local obj = ParaScene.CreateMeshPhysicsObject("igesTest", asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
		obj:SetPosition(ParaScene.GetPlayer():GetPosition());
		obj:GetAttributeObject():SetField("progress",1);
		ParaScene.Attach(obj);
	else
		_guihelper.MessageBox(format("unknown file: %s", io_filename));
	end
end