--[[
Title: flash external interface
Author(s): LiXizhi, leio
Date: 2009/8/20
use the lib: wrapper functions for invocation between flash and NPL script.
Flash uses XML for passing data. These wrapper functions provides translation between XML and native NPL tables. 
------------------------------------------------------------
NPL.load("(gl)script/ide/FlashExternalInterface.lua");
commonlib.test_deserialize_tonpl();
commonlib.test_serialize_toflash();
-------------------------------------------------------
]]
--[[ when a flash script invokes a method, this function will be called with the input decription. 
Use SetFlashReturnValue() to set return value to flash script
@param flash_player_index: the flash player index. 
@param input: such as <invoke name="SomeFunction" returntype="xml"><arguments></arguments></invoke>
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/XPath.lua");

local tostring = tostring
local tonumber = tonumber
local type = type
local format = format;

function commonlib.flash_call_back(flash_player_index, input)
	local flash_player = ParaUI.GetFlashPlayer(flash_player_index);
	if(flash_player:IsValid()) then
		--把flash funciton(args...) 转换成 npl funciton 的描述， 包含函数名称 和 参数列表
		local func_args = commonlib.deserialize_tonpl_function(input)
		
		local funcName = func_args.funcName;--函数名称
		local args_result = func_args.args;--参数列表
		--commonlib.echo("====funcName");
		--commonlib.echo(funcName);
		--commonlib.echo(args_result);
		--判断funcName域是否存在
		if(not commonlib.getfield(funcName))then return end
		--转换成npl参数列表
		local args = "";
		if(args_result)then
			local k,arg;
			for k,arg in ipairs(args_result) do
				if(k == 1)then
					args = commonlib.serialize(arg)
				else
					args = args..","..commonlib.serialize(arg)
				end
			end
		end
		local sFunc = format("%s(%s)",funcName,args)
		--commonlib.echo("====sFunc");
		--commonlib.echo(sFunc);
		--执行npl函数
		NPL.DoString(sFunc);
		
		--serialize_toflash_function
		local toflash_finished = commonlib.serialize_toflash_internal("flash_call_back_finished");
		
		-- 通知flash npl函数执行完毕
		--目前所有的callback返回值都是这个"flash_call_back_finished"
		flash_player:SetFlashReturnValue(toflash_finished);
		--flash_player:SetFlashReturnValue("<string>This is from NPL script: script/ide/FlashExternalInterface.lua</string>");
	end
end

-- invoke flash function
--[[
local input = {
		funcName = "functionName",--函数名称
		args = { "first_string", { [0]={  }, 0, 1, [4]=true, [5]={ key="a" } } }--参数列表
	}
--]]
function commonlib.CallFlashFunction(flash_player_index, input)
	local flash_player = ParaUI.GetFlashPlayer(flash_player_index);
	if(flash_player:IsValid()) then
		--转换成flash function(arg1...)
		local toflash_function = commonlib.serialize_toflash_function(input);
		--执行flash function
		local result = flash_player:CallFlashFunction(toflash_function);
		--把flash的返回值转换成npl内置类型
		result = commonlib.deserialize_tonpl_onlydatatype(result)
		return result;
	end
end

-- 把table转换成xml形式的字符串
--@param funcName:函数名称
--@param args:参数列表
--[[
local func_args = {
		funcName = "functionName",
		args = { "first_string", { [0]={  }, 0, 1, [4]=true, [5]={ key="a" } } },
	}
--]]
function commonlib.serialize_toflash_function(func_args)
	if(not func_args)then return end
	local funcName = func_args.funcName;
	local args = func_args.args;
	if(not funcName or not args)then return end
	local s = "";
	if(type(args) == "table")then
		local k;
		local len = table.getn(args);
		for k = 1,len do
			local v = args[k];
			--commonlib.echo(k);
			--commonlib.echo(v);
			s = s..commonlib.serialize_toflash_internal(v);
		end
	else
		s = commonlib.serialize_toflash_internal(args)
	end
	s = string.format([[<invoke name="%s" returntype="xml"><arguments>%s</arguments></invoke>]],funcName,s);
	return s;
end
--把npl内置类型转换成flash内置类型的描述,支持：table,number,boolean
--注意：目前table的转换不支持 index和key混合使用，如果t = {"index",["key1" = 0]},将会被转换成两个对象array and object
--在使用table的时候，最好是其中一种
-- {first_string} --> array><property id="0"><string>first_string</string></property></array>
--如果是index类型，里面的值不能是nil
function commonlib.serialize_toflash_internal(o)
	local type_ = type(o);
	if type_ == "number" then
		local s = format("<number>%s</number>",tostring(o));
		return s;
	elseif type_ == "nil" then
		return ("<null/>")
	elseif type_ == "string" then
		if(o == "__nil__")then
			return ("<null/>")
		end
		local s = format("<string>%s</string>",o);
		return s;
	elseif type_ == "boolean" then	
		if(o) then
			return "<true/>"
		else
			return "<false/>"
		end
	elseif type_ == "function" then
		return ""--不支持function
	elseif type_ == "userdata" then
		return ("")--不支持userdata
	elseif type_ == "table" then
		local hasIndex = false;
		--判断是否有index pairs
		local k,v;
		for k,v in ipairs(o) do
			hasIndex = true;
			break;
		end
		local str_array = "";
		if(hasIndex)then
			str_array = "<array>"
			local k,v
			--index
			for k,v in ipairs(o) do
				local property = format([[<property id="%s">]],k-1);
				local value = commonlib.serialize_toflash_internal(v);
				str_array = str_array..property..value.."</property>"
			end
			str_array = str_array.."</array>";
		end
		--判断时候有key pairs
		local hasKey = false;
		local k,v;
		for k,v in pairs(o) do
			if(type(k) == "string")then
				hasKey = true;
				break;
			end
		end
		--key
		local str_object = ""
		if(hasKey)then
			str_object = "<object>"
			local k,v
			for k,v in pairs(o) do
				if(type(k) == "string")then
					local property = format([[<property id="%s">]],k);
					local value = commonlib.serialize_toflash_internal(v);
					str_object = str_object..property..value.."</property>"
				end
			end
			str_object = str_object.."</object>";
		end
		return str_array..str_object;
	else
		LOG.std("", "warn", "FlashExternal", "--cannot serialize a " .. type_)
	end
end
----------------------------------------------------
--parse function 把xml形式的字符串转换成table
----------------------------------------------------
commonlib.bool_deserialize_tonpl = {};
function commonlib.bool_deserialize_tonpl.create(mcmlNode)
	if(not mcmlNode)then return end
	local value = mcmlNode.name;
	if(value == "true")then
		return true;
	else
		return false;
	end
end
commonlib.string_deserialize_tonpl = {};
function commonlib.string_deserialize_tonpl.create(mcmlNode)
	if(not mcmlNode)then return end
	local value = mcmlNode[1];
	return tostring(value);
end
commonlib.number_deserialize_tonpl = {};
function commonlib.number_deserialize_tonpl.create(mcmlNode)
	if(not mcmlNode)then return end
	local value = mcmlNode[1];
	return tonumber(value);
end
commonlib.object_deserialize_tonpl = {};
function commonlib.object_deserialize_tonpl.create(mcmlNode)
	if(not mcmlNode)then return end
	local result = {};
	local node;
	for node in mcmlNode:next() do
		local ctl = commonlib.flash_type_mapping[node.name];
		if (ctl and ctl.create) then
			ctl.create(node,result);
		end
	end
	return result;
end
commonlib.property_deserialize_tonpl = {};
function commonlib.property_deserialize_tonpl.create(mcmlNode,result)
	if(not result or not mcmlNode)then return end
	local id = mcmlNode:GetNumber("id");
	--如果是number,则认为是从数组解析，因为正常数组索引是从0开始，而table索引是从1开始，所以+1
	if(id)then
		id = id + 1;
	end
	--如果是string,则认为是从Hashtable解析
	if(not id)then
		id = mcmlNode:GetString("id");
	end
	local node;
	for node in mcmlNode:next() do
		local ctl = commonlib.flash_type_mapping[node.name];
		if (ctl and ctl.create) then
			local value = ctl.create(node);
			result[id] = value;
		end
	end
end
commonlib.flash_type_mapping = {
	["true"] = commonlib.bool_deserialize_tonpl,
	["false"] = commonlib.bool_deserialize_tonpl,
	["string"] = commonlib.string_deserialize_tonpl,
	["number"] = commonlib.number_deserialize_tonpl,
	["array"] = commonlib.object_deserialize_tonpl,
	["object"] = commonlib.object_deserialize_tonpl,
	["property"] = commonlib.property_deserialize_tonpl,
}
--把flash的一个函数和参数转换成table
--[[
funciton funcName(arg1,arg2...) -->
local func_args = {
			funcName = "funcName",--函数名称
			args = {arg1,arg2},--参数列表
		}
--]]
function commonlib.deserialize_tonpl_function(value)
	if(not value or type(value) ~= "string")then return end
	local xmlRoot = ParaXML.LuaXML_ParseString(value);
	local args_result = {};
	local func_result;
	if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
		
		xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
		xmlRoot = xmlRoot[1];
		-- invoke function name
		func_result = xmlRoot:GetString("name");
		
		--commonlib.echo(xmlRoot);
		local rootNode;
		for rootNode in commonlib.XPath.eachNode(xmlRoot, "//arguments") do
			if(rootNode) then
				local node;
				for node in rootNode:next() do
					local ctl = commonlib.flash_type_mapping[node.name];
					if (ctl and ctl.create) then
						local value = ctl.create(node);
						table.insert(args_result,value);
					end
				end
			end
		end		
	end
	local func_args = {
			funcName = func_result,
			args = args_result,
		}
	return func_args;
end

--@param value:flash 某个内置类型的xml形式描述 ,支持的内置类型：array,number,boolean,object,string
--<array><property id="0"><string>first_string</string></property></array> -->{first_string}
--return : array,object -->table number,boolean,string --> number,boolean,string
function commonlib.deserialize_tonpl_onlydatatype(value)
	if(not value or type(value) ~= "string")then return end
	local xmlRoot = ParaXML.LuaXML_ParseString(value);
	if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
		
		local rootNode = Map3DSystem.mcml.buildclass(xmlRoot);
		rootNode = rootNode[1];
		local ctl = commonlib.flash_type_mapping[rootNode.name];
		if (ctl and ctl.create) then
			local value = ctl.create(rootNode);
			return value;
		end
	end
end
function commonlib.test_deserialize_tonpl()
	local value = [[
	<invoke name="functionName" returntype="xml">
<arguments>
<string>first_string</string>
<array>
	<property id="0">
	<array></array>
	</property>
	<property id="1">
	<number>0</number>
	</property>
	<property id="2">
	<number>1</number>
	</property>
	<property id="3">
	<number>NaN</number>
	</property>
	<property id="4">
	<true/>
	</property>
	<property id="5">
	<object>
	<property id="key">
	<string>a</string>
	</property>
	</object>
	</property>
	<property id="6">
	<null/>
	</property>
</array>
</arguments>
</invoke>
	]];
	local r = commonlib.deserialize_tonpl_function(value);
	commonlib.echo(r);
end
function commonlib.test_serialize_toflash()
	local func_args = {
		funcName = "functionName",
		args = { "first_string", { [0]={  }, 0, 1, [4]=true, [5]={ key="a" } } },
	}
	commonlib.echo(func_args);
	local s = commonlib.serialize_toflash_function(func_args);
	commonlib.echo(s);
	local r = commonlib.deserialize_tonpl_function(s);
	commonlib.echo(r);
end