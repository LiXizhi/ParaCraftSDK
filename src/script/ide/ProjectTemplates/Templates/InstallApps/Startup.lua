--[[
Title: code behind page
Author(s): Leio Zhang
Date: 2008/4/8, refactored by LXZ 2008.9.19
Desc: 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/ProjectTemplates/Templates/InstallApps/Startup.lua");
-------------------------------------------------------
]]

local InstallApps = {};
commonlib.setfield("ProjectTemplates.InstallApps", InstallApps)

function InstallApps.OnInit()
	local self = document:GetPageCtrl();
	local name = self:GetRequestParam("name")
	local location = self:GetRequestParam("location")

	InstallApps.Page = self;
	InstallApps.LastPageIndex = "1";
	
	self:SetNodeValue("instance_name", name)
	self:SetNodeValue("filepath", location)	
	self:SetNodeValue("date_txt", ParaGlobal.GetDateFormat("yyyy/M/d"));
	
	self:SetNodeValue("package", "MyCompany")
	self:SetNodeValue("title", name)
	self:SetNodeValue("app_name", name)
	self:SetNodeValue("install_Path", location)
end

function InstallApps.OnClickPageIndex(value)
	if(value) then
		value = tostring(value);
		-- hide last
		if(InstallApps.LastPageIndex and InstallApps.LastPageIndex~=value) then
			local editor = InstallApps.Page:FindControl("editor_"..InstallApps.LastPageIndex);
			if(editor)then
				editor.visible = false;
			end
		end
		-- show current
		local editor = InstallApps.Page:FindControl("editor_"..value);
		if(editor)then
			editor.visible = true;
		end
		InstallApps.LastPageIndex = value;
		InstallApps.Page:SetUIValue("pageindex", tostring(value));
	end
end

function InstallApps.btn_click(btnName, values) 
	local index = tonumber(InstallApps.LastPageIndex);
	--_guihelper.MessageBox(commonlib.serialize(nodepath))
	if(btnName =="pre_btn")then
		if( index>1 )then
			index = index -1;
			InstallApps.Page:SetUIValue("pageindex", tostring(index));
			InstallApps.OnClickPageIndex(tostring(index));
		end
	elseif(btnName =="next_btn")then
		if( index<3 )then
			index = index + 1;
			InstallApps.Page:SetUIValue("pageindex", tostring(index));
			InstallApps.OnClickPageIndex(tostring(index));
		end
	elseif(btnName =="finish_btn")then
		if(InstallApps.DoFinish(values)) then
			InstallApps.Page:CloseWindow();
		end
		
	elseif(btnName =="cancel_btn")then
		InstallApps.Page:CloseWindow();
	end
end
function InstallApps.DoFinish(input)
	if(input == nil )then return end
	local body = InstallApps.LoadTemplate("script/ide/ProjectTemplates/Templates/InstallApps/file/app_simple.lua.template")
	local templateStr = InstallApps.ProgressFile(input,body)
	local luaBoolean = InstallApps.GenerateFile(templateStr,input.filepath,input.fileName,input.fileType)
	
	local input_xml = commonlib.deepcopy(input)
	   input_xml.fileName = "IP";
	   input_xml.fileType = ".xml";
		   
	body = InstallApps.LoadTemplate("script/ide/ProjectTemplates/Templates/InstallApps/file/app_simple.lua.IP.xml.template")
	templateStr = InstallApps.ProgressFile(input_xml,body)
	local xmlBoolean = InstallApps.GenerateFile(templateStr,input_xml.filepath,input_xml.fileName,input_xml.fileType)
	local dbBoolean = InstallApps.DBRegistration(input.autoInsertDB, input)
	if(luaBoolean and xmlBoolean and dbBoolean) then
		_guihelper.MessageBox("成功生成文件!");
		return true
	else
		_guihelper.MessageBox("失败!");
	end
end
function InstallApps.LoadTemplate(filaPath)
	local file = ParaIO.open(filaPath, "r");	
	if(file:IsValid()) then
		local body = file:GetText();
		if(type(body)=="string") then
			file:close();			
			return body;
		end
		file:close();
	end	
 end
 
 function InstallApps.ProgressFile(input,templateStr)
	if(templateStr==nil)then return ; end
	templateStr = InstallApps.NormalizeReturnString(templateStr)
	local instanceName = input.instance_name;
	local fileName = input.fileName;
	local fileType = input.fileType;
	local install_path = input.filepath;
	local filepath = input.filepath.."/"..fileName..fileType;
	local title  = input.title;
	local author = input.author;
	local date_txt = input.date_txt;
	local description = input.description;
	
	local package = input.package;
	
	templateStr=string.gsub(templateStr,"%%instance_name%%",instanceName);
	templateStr=string.gsub(templateStr,"%%install_path%%",install_path);
	templateStr=string.gsub(templateStr,"%%file_path%%",filepath);
	templateStr=string.gsub(templateStr,"%%package%%",package);
			
	templateStr=string.gsub(templateStr,"%%title%%",title);
	templateStr=string.gsub(templateStr,"%%author%%",author);
	templateStr=string.gsub(templateStr,"%%date%%",date_txt);
	templateStr=string.gsub(templateStr,"%%description%%",description);
	
	return templateStr;
	
 end
 function InstallApps.GenerateFile(input,filepath,fileName,fileType)	
	filepath = filepath.."/";
	local outputfile = ParaIO.GetParentDirectoryFromPath(filepath,0)..fileName..fileType;
	ParaIO.CreateDirectory(outputfile)
	commonlib.echo(outputfile) -- remove this
	local out = ParaIO.open(outputfile, "w")
	if(out:IsValid()) then
		out:WriteString(input);
		out:close();
		return true;
	else
		return false;
	end
 end
 
 -- if the text line seperator "\n" is replaced by "\r\n"
function InstallApps.NormalizeReturnString(text)
	text = string.gsub(text, "\r\n", "\n");
	return string.gsub(text, "\n", "\r\n");
end

--db registration 
function InstallApps.DBRegistration(bool, values)
	if(bool == nil or bool ==false) then return true; end
	if(bool)then
		--local sqlstr = InstallApps.GetSqlString(values);
		--local db = Map3DSystem.App.Registration.ConnectToAppDB();
		--
		--local cmd = "INSERT INTO apps VALUES".. InstallApps.GetSqlString();	
		--db:exec(cmd);
		return true;
	end
end

-- obsoleted
function InstallApps.GetSqlString(default)
	local str ="(NULL, '%instance_name%_GUID', '%instance_name%', '1.0.0', 'http://www.paraengine.com/apps/%instance_name%_v1.zip', 'YourCompany', 'enUS', '%install_path%/IP.xml', '', '%file_path%', '%package%.%instance_name%.MSGProc', %isLoaded%)";
	str=string.gsub(str,"%%instance_name%%",default.instance_name);
	str=string.gsub(str,"%%install_path%%",default.filepath);
	str=string.gsub(str,"%%package%%",default.package);
	local isLoaded;
	if(default.isLoaded)then isLoaded = 1; else isLoaded = 0 ; end
	str=string.gsub(str,"%%isLoaded%%",isLoaded);
	
	local fileName = default.fileName;
	local fileType = default.fileType;
	local filepath = default.filepath.."/"..fileName..fileType;
	str=string.gsub(str,"%%file_path%%",filepath);
	return str;
end
