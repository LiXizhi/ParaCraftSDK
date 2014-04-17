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
end

-- a handy function to select only the first node that match or nil. 
function XPath.selectNode(xmlLuaTable, xpath)
end

-- return an iterator of selected nodes in the XML document.
-- see function XPath.selectNodes(xmlLuaTable, xpath) for parameter specification
function XPath.eachNode(xmlLuaTable, xpath)
end

-- Desc: Decode character references and standard entity references in the string (str).
-- @param str: the string to be decoded
-- @return: a new decoded string as the result.
function XPath.XMLDecodeString(str)
end

-- Desc: Encode the following characters found in (str): & ' < > " and replace them with the standard entity references. 
-- @param str: the string to be encoded
-- @return: an encoded string.
function XPath.XMLEncodeString(str)
end

function XPath.selectNodes2(xml,xpath)
end
