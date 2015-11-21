--[[
Title: a common class for processing template files
Author(s): LiXizhi
Date: 2008/9/19
Desc: it will intelligently replace files defined in template_files. It will use all startup form variables as file replaceables, plus an internal variable output, which is the file name
as a convention, commonly used variable names are 
| name | name of the module |
| location | location of the module, WITHOUT the trailing slash. |
| date | such as 2008/9/19 |
| package | the global namespace, such as "MyCompany.MyApp" |
| output | internal variable, it is the output file path for the current template file. |

---++ Example Usage
please see MCMLPage/*.* and NPL_File/*.*

---++ template file example
variables in template files are %name%, if you want to use its verbatim form, use %$name%, see ProjectTemplate/templateStartup.html for an example.
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/ProjectTemplates/TemplateProcessor.lua");
local template_files = {
	{filename = "script/ide/ProjectTemplates/Templates/MCMLPage/templatePage.lua.template", output="%location%/%name%.lua", },
	{filename = "script/ide/ProjectTemplates/Templates/MCMLPage/templatePage.html.template", output="%location%/%name%.html", },
}
ProjectTemplates.TemplateProcessor.OnInit()
ProjectTemplates.TemplateProcessor.OnSubmit(btnName, values, template_files)
-------------------------------------------------------
]]

local TemplateProcessor = {};
commonlib.setfield("ProjectTemplates.TemplateProcessor", TemplateProcessor)

---------------------------------
-- example template files
---------------------------------
local template_files = {
	{filename = "script/ide/ProjectTemplates/Templates/TemplateProcessor/templatePage.lua", output="%location%/%name%.lua", },
	{filename = "script/ide/ProjectTemplates/Templates/TemplateProcessor/templatePage.html", output="%location%/%name%.html", },
}

-- call this function in mcml page OnInit function to set commonly used form variables.
function TemplateProcessor.OnInit()
	local self = document:GetPageCtrl();
	local name = self:GetRequestParam("name")
	local location = self:GetRequestParam("location")
	
	self:SetNodeValue("name", name);
	self:SetNodeValue("location", location);
	self:SetNodeValue("date", ParaGlobal.GetDateFormat("yyyy/M/d"));
end

-- call this function to handle mcml page event. 
-- @param template_files: see the example template files.
function TemplateProcessor.OnSubmit(btnName, values, template_files)
	local pageCtrl = document:GetPageCtrl();
	
	if(btnName=="save")then
		-- validate form values
		values.location = string.gsub(values.location, "\\", "/")
		
		-- create a rule mapping using all form values
		NPL.load("(gl)script/ide/rulemapping.lua");
		local replaceables = {};
		local n, v;
		for n, v in pairs(values) do
			replaceables["%%"..n.."%%"] = v;
		end
		
		local rulemap = CommonCtrl.rulemapping:new({
			replaceables=replaceables, 
		})
		
		-- reduce one file after another
		local index = 1;
		local function ProduceFile_()
			local template = template_files[index];
			if(type(template) == "table" and template.output) then
				local output = rulemap(template.output, true);
				
				-- generate a text file output with text content
				local function GenFile_()
					ParaIO.CreateDirectory(output)
					local out = ParaIO.open(output, "w")
					if(out:IsValid()) then
						local content = TemplateProcessor.LoadTemplate(template.filename);
						if(content) then
							content = TemplateProcessor.NormalizeLineEnding(content)
							content = rulemap(content, true)
							content = string.gsub(content, "%%%$(%w+)%%", "%%%1%%")
							out:WriteString(content);
							log("successfully generated file "..output.."\n");
							index = index + 1
							ProduceFile_();
						else
							log("failed to generate file "..output..", because source template file does not exist\n");
						end	
						out:close();
					else
						log("failed to generate file "..output.."\n");
					end
				end
		
				if(ParaIO.DoesFileExist(output, false)) then
					_guihelper.MessageBox(string.format("file %s already exist, do you want to overwrite it?", output), GenFile_)
				else
					GenFile_();	
				end
			else
				_guihelper.MessageBox("successfully created files!")
				pageCtrl:CloseWindow();	
			end
		end
		ProduceFile_();
		
	elseif(btnName=="cancel")then
		pageCtrl:CloseWindow();
	end
end

-- load a template file and return its content
function TemplateProcessor.LoadTemplate(filename)
	local file = ParaIO.open(filename, "r");	
	if(file:IsValid()) then
		local body = file:GetText();
		if(type(body)=="string") then
			file:close();			
			return body;
		end
		file:close();
	end	
 end
 
-- if the text line seperator "\n" is replaced by "\r\n"
function TemplateProcessor.NormalizeLineEnding(text)
	text = string.gsub(text, "\r\n", "\n");
	return string.gsub(text, "\n", "\r\n");
end

-- THIS is never used. just ported from leio's old code
function TemplateProcessor.ValidateName(str)
	local errormsg="";
	local reservedName = "";
		str = string.gsub(str,"%s*$","");
		str = string.gsub(str,"^%s*","");
		str = string.gsub(str,"%.*$","");
		str = string.gsub(str,"^%.*","");
		
	if(string.find(str,"[%c~!@#$%%^&*()=+%[\\%]{}''\";:/?,><`|!￥…（）-、；：。，》《]")) then
			errormsg = errormsg.."不能含有特殊字符\n"
	end
	
	if(string.len(str)<3) then
			errormsg = errormsg.."名称太短\n"
	end
	return errormsg,str;
end

