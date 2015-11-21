--[[
Title: script related mcml node
Author(s): LiXizhi
Date: 2008/4/15
Desc: 
pe:script, HTML script tag, e.g. 

---++ script tag
we can load external script or page embedded script(inline script). DOM object is exposed to both types of script for functions defined in them. 

*property*
| *name* | *description* |
| type | default to "text/npl". currently there is only supported type. |
| src | external script file path |
| refresh | "true" or "false", default to "true". If true, when the pageCtrl:Refresh() method is called, the script block will reevaluate all inline scripts. Otherwise inline script are evaluated only once for a given page instance. |
| IsInitialized | this attribute can be script code. Normally it is automatically set to true on the first time, if refresh attribute is false. |
| [inner text] | inline script |

---+++ external script
external script is loaded only once even if they appear in different page files. and it must be existing file on the local machine. 
<verbatim> 
	<pe:script type="text/npl" src="script/test/test.lua" />
</verbatim>

---+++ embedded script 
inline script is executed in place when the page is loaded. global functions and variables defined inside inline script are in a safe page environment.
therefore does not override the glia NPL scripting environment.
*Example 1: short inline script*
<verbatim> 
	<%
		varName = 123
		function MyFuncion()
			return "hello world"
		 end
		document.write(MyFuncion());
	%>
</verbatim>

if script begins with =, it is same as document.write(). <br/>
*Example 2: one line script*
<verbatim> 
	<%=Eval("varName").."Hello world"%>
</verbatim>

*Example 3: verbose inline script*
<verbatim> 
	<script type="text/npl" refresh="true">
	<![CDATA[
	  function InlineFunction()
		return "function can be declared globally in a page environment"
	  end
	  document.write("<p>Hello "..InlineFunction())
	  document.write(commonlib.getfield("Map3DSystem.User.Name"))
	  document.write("!</p>")
	]__REMOVE_THIS_COMMENT__]>
	</script>
</verbatim>	

_Note_: there is an limitation of what can be inside an inline script. Inline script is evaluabled just in place at render time and does not modify the parent MCML node structure. 
So generally only pure display MCML tags can be generated on the fly, like the one in above example. Forms and id requery is not possible for dynamically generated node.

_Note_: both inline and external scripts are currently in global environment. We will restrict access to some classes in future, 
so do not attempt to modify anything global in it, otherwise your code may become invalid after the upcoming patch.

use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_script.lua");
local pe_script = commonlib.gettable("System.Windows.mcml.Elements.pe_script");
Elements.pe_script:RegisterAs("script", "pe:script", "unknown");
pe_script.BeginCode(self);
	NPL.DoString(code);
pe_script.EndCode(self);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/mcml/DOM.lua");
local mcml = commonlib.gettable("System.Windows.mcml");
local Elements = commonlib.gettable("System.Windows.mcml.Elements");
local Document = commonlib.gettable("System.Windows.mcml.Document");

-----------------------------------
-- pe:script and html script node
-----------------------------------
local pe_script = commonlib.inherit(commonlib.gettable("System.Windows.mcml.PageElement"), commonlib.gettable("System.Windows.mcml.Elements.pe_script"));

-- the following code is appended before the actual code to prevent global function defined in inline script to pollute the global environment. 
pe_script.prepare_page_env = "setfenv (1, System.Windows.mcml.Elements.pe_script._PAGESCRIPT);";

-- skip child node parsing.
function pe_script:createFromXmlNode(o)
	return self:new(o);
end
			
-- Code within this element is executed immediately when the page is loaded, if it is not in a function.
-- if it references an external script. The script should be on disk, otherwise it will be ignored. 
-- Moreover, external script will be loaded only once. e.g. 
--  <script type="text/npl">
--    <![CDATA[ 
--      document.write("<p>Hello World!</p>")
--    ]]>
--  </script>
-- MCML also supports Embedded Code Blocks in MCML Pages. The syntax is <%embeded code block%>. An embedded code block is server code that 
-- executes during the page's render phase. The code in the block can execute programming statements and call functions in the current page class. 
-- Embedded code blocks must be written in the page's default language. 
-- In general, using embedded code blocks for complex programming logic is not a best practice, because when the code is mixed on the page with markup, 
-- it can be difficult to debug and maintain. In addition, because the code is executed only during the page's render phase, 
-- you have substantially less flexibility than with code-behind or script-block code in scoping your code to the appropriate stage of page processing.
-- 
-- There is also a short cut <%="Any text or function here"%> which expands to <%document.write("Any text or function here")%>, 
-- e.g. one can write <%="profile.xml?uid="+Eval("uid")%>
function pe_script:LoadComponent(parentElem, parentLayout, style)
	local bAllowRefresh = self:GetBool("refresh");
	if(bAllowRefresh==false) then
		-- Tricky: if IsInitialized contains code, we will always refresh code value. 
		if(tostring(self:GetAttributeWithCode("IsInitialized",nil, true)) == "true") then
			local flushnode = self:GetChild("pe:flushnode");
			if (flushnode) then
				flushnode:LoadComponent(parentElem, parentLayout, style);
			end
			return;
		else
			self:SetAttributeIfNotCode("IsInitialized", true);
		end
	end
	
	-- nil or "text/npl" or "text/javascript"
	local scriptType = self:GetString("type");
	-- Defines a URL to a file that contains the script (instead of inserting the script into your HTML document, you can refer to a file that contains the script)
	local src = self:GetString("src");
	-- Defines the character encoding used in script
	local charset = self:GetString("charset");
	-- get the inner text if any.
	local bIsEmbeddedCodeBlock = (self.name == "unknown");
	---------------------
	-- TODO: shall we setup the security sandbox environment, here? 
	---------------------
	
	-- include src scripting file, relative path is allowed. 
	self:LoadScriptFile(src);
	
	-- call the code in a module environment, so that global functions defined in the file is stored in a local _PAGESCRIPT table on its PageCtrl node. 
	-- More info, please see http://lua-users.org/wiki/LuaModuleFunctionCritiqued 
	local code = self:GetPureText();
	local code_original = code;
	local code_func;
	if(self.code_code__ == code) then
		code_func = self.code_func__;
	end

	if(not code_func and bIsEmbeddedCodeBlock) then
		code = string.match(code, "^%%(.*)%%$")
		if(code and string.byte(code, 1) == 61) then
			-- if the first one is '='(61)
			code = string.gsub(code, "^=(.*)$", "document.write(%1)");
		end
	end

	if(code~=nil and code~="") then
		local pageCtrl = self:GetPageCtrl();
		if(pageCtrl) then
			pe_script.SetPageScope(pageCtrl);
			
			pe_script.BeginCode(self);

			if(not self.code_code__) then
				-- Do code in local environment
				local url = self:GetRequestURL() or "unknown inline MCML script";
				local cache_code = true;
				if(not cache_code) then
					NPL.DoString(pe_script.prepare_page_env..code, url);
				else
					self.code_code__ = code_original;
					local errormsg;
					code_func, errormsg = loadstring(code, url);
					if(not code_func) then
						LOG.std(nil, "error", "pe_script", "<Runtime error> syntax error while loading code in url:%s\n%s", url, tostring(errormsg));
					else
						self.code_func__ = code_func;
					end
				end
			end

			if(code_func) then
				setfenv (code_func, pe_script._PAGESCRIPT);
				code_func();
			end

			pe_script.EndCode(self, parentElem, parentLayout, style);
		else
			log("warning: inline <script> code in mcml page is ignored, because the page is not instantiated via PageCtrl. For security reasons, script code is ignored.\n");	
		end	
	end

	-- load child node
	local flushnode = self:GetChild("pe:flushnode");
	if (flushnode) then
		flushnode:LoadComponent(parentElem, parentLayout, style);
	end
end

function pe_script:UpdateLayout(parentLayout)
	local flushnode = self:GetChild("pe:flushnode");
	if (flushnode) then
		flushnode:UpdateLayout(parentLayout);
	end
end

-- Execute code in page scoping and return the result of the code.
-- @param code: string to do, 
-- please note: page document object is not available in code
-- There is also a short cut ="Any text or function here", which expands to return ("Any text or function here"), 
-- e.g. one can call pe_script.DoPageCode("=\"profile.xml?uid=\"+Eval(\"uid\")") as short cut for pe_script.DoPageCode("return (\"profile.xml?uid=\"+Eval(\"uid\"))")
-- @return: code result is returned. 
function pe_script.DoPageCode(code, pageCtrl)
	if(code and pageCtrl) then
		if(string.byte(code, 1) == 61) then
			-- if the first one is '='(61)
			code = string.gsub(code, "^=(.*)$", "return (%1)");
		end	
		pe_script.SetPageScope(pageCtrl);
		
		-- we used the loadstring from lua, maybe a more secure function is better. 
		local file_func, errmsg = loadstring(pe_script.prepare_page_env..code);
		if(file_func) then
			return file_func();
		else
			LOG.std(nil, "error", "pe_script", "<Runtime Error>failed to do page code in page%s. error msg:%s", tostring(pageCtrl.url), tostring(errmsg))
			echo(pe_script.prepare_page_env..code);
			return nil;
		end
	end
end

-----------------------------
-- page scope functions
-----------------------------
pe_script.PageScope = {};

-- evaluate a variable only in current page scope. 
-- @param name: name of the value to be searched in page environment. 
function pe_script.PageScope.Eval(name)
	if(pe_script._PAGESCRIPT and name) then	
		--commonlib.echo(rawget(pe_script._PAGESCRIPT, name))
		return rawget(pe_script._PAGESCRIPT, name)
	end
end

-- evaluate a variable hierarchy only in current page scope. 
-- @param name: name of the value to be searched in page environment. such as "Book/Title", "Book.Title"
function pe_script.PageScope.XPath(name)
	if(pe_script._PAGESCRIPT and name) then	
		--commonlib.echo(rawget(pe_script._PAGESCRIPT, name))
		local v = pe_script._PAGESCRIPT
		local w;
		for w in string.gfind(name, "[%w_]+") do
			v = rawget(v, w)
			if(v==nil) then
				break
			end
		end
		return v
	end
end

-- set page scope for the given page
-- so that Map3DSystem.mcml_controls.pe_script._PAGESCRIPT contains the page environment
-- a page scope contains all functions in pe_script.PageScope. The most important one is Eval(name), XPath(name) and Page object.
function pe_script.SetPageScope(pageCtrl)
	if(pageCtrl == nil) then return end
	pe_script._PAGESCRIPT = pageCtrl:GetPageScope();
end

-- code executed between pe_script.BeginCode() and pe_script.EndCode() can access to the "document" DOM object.
-- setup the DOM environment so that we can do something like below inside inline script block.
-- <script type="text/npl">
--   document.write("Hello World!")
-- </script>
-- @param self: must be a valid node which provide the context of the mcml page. 
function pe_script.BeginCode(self)
	if(self) then
		document = Document:new();
		document.body = self:GetParent("pe:mcml") or self:GetRoot();
	end
end

-- code executed between pe_script.BeginCode() and pe_script.EndCode() can access to the "document" DOM object.
-- @param self: if nil, it will ignore document.write inside the code. 
function pe_script.EndCode(self)
	if(document) then
		-- flush and create content
		local domNode = document:flush();
		if(domNode~=nil) then
			local flushnode;
			if(self) then
				-- bug fixed 2008.6.26: we will append all script generated node to pe:flushnode.  This will allow sub nodes to call GetPageCtrl().
				flushnode = self:GetChild("pe:flushnode");
				if(not flushnode) then
					flushnode = Elements.pe_unknown:createFromXmlNode({name="pe:flushnode"});
					self:AddChild(flushnode);
				else
					flushnode:ClearAllChildren();	
				end	
				-- create each child node. 
				if(flushnode) then
					for childnode in domNode:next() do
						flushnode:AddChild(childnode);
					end
				end
			end		
		end
		-- clear the document object
		document = nil;
	end	
end


