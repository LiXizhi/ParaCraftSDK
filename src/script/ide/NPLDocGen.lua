--[[
Title: Generating NPL wiki page documentation from source code. 
Author(s): LiXizhi
Date: 2008/3/12, 2008/10/23 gen change log added
Desc: This class is usually used with the unit test framework, to automatically generate 
a group of source code documentation from a configuration file
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/NPLDocGen.lua");
commonlib.NPLDocGen.GenerateTWikiTopic({
	WikiWord = "NPLDocGen",
	ClassName = "commonlib.NPLDocGen",
	input = {"script/ide/NPLDocGen.lua", 
		"script/ide/UnitTest/readme.lua",
	},
})

commonlib.NPLDocGen.GenerateChangeLogWiki({WikiWord = "ParaEngineChangeLog", TopicParent="ParaEngineDoc", HeaderText="---+++ ParaEngine Change History\r\n", input = {"changes.txt"},})

-- When can use the unit test framework, and put lots of below blocks in a single file to batch generate output for many files. 
%TESTCASE{"NPLDocGen", func="commonlib.NPLDocGen.GenerateTWikiTopic", input={WikiWord = "NPLDocGen", ClassName = "commonlib.NPLDocGen", input = {"script/ide/NPLDocGen.lua", "script/ide/mathlib.lua"},}}%
-------------------------------------------------------
]]
-- create class
local NPLDocGen = commonlib.gettable("commonlib.NPLDocGen");

-- default wiki generation input template
NPLDocGen.WikiInput = {
	-- the wiki word for documentation. 
	WikiWord = "NPLDocGen",
	-- array of input files or string script path. 
	-- if file is "*.lua" class and member functions are extracted
	-- if file is "readme.lua" all comment blocks are extracted.  
	-- if file is ".txt" all text are extracted. 
	input = {"script/ide/NPLDocGen.lua", "script/ide/mathlib.lua"},
	-- the output directory. If nil, it will default to script/doc/
	output = "script/doc/",
	-- string or nil, if nil or "", it will be same as WikiWord. Or it can be a fully qualified name, such as "commonlib.NPLDocGen"
	ClassName = nil,
	-- if nil, it defaults to "NPL"
	TopicParent = "NPL",
	-- if the file does not contain an author, use this one. 
	author = "LiXizhi",
	-- a short string description before table of content, this is usually nil.
	desc = nil,
	-- a post processing function string. it applies to "*.txt" and "readme.lua" files in the input. 
	-- such as "NPLDocGen.MakeValidMCMLWikiWords"
	PostProcessor = nil,
	-- a pre processing function string. it applies to all files in the input. 
	-- such as "NPLDocGen.PreProcRPCWrapperToFunction"
	PreProcessor = nil,
	-- if header is ignored, only the context body will be output, and no table of content is generated. 
	IgnoreHeader = nil;
}

-- create an instance. 
function NPLDocGen.WikiInput:new(o)
	o = o or {}   -- create object if user does not provide one
	if(type(o.input) == "string") then
		o.input = {o.input};
	end
	o.ClassName = o.ClassName or o.WikiWord;
	setmetatable(o, self)
	self.__index = self
	return o
end

----------------------------------------------
-- public methods
----------------------------------------------

-- generate the change log
-- @param input: {WikiWord = "ParaEngineChangeLog", TopicParent="ParaEngineDoc", HeaderText="---+++ ParaEngine Change History\r\n", input = {"changes.txt"},}
function NPLDocGen.GenerateChangeLogWiki(input)
	input = NPLDocGen.WikiInput:new(input)
	local outputfile = ParaIO.GetParentDirectoryFromPath(input.output,0)..input.WikiWord..".txt";
	ParaIO.CreateDirectory(outputfile)
	local out = ParaIO.open(outputfile, "w")
	if(out:IsValid()) then
		if(input.HeaderText)then
			out:WriteString(input.HeaderText);
		end
		local i,filename 
		for i,filename in ipairs(input.input) do
			-- for each file
			local src = ParaIO.open(filename, "r")
			if(src:IsValid()) then
				log(string.format("processing file: %s ", filename));
				-- TODO: We should rewrite this for robustness and performances
				local text = src:GetText();
				
				-- this allows for ansi code page (chinese characters) to convert to UTF-8 character encoding. 
				text = ParaMisc.EncodingConvert("", "utf-8", text)
				
				text = string.gsub(text, "\n\t\t%-", "\n      * ")
				text = string.gsub(text, "\n\t%-", "\n   * ")
				text = string.gsub(text, "<", "&lt;")
				text = string.gsub(text, ">", "&gt;")
				out:WriteString(text);
				
				log(string.format(".... done.\r\n"));
				src:close();
			else	
				log(string.format("error: failed opening file : %s for reading \r\n", filename));
			end
		end	
		out:close();
	else
		log(string.format("error: failed opening file : %s for writing when generate wiki topic \n", outputfile));
	end
