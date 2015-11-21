--[[
Title: 
Author(s): Leio
Date: 2010/5/12
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/IPCClassBuilder.lua");
------------------------------------------------------
--]]
local IPCClassBuilder = commonlib.gettable("IPCBinding.IPCClassBuilder");
--把npl类型转换为c#类型
function IPCClassBuilder.NPLToCShrapType(type)
	if(not type)then return end
	local csharp_type = "";
	if(type == "string")then
		csharp_type = "string";
	elseif(type == "number")then
		csharp_type = "double";
	elseif(type == "boolean")then
		csharp_type = "bool";
	elseif(type == "table")then
		csharp_type = "XmlElement";
	end
	return csharp_type;
end
function IPCClassBuilder.ParseCtor(classTitle,args)
	if(not classTitle or not args)then return end;
	local k,v;
	local lines_args = "";
	local lines = "";
	for k,v in ipairs(args) do
		local prop = v.prop;
		local prop_name = v.prop_name;
		local line_args;
		local line;
		if(k == 1)then
			line_args = string.format("%s _%s",prop,prop_name);
		else
			line_args = string.format(",%s _%s",prop,prop_name);
		end
		lines_args = lines_args .. line_args;
		line = string.format("this._%s = _%s;",prop_name,prop_name);
		lines = lines .."\r\n".. line;
	end
	local r = string.format([[
	public %s() {}
	public %s(%s) {
	%s
	}
	]],classTitle,classTitle,lines_args,lines);
	return r;
end
function IPCClassBuilder.ParseUpdateValueFunction(classTitle,args)
	if(not classTitle or not args)then return end;
		local k,v;
	local lines_args = "";
	local lines = "";
	for k,v in ipairs(args) do
		local prop = v.prop;
		local prop_name = v.prop_name;
		--obj 是个固定的变量名
		local line = string.format([[
		if(this._%s != obj.%s)
		{
			this._%s = obj.%s;
			OnPropertyQuietChanged(new PropertyChangedEventArgs("%s"));
		}
		]],prop_name,prop_name,prop_name,prop_name,prop_name);
		lines = lines .."\r\n".. line;
	end
	local r = string.format([[
	public override void UpdateValue(IBindableObject _obj)
			{
				%s obj = _obj as %s;
				if (obj == null)
				{
					return;
				}
			%s
			}
	]],classTitle,classTitle,lines);
	return r;
end
--[[
local args = {
	--c#属性名称
	prop_name = label, 
	--c#属性类型
	prop = csharp_type, 
	--npl属性类型的描述
	npl_props = { 
			label = "uid", 
			type = "string",
			category = "test category", 
			desc = "description", 
			editor="System.Drawing.Design.UITypeEditor", 
			converter="System.ComponentModel.TypeConverter",
		
		},
}
--]]
function IPCClassBuilder.ParseProperty(args)
	if(not args)then return end;
	local k,v;
	local result = "";
	for k,v in ipairs(args) do
		local prop = v.prop;
		local prop_name = v.prop_name;
		local npl_props = v.npl_props;
		local r;
		local category;
		local desc;
		local editor, editor_attribute;
		local converter;
		function clearSpace(s,bSub)
			if(not s or type(s) ~= "string")then return end
			if(bSub)then
				s = string.gsub(s,"%s","");
			end
			if(s ~= "")then
				return s;
			end
		end
		if(npl_props)then
			category = clearSpace(npl_props.category);
			desc = clearSpace(npl_props.desc);
			editor = clearSpace(npl_props.editor,true);
			editor_attribute = npl_props.editor_attribute;
			converter = clearSpace(npl_props.converter,true);

			if(category)then
				category = string.format('[Category("%s")]',category);
			end
			if(desc)then
				desc = string.format('[Description("%s")]',desc);
			end
			if(editor)then
				editor = string.format("[Editor(typeof(%s),typeof(System.Drawing.Design.UITypeEditor))]",editor);
			end
			if(converter)then
				converter = string.format("[TypeConverter(typeof(%s))]",converter);
			end
		end
		category = category or "";
		desc = desc or "";
		editor = editor or "";
		converter = converter or "";
		editor_attribute = editor_attribute or "";
		
		if(prop_name == "uid" or prop_name == "worldfilter" or prop_name == "template_file")then
			r = string.format([[
			private %s _%s;
				%s
				%s
				%s
				%s
				public override %s %s
				{
				
					get { return _%s; }
					set
					{
						_%s = value;
						OnPropertyChanged(new PropertyChangedEventArgs("%s"));
					}
				}]],prop,prop_name,category,desc,editor,converter,prop,prop_name,prop_name,prop_name,prop_name);
		else

			r = string.format([[
			private %s _%s;
				%s
				%s
				%s
				%s
				%s
				public %s %s
				{
					get { return _%s; }
					set
					{
						_%s = value;
						OnPropertyChanged(new PropertyChangedEventArgs("%s"));
					}
				}]],prop,prop_name,category,desc,editor_attribute, editor,converter,prop,prop_name,prop_name,prop_name,prop_name);
		end
		result = result..r;
	end
	return result;
