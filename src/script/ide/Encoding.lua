--[[
Title: encoding functions
Author(s): LiXizhi
Date: 2008/12/10
Desc: file encoding is a very complicated issue. if the npl file encoding is set to utf8 ( usually without signature), then to display a file, one usually needs to 
convert from system default encoding to utf8 and vice versa. However, it is still impossible to display a file name created in one encoding system and opened in another.  
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/Encoding.lua");
local Encoding = commonlib.gettable("commonlib.Encoding");
commonlib.Encoding.Utf8ToDefault(text)
commonlib.Encoding.DefaultToUtf8(text)

print(commonlib.Encoding.SortCSVString("Cword,Aword,Bword"))
-------------------------------------------------------
]]
local string_match = string.match;
local string_gfind = string.gfind;
local string_find = string.find;
local string_gsub = string.gsub;
local string_format = string.format;
local string_sub = string.sub;
local tostring = tostring
local tonumber = tonumber
local math_floor = math.floor;
local string_byte = string.byte
local string_char = string.char;

if(not commonlib) then commonlib={}; end
if(not commonlib.Encoding) then commonlib.Encoding={}; end

local Encoding = commonlib.Encoding;

function Encoding.Utf8ToDefault(text)
	return ParaMisc.EncodingConvert("utf-8", "", text);
end

function Encoding.DefaultToUtf8(text)
	return ParaMisc.EncodingConvert("", "utf-8", text)
end


-- sort commar separated vector (CSV) string alphabetically
-- @param fields: string such as "C,B,A", or a table containing string arrays such as {"C", "B", "A"}
-- @return return a new CSV string "A,B,C"
function Encoding.SortCSVString(fields)
	if(type(fields) == "string") then
		local fieldTable = {}
		local w;
		for w in string.gfind(fields, "%w+") do
			table.insert(fieldTable, w)
		end
		fields = fieldTable;
	end	
	if(type(fields) == "table") then	
		table.sort(fields);
		local csvNew;
		local _,w
		for _,w in ipairs(fields) do
			if(not csvNew) then
				csvNew = w
			else
				csvNew = csvNew..","..w
			end
		end
		return csvNew
	end
end
function Encoding.EncodeStr(s)
	local s = tostring(s);
	if(not s)then return end
	s = string_gsub(s, "&", "&amp;");
	s = string_gsub(s, "\'", "&apos;");
	s = string_gsub(s, "<", "&lt;");
	s = string_gsub(s, ">", "&gt;");
	s = string_gsub(s, "\"", "&quot;");
	return s;
end

function Encoding.EncodeHTMLInnerText(s)
	local s = tostring(s);
	if(not s)then return end
	s = string_gsub(s, "&", "&amp;");
	-- s = string_gsub(s, "\'", "&apos;");
	s = string_gsub(s, "<", "&lt;");
	s = string_gsub(s, ">", "&gt;");
	-- s = string_gsub(s, "\"", "&quot;");
	return s;
end

function Encoding.HasXMLEscapeChar(s)
	if(string.match(s, "[&'<>\"\n]")) then
		return true;
	end
end
-----------------------------------------------------------------------------
-- Encoding conversion routines
-- LuaSocket toolkit
-- Author: Diego Nehab
-- Conforming to: RFC 2045, LTN7
-- RCS ID: $Id: code.lua,v 1.3 2003/07/14 19:52:45 traumwind Exp $
-----------------------------------------------------------------------------
local Private = {};

-----------------------------------------------------------------------------
-- Public constants
-----------------------------------------------------------------------------
Encoding.LINEWIDTH = 76

-----------------------------------------------------------------------------
-- Direct and inverse convertion tables for base64
-----------------------------------------------------------------------------
Private.t64 = {
	[00] = 'A', [01] = 'B', [02] = 'C', [03] = 'D', [04] = 'E', [05] = 'F', 
	[06] = 'G', [07] = 'H', [08] = 'I', [09] = 'J', [10] = 'K', [11] = 'L', 
	[12] = 'M', [13] = 'N', [14] = 'O', [15] = 'P', [16] = 'Q', [17] = 'R', 
	[18] = 'S', [19] = 'T', [20] = 'U', [21] = 'V', [22] = 'W', [23] = 'X', 
	[24] = 'Y', [25] = 'Z', [26] = 'a', [27] = 'b', [28] = 'c', [29] = 'd', 
	[30] = 'e', [31] = 'f', [32] = 'g', [33] = 'h', [34] = 'i', [35] = 'j', 
	[36] = 'k', [37] = 'l', [38] = 'm', [39] = 'n', [40] = 'o', [41] = 'p', 
	[42] = 'q', [43] = 'r', [44] = 's', [45] = 't', [46] = 'u', [47] = 'v', 
	[48] = 'w', [49] = 'x', [50] = 'y', [51] = 'z', [52] = '0', [53] = '1', 
	[54] = '2', [55] = '3', [56] = '4', [57] = '5', [58] = '6', [59] = '7', 
	[60] = '8', [61] = '9', [62] = '+', [63] = '/', [64] = '='
}

