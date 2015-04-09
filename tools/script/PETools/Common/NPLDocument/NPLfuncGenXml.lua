--[[
Title: 
Author: Spring Yan
Date : 2010.6.11
NPL.load("(gl)script/PETools/Common/NPLDocument/NPLfuncGenXml.lua");

Desc: This script according "script/PETools/Common/NPLDocument/NPLfunclist.table" to parse functions in NPL files

sample of NPLfunclist.lua:

commonlib0={"--print","app--print","echo"}
XPath0={"selectNodes","eachNode"}

Variables={
{name="commonlib",url={"script/ide/--print.lua","script/ide/serialization.lua"}},
{name="XPath",url="script/ide/XPath.lua",ns="commonlib.XPath"}
}

]]

NPL.load("(gl)script/ide/commonlib.lua");

local NPLfuncGenXml=commonlib.gettable("commonlib.NPLfuncGenXml");
local config={
	outputfile="script/PETools/Common/NPLDocument/NPLfuncDoc.xml",
}

function NPLfuncGenXml.GetMemberFunctions(bodyText,classname)
	local memFuncs = {}
	local comments, syntax;

	for comments, ns, temp, syntax in string.gfind(bodyText, "\n(%-%-%s*@namespace.-\n)("..classname.."%..%a*%s*)(.-__call%s*=%s*)(function[^\n]*)") do
		local memFunc = {};
		memFunc.syntax = syntax;	
		local _,_, name, params = string.find(syntax, "function%s*([^%(]-)%s*%(([^%)]-)%)")
		ns = string.gsub(ns,"%s*$","")
		memFunc.name = string.gsub(ns, "^%s*"..classname.."%.", "")

		----print("========================")	
		----print(comments)
		----print(syntax)
				
		if(params) then
			local param
			for param in string.gfind(params,"(%w+)") do
				param = string.gsub(param, "%s*$", "")
				param = string.gsub(param, "^%s*", "")
				if(param~="") then
					memFunc.params = memFunc.params or {};
					table.insert(memFunc.params, param);
				end	
			end
		end
		if(memFunc.name) then
			table.insert(memFuncs, memFunc);
		end

		memFunc.desc = string.gsub(comments, "\n%-*%s*@%s*(%w+)%s*(%w*):?", "\n   * _%1_ __%2__ :");
		local type, paramName, paramDoc;
		for type, paramName, paramDoc in string.gfind(comments,"\n%-*%s*@%s*(%w+)%s*(%w*)%s*:?%s*([^@]*)") do
			paramDoc = string.gsub(paramDoc, "%s*\n%s*$", "");
			if(type == "return" or type == "returns") then
				paramName = "return";
				memFunc.params = memFunc.params or {};
				table.insert(memFunc.params, paramName);
				
				memFunc.paramsDoc = memFunc.paramsDoc or {};
				memFunc.paramsDoc[paramName] = paramDoc;
			end
		end
		
	end  

	for comments, syntax in string.gfind(bodyText, "\r\n(\r\n%-%-.-\r\n)(function [^\r\n]*)") do
		local memFunc = {};
		memFunc.syntax = syntax;
		--
		-- get params and function name from syntax
		--
		--print("========================")	
		--print(string.match(bodyText, "(\n%-%-.-\n)(function [^\n]*)"))
		--print(syntax)		
		
		local _,_, name, params = string.find(syntax, "function%s+([^%(]-)%s*%(([^%)]-)%)")
		if(name) then
			memFunc.name = string.gsub(name, "%s*"..classname.."%.", "")
		end	
		
		if(params) then
			local param
			for param in string.gfind(params,"(%w+)") do
				param = string.gsub(param, "%s*$", "")
				param = string.gsub(param, "^%s*", "")
				if(param~="") then
					memFunc.params = memFunc.params or {};
					table.insert(memFunc.params, param);
				end	
			end
		end
		if(memFunc.name) then
			table.insert(memFuncs, memFunc);
		end
		--
		-- get parasDoc from comments
		--
		memFunc.desc = string.gsub(comments, "\n%-*%s*@%s*(%w+)%s*(%w*):?", "\n   * _%1_ __%2__ :");
		local type, paramName, paramDoc;
		for type, paramName, paramDoc in string.gfind(comments,"\n%-*%s*@%s*(%w+)%s*(%w*)%s*:?%s*([^@]*)") do
			paramDoc = string.gsub(paramDoc, "%s*\n%s*$", "");
			if(type == "return" or type == "returns") then
				paramName = "return";
				memFunc.params = memFunc.params or {};
				table.insert(memFunc.params, paramName);
				
				memFunc.paramsDoc = memFunc.paramsDoc or {};
				memFunc.paramsDoc[paramName] = paramDoc;
			end
		end
	end

	return memFuncs;
end

