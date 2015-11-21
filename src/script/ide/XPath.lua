--[[
Title: XPath parser in NPL
Author(s): WangTian
Date: 2007/12/28
Desc: XPath uses path expressions to select nodes in an XML document. The node is selected by 
	following an xpath. An xpath consists of xpath expression and predicate(optional).

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/XPath.lua");

local xmlDocIP = ParaXML.LuaXML_ParseFile("script/apps/Poke/IP.xml");
local xpath = "/mcml:mcml/mcml:packageList/mcml:package/";
local xpath = "//mcml:IPList/mcml:IP[@text = 'Level2_2']";
local xpath = "//mcml:IPList/mcml:IP[@version = 5]";
local xpath = "//mcml:IPList/mcml:IP[@version < 6]"; -- only supported by selectNodes2
local xpath = "//mcml:IPList/mcml:IP[@version > 4]"; -- only supported by selectNodes2
local xpath = "//mcml:IPList/mcml:IP[@version >= 5]"; -- only supported by selectNodes2
local xpath = "//mcml:IPList/mcml:IP[@version <= 5]"; -- only supported by selectNodes2

local xmlDocIP = ParaXML.LuaXML_ParseFile("character/v3/Pet/MGBB/mgbb.xml");
local xpath = "/mesh/shader/@index";
local xpath = "/mesh/boundingbox/@minx";
local xpath = "/mesh/submesh/@filename";
local xpath = "/mesh/submesh";

--
-- select nodes to an array table
--
local result = commonlib.XPath.selectNodes(xmlDocIP, xpath);
local result = XPath.selectNodes(xmlDocIP, xpath, nMaxResultCount); -- select at most nMaxResultCount result

--
-- select a single node or nil
--
local node = XPath.selectNode(xmlDocIP, xpath);

--
-- iterate on all nodes. 
--
for node in commonlib.XPath.eachNode(xmlDocIP, xpath) do
	commonlib.echo(node[1]);
end

-- debug: print the result table
NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
Map3DSystem.Misc.SaveTableToFile(result, "TestTable/LODxml.ini");
-------------------------------------------------------
]]

local XPath = {};
if(not commonlib.XPath) then commonlib.XPath = XPath; end


local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local type = type

local table_getn = table.getn
local table_insert = table.insert

local string_find = string.find;
local string_gfind = string.gfind;
local string_lower = string.lower;
local string_match = string.match;
local string_gsub = string.gsub;
local string_sub = string.sub;