Private.f64 = {
	['A'] = 00, ['B'] = 01, ['C'] = 02, ['D'] = 03, ['E'] = 04, ['F'] = 05, 
	['G'] = 06, ['H'] = 07, ['I'] = 08, ['J'] = 09, ['K'] = 10, ['L'] = 11, 
	['M'] = 12, ['N'] = 13, ['O'] = 14, ['P'] = 15, ['Q'] = 16, ['R'] = 17, 
	['S'] = 18, ['T'] = 19, ['U'] = 20, ['V'] = 21, ['W'] = 22, ['X'] = 23, 
	['Y'] = 24, ['Z'] = 25, ['a'] = 26, ['b'] = 27, ['c'] = 28, ['d'] = 29, 
	['e'] = 30, ['f'] = 31, ['g'] = 32, ['h'] = 33, ['i'] = 34, ['j'] = 35, 
	['k'] = 36, ['l'] = 37, ['m'] = 38, ['n'] = 39, ['o'] = 40, ['p'] = 41, 
	['q'] = 42, ['r'] = 43, ['s'] = 44, ['t'] = 45, ['u'] = 46, ['v'] = 47, 
	['w'] = 48, ['x'] = 49, ['y'] = 50, ['z'] = 51, ['0'] = 52, ['1'] = 53, 
	['2'] = 54, ['3'] = 55, ['4'] = 56, ['5'] = 57, ['6'] = 58, ['7'] = 59, 
	['8'] = 60, ['9'] = 61, ['+'] = 62, ['/'] = 63, ['='] = 64
}

-----------------------------------------------------------------------------
-- Converts a three byte sequence into its four character base64 
-- representation
-----------------------------------------------------------------------------
function Private.t2f(a,b,c)
	local s = string_gfind(a)*65536 + string_gfind(b)*256 + string_gfind(c) 
	local ca, cb, cc, cd
	cd = math.mod(s, 64)
	s = (s - cd) / 64
	cc = math.mod(s, 64)
	s = (s - cc) / 64
	cb = math.mod(s, 64)
	ca = (s - cb) / 64
	return Private.t64[ca] .. Private.t64[cb] .. 
		Private.t64[cc] .. Private.t64[cd]
end

-----------------------------------------------------------------------------
-- Converts a four character base64 representation into its three byte
-- sequence
-----------------------------------------------------------------------------
function Private.f2t(a,b,c,d)
	local s = Private.f64[a]*262144 + Private.f64[b]*4096 + 
		Private.f64[c]*64 + Private.f64[d] 
	local ca, cb, cc
	cc = math.mod(s, 256)
	s = (s - cc) / 256
	cb = math.mod(s, 256)
	ca = (s - cb) / 256
	return string_char(ca, cb, cc)
end

-----------------------------------------------------------------------------
-- Creates a base64 representation of an incomplete last block
-----------------------------------------------------------------------------
function Private.to64pad(s)
	local a, b, ca, cb, cc, _
	_, _, a, b = string.find(s, "(.?)(.?)")
	if b == "" then 
		s = string_gfind(a)*16
		cb = s % 64
		ca = (s - cb)/64
		return Private.t64[ca] .. Private.t64[cb] .. "=="
	end
	s = string_gfind(a)*1024 + string_gfind(b)*4
	cc = s % 64
	s = (s - cc) / 64
	cb = s % 64
	ca = (s - cb)/64
	return Private.t64[ca] .. Private.t64[cb] .. Private.t64[cc] .. "="
end

-----------------------------------------------------------------------------
-- Decodes the base64 representation of an incomplete last block
-----------------------------------------------------------------------------
function Private.from64pad(s)
	local a, b, c, d
	local ca, cb, _
	_, _, a, b, c, d = string_find(s, "(.)(.)(.)(.)")
	if d ~= "=" then return Private.f2t(a,b,c,d) 
	elseif c ~= "=" then
		s = Private.f64[a]*1024 + Private.f64[b]*16 + Private.f64[c]/4
		cb = s % 256
		ca = (s - cb)/256
		return string_char(ca, cb)
	else
		s = Private.f64[a]*4 + Private.f64[b]/16 
		ca = s % 256
		return string_char(ca)
	end
end

