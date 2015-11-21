--[[
Title: Lua XML
Author(s): http://lua-users.org/wiki/XmlTree  modified by LiXizhi to meet our specification
Date: 2007/9/22
Desc: 
Specifications:  
	A tree is a Lua table representation of an element and its contents. The table must have a name key, giving the element name. 
The tree may have a attr key, which gives a table of all of the attributes of the element. Only string keys are relevant.
If the element is not empty, each child node is contained in tree[1], tree[2], etc. Child nodes may be either strings, denoting character data content, or other trees. 

Spec by example
	lz = commonlib.XML2Lua("<paragraph justify='centered'>first child<b>bold</b>second child</paragraph>")
	lz ={
		  {
			"first child",
			{ "bold", attr={  }, n=1, name="b" },
			"second child",
			attr={ justify="centered" },
			n=3,
			name="paragraph" 
		  },
		  n=1 
		}
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/LuaXML.lua");
local xmlRoot = commonlib.XML2Lua("<paragraph justify='centered'>first child<b>bold</b>second child</paragraph>")
log(commonlib.Lua2XmlString(xmlRoot));
-------------------------------------------------------
]]
if(not commonlib) then commonlib={}; end

local Encoding = commonlib.gettable("commonlib.Encoding");
local type = type;

function commonlib.XML2Lua(s)
	local function parseattr(s)
	  local arg = {}
	  string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
		arg[w] = a
	  end)
	  return arg
	end

  local stack = {n=0}
  local top = {n=0}
  table.insert(stack, top)
  local ni,c,name,attr, empty
  local i, j = 1, 1
  while 1 do
    ni,j,c,name,attr, empty = string.find(s, "<(%/?)(%w+)(.-)(%/?)>", j)
    if not ni then break end
    local text = string.sub(s, i, ni-1)
    if not string.find(text, "^%s*$") then
      table.insert(top, text)
    end
    if empty == "/" then  -- empty element tag
      table.insert(top, {n=0, name=name, attr=parseattr(attr), empty=1})
    elseif c == "" then   -- start tag
      top = {n=0, name=name, attr=parseattr(attr)}
      table.insert(stack, top)   -- new level
    else  -- end tag
      local toclose = table.remove(stack)  -- remove top
      top = stack[table.getn(stack)]
      if table.getn(stack) < 1 then
        log("nothing to close with "..name)
        return 
      end
      if toclose.name ~= name then
        log("trying to close "..toclose.name.." with "..name)
        return
      end
      table.insert(top, toclose)
    end 
    i = j+1
  end
  local text = string.sub(s, i)
  if not string.find(text, "^%s*$") then
    table.insert(stack[#stack], text)
  end
  if #stack > 1 then
    log("unclosed "..stack[#stack].name)
    return
  end
  return stack[1]

end

-- implemented by LiXizhi, 2008.10.20
-- converting lua table to xml file. Please note the lua table must be in the format returned by commonlib.XML2Lua();
-- @param bBeautify: if true, it will use indentations. 
function commonlib.Lua2XmlString(input, bBeautify)
	if(not input) then return end
	local output = {};
	local indent = 0;
	local function OutputNode(inTable)
		if(not inTable) then return end
		if(type(inTable) == "string") then 
			table.insert(output, Encoding.EncodeHTMLInnerText(inTable))
		elseif(type(inTable) == "table") then 	
			local nodeXML;
			if(inTable.name) then
				local indentStr;
				
				if(inTable.name == "![CDATA[") then
					nodeXML = "<"..inTable.name;
					table.insert(output, nodeXML)
				
					for i, childNode in ipairs(inTable) do
						if(type(childNode)=="string") then
							table.insert(output, childNode)
						end
					end
					table.insert(output, "]]>")
					return 
				else
					if(bBeautify) then
						indentStr = "\r\n"..string.rep("\t", indent);
					end
					nodeXML = (indentStr or "").."<"..inTable.name;
					table.insert(output, nodeXML)
				
					if(inTable.attr) then
						local name, value
						for name, value in pairs(inTable.attr) do
							table.insert(output, string.format(" %s=\"%s\"", name, Encoding.EncodeStr(value)))
						end
					end
					
				end
			end	
			local nChildSize = table.getn(inTable);
			if(nChildSize>0) then
				if(nodeXML) then
					table.insert(output, ">");
				end	
				indent = indent+1;
				for i, childNode in ipairs(inTable) do
					OutputNode(childNode);
				end
				indent = indent-1;
				
				if(nodeXML) then
					local indentStr;
					if(bBeautify) then
						indentStr = "\r\n"..string.rep("\t", indent);
					end
					table.insert(output, (indentStr or "").."</"..inTable.name..">");
				end	
			else
				if(nodeXML) then
					table.insert(output, "/>");
				end	
			end
		end
	end
	OutputNode(input)
	return table.concat(output);
end