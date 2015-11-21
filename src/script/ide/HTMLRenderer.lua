--[[
Title: A simple HTML renderer
Author(s): LiXizhi
Date: 2007/10/3
Desc: It only support formatting to the following tag and their attributes: h1, h2,h3, h4, li, img(attr: src,height, width, title), a(href), anyTag(attr: style="color: #006699; left: -60px; position: relative; top: 30px;width: 100px;height: 100px"),title
It also support relative image path as well as HTTP file path. In addition to per tag css, it also support global CSS via a table called css during initialization.
All images are displayed on the left block, where all text are displayed in the right block. images is aligned vertically at the its normal text flow position. 
Note1: the HTML must use ansi encoding. Unicode or UTF8 encoding will render Chinese text unreadable.
Note2: all HTML tag and attribute must use lower case.
Note3: we can use tag css to position a text or image any where relative to its normal text flow. We can also specify fixed block size. 
Example file: script/test/testHTMLrenderer.html
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/HTMLRenderer.lua");
local ctl = CommonCtrl.GetControl("HTMLRenderer1");
if(not ctl) then
	ctl = CommonCtrl.HTMLRenderer:new{
		name = "HTMLRenderer1",
		alignment = "_lt",
		left=0, top=0,
		width = 512,
		height = 290,
		parent = _parent,
		source = "script/test/TestHTMLRenderer.html"
	};
end	
ctl:Show();

-- call to load another source
-- ctl:LoadFile("readme.html", true);

-- call to unload resources
-- ctl:Unload()
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local HTMLRenderer = {
	-- the top level control name
	name = "HTMLRenderer1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 400, 
	-- the fixed text width. the remaining is the image bar width. By default it is 0.6 of the total width
	TextWidth = nil,
	parent = nil,
	-- HTML file path, it also support pure txt file. 
	source = nil,
	-- HREF link callback, it should be a function of type function(href) end, where href is the string. If this function is not provided, a default function is used.
	HRefLinkCallback = nil,
	-- TODO: shall we implement some css in HTML, so that we can set default h1, etc tag style
	css = {
		["title"] = {
			scaling = 1.2,
			indent = -20,
		},
		["h1"] = {
			scaling = 1.2,
			indent = -5,
			headimage = "Texture/unradiobox.png",
			headimagewidth = 16,
		},
		["h2"] = {
			scaling = 1.15,
			indent = -5,
			headimage = "Texture/unradiobox.png",
			headimagewidth = 16,
		},
		["h3"] = {
			scaling = 1.1,
			indent = -5,
			headimage = "Texture/unradiobox.png",
			headimagewidth = 16,
		},
		["h4"] = {
			scaling = 1.1,
			indent = 0,
			headimage = "Texture/unradiobox.png",
			headimagewidth = 16,
		},
		["li"] = {
			scaling = 1,
			indent = 3,
			headimage = "Texture/unradiobox.png",
			headimagewidth = 8,
		},
		["Text"] = {
			scaling = 1,
			indent = -10,
		},
		["a"] = {
			scaling = 1,
			color = "0 0 255",
		},
	},
}
CommonCtrl.HTMLRenderer = HTMLRenderer;

-- constructor
function HTMLRenderer:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function HTMLRenderer:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function HTMLRenderer:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("HTMLRenderer instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background="";
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);
		
		if(not self.TextWidth) then
			local _,_,width, _ = _parent:GetAbsPosition();
			self.TextWidth = 0.6*width;
		end
		
		-- this invisible control is used for text block size calculating using a given font. 
		_this = ParaUI.CreateUIObject("text", "size", "_lt", 0, 0, self.TextWidth, 16);
		_this.visible = false;
		_parent:AddChild(_this);
		
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.TreeView:new{
			name = self.name.."HTMLTreeView",
			rendererName = self.name,
			alignment = "_fi",
			left = 0,
			top = 0,
			width = 0,
			height = 0,
			TextWidth = self.TextWidth,
			SourceDir = "",
			parent = _parent,
			DefaultIndentation = 5,
			DefaultNodeHeight = 22,
			DrawNodeHandler = CommonCtrl.HTMLRenderer.DrawHTMLNodeHandler,
			css = self.css or CommonCtrl.HTMLRenderer.css,
			-- loaded images, <"name", true> pairs. one can then call Unload to unload all used images 
			UsedImages = {},
		};
		ctl:Show();
		
		-- load the source file.
		self:LoadFile(self.source, true)
	else
		if(bShow == nil) then
			bShow = not _this.visible;
		end
		_this.visible = bShow;
	end	
end

-- load a file to memory and display it.
-- @param bReload: true to reload
function HTMLRenderer:LoadFile(source, bReload)
	if(not bReload and self.source == source) then
		return;
	end
	self.source = source;
	
	local ctl = CommonCtrl.GetControl(self.name.."HTMLTreeView");
	if(ctl == nil)then
		log("err getting HTMLTreeView instance"..self.name.."\r\n");
		return;
	end
	local _this=ParaUI.GetUIObject(self.name);
	local sizeUI;
	if(_this:IsValid()) then
		sizeUI = _this:GetChild("size");
	end
	if(not sizeUI or not sizeUI:IsValid()) then
		log("HTML renderer size control is not found \r\n");
	end
	-- set source directory:so that we use it for relative path calculation
	ctl.SourceDir = string.gsub(source, "[^/\\]+$", "");
	self.SourceDir = ctl.SourceDir;
	
	-- rebuild HTML nodes
	ctl.RootNode:ClearAllChildren();
	local x = ParaXML.LuaXML_ParseFile(self.source);
	--log(ctl.SourceDir.."\n")
	--log(commonlib.serialize(x));
	CommonCtrl.HTMLRenderer.BuildHTML(x, ctl.RootNode, sizeUI);
	ctl:Update();
end

-- unload all resources used by this ctl
function HTMLRenderer:Unload()
	local ctl = CommonCtrl.GetControl(self.name.."HTMLTreeView");
	if(ctl == nil)then
		log("err getting HTMLTreeView instance"..self.name.."\r\n");
		return;
	end
	local k, v;
	for k,v in ipairs(ctl.UsedImages) do
		--log(k.." of HTML texture is unloaded \n")
		ParaAsset.LoadTexture("",k,1):UnloadAsset();
	end
end

-- private: build internal treeview node to display a table. 
-- @param o: the current xml table
-- @param treeNode: to which treeview node the content is saved to.
-- @param sizeUI: the UI object to calculate size of the UI control 
-- @param style: nil or a table containing style{color=string, href=string}. This is a style object to be associated with each node.
function HTMLRenderer.BuildHTML(o, node, sizeUI, style)
	local function GetTextHeight(text, tagName)
		sizeUI.text = text;
		sizeUI:DoAutoSize();
		local height = sizeUI.height;
		local css = node.TreeView.css[tagName];
		if(css~=nil) then
			if(css.scaling~=nil) then
				height = height *css.scaling;
			end	
		end
		return (height+6); -- assuming spacing is 3
	end
	local height;
	if (type(o) == "table") then
		local ParseChild;
		local tagName = string.lower(o.name or "");
		-- clone and merge new style if the node has css style property
		if(o.attr and o.attr.style) then
			style = CommonCtrl.HTMLRenderer.NewStyle(style, o.attr.style);
		end
		-- use the height in css
		if(style) then
			height = style.height;
			--log(tagName..commonlib.serialize(style).."\n")
		end
		if(tagName == "h1" or tagName == "h2" or tagName == "h3" or tagName == "h4" or tagName == "li" or tagName == "title") then
			-- we will use slightly different formating to display header.
			local text = CommonCtrl.HTMLRenderer.HTMLGetAllTextInTable(o);
			if(o.attr and o.attr.height~=nil) then
				height = o.attr.height;
			end
			node:AddChild( CommonCtrl.TreeNode:new({Text = text, Name = tagName, attr=o.attr, style=style, NodeHeight = height or GetTextHeight(text, tagName) }) );
		elseif(tagName == "img") then
			-- image tag always has zero height.
			local text = CommonCtrl.HTMLRenderer.HTMLGetAllTextInTable(o);
			node:AddChild( CommonCtrl.TreeNode:new({Text = text, Name = tagName, attr=o.attr, style=style, NodeHeight = height or 3}) );
		elseif(tagName == "a") then	
			if(o.attr and o.attr.href) then
				if(not o.attr.style) then
					style = CommonCtrl.HTMLRenderer.NewStyle(style, o.attr.style);
				end	
				style.href = o.attr.href;
			end
			ParseChild = true;
		else
			ParseChild = true;
		end
		if(ParseChild) then
			-- add further node
			local k,v
			for k,v in ipairs(o) do
				CommonCtrl.HTMLRenderer.BuildHTML(v, node, sizeUI, style);
			end
		end
	elseif (type(o) == "string" and o ~= "") then
		local tagName = "Text";
		-- use the height in css
		if(style) then
			height = style.height;
			--log(tagName..commonlib.serialize(style).."\n")
		end
		node:AddChild( CommonCtrl.TreeNode:new({Text = o, Name = tagName, style=style, NodeHeight = height or GetTextHeight(o, tagName) }) );
	end
end

-- private: retrieve and concartinate all text in the HTML table o, ignoring all tag or hierachies.
-- e,g, "<h1>hello <font> LiXizhi</font> !</h1>" will "return hello LiXizhi !" as a string. 
function HTMLRenderer.HTMLGetAllTextInTable(o)
	local str = "";
	if (type(o) == "table") then
		local k,v
		for k,v in ipairs(o) do
			str = str..CommonCtrl.HTMLRenderer.HTMLGetAllTextInTable(v);
		end
	elseif (type(o) == "string") then
		str = o;
	end
	return str;
end

-- private: create a new copy of style object. 
-- @param baseStyle: nil or a table containing styles. 
-- @param cssStyle: nil or a string of css style, such as "color = #006699;"
-- @return: The new style returned will copy all attribute of baseStyle and overriding it by cssStyle
function HTMLRenderer.NewStyle(baseStyle, cssStyle)
	local style = {}   -- create object if user does not provide one
	if(type(baseStyle) == "table") then
		local k,v
		for k,v in pairs(baseStyle) do
			style[k] = v;
		end
	end	
	if(cssStyle~=nil) then
		local name, value;
		for name, value in string.gfind(cssStyle, "(%a+)%s*:%s*([^;%s]*)[;]?") do
			name = string.lower(name);
			if(name == "height" or name == "left" or name == "top" or name == "width") then
				local _, _, cssvalue = string.find(value, "([%+%-]?%d+)");
				if(cssvalue~=nil) then
					value = tonumber(cssvalue);
				else
					value = nil;
				end
			end
			style[name] = value;
			--log(name..":"..value.."\n");
		end
	end
	return style;
end


-- close the given control
function HTMLRenderer.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting HTMLRenderer instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end

-- when user clicked an href node. possibly open with an external browser.
function HTMLRenderer.OnClickHRefNode(sCtrlName, href)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting HTMLRenderer instance "..sCtrlName.."\r\n");
		return;
	end
	if(not self.HRefLinkCallback) then
		self:DefaultHRefLinkCallback(href)
	else
		self.HRefLinkCallback(href)
	end
end
-- default handler when user click href node.
function HTMLRenderer:DefaultHRefLinkCallback(href)
	if(string.find(href, "http://")~=nil) then
		-- for absolute path, we will open externally.
		_guihelper.MessageBox("是否用外部浏览器打开:\n"..href, string.format([[ParaGlobal.ShellExecute("open", "iexplore.exe", %q, "", 1);]], href));
	else
		-- for relative path, we will open locally.
		self:LoadFile(self.SourceDir..href);
	end
end

-- default node renderer: it display a clickable check box for expandable node, followed by node text
function HTMLRenderer.DrawHTMLNodeHandler(_parent,treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local ClientWidth = treeNode.TreeView.ClientWidth;
	local TextWidth = treeNode.TreeView.TextWidth;
	local maxImageWidth = ClientWidth - TextWidth -20;
	local top = 0;
	local href;
	
	if(treeNode.Text ~= nil) then
		--log(treeNode.Text..ClientWidth.." "..tostring(treeNode.NodeHeight).."\n")
		-- style parse here
		local left = 0;
		local fontcolor = nil;
		if(treeNode.style) then
			if(treeNode.style.color) then
				fontcolor = treeNode.style.color;
			end
			--if(treeNode.style.position == "relative") then
				--log("css: position:relative");
				if(treeNode.style.left~=nil) then
					left = left + treeNode.style.left;
				end
				if(treeNode.style.top~=nil) then
					top = top + treeNode.style.top;
				end
			--end
			if(treeNode.style.href ~=nil) then
				href = treeNode.style.href;
			end	
		end	
			
		-- for each type of tag
		local tagName = treeNode.Name;
		if(tagName == "Text" or tagName == "h1" or tagName == "h2" or tagName == "h3" or tagName == "h4" or tagName == "li" or tagName == "title") then
			local scaling = 1;
			local headimagewidth = 16;
			local headimage = nil;
			
			-- get tag formatting from global css of the HTML page
			local css = treeNode.TreeView.css[tagName];
			if(css~=nil) then
				if(css.scaling~=nil) then
					scaling = css.scaling;
				end
				if(css.headimagewidth~=nil) then
					headimagewidth = css.headimagewidth;
				end
				if(css.headimage~=nil) then
					headimage = css.headimage;
				end
				if(css.indent~=nil) then
					left = left + css.indent;
				end
			end
			local offsetX = TextWidth/2*(scaling-1);
			local offsetY = treeNode.NodeHeight/2*(scaling-1);
			
			if(headimage~=nil) then
				_this=ParaUI.CreateUIObject("button","b","_lt", ClientWidth - TextWidth-headimagewidth+left-(2*offsetX)-2, top+offsetY, headimagewidth, headimagewidth);
				_this.background=headimage;
				--_guihelper.SetUIColor(_this, "255 255 255");
				_parent:AddChild(_this);
			end	
		
			if(href~=nil) then
				_this=ParaUI.CreateUIObject("button","b","_lt", ClientWidth - TextWidth+left-offsetX, top+offsetY ,TextWidth, treeNode.NodeHeight);
				_this.background="";
				_this.onclick = string.format(";CommonCtrl.HTMLRenderer.OnClickHRefNode(%q, %q)", treeNode.TreeView.rendererName, href);
				_this.tooltip = "点击打开:"..href;
				_this.animstyle = 11;
				_guihelper.SetUIFontFormat(_this, 16);
				if(fontcolor == nil) then
					-- use default link css color if user does not provide one
					if(treeNode.TreeView.css["a"]~=nil and treeNode.TreeView.css["a"].color~=nil)then
						fontcolor = treeNode.TreeView.css["a"].color;
					end
				end
			else
				_this=ParaUI.CreateUIObject("text","b","_lt", ClientWidth - TextWidth+left-offsetX, top+offsetY,TextWidth, 18);
			end	
			if(scaling~=1) then
				_this.scalingx = scaling;
				_this.scalingy = scaling;
			end	
			_this.text = treeNode.Text;
			if(fontcolor~=nil)then
				_guihelper.SetFontColor(_this, fontcolor);
			end
			_parent:AddChild(_this);
			
		elseif(tagName == "img") then
			-- image tag always has zero height.
			local width = maxImageWidth;
			local height = width*0.75;
			local title;
			local src;
			if(treeNode.attr) then
				width = tonumber(treeNode.attr.width or width);
				height = tonumber(treeNode.attr.height or height);
				src = treeNode.attr.src;
				if(src ~=nil and not string.find(src, "http://")) then
					src = treeNode.TreeView.SourceDir..src;
				end
				if(treeNode.attr.title~=nil) then
					title = treeNode.attr.title;
				end
			end
			-- ensure that the image is always displayed within the left bar
			if(width > maxImageWidth) then
				height = height*maxImageWidth/width;
				width = maxImageWidth;
			end
			-- the image size in style took precedence
			if(treeNode.style.width) then 	width = treeNode.style.width	end
			if(treeNode.style.height) then	height = treeNode.style.height	end
			
			if(title~=nil) then
				_this=ParaUI.CreateUIObject("text","b","_lt", ClientWidth - TextWidth-width-40+left, top ,width, 18);
				_this.text = title;
				_guihelper.SetUIFontFormat(_this, 2+32+256);
				if(fontcolor~=nil)then
					_guihelper.SetFontColor(_this, fontcolor);
				end
				_parent:AddChild(_this);
				top = top+20;
			end
			if(src) then
				_this=ParaUI.CreateUIObject("button","b","_lt", ClientWidth - TextWidth-width-20+left, top, width, height);
				_this.enabled = false;
				_this.background = src;
				_guihelper.SetUIColor(_this, "255 255 255");
				_parent:AddChild(_this);
				_this:UpdateRect();
				
				-- add image to image pool so that we can unload them later. Remove modifer string from src of course
				treeNode.TreeView.UsedImages[string.gsub(src, "[:;][^/].*$", "")] = true;
			end	
			--log("images: "..tostring(src).."\n");
		end
	end
end
