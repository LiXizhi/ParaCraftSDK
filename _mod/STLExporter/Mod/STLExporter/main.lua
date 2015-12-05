--[[
Title: bmax exporter
Author(s): leio, refactored LiXizhi
Date: 2015/11/25
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/STLExporter/main.lua");
local STLExporter = commonlib.gettable("Mod.STLExporter");
local exporter = STLExporter:new();
exporter:Export("test/default.bmax",nil,true);
------------------------------------------------------------
]]
local CmdParser = commonlib.gettable("MyCompany.Aries.Game.CmdParser");	

local STLExporter = commonlib.inherit(commonlib.gettable("Mod.ModBase"),commonlib.gettable("Mod.STLExporter"));

function STLExporter:ctor()
end

-- virtual function get mod name
function STLExporter:GetName()
	return "STLExporter"
end

-- virtual function get mod description 
function STLExporter:GetDesc()
	return "STLExporter is a plugin in paracraft"
end

function STLExporter:init()
	LOG.std(nil, "info", "STLExporter", "plugin initialized");

	self:RegisterCommand();
	self:RegisterExporter();
end

function STLExporter:OnLogin()
end
-- called when a new world is loaded. 

function STLExporter:OnWorldLoad()
end
-- called when a world is unloaded. 

function STLExporter:OnLeaveWorld()
end

function STLExporter:OnDestroy()
end

-- add plugin integration points with the IDE
function STLExporter:RegisterExporter()
	GameLogic.GetFilters():add_filter("GetExporters", function(exporters)
		exporters[#exporters+1] = {id="STL", title="STL exporter", desc="export stl files for 3d printing"}
		return exporters;
	end);

	GameLogic.GetFilters():add_filter("select_exporter", function(id)
		if(id == "STL") then
			id = nil; -- prevent other exporters
			self:OnClickExport();
		end
		return id;
	end);
end

function STLExporter:RegisterCommand()
	local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");
	Commands["stlexporter"] = {
		name="stlexporter", 
		quick_ref="/stlexporter [-b|binary] [-native|cpp] [filename]", 
		desc=[[export a bmax file or current selection to stl file
@param -b: export as binary STL file
@param -native: use C++ exporter, instead of NPL.
/stlexporter test.stl			export current selection to test.stl file
/stlexporter -b test.bmax		convert test.bmax file to test.stl file
]], 
		handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
			local file_name, options;
			options, cmd_text = CmdParser.ParseOptions(cmd_text);
			file_name,cmd_text = CmdParser.ParseString(cmd_text);

			local save_as_binary = options.b~=nil or options.binary~=nil;
			local use_cpp_native = options.native~=nil or options.cpp~=nil;
			self:Export(file_name,nil, save_as_binary, use_cpp_native);
		end,
	};
end

function STLExporter:OnClickExport()
	NPL.load("(gl)script/apps/Aries/Creator/Game/GUI/SaveFileDialog.lua");
	local SaveFileDialog = commonlib.gettable("MyCompany.Aries.Game.GUI.SaveFileDialog");
	SaveFileDialog.ShowPage("please enter STL file name", function(result)
		if(result and result~="") then
			STLExporter.last_filename = result;
			local filename = GameLogic.GetWorldDirectory()..result;
			LOG.std(nil, "info", "STLExporter", "exporting to %s", filename);
			GameLogic.RunCommand("stlexporter", filename);
		end
	end, STLExporter.last_filename or "test", nil, "stl");
end

-- @param input_file_name: file name. if it is *.bmax, we will convert this file and save output to *.stl file.
-- if it is not, we will convert current selection to *.stl files. 
-- @param output_file_name: this should be nil, unless you explicitly specify an output name. 
-- @param -binary: export as binary STL file
-- @param -native: use C++ exporter, instead of NPL.
function STLExporter:Export(input_file_name,output_file_name,binary,native)
	input_file_name = input_file_name or "default.stl";
	binary = binary == true;

	local name, extension = string.match(input_file_name,"(.+)%.(%w+)$");

	if(not output_file_name)then
		if(extension == "bmax") then
			output_file_name = name .. ".stl";
		elseif(extension == "stl") then
			output_file_name = name .. ".stl";
		else
			output_file_name = input_file_name..".stl";
		end
	end
	LOG.std(nil, "info", "STLExporter", "exporting from %s to %s", input_file_name, output_file_name);
	
	local res;
	if(native and ParaScene.BmaxExportToSTL)then
		-- use the C++ ParaEngine, functions may be limited. 
		res = ParaScene.BmaxExportToSTL(input_file_name,output_file_name, binary);
	else
		NPL.load("(gl)Mod/STLExporter/BMaxModel.lua");
		local BMaxModel = commonlib.gettable("Mod.STLExporter.BMaxModel");
		NPL.load("(gl)Mod/STLExporter/STLWriter.lua");
		local STLWriter = commonlib.gettable("Mod.STLExporter.STLWriter");

		local model = BMaxModel:new();
		if(extension == "bmax") then
			model:Load(input_file_name);
		else
			-- load from current selection
			local blocks = Game.SelectionManager:GetSelectedBlocks();
			if(blocks) then
				model:LoadFromBlocks(blocks);
			end
		end
		
		local writer = STLWriter:new();
		-- STL file uses Z up
		writer:SetYAxisUp(false);
		writer:LoadModel(model);

		if(binary)then
			res = writer:SaveAsBinary(output_file_name);
		else
			res = writer:SaveAsText(output_file_name);
		end
	end
	if(res)then
		_guihelper.MessageBox(format("Successfully saved STL file to :%s, do you want to open it?", commonlib.Encoding.DefaultToUtf8(output_file_name)), function(res)
			if(res and res == _guihelper.DialogResult.Yes) then
				ParaGlobal.ShellExecute("open", ParaIO.GetCurDirectory(0)..output_file_name, "", "", 1);
			end
		end, _guihelper.MessageBoxButtons.YesNo);
	end
end