end

--[[ generate a wiki page for the given set of input source files
twiki requires the following header file, where the second line is optional. 
	%META:TOPICINFO{author="LiXizhi" date="1204269972" format="1.1" reprev="1.1" version="1.1"}%
	%META:TOPICPARENT{name="TestConvert"}%
@param input: is a partial pure table of NPLDocGen.WikiInput
@see: "script/NPL_twiki_doc.lua" for more information. 
]]
function NPLDocGen.GenerateTWikiTopic(input)
	input = NPLDocGen.WikiInput:new(input)
	local outputfile = ParaIO.GetParentDirectoryFromPath(input.output,0)..input.WikiWord..".txt";
	ParaIO.CreateDirectory(outputfile)
	local out = ParaIO.open(outputfile, "w")
	if(out:IsValid()) then
		log(string.format("Output to wiki topic %s: %s \n", input.WikiWord, outputfile));
		-- Write the wiki header and parent topic if any
		-- TODO: replace author name with user specified
		out:WriteString([[%META:TOPICINFO{author="LiXizhi" date="1204269972" format="1.1" reprev="1.1" version="1.1"}%]]);
		out:WriteString("\r\n");
		if(input.TopicParent) then
			out:WriteString([[%META:TOPICPARENT{name="]]);
			out:WriteString(input.TopicParent)
			out:WriteString("\"}%\r\n")
		end	
		if(not input.IgnoreHeader) then
			if(input.ClassName) then
				out:WriteString(string.format("---++!! !%s\r\n", input.ClassName));
			else
				out:WriteString("---++!! !%TOPIC%\r\n");
			end	
			if(type(input.desc) =="string") then
				out:WriteString(string.format("__description__: %s\r\n\r\n", input.desc));
			end
			out:WriteString("%TOC{title=\"Contents:\"}%\r\n%STARTINCLUDE%\r\n");
		end	
		
		local i,filename 
		for i,filename in ipairs(input.input) do
			-- for each file
			local src = ParaIO.open(filename, "r")
			if(src:IsValid()) then
				log(string.format("processing file: %s ", filename));
				-- TODO: We should rewrite this for robustness and performances
				local text = src:GetText();
				if(input.PreProcessor) then
					local PreFunc = commonlib.getfield(input.PreProcessor);
					if(type(PreFunc) == "function") then
						text = PreFunc(text);
					end
				end
				text = NPLDocGen.NormalizeReturnString(text);
				
				-- this allows for ansi code page (chinese characters) to convert to HTML special character encoding. 
				text = ParaMisc.EncodingConvert("", "utf-8", text)
				
				if(string.find(filename, "%.txt$")) then
					--
					-- for txt file, just output every thing in it.
					--
					if(input.PostProcessor) then
						local postFunc = commonlib.getfield(input.PostProcessor);
						if(type(postFunc) == "function") then
							text = postFunc(text);
						end
					end
					out:WriteString(text);
				elseif(string.find(filename, "%.lua$")) then
					--
					-- for NPL source files 
					--
					NPLDocGen.ProcessNPLFile(input, filename, text, out);
				end
				log(string.format(".... done.\r\n"));
				src:close();
			else	
				log(string.format("error: failed opening file : %s for reading \r\n", filename));
			end
		end	
		if(not input.IgnoreHeader) then
			out:WriteString("%STOPINCLUDE%\r\n");
		end	
		out:close();
	else
		log(string.format("error: failed opening file : %s for writing when generate wiki topic \n", outputfile));
	end
end

--[[
generate a portal page with groups and items. 
@see: "script/NPL_twiki_doc.lua" for more information. 
]]
function NPLDocGen.GenerateTWikiPortalTopic(input)
	input = NPLDocGen.WikiInput:new(input)
	local outputfile = ParaIO.GetParentDirectoryFromPath(input.output,0)..input.WikiWord..".txt";
	ParaIO.CreateDirectory(outputfile)
	local out = ParaIO.open(outputfile, "w")
	if(out:IsValid()) then
		log(string.format("Output to wiki topic %s: %s \n", input.WikiWord, outputfile));
		-- Write the wiki header and parent topic if any
		-- TODO: replace author name with user specified
		out:WriteString([[%META:TOPICINFO{author="LiXizhi" date="1204269972" format="1.1" reprev="1.1" version="1.1"}%]]);
		out:WriteString("\r\n");
		if(input.TopicParent) then
			out:WriteString([[%META:TOPICPARENT{name="]]);
			out:WriteString(input.TopicParent)
			out:WriteString("\"}%\r\n")
		end	
		if(input.ClassName) then
			out:WriteString(string.format("---++!! %s\r\n", input.ClassName));
		else
			out:WriteString("---++!! %TOPIC%\r\n");
		end	
		out:WriteString("%TOC%\r\n");
		
		local i,filename 
		for i,filename in ipairs(input.input) do
			local src = ParaIO.open(filename, "r")
			if(src:IsValid()) then
				log(string.format("processing file: %s ", filename));
				-- TODO: We should rewrite this for robustness and performances
				local text = src:GetText();
				local group, grouptext;
				for group, grouptext in string.gfind(text, "%s*%-%-%[%[%s*[Gg]roup%s*=%s*(%w+)(.-)%]%]") do
					-- group name
					out:WriteString(string.format("---++ %s\r\n", group))
					local wikiword;
					for wikiword in string.gfind(grouptext, "WikiWord%s*=%s*\"(%w+)\"") do
						out:WriteString(string.format("   * [[%s]]\r\n", wikiword));
					end
				end
				log(string.format(".... done.\r\n"));
				src:close();
			else	
				log(string.format("error: failed opening file : %s for reading \r\n", filename));
			end
		end	
		out:close();
	else
		log(string.format("error: failed opening file : %s for writing when generate wiki topic \n", outputfile));
	end
end

--------------------------------
-- private functions
--------------------------------

-- process NPL source file.
-- @param filename: input file name
-- @param text: input file text
-- @param out: output file object
function NPLDocGen.ProcessNPLFile(input, filename, text, out)
	--
	-- header: title, author, date, description and sample code
	--
	local _,_, header,body = string.find(text, "^%s*%-%-%[%[(.-\r\n)%]%](.*)$")

	local headerInfo;
	if(header) then
		headerInfo = NPLDocGen.GetHeaderInfo(header)
		if(not input.IgnoreHeader) then
			if(headerInfo.Title) then
				out:WriteString(string.format("\r\n---++ %s\r\n", headerInfo.Title))
			end
			out:WriteString(string.format("| *Title* | %s |\r\n", headerInfo.Title or ""))
			out:WriteString(string.format("| *Author(s)* | %s |\r\n", headerInfo.Author or ""))
			out:WriteString(string.format("| *Date* | %s |\r\n", headerInfo.Date or ""))
			out:WriteString(string.format("| *File* | %s |\r\n", filename))
			
			out:WriteString(string.format("---+++ Description\r\n"))
			out:WriteString(headerInfo.Desc or "")
			if(headerInfo.SampleCode) then
				out:WriteString("\r\n%T% __Sample Code__\r\n")
				out:WriteString("<verbatim>\r\n")
				out:WriteString(headerInfo.SampleCode)
				out:WriteString("</verbatim>\r\n")
			end	
		end	
	else
		body = text;
	end

	if(string.find(filename, "readme%.lua$")) then
		--
		-- for readme.lua file, extract wiki block in it. 
		--
		if(header and body) then
			text = NPLDocGen.ExtractWikiText(body);
		end	
		if(input.PostProcessor) then
			local postFunc = commonlib.getfield(input.PostProcessor);
			if(type(postFunc) == "function") then
				text = postFunc(text);
			end
		end
		out:WriteString(text);
		return;
	end	
	--
	-- body: member functions, table definition, global variables (attributes)
	--
	if(body) then
		--
		-- member functions
		--
		local memFuncs = NPLDocGen.GetMemberFunctions(body)
		if(table.getn(memFuncs)>0) then
			out:WriteString(string.format("\r\n---+++ Member Functions\r\n"))
			local i, memFunc
			for i,memFunc in ipairs(memFuncs) do 
				out:WriteString(string.format("\r\n---++++ !%s\r\n", memFunc.name))	
				if(memFunc.desc) then
					out:WriteString(memFunc.desc)
				end
				if(memFunc.syntax) then
					out:WriteString("\r\n\r\n__syntax__\r\n<verbatim>")
					out:WriteString(memFunc.syntax)
					out:WriteString("</verbatim>\r\n")
				end	
				
				if(memFunc.params and table.getn(memFunc.params)>0 ) then
					-- output params:
					out:WriteString("\r\n\r\n__parameters__\r\n\r\n")
					local _;
					
					for _, param in ipairs(memFunc.params) do
						-- print all parameters in a table. 
						if(memFunc.paramsDoc) then
							out:WriteString(string.format("| *%s* | %s |\r\n", param, memFunc.paramsDoc[param] or ""))
						else
							out:WriteString(string.format("| *%s* |  |\r\n", param))
						end	
					end	
				end
				if(memFunc.codes) then
					-- output codes: like @code: script/test/abc.xml.
					out:WriteString("\r\n\r\n__source code samples__\r\n\r\n")
					local _, code
					for _,code in ipairs(memFunc.codes) do
						local codepath = code.codepath;
						if(codepath and ParaIO.DoesFileExist(codepath)) then
							local _,_, fileext = string.find(codepath, "%.(%w+)$");
							local filetype;
							if(fileext) then
								fileext = string.lower(fileext);
								if(fileext=="html" or fileext=="htm") then
									filetype = "html"
								elseif(fileext=="xml") then
									filetype = "xml"
								elseif(fileext=="lua") then
									filetype = "lua"	
								elseif(fileext=="c" or fileext=="cpp" or fileext=="h" or fileext=="hpp") then
									filetype = "cpp"
								end
							end
							out:WriteString(string.format("| *source path* | _%s_ |\r\n", codepath))
							out:WriteString(string.format("%%CODE{\"%s\"}%%\r\n", fileext or ""))
							local codefile = ParaIO.open(codepath, "r");
							if(codefile:IsValid()) then
								out:WriteString(codefile:GetText())
								codefile:close();
							end
							out:WriteString(string.format("%%ENDCODE%%\r\n"))
						end
					end
				end
			end
		end	
		--
		-- TODO: table definition
		--
	end
end

-- if the text line seperator "\n" is replaced by "\r\n"
function NPLDocGen.NormalizeReturnString(text)
	text = string.gsub(text, "\r\n", "\n");
	return string.gsub(text, "\n", "\r\n");
end


--[[
extract header information from the headerText
@param headerText: a common header looks like below. 
Title: Title Text
Author(s): LiXizhi
Date: 2008/3/12
Desc: description text
may be multiple lines
Use Lib:
-------------------------------------------------------
sample code here
-------------------------------------------------------
@return: it will return a table {Title, Author, Date, Desc, SampleCode}
]]
function NPLDocGen.GetHeaderInfo(headerText)
	local headerInfo = {}
	local _;
	_,_, headerInfo.Title = string.find(headerText,"\nTitle:%s*([^\r\n]*)")
	_,_, headerInfo.Author= string.find(headerText,"\nAuthor.-:%s*([^\r\n]*)")
	_,_, headerInfo.Date= string.find(headerText,"\nDate:%s*([^\r\n]*)")
	_,_, headerInfo.Desc= string.find(headerText,"\nDesc:%s*(.-\r\n)Use Lib:")
	if(not headerInfo.Desc) then
		_,_, headerInfo.Desc= string.find(headerText,"\nDesc:%s*(.-\r\n)use the lib:")
	end
	_,_, headerInfo.SampleCode= string.find(headerText,"\nUse Lib:%s*\r\n%-%-%-%-%-%-%-%-%-+\r\n(.-)%-%-%-%-%-%-%-%-%-+\r\n")
	if(not headerInfo.SampleCode)then
		_,_, headerInfo.SampleCode= string.find(headerText,"\nuse the lib:%s*\r\n%-%-%-%-%-%-%-%-%-+\r\n(.-)%-%-%-%-%-%-%-%-%-+\r\n")
	end
	return headerInfo;
end

-- body text is assumed to be wiki page, then all comments blocks are extracted and concartinated to a single string. 
function NPLDocGen.ExtractWikiText(bodyText)
	return string.gsub(bodyText, "\r?\n?%-%-%[%[.-\r\n(.*)$", "%1")	
end

-- @param comments: all comments text
-- @param syntax: the function definition line. 
function NPLDocGen.ParseFunction(comments, syntax)
	local memFunc = {};
	memFunc.syntax = syntax;
	--
	-- get params and function name from syntax
	--
	local _,_, name, params = string.find(syntax, "function%s+([^%(]-)%s*%(([^%)]-)%)")
	if(name) then
		memFunc.name = string.gsub(name, "%s*$", "")
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
	--
	-- get parasDoc from comments
	--
	-- remove comments line
	comments = NPLDocGen.RemoveCommentHeader(comments)
	-- encapsulate table definition inside verbatim block. 
	comments = NPLDocGen.DoTableDefVerbatim(comments)
	-- replace parameter definition with bullet style bold text. 
		
	memFunc.desc = string.gsub(comments, "\r?\n?%-*%s*@%s*(%w+)%s*(%w*):?", "\r\n   * _%1_ __%2__ :");
	local type, paramName, paramDoc;
	for type, paramName, paramDoc in string.gfind(comments,"\r?\n%-*%s*@%s*(%w+)%s*(%w*)%s*:?%s*([^@]*)") do
		paramDoc = string.gsub(paramDoc, "%s*\r?\n%s*$", "");
		if(type == "param" or type == "params") then
			memFunc.paramsDoc = memFunc.paramsDoc or {};
			memFunc.paramsDoc[paramName] = paramDoc;
		elseif(type == "return" or type == "returns") then
			paramName = "return";
			memFunc.params = memFunc.params or {};
			table.insert(memFunc.params, paramName);
				
			memFunc.paramsDoc = memFunc.paramsDoc or {};
			memFunc.paramsDoc[paramName] = paramDoc;
		elseif(type == "see") then
			paramName = type;
			memFunc.paramsDoc = memFunc.paramsDoc or {};
			memFunc.paramsDoc[paramName] = paramDoc;
		elseif(type=="code") then
			memFunc.codes = memFunc.codes or {};	
			local codepath = paramDoc;
			table.insert(memFunc.codes, {codepath=codepath});
		end
	end
	return memFunc;
end

--[[
extract array of member functions from string
@param bodyText: a common function looks like below. 
@return: it will return a table {{name="", desc="", syntax="", codes={}, params = {""}, paramsDoc = {a mapping from params name to its description, "return" and "see" are two special param key }, }}
]]
function NPLDocGen.GetMemberFunctions(bodyText)
	local memFuncs = {}
	local comments = nil;
	for line in string.gmatch(bodyText, "([^\r\n]*)\r?\n") do
		if(line:match("^%s*%-%-")) then
			comments = comments or {};
			comments[#comments+1] = line;
		elseif(line:match("^%s*$")) then
			comments = nil;
		elseif(line:match("^%s*function %w+")) then
			local memFunc = NPLDocGen.ParseFunction(table.concat(comments or {}, "\r\n"), line)
			if(memFunc.name) then
				table.insert(memFuncs, memFunc);
			end
		end
	end
	return memFuncs;
end

---------------------------------
-- common replacer
---------------------------------

-- if text contains a table definition like 
-- table1 = {
-- }
-- it will be encapsulated with verbatim block
function NPLDocGen.DoTableDefVerbatim(text)
	return string.gsub(text, "(\r\n)(.*%{\r\n.-\r\n%})", "%1<verbatim>%2</verbatim>");
end

-- if text contains "\r\n--" and other comment styles, it will be removed. 
function NPLDocGen.RemoveCommentHeader(text)
	text = string.gsub(text, "(\r\n)%-%-([^%-]%s*[^\r\n]*)", "%1%2");
	return string.gsub(text, "(\r\n)%-%-%[%[(.-\r\n)%]%]", "%1%2");
end

---------------------------------
-- pre processor 
---------------------------------

-- add a fake function in front of paraworld.CreateRPCWrapper() for documentation generation purposes. 
function NPLDocGen.PreProcRPCWrapperToFunction(input)
	local text = string.gsub(input, "\nparaworld.CreateRPCWrapper%s*%(%s*\"([^\"]+)\"", "\n-- \r\nfunction %1() \r\nend\r\nparaworld.CreateRPCWrapper(\"%1\"");
	-- converting ///line 1 \r\n to line1 \r\n\r\n
	return string.gsub(text, "\n%s*///([^\r\n]*)", "\n%1\r\n");
end

---------------------------------
-- post processor 
---------------------------------

-- This is a post processing function. To convert MCML tag in pe namespace to valid wiki words
-- @param input: such as [[pe:map-mark2d]]
-- @return [[Pe_mapmark2d][pe:map-mark2d]]
function NPLDocGen.MakeValidMCMLWikiWords(input)
	return string.gsub(input, "%[%[pe([%:%-]*)([%w]*)([%:%-]*)([%w]*)%]%]", "[[Pe_%2%4][pe:%2%3%4]]");
end

-- @param input: such as [[paraworld.auth.AuthUser]]
-- @return [[Paraworld_auth_AuthUser][paraworld.auth.AuthUser]]
function NPLDocGen.MakeValidParaWorldAPIWikiWords(input)
	return string.gsub(input, "%[%[paraworld([%.]*)(%a*)([%.]*)(%a*)%]%]", "[[Paraworld_%2_%4][paraworld.%2.%4]]");
end