-----------------------------------------------------------------------------
-- Break a string in lines of equal size
-- Input 
--   data: string to be broken 
--   eol: end of line marker
--   width: width of output string lines
-- Returns
--   string broken in lines
-----------------------------------------------------------------------------
function Encoding.split(data, eol, width)
    width = width or (Encoding.LINEWIDTH - string.len(eol) + 2)
    eol = eol or "\r\n"
	-- this looks ugly,  but for lines with less  then 200 columns,
	-- it is more efficient then using strsub and the concat module
	local line = "(" .. string.rep(".", width) .. ")"
    local repl = "%1" .. eol
	return string_gsub(data, line, repl)
end

-----------------------------------------------------------------------------
-- Encodes a string into its base64 representation
-- Input 
--   s: binary string to be encoded
--   single: single line output?
-- Returns
--   string with corresponding base64 representation
-----------------------------------------------------------------------------
function Encoding.base64(s, single)
	local pad, whole
	local l = string.len(s)
	local m = (l % 3)
	l = l - m
	if l > 0 then 
        whole = string_gsub(string_sub(s, 1, l), "(.)(.)(.)", Private.t2f)
	else whole = "" end
	if m > 0 then pad = Private.to64pad(string_sub(s, l+1))
	else pad = "" end
	if single then return whole .. pad
	else return Encoding.split(whole .. pad, 76) end
end

-----------------------------------------------------------------------------
-- Decodes a string from its base64 representation
-- Input 
--   s: base64 string
-- Returns
--   decoded binary string
-----------------------------------------------------------------------------
function Encoding.unbase64(s)
    -- clean string
	local f64 = Private.f64
	s = string_gsub(s, "(.)", function (c) 
		if f64[c] then return c
		else return "" end
	end)
	local l = #s
	local whole, pad
	if l > 4 then 
        whole = string_gsub(string_sub(s, 1, -5), "(.)(.)(.)(.)", Private.f2t)
	else whole = "" end
	pad = Private.from64pad(string_sub(s, -4))
	return whole .. pad
end

local mac_string;

local function get_mac_string()
	if(not mac_string) then
		mac_string = ParaEngine.GetAttributeObject():GetField("MaxMacAddress","")
	end
	return mac_string;
end

-- encode with mac address. 
function Encoding.PasswordEncodeWithMac(text)
	if(text) then
		local mac_key = get_mac_string();
		return ParaMisc.SimpleEncode(string.format("{%q,%q}", mac_key, text))
	end
end

-- return nil if mac address does not match with the local one. 
function Encoding.PasswordDecodeWithMac(text)
	if(text) then
		text = ParaMisc.SimpleDecode(text)
		if(text:match("^{.*}$")) then
			local tmp = NPL.LoadTableFromString(text);
			if(tmp) then
				if(tmp[1] == get_mac_string() and tmp[2]) then
					return tmp[2];
				else
					-- mac address mismatch
					return;
				end
			end
		end
		return text;
	end
end

-- used in poweritem api ChangeItem. 
-- @param input:either string or table. 
-- @return the server data string or nil.
function Encoding.EncodeServerData(input)
	if(type(input) == "table") then
		-- input = commonlib.serialize_compact(input);
		input = commonlib.Json.Encode(input);
	end
	if(type(input) == "string") then
		input = string_gsub(input,",","@");
		input = string_gsub(input,"|","#");
		input = string_gsub(input,"~","*");
		return input;
	end
end

function Encoding.DecodeServerData(input)
	if(type(input) ~= "string" or input == "")then
		return
	end
	input = string_gsub(input,"@",",");
	input = string_gsub(input,"#","|");
	input = string_gsub(input,"*","~");
	--input = commonlib.LoadTableFromString(input);
	local parsed_serverdata = {};
	NPL.FromJson(input, parsed_serverdata);
	return parsed_serverdata;
end

function Encoding.EncodeServerDataString(input)
	if(type(input) == "string") then
		input = string_gsub(input,"[,|~]"," ");
	end
	return input
end

-- Decode an URL-encoded string
-- (Note that you should only decode a URL string after splitting it; this allows you to correctly process quoted "?" characters in the query string or base part, for instance.) 
function Encoding.url_decode(str)
	str = string_gsub (str, "+", " ")
	str = string_gsub (str, "%%(%x%x)",
		function(h) return string.char(tonumber(h,16)) end)
	str = string_gsub (str, "\r\n", "\n")
	return str
end

-- URL-encode a string
function Encoding.url_encode(str)
	if (str) then
		str = string_gsub (str, "\n", "\r\n")
		str = string_gsub (str, "([^%w ])",
			function (c) return string.format ("%%%02X", string.byte(c)) end)
		str = string_gsub (str, " ", "+")
	end
	return str
end