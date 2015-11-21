--[[
Title: Debug window of a given user
Author(s): WD
Date: 2011/06/23
use the lib:
"(gl)script/kids/3DMapSystemApp/DebugApp/DebugConsole.lua"
]]
local DebugConsole = commonlib.gettable("Map3DSystem.App.DebugConsole");

NPL.load("(gl)script/ide/common_control.lua");


--[[
initialize console prog
]]
function DebugConsole.OnInit()
	DebugConsole.page = document:GetPageCtrl();
	DebugConsole.ViewVariables = {};
end

--[[
implements all controls command process
@param:default argument for control name
]]
function DebugConsole.Main_Func(e)
    if type(e) ~= "string" then return; end

	-- preload NPL file
    if e=="btnLoadNPL" then
		local ctrl = DebugConsole.page:FindControl("sltLoadedNPLFile");
        if(ctrl) then 
			local fileName = ctrl:GetText();
	
			if(fileName ~= nil) then
				DebugConsole.LoadNPL(fileName);
			end
		end
        return;
    -- view state variables
    elseif e== "btnView" then
        if(DebugConsole.page) then
            DebugConsole.page:CallMethod("pegvwVariablesView", "SetDataSource", DebugConsole.GetViewVariables());
            DebugConsole.page:CallMethod("pegvwVariablesView", "DataBind");
        end
		return;

	elseif e == "btnClearView" then
		if(DebugConsole.page) then
            DebugConsole.page:CallMethod("pegvwVariablesView", "SetDataSource",{});
            DebugConsole.page:CallMethod("pegvwVariablesView", "DataBind");
			DebugConsole.ViewVariables = {};
        end
		return;

    -- execute NPL code 
    elseif e == "btnExecNPL" then
        local ctrl = DebugConsole.page:FindControl("rthNPL");
        if(ctrl) then  
			DebugConsole.SaveCode("lastcode");
			NPL.DoString(ctrl:GetText());
		end
        return;

    -- clear NPL code
    elseif e== "btnClear" then
        local ctrl = DebugConsole.page:FindControl("rthNPL");
        if(ctrl) then  
			ctrl:SetText("")
		end
        return;

    -- save NPL code to history
    elseif e =="btnSave" then
        DebugConsole.SaveCode();
        return;
    end
end

--[[
implements update history code file after runned
@param: history code file list
]]
function DebugConsole.UpdateHistoryDoCodeFiles(sCtrlName)
	DebugConsole.page:CallMethod(sCtrlName, "SetDataSource", DebugConsole.GetDataSource());
	DebugConsole.page:CallMethod(sCtrlName, "DataBind");--specify false to refresh UI,false is default value
end

--[[
implements save history code file to local
@param: filename to be saved
]]
function DebugConsole.SaveCode(filename)
    local ctrl = DebugConsole.page:FindControl("rthNPL");
    if(ctrl) then  
		local text = ctrl:GetText();
					
		local filename = filename or string.sub(text, 1, 50);
		filename = string.gsub(filename, "%A", "");
		filename = string.sub(filename, 1, 20);
		if(filename~="") then				
			local fullName = "temp/apps/"..string.gsub("Debug_GUID", "%W", "").."/" .. filename;
			local fileObj = ParaIO.open(fullName..".txt", "w");

			if(fileObj:IsValid()) then
				fileObj:WriteString(text);	
			end	
			fileObj:close();
			DebugConsole.UpdateHistoryDoCodeFiles("pegvwDebugDostringHistory");
		else
			_guihelper.MessageBox("Can not save empty code.\n")	
		end	
	end
end

--[[
	open code file to modify
	@param strlName:the control to show NPL code string
	@param filepath:NPL code file to be load
]]
function DebugConsole.OnOpenCodeFile(sCtrlName,filepath, NoMessage)
	local fileObj = ParaIO.open(filepath, "r");
	if(fileObj:IsValid()) then
		local ctl = DebugConsole.page:FindControl(sCtrlName);
		if(ctl~=nil)then
			ctl:SetText(fileObj:GetText());
		else
			commonlib.echo("can not find control \"" .. sCtrlName .. "\" on this page.\n");
		end
		fileObj:close();
	elseif(not NoMessage) then
		_guihelper.MessageBox("Unable to open file "..filepath);
	end	
end

--[[
	delete NPL file by full-filepath
	@param:filepath of NPL file
]]
function DebugConsole.OnDeleteDoCodeFileNode(filePath)
	if(type(filePath) == "string" and filePath ~= nil) then
		-- call the event handler if any
		_guihelper.MessageBox("Are you sure you want to delete the file: "..filePath.."?",  function ()
			ParaIO.DeleteFile(filePath);
			DebugConsole.UpdateHistoryDoCodeFiles("pegvwDebugDostringHistory");
		end)
	end
end

--[[
	dofile execuable NPL file 
	@param: NPL file name,e.g."(gl)script/kids/3DMapSystemApp/DebugApp/DebugConsole.lua"
]]
function DebugConsole.LoadNPL(fileName)
	if(type(fileName) == "string" and fileName ~= "") then
		NPL.load(fileName);
	end
end

--[[
	return history of code file
]]
function DebugConsole.GetDataSource()
	local files = {};
	local i, file
	local dir = "temp/apps/"..string.gsub("Debug_GUID", "%W", "").."/";
	commonlib.SearchFiles(files, dir, "*.txt", 0, 150, true)
	
	DebugConsole.HistoryDataSource = {};

	for i, file in ipairs(files) do
		local _,_,filename= string.find(file, "(%w+)%.txt$");
		local filepath = dir .. file;
		local item = {
			filename = filename,
			filepath = filepath,
		}
		table.insert(DebugConsole.HistoryDataSource,item);
	end
	return DebugConsole.HistoryDataSource;
end

--[[
	return variables information by var name
]]
function DebugConsole.GetViewVariables()
	local ctrl = DebugConsole.page:FindControl("txtVarName");
	if(ctrl == nil )then 
		commonlib.echo("control is nil.");
		return {} 
	end
	
	local varName = ctrl.text;
	local varValue;
	local _,_,tableName = string.find(varName,"(%w+)%.(%w+)$");
	if(not tableName) then
		varValue = _G[varName];	
	else
		local typ = type(_G[tableName]);
		if(typ == "table") then
			local _,_,subTable = string.find(varName,tableName .. "%.(%w+)$");
	
			varValue = _G[tableName][subTable]			
		else
			varValue = _G[tableName];
		end
		
	end

	if(not varValue) then return {} end;
	local varTyp = type(varValue);
	if(varTyp == "function" or varTyp == "table") then
		local _,_,adr = string.find(tostring(varValue),varTyp .. "%: (%w+)$");
		varValue = "0x" .. adr;
	end

	local item = { Name= varName,Value=varValue,Type=varTyp};

	local i = 0;
	local hold = false;
	for i in ipairs(DebugConsole.ViewVariables) do
		if(DebugConsole.ViewVariables[i].Name == item.Name) then
			hold = true;
		end
	end

	if(hold == false) then
		table.insert(DebugConsole.ViewVariables,item);
	end

	return  DebugConsole.ViewVariables;        
end