function NPLfuncGenXml.ProcessNPLFile(text,class,classname)
	local _,_, header,body = string.find(text, "^%s*%-%-%[%[(.-\n)%]%](.*)$")
	local func_id=nil;	
	local headerInfo;
	local output="";
	
	if(header) then
	else
		body = text;
	end
	--
	-- body: member functions, table definition, global variables (attributes)
	--
	if(body) then
		--
		-- member functions
		--
		local memFuncs = NPLfuncGenXml.GetMemberFunctions(body,classname)
		
		
		if(table.getn(memFuncs)>0) then
			local i, memFunc
			if (table.getn(class))>0 then
				func_name= commonlib.serialize(class)			
				-- --print(func_name)
				
				for i,memFunc in ipairs(memFuncs) do 
					func_id=nil
					----print(memFunc.name)
					----print(string.find(func_name,memFunc.name))
					if string.find(func_name,memFunc.name) then
						output=output..string.format('		<function name="%s">', memFunc.name).."\n";						
						--print(string.format('		<function name="%s">\n', memFunc.name))	
						func_id=1
						if(memFunc.desc) then
						-- --print(string.format('	<summary>%s</summary>', memFunc.desc))
							output=output..string.format('			<summary><![CDATA[ %s ]]></summary>',memFunc.desc).."\n";
							--print(string.format('			<summary>%s</summary>\n',memFunc.name))
						end
				
						if(memFunc.params and table.getn(memFunc.params)>0 ) then
						-- output params:
							local _;					
							for _, param in ipairs(memFunc.params) do
							
								if(param=="return") then
									output=output..string.format("			<returns>%s</return>", memFunc.paramsDoc[param] or "").."\n";
									--print(string.format("			<returns>%s</return>\n", memFunc.paramsDoc[param] or ""))
								else
									output=output..string.format('			<parameter name="%s" />', param).."\n";
									--print(string.format('			<parameter name="%s" />\n', param))
								end	
							end	
						end -- if(memFunc.params
					end -- if string.find(func_name,memFunc.name)
					if func_id then
						output=output.."		</function>\n";
						--print("		</function>\n")
					end
				end -- for i,memFunc
			else
				for i,memFunc in ipairs(memFuncs) do 					
					output=output..string.format('		<function name="%s">', memFunc.name).."\n";
					--print(string.format('		<function name="%s">\n', memFunc.name))	
					if(memFunc.desc) then
					-- --print(string.format('			<summary>%s</summary>', memFunc.desc))
						output=output..string.format('			<summary><![CDATA[ %s ]]></summary>',memFunc.desc).."\n";
						--print(string.format('			<summary>%s</summary>\n',memFunc.name))
					end
				
					if(memFunc.params and table.getn(memFunc.params)>0 ) then
						-- output params:
						local _;
					
						for _, param in ipairs(memFunc.params) do

							if(param=="return") then
								output=output..string.format("			<returns>%s</return>", memFunc.paramsDoc[param] or "").."\n";
								--print(string.format("			<returns>%s</return>\n", memFunc.paramsDoc[param] or ""))
							else
								output=output..string.format('			<parameter name="%s" />', param).."\n";
								--print(string.format('			<parameter name="%s" />\n', param))
							end	
						end	
					end
					output=output.."		</function>\n";
					--print("		</function>\n")
				end	 -- for i,memFunc
			end	-- if (table.getn(class))
		end -- if(table.getn(memFuncs)
	end -- if(body)
	
	return output 
end

function NPLfuncGenXml.AnalysClass(item,url)
	local NPLfunclist=commonlib.LoadTableFromFile("script/PETools/Common/NPLDocument/NPLfunclist.table");
	local class=NPLfunclist[item]
	local classname=string.gsub(item,"0$","")
	--local class=commonlib.gettable(item.."0")
	local body=""
	local output=""
	
	----print(class)
	
	if type(url)=="string" then
	
		local f = ParaIO.open(url, "r")
		-- local f = assert(io.open(url, "r"))
		if(f:IsValid()) then
		--	body = f:read("*all")	
			body = f:GetText();
			f:close()
		end	
	elseif type(url)=="table"	then
		for i,fileurl in pairs(url) do
			local f = ParaIO.open(fileurl, "r")
		-- local f = assert(io.open(fileurl, "r"))
			if(f:IsValid()) then
			--	body = body..f:read("*all")	
				body = body..f:GetText();
				f:close()
			end
		end	
	end
	----print(body);
	----print("+++++++++++++++++++++++++++++++++++\n");
	output=NPLfuncGenXml.ProcessNPLFile(body,class,classname)
	
	return output
end

function NPLfuncGenXml_init()
	local out = ParaIO.open(config.outputfile, "w")
	out:WriteString('<?xml version="1.0" encoding="utf-8" ?>\n')
	--print('<?xml version="1.0" encoding="utf-8" ?>\n')
	out:WriteString("<doc>\n");
	--print("<doc>\n")
	out:WriteString("<tables>\n");
	--print("<tables>\n")
	local NPLfunclist=commonlib.LoadTableFromFile("script/PETools/Common/NPLDocument/NPLfunclist.table");
	for i,v in pairs(NPLfunclist.Variables) do
		local	classname=""
		local	classurl=""
		local	output=""
		
		for j,item in pairs(v) do
			if j=="name" then
				classname=item
			end
			if j=="url" then
				classurl=item
			end
		end
		if classname~="" then
			out:WriteString('	<table name="'..string.gsub(classname,"0$","")..'">\n');
			--print('	<table name="'..classname..'">\n')
			output=NPLfuncGenXml.AnalysClass(classname,classurl);
			out:WriteString(output);
			out:WriteString("	</table>\n");
			--print("	</table>\n")
		end	
	end
	out:WriteString("</tables>\n");
	--print("	</tables>\n");
	
	out:WriteString("<variables>\n");
	for i,v in pairs(NPLfunclist.Variables) do
		local	classname=""
		local namespace=""
		
		for j,item in pairs(v) do
			if j=="name" then
				classname=string.gsub(item,"0$","")
			end
			if j=="ns" then
				namespace=item
			end
		end
		if classname~="" then
			if namespace~="" then
				out:WriteString('	<variable name="'..classname..'" type="'..classname..'" ns="'..namespace..'"/> \n');
			else
				out:WriteString('	<variable name="'..classname..'" type="'..classname..'"/> \n');
			end
		end	
	end
	out:WriteString("</variables>\n");
	out:WriteString("</doc>\n");
	--print("</doc>\n")
	out:close()
end	