end
function IPCClassBuilder.ParseClassBody(s)
	local __,__,line = string.find(s,[[%s-%[Class%((.-)%)%]%s-]]);
	local __,__,classTitle = string.find(line or "",[[label="(.-)"]]);
	local __,__,namespace = string.find(line or "",[[namespace="(.-)"]]);
	namespace = namespace or "PETools.World";
	
	local body;
	local csharp_args = {};
	for body in string.gfind(s,[[%s-%[Property%((.-)%)%]%s-]]) do
		
		local __,__,type = string.find(body,[[type="(.-)"]]);
		local __,__,label = string.find(body,[[label="(.-)"]]);
		
		if(type and label)then
			
		local csharp_type = IPCClassBuilder.NPLToCShrapType(type)
			table.insert(csharp_args,{prop_name = label, prop = csharp_type});
		end
	end
	return namespace,classTitle,csharp_args;
end
--通过解析lua文件中的注释来生成cs文件
function IPCClassBuilder.ParseClass(s)
	if(not s)then return end
	local namespace,classTitle,csharp_args = IPCClassBuilder.ParseClassBody(s);
	commonlib.echo({namespace,classTitle,csharp_args});
	return IPCClassBuilder.ParseClassByParams(namespace,classTitle,csharp_args)
end
--通过GetClassDescriptor()直接生成cs文件
-- @param class_attribute: C# class attribute string to be applied. 
function IPCClassBuilder.ParseClassByLuaParams(namespace,classTitle,props, class_attribute)
	namespace = namespace or "PETools.World";
	if(not namespace or not classTitle or not props)then return end
	local classTitle = classTitle.label;
	local k,v;
	local csharp_args = {};
	for k,v in ipairs(props) do
		local type = v.type;
		local label = v.label;

		if(type and label)then
			
			local csharp_type = IPCClassBuilder.NPLToCShrapType(type)
			table.insert(csharp_args,{
				--c#属性名称
				prop_name = label, 
				--c#属性类型
				prop = csharp_type, 
				--npl属性类型的描述
				npl_props = v,
				});
		end
	end
	return IPCClassBuilder.ParseClassByParams(namespace,classTitle,csharp_args, class_attribute);
end
function IPCClassBuilder.ParseClassByParams(namespace,classTitle,csharp_args, class_attribute)
	namespace = namespace or "PETools.World";
	if(not namespace or not classTitle or not csharp_args)then return end
    local ctor = IPCClassBuilder.ParseCtor(classTitle,csharp_args)
    local props = IPCClassBuilder.ParseProperty(csharp_args)
    local updateFunc = IPCClassBuilder.ParseUpdateValueFunction(classTitle,csharp_args)
    
	local r = string.format([[
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Media3D;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.ComponentModel;
using System.Xml;
using System.Xml.Serialization;
using System.Collections;
using System.Drawing.Design;

using PETools.World.TypeConverter;
using PETools.EntityTemplates.Buildin;

namespace %s
{
	%s
	public class %s : IBindableObject
	{
	   %s
	   %s
	   %s
	}
}
		]],namespace,class_attribute or "", classTitle,ctor or "",props or "",updateFunc or "");
		return r;
end