-- Decs: XPath uses path expressions to select nodes in an XML document. The node is selected by 
--	following an xpath. An xpath consists of xpath expression and predicate(optional).
--
--		Supported path expressions are listed below:
--
--		nodename: Selects all child nodes of the named node 
--		/	: Selects from the ROOT node 
--		//	: Selects nodes in the document from the current node that match the selection ANYWHERE in the document
--		@	: Selects attributes 
--
--		Predicates are used to find a specific node or a node that 
--		contains a specific value. Predicates are always embedded in square brackets.
--		Supported operators are listed below:
--		<	: number
--		>	: number
--		<=	: number
--		>=	: number
--		=	: number or string
--		
--		operators:
--		|	:  | operator in an XPath expression you can select several paths. (not implemented yet)
--
--	e.g: xpath:  /mcml:mcml/mcml:packageList/mcml:package/*[mcml:AuthorName = 'ParaEngine']
--	e.g: xpath:  /mcml:mcml/mcml:app/mcml:IPList/mcml:IP[@something < 23]
--	e.g: xpath:  /mcml:mcml/mcml:app/mcml:IPList/mcml:IP[@something]
-- @param nMaxResultCount: this can be nil, if a number, we will stop selecting once we have found this amount of result
function XPath.selectNodes(xmlLuaTable, xpath, nMaxResultCount)
	if(not xmlLuaTable) then
		return {};
	end
	
	-- divide the xpath into Path Expression and Predicates
	local sExpression;
	local sPredicate;
	local sAttribute;
	local bracketL = string_find(xpath, '%[');
	local bracketR = string_find(xpath, '%]');
			
	-- TODO: make sure that the expression don't contain extra "/" in the end
	if(bracketL ~= nil) then 
		sExpression = string_sub(xpath, 1, bracketL - 1);
	else
		sExpression = xpath;
	end
	
	local at = string_find(sExpression, '@');
	if(at ~= nil) then
		if("/" == string_sub(sExpression, at-1, at-1)) then
			local slash = string_find(sExpression, '/', at);
			if(slash == nil) then
				-- no forward slash at the end of the string
				sAttribute = string_sub(sExpression, at + 1);
				sExpression = string_sub(sExpression, 1, at - 2);
			else
				-- remove additional forward slash at the end of the string
				sAttribute = string_sub(sExpression, at + 1, slash - 1);
				sExpression = string_sub(sExpression, 1, at - 2);
			end
		end
	end
	
	if(bracketL ~= nil and bracketR ~= nil and bracketL < bracketR) then
		sPredicate = string_sub(xpath, bracketL + 1, bracketR - 1);
	end
	--
	-- predicate filter function
	--
	local FilterPredicate;
	if(sPredicate ~= nil) then
		-- sPredicate available
		local attributeName;
		local sPredicateNoSpace = string_gsub(sPredicate, " ", "");
		
		local _at = string_find(sPredicateNoSpace, '@');
		local _lessthan = string_find(sPredicateNoSpace, '<');
		local _greaterthan = string_find(sPredicateNoSpace, '>');
		local _equal = string_find(sPredicateNoSpace, '=');
		--local _add = string_find(sPredicateNoSpace, '|');
		--local _or = string_find(sPredicateNoSpace, '&');
		local strEqual = "";
		local numEqual;
		local numLess;
		local numGreater;
		local numLessEqual;
		local numGreaterEqual;
		
		
		if(_at ~= nil) then
			-- [@attrname...]
			if(_equal ~= nil) then
				-- = or <= or >= expression
				if(_lessthan ~= nil) then
					-- "<=" expression
					attributeName = string_sub(sPredicateNoSpace, _at + 1, _lessthan - 1);
					numLessEqual = tonumber(string_sub(sPredicateNoSpace, _equal + 1));
				elseif(_greaterthan ~= nil) then
					-- ">=" expression
					attributeName = string_sub(sPredicateNoSpace, _at + 1, _greaterthan - 1);
					numGreaterEqual = tonumber(string_sub(sPredicateNoSpace, _equal + 1));
				else
					-- "=" expression
					attributeName = string_sub(sPredicateNoSpace, _at + 1, _equal - 1);
					local _singleQuote1 = string_find(sPredicateNoSpace, '\'');
					if(_singleQuote1 ~= nil) then
						local _singleQuote2 = string_find(sPredicateNoSpace, '\'', _singleQuote1 + 1);
						strEqual = string_sub(sPredicateNoSpace, _singleQuote1 + 1, _singleQuote2 - 1);
					else
						numEqual = tonumber(string_sub(sPredicateNoSpace, _equal + 1));
					end
				end
			else
				-- [@attrname...] no "="
				if(_lessthan == nil and _greaterthan == nil) then
					-- [@attrname]
					attributeName = string_sub(sPredicateNoSpace, _at + 1, -1);
				else
					if(_lessthan ~= nil and _greaterthan ~= nil) then
						-- wrong expression containing both less than and greater than symble
					elseif(_lessthan ~= nil) then
						-- "<" expression
						attributeName = string_sub(sPredicateNoSpace, _at + 1, _lessthan - 1);
						numLess = tonumber(string_sub(sPredicateNoSpace, _lessthan + 1));
					elseif(_greaterthan ~= nil) then
						-- ">" expression
						attributeName = string_sub(sPredicateNoSpace, _at + 1, _greaterthan - 1);
						numGreater = tonumber(string_sub(sPredicateNoSpace, _greaterthan + 1));
					end
				end
			end
			-- filter the result according to the expression statement
			if(attributeName ~= nil) then
				-- return true if predicate passed. 
				FilterPredicate = function (v)
					if(type(strEqual) == "string" and strEqual ~= "") then
						-- equal to string
						if(v.attr == nil or v.attr[attributeName] ~= strEqual) then
							return;
						end
					elseif(type(numEqual) == "number" and numEqual ~= nil) then
						-- equal to number
						if(v.attr == nil or tonumber(v.attr[attributeName]) ~= numEqual) then
							return;
						end
					elseif(type(numLess) == "number" and numLess ~= nil) then
						-- less than number
						if(v.attr == nil or tonumber(v.attr[attributeName]) == nil or 
								tonumber(v.attr[attributeName]) > numLess or tonumber(v.attr[attributeName]) == numLess) then
							return;
						end
					elseif(type(numGreater) == "number" and numGreater ~= nil) then
						-- greater than number
						if(v.attr == nil or tonumber(v.attr[attributeName]) == nil or 
								tonumber(v.attr[attributeName]) < numGreater or tonumber(v.attr[attributeName]) == numLess) then
							return;
						end
					elseif(type(numLessEqual) == "number" and numLessEqual ~= nil) then
						-- less than or equal to number
						if(v.attr == nil or tonumber(v.attr[attributeName]) == nil or 
								tonumber(v.attr[attributeName]) > numLessEqual) then
							return;
						end
					elseif(type(numGreaterEqual) == "number" and numGreaterEqual ~= nil) then
						-- greater than or equal to number
						if(v.attr == nil or tonumber(v.attr[attributeName]) == nil or 
								tonumber(v.attr[attributeName]) < numGreaterEqual) then
							return;
						end
					elseif(v.attr == nil or v.attr[attributeName] == nil) then
						-- contain attribute expression
						return;
					end
					return v;
				end
			end	
		end	
	end	
	
	--
	-- filter the result according to sAttribute
	--
	local FilterAttribute;
	if(sAttribute) then
		FilterAttribute = function (v)
			if(v.attr) then
				return v.attr[sAttribute];
			end
		end
	end	
	--
	-- filter predicate and then attribute for a given node. return the object if matched. 
	--
	local function FilterNode (v)
		if(v and FilterPredicate) then
			 v = FilterPredicate(v);
		end
		if(v and FilterAttribute) then
			 v = FilterAttribute(v);
		end
		return v;
	end

	--
	-- traverse through the xml table to get nodes according to xpath expression
	--		/ expression : Selects from the ROOT node 
	-- @return true if we have found enough result 
	local function TraverseXMLTable1(o, xpath, result, nMaxResultCount)
		if (type(o) == "table") then
			-- traverse through the 
			local forwardSlash1 = string_find(xpath, "/");
			if(forwardSlash1 == 1) then
				local forwardSlash2 = string_find(xpath, "/", 2);
				local currentName;
				if(forwardSlash2 ~= nil and forwardSlash2 ~= string.len(xpath)) then
					-- not the end of a xpath expression
					currentName = string_sub(xpath, 2, forwardSlash2 - 1);
					-- recursively traverse the sub table
					local i;
					local nSize = table.getn(o);
					if(nSize~=0) then
						for i = 1, nSize do
							if(o.name == currentName) then
								if(TraverseXMLTable1(o[i], string_sub(xpath, forwardSlash2, -1), result, nMaxResultCount)) then
									return true;
								end
							end
						end
					end	
				else
					-- reach the end of a xpath expression
					if(forwardSlash2 == string.len(xpath)) then
						currentName = string_sub(xpath, 2, -2); -- with an extra "/" at the end of xpath
					else
						currentName = string_sub(xpath, 2, -1);
					end
					
					if(o.name == currentName) then
						-- insert the node into result
						o = FilterNode(o)
						if(o) then
							table_insert(result, o);
							if(nMaxResultCount and #result>=nMaxResultCount) then
								return true;
							end
						end
					end
				end
			end
		end
	end

	--
	-- traverse through the xml table to get nodes according to xpath expression
	--		// expression : Selects nodes in the document from the current node that match the selection ANYWHERE in the document
	-- @return true if we have found enough result 
	local function TraverseXMLTable2(o, xpath, currentPath, result, nMaxResultCount)
		
		if (type(o) == "table") then
			-- traverse through the 
			local nextPath = currentPath.."/"..o.name;
			local tag = string_match(nextPath.."/", xpath); -- remove the additional "//"
			
			if(tag ~= nil) then
				-- insert the node into result
				o = FilterNode(o)
				if(o) then
					table_insert(result, o);
					if(nMaxResultCount and #result>=nMaxResultCount) then
						return true;
					end
				end	
			else
				-- not match the xpath
				-- recursively traverse the sub table
				local i;
				local nSize = table.getn(o);
				if(nSize ~= 0) then
					for i = 1, nSize do
						if(TraverseXMLTable2(o[i], xpath, nextPath, result, nMaxResultCount)) then
							return true;
						end
					end
				end
			end
		end
	end


	-- select nodes according to xpath
	local result = {};
	
	if(string_match(sExpression, "^//")) then
		-- "//" expression : Selects nodes in the document from the current node that 
		--					match the selection ANYWHERE in the document
		local i;
		local nSize = table.getn(xmlLuaTable);
		if(nSize ~= 0) then
			local sMatchExp = string_sub(sExpression, 2).."/";
			for i = 1, nSize do
				if(TraverseXMLTable2(xmlLuaTable[i], sMatchExp, "/", result, nMaxResultCount)) then
					break
				end
			end
		end
	elseif(string_match(sExpression, "^/")) then
		-- "/" expression : Selects from the ROOT node
		local i;
		local nSize = table.getn(xmlLuaTable);
		if(nSize ~= 0) then
			for i = 1, nSize do
				if(TraverseXMLTable1(xmlLuaTable[i], sExpression, result, nMaxResultCount)) then
					break
				end
			end
		end
	else
		-- nodename expression : Selects all child nodes of the named node
	end
	
	return result;
end

-- a handy function to select only the first node that match or nil. 
function XPath.selectNode(xmlLuaTable, xpath)
	return XPath.selectNodes(xmlLuaTable, xpath, 1)[1];
end

-- return an iterator of selected nodes in the XML document.
-- see function XPath.selectNodes(xmlLuaTable, xpath) for parameter specification
function XPath.eachNode(xmlLuaTable, xpath)
	local result = XPath.selectNodes(xmlLuaTable, xpath);
	local index = 0;
	
	return function ()
		index = index + 1;
		if(result[index] ~= nil) then
			return result[index];
		end
	end
end

-- Desc: Decode character references and standard entity references in the string (str).
-- @param str: the string to be decoded
-- @return: a new decoded string as the result.
function XPath.XMLDecodeString(str)
	local decodedStr = str;
	decodedStr = string_gsub(decodedStr, "&amp;", "&");
	decodedStr = string_gsub(decodedStr, "&apos;", "\'");
	decodedStr = string_gsub(decodedStr, "&lt;", "<");
	decodedStr = string_gsub(decodedStr, "&gt;", ">");
	decodedStr = string_gsub(decodedStr, "&quot;", "\"");
	return decodedStr;
end

-- Desc: Encode the following characters found in (str): & ' < > " and replace them with the standard entity references. 
-- @param str: the string to be encoded
-- @return: an encoded string.
function XPath.XMLEncodeString(str)
	local encodedStr = str;
	encodedStr = string_gsub(encodedStr, "&", "&amp;");
	encodedStr = string_gsub(encodedStr, "\'", "&apos;");
	encodedStr = string_gsub(encodedStr, "<", "&lt;");
	encodedStr = string_gsub(encodedStr, ">", "&gt;");
	encodedStr = string_gsub(encodedStr, "\"", "&quot;");
	return encodedStr;
end


-----------------------------------------------------------------------------
-- XPath module based on LuaExpat
-- Description: Module that provides xpath capabilities to xmls.
-- Author: Gal Dubitski, modified by LiXizhi to meet DOM standard in ParaEngine
-- Version: 0.1
-- Date: 2008-01-15
-----------------------------------------------------------------------------
local resultTable,option = {},nil

local function insertToTable(leaf)
	if type(leaf) == "table" then
		if option == nil then
			table.insert(resultTable,leaf)
		elseif option == "text()" then
			table.insert(resultTable,leaf[1])
		elseif option == "node()" then
			table.insert(resultTable,leaf.name)
		elseif option:find("@") == 1 then
			table_insert(resultTable,leaf.attr[option:sub(2)])
		end
	end
end

-- Compatibility: Lua-5.1
local function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

local function match(tag,tagAttr,tagExpr,nextTag)
	
	local expression,evalTag
	
	-- check if its a wild card
	if tagExpr == "*" then
		return true
	end
	
	-- check if its empty
	if tagExpr == "" then
		if tag == nextTag then
			return false,1
		else
			return false,0
		end
	end
	
	-- check if there is an expression to evaluate
	if tagExpr:find("[[]") ~= nil and tagExpr:find("[]]") ~= nil then
		evalTag = tagExpr:sub(1,tagExpr:find("[[]")-1)
		expression = tagExpr:sub(tagExpr:find("[[]")+1,tagExpr:find("[]]")-1)
		if evalTag ~= tag then
			return false
		end
	else
		return (tag == tagExpr)
	end
	
	-- check if the expression is an attribute
	if expression:find("@") ~= nil then
		if(tagAttr) then
			local evalAttr,evalValue
			evalAttr = expression:sub(expression:find("[@]")+1,expression:find("[=]")-1)
			evalValue = string.gsub(expression:sub(expression:find("[=]")+1),"'","")
			evalValue = evalValue:gsub("\"","")
			if tagAttr[evalAttr] ~= evalValue then
				return false
			else
				return true
			end
		else
			return false;
		end
	end
end

local function parseNodes(tags,xmlTable,counter)
	if counter > #tags then
		return nil
	end
	local currentTag = tags[counter]
	local nextTag
	if #tags > counter then
		nextTag = tags[counter+1]
	end
	for i,value in ipairs(xmlTable) do
		if type(value) == "table" then
			local x,y = match(value.name,value.attr,currentTag,nextTag)
			if x then
				if #tags == counter then
					insertToTable(value)
				else
					parseNodes(tags,value,counter+1)
				end
			else
				if y ~= nil then
					if y == 1 then
						if counter+1 == #tags then
							insertToTable(value)
						else
							parseNodes(tags,value,counter+2)
						end
					else
						parseNodes(tags,value,counter)
					end
				end
			end
		end
	end
end

function XPath.selectNodes2(xml,xpath)
	assert(type(xml) == "table")
	assert(type(xpath) == "string")
	
	resultTable = {}
	local xmlTree = {}
	table_insert(xmlTree,xml)
	assert(type(xpath) == "string")
	
	tags = split(xpath,'[\\/]+')
	
	local lastTag = tags[#tags] 
	if lastTag == "text()" or lastTag == "node()" or lastTag:find("@") == 1 then
		option = tags[#tags]
		table.remove(tags,#tags)
	else
		option = nil
	end
	
	if xpath:find("//") == 1 then
		table.insert(tags,1,"")
	end
	
	parseNodes(tags,xmlTree,1)
	return resultTable